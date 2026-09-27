; Signed24 Q8 coordinate * signed16 Q8 trig, abs(trig)<=256.
; Round magnitude to nearest, ties away from zero. Result signed24 Q8.
; No IRQ-owned scratch, no SMC, documented 6502 instructions only.
qc_product:
 lda qc_a+2
 eor qc_b+1
 and #$80
 sta qc_sign
 lda qc_a+2
 bpl qc_product_a_positive
 sec
 lda #0
 sbc qc_a
 sta qc_a
 lda #0
 sbc qc_a+1
 sta qc_a+1
 lda #0
 sbc qc_a+2
 sta qc_a+2
qc_product_a_positive:
 lda qc_b+1
 bpl qc_product_b_positive
 sec
 lda #0
 sbc qc_b
 sta qc_b
 lda #0
 sbc qc_b+1
 sta qc_b+1
qc_product_b_positive:
 ldx #2
qc_product_copy:
 lda qc_a,x
 sta qc_m,x
 dex
 bpl qc_product_copy
 lda #0
 sta qc_m+3
 ldx #3
qc_product_clear:
 sta qc_prod,x
 dex
 bpl qc_product_clear
 ldx #9
qc_product_loop:
 lsr qc_b+1
 ror qc_b
 bcc qc_product_shift
 clc
 lda qc_prod
 adc qc_m
 sta qc_prod
 lda qc_prod+1
 adc qc_m+1
 sta qc_prod+1
 lda qc_prod+2
 adc qc_m+2
 sta qc_prod+2
 lda qc_prod+3
 adc qc_m+3
 sta qc_prod+3
qc_product_shift:
 asl qc_m
 rol qc_m+1
 rol qc_m+2
 rol qc_m+3
 dex
 bne qc_product_loop
 lda qc_prod
 cmp #128
 lda qc_prod+1
 adc #0
 sta qc_r
 lda qc_prod+2
 adc #0
 sta qc_r+1
 lda qc_prod+3
 adc #0
 sta qc_r+2
 lda qc_sign
 beq qc_product_done
 sec
 lda #0
 sbc qc_r
 sta qc_r
 lda #0
 sbc qc_r+1
 sta qc_r+1
 lda #0
 sbc qc_r+2
 sta qc_r+2
qc_product_done:
 rts
