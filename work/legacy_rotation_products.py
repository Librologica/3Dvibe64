"""Exact per-coefficient camera products in the existing legacy runtime pool.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""

def once(source,old,new):
    if source.count(old)!=1:raise ValueError('Rotation product hook not unique: '+repr(old[:90]))
    return source.replace(old,new,1)

def apply(source):
    source=once(source,' sta lr_coeff_hi+2\n rts\n\nlr_negate_phase:', ''' sta lr_coeff_hi+2
.if LR_PRODUCT_LUT_ACTIVE != 0
 jsr lr_build_product_luts
.endif
 rts

lr_negate_phase:''')
    begin=source.index('lr_mul_coefficient_positive:\n');end=source.index(' clc\n lda lr_product+1\n adc #2\n',begin)
    old=source[begin:end];serial=old.removeprefix('lr_mul_coefficient_positive:\n')
    source=source[:begin]+'''lr_mul_coefficient_positive:
.if LR_PRODUCT_LUT_ACTIVE != 0
 jsr lr_lookup_product
.else
'''+serial+'.endif\n'+source[end:]
    helper='''
; Runtime-only allocation after every existing vertex/face/color buffer.
LR_PRODUCT_LUT_BASE = (RUNTIME_BUFFER_COLOR_POLICY_END + $ff) & $ff00
LR_PRODUCT_LUT_END = LR_PRODUCT_LUT_BASE + $c00
.if LR_PRODUCT_LUT_END <= RUNTIME_BUFFER_LIMIT
LR_PRODUCT_LUT_ACTIVE = 1
.else
LR_PRODUCT_LUT_ACTIVE = 0
.endif
.if LR_PRODUCT_LUT_ACTIVE != 0
LR_RUNTIME_BUFFER_END = LR_PRODUCT_LUT_END
.cerror LR_PRODUCT_LUT_BASE < RUNTIME_BUFFER_COLOR_POLICY_END,"Rotation LUT overlaps existing runtime buffers"
.cerror LR_RUNTIME_BUFFER_END > RUNTIME_BUFFER_LIMIT,"Rotation LUT exceeds runtime memory contract"

lr_build_product_luts:
 ldx #0
lr_build_lut_next:
 jsr lr_build_product_lut_index
 inx
 cpx #4
 bne lr_build_lut_next
 rts

; X=coefficient index. Store all 256 unsigned index*abs(coefficient) products
; as three byte planes. Same table serves the coordinate's low and high byte.
lr_build_product_lut_index:
 stx lr_lut_index
 lda lr_coeff_lo,x
 sta lr_multiplier
 lda lr_coeff_hi,x
 sta lr_multiplier+1
 bpl lr_lut_abs_ready
 sec
 lda #0
 sbc lr_multiplier
 sta lr_multiplier
 lda #0
 sbc lr_multiplier+1
 sta lr_multiplier+1
lr_lut_abs_ready:
 lda lr_lut_valid,x
 beq lr_lut_rebuild
 lda lr_lut_last_lo,x
 cmp lr_multiplier
 bne lr_lut_rebuild
 lda lr_lut_last_hi,x
 cmp lr_multiplier+1
 beq lr_lut_done
lr_lut_rebuild:
 lda lr_multiplier
 sta lr_lut_last_lo,x
 lda lr_multiplier+1
 sta lr_lut_last_hi,x
 lda #0
 sta ptr0lo
 sta lr_product
 sta lr_product+1
 sta lr_product+2
 lda lr_lut_page_hi,x
 sta ptr0hi
 ldy #0
lr_lut_fill:
 lda lr_product
 sta (ptr0lo),y
 inc ptr0hi
 lda lr_product+1
 sta (ptr0lo),y
 inc ptr0hi
 lda lr_product+2
 sta (ptr0lo),y
 dec ptr0hi
 dec ptr0hi
 clc
 lda lr_product
 adc lr_multiplier
 sta lr_product
 lda lr_product+1
 adc lr_multiplier+1
 sta lr_product+1
 lda lr_product+2
 adc #0
 sta lr_product+2
 iny
 bne lr_lut_fill
 ldx lr_lut_index
 lda #1
 sta lr_lut_valid,x
lr_lut_done:
 rts

lr_lookup_product:
 sty lr_lut_saved_y
 lda ptr0lo
 sta lr_lut_saved_ptr
 lda ptr0hi
 sta lr_lut_saved_ptr+1
 ldx lr_mul_index
 lda lr_lut_page_hi,x
 sta ptr0hi
 lda #0
 sta ptr0lo
 ldy lr_value
 lda (ptr0lo),y
 sta lr_product
 inc ptr0hi
 lda (ptr0lo),y
 sta lr_product+1
 inc ptr0hi
 lda (ptr0lo),y
 sta lr_product+2
 dec ptr0hi
 dec ptr0hi
 ldy lr_value+1
 lda (ptr0lo),y
 clc
 adc lr_product+1
 sta lr_product+1
 inc ptr0hi
 lda (ptr0lo),y
 adc lr_product+2
 sta lr_product+2
 inc ptr0hi
 lda (ptr0lo),y
 adc #0
 sta lr_product+3
 lda lr_lut_saved_ptr
 sta ptr0lo
 lda lr_lut_saved_ptr+1
 sta ptr0hi
 ldy lr_lut_saved_y
 ldx #0
 rts

lr_lut_page_hi:
 .byte >LR_PRODUCT_LUT_BASE,>(LR_PRODUCT_LUT_BASE+$300),>(LR_PRODUCT_LUT_BASE+$600),>(LR_PRODUCT_LUT_BASE+$900)
lr_lut_last_lo: .fill 4,0
lr_lut_last_hi: .fill 4,0
lr_lut_valid: .fill 4,0
lr_lut_index: .byte 0
lr_lut_saved_y: .byte 0
lr_lut_saved_ptr: .word 0
.else
LR_RUNTIME_BUFFER_END = RUNTIME_BUFFER_COLOR_POLICY_END
.endif
lr_products_helpers_end:
.cerror * > $d000,"Rotation product helpers overlap IO"
; LEGACY_ROTATION_PRODUCTS=exact-runtime-lut-with-serial-fallback
'''
    return source+helper
