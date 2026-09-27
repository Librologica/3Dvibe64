; Copyright 2026 librologica.digital. PolyForm Noncommercial 1.0.0.
; Fixed-camera first gate. X stores unsigned Q2 logical-screen coordinates.
; For scale<128: offset=sign(x)*floor((abs(x)*scale+8)/16).
; Retains existing coarse high-scale projection instead of silently changing
; its near-distance contract. No division, new zero page or SMC.
probe_xq2_store:
 ldx tmpidx
 lda rxbuf,x
 ldx scalev
 cpx #$80
 bcs probe_xq2_coarse
 jsr probe_xq2_product
 jmp probe_xq2_save
probe_xq2_coarse:
 ; Existing saturating high-scale path already produced sx.
 ldy tmpidx
 lda sx,y
 sta p1lo
 lda #0
 sta p1hi
 asl p1lo
 rol p1hi
 asl p1lo
 rol p1hi
probe_xq2_save:
 ldy tmpidx
 lda p1lo
 sta sxq2_lo,y
 lda p1hi
 sta sxq2_hi,y
 rts

probe_xq2_product:
 sta mula
 stx mulb
 lda #0
 sta mulsign
 lda mula
 bpl probe_xq2_abs
 eor #$ff
 clc
 adc #1
 sta mula
 lda #$80
 sta mulsign
probe_xq2_abs:
 lda mula
 clc
 adc mulb
 tax
 lda sqlo,x
 sta prodlo
 lda sqhi,x
 sta prodhi
 lda mula
 sec
 sbc mulb
 bcs probe_xq2_diff
 eor #$ff
 clc
 adc #1
probe_xq2_diff:
 tax
 sec
 lda prodlo
 sbc sqlo,x
 sta prodlo
 lda prodhi
 sbc sqhi,x
 sta prodhi
 clc
 lda prodlo
 adc #8
 sta prodlo
 lda prodhi
 adc #0
 sta prodhi
 lsr prodhi
 ror prodlo
 lsr prodhi
 ror prodlo
 lsr prodhi
 ror prodlo
 lsr prodhi
 ror prodlo
 lda mulsign
 bmi probe_xq2_negative
 clc
 lda #<(PROJ_CENTER_X*4)
 adc prodlo
 sta p1lo
 lda #>(PROJ_CENTER_X*4)
 adc prodhi
 sta p1hi
 cmp #>(PROJ_SCREEN_MAX_X*4)
 bcc probe_xq2_done
 bne probe_xq2_max
 lda p1lo
 cmp #<(PROJ_SCREEN_MAX_X*4)
 bcc probe_xq2_done
probe_xq2_max:
 lda #<(PROJ_SCREEN_MAX_X*4)
 sta p1lo
 lda #>(PROJ_SCREEN_MAX_X*4)
 sta p1hi
 rts
probe_xq2_negative:
 sec
 lda #<(PROJ_CENTER_X*4)
 sbc prodlo
 sta p1lo
 lda #>(PROJ_CENTER_X*4)
 sbc prodhi
 sta p1hi
 bcs probe_xq2_done
 lda #0
 sta p1lo
 sta p1hi
probe_xq2_done:
 rts

; Checked use of the old fast divisor, whose documented domain is |N|<=2032.
; The fallback is the existing full signed Euclidean division, never a clamp.
probe_div_checked:
 lda xyq2_nhi
 bmi probe_div_negative
 cmp #7
 bcc probe_div_fast
 bne probe_div_full
 lda xyq2_nlo
 cmp #$f1
 bcc probe_div_fast
 bcs probe_div_full
probe_div_negative:
 cmp #$f8
 bcc probe_div_full
 bne probe_div_fast
 lda xyq2_nlo
 cmp #$10
 bcc probe_div_full
probe_div_fast:
 jmp xyq2_div_signed_euclid_11x8
probe_div_full:
 jmp xyq2_div_signed_euclid
probe_xq2_code_end:
