"""Separate Mode1-7 plus API, source identity and native evidence. Never FPS."""
import hashlib,json,os,re,shutil,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'work'))
from mode8.common import require_qualification_checks

def main():
    require_qualification_checks()
    q=json.loads((ROOT/'QUALIFICATION-1.14.0.json').read_text(encoding='utf-8'))
    assert q['version']=='1.14.0' and q['GitHubPublished']
    assert q['defaultPrecision']=='legacy' and q['publicSelector']=='-Precision legacy-plus'
    assert not q['aliasOfRotation'] and not q['q8GeometryBackendIntroduced']
    for name,digest in q['engineSourceSHA256'].items():
        assert hashlib.sha256((ROOT/name).read_bytes()).hexdigest().lower()==digest.lower(),name
    assert len(q['finalIdentity'])==len(q['nativeFPS'])==57
    assert all(d['identicalPRG'] for d in q['finalIdentity'])
    assert {int(d['case'][1]) for d in q['nativeFPS'] if d['profile']=='legacy-plus'}==set(range(1,8))
    for case,data in q['stability'].items():
        for profile,d in data['profiles'].items():
            # Failed intermediate measurements are retained in the ledger, not promoted.
            if 'legacy-plus' not in profile or 'before-' in profile or profile.endswith('-attributes'):continue
            for key in ('falseDisappearances','unexpectedVisibleWithoutSourceEdges','behindLeaks','sharedMismatches','frozenBufferFailures'):assert not d[key],(case,profile,key,d)
    for d in q['nativeFPS']:
        assert d['emulatedSeconds']>=20 and d['simulationTicks']==2048 and d['nativeCounterAgrees']
        assert not d['hostTimeUsedForFPS'] and not any(d['faults'].values()) and d['SIDWritesDuringMeasuredLap']==0
    assert len(q['orbits'])==32
    for d in q['orbits'].values():assert d['poses']==36 and not d['frozenBufferFailures']
    # A tiny synthetic triangle exercises the compiler API. No scene file,
    # camera route, native capture or compiled fixture is packaged.
    scene=dict(schema=1,name='public triangle contract',graphicsMode=2,axisConvention='world-z-up',world=dict(backgroundColor=0,grounds=[]),camera=dict(id='camera',position=[0,0,0],rotation=[0,0,0],mode='walkLite'),
        meshes=[dict(id='m',type='mesh',geometry='solid',materialProfile='single',vertices=[[-8,-6,-8],[8,-6,8],[0,6,0]],faces=[[0,1,2]])],
        objects=[dict(id='o',mesh='m',position=[0,40,0],rotation=[0,0,0],angularVelocity=[0,0,0],scale=1,visible=True,material='blue',reflectivity='satin')],contract=dict(version=1,viewportProfile='normal',ground=False))
    env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1')
    with tempfile.TemporaryDirectory(prefix='3dvibe64-plus-api-') as td:
        t=Path(td);sc=t/'triangle.json';sc.write_text(json.dumps(scene),encoding='utf-8')
        base=['-GraphicsMode','2','-CameraMode','walkLite','-CameraViewport','normal','-MemoryLayout','high-basic-v2','-Quality','fast','-Projection','extended-table','-VideoStandard','pal','-FramePresentation','safe','-NoFpsOverlay','-NoCameraRuntimeControls','-ExplorerClipMode','near','-ExplorerNearCrossMode','poly','-MinFaceAreaOverride','0','-ScreenMinSpanOverride','0','-SkipCmdUpdate']
        outputs={}
        for profile,args in [('default',[]),('legacy',['-Precision','legacy']),('rotation',['-Precision','legacy','-LegacyStability','rotation']),('plus',['-Precision','legacy-plus'])]:
            sdk=t/profile
            shutil.copytree(ROOT,sdk,ignore=shutil.ignore_patterns('__pycache__','*.pyc','.git'))
            command=[shutil.which('pwsh'),'-NoProfile','-File',str(sdk/'work/build-3Dvibe64.ps1'),'-SceneFile',str(sc),*base,*args]
            result=subprocess.run(command,capture_output=True,text=True,encoding='utf-8',errors='replace',env=env)
            assert result.returncode==0,(profile,result.stdout[-2000:],result.stderr[-2000:])
            outputs[profile]=(sdk/'work/3Dvibe64.prg').read_bytes()
            asm=(sdk/'work/3Dvibe64.asm').read_text(encoding='utf-8-sig')
            assert ('LEGACY_PLUS_NEAR_Q4=1' in asm)==(profile=='plus')
            assert ('LEGACY_PLUS_NEAR_SCREEN_Q4=1' in asm)==(profile=='plus')
            if profile=='plus':
                assert 'legacy_camera_set_yaw_phase:' in asm and 'legacy_camera_set_pitch_phase:' in asm
                block=asm[asm.index('lc_round_q4:\n'):asm.index('lc_commit_q4:\n')]
                assert block.count(' ror p1hi\n')==block.count(' ror p1lo\n')==4
                assert ' bne lc_round_shift' not in block and ' ldx #0\n' in block
        assert outputs['default']==outputs['legacy']
        assert outputs['plus']!=outputs['rotation']
        rejected=[(['-Precision','legacy-plus','-GraphicsMode','8'],'only applicable'),
            (['-Precision','legacy-plus','-LegacyStability','historical'],'conflicting LegacyStability'),
            (['-Precision','legacy-plus','-GraphicsMode','2','-CameraMode','walkLite','-MemoryLayout','stable','-NoFpsOverlay'],'requires walkLite'),
            (['-Precision','legacy-plus','-GraphicsMode','2','-CameraMode','walkLite','-CameraViewport','small','-MemoryLayout','high-basic-v2','-NoFpsOverlay'],'requires walkLite'),
            (['-Precision','legacy-plus','-GraphicsMode','2','-CameraMode','walkLite','-MemoryLayout','high-basic-v2'],'requires -NoFpsOverlay'),
            (['-Precision','q8','-LegacyStability','rotation'],'only applicable')]
        for args,error in rejected:
            result=subprocess.run([shutil.which('pwsh'),'-NoProfile','-File',str(ROOT/'work/build-3Dvibe64.ps1'),*args],capture_output=True,text=True,encoding='utf-8',errors='replace',env=env)
            assert result.returncode and error in result.stdout+result.stderr,(args,result.stdout,result.stderr)
    assert not (ROOT/'work/3Dvibe64.asm').exists() and not (ROOT/'work/3Dvibe64.prg').exists()
    print('LEGACY_PLUS PASS:4 positive compiler paths,6 rejected combinations,57 exact native builds,32 orbit sets; native FPS provenance retained, not replayed')

if __name__=='__main__':main()
