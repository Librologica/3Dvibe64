"""Bind one native source mesh to multiple independent Q8 instance buffers."""
import json
import re
from pathlib import Path
import shared_mesh_runtime as shared
import torus_runtime as arrays
ROOT=Path(__file__).resolve().parents[1]
CONFIG=None
REPORT=None


def create(result):
    global CONFIG,REPORT
    path,stats=result
    asset=shared.configure_asset(json.loads((ROOT/'assets/crystal-mesh.json').read_text(encoding='utf-8-sig')))
    CONFIG=shared.validate(json.loads((ROOT/'assets/shared-meshes.json').read_text(encoding='utf-8-sig')))
    scene=json.loads(path.read_text(encoding='utf-8-sig'));m=scene['meshes'][0]
    assert len(m['vertices'])==9 and len(m['faces'])==16
    # Distinct integer importer scaffolds avoid welds. These are retired from
    # resident coordinate pools; the real Q8 transforms use shared local data.
    for i,instance in enumerate(CONFIG['instances']):
        first=len(m['vertices']);cx=-15+10*i
        for x,y,z in shared.VERTICES:m['vertices'].append([x+cx,z,y+9])
        for face in shared.FACES:
            m['faces'].append([first+v for v in face]);m['faceUV'].append([[0,0]]*3)
            m['faceTextures'].append('plain-ceiling');m['faceMaterials'].append('gray')
    path.write_text(json.dumps(scene,indent=2)+'\n',encoding='utf-8')
    cfg=json.loads((ROOT/'assets/surfaces.json').read_text(encoding='utf-8-sig'));entries=cfg['meshes'][m['id']]
    for instance in CONFIG['instances']:
        for f in range(8):
            level=max(4,min(32,instance['level']+([6,0,-4,2] if f<4 else [-8,-10,-12,-6])[f&3]))
            entries.append(dict(mode='gouraud',levels=[level]*3))
    (ROOT/'assets/surfaces.json').write_text(json.dumps(cfg,indent=2)+'\n',encoding='utf-8')
    count=len(CONFIG['instances']);copies=1 if CONFIG['sharing'] else count
    REPORT=dict(configuration=CONFIG,sourceVertexCount=6*copies,sourceTriangleCount=8*copies,
        sourceGeometryBytes=50*copies,sourceVertexBytes=18*copies,sourceTopologyBytes=32*copies,
        sourceGeometrySavedBytes=50*(count-copies),sourceMeshSHA256=shared.digest([shared.VERTICES,shared.FACES]),sourceAsset=asset,
        instanceCount=count,runtimeVertexCount=9+6*count,runtimeFaceCount=16+8*count,
        instanceVertexRanges=[[9+6*i,15+6*i] for i in range(count)],instanceFaceRanges=[[16+8*i,24+8*i] for i in range(count)],
        transforms='independent Q8 positions, Q6 scales, full16-bit yaw; exact existing Q8 sine/product arithmetic',
        buffers='disjoint native world/view/projection and clipping caches per instance; shared scratch only during one transform',
        scope='2..4 disjoint solid octahedra inside the convex room; no actor/door substitution in existing profiles',
        geometryLOD=False,animation='static instance descriptors; application-controlled animation/roll remains Q8-02')
    stats.update(vertices=REPORT['runtimeVertexCount'],triangles=REPORT['runtimeFaceCount'],sharedMeshes=REPORT)
    (ROOT/'reports/scene.json').write_text(json.dumps(stats,indent=2)+'\n',encoding='utf-8')
    (ROOT/'reports/shared-meshes.json').write_text(json.dumps(REPORT,indent=2)+'\n',encoding='utf-8')
    return path,stats


def counts():return REPORT['runtimeVertexCount'],REPORT['runtimeFaceCount']


def adapt(source,parts):
    n=len(CONFIG['instances']);copies=1 if CONFIG['sharing'] else n
    # Existing actor slots remain inert; the new objects are native triangles.
    parts['skeleton']='wr_code_begin:\nwr_collect:\n clc\n rts\nwr_draw:\nwr_tick:\n rts\nwr_enabled: .byte 0\nwr_pose: .byte 0\nwr_dirty: .byte 0\nwr_depth: .byte 0\nwr_code_end:\n'
    parts['skeleton_poses']='wr_pose_tables_begin:\n .byte 0\nwr_pose_tables_end:\n'
    parts['billboard']='bb_code_begin:\nbb_collect:\n clc\n rts\nbb_draw:\nbb_tick:\n rts\nbb_code_end:\n'
    parts['bb_state']='bb_enabled: .byte 0\nbb_frame: .byte 0\nbb_loaded: .byte 255\n'
    parts['bb_pixels']='bb_pixels: .byte 0\n'
    # Retain world-only coordinate pools and source indexes. No expanded model
    # coordinates survive the native build; instance buffers still span all VERT_COUNT.
    for axis in 'xyz':
        _,pool=arrays.array(source,axis+'coord');_,indexes=arrays.array(source,'vert_'+axis+'i')
        values=[pool[i] for i in indexes[:9]];compact=sorted(set(values))
        source=arrays.put(source,axis+'coord',compact)
        source=arrays.put(source,'vert_'+axis+'i',[compact.index(v) for v in values])
        source,changed=re.subn(r'(?m)^'+axis.upper()+r'COORD_COUNT = [^\n]+$',axis.upper()+'COORD_COUNT = '+str(len(compact)),source)
        assert changed==1
    for c in range(4):
        _,old=arrays.array(source,'face'+str(c));values=old[:16]
        for _ in range(copies):values += [face[c] if c<3 else 0 for face in shared.FACES]
        source=arrays.put(source,'face'+str(c),values)
    containers={'__source':source,**parts};pattern=r'(?m)^op_face_axis: \.byte ([^\n]+)\n'
    owners=[k for k,v in containers.items() if re.search(pattern,v)];assert len(owners)==1
    owner=owners[0];match=re.search(pattern,containers[owner]);axes=[int(v) for v in match[1].split(',')]
    containers[owner]=containers[owner][:match.start()]+shared.data('op_face_axis',axes[:16]+[255]*(8*n))+containers[owner][match.end():]
    source=containers.pop('__source');parts.update(containers)
    # World vertices use the old exact identity path; only model slots are
    # filled by the independent instance transformer before camera rotation.
    old=' cmp active_vend\n bne hc_vertex_loop\n'
    owners=[k for k,v in parts.items() if old in v];assert len(owners)==1,owners
    parts[owners[0]]=parts[owners[0]].replace(old,' cmp #9\n bne hc_vertex_loop\n',1)
    old=' jsr hp_build_vertices\n'
    owners=[k for k,v in parts.items() if old in v];assert len(owners)==1,owners
    parts[owners[0]]=parts[owners[0]].replace(old,old+' jsr sm_update\n',1)
    # Resolve immutable local topology before every collect/draw use. All
    # original UV, shade, face-id, palette and depth buffers stay instance-local.
    def consumers(code):
        code=re.sub(r'(?m)^( (?:lda|ldx|ldy)) face([0-3]),[xy]$',r'\1 sm_fv\2',code)
        for c in range(4):
            code=code.replace('<face'+str(c),'<sm_fv'+str(c)).replace('>face'+str(c),'>sm_fv'+str(c))
        return code
    source=consumers(source)
    for k in parts:parts[k]=consumers(parts[k])
    source=source.replace('load_face_visible:\n','load_face_visible:\n jsr sm_collect_face\n bcs +\n rts\n+\n',1)
    source=source.replace('ddb_face_loop:\n','ddb_face_loop:\n jsr sm_draw_face\n',1)
    # Meshes use native face depth; the convex shell remains behind all interior objects.
    old=' lda faceidx\n cmp #14\n bcs cr_actor_depth\n'
    assert source.count(old)==1
    source=source.replace(old,' lda faceidx\n cmp #16\n bcs sm_model_depth\n cmp #14\n bcs cr_actor_depth\n',1)
    source=source.replace('cr_actor_depth:\n','sm_model_depth:\ncr_actor_depth:\n',1)
    parts['shared_mesh_transform']=shared.kernel(CONFIG)
    parts['shared_mesh_topology']=shared.topology_kernel()
    parts['shared_mesh_state']=shared.state(CONFIG)
    parts['shared_mesh_source']=shared.source_vertices(CONFIG)
    # Fail closed if a new direct topology consumer bypasses the resolver.
    whole=source+'\n'+'\n'.join(v for k,v in parts.items() if k!='shared_mesh_topology')
    assert not re.search(r'(?m)^ (?:lda|ldx|ldy) face[0-3],',whole)
    return source,parts


def report():
    return dict(sharedMeshes=REPORT,comparison=str(len(CONFIG['instances']))+' native solid mesh instances with independent Q8 state',
        skeleton=dict(enabled=False,reason='dedicated source-mesh proof uses the native polygon pipeline'),
        billboard=dict(enabled=False),occlusion='convex shell behind independent native depth-bucket mesh triangles')
