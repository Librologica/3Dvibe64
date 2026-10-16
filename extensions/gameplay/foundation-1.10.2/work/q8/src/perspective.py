"""Fixed-point projective UV adapter; only explicit Mode7 Q8 opt-in.
Copyright 2026 librologica.digital. PolyForm Noncommercial 1.0.0.
W=32768/Z, UW=floor(raw_U_Q4.4 * W /128). All carriers unsigned16.
Near clipping precedes encoding; screen clipping interpolates UW,VW,W.
"""
import re
from texture_edges import generate

def once(s,a,b):
    assert s.count(a)==1,(a[:80],s.count(a))
    return s.replace(a,b)

def adapt(source,parts,placed=None):
    shaded='m3_q0:' in source
    rational = not shaded and 'm2_update_face_lighting:' not in source
    # Source is fresh at both sizing and final attachment. Parts are not.
    source=once(source,'m7_sample:\n','m7_sample:\n jsr ps_sample\n')
    # Mixed repeat kernels patch the ORIGINAL address jump, not the newly
    # inserted projective-sampling JSR. Both operands moved by three bytes.
    source=source.replace(' sta m7_sample+1\n',' sta m7_sample+4\n')
    source=source.replace(' sta m7_sample+2\n',' sta m7_sample+5\n')
    a=source.index('m7_advance:\n');b=source.index('m7_prepare_span:\n',a)
    source=source[:a]+'m7_advance:\n jmp ps_advance\n\n'+source[b:]
    a=source.index('m7_prepare_span:\n');b=source.index('; A=start, X=end, m7_den=length.',a)
    source=source[:a]+'m7_prepare_span:\n jmp ps_prepare_span\n\n'+source[b:]
    if placed is not None:
        if rational:
            import perspective_rational
            return perspective_rational.apply(source,{},state,once)[0],parts
        return source,parts
    # Encoding occurs only on the camera-near output, NEVER after screen clip.
    parts['clip_helpers']=once(parts['clip_helpers'],'hc_append_a:\n','hc_append_a:\n jsr ps_encode\n')
    old=' lda hc_face_vertices,x\n tax\n lda tq_cache_x0,x\n'
    loads=''.join(f' lda hc_cam_z{j},x\n sta hc_depth+{j}\n' for j in range(3))
    parts['clip']=once(parts['clip'],old,old.replace(' lda tq_cache_x0,x\n',loads+' lda tq_cache_x0,x\n'))
    # Copy/intersection helpers keep the additional rational denominator.
    helpers=parts['clip_helpers']
    for bank in 'ab':
        old=''.join(f' lda hc_{bank}_s{p},x\n sta hc_out_s+{j}\n' for j,p in enumerate(('lo','hi')))
        helpers=once(helpers,old,old.replace('_s','_w')+old)
        old=''.join(f' lda hc_out_s+{j}\n sta hc_{bank}_s{p},y\n' for j,p in enumerate(('lo','hi')))
        helpers=once(helpers,old,old.replace('_s','_w')+old)
    old=''.join(f' lda hc_b_s{p},x\n sta hc_a_s{p},x\n' for p in ('lo','hi'))
    helpers=once(helpers,old,old.replace('_s','_w')+old)
    interpolation=parts['texture_helpers']
    a=interpolation.index('hc_interpolate_s:');b=interpolation.index('\n rts\n',a)+len('\n rts\n')
    parts['texture_helpers']+=interpolation[a:b].replace('_s','_w')
    parts['clip_helpers']=helpers
    parts['clip']=once(parts['clip'],' jsr hc_interpolate_s\n',' jsr hc_interpolate_w\n jsr hc_interpolate_s\n')
    edge,data=generate(shaded,perspective=True);parts['poly_draw']=edge
    # Remove the old edge state before adding the new five-channel state.
    _,old_data=generate(shaded)
    parts['data']=once(parts['data'],old_data,data)
    for bank in 'ab':
        for p in ('lo','hi'):parts['data']+=f'hc_{bank}_w{p}: .fill 12,0\n'
    parts['data']+='hc_out_w: .word 0\n'
    # Reuse existing byte arrays for low halves; additional 800 bytes high/W.
    for side,old in [('left','leftshade'),('right','rightshade')]:
        parts['data']+=f'ps_{side}s_lo = {old}\nps_{side}v_lo = m7_{side}v\n'
        for n in ('s_hi','v_hi','w_lo','w_hi'):parts['data']+=f'ps_{side}{n}: .fill VIEWPORT_ROW_CAPACITY,0\n'
    # Keep the proven complete/partial byte kernel and Gouraud compositor.
    parts['perspective_encode']=encoder()
    parts['perspective_sample']=sampler(shaded)
    parts['perspective_span']=spans(shaded)
    parts['perspective_state']=state()
    if rational:
        import perspective_rational
        return perspective_rational.apply(source,parts,state,once)
    return source,parts

def encoder():
    s='''; raw UV are u8 with 8 clipping fraction bits; preserve both.
ps_encode:
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
ps_encode_valid:
 ldx #5
 lda #0
-
 sta hc_num,x
 dex
 bpl -
 lda #128
 sta hc_num+2
 ldx #2
-
 lda hc_depth,x
 sta hc_divisor,x
 dex
 bpl -
 jsr hc_div40
 lda hc_num
 sta hc_out_w
 sta ps_b
 lda hc_num+1
 sta hc_out_w+1
 sta ps_b+1
'''
    for a in 'sv':
        s+=f' lda hc_out_{a}\n sta ps_a\n lda hc_out_{a}+1\n sta ps_a+1\n jsr ps_mul16\n'
        s+=f' lda ps_prod+2\n asl\n sta hc_out_{a}\n lda ps_prod+1\n asl\n lda hc_out_{a}\n adc #0\n sta hc_out_{a}\n'
        s+=f' lda ps_prod+3\n asl\n sta hc_out_{a}+1\n lda ps_prod+2\n asl\n lda hc_out_{a}+1\n adc #0\n sta hc_out_{a}+1\n'
    s+=''' rts
; Unsigned16 x unsigned16 => unsigned32. ps_b preserved for V.
ps_mul16:
 ldx #3
 lda #0
-
 sta ps_prod,x
 sta ps_shift,x
 dex
 bpl -
 lda ps_a
 sta ps_shift
 lda ps_a+1
 sta ps_shift+1
 lda ps_b
 sta ps_bits
 lda ps_b+1
 sta ps_bits+1
 ldx #16
ps_mul_loop:
 lsr ps_bits+1
 ror ps_bits
 bcc ps_mul_shift
 clc
'''
    for j in range(4):s+=f' lda ps_prod+{j}\n adc ps_shift+{j}\n sta ps_prod+{j}\n'
    s+=' asl ps_shift\n rol ps_shift+1\n rol ps_shift+2\n rol ps_shift+3\n dex\n bne ps_mul_loop\n rts\n'
    # Branch target is before the shifts, not the additions.
    s=s.replace(' asl ps_shift\n','ps_mul_shift:\n asl ps_shift\n')
    return s

def sampler(shaded):
    s='ps_sample:\n stx ps_saved_x\n'
    s+=' lda ps_cur0+2\n sta ps_den\n lda ps_cur1+2\n sta ps_den+1\n'
    for ch,n in [(0,'u'),(1,'v')]:
        s+=f' lda ps_cur0+{ch}\n sta ps_a\n lda ps_cur1+{ch}\n sta ps_a+1\n jsr ps_uv_divide\n sta m7_{n}\n'
    s+=' ldx ps_saved_x\n rts\n'+uv_division()+division()
    return s

def uv_division():
    return '''; Exact floor((ps_a unsigned16 *128)/ps_den unsigned16).
; q<256: extract one integer bit followed by seven fractional bits.
; Full quotient24/remainder16 preserved. Original divider handles other inputs.
; Private absolute state only; no SMC/ZP/IRQ changes.
ps_uv_divide:
 lda ps_den
 ora ps_den+1
 bne ps_uv_nonzero
 jmp ps_uv_fallback
ps_uv_nonzero:
 lda ps_a
 sta ps_remainder
 lda ps_a+1
 sta ps_remainder+1
 lda #0
 sta ps_num
 sta ps_num+1
 sta ps_num+2
 lda ps_remainder+1
 cmp ps_den+1
 bcc ps_uv_fraction
 bne ps_uv_integer
 lda ps_remainder
 cmp ps_den
 bcc ps_uv_fraction
ps_uv_integer:
 sec
 lda ps_remainder
 sbc ps_den
 sta ps_remainder
 lda ps_remainder+1
 sbc ps_den+1
 sta ps_remainder+1
 inc ps_num
 ; A/W>=2: do not truncate the full quotient or change its low byte.
 lda ps_remainder+1
 cmp ps_den+1
 bcc ps_uv_fraction
 bne ps_uv_fallback
 lda ps_remainder
 cmp ps_den
 bcs ps_uv_fallback
ps_uv_fraction:
 ldx #7
ps_uv_bit:
 asl ps_remainder
 rol ps_remainder+1
 bcs ps_uv_subtract
 lda ps_remainder+1
 cmp ps_den+1
 bcc ps_uv_zero_bit
 bne ps_uv_subtract
 lda ps_remainder
 cmp ps_den
 bcc ps_uv_zero_bit
ps_uv_subtract:
 sec
 lda ps_remainder
 sbc ps_den
 sta ps_remainder
 lda ps_remainder+1
 sbc ps_den+1
 sta ps_remainder+1
 sec
 jmp ps_uv_append
ps_uv_zero_bit:
 clc
ps_uv_append:
 rol ps_num
 dex
 bne ps_uv_bit
 lda ps_num
 rts
ps_uv_fallback:
 lda ps_a
 sta ps_num
 lda ps_a+1
 sta ps_num+1
 lda #0
 sta ps_num+2
 ldx #7
-
 asl ps_num
 rol ps_num+1
 rol ps_num+2
 dex
 bne -
 jsr ps_div24_16
 lda ps_num
 rts
'''

def division():
    return '''; Unsigned numerator24/denominator16, exact floor and remainder.
; Documented 6510 instructions, private absolute scratch, no SMC.
ps_div24_16:
 lda #0
 sta ps_remainder
 sta ps_remainder+1
 lda ps_den
 ora ps_den+1
 bne ps_div_nonzero
 inc ps_fault
 lda #0
 sta ps_num
 sta ps_num+1
 sta ps_num+2
 rts
ps_div_nonzero:
 ldx #24
ps_div_loop:
 asl ps_num
 rol ps_num+1
 rol ps_num+2
 rol ps_remainder
 rol ps_remainder+1
 bcs ps_div_subtract
 lda ps_remainder+1
 cmp ps_den+1
 bcc ps_div_next
 bne ps_div_subtract
 lda ps_remainder
 cmp ps_den
 bcc ps_div_next
ps_div_subtract:
 sec
 lda ps_remainder
 sbc ps_den
 sta ps_remainder
 lda ps_remainder+1
 sbc ps_den+1
 sta ps_remainder+1
 inc ps_num
ps_div_next:
 dex
 bne ps_div_loop
 rts
'''

def spans(shaded):
    s='ps_prepare_span:\n'
    if shaded:s+=' jsr m3_prepare_span\n'
    s+=''' lda yrow
 and #3
 asl
 asl
 sta m2_bayer_row
 sec
 lda rightval
 sbc leftval
 sta m7_den
 lda leftval
 sta gouraud_scan_x
 lda rightval
 sta gouraud_scan_end
 ldx yrow
 lda tq_closed,x
 bne ps_span_closed
 dec gouraud_scan_end
ps_span_closed:
'''
    for ch,a in enumerate('svw'):
        s+=f' ldy yrow\n lda ps_left{a}_lo,y\n sta ps_cur0+{ch}\n lda ps_left{a}_hi,y\n sta ps_cur1+{ch}\n'
        s+=f' sec\n lda ps_right{a}_lo,y\n sbc ps_cur0+{ch}\n sta hc_delta\n lda ps_right{a}_hi,y\n sbc ps_cur1+{ch}\n sta hc_delta+1\n'
        s+=f' lda #0\n sbc #0\n sta hc_delta+2\n jsr ps_setup\n lda hc_result\n sta ps_step0+{ch}\n lda hc_result+1\n sta ps_step1+{ch}\n lda hc_remainder\n sta ps_rem+{ch}\n lda #0\n sta ps_err+{ch}\n'
    s+=''' rts
ps_setup:
 lda m7_den
 bne ps_setup_nonzero
 lda #0
 sta hc_result
 sta hc_result+1
 sta hc_result+2
 sta hc_remainder
 sta hc_remainder+1
 rts
ps_setup_nonzero:
 sta hc_den
 lda #0
 sta hc_den+1
 sta hc_den+2
 sta hc_factor+1
 sta hc_factor+2
 lda #1
 sta hc_factor
 jsr hq_ratio_product
 ; Euclidean floor, exact signed step with nonnegative remainder.
 lda hc_sign
 bpl ps_setup_done
 lda hc_remainder
 ora hc_remainder+1
 beq ps_setup_done
 sec
 lda hc_result
 sbc #1
 sta hc_result
 lda hc_result+1
 sbc #0
 sta hc_result+1
 sec
 lda m7_den
 sbc hc_remainder
 sta hc_remainder
ps_setup_done:
 rts

ps_advance:
 stx ps_saved_x
 ldx #0
ps_advance_loop:
 clc
 lda ps_cur0,x
 adc ps_step0,x
 sta ps_cur0,x
 lda ps_cur1,x
 adc ps_step1,x
 sta ps_cur1,x
 clc
 lda ps_err,x
 adc ps_rem,x
 bcs ps_advance_correct
 cmp m7_den
 bcc ps_advance_store
ps_advance_correct:
 sec
 sbc m7_den
 sta ps_err,x
 inc ps_cur0,x
 bne ps_advance_next
 inc ps_cur1,x
 jmp ps_advance_next
ps_advance_store:
 sta ps_err,x
ps_advance_next:
 inx
 cpx #3
 bne ps_advance_loop
 ldx ps_saved_x
'''
    if not shaded:s=s.replace(' lda yrow\n and #3\n asl\n asl\n sta m2_bayer_row\n','')
    if shaded:s+=' jsr m3_advance_q\n'
    s+=' inc gouraud_scan_x\n rts\n'
    a=s.index('ps_setup:\n');b=s.index('ps_advance:\n',a)
    return s[:a]+span_division()+s[b:]

def span_division():
    return '''; Exact signed17 delta / unsigned8 span width, Euclidean floor.
; Normal input is a difference of unsigned16 carriers: -65535..65535.
; Callers ONLY subtract unsigned16 endpoint carriers, so sign is 00/FF.
; Restoring16/8 division, no extra state, no additional allocation block.
ps_setup:
 lda m7_den
 bne pss_nonzero
 lda #0
 sta hc_result
 sta hc_result+1
 sta hc_result+2
 sta hc_remainder
 sta hc_remainder+1
 rts
pss_nonzero:
 lda hc_delta+2
 sta hc_sign
 ; Positive: divide delta. Negative: divide abs(delta)-1, then complement
 ; quotient and denominator-1-remainder. Exactly floor, without borrow fix.
 lda hc_delta
 eor hc_sign
 sta hc_result
 lda hc_delta+1
 eor hc_sign
 sta hc_result+1
pss_unsigned:
 lda #0
 sta hc_result+2
 sta hc_remainder
 sta hc_remainder+1
 sta hc_remainder+2
 ldx #16
pss_loop:
 asl hc_result
 rol hc_result+1
 rol hc_remainder
 bcs pss_short_sub
 lda hc_remainder
 cmp m7_den
 bcc pss_short_next
pss_short_sub:
 sec
 lda hc_remainder
 sbc m7_den
 sta hc_remainder
 inc hc_result
pss_short_next:
 dex
 bne pss_loop
pss_sign:
 lda hc_sign
 bpl pss_done
 lda hc_result
 eor #255
 sta hc_result
 lda hc_result+1
 eor #255
 sta hc_result+1
 clc
 lda m7_den
 sbc hc_remainder
 sta hc_remainder
pss_done:
 rts
'''

def state():
    s='ps_fault: .byte 0\nps_saved_x: .byte 0\n'
    for n,size in [('a',2),('b',2),('bits',2),('prod',4),('shift',4),('num',3),('den',2),('remainder',2),('cur0',3),('cur1',3),('step0',3),('step1',3),('rem',3),('err',3)]:s+=f'ps_{n}: .fill {size},0\n'
    return s
