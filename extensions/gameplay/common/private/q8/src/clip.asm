; Convex source triangle/quad -> near Q8 intersection -> screen Q8 clip -> Q2.
; Fractional shade carried as Q8 through all intersections (0..32).
load_face_y:
 sty sortj
.if GOURAUD_MODE6 != 0
 jsr gouraud_load_face_raw_shades_y
.endif
 ldy sortj
 lda face0,y
 sta hc_face_vertices
 lda face1,y
 sta hc_face_vertices+1
 lda face2,y
 sta hc_face_vertices+2
 lda face3,y
 sta hc_face_vertices+3
.if HAS_TRI_FACES != 0
 lda face_vertex_count,y
.else
 lda #4
.endif
 sta hc_source_count
 sta loaded_face_vertex_count
 sec
 sbc #1
 sta hc_previous
 lda #0
 sta hc_current
 sta hc_count
 sta hc_changed
 sta clip_poly_active
 lda hp_fault
 bne hc_face_empty
hc_near_loop:
 ldx hc_previous
 lda hc_face_vertices,x
 tax
 lda projdone,x
 sta hc_prev_inside
 ldx hc_current
 lda hc_face_vertices,x
 tax
 lda projdone,x
 sta hc_cur_inside
 cmp hc_prev_inside
 beq hc_near_no_cross
 lda #1
 sta hc_changed
 jsr hc_near_intersection
 jsr hc_append_a
hc_near_no_cross:
 lda hc_cur_inside
 beq hc_near_outside
 ldx hc_current
.if GOURAUD_MODE6 != 0
 lda gouraud_vshade0,x
.else
 lda #0
.endif
 sta hc_out_s+1
 lda #0
 sta hc_out_s
 lda hc_face_vertices,x
 tax
 lda sxq2_lo,x
 sta hc_q
 lda sxq2_hi,x
 sta hc_q+1
 lda hq_sx_fraction,x
 sta hq_residue
 jsr hq_expand_q
 lda hq_projected
 sta hc_out_x
 lda hq_projected+1
 sta hc_out_x+1
 lda hq_projected+2
 sta hc_out_x+2
 ldx hc_current
 lda hc_face_vertices,x
 tax
 lda syq2_lo,x
 sta hc_q
 lda syq2_hi,x
 sta hc_q+1
 lda hq_sy_fraction,x
 sta hq_residue
 jsr hq_expand_q
 lda hq_projected
 sta hc_out_y
 lda hq_projected+1
 sta hc_out_y+1
 lda hq_projected+2
 sta hc_out_y+2
 jsr hc_append_a
 jmp hc_near_next
hc_near_outside:
 lda #1
 sta hc_changed
hc_near_next:
 lda hc_current
 sta hc_previous
 inc hc_current
 lda hc_current
 cmp hc_source_count
 bne hc_near_loop
 lda hc_count
 cmp #3
 bcc hc_face_empty
 lda #0
 sta hc_plane
hc_screen_plane:
 jsr hc_screen_pass
 lda hc_count
 cmp #3
 bcc hc_face_empty
 inc hc_plane
 lda hc_plane
 cmp #4
 bne hc_screen_plane
 jsr hq_quantize_poly
 jsr hc_commit_poly
 ; Clipped Q2 shoelace sign is perspective-correct; old camera-XY cull is not.
 jsr hc_winding_visible
 bcc hc_face_empty
 lda hc_changed
 sta clip_poly_active
 bne hc_face_ready
 jsr hc_load_fast_face
 jmp screen_face_drawable
hc_face_ready:
 ; Span metadata remains required by sliver rejection/material setup.
 lda clip_a_x
 sta spanw
 sta p1lo
 lda clip_a_y
 sta spanh
 sta p1hi
 ldx #1
hc_meta_loop:
 lda clip_a_x,x
 cmp spanw
 bcc hc_meta_xmax
 sta spanw
hc_meta_xmax:
 cmp p1lo
 bcs hc_meta_y
 sta p1lo
hc_meta_y:
 lda clip_a_y,x
 cmp spanh
 bcc hc_meta_ymax
 sta spanh
hc_meta_ymax:
 cmp p1hi
 bcs hc_meta_next
 sta p1hi
hc_meta_next:
 inx
 cpx clip_a_count
 bne hc_meta_loop
 sec
 lda spanw
 sbc p1lo
 sta spanw
 sec
 lda spanh
 sbc p1hi
 sta spanh
 sec
 rts
hc_face_empty:
 lda #0
 sta hc_count
 sta clip_a_count
 lda #1
 sta clip_poly_active
 clc
 rts

hc_near_intersection:
 ldx hc_previous
 ldy hc_current
 lda hc_prev_inside
 beq hc_near_canonical
 ldx hc_current
 ldy hc_previous
hc_near_canonical:
 stx hc_from
 sty hc_to
 lda hc_face_vertices,x
 sta hc_from_vertex
 lda hc_face_vertices,y
 sta hc_to_vertex
 tax
 ldy hc_from_vertex
 sec
 lda hc_cam_z0,x
 sbc hc_cam_z0,y
 sta hc_den
 lda hc_cam_z1,x
 sbc hc_cam_z1,y
 sta hc_den+1
 sec
 lda #0
 sbc hc_cam_z0,y
 sta hc_factor
 lda #CAMERA_FACE_MIN_DEPTH
 sbc hc_cam_z1,y
 sta hc_factor+1
 lda #0
 sta hc_depth
 sta hc_depth+2
 lda #CAMERA_FACE_MIN_DEPTH
 sta hc_depth+1
 jsr hc_near_x
 jsr hc_near_y
.if GOURAUD_MODE6 != 0
 ldx hc_to
 ldy hc_from
 lda #0
 sta hc_delta
 sec
 lda gouraud_vshade0,x
 sbc gouraud_vshade0,y
 sta hc_delta+1
 jsr hc_ratio_product
 lda hc_result
 sta hc_out_s
 ldy hc_from
 clc
 lda hc_result+1
 adc gouraud_vshade0,y
 sta hc_out_s+1
.else
 lda #0
 sta hc_out_s
 sta hc_out_s+1
.endif
 rts

hc_screen_pass:
 ldx hc_plane
 lda hc_bounds_lo,x
 sta hc_bound
 lda hc_bounds_hi,x
 sta hc_bound+1
 lda #0
 sta hc_bound+2
 lda #0
 sta hc_out_count
 sta hc_current
 lda hc_count
 sec
 sbc #1
 sta hc_previous
hc_screen_loop:
 ldx hc_previous
 jsr hc_screen_inside
 lda #0
 rol
 sta hc_prev_inside
 ldx hc_current
 jsr hc_screen_inside
 lda #0
 rol
 sta hc_cur_inside
 cmp hc_prev_inside
 beq hc_screen_no_cross
 lda #1
 sta hc_changed
 jsr hc_screen_intersection
 jsr hc_append_b
hc_screen_no_cross:
 lda hc_cur_inside
 beq hc_screen_outside
 ldx hc_current
 jsr hc_copy_a_to_out
 jsr hc_append_b
 jmp hc_screen_next
hc_screen_outside:
 lda #1
 sta hc_changed
hc_screen_next:
 lda hc_current
 sta hc_previous
 inc hc_current
 lda hc_current
 cmp hc_count
 bne hc_screen_loop
 jmp hc_copy_back
hc_bounds_lo: .byte 0,0,0,0
hc_bounds_hi: .byte 0,PROJ_SCREEN_MAX_X,0,PROJ_SCREEN_MAX_Y

hc_screen_coord:
 lda hc_plane
 cmp #2
 bcs hc_screen_coord_y
 lda hc_a_xlo,x
 sta hc_value
 lda hc_a_xhi,x
 sta hc_value+1
 lda hc_a_xext,x
 sta hc_value+2
 rts
hc_screen_coord_y:
 lda hc_a_ylo,x
 sta hc_value
 lda hc_a_yhi,x
 sta hc_value+1
 lda hc_a_yext,x
 sta hc_value+2
 rts
hc_screen_inside:
 jsr hc_screen_coord
 lda hc_plane
 and #1
 bne hc_screen_upper
 lda hc_value+2
 bmi hc_screen_no
 sec
 rts
hc_screen_upper:
 lda hc_value+2
 bmi hc_screen_yes
 bne hc_screen_no
 lda hc_value+1
 cmp hc_bound+1
 bcc hc_screen_yes
 bne hc_screen_no
 lda hc_value
 cmp hc_bound
 bcc hc_screen_yes
 beq hc_screen_yes
hc_screen_no:
 clc
 rts
hc_screen_yes:
 sec
 rts

hc_screen_intersection:
 ldx hc_previous
 ldy hc_current
 lda hc_prev_inside
 beq hc_screen_canonical
 ldx hc_current
 ldy hc_previous
hc_screen_canonical:
 stx hc_from
 sty hc_to
 jsr hc_screen_coord
 lda hc_value
 sta hc_base
 lda hc_value+1
 sta hc_base+1
 lda hc_value+2
 sta hc_base+2
 sec
 lda hc_bound
 sbc hc_base
 sta hc_factor
 lda hc_bound+1
 sbc hc_base+1
 sta hc_factor+1
 lda hc_bound+2
 sbc hc_base+2
 sta hc_factor+2
 ldx hc_to
 jsr hc_screen_coord
 sec
 lda hc_value
 sbc hc_base
 sta hc_den
 lda hc_value+1
 sbc hc_base+1
 sta hc_den+1
 lda hc_value+2
 sbc hc_base+2
 sta hc_den+2
 bpl hc_screen_ratio_ready
 sec
 lda #0
 sbc hc_den
 sta hc_den
 lda #0
 sbc hc_den+1
 sta hc_den+1
 lda #0
 sbc hc_den+2
 sta hc_den+2
 sec
 lda #0
 sbc hc_factor
 sta hc_factor
 lda #0
 sbc hc_factor+1
 sta hc_factor+1
 lda #0
 sbc hc_factor+2
 sta hc_factor+2
hc_screen_ratio_ready:
 jsr hc_interpolate_x
 jsr hc_interpolate_y
.if GOURAUD_MODE6 != 0
 jsr hc_interpolate_s
.else
 lda #0
 sta hc_out_s
 sta hc_out_s+1
.endif
 lda hc_plane
 cmp #2
 bcs hc_screen_lock_y
 lda hc_bound
 sta hc_out_x
 lda hc_bound+1
 sta hc_out_x+1
 lda hc_bound+2
 sta hc_out_x+2
 rts
hc_screen_lock_y:
 lda hc_bound
 sta hc_out_y
 lda hc_bound+1
 sta hc_out_y+1
 lda hc_bound+2
 sta hc_out_y+2
 rts

hc_commit_poly:
 lda hc_count
 sta clip_a_count
 lda #0
 sta hc_poly_index
hc_commit_loop:
 ldx hc_poly_index
.if GOURAUD_MODE6 != 0
 lda hc_a_shi,x
 sta clip_a_shade,x
.endif
 lda #0
 sta hc_axis
 lda hc_a_xlo,x
 sta hc_q
 lda hc_a_xhi,x
 sta hc_q+1
 jsr hc_anchor
 ldx hc_poly_index
 sta clip_a_x,x
 lda #1
 sta hc_axis
 lda hc_a_ylo,x
 sta hc_q
 lda hc_a_yhi,x
 sta hc_q+1
 jsr hc_anchor
 ldx hc_poly_index
 sta clip_a_y,x
 inc hc_poly_index
 lda hc_poly_index
 cmp hc_count
 bne hc_commit_loop
 rts
hc_anchor:
 ; Exact center-relative integer anchor of already bounded Q2 coordinate.
 ldx hc_axis
 lda hc_q+1
 cmp hc_center_hi,x
 bcc hc_anchor_ceil
 bne hc_anchor_shift
 lda hc_q
 cmp hc_center_lo,x
 bcs hc_anchor_shift
hc_anchor_ceil:
 clc
 lda hc_q
 adc #3
 sta hc_q
 lda hc_q+1
 adc #0
 sta hc_q+1
hc_anchor_shift:
 lsr hc_q+1
 ror hc_q
 lsr hc_q+1
 ror hc_q
 lda hc_q
 rts

hp_needs_screen:
 ; Preserve existing conservative cull decision for wholly inside faces.
 ldy faceidx
 lda face0,y
 jsr hc_vertex_outside
 bne hc_needs_yes
 ldy faceidx
 lda face1,y
 jsr hc_vertex_outside
 bne hc_needs_yes
 ldy faceidx
 lda face2,y
 jsr hc_vertex_outside
 bne hc_needs_yes
.if HAS_TRI_FACES != 0
 ldy faceidx
 lda face_vertex_count,y
 cmp #4
 bne hc_needs_no
.endif
 ldy faceidx
 lda face3,y
 jsr hc_vertex_outside
 rts
hc_needs_no:
 lda #0
 rts
hc_needs_yes:
 lda #1
 rts
hc_vertex_outside:
 tax
 lda projdone,x
 beq hc_needs_yes
 lda sxq2_hi,x
 bmi hc_needs_yes
 cmp #>(PROJ_SCREEN_MAX_X*4)
 bcc hc_outside_test_y
 bne hc_needs_yes
 lda sxq2_lo,x
 cmp #<(PROJ_SCREEN_MAX_X*4+1)
 bcs hc_needs_yes
hc_outside_test_y:
 lda syq2_hi,x
 bmi hc_needs_yes
 cmp #>(PROJ_SCREEN_MAX_Y*4)
 bcc hc_needs_no
 bne hc_needs_yes
 lda syq2_lo,x
 cmp #<(PROJ_SCREEN_MAX_Y*4+1)
 bcs hc_needs_yes
 lda #0
 rts
