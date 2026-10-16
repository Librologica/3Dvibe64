"""Exact paired U/V prototypes and demo-only full fast-domain integration.
Required Notice: 3Dvibe64. Copyright2026 librologica.digital.
PolyForm Noncommercial1.0.0. No SDK/frozen changes.
"""

def kernel(kind):
    if kind not in ('indexed','unrolled','fractional'):raise ValueError(kind)
    s='''up_pair:
 lda ps_den
 ora ps_den+1
 beq up_fallback
 ldx #1
up_init:
 lda up_inputlo,x
 sta up_remlo,x
 lda up_inputhi,x
 sta up_remhi,x
 lda #0
 sta m7_u,x
 lda up_remhi,x
 cmp ps_den+1
 bcc up_init_next
 bne up_initial_sub
 lda up_remlo,x
 cmp ps_den
 bcc up_init_next
up_initial_sub:
 sec
 lda up_remlo,x
 sbc ps_den
 sta up_remlo,x
 lda up_remhi,x
 sbc ps_den+1
 sta up_remhi,x
 inc m7_u,x
 lda up_remhi,x
 cmp ps_den+1
 bcc up_init_next
 bne up_fallback
 lda up_remlo,x
 cmp ps_den
 bcs up_fallback
up_init_next:
 dex
 bpl up_init
 ldy #7
up_bit:
'''
    def bit(tag,idx):
        return f''' asl up_remlo{idx}
 rol up_remhi{idx}
 bcs up_sub_{tag}
 lda up_remhi{idx}
 cmp ps_den+1
 bcc up_zero_{tag}
 bne up_sub_{tag}
 lda up_remlo{idx}
 cmp ps_den
 bcc up_zero_{tag}
up_sub_{tag}:
 sec
 lda up_remlo{idx}
 sbc ps_den
 sta up_remlo{idx}
 lda up_remhi{idx}
 sbc ps_den+1
 sta up_remhi{idx}
 sec
 jmp up_append_{tag}
up_zero_{tag}:
 clc
up_append_{tag}:
 rol m7_u{idx}
'''
    if kind=='indexed':
        s+=' ldx #1\nup_channel:\n'+bit('shared',',x')+' dex\n bpl up_channel\n'
    else:s+=bit('u','')+bit('v','+1')
    s+=''' dey
 bne up_bit
 rts
up_fallback:
 lda up_inputlo
 sta ps_a
 lda up_inputhi
 sta ps_a+1
 jsr ps_uv_divide
 sta m7_u
 lda up_inputlo+1
 sta ps_a
 lda up_inputhi+1
 sta ps_a+1
 jsr ps_uv_divide
 sta m7_v
 rts
'''
    if kind=='fractional':
        start='''up_pair:
 ldx #1
up_init:
 lda up_inputlo,x
 sta up_remlo,x
 lda up_inputhi,x
 sta up_remhi,x
 cmp ps_den+1
 bcc up_init_next
 bne up_fallback
 lda up_remlo,x
 cmp ps_den
 bcs up_fallback
up_init_next:
 dex
 bpl up_init
 ; After seven ROLs only the old bit0 could remain as output bit7.
 ; ASL forces it zero; all remaining old bits are shifted out exactly.
 asl m7_u
 asl m7_v
 ldy #7
up_bit:
'''
        s=start+s.split('up_bit:\n',1)[1]
        s=s.replace('jsr ps_uv_divide','jsr ps_uv_fallback')
    return s

def adapt(source,parts,placed):
    if placed is None:
        s=parts['perspective_sample']
        # Keep the whole original scalar divider as the exact fallback.
        # The paired fast path includes each channel's integer quotient bit.
        start=s.index('ps_uv_divide:\n')
        s=s[:start]+kernel('unrolled')+s[start:]
        for prefix in ('ps_cur','bk_look'):
            old=''
            for ch,out in enumerate(('m7_u','m7_v') if prefix=='ps_cur' else ('bk_next+0','bk_next+1')):
                old+=f' lda {prefix}0+{ch}\n sta ps_a\n lda {prefix}1+{ch}\n sta ps_a+1\n jsr ps_uv_divide\n sta {out}\n'
            new=''
            for ch in range(2):
                new+=f' lda {prefix}0+{ch}\n sta up_inputlo+{ch}\n lda {prefix}1+{ch}\n sta up_inputhi+{ch}\n'
            new+=' jsr up_pair\n'
            if prefix=='bk_look':
                new+=' lda m7_u\n sta bk_next+0\n lda m7_v\n sta bk_next+1\n'
            assert s.count(old)==1,(prefix,s.count(old))
            s=s.replace(old,new)
        parts['perspective_sample']=s
        # Existing multiply scratch, dead across sampling and reinitialized
        # before next setup. Generic fallback touches neither prod nor shift.
        parts['data']+='''up_inputlo = ps_prod
up_inputhi = ps_prod+2
up_remlo = ps_shift
up_remhi = ps_shift+2
.if m7_v != m7_u+1
 .error "Paired UV output must be contiguous"
.endif
'''
    return source,parts
