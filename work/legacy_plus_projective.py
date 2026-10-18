"""Projective textures on ordinary plus Q4 geometry, never Q8 geometry.

Encode after near8: W=floor(524288/Z_Q4), UW=floor(U_Q4.4*W/128).
Screen clipping transports UW,VW,W together. The shared integer texture DDA
and nearest sampler consume integer legacy-plus screen points converted to
Q2 solely for raster coverage. No Q8 transform/project/clip kernel is used.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import argparse,re,sys
from pathlib import Path

def once(s,a,b):
    assert s.count(a)==1,(a[:90],s.count(a))
    return s.replace(a,b,1)

def bridge():
    s='''
lpp_encode_polygon:
 lda lpp_encoded
 bne lpp_encode_done
 lda clip_a_count
 beq lpp_encode_done
 lda #0
 sta lpp_index
lpp_encode_loop:
 ldx lpp_index
 lda clip_a_vzlo,x
 sta ps_den
 lda clip_a_vzhi,x
 sta ps_den+1
 bmi lpp_bad_depth
 cmp #$10
 bcc lpp_near_check
 bne lpp_bad_depth
 lda ps_den
 bne lpp_bad_depth
lpp_near_check:
 lda ps_den+1
 bne lpp_depth_ok
 lda ps_den
 cmp #128
 bcs lpp_depth_ok
lpp_bad_depth:
 inc ps_fault
 lda #128
 sta ps_den
 lda #0
 sta ps_den+1
lpp_depth_ok:
 lda #0
 sta ps_num
 sta ps_num+1
 lda #8
 sta ps_num+2
 jsr ps_div24_16
 ldx lpp_index
 lda ps_num
 sta lpt_a_wlo,x
 sta ps_b
 lda ps_num+1
 sta lpt_a_whi,x
 sta ps_b+1
'''
    for a in 'sv':
        s+=f''' lda lpt_a_{a}lo,x
 sta ps_a
 lda #0
 sta ps_a+1
 jsr lpp_mul16
 ldy #7
-
 lsr ps_prod+3
 ror ps_prod+2
 ror ps_prod+1
 ror ps_prod
 dey
 bne -
 ldx lpp_index
 lda ps_prod
 sta lpt_a_{a}lo,x
 lda ps_prod+1
 sta lpt_a_{a}hi,x
'''
    s+=''' inc lpp_index
 lda lpp_index
 cmp clip_a_count
 bne lpp_encode_loop
 lda #1
 sta lpp_encoded
lpp_encode_done:
 rts

lpp_raster_polygon:
 lda clip_a_count
 cmp #3
 bcc lpp_raster_done
 lda #1
 sta lpt_changed
 ldx #0
lpp_raster_loop:
'''
    for a in 'xy':
        s+=f' lda clip_a_{a},x\n sta lpt_a_{a}lo,x\n lda #0\n sta lpt_a_{a}hi,x\n'
        s+=(f' asl lpt_a_{a}lo,x\n rol lpt_a_{a}hi,x\n')*2
    s+=''' lda #0
 sta lpt_a_qlo,x
 inx
 cpx clip_a_count
 bne lpp_raster_loop
lpp_raster_done:
 rts

; Unsigned16 product; no geometry operands, no zero-page storage.
lpp_mul16:
 ldx #3
 lda #0
-
 sta ps_prod,x
 sta ps_shift,x
 dex
 bpl -
 lda ps_a
 sta ps_shift
 lda ps_a+1
 sta ps_shift+1
 lda ps_b
 sta ps_bits
 lda ps_b+1
 sta ps_bits+1
 ldx #16
lpp_mul_loop:
 lsr ps_bits+1
 ror ps_bits
 bcc lpp_mul_shift
 clc
'''
    for j in range(4):s+=f' lda ps_prod+{j}\n adc ps_shift+{j}\n sta ps_prod+{j}\n'
    s+=' asl ps_shift\n rol ps_shift+1\n rol ps_shift+2\n rol ps_shift+3\n dex\n bne lpp_mul_loop\n rts\n'
    s=s.replace(' asl ps_shift\n','lpp_mul_shift:\n asl ps_shift\n',1)
    return s

def ratio_math():
    # The raster DDA requests delta24 * (0..4) / denominator16. No Q8
    # coordinate representation, camera matrix or projection is involved.
    s='''lpr_ratio_product:
 lda lpt_delta+2
 sta lpt_sign
 bpl lpp_ratio_positive
 sec
'''
    for j in range(3):s+=f' lda #0\n sbc lpt_delta+{j}\n sta lpt_delta+{j}\n'
    s+='''lpp_ratio_positive:
 lda #0
 sta ps_num
 sta ps_num+1
 sta ps_num+2
 ldx lpt_factor
 beq lpp_ratio_divide
lpp_ratio_add:
 clc
'''
    for j in range(3):s+=f' lda ps_num+{j}\n adc lpt_delta+{j}\n sta ps_num+{j}\n'
    s+=''' dex
 bne lpp_ratio_add
lpp_ratio_divide:
 lda lpt_den
 sta ps_den
 lda lpt_den+1
 sta ps_den+1
 jsr ps_div24_16
'''
    for j in range(3):s+=f' lda ps_num+{j}\n sta lpt_result+{j}\n'
    for j in range(2):s+=f' lda ps_remainder+{j}\n sta lpt_remainder+{j}\n'
    s+=' lda lpt_sign\n bpl lpp_ratio_done\n sec\n'
    for j in range(3):s+=f' lda #0\n sbc lpt_result+{j}\n sta lpt_result+{j}\n'
    return s+'lpp_ratio_done:\n rts\n'

def patch(s):
    assert 'LEGACY_PLUS_NEAR_SCREEN_Q4=1' in s
    assert 'MODE7_UV_CARRIER = $01' in s
    assert 'CAMERA_PLANE_CLIP_PROFILE = $00' in s
    sys.path.insert(0,str(Path(__file__).parent/'q8/src'))
    # Reuse only the existing texture edge walker and rational sampler.
    # Their generated private attribute names are separated from Q8 state.
    import texture_edges,perspective
    shaded='m3_q0:' in s;flat='m2_update_face_lighting:' in s
    # Plus already redirects both near and positive-depth polygons to the
    # projected-screen clipper. Remove only the now-unreferenced integer
    # camera-side implementation; retain its live projection helpers and all
    # screen/near routines. This funds the rational carriers without moving
    # video buffers or widening a memory window.
    a=s.index('clip_poly_clip_camera_x_current:\n');b=s.index('clip_poly_project_a_from_camera:\n',a)
    old=s[a:b];outside=s[:a]+s[b:]
    for name in re.findall(r'(?m)^(\w+):',old):
        assert not re.search(r'\b'+name+r'\b',outside),('Live old camera-side clip consumer',name)
    assert old.count('.if ')==old.count('.endif'), 'Unbalanced retired camera clip block'
    s=s[:a]+'; Plus projective: unreferenced integer camera-side clip removed.\n'+s[b:]
    def private(code):return code.replace('hc_','lpt_').replace('hq_','lpr_')
    edge,edge_data=texture_edges.generate(shaded,perspective=True)
    edge=private(edge).replace('draw_clip_poly_gouraud:\n','lpp_draw_polygon:\n',1)
    sample=private(perspective.sampler(shaded));span=private(perspective.spans(shaded))
    if flat and not shaded:
        span=span.replace('ps_prepare_span:\n','ps_prepare_span:\n lda yrow\n and #3\n asl\n asl\n sta m2_bayer_row\n',1)
    s=once(s,'load_face_y:\n','load_face_y:\n lda #0\n sta lpp_encoded\n')
    s=once(s,'m7_sample:\n','m7_sample:\n jsr ps_sample\n')
    s=s.replace(' sta m7_sample+1\n',' sta m7_sample+4\n').replace(' sta m7_sample+2\n',' sta m7_sample+5\n')
    a=s.index('m7_advance:\n');b=s.index('m7_prepare_span:\n',a)
    s=s[:a]+'m7_advance:\n jmp ps_advance\n\n'+s[b:]
    a=s.index('m7_prepare_span:\n');b=s.index('; A=start, X=end, m7_den=length.',a)
    s=s[:a]+'m7_prepare_span:\n jmp ps_prepare_span\n\n'+s[b:]
    s=once(s,'clip_poly_clip_screen_current:\n','clip_poly_clip_screen_current:\n jsr lpp_encode_polygon\n')
    # Every corner entering the ordinary polygon initializer keeps Q4 depth.
    a=s.index('clip_poly_load_vertex_a:\n');b=s.index('clip_poly_right_a_to_b:\n',a)
    code=s[a:b]
    for axis in 'xyz':
        for part in ('lo','hi'):code=code.replace('v'+axis+'raw'+part,'lpn_'+axis+part)
    s=s[:a]+code+s[b:]
    # Preserve all three full16 rational carriers through screen clipping.
    extra=('shi','vhi','wlo','whi')
    for bank in 'ab':
        for endpoint in ('in','out'):
            old=f' lda clip_{bank}_shade,x\n sta gouraud_clip_shade_{endpoint}\n'
            added=''.join(f' lda lpt_{bank}_{ch},x\n sta lpp_{ch}_{endpoint}\n' for ch in extra)
            s=s.replace(old,added+old)
    # Pure attribute copies (including swaps, compaction and clipped fans).
    pat=re.compile(r'(?m)^ lda clip_([ab])_shade([+,a-z0-9 ]*)\n sta clip_([ab])_shade([+,a-z0-9 ]*)\n')
    def copy(m):
        return ''.join(f' lda lpt_{m[1]}_{ch}{m[2]}\n sta lpt_{m[3]}_{ch}{m[4]}\n' for ch in extra)+m[0]
    s,n=pat.subn(copy,s);assert n>=3,n
    for side,src,dst in [('right','a','b'),('left','b','a'),('top','a','b'),('bottom','b','a')]:
        a=s.index(f'clip_append_{side}_intersection_{src}_to_{dst}:\n');b=s.index('\n rts\n',a)
        code=s[a:b]
        call=' jsr gouraud_interp_clip_shade\n'
        assert code.count(call)==1
        added=''.join(f' lda lpp_{ch}_result\n sta lpt_{dst}_{ch},y\n' for ch in extra)
        code=code.replace(f' inc clip_{dst}_count',added+f' inc clip_{dst}_count',1)
        s=s[:a]+code+s[b:]
    # Exact16 screen weights, matching the near geometry's existing rule.
    a=s.index('clip_load_inside_right_a:\n');b=s.index('gouraud_interp_clip_shade:\n',a)
    code=s[a:b].replace(' jsr clip_ratio_to_scale8\n',' jsr lpn_ratio_nearest\n').replace(' jsr mul_s16_u8_frac\n',' jsr lpn_mul_nearest\n')
    s=s[:a]+code+s[b:]
    # Replace the affine screen-attribute interpolator only. The near callback
    # lpa_near_attributes still processes raw UV before rational encoding.
    a=s.index('gouraud_interp_clip_shade:\n');b=s.index('\n.endif',a)
    interp='gouraud_interp_clip_shade:\n'
    if shaded:
        interp+=''' sec
 lda m3_clip_q_out
 sbc m3_clip_q_in
 sta p1lo
 lda #0
 sbc #0
 sta p1hi
 jsr lpn_mul_nearest
 clc
 lda p1lo
 adc m3_clip_q_in
 sta m3_clip_q_result
'''
    for ch,lowin,lowout,lowresult in [('w','lpp_wlo_in','lpp_wlo_out','lpp_wlo_result'),('v','m7_clip_v_in','m7_clip_v_out','m7_clip_v_result'),('s','gouraud_clip_shade_in','gouraud_clip_shade_out','lpp_slo_result')]:
        interp+=f''' sec
 lda {lowout}
 sbc {lowin}
 sta p1lo
 lda lpp_{ch}hi_out
 sbc lpp_{ch}hi_in
 sta p1hi
 jsr lpn_mul_nearest
 clc
 lda p1lo
 adc {lowin}
 sta {lowresult}
 lda p1hi
 adc lpp_{ch}hi_in
 sta lpp_{ch}hi_result
'''
    interp+=' lda lpp_slo_result\n rts\n'
    s=s[:a]+'gouraud_interp_clip_shade:\n jmp lpp_screen_attributes\n'+s[b:]
    interp=interp.replace('gouraud_interp_clip_shade:\n','lpp_screen_attributes:\n',1)
    # One convex-polygon raster for both intact and clipped triangles.
    a=s.index('draw_loaded_face_gouraud:\n');b=s.index('gouraud_build_edge_shades:\n',a)
    s=s[:a]+'''draw_loaded_face_gouraud:
 lda clip_poly_active
 bne lpp_loaded_clipped
 jsr clip_poly_init_from_face
 jsr lpp_encode_polygon
lpp_loaded_clipped:
 jsr lpp_raster_polygon
 jmp lpp_draw_polygon

'''+s[b:]
    a=s.index('gouraud_build_edge_shades:\n');b=s.index('gouraud_fill_bounds:\n',a)
    s=s[:a]+'gouraud_build_edge_shades:\n rts ; retired affine walker\n\n'+s[b:]
    a=s.index('gouraud_build_edge_shades_v:\n');b=s.index('; Mode 7 affine Q4.4.',a)
    s=s[:a]+'gouraud_build_edge_shades_v:\n rts ; retired affine walker\n\n'+s[b:]
    # The legacy fill loop includes equal endpoints. The rational walker has
    # half-open internal right edges: left==right is empty unless this row
    # ends on a closed viewport cap. Avoid an end=start-1 byte-kernel wrap.
    a=s.index(' cmp leftval\n',s.index('gouraud_fill_bounds:\n'))
    b=s.index(' stx yrow\n ldx leftval\n',a)
    s=s[:a]+''' cmp leftval
 bcc gfb_next
 bne lpp_fill_nonempty
 lda tq_closed,x
 beq gfb_next
lpp_fill_nonempty:
'''+s[b:]
    if shaded:
        a=s.index('gouraud_build_edge_shades_v_q:\n');b=s.index('m3_code_end = *',a)
        s=s[:a]+'gouraud_build_edge_shades_v_q:\n rts ; retired affine walker\n'+s[b:]
    a=s.index('draw_clip_poly_gouraud:\n');b=s.index('\n.endif',a)
    s=s[:a]+'''draw_clip_poly_gouraud:
 jsr lpp_raster_polygon
 jmp lpp_draw_polygon
'''+s[b:]
    s=once(s,'render_frame_end:\n','''render_frame_end:
 lda ps_fault
 beq lpp_frame_valid
lpp_profile_fault:
 lda #2
 sta $d020
 jmp lpp_profile_fault
lpp_frame_valid:
''')
    data=private(edge_data)+perspective.state()
    data+='lpt_count = clip_a_count\nlpp_encoded: .byte 0\nlpp_index: .byte 0\nlpt_changed: .byte 0\n'
    for n,length in [('delta',3),('factor',3),('den',3),('result',3),('remainder',3),('sign',1)]:data+=f'lpt_{n}: .fill {length},0\n'
    for bank in 'ab':
        data+=f'lpt_{bank}_slo = clip_{bank}_shade\nlpt_{bank}_vlo = m7_clip_{bank}_v\n'
        for ch in extra:data+=f'lpt_{bank}_{ch}: .fill 12,0\n'
    for a in 'xy':
        for part in ('lo','hi'):data+=f'lpt_a_{a}{part}: .fill 12,0\n'
    data+='lpt_a_qlo: .fill 12,0\n'
    if shaded:data+='lpt_a_qhi = m3_clip_a_q\n'
    for ch in extra:
        for ep in ('in','out','result'):data+=f'lpp_{ch}_{ep}: .byte 0\n'
    data+='lpp_slo_result: .byte 0\n'
    for side,old in [('left','leftshade'),('right','rightshade')]:
        data+=f'ps_{side}s_lo = {old}\nps_{side}v_lo = m7_{side}v\n'
        for ch in ('s_hi','v_hi','w_lo','w_hi'):data+=f'ps_{side}{ch}: .fill VIEWPORT_ROW_CAPACITY,0\n'
    parts=dict(bridge=bridge(),edge=edge,ratio=ratio_math(),screen_attrs=interp,sample=sample,span=span,state=data)
    for n,code in parts.items():s+=f'\nlpp_{n}_begin:\n'+code+f'\nlpp_{n}_end:\n.cerror * > $d000,"Plus projective {n} overlaps IO"\n'
    return s+'\n; LEGACY_PLUS_PROJECTIVE_Q4=1\n'

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('asm',type=Path);a=p.parse_args()
    a.asm.write_text(patch(a.asm.read_text(encoding='utf-8-sig')),encoding='ascii')
