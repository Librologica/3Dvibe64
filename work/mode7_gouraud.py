"""M3-only textured Gouraud; M1/M2 emitters remain byte-identical when disabled.

Keep the validated Mode 6 builder's shade topology, independent of corner UV.
The third affine attribute uses exactly the Mode 7 edge ownership and clip t.
All new storage/code lives in the existing middle segment (no layout changes).
"""
import re
from pathlib import Path


def emit_gouraud(s, carrier, compositor='A'):
    from mode7 import replace_once, between
    # Restore only the live lighting data, extracted from the unchanged
    # Mode 6 topology generator with the user's creaseAngle (default 60).
    names = ['gouraud_normal_'+a for a in 'xyz'] + [
        'gouraud_center_dot_lo', 'gouraud_center_dot_hi', 'gouraud_shade_value',
        'object_runtime_shade_first', 'object_runtime_shade_end'] + [
        'gouraud_face_shade'+str(i) for i in range(3)]
    data = '\nm3_metadata_begin = *\n'
    for name in names:
        pat = r'(?m)^'+name+r':(?: \.byte[^\n]*\n|\n(?: \.byte[^\n]*\n)+)'
        block = re.search(pat, carrier)
        if block is None:
            raise ValueError('Missing M3 shade metadata: '+name)
        data += block[0]
    data += 'm3_metadata_end = *\n'
    # M2 flat caches and quantizer preparation are not needed in M3.
    s = between(s, 'm2_update_face_lighting:\n', 'm2_update_face_lighting_end = *', '')
    s = between(s, 'm2_prepare_face:\n', 'm2_prepare_face_end = *', '')
    s = between(s, 'm2_composite:\n', 'm2_composite_end = *', '')
    for name in ['m2_face_source', 'm2_face_shade', 'm2_threshold', 'm2_base',
                 'm2_face', 'm2_halfshade']:
        s, n = re.subn(r'(?m)^'+name+r':(?:[^\n]+\n|\n(?: \.byte[^\n]*\n)+)', '', s)
        if n != 1:
            raise ValueError('M3 removal anchor: '+name)
    s = s.replace(' jsr m2_update_face_lighting\n',' jsr m3_update_shades\n')
    load = 'gouraud_load_face_raw_shades_y:\n'
    s = replace_once(s, load+' jsr m2_prepare_face\n', load+''.join(
        f' ldx gouraud_face_shade{i},y\n lda gouraud_shade_value,x\n sta m3_q{i}\n'
        for i in range(3)))
    # Duplicate V-only transfers including swaps, clipping fans, compaction.
    attrs = {'m7_v'+str(i): 'm3_q'+str(i) for i in range(4)}
    attrs.update({f'm7_clip_{part}_v':f'm3_clip_{part}_q' for part in ('a','b')})
    attrs.update({f'm7_clip_v_{part}':f'm3_clip_q_{part}' for part in ('in','out','result')})
    keys = '|'.join(sorted(attrs,key=len,reverse=True))
    operand = r'(?:\+\d+)?(?:,[xy])?'
    pattern = r'(?m)^ lda ('+keys+r')'+operand+r'\n(?: (?:ldx|ldy) [^\n]+\n)?(?: sta (?:'+keys+r')'+operand+r'\n)+'
    def clone(m):
        return re.sub(r'\b('+keys+r')\b',lambda n:attrs[n[0]],m[0])+m[0]
    s, count = re.subn(pattern, clone, s)
    if count < 15:
        raise ValueError('M3 missing Q clip/copy paths')
    # Interpolate Q first; preserve A=U and the unchanged V result contract.
    clip = '''gouraud_interp_clip_shade:
 jsr m3_interp_clip_q
'''
    s = replace_once(s, 'gouraud_interp_clip_shade:\n',clip)
    # Clone the fully corrected V walker: identical X DDA, no ownership change.
    a=s.index('gouraud_build_edge_shades_v:\n')
    b=s.index('\n; Mode 7 affine Q4.4.',a)
    edge=s[a:b]
    for old,new in attrs.items():
        edge=re.sub(r'\b'+old+r'\b',new,edge)
    edge=edge.replace('m7_leftv','m3_leftq').replace('m7_rightv','m3_rightq')
    for label in sorted(re.findall(r'(?m)^(\w+):',edge),key=len,reverse=True):
        edge=re.sub(r'\b'+label+r'\b',label+'_q',edge)
    s=s.replace(' jsr gouraud_build_edge_shades_v\n',
                ' jsr gouraud_build_edge_shades_v\n jsr gouraud_build_edge_shades_v_q\n')
    s=replace_once(s,'m7_prepare_span:\n','m7_prepare_span:\n jsr m3_prepare_span\n')
    s=replace_once(s,'m7_uv_done:\n','m7_uv_done:\n jsr m3_advance_q\n')
    s=s.replace(' jmp m2_composite\n',' jmp m3_composite\n')
    data += 'm3_buffers_begin = *\n'
    data += 'm3_leftq: .fill VIEWPORT_ROW_CAPACITY,0\nm3_rightq: .fill VIEWPORT_ROW_CAPACITY,0\n'
    data += 'm3_clip_a_q: .fill 12,0\nm3_clip_b_q: .fill 12,0\n'
    for name in ['q0','q1','q2','q3','clip_q_in','clip_q_out','clip_q_result',
                 'qcur','qstep','qrem','qdir','qerr','texel','threshold','base']:
        data += 'm3_'+name+': .byte 0\n'
    data += 'm3_buffers_end = *\n'
    code=Path(__file__).with_name('mode7-gouraud.asm').read_text()
    if compositor != 'A':
        alternative=Path(__file__).with_name('mode7-compositor-'+compositor.lower()+'.asm').read_text()
        code=between(code, 'm3_composite:\n', 'm3_composite_end = *', alternative.rstrip()+'\n')
    # M3 light-vector products can reach +128 (e.g. -128 * -64 / 64).
    # The shared mul_s6 returns one byte, so clamp a sign overflow BEFORE
    # add_s8_sat interprets the product. Leave shared geometry math and M2 alone.
    a=s.index('prepare_object_light_for_shade:\n')
    b=s.index('\n rts\n',a)
    light=s[a:b]
    if light.count(' jsr mul_s6\n') != 9:
        raise ValueError('LightFix requires nine object-light matrix products')
    s=s[:a]+light.replace(' jsr mul_s6\n',' jsr m31_light_mul_s6\n')+s[b:]
    code += '''
; Saturated signed-byte result for A=-128..127, X=-64..64 (Q6 matrix).
; mulsign retains the mathematical sign, including a result truncated to zero.
m31_light_mul_s6:
 jsr mul_s6
 bit mulsign
 bmi m31_light_mul_negative
 cmp #$80
 bcc m31_light_mul_done
 lda #$7f
 rts
m31_light_mul_negative:
 cmp #$80
 bcs m31_light_mul_done
 cmp #0
 beq m31_light_mul_done
 lda #$80
m31_light_mul_done:
 rts
m31_light_mul_s6_end = *
'''
    # The middle entry is not executed by fall-through. Keep all additions
    # before its end marker so the existing builder bounds check covers them.
    s=replace_once(s,'mode3_high_basic_middle_end = *\n',
        '\nm3_code_begin = *\n'+code+'\n'+edge+'\nm3_code_end = *\n'+data+
        'mode3_high_basic_middle_end = *\n')
    # Fixed-camera projection tables already overflow high for the M2 torus.
    # Keep the existing four segment windows. In M3 fixed only, place the
    # unchanged six corner-UV arrays in spare low RAM (absolute label users).
    # No texture layout, UV format, sampling code or M1/M2 allocation changes.
    if re.search(r'(?m)^CAMERA_MOVABLE = \$00$', s):
        uvdata = '\nm3_fixed_uv_begin = *\n'
        for axis in 'uv':
            for i in range(3):
                name=f'm7_face_{axis}{i}'
                pat=r'(?m)^'+name+r':\n(?: \.byte[^\n]*\n)+'
                block=re.search(pat,s)
                if block is None:raise ValueError('Missing fixed UV array: '+name)
                uvdata += block[0]
                s=s[:block.start()]+s[block.end():]
        uvdata += 'm3_fixed_uv_end = *\n'
        s=replace_once(s,'init_video_standard:\n',uvdata+'init_video_standard:\n')
    if compositor == 'C':
        from mode7_raster import accurate_edges
        s = accurate_edges(s)
        from mode7_layout import recover_layout
        s = recover_layout(s)
    return s
