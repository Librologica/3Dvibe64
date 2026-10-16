"""Two static room meshes with floor cubes; no SDK/renderer changes.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import json,math

CUBES=[dict(room=0,center=[-16,0,-7],size=6),
       dict(room=1,center=[16,48,-6],size=8)]

def create(room,textures,root):
    meshes=[]
    for index,cy in enumerate((0,48)):
        m=room.Mesh(f'room{index+1}',[0,cy,0])
        y0,y1=(-24,23) if index==0 else (25,72)
        # Planar rectangles do not need extra coplanar internal panels.
        for a,b in ((y0,y1),):
            for x,n in ((-24,[1,0,0]),(24,[-1,0,0])):
                m.quad([(x,a,-10),(x,b,-10),(x,b,18),(x,a,18)],n)
        far=cy-24 if index==0 else cy+24
        normal=[0,1,0] if index==0 else [0,-1,0]
        for a,b in ((-24,24),):
            m.quad([(a,far,-10),(b,far,-10),(b,far,18),(a,far,18)],normal)
        # Solid 2-WU slab, facing planes at Y23/Y25, not coincident planes.
        partition=23 if index==0 else 25
        for a,b in ((-24,-7),(7,24)):
            m.quad([(a,partition,-10),(b,partition,-10),(b,partition,18),(a,partition,18)],
                   [0,-1,0] if index==0 else [0,1,0])
        for z,n,t in ((-10,[0,0,1],'stone-floor'),(18,[0,0,-1],'plain-ceiling')):
            c=[(-24,y0,z),(24,y0,z),(24,y1,z),(-24,y1,z)]
            if t=='stone-floor':
                # Match the two portal endpoints explicitly, avoiding a
                # T-junction between the wide room floor and narrow connector.
                # Convex-cell order already draws floor before its cube; the
                # old room2 hole/ring is no longer required for occlusion.
                ring=([c[0],c[1],c[2],(7,y1,z),(-7,y1,z),c[3]] if index==0 else
                      [c[0],(-7,y0,z),(7,y0,z),c[1],c[2],c[3]])
                for i in range(len(ring)):
                    m.quad([ring[i],ring[(i+1)%len(ring)],(0,cy,z)],n,t)
            else:m.quad(c,n,t)
        if index==0:
            # Connector: two textured reveals, floor and ceiling.
            for x,n in ((-7,[1,0,0]),(7,[-1,0,0])):
                m.quad([(x,23,-10),(x,25,-10),(x,25,18),(x,23,18)],n)
            for z,n,t in ((-10,[0,0,1],'stone-floor'),(18,[0,0,-1],'plain-ceiling')):
                m.quad([(-7,23,z),(7,23,z),(7,25,z),(-7,25,z)],n,t)
        cube_first=len(m.faces)
        for cube in (c for c in CUBES if c['room']==index):
            x,y,z=cube['center'];h=cube['size']/2
            assert z-h==-10
            # Five outward faces; bottom rests exactly on the floor and cannot
            # be seen. The solid carrier is spatially uniform, UV fixed at0.
            for xx,n in ((x-h,[-1,0,0]),(x+h,[1,0,0])):
                m.quad([(xx,y-h,z-h),(xx,y+h,z-h),(xx,y+h,z+h),(xx,y-h,z+h)],n,'plain-ceiling')
            for yy,n in ((y-h,[0,-1,0]),(y+h,[0,1,0])):
                m.quad([(x-h,yy,z-h),(x+h,yy,z-h),(x+h,yy,z+h),(x-h,yy,z+h)],n,'plain-ceiling')
            m.quad([(x-h,y-h,z+h),(x+h,y-h,z+h),(x+h,y+h,z+h),(x-h,y+h,z+h)],
                   [0,0,1],'plain-ceiling')
        fs=[];uvs=[];ts=[];mats=[];cube_faces=[]
        for fi,(face,t) in enumerate(zip(m.faces,m.tex)):
            points=[m.vertices[v] for v in face]
            if t=='stone':
                axis=2 if all(p[0]==points[0][0] for p in points) else 0
                # Global phase, remove only full repeat periods so each face
                # fits unsigned Q4.4. Room2 local forward is offset by48WU.
                world=[p[axis]+(cy if axis==2 else 0) for p in points]
                shift=8*math.floor(min((n+24)/6 for n in world)/8)
                uv=[[round(((n+24)/6-shift)*16)/16,round((p[1]+10)/6*16)/16]
                    for n,p in zip(world,points)]
            elif t=='stone-floor':
                # Half-size tiles: repeat8 maps two UV units to one 16-texel
                # period, so a 4.5-WU UV unit gives a 9-WU square tile.
                # Remove only complete periods per face to keep unsigned Q4.4
                # valid, retaining the same global phase at every shared edge.
                raw=[[(p[0]+39)/4.5,(p[2]+cy+39)/4.5] for p in points]
                shifts=[2*math.floor(min(q[a] for q in raw)/2) for a in range(2)]
                uv=[[round((q[a]-shifts[a])*16)/16 for a in range(2)] for q in raw]
                assert all(0<=v<=15.9375 for pair in uv for v in pair)
            else:uv=[[0,0] for p in points]
            for ids in (((0,1,2),(0,2,3)) if len(face)==4 else ((0,1,2),)):
                if fi>=cube_first:cube_faces.append(len(fs))
                fs.append([face[j] for j in ids]);uvs.append([uv[j] for j in ids]);ts.append(t)
                mats.append('brown' if t=='stone' else 'gray')
        mesh=m.scene();mesh.update(faces=fs,faceUV=uvs,faceTextures=ts,faceMaterials=mats,
                                   gouraud={'creaseAngle':0},materialProfile='multimaterial')
        meshes.append(mesh)
        assert len(m.vertices)<=48 and max(math.sqrt(sum(v*v for v in p)) for p in m.vertices)<=40
    doc=json.loads((root/'assets/template.json').read_text())
    doc.update(name='two-rooms-floor-cubes-perspective-gouraud-q8',textures=textures(),meshes=meshes,
               objects=[dict(id=f'room{i+1}',mesh=f'room{i+1}',position=[0,48*i,0],rotation=[0,0,0],
                             angularVelocity=[0,0,0],scale=1,visible=True,material='gray',reflectivity='satin')
                        for i in range(2)])
    doc['camera']['position']=[0,-10,0]
    doc['lights']=[dict(id='lamp',mode='static',position=[-12,16,12],intensity=10)]
    path=room.ROOT/'scenes/large-room.json';path.write_text(json.dumps(doc,indent=2))
    return path,dict(rooms=2,cubes=CUBES,vertices=sum(len(m['vertices']) for m in meshes),
                     triangles=sum(len(m['faces']) for m in meshes),creaseAngle=0,
                     wallBrickWU=[6,3],floorTileWU=[9,9],openingWU=14,openingThicknessWU=2)

def bake(room,source):
    def array(name):
        m=re.search(r'(?m)^'+name+r':\n((?: \.byte[^\n]*\n)+)',source);assert m,name
        return m,[int(n[1:],16) if n.startswith('$') else int(n) for n in re.findall(r'\$[0-9a-fA-F]+|-?\d+',m[1])]
    import re
    scene=json.loads((room.ROOT/'scenes/large-room.json').read_text())
    positions=[];cube_face_ids=set();face_offset=0
    for obj,mesh in zip(scene['objects'],scene['meshes']):
        offset=len(positions);ox,oy,oz=obj['position']
        positions += [[x+ox,y+oz,z+oy] for x,y,z in mesh['vertices']]
        for fi,(face,uv,t) in enumerate(zip(mesh['faces'],mesh['faceUV'],mesh['faceTextures'])):
            if t=='plain-ceiling' and all(mesh['vertices'][i][1]<0 for i in face):
                cube_face_ids.add(face_offset+fi)
        face_offset+=len(mesh['faces'])
    normals=[[(v+128)%256-128 for v in array('gouraud_normal_'+a)[1]] for a in 'xyz']
    geom={};cube_shades=set()
    for corner in range(3):
        for fi,(v,s) in enumerate(zip(array('face'+str(corner))[1],array('gouraud_face_shade'+str(corner))[1])):
            assert s not in geom or geom[s]==v
            geom[s]=v
            if fi in cube_face_ids:cube_shades.add(s)
    lamps=[[p[0],p[2],p[1]] for p in (l['position'] for l in scene['lights'])]
    entries=[];levels=[]
    for s in range(len(normals[0])):
        p=positions[geom[s]];n=[axis[s] for axis in normals]
        light=min(lamps,key=lambda l:sum((l[a]-p[a])**2 for a in range(3)))
        vector=[light[a]-p[a] for a in range(3)];distance=math.sqrt(sum(v*v for v in vector))
        cosine=max(0,sum(n[a]*vector[a] for a in range(3))/(math.sqrt(sum(v*v for v in n))*distance))
        cube=s in cube_shades
        # Solid cubes: clearly distinct flat-tone planes (top white, front/back
        # medium gray, sides dark gray). No texel pattern and no noisy transition
        # band. Room surfaces retain the original native Gouraud gradients.
        q=(32 if n[1]>0 else 18 if n[2] else 5) if cube else max(0,min(32,round(8+26*cosine/(1+(distance/36)**2))))
        levels.append(q);entries.append(dict(shadeVertex=s,geometryVertex=geom[s],normal=n,
                                            position=p,Q=q,cube=cube,cosine=cosine,distance=distance))
    block,_=array('gouraud_shade_value')
    source=source[:block.start()]+'gouraud_shade_value:\n .byte '+','.join(map(str,levels))+'\n'+source[block.end():]
    start=source.index('m3_update_shades:\n');end=source.index('m3_update_shades_end = *',start)
    source=source[:start]+'m3_update_shades:\n rts ; demo-only static vertex light\n'+source[end:]
    for name in ['gouraud_normal_'+a for a in 'xyz']+['gouraud_center_dot_lo','gouraud_center_dot_hi']:
        block,_=array(name);source=source[:block.start()]+source[block.end():]
        assert not re.search(r'\b'+name+r'\b','\n'.join(l.split(';',1)[0] for l in source.splitlines()))
    (room.ROOT/'reports/static-light.json').write_text(json.dumps(dict(entries=entries,levels=levels,
        range=[min(levels),max(levels)],model='demo-only baked Lambert, one static lamp',
        cubeAppearance='uniform texel2, UV0; top32/front18/side5, hard edges, no surface texture pattern'),indent=2))
    return source

def trajectory(room,original):
    code,_=original()
    code=code.replace(' and #15\n',' and #31\n')
    # Eye baseline Y stays exactly0: omit its redundant route tables/update.
    for suffix in ('lo','hi'):
        code=code.replace(f' lda demo_y_pos_{suffix},x\n sta demo_y_{suffix}\n','')
        code=code.replace(f' lda demo_y_delta_{suffix},x\n sta demo_y_step_{suffix}\n','')
        code=code.replace(f'demo_y_step_{suffix}: .byte 0\n','')
    code=code.replace(' clc\n lda demo_y_lo\n adc demo_y_step_lo\n sta demo_y_lo\n lda demo_y_hi\n adc demo_y_step_hi\n sta demo_y_hi\n','')
    poses=[];targets=[]
    for i in range(64):
        a=-math.pi/2+math.tau*i/64
        x=9*math.sin(2*a);y=24+34*math.sin(a)
        ahead=a+0.23;tx=9*math.sin(2*ahead);ty=24+34*math.sin(ahead)
        yaw=-math.atan2(tx-x,ty-y)
        pitch=0.035*math.sin(3*a)
        # Smooth look at two floor cubes; Gaussian weight gives gradual head
        # turn and tilt without changing the walking trajectory or its speed.
        events=[(6,CUBES[0]['center']),(23,CUBES[1]['center']),(57,CUBES[0]['center'])]
        chosen=None
        for center,target in events:
            delta=(i-center+32)%64-32;w=math.exp(-0.5*(delta/2.7)**2)*0.88
            if w<0.02:continue
            dx=target[0]-x;dy=target[1]-y
            target_yaw=-math.atan2(dx,dy)
            yaw+=w*((target_yaw-yaw+math.pi)%math.tau-math.pi)
            pitch=(1-w)*pitch+w*math.atan2(-target[2],math.hypot(dx,dy))
            chosen=target
        poses.append([round(x*256),0,round(y*256),round(yaw*65536/math.tau)&65535,round(pitch*65536/math.tau)&65535])
        targets.append(chosen)
    # Store32 keyframes; continuous Q8 increments over64ticks retain the same
    # 40.96s tour and walking speed while halving only host path metadata.
    poses=poses[::2];targets=targets[::2]
    code=code.replace(' lda demo_subtick\n and #31\n',' lda demo_subtick\n and #63\n')
    code=code.replace(' lda demo_key\n and #63\n',' lda demo_key\n and #31\n')
    data=''
    for f,name in enumerate(('x','y','z','yaw','pitch')):
        if name=='y':continue
        vals=[p[f]&65535 for p in poses]
        ds=[round((((vals[(i+1)%32]-v+32768)&65535)-32768)/64)&65535 for i,v in enumerate(vals)]
        for kind,arr in (('pos',vals),('delta',ds)):
            for shift,suffix in ((0,'lo'),(8,'hi')):
                data+=f'demo_{name}_{kind}_{suffix}: .byte '+','.join(str((v>>shift)&255) for v in arr)+'\n'
    data+='demo_bob: .byte '+','.join(str(round(16*(1-math.cos(i*math.tau/32)))) for i in range(32))+'\n'
    (room.ROOT/'scenes/camera-keyframes.json').write_text(json.dumps(dict(ticksPerKey=64,
        posesQ8=poses,periodTicks=2048,nominalSeconds=40.96,lookTargets=targets,cubes=CUBES,
        opening=dict(y=24,x=[-7,7]),roomBounds=[[-24,24,-24,24],[-24,24,24,72]]),indent=2))
    return code,data
