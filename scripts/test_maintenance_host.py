"""CLI precedence, optimized validation and capture identity regressions."""
import copy,importlib.util,json,os,shutil,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'work'));sys.path.insert(0,str(ROOT/'scripts'))
from run_release_tests import copy_package
from mode8 import provenance
from mode8.build import load,validate
from mode8.navigation import heading

def rejected(fn,code):
    try:fn()
    except ValueError as error:assert code in str(error),str(error)
    else:raise AssertionError('Invalid evidence/input accepted')

def cli(sdk,path,args,ok=True):
    mode8='-GraphicsMode' in args and args[args.index('-GraphicsMode')+1]=='8'
    extra=[] if mode8 else ['-SkipCmdUpdate','-NoFpsOverlay']
    command=[shutil.which('pwsh'),'-NoProfile','-File',str(sdk/'work/build-3Dvibe64.ps1'),'-SceneFile',str(path),*args,*extra]
    p=subprocess.run(command,cwd=sdk,capture_output=True,text=True)
    assert (p.returncode==0)==ok,(command,p.stdout+p.stderr)
    return p

def config(temp):
    sdk=temp/'sdk';copy_package(ROOT,sdk)
    assert not (sdk/'.git').exists()
    assert (sdk/'work/build-3Dvibe64.ps1').read_bytes()==(ROOT/'work/build-3Dvibe64.ps1').read_bytes()
    basic=load(sdk/'examples/basic-solid-reference.json');basic.pop('contract',None)
    args=['-GraphicsMode','3','-CameraMode','fixed','-Quality','balanced','-Projection','table','-MemoryLayout','stable']
    cases=[('absent',copy.deepcopy(basic),[]),('contract-small',copy.deepcopy(basic),[]),('alias-small',copy.deepcopy(basic),[]),('cli-normal',copy.deepcopy(basic),['-CameraViewport','normal'])]
    for name,d,extra in cases:
        if name=='contract-small' or name=='cli-normal':d['contract']={'viewportProfile':'small'}
        if name=='alias-small':d['objectModel']={'viewportProfile':'small'}
        path=sdk/'examples'/f'maintenance-{name}.json';path.write_text(json.dumps(d))
        cli(sdk,path,args+extra)
        asm=(sdk/'work/3Dvibe64.asm').read_text()
        expected='$01' if name in ['contract-small','alias-small'] else '$00'
        assert 'CAMERA_VIEWPORT_SMALL = '+expected in asm
    bad=copy.deepcopy(basic);bad['contract']={'viewportProfile':'wide'}
    path=sdk/'examples/maintenance-invalid-viewport.json';path.write_text(json.dumps(bad));cli(sdk,path,args,False)
    textured=load(sdk/'examples/mode7-perspective-cube.json')
    # Keep a real relative PNG path through effective configuration resolution.
    png=load(sdk/'examples/mode7-cube-png.json')
    textured['textures']=png['textures'];path=sdk/'examples/maintenance-override-png.json';path.write_text(json.dumps(textured))
    args=['-GraphicsMode','7','-Precision','legacy','-TexturePrecision','affine','-MemoryLayout','high-basic-v2','-CameraViewport','normal','-Projection','extended-table','-Quality','fast']
    cli(sdk,path,args)
    prepared=load(sdk/'work/build/mode7-scene.json')
    assert prepared['texturePrecision']=='affine' and len(prepared['_mode7']['textures'][0]['texels'])==256
    cli(sdk,path,[v if v!='affine' else 'perspective' for v in args],False)
    invalid=load(sdk/'examples/mode8/two-levels.json');invalid['scene']['floor'][67]=32
    path=sdk/'examples/maintenance-invalid-mode8.json';path.write_text(json.dumps(invalid))
    failure=cli(sdk,path,['-GraphicsMode','8','-ValidateOnly'],False)
    assert 'MULTI_GEOMETRY' in failure.stdout+failure.stderr
    previous=os.environ.get('PYTHONOPTIMIZE')
    try:
        os.environ['PYTHONOPTIMIZE']='1'
        failure=cli(sdk,path,['-GraphicsMode','8','-ValidateOnly'],False)
        assert 'MULTI_GEOMETRY' in failure.stdout+failure.stderr
        cli(sdk,sdk/'examples/mode8/two-levels.json',['-GraphicsMode','8','-ValidateOnly'])
    finally:
        if previous is None:os.environ.pop('PYTHONOPTIMIZE',None)
        else:os.environ['PYTHONOPTIMIZE']=previous
    source=(sdk/'work/build-3Dvibe64.ps1').read_text()
    assert '"--labels=build\\' not in source
    assert '("--labels=" + $Mode3HighBasicSegmentLabelsPath)' in source
    # Package input is the current file list/bytes, not .git or historical HEAD.
    (sdk/'.git').mkdir();(sdk/'.git/config').write_text('test fixture only')
    original=(sdk/'README.md').read_bytes();(sdk/'README.md').write_bytes(original+b'\nCurrent candidate edit\n')
    second=temp/'package-copy';copy_package(sdk,second)
    assert not (second/'.git').exists() and (second/'README.md').read_bytes()==(sdk/'README.md').read_bytes()
    return dict(viewportCases=5,textureOverrideAndRelativePNG=True,incompatiblePrecisionRejected=True,currentPackageCopy=True,windowsAssemblerPathNative=True,optimizedPublicMode8ValidateOnly=True,LinuxExecution='not claimed')

def capture_identity(temp):
    # Synthetic bytes exercise identity validation ONLY. Never pass these
    # fixtures to the native qualifier and never claim their clocks as FPS.
    b=temp/'identity-build';o=temp/'identity-capture';b.mkdir();o.mkdir()
    for name in ['3Dvibe64.prg','scene.json','build.json','font.bin','labels.txt']:(b/name).write_bytes(b'synthetic test fixture '+name.encode())
    for name in ['frame-0001.vsf','color.bin','vic.bin','trace.log']:(o/name).write_bytes(b'synthetic identity fixture')
    run=dict(command=[sys.executable,'synthetic-identity-test']);(o/'run.json').write_text(json.dumps(run))
    context=dict(run='auto',short=True,interactive=False,sceneSHA256='fixture')
    ident=provenance.identity(b,'pal',context);provenance.record(b,o,'pal',context,ident)
    provenance.verify(b,o,'pal',context)
    for file in [b/'3Dvibe64.prg',b/'scene.json',b/'build.json',o/'frame-0001.vsf',o/'trace.log']:
        data=file.read_bytes();file.write_bytes(data+b'changed')
        rejected(lambda:provenance.verify(b,o,'pal',context),'CAPTURE_PROVENANCE');file.write_bytes(data)
    rejected(lambda:provenance.verify(b,o,'ntsc',context),'CAPTURE_PROVENANCE')
    rejected(lambda:provenance.verify(b,o,'pal',{**context,'run':'interactive'}),'CAPTURE_PROVENANCE')
    original=(o/provenance.MANIFEST).read_bytes();tampered=json.loads(original);tampered['producer']['emulatorSHA256']='0'*64
    (o/provenance.MANIFEST).write_text(json.dumps(tampered));rejected(lambda:provenance.verify(b,o,'pal',context),'producer binary differs')
    (o/provenance.MANIFEST).write_bytes(original)
    manifest=(o/provenance.MANIFEST).read_bytes();(o/provenance.MANIFEST).unlink()
    rejected(lambda:provenance.verify(b,o,'pal',context),'missing acquisition manifest')
    (o/provenance.MANIFEST).write_bytes(manifest)
    return dict(identityPositive=1,identityNegativeCases=9,syntheticFixtureNotUsedForFPS=True)

def validation():
    data=load(ROOT/'examples/mode8/two-levels.json');data['scene']['floor'][67]=32
    rejected(lambda:validate(data),'MULTI_GEOMETRY')
    code="import sys;sys.path.insert(0,'work');from mode8.build import load,validate;d=load('examples/mode8/two-levels.json');d['scene']['floor'][67]=32;validate(d)"
    p=subprocess.run([sys.executable,'-O','-c',code],cwd=ROOT,capture_output=True,text=True)
    assert p.returncode and 'MULTI_GEOMETRY' in p.stderr
    p=subprocess.run([sys.executable,'-O','-c',"import sys;sys.path.insert(0,'work');from mode8.build import load,validate;validate(load('examples/mode8/two-levels.json'))"],cwd=ROOT,capture_output=True,text=True)
    assert p.returncode==0,p.stderr
    assert heading(0,0)==64
    return dict(optimizedInvalidGeometryRejected=True,optimizedValidGeometryAccepted=True,coincidentHeading=64)

def allocation_checks():
    sys.path.insert(0,str(ROOT/'work/q8/src'))
    from allocation import bounded_place,PlacementFailure
    from emit import pack
    from nf_modes import place
    sizes={'tables':512,'code':468};gaps=[(0x1c02,0x2000)]
    result,stats=bounded_place(sizes,gaps,60000)
    assert result[0]=={'tables':(0x1e00,0x2000),'code':(0x1c02,0x1df6)},result
    lab={'mode3_high_basic_low_segment_end':0x1c02,'mode3_high_basic_middle_end':0x5c00,'mode3_high_basic_relocated_code_end':0xa000,'mode3_high_basic_high_code_end':0xd000}
    q8=pack(sizes,lab);nf=place(sizes,gaps)
    assert q8[0]==nf[0]==result[0]
    try:bounded_place(sizes,gaps,1)
    except PlacementFailure as e:assert e.reason=='SEARCH_BUDGET_EXHAUSTED'
    else:raise AssertionError('budget not enforced')
    try:bounded_place({'tables':1024},gaps,1000)
    except PlacementFailure as e:assert e.reason=='NO_ALIGNED_PLACEMENT'
    else:raise AssertionError('impossible allocation accepted')
    for n,(a,b) in result[0].items():
        assert 0x1c02<=a<b<=0x2000 and a%(256 if n=='tables' else 2)==0
        assert b-a==sizes[n]+(32 if n=='code' else 0)
    return dict(Q8AndNormalizedAllocatorCounterexampleResolved=True,allocationBudgetDistinctFromImpossibility=True)


def mode8_diagnostics(temp):
    from mode8.build import build
    from mode8.navigation import simulate
    from mode8.reference import adapter
    from mode8.trace import Trace
    from mode8 import model
    d=load(ROOT/'examples/mode8/two-levels.json')
    d['navigation']['nodes'].insert(1,d['scene']['initial'][:2])
    source=temp/'coincident.json';source.write_text(json.dumps(d),encoding='utf8')
    out=temp/'coincident-build';build(source,out,'auto')
    config,oracle,meta=adapter(d);trace=Trace(out,config['backend'],meta)
    trace.execute(trace.l['init_simulation'],False)
    planned,states,blocked=simulate(d['scene'],d['navigation'],ticks=100)
    for tick in range(1,101):
        trace.execute(trace.l['simulation_tick'],False);m=trace.c.memory
        word=lambda a:m[a]+256*m[a+1]
        assert (word(0x20),word(0x22),word(0x24),m[0x2c],m[0x2e])==planned[tick]
    # Independent fine rendering deliberately exposes the retained approximation.
    d=load(ROOT/'examples/mode8/two-levels.json');config,oracle,meta=adapter(d)
    out=temp/'visual-build';build(ROOT/'examples/mode8/two-levels.json',out,'interactive')
    trace=Trace(out,config['backend'],meta);center=(2546,7763,178,96,0)
    poses=[center]+[(2546+dx,7763+dy,178+da,96,0) for dx,dy,da in
        [(0,0,-2),(0,0,-1),(0,0,1),(0,0,2),(-8,0,0),(8,0,0),(0,-8,0),(0,8,0)]]
    poses += [tuple(p['pose']) for p in load(ROOT/'examples/mode8/sampling/two-levels.json')['poses']]
    for pose in poses:
        _,assembled=trace.view(pose)
        adaptive,pixels,details=model.render(meta['p'],pose)
        fine,finepixels,_=model.render(meta['p'],pose,full=True)
        assert assembled==adaptive
        if pose==center:
            assert sum(a!=b for a,b in zip(adaptive,fine))==36
            assert sum(a!=b for a,b in zip(pixels,finepixels))==138
    return dict(coincidentAssembledTicks=100,divergentPoses=0,
        independentFineDiagnosticPoses=len(poses),knownAdaptiveDifferenceBytes=36,
        knownAdaptiveDifferencePixels=138,CPUReplayNotFPS=True)


def main():
    result=validation();result.update(allocation_checks())
    with tempfile.TemporaryDirectory(prefix='3dvibe64-maintenance-host-') as tmp:
        temp=Path(tmp);result.update(config(temp));result.update(capture_identity(temp));result.update(mode8_diagnostics(temp))
    print(json.dumps(dict(result='PASS',checks=result),indent=2))

if __name__=='__main__':main()
