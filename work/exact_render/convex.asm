; Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
er_convex_shape:
 lda #0
 sta er_convex_corner
 sta er_convex_orientation
er_convex_corner_loop:
 lda er_convex_corner
 tax
 lda er_shape_x,x
 sta er_convex_x0
 lda er_shape_ylo,x
 sta er_convex_y0
 lda er_shape_yhi,x
 sta er_convex_y0+1
 lda er_convex_corner
 clc
 adc #1
 cmp er_shape_count
 bcc +
 sbc er_shape_count
+
 tax
 jsr er_convex_delta
 lda er_convex_dx
 sta er_convex_ax
 lda er_convex_dy
 sta er_convex_ay
 lda er_convex_dy+1
 sta er_convex_ay+1
 lda er_convex_sign
 sta er_convex_asign
 lda #0
 sta er_convex_probe
er_convex_probe_loop:
 lda er_convex_probe
 cmp er_convex_corner
 beq er_convex_next_probe
 lda er_convex_corner
 clc
 adc #1
 cmp er_shape_count
 bcc +
 sbc er_shape_count
+
 cmp er_convex_probe
 beq er_convex_next_probe
 ldx er_convex_probe
 jsr er_convex_delta
 ; dx1*dy2 - dx2*dy1, each signed product held in24 bits.
 lda er_convex_sign
 and #$80
 sta er_convex_product_sign
 lda er_convex_asign
 and #1
 beq +
 lda er_convex_product_sign
 eor #$80
 sta er_convex_product_sign
+
 lda er_convex_ax
 jsr er_convex_multiply
 lda er_convex_product
 sta er_convex_cross
 lda er_convex_product+1
 sta er_convex_cross+1
 lda er_convex_product+2
 sta er_convex_cross+2
 lda er_convex_dx
 sta er_convex_bx
 lda er_convex_dy
 sta er_convex_by
 lda er_convex_dy+1
 sta er_convex_by+1
 lda er_convex_sign
 and #1
 beq +
 lda #$80
+
 sta er_convex_product_sign
 lda er_convex_asign
 and #$80
 eor er_convex_product_sign
 sta er_convex_product_sign
 lda er_convex_ay
 sta er_convex_dy
 lda er_convex_ay+1
 sta er_convex_dy+1
 lda er_convex_bx
 jsr er_convex_multiply
 sec
 lda er_convex_cross
 sbc er_convex_product
 sta er_convex_cross
 lda er_convex_cross+1
 sbc er_convex_product+1
 sta er_convex_cross+1
 lda er_convex_cross+2
 sbc er_convex_product+2
 sta er_convex_cross+2
 ora er_convex_cross
 ora er_convex_cross+1
 beq er_convex_no
 lda er_convex_cross+2
 and #$80
 ora #1
 ldx er_convex_orientation
 beq er_convex_first_sign
 cmp er_convex_orientation
 bne er_convex_no
er_convex_first_sign:
 sta er_convex_orientation
er_convex_next_probe:
 inc er_convex_probe
 lda er_convex_probe
 cmp er_shape_count
 bne er_convex_probe_loop
 inc er_convex_corner
 lda er_convex_corner
 cmp er_shape_count
 bne er_convex_corner_loop
 sec
 rts
er_convex_no:
 clc
 rts
er_convex_delta:
 lda #0
 sta er_convex_sign
 sec
 lda er_shape_x,x
 sbc er_convex_x0
 bcs +
 eor #$ff
 clc
 adc #1
 inc er_convex_sign
+
 sta er_convex_dx
 sec
 lda er_shape_ylo,x
 sbc er_convex_y0
 sta er_convex_dy
 lda er_shape_yhi,x
 sbc er_convex_y0+1
 sta er_convex_dy+1
 bpl er_convex_delta_done
 lda er_convex_sign
 ora #$80
 sta er_convex_sign
 sec
 lda #0
 sbc er_convex_dy
 sta er_convex_dy
 lda #0
 sbc er_convex_dy+1
 sta er_convex_dy+1
er_convex_delta_done:
 rts

; A unsigned8 X magnitude times unsigned9 Y magnitude, sign separate.
er_convex_multiply:
 sta er_convex_factor
 ldx er_convex_dy
 jsr er_mul_u8
 lda prodlo
 sta er_convex_product
 lda prodhi
 sta er_convex_product+1
 lda er_convex_dy+1
 beq +
 clc
 lda er_convex_product+1
 adc er_convex_factor
 sta er_convex_product+1
+
 lda #0
 sta er_convex_product+2
 bit er_convex_product_sign
 bpl er_convex_multiply_done
 sec
 lda #0
 sbc er_convex_product
 sta er_convex_product
 lda #0
 sbc er_convex_product+1
 sta er_convex_product+1
 lda #0
 sbc #0
 sta er_convex_product+2
er_convex_multiply_done:
 rts

er_convex_corner: .byte 0
er_convex_orientation: .byte 0
er_convex_x0: .byte 0
er_convex_y0: .word 0
er_convex_dx: .byte 0
er_convex_dy: .word 0
er_convex_sign: .byte 0
er_convex_ax: .byte 0
er_convex_ay: .word 0
er_convex_asign: .byte 0
er_convex_bx: .byte 0
er_convex_by: .word 0
er_convex_factor: .byte 0
er_convex_product_sign: .byte 0
er_convex_product: .fill 3,0
er_convex_cross: .fill 3,0
er_convex_probe: .byte 0
