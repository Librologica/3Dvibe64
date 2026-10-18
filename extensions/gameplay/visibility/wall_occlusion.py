"""Opt-in conservative whole-wall rejection for a caller-supplied Q8 adapter.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
Opaque vertical convex quad pairs, upper local Y positive/lower negative;
all four vertices front of near, both triangles collected; strict painter order.
No automatic scene classification, scene construction or fixed RAM placement.
"""
from pathlib import Path
import sys,math,re
sys.path.insert(0,str(Path(__file__).resolve().parents[3]/'work/q8/src'))
from perspective_exact import once

KERNEL_SETUP = 'oc_reset:\n ldx #RO_FACE_COUNT-1\n lda #255\n-\n sta oc_depth,x\n dex\n bpl -\n rts\noc_build:\n inc oc_frames\n bne +\n inc oc_frames+1\n+\n lda #0\n sta oc_frame_culled\n sta oc_q\noc_quad:\n ldx oc_q\n lda #0\n sta oc_hidden,x\n sta oc_box_right,x\n sta oc_box_bottom,x\n sta oc_tmax\n sta oc_ty\n sta oc_bmax\n lda #255\n sta oc_near,x\n sta oc_far,x\n sta oc_box_left,x\n sta oc_box_top,x\n sta oc_tmin\n sta oc_bmin\n sta oc_by\n ldy oc_first,x\n lda oc_depth,y\n cmp #255\n beq oc_next_quad\n sta oc_near,x\n sta oc_far,x\n lda face0,y\n sta oc_v\n lda face1,y\n sta oc_v+1\n lda face2,y\n sta oc_v+2\n iny\n lda face2,y\n sta oc_v+3\n lda oc_depth,y\n cmp #255\n beq oc_invalid\n cmp oc_near,x\n bcs +\n sta oc_near,x\n+\n cmp oc_far,x\n bcc +\n sta oc_far,x\n+\n lda #0\n sta oc_i\noc_vertices:\n ldx oc_i\n lda oc_v,x\n tax\n lda projdone,x\n beq oc_invalid\n ldy oc_q\n lda sx,x\n cmp oc_box_left,y\n bcs +\n sta oc_box_left,y\n+\n cmp oc_box_right,y\n bcc +\n sta oc_box_right,y\n+\n lda sy,x\n cmp oc_box_top,y\n bcs +\n sta oc_box_top,y\n+\n cmp oc_box_bottom,y\n bcc +\n sta oc_box_bottom,y\n+\n jsr oc_vertex_groups\n inc oc_i\n lda oc_i\n cmp #4\n bne oc_vertices\n jsr oc_make_rect\n jmp oc_next_quad\noc_invalid:\n ldx oc_q\n lda #255\n sta oc_near,x\n sta oc_far,x\noc_next_quad:\n inc oc_q\n lda oc_q\n cmp #RO_QUAD_COUNT\n bne oc_quad\n jmp oc_compare_all\n'
KERNEL_GEOMETRY = 'oc_vertex_groups:\n ldy vert_yi,x\n lda ycoord,y\n bmi oc_bottom_vertex\n lda sx,x\n cmp oc_tmin\n bcs +\n sta oc_tmin\n+\n cmp oc_tmax\n bcc +\n sta oc_tmax\n+\n lda sy,x\n cmp oc_ty\n bcc +\n sta oc_ty\n+\n rts\noc_bottom_vertex:\n lda sx,x\n cmp oc_bmin\n bcs +\n sta oc_bmin\n+\n cmp oc_bmax\n bcc +\n sta oc_bmax\n+\n lda sy,x\n cmp oc_by\n bcs +\n sta oc_by\n+\n rts\noc_make_rect:\n ldx oc_q\n lda oc_tmin\n cmp oc_bmin\n bcs +\n lda oc_bmin\n+\n clc\n adc #5\n sta oc_left,x\n lda oc_tmax\n cmp oc_bmax\n bcc +\n lda oc_bmax\n+\n sec\n sbc #5\n bcc oc_bad_rect\n sta oc_right,x\n cmp oc_left,x\n bcc oc_bad_rect\n lda oc_ty\n clc\n adc #5\n sta oc_top,x\n lda oc_by\n sec\n sbc #5\n bcc oc_bad_rect\n sta oc_bottom,x\n cmp oc_top,x\n bcc oc_bad_rect\n rts\noc_bad_rect:\n lda #255\n sta oc_far,x\n rts\n'
KERNEL_COMPARE = 'oc_compare_all:\n lda #0\n sta oc_q\noc_target:\n ldy oc_q\n lda oc_near,y\n cmp #255\n beq oc_compare_next\n ldx #0\noc_occluder:\n lda oc_far,x\n cmp oc_near,y\n bcs oc_continue\n lda oc_box_left,y\n cmp oc_left,x\n bcc oc_continue\n lda oc_right,x\n cmp oc_box_right,y\n bcc oc_continue\n lda oc_box_top,y\n cmp oc_top,x\n bcc oc_continue\n lda oc_bottom,x\n cmp oc_box_bottom,y\n bcc oc_continue\n lda #1\n sta oc_hidden,y\n inc oc_frame_culled\n inc oc_culled_total\n bne oc_compare_next\n inc oc_culled_total+1\n jmp oc_compare_next\noc_continue:\n inx\n cpx #RO_QUAD_COUNT\n bne oc_occluder\noc_compare_next:\n inc oc_q\n lda oc_q\n cmp #RO_QUAD_COUNT\n bne oc_target\n rts\noc_hidden_face:\n ldx oc_face_quad,y\n cpx #255\n beq oc_keep\n lda oc_hidden,x\n beq oc_keep\n sec\n rts\noc_keep:\n clc\n rts\n'


def attach(source,parts,*,face_count,first_faces,draw_part=None,opaque_vertical_contract=False,palette_indices=None):
    """Adapter must validate all variants of its wall geometry and opacity.

    first_faces identifies disjoint consecutive triangle pairs [a,b,c],[a,c,d].
    The adapter owns shader stability and a camera confined between wall planes.
    Unknown/near-clipped/partial/tied cases are kept by the native kernel.
    """
    if not opaque_vertical_contract:raise ValueError('WALL_OCCLUSION: validated opaque vertical wall contract required')
    for label in ('material_screen_bytes','material_color_bytes'):
        match=re.search(r'(?m)^'+label+r':\n((?: \.byte[^\n]*\n)+)',source)
        if match is None:raise ValueError('WALL_OCCLUSION: shared palette table required: '+label)
        values=[int(v[1:],16) if v.startswith('$') else int(v) for v in re.findall(r'\$[0-9a-fA-F]+|\d+',match[1])]
        selected=values
        if palette_indices is not None:
            if not isinstance(palette_indices,(list,tuple)) or not palette_indices or any(type(i)is not int or not 0<=i<len(values) for i in palette_indices):raise ValueError('WALL_OCCLUSION: invalid reachable palette entry set')
            selected=[values[i] for i in palette_indices]
        if not selected or len(set(selected))!=1:raise ValueError('WALL_OCCLUSION: immutable shared VIC palette required')
    if type(face_count)is not int or not 2<=face_count<=128:raise ValueError('WALL_OCCLUSION: 2..128 runtime faces required')
    if not isinstance(first_faces,(list,tuple)) or not 1<=len(first_faces)<=64:raise ValueError('WALL_OCCLUSION: 1..64 pairs required')
    mapping=[255]*face_count
    for q,f in enumerate(first_faces):
        if type(f)is not int or not 0<=f<face_count-1 or mapping[f]!=255 or mapping[f+1]!=255:raise ValueError('WALL_OCCLUSION: invalid/overlapping triangle pair')
        mapping[f]=mapping[f+1]=q
    if draw_part is not None and draw_part not in parts:raise ValueError('WALL_OCCLUSION: adapter draw part missing')
    source=once(source,'begin_depth_buckets:\n','begin_depth_buckets:\n jsr oc_reset\n')
    source=once(source,' sta bucket_head,x\n rts\n',' sta bucket_head,x\n pha\n txa\n sta oc_depth,y\n pla\n rts\n')
    if draw_part is None:source=once(source,'draw_depth_buckets:\n','draw_depth_buckets:\n jsr oc_build\n')
    else:parts[draw_part]=once(parts[draw_part],'draw_depth_buckets:\n','draw_depth_buckets:\n jsr oc_build\n')
    source=once(source,'ddb_face_loop:\n','ddb_face_loop:\n ldy sortj\n jsr oc_hidden_face\n bcc +\n jmp ddb_after_draw\n+\n')
    data=f'RO_FACE_COUNT={face_count}\nRO_QUAD_COUNT={len(first_faces)}\noc_depth: .fill {face_count},255\n'
    for name in ['left','right','top','bottom','box_left','box_right','box_top','box_bottom','near','far','hidden']:
        data+=f'oc_{name}: .fill {len(first_faces)},0\n'
    data+='oc_first: .byte '+','.join(map(str,first_faces))+'\noc_face_quad: .byte '+','.join(map(str,mapping))+'\noc_v: .fill 4,0\n'
    for name in ['q','i','tmin','tmax','ty','bmin','bmax','by','frame_culled']:data+=f'oc_{name}: .byte 0\n'
    parts['data']+=data+'oc_culled_total: .word 0\noc_frames: .word 0\n'
    for name,body in [('setup',KERNEL_SETUP),('geometry',KERNEL_GEOMETRY),('compare',KERNEL_COMPARE)]:
        parts['wall_occlusion_'+name]=body
    return source,parts


def validate_quads(vertices,triangles,first_faces):
    """Validate each local-space variant before asserting the adapter contract.
    Four distinct vertices; [a,b,c],[a,c,d]; axis-aligned vertical rectangle;
    exactly two Y planes straddling zero. Opacity/camera bounds remain caller
    obligations and cannot be inferred from geometry alone.
    """
    if not vertices or not triangles:raise ValueError('Wall geometry required')
    for f in first_faces:
        if type(f)is not int or not 0<=f<len(triangles)-1:raise ValueError('Invalid wall face index')
        a,b=triangles[f:f+2]
        if len(a)!=3 or len(b)!=3 or a[0]!=b[0] or a[2]!=b[1]:raise ValueError('Wall triangle diagonal/order mismatch')
        ids=[*a,b[2]]
        if len(set(ids))!=4 or any(type(i)is not int or not 0<=i<len(vertices) for i in ids):raise ValueError('Wall requires four distinct valid vertices')
        points=[vertices[i] for i in ids]
        if any(len(p)!=3 or any(type(v)not in (int,float) or not math.isfinite(v) for v in p) for p in points):raise ValueError('Invalid wall coordinate')
        if len({tuple(p) for p in points})!=4:raise ValueError('Four distinct coordinate positions required')
        ys=sorted({p[1] for p in points});xs={p[0] for p in points};zs={p[2] for p in points}
        if len(ys)!=2 or not ys[0]<0<ys[1] or not ((len(xs)==1 and len(zs)==2) or (len(zs)==1 and len(xs)==2)):raise ValueError('Vertical rectangle across positive/negative Y required')
        if not (points[0][1]==points[1][1] and points[2][1]==points[3][1] and points[0][1]!=points[2][1]):raise ValueError('Ordered convex wall rectangle required')
        if any(sum(p[1]==y for p in points)!=2 for y in ys):raise ValueError('Two top and two bottom vertices required')
    return True
