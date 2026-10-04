"""Exact paired UV restoring division for the lit projective Q8 sampler.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. No SMC, reciprocal or sampling approximation.
Reserve E8..EF while renderer owns the machine. IRQ must not use this state.
Unlit rational recurrence retains its full quotient/remainder scalar contract.
"""
import re

def kernel():
    s='''up_pair:
 lda ps_den
 ora ps_den+1
 beq uz_fallback
 lda ps_den
 sta uz_denlo
 lda ps_den+1
 sta uz_denhi
 ldx #1
uz_init:
 lda up_inputlo,x
 sta uz_remlo,x
 lda up_inputhi,x
 sta uz_remhi,x
 lda #0
 sta uz_quotient,x
 lda uz_remhi,x
 cmp uz_denhi
 bcc uz_init_next
 bne uz_initial_sub
 lda uz_remlo,x
 cmp uz_denlo
 bcc uz_init_next
uz_initial_sub:
 sec
 lda uz_remlo,x
 sbc uz_denlo
 sta uz_remlo,x
 lda uz_remhi,x
 sbc uz_denhi
 sta uz_remhi,x
 lda #128
 sta uz_quotient,x
 lda uz_remhi,x
 cmp uz_denhi
 bcc uz_init_next
 bne uz_fallback
 lda uz_remlo,x
 cmp uz_denlo
 bcs uz_fallback
uz_init_next:
 dex
 bpl uz_init
'''
    for bit in range(7):
        for channel,off in (('u',''),('v','+1')):
            tag=f'uz_b{bit}_{channel}'
            s+=f''' asl uz_remlo{off}
 rol uz_remhi{off}
 bcs {tag}_sub
 lda uz_remhi{off}
 cmp uz_denhi
 bcc {tag}_next
 bne {tag}_sub
 lda uz_remlo{off}
 cmp uz_denlo
 bcc {tag}_next
{tag}_sub:
 sec
 lda uz_remlo{off}
 sbc uz_denlo
 sta uz_remlo{off}
 lda uz_remhi{off}
 sbc uz_denhi
 sta uz_remhi{off}
 lda uz_quotient{off}
 ora #{64>>bit}
 sta uz_quotient{off}
{tag}_next:
'''
    s+=''' lda uz_quotient
 sta m7_u
 lda uz_quotient+1
 sta m7_v
 clc
 ldy #0
 rts
uz_fallback:
'''
    for ch,name in ((0,'u'),(1,'v')):
        s+=f' lda up_inputlo+{ch}\n sta ps_a\n lda up_inputhi+{ch}\n sta ps_a+1\n jsr ps_uv_divide\n sta m7_{name}\n'
    return s+' rts\n'

def apply(source,parts,pigments):
    # This update changes neither affine nor the unlit recurrence's ABI.
    if 'ri_full_channel:' in parts['perspective_sample'] or (pigments and all(pigments)):
        return source,parts
    # Existing symbolic zero-page owners must not alias the reserved band.
    for name,value in re.findall(r'(?mi)^(\w+)\s*=\s*\$([0-9a-f]{1,4})\s*(?:;[^\n]*)?$',source):
        # Uppercase FACE_COUNT and other scalar configuration values are not
        # RAM allocations. Runtime scratch aliases use lower-case names.
        if (not name.isupper() or name.startswith('ZP_')) and 0xe8<=int(value,16)<0xf0:
            raise ValueError('UV_ZP_CONFLICT: '+name)
    for line in source.splitlines():
        m=re.match(r'\s*(?:lda|ldx|ldy|sta|stx|sty|adc|sbc|cmp|cpx|cpy|inc|dec|asl|lsr|rol|ror|and|ora|eor|bit)\s+(?:\(\s*)?\$0*(e[89a-f])\b',line,re.I)
        if m:raise ValueError('UV_ZP_CONFLICT: direct operand '+line.strip())
    old=''.join(f' lda ps_cur0+{ch}\n sta ps_a\n lda ps_cur1+{ch}\n sta ps_a+1\n jsr ps_uv_divide\n sta m7_{name}\n' for ch,name in ((0,'u'),(1,'v')))
    new=''.join(f' lda ps_cur0+{ch}\n sta up_inputlo+{ch}\n lda ps_cur1+{ch}\n sta up_inputhi+{ch}\n' for ch in range(2))+' jsr up_pair\n'
    sample=parts['perspective_sample'];assert sample.count(old)==1
    parts['perspective_sample']=sample.replace(old,new)
    # Encoder product scratch is dead during sampling and not touched by scalar
    # division. No extra absolute state and no IRQ consumers are introduced.
    parts['data']+='''up_inputlo = ps_prod
up_inputhi = ps_prod+2
uz_remlo = $e8
uz_remhi = $ea
uz_denlo = $ec
uz_denhi = $ed
uz_quotient = $ee
.if m7_v != m7_u+1
 .error "Paired UV output must be contiguous"
.endif
'''
    parts['perspective_uv_pair']=kernel()
    return source,parts
