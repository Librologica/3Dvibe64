"""Compact future-state aliases from 1.10.2-dev1 for the maintained room adapter.
The private room renderer ALREADY batches scalar carriers; retain its UV8,
unlit/flat shaders and tails while removing the redundant boundary copy.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import hashlib
import re
from pathlib import Path
from optimizations import once

def apply(source):
    sdk=Path(__file__).resolve().parents[1]/'sdk'
    version=(sdk/'VERSION').read_text().strip()
    assert version=='1.10.2-dev3'
    # Qualify compatibility with the unchanged dev1 implementation, rather
    # than treating this inherited optimization as a new dev3 algorithm.
    assert hashlib.sha256((sdk/'work/q8/src/texture_fast.py').read_bytes()).hexdigest().upper()=='3760C94B8666EB7DDC59410790BC48937CADCF0D33B6482B8633D5F6D3F6E7D7'
    public=(sdk/'work/q8/src/texture_fast.py').read_text()
    assert 'bk_look0 = ps_cur0' in public and 'bk_look1 = ps_cur1' in public
    assert ' sta ps_err,x\n' in public
    source=once(source,' lda bk_future+1\n sta bk_look1,x\n lda bk_delta\n sta ca_lookerr,x\n',
                ' lda bk_future+1\n sta bk_look1,x\n lda bk_delta\n sta ps_err,x\n')
    source=once(source,'bk_look0: .fill 3,0\n','bk_look0 = ps_cur0\n')
    source=once(source,'bk_look1: .fill 3,0\n','bk_look1 = ps_cur1\n')
    source=once(source,'ca_lookerr: .fill 3,0\n','')
    source=once(source,'''ca_block:
 dec bk_count
 bne ca_shade
 stx ps_saved_x
 ldx #2
ca_commit:
 lda bk_look0,x
 sta ps_cur0,x
 lda bk_look1,x
 sta ps_cur1,x
 lda ca_lookerr,x
 sta ps_err,x
 dex
 bpl ca_commit
 ldx ps_saved_x
ca_shade:
''','''ca_block:
 dec bk_count
ca_shade:
''')
    # The private full-byte kernel embeds three advance copies. They must
    # use the same future-state contract as the scalar/partial-byte path.
    for pixel in range(3):
        prefix=f'fx{pixel}_'
        old=('ca_block:\n dec bk_count\n bne ca_shade\n stx ps_saved_x\n ldx #2\n'
             'ca_commit:\n lda bk_look0,x\n sta ps_cur0,x\n lda bk_look1,x\n'
             ' sta ps_cur1,x\n lda ca_lookerr,x\n sta ps_err,x\n dex\n'
             ' bpl ca_commit\n ldx ps_saved_x\nca_shade:\n')
        for label in ('ca_block','ca_shade','ca_commit'):
            old=old.replace(label,prefix+label)
        source=once(source,old,prefix+'ca_block:\n dec bk_count\n'+prefix+'ca_shade:\n')
    executable='\n'.join(line.split(';',1)[0] for line in source.splitlines())
    if re.search(r'\bca_lookerr\b',executable):
        (sdk.parent/'reports/dev-transform.asm').write_text(source)
        raise AssertionError('Remaining future-residue consumer: '+repr([line for line in executable.splitlines() if 'ca_lookerr' in line]))
    return source
