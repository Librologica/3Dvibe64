"""Q8 geometry with additive integer line raster, Modes1/2/5 only.
Required Notice:3Dvibe64. PolyForm Noncommercial1.0.0.
Derived from the qualified three-rooms Mode2 hybrid; no scene assumptions.
"""
from pathlib import Path
def apply(source,parts,mode):
    if mode in (1,2):
        tail=parts['wire_line'][parts['wire_line'].index('qw_round:\n'):]
        parts['wire_line']=Path(__file__).with_name('hybrid_line.asm').read_text()+tail
    elif mode==5:
        # Fill coverage remains Q8/Q2. Only the drawn clipped perimeter changes.
        for name,size in [('x0',2),('y0',2),('x1',2),('y1',2),('dx',2),('dy',2),
            ('major',1),('sign',1),('a',2),('b',2),('c',2),('d',2),('den',2),('step',2),
            ('rem',2),('pos',1),('last',1),('minor',1),('mask',1),('poly_i',1)]:
            parts['data']+=f'qw_{name}: .fill {size},0\n'
        old=Path(__file__).with_name('wire_line.asm').read_text()
        tail=old[old.index('qw_round:\n'):].replace(' jmp plot_wire_point\n',' jmp mode5_plot_background_point\n')
        parts['wire_line']=Path(__file__).with_name('hybrid_line.asm').read_text()+tail
        start=source.index('mode5_draw_loaded_polygon_outline:\n')
        end=source.index('; Reuse the renderer\'s connected Bresenham kernel.',start)
        body='''mode5_draw_loaded_polygon_outline:
 lda xyq2_face_valid
 beq hy_outline_done
 lda #0
 sta qw_mask
 sta qw_poly_i
hy_outline_loop:
 ldx qw_poly_i
'''
        for axis in 'xy':
            for i,suf in enumerate(('lo','hi')):body+=f' lda hc_a_{axis}{suf},x\n sta qw_{axis}0+{i}\n'
        body+=' inx\n cpx hc_count\n bcc hy_next_ready\n ldx #0\nhy_next_ready:\n'
        for axis in 'xy':
            for i,suf in enumerate(('lo','hi')):body+=f' lda hc_a_{axis}{suf},x\n sta qw_{axis}1+{i}\n'
        body+=' jsr qw_line\n inc qw_poly_i\n lda qw_poly_i\n cmp hc_count\n bne hy_outline_loop\nhy_outline_done:\n rts\n\n'
        source=source[:start]+body+source[end:]
    else:raise ValueError('HYBRID_MODE: only1/2/5')
    assert 'jsr hp_mul' not in parts['wire_line'] and 'jsr hc_div40' not in parts['wire_line']
    return source,parts
