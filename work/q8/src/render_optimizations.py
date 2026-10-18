"""Opt-in exact render work elimination. No scene-specific labels or assets.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import re
from perspective_exact import once

OPTIONS={'camera-extremes','degenerate-faces','zero-terms','live-attributes','adapter-outcodes','inside-planes','bounded-divide','packed-samples','unrolled-advance'}

def camera_extremes(parts):
    if 'camera_math' not in parts:raise ValueError('RENDER_CAMERA: mobile Q8 camera required')
    s=once(parts['camera_math'],'qc_product_b_positive:\n','''qc_product_b_positive:
 lda qc_b
 bne ro_camera_general
 lda qc_b+1
 beq ro_camera_zero
 ldx #2
ro_camera_unit:
 lda qc_a,x
 sta qc_r,x
 dex
 bpl ro_camera_unit
 jmp ro_camera_sign
ro_camera_zero:
 ldx #2
ro_camera_clear:
 sta qc_r,x
 dex
 bpl ro_camera_clear
 rts
ro_camera_general:
''')
    parts['camera_math']=once(s,' lda qc_sign\n beq qc_product_done\n','ro_camera_sign:\n lda qc_sign\n beq qc_product_done\n')

def degenerate_faces(source):
    # A quad can have two equal indices and still contain a visible triangle.
    # Only source triangles with a repeated index are provably empty here.
    return once(source,'dm_collect_loop:\n','''dm_collect_loop:
.if HAS_TRI_FACES != 0
 ldy faceidx
 lda face_vertex_count,y
 cmp #3
 bne ro_face_nonempty
 lda face0,y
 cmp face1,y
 beq dm_skip
 cmp face2,y
 beq dm_skip
 lda face1,y
 cmp face2,y
 beq dm_skip
ro_face_nonempty:
.endif
''')

def zero_terms(parts):
    # Keep the full transform, signed24 carry and fractional terms. At any
    # orientation a term equal to exactly zero contributes nothing.
    s=parts['vertices'];count=0
    for row in range(3):
        for column,axis in enumerate('xyz'):
            label=f'hp_term{row}{column}'
            old=f' ldx vert_{axis}i,y\n lda {label}_hi,x\n'
            start=s.find(old)
            if start<0:raise ValueError('RENDER_TERMS: standard vertex emitter required')
            end=s.index(' sta hc_sum+2\n',start)+len(' sta hc_sum+2\n')
            tag=f'ro_zero_{row}{column}'
            body=s[start:end]
            body=body.replace(old,f' ldx vert_{axis}i,y\n lda {label}_lo,x\n ora {label}_hi,x\n beq {tag}\n lda {label}_hi,x\n',1)
            s=s[:start]+body+tag+':\n'+s[end:];count+=1
    parts['vertices']=s;return count

def live_attributes(source,parts,masks=None):
    """X/S/V/W[/Q] bitmask; explicit masks are the adapter's shader contract.

    Omitted masks keep every channel. Uniform texture selection (pu_texel)
    automatically makes S/V/W dead, retaining Q in the lit shader. Thus
    far LOD keeps its exact existing pattern and per-pixel illumination.
    """
    shaded='m3_q0:' in source
    attrs=['x','s','v','w']+(['q'] if shaded else [])
    all_bits=(1<<len(attrs))-1;flat_bits=17 if shaded else 1
    data='ro_active: .byte '+str(all_bits)+'\nro_bits: .byte 1,2,4,8'+(',16' if shaded else '')+'\n'
    select=f' lda #{all_bits}\n'
    if masks is not None:
        if not isinstance(masks,(list,tuple)) or not masks or any(type(v)is not int or not v&1 or v&~all_bits or (v&6 and not v&8) for v in masks):
            raise ValueError('RENDER_ATTRIBUTES: masks must include X and only existing channels')
        data+='ro_face_attributes: .byte '+','.join(map(str,masks))+'\n'
        select=' lda ro_face_attributes,y\n'
    select+=' sta ro_active\n'
    if masks is not None:
        select+=f' cmp #{all_bits}\n bne ro_attributes_ready\n'
    # This is a texture property, not a material/room ID or distance override.
    select+=f' lda pu_texel\n beq ro_attributes_ready\n lda ro_active\n and #{flat_bits}\n sta ro_active\nro_attributes_ready:\n'
    parts['clip']=once(parts['clip'],' jsr gouraud_load_face_raw_shades_y\n',' jsr gouraud_load_face_raw_shades_y\n'+select)
    parts['clip_helpers']=once(parts['clip_helpers'],'hc_append_a:\n jsr ps_encode\n',
        'hc_append_a:\n lda ro_active\n and #14\n beq ro_no_encode\n jsr ps_encode\nro_no_encode:\n')
    s=parts['clip']
    # Near intersections carry raw S/V[/Q], not W (encoding comes later).
    begin=s.index('hc_near_intersection:');end=s.index('\n rts\n',begin)
    near=s[begin:end]
    for attr,raw,bit in [('s','gouraud_vshade0',2),('v','m7_v0',4)]+([('q','m3_q0',16)] if shaded else []):
        # Header may have an assembly IF. Preserve it outside the skipped block.
        anchor=f' ldx hc_to\n ldy hc_from\n lda #0\n sta hc_delta\n sec\n lda {raw},x\n'
        if anchor not in near:raise ValueError('RENDER_ATTRIBUTES: near attribute ABI changed: '+attr)
        a=near.index(anchor);last=f' sta hc_out_{attr}+1\n';b=near.index(last,a)+len(last)
        near=near[:a]+f' lda ro_active\n and #{bit}\n beq ro_near_{attr}_done\n'+near[a:b]+f'ro_near_{attr}_done:\n'+near[b:]
    s=s[:begin]+near+s[end:]
    for i,attr in enumerate(attrs[1:],1):
        old=f' jsr hc_interpolate_{attr}\n'
        s=once(s,old,f' lda ro_active\n and #{1<<i}\n beq ro_screen_{attr}_done\n'+old+f'ro_screen_{attr}_done:\n')
    parts['clip']=s
    s=parts['poly_draw']
    for i,attr in enumerate(attrs[1:],1):
        anchor=f' lda #{i}\n sta tq_ch\n'
        a=s.index(anchor);b=s.index(' jsr tq_setup_channel\n',a)+len(' jsr tq_setup_channel\n')
        s=s[:a]+f' lda ro_active\n and #{1<<i}\n beq ro_setup_{attr}_done\n'+s[a:b]+f'ro_setup_{attr}_done:\n'+s[b:]
    s=once(s,'tq_advance:\n clc\n','tq_advance:\n lda ro_bits,x\n and ro_active\n beq ro_advance_next\n clc\n')
    s=once(s,'tq_advance_done:\n inx\n','tq_advance_done:\nro_advance_next:\n inx\n')
    parts['poly_draw']=s
    # UV outputs are dead for uniform pages / far LOD. Q is stepped by the
    # independent shaded span code and must never be skipped here.
    parts['perspective_sample']=once(parts['perspective_sample'],'ps_sample:\n',
        'ps_sample:\n lda pu_texel\n beq ro_sample_uv\n rts\nro_sample_uv:\n')
    parts['data']+=data
    return dict(channels=attrs,explicitMasks=masks is not None,uniformTextureMask=flat_bits,
                LOD='unchanged; only unused UV work removed',lighting='Q retained')

def inside_planes(parts):
    if 'clip' not in parts:raise ValueError('RENDER_CLIP: Q8 screen clipper required')
    parts['clip']=once(parts['clip'],' sta hc_bound+2\n',' sta hc_bound+2\n'+' ldx #0\nro_plane_probe:\n jsr hc_screen_inside\n bcc ro_plane_required\n inx\n cpx hc_count\n bne ro_plane_probe\n rts\nro_plane_required:\n')


def apply(source,parts,options,*,masks=None):
    info={}
    if 'unrolled-advance' in options:
        from exact_raster import unrolled_advance
        unrolled_advance(source,parts);info['unrolled-advance']='exact three-channel rational advance; unlit only'
    if 'packed-samples' in options:
        source=once(source,'m7_full_byte:\n jsr m7_sample\n asl\n asl\n asl\n asl\n asl\n asl\n sta m7_packed\n jsr m7_advance\n jsr m7_sample\n asl\n asl\n asl\n asl\n ora m7_packed\n sta m7_packed\n jsr m7_advance\n jsr m7_sample\n asl\n asl\n ora m7_packed\n sta m7_packed\n','m7_full_byte:\n jsr m7_sample\n asl\n asl\n sta m7_packed\n jsr m7_advance\n jsr m7_sample\n ora m7_packed\n asl\n asl\n sta m7_packed\n jsr m7_advance\n jsr m7_sample\n ora m7_packed\n asl\n asl\n sta m7_packed\n')
        info['packed-samples']='four two-bit samples composed with six shifts; original sampling/advance calls retained'
    if 'bounded-divide' in options:
        from exact_raster import bounded_divide
        bounded_divide(parts);info['bounded-divide']='exact 8-bit quotient guard with original 24/16 fallback'
    if 'inside-planes' in options:
        inside_planes(parts);info['inside-planes']='skip unchanged plane copies only when every Q8 vertex is inside'
    if 'camera-extremes' in options:camera_extremes(parts);info['camera-extremes']='exact zero/unit products; general fallback'
    if 'degenerate-faces' in options:source=degenerate_faces(source);info['degenerate-faces']='repeated-index triangles only; quads retained'
    if 'zero-terms' in options:info['zero-terms']=dict(guardedTerms=zero_terms(parts),fallback='all nonzero and fractional products retained')
    if 'live-attributes' in options:info['live-attributes']=live_attributes(source,parts,masks)
    if 'adapter-outcodes' in options:
        if 'tq_classify_projection:' not in parts.get('full_projection','') or 'tq_face_code' not in parts.get('clip','') or 'tq_point_code' not in parts.get('clip_helpers',''):
            raise ValueError('RENDER_OUTCODES: adapter removed a required public hook')
        info['adapter-outcodes']='explicit public conservative outcodes; hooks verified'
    return source,parts,info
