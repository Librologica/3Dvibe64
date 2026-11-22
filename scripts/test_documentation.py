"""Current stable source identity, complete bilingual index, links, CLI and source contracts."""
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import unicodedata
from urllib.parse import unquote,urlsplit

ROOT=Path(__file__).resolve().parents[1]

def read(name):return (ROOT/name).read_text(encoding='utf-8-sig')


def anchors(text):
    values=set();seen={};fenced=False
    for line in text.splitlines():
        if line.lstrip().startswith('```'):fenced=not fenced
        if fenced or not re.match(r'^#{1,6}\s',line):continue
        s=re.sub(r'^#{1,6}\s+','',line).strip().rstrip('#').strip().lower()
        s=re.sub(r'<[^>]+>','',s)
        s=''.join(c for c in s if c in '_- ' or unicodedata.category(c)[0] in 'LN')
        s=s.replace(' ','-');n=seen.get(s,0);seen[s]=n+1
        values.add(s+('-'+str(n) if n else ''))
    values.update(re.findall(r'<a\s+(?:name|id)=[\"\']([^\"\']+)',text,re.I))
    return values


def links(files):
    broken=[];count=0
    for name in files:
        p=ROOT/name;text=read(name)
        # Fenced command examples can contain Markdown-looking syntax.
        text=re.sub(r'(?ms)^```.*?^```[^\n]*','',text)
        for match in re.finditer(r'!?\[[^\]\n]*\]\(([^\n]+?)\)',text):
            target=match[1].strip()
            if target.startswith('<'):target=target[1:target.index('>')]
            else:target=target.split(' "',1)[0]
            u=urlsplit(target)
            if u.scheme or u.netloc:continue
            path=unquote(u.path)
            dest=(p.parent/path).resolve() if path else p
            count+=1
            if not dest.is_relative_to(ROOT) or not dest.exists():
                broken.append((name,target,'missing local target'));continue
            if u.fragment and dest.suffix=='.md':
                if unquote(u.fragment).lower() not in anchors(dest.read_text(encoding='utf-8-sig')):
                    broken.append((name,target,'missing heading anchor'))
    assert not broken,'Broken documentation links:\n'+'\n'.join(map(str,broken))
    return count




def main():
    load=lambda p:json.loads((ROOT/p).read_text('utf-8-sig'))
    version=(ROOT/'VERSION').read_text().strip()
    assert version=='1.20.1'
    package=load('PACKAGE-MANIFEST.json');docs=load('DOCUMENTATION.json')
    release=load('RELEASE.json');development=load('DEVELOPMENT.json')
    assert all(d['version']==version for d in (docs,release,development,package['package'],package['release']))
    for data in (release,development,docs,package['release']):
        assert data['GitHubPublished'] and data['releasePageCreated'] and data['releaseURL']=='https://github.com/Librologica/3Dvibe64/releases/tag/v1.20.1'
    assert release['classification']=='stable' and release['publicationStatus']=='published'
    assert release['qualifiedAsStable'] and release['tagCreated'] and release['tag']=='v'+version
    assert not package['package']['prerelease'] and not package['package']['precompiledPrograms']
    assert docs['locales']==['en','it'] and docs['publication']=='stable source SDK'
    names={p.relative_to(ROOT).as_posix() for p in ROOT.rglob('*') if p.is_file()}
    manifest={n:h for h,n in (line.split('  ',1) for line in (ROOT/'MANIFEST.sha256').read_text().splitlines())}
    assert names==set(manifest)|{'MANIFEST.sha256'}
    assert len(names)==package['package']['permanentFiles']
    for name,digest in manifest.items():
        assert hashlib.sha256((ROOT/name).read_bytes()).hexdigest().upper()==digest,name
    assert hashlib.sha256((ROOT/'work/build-3Dvibe64.ps1').read_bytes()).hexdigest().upper()==package['builder']['sha256']
    banned={'.prg','.d64','.tap','.zip','.wav','.mp3','.mp4','.vsf','.pyc'}
    assert not [n for n in names if Path(n).suffix.lower() in banned]
    assert not any((ROOT/n).exists() for n in ('examples','validation','demos','artifacts'))
    content_version=docs.get('contentVersion',version)
    assert content_version in (version,)
    pairs=docs['currentPairs']+docs['developmentPairs']
    for pair in pairs:
        for language in ('en','it'):
            text=(ROOT/pair[language]).read_text('utf-8-sig')
            assert content_version in text,pair[language]
            assert 'stable' in text.lower() or 'stabile' in text.lower(),pair[language]
            assert 'GitHub publication pending' not in text and 'pubblicazione GitHub in attesa' not in text.lower(),pair[language]
            for obsolete in ('> Stable1.15.1 source SDK published','> SDK sorgente stabile1.15.1 pubblicato',
                             'This stable1.15.1 source distribution is published',
                             'Questa distribuzione sorgente stabile1.15.1 Ã¨ pubblicata',
                             'derivato da agentic22','from delivered agentic22'):
                assert obsolete not in text,(pair[language],obsolete)
    current=set(docs['currentBilingual'])|{x[l] for x in pairs for l in ('en','it')}
    assert not current & set(docs['historicalReports'])
    for name in current|{'AGENTS.md'}:
        assert not re.search(r'(?i)agentic[-_ ]*\d+',read(name)),('internal build name in current public documentation',name)
    for name in current-{'LICENSE-DOCUMENTATION.md'}:
        first=(ROOT/name).read_text('utf-8-sig').splitlines()[0]
        assert content_version in first,name
    count=links(sorted(n for n in names if n.endswith('.md')))
    import ast
    tree=ast.parse((ROOT/'work/build-gameplay.py').read_text('utf-8-sig'))
    profiles=next(ast.literal_eval(n.value) for n in tree.body if isinstance(n,ast.Assign) and any(isinstance(x,ast.Name) and x.id=='PROFILES' for x in n.targets))
    assert set(profiles)==set(docs['gameplayProfiles']) and len(profiles)==13
    flags={a.value for c in ast.walk(tree) if isinstance(c,ast.Call) and isinstance(c.func,ast.Attribute) and c.func.attr=='add_argument' for a in c.args if isinstance(a,ast.Constant) and isinstance(a.value,str) and a.value.startswith('--')}
    assert flags==set(docs['gameplayConfigurationOptions'])|set(docs['gameplayRequiredOptions'])
    for lang in ('en','it'):
        text=(ROOT/f'GAMEPLAY.{lang}.md').read_text('utf-8-sig')
        for token in list(profiles)+list(flags)+['--validate-only','--plan-only','reserveBytes','minimumContiguousBytes','3759']:
            assert token in text,(lang,token)
    # Identical API field names, ranges and calling conventions in both manuals.
    for token in ('animatedMeshes','animation','clips','frames','lighting','reference','frozen',
                  'interpolation','linear','step','phase','am_set_clip','am_reset_all',
                  'am_invalidate_light','3..85','1..255','2/4/8/16/32/64','0..255',
                  'am_clip','am_phase_lo','am_phase_hi','am_light_valid'):
        for language in ('en','it'):
            assert token in (ROOT/f'ANIMATED-MESH.{language}.md').read_text('utf-8-sig'),(token,language)
    assert set(re.findall(r'```json\n(.*?)\n```',(ROOT/'ANIMATED-MESH.en.md').read_text(),re.S))==set(
        re.findall(r'```json\n(.*?)\n```',(ROOT/'ANIMATED-MESH.it.md').read_text(),re.S))
    fade=package['distanceFade']
    for name,digest in fade['backendHashes'].items():
        assert hashlib.sha256((ROOT/name).read_bytes()).hexdigest().upper()==digest,('stale distance-fade backend identity',name)
    assert fade['default']=='off' and fade['modes']==list(range(1,9)) and fade['textureLODIndependent']
    assert fade['cli']==['DistanceFade','DistanceFadeStart','DistanceFadeEnd']
    assert package['mode7LOD']['default']=='off' and package['mode7LOD']['fadeWidthWU']==16
    for lang in ['en','it']:
        text=(ROOT/f'DISTANCE-FADE.{lang}.md').read_text('utf-8')
        for token in ['-DistanceFade','-DistanceFadeStart','-DistanceFadeEnd','--distance-fade','--fade-start','--fade-end','distanceFade','TextureLOD','TextureLODNear','TextureLODFar','32767','2449','Mode8','Mode7','Q8']:
            assert token in text,(lang,token)
    assert set(re.findall(r'```(?:json|powershell)\n(.*?)\n```',(ROOT/'DISTANCE-FADE.en.md').read_text('utf-8'),re.S))==set(re.findall(r'```(?:json|powershell)\n(.*?)\n```',(ROOT/'DISTANCE-FADE.it.md').read_text('utf-8'),re.S))
    print(f'STABLE DOCUMENTATION PASS; {len(pairs)} bilingual pairs, {count} local links, {len(names)} source files')


if __name__=='__main__':main()
