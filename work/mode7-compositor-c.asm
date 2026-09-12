; M3.1 C: local texel is neutral at Q=10..22.
; Q<=6: (1,1,2), Q>=26: (2,3,3). Three intermediate Q per transition.
; Existing scratch; no LUT or extra RAM. Incoming A is texel 1..3.
m3_composite:
 sta m3_base
 ldx m3_qcur
 cpx #10
 bcc m31_c_low
 cpx #23
 bcc m31_c_return
 cmp #3
 beq m31_c_return
 cpx #26
 bcs m31_c_bright
 txa
 sec
 sbc #22
 jmp m31_c_transition
m31_c_low:
 cmp #1
 beq m31_c_return
 dec m3_base
 cpx #7
 bcc m31_c_stable
 txa
 sec
 sbc #6
m31_c_transition:
 asl
 asl
 sta m3_threshold
 lda gouraud_scan_x
 and #3
 ora m2_bayer_row
 tay
 lda m3_threshold
 cmp m2_bayer,y
 lda m3_base
 adc #0
m31_c_return:
 rts
m31_c_bright:
 inc m3_base
m31_c_stable:
 lda m3_base
 rts
m31_c_instructions_end = *
