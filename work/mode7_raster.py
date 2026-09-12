"""R1: integer top-left coverage for the current C + LightFix renderer only.

Same XY endpoints and U/V/Q DDA. No new storage or per-pixel arithmetic.
Sample at integer (x,y): y0 <= y < y1, ceil(left) <= x < ceil(right).
The right intersection remains the interpolation anchor, not a covered pixel.
"""


def accurate_edges(s):
    for suffix in ('', '_v', '_v_q'):
        start = s.index('gouraud_trace_shade_edge'+suffix+':\n')
        end = s.index('gouraud_store_edge_sample'+suffix+':\n', start)
        edge = s[start:end]
        old = ' sta gouraud_edge_xerr_hi\n'
        new = old+f''' lda gouraud_edge_xdir
 bmi r1_x_bias_done{suffix}
 lda gouraud_edge_dy
 sec
 sbc #1
 sta gouraud_edge_xerr_lo
r1_x_bias_done{suffix}:
 lda #0
'''
        # Negative slopes already produce ceil(x0-|dx|*k/dy).
        # dy-1 bias makes positive slopes produce the same ceil convention.
        assert edge.count(old) == 1
        edge = edge.replace(old, new)
        old = f'''gtse_loop{suffix}:
 jsr gouraud_store_edge_sample{suffix}
 lda gouraud_edge_row
 cmp gouraud_edge_y1
 beq gtse_done{suffix}
'''
        new = f'''gtse_loop{suffix}:
 lda gouraud_edge_row
 cmp gouraud_edge_y1
 bne r1_edge_sample{suffix}
 lda clip_poly_active
 beq gtse_done{suffix}
 lda gouraud_edge_row
 cmp #PROJ_SCREEN_MAX_Y
 bne gtse_done{suffix}
 jsr gouraud_store_edge_sample{suffix}
 rts
r1_edge_sample{suffix}:
 jsr gouraud_store_edge_sample{suffix}
'''
        assert edge.count(old) == 1
        edge = edge.replace(old, new)
        a = edge.index('gtse_horizontal'+suffix+':\n')
        b = edge.index('gtse_done'+suffix+':\n', a)
        edge = edge[:a]+'gtse_horizontal'+suffix+':\n'+edge[b:]
        s = s[:start]+edge+s[end:]
    # Keep rightval and denominator at the right U/V/Q anchor. Only the
    # final covered pixel changes, so no last-pixel division or UV rescale.
    old = ' sta gouraud_scan_end\n ldy yrow\n'
    assert s.count(old) == 1
    # The viewport clipping caps are closed: max X/Y denote the last valid
    # sample, not a shared mesh edge. Preserve that final column/row.
    cap_range = 'r1_span_closed_cap:\n ldx #255\n ldy #0\n'
    for i in range(3):
        cap_range += f''' lda vx{i}
 cmp #PROJ_SCREEN_MAX_X
 bne r1_cap_next{i}
 cpx vy{i}
 bcc r1_cap_min{i}
 ldx vy{i}
r1_cap_min{i}:
 cpy vy{i}
 bcs r1_cap_next{i}
 ldy vy{i}
r1_cap_next{i}:
'''
    # ceil(right)==MAX_X alone is insufficient: it may still be outside a
    # sloped edge. Only the actual triangle intersection with the clip cap
    # is closed. Its Y interval is the min/max of vertices exactly on MAX_X.
    # X/Y are free here; UV/Q setup below reloads both. No scratch RAM.
    s = s.replace(old, ''' sta gouraud_scan_end
 lda clip_poly_active
 beq r1_trim_right
 lda gouraud_scan_end
 cmp #PROJ_SCREEN_MAX_X
 bne r1_trim_right
 jsr r1_span_closed_cap
 bcs r1_right_ready
r1_trim_right:
 dec gouraud_scan_end
r1_right_ready:
 ldy yrow
''')
    cap_range += ''' txa
 cmp yrow
 beq r1_cap_check_max
 bcs r1_cap_no
r1_cap_check_max:
 tya
 cmp yrow
 rts
r1_cap_no:
 clc
 rts
'''
    s = s.replace('gouraud_fill_bounds:\n', cap_range+'\ngouraud_fill_bounds:\n')
    old = ' cmp leftval\n bcc gfb_next\n'
    assert s.count(old) == 1
    # On a closed viewport cap, ceil(left)==right==MAX_X may cover one
    # pixel, even though an ordinary half-open span with equal bounds is
    # empty. Exclude terminal apex rows; integer horizontal extrema with
    # nonzero width already have distinct bounds. The cap interval test
    # rejects equal ceil intersections merely adjacent to MAX_X.
    return s.replace(old, ''' cmp leftval
 bcc gfb_next
 bne r1_gfb_nonempty
 lda clip_poly_active
 beq gfb_next
 lda rightval
 cmp #PROJ_SCREEN_MAX_X
 bne gfb_next
 lda vx0
 cmp #PROJ_SCREEN_MAX_X
 bne r1_gfb_cap_has_width
 lda vx1
 cmp #PROJ_SCREEN_MAX_X
 bne r1_gfb_cap_has_width
 lda vx2
 cmp #PROJ_SCREEN_MAX_X
 beq gfb_next
r1_gfb_cap_has_width:
 cpx face_ymin
 beq gfb_next
 cpx face_ymax
 beq gfb_next
 stx yrow
 jsr r1_span_closed_cap
 ldx yrow
 bcc gfb_next
r1_gfb_nonempty:
''')
