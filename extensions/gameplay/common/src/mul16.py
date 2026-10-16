"""Demo-only exact narrow clipping products, generic fallback retained.
Required Notice:3Dvibe64. PolyForm Noncommercial1.0.0.
"""
from block4 import once

def body(source,kind):
    assert kind in ('baseline','shared','fixed16')
    if kind=='baseline':return source
    # Called after signed delta normalization and scratch/numerator zeroing.
    # Nonzero check remains before dispatch, so existing zero shortcut survives.
    if kind=='fixed16':
        new=''' lda hc_shift+2
 ora hc_value+2
 bne hq_mul_loop
 ldx #16
n16_loop:
 lsr hc_value+1
 ror hc_value
 bcc n16_shift
 clc
 lda hc_num+2
 adc hc_shift
 sta hc_num+2
 lda hc_num+3
 adc hc_shift+1
 sta hc_num+3
n16_shift:
 ; C is the17th addition bit, or zero from the multiplier test.
 ; Product recurrence includes that carry; no overflow is discarded.
 ror hc_num+3
 ror hc_num+2
 ror hc_num+1
 ror hc_num
 dex
 bne n16_loop
 jmp hq_mul_done
'''
        return once(source,' beq hq_mul_done\nhq_mul_loop:\n',' beq hq_mul_done\n'+new+'hq_mul_loop:\n')
    new=''' lda hc_shift+2
 ora hc_value+2
 beq n16_small
 ldy #1
 bne n16_ready
n16_small:
 ldy #0
n16_ready:
'''
    source=once(source,' beq hq_mul_done\nhq_mul_loop:\n',' beq hq_mul_done\n'+new+'hq_mul_loop:\n')
    source=once(source,' sta hc_num+3\n lda hc_num+4\n',' sta hc_num+3\n tya\n beq hq_mul_shift\n lda hc_num+4\n')
    source=once(source,' rol hc_shift+3\n rol hc_shift+4\n',' rol hc_shift+3\n tya\n beq n16_shift_done\n rol hc_shift+4\n')
    return once(source,' rol hc_shift+5\n jmp hq_mul_loop\n',' rol hc_shift+5\nn16_shift_done:\n jmp hq_mul_loop\n')

def adapt(source,parts,placed,kind='fixed16'):
    if placed is None and kind!='baseline':
        assert 'hq_ratio_product:\n' in parts['screen_precision']
        parts['screen_precision']=body(parts['screen_precision'],kind)
        # Complete routines, no fallthrough: preserve same legal RAM windows,
        # alignment and eight-byte guard for EACH independently placed block.
        s=parts['screen_precision'];a=s.index('hq_ratio_product:\n');b=s.index('hq_quantize_poly:\n')
        clean=lambda t:'\n'.join(line.split(';',1)[0] for line in t.splitlines()).rstrip()
        assert clean(s[:a]).endswith('rts') and clean(s[a:b]).endswith('rts')
        parts['ratio_product']=s[a:b];parts['screen_precision']=s[:a]+s[b:]
    return source,parts
