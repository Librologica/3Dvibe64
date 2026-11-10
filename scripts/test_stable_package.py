"""Published stable source promotion, program identity and no-demo/no-benchmark contract."""
import hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def load(n):return json.loads((ROOT/n).read_text('utf-8-sig'))
def digest(n):return hashlib.sha256((ROOT/n).read_bytes()).hexdigest()
def main():
    version=(ROOT/'VERSION').read_text().strip();assert version=='1.20.0'
    release=load('RELEASE.json');package=load('PACKAGE-MANIFEST.json');q=load(release['qualification'])
    assert release['classification']=='stable' and release['publicationStatus']=='published'
    assert release['GitHubPublished'] and release['releasePageCreated'] and release['tagCreated']
    assert release['releaseURL']=='https://github.com/Librologica/3Dvibe64/releases/tag/v1.20.0' and release['tag']=='v'+version and release['plannedTag']=='v'+version
    assert release['sourceDevelopment']=='1.15.2-dev-agentic36' and release['qualifiedAsStable']
    assert not package['package']['prerelease'] and package['release']['stable']
    assert package['stablePromotion']['status']=='complete' and package['stablePromotion']['runtimeAndDefaultsUnchanged']
    assert q['status']=='qualified-by-exact-program-identity-with-existing-blocks'
    assert q['newNativeTimingRuns']==0 and q['measurementsReusedByExactIdentity'] and not q['runtimeChangedDuringPromotion']
    for name,h in q['runtimeSourceSHA256'].items():assert digest(name)==h,name
    assert q['plannedCases']==233 and q['measuredCases']==177 and q['measuredNativeCells']==531
    assert q['originalNativeRuns']==651 and q['existingBlockedCases']==56 and not q['newBuildBlocks']
    assert len(q['coldBuildIdentities'])==177 and all(x['allNumericLabelsIdentical'] for x in q['coldBuildIdentities'])
    expected={(r['group'],r['caseId']):r['PRGSHA256'] for r in q['coldBuildIdentities']}
    assert len(q['nativeFPS'])==531 and {r['multiplier'] for r in q['nativeFPS']}=={1,20,64}
    assert {r['primaryMode'] for r in q['nativeFPS']}==set(range(1,9))
    assert all(r['emulatedSeconds']>=20 and r['PRGSHA256']==expected[r['group'],r['caseId']] for r in q['nativeFPS'])
    assert q['generalIndex']['anchor']=='1.15.0=100' and q['generalIndex']['deltaPercent']==0
    assert 'reconstructed' in q['generalIndex']['status'] and abs(q['generalIndex']['new']-137.50563008162632)<1e-10
    assert q['extendedIndex']['value']==100 and q['extendedIndex']['specificationVersion']=='1.0.1'
    assert not q['hardwareTested'] and not q['newNTSCQualification']
    assert not release['demosIncluded'] and not release['benchmarksIncluded']
    forbidden={'.prg','.d64','.d71','.d81','.tap','.t64','.sid','.mp3','.wav','.mp4','.webm','.zip','.vsf','.pyc'}
    assert not [p for p in ROOT.rglob('*') if p.is_file() and p.suffix.lower() in forbidden]
    for name in ['examples','validation','demos','benchmarks','artifacts','media']:assert not (ROOT/name).exists(),name
    for name in ['analyze_mode8.py','benchmark_native_render.py','benchmark_normalized16.py','qualify_mode8.py','sphere_api_example.py','seal_dev.py']:
        assert not (ROOT/'scripts'/name).exists(),name
    assert not (ROOT/'work/qualify-gameplay.py').exists()
    assert package['distanceFade']['default']=='off' and package['distanceFade']['modes']==list(range(1,9))
    assert package['mode7LOD']['default']=='off' and package['mode7LOD']['fadeWidthWU']==16
    print('STABLE PACKAGE PASS; unchanged measured programs, explicit existing blocks, published on GitHub, no demos/benchmarks')
if __name__=='__main__':main()
