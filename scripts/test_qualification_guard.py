"""Positive native frame, coherent altered frame, -O/-OO/PYTHONOPTIMIZE refusals."""
import hashlib,json,os,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'work'))
from mode8.build import build
from mode8.native import run
from mode8.provenance import verify

def main():
    code="import sys;sys.path.insert(0,sys.argv[1]);from mode8.native import run;run('missing','missing','missing')"
    for flags,level in [(['-O'],None),(['-OO'],None),([], '1')]:
        env=os.environ.copy();env.pop('PYTHONOPTIMIZE',None)
        if level:env['PYTHONOPTIMIZE']=level
        for tail in [['-c',code,str(ROOT/'work')],[str(ROOT/'scripts/run_release_tests.py'),'test_mode8.py']]:
            r=subprocess.run([sys.executable,*flags,*tail],capture_output=True,text=True,env=env)
            assert r.returncode and 'QUALIFICATION_OPTIMIZED_PYTHON' in r.stdout+r.stderr,(flags,tail,r.stdout,r.stderr)
            assert 'FileNotFoundError' not in r.stderr
    previous=os.environ.get('PYTHONOPTIMIZE')
    try:
        os.environ['PYTHONOPTIMIZE']='1'
        try:run('missing','missing','missing')
        except RuntimeError as e:assert 'QUALIFICATION_OPTIMIZED_PYTHON' in str(e)
        else:raise AssertionError('direct native.run accepted optimized environment')
    finally:
        if previous is None:os.environ.pop('PYTHONOPTIMIZE',None)
        else:os.environ['PYTHONOPTIMIZE']=previous
    with tempfile.TemporaryDirectory(prefix='qualification-guard-') as temp:
        t=Path(temp);scene=ROOT/'examples/mode8/perimeter.json';b=t/'build';out=t/'capture'
        build(scene,b,'auto')
        good=run(scene,b,out,short=True)
        assert good['captureProvenanceVerified'] and good['bitmapDifferentBytes']==0
        file=out/'frame-0001.vsf';raw=bytearray(file.read_bytes());offset=raw.index(b'C64MEM')+26
        bank=raw[offset+7];raw[offset+(0x63c0 if not bank else 0xe3c0)]^=1
        file.write_bytes(raw)
        manifest=out/'capture-manifest.json';m=json.loads(manifest.read_text(encoding='utf8'))
        m['files'][file.name]=hashlib.sha256(raw).hexdigest().upper()
        manifest.write_text(json.dumps(m,indent=2)+'\n',encoding='utf8')
        verify(b,out,'pal',m['identity']['qualification']) # coherently rehashed, so this must pass
        try:run(scene,b,out,short=True,reuse=True)
        except AssertionError as e:assert 'bitmap' in str(e),str(e)
        else:raise AssertionError('altered bitmap accepted with coherent manifest')
    print('QUALIFICATION_GUARD: PASS; native positive/altered bitmap; 6 optimized subprocess refusals; direct API guard')
if __name__=='__main__':main()
