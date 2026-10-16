"""Optional development-only Gallery Static player, never baseline builds.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0.
"""
import hashlib,re
from pathlib import Path

def parts():
    root=Path(__file__).resolve().parents[6]/'2.5vibeVic-Gallery-Static-SID'
    expected='4715E47BE7F74C80EF1DBFBD7879C234C039024A44E43F2C45C1B3AC619D735F'
    if hashlib.sha256((root/'Gallery-Static.sid').read_bytes()).hexdigest().upper()!=expected:
        raise ValueError('Gallery Static identity mismatch')
    s=(root/'src/player.asm').read_text()
    s=s[s.index('sid_init:'):s.index('code_end:')]+s.split('code_end:')[1].split('.include')[0]
    tables=(root/'build/score.inc').read_text()
    names=set(re.findall(r'^(\w+):',s+tables,re.M))
    for n in sorted(names,key=len,reverse=True):
        s=re.sub(r'\b'+n+r'\b','gs_'+n,s)
        tables=re.sub(r'\b'+n+r'\b','gs_'+n,tables)
    return s,tables
