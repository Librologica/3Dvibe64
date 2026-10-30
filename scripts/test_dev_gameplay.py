"""Distribution exclusion and ordinary engine preservation contract."""
import hashlib,importlib.util,json,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def main():
    assert b'\r\n' not in (ROOT/'work/build-3Dvibe64.ps1').read_bytes(),'Generator source must retain LF here-string semantics'
    package=json.loads((ROOT/'PACKAGE-MANIFEST.json').read_text())
    policy=package['distributionPolicy']
    assert not policy['newDemosIncluded'] and policy['baseline']=='v1.10.2'
    assert (ROOT/'VERSION').read_text().strip()=='1.15.1'
    assert package['package']['prerelease'] is False
    for name,digest in policy['ordinaryEngineSHA256'].items():
        assert hashlib.sha256((ROOT/name).read_bytes()).hexdigest().upper()==digest,name
    expected=set(policy['preexistingExampleFiles'])
    actual={p.relative_to(ROOT).as_posix() for p in (ROOT/'examples').rglob('*') if p.is_file()}
    assert actual==expected,(actual-expected,expected-actual)
    for name in ['common','profiles','experiments','foundation-1.10.2']:
        assert not (ROOT/'extensions/gameplay'/name).exists(),name
    assert not (ROOT/'work/build-underworld.py').exists()
    spec=importlib.util.spec_from_file_location('builder',ROOT/'work/build-gameplay.py')
    b=importlib.util.module_from_spec(spec);spec.loader.exec_module(b)
    with tempfile.TemporaryDirectory() as folder:
        out=Path(folder)/'absent'
        try:b.build('shared-meshes',out)
        except ValueError as e:assert '--project-source' in str(e)
        else:raise AssertionError('Missing external project inputs were accepted')
        assert not out.exists()
    for out in (ROOT,ROOT/'must-not-exist'):
        try:b.build('shared-meshes',out)
        except ValueError:pass
        else:raise AssertionError('In-source output accepted')
    print('DISTRIBUTION PASS; no new demos; current ordinary engine hashes:',len(policy['ordinaryEngineSHA256']))
if __name__=='__main__':main()
