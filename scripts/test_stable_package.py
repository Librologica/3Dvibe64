"""Published stable source state, current native identity and immutable history."""
import hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def load(n):return json.loads((ROOT/n).read_text(encoding='utf-8'))
def digest(n):return hashlib.sha256((ROOT/n).read_bytes()).hexdigest()
def main():
    version=(ROOT/'VERSION').read_text().strip();assert version=='1.15.1'
    release=load('RELEASE.json');package=load('PACKAGE-MANIFEST.json');docs=load('DOCUMENTATION.json');compat=load('DEVELOPMENT.json');q=load('QUALIFICATION-1.15.1.json')
    assert release['classification']=='stable' and release['publicationStatus']=='published'
    assert release['tag']=='v1.15.1' and release['tagCreated'] and release['tagLocation']=='https://github.com/Librologica/3Dvibe64/tree/v1.15.1'
    assert not release['runtimeChangedDuringPromotion'] and release['sourceDevelopment']=='1.15.1-dev-agentic17'
    assert package['package']['prerelease'] is False and package['release']['stable'] is True
    assert package['release']['version']==version and package['release']['status']=='published stable'
    assert package['stablePromotion']['status']=='complete' and package['stablePromotion']['runtimeAndDefaultsUnchanged']
    assert compat['status']=='stable' and not compat['localStableRelease']
    assert compat['release']['version']==version and compat['release']['stable'] and not compat['release']['prerelease']
    for data in [release,package['release'],package['distributionPolicy'],docs,compat,compat['release'],q]:
        assert data['GitHubPublished'] is True and data['releaseURL']=='https://github.com/Librologica/3Dvibe64/releases/tag/v1.15.1' and data['releasePageCreated'] is True
    assert q['sourceDevelopmentTreeSHA256']=='a3a5301dc21b9eb800e25ac5e6f2079ec48f59f0447b554cabc5dc59492b513f'
    for field in ['runtimeSourceSHA256','publicAPISourceSHA256','historicalSourceSHA256']:
        for name,h in q[field].items():assert digest(name).lower()==h.lower(),name
    assert q['newNativeTimingRuns']==0 and q['measurementsReusedByExactIdentity'] and not q['runtimeChangedDuringPromotion']
    assert q['plannedCases']==81 and q['measuredCases']==54 and q['measuredNativeCells']==162
    assert len(q['existingBlockedCases'])==27 and not q['newBuildBlocks']
    assert len(q['coldBuildIdentities'])==54 and all(x['identicalPRG'] and x['allNumericLabelsIdentical'] for x in q['coldBuildIdentities'])
    assert len(q['nativeFPS'])==162 and {x['multiplier'] for x in q['nativeFPS']}=={1,20,64}
    assert {x['primaryMode'] for x in q['nativeFPS']}==set(range(1,9))
    assert all(x['emulatedSeconds']>=20 and x['measureRefreshes']==1024 for x in q['nativeFPS'])
    assert q['index']['stableAnchorVersion']=='1.15.0' and q['index']['basketUnchanged'] and abs(q['index']['overallIndex']-117.64764535152725)<1e-10
    assert not q['timingFlags']['unresolved'] and not q['hardwareTested'] and not q['newNTSCQualification']
    assert q['publicStableGateStatus']=='verified-clean-zip' and q['publicStableGates']['status']=='passed'
    assert q['documentedBuilds']['status']=='verified' and q['documentedBuilds']['buildCount']==14
    assert not q['documentedBuilds']['FPSMeasured'] and q['documentedBuilds']['allFixturesExternal']
    assert len(q['documentedBuilds']['optionalAPIPrograms'])==2
    assert all(p['agentic17APIProgramsIdentical'] for p in q['documentedBuilds']['optionalAPIPrograms'])
    assert package['circleSpheres']['status']=='optional stable API'
    assert package['circleSpheres']['qualificationReport']=='QUALIFICATION-1.15.1.json'
    refs=package['mode8']['referenceBuilds'];assert len(refs)==6
    assert all(p['scene'].startswith('external:') and p['lowCodeFreeBytes']>0 and len(p['fixtureSHA256'])==64 for p in refs)
    current=set(docs['currentBilingual'])|{p[lang] for p in docs['currentPairs'] for lang in ['en','it']}
    assert not current&set(docs['historicalReports'])
    for name in sorted(current-{'LICENSE-DOCUMENTATION.md'}):
        text=(ROOT/name).read_text(encoding='utf-8');heading=re.search(r'(?m)^# (.+)',text)
        assert heading and version in heading[1] and '-dev' not in heading[1],name
        assert not re.search(r'(?m)^##? (Current development|Sviluppo corrente)',text),name
        assert 'This SDK is unpublished development' not in text,name
    for name in ['examples','validation','artifacts','demos','media']:assert not (ROOT/name).exists(),name
    banned={'.prg','.d64','.tap','.mp3','.wav','.mp4','.gif','.zip','.vsf','.pyc'}
    assert not [p for p in ROOT.rglob('*') if p.is_file() and '.git' not in p.parts and p.suffix.lower() in banned]
    print('STABLE PACKAGE PASS; published1.15.1, qualified program identity, original history and no demos')
if __name__=='__main__':main()
