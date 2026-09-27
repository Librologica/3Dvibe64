"""Opt-in precise wire adapters. Preserve SDK pixel writer, buckets and timing."""
import re
from pathlib import Path
from continuous import prepare

def prepare_wire(source,music,motion,mode):
    source=prepare(source,music,motion,mode)
    if mode==1:
        source=source.replace('draw_wire_active_mesh:\n','draw_wire_active_mesh:\n jmp qw_mesh\n')
        source=source.replace('draw_wire_mesh:\n','draw_wire_mesh:\n jmp qw_mesh\n')
    else:
        assert 'MODE2_FACE_BUCKET_PIPELINE = $01' in source
        source=source.replace(' jsr mode2_screen_winding_visible',' sec ; precise winding already checked by Q8 loader\n nop\n nop')
        source=source.replace('draw_loaded_wire_face:\n','draw_loaded_wire_face:\n jmp qw_draw_face\n')
        for b in 'ab':source=source.replace(f'draw_loaded_face_solid_{b}:\n',f'draw_loaded_face_solid_{b}:\n jsr qw_build_mask\n jmp fill_bounds_solid_{b}\n')
    return source

def wire_pieces(p,lab):
    p.pop('poly_draw')
    # Always retain clipped polygon in hc_a for masks. No integer fast loader.
    old=' lda hc_changed\n sta clip_poly_active\n bne hc_face_ready\n jsr hc_load_fast_face\n jmp screen_face_drawable\n'
    assert old in p['clip']
    p['clip']=p['clip'].replace(old,' lda #1\n sta clip_poly_active\n jmp hc_face_ready\n')
    # Gouraud entry is never assembled in wire; parent retired it to an alias.
    # Private Q2 caches, not an expansion of SDK solid flags.
    for a in 'xy':
        for part in ('lo','hi'):p['data']+=f's{a}q2_{part}: .fill VERT_COUNT,0\n'
        for i in range(4):
            for part in ('lo','hi'):p['data']+=f'v{a}q2_{i}{part}: .byte 0\n'
    for n,size in [('v0',1),('v1',1),('edge',1),('face',1),('side',1),('arity',1),('plane',1),('end',1),
                   ('mask',1),('poly_i',1),('x0',2),('y0',2),('x1',2),('y1',2),('dx',2),('dy',2),
                   ('major',1),('sign',1),('a',2),('b',2),('c',2),('d',2),('den',2),('step',2),
                   ('rem',2),('pos',1),('last',1),('minor',1),('saved',4)]:p['data']+=f'qw_{n}: .fill {size},0\n'
    p['wire_clip']=edge_clip()
    p['wire_dispatch']=dispatch(lab['GRAPHICS_MODE'])
    p['wire_line']=Path(__file__).with_name('wire_line.asm').read_text()
    return p

def copy(src,dst,size=2):return ''.join(f' lda {src}+{i}\n sta {dst}+{i}\n' for i in range(size))

def edge_clip():
    s='''; Each original edge is clipped separately: never create cap edges.
qw_clip_edge:
 lda #0
 sta hc_current
 sta hc_previous
 lda qw_v0
 sta hc_face_vertices
 tax
 lda projdone,x
 sta hc_prev_inside
 lda qw_v1
 sta hc_face_vertices+1
 tax
 lda projdone,x
 sta hc_cur_inside
 ora hc_prev_inside
 beq qw_edge_empty
 lda #1
 sta hc_current
 lda hc_cur_inside
 cmp hc_prev_inside
 beq qw_edge_near_ready
 jsr hc_near_intersection
 lda hc_prev_inside
 beq qw_store_near_zero
 ldy #1
 bne qw_store_near
qw_store_near_zero:
 ldy #0
qw_store_near:
'''
    for a in 'xy':
        for i,suf in enumerate(('lo','hi','ext')):s+=f' lda hc_out_{a}+{i}\n sta hc_a_{a}{suf},y\n'
    s+='qw_edge_near_ready:\n lda #0\n sta hc_corner\nqw_edge_load:\n ldx hc_corner\n lda hc_face_vertices,x\n tax\n lda projdone,x\n beq qw_edge_load_next\n'
    for a in 'xy':
        s+=f' ldx hc_corner\n lda hc_face_vertices,x\n tax\n lda s{a}q2_lo,x\n sta hc_q\n lda s{a}q2_hi,x\n sta hc_q+1\n lda hq_s{a}_fraction,x\n sta hq_residue\n jsr hq_expand_q\n ldy hc_corner\n'
        for i,suf in enumerate(('lo','hi','ext')):s+=f' lda hq_projected+{i}\n sta hc_a_{a}{suf},y\n'
    s+='''qw_edge_load_next:
 inc hc_corner
 lda hc_corner
 cmp #2
 bne qw_edge_load
 lda #0
 sta hc_plane
 sta hc_previous
 lda #1
 sta hc_current
qw_edge_plane:
 ldx hc_plane
 lda hc_bounds_lo,x
 sta hc_bound
 lda hc_bounds_hi,x
 sta hc_bound+1
 lda #0
 sta hc_bound+2
 ldx #0
 jsr hc_screen_inside
 lda #0
 rol
 sta hc_prev_inside
 ldx #1
 jsr hc_screen_inside
 lda #0
 rol
 sta hc_cur_inside
 ora hc_prev_inside
 beq qw_edge_empty
 lda hc_cur_inside
 cmp hc_prev_inside
 beq qw_edge_next_plane
 jsr hc_screen_intersection
 ldy hc_from
'''
    for a in 'xy':
        for i,suf in enumerate(('lo','hi','ext')):s+=f' lda hc_out_{a}+{i}\n sta hc_a_{a}{suf},y\n'
    s+='''qw_edge_next_plane:
 inc hc_plane
 lda hc_plane
 cmp #4
 bne qw_edge_plane
 lda #2
 sta hc_count
 jsr hq_quantize_poly
'''
    for a in 'xy':
        for n in range(2):
            for i,suf in enumerate(('lo','hi')):s+=f' lda hc_a_{a}{suf}+{n}\n sta qw_{a}{n}+{i}\n'
    s+=' sec\n rts\nqw_edge_empty:\n clc\n rts\n'
    return s

def dispatch(mode):
    if mode==1:
        return '''qw_mesh:
 lda #0
 sta qw_mask
.if WIRE_TWO_COLOR_MODE1_ENABLE != 0
 jsr activate_wire_two_color_palette
.else
 lda #$aa
 sta fillbyte
.endif
 ldx meshidx
 lda mesh_edge_first,x
 sta qw_edge
 lda mesh_edge_end,x
 sta qw_end
qw_mesh_loop:
 lda qw_edge
 cmp qw_end
 beq qw_mesh_done
 tay
 lda edge0,y
 sta qw_v0
 lda edge1,y
 sta qw_v1
.if WIRE_TWO_COLOR_MODE1_ENABLE != 0
 jsr load_wire_two_color_edge_pattern_y
.endif
.if WIRE_EDGE_SOLID_COLOR_ENABLE != 0
 ldx qw_edge
 jsr load_wire_edge_solid_color_x
.endif
 jsr qw_clip_edge
 bcc qw_mesh_next
 jsr qw_line
qw_mesh_next:
 inc qw_edge
 jmp qw_mesh_loop
qw_mesh_done:
 rts
'''
    s='''qw_draw_face:
 lda #0
 sta qw_mask
 lda sortj
 sta qw_face
 tay
.if HAS_TRI_FACES != 0
 lda face_vertex_count,y
.else
 lda #4
.endif
 sta qw_arity
 lda #0
 sta qw_side
qw_face_loop:
 ldy qw_face
 ldx qw_side
 lda qw_face_table_lo,x
 sta qw_face_fetch+1
 lda qw_face_table_hi,x
 sta qw_face_fetch+2
qw_face_fetch:
 lda face0,y
 sta qw_v0
 inx
 cpx qw_arity
 bcc qw_face_next_index
 ldx #0
qw_face_next_index:
 lda qw_face_table_lo,x
 sta qw_face_fetch_next+1
 lda qw_face_table_hi,x
 sta qw_face_fetch_next+2
qw_face_fetch_next:
 lda face0,y
 sta qw_v1
 jsr qw_clip_edge
 bcc qw_face_next
 jsr qw_line
qw_face_next:
 inc qw_side
 lda qw_side
 cmp qw_arity
 bne qw_face_loop
 lda qw_face
 sta sortj
 rts
qw_face_table_lo: .byte <face0,<face1,<face2,<face3
qw_face_table_hi: .byte >face0,>face1,>face2,>face3

; Same connected Q2 boundary as the line walker; original solid erase spans.
qw_mask:
 lda #1
 sta qw_mask
 lda #99
 sta face_ymin
 lda #0
 sta face_ymax
 ldx #99
qw_mask_clear:
 lda #255
 sta leftb,x
 lda #0
 sta rightb,x
 dex
 bpl qw_mask_clear
 lda #0
 sta qw_poly_i
qw_mask_loop:
 ldx qw_poly_i
'''
    for a in 'xy':
        for i,suf in enumerate(('lo','hi')):s+=f' lda hc_a_{a}{suf},x\n sta qw_{a}0+{i}\n'
    s+=' inx\n cpx hc_count\n bcc qw_mask_next_index\n ldx #0\nqw_mask_next_index:\n'
    for a in 'xy':
        for i,suf in enumerate(('lo','hi')):s+=f' lda hc_a_{a}{suf},x\n sta qw_{a}1+{i}\n'
    s+=' jsr qw_line\n inc qw_poly_i\n lda qw_poly_i\n cmp hc_count\n bne qw_mask_loop\n rts\n'
    # Data/routine names must never alias.
    return s.replace('qw_mask:\n','qw_build_mask:\n')
