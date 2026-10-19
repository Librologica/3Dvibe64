"""Convex fan fill and an explicit opaque triangle-pair bounds API.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
from pathlib import Path

def patch(s):
    from legacy_plus_exact import once,block,constant
    if constant(s,'LAZY_CONVEX_BOUNDS')!=0:raise ValueError('EXACT_RENDER_CONVEX: eager bounds required')
    a=s.index('draw_clip_poly_common:\n');b=s.index('dcp_done:\n rts\n',a)+len('dcp_done:\n rts\n')
    s=s[:a]+'''draw_clip_poly_common:
 lda clip_a_count
 cmp #3
 bcc dcp_done
 jsr er_merge_begin
 lda #1
 sta clip_cur_idx
dcp_loop:
 jsr load_clip_poly_fan_triangle
 jsr build_loaded_face_bounds_convex
 lda er_merge_active
 bne er_clip_next
 jsr er_clip_fill
er_clip_next:
 inc clip_cur_idx
 lda clip_cur_idx
 clc
 adc #1
 cmp clip_a_count
 bcc dcp_loop
 lda er_merge_active
 beq dcp_done
 lda er_merge_ymin
 sta face_ymin
 lda er_merge_ymax
 sta face_ymax
 lda #0
 sta er_merge_active
 jsr er_clip_fill
dcp_done:
 rts
er_clip_fill:
 jsr fill_bounds_solid_a
 rts
'''+s[b:]
    s=s.replace('dcp_fill_call+','er_clip_fill+')
    s=once(s,'build_loaded_face_bounds_convex_legacy:\n jsr setup_face_y_bounds\n','build_loaded_face_bounds_convex_legacy:\n jsr setup_face_y_bounds\n lda er_merge_active\n bne bltc_init_done\n')
    helper='''; Only uniform solid native fills may merge; patterns retain their fan.
er_merge_begin:
 lda #0
 sta er_merge_active
.if FACE_MATERIAL_ACTIVE_ONLY != 1 || FACE_REFLECTIVITY_ACTIVE_ONLY != 1 || FACE_SOLID_COLOR_ENABLE != 0 || VIC_COLOR_POLICY_ENABLE != 0
 rts ; preserve material-cell painter ownership on mixed palettes
.endif
 lda clip_a_count
 cmp #4
 bcc er_merge_no
 cmp #(CLIP_POLY_VERTEX_CAPACITY+1)
 bcs er_merge_no
 lda er_clip_fill+1
 cmp #<fill_bounds_solid_a
 bne er_merge_check_b
 lda er_clip_fill+2
 cmp #>fill_bounds_solid_a
 beq er_merge_shape
er_merge_check_b:
 lda er_clip_fill+1
 cmp #<fill_bounds_solid_b
 bne er_merge_no
 lda er_clip_fill+2
 cmp #>fill_bounds_solid_b
 bne er_merge_no
er_merge_shape:
 lda clip_a_count
 sta er_shape_count
 ldx #0
er_merge_copy:
 lda clip_a_x,x
 sta er_shape_x,x
 lda #0
 sta er_shape_yhi,x
 lda clip_a_y,x
 asl
 rol er_shape_yhi,x
 asl
 rol er_shape_yhi,x
 sta er_shape_ylo,x
 inx
 cpx er_shape_count
 bne er_merge_copy
 jsr er_convex_shape
 bcc er_merge_no
 lda clip_a_y
 sta er_merge_ymin
 sta er_merge_ymax
 ldx er_shape_count
 dex
er_merge_extrema:
 lda clip_a_y,x
 cmp er_merge_ymin
 bcs +
 sta er_merge_ymin
+
 cmp er_merge_ymax
 bcc +
 sta er_merge_ymax
+
 dex
 bpl er_merge_extrema
 lda clip_a_y
 cmp er_merge_ymin
 beq er_merge_init
 cmp er_merge_ymax
 bne er_merge_no
er_merge_init:
 ldx er_merge_ymin
er_merge_clear:
 lda #255
 sta leftb,x
 lda #0
 sta rightb,x
 cpx er_merge_ymax
 beq er_merge_yes
 inx
 jmp er_merge_clear
er_merge_yes:
 lda #1
 sta er_merge_active
 rts
er_merge_no:
 rts

; Explicit adapter entry, never applied to an ordinary source quad.
; Caller must have loaded an opaque same-material triangle pair as one quad,
; with native Q2 endpoints, in front of near and in contiguous painter order.
; On carry clear rebuild/draw the original two triangles. No pixels are written.
er_try_pair_bounds:
 lda clip_poly_active
 bne er_pair_no
 lda loaded_face_vertex_count
 cmp #4
 bne er_pair_no
 jsr mobile_yq2_face_eligible
 bcc er_pair_no
 lda #4
 sta er_shape_count
 ldx #0
 ldy #0
er_pair_copy:
 cpy #3
 bne +
 lda vx3
 jmp er_pair_x_ready
+
 lda vx0,x
er_pair_x_ready:
 cmp #(PROJ_SCREEN_MAX_X+1)
 bcs er_pair_no
 sta er_shape_x,y
 lda vyq2_0hi,x
 cmp #>((PROJ_SCREEN_MAX_Y*4)+1)
 bcc +
 bne er_pair_no
 lda vyq2_0lo,x
 cmp #<((PROJ_SCREEN_MAX_Y*4)+1)
 bcs er_pair_no
+
 lda vyq2_0lo,x
 sta er_shape_ylo,y
 lda vyq2_0hi,x
 sta er_shape_yhi,y
 inx
 inx
 iny
 cpy #4
 bne er_pair_copy
 jsr er_convex_shape
 bcc er_pair_no
 jsr build_loaded_face_bounds_xyq2
 lda #2
 ldx #0
 jsr er_pair_diagonal
 lda #0
 ldx #2
 jsr er_pair_diagonal
 jsr xyq2_validate_bounds
 lda xyq2_face_valid
 beq er_pair_no
 sec
 rts
er_pair_no:
 clc
 rts
er_pair_diagonal:
 asl
 tay
 txa
 asl
 tax
 lda vxq2_0lo,y
 sta xyq2_x0lo
 lda vxq2_0hi,y
 sta xyq2_x0hi
 lda vyq2_0lo,y
 sta xyq2_y0lo
 lda vyq2_0hi,y
 sta xyq2_y0hi
 lda vxq2_0lo,x
 sta xyq2_x1lo
 lda vxq2_0hi,x
 sta xyq2_x1hi
 lda vyq2_0lo,x
 sta xyq2_y1lo
 lda vyq2_0hi,x
 sta xyq2_y1hi
 jmp trace_edge_convex_xyq2

er_merge_active: .byte 0
er_merge_ymin: .byte 0
er_merge_ymax: .byte 0
er_shape_count: .byte 0
er_shape_x: .fill CLIP_POLY_VERTEX_CAPACITY,0
er_shape_ylo: .fill CLIP_POLY_VERTEX_CAPACITY,0
er_shape_yhi: .fill CLIP_POLY_VERTEX_CAPACITY,0
'''
    helper+=(Path(__file__).parent/'exact_render/convex.asm').read_text()
    return s+block('convex',helper)
