; M3.1 B: preserve M3 E, compress each Bayer ramp into E remainder 6..10.
; Stable outputs bypass Bayer. Existing three scratch bytes only.
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
 bcc m31_b_level
 sec
 sbc #16
 inx
m31_b_level:
 cmp #6
 bcc m31_b_stable
 cmp #11
 bcs m31_b_upper
 stx m3_base
 tay
 lda m31_b_transition-6,y
 sta m3_threshold
 lda gouraud_scan_x
 and #3
 ora m2_bayer_row
 tay
 lda m3_threshold
 cmp m2_bayer,y
 lda m3_base
 adc #0
 rts
m31_b_upper:
 inx
m31_b_stable:
 txa
 rts
m31_b_instructions_end = *
m31_b_transition:
 .byte 3,5,8,11,13
