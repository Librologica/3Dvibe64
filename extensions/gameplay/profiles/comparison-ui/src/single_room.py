"""One closed room, unchanged dungeon texture pixels and global UV scale.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import json,math,re
from pathlib import Path
import torus_runtime as arrays
ROOT=Path(__file__).resolve().parents[1]
WIRE_FACE=14
BILLBOARD_FACE=15
KEYS=48
PERIOD=KEYS*64

def create(room,textures):
    m=room.Mesh('comparison-room',[0,0,0])
    for x,n in ((-24,[1,0,0]),(24,[-1,0,0])):
        m.quad([(x,-24,-10),(x,24,-10),(x,24,18),(x,-24,18)],n)
    for y,n in ((-24,[0,1,0]),(24,[0,-1,0])):
        m.quad([(-24,y,-10),(24,y,-10),(24,y,18),(-24,y,18)],n)
    c=[(-24,-24,-10),(24,-24,-10),(24,24,-10),(-24,24,-10)]
    for i in range(4):m.quad([c[i],c[(i+1)%4],(0,0,-10)],[0,0,1],'stone-floor')
    m.quad([(-24,-24,18),(24,-24,18),(24,24,18),(-24,24,18)],[0,0,-1],'plain-ceiling')
    fs=[];uvs=[];ts=[];materials=[]
    for face,t in zip(m.faces,m.tex):
        pts=[m.vertices[v] for v in face]
        if t=='stone':
            axis=2 if all(p[0]==pts[0][0] for p in pts) else 0
            world=[p[axis] for p in pts]
            shift=8*math.floor(min((n+24)/6 for n in world)/8)
            uv=[[round(((n+24)/6-shift)*16)/16,round((p[1]+10)/6*16)/16] for n,p in zip(world,pts)]
        elif t=='stone-floor':
            raw=[[(p[0]+39)/4.5,(p[2]+39)/4.5] for p in pts]
            shifts=[2*math.floor(min(q[a] for q in raw)/2) for a in range(2)]
            uv=[[round((q[a]-shifts[a])*16)/16 for a in range(2)] for q in raw]
        else:uv=[[0,0] for _ in pts]
        for ids in (((0,1,2),(0,2,3)) if len(face)==4 else ((0,1,2),)):
            fs.append([face[i] for i in ids]);uvs.append([uv[i] for i in ids]);ts.append(t)
            materials.append('brown' if t=='stone' else 'gray')
    assert len(fs)==WIRE_FACE
    for i in range(2):
        fs.append(fs[0].copy());uvs.append(uvs[0].copy());ts.append(ts[0]);materials.append(materials[0])
    mesh=m.scene();mesh.update(faces=fs,faceUV=uvs,faceTextures=ts,faceMaterials=materials,
        gouraud={'creaseAngle':0},materialProfile='multimaterial')
    doc=json.loads((ROOT/'assets/template.json').read_text())
    obj=dict(id='comparison-room',mesh=mesh['id'],position=[0,0,0],rotation=[0,0,0],
        angularVelocity=[0,0,0],scale=1,visible=True,material='gray',reflectivity='satin')
    doc.update(name='single-room-skeleton-versus-billboard',meshes=[mesh],objects=[obj],textures=textures(),
        texturePrecision='perspective',textureLighting='gouraud',textureCompositor='C',
        privateExperiment='three-rooms-sphere') # Existing private all-RAM layout token, not room count.
    doc.pop('texturePalette',None)
    doc['camera'].update(position=[0,-22,0],rotation=[0,0,0])
    doc['lights']=[dict(id='lamp',mode='static',position=[-12,16,12],intensity=10)]
    doc['comparison']=dict(rooms=1,closed=True,skeleton=dict(position=[-7,0,-2.5],scale=.5,node=WIRE_FACE),
        billboard=dict(position=[7,0,-2.5],size=[6,16],node=BILLBOARD_FACE),
        nodeFaces='synthetic painter nodes only, never rasterized as room triangles')
    path=room.ROOT/'scenes/large-room.json';path.write_text(json.dumps(doc,indent=2))
    stats=dict(rooms=1,closed=True,bounds=[[-24,24],[-24,24],[-10,18]],vertices=len(m.vertices),
        triangles=len(fs),roomTriangles=WIRE_FACE,actorNodes=[WIRE_FACE,BILLBOARD_FACE],
        cubes=0,corridors=0,ranges=[dict(first=0,end=len(fs),cubeFirst=WIRE_FACE)],connectors=[[]])
    (ROOT/'reports/scene.json').write_text(json.dumps(stats,indent=2))
    return path,stats

def bake(source):
    for k in range(3):
        _,v=arrays.array(source,'gouraud_face_shade'+str(k))
        source=arrays.put(source,'gouraud_face_shade'+str(k),[16]*len(v))
    source=arrays.put(source,'gouraud_shade_value',list(range(33)))
    for label in ('object_runtime_shade_first','object_runtime_shade_end'):
        source=arrays.put(source,label,[0])
    a=source.index('m3_update_shades:\n');b=source.index('m3_update_shades_end = *',a)
    source=source[:a]+'m3_update_shades:\n rts\n'+source[b:]
    for label in ['gouraud_normal_'+a for a in 'xyz']+['gouraud_center_dot_lo','gouraud_center_dot_hi']+['face_normal_'+a for a in 'xyz']+['face_center_dot_lo','face_center_dot_hi']:
        source,n=re.subn(r'(?m)^'+label+r':\n(?: \.byte[^\n]*\n)+','',source);assert n==1,label
    a=source.index('\nsubtract_face_center_dot:\n')+1;b=source.index(' rts\n',a)+len(' rts\n')
    source=source[:a]+'subtract_face_center_dot:\n rts\n'+source[b:]
    a=source.index('prepare_angles:\n');b=source.index('build_coord_terms:\n',a)
    names=re.findall(r'(?m)^(\w+):',source[a:b])
    live=('prepare_angles','prepare_object_matrix','prepare_object_light_for_shade','gouraud_update_object_shades')
    source=source[:a]+''.join(n+':\n' for n in live)+' rts\n'+''.join(n+' = hp_unreachable\n' for n in names if n not in live)+source[b:]
    old=' beq lfv_camera_plane_facing_done\n jsr camera_plane_original_facing\n'
    source=source.replace(old,' beq lfv_camera_plane_facing_done\n sec\n nop\n nop\n')
    for name in ('material_screen_bytes','material_color_bytes'):
        _,v=arrays.array(source,name)
        for reflect in range(4):
            v[reflect*10]=0xBC if name=='material_screen_bytes' else 15
            v[reflect*10+9]=0x9C if name=='material_screen_bytes' else 15
        source=arrays.put(source,name,v)
    # Camera stays inside the closed convex room. Every shell triangle is
    # behind both interior subjects; actor nodes retain native depth order.
    source=source.replace('bvf_depth_ready:\n',f'''bvf_depth_ready:
 lda faceidx
 cmp #{WIRE_FACE}
 bcs cr_actor_depth
 lda #200
 bne cr_store_depth
cr_actor_depth:
 lda p1lo
 clc
 adc #32
cr_store_depth:
 sta p1lo
''')
    return source

def surface_hooks(source,scene):
    import optimizations as op
    mesh=scene['meshes'][0]
    codes=[253 if t=='plain-ceiling' else 255 for t in mesh['faceTextures']]
    source=op.once(source,'lg_bind_uniform:\n sta iu_sample_uniform+1\n lda lg_weight\n','''lg_bind_uniform:
 sta iu_sample_uniform+1
 lda sc_face_codes,y
 cmp #253
 bne sc_uniform_original
 lda #2
 sta lg_modal
 lda #3
 sta lg_accent
 lda #<sc_ceiling_sample
 sta iu_sample_uniform+3
 lda #>sc_ceiling_sample
 sta iu_sample_uniform+4
 ldx lg_texture
 lda op_uniform
 rts
sc_uniform_original:
 lda lg_weight
''')
    return source+'\n*=$4000\nsc_ceiling_sample:\n jmp lg_far_sample\nsc_face_codes: .byte '+','.join(map(str,codes))+'\n'

def filler_hooks(source):
    # Keep the native Q8 texture filler; fc label ABI is retained for the
    # property-selected ceiling helper, without a cube or a cube shader.
    source=source.replace(' jmp gouraud_fill_bounds\n',' jmp fc_finish_bounds\n',1)
    return source+'''\n*=$4000
fc_finish_bounds:
 lda sortj
 sta fc_code
sc_inclusive_setup:
 jmp gouraud_fill_bounds
fc_code: .byte 0
'''

def configure_tour(human):
    route=[]
    for i in range(KEYS):
        a=math.pi+i*math.tau/KEYS
        radius=21.5+.5*math.sin(2*a)
        x,z=radius*math.sin(a),radius*math.cos(a)
        target_x=2.5*math.sin(3*a)
        target_y=-3+3.5*math.sin(2*a)
        yaw=-math.atan2(target_x-x,-z)
        pitch=math.atan2(-target_y,math.hypot(target_x-x,z))
        route.append([round(x*256),0,round(z*256),round(yaw*65536/math.tau)&65535,round(pitch*65536/math.tau)&65535])
    human.KEYS=KEYS;human.PERIOD=PERIOD;human.poses=lambda:route
    (ROOT/'reports/camera-design.json').write_text(json.dumps(dict(
        keys=KEYS,periodTicks=PERIOD,orbitDegrees=360,radiusWU=[21,22],
        lookTargetXWU=[-2.5,2.5],lookTargetHeightWU=[-6.5,.5],
        description='closed room; orbit both subjects; twice scan up/down and three alternating gaze sweeps',
        posesQ8=route),indent=2))
