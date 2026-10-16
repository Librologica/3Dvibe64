"""Demo-only exact batching of perspective carriers for existing block4 UV.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
Do not change the UV approximation, Gouraud Q, pixel coverage or public SDK.
"""
from block4 import once

def advance():
    code='''ps_advance:
 lda bk_count
 bne ca_block
 jmp bk_exact_advance ; short tail: original carrier/Q/X advancement
ca_block:
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
 jsr m3_advance_q ; shade still advances at every logical pixel
 inc gouraud_scan_x
'''
    for ch in range(2):
        code+=f''' clc
 lda bk_cur0+{ch}
 adc bk_step0+{ch}
 sta bk_cur0+{ch}
 lda bk_cur1+{ch}
 adc bk_step1+{ch}
 sta bk_cur1+{ch}
'''
    return code+' rts\n'

def adapt(source,parts,placed):
    if placed is None:
        sample=parts['perspective_sample']
        sample=once(sample,' lda bk_future+1\n sta bk_look1,x\n',
            ' lda bk_future+1\n sta bk_look1,x\n lda bk_delta\n sta ca_lookerr,x\n')
        parts['perspective_sample']=sample
        # This is the block wrapper at the END of the part, not original DDA.
        text=parts['perspective_span'];at=text.index('ps_advance:\n')
        assert text[at:].rstrip().endswith('bk_advance_done:\n rts')
        parts['perspective_span']=text[:at]
        parts['carrier_advance']=advance() # separate checked placement unit
        parts['data']+='ca_lookerr: .fill 3,0\n'
    return source,parts
