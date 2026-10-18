"""Plus-only wire clipping: each flag describes the incoming polygon edge.

0 retains a source edge; 1 marks a closing edge created by clipping. An
intersection leaving a half-space inherits the source incoming-edge flag;
an entering intersection starts a new closing edge. This survives any
number of camera/screen planes, including two clipped ends of a real edge.
Transforms and raster arithmetic remain dev3. Near depth and edge clipping
are corrected separately, with native per-stage qualification.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import argparse
from pathlib import Path


def patch(source):
    def replace(old, new):
        nonlocal source
        assert source.count(old) == 1, old[:100]
        source = source.replace(old, new, 1)

    replace('draw_clip_wire_edge_guarded:\n jsr clip_wire_edge_is_generated_cap\n bcs dcweg_skip\n jsr clip_wire_edge_is_screen_border\n bcs dcweg_skip',
            'draw_clip_wire_edge_guarded:\n jsr clip_wire_edge_is_generated_cap\n bcs dcweg_skip')
    start = source.index('clip_wire_edge_is_generated_cap:\n')
    end = source.index('clip_wire_edge_is_screen_border:\n', start)
    source = source[:start] + '''; Flag belongs to the incoming edge, not to the vertex's origin.
clip_wire_edge_is_generated_cap:
 ldx clip_cur_idx
 lda clip_a_flag,x
 beq cwigc_draw
 sec
 rts
cwigc_draw:
 clc
 rts

''' + source[end:]

    # The input polygon has only original edges. Entering the near/camera
    # plane starts a cap; leaving it ends a retained original edge.
    for name in ('near_project_intersection', 'camera_plane_append_original_intersection'):
        start = source.index(name + ':\n')
        end = source.index('\n rts', start) + len('\n rts')
        block = source[start:end]
        old = ' lda #$01\n sta clip_a_flag,y'
        assert block.count(old) == 1, name
        source = source[:start] + block.replace(old, ' lda clip_cur_inside\n sta clip_a_flag,y') + source[end:]

    # Both camera-space and projected-screen Sutherland-Hodgman stages use
    # clip_cur_inside. Copies already preserve their incoming-edge flags.
    names = [
        ('camera_plane_append_intersection_a_to_b', 'a', 'b'),
        *[(f'clip_append_{plane}_intersection{cam}_{a}_to_{b}', a, b)
          for cam in ('', '_cam')
          for plane, a, b in (('right', 'a', 'b'), ('left', 'b', 'a'),
                              ('top', 'a', 'b'), ('bottom', 'b', 'a'))],
    ]
    for i, (name, a, b) in enumerate(names):
        start = source.index(name + ':\n')
        end = source.index('\n rts', start) + len('\n rts')
        block = source[start:end]
        old = f' lda #$01\n sta clip_{b}_flag,y'
        assert block.count(old) == 1, name
        new = f''' lda clip_cur_inside
 bne lp_edge_flag_{i}
 ldx clip_cur_idx
 lda clip_{a}_flag,x
lp_edge_flag_{i}:
 ldy clip_{b}_count
 sta clip_{b}_flag,y'''
        source = source[:start] + block.replace(old, new) + source[end:]

    # Screen compaction moves vertices: keep the incoming edge aligned.
    # Removing a duplicate final vertex transfers its incoming edge to the
    # first vertex, since it now closes the compacted polygon.
    replace(' lda clip_a_y,x\n sta clip_a_y,y\ncpcsa_inc_write:',
            ' lda clip_a_y,x\n sta clip_a_y,y\n lda clip_a_flag,x\n sta clip_a_flag,y\ncpcsa_inc_write:')
    replace(' bne cpcsa_done\n dec clip_a_count\ncpcsa_done:',
            ' bne cpcsa_done\n lda clip_a_flag,x\n sta clip_a_flag\n dec clip_a_count\ncpcsa_done:')
    # Second isolated correction: near_depth_byte clamps negative depth to
    # zero. That changes the intersection parameter for camera-plane crossings.
    # Use signed 16-bit endpoint depths, with positive unsigned numerator and
    # denominator (the first endpoint is outside, the second inside).
    start = source.index('near_project_intersection:\n')
    end = source.index(' jsr near_interp_x_to_t1', start)
    source = source[:start] + '''near_project_intersection:
 ldx p1lo
 stx clip_in_x
 ldx p1hi
 stx clip_out_x
 ldx clip_in_x
 sec
 lda #CAMERA_FACE_MIN_DEPTH
 sbc vzrawlo,x
 sta clip_num16_lo
 lda #$00
 sbc vzrawhi,x
 sta clip_num16_hi
 ldx clip_out_x
 lda vzrawlo,x
 ldx clip_in_x
 sec
 sbc vzrawlo,x
 sta clip_den16_lo
 ldx clip_out_x
 lda vzrawhi,x
 ldx clip_in_x
 sbc vzrawhi,x
 sta clip_den16_hi
 jsr clip_ratio_to_scale8
''' + source[end:]
    # Third isolated correction: projection's through-mesh clamp sets the
    # cached validity bit for vertices behind near. Near-poly classification
    # must reflect geometric depth, independent of that clamped screen point.
    replace('etpv_mark_valid:\n lda t1\n sta projdone,y', '''etpv_mark_valid:
.if EXPLORER_NEAR_POLY != 0
 lda vzrawhi,y
 bmi lp_depth_invalid
 bne lp_depth_valid
 lda vzrawlo,y
 cmp #CAMERA_FACE_MIN_DEPTH
 bcc lp_depth_invalid
lp_depth_valid:
 lda #$01
 bne lp_depth_store
lp_depth_invalid:
 lda #$00
lp_depth_store:
.else
 lda t1
.endif
 sta projdone,y''')
    # Fourth isolated correction: after clipping to positive near depth,
    # projected source edges are straight. Clip those signed16 screen points
    # directly. Repeated integer-WU side-plane interpolation can collapse a
    # narrow, still-visible source edge to a cap before rasterization.
    start = source.index('clip_loaded_face_near_poly:\n')
    end = source.index('cln_done:\n', start)
    block = source[start:end]
    old = '.if EXPLORER_CAMERA_X_CLIP != 0\n jsr clip_poly_clip_camera_x_current\n.else\n jsr clip_poly_clip_screen_current\n.endif'
    assert block.count(old) == 1
    source = source[:start] + block.replace(old, ' jsr clip_poly_clip_screen_current') + source[end:]
    # Fifth isolated correction: the ordinary positive-depth screen path
    # has the same lossy integer-WU side intersections. Keep its original
    # (fine-camera) projected coordinates and clip directly in screen space.
    start = source.index('clip_loaded_face_poly_x:\n')
    end = source.index('clip_poly_clip_screen_current:\n', start)
    block = source[start:end]
    old = ' jsr clip_poly_clip_camera_x_current\n rts'
    assert block.count(old) == 1
    source = source[:start] + block.replace(old, ' jsr clip_poly_clip_screen_current\n rts') + source[end:]
    return '; Legacy-plus dev5: retained edges and projected near/screen clipping\n' + source


def main():
    p = argparse.ArgumentParser()
    p.add_argument('asm', type=Path)
    args = p.parse_args()
    source = args.asm.read_text(encoding='utf-8-sig')
    args.asm.write_text(patch(source), encoding='ascii')


if __name__ == '__main__':
    main()
