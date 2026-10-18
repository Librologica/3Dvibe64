"""M4 C-only allocation recovery. No runtime instructions or data values change.

Use existing low capacity; never widen a segment. Preserve low address bytes so
indexed accesses and relative branches retain their page-cross timing.
"""
import re


def recover_layout(s):
    from mode7 import replace_once
    if not re.search(r'(?m)^MEMORY_LAYOUT_HIGH_BASIC_V2 = \$01$', s):
        return s
    fixed = bool(re.search(r'(?m)^CAMERA_MOVABLE = \$00$', s))
    full = bool(re.search(r'(?m)^CAMERA_FULL_ENABLE = \$01$', s))
    normal = bool(re.search(r'(?m)^CAMERA_VIEWPORT_WIDTH = \$A0$', s))
    # Small walkFull already fits high and has less low capacity. Preserve it.
    if not (fixed or (full and normal)):
        return s
    reserve = '\n; M4: allocation only. Gaps are filled by original blocks below.\n'
    reserve += 'm4_low_recovery_begin = *\n'
    if fixed:
        reserve += ''' .fill (m4_camera_source - *) & $ff, 0
m4_camera_low = *
* = * + m4_camera_size
m4_camera_low_end = *
'''
        s = replace_once(s, 'camera_plane_classify_vertex:\n', '''m4_camera_source = *
.if m4_camera_source < $9000 || m4_camera_source >= $a000
 .error "M4 camera source is outside relocated segment"
.endif
* = m4_camera_low
camera_plane_classify_vertex:
''')
        pat = r'(?m)^camera_plane_cull_normal_z:\n(?: \.byte[^\n]*\n)+'
        m = re.search(pat, s)
        if m is None:
            raise ValueError('M4 requires camera-plane cull table boundary')
        end = '''m4_camera_size = * - m4_camera_low
.if * != m4_camera_low_end || m4_camera_low < $0801 || * > $2000
 .error "M4 camera block outside reserved low segment"
.endif
.if (m4_camera_low & $ff) != (m4_camera_source & $ff)
 .error "M4 camera relocation changes page offset"
.endif
* = m4_camera_source
; Retain remainder: subsequent code moves by an integral number of pages.
m4_camera_residue_begin = *
 .fill m4_camera_size & $ff, 0
m4_camera_residue_end = *
'''
        s = s[:m.end()] + end + s[m.end():]
    reserve += ''' .fill (m4_sq_source - *) & $ff, 0
m4_sq_low = *
* = * + 512
m4_sq_low_end = *
m4_low_recovery_end = *
.if m4_low_recovery_begin < $0801 || m4_low_recovery_end > $2000
 .error "M4 recovery overlaps bitmap B above low segment"
.endif
'''
    s = replace_once(s, 'mode3_high_basic_low_segment_end = *\n',
                     reserve + 'mode3_high_basic_low_segment_end = *\n')
    s = replace_once(s, 'sqlo:\n', '''m4_sq_source = *
.if m4_sq_source < $a000 || m4_sq_source + 512 > $d000
 .error "M4 square table source is outside high segment"
.endif
* = m4_sq_low
sqlo:
''')
    pat = r'(?m)^sqhi:\n(?: \.byte[^\n]*\n)+'
    m = re.search(pat, s)
    if m is None:
        raise ValueError('M4 requires square table boundary')
    end = '''m4_sq_data_end = *
.if m4_sq_data_end - m4_sq_low != 512 || m4_sq_data_end != m4_sq_low_end
 .error "M4 square tables do not match reserved 512 bytes"
.endif
.if (m4_sq_source & $ff) != (m4_sq_low & $ff)
 .error "M4 square table relocation changes page offset"
.endif
* = m4_sq_source
'''
    return s[:m.end()] + end + s[m.end():]
