"""Two-object opt-in. Keep all single-object emissions byte-identical."""
import math


def metadata(lab,byte,vertices):
    ranges=[];owned=set();faces_owned=set();edges_owned=set()
    for obj in range(lab['SCENE_OBJECT_COUNT']):
        mesh=byte('object_mesh',obj)
        first,end=byte('mesh_vfirst',mesh),byte('mesh_vend',mesh)
        if not 0<=first<end<=lab['VERT_COUNT']:
            raise ValueError('Q8_OBJECT_VERTEX_RANGE')
        indexes=set(range(first,end))
        if owned & indexes:raise ValueError('Q8_SHARED_VERTEX_RANGE_UNQUALIFIED')
        owned|=indexes
        scale=byte('object_scale',obj)
        radius=max(math.sqrt(sum(n*n for n in v)) for v in vertices[first:end])*scale/64
        if radius>40:raise ValueError(f'Q8_GEOMETRY_DOMAIN: object {obj}, radius {radius:.3f} > 40 WU')
        ffirst,fend=byte('mesh_face_first',mesh),byte('mesh_face_end',mesh)
        faces=set(range(ffirst,fend))
        if not 0<=ffirst<=fend<=lab['FACE_COUNT'] or faces & faces_owned:
            raise ValueError('Q8_OBJECT_FACE_RANGE')
        if ffirst==fend and lab['GRAPHICS_MODE']!=1:raise ValueError('Q8_EMPTY_FACE_RANGE')
        for f in faces:
            n=byte('face_vertex_count',f) if 'face_vertex_count' in lab else 4
            if any(byte(f'face{k}',f) not in indexes for k in range(n)):
                raise ValueError('Q8_CROSS_OBJECT_FACE_VERTEX')
        faces_owned|=faces
        ranges.append(dict(object=obj,mesh=mesh,first=first,end=end,scaleQ6=scale,
                           radiusWU=radius,faceFirst=ffirst,faceEnd=fend))
        if lab['GRAPHICS_MODE']==1 or (lab['GRAPHICS_MODE']==2 and 'mesh_edge_first' in lab):
            efirst,eend=byte('mesh_edge_first',mesh),byte('mesh_edge_end',mesh)
            edges=set(range(efirst,eend))
            if not 0<=efirst<eend<=lab['WIRE_EDGE_COUNT'] or edges & edges_owned:
                raise ValueError('Q8_OBJECT_EDGE_RANGE')
            if any(byte(f'edge{k}',e) not in indexes for e in edges for k in range(2)):
                raise ValueError('Q8_CROSS_OBJECT_EDGE_VERTEX')
            edges_owned|=edges
            ranges[-1].update(edgeFirst=efirst,edgeEnd=eend)
    if owned!=set(range(lab['VERT_COUNT'])):raise ValueError('Q8_UNOWNED_VERTEX_RANGE')
    if faces_owned!=set(range(lab['FACE_COUNT'])):raise ValueError('Q8_UNOWNED_FACE_RANGE')
    if 'mesh_edge_first' in lab and lab['GRAPHICS_MODE'] in (1,2) and edges_owned!=set(range(lab['WIRE_EDGE_COUNT'])):
        raise ValueError('Q8_UNOWNED_EDGE_RANGE')
    return ranges


def change(text,old,new,count=1):
    assert text.count(old)==count,(old,text.count(old),count)
    return text.replace(old,new)


def adapt(parts):
    p=parts.copy()
    # set_active_object has already copied the current object's full angle and
    # scale into these SDK scratch fields; Q6 lighting does not overwrite them.
    for name in ('trig','camera_trig_y','camera_trig_z'):
        if name in p:
            for ax in 'xyz':
                for suffix in ('lo','hi'):
                    p[name]=p[name].replace(f'object_ang_{ax}_{suffix}',f'ang{ax}_{suffix}')
    p['matrix']=change(p['matrix'],' lda object_scale\n',' lda obj_scale_cur\n')
    v=p['vertices']
    v=change(v,'hp_origin_supported:\n','hp_origin_supported:\n ldx objidx\n')
    for ax in 'xyz':
        for suffix in ('lo','hi','ext'):
            v=v.replace(f' lda object_pos_{ax}_{suffix}\n',f' lda object_pos_{ax}_{suffix},x\n')
    p['vertices']=change(change(v,'hp_build_vertices:\n lda #0\n','hp_build_vertices:\n lda active_vfirst\n'),
                         ' cmp #VERT_COUNT\n bne hc_vertex_loop',' cmp active_vend\n bne hc_vertex_loop')
    p['projection']=change(change(p['projection'],'hc_project_vertices:\n lda #0\n',
                                 'hc_project_vertices:\n lda active_vfirst\n'),
                           ' cmp #VERT_COUNT\n bne hc_pv_loop',' cmp active_vend\n bne hc_pv_loop')
    p['core']=change(p['core'],''' ldx #VERT_COUNT-1
 lda #0
hc_invalid:
 sta projdone,x
 dex
 bpl hc_invalid
''',''' ldx active_vfirst
 lda #0
hc_invalid:
 sta projdone,x
 inx
 cpx active_vend
 bne hc_invalid
''')
    if 'camera_yaw' in p:
        p['camera_yaw']=change(p['camera_yaw'],' lda #0\n sta qc_index\n',
                               ' lda active_vfirst\n sta qc_index\n')
        p['camera_pitch']=change(p['camera_pitch'],' cmp #VERT_COUNT\n bne qc_vertex',
                                 ' cmp active_vend\n bne qc_vertex')
    return p
