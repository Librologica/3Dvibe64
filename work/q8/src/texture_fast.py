"""Scene-independent Mode 7 fast profile, explicitly approximate.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. No frozen demo, fixed addresses or RGB LUT.
Eight-pixel exact projective endpoints / affine interior / exact 1..8 tail.
Even logical rows sampled; missing pair copied within the SAME VIC color cell.
"""
from perspective_exact import once


def sampler():
    return '''ps_sample:
 stx bk_saved_x
 lda pu_texel
 beq bk_textured
 rts
bk_textured:
 lda bk_count
 beq bk_boundary
bk_cached:
 lda bk_cur1
 sta m7_u
 lda bk_cur1+1
 sta m7_v
 ldx bk_saved_x
 rts
bk_boundary:
 sec
 lda gouraud_scan_end
 sbc gouraud_scan_x
 cmp #8
 bcs bk_long
 jmp bk_exact_sample
bk_long:
 lda bk_ready
 beq bk_seed
 ldx #1
bk_reuse:
 lda bk_next,x
 sta bk_cur1,x
 lda #0
 sta bk_cur0,x
 dex
 bpl bk_reuse
 jmp bk_start
bk_seed:
 jsr bk_exact_sample
 ldx #1
bk_copy_start:
 lda m7_u,x
 sta bk_cur1,x
 lda #0
 sta bk_cur0,x
 dex
 bpl bk_copy_start
bk_start:
 ldx #2
bk_predict_channels:
 jsr bk_predict
 lda bk_future
 sta bk_look0,x
 lda bk_future+1
 sta bk_look1,x
 dex
 bpl bk_predict_channels
 lda bk_look0+2
 sta ps_den
 lda bk_look1+2
 sta ps_den+1
 ldx #1
bk_inputs:
 lda bk_look0,x
 sta up_inputlo,x
 lda bk_look1,x
 sta up_inputhi,x
 dex
 bpl bk_inputs
 jsr up_pair
 ldx #1
bk_endpoints:
 lda m7_u,x
 sta bk_next,x
 dex
 bpl bk_endpoints
 ldx #1
bk_setup_steps:
 sec
 lda bk_next,x
 sbc bk_cur1,x
 tay
 lda #0
 sbc #0
 sta bk_sign
 tya
 asl
 asl
 asl
 asl
 asl
 sta bk_step0,x
 tya
 lsr bk_sign
 ror
 lsr bk_sign
 ror
 lsr bk_sign
 ror
 sta bk_step1,x
 dex
 bpl bk_setup_steps
 lda #8
 sta bk_count
 lda #1
 sta bk_ready
 jmp bk_cached
bk_predict:
 clc
 lda ps_cur0,x
 adc bk_step8lo,x
 sta bk_future
 lda ps_cur1,x
 adc bk_step8hi,x
 sta bk_future+1
 clc
 lda ps_err,x
 adc bk_rem8,x
 bcs bk_correct
 cmp m7_den
 bcc bk_predict_done
bk_correct:
 sec
 sbc m7_den
 inc bk_future
 bne bk_predict_done
 inc bk_future+1
bk_predict_done:
 rts
'''


def carriers():
    return '''bk_setup_carriers:
 lda m7_den
 cmp #8
 bcc bk_setup_done
 ldx #2
bk_setup_channel:
 lda ps_step0,x
 sta bk_step8lo,x
 lda ps_step1,x
 sta bk_step8hi,x
 lda ps_rem,x
 sta bk_rem8,x
 ldy #3
bk_setup_double:
 asl bk_step8lo,x
 rol bk_step8hi,x
 lda bk_rem8,x
 asl
 bcs bk_setup_sub
 cmp m7_den
 bcc bk_setup_store
bk_setup_sub:
 sec
 sbc m7_den
 inc bk_step8lo,x
 bne bk_setup_store
 inc bk_step8hi,x
bk_setup_store:
 sta bk_rem8,x
 dey
 bne bk_setup_double
 dex
 bpl bk_setup_channel
bk_setup_done:
 rts
bk_advance_uv:
 lda bk_count
 beq bk_advance_done
 dec bk_count
 ldx #1
bk_advance_channel:
 clc
 lda bk_cur0,x
 adc bk_step0,x
 sta bk_cur0,x
 lda bk_cur1,x
 adc bk_step1,x
 sta bk_cur1,x
 dex
 bpl bk_advance_channel
bk_advance_done:
 rts
'''


def edge_one():
    return '''we_advance_one:
 clc
 lda tq_cur0,x
 adc tq_step0,x
 sta tq_cur0,x
 lda tq_cur1,x
 adc tq_step1,x
 sta tq_cur1,x
 lda tq_cur2,x
 adc tq_step2,x
 sta tq_cur2,x
 clc
 lda tq_err0,x
 adc tq_rem0,x
 sta tq_err0,x
 lda tq_err1,x
 adc tq_rem1,x
 sta tq_err1,x
 cmp tq_dy+1
 bcc we_one_done
 bne we_one_correct
 lda tq_err0,x
 cmp tq_dy
 bcc we_one_done
we_one_correct:
 sec
 lda tq_err0,x
 sbc tq_dy
 sta tq_err0,x
 lda tq_err1,x
 sbc tq_dy+1
 sta tq_err1,x
 inc tq_cur0,x
 bne we_one_done
 inc tq_cur1,x
 bne we_one_done
 inc tq_cur2,x
we_one_done:
 rts
'''


def edge_prime():
    return '''we_prepare_steps:
 lda tq_row
 and #1
 beq we_double_begin
 ldx #1
we_prime:
 jsr we_advance_one
 inx
 cpx #5
 bne we_prime
we_double_begin:
 ldx #1
we_double:
 asl tq_step0,x
 rol tq_step1,x
 rol tq_step2,x
 asl tq_rem0,x
 rol tq_rem1,x
 lda tq_rem1,x
 cmp tq_dy+1
 bcc we_double_next
 bne we_double_correct
 lda tq_rem0,x
 cmp tq_dy
 bcc we_double_next
we_double_correct:
 sec
 lda tq_rem0,x
 sbc tq_dy
 sta tq_rem0,x
 lda tq_rem1,x
 sbc tq_dy+1
 sta tq_rem1,x
 inc tq_step0,x
 bne we_double_next
 inc tq_step1,x
 bne we_double_next
 inc tq_step2,x
we_double_next:
 inx
 cpx #5
 bne we_double
 rts
'''


def row_filter():
    return '''sl_filter_row:
 txa
 and #1
 bne sl_skipped_palette
 lda leftb,x
 jmp sl_retained
sl_skipped_palette:
 lda leftb,x
 sta leftval
 lda rightb,x
 sta rightval
 cmp leftval
 bcc sl_skipped_empty
 bne sl_skipped_nonempty
 lda tq_closed,x
 beq sl_skipped_empty
sl_skipped_nonempty:
 stx yrow
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx rightval
 lda xbyte,x
 sta endbyte
 lda drawbuf
 bne sl_palette_b
 jsr apply_material_span_a
 jmp gfb_next_restore
sl_palette_b:
 jsr apply_material_span_b
 jmp gfb_next_restore
sl_skipped_empty:
 jmp gfb_next
'''


def duplicate():
    return '''sl_duplicate:
 lda #1
 sta sl_gap
sl_gap_loop:
 ldx sl_gap
 lda drawbuf
 bne sl_bank_b
 lda row0lo_a-1,x
 sta ptr0lo
 lda row0hi_a-1,x
 sta ptr0hi
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 lda row1lo_a,x
 sta row1lo
 lda row1hi_a,x
 sta row1hi
 jmp sl_copy_setup
sl_bank_b:
 lda row0lo_b-1,x
 sta ptr0lo
 lda row0hi_b-1,x
 sta ptr0hi
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
 lda row1lo_b,x
 sta row1lo
 lda row1hi_b,x
 sta row1hi
sl_copy_setup:
 lda #CAMERA_VIEWPORT_CELL_WIDTH
 sta sl_bytes
 ldy #0
sl_copy_byte:
 lda (ptr0lo),y
 sta (row0lo),y
 sta (row1lo),y
 dec sl_bytes
 beq sl_next_gap
 clc
 lda ptr0lo
 adc #8
 sta ptr0lo
 bcc sl_copy_src_ready
 inc ptr0hi
sl_copy_src_ready:
 clc
 lda row0lo
 adc #8
 sta row0lo
 bcc sl_copy_dst0_ready
 inc row0hi
sl_copy_dst0_ready:
 clc
 lda row1lo
 adc #8
 sta row1lo
 bcc sl_copy_dst1_ready
 inc row1hi
sl_copy_dst1_ready:
 jmp sl_copy_byte
sl_next_gap:
 inc sl_gap
 inc sl_gap
 lda sl_gap
 cmp #PROJ_SCREEN_MAX_Y+1
 bcc sl_gap_loop
 rts
.cerror CAMERA_VIEWPORT_HEIGHT != PROJ_SCREEN_MAX_Y+1,"Fast viewport row extent changed"
.cerror CAMERA_VIEWPORT_HEIGHT & 3 != 0,"Fast viewport must consist of complete color cells"
.cerror (CAMERA_VIEWPORT_ORIGIN_Y*2) & 7 != 0,"Fast duplicate must share upper row color cell"
'''


def neutral():
    # No fused demo kernel is required. Only public scalar C entry points.
    return '''sg_prepare:
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
 beq sg_neutral
 sta sg_mode
 lda #$60
 sta m3_composite
 sta m3_advance_q
 lda #$ea
 sta m3_composite+1
 sta m3_composite+2
sg_neutral:
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
 beq sg_original
 sta sg_mode
 lda #$8d
 sta m3_composite
 lda #<m3_base
 sta m3_composite+1
 lda #>m3_base
 sta m3_composite+2
 lda #$18
 sta m3_advance_q
 lda #$ad
 sta m3_advance_q+1
 lda #<m3_qcur
 sta m3_advance_q+2
sg_original:
 sec
 lda rightval
 jmp m3_prepare_span+3
'''


def apply(source,parts):
    assert 'm3_q0:' in source and 'perspective_uv_pair' in parts
    if 'pu_texel:' not in parts['data']:parts['data']+='pu_texel: .byte 0\n'
    # The original exact paired sample remains the tail and seed oracle.
    p=once(parts['perspective_sample'],'ps_sample:\n','bk_exact_sample:\n')
    # The paired divider already handles both channels in the narrow domain.
    # Its fallback retains the general exact divider; omit the duplicate
    # narrow scalar implementation to fund the fast profile's camera budget.
    a=p.index('ps_uv_divide:\n');b=p.index('ps_uv_fallback:\n',a)
    p=p[:a]+'ps_uv_divide:\n'+p[b:]
    parts['perspective_sample']=p+sampler()
    p=once(parts['perspective_span'],'ps_prepare_span:\n','ps_prepare_span:\n lda #0\n sta bk_count\n sta bk_ready\n')
    a=p.index('ps_setup:\n');head=p[:a]
    end=head.rindex(' rts\n')
    head=head[:end]+' jsr bk_setup_carriers\n'+head[end:]
    p=head+p[a:]
    a=p.index('ps_advance:\n');b=p.index(' inc gouraud_scan_x\n rts\n',a)
    # Preserve X ABI and Q advancement; uniform path never consumes block state.
    p=p[:b]+' stx bk_saved_x\n jsr bk_advance_uv\n ldx bk_saved_x\n'+p[b:]
    parts['perspective_span']=p
    parts['fast_carriers']=carriers()
    e=parts['poly_draw']
    e=once(e,'tq_row_loop:\n ; ceil((integer-Q2 + remainder/dy)/4), including exact fractional ties.\n lda tq_cur0\n','tq_row_loop:\n jsr we_prepare_steps\nwe_geometry_row:\n ; Full one-row geometry; attributes are advanced only at even rows.\n lda tq_cur0\n')
    e=once(e,' sta leftb,x\n lda tq_cur0+1\n',' sta leftb,x\n txa\n and #1\n bne tq_right\n lda tq_cur0+1\n')
    e=once(e,' sta tq_closed,x\n lda tq_cur0+1\n',' sta tq_closed,x\n txa\n and #1\n bne tq_next_row\n lda tq_cur0+1\n')
    a=e.index(' ldx #0\ntq_advance:\n');b=e.index('tq_edge_done:\n',a)
    e=e[:a]+''' ldx #0
 jsr we_advance_one
 lda tq_row
 and #1
 beq we_attributes_ready
 ldx #1
we_advance_attributes:
 jsr we_advance_one
 inx
 cpx #5
 bne we_advance_attributes
we_attributes_ready:
 jmp we_geometry_row
'''+e[b:]
    parts['poly_draw']=e
    parts['fast_edge_one']=edge_one()
    parts['fast_edge_prime']=edge_prime()
    source=once(source,'gfb_row:\n lda leftb,x\n','gfb_row:\n jmp sl_filter_row\nsl_retained:\n')
    source=once(source,'pp_frame_valid:\n','pp_frame_valid:\n jsr sl_duplicate\n')
    source=once(source,'m3_prepare_span:\n sec\n lda rightval\n','m3_prepare_span:\n jmp sg_prepare\n')
    parts['fast_filter']=row_filter()
    parts['fast_duplicate']=duplicate()
    parts['fast_neutral']=neutral()
    # Only even logical rows produce/consume these eight private arrays.
    # Interleave pairs at offsets 0/1: an even row index reaches disjoint bytes
    # without shifts in the edge/span kernels. 800 -> 400 bytes at height 100.
    # Geometric bounds, palettes and original shade arrays remain full-height.
    for side in ('left','right'):
        for a,b in (('s_hi','v_hi'),('w_lo','w_hi')):
            first='ps_'+side+a;second='ps_'+side+b
            parts['data']=once(parts['data'],second+': .fill VIEWPORT_ROW_CAPACITY,0\n',
                               second+' = '+first+'+1\n')
    for side in ('left','right'):
        source=once(source,'m7_'+side+'v: .fill VIEWPORT_ROW_CAPACITY,0\n',
                    'm7_'+side+'v = '+side+'shade+1\n')
    source=once(source,'m3_rightq: .fill VIEWPORT_ROW_CAPACITY,0\n',
                'm3_rightq = m3_leftq+1\n')
    parts['data']+='''bk_count: .byte 0
bk_ready: .byte 0
bk_saved_x: .byte 0
bk_sign: .byte 0
bk_cur0: .fill 2,0
bk_cur1: .fill 2,0
bk_next: .fill 2,0
bk_step0: .fill 2,0
bk_step1: .fill 2,0
bk_look0: .fill 3,0
bk_look1: .fill 3,0
bk_future: .word 0
bk_step8lo: .fill 3,0
bk_step8hi: .fill 3,0
bk_rem8: .fill 3,0
sl_gap: .byte 0
sl_bytes: .byte 0
sg_mode: .byte 255
'''
    # Keep the existing guarded packing units. Six additional 32-byte guards
    # otherwise consume the last free space of even the public cube profile.
    # Entry points remain independent; merging does not alter instructions.
    for helper,owner in (('fast_carriers','perspective_span'),
                         ('fast_edge_one','poly_draw'),
                         ('fast_edge_prime','poly_draw'),
                         ('fast_filter','perspective_sample'),
                         ('fast_duplicate','texture_helpers'),
                         ('fast_neutral','perspective_product')):
        parts[owner]+=parts.pop(helper)
    parts['data']+=parts.pop('perspective_state')
    # Small, already separated camera/trig placement units can share a guard.
    for helper,owner in (('camera_trig_y','trig'),('camera_trig_z','trig'),
                         ('camera_demo','core')):
        if helper in parts:parts[owner]+=parts.pop(helper)
    return source,parts
