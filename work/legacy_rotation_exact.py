"""Exact post-emission camera products for ordinary legacy-plus solid modes.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
Keep the original Q10 rounding and original private32-bit product. The bounded
placer chooses an exact optimized layout only if it fits its existing windows.
"""
import re


PRODUCT = """
 ; Exact unsigned16 x unsigned11 product. The low coefficient byte uses
 ; an eight-step right-rotating24-bit accumulator, with its high byte in A.
 ; Its remaining0..4 high byte is accumulated at bit8, in three exact steps.
 ; Preserve Y; reuse only existing private multiplication scratch.
 sty lr_value+3
 lda #0
 sta lr_product
 sta lr_product+1
 sta lr_product+3
 ldx #8
lr_split_low_loop:
 lsr lr_multiplier
 bcc lr_split_low_skip
 tay
 clc
 lda lr_product+1
 adc lr_value
 sta lr_product+1
 tya
 adc lr_value+1
lr_split_low_skip:
 ror
 ror lr_product+1
 ror lr_product
 dex
 bne lr_split_low_loop
 sta lr_product+2
 lda lr_multiplier+1
 beq lr_split_done
 ldx #3
lr_split_high_loop:
 lsr lr_multiplier+1
 bcc lr_split_high_skip
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
lr_split_high_skip:
 asl lr_value
 rol lr_value+1
 rol lr_value+2
 dex
 bne lr_split_high_loop
lr_split_done:
 ldy lr_value+3
 ldx #0
"""

SHORTCUT = """lr_mul_s16_q10:
 lda p1lo
 ora p1hi
 beq lr_split_identity_return
 lda lr_coeff_lo,x
 bne lr_split_general
 lda lr_coeff_hi,x
 beq lr_split_zero_return
 cmp #4
 beq lr_split_identity_return
 cmp #$fc
 bne lr_split_general
 sec
 lda #0
 sbc p1lo
 sta p1lo
 lda #0
 sbc p1hi
 sta p1hi
lr_split_identity_return:
 ldx #0
 rts
lr_split_zero_return:
 sta p1lo
 sta p1hi
 ldx #0
 rts
lr_split_general:
"""


LEGACY_SERIAL = ' lda #0\n sta lr_product\n sta lr_product+1\n sta lr_product+2\n sta lr_product+3\n ldx #11\nlr_mul_loop:\n lsr lr_multiplier+1\n ror lr_multiplier\n bcc lr_mul_no_add\n clc\n lda lr_product\n adc lr_value\n sta lr_product\n lda lr_product+1\n adc lr_value+1\n sta lr_product+1\n lda lr_product+2\n adc lr_value+2\n sta lr_product+2\n lda lr_product+3\n adc lr_value+3\n sta lr_product+3\nlr_mul_no_add:\n asl lr_value\n rol lr_value+1\n rol lr_value+2\n rol lr_value+3\n dex\n bne lr_mul_loop\n'

def original_source(source):
    # Public integrations may allocate again after adding caller-owned blocks.
    # Normalize our own previous emission before considering the new free RAM.
    # This keeps placement idempotent and retains the real original fallback.
    if 'lr_split_low_loop:\n' not in source:
        return source
    pattern=re.compile(r'\n; Plus allocation block rotation_product\n(?:\* = \$[0-9a-f]+|\.virtual \$4000)\nlpa_block_rotation_product_begin:\n(.*?)lpa_block_rotation_product_end:\n(?:\.cerror[^\n]+\n|\.endvirtual\n)',re.S)
    matches=list(pattern.finditer(source))
    if matches:
        if len(matches)!=1 or source.count(' jsr lr_split_product\n')!=1:
            raise ValueError('EXACT_ROTATION_REENTRANT_BLOCK')
        source=pattern.sub('',source)
        source=source.replace(' jsr lr_split_product\n',LEGACY_SERIAL,1)
    else:
        if source.count(PRODUCT)!=1:
            raise ValueError('EXACT_ROTATION_REENTRANT_INLINE')
        source=source.replace(PRODUCT,LEGACY_SERIAL,1)
    if SHORTCUT in source:
        source=source.replace(SHORTCUT,'lr_mul_s16_q10:\n',1)
    if 'lr_split_low_loop:\n' in source or 'lr_split_product:\n' in source:
        raise ValueError('EXACT_ROTATION_REENTRANT_RESTORE')
    return source

def strategies(source):
    source=original_source(source)
    if not re.search(r'(?m)^GRAPHICS_MODE = \$0[3-7]$', source):
        return [('original-not-applicable', source)]
    marker = 'lr_mul_coefficient_positive:\n.if LR_PRODUCT_LUT_ACTIVE != 0\n jsr lr_lookup_product\n.else\n'
    if source.count(marker) != 1:
        return [('original-not-applicable', source)]
    begin = source.index(marker) + len(marker)
    end = source.index('.endif\n clc\n lda lr_product+1\n adc #2\n', begin)
    old = source[begin:end]
    if 'lr_mul_loop:\n' not in old or ' ldx #11\n' not in old:
        raise ValueError('EXACT_ROTATION_SERIAL_CONTRACT')
    inline = source[:begin] + PRODUCT + source[end:]
    if inline.count('lr_mul_s16_q10:\n') != 1:
        raise ValueError('EXACT_ROTATION_ENTRY_CONTRACT')
    shortcut = inline.replace('lr_mul_s16_q10:\n', SHORTCUT, 1)
    relocated = shortcut.replace(PRODUCT, ' jsr lr_split_product\n', 1)
    relocated += ('\n; Plus allocation block rotation_product\n.virtual $4000\n'
                  'lpa_block_rotation_product_begin:\nlr_split_product:\n'
                  + PRODUCT + ' rts\nlpa_block_rotation_product_end:\n.endvirtual\n')
    # Selection depends exclusively on the unchanged bounded RAM contract.
    # The original source is the final fallback; no case or scene IDs are read.
    return [('split-shortcuts-relocated', relocated),
            ('split-inline', inline), ('original-memory-fallback', source)]
