"""Compact exact rational sampler, unlit projective Mode 7 only.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. No approximate perspective correction.
"""
def aliases():
    return '''; Retired unlit affine state; encoder scratch is idle within spans.
ri_mode = m7_start
ri_rlo = m7_uerr
ri_rhi = m7_udir
ri_slo = m7_urem
ri_shi = m7_ustep
ri_ca = ps_prod
.if m7_v != m7_u+1 || m7_verr != m7_uerr+1 || m7_vdir != m7_udir+1 || m7_vrem != m7_urem+1 || m7_vstep != m7_ustep+1
 .error "Rational alias byte pairs must be contiguous"
.endif
'''

def select():
    return '''ri_select:
 lda #0
 sta ri_mode
 lda m7_den
 cmp #8
 bcc ri_select_done
 ldx #2
ri_step_check:
 lda ps_step1,x
 beq ri_positive_step
 cmp #255
 bne ri_select_done
 lda ps_step0,x
 cmp #224
 bcc ri_select_done
 bcs ri_step_ok
ri_positive_step:
 lda ps_step0,x
 cmp #33
 bcs ri_select_done
ri_step_ok:
 dex
 bpl ri_step_check
 inc ri_mode
ri_select_done:
 rts
'''

def sample():
    return '''ps_sample:
 stx ps_saved_x
 lda ps_cur0+2
 sta ps_den
 lda ps_cur1+2
 sta ps_den+1
 ; W256..8191, |carrier integer steps|<=32, full q0..255.
 ; |S|<=12256 and pre-normalization |R|<20704: signed16 is sufficient.
 lda ri_mode
 beq ri_full
 lda ps_den+1
 beq ri_disable
 cmp #32
 bcs ri_disable
 lda ri_mode
 cmp #2
 bne ri_full
 jmp ri_update
ri_disable:
 lda #0
 sta ri_mode
ri_full:
 ldy #0
ri_full_channel:
 lda ps_cur0,y
 sta ps_a
 lda ps_cur1,y
 sta ps_a+1
 jsr ps_uv_divide
 sta m7_u,y
 lda ri_mode
 beq ri_full_next
 lda ps_num+1
 ora ps_num+2
 bne ri_cancel_seed
 lda ps_remainder
 sta ri_rlo,y
 lda ps_remainder+1
 sta ri_rhi,y
 ; Signed16 stepA*128, modulo16; guard proves final S representable.
 lda ps_step1,y
 lsr
 lda ps_step0,y
 ror
 sta ri_shi,y
 lda #0
 ror
 sta ri_slo,y
 lda ps_step0+2
 sta ps_shift
 lda ps_step1+2
 sta ps_shift+1
 lda m7_u,y
 sta ps_bits
 ldx #8
ri_seed_product:
 lsr ps_bits
 bcc ri_seed_shift
 sec
 lda ri_slo,y
 sbc ps_shift
 sta ri_slo,y
 lda ri_shi,y
 sbc ps_shift+1
 sta ri_shi,y
ri_seed_shift:
 asl ps_shift
 rol ps_shift+1
 dex
 bne ri_seed_product
 beq ri_full_next
ri_cancel_seed:
 lda #0
 sta ri_mode
ri_full_next:
 iny
 cpy #2
 bne ri_full_channel
 lda ri_mode
 beq ri_return
 inc ri_mode
ri_return:
 ldx ps_saved_x
 rts
ri_update:
 ldx #0
ri_update_channel:
 clc
 lda ri_rlo,x
 adc ri_slo,x
 sta ri_rlo,x
 lda ri_rhi,x
 adc ri_shi,x
 sta ri_rhi,x
 lda ri_ca,x
 beq ri_no_ca
 clc
 lda ri_rlo,x
 adc #128
 sta ri_rlo,x
 lda ri_rhi,x
 adc #0
 sta ri_rhi,x
ri_no_ca:
 lda ri_ca+2
 beq ri_normalize
 sec
 lda ri_rlo,x
 sbc m7_u,x
 sta ri_rlo,x
 lda ri_rhi,x
 sbc #0
 sta ri_rhi,x
ri_normalize:
 lda ri_rhi,x
 bmi ri_down
 cmp ps_den+1
 bcc ri_next
 bne ri_up
 lda ri_rlo,x
 cmp ps_den
 bcc ri_next
ri_up:
 lda m7_u,x
 cmp #255
 beq ri_abort
 sec
 lda ri_rlo,x
 sbc ps_den
 sta ri_rlo,x
 lda ri_rhi,x
 sbc ps_den+1
 sta ri_rhi,x
 inc m7_u,x
 sec
 lda ri_slo,x
 sbc ps_step0+2
 sta ri_slo,x
 lda ri_shi,x
 sbc ps_step1+2
 sta ri_shi,x
 jmp ri_normalize
ri_abort:
 jmp ri_disable
ri_down:
 lda m7_u,x
 beq ri_abort
 clc
 lda ri_rlo,x
 adc ps_den
 sta ri_rlo,x
 lda ri_rhi,x
 adc ps_den+1
 sta ri_rhi,x
 dec m7_u,x
 clc
 lda ri_slo,x
 adc ps_step0+2
 sta ri_slo,x
 lda ri_shi,x
 adc ps_step1+2
 sta ri_shi,x
 jmp ri_normalize
ri_next:
 inx
 cpx #2
 bne ri_update_channel
 jmp ri_return
'''

def apply(source,parts,state,once):
    # unlit-only: the shaded path has live affine state consumers.
    import re
    assert len(re.findall(r'\bm7_dda_setup\b',source))==1
    a=source.index('; A=start, X=end, m7_den=length.');b=source.index('; Signed, pre-viewport table-projection result',a)
    source=source[:a]+source[b:]
    for n in ('m7_ustep','m7_vstep','m7_urem','m7_vrem','m7_uerr','m7_verr','m7_udir','m7_vdir','m7_start'):
        assert len(re.findall(r'\b'+n+r'\b',source))==1,('Live affine state',n)
    if 'perspective_sample' not in parts:return source,parts
    s=parts['perspective_sample']
    a=s.index('ps_uv_fallback:')
    divider='ps_uv_divide:\n'+s[a:]
    # Only the original unsigned24/16 divider is needed for seed/fallback.
    parts['perspective_sample']=sample()+divider
    spans=parts['perspective_span']
    exit_at=spans.rfind(' rts\n',0,spans.index('ps_setup:\n'))
    assert exit_at>=0
    spans=spans[:exit_at]+' jsr ri_select\n'+spans[exit_at:]
    spans=once(spans,'ps_advance_loop:\n','ps_advance_loop:\n lda #0\n sta ri_ca,x\n')
    spans=once(spans,'ps_advance_correct:\n','ps_advance_correct:\n inc ri_ca,x\n')
    parts['perspective_span']=spans
    parts['perspective_select']=select()
    parts['data']+=state()+aliases()
    del parts['perspective_state']
    return source,parts
