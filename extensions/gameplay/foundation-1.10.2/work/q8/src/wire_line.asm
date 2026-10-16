; Bounded unsigned Q2 endpoints; connected, canonical major-axis sampler.
; Plot rounded endpoints and all integer major samples within the true segment.
; For each interior sample: floor((aMinor*D + delta*(4*i-aMajor)+2*D)/(4*D)).
; Setup uses exact products/division once; loop uses signed remainder increments.
; IRQ/player do not touch any qw_/hc_/hp_ state or the two face fetch SMC sites.
qw_line:
 sec
 lda qw_x1
 sbc qw_x0
 sta qw_dx
 lda qw_x1+1
 sbc qw_x0+1
 sta qw_dx+1
 bpl qw_dx_abs
 sec
 lda #0
 sbc qw_dx
 sta qw_dx
 lda #0
 sbc qw_dx+1
 sta qw_dx+1
qw_dx_abs:
 sec
 lda qw_y1
 sbc qw_y0
 sta qw_dy
 lda qw_y1+1
 sbc qw_y0+1
 sta qw_dy+1
 bpl qw_dy_abs
 sec
 lda #0
 sbc qw_dy
 sta qw_dy
 lda #0
 sbc qw_dy+1
 sta qw_dy+1
qw_dy_abs:
 lda #0
 sta qw_major
 lda qw_dx+1
 cmp qw_dy+1
 bcc qw_y_major
 bne qw_x_major
 lda qw_dx
 cmp qw_dy
 bcs qw_x_major
qw_y_major:
 inc qw_major
 lda qw_y0
 sta qw_a
 lda qw_y0+1
 sta qw_a+1
 lda qw_y1
 sta qw_b
 lda qw_y1+1
 sta qw_b+1
 lda qw_x0
 sta qw_c
 lda qw_x0+1
 sta qw_c+1
 lda qw_x1
 sta qw_d
 lda qw_x1+1
 sta qw_d+1
 jmp qw_order
qw_x_major:
 lda qw_x0
 sta qw_a
 lda qw_x0+1
 sta qw_a+1
 lda qw_x1
 sta qw_b
 lda qw_x1+1
 sta qw_b+1
 lda qw_y0
 sta qw_c
 lda qw_y0+1
 sta qw_c+1
 lda qw_y1
 sta qw_d
 lda qw_y1+1
 sta qw_d+1
qw_order:
 lda qw_b+1
 cmp qw_a+1
 bcc qw_swap
 bne qw_ordered
 lda qw_b
 cmp qw_a
 bcs qw_ordered
qw_swap:
 ldx #1
qw_swap_loop:
 lda qw_a,x
 ldy qw_b,x
 sta qw_b,x
 tya
 sta qw_a,x
 lda qw_c,x
 ldy qw_d,x
 sta qw_d,x
 tya
 sta qw_c,x
 dex
 bpl qw_swap_loop
qw_ordered:
 ; Endpoint pixels preserve subpixel-sized lines and connection at mesh corners.
 lda qw_a
 ldx qw_a+1
 jsr qw_round
 sta qw_pos
 lda qw_c
 ldx qw_c+1
 jsr qw_round
 sta qw_minor
 jsr qw_emit
 lda qw_b
 ldx qw_b+1
 jsr qw_round
 sta qw_pos
 lda qw_d
 ldx qw_d+1
 jsr qw_round
 sta qw_minor
 jsr qw_emit
 sec
 lda qw_b
 sbc qw_a
 sta qw_dx
 lda qw_b+1
 sbc qw_a+1
 sta qw_dx+1
 ora qw_dx
 beq qw_line_done
 ; ceil(a/4), floor(b/4).
 clc
 lda qw_a
 adc #3
 sta hc_q
 lda qw_a+1
 adc #0
 lsr
 ror hc_q
 lsr
 ror hc_q
 lda hc_q
 sta qw_pos
 lda qw_b
 sta hc_q
 lda qw_b+1
 lsr
 ror hc_q
 lsr
 ror hc_q
 lda hc_q
 sta qw_last
 cmp qw_pos
 bcc qw_line_done
 ; signed delta, product delta * (4*pos-a).
 sec
 lda qw_d
 sbc qw_c
 sta hp_a
 sta qw_step
 lda qw_d+1
 sbc qw_c+1
 sta hp_a+1
 sta qw_step+1
 sta qw_sign
 lda qw_pos
 sta hp_b
 lda #0
 sta hp_b+1
 asl hp_b
 rol hp_b+1
 asl hp_b
 rol hp_b+1
 sec
 lda hp_b
 sbc qw_a
 sta hp_b
 lda hp_b+1
 sbc qw_a+1
 sta hp_b+1
 jsr hp_mul
 lda hp_sign
 bpl qw_first_product
 sec
 lda #0
 sbc hp_p
 sta hp_p
 lda #0
 sbc hp_p+1
 sta hp_p+1
 lda #0
 sbc hp_p+2
 sta hp_p+2
 lda #0
 sbc hp_p+3
 sta hp_p+3
qw_first_product:
 ldx #3
qw_save_product:
 lda hp_p,x
 sta qw_saved,x
 dex
 bpl qw_save_product
 lda qw_c
 sta hp_a
 lda qw_c+1
 sta hp_a+1
 lda qw_dx
 sta hp_b
 lda qw_dx+1
 sta hp_b+1
 jsr hp_mul
 clc
 lda hp_p
 adc qw_saved
 sta hc_num
 lda hp_p+1
 adc qw_saved+1
 sta hc_num+1
 lda hp_p+2
 adc qw_saved+2
 sta hc_num+2
 lda hp_p+3
 adc qw_saved+3
 sta hc_num+3
 lda #0
 sta hc_num+4
 sta hc_num+5
 lda qw_dx
 sta qw_den
 lda qw_dx+1
 sta qw_den+1
 asl qw_den
 rol qw_den+1
 clc
 lda hc_num
 adc qw_den
 sta hc_num
 lda hc_num+1
 adc qw_den+1
 sta hc_num+1
 lda hc_num+2
 adc #0
 sta hc_num+2
 lda hc_num+3
 adc #0
 sta hc_num+3
 asl qw_den
 rol qw_den+1
 lda qw_den
 sta hc_divisor
 lda qw_den+1
 sta hc_divisor+1
 lda #0
 sta hc_divisor+2
 jsr hc_div40
 lda hc_num
 sta qw_minor
 lda hc_remainder
 sta qw_rem
 lda hc_remainder+1
 sta qw_rem+1
 lda qw_sign
 bpl qw_step_positive
 sec
 lda #0
 sbc qw_step
 sta qw_step
 lda #0
 sbc qw_step+1
 sta qw_step+1
qw_step_positive:
 asl qw_step
 rol qw_step+1
 asl qw_step
 rol qw_step+1
qw_line_loop:
 jsr qw_emit
 lda qw_pos
 cmp qw_last
 beq qw_line_done
 inc qw_pos
 lda qw_sign
 bmi qw_step_down
 clc
 lda qw_rem
 adc qw_step
 sta qw_rem
 lda qw_rem+1
 adc qw_step+1
 sta qw_rem+1
 cmp qw_den+1
 bcc qw_line_loop
 bne qw_rem_sub
 lda qw_rem
 cmp qw_den
 bcc qw_line_loop
qw_rem_sub:
 sec
 lda qw_rem
 sbc qw_den
 sta qw_rem
 lda qw_rem+1
 sbc qw_den+1
 sta qw_rem+1
 inc qw_minor
 jmp qw_line_loop
qw_step_down:
 sec
 lda qw_rem
 sbc qw_step
 sta qw_rem
 lda qw_rem+1
 sbc qw_step+1
 sta qw_rem+1
 bcs qw_line_loop
 clc
 lda qw_rem
 adc qw_den
 sta qw_rem
 lda qw_rem+1
 adc qw_den+1
 sta qw_rem+1
 dec qw_minor
 jmp qw_line_loop
qw_line_done:
 rts

qw_round:
 ; Unsigned Q2, round nearest, half ties towards positive coordinate.
 stx hc_q+1
 clc
 adc #2
 sta hc_q
 bcc qw_round_shift
 inc hc_q+1
qw_round_shift:
 lsr hc_q+1
 ror hc_q
 lsr hc_q+1
 ror hc_q
 lda hc_q
 rts
qw_emit:
 lda qw_major
 bne qw_emit_y
 lda qw_pos
 sta leftval
 lda qw_minor
 sta rightval
 jmp qw_emit_ready
qw_emit_y:
 lda qw_minor
 sta leftval
 lda qw_pos
 sta rightval
qw_emit_ready:
 lda qw_mask
 bne qw_emit_bounds
 jmp plot_wire_point
qw_emit_bounds:
.if GRAPHICS_MODE = 2
 ldx rightval
 lda leftval
 cmp leftb,x
 bcs qw_bound_max
 sta leftb,x
qw_bound_max:
 cmp rightb,x
 bcc qw_bound_y
 sta rightb,x
qw_bound_y:
 txa
 cmp face_ymin
 bcs qw_bound_ymax
 sta face_ymin
qw_bound_ymax:
 cmp face_ymax
 bcc qw_bound_done
 sta face_ymax
qw_bound_done:
.endif
 rts
