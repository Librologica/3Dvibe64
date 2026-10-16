"""Check release identity, sealed foundation and isolation of the new entry point."""
import importlib.util,json,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'work'))
spec=importlib.util.spec_from_file_location('gameplay_build',ROOT/'work/build-gameplay.py')
builder=importlib.util.module_from_spec(spec);spec.loader.exec_module(builder)


def main():
    from mode8.common import require_qualification_checks
    require_qualification_checks()
    package=json.loads((ROOT/'PACKAGE-MANIFEST.json').read_text())
    assert (ROOT/'VERSION').read_text().strip()==package['package']['version']=='1.11.0'
    assert not package['package']['prerelease'] and not package['gameplayDevelopment']['publicSceneAPI']
    base=ROOT/'extensions/gameplay/foundation-1.10.2';identity=builder.foundation_identity()
    assert identity['version']=='1.10.2'
    checked=0
    for path in (base/'work').rglob('*'):
        if path.is_file():
            relative=path.relative_to(base)
            assert builder.sha(ROOT/relative)==builder.sha(path),('Inherited engine changed',relative)
            checked+=1
    for name in builder.PROFILES:
        p=json.loads((ROOT/f'examples/gameplay/{name}.json').read_text())
        assert p['profile']==name and p['engineVersion']=='1.11.0'
        assert p['standard']=='pal' and p['multiplier']==64 and not p['music']
        assert (ROOT/f"extensions/gameplay/billboards/{p['billboardImplementation']}.py").exists()
    # A mistaken in-source build must fail before creating or overwriting files.
    for bad in (ROOT,ROOT/'build-that-must-not-exist'):
        try:builder.build('comparison-ui',bad)
        except ValueError:pass
        else:raise AssertionError('In-source output accepted')
    with tempfile.TemporaryDirectory() as existing:
        try:builder.build('comparison-ui',existing)
        except ValueError:pass
        else:raise AssertionError('Existing output accepted')
    assert not (ROOT/'build-that-must-not-exist').exists()
    print('DEV GAMEPLAY CONTRACT PASS; inherited engine files unchanged:',checked)


if __name__=='__main__':main()
