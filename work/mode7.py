"""DEV Mode 7: validated affine UV attributes and 6510 byte mapper generation.

The frozen geometry generator is a compile-time intermediate, not a Gouraud
rendering fallback. No path is run or emitted differently for modes 1-6.
"""
import copy
import json
import math
from pathlib import Path
import re
import sys
import importlib.util

# Existing host tests load this backend by file path, without putting work/
# on sys.path. Resolve the host-only helper beside this exact backend too.
_png_spec = importlib.util.spec_from_file_location('mode7_png', Path(__file__).with_name('mode7_png.py'))
_png_module = importlib.util.module_from_spec(_png_spec)
_png_spec.loader.exec_module(_png_module)


def prepare(doc, scene_dir=None):
    doc = copy.deepcopy(doc)
    if doc.get('graphicsMode') != 7:
        raise ValueError('graphicsMode must be 7')
    if doc.get('meshSourceSharing'):
        raise ValueError('Mode 7 v1: source sharing is not yet supported')
    palette = doc.get('texturePalette')
    if palette is not None and (not isinstance(palette,list) or len(palette)!=3 or
            any(type(c) is not int or not 0 <= c <= 15 for c in palette)):
        raise ValueError('texturePalette must contain three VIC-II colors 0..15 (codes 01,10,11)')
    textures = doc.get('textures', [])
    if not 1 <= len(textures) <= 16:
        raise ValueError('Mode 7 requires 1..16 textures')
    _png_module.expand_textures(textures, scene_dir)
    ids = {}
    for i, tex in enumerate(textures):
        if not isinstance(tex.get('id'), str) or tex['id'] in ids:
            raise ValueError('Textures require unique string ids')
        if tex.get('width') != 16 or tex.get('height') != 16:
            raise ValueError('Texture dimensions must be 16x16')
        pixels = tex.get('texels', [])
        if len(pixels) != 256 or any(type(p) is not int or p not in (1, 2, 3) for p in pixels):
            raise ValueError('Texture must contain 256 integer texels, each 1, 2 or 3')
        repeat=tex.setdefault('repeat',[1,1])
        if not isinstance(repeat,list) or len(repeat)!=2 or any(type(v) is not int or v not in (1,2,4,8,16) for v in repeat):
            raise ValueError('Texture repeat must be [U,V], each 1,2,4,8 or 16')
        ids[tex['id']] = i
    sources = {}
    uvfaces = {}
    texfaces = {}
    for mesh in doc.get('meshes', []):
        if not mesh.get('vertices') or not mesh.get('faces') or 'builtin' in mesh or 'file' in mesh:
            raise ValueError('Mode 7 v1 requires explicit mesh vertices and faces')
        if mesh.get('faceOverrides'):
            raise ValueError('Mode 7 v1 does not support face shading overrides')
        uv = mesh.get('uv')
        corner = mesh.get('faceUV')
        if (uv is None) == (corner is None):
            raise ValueError('Specify exactly one of uv (per vertex) or faceUV (per corner)')
        if uv is not None and len(uv) != len(mesh['vertices']):
            raise ValueError('uv length must match vertices')
        if corner is not None and len(corner) != len(mesh['faces']):
            raise ValueError('faceUV length must match faces')
        face_textures=mesh.get('faceTextures',[None]*len(mesh['faces']))
        if not isinstance(face_textures,list) or len(face_textures)!=len(mesh['faces']):
            raise ValueError('faceTextures length must match faces; null inherits mesh texture')
        fs, us, ts = [], [], []
        for fi, face in enumerate(mesh['faces']):
            tid=face_textures[fi] if face_textures[fi] is not None else mesh.get('texture')
            if not isinstance(tid,str) or tid not in ids:
                raise ValueError('Every face must resolve a declared texture')
            if len(face) not in (3, 4) or any(type(x) is not int or not 0 <= x < len(mesh['vertices']) for x in face):
                raise ValueError('Textured faces require 3/4 valid vertex indices')
            coords = corner[fi] if corner is not None else [uv[x] for x in face]
            if len(coords) != len(face):
                raise ValueError('UV corner count differs from face')
            packed = []
            for pair in coords:
                if len(pair) != 2 or any(type(x) not in (int, float) or not math.isfinite(x) or not 0 <= x <= 255/16 or x*16 != int(x*16) for x in pair):
                    raise ValueError('UV must be exact Q4.4 texel coordinates, 0..15.9375')
                packed.append([int(x*16) for x in pair])
            # Fixed diagonal corner 0 -> 2. Preserve winding of both triangles.
            for tri in ((0, 1, 2),) if len(face) == 3 else ((0, 1, 2), (0, 2, 3)):
                fs.append([face[x] for x in tri])
                us.append([packed[x] for x in tri])
                ts.append(ids[tid])
        mesh['faces'] = fs
        if doc.get('textureLighting') != 'gouraud':
            mesh['gouraud'] = {'creaseAngle': 180}  # unused geometry-carrier metadata
        for key in ('uv', 'faceUV', 'texture', 'faceTextures'):
            mesh.pop(key, None)
        sources[mesh['id']] = mesh
        uvfaces[mesh['id']] = us
        texfaces[mesh['id']] = ts
    return doc, textures, uvfaces, texfaces


def prepare_scene(doc, scene_dir=None):
    lighting = doc.get('textureLighting', 'none')
    compositor = doc.get('textureCompositor', 'C' if lighting == 'gouraud' else 'A')
    if compositor not in ('A', 'B', 'C'):
        raise ValueError('textureCompositor must be A, B or C')
    if compositor != 'A' and lighting != 'gouraud':
        raise ValueError('B/C textureCompositor requires gouraud lighting')
    if lighting not in ('none', 'flat', 'gouraud'):
        raise ValueError('textureLighting must be none, flat or gouraud')
    # Source-face identity, not UV topology: both children of a quad share
    # the geometric normal/plane of its first triangle (fixed diagonal 0-2).
    representatives = {}
    for mesh in doc.get('meshes', []):
        indices = []
        for face in mesh.get('faces', []):
            indices.extend([len(indices)] * (2 if len(face) == 4 else 1))
        representatives[mesh['id']] = indices
    prepared, textures, uvfaces, texfaces = prepare(doc, scene_dir)
    prepared.pop('textureLighting', None)
    prepared.pop('textureCompositor', None)
    uvs, tids = [], []
    face_sources = []
    for obj in prepared['objects']:
        mid = obj.get('mesh')
        if mid not in uvfaces or obj.get('faceOverrides'):
            raise ValueError('Mode 7 objects must reference a textured mesh without faceOverrides')
        if any(key in obj for key in ('materialOverride', 'reflectivityOverride', 'colorOverride')):
            raise ValueError('Mode 7 v1 does not support instance palette overrides; use material and reflectivity')
        face_sources.extend([len(uvs)+i for i in representatives[mid]])
        uvs.extend(uvfaces[mid])
        tids.extend(texfaces[mid])
    if not 1 <= len(uvs) <= 255:
        raise ValueError('Mode 7 v1 supports 1..255 runtime triangles')
    prepared['graphicsMode'] = 6
    prepared.pop('textures')
    # Drop unused pages and remap indices before generating runtime tables.
    used=sorted(set(tids));remap={old:new for new,old in enumerate(used)}
    prepared['_mode7'] = {'textures': [textures[i] for i in used], 'uvs': uvs,
                         'textureIds': [remap[i] for i in tids],
                         'palette':prepared.pop('texturePalette',None)}
    if lighting in ('flat', 'gouraud'):
        prepared['_mode7']['flatLighting'] = {'faceSources': face_sources}
    if lighting == 'gouraud':
        prepared['_mode7']['gouraudLighting'] = True
        if compositor != 'A':
            prepared['_mode7']['compositor'] = compositor
    return prepared


def replace_once(s, a, b):
    if s.count(a) != 1:
        raise ValueError(f'Expected one anchor ({s.count(a)}): {a[:80]}')
    return s.replace(a, b)


def between(s, start, end, replacement):
    a = s.index(start)
    b = s.index(end, a)
    return s[:a] + replacement + s[b:]


def byte_table(name, values):
    return name + ':\n' + ''.join(' .byte '+','.join(str(v) for v in values[i:i+16])+'\n' for i in range(0,len(values),16))


def optimize_uv_edges(source):
    s=source.replace('\r\n','\n')
    for suffix in ('','_v'):
        start=s.index('gouraud_trace_shade_edge'+suffix+':\n')
        end=s.index('gouraud_store_edge_sample'+suffix+':\n',start)
        edge=s[start:end]
        a=edge.index(' sec\n lda gouraud_edge_x1\n')
        b=edge.index(' lda #$00\n sta gouraud_edge_xerr_lo',a)
        setup=' lda gouraud_edge_dy\n sta m7_den\n'
        for coord,slot in (('x','u'),('s','v')):
            setup+=f' lda gouraud_edge_{coord}0\n ldx gouraud_edge_{coord}1\n jsr m7_dda_setup\n'
            setup+=f' lda m7_q\n sta m7_{slot}step\n lda m7_r\n sta m7_{slot}rem\n lda m7_dir\n sta gouraud_edge_{coord}dir\n'
        edge=edge[:a]+setup+edge[b:]
        a=edge.index(' clc\n lda gouraud_edge_xerr_lo\n')
        b=edge.index(' inc gouraud_edge_row\n',a)
        advance=''
        for coord,slot,err in (('x','u','gouraud_edge_xerr_lo'),('s','v','gouraud_edge_serr')):
            tag='demo_edge_'+coord+suffix
            advance+=f''' clc
 lda gouraud_edge_{coord}cur
 adc m7_{slot}step
 sta gouraud_edge_{coord}cur
 clc
 lda {err}
 adc m7_{slot}rem
 bcs {tag}_correct
 cmp gouraud_edge_dy
 bcc {tag}_store
{tag}_correct:
 sec
 sbc gouraud_edge_dy
 sta {err}
 clc
 lda gouraud_edge_{coord}cur
 adc gouraud_edge_{coord}dir
 sta gouraud_edge_{coord}cur
 jmp {tag}_done
{tag}_store:
 sta {err}
{tag}_done:
'''
        edge=edge[:a]+advance+edge[b:]
        s=s[:start]+edge+s[end:]
    return s

def coherent_uv_bounds(source):
    s=source.replace('\r\n','\n')
    old='gbes_init:\n lda gouraud_vshade0\n sta leftshade,x\n sta rightshade,x\n'
    new='gbes_init:\n lda #255\n sta leftb,x\n lda #0\n sta rightb,x\n lda gouraud_vshade0\n sta leftshade,x\n sta rightshade,x\n'
    assert s.count(old)==1;s=s.replace(old,new)
    for suffix,left,right in (('','leftshade','rightshade'),('_v','m7_leftv','m7_rightv')):
        a=s.index('gouraud_store_edge_sample'+suffix+':\n')
        b=s.index('\ngouraud_fill_bounds:\n',a) if not suffix else s.index('\n; Mode 7 affine Q4.4.',a)
        begin=f'''gouraud_store_edge_sample{suffix}:
 lda gouraud_edge_row
 cmp face_ymin
 bcc seam_done{suffix}
 cmp face_ymax
 bcc seam_in_range{suffix}
 bne seam_done{suffix}
seam_in_range{suffix}:
 tax
 lda gouraud_edge_xcur
 cmp leftb,x
'''
        if not suffix:
            body=''' bcc seam_left
 bne seam_right_check
seam_left:
 sta leftb,x
 lda gouraud_edge_scur
 sta leftshade,x
seam_right_check:
 lda gouraud_edge_xcur
 cmp rightb,x
 bcc seam_done
 sta rightb,x
 lda gouraud_edge_scur
 sta rightshade,x
'''
        else:
            body=''' bne seam_right_check_v
 lda gouraud_edge_scur
 sta m7_leftv,x
seam_right_check_v:
 lda gouraud_edge_xcur
 cmp rightb,x
 bne seam_done_v
 lda gouraud_edge_scur
 sta m7_rightv,x
'''
        s=s[:a]+begin+body+f'seam_done{suffix}:\n rts\n'+s[b:]
    return s


def remove_unused_gouraud_state(source):
    """M1: data-only pruning after the Mode 7 UV backend has been emitted.

    Never apply to the shared Mode 1-6 generator. The retained byte kernel
    cannot use the scalar Bayer path, and FULL_DYNAMIC_SHADE is disabled.
    64tass still resolves every active reference: stale active users fail build.
    UV/geometry aliases (vshade, edge samples, clip shade, pair_clear) stay.
    """
    if not re.search(r'(?m)^GOURAUD_BYTE_SPAN_KERNEL = \$01$',source):
        raise ValueError('M1 requires the qualified byte-oriented UV kernel')
    if not re.search(r'(?m)^FULL_DYNAMIC_SHADE = \$00$',source):
        raise ValueError('M1 must not remove active dynamic lighting state')
    names=(['gouraud_face_shade'+str(i) for i in range(4)]+
           ['gouraud_geom_vertex','gouraud_normal_x','gouraud_normal_y','gouraud_normal_z',
            'gouraud_center_dot_lo','gouraud_center_dot_hi','gouraud_shade_value',
            'mesh_shade_first','mesh_shade_end','object_runtime_shade_first','object_runtime_shade_end',
            'gouraud_bayer4x4','gouraud_pair_01','gouraud_pair_10','gouraud_pair_11',
            'gouraud_scan_delta','gouraud_scan_dir','gouraud_scan_err','gouraud_scan_span','gouraud_scan_shade',
            'gouraud_edge_dx','gouraud_edge_sdelta',
            'shade_intensity_changed','shade_last_meshidx','shade_last_light_phase',
            'shade_last_light_intensity','shade_last_reflect_offset']+
           ['shade_last_ang'+axis+'_'+part for axis in 'xyz' for part in ('lo','hi')])
    removed={}
    for name in names:
        pattern=r'(?m)^'+name+r':(?: \.byte[^\n]*\n|\n(?: \.byte[^\n]*\n)+)'
        found=list(re.finditer(pattern,source))
        if len(found)!=1:raise ValueError('M1 data declaration changed: '+name)
        block=found[0]
        count=sum(len(line.split('.byte',1)[1].split(',')) for line in block[0].splitlines() if '.byte' in line)
        removed[name]=count
        source=source[:block.start()]+source[block.end():]
    return source,removed


def emit(doc, asm):
    meta = doc['_mode7']
    m3_carrier = asm.replace('\r\n', '\n') if meta.get('gouraudLighting') else None
    textures=meta['textures']
    repeats=list(dict.fromkeys(tuple(t['repeat']) for t in textures))
    multiple=len(textures)>1
    texture_select=''
    if multiple:
        texture_select=' lda m7_face_texture,y\n tax\n lda m7_texture_hi,x\n sta m7_fetch+2\n'
        if len(repeats)>1:
            texture_select+=' lda m7_sampler_lo,x\n sta m7_sample+1\n lda m7_sampler_hi,x\n sta m7_sample+2\n'
    s = asm.replace('\r\n', '\n')
    # Bucket rendering enters load_face_y directly, bypassing load_face's
    # reset. Never let an unclipped face reuse the previous clipped polygon.
    s=replace_once(s,'load_face_y:\n','load_face_y:\n lda #0\n sta clip_poly_active\n'
        ' sty faceidx\n jsr camera_plane_face_classify\n beq sfd_no\n ldy faceidx\n')
    # Mode 7 v1 rasterizes at logical-pixel endpoints. The carrier mixed Q2
    # original Y with integer clipped Y, opening cracks on a shared edge when
    # only one triangle was clipped. Use the same projected integer endpoint
    # for every triangle; viewport and physical/logical resolution are unchanged.
    if re.search(r'(?m)^CAMERA_MOVABLE = \$00$',s):
        for i in range(4):
            a=s.index(f' lda syq2_lo,x\n sta vyq2_{i}lo',s.index('load_face_y:\n'))
            b=s.index(f' sta vy{i}\n',a)+len(f' sta vy{i}\n')
            s=s[:a]+s[b:]
    s=replace_once(s,'load_face_y_clip:\n','load_face_y_clip:\n jsr m7_sync_clipped_xyq2\n')
    # Remove the complete dynamic per-vertex lighting calculation (not merely
    # its callers). Face normals needed for geometric culling are retained.
    s = between(s, 'gouraud_update_object_shades:\n', 'gous_done:\n rts', 'gouraud_update_object_shades:\n')
    s = s.replace(' jsr gouraud_update_object_shades\n', '')
    s = between(s, 'gouraud_load_face_raw_shades_y:\n', 'draw_loaded_face_gouraud:\n',
                'gouraud_load_face_raw_shades_y:\n' + ''.join(
                    f' lda m7_face_u{i},y\n sta gouraud_vshade{i}\n lda m7_face_v{i},y\n sta m7_v{i}\n' for i in range(3)) +
                texture_select+' rts\n'
                'gouraud_apply_face_reflectivity:\n rts\n\n')
    # All geometry clipping/copy paths transport V in parallel to the old
    # scalar attribute, now U. Duplicate only pure attribute transfers; never
    # duplicate geometry operations, calls, or face winding decisions.
    attrs = {'gouraud_vshade'+str(i): 'm7_v'+str(i) for i in range(4)}
    attrs.update({'clip_a_shade':'m7_clip_a_v','clip_b_shade':'m7_clip_b_v',
                  'gouraud_clip_shade_in':'m7_clip_v_in','gouraud_clip_shade_out':'m7_clip_v_out'})
    suffix = r'(?:\+\d+)?(?:,[xy])?'
    pat = r'(?m)^ lda (' + '|'.join(attrs) + r')'+suffix+r'\n(?: (?:ldx|ldy) [^\n]+\n)?(?: sta (?:'+'|'.join(attrs)+r')'+suffix+r'\n)+'
    def duplicate(m):
        old = m.group(0)
        new = re.sub(r'\b('+'|'.join(attrs)+r')\b', lambda n: attrs[n.group()], old)
        return new + old
    s, transfers = re.subn(pat, duplicate, s)
    if transfers < 15:
        raise ValueError('Missing clipping attribute transfer paths')
    # The raw-screen intersection path is distinct from camera-X clipping.
    # It already loads the scalar endpoints but did not append their result.
    for side,src,dst in [('right','a','b'),('left','b','a'),('top','a','b'),('bottom','b','a')]:
        start=s.index(f'clip_append_{side}_intersection_{src}_to_{dst}:\n')
        end=s.index('\n rts\n',start)
        block=s[start:end]
        block=replace_once(block,f' inc clip_{dst}_count',
            ' jsr gouraud_interp_clip_shade\n'+f' ldy clip_{dst}_count\n sta clip_{dst}_shade,y\n'
            f' lda m7_clip_v_result\n sta m7_clip_{dst}_v,y\n inc clip_{dst}_count')
        s=s[:start]+block+s[end:]
    # Polygon compaction must move attributes with the surviving positions.
    # The geometry-only carrier compactor does not transport its old scalar.
    s = replace_once(s, ' lda clip_a_y,x\n sta clip_a_y,y\ncpcsa_inc_write:',
        ' lda clip_a_y,x\n sta clip_a_y,y\n lda clip_a_shade,x\n sta clip_a_shade,y\n'
        ' lda m7_clip_a_v,x\n sta m7_clip_a_v,y\ncpcsa_inc_write:')
    fan_start=s.index('load_clip_poly_fan_triangle:\n')
    fan_end=s.index('\n.if GOURAUD_MODE6 != 0\ndraw_clip_poly_gouraud:',fan_start)
    fan=s[fan_start:fan_end]
    fan=replace_once(fan,' rts\n',' jsr m7_sync_clipped_xyq2\n rts\n')
    s=s[:fan_start]+fan+s[fan_end:]
    # Fixed-camera table projection historically stores only clamped sx/sy.
    # Supply signed pre-viewport coordinates to the existing polygon clipper.
    for axis in ('x','y'):
        anchor=f' jsr mul_s6_xpos_round\n tax\n lda proj{axis},x'
        s=s.replace(anchor,f' jsr mul_s6_xpos_round\n jsr m7_store_fixed_raw_{axis}\n tax\n lda proj{axis},x')
        for label in ('pv','pvet'):
            anchor=f'{label}_{axis}_center:\n'
            s=s.replace(anchor,anchor+f' lda #0\n jsr m7_store_fixed_raw_{axis}\n')
    # Intersections: the same scalev computed by the geometric clipper is
    # used for both channels. mul_s16_u8_frac truncates signed magnitude.
    s = between(s, 'gouraud_interp_clip_shade:\n', '\n.endif', '''gouraud_interp_clip_shade:
 sec
 lda m7_clip_v_out
 sbc m7_clip_v_in
 sta p1lo
 lda #0
 sbc #0
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 clc
 lda p1lo
 adc m7_clip_v_in
 sta m7_clip_v_result
 sec
 lda gouraud_clip_shade_out
 sbc gouraud_clip_shade_in
 sta p1lo
 lda #0
 sbc #0
 sta p1hi
 lda scalev
 jsr mul_s16_u8_frac
 clc
 lda p1lo
 adc gouraud_clip_shade_in
 rts
''')
    s, intersections = re.subn(r'( jsr gouraud_interp_clip_shade\n ldy (clip_[ab]_count)\n)( sta (clip_[ab]_shade),y\n)',
        lambda m: m[1]+' pha\n lda m7_clip_v_result\n sta '+attrs[m[4]]+',y\n pla\n'+m[3],s)
    if intersections < 4:
        raise ValueError('Missing clipping intersection paths')
    # Existing edge geometry and inclusion rules are retained. Attribute DDA
    # has a ninth error bit, needed for Q4.4 deltas up to 255 (shade was <=32).
    edge = s[s.index('gouraud_build_edge_shades:\n'):s.index('gouraud_fill_bounds:\n')]
    edge = edge.replace(' sta gouraud_edge_serr\n lda gouraud_edge_y0', ' sta gouraud_edge_serr\n sta m7_edge_errhi\n lda gouraud_edge_y0')
    edge = replace_once(edge, ' adc gouraud_edge_sdelta\n sta gouraud_edge_serr\n',
        ' adc gouraud_edge_sdelta\n sta gouraud_edge_serr\n lda #0\n adc #0\n sta m7_edge_errhi\n')
    edge = replace_once(edge, 'gtse_sstep_check:\n lda gouraud_edge_serr',
        'gtse_sstep_check:\n lda m7_edge_errhi\n bne m7_edge_sub\n lda gouraud_edge_serr')
    edge = replace_once(edge, ' bcc gtse_sstep_done\n sec\n sbc gouraud_edge_dy',
        ' bcc gtse_sstep_done\nm7_edge_sub:\n sec\n lda gouraud_edge_serr\n sbc gouraud_edge_dy')
    edge = replace_once(edge, ' sbc gouraud_edge_dy\n sta gouraud_edge_serr\n clc',
        ' sbc gouraud_edge_dy\n sta gouraud_edge_serr\n lda m7_edge_errhi\n sbc #0\n sta m7_edge_errhi\n clc')
    # V walk uses the same geometric traversal and row ownership decisions,
    # with separate endpoint/row arrays. Scratch is shared, calls sequential.
    v_edge = edge
    for old, new in attrs.items():
        v_edge = v_edge.replace(old,new)
    v_edge = v_edge.replace('leftshade','m7_leftv').replace('rightshade','m7_rightv')
    labels = re.findall(r'(?m)^(\w+):',v_edge)
    for label in sorted(labels,key=len,reverse=True):
        v_edge = re.sub(r'\b'+label+r'\b',label+'_v',v_edge)
    s = between(s,'gouraud_build_edge_shades:\n','gouraud_fill_bounds:\n',edge)
    s = s.replace(' jsr gouraud_build_edge_shades\n',' jsr gouraud_build_edge_shades\n jsr gouraud_build_edge_shades_v\n')
    # Span setup and hot loop are independent of the old Bayer/Gouraud code.
    s = between(s,' ; Select one screen-anchored Bayer row once per scanline.', 'gfb_next_restore:\n',
        ' jsr m7_prepare_span\n jsr gouraud_draw_scan_span_bytes\n')
    sync='\nm7_sync_clipped_xyq2:\n'
    for i in range(4):
        for axis in ('x','y'):
            sync+=f' lda v{axis}{i}\n sta v{axis}q2_{i}lo\n lda #0\n sta v{axis}q2_{i}hi\n'
            sync+=f' asl v{axis}q2_{i}lo\n rol v{axis}q2_{i}hi\n'*2
    sync+=' rts\n'
    s = between(s,'gouraud_draw_scan_span_bytes:\n','.endif\n.if POLY_FILL_ENABLE != 0 && HIDDEN_WIRE_ENABLE = 0',
        v_edge + Path(__file__).with_name('mode7-kernel.asm').read_text()+sync)
    # Remove no-longer-referenced dynamic lookup data to fund the UV tables.
    for name in ('gouraud_level_ptr_lo','gouraud_level_ptr_hi'):
        s = re.sub(r'(?m)^'+name+r':\n(?: \.byte[^\n]*\n)+','',s)
    s = re.sub(r'(?m)^gouraud_level_\d+:\n(?: \.byte[^\n]*\n)+','',s)
    # Separate V attributes occupy their own storage, never alias geometry.
    variables = ['m7_v0','m7_v1','m7_v2','m7_v3','m7_clip_v_in','m7_clip_v_out','m7_clip_v_result',
        'm7_edge_errhi','m7_u','m7_v','m7_ustep','m7_vstep','m7_urem','m7_vrem','m7_uerr','m7_verr',
        'm7_udir','m7_vdir','m7_den','m7_delta','m7_q','m7_r','m7_dir','m7_start','m7_index','m7_packed']
    data = '\nTEXTURE_MODE7 = 1\n'+''.join(x+': .byte 0\n' for x in variables)
    data += 'm7_clip_a_v: .fill 12,0\nm7_clip_b_v: .fill 12,0\nm7_leftv: .fill VIEWPORT_ROW_CAPACITY,0\nm7_rightv: .fill VIEWPORT_ROW_CAPACITY,0\n'
    for axis in range(2):
        for corner in range(3):
            data += byte_table('m7_face_'+('u' if axis==0 else 'v')+str(corner),[face[corner][axis] for face in meta['uvs']])
    if multiple:
        data += byte_table('m7_face_texture',meta['textureIds'])
    data += byte_table('m7_pair',[(code << (6-2*phase)) for code in range(4) for phase in range(4)])
    if multiple:
        data += 'm7_texture_hi: .byte '+','.join('>m7_texture_'+str(i) for i in range(len(textures)))+'\n'
    if len(repeats)>1:
        for part,op in [('lo','<'),('hi','>')]:
            data+='m7_sampler_'+part+': .byte '+','.join(op+'m7_sampler_'+str(repeats.index(tuple(t['repeat']))) for t in textures)+'\n'
    data += '.align 256\nm7_textures_begin = *\n'
    for i, tex in enumerate(meta['textures']):
        data += byte_table('m7_texture_'+str(i),tex['texels'])
    data += 'm7_textures_end = *\n'
    s = replace_once(s,'gouraud_bayer_code_lut_y0:\n',data+'gouraud_bayer_code_lut_y0:\n')
    s = re.sub(r'(?m)^gouraud_bayer_code_lut_y[0-3]:\n(?: \.byte[^\n]*\n)+','',s)
    s = re.sub(r'(?m)^gouraud_bayer_code_lut_row_(?:lo|hi):\n(?: \.byte[^\n]*\n)+','',s)
    s = s.replace('GOURAUD_MODE6', 'MODE7_UV_CARRIER')
    s = s.replace('GRAPHICS_MODE = $06', 'GRAPHICS_MODE = $07').replace('GRAPHICS_MODE != $06','GRAPHICS_MODE != $07')
    s=coherent_uv_bounds(optimize_uv_edges(s))
    # Specialize addressing for power-of-two tiling, no per-texel division.
    def sampler(repeat):
        ru,rv=[int(math.log2(v)) for v in repeat]
        return (' lda m7_v\n'+' asl\n'*rv+' and #$f0\n sta m7_index\n lda m7_u\n'+
                ' lsr\n'*(4-ru)+(' and #$0f\n' if ru else '')+' ora m7_index\n tay\n')
    if len(repeats)==1:
        sample_code='m7_sample:\nm7_address_begin:\n'+sampler(repeats[0])
    else:
        sample_code='m7_sample:\n jmp m7_sampler_0\nm7_address_begin:\n'
        for i,repeat in enumerate(repeats):
            sample_code+=f'm7_sampler_{i}:\n'+sampler(repeat)+' jmp m7_fetch\n'
    s=between(s,'m7_sample:\n','m7_fetch:\n',sample_code)
    # Optional shared scene palette. VIC-II cell colors cannot independently
    # represent arbitrary palettes for overlapping textured faces.
    if meta.get('palette') is not None:
        dark,high,highlight=meta['palette']
        for name,value in [('material_screen_bytes',dark*16+high),('material_color_bytes',highlight)]:
            pattern=r'(?m)^'+name+r':\n(?: \.byte[^\n]*\n)+'
            block=re.search(pattern,s)
            if block is None:raise ValueError('Missing static material palette: '+name)
            count=len(re.findall(r'\$[0-9A-Fa-f]{2}',block[0]))
            s=s[:block.start()]+byte_table(name,[value]*count)+s[block.end():]
    s,m1_removed=remove_unused_gouraud_state(s)
    if meta.get('flatLighting'):
        from mode7_lighting import emit_flat_lighting
        s = emit_flat_lighting(s, meta['flatLighting']['faceSources'])
    if m3_carrier is not None:
        from mode7_gouraud import emit_gouraud
        s = emit_gouraud(s, m3_carrier, meta.get('compositor', 'A'))
    return s, {'memoryGateM1':{'removedData':m1_removed,'removedDataBytes':sum(m1_removed.values())},
               'attributeTransfers':transfers,'clipIntersectionSites':intersections,
               'texturesBytes':256*len(textures),'faceUVBytes':6*len(meta['uvs']),
               'textureIndexBytes':len(meta['uvs']) if multiple else 0,
               'texturePageTableBytes':len(textures) if multiple else 0,
               'samplerDispatchTableBytes':2*len(textures) if len(repeats)>1 else 0,
               'uvExtraScratchBytes':len(variables)+224,'triangles':len(meta['uvs']),
               'samplerVariants':len(repeats),'textureRepeat':repeats,'coherentEdges':True}


if __name__ == '__main__':
    action, src, dst = sys.argv[1:]
    if action == 'prepare':
        try:
            result = prepare_scene(json.loads(Path(src).read_text(encoding='utf-8-sig')), Path(src).resolve().parent)
        except (ValueError, OSError) as error:
            print(f'Mode 7 scene {src}: {error}', file=sys.stderr)
            sys.exit(2)
        Path(dst).write_text(json.dumps(result),encoding='utf-8')
    elif action == 'emit':
        result, report = emit(json.loads(Path(src).read_text(encoding='utf-8-sig')),Path(dst).read_text())
        Path(dst).write_text(result,encoding='ascii')
        Path(dst).with_suffix('.mode7.json').write_text(json.dumps(report,indent=2))
    else:
        raise ValueError(action)
