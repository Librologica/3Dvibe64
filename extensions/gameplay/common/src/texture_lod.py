"""Opt-in approximate whole-face material LOD on the qualified two-room ABI.

Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. No change to geometry, palette requests or light.
"""
from collections import Counter
from optimizations import once

def apply(source,scene,options):
    assert 'op_uniform_select:\n' in source,'Requires property-based uniform path'
    enter=options['enter'];leave=options['leave'];guard=options.get('footprintGuard',False)
    assert isinstance(enter,int) and isinstance(leave,int) and 1<leave<enter<256
    pigments=[]
    for texture in scene['textures']:
        texels=texture['texels']
        assert len(texels)==256 and set(texels)<=set((1,2,3))
        # Modal source pigment, deterministic tie-breaking; NOT RGB averaging.
        counts=Counter(texels)
        pigments.append(min(counts,key=lambda value:(-counts[value],value)))
    source=once(source,'op_uniform_select:\n lda op_texture_constant,x\n',
                'op_uniform_select:\n jsr lod_select\n')
    code=f'''*=$fe60
lod_code_begin:
lod_select:
 lda op_texture_constant,x
 bne lod_return
 stx lod_texture
 sty lod_face
 lda lod_history,y
 beq lod_enter
 lda #{leave}
 bne lod_threshold_ready
lod_enter:
 lda #{enter}
lod_threshold_ready:
 sta lod_threshold
'''
    if guard:code+=''' lda #255
 sta lod_minx
 sta lod_miny
 lda #0
 sta lod_maxx
 sta lod_maxy
'''
    for i in range(4):
        if i==3:code+=''' lda face_vertex_count,y
 cmp #4
 bcc lod_vertices_done
'''
        code+=f''' lda face{i},y
 tax
 jsr lod_vertex
 bcc lod_near
'''
    code+='''lod_vertices_done:
'''
    if guard:code+=''' sec
 lda lod_maxx
 sbc lod_minx
 cmp #97
 bcs lod_near
 sec
 lda lod_maxy
 sbc lod_miny
 cmp #65
 bcs lod_near
'''
    code+=''' lda #1
 sta lod_history,y
 ldx lod_texture
 lda lod_pigment,x
 rts
lod_near:
 lda #0
 sta lod_history,y
 ldx lod_texture
 lda #0 ; Return Z consistent with A, not with the restored texture index.
lod_return:
 rts
lod_vertex:
 ; Camera-space Q16.8 depth; reject negatives, behind and small denominators.
 lda hc_cam_z2,x
 bmi lod_vertex_near
 bne lod_vertex_depth_ok
 lda hc_cam_z1,x
 cmp lod_threshold
 bcc lod_vertex_near
lod_vertex_depth_ok:
'''
    if guard:
        code+=''' ; Fully-inside projected bbox only. Uncertain/offscreen -> original.
 lda tq_cache_x2,x
 ora tq_cache_y2,x
 bne lod_vertex_near
 lda tq_cache_x1,x
 cmp #160
 bcs lod_vertex_near
 cmp lod_minx
 bcs lod_xmin_done
 sta lod_minx
lod_xmin_done:
 cmp lod_maxx
 bcc lod_xmax_done
 sta lod_maxx
lod_xmax_done:
 lda tq_cache_y1,x
 cmp #100
 bcs lod_vertex_near
 cmp lod_miny
 bcs lod_ymin_done
 sta lod_miny
lod_ymin_done:
 cmp lod_maxy
 bcc lod_ymax_done
 sta lod_maxy
lod_ymax_done:
'''
    code+=''' sec
 rts
lod_vertex_near:
 clc
 rts
lod_code_end:
 .cerror * > $fff0,"LOD code touches vectors"
 .cerror op_backface_end > lod_code_begin,"LOD code overlaps backface"
*=$e8b0
lod_state_begin:
lod_history: .fill FACE_COUNT,0
lod_texture: .byte 0
lod_face: .byte 0
lod_threshold: .byte 0
lod_minx: .byte 0
lod_maxx: .byte 0
lod_miny: .byte 0
lod_maxy: .byte 0
lod_pigment: .byte '''+','.join(map(str,pigments))+'''
lod_state_end:
 .cerror * > $e900,"LOD state touches carrier helpers"
 .cerror op_rows_end > lod_state_begin,"LOD state overlaps row helpers"
 .cerror FACE_COUNT != 64,"Requalify the frozen two-room ABI"
'''
    return source+code
