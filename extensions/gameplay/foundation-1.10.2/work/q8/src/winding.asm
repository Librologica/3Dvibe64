; Exact signed 24-bit shoelace sum on viewport-clipped Q2 coordinates.
; x in 0..636, y in 0..396, at most 12 vertices: sum cannot overflow s24.
; C=1 only for positive screen winding. Degenerate zero-area faces are empty.
; Scratch hc_num/hc_shift/hc_value is private, not used by SID IRQ.
hc_winding_visible:
 lda #0
 sta cw_area
 sta cw_area+1
 sta cw_area+2
 sta cw_cur
 ldx hc_count
 dex
 stx cw_prev
cw_loop:
 ldx cw_prev
 ldy cw_cur
 jsr cw_load_product
 jsr cw_multiply
 clc
 lda cw_area
 adc hc_num
 sta cw_area
 lda cw_area+1
 adc hc_num+1
 sta cw_area+1
 lda cw_area+2
 adc hc_num+2
 sta cw_area+2
 ldx cw_cur
 ldy cw_prev
 jsr cw_load_product
 jsr cw_multiply
 sec
 lda cw_area
 sbc hc_num
 sta cw_area
 lda cw_area+1
 sbc hc_num+1
 sta cw_area+1
 lda cw_area+2
 sbc hc_num+2
 sta cw_area+2
 lda cw_cur
 sta cw_prev
 inc cw_cur
 lda cw_cur
 cmp hc_count
 bne cw_loop
 lda cw_area+2
 bmi cw_hidden
 ora cw_area+1
 ora cw_area
 cmp #1
 rts
cw_hidden:
 clc
 rts
cw_load_product:
 lda hc_a_xlo,x
 sta hc_shift
 lda hc_a_xhi,x
 sta hc_shift+1
 lda #0
 sta hc_shift+2
 sta hc_num
 sta hc_num+1
 sta hc_num+2
 lda hc_a_ylo,y
 sta hc_value
 lda hc_a_yhi,y
 sta hc_value+1
 rts
cw_multiply:
 lsr hc_value+1
 ror hc_value
 bcc cw_shift
 clc
 lda hc_num
 adc hc_shift
 sta hc_num
 lda hc_num+1
 adc hc_shift+1
 sta hc_num+1
 lda hc_num+2
 adc hc_shift+2
 sta hc_num+2
cw_shift:
 asl hc_shift
 rol hc_shift+1
 rol hc_shift+2
 lda hc_value
 ora hc_value+1
 bne cw_multiply
 rts
