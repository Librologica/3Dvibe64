"""Release documentation parity, local links, CLI coverage and source integrity."""
import ast
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import tempfile
import unicodedata
from urllib.parse import unquote,urlsplit

ROOT=Path(__file__).resolve().parents[1]


def read(name):return (ROOT/name).read_text(encoding='utf-8-sig')
def load(name):return json.loads(read(name))


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
    version=read('VERSION').strip();assert version=='1.15.0-dev2'
    package=load('PACKAGE-MANIFEST.json');assert package['package']['version']==version
    assert package['package']['prerelease'] and not package['package']['precompiledPrograms']
    docs=load('DOCUMENTATION.json');assert docs['version']==version and docs['locales']==['en','it']
    assert docs['sourceOnly'] and docs['publication']=='unpublished local development' and not docs['newDemosIncluded']
    files=set(docs['currentBilingual'])
    for pair in docs['currentPairs']:
        for locale in ['en','it']:
            p=pair[locale];assert (ROOT/p).is_file(),p
            assert version in read(p),p
            files.add(p)
    files.update(docs['historicalReports'])
    for lang in ['en','it']:
        text=read('GAMEPLAY.'+lang+'.md')
        for name in docs['gameplayProfiles']:assert name in text,(lang,name)
        for flag in docs['gameplayConfigurationOptions']:assert flag in text,(lang,flag)
        for token in ['--profile','--out','--project-source','--validate-only','--plan-only','reserveBytes','minimumContiguousBytes','3759']:
            assert token in text,(lang,token)
    flags=set()
    for call in ast.walk(ast.parse(read('work/build-gameplay.py'))):
        if isinstance(call,ast.Call) and isinstance(call.func,ast.Attribute) and call.func.attr=='add_argument':
            flags.update(a.value for a in call.args if isinstance(a,ast.Constant) and isinstance(a.value,str) and a.value.startswith('--'))
    assert flags==set(docs['gameplayConfigurationOptions'])|set(docs['gameplayRequiredOptions']),flags
    assert not (ROOT/'examples').exists() and not (ROOT/'validation').exists()
    profiles=docs['gameplayProfiles'];assert len(profiles)==13
    count=links(sorted(p.relative_to(ROOT).as_posix() for p in ROOT.rglob('*.md')))
    entries={}
    for line in read('MANIFEST.sha256').splitlines():
        h,n=line.split('  ',1);assert n not in entries;entries[n]=h
        assert hashlib.sha256((ROOT/n).read_bytes()).hexdigest().upper()==h,n
    actual={p.relative_to(ROOT).as_posix() for p in ROOT.rglob('*') if p.is_file() and '.git' not in p.relative_to(ROOT).parts}
    assert set(entries)|{'MANIFEST.sha256'}==actual
    forbidden={'.prg','.d64','.d71','.d81','.tap','.t64','.mp3','.wav','.mp4','.webm','.zip','.vsf','.pyc'}
    assert not [n for n in entries if Path(n).suffix.lower() in forbidden]
    development=load('DEVELOPMENT.json')
    assert development['version']==version and development['status']=='development'
    assert development['nativeQualifiedModes']==list(range(1,8))
    assert not development['GitHubPublished'] and development['releaseURL'] is None
    assert not package['release']['stable'] and not package['release']['privateUnderworldPortIncluded']
    assert package['stablePromotion']['status']=='pending' and package['stablePromotion']['defaultProgramBytesUnchanged']
    assert not package['release']['GitHubPublished'] and package['release']['releaseURL'] is None
    print('DOCUMENTATION PASS; pairs=',len(docs['currentPairs']),'local links=',count,'profiles=',len(profiles),'source files=',len(actual))


if __name__=='__main__':main()
