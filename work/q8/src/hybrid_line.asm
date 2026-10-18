; Hybrid integer raster: round bounded clipped Q2 endpoints only here.
; Canonical major axis; one connected integer sample per major position.
; Error in [0,D-1], unsigned8 storage; addition uses carry for9th bit.
; D<=159. No multiply or divide. Same walker for visible edges and masks.
; Renderer-owned state; IRQ does not access qw_ fields. No SMC.
qw_line:
 lda qw_x0
 ldx qw_x0+1
 jsr qw_round
 sta qw_a
 lda qw_x1
 ldx qw_x1+1
 jsr qw_round
 sta qw_b
 lda qw_y0
 ldx qw_y0+1
 jsr qw_round
 sta qw_c
 lda qw_y1
 ldx qw_y1+1
 jsr qw_round
 sta qw_d
 sec
 lda qw_b
 sbc qw_a
 bcs hw_dx_ready
 eor #255
 clc
 adc #1
hw_dx_ready:
 sta qw_dx
 sec
 lda qw_d
 sbc qw_c
 bcs hw_dy_ready
 eor #255
 clc
 adc #1
hw_dy_ready:
 sta qw_dy
 lda #0
 sta qw_major
 lda qw_dx
 cmp qw_dy
 bcs hw_x_major
 inc qw_major
 lda qw_a
 ldx qw_c
 sta qw_c
 stx qw_a
 lda qw_b
 ldx qw_d
 sta qw_d
 stx qw_b
 lda qw_dy
 sta qw_den
 lda qw_dx
 sta qw_step
 jmp hw_order
hw_x_major:
 lda qw_dx
 sta qw_den
 lda qw_dy
 sta qw_step
hw_order:
 lda qw_b
 cmp qw_a
 bcs hw_ordered
 lda qw_a
 ldx qw_b
 sta qw_b
 stx qw_a
 lda qw_c
 ldx qw_d
 sta qw_d
 stx qw_c
hw_ordered:
 lda qw_a
 sta qw_pos
 lda qw_b
 sta qw_last
 lda qw_c
 sta qw_minor
 lda #0
 sta qw_sign
 lda qw_d
 cmp qw_c
 bcs hw_sign_ready
 dec qw_sign
hw_sign_ready:
 lda qw_den
 lsr
 sta qw_rem
hw_line_loop:
 jsr qw_emit
 lda qw_pos
 cmp qw_last
 beq hw_line_done
 inc qw_pos
 clc
 lda qw_rem
 adc qw_step
 sta qw_rem
 bcs hw_correct
 cmp qw_den
 bcc hw_line_loop
hw_correct:
 sec
 lda qw_rem
 sbc qw_den
 sta qw_rem
 lda qw_sign
 bmi hw_minor_down
 inc qw_minor
 jmp hw_line_loop
hw_minor_down:
 dec qw_minor
 jmp hw_line_loop
hw_line_done:
 rts

