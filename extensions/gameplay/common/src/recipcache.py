"""Exact near-plane identity, full-depth FIFO cache and dead cull-data recovery.
Required Notice:3Dvibe64. PolyForm Noncommercial1.0.0.
"""
from block4 import once
import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def recover_tables(source):
    """Only normals of the already removed legacy early-culling routine.
    Complete-program symbolic/pointer/alias consumer checks, fail closed.
    """
    assert re.search(r'(?m)^STABLE_FACE_CULL_PROFILE\s*=\s*(?:0|\$00)\s*$',source)
    assert 'camera_plane_original_facing = hp_unreachable' in source
    rows=[]
    for axis in 'xyz':
        name='camera_plane_cull_normal_'+axis
        pattern=r'(?m)^'+name+r':\n(?: \.byte[^\n]*\n)+'
        match=re.search(pattern,source);assert match,name
        values=re.findall(r'\$[0-9a-fA-F]+|(?<![\w])\d+',match[0].split(':',1)[1])
        rest=source[:match.start()]+source[match.end():]
        executable='\n'.join(line.split(';',1)[0] for line in rest.splitlines())
        assert not re.search(r'\b'+name+r'\b',executable),('Live cull-normal consumer',name)
        rows.append(dict(label=name,bytes=len(values),externalConsumers=0))
        source=rest
    assert len({r['bytes'] for r in rows})==1 and rows[0]['bytes']>0
    (ROOT/'reports/reciprocal-memory-proof.json').write_text(json.dumps(rows,indent=2))
    return source

def near_identity(body):
    # Reached only after depth high byte2 ==0 and depth byte1 is nonzero.
    # CMP1 carries into ROR after a zero low-byte load.
    # W=32768, so floor(raw16*W/32768) equals raw16 for BOTH attributes.
    # Caller consumes only hc_out_*, then reloads indices. No new scratch.
    old=body[body.index('ps_encode:\n'):body.index('ps_encode_valid:\n')]
    expected='''ps_encode:
 lda hc_depth+2
 bne ps_far_error
 lda hc_depth+1
 bne ps_depth_valid
 inc ps_fault
ps_depth_valid:
 jmp ps_encode_valid
ps_far_error:
 ; Exact 256 WU is allowed; larger depths are outside this initial profile.
 cmp #1
 bne ps_depth_error
 lda hc_depth
 ora hc_depth+1
 beq ps_encode_valid
ps_depth_error:
 inc ps_fault
'''
    assert old==expected
    return once(body,old, '''ps_encode:
 lda hc_depth+2
 bne ps_far_error
 lda hc_depth+1
 beq ps_depth_error
ps_depth_valid:
 cmp #1
 bne ps_encode_valid
 lda hc_depth
 bne ps_encode_valid
 sta hc_out_w
 ror
 sta hc_out_w+1
 rts
ps_far_error:
 ; Exact 256 WU allowed; preserve zero/out-of-domain fault guards.
 cmp #1
 bne ps_depth_error
 lda hc_depth
 ora hc_depth+1
 beq ps_encode_valid
ps_depth_error:
 inc ps_fault
''')

def adapt(source,parts,placed,kind='near'):
    assert kind in ('near','baseline','memory','cache2','cache4','cache8')
    if placed is None and kind not in ('baseline','memory'):
        parts['clip_helpers']=near_identity(parts['clip_helpers'])
        if kind.startswith('cache'):
            size=int(kind[5:]);parts['clip_helpers']=cache_encoder(parts['clip_helpers'],size)
            parts['data']+=cache_state(size)
    return source,parts

def cache_state(size):
    assert size in (2,4,8)
    return ('rc_next: .byte 0\nrc_slot: .byte 255\n'+
            ''.join(f'rc_{n}: .fill {size},0\n' for n in ('keylo','keyhi','wlo','whi')))

def cache_encoder(body,size):
    assert size in (2,4,8)
    # Eligible depths257..65535 only: keyhi0 is a permanently invalid sentinel.
    # Near identity is above this entry; far/invalid inputs remain uncached.
    search=f'''ps_encode_valid:
 lda #255
 sta rc_slot
 lda hc_depth+2
 bne rc_uncached
 lda hc_depth+1
 beq rc_uncached
 ldx #{size-1}
rc_search:
 lda hc_depth+1
 cmp rc_keyhi,x
 bne rc_next_key
 lda hc_depth
 cmp rc_keylo,x
 beq rc_cache_hit
rc_next_key:
 dex
 bpl rc_search
rc_cache_miss:
 ldx rc_next
 stx rc_slot
 inx
 txa
 and #{size-1}
 sta rc_next
 jmp rc_uncached
rc_cache_hit:
 lda rc_wlo,x
 sta hc_num
 lda rc_whi,x
 sta hc_num+1
 jmp rc_w_ready
rc_uncached:
'''
    body=once(body,'ps_encode_valid:\n',search)
    body=once(body,' jsr hc_div40\n lda hc_num\n',' jsr hc_div40\nrc_w_ready:\n lda hc_num\n')
    body=once(body,' sta ps_b+1\n lda hc_out_s\n',''' sta ps_b+1
 ldx rc_slot
 bmi rc_apply_uv
 lda hc_depth
 sta rc_keylo,x
 lda hc_depth+1
 sta rc_keyhi,x
 lda hc_out_w
 sta rc_wlo,x
 lda hc_out_w+1
 sta rc_whi,x
rc_apply_uv:
 lda hc_out_s
''')
    return body
