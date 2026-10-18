"""Bounded ordinary legacy camera: 12-bit phase, Q10 rotation coefficients.

Object transforms stay Q6, temporary camera coordinates stay Q4. No Q8 or
normalized backend is selected or edited.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import math,re

def once(source,old,new):
    if source.count(old)!=1:raise ValueError('Rotation hook not unique: '+repr(old[:100]))
    return source.replace(old,new,1)

def apply(source):
    for name,value in [('CAMERA_WALK_LITE',1),('MEMORY_LAYOUT_HIGH_BASIC_V2',1),('EXPLORER_MATRIX_FOLD',0),
                       ('ENGINE_CAMERA_WALK_LITE_PITCH_RUNTIME_ACTIVE',1),('CAMERA_ROLL_ACTIVE',0)]:
        if not re.search(r'(?m)^'+name+fr' = \${value:02X}$',source):raise ValueError('Rotation profile requires '+name+'='+str(value))
    source=once(source,'render_frame_begin:\n','render_frame_begin:\n jsr lr_prepare\n')
    begin=source.index('\nexplorer_transform_project_vertices:\n')+1;end=source.index('\nrotate_project_vertices:\n',begin)
    code=source[begin:end]
    for name,index in [('cosyv',0),('sinyv',1),('cosxv',2),('sinxv',3)]:
        hook=' lda '+name+'\n jsr mul_s16_s6\n'
        if code.count(hook)not in (2,4):raise ValueError('Unexpected camera coefficient uses '+name)
        code=code.replace(hook,f' ldx #{index}\n jsr lr_mul_s16_q10\n')
    code=once(code,' lda explorer_cam_pitch\n bne etpv_engine_walk_pitch_apply\n',
              ' lda explorer_cam_pitch\n ora explorer_cam_pitch_frac\n bne etpv_engine_walk_pitch_apply\n')
    source=source[:begin]+code+source[end:]
    helper='''
lr_helpers_begin:
; Public phase: old high byte + top four bits of the new fractional byte.
; Setter A=low phase byte, Y=old high phase byte; lower four bits ignored.
legacy_camera_set_yaw_phase:
 and #$f0
 sta explorer_cam_yaw_frac
 sty explorer_cam_yaw
 rts
legacy_camera_set_pitch_phase:
 and #$f0
 sta explorer_cam_pitch_frac
 sty explorer_cam_pitch
 rts

lr_prepare:
 lda explorer_cam_yaw_frac
 and #$f0
 sta lr_phase_lo
 lda explorer_cam_yaw
 sta lr_phase_hi
 jsr lr_negate_phase
 jsr lr_interp
 lda p1lo
 sta lr_coeff_lo+1
 lda p1hi
 sta lr_coeff_hi+1
 clc
 lda lr_phase_hi
 adc #64
 sta lr_phase_hi
 jsr lr_interp
 lda p1lo
 sta lr_coeff_lo
 lda p1hi
 sta lr_coeff_hi
 lda explorer_cam_pitch_frac
 and #$f0
 sta lr_phase_lo
 lda explorer_cam_pitch
 sta lr_phase_hi
 jsr lr_negate_phase
 jsr lr_interp
 lda p1lo
 sta lr_coeff_lo+3
 lda p1hi
 sta lr_coeff_hi+3
 clc
 lda lr_phase_hi
 adc #64
 sta lr_phase_hi
 jsr lr_interp
 lda p1lo
 sta lr_coeff_lo+2
 lda p1hi
 sta lr_coeff_hi+2
 rts

lr_negate_phase:
 sec
 lda #0
 sbc lr_phase_lo
 sta lr_phase_lo
 lda #0
 sbc lr_phase_hi
 sta lr_phase_hi
 rts

lr_interp:
 lda lr_phase_lo
 lsr
 lsr
 lsr
 lsr
 sta lr_weight
 ldx lr_phase_hi
 lda lr_sin_lo,x
 sta lr_base_lo
 lda lr_sin_hi,x
 sta lr_base_hi
 inx
 sec
 lda lr_sin_lo,x
 sbc lr_base_lo
 tax
 lda lr_weight
 jsr mul_s8_16
 ; Adjacent Q10 sine samples differ by at most26; product fits signed16.
 clc
 lda prodlo
 adc #8
 sta prodlo
 lda prodhi
 adc #0
 sta prodhi
 ldx #4
lr_interp_shift:
 lda prodhi
 cmp #$80
 ror prodhi
 ror prodlo
 dex
 bne lr_interp_shift
 clc
 lda prodlo
 adc lr_base_lo
 sta p1lo
 lda prodhi
 adc lr_base_hi
 sta p1hi
 rts

; Input p1 signed16 Q4, X selects Q10 coefficient. Rounded signed16 Q4 out.
; Simple independent serial product is the first measured rotation change.
lr_mul_s16_q10:
 stx lr_mul_index
 lda #0
 sta lr_mul_sign
 lda p1hi
 bpl lr_mul_coord_positive
 lda #$80
 sta lr_mul_sign
 sec
 lda #0
 sbc p1lo
 sta p1lo
 lda #0
 sbc p1hi
 sta p1hi
lr_mul_coord_positive:
 lda p1lo
 sta lr_value
 lda p1hi
 sta lr_value+1
 lda #0
 sta lr_value+2
 sta lr_value+3
 ldx lr_mul_index
 lda lr_coeff_lo,x
 sta lr_multiplier
 lda lr_coeff_hi,x
 sta lr_multiplier+1
 bpl lr_mul_coefficient_positive
 lda lr_mul_sign
 eor #$80
 sta lr_mul_sign
 sec
 lda #0
 sbc lr_multiplier
 sta lr_multiplier
 lda #0
 sbc lr_multiplier+1
 sta lr_multiplier+1
lr_mul_coefficient_positive:
 lda #0
 sta lr_product
 sta lr_product+1
 sta lr_product+2
 sta lr_product+3
 ldx #11
lr_mul_loop:
 lsr lr_multiplier+1
 ror lr_multiplier
 bcc lr_mul_no_add
 clc
 lda lr_product
 adc lr_value
 sta lr_product
 lda lr_product+1
 adc lr_value+1
 sta lr_product+1
 lda lr_product+2
 adc lr_value+2
 sta lr_product+2
 lda lr_product+3
 adc lr_value+3
 sta lr_product+3
lr_mul_no_add:
 asl lr_value
 rol lr_value+1
 rol lr_value+2
 rol lr_value+3
 dex
 bne lr_mul_loop
 clc
 lda lr_product+1
 adc #2
 sta lr_product+1
 lda lr_product+2
 adc #0
 sta lr_product+2
 lda lr_product+3
 adc #0
 sta lr_product+3
 ; Discard eight low bits, then divide the remaining unsigned value by4.
 lsr lr_product+3
 ror lr_product+2
 ror lr_product+1
 lsr lr_product+3
 ror lr_product+2
 ror lr_product+1
 lda lr_product+1
 sta p1lo
 lda lr_product+2
 sta p1hi
 lda lr_mul_sign
 bpl lr_mul_done
 sec
 lda #0
 sbc p1lo
 sta p1lo
 lda #0
 sbc p1hi
 sta p1hi
lr_mul_done:
 rts

explorer_cam_yaw_frac: .byte 0
explorer_cam_pitch_frac: .byte 0
lr_phase_lo: .byte 0
lr_phase_hi: .byte 0
lr_weight: .byte 0
lr_base_lo: .byte 0
lr_base_hi: .byte 0
lr_coeff_lo: .fill 4,0
lr_coeff_hi: .fill 4,0
lr_mul_index: .byte 0
lr_mul_sign: .byte 0
lr_multiplier: .word 0
lr_value: .fill 4,0
lr_product: .fill 4,0
'''
    sine=[round(1024*math.sin(i*math.tau/256))for i in range(256)]
    for name,values in [('lr_sin_lo',[v&255 for v in sine]),('lr_sin_hi',[(v>>8)&255 for v in sine])]:
        helper+=name+':\n'
        for i in range(0,256,16):helper+=' .byte '+','.join(f'${v:02x}'for v in values[i:i+16])+'\n'
    result=source+helper+'lr_helpers_end:\n.cerror * > $d000,"Fine camera rotation helpers overlap IO"\n; LEGACY_ROTATION_PHASE_BITS=12\n'
    from legacy_rotation_products import apply as product_apply
    from legacy_rotation_terms import apply as terms_apply
    return terms_apply(product_apply(result))
