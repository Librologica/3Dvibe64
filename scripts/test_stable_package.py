"""Stable/offline publication state, unchanged runtime and current-doc audit."""
import json,hashlib,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def load(n):return json.loads((ROOT/n).read_text(encoding='utf-8'))
def digest(n):return hashlib.sha256((ROOT/n).read_bytes()).hexdigest()
def main():
    assert (ROOT/'VERSION').read_text().strip()=='1.15.0'
    release=load('RELEASE.json');package=load('PACKAGE-MANIFEST.json');docs=load('DOCUMENTATION.json');compat=load('DEVELOPMENT.json');q=load('QUALIFICATION-1.15.0.json')
    assert release['classification']=='stable' and release['publicationStatus']=='local-only'
    assert release['localTag']=='v1.15.0' and not release['runtimeChangedDuringPromotion']
    assert package['package']['prerelease'] is False and package['release']['stable'] is True
    assert package['release']['version']=='1.15.0' and package['release']['status']=='stable-local'
    assert package['stablePromotion']['status']=='complete-local' and package['stablePromotion']['runtimeAndDefaultsUnchanged']
    assert compat['status']=='stable-local' and compat['localStableRelease']
    assert compat['release']['version']=='1.15.0' and compat['release']['status']=='stable-local' and compat['release']['stable']
    assert not compat['release']['prerelease'] and not package['release']['prerelease']
    for data in (release,package['release'],package['distributionPolicy'],docs,compat,compat['release'],q):
        assert data['GitHubPublished'] is False and data['releaseURL'] is None
        assert data['releasePageCreated'] is False
    for name,h in q['runtimeSourceSHA256'].items():assert digest(name)==h,name
    for name,h in q['historicalSourceSHA256'].items():assert digest(name)==h,name
    old=load('QUALIFICATION-1.15.0-dev2.json')
    assert not q['newNativeTimingRuns'] and q['measurementOriginVersion']==old['version']
    for key in ('nativeFPS','comparisons','pixelIdentity','correctnessCallbacks','inheritedDefaultIdentity'):
        assert q[key]==old[key],key
    assert q['engineSourceSHA256']==old['engineSourceSHA256']
    current=set(docs['currentBilingual'])|{p[lang] for p in docs['currentPairs'] for lang in ('it','en')}
    history=set(docs['historicalReports']);assert not current&history
    for name in sorted(current-{'LICENSE-DOCUMENTATION.md'}):
        text=(ROOT/name).read_text(encoding='utf-8')
        heading=re.search(r'(?m)^# (.+)',text)
        assert heading and '1.15.0' in heading[1] and '-dev' not in heading[1],name
        assert not re.search(r'(?m)^> (Development edition|Edizione di sviluppo)',text),name
        assert not re.search(r'(?m)^# .*1\.1[34]\.0',text),name
        for stale in ('This stable distribution is published on GitHub','Stable source distribution published on GitHub','Questa distribuzione stabile sorgente è pubblicata su GitHub','futura release stabile GitHub','future stable GitHub release','Stable promotion remains a later action'):
            assert stale not in text,(name,stale)
    for name in ('examples','validation','artifacts','demos','media'):
        assert not (ROOT/name).exists(),name
    assert not any(p.suffix.lower() in ('.prg','.d64','.tap','.mp3','.wav','.mp4','.gif','.zip','.vsf') for p in ROOT.rglob('*') if p.is_file() and '.git' not in p.parts)
    print('STABLE PACKAGE PASS; offline publication state,',len(q['runtimeSourceSHA256']),'runtime files,',len(q['historicalSourceSHA256']),'historical files,',len(current),'current manuals; no new timing claims or demos')
if __name__=='__main__':main()
