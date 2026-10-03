"""Exact quotient/remainder Q2 edge DDA. Divisions occur in edge setup only."""
def generate(shaded,perspective=False):
    attrs=['x','s','v']+(['w'] if perspective else [])+(['q'] if shaded else [])
    s='''; Every face uses its whole clipped convex polygon, not a fan.
draw_clip_poly_gouraud:
 lda #0
 sta face_ymin
 lda #PROJ_SCREEN_MAX_Y
 sta face_ymax
 ldx #PROJ_SCREEN_MAX_Y
tq_clear:
 lda #255
 sta leftb,x
 lda #0
 sta rightb,x
 sta tq_closed,x
 dex
 bpl tq_clear
 lda #0
 sta tq_edge
tq_edges:
 lda tq_edge
 sta tq_from
 clc
 adc #1
 cmp hc_count
 bcc tq_next_ok
 lda #0
tq_next_ok:
 sta tq_to
 jsr tq_edge_setup
 inc tq_edge
 lda tq_edge
 cmp hc_count
 bne tq_edges
 jmp gouraud_fill_bounds

tq_edge_setup:
 ldx tq_from
 ldy tq_to
 lda hc_a_yhi,x
 cmp hc_a_yhi,y
 bcc tq_ordered
 bne tq_swap
 lda hc_a_ylo,x
 cmp hc_a_ylo,y
 bcc tq_ordered
 beq tq_edge_done
tq_swap:
 sty tq_from
 stx tq_to
 ldx tq_from
 ldy tq_to
tq_ordered:
 sec
 lda hc_a_ylo,y
 sbc hc_a_ylo,x
 sta tq_dy
 lda hc_a_yhi,y
 sbc hc_a_yhi,x
 sta tq_dy+1
 lda hc_a_ylo,x
 and #3
 eor #3
 clc
 adc #1
 and #3
 sta tq_pre
 clc
 adc hc_a_ylo,x
 sta tq_work
 lda hc_a_yhi,x
 adc #0
 lsr
 ror tq_work
 lsr
 ror tq_work
 lda tq_work
 sta tq_row
 clc
 lda hc_a_ylo,y
 adc #3
 sta tq_work
 lda hc_a_yhi,y
 adc #0
 lsr
 ror tq_work
 lsr
 ror tq_work
 lda tq_work
 sta tq_end
 ; Closed screen bottom; internal edge endpoints are otherwise excluded.
 lda hc_changed
 beq tq_end_ready
 lda hc_a_yhi,y
 cmp #>(PROJ_SCREEN_MAX_Y*4)
 bne tq_end_ready
 lda hc_a_ylo,y
 cmp #<(PROJ_SCREEN_MAX_Y*4)
 bne tq_end_ready
 inc tq_end
tq_end_ready:
 lda tq_row
 cmp tq_end
 bcs tq_edge_done
 lda #0
 sta tq_cap
 lda hc_changed
 beq tq_cap_ready
 lda hc_a_xhi,x
 cmp #>(PROJ_SCREEN_MAX_X*4)
 bne tq_cap_ready
 cmp hc_a_xhi,y
 bne tq_cap_ready
 lda hc_a_xlo,x
 cmp #<(PROJ_SCREEN_MAX_X*4)
 bne tq_cap_ready
 cmp hc_a_xlo,y
 bne tq_cap_ready
 inc tq_cap
tq_cap_ready:
'''
    for i,a in enumerate(attrs):
        s+=f' lda #{i}\n sta tq_ch\n ldx tq_from\n ldy tq_to\n'
        for j,part in enumerate(('lo','hi')):
            s+=f' lda hc_a_{a}{part},x\n sta tq_start+{j}\n'
        s+=' lda #0\n sta tq_start+2\n sec\n'
        for j,part in enumerate(('lo','hi')):
            s+=f' lda hc_a_{a}{part},y\n sbc hc_a_{a}{part},x\n sta tq_delta+{j}\n'
        s+=' lda #0\n sbc #0\n sta tq_delta+2\n jsr tq_setup_channel\n'
    s+='''tq_row_loop:
 ; ceil((integer-Q2 + remainder/dy)/4), including exact fractional ties.
 lda tq_cur0
 and #3
 bne tq_x_ceil
 lda tq_err0
 ora tq_err1
 beq tq_x_ceil
 lda #4
 bne tq_x_bias
tq_x_ceil:
 lda #3
tq_x_bias:
 clc
 adc tq_cur0
 sta tq_work
 lda tq_cur1
 adc #0
 lsr
 ror tq_work
 lsr
 ror tq_work
 ldx tq_row
 lda tq_work
 cmp leftb,x
 bcs tq_right
 sta leftb,x
'''
    names=(['ps_lefts_hi','ps_leftv_hi','ps_leftw_hi'] if perspective else ['leftshade','m7_leftv'])+(['m3_leftq'] if shaded else [])
    for i,n in enumerate(names,1):
        if perspective and i<=3:s+=f' lda tq_cur0+{i}\n sta {n[:-2]}lo,x\n'
        s+=f' lda tq_cur1+{i}\n sta {n},x\n'
    s+='''tq_right:
 lda tq_work
 cmp rightb,x
 bcc tq_next_row
 beq tq_right_tie
 sta rightb,x
 lda tq_cap
 jmp tq_right_cap
tq_right_tie:
 lda tq_cap
 ora tq_closed,x
tq_right_cap:
 sta tq_closed,x
'''
    names=(['ps_rights_hi','ps_rightv_hi','ps_rightw_hi'] if perspective else ['rightshade','m7_rightv'])+(['m3_rightq'] if shaded else [])
    for i,n in enumerate(names,1):
        if perspective and i<=3:s+=f' lda tq_cur0+{i}\n sta {n[:-2]}lo,x\n'
        s+=f' lda tq_cur1+{i}\n sta {n},x\n'
    s+='''tq_next_row:
 inc tq_row
 lda tq_row
 cmp tq_end
 beq tq_edge_done
 ldx #0
tq_advance:
 clc
'''
    for j in range(3):s+=f' lda tq_cur{j},x\n adc tq_step{j},x\n sta tq_cur{j},x\n'
    s+=''' clc
 lda tq_err0,x
 adc tq_rem0,x
 sta tq_err0,x
 lda tq_err1,x
 adc tq_rem1,x
 sta tq_err1,x
 cmp tq_dy+1
 bcc tq_advance_done
 bne tq_correct
 lda tq_err0,x
 cmp tq_dy
 bcc tq_advance_done
tq_correct:
 sec
 lda tq_err0,x
 sbc tq_dy
 sta tq_err0,x
 lda tq_err1,x
 sbc tq_dy+1
 sta tq_err1,x
 inc tq_cur0,x
 bne tq_advance_done
 inc tq_cur1,x
 bne tq_advance_done
 inc tq_cur2,x
tq_advance_done:
 inx
'''+f' cpx #{len(attrs)}\n bne tq_advance\n jmp tq_row_loop\ntq_edge_done:\n rts\n'
    s+='''; Exact initial offset and step, then quotient/remainder additions.
tq_setup_channel:
 lda tq_pre
 jsr tq_product
 ldx tq_ch
 clc
'''
    for j in range(3):s+=f' lda hc_result+{j}\n adc tq_start+{j}\n sta tq_cur{j},x\n'
    for j in range(2):s+=f' lda hc_remainder+{j}\n sta tq_err{j},x\n'
    s+=' lda #4\n jsr tq_product\n ldx tq_ch\n'
    for j in range(3):s+=f' lda hc_result+{j}\n sta tq_step{j},x\n'
    for j in range(2):s+=f' lda hc_remainder+{j}\n sta tq_rem{j},x\n'
    s+=''' rts
tq_product:
 sta hc_factor
 lda #0
 sta hc_factor+1
 sta hc_factor+2
 sta hc_den+2
 lda tq_dy
 sta hc_den
 lda tq_dy+1
 sta hc_den+1
'''
    for j in range(3):s+=f' lda tq_delta+{j}\n sta hc_delta+{j}\n'
    s+=''' jsr hq_ratio_product
 ; Convert signed trunc0 to Euclidean floor + nonnegative remainder.
 lda hc_sign
 bpl tq_product_done
 lda hc_remainder
 ora hc_remainder+1
 beq tq_product_done
 sec
 lda hc_result
 sbc #1
 sta hc_result
 lda hc_result+1
 sbc #0
 sta hc_result+1
 lda hc_result+2
 sbc #0
 sta hc_result+2
 sec
 lda tq_dy
 sbc hc_remainder
 sta hc_remainder
 lda tq_dy+1
 sbc hc_remainder+1
 sta hc_remainder+1
tq_product_done:
 rts
'''
    data='tq_closed: .fill VIEWPORT_ROW_CAPACITY,0\n'
    for n in ('edge','from','to','row','end','pre','work','cap','ch'):data+=f'tq_{n}: .byte 0\n'
    data+='tq_dy: .word 0\ntq_start: .fill 3,0\ntq_delta: .fill 3,0\n'
    for kind,count in (('cur',3),('step',3),('err',2),('rem',2)):
        for j in range(count):data+=f'tq_{kind}{j}: .fill {len(attrs)},0\n'
    return s,data
