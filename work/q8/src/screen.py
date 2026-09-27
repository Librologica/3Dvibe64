"""Generated exact wide screen arithmetic, no changes to span/fill kernels."""

def arithmetic():
    # 24-bit screen deltas after legacy remote clamp: <2^22. The ratio numerator
    # is nonnegative and <= denominator <2^22. Products therefore fit 48 bits.
    s='''; Q2 + signed residual [-63,63] -> exact signed Q16.8 screen value.
hq_expand_q:
 lda hc_q
 sta hq_projected
 lda hc_q+1
 sta hq_projected+1
 asl
 lda #0
 sbc #0
 eor #$ff
 sta hq_projected+2
 ldx #6
hq_expand_shift:
 asl hq_projected
 rol hq_projected+1
 rol hq_projected+2
 dex
 bne hq_expand_shift
 ldy #0
 lda hq_residue
 bpl hq_residue_positive
 dey
hq_residue_positive:
 clc
 adc hq_projected
 sta hq_projected
 tya
 adc hq_projected+1
 sta hq_projected+1
 tya
 adc hq_projected+2
 sta hq_projected+2
 rts

; Signed24 delta * unsigned24 factor / unsigned24 denominator, exact trunc0.
; hc_value is a private destructive multiplier; no caller needs its old value.
hq_ratio_product:
 lda hc_delta+2
 sta hc_sign
 bpl hq_delta_positive
 sec
'''
    for i in range(3):s+=f' lda #0\n sbc hc_delta+{i}\n sta hc_delta+{i}\n'
    s+='hq_delta_positive:\n'
    for i in range(3):s+=f' lda hc_delta+{i}\n sta hc_shift+{i}\n lda hc_factor+{i}\n sta hc_value+{i}\n lda hc_den+{i}\n sta hc_divisor+{i}\n'
    s+=' lda #0\n'
    for i in range(6):s+=f' sta hc_num+{i}\n'
    for i in range(3,6):s+=f' sta hc_shift+{i}\n'
    s+='''hq_mul_loop:
 lda hc_value
 ora hc_value+1
 ora hc_value+2
 beq hq_mul_done
 lsr hc_value+2
 ror hc_value+1
 ror hc_value
 bcc hq_mul_shift
 clc
'''
    for i in range(6):s+=f' lda hc_num+{i}\n adc hc_shift+{i}\n sta hc_num+{i}\n'
    s+='hq_mul_shift:\n asl hc_shift\n'
    for i in range(1,6):s+=f' rol hc_shift+{i}\n'
    s+=' jmp hq_mul_loop\nhq_mul_done:\n jsr hc_div40\n'
    for i in range(3):s+=f' lda hc_num+{i}\n sta hc_result+{i}\n'
    s+=' lda hc_sign\n bpl hq_ratio_done\n sec\n'
    for i in range(3):s+=f' lda #0\n sbc hc_result+{i}\n sta hc_result+{i}\n'
    s+='hq_ratio_done:\n rts\n'
    # After all four planes XY is bounded and fits UNSIGNED16 (159*256,99*256).
    # Truncate offset relative to the center, matching approved original vertices.
    s+='hq_quantize_poly:\n ldx #0\nhq_quantize_loop:\n'
    for a in 'xy':
        s+=f''' lda hc_a_{a}hi,x
 cmp #PROJ_CENTER_{a.upper()}
 bcs hq_quantize_{a}_shift
 clc
 lda hc_a_{a}lo,x
 adc #63
 sta hc_a_{a}lo,x
 lda hc_a_{a}hi,x
 adc #0
 sta hc_a_{a}hi,x
hq_quantize_{a}_shift:
'''
        for _ in range(6):s+=f' lsr hc_a_{a}hi,x\n ror hc_a_{a}lo,x\n'
    s+=' inx\n cpx hc_count\n bne hq_quantize_loop\n rts\n'
    return s
