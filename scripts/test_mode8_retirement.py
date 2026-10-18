"""Retired Mode8 requests fail before generation, including public PowerShell."""
from pathlib import Path
import itertools, shutil, subprocess, sys, tempfile
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'work'))
from experiments import parse
from mode8.build import build

def main():
    flags=('mode8-regions','mode8-rays','mode8-chars')
    requests=['all']+[','.join(c) for n in range(1,4) for c in itertools.combinations(flags,n)]
    for value in (None,'','none'):
        assert parse(value,'mode8')==set()
    assert parse('all','q8')=={'uv-texel','q8-arithmetic','camera-table','visibility','camera-extremes','zero-terms','degenerate-faces','live-attributes','adapter-outcodes','inside-planes','bounded-divide','packed-samples','unrolled-advance'}
    with tempfile.TemporaryDirectory(prefix='mode8-retired-') as temp:
        for value in requests:
            try:build('missing-input.json',Path(temp)/'out',engine_experiments=value)
            except ValueError as e:assert 'ENGINE_MODE8_RETIRED' in str(e) and 'none' in str(e)
            else:raise AssertionError(('retired request accepted',value))
            cmd=[shutil.which('pwsh') or 'powershell','-NoProfile','-File',str(ROOT/'work/build-3Dvibe64.ps1'),
                 '-GraphicsMode','8','-SceneFile',str(ROOT/'examples/mode8/two-levels.json'),
                 '-ValidateOnly','-EngineExperiments',value,'-OutputDirectory',str(Path(temp)/'out')]
            r=subprocess.run(cmd,capture_output=True,text=True)
            assert r.returncode!=0 and 'ENGINE_MODE8_RETIRED' in r.stdout+r.stderr,(cmd,r.stdout,r.stderr)
        for value in (None,'none'):
            build(ROOT/'examples/mode8/two-levels.json',Path(temp)/'out',validate_only=True,engine_experiments=value)
            cmd=[shutil.which('pwsh') or 'powershell','-NoProfile','-File',str(ROOT/'work/build-3Dvibe64.ps1'),
                 '-GraphicsMode','8','-SceneFile',str(ROOT/'examples/mode8/two-levels.json'),'-ValidateOnly']
            if value is not None:cmd+=['-EngineExperiments',value]
            r=subprocess.run(cmd,capture_output=True,text=True)
            assert r.returncode==0,(cmd,r.stdout,r.stderr)
    assert not (ROOT/'work/mode8/experiments.py').exists()
    print('MODE8_RETIREMENT: PASS; 8 API + 8 public refusals; ordinary/none; Q8 all preserved')
if __name__=='__main__':main()
