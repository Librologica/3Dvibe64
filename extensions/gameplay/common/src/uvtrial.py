"""Exact paired division feasibility variants; no public generator changes.
Required Notice:3Dvibe64. PolyForm Noncommercial1.0.0.
"""
from uvpair import kernel as original

def kernel(kind):
    s=original('unrolled')
    if kind=='baseline':return s
    assert kind in ('trial','highfirst')
    # With W<=32768 and R<W, 2R fits16 bits; otherwise exact old fallback.
    gate=''' lda ps_den+1
 cmp #128
 bcc ut_domain_ok
 bne up_fallback
 lda ps_den
 bne up_fallback
ut_domain_ok:
'''
    s=s.replace(' ldx #1\nup_init:\n',gate+' ldx #1\nup_init:\n',1)
    def bit(tag,idx):
        pre=f' asl up_remlo{idx}\n rol up_remhi{idx}\n sec\n'
        if kind=='trial':
            return pre+f''' lda up_remlo{idx}
 sbc ps_den
 tax
 lda up_remhi{idx}
 sbc ps_den+1
 bcc ut_append_{tag}
 sta up_remhi{idx}
 stx up_remlo{idx}
ut_append_{tag}:
 ; On failure R stays untouched and C0; success stores R with C1.
 rol m7_u{idx}
'''
        return pre+f''' lda up_remhi{idx}
 sbc ps_den+1
 bcc ut_zero_{tag}
 tax
 lda up_remlo{idx}
 sbc ps_den
 bcs ut_store_{tag}
 dex
 cpx #255
 beq ut_zero_{tag}
ut_store_{tag}:
 sta up_remlo{idx}
 stx up_remhi{idx}
 sec
 bcs ut_append_{tag}
ut_zero_{tag}:
 clc
ut_append_{tag}:
 rol m7_u{idx}
'''
    a=s.index('up_bit:\n');b=s.index(' dey\n bne up_bit\n',a)
    return s[:a]+'up_bit:\n'+bit('u','')+bit('v','+1')+s[b:]

def adapt(source,parts,placed,kind):
    if kind=='baseline' or placed is not None:return source,parts
    old=original('unrolled');assert parts['perspective_sample'].count(old)==1
    parts['perspective_sample']=parts['perspective_sample'].replace(old,kernel(kind))
    return source,parts
