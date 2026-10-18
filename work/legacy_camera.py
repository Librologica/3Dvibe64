"""Bounded Mode2 camera experiment: Q4 camera coordinates, Q6 legacy math.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
No Q8/normalized backend. Historical and dev1 corrected paths are unchanged.
"""
import re

def once(source,old,new):
    if source.count(old)!=1:raise ValueError('Camera hook not unique: '+repr(old[:80]))
    return source.replace(old,new,1)

def fast_product(source):
    """Exact native quarter-square product for the small unsigned quotient.

    The original signed16 Q6 routine already separates abs(value)/64 and
    its remainder. Replace only its eight-step quotient multiply when both
    positive operands fit signed8. Keep the original rounding/fallback.
    """
    begin=source.index('\nmul_s16_s6:\n')+1;end=source.index('\nexplorer_axis_to_byte:\n',begin)
    code=source[begin:end]
    code=once(code,' lda #$00\n sta mul16reslo\n sta mul16reshi\n', ''' lda mul16hi
 bne lc_product_serial
 lda mul16lo
 bmi lc_product_serial
 lda mul16abs
 bmi lc_product_serial
 tax
 lda mul16lo
 jsr mul_s8_16
 lda prodlo
 sta mul16reslo
 lda prodhi
 sta mul16reshi
 jmp lc_product_remainder
lc_product_serial:
 lda #$00
 sta mul16reslo
 sta mul16reshi
''')
    code=once(code,' lda mul16rem\n beq ms16_no_rem\n','lc_product_remainder:\n lda mul16rem\n beq ms16_no_rem\n')
    return source[:begin]+code+source[end:]

def apply(source):
    for constant in ('CAMERA_WALK_LITE','MEMORY_LAYOUT_HIGH_BASIC_V2'):
        if not re.search(r'(?m)^'+constant+r' = \$01$',source):raise ValueError('Camera experiment requires '+constant)
    if not re.search(r'(?m)^EXPLORER_MATRIX_FOLD = \$00$',source):raise ValueError('Camera experiment requires NoFold')
    # Preserve the fractional borrow rather than converting camera positions
    # to whole WU before rotation. The existing public position ABI stays 8.8.
    for axis in 'xy':
        begin=source.index('\nlegacy_world_sub_camera_'+axis+':\n')+1
        end=source.index('\n rts\n',begin)+len('\n rts\n')
        code=source[begin:end]
        code=once(code,f' lda #$80\n sbc explorer_cam_{axis}_lo\n',f' lda #$00\n sbc explorer_cam_{axis}_lo\n sta lc_fraction\n')
        code=once(code,' rts\n',f''' lda explorer_rel_{axis}_lo
 sta p1lo
 lda explorer_rel_{axis}_hi
 sta p1hi
 jsr lc_pack_q4
 lda p1lo
 sta explorer_rel_{axis}_lo
 lda p1hi
 sta explorer_rel_{axis}_hi
 rts
''')
        source=source[:begin]+code+source[end:]
    begin=source.index('\nexplorer_sub_cam_z16:\n')+1;end=source.index('\n rts\n',begin)+len('\n rts\n')
    code=source[begin:end]
    code=once(code,' lda #$80\n sbc explorer_cam_z_lo\n',' lda #$00\n sbc explorer_cam_z_lo\n sta lc_fraction\n')
    code=once(code,' rts\n',''' lda rz1
 sta p1lo
 lda explorer_z_hi16
 sta p1hi
 jsr lc_pack_q4
 lda p1lo
 sta rz1
 lda p1hi
 sta explorer_z_hi16
 rts
''')
    source=source[:begin]+code+source[end:]
    begin=source.index('\nexplorer_transform_project_vertices:\n')+1;end=source.index('\nrotate_project_vertices:\n',begin)
    code=source[begin:end]
    hook='.if EXPLORER_NEAR_POLY != 0 || CAMERA_PLANE_CLIP_PROFILE != 0\n ldy tmpidx\n lda explorer_view_x_lo\n'
    code=once(code,hook,' jsr lc_commit_q4\n'+hook)
    code=once(code,' jsr explorer_project_x16\n',' jsr lc_project_x\n')
    code=once(code,' jsr explorer_project_y16\n',' jsr lc_project_y\n')
    source=source[:begin]+code+source[end:]
    source=once(source,'explorer_project_axis_offset:\n','''explorer_project_axis_offset:
 lda lc_project_active
 beq lc_integer_projection
 jmp lc_project_offset
lc_integer_projection:
''')
    # Reuse the native exact-ratio fallback, with Q4 numerator AND divisor.
    # Large numerators are normalized as in the ordinary engine. Near-plane
    # intersections still use its integer raw geometry: this is a prototype.
    original=source[source.index('\nexplorer_project_axis_offset:\n')+1:source.index('\nexplorer_project_x16:\n')]
    absolute=original[original.index(' lda #$00\n sta mul16sign\n'):original.index(' jsr load_projection_table_index\n')]
    tail=original[original.index(' lda mul16hi\n beq epao_mul_start\n'):]
    projection='lc_project_offset:\n'+absolute+''' lda lc_qz
 sta p1lo
 lda lc_qz+1
 sta p1hi
 bmi lc_clamp_near
 bne lc_depth_ready
 lda p1lo
 cmp #(CAMERA_FACE_MIN_DEPTH * 16)
 bcs lc_depth_ready
lc_clamp_near:
 lda #(CAMERA_FACE_MIN_DEPTH * 16)
 sta p1lo
 lda #0
 sta p1hi
lc_depth_ready:
'''+tail
    projection=projection.replace('epao_','lc_ratio_')
    helpers='''
; Camera Q4 prototype. Appended at the ordinary engine's current end.
lc_helpers_begin:
lc_pack_q4:
 ; Bound each relative axis to [-1024,1024) WU, keeping every possible
 ; rotation inside signed16 Q4. Out-of-domain is an explicit runtime fault.
 lda p1hi
 bmi lc_pack_negative
 cmp #4
 bcc lc_pack_valid
 bcs lc_pack_fault
lc_pack_negative:
 cmp #$fc
 bcs lc_pack_valid
lc_pack_fault:
 lda #1
 sta legacy_camera_fault
 lda #0
 sta p1lo
 sta p1hi
 sta lc_fraction
lc_pack_valid:
 ldx #4
lc_pack_shift:
 asl p1lo
 rol p1hi
 dex
 bne lc_pack_shift
 lda lc_fraction
 lsr
 lsr
 lsr
 lsr
 ora p1lo
 sta p1lo
 rts

lc_round_q4:
 clc
 lda p1lo
 adc #8
 sta p1lo
 lda p1hi
 adc #0
 sta p1hi
 ldx #4
lc_round_shift:
 lda p1hi
 cmp #$80
 ror p1hi
 ror p1lo
 dex
 bne lc_round_shift
 rts

lc_commit_q4:
 lda p1lo
 sta lc_qz
 lda p1hi
 sta lc_qz+1
 jsr lc_round_q4
 lda p1lo
 sta lc_integer_z
 lda p1hi
 sta lc_integer_z+1
 lda explorer_view_x_lo
 sta lc_qx
 sta p1lo
 lda explorer_view_x_hi
 sta lc_qx+1
 sta p1hi
 jsr lc_round_q4
 lda p1lo
 sta explorer_view_x_lo
 lda p1hi
 sta explorer_view_x_hi
 lda explorer_view_y_lo
 sta lc_qy
 sta p1lo
 lda explorer_view_y_hi
 sta lc_qy+1
 sta p1hi
 jsr lc_round_q4
 lda p1lo
 sta explorer_view_y_lo
 lda p1hi
 sta explorer_view_y_hi
 lda lc_integer_z
 sta p1lo
 lda lc_integer_z+1
 sta p1hi
 rts

lc_project_x:
 lda lc_qx
 sta p1lo
 lda lc_qx+1
 sta p1hi
 lda #1
 sta lc_project_active
 jsr explorer_project_x16
 lda #0
 sta lc_project_active
 rts
lc_project_y:
 lda lc_qy
 sta p1lo
 lda lc_qy+1
 sta p1hi
 lda #1
 sta lc_project_active
 jsr explorer_project_y16
 lda #0
 sta lc_project_active
 rts
'''+projection+'''
lc_fraction: .byte 0
lc_qx: .word 0
lc_qy: .word 0
lc_qz: .word 0
lc_integer_z: .word 0
lc_project_active: .byte 0
legacy_camera_fault: .byte 0
lc_helpers_end:
.cerror * > $d000,"Camera helpers overlap IO; bounded experiment does not fit this scene"
; LEGACY_CAMERA_Q4=1
'''
    return fast_product(source)+helpers
