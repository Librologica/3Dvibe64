; Camera Q16.8 -> screen Q16.8; retain exact Q2 + signed residual caches.
hc_project_vertices:
 lda #0
 sta hp_idx
hc_pv_loop:
 ldx hp_idx
 jsr hc_load_vertex_point
 jsr hc_depth_inside
 lda #0
 rol
 ldx hp_idx
 sta projdone,x
 cmp #0
 beq hc_pv_behind
 lda hc_cam_x0,x
 sta hc_coord
 lda hc_cam_x1,x
 sta hc_coord+1
 lda hc_cam_x2,x
 sta hc_coord+2
 lda #0
 sta hc_axis
 jsr hc_project_axis
 ldy hp_idx
 lda hc_q
 sta sxq2_lo,y
 lda hc_q+1
 sta sxq2_hi,y
 lda hq_residue
 sta hq_sx_fraction,y
 lda hc_integer
 sta pxrawlo,y
 lda hc_integer+1
 sta pxrawhi,y
 jsr hc_clamp_integer
 ldy hp_idx
 sta sx,y
 ldx hp_idx
 lda hc_cam_y0,x
 sta hc_coord
 lda hc_cam_y1,x
 sta hc_coord+1
 lda hc_cam_y2,x
 sta hc_coord+2
 lda #1
 sta hc_axis
 jsr hc_project_axis
 ldy hp_idx
 lda hc_q
 sta syq2_lo,y
 lda hc_q+1
 sta syq2_hi,y
 lda hq_residue
 sta hq_sy_fraction,y
 lda hc_integer
 sta pyrawlo,y
 lda hc_integer+1
 sta pyrawhi,y
 jsr hc_clamp_integer
 ldy hp_idx
 sta sy,y
 jmp hc_pv_next
hc_pv_behind:
 ; These are never consumed by Q8 near clipping; clear stale screen caches.
 lda #0
 sta sx,x
 sta sy,x
 sta sxq2_lo,x
 sta sxq2_hi,x
 sta syq2_lo,x
 sta syq2_hi,x
 sta hq_sx_fraction,x
 sta hq_sy_fraction,x
hc_pv_next:
 inc hp_idx
 lda hp_idx
 cmp #VERT_COUNT
 bne hc_pv_loop
 rts
hc_depth_inside:
 lda hc_depth+2
 bmi hc_depth_no
 bne hc_depth_yes
 lda hc_depth+1
 cmp #CAMERA_FACE_MIN_DEPTH
 rts
hc_depth_yes:
 sec
 rts
hc_depth_no:
 clc
 rts

; |signed24 coordinate| * (170*256) => unsigned48 / positive24 depth.
hc_project_axis:
 lda hc_coord+2
 sta hc_sign
 bpl hc_coord_abs
 sec
 lda #0
 sbc hc_coord
 sta hc_coord
 lda #0
 sbc hc_coord+1
 sta hc_coord+1
 lda #0
 sbc hc_coord+2
 sta hc_coord+2
hc_coord_abs:
 ldx #5
 lda #0
hc_num_clear:
 sta hc_num,x
 sta hc_shift,x
 dex
 bpl hc_num_clear
 ldx #2
hc_copy_coord:
 lda hc_coord,x
 sta hc_shift,x
 lda hc_depth,x
 sta hc_divisor,x
 dex
 bpl hc_copy_coord
 ; Constant multiply, preserving eight fractional bits through screen clipping.
 lda #<43520
 sta hc_value
 lda #>43520
 sta hc_value+1
hc_project_mul_loop:
 lsr hc_value+1
 ror hc_value
 bcc hc_project_mul_shift
 clc
 lda hc_num
 adc hc_shift
 sta hc_num
 lda hc_num+1
 adc hc_shift+1
 sta hc_num+1
 lda hc_num+2
 adc hc_shift+2
 sta hc_num+2
 lda hc_num+3
 adc hc_shift+3
 sta hc_num+3
 lda hc_num+4
 adc hc_shift+4
 sta hc_num+4
 lda hc_num+5
 adc hc_shift+5
 sta hc_num+5
hc_project_mul_shift:
 asl hc_shift
 rol hc_shift+1
 rol hc_shift+2
 rol hc_shift+3
 rol hc_shift+4
 rol hc_shift+5
 lda hc_value
 ora hc_value+1
 bne hc_project_mul_loop
 jsr hc_div40
 lda hc_num
 and #63
 sta hq_residue
 ldx #6
hq_projection_to_q2:
 lsr hc_num+5
 ror hc_num+4
 ror hc_num+3
 ror hc_num+2
 ror hc_num+1
 ror hc_num
 dex
 bne hq_projection_to_q2
 ; Saturate only remote, wholly offscreen projected points. Small mesh diameter
 ; guarantees contributing front vertices fit this range; tests check this.
 lda hc_num+4
 ora hc_num+5
 ora hc_num+3
 ora hc_num+2
 bne hc_q_saturate
 lda hc_num+1
 cmp #$3e
 bcc hc_q_magnitude
hc_q_saturate:
 lda #0
 sta hq_residue
 lda #$3d
 sta hc_num+1
 lda #$ff
 sta hc_num
hc_q_magnitude:
 lda hc_axis
 beq hc_q_sign
 lda hc_sign
 eor #$80
 sta hc_sign
hc_q_sign:
 lda hc_num
 sta hc_q
 lda hc_num+1
 sta hc_q+1
 lda hc_sign
 bpl hc_q_center
 sec
 lda #0
 sbc hq_residue
 sta hq_residue
 sec
 lda #0
 sbc hc_q
 sta hc_q
 lda #0
 sbc hc_q+1
 sta hc_q+1
hc_q_center:
 ldx hc_axis
 clc
 lda hc_q
 adc hc_center_lo,x
 sta hc_q
 lda hc_q+1
 adc hc_center_hi,x
 sta hc_q+1
 ; Keep approved integer anchors: center + trunc(signed offset/4).
 lsr hc_num+1
 ror hc_num
 lsr hc_num+1
 ror hc_num
 lda hc_sign
 bpl hc_integer_center
 sec
 lda #0
 sbc hc_num
 sta hc_num
 lda #0
 sbc hc_num+1
 sta hc_num+1
hc_integer_center:
 clc
 lda hc_num
 adc hc_centers,x
 sta hc_integer
 lda hc_num+1
 adc #0
 sta hc_integer+1
 rts
hc_centers: .byte PROJ_CENTER_X,PROJ_CENTER_Y
hc_center_lo: .byte <(PROJ_CENTER_X*4),<(PROJ_CENTER_Y*4)
hc_center_hi: .byte >(PROJ_CENTER_X*4),>(PROJ_CENTER_Y*4)
hc_limits: .byte PROJ_SCREEN_MAX_X,PROJ_SCREEN_MAX_Y
hc_clamp_integer:
 lda hc_integer+1
 bmi hc_integer_zero
 bne hc_integer_limit
 ldx hc_axis
 lda hc_integer
 cmp hc_limits,x
 bcc hc_integer_done
hc_integer_limit:
 ldx hc_axis
 lda hc_limits,x
 rts
hc_integer_zero:
 lda #0
hc_integer_done:
 rts

; Restoring unsigned 48/24 (historical ABI name retained).
; Remainder needs 25 bits: keep fourth byte. All callers initialize all 6 bytes.
hc_div40:
 lda hc_divisor
 ora hc_divisor+1
 ora hc_divisor+2
 beq hp_unreachable
 lda #0
 ldx #3
hc_div_clear:
 sta hc_remainder,x
 dex
 bpl hc_div_clear
 ldy #48
hc_div_loop:
 asl hc_num
 rol hc_num+1
 rol hc_num+2
 rol hc_num+3
 rol hc_num+4
 rol hc_num+5
 rol hc_remainder
 rol hc_remainder+1
 rol hc_remainder+2
 rol hc_remainder+3
 lda hc_remainder+3
 bne hc_div_sub
 lda hc_remainder+2
 cmp hc_divisor+2
 bcc hc_div_next
 bne hc_div_sub
 lda hc_remainder+1
 cmp hc_divisor+1
 bcc hc_div_next
 bne hc_div_sub
 lda hc_remainder
 cmp hc_divisor
 bcc hc_div_next
hc_div_sub:
 sec
 lda hc_remainder
 sbc hc_divisor
 sta hc_remainder
 lda hc_remainder+1
 sbc hc_divisor+1
 sta hc_remainder+1
 lda hc_remainder+2
 sbc hc_divisor+2
 sta hc_remainder+2
 lda hc_remainder+3
 sbc #0
 sta hc_remainder+3
 inc hc_num
hc_div_next:
 dey
 bne hc_div_loop
 rts

; trunc(delta_s16 * factor_u15 / den_u15), 0 <= factor <= denominator.
hc_ratio_product:
 lda hc_delta
 sta hp_a
 lda hc_delta+1
 sta hp_a+1
 lda hc_factor
 sta hp_b
 lda hc_factor+1
 sta hp_b+1
 jsr hp_mul
 ldx #3
hc_ratio_num:
 lda hp_p,x
 sta hc_num,x
 dex
 bpl hc_ratio_num
 lda #0
 sta hc_num+4
 sta hc_num+5
 sta hc_divisor+2
 lda hc_den
 sta hc_divisor
 lda hc_den+1
 sta hc_divisor+1
 jsr hc_div40
 lda hc_num
 sta hc_result
 lda hc_num+1
 sta hc_result+1
 lda hp_sign
 bpl hc_ratio_done
 sec
 lda #0
 sbc hc_result
 sta hc_result
 lda #0
 sbc hc_result+1
 sta hc_result+1
hc_ratio_done:
 rts
