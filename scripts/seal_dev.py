"""Seal the current source package; output artifacts remain outside it."""
import hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]


def main():
    files=sorted(p for p in ROOT.rglob('*') if p.is_file() and '.git' not in p.relative_to(ROOT).parts
                 and '__pycache__' not in p.parts and p.name!='MANIFEST.sha256')
    # Nested foundation manifest is a source input and must be included.
    files.extend(p for p in (ROOT/'extensions').rglob('MANIFEST.sha256') if p.is_file())
    files=sorted(set(files));count=len(files)+1
    package=ROOT/'PACKAGE-MANIFEST.json';d=json.loads(package.read_text(encoding='utf-8'));d['package']['permanentFiles']=count
    package.write_text(json.dumps(d,indent=2)+'\n',encoding='utf-8',newline='\n')
    test=ROOT/'scripts/test_release_contract.py';s=test.read_text(encoding='utf-8-sig')
    s,n=re.subn(r'PERMANENT_FILE_COUNT = \d+',f'PERMANENT_FILE_COUNT = {count}',s)
    assert n==1;test.write_text(s,encoding='utf-8',newline='\n')
    digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest().upper()
    (ROOT/'MANIFEST.sha256').write_text(''.join(digest(p)+'  '+p.relative_to(ROOT).as_posix()+'\n' for p in files),encoding='utf-8',newline='\n')
    print(json.dumps(dict(version=d['package']['version'],files=count,manifestSHA256=digest(ROOT/'MANIFEST.sha256'))))


if __name__=='__main__':main()
