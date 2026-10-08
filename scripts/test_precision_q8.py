"""Public precision opt-in/default contract; no historical workspace dependency."""
import copy,hashlib,importlib.util,json,os,shutil,subprocess,sys,tempfile
from pathlib import Path
from test_release_contract import REFERENCE_BUILDS,build
ROOT=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest().upper()
manifest=json.loads((ROOT/'PACKAGE-MANIFEST.json').read_text(encoding='utf-8'))
q8=manifest['precision']['q8'];assert manifest['precision']['default']=='legacy'
source=(ROOT/'work/build-3Dvibe64.ps1').read_text()
assert '[string]$Precision = "legacy"' in source
assert "if ($Precision -eq 'q8')" in source

# Omission vs explicit legacy; these must also match the frozen reference PRGs.
for mode in range(1,8):
    if mode<=5:
        _,scene,expected,args=REFERENCE_BUILDS[min(mode-1,3)]
        args=list(args);args[args.index('-GraphicsMode')+1]=str(mode)
        if mode==5:expected='9E6AD6CE233450CF5EC02923DB600FA6A13D8EB4FDD9F1381764EC1C7019E5D5'
    else:
        scene='examples/'+('mode6-gouraud-torus-fps.json' if mode==6 else 'mode7-cube-gouraud.json')
        args=['-GraphicsMode',str(mode),'-MemoryLayout','high-basic-v2','-Projection','extended-table','-Quality','fast']
        expected={6:'4F5539DFDF1ABCB10DEA49B105DF47AE477E529A49A10F91253A57E82C2008BF',7:'25108E247BAD86A94EED6D7431753B197661BDCDBCF89836BAF0FDF2209A71BD'}[mode]
    for extra in ([],['-Precision','legacy']):
        build(ROOT,scene,(*args,*extra))
        assert sha(ROOT/'work/3Dvibe64.prg')==expected,(mode,extra,'legacy changed')

sys.path.insert(0,str(ROOT/'work/q8'))
spec=importlib.util.spec_from_file_location('q8_contract_builder',ROOT/'work/q8/build.py')
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
base=json.loads((ROOT/'examples/q8/two-objects-mode4.json').read_text())
with tempfile.TemporaryDirectory(prefix='3dvibe64-q8-contract-') as temp:
    out=Path(temp)
    module.validate(base,4,'pal',out/'valid')
    invalid=[]
    for key,value in [('meshSourceSharing',True),('timeline',{'tickRate':50})]:
        s=copy.deepcopy(base);s[key]=value;invalid.append(s)
    for mode in ('fixed','walkFull'):
        s=copy.deepcopy(base);s['camera']['mode']=mode;invalid.append(s)
    for rotation in ([1,0,0],[0,0,1]):
        s=copy.deepcopy(base);s['camera']['rotation']=rotation;invalid.append(s)
    s=copy.deepcopy(base);s['world']['grounds']=[{'mode':'plane'}];invalid.append(s)
    s=copy.deepcopy(base);s['contract']['viewportProfile']='small';invalid.append(s)
    s=copy.deepcopy(base);s['objects']*=2;invalid.append(s)
    for scale in (0,1.01,float('nan')):
        s=copy.deepcopy(base);s['objects'][0]['scale']=scale;invalid.append(s)
    s=copy.deepcopy(base);s['objects'][0]['position'][0]=5000;invalid.append(s)
    for s in invalid:
        try:module.validate(s,4,'pal',out/'invalid')
        except ValueError:pass
        else:raise AssertionError('invalid Q8 scene accepted')
    for target in (ROOT/'bad-output',out):
        try:module.validate(base,4,'pal',target)
        except ValueError:pass
        else:raise AssertionError('unsafe/existing output accepted')
    references=q8['referenceBuilds'];assert len(references)==42
    for r in references:
        destination=out/r['name']
        cmd=[shutil.which('pwsh'),'-NoProfile','-File',str(ROOT/'work/build-3Dvibe64.ps1'),
            '-Precision','q8','-Q8Camera',r['camera'],'-GraphicsMode',str(r['mode']),
            '-SceneFile',str(ROOT/f'examples/q8/two-objects-mode{r["mode"]}.json'),
            '-VideoStandard',r['standard'],'-FramePresentation','legacy','-OutputDirectory',str(destination)]
        completed=subprocess.run(cmd,capture_output=True,text=True,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'))
        assert completed.returncode==0,completed.stdout+completed.stderr
        assert sha(destination/'3Dvibe64.prg')==r['sha256'],r['name']
        print('Q8 reference PASS',r['name'],flush=True)
    # Only Precision is mandatory for opt-in; Q8 defaults to stationary PAL.
    expected=next(r for r in references if r['name']=='stationary-m4-pal')['sha256']
    completed=subprocess.run([shutil.which('pwsh'),'-NoProfile','-File',str(ROOT/'work/build-3Dvibe64.ps1'),
        '-Precision','q8','-GraphicsMode','4','-SceneFile',str(ROOT/'examples/q8/two-objects-mode4.json'),
        '-FramePresentation','legacy','-OutputDirectory',str(out/'q8-defaults')],capture_output=True,text=True)
    assert completed.returncode==0,completed.stdout+completed.stderr
    assert sha(out/'q8-defaults/3Dvibe64.prg')==expected
    # CLI refusals happen before compilation; no ignored feature combinations.
    prefix=[shutil.which('pwsh'),'-NoProfile','-File',str(ROOT/'work/build-3Dvibe64.ps1'),
        '-Precision','q8','-SceneFile',str(ROOT/'examples/q8/two-objects-mode4.json')]
    for extra in (['-GraphicsMode','8'],['-CameraViewport','small'],['-CameraMode','fixed'],['-HeaderText','invalid'],['-VideoStandard','auto'],['-MemoryLayout','stable']):
        completed=subprocess.run(prefix+extra,capture_output=True,text=True)
        assert completed.returncode!=0,extra
print('Q8_PRECISION_CONTRACT: legacy omission/explicit 7/7; Q8 frozen-source builds 42/42; Q8 defaults and validation/refusals PASS')
