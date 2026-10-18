"""Mode integration for the ordinary legacy-plus geometry pipeline.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import argparse
import re
from pathlib import Path


def patch(source):
    # Mode1 with polygon clipping already relocates from $4000 to $a000 at
    # the beginning of the clipper. The old final guard assumed that jump
    # never happened and checked the high code against the low $5c00 limit.
    # Keep the real overlap checks and the no-polygon relocation unchanged.
    old = '.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && HIDDEN_WIRE_ENABLE = 0 && LOWRES_TRACE_ENABLE = 0\n'
    assert source.count(old) == 1
    source = source.replace(old, old.rstrip('\n') + ' && EXPLORER_SCREEN_CLIP_POLY = 0\n', 1)
    if re.search(r'(?m)^GRAPHICS_MODE = \$01$', source):
        source = source.replace('row0lo_a:\n', '''.cerror * > $d000,"Mode1 base code overlaps IO"
* = $5000
row0lo_a:
''', 1)
        source = source.replace('lc_helpers_begin:\n', '''.cerror * > $5c00,"Mode1 raster tables overlap video buffer A"
.cerror LR_RUNTIME_BUFFER_END > $9500,"Mode1 rotation tables exceed helper budget"
.if LR_RUNTIME_BUFFER_END > $9000
* = LR_RUNTIME_BUFFER_END
.else
* = $9000
.endif
lc_helpers_begin:
''', 1)
        marker = '.if MEMORY_LAYOUT_HIGH_BASIC_V2 != 0 && POLY_FILL_ENABLE = 0 && WIRE_DEPTH_SORT_ENABLE = 0 && HIDDEN_WIRE_ENABLE = 0 && WIRE_RENDER_ENABLE != 0 && WIRE_MESH_COUNT != 0\n.if * > $5c00\n'
        assert source.count(marker) == 1
        source = source.replace(marker, marker.replace('$5c00', '$5000'), 1)
        a=source.index('dwm_loop:\n');b=source.index('dwm_next:\n',a)
        block=source[a:b]
        # Original pure wire traversal rejected the whole edge if either
        # endpoint was behind near. Keep its fast path for two valid ends.
        old=' lda projdone,x\n beq dwm_next\n'
        assert block.count(old)==2
        block=block.replace(old,' lda projdone,x\n',1)
        block=block.replace(old,' lda projdone,x\n beq lpm_draw_crossing\n ldx clip_prev_idx\n lda projdone,x\n beq lpm_draw_crossing\n',1)
        block+=''' jmp dwm_next
lpm_draw_crossing:
 jsr lpm_clip_edge
 beq dwm_next
 jsr draw_wire_edge_guarded
'''
        source=source[:a]+block+source[b:]
        source+='''
; Mode1 segment near crossing: native Q4 camera coordinates and the same
; near/screen stages as legacy-plus polygons. A line remains a line.
lpm_clip_edge:
 ldx clip_prev_idx
 lda projdone,x
 bne lpm_previous_inside
 ldy clip_cur_idx
 lda projdone,y
 beq lpm_no_edge
 stx p1lo
 sty p1hi
 jmp lpm_intersection
lpm_previous_inside:
 stx p1hi
 lda clip_cur_idx
 sta p1lo
lpm_intersection:
 lda p1hi
 sta lpm_inside
 lda #0
 sta clip_a_count
 sta clip_cur_inside
 jsr near_project_intersection
 ldx lpm_inside
 ldy #1
'''
        for axis in 'xyz':
            for part in ('lo','hi'):
                source+=f' lda lpn_{axis}{part},x\n sta clip_a_v{axis}{part},y\n'
        source+=''' lda #2
 sta clip_a_count
 jsr lps_near_screen
 lda clip_a_count
 cmp #2
 bcc lpm_no_edge
 lda clip_a_x
 sta ex0
 lda clip_a_y
 sta ey0
 lda clip_a_x+1
 sta ex1
 lda clip_a_y+1
 sta ey1
 lda #1
 rts
lpm_no_edge:
 lda #0
 rts
lpm_inside: .byte 0
'''
    return source


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('asm', type=Path)
    a = p.parse_args()
    a.asm.write_text(patch(a.asm.read_text(encoding='utf-8-sig')), encoding='ascii')
