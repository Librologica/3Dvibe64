"""Mode-dependent NF geometry ABI. Raster/shader code is inherited unchanged.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0.
"""
from normalized import copy,load,negate,add

def change(s,a,b):
    assert s.count(a)==1,(a,s.count(a));return s.replace(a,b)

def place(sizes,gaps):
    items=sorted(sizes.items(),key=lambda p:-p[1]);seen=set();nodes=0
    def solve(i,free,placed):
        nonlocal nodes
        nodes+=1
        if nodes>100000:return None
        if i==len(items):return placed,free
        key=(i,tuple(sorted(free)))
        if key in seen:return None
        seen.add(key);name,size=items[i];align=256 if name=='tables' else 2
        need=size+(0 if name in ('tables','data') else 32);choices=[]
        for j,(a,b) in enumerate(free):
            start=(a+align-1)//align*align
            if start+need<=b:choices.append((b-start-need,j,start))
        for _,j,start in sorted(choices):
            a,b=free[j];rest=free[:j]+free[j+1:]
            if a<start:rest.append((a,start))
            if start+need<b:rest.append((start+need,b))
            result=solve(i+1,rest,{**placed,name:(start,start+need)})
            if result:return result
        return None
    result=solve(0,gaps,{})
    if result:return result
    raise ValueError(('NF allocation cannot fit',sizes,gaps))

def extend(p,lab):
    mode=lab['GRAPHICS_MODE']
    p['normalized_data']+='nf_source_count: .byte 0\n'
    c=p['clip']
    c=change(c,' lda #4\n sta hc_count\n sta nf_count\n sta loaded_face_vertex_count\n',
             ' ldy sortj\n.if HAS_TRI_FACES != 0\n lda face_vertex_count,y\n.else\n lda #4\n.endif\n sta nf_source_count\n sta hc_count\n sta nf_count\n sta loaded_face_vertex_count\n')
    assert c.count(' cmp #4\n')==2
    c=c.replace(' cmp #4\n',' cmp nf_source_count\n')
    c=change(c,' sta clip_poly_active\n',' sta clip_poly_active\n sta hc_changed\n') if c.count(' sta clip_poly_active\n')==1 else c.replace(' sta clip_poly_active\n lda #31',' sta clip_poly_active\n sta hc_changed\n lda #31')
    c=change(c,'nf_clip_begin:\n lda #1\n sta clip_poly_active\n','nf_clip_begin:\n lda #1\n sta clip_poly_active\n sta hc_changed\n')
    p['clip']=c
    if mode<=2:
        p['wire_clip']=wire_edge(p['clip'])
        from pathlib import Path
        wide=(Path(__file__).parent/'wide.asm').read_text()
        p['wire_division']=wide[wide.index('hc_div40:'):wide.index('; trunc(delta_s16')]
    if mode in (6,7):
        attrs=[('s','gouraud_vshade0')]
        if mode==7:attrs+=[('v','m7_v0')]+([('q','m3_q0')] if 'm3_q0' in lab else [])
        attribute_parts(p,attrs,mode)
    if mode==7:
        p['normalized_matrix']=compact_matrix_code()
        p.pop('texture_helpers',None);p.pop('full_projection',None)
        p['clip_helpers']=p['clip_helpers'].replace('GOURAUD_MODE6','MODE7_UV_CARRIER')
        from screen import arithmetic
        code=arithmetic();p['raster_ratio']=code[code.index('hq_ratio_product:'):code.index('hq_quantize_poly:')]
        from pathlib import Path
        wide=(Path(__file__).parent/'wide.asm').read_text()
        p['raster_division']=wide[wide.index('hc_div40:'):wide.index('; trunc(delta_s16')]
    return p

def compact_matrix_code():
    # Preserve all products/rounding/order; share operand transfers to fit RAM.
    # Main-thread p1 pointer only, no SMC or ISR access. 36 setup products.
    import normalized
    original=normalized.product;products=[]
    def compact(a,b,d):
        index=len(products);products.append((a,b,d))
        return f' ldx #{index}\n jsr nf_compact_product\n'
    normalized.product=compact
    try:code=normalized.matrix()
    finally:normalized.product=original
    code+='nf_compact_product:\n stx nf_compact_index\n'
    for channel,dst in (('a','hp_a'),('b','hp_b')):
        code+=f' lda nf_product_{channel}lo,x\n sta p1lo\n lda nf_product_{channel}hi,x\n sta p1hi\n ldy #0\n lda (p1lo),y\n sta {dst}\n iny\n lda (p1lo),y\n sta {dst}+1\n'
    code+=' jsr hp_q8\n ldx nf_compact_index\n lda nf_product_dlo,x\n sta p1lo\n lda nf_product_dhi,x\n sta p1hi\n ldy #0\n lda hp_r\n sta (p1lo),y\n iny\n lda hp_r+1\n sta (p1lo),y\n rts\nnf_compact_index: .byte 0\n'
    for j,ch in enumerate('abd'):
        for part,op in (('lo','<'),('hi','>')):code+=f'nf_product_{ch}{part}: .byte '+','.join(op+p[j] for p in products)+'\n'
    return code

def wire_edge(poly):
    s='''; Original edge only: homogeneous clipping never invents cap edges.
qw_clip_edge:
 lda #0
 sta nf_poly_index
 lda #31
 sta nf_and
 lda #0
 sta nf_or
nf_edge_load:
 ldy nf_poly_index
 lda qw_v0,y
 tax
 lda nf_vertex_exp,x
 sta nf_exp
 lda nf_outcodes,x
 ora nf_or
 sta nf_or
 lda nf_outcodes,x
 and nf_and
 sta nf_and
'''
    for ax in 'xyz':
        for part in ('lo','hi'):s+=f' lda nf_v{ax}{part},x\n sta nf_a_{ax}{part},y\n'
    s+=''' inc nf_poly_index
 lda nf_poly_index
 cmp #2
 bne nf_edge_load
 lda hp_fault
 ora nf_and
 bne nf_edge_empty
 jsr nf_set_near
 lda nf_or
 bne nf_edge_clip_begin
 lda #0
 sta nf_poly_index
nf_edge_cached:
 ldy nf_poly_index
 lda qw_v0,y
 tax
'''
    for ax in 'xy':
        for i,part in enumerate(('lo','hi')):s+=f' lda s{ax}q2_{part},x\n sta hc_a_{ax}{part},y\n'
    s+=''' inc nf_poly_index
 lda nf_poly_index
 cmp #2
 bne nf_edge_cached
 jmp nf_edge_commit
nf_edge_clip_begin:
 lda #0
 sta nf_plane
 sta nf_prev
 lda #1
 sta nf_cur
nf_edge_plane:
 ldx #0
 jsr nf_load_a
 jsr nf_distance
'''+copy('nf_d','nf_prev_d',4)+''' ldx #1
 jsr nf_load_a
 jsr nf_distance
'''+copy('nf_d','nf_cur_d',4)+''' lda nf_prev_d+3
 and nf_cur_d+3
 bmi nf_edge_empty
 lda nf_prev_d+3
 eor nf_cur_d+3
 bpl nf_edge_next_plane
 jsr nf_intersection
 ldy nf_from
'''
    for ax in 'xyz':
        for i,part in enumerate(('lo','hi')):s+=f' lda nf_out_{ax}+{i}\n sta nf_a_{ax}{part},y\n'
    s+='''nf_edge_next_plane:
 inc nf_plane
 lda nf_plane
 cmp #5
 bne nf_edge_plane
 lda #2
 sta hc_count
 lda #0
 sta nf_poly_index
'''
    # Shared generator of endpoint projection; different entry/exit, no winding.
    project=poly[poly.index('nf_project_polygon:'):poly.index('nf_face_finish:')]
    project=project.replace('nf_project_polygon','nf_edge_project')
    for ax in 'xy':project=project.replace('nf_poly_'+ax+'_','nf_edge_'+ax+'_')
    s+=project+'nf_edge_commit:\n'
    for ax in 'xy':
        for n in range(2):
            for i,part in enumerate(('lo','hi')):s+=f' lda hc_a_{ax}{part}+{n}\n sta qw_{ax}{n}+{i}\n'
    return s+' sec\n rts\nnf_edge_empty:\n clc\n rts\n'

def attribute_parts(p,attrs,mode):
    # Screen-affine attributes: near uses camera t, frustum uses projected lambda.
    # lambda=t*z_to/z_intersection, i.e. same screen-space linear convention
    # as the inherited Gouraud/affine-UV pipeline, without reprojecting edges.
    c=p['clip'];c=change(c,' sty sortj\n',' sty sortj\n jsr gouraud_load_face_raw_shades_y\n ldy sortj\n')
    c=change(c,' ldx hc_face_vertices,y\n lda nf_vertex_exp,x\n',
             ' jsr nf_load_attributes\n ldy nf_poly_index\n ldx hc_face_vertices,y\n lda nf_vertex_exp,x\n')
    c=change(c,'nf_face_finish:\n jsr hc_commit_poly\n','nf_face_finish:\n jsr nf_commit_attributes\n jsr hc_commit_poly\n')
    c=change(c,' jsr nf_append_b\nnf_clip_next:\n',' jsr nf_copy_attributes\n jsr nf_append_b\nnf_clip_next:\n')
    a=c.index('nf_copy_back:');b=c.index(' inx\n jmp nf_copy_back',a)
    extra=''.join(f' lda nf_b_{att}{part},x\n sta nf_a_{att}{part},x\n' for att,_ in attrs for part in ('lo','hi'))
    c=c[:b]+extra+c[b:]
    c=change(c,'nf_append_b:\n ldy nf_out_count\n','nf_append_b:\n jsr nf_append_attributes\n ldy nf_out_count\n')
    p['clip']=c
    i=p['normalized_intersection']
    i=change(i,' rts\nnf_ratio_needed:',' jsr nf_copy_attributes\n rts\nnf_ratio_needed:')
    assert i.endswith('+\n rts\n')
    p['normalized_intersection']=i[:-len('+\n rts\n')]+'+\n jsr nf_interpolate_attributes\n rts\n'
    s='nf_load_attributes:\n ldy nf_poly_index\n'
    for att,raw in attrs:s+=f' lda {raw},y\n sta nf_a_{att}hi,y\n lda #0\n sta nf_a_{att}lo,y\n'
    s+=' rts\nnf_copy_attributes:\n'
    for att,_ in attrs:
        for k,part in enumerate(('lo','hi')):s+=f' lda nf_a_{att}{part},x\n sta nf_out_{att}+{k}\n'
    s+=' rts\nnf_append_attributes:\n ldy nf_out_count\n'
    for att,_ in attrs:
        for k,part in enumerate(('lo','hi')):s+=f' lda nf_out_{att}+{k}\n sta nf_b_{att}{part},y\n'
    s+=' rts\nnf_commit_attributes:\n ldx #0\n-\n cpx hc_count\n beq +\n'
    for att,_ in attrs:
        for part in ('lo','hi'):s+=f' lda nf_a_{att}{part},x\n sta hc_a_{att}{part},x\n'
    s+=' inx\n jmp -\n+\n rts\nnf_interpolate_attributes:\n lda nf_plane\n beq nf_attr_ratio_ready\n'
    s+=copy('nf_ratio_value','nf_a')+' ldx nf_to\n lda nf_a_zlo,x\n sta nf_b\n lda nf_a_zhi,x\n sta nf_b+1\n jsr nf_umultiply\n'+copy('nf_product','nf_rem',4)
    s+=' lda #0\n sta nf_den\n sta nf_den+1\n'+copy('nf_out_z','nf_den+2')
    # Geometry rounding can lower z_intersection slightly; clamp lambda <=1.
    for k in reversed(range(4)):s+=f' lda nf_rem+{k}\n cmp nf_den+{k}\n bcc nf_attr_divide\n bne nf_attr_clamp\n'
    s+='nf_attr_clamp:\n'+load(65535,'nf_ratio_value')+' jmp nf_attr_ratio_ready\nnf_attr_divide:\n jsr nf_ratio\nnf_attr_ratio_ready:\n'
    for att,_ in attrs:
        s+=f' ldx nf_to\n ldy nf_from\n sec\n lda nf_a_{att}lo,x\n sbc nf_a_{att}lo,y\n sta nf_a\n lda nf_a_{att}hi,x\n sbc nf_a_{att}hi,y\n sta nf_a+1\n lda #0\n sbc #0\n sta nf_delta_sign\n bpl +\n'
        s+=negate('nf_a',2)+'+\n'+copy('nf_ratio_value','nf_b')+' jsr nf_umultiply\n clc\n lda nf_product+1\n adc #128\n sta nf_product+1\n lda nf_product+2\n adc #0\n sta nf_product+2\n lda nf_product+3\n adc #0\n sta nf_product+3\n lda nf_delta_sign\n bpl +\n'+negate('nf_product+2',2)+'+\n ldy nf_from\n clc\n'
        for k,part in enumerate(('lo','hi')):s+=f' lda nf_a_{att}{part},y\n adc nf_product+{k+2}\n sta nf_out_{att}+{k}\n'
    s+=' rts\n'
    p['nf_attributes']=s
    for att,_ in attrs:
        for bank in 'ab':
            for part in ('lo','hi'):p['normalized_data']+=f'nf_{bank}_{att}{part}: .fill 12,0\n'
        p['normalized_data']+=f'nf_out_{att}: .word 0\n'
