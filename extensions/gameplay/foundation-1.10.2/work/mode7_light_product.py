"""Saturate light-only Q6 products before a byte loses its mathematical sign."""

def code(prefix):
    return f'''
; Saturated signed-byte result for A=-128..127, X=-64..64 (Q6 matrix).
; mulsign retains the mathematical sign, including a result truncated to zero.
{prefix}_light_mul_s6:
 jsr mul_s6
 bit mulsign
 bmi {prefix}_light_mul_negative
 cmp #$80
 bcc {prefix}_light_mul_done
 lda #$7f
 rts
{prefix}_light_mul_negative:
 cmp #$80
 bcs {prefix}_light_mul_done
 cmp #0
 beq {prefix}_light_mul_done
 lda #$80
{prefix}_light_mul_done:
 rts
{prefix}_light_mul_s6_end = *
'''
