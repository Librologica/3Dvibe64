; Copyright 2026 librologica.digital. PolyForm Noncommercial 1.0.0.
; Bounded Mode 6 core template: runtime Q8 matrix, Q8 coordinates,
; Q2 perspective endpoints. No zero-page allocation, no SMC, no IRQ state.
; Original transform is retained as whole-object fallback. All new temporary
; results are validated before committing any legacy rasterizer buffer.
; src/emit.py validates the profile, augments camera-extension checks/cache
; commits and allocates blocks in measured free gaps. No hardcoded cube data.
hp_code_start:
explorer_transform_project_vertices:
 lda #0
 sta hp_used
 jsr hp_origins
 bcc hp_fallback_return
 jsr hp_prepare_matrix
 jsr hp_prepare_terms
 jsr hp_build_vertices
 jsr hp_project_all
 bcc hp_fallback_return
 jsr hp_commit
 lda #1
 sta hp_used
 rts
hp_fallback_return:
 inc hp_fallback
 jmp hp_legacy_transform_project_vertices

hp_origins:
 ; No change of camera projection or runtime camera mode is silently accepted.
 lda explorer_cam_yaw
 ora explorer_cam_pitch
 bne hp_origin_fail
 lda object_scale
 cmp #45
 bne hp_origin_fail
 sec
 lda object_pos_x_lo
 sbc explorer_cam_x_lo
 sta hp_origin_x
 lda object_pos_x_hi
 sbc explorer_cam_x_hi
 sta hp_origin_x+1
 jsr hp_check_origin_axis
 bcc hp_origin_fail
 sec
 lda object_pos_y_lo
 sbc explorer_cam_y_lo
 sta hp_origin_y
 lda object_pos_y_hi
 sbc explorer_cam_y_hi
 sta hp_origin_y+1
 jsr hp_check_origin_axis
 bcc hp_origin_fail
 sec
 lda object_pos_z_lo
 sbc explorer_cam_z_lo
 sta hp_origin_z
 lda object_pos_z_hi
 sbc explorer_cam_z_hi
 sta hp_origin_z+1
 lda object_pos_z_ext
 sbc explorer_cam_z_ext
 bne hp_origin_fail
 lda hp_origin_z+1
 cmp #128
 bcc hp_origin_fail
 cmp #193
 bcs hp_origin_fail
 sec
 rts
hp_origin_fail:
 clc
 rts
hp_check_origin_axis:
 cmp #9
 bcc hp_origin_axis_ok
 cmp #248
 bcc hp_origin_fail
hp_origin_axis_ok:
 sec
 rts

; Signed 16x16 -> unsigned magnitude in hp_p[4], hp_sign records sign.
; Inputs are destroyed. Variable length (zero multiplier is cheap).
hp_mul:
 lda hp_a+1
 eor hp_b+1
 sta hp_sign
 lda hp_a+1
 bpl hp_mul_a_positive
 sec
 lda #0
 sbc hp_a
 sta hp_a
 lda #0
 sbc hp_a+1
 sta hp_a+1
hp_mul_a_positive:
 lda hp_b+1
 bpl hp_mul_b_positive
 sec
 lda #0
 sbc hp_b
 sta hp_b
 lda #0
 sbc hp_b+1
 sta hp_b+1
hp_mul_b_positive:
 lda hp_a
 sta hp_shift
 lda hp_a+1
 sta hp_shift+1
 lda #0
 sta hp_shift+2
 sta hp_shift+3
 sta hp_p
 sta hp_p+1
 sta hp_p+2
 sta hp_p+3
hp_mul_loop:
 lda hp_b
 ora hp_b+1
 beq hp_mul_done
 lsr hp_b+1
 ror hp_b
 bcc hp_mul_shift
 clc
 lda hp_p
 adc hp_shift
 sta hp_p
 lda hp_p+1
 adc hp_shift+1
 sta hp_p+1
 lda hp_p+2
 adc hp_shift+2
 sta hp_p+2
 lda hp_p+3
 adc hp_shift+3
 sta hp_p+3
hp_mul_shift:
 asl hp_shift
 rol hp_shift+1
 rol hp_shift+2
 rol hp_shift+3
 jmp hp_mul_loop
hp_mul_done:
 rts
hp_q8:
 jsr hp_mul
 clc
 lda hp_p
 adc #128
 lda hp_p+1
 adc #0
 sta hp_r
 lda hp_p+2
 adc #0
 sta hp_r+1
 jmp hp_apply_sign
hp_int_product:
 jsr hp_mul
 lda hp_p
 sta hp_r
 lda hp_p+1
 sta hp_r+1
hp_apply_sign:
 lda hp_sign
 bpl hp_sign_done
 sec
 lda #0
 sbc hp_r
 sta hp_r
 lda #0
 sbc hp_r+1
 sta hp_r+1
hp_sign_done:
 rts

; Linear interpolation of signed Q8 sine using the full 16-bit angle phase.
; Trig delta magnitude <=7. Symmetric nearest rounding, ties away from zero.
hp_sine:
 stx hp_sine_index
 lda hp_sin_lo,x
 sta hp_base
 lda hp_sin_hi,x
 sta hp_base+1
 inx
 sec
 lda hp_sin_lo,x
 sbc hp_base
 sta hp_a
 lda hp_sin_hi,x
 sbc hp_base+1
 sta hp_a+1
 lda hp_fraction
 sta hp_b
 lda #0
 sta hp_b+1
 jsr hp_q8
 clc
 lda hp_r
 adc hp_base
 sta hp_r
 lda hp_r+1
 adc hp_base+1
 sta hp_r+1
 rts

; Unsigned numerator hp_p[0..2] / hp_den[0..1], 24 iterations.
; The seventeenth remainder bit is handled BEFORE comparing/subtracting.
; Quotient replaces numerator, remainder remains available for tests.
hp_div24:
 lda #0
 sta hp_rem
 sta hp_rem+1
 ldx #24
hp_div_loop:
 asl hp_p
 rol hp_p+1
 rol hp_p+2
 rol hp_rem
 rol hp_rem+1
 bcs hp_div_sub
 lda hp_rem+1
 cmp hp_den+1
 bcc hp_div_next
 bne hp_div_sub
 lda hp_rem
 cmp hp_den
 bcc hp_div_next
hp_div_sub:
 sec
 lda hp_rem
 sbc hp_den
 sta hp_rem
 lda hp_rem+1
 sbc hp_den+1
 sta hp_rem+1
 inc hp_p
hp_div_next:
 dex
 bne hp_div_loop
 rts

hp_project_all:
 lda #0
 sta hp_idx
hp_project_vertex:
 lda hp_idx
 asl
 tax
 lda hp_vz,x
 sta hp_den
 lda hp_vz+1,x
 sta hp_den+1
 cmp #CAMERA_FACE_MIN_DEPTH
 bcc hp_projection_fail
 lda #0
 sta hp_axis
 lda hp_vx,x
 sta hp_a
 lda hp_vx+1,x
 sta hp_a+1
 jsr hp_project_axis
 bcc hp_projection_fail
 lda hp_idx
 asl
 tax
 lda hp_projection
 sta hp_px,x
 lda hp_projection+1
 sta hp_px+1,x
 lda hp_integer
 sta hp_ix,x
 lda hp_integer+1
 sta hp_ix+1,x
 lda #1
 sta hp_axis
 lda hp_vy,x
 sta hp_a
 lda hp_vy+1,x
 sta hp_a+1
 jsr hp_project_axis
 bcc hp_projection_fail
 lda hp_idx
 asl
 tax
 lda hp_projection
 sta hp_py,x
 lda hp_projection+1
 sta hp_py+1,x
 lda hp_integer
 sta hp_iy,x
 lda hp_integer+1
 sta hp_iy+1,x
 inc hp_idx
 lda hp_idx
 cmp #8
 bne hp_project_vertex
 sec
 rts
hp_projection_fail:
 clc
 rts

hp_project_axis:
 lda #<(PROJ_FOCAL*4)
 sta hp_b
 lda #>(PROJ_FOCAL*4)
 sta hp_b+1
 jsr hp_mul
 lda hp_p+3
 bne hp_projection_fail
 jsr hp_div24
 lda hp_p+2
 bne hp_projection_fail
 lda hp_axis
 beq hp_project_sign_ready
 lda hp_sign
 eor #$80
 sta hp_sign
hp_project_sign_ready:
 lda hp_p
 sta hp_r
 lda hp_p+1
 sta hp_r+1
 jsr hp_apply_sign
 lda hp_axis
 beq hp_project_x_center
 lda #<(PROJ_CENTER_Y*4)
 ldy #>(PROJ_CENTER_Y*4)
 jmp hp_project_add_center
hp_project_x_center:
 lda #<(PROJ_CENTER_X*4)
 ldy #>(PROJ_CENTER_X*4)
hp_project_add_center:
 clc
 adc hp_r
 sta hp_projection
 tya
 adc hp_r+1
 sta hp_projection+1
 bmi hp_projection_fail
 ldx hp_axis
 cmp hp_limit_hi,x
 bcc hp_project_inside
 bne hp_projection_fail
 lda hp_projection
 cmp hp_limit_lo,x
 bcs hp_projection_fail
hp_project_inside:
 ; Integer/raw anchors use signed truncation of offset, not absolute floor.
 lsr hp_p+1
 ror hp_p
 lsr hp_p+1
 ror hp_p
 lda hp_p
 sta hp_r
 lda hp_p+1
 sta hp_r+1
 jsr hp_apply_sign
 ldx hp_axis
 clc
 lda hp_center,x
 adc hp_r
 sta hp_integer
 lda #0
 adc hp_r+1
 sta hp_integer+1
 sec
 rts
hp_limit_lo: .byte <(PROJ_SCREEN_MAX_X*4+1),<(PROJ_SCREEN_MAX_Y*4+1)
hp_limit_hi: .byte >(PROJ_SCREEN_MAX_X*4+1),>(PROJ_SCREEN_MAX_Y*4+1)
hp_center: .byte PROJ_CENTER_X,PROJ_CENTER_Y

hp_commit:
 ldy #0
 ldx #0
hp_commit_loop:
 lda hp_px,x
 sta sxq2_lo,y
 lda hp_px+1,x
 sta sxq2_hi,y
 lda hp_py,x
 sta syq2_lo,y
 lda hp_py+1,x
 sta syq2_hi,y
 lda hp_ix,x
 sta sx,y
 sta pxrawlo,y
 lda hp_ix+1,x
 sta pxrawhi,y
 lda hp_iy,x
 sta sy,y
 sta pyrawlo,y
 lda hp_iy+1,x
 sta pyrawhi,y
 ; Legacy sorting/culling caches remain integer WU. Q8 buffers retained above.
 lda hp_vx+1,x
 sta rxbuf,y
 lda hp_vy+1,x
 sta rybuf,y
 lda hp_vz+1,x
 sta sz,y
 lda #0
 sta szhi,y
 lda #1
 sta projdone,y
 inx
 inx
 iny
 cpy #8
 bne hp_commit_loop
 rts

hp_template_end:
