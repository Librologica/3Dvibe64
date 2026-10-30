; Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
; SPHERE BLOCK project
er_sphere_draw_camera:
 jsr er_sphere_project
 bcc er_sphere_project_return
 jmp er_circle_draw
er_sphere_project:
 lda #0
 sta er_sphere_valid
 lda er_sphere_camera_z+1
 bmi er_sphere_near
 bne er_sphere_depth_ready
 lda er_sphere_camera_z
 cmp #(CAMERA_FACE_MIN_DEPTH*16)
 bcc er_sphere_near
er_sphere_depth_ready:
 lda er_sphere_radius+1
 cmp #64
 bcs er_sphere_invalid
 ora er_sphere_radius
 beq er_sphere_invalid
 jsr er_sphere_radius_project
 bcc er_sphere_project_return
 lda er_sphere_camera_z
 sta clip_a_vzlo
 lda er_sphere_camera_z+1
 sta clip_a_vzhi
 lda er_sphere_camera_x
 sta clip_a_vxlo
 lda er_sphere_camera_x+1
 sta clip_a_vxhi
 lda er_sphere_camera_y
 sta clip_a_vylo
 lda er_sphere_camera_y+1
 sta clip_a_vyhi
 ldx #0
 jsr clip_project_a_x_from_camera
 lda mul16sign
 sta er_sphere_negative
 lda clip_a_xlo
 sta er_sphere_integer
 lda clip_a_xhi
 sta er_sphere_integer+1
 jsr er_sphere_axis_q2
 bcc er_sphere_project_return
 lda er_sphere_integer
 sta er_circle_xq2
 lda er_sphere_integer+1
 sta er_circle_xq2+1
 ldx #0
 jsr clip_project_a_y_from_camera
 lda mul16sign
 eor #128
 sta er_sphere_negative
 lda clip_a_ylo
 sta er_sphere_integer
 lda clip_a_yhi
 sta er_sphere_integer+1
 jsr er_sphere_axis_q2
 bcc er_sphere_project_return
 lda er_sphere_integer
 sta er_circle_yq2
 lda er_sphere_integer+1
 sta er_circle_yq2+1
 lda #1
 sta er_sphere_valid
 lda #0
 sta er_sphere_status
 sec
er_sphere_project_return:
 rts
er_sphere_near:
 lda #1
 bne er_sphere_fail
er_sphere_invalid:
 lda #2
 bne er_sphere_fail
er_sphere_oversize:
 lda #3
 bne er_sphere_fail
er_sphere_subpixel:
 lda #4
 bne er_sphere_fail
er_sphere_offscreen:
 lda #5
er_sphere_fail:
 sta er_sphere_status
 clc
 rts

er_sphere_axis_q2:
 lda #0
 sta er_sphere_fraction
 ldx #3
er_sphere_fraction_bit:
 asl crosslo
 rol crosshi
 sec
 lda crosslo
 sbc p1lo
 tay
 lda crosshi
 sbc p1hi
 bcc er_sphere_fraction_skip
 sty crosslo
 sta crosshi
er_sphere_fraction_skip:
 rol er_sphere_fraction
 dex
 bne er_sphere_fraction_bit
 lda er_sphere_fraction
 clc
 adc #1
 lsr
 sta er_sphere_fraction
 beq er_sphere_refined
 ldx er_sphere_negative
 bmi er_sphere_refine_negative
 cmp #4
 bne er_sphere_refined
 lda #0
 sta er_sphere_fraction
 inc er_sphere_integer
 bne er_sphere_refined
 inc er_sphere_integer+1
 jmp er_sphere_refined
er_sphere_refine_negative:
 lda #4
 sec
 sbc er_sphere_fraction
 sta er_sphere_fraction
 lda er_sphere_integer
 bne +
 dec er_sphere_integer+1
+ dec er_sphere_integer
er_sphere_refined:
 lda er_sphere_integer+1
 beq er_sphere_axis_ready
 cmp #255
 bne er_sphere_offscreen
 lda er_sphere_integer
 cmp #192
 bcc er_sphere_offscreen
er_sphere_axis_ready:
 asl er_sphere_integer
 rol er_sphere_integer+1
 asl er_sphere_integer
 rol er_sphere_integer+1
 clc
 lda er_sphere_integer
 adc er_sphere_fraction
 sta er_sphere_integer
 bcc +
 inc er_sphere_integer+1
+ sec
 rts

; Compute24bit (radiusQ4 * focal *4), then divide by full native depthQ4.
er_sphere_radius_project:
 lda er_sphere_radius
 sta er_sphere_multiplier
 lda er_sphere_radius+1
 sta er_sphere_multiplier+1
 lda #<(PROJ_FOCAL*4)
 sta er_sphere_factor
 lda #>(PROJ_FOCAL*4)
 sta er_sphere_factor+1
 lda #0
 sta er_sphere_factor+2
 sta er_sphere_numerator
 sta er_sphere_numerator+1
 sta er_sphere_numerator+2
 ldx #14
er_sphere_mul_loop:
 lsr er_sphere_multiplier+1
 ror er_sphere_multiplier
 bcc er_sphere_mul_next
 clc
 lda er_sphere_numerator
 adc er_sphere_factor
 sta er_sphere_numerator
 lda er_sphere_numerator+1
 adc er_sphere_factor+1
 sta er_sphere_numerator+1
 lda er_sphere_numerator+2
 adc er_sphere_factor+2
 sta er_sphere_numerator+2
er_sphere_mul_next:
 asl er_sphere_factor
 rol er_sphere_factor+1
 rol er_sphere_factor+2
 dex
 bne er_sphere_mul_loop
 lda #0
 sta er_sphere_remainder
 sta er_sphere_remainder+1
 ldx #24
er_sphere_div_loop:
 asl er_sphere_numerator
 rol er_sphere_numerator+1
 rol er_sphere_numerator+2
 rol er_sphere_remainder
 rol er_sphere_remainder+1
 bcs er_sphere_div_subtract
 lda er_sphere_remainder+1
 cmp er_sphere_camera_z+1
 bcc er_sphere_div_next
 bne er_sphere_div_subtract
 lda er_sphere_remainder
 cmp er_sphere_camera_z
 bcc er_sphere_div_next
er_sphere_div_subtract:
 sec
 lda er_sphere_remainder
 sbc er_sphere_camera_z
 sta er_sphere_remainder
 lda er_sphere_remainder+1
 sbc er_sphere_camera_z+1
 sta er_sphere_remainder+1
 inc er_sphere_numerator
er_sphere_div_next:
 dex
 bne er_sphere_div_loop
 lda er_sphere_numerator+1
 ora er_sphere_numerator+2
 bne er_sphere_oversize
 asl er_sphere_remainder
 rol er_sphere_remainder+1
 bcs er_sphere_radius_round
 lda er_sphere_remainder+1
 cmp er_sphere_camera_z+1
 bcc er_sphere_radius_rounded
 bne er_sphere_radius_round
 lda er_sphere_remainder
 cmp er_sphere_camera_z
 bcc er_sphere_radius_rounded
er_sphere_radius_round:
 inc er_sphere_numerator
 beq er_sphere_oversize
er_sphere_radius_rounded:
 lda er_sphere_numerator
 cmp er_sphere_min_radius_q2
 bcs +
 lda er_sphere_min_radius_q2
+ cmp #(ER_SPHERE_MAX_RADIUS_Q2+1)
 bcs er_sphere_oversize
 sta er_circle_radius_q2
 cmp #0
 beq er_sphere_subpixel
 sec
 rts

er_sphere_camera_x: .word 0
er_sphere_camera_y: .word 0
er_sphere_camera_z: .word 0
er_sphere_depth_q4 = er_sphere_camera_z
er_sphere_radius: .word 16
er_sphere_min_radius_q2: .byte 0
er_sphere_status: .byte 0
er_sphere_valid: .byte 0
er_sphere_negative: .byte 0
er_sphere_integer: .word 0
er_sphere_fraction: .byte 0
er_sphere_multiplier: .word 0
er_sphere_factor: .fill 3,0
er_sphere_numerator: .fill 3,0
er_sphere_remainder: .word 0

; SPHERE BLOCK raster
; Native material_screen_cur/material_color_cur/fillbyte/drawbuf are inputs.
er_circle_draw:
 lda #0
 sta er_circle_drawn
 lda er_circle_radius_q2
 beq er_sphere_subpixel
 cmp #(ER_SPHERE_MAX_RADIUS_Q2+1)
 bcs er_sphere_oversize
 lda er_circle_xq2+1
 cmp #4
 bcc +
 cmp #255
 bne er_sphere_offscreen
+ lda er_circle_yq2+1
 cmp #4
 bcc +
 cmp #255
 bne er_sphere_offscreen
+ sec
 lda er_circle_yq2
 sbc er_circle_radius_q2
 sta er_circle_tmp
 lda er_circle_yq2+1
 sbc #0
 sta er_circle_tmp+1
 clc
 lda er_circle_tmp
 adc #3
 sta er_circle_tmp
 bcc +
 inc er_circle_tmp+1
+ jsr er_circle_floor4
 lda er_circle_tmp+1
 bmi er_circle_first_zero
 bne er_sphere_offscreen
 lda er_circle_tmp
 cmp #100
 bcs er_sphere_offscreen
 bcc er_circle_first_ready
er_circle_first_zero:
 lda #0
er_circle_first_ready:
 sta er_circle_row
 clc
 lda er_circle_yq2
 adc er_circle_radius_q2
 sta er_circle_tmp
 lda er_circle_yq2+1
 adc #0
 sta er_circle_tmp+1
 jsr er_circle_floor4
 lda er_circle_tmp+1
 bmi er_circle_empty
 bne er_circle_last_max
 lda er_circle_tmp
 cmp #100
 bcc er_circle_last_ready
er_circle_last_max:
 lda #99
er_circle_last_ready:
 sta er_circle_last
 cmp er_circle_row
 bcc er_circle_empty
 ldx er_circle_radius_q2
 sec
 lda er_circle_square_lo,x
 sbc #1
 sta er_circle_r2
 lda er_circle_square_hi,x
 sbc #0
 sta er_circle_r2+1
 stx er_circle_cap
 stx er_circle_extent
 lda er_circle_trim_tips
 beq er_circle_row_loop
 lda er_circle_yq2
 and #3
 sta er_circle_tmp
 lda #4
 sec
 sbc er_circle_tmp
 cmp er_circle_tmp
 bcs +
 lda er_circle_tmp
+ tax
 sec
 lda er_circle_r2
 sbc er_circle_square_lo,x
 sta er_circle_f
 lda er_circle_r2+1
 sbc er_circle_square_hi,x
 sta er_circle_f+1
 bcc er_circle_tiny
 jsr er_circle_sqrt
 lda er_circle_extent
 sta er_circle_cap
er_circle_row_loop:
 lda #0
 sta er_circle_tmp+1
 lda er_circle_row
 sta er_circle_tmp
 asl er_circle_tmp
 rol er_circle_tmp+1
 asl er_circle_tmp
 rol er_circle_tmp+1
 sec
 lda er_circle_tmp
 sbc er_circle_yq2
 sta er_circle_tmp
 lda er_circle_tmp+1
 sbc er_circle_yq2+1
 sta er_circle_tmp+1
 bpl er_circle_abs_ready
 sec
 lda #0
 sbc er_circle_tmp
 sta er_circle_tmp
 lda #0
 sbc er_circle_tmp+1
 sta er_circle_tmp+1
er_circle_abs_ready:
 lda er_circle_tmp+1
 bne er_circle_next
 ldx er_circle_tmp
 cpx er_circle_radius_q2
 bcs er_circle_next
 sec
 lda er_circle_r2
 sbc er_circle_square_lo,x
 sta er_circle_f
 lda er_circle_r2+1
 sbc er_circle_square_hi,x
 sta er_circle_f+1
 jsr er_circle_sqrt
 lda er_circle_extent
 cmp er_circle_cap
 bcc +
 lda er_circle_cap
+ sta er_circle_span_extent
 sec
 lda er_circle_xq2
 sbc er_circle_span_extent
 sta er_circle_tmp
 lda er_circle_xq2+1
 sbc #0
 sta er_circle_tmp+1
 clc
 lda er_circle_tmp
 adc #3
 sta er_circle_tmp
 bcc +
 inc er_circle_tmp+1
+ jsr er_circle_floor4
 lda er_circle_tmp
 sta er_circle_left
 lda er_circle_tmp+1
 sta er_circle_left+1
 clc
 lda er_circle_xq2
 adc er_circle_span_extent
 sta er_circle_tmp
 lda er_circle_xq2+1
 adc #0
 sta er_circle_tmp+1
 jsr er_circle_floor4
 lda er_circle_trim_tips
 beq er_circle_clip_span
 lda er_circle_tmp
 cmp er_circle_left
 bne er_circle_clip_span
 lda er_circle_tmp+1
 cmp er_circle_left+1
 beq er_circle_next
er_circle_clip_span:
 lda er_circle_tmp+1
 bmi er_circle_next
 bne er_circle_right_max
 lda er_circle_tmp
 cmp #160
 bcc er_circle_right_ready
er_circle_right_max:
 lda #159
er_circle_right_ready:
 sta er_circle_right
 lda er_circle_left+1
 bmi er_circle_left_zero
 bne er_circle_next
 lda er_circle_left
 cmp #160
 bcs er_circle_next
 bcc er_circle_left_ready
er_circle_left_zero:
 lda #0
er_circle_left_ready:
 cmp er_circle_right
 bcc er_circle_span_ready
 beq er_circle_span_ready
 bcs er_circle_next
er_circle_span_ready:
 sta er_circle_left
 jsr er_circle_fill_row
er_circle_next:
 lda er_circle_row
 cmp er_circle_last
 beq er_circle_finish
 inc er_circle_row
 jmp er_circle_row_loop
er_circle_finish:
 lda er_circle_drawn
 bne er_circle_success
er_circle_empty:
 lda er_circle_radius_q2
 cmp #6
 bcs er_sphere_offscreen
er_circle_tiny:
 clc
 lda er_circle_xq2
 adc #2
 sta er_circle_tmp
 lda er_circle_xq2+1
 adc #0
 sta er_circle_tmp+1
 jsr er_circle_floor4
 lda er_circle_tmp+1
 bne er_sphere_offscreen
 lda er_circle_tmp
 cmp #160
 bcs er_sphere_offscreen
 sta er_circle_left
 sta er_circle_right
 clc
 lda er_circle_yq2
 adc #2
 sta er_circle_tmp
 lda er_circle_yq2+1
 adc #0
 sta er_circle_tmp+1
 jsr er_circle_floor4
 lda er_circle_tmp+1
 bne er_sphere_offscreen
 lda er_circle_tmp
 cmp #100
 bcs er_sphere_offscreen
 sta er_circle_row
 jsr er_circle_fill_row
er_circle_success:
 lda #0
 sta er_sphere_status
 sec
 rts
er_circle_fill_row:
 ldx er_circle_row
 stx face_ymin
 stx face_ymax
 lda er_circle_left
 sta leftb,x
 lda er_circle_right
 sta rightb,x
 lda drawbuf
 bne er_circle_fill_b
 jsr fill_bounds_solid_a
 jmp er_circle_filled
er_circle_fill_b:
 jsr fill_bounds_solid_b
er_circle_filled:
 inc er_circle_drawn
 rts
er_circle_floor4:
 lda er_circle_tmp+1
 cmp #128
 ror er_circle_tmp+1
 ror er_circle_tmp
 lda er_circle_tmp+1
 cmp #128
 ror er_circle_tmp+1
 ror er_circle_tmp
 rts

er_circle_xq2: .word 320
er_circle_yq2: .word 200
er_sphere_screen_xq2 = er_circle_xq2
er_sphere_screen_yq2 = er_circle_yq2
er_circle_radius_q2: .byte 4
er_circle_trim_tips: .byte 1
er_circle_tmp: .word 0
er_circle_r2: .word 0
er_circle_f: .word 0
er_circle_row: .byte 0
er_circle_last: .byte 0
er_circle_drawn: .byte 0
er_circle_extent: .byte 0
er_circle_cap: .byte 0
er_circle_span_extent: .byte 0
er_circle_left: .word 0
er_circle_right: .byte 0

; SPHERE BLOCK sqrt
er_circle_sqrt:
 ldx er_circle_extent
er_circle_sqrt_reduce:
 lda er_circle_f+1
 cmp er_circle_square_hi,x
 bcc er_circle_sqrt_down
 bne er_circle_sqrt_grow
 lda er_circle_f
 cmp er_circle_square_lo,x
 bcs er_circle_sqrt_grow
er_circle_sqrt_down:
 dex
 jmp er_circle_sqrt_reduce
er_circle_sqrt_grow:
 inx
 lda er_circle_f+1
 cmp er_circle_square_hi,x
 bcc er_circle_sqrt_ready
 bne er_circle_sqrt_grow
 lda er_circle_f
 cmp er_circle_square_lo,x
 bcs er_circle_sqrt_grow
er_circle_sqrt_ready:
 dex
 stx er_circle_extent
 rts
