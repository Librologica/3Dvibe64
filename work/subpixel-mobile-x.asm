; Copyright 2026 librologica.digital. PolyForm Noncommercial 1.0.0.
; Original vertices only: one existing perspective division, then retain two
; remainder bits. Integer/raw screen X and the old clip projector stay intact.
; Q2 offset = floor(4*abs(axis)*focal/depth), sign applied after truncation.
; For large axes, inherits existing joint axis/depth normalization.
; No new zero page, multiplication, division, SMC or IRQ dependency.
probe_mobile_project_x:
 jsr explorer_project_axis_offset
 jsr probe_mobile_x_store
 jmp probe_mobile_x_legacy

probe_mobile_x_store:
 lda mul16reshi
 bne probe_mobile_x_saturated
 lda #0
 sta mul16rem
 jsr probe_mobile_fraction_bit
 jsr probe_mobile_fraction_bit
 lda mul16reslo
 sta prodlo
 lda #0
 sta prodhi
 asl prodlo
 rol prodhi
 asl prodlo
 rol prodhi
 lda prodlo
 ora mul16rem
 sta prodlo
 lda mul16sign
 bmi probe_mobile_x_left
 clc
 lda #<(PROJ_CENTER_X*4)
 adc prodlo
 sta prodlo
 lda #>(PROJ_CENTER_X*4)
 adc prodhi
 sta prodhi
 cmp #>(PROJ_SCREEN_MAX_X*4)
 bcc probe_mobile_x_save
 bne probe_mobile_x_max
 lda prodlo
 cmp #<(PROJ_SCREEN_MAX_X*4)
 bcc probe_mobile_x_save
 bcs probe_mobile_x_max
probe_mobile_x_left:
 sec
 lda #<(PROJ_CENTER_X*4)
 sbc prodlo
 sta prodlo
 lda #>(PROJ_CENTER_X*4)
 sbc prodhi
 sta prodhi
 bcs probe_mobile_x_save
probe_mobile_x_min:
 lda #0
 sta prodlo
 sta prodhi
 beq probe_mobile_x_save
probe_mobile_x_saturated:
 lda mul16sign
 bmi probe_mobile_x_min
probe_mobile_x_max:
 lda #<(PROJ_SCREEN_MAX_X*4)
 sta prodlo
 lda #>(PROJ_SCREEN_MAX_X*4)
 sta prodhi
probe_mobile_x_save:
 ldy tmpidx
 lda prodlo
 sta sxq2_lo,y
 lda prodhi
 sta sxq2_hi,y
 rts

; Long division continuation with a 17-bit doubled remainder. The quotient,
; scalev, sign and divisor are preserved for the legacy integer/raw X stores.
probe_mobile_fraction_bit:
 asl mul16rem
 asl crosslo
 rol crosshi
 bcs probe_mobile_fraction_sub
 lda crosshi
 cmp p1hi
 bcc probe_mobile_fraction_done
 bne probe_mobile_fraction_sub
 lda crosslo
 cmp p1lo
 bcc probe_mobile_fraction_done
probe_mobile_fraction_sub:
 sec
 lda crosslo
 sbc p1lo
 sta crosslo
 lda crosshi
 sbc p1hi
 sta crosshi
 inc mul16rem
probe_mobile_fraction_done:
 rts
probe_mobile_code_end:
