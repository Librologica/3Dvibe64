"""Q8-only Mode 7 adapter. Frozen SDK and all legacy outputs stay untouched."""
import re
from pathlib import Path
from continuous import prepare,retire

def replace(s,a,b):
    assert s.count(a)==1,(a[:80],s.count(a))
    return s.replace(a,b)

def prepare_texture(source,music,motion):
    source=prepare(source,music,motion,7)
    # Only new whole-polygon edge builder is reachable. Keep the UV fetch,
    # byte packer, per-span interpolation and existing lighting code verbatim.
    source=retire(source,'draw_loaded_face_gouraud:','gouraud_fill_bounds:')
    source=source.replace('draw_loaded_face_gouraud = hp_unreachable','draw_loaded_face_gouraud = draw_clip_poly_gouraud')
    source=retire(source,'gouraud_build_edge_shades_v:','; Mode 7 affine Q4.4.')
    if 'gouraud_build_edge_shades_v_q:' in source:
        source=retire(source,'gouraud_build_edge_shades_v_q:','m3_code_end = *')
    source=retire(source,'build_loaded_face_bounds_xyq2:','; Mesh data is generated below by the build script.')
    # All variants use the same top-left bounds. A viewport clipping cap is
    # closed; internal shared mesh edges remain half-open.
    start=source.index(' cmp leftval\n',source.index('gouraud_fill_bounds:'))
    end=source.index(' stx yrow\n ldx leftval\n',start)
    source=source[:start]+''' cmp leftval
 bcc gfb_next
 bne tq_fill_nonempty
 lda tq_closed,x
 beq gfb_next
tq_fill_nonempty:
'''+source[end:]
    start=source.index(' sta gouraud_scan_end\n',source.index('m7_prepare_span:'))
    end=source.index(' ldy yrow\n',start)
    source=source[:start]+''' sta gouraud_scan_end
 ldx yrow
 lda tq_closed,x
 bne tq_span_right_ready
 dec gouraud_scan_end
tq_span_right_ready:
'''+source[end:]
    return source

def texture_pieces(p,lab):
    shaded='m3_q0' in lab
    attrs=[('s','gouraud_vshade0'),('v','m7_v0')]+([('q','m3_q0')] if shaded else [])
    p={n:code.replace('GOURAUD_MODE6','MODE7_UV_CARRIER') for n,code in p.items()}
    clip=p['clip'];helper=p['clip_helpers'];extra=''
    # Mode 7 retains near=1 WU (solid Q8 demos used 8). Remote Q2 cache
    # saturation is NOT safe for UV clipping there. Preserve full signed24
    # projected coordinates separately; legacy integer caches are only hints.
    proj=p['projection'];full='tq_full_projection:\n lda hc_sign\n'
    full+=' ldx hc_axis\n beq tq_full_sign\n eor #128\ntq_full_sign:\n cmp #128\n bcc tq_full_positive\n sec\n'
    for j in range(3):full+=f' lda #0\n sbc hc_num+{j}\n sta tq_full+{j}\n'
    full+=' jmp tq_full_center\ntq_full_positive:\n'
    for j in range(3):full+=f' lda hc_num+{j}\n sta tq_full+{j}\n'
    full+='tq_full_center:\n ldx hc_axis\n clc\n lda tq_full+1\n adc hc_centers,x\n sta tq_full+1\n lda tq_full+2\n adc #0\n sta tq_full+2\n rts\n'
    proj=replace(proj,' jsr hc_div40\n lda hc_num\n and #63\n',' jsr hc_div40\n jsr tq_full_projection\n lda hc_num\n and #63\n')
    for ax in 'xy':
        anchor=f' jsr hc_project_axis\n ldy hp_idx\n lda hc_q\n sta s{ax}q2_lo,y\n'
        copy=''.join(f' lda tq_full+{j}\n sta tq_cache_{ax}{j},y\n' for j in range(3))
        proj=replace(proj,anchor,anchor.replace(' lda hc_q\n',copy+' lda hc_q\n'))
        for j in range(3):extra+=f'tq_cache_{ax}{j}: .fill VERT_COUNT,0\n'
        a=clip.index(f' lda s{ax}q2_lo,x\n');b=clip.index(f' sta hc_out_{ax}+2\n',a)+len(f' sta hc_out_{ax}+2\n')
        clip=clip[:a]+''.join(f' lda tq_cache_{ax}{j},x\n sta hc_out_{ax}+{j}\n' for j in range(3))+clip[b:]
    helper=helper.replace(' jsr hq_expand_q\n',''.join(f' lda tq_full+{j}\n sta hq_projected+{j}\n' for j in range(3)))
    p['projection']=proj;p['full_projection']=full;extra+='tq_full: .fill 3,0\n'
    # U/V are unsigned bytes with eight additional fractional bits while
    # clipping. Differences therefore need SIGNED17, not old signed16 shade.
    a=clip.index('.if MODE7_UV_CARRIER != 0\n ldx hc_to\n',clip.index('hc_near_intersection:'))
    b=clip.index('\n rts\n',a)
    near=' lda #0\n sta hc_den+2\n sta hc_factor+2\n'
    for att,raw in attrs:
        near+=f''' ldx hc_to
 ldy hc_from
 lda #0
 sta hc_delta
 sec
 lda {raw},x
 sbc {raw},y
 sta hc_delta+1
 lda #0
 sbc #0
 sta hc_delta+2
 jsr hq_ratio_product
 lda hc_result
 sta hc_out_{att}
 ldy hc_from
 clc
 lda hc_result+1
 adc {raw},y
 sta hc_out_{att}+1
'''
    clip=clip[:a]+near+clip[b:]
    # Emit all original-endpoint loads BEFORE geometry projection clobbers X.
    anchor=' sta hc_out_s\n lda hc_face_vertices,x\n'
    add=''
    for att,raw in attrs[1:]:
        add+=f' lda {raw},x\n sta hc_out_{att}+1\n lda #0\n sta hc_out_{att}\n'
    clip=replace(clip,anchor,' sta hc_out_s\n'+add+' lda hc_face_vertices,x\n')
    clip=replace(clip,' jsr hc_interpolate_s\n',''.join(f' jsr hc_interpolate_{att}\n' for att,_ in attrs))
    # Duplicate PURE attribute transfers, not geometry or clipping decisions.
    for att,_ in attrs[1:]:
        for bank in 'ab':
            for part in ('lo','hi'):extra+=f'hc_{bank}_{att}{part}: .fill 12,0\n'
        extra+=f'hc_out_{att}: .word 0\n'
        # Copy/intersection helper blocks are contiguous generated routines.
        for bank in 'ab':
            old=''.join(f' lda hc_{bank}_s{part},x\n sta hc_out_s+{j}\n' for j,part in enumerate(('lo','hi')))
            new=old.replace('_s','_'+att)
            helper=replace(helper,old,new+old)
            old=''.join(f' lda hc_out_s+{j}\n sta hc_{bank}_s{part},y\n' for j,part in enumerate(('lo','hi')))
            helper=replace(helper,old,old.replace('_s','_'+att)+old)
        old=''.join(f' lda hc_b_s{part},x\n sta hc_a_s{part},x\n' for part in ('lo','hi'))
        helper=replace(helper,old,old.replace('_s','_'+att)+old)
        a=helper.index('hc_interpolate_s:');b=helper.index('\n rts\n',a)+len('\n rts\n')
        helper+=helper[a:b].replace('_s','_'+att)
    if 'sxq2_lo' not in lab:extra+='sxq2_lo: .fill VERT_COUNT,0\nsxq2_hi: .fill VERT_COUNT,0\n'
    p['clip']=clip;p['clip_helpers']=helper;p['data']+=extra
    from texture_edges import generate
    edge,edge_data=generate(shaded)
    p['poly_draw']=edge;p['data']+=edge_data
    # Keep packable blocks smaller than existing four segment windows.
    a=p['clip_helpers'].index('hc_near_x:')
    p['texture_helpers']=p['clip_helpers'][a:];p['clip_helpers']=p['clip_helpers'][:a]
    return p
