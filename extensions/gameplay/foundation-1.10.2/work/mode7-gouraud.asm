; M3 shade topology is emitted by the unchanged Mode 6 builder.
; Point-light dot/intensity follow M2; no specular/reflectivity.
m3_update_shades:
 ldx objidx
 lda object_runtime_shade_first,x
 sta tmpidx
 lda object_runtime_shade_end,x
 sta fullcount
m3_shade_loop:
 lda tmpidx
 cmp fullcount
 beq m3_shade_done
 tay
 lda #0
 sta dotlo
 sta dothi
 lda gouraud_normal_x,y
 ldx sh_nx
 jsr mul_s8_16
 jsr add_dot_product
 ldy tmpidx
 lda gouraud_normal_y,y
 ldx sh_ny
 jsr mul_s8_16
 jsr add_dot_product
 ldy tmpidx
 lda gouraud_normal_z,y
 ldx sh_nz
 jsr mul_s8_16
 jsr add_dot_product
 ldy tmpidx
 sec
 lda dotlo
 sbc gouraud_center_dot_lo,y
 sta dotlo
 lda dothi
 sbc gouraud_center_dot_hi,y
 bmi m3_shade_dark
 ldx light_intensity
 jsr mul_s8_16
 lsr prodhi
 ror prodlo
 lsr prodhi
 ror prodlo
 lsr prodhi
 ror prodlo
 lda prodhi
 bne m3_shade_max
 lda prodlo
 cmp #33
 bcc m3_shade_store
m3_shade_max:
 lda #32
 bne m3_shade_store
m3_shade_dark:
 lda #0
m3_shade_store:
 ldy tmpidx
 sta gouraud_shade_value,y
 inc tmpidx
 jmp m3_shade_loop
m3_shade_done:
 rts
m3_update_shades_end = *

m3_interp_clip_q:
 sec
 lda m3_clip_q_out
 sbc m3_clip_q_in
 sta p1lo
 lda #0
 sbc #0
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 clc
 lda p1lo
 adc m3_clip_q_in
 sta m3_clip_q_result
 rts
m3_interp_clip_q_end = *

m3_prepare_span:
 sec
 lda rightval
 sbc leftval
 sta m7_den
 ldy yrow
 lda m3_leftq,y
 sta m3_qcur
 ldx m3_rightq,y
 jsr m7_dda_setup
 lda m7_q
 sta m3_qstep
 lda m7_r
 sta m3_qrem
 lda m7_dir
 sta m3_qdir
 lda #0
 sta m3_qerr
 rts
m3_prepare_span_end = *

m3_advance_q:
 clc
 lda m3_qcur
 adc m3_qstep
 sta m3_qcur
 clc
 lda m3_qerr
 adc m3_qrem
 bcs m3_q_correct
 cmp m7_den
 bcc m3_q_store
m3_q_correct:
 sec
 sbc m7_den
 sta m3_qerr
 clc
 lda m3_qcur
 adc m3_qdir
 sta m3_qcur
 rts
m3_q_store:
 sta m3_qerr
 rts
m3_advance_q_end = *

; Exact M2 compositor equation, evaluated with the current sample Q.
; E = (Q >> 1) + 8*(texel-1). Only shifts/adds, no divide/multiply.
m3_composite:
 sec
 sbc #1
 asl
 asl
 asl
 sta m3_texel
 lda m3_qcur
 lsr
 clc
 adc m3_texel
 ldx #1
 cmp #16
 bcc m3_quantize
 sec
 sbc #16
 inx
m3_quantize:
 sta m3_threshold
 stx m3_base
 lda gouraud_scan_x
 and #3
 ora m2_bayer_row
 tay
 lda m3_threshold
 cmp m2_bayer,y
 lda m3_base
 adc #0
 rts
m3_composite_end = *
