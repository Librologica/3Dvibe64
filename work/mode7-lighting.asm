; M2: per-source-face point-light dot in the engine's object-space units.
; Q = clamp(floor(max(0, dot>>8) * intensity / 8), 0, 32).
; A quad's second triangle copies its representative, never its own normal.
m2_code_begin = *
m2_update_face_lighting:
 lda active_face_first
 sta m2_face
m2_light_loop:
 ldy m2_face
 lda m2_face_source,y
 cmp m2_face
 beq m2_light_compute
 tax
 lda m2_face_shade,x
 jmp m2_light_store
m2_light_compute:
 sty tmpidx
 lda #0
 sta dotlo
 sta dothi
 lda face_normal_x,y
 ldx sh_nx
 jsr mul_s8_16
 jsr add_dot_product
 ldy tmpidx
 lda face_normal_y,y
 ldx sh_ny
 jsr mul_s8_16
 jsr add_dot_product
 ldy tmpidx
 lda face_normal_z,y
 ldx sh_nz
 jsr mul_s8_16
 jsr add_dot_product
 jsr subtract_face_center_dot
 lda dothi
 bmi m2_light_dark
 ldx light_intensity
 jsr mul_s8_16
 lsr prodhi
 ror prodlo
 lsr prodhi
 ror prodlo
 lsr prodhi
 ror prodlo
 lda prodhi
 bne m2_light_max
 lda prodlo
 cmp #33
 bcc m2_light_store
m2_light_max:
 lda #32
 bne m2_light_store
m2_light_dark:
 lda #0
m2_light_store:
 ldy m2_face
 sta m2_face_shade,y
 inc m2_face
 lda m2_face
 cmp active_face_end
 bne m2_light_loop
 rts
m2_update_face_lighting_end = *

; E(texel,Q) = floor(Q/2) + 8*(texel-1), in [0,32].
; Contrasting local levels survive both extreme face lighting values.
; Prepare three quantizer bands and thresholds once per original face.
m2_prepare_face:
 tya
 pha
 lda m2_face_shade,y
 lsr
 sta m2_halfshade
 ldx #0
m2_prepare_loop:
 lda m2_halfshade
 ldy #1
 cmp #16
 bcc m2_prepare_store
 sec
 sbc #16
 iny
m2_prepare_store:
 sta m2_threshold,x
 tya
 sta m2_base,x
 clc
 lda m2_halfshade
 adc #8
 sta m2_halfshade
 inx
 cpx #3
 bne m2_prepare_loop
 pla
 tay
 rts
m2_prepare_face_end = *

; A=texel 1..3 -> A=opaque VIC-II pigment 1..3. No multiply/divide.
; Thresholds compare against Bayer 1..16 so carry adds the upper pigment.
; The original logical x/y anchor is shared by full and partial byte paths.
m2_composite:
 tax
 dex
m2_bayer_phase_begin:
 lda gouraud_scan_x
 and #3
 ora m2_bayer_row
 tay
m2_quantize_begin:
 lda m2_threshold,x
 cmp m2_bayer,y
 lda m2_base,x
 adc #0
 rts
m2_composite_end = *
; A=signed-byte light position, Y:X=signed-word object position.
; Return clamp(light-object,-128,127). Do not wrap a distant front light
; behind the mesh. p1/prod scratch is dead before the existing matrix code.
m2_relative_s8:
 sta p1lo
 stx p1hi
 sty prodlo
 ldx #0
 cmp #128
 bcc m2_relative_light_positive
 dex
m2_relative_light_positive:
 stx prodhi
 sec
 lda p1lo
 sbc p1hi
 sta p1lo
 lda prodhi
 sbc prodlo
 bvc m2_relative_no_overflow
 lda prodhi
 bmi m2_relative_min
 bpl m2_relative_max
m2_relative_no_overflow:
 beq m2_relative_positive
 bmi m2_relative_check_negative
 bpl m2_relative_max
m2_relative_check_negative:
 cmp #255
 beq m2_relative_negative
 jmp m2_relative_min
m2_relative_max:
 lda #127
 rts
m2_relative_min:
 lda #128
 rts
m2_relative_positive:
 lda p1lo
 bmi m2_relative_max
 rts
m2_relative_negative:
 lda p1lo
 bpl m2_relative_min
 rts
m2_code_end = *
