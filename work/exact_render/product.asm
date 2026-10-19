; Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
; Exact unsigned8x8 using existing floor(n*n/4), n=0..255.
; If a+b overflows, q(s+256)=q(s)+128*s+16384.
; A,X inputs; prodlo/hi output; preserveY and native pointer registers.
er_mul_u8:
 sta mula
 stx mulb
 clc
 adc mulb
 tax
 lda sqlo,x
 sta prodlo
 lda sqhi,x
 sta prodhi
 bcc er_sum_ready
 txa
 lsr
 sta mulsign
 lda #0
 ror
 clc
 adc prodlo
 sta prodlo
 lda prodhi
 adc mulsign
 adc #$40
 sta prodhi
er_sum_ready:
 sec
 lda mula
 sbc mulb
 bcs er_diff_ready
 eor #$ff
 clc
 adc #1
er_diff_ready:
 tax
 sec
 lda prodlo
 sbc sqlo,x
 sta prodlo
 lda prodhi
 sbc sqhi,x
 sta prodhi
 rts

; |signed16| times |Q10| -> exact unsigned32 in lr_product.
; Product by low coefficient byte is two exact8x8 partial products.
; Upper coefficient byte is at most4, requiring at most3 shifted adds.
er_product:
 lda #0
 sta lr_product
 sta lr_product+1
 sta lr_product+2
 sta lr_product+3
 lda lr_multiplier
 beq er_upper
 tax
 lda lr_value
 jsr er_mul_u8
 lda prodlo
 sta lr_product
 lda prodhi
 sta lr_product+1
 lda lr_value+1
 beq er_upper
 ldx lr_multiplier
 jsr er_mul_u8
 clc
 lda prodlo
 adc lr_product+1
 sta lr_product+1
 lda prodhi
 adc #0
 sta lr_product+2
er_upper:
 lda lr_multiplier+1
 beq er_product_done
er_upper_loop:
 lsr lr_multiplier+1
 bcc er_upper_skip
 clc
 lda lr_product+1
 adc lr_value
 sta lr_product+1
 lda lr_product+2
 adc lr_value+1
 sta lr_product+2
 lda lr_product+3
 adc lr_value+2
 sta lr_product+3
er_upper_skip:
 lda lr_multiplier+1
 beq er_product_done
 asl lr_value
 rol lr_value+1
 rol lr_value+2
 jmp er_upper_loop
er_product_done:
 rts
