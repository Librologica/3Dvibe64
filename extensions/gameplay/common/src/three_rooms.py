"""Private three-room scene, genuine rotating smooth Gouraud torus.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. No public SDK or frozen demo is modified.
"""
import json, math, re
from pathlib import Path
import build_room as previous
room=previous.room
ROOT=Path(__file__).resolve().parents[1]
room.dynamic_objects=True
CENTERS=(0,48,160)

def create():
    meshes=[];ranges=[];connectors=[];base=0
    for index,cy in enumerate(CENTERS):
        origin=80 if index==1 else cy
        m=room.Mesh(f'room{index+1}',[0,origin,0])
        y0=cy-24+(1 if index else 0);y1=cy+24-(1 if index<2 else 0)
        for x,n in ((-24,[1,0,0]),(24,[-1,0,0])):
            m.quad([(x,y0,-10),(x,y1,-10),(x,y1,18),(x,y0,18)],n)
        for y,n,open_wall in ((y0,[0,1,0],index>0),(y1,[0,-1,0],index<2)):
            for a,b in ((-24,-7),(7,24)) if open_wall else ((-24,24),):
                m.quad([(a,y,-10),(b,y,-10),(b,y,18),(a,y,18)],n)
        for z,n,t in ((-10,[0,0,1],'stone-floor'),(18,[0,0,-1],'plain-ceiling')):
            c=[(-24,y0,z),(24,y0,z),(24,y1,z),(-24,y1,z)]
            if t=='stone-floor':
                ring=[c[0]]+([(-7,y0,z),(7,y0,z)] if index>0 else [])+[c[1],c[2]]
                if index<2:ring += [(7,y1,z),(-7,y1,z)]
                ring += [c[3]]
                for i in range(len(ring)):m.quad([ring[i],ring[(i+1)%len(ring)],(0,cy,z)],n,t)
            else:m.quad(c,n,t)
        connector_first=len(m.faces)
        if index<2:
            connector_end=CENTERS[index+1]-23
            # Keep exact global UV phase/tile size within the Q4.4 endpoint
            # domain. Long walls/floor need panels, not a rescaled texture.
            count=math.ceil((connector_end-y1)/24)
            limits=[y1+round((connector_end-y1)*i/count) for i in range(count+1)]
            for a,b in zip(limits,limits[1:]):
                for x,n in ((-7,[1,0,0]),(7,[-1,0,0])):
                    m.quad([(x,a,-10),(x,b,-10),(x,b,18),(x,a,18)],n)
                m.quad([(-7,a,-10),(7,a,-10),(7,b,-10),(-7,b,-10)],[0,0,1],'stone-floor')
            m.quad([(-7,y1,18),(7,y1,18),(7,connector_end,18),(-7,connector_end,18)],[0,0,-1],'plain-ceiling')
        cube_first=len(m.faces)
        if index<2:
            cube=previous.two_rooms.CUBES[index];x,y,z=cube['center'];h=cube['size']/2
            for xx,n in ((x-h,[-1,0,0]),(x+h,[1,0,0])):
                m.quad([(xx,y-h,z-h),(xx,y+h,z-h),(xx,y+h,z+h),(xx,y-h,z+h)],n,'plain-ceiling')
            for yy,n in ((y-h,[0,-1,0]),(y+h,[0,1,0])):
                m.quad([(x-h,yy,z-h),(x+h,yy,z-h),(x+h,yy,z+h),(x-h,yy,z+h)],n,'plain-ceiling')
            m.quad([(x-h,y-h,z+h),(x+h,y-h,z+h),(x+h,y+h,z+h),(x-h,y+h,z+h)],[0,0,1],'plain-ceiling')
        fs=[];uvs=[];ts=[];mats=[];conn=[];cube_ids=[]
        for fi,(face,t) in enumerate(zip(m.faces,m.tex)):
            pts=[m.vertices[v] for v in face]
            if t=='stone':
                axis=2 if all(p[0]==pts[0][0] for p in pts) else 0
                world=[p[axis]+(origin if axis==2 else 0) for p in pts]
                shift=8*math.floor(min((n+24)/6 for n in world)/8)
                uv=[[round(((n+24)/6-shift)*16)/16,round((p[1]+10)/6*16)/16] for n,p in zip(world,pts)]
            elif t=='stone-floor':
                raw=[[(p[0]+39)/4.5,(p[2]+origin+39)/4.5] for p in pts]
                shifts=[2*math.floor(min(q[a] for q in raw)/2) for a in range(2)]
                uv=[[round((q[a]-shifts[a])*16)/16 for a in range(2)] for q in raw]
            else:uv=[[0,0] for p in pts]
            for ids in (((0,1,2),(0,2,3)) if len(face)==4 else ((0,1,2),)):
                if connector_first<=fi<cube_first:conn.append(base+len(fs))
                if fi>=cube_first:cube_ids.append(base+len(fs))
                fs.append([face[j] for j in ids]);uvs.append([uv[j] for j in ids]);ts.append(t)
                mats.append('brown' if t=='stone' else 'gray')
        mesh=m.scene();mesh.update(faces=fs,faceUV=uvs,faceTextures=ts,faceMaterials=mats,
                                   gouraud={'creaseAngle':0},materialProfile='multimaterial')
        meshes.append(mesh);ranges.append(dict(first=base,end=base+len(fs),cubeFirst=min(cube_ids) if cube_ids else base+len(fs)))
        connectors.append(conn);base+=len(fs)
    # Eight longitudinal rings/four tube samples. Shared vertices, analytic
    # outward winding checked below. Rounded integer geometry is the source
    # mesh; its runtime XYZ transforms remain fully Q8.
    verts=[];fs=[]
    for i in range(8):
        a=i*math.tau/8
        for j in range(4):
            b=j*math.tau/4;r=7+2*math.cos(b)
            verts.append([round(r*math.cos(a)),round(2*math.sin(b)),round(r*math.sin(a))])
    for i in range(8):
        for j in range(4):
            quad=[i*4+j,((i+1)%8)*4+j,((i+1)%8)*4+(j+1)%4,i*4+(j+1)%4]
            for ids in ((0,1,2),(0,2,3)):
                f=[quad[k] for k in ids];p,q,r=[verts[k] for k in f]
                u=[q[k]-p[k] for k in range(3)];v=[r[k]-p[k] for k in range(3)]
                n=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
                center=[sum(verts[k][d] for k in f)/3 for d in range(3)];rr=math.hypot(center[0],center[2])
                outward=[center[0]*(1-7/rr),center[1],center[2]*(1-7/rr)]
                if sum(n[k]*outward[k] for k in range(3))<0:f.reverse()
                fs.append(f)
    meshes.append(dict(id='torus',type='mesh',geometry='solid',materialProfile='single',vertices=verts,faces=fs,
                       texture='plain-ceiling',faceTextures=['plain-ceiling']*len(fs),
                       faceUV=[[[0,0]]*3 for f in fs],gouraud={'creaseAngle':180}))
    doc=json.loads((ROOT/'assets/template.json').read_text())
    objects=[dict(id=f'room{i+1}',mesh=f'room{i+1}',position=[0,80 if i==1 else CENTERS[i],0],rotation=[0,0,0],angularVelocity=[0,0,0],
                  scale=1,visible=True,material='gray',reflectivity='satin') for i in range(3)]
    objects.append(dict(id='floating-torus',mesh='torus',position=[0,96,4],rotation=[64,8,16],
                        angularVelocity=[0.45,0.65,0.35],scale=0.75,visible=True,material='gray',reflectivity='satin'))
    doc.update(name='three-rooms-floating-gouraud-torus-q8',textures=previous.textures(),meshes=meshes,objects=objects)
    doc['camera']['position']=[0,-10,0];doc['lights']=[dict(id='lamp',mode='static',position=[-12,86,12],intensity=10)]
    path=room.ROOT/'scenes/large-room.json';path.parent.mkdir(exist_ok=True);path.write_text(json.dumps(doc,indent=2))
    stats=dict(rooms=3,torusVertices=32,torusTriangles=64,torusCenter=[0,96,4],torusScale=0.75,torusCreaseAngle=180,
               ranges=ranges,connectors=connectors,
               vertices=sum(len(m['vertices']) for m in meshes),triangles=sum(len(m['faces']) for m in meshes))
    assert stats['vertices']<128 and stats['triangles']<255,stats
    (ROOT/'reports/scene.json').write_text(json.dumps(stats,indent=2));return path,stats

def trajectory():
    # A round trip through both apertures, then a gentle loop around the torus.
    # Catmull-Rom positions and blended look direction avoid sharp yaw changes.
    nodes=[(0,-10),(7,2),(0,16),(0,24),(0,32),(-7,43),(0,63),(0,72),(0,80),
           (18.6,83.6),(21.7,103.75),(7.75,117.7),(-13.95,111.5),(-21.7,92.9),(-12.4,75.85),(0,80),(0,72),(0,63),
           (7,50),(0,32),(0,24),(0,16),(-7,3),(-6,-10)]
    def point(t):
        i=int(t)%len(nodes);u=t-math.floor(t)
        p0,p1,p2,p3=[nodes[k%len(nodes)] for k in (i-1,i,i+1,i+2)]
        return [0.5*((2*p1[a])+(-p0[a]+p2[a])*u+(2*p0[a]-5*p1[a]+4*p2[a]-p3[a])*u*u+
                    (-p0[a]+3*p1[a]-3*p2[a]+p3[a])*u*u*u) for a in range(2)]
    poses=[]
    for i in range(64):
        t=i*len(nodes)/64;x,z=point(t);nx,nz=point(t+0.2)
        yaw=-math.atan2(nx-x,nz-z);pitch=0.025*math.sin(i*math.tau/32)
        # Gradual gaze lock in room3, still looking ahead when entering/leaving.
        w=max(0,min(1,(z-80)/8));w=w*w*(3-2*w)
        tyaw=-math.atan2(-x,96-z);yaw+=w*((tyaw-yaw+math.pi)%math.tau-math.pi)
        pitch=(1-w)*pitch+w*math.atan2(-4,math.hypot(x,96-z))
        poses.append([round(x*256),0,round(z*256),round(yaw*65536/math.tau)&65535,round(pitch*65536/math.tau)&65535])
    code,_=previous.original_trajectory()
    code=code.replace(' and #15\n',' and #63\n')
    for suffix in ('lo','hi'):
        code=code.replace(f' lda demo_y_pos_{suffix},x\n sta demo_y_{suffix}\n','')
        code=code.replace(f' lda demo_y_delta_{suffix},x\n sta demo_y_step_{suffix}\n','')
        code=code.replace(f'demo_y_step_{suffix}: .byte 0\n','')
    code=code.replace(' clc\n lda demo_y_lo\n adc demo_y_step_lo\n sta demo_y_lo\n lda demo_y_hi\n adc demo_y_step_hi\n sta demo_y_hi\n','')
    # Keep the 64 keys; 64 ticks/key = 81.92 s tour. Y baseline stays zero.
    data=''
    for f,name in enumerate(('x','y','z','yaw','pitch')):
        if name=='y':continue
        vals=[p[f]&65535 for p in poses]
        ds=[round((((vals[(i+1)%64]-v+32768)&65535)-32768)/64)&65535 for i,v in enumerate(vals)]
        for kind,arr in (('pos',vals),('delta',ds)):
            for shift,suffix in ((0,'lo'),(8,'hi')):
                data+=f'demo_{name}_{kind}_{suffix}: .byte '+','.join(str((v>>shift)&255) for v in arr)+'\n'
    data+='demo_bob: .byte '+','.join(str(round(16*(1-math.cos(i*math.tau/32)))) for i in range(32))+'\n'
    (room.ROOT/'scenes/camera-keyframes.json').write_text(json.dumps(dict(ticksPerKey=64,posesQ8=poses,periodTicks=4096,
        nominalSeconds=81.92,torusGaze='smoothly locked in central room3 tour',roomBounds=[[-24,24,-24,23],[-24,24,25,71],[-24,24,73,120]]),indent=2))
    return code,data

def bake(source):
    scene=json.loads((room.ROOT/'scenes/large-room.json').read_text());stats=json.loads((ROOT/'reports/scene.json').read_text())
    def array(name):
        m=re.search(r'(?m)^'+name+r':\n((?: \.byte[^\n]*\n)+)',source);assert m,name
        return m,[int(n[1:],16) if n.startswith('$') else int(n) for n in re.findall(r'\$[0-9a-fA-F]+|-?\d+',m[1])]
    pos=[]
    for obj,mesh in zip(scene['objects'],scene['meshes']):
        ox,oy,oz=obj['position'];pos += [[x+ox,y+oz,z+oy] for x,y,z in mesh['vertices']]
    normals=[[(v+128)%256-128 for v in array('gouraud_normal_'+a)[1]] for a in 'xyz'];geom={};cube_shades=set()
    cube_faces={f for rng in stats['ranges'][:2] for f in range(rng['cubeFirst'],rng['end'])}
    for k in range(3):
        for fi,(v,s) in enumerate(zip(array('face'+str(k))[1],array('gouraud_face_shade'+str(k))[1])):
            geom[s]=v
            if fi in cube_faces:cube_shades.add(s)
    levels=[]
    for s in range(len(normals[0])):
        p=pos[geom[s]];n=[ax[s] for ax in normals];cy=min(CENTERS,key=lambda cy:abs(cy-p[2]))
        lamp=[-12,12,cy+16];d=[lamp[k]-p[k] for k in range(3)];length=math.sqrt(sum(v*v for v in d))
        cosine=max(0,sum(n[k]*d[k] for k in range(3))/(math.sqrt(sum(v*v for v in n))*length))
        levels.append((32 if n[1]>0 else 18 if n[2] else 5) if s in cube_shades else
                      max(0,min(32,round(8+26*cosine/(1+(length/36)**2)))))
    m,_=array('gouraud_shade_value');source=source[:m.start()]+'gouraud_shade_value:\n .byte '+','.join(map(str,levels))+'\n'+source[m.end():]
    # Native dynamic shade update is retained only for the rotating torus.
    source=source.replace('m3_update_shades:\n','m3_update_shades:\n lda objidx\n cmp #3\n beq tr_dynamic_shades\n rts\ntr_dynamic_shades:\n')
    # Retain more of the native Lambert dot before its coarse intensity divide.
    # A softer, ambient-lit torus: Q=clamp(8+positiveDot/64,8,32).
    a=source.index(' ldx light_intensity\n',source.index('m3_update_shades:\n'))
    b=source.index('m3_shade_store:\n',a)
    source=source[:a]+''' sta dothi
 lda dotlo
 ldx #6
tr_shade_shift:
 lsr dothi
 ror
 dex
 bne tr_shade_shift
 clc
 adc #8
 cmp #33
 bcc m3_shade_store
m3_shade_max:
 lda #32
 bne m3_shade_store
m3_shade_dark:
 lda #8
'''+source[b:]
    # The old original-face camera test mixes Q6 and Q8 coordinate spaces.
    source=source.replace(' beq lfv_camera_plane_facing_done\n jsr camera_plane_original_facing\n',
                          ' beq lfv_camera_plane_facing_done\n sec\n nop\n nop\n')
    # Convex cells: draw distant shells before their interior objects, then
    # near shell and its interior object. Two disjoint apertures, no PVS claim.
    ranking=[[100,170,230],[170,100,170],[230,170,100]]
    depth=[]
    for current in range(3):
        row=[]
        for ri,rng in enumerate(stats['ranges']):
            row += [ranking[current][ri] if f<rng['cubeFirst'] else ranking[current][ri]-30 for f in range(rng['first'],rng['end'])]
        for ci,ids in enumerate(stats['connectors']):
            for f in ids:row[f]=75 if current in (ci,ci+1) else 200
        depth.append(row)
    tor_first=stats['ranges'][-1]['end']
    patch=f'''bvf_depth_ready:
 lda faceidx
 cmp #{tor_first}
 bcc tr_shell_depth
 ; Retain native intra-torus depth order, below its containing room shell.
 lda p1lo
 sta tr_torus_depth
 lda explorer_cam_z_hi
 cmp #24
 bcc tr_torus_far
 cmp #137
 bcc tr_torus_middle
 lda tr_torus_depth
 cmp #60
 bcc tr_torus_near_valid
 lda #59
tr_torus_near_valid:
 clc
 adc #30
 jmp tr_depth_done
 ; Remote torus is already small: preserve quarter-WU bucket ranking.
tr_torus_reduce:
 lsr tr_torus_depth
 lsr tr_torus_depth
 rts
tr_torus_middle:
 jsr tr_torus_reduce
 lda #135
 bne tr_torus_store
tr_torus_far:
 jsr tr_torus_reduce
 lda #195
tr_torus_store:
 clc
 adc tr_torus_depth
 jmp tr_depth_done
tr_shell_depth:
 lda faceidx
 tax
 lda explorer_cam_z_hi
 cmp #24
 bcc tr_depth_room0
 cmp #137
 bcc tr_depth_room1
 lda tr_depth2,x
 jmp tr_depth_done
tr_depth_room1:
 lda tr_depth1,x
 jmp tr_depth_done
tr_depth_room0:
 lda tr_depth0,x
tr_depth_done:
 sta p1lo
'''
    source=source.replace('bvf_depth_ready:\n',patch)
    # Keep room colors, common highlight avoids extra cell-palette conflicts.
    for name in ('material_screen_bytes','material_color_bytes'):
        m,values=array(name)
        for reflect in range(4):
            values[reflect*10]=0xBC if name=='material_screen_bytes' else 15
            values[reflect*10+9]=0x9C if name=='material_screen_bytes' else 15
        source=source[:m.start()]+name+':\n .byte '+','.join(map(str,values))+'\n'+source[m.end():]
    bake.depth='tr_torus_depth: .byte 0\n'+''.join(f'tr_depth{i}: .byte '+','.join(map(str,d))+'\n' for i,d in enumerate(depth))
    import cell_order
    bake.depth=cell_order.generate(scene,stats)
    source=cell_order.hooks(source)
    return source

def pack(sizes,lab):
    # PRIVATE demo all-RAM layout: KERNAL banked out, own IRQ/NMI wrapper.
    # Existing bitmap/screen windows untouched. Never allocate I/O/vectors.
    gaps=[(lab['mode3_high_basic_low_segment_end'],0x2000),(lab['mode3_high_basic_high_code_end'],0x5c00),
          (lab['mode3_high_basic_relocated_code_end'],0xa400),(lab['tr_fixed_high_end'],0xd000),
          (lab['mode3_high_basic_middle_end'],0xff00),
          (lab['RUNTIME_BUFFER_END']+32,0x9000)]
    items=sorted(sizes.items(),key=lambda x:-x[1]);seen=set();nodes=0
    def search(i,free,placed):
        nonlocal nodes
        nodes+=1
        if nodes>300000:return None
        if i==len(items):return placed,free
        state=(i,tuple(sorted(free)))
        if state in seen:return None
        seen.add(state)
        name,size=items[i];need=size+(0 if name in ('tables','data') else 8)
        if sum(b-a for a,b in free)<sum(s+(0 if n in ('tables','data') else 8) for n,s in items[i:]):return None
        options=[(b-((a+1)&~1)-need,j,(a+1)&~1) for j,(a,b) in enumerate(free) if ((a+1)&~1)+need<=b]
        for _,j,start in sorted(options):
            a,b=free[j];nextfree=free[:j]+free[j+1:]
            if a<start:nextfree.append((a,start))
            if start+need<b:nextfree.append((start+need,b))
            result=search(i+1,nextfree,{**placed,name:(start,start+need)})
            if result:return result
        return None
    result=search(0,gaps,{})
    if not result:raise ValueError(f'THREE_ROOM_MEMORY: exact search failed, need={sum(s+(0 if n in ("tables","data") else 8) for n,s in items)}, free={sum(b-a for a,b in gaps)}, nodes={nodes}, blocks={len(items)}')
    return result[0],gaps,result[1]

original_adapt=previous.adapt_scene
def adapt(source,parts,placed):
    source,parts=original_adapt(source,parts,placed)
    # Source IRQ originally enters through the KERNAL register-save stub.
    # Own RAM vector must save precisely the same A/X/Y set and RTI directly.
    source=source.replace(' lda #$36\n sta $01\n',' lda #$35\n sta $01\n')
    source=source.replace('init_irq:\n','''init_irq:
 lda #<tr_irq_entry
 sta $fffe
 lda #>tr_irq_entry
 sta $ffff
 lda #<tr_nmi
 sta $fffa
 lda #>tr_nmi
 sta $fffb
''')
    source=source.replace(' jmp $ea81\n',' jmp tr_irq_exit\n')
    if placed is None:
        parts['data']+=bake.depth
        parts['tr_irq']='''tr_irq_entry:
 pha
 txa
 pha
 tya
 pha
 jmp raster_irq
tr_irq_exit:
 pla
 tay
 pla
 tax
 pla
tr_nmi:
 rti
'''
    return source,parts

room.make_scene=create;room.trajectory=trajectory;room.bake_static_light=bake;room.render_adapter=adapt
import block4
block4.pack=pack
block_enabled=True
if __name__=='__main__':
    import sys
    if '--silent' not in sys.argv:sys.argv.append('--silent')
    room.main()
    name=sys.argv[sys.argv.index('--name')+1]
    out=room.ROOT/'build'/name
    for path in (out/'build.json',room.ROOT/'reports'/f'{name}-build.json'):
        info=json.loads(path.read_text());info.update(rooms=3,cameraTicks=4096,music=False,staticVertexLighting=False,
            lighting='static baked room Gouraud + dynamic smooth torus Gouraud',torusScale=0.75,torusCreaseAngle=180,
            demoCamera=dict(keyframes=64,ticksPerKey=64,periodTicks=4096,walkingBob=True),
            demoOnlySpecialization='private four-object all-RAM scene; convex-room painter; rotating untextured Gouraud torus',
            publicProfileExtension='private demo, not a public four-object Q8 qualification',
            publicEngineModified=False,privateQ8AdapterModified=True)
        path.write_text(json.dumps(info,indent=2))
    # The raw all-RAM image is diagnostic only. Never deliver it through LOAD.
    from package_prg import package
    package(out,out/'3Dvibe64-loadsafe.prg')
