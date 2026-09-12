"""M2 opt-in emitter. No changes to M1 when textureLighting is absent/none."""
from pathlib import Path
import re


def emit_flat_lighting(s, sources):
    from mode7 import replace_once, byte_table
    for flag in ('MODE4_OBJECT_LIGHT_CACHE', 'DYNAMIC_LIGHT'):
        if not re.search(r'(?m)^'+flag+r' = \$01$', s):
            raise ValueError('M2 requires existing dynamic object light infrastructure: '+flag)
    # The old light setup subtracts the low byte of object depth. For a
    # texture-only scene at z=200 and a light at z=10 this wraps -190 to +66,
    # reversing illumination. M2 alone uses a signed 16-bit displacement,
    # saturated to the existing signed-byte matrix domain, before rotation.
    a = s.index('prepare_object_light_for_shade:\n')
    b = s.index(' lda rx0\n ldx m00\n', a)
    vector = 'prepare_object_light_for_shade:\n'
    for axis, target, obj in [('x','rx0','obj_pos_x_cur'),('y','ry0','obj_pos_y_cur')]:
        vector += (f' ldx light_phase\n lda light_pos_{axis},x\n'
                   f'.if SCENE_OBJECT_{axis.upper()}_ACTIVE != 0\n'
                   f' ldx {obj}\n ldy #0\n cpx #128\n bcc m2_{axis}_positive\n dey\n'
                   f'm2_{axis}_positive:\n jsr m2_relative_s8\n.endif\n sta {target}\n')
    vector += (' ldx light_phase\n lda light_pos_z,x\n ldx obj_depth_lo\n'
               ' ldy obj_depth_hi\n jsr m2_relative_s8\n sta rz0\n\n')
    s = s[:a]+vector+s[b:]
    # Cache before culling/projection reuse the sh_n* zero page registers.
    hook = ' jsr prepare_object_light_for_shade\n'
    if not s.count(hook):
        raise ValueError('Missing object light setup')
    s = s.replace(hook, hook+' jsr m2_update_face_lighting\n')
    s = replace_once(s, 'gouraud_load_face_raw_shades_y:\n',
                     'gouraud_load_face_raw_shades_y:\n jsr m2_prepare_face\n')
    s = replace_once(s, 'm7_prepare_span:\n', 'm7_prepare_span:\n'
                     ' lda yrow\n and #3\n asl\n asl\n sta m2_bayer_row\n')
    s = replace_once(s, 'm7_fetch_end:\n rts\n',
                     'm7_fetch_end:\n jmp m2_composite\n')
    # New routines fit the existing low segment; the layout boundaries and
    # texture page alignment are unchanged. No new segment or relocation.
    code = Path(__file__).with_name('mode7-lighting.asm').read_text()
    # walkFull has a tighter low segment (especially small viewport). Keep
    # its 63-byte relative-vector helper in the EXISTING middle segment.
    # No segment boundaries/layout are changed; walkLite output is untouched.
    if re.search(r'(?m)^CAMERA_FULL_RUNTIME_ACTIVE = \$01$', s):
        a = code.index('m2_relative_s8:\n')
        b = code.index('m2_code_end = *', a)
        helper = code[a:b]+'m2_relative_s8_end = *\n'
        code = code[:a]+code[b:]
        anchor = 'mode3_high_basic_middle_start = *\n.endif\n.endif\n'
        s = replace_once(s, anchor, anchor+helper)
    s = replace_once(s, 'init_video_standard:\n', code+'\ninit_video_standard:\n')
    data = '\nm2_lighting_data_begin = *\n'
    data += byte_table('m2_face_source', sources)
    data += 'm2_face_shade: .fill FACE_COUNT,0\n'
    data += byte_table('m2_bayer', [1,9,3,11,13,5,15,7,4,12,2,10,16,8,14,6])
    data += 'm2_threshold: .fill 3,0\nm2_base: .fill 3,0\n'
    data += 'm2_face: .byte 0\nm2_halfshade: .byte 0\nm2_bayer_row: .byte 0\n'
    data += 'm2_lighting_data_end = *\n'
    # Place immediately before the existing texture alignment, not among UV
    # arrays or geometric buffers. Single texture and multi texture alike.
    s = replace_once(s, '.align 256\nm7_textures_begin = *\n',
                     data+'.align 256\nm7_textures_begin = *\n')
    return s
