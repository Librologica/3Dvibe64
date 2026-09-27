; Preserve whole convex clipped polygon: no fan/shading seam at clip activation.
draw_clip_poly_gouraud:
 ; Fault unwind must return to this caller, not a previous face's stack.
 tsx
 stx xyq2_builder_sp
 lda #0
 sta xyq2_faulted
 sta xyq2_face_valid
 lda hc_count
 cmp #3
 bcc hc_poly_done
 lda hc_a_ylo
 sta xyq2_minlo
 sta xyq2_maxlo
 lda hc_a_yhi
 sta xyq2_minhi
 sta xyq2_maxhi
 ldx #1
hc_poly_minmax:
 stx hc_poly_index
 lda hc_a_ylo,x
 sta xyq2_nlo
 lda hc_a_yhi,x
 sta xyq2_nhi
 jsr xyq2_include_y
 ldx hc_poly_index
 inx
 cpx hc_count
 bne hc_poly_minmax
 lda xyq2_minlo
 sta vyq2_0lo
 sta vyq2_2lo
 sta vyq2_3lo
 lda xyq2_minhi
 sta vyq2_0hi
 sta vyq2_2hi
 sta vyq2_3hi
 lda xyq2_maxlo
 sta vyq2_1lo
 lda xyq2_maxhi
 sta vyq2_1hi
 jsr setup_face_y_bounds_xyq2
 bcc hc_poly_done
 lda #0
 sta hc_poly_index
hc_poly_edges:
 ldx hc_poly_index
 lda hc_a_xlo,x
 sta xyq2_x0lo
 lda hc_a_xhi,x
 sta xyq2_x0hi
 lda hc_a_ylo,x
 sta xyq2_y0lo
 lda hc_a_yhi,x
 sta xyq2_y0hi
 inx
 cpx hc_count
 bcc hc_poly_next_ok
 ldx #0
hc_poly_next_ok:
 lda hc_a_xlo,x
 sta xyq2_x1lo
 lda hc_a_xhi,x
 sta xyq2_x1hi
 lda hc_a_ylo,x
 sta xyq2_y1lo
 lda hc_a_yhi,x
 sta xyq2_y1hi
 jsr trace_edge_convex_xyq2
 inc hc_poly_index
 lda hc_poly_index
 cmp hc_count
 bne hc_poly_edges
 jsr xyq2_validate_bounds
 lda xyq2_face_valid
 beq hc_poly_done
 ldx face_ymin
hc_poly_init_shades:
 lda clip_a_shade
 sta leftshade,x
 sta rightshade,x
 cpx face_ymax
 beq hc_poly_shades_begin
 inx
 bne hc_poly_init_shades
hc_poly_shades_begin:
 lda #0
 sta hc_poly_index
hc_poly_shades:
 ldx hc_poly_index
 lda clip_a_x,x
 sta gouraud_edge_x0
 lda clip_a_y,x
 sta gouraud_edge_y0
 lda clip_a_shade,x
 sta gouraud_edge_s0
 inx
 cpx hc_count
 bcc hc_poly_shade_next
 ldx #0
hc_poly_shade_next:
 lda clip_a_x,x
 sta gouraud_edge_x1
 lda clip_a_y,x
 sta gouraud_edge_y1
 lda clip_a_shade,x
 sta gouraud_edge_s1
 jsr gouraud_trace_shade_edge
 inc hc_poly_index
 lda hc_poly_index
 cmp hc_count
 bne hc_poly_shades
 jmp gouraud_fill_bounds
hc_poly_done:
 rts
