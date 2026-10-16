"""Exact span-level neutral shading specialization for documented 6510.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. Private demo, not an engine modification.
"""
def hooks(text,once):
    return once(text,'m3_prepare_span:\n sec\n lda rightval\n','m3_prepare_span:\n jmp sg_prepare\n')

def helper():
    s='''*=$fa00
sg_begin:
; IRQ/music neither calls nor modifies these renderer entries.
; Patch between scanlines, never while executing a patched entry.
sg_prepare:
 ldy yrow
 lda m3_leftq,y
 cmp #10
 bcc sg_dynamic
 cmp #23
 bcs sg_dynamic
 lda m3_rightq,y
 cmp #10
 bcc sg_dynamic
 cmp #23
 bcs sg_dynamic
 lda #1
 cmp sg_mode
 beq sg_neutral_setup
 sta sg_mode
 lda #$60
 sta m3_composite
 sta m3_advance_q
 lda #$ea
 sta m3_composite+1
 sta m3_composite+2
 lda #$4c
'''
    for i in range(4):s+=f' sta fx{i}_m3_composite\n'
    for i in range(3):s+=f' sta fx{i}_m3_advance_q\n'
    for i in range(4):s+=f' lda #<fx{i}_composite_done\n sta fx{i}_m3_composite+1\n lda #>fx{i}_composite_done\n sta fx{i}_m3_composite+2\n'
    for i in range(3):s+=f' lda #<fx{i}_shade_done\n sta fx{i}_m3_advance_q+1\n lda #>fx{i}_shade_done\n sta fx{i}_m3_advance_q+2\n'
    s+='''sg_neutral_setup:
 ; Q accumulator is dead in this plateau, not a coarsened light estimate.
 lda m3_leftq,y
 sta m3_qcur
 lda #0
 sta m3_qstep
 sta m3_qrem
 sta m3_qerr
 sec
 lda rightval
 sbc leftval
 sta m7_den
 rts
sg_dynamic:
 lda #0
 cmp sg_mode
 beq sg_original_setup
 sta sg_mode
 lda #$8d
 sta m3_composite
'''
    for i in range(4):s+=f' sta fx{i}_m3_composite\n'
    s+=' lda #<m3_base\n sta m3_composite+1\n'
    for i in range(4):s+=f' sta fx{i}_m3_composite+1\n'
    s+=' lda #>m3_base\n sta m3_composite+2\n'
    for i in range(4):s+=f' sta fx{i}_m3_composite+2\n'
    s+=' lda #$18\n sta m3_advance_q\n'
    for i in range(3):s+=f' sta fx{i}_m3_advance_q\n'
    s+=' lda #$ad\n'
    for i in range(3):s+=f' sta fx{i}_m3_advance_q+1\n'
    s+=' lda #<m3_qcur\n'
    for i in range(3):s+=f' sta fx{i}_m3_advance_q+2\n'
    s+='''sg_original_setup:
 sec
 lda rightval
 jmp m3_prepare_span+3
sg_mode: .byte $ff
sg_end:
 .cerror * > $ff00,"Span shader exceeds safe high RAM"
 .cerror m3_base < $100,"Expected absolute original STA"
 .cerror m3_qcur < $100,"Expected absolute original LDA"
'''
    return s
