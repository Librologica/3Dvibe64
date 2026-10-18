"""Reuse exact local coordinate terms for consecutive identical matrices.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
from legacy_rotation import once

def apply(source):
    source=once(source,'render_frame_begin:\n jsr lr_prepare\n',
                'render_frame_begin:\n lda #0\n sta lr_terms_valid\n jsr lr_prepare\n')
    source=once(source,'build_coord_terms:\n','''build_coord_terms:
 ; Global coordinate dictionaries are immutable within a generated scene.
 ; Reuse only when all nine effective (already scaled) matrix bytes match.
 lda lr_terms_valid
 beq lr_terms_rebuild
 ldx #8
lr_terms_compare:
 lda m00,x
 cmp lr_terms_matrix,x
 bne lr_terms_rebuild
 dex
 bpl lr_terms_compare
 rts
lr_terms_rebuild:
 ldx #8
lr_terms_remember:
 lda m00,x
 sta lr_terms_matrix,x
 dex
 bpl lr_terms_remember
 lda #1
 sta lr_terms_valid
''')
    return source+'''
lr_terms_valid: .byte 0
lr_terms_matrix: .fill 9,0
.cerror * > $d000,"Local coordinate-term cache overlaps IO"
; LEGACY_ROTATION_TERMS=consecutive-identical-effective-matrix-per-view
'''
