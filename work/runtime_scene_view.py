"""Optional shared lens/roll and conservative object bounds for LegacyPlus.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import math
from animated_mesh import replace_once, table, data
from legacy_plus_exact import block, constant
from runtime_support_native import multiply_code, frustum_code


def lens(source):
    # Undo only the proven fixed-focal specialization, retaining its original
    # general multiplication. Dynamic loads replace operands, never offsets.
    if '; LP12_FOCAL_BEGIN\n' in source:
        a = source.index('; LP12_FOCAL_BEGIN\n')
        b = source.index('; LP12_FOCAL_END\n', a)+len('; LP12_FOCAL_END\n')
        first = '.if 0 ; LP12_ORIGINAL_FOCAL\n'
        old = source[source.index(first, a)+len(first):source.index('.endif ; LP12_ORIGINAL_FOCAL', a)]
        source = source[:a]+old+source[b:]
    assert source.count(' lda #EXPLORER_PROJ_FOCAL\n') == 4
    assert source.count(' ldx #EXPLORER_PROJ_FOCAL\n') == 1
    assert source.count(' ldx #PROJ_FRUSTUM_FOCAL\n') == 4
    source = source.replace(' lda #EXPLORER_PROJ_FOCAL\n', ' lda rs_lens_focal\n')
    source = source.replace(' ldx #EXPLORER_PROJ_FOCAL\n', ' ldx rs_lens_focal\n')
    source = source.replace(' ldx #PROJ_FRUSTUM_FOCAL\n', ' ldx rs_lens_half\n')
    # Broad-phase admission must allow every supported wider lens. Near-screen
    # clipping above remains exact. These initial tests are deliberately loose.
    if 'ENGINE_CIRCLE_SPHERES = 1' in source:
        source = replace_once(source, ' lda #<(PROJ_FOCAL*4)\n', ' lda rs_lens_times4\n')
        source = replace_once(source, ' lda #>(PROJ_FOCAL*4)\n', ' lda rs_lens_times4+1\n')
    focal = constant(source, 'PROJ_FOCAL')
    source = replace_once(source, 'render_frame_begin:\n', 'render_frame_begin:\n jsr rs_lens_prepare\n')
    return source+block('scene_lens', f''' ; Set between views only. A=even focal64..254; C=1 accepted.
rs_lens_set:
 cmp #64
 bcc rs_lens_bad
 cmp #255
 bcs rs_lens_bad
 and #1
 bne rs_lens_bad
 ; Caller value is preserved in X by the public setter wrapper below.
 txa
 rts
rs_lens_bad:
 clc
 rts
rs_lens_prepare:
 lda rs_lens_focal
 lsr
 sta rs_lens_half
 lda rs_lens_focal
 sta rs_lens_times4
 lda #0
 sta rs_lens_times4+1
 asl rs_lens_times4
 rol rs_lens_times4+1
 asl rs_lens_times4
 rol rs_lens_times4+1
 rts
rs_lens_focal: .byte {focal}
rs_lens_half: .byte {focal//2}
rs_lens_times4: .word {focal*4}
'''.replace(' cmp #64\n', ' tax\n cmp #64\n', 1).replace(' txa\n rts\n',' txa\n sta rs_lens_focal\n jsr rs_lens_prepare\n sec\n rts\n',1))


def roll(source):
    # Independent multiplication protects camera product LUT validity. No
    # coefficient slots are borrowed from lr_coeff, even temporarily.
    source = replace_once(source, 'render_frame_begin:\n', 'render_frame_begin:\n jsr rs_view_prepare\n')
    for label in ('etpv_engine_walk_pitch_done', 'er_sphere_etpv_engine_walk_pitch_done'):
        anchor='\n'+label+':\n'
        if anchor in source:
            source = replace_once(source, anchor, anchor+' jsr rs_view_roll\n')
    code = '''rs_view_prepare:
 lda rs_view_bank
 and #$f0
 sta lr_phase_lo
 lda rs_view_bank+1
 sta lr_phase_hi
 jsr lr_negate_phase
 jsr lr_interp
 lda p1lo
 sta rs_view_sin
 lda p1hi
 sta rs_view_sin+1
 clc
 lda lr_phase_hi
 adc #64
 sta lr_phase_hi
 jsr lr_interp
 lda p1lo
 sta rs_view_cos
 lda p1hi
 sta rs_view_cos+1
 rts
rs_view_roll:
 lda rs_view_bank
 ora rs_view_bank+1
 bne +
 rts
+
 lda p1lo
 sta rs_view_z
 lda p1hi
 sta rs_view_z+1
 lda explorer_view_x_lo
 sta rs_view_x
 lda explorer_view_x_hi
 sta rs_view_x+1
 lda explorer_view_y_lo
 sta rs_view_y
 lda explorer_view_y_hi
 sta rs_view_y+1
'''
    for coord, coef, dest in [('x','cos','xc'),('y','sin','ys'),('x','sin','xs'),('y','cos','yc')]:
        for suffix in ('', '+1'):
            code += f' lda rs_view_{coord}{suffix}\n sta rs_view_value{suffix}\n lda rs_view_{coef}{suffix}\n sta rs_view_coef{suffix}\n'
        code += f' jsr rs_view_multiply\n lda rs_view_result\n sta rs_view_{dest}\n lda rs_view_result+1\n sta rs_view_{dest}+1\n'
    code += ''' sec
 lda rs_view_xc
 sbc rs_view_ys
 sta explorer_view_x_lo
 lda rs_view_xc+1
 sbc rs_view_ys+1
 sta explorer_view_x_hi
 clc
 lda rs_view_xs
 adc rs_view_yc
 sta explorer_view_y_lo
 lda rs_view_xs+1
 adc rs_view_yc+1
 sta explorer_view_y_hi
 lda rs_view_z
 sta p1lo
 lda rs_view_z+1
 sta p1hi
 rts
; Exact signed16 * signed Q10; nearest magnitude, ties away from zero.
rs_view_multiply:
 lda rs_view_value+1
 eor rs_view_coef+1
 sta rs_view_sign
 lda rs_view_value+1
 bpl +
 sec
 lda #0
 sbc rs_view_value
 sta rs_view_value
 lda #0
 sbc rs_view_value+1
 sta rs_view_value+1
+
 lda rs_view_coef+1
 bpl +
 sec
 lda #0
 sbc rs_view_coef
 sta rs_view_coef
 lda #0
 sbc rs_view_coef+1
 sta rs_view_coef+1
+
 lda #0
 sta rs_view_value+2
 sta rs_view_value+3
 ldx #3
rs_view_zero:
 sta rs_view_product,x
 dex
 bpl rs_view_zero
 ldx #11
rs_view_bit:
 lsr rs_view_coef+1
 ror rs_view_coef
 bcc rs_view_shift
 clc
'''
    for i in range(4):
        code += f' lda rs_view_product+{i}\n adc rs_view_value+{i}\n sta rs_view_product+{i}\n'
    code += '''rs_view_shift:
 asl rs_view_value
 rol rs_view_value+1
 rol rs_view_value+2
 rol rs_view_value+3
 dex
 bne rs_view_bit
 clc
 lda rs_view_product+1
 adc #2
 sta rs_view_product+1
 lda rs_view_product+2
 adc #0
 sta rs_view_product+2
 lda rs_view_product+3
 adc #0
 sta rs_view_product+3
 ldx #2
rs_view_divide:
 lsr rs_view_product+3
 ror rs_view_product+2
 ror rs_view_product+1
 dex
 bne rs_view_divide
 lda rs_view_product+1
 sta rs_view_result
 lda rs_view_product+2
 sta rs_view_result+1
 lda rs_view_sign
 bpl +
 sec
 lda #0
 sbc rs_view_result
 sta rs_view_result
 lda #0
 sbc rs_view_result+1
 sta rs_view_result+1
+
 rts
'''
    for name, size in [('bank',2),('sin',2),('cos',2),('z',2),('x',2),('y',2),('xc',2),('ys',2),('xs',2),('yc',2),('value',4),('coef',2),('result',2),('sign',1),('product',4)]:
        code += f'rs_view_{name}: .fill {size},0\n'
    return source+block('scene_view_roll', code)


def bounds(source, support):
    # Radius is compiler-owned per immutable mesh; the runtime scale remains
    # caller-owned. L1 bound +12.5%+3 units covers quantized object/view rotation.
    first,end=table(source,'mesh_vfirst'),table(source,'mesh_vend')
    coords=[table(source,a+'coord') for a in 'xyz']
    indices=[table(source,'vert_'+a+'i') for a in 'xyz']
    radii=[]
    for a,b in zip(first,end):
        magnitude=max(sum(abs((coords[k][indices[k][v]]+128)%256-128) for k in range(3)) for v in range(a,b))
        radii.append(math.ceil(magnitude*1.125+3)*16)
    source=replace_once(source,'resp_loop:\n','resp_loop:\n')
    start=source.index('resp_loop:\n');endloop=source.index('resp_next_object:',start)
    part=source[start:endloop]
    part=replace_once(part,' jsr set_active_object\n',' jsr set_active_object\n jsr rs_object_visible\n bcc resp_next_object\n')
    source=source[:start]+part+source[endloop:]
    # Current view transform copied directly, including optional roll.
    start=source.index(' lda explorer_rel_x_lo\n sta p1lo\n lda explorer_rel_x_hi\n sta p1hi\n ldx #0\n jsr lr_mul_s16_q10\n',source.index('explorer_transform_project_vertices:\n'))
    end=source.index('etpv_engine_walk_pitch_done:\n',start)+len('etpv_engine_walk_pitch_done:\n')
    if source[end:].startswith(' jsr rs_view_roll\n'):
        end += len(' jsr rs_view_roll\n')
    view=source[start:end]+'.endif\n'
    for label in ('etpv_engine_walk_pitch_apply','etpv_engine_walk_pitch_done'):
        view=view.replace(label,'rs_bound_'+label)
    code='rs_object_visible:\n'
    for axis,lo,hi in [('x','explorer_rel_x_lo','explorer_rel_x_hi'),('y','explorer_rel_y_lo','explorer_rel_y_hi'),('z','rz1','explorer_z_hi16')]:
        if axis in 'xy':
            code+=f''' lda #0
 sta rs_object_center_{axis}
 lda obj_pos_{axis}_cur
 sta rs_object_center_{axis}+1
 cmp #128
 lda #0
 bcc +
 lda #255
+
 sta rs_object_center_{axis}+2
'''
        source_lo=f'object_pos_{axis}_lo,x' if axis=='z' else f'rs_object_center_{axis}'
        source_hi=f'object_pos_{axis}_hi,x' if axis=='z' else f'rs_object_center_{axis}+1'
        source_ext=f'object_pos_{axis}_ext,x' if axis=='z' else f'rs_object_center_{axis}+2'
        code+=f''' ldx objidx
 sec
 lda {source_lo}
 sbc explorer_cam_{axis}_lo
 sta lc_fraction
 lda {source_hi}
 sbc explorer_cam_{axis}_hi
 sta p1lo
 lda {source_ext}
 sbc explorer_cam_{axis}_ext
 sta p1hi
 bvs rs_object_accept
 bmi rs_object_negative_{axis}
 cmp #4
 bcs rs_object_accept
 bcc rs_object_pack_{axis}
rs_object_negative_{axis}:
 cmp #$fc
 bcc rs_object_accept
rs_object_pack_{axis}:
 jsr lc_pack_q4
 lda p1lo
 sta {lo}
 lda p1hi
 sta {hi}
'''
    code+=view+''' lda p1lo
 sta rs_bound_center+4
 lda p1hi
 sta rs_bound_center+5
 lda explorer_view_x_lo
 sta rs_bound_center
 lda explorer_view_x_hi
 sta rs_bound_center+1
 lda explorer_view_y_lo
 sta rs_bound_center+2
 lda explorer_view_y_hi
 sta rs_bound_center+3
 ldx meshidx
 lda rs_mesh_radius_lo,x
 sta rs_mul_a
 lda rs_mesh_radius_hi,x
 sta rs_mul_a+1
 lda obj_scale_cur
 sta rs_mul_b
 jsr rs_mul_u16_u8
 ; ceil(radius * Q6scale /64).
 clc
 lda rs_mul_result
 adc #63
 sta rs_mul_result
 lda rs_mul_result+1
 adc #0
 sta rs_mul_result+1
 lda rs_mul_result+2
 adc #0
 sta rs_mul_result+2
 ldx #6
rs_object_radius_shift:
 lsr rs_mul_result+2
 ror rs_mul_result+1
 ror rs_mul_result
 dex
 bne rs_object_radius_shift
 ; Absolute rounding margin stays in world units even at tiny object scales.
 clc
 lda rs_mul_result
 adc #48
 sta rs_mul_result
 lda rs_mul_result+1
 adc #0
 sta rs_mul_result+1
 lda rs_mul_result+2
 adc #0
 sta rs_mul_result+2
 lda rs_mul_result+2
 bne rs_object_accept
 lda rs_mul_result
 sta rs_bound_radius
 lda rs_mul_result+1
 bmi rs_object_accept
 sta rs_bound_radius+1
'''
    if 'rs_lens_focal:' in source:
        code+=' lda rs_lens_focal\n sta rs_bound_focal\n'
    else:
        code+=' lda #PROJ_FOCAL\n sta rs_bound_focal\n'
    code+=' jmp rs_bounds_visible\nrs_object_accept:\n sec\n rts\nrs_object_center_x: .fill 3,0\nrs_object_center_y: .fill 3,0\n'
    code+=data('rs_mesh_radius_lo',[v&255 for v in radii])+data('rs_mesh_radius_hi',[v>>8 for v in radii])
    expected=dict(focal=constant(source,'PROJ_FOCAL'),nearQ4=constant(source,'PROJ_CAMERA_FACE_MIN_DEPTH')*16)
    if 'frustum' in support and any(support['frustum'].get(k,v)!=v for k,v in expected.items()):
        raise ValueError('RUNTIME_SCENE: objectBounds owns the native frustum contract')
    support['frustum']=expected
    return source+block('scene_object_bounds',code)
