"""Detect uniform runtime texture pages, never a hardcoded material/texture ID.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0.
"""
import re
from perspective_exact import once

def apply(source,parts,lab,byte):
    pages=sorted((int(m[1]),name) for name in lab if (m:=re.fullmatch(r'm7_texture_(\d+)',name)))
    assert [i for i,_ in pages]==list(range(len(pages)))
    pigments=[]
    for _,name in pages:
        pixels=[byte(name,j) for j in range(256)]
        assert all(p in (1,2,3) for p in pixels)
        pigments.append(pixels[0] if all(p==pixels[0] for p in pixels) else 0)
    if not any(pigments):return source,parts,pigments
    # UV loading is per original face, before clipping. Preserve Y.
    select=(' lda m7_face_texture,y\n tax\n lda pu_textures,x\n' if len(pages)>1 else f' lda #{pigments[0]}\n')+' sta pu_texel\n'
    source=once(source,'gouraud_load_face_raw_shades_y:\n','gouraud_load_face_raw_shades_y:\n'+select)
    parts['data']+='pu_texel: .byte 0\npu_textures: .byte '+','.join(map(str,pigments))+'\n'
    # The existing address/fetch remains exact for all256 entries. Skip only
    # division/carrier DDA; uniform textures do not consume those attributes.
    p=parts['perspective_sample']
    parts['perspective_sample']=once(p,'ps_sample:\n','ps_sample:\n lda pu_texel\n beq pu_sample_general\n rts\npu_sample_general:\n')
    p=parts['perspective_span']
    p=once(p,'ps_prepare_span:\n','ps_prepare_span:\n lda pu_texel\n beq pu_prepare_general\n jmp pu_prepare\npu_prepare_general:\n')
    p=once(p,'ps_advance:\n','ps_advance:\n lda pu_texel\n beq pu_advance_general\n jmp pu_advance\npu_advance_general:\n')
    shaded='m3_q0:' in source
    flat='m2_update_face_lighting:' in source
    extra='pu_prepare:\n'+(' jsr m3_prepare_span\n' if shaded else '')
    if shaded or flat:extra+=' lda yrow\n and #3\n asl\n asl\n sta m2_bayer_row\n'
    extra+=''' lda leftval
 sta gouraud_scan_x
 lda rightval
 sta gouraud_scan_end
 ldx yrow
 lda tq_closed,x
 bne pu_span_closed
 dec gouraud_scan_end
pu_span_closed:
 rts
pu_advance:
'''+(' jsr m3_advance_q\n' if shaded else '')+' inc gouraud_scan_x\n rts\n'
    parts['perspective_span']=p+extra
    return source,parts,pigments
