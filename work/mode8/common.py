"""Optional qualification tools: external outputs, no SDK mutation."""
from pathlib import Path
import hashlib,json,statistics
ROOT=Path(__file__).resolve().parents[2]
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest().upper()
def digest(o):return hashlib.sha256(json.dumps(o,sort_keys=True,separators=(',',':')).encode()).hexdigest().upper()
def writable(p):
    p=Path(p).resolve()
    if p.is_relative_to(ROOT):raise ValueError('OUTPUT_SCOPE: output must be outside SDK')
    return p
def save(p,o):
    p=writable(p);p.parent.mkdir(parents=True,exist_ok=True)
    p.write_text(json.dumps(o,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
def load(p):return json.loads(Path(p).read_text(encoding='utf-8-sig'))
def stats(v):
    s=sorted(v)
    return dict(n=len(s),mean=statistics.mean(s),median=statistics.median(s),p95=s[int(.95*(len(s)-1))],worst=max(s),minimum=min(s),percentile='sorted[floor(0.95*(n-1))]') if s else dict(n=0)
