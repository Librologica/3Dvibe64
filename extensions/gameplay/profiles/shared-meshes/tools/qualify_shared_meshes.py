"""Native shared/replicated equivalence, source ROM and independent Q8 oracle."""
import copy
import json
import math
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path
import native_compare as native
from verify_ui import check_frame
ROOT=native.ROOT


def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,d):p.write_text(json.dumps(d,indent=2)+'\n',encoding='utf-8')


def reference(kind):
    external=os.environ.get('Q8_SHARED_REPLICATED_PROJECT' if kind=='replicated' else 'Q8_SHARED_ROOM_PROJECT')
    if external:return Path(external).resolve(),('shared-meshes' if kind=='replicated' else 'mesh-room-reference')
    root=ROOT/'verification'/kind;name='mesh-replicated-reference' if kind=='replicated' else 'mesh-room-reference'
    if (root/'qualification-build.json').exists():
        info=read(root/'qualification-build.json');assert native.sha(root/info['program'])==info['PRGSHA256'];return root,name
    if root.exists():raise ValueError('Incomplete reference directory; choose a new delivered output')
    root.mkdir(parents=True)
    for folder in ('src','sdk','private','assets'):
        ignored=['__pycache__','*.pyc']+(['shared_mesh_profile.py'] if kind=='room' and folder=='src' else [])
        shutil.copytree(ROOT/folder,root/folder,ignore=shutil.ignore_patterns(*ignored))
    shutil.copy2(ROOT/'build_demo.py',root/'build_demo.py')
    for folder in ('room','room/scenes','room/reports','reports','artifacts'):(root/folder).mkdir(exist_ok=True)
    cfg=read(root/'assets/surfaces.json')
    for key in cfg['meshes']:cfg['meshes'][key]=cfg['meshes'][key][:16]
    write(root/'assets/surfaces.json',cfg)
    if kind=='replicated':
        cfg=read(root/'assets/shared-meshes.json');cfg['sharing']=False;write(root/'assets/shared-meshes.json',cfg)
    command=[sys.executable,'-B','build_demo.py','--name',name,'--artifact-tag',name,'--precise']
    if kind=='room':command+=['--without-skeleton','--without-billboard']
    result=subprocess.run(command,cwd=root,capture_output=True,timeout=300)
    (root/'reference-build.log').write_bytes(result.stdout+result.stderr);assert result.returncode==0,root
    info=read(root/f'room/build/{name}/build.json');prg=root/info['distributionPRG']
    write(root/'qualification-build.json',dict(program=info['distributionPRG'],PRGSHA256=native.sha(prg),command=command))
    return root,name


def specifications():
    return [('front',[0,0,-18,0,0]),('rear',[0,0,18,180,0]),
        ('left',[-20,0,0,-90,0]),('right',[20,0,0,90,0]),
        ('oblique',[-15,0,-15,-45,14]),('reverse',[15,0,15,135,-14]),
        ('near',[5,0,-10,0,0]),('low',[0,-8,-18,0,0]),
        ('look-up',[0,0,-18,0,14]),('look-down',[0,0,-18,0,-14])]


def capture(root,build,tag,room=False):
    old=native.ROOT;native.ROOT=root
    try:
        b,prg,l=native.paths(build);stem=ROOT/'reports/shared-views'/tag
        cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x','bank ram',
            f'save "{stem}-initial.ram" 0 $0000 $ffff','bank cpu',f'> ${l["advance_sim_tick"]:04x} 60','disable 1',
            'break exec .fps_frame_done','disable 2','break exec .raster_irq','disable 3']
        def put(n,v):cmds.append(f'> ${l[n]:04x} {v&255:02x}')
        for case,camera in specifications():
            for axis,value in zip('xyz',camera[:3]):
                q=round(value*256)
                for i,suffix in enumerate(('lo','hi','ext')):put('explorer_cam_'+axis+'_'+suffix,q>>(8*i))
            for axis,value in zip(('yaw','pitch'),camera[3:]):
                q=round(value*65536/360)&65535;put('explorer_cam_'+axis,q>>8);put('qc_demo_'+axis+'_lo',q)
            for mask in ([0] if room else [0,1,2,4,8,15]):
                if not room:cmds.append(f'> ${l["sm_visible"]:04x} '+' '.join(f'{int(bool(mask&(1<<i))):02x}' for i in range(4)))
                cmds+=['enable 1','ignore 1 2','x','disable 1','enable 2','x','disable 2','bank ram',
                    f'save "{stem}-{case}-{mask}.ram" 0 $0000 $ffff','bank cpu',f'save "{stem}-{case}-{mask}.color.ram" 0 $d800 $dbe7']
                if tag=='shared' and mask==15 and case in ('front','rear','oblique'):
                    cmds+=['enable 3','ignore 3 1','x','disable 3',f'screenshot "{stem}-{case}.png" 2']
        cmds.append('quit');info=native.run(prg,stem,cmds)
        write(stem.with_suffix('.json'),info)
        return l,info
    finally:native.ROOT=old


def memory(tag,case,mask):return (ROOT/f'reports/shared-views/{tag}-{case}-{mask}.ram').read_bytes()[2:]
def bitmap(m):return m[0x2000:0x3f40]+m[0x6000:0x7f40]
def pixel(m,x,y):
    py=8+y*2;a=0x2000+(py//8)*320+(6+x//4)*8+py%8
    return (m[a]>>(6-2*(x&3)))&3


def source_memory(ram,l,asset,copies):
    n=len(asset['vertices']);expected=bytes(p[a]&255 for a in (0,2,1) for _ in range(copies) for p in asset['vertices'])
    assert l['sm_source_end']-l['sm_source_begin']==len(expected)==18*copies
    assert ram[l['sm_source_begin']:l['sm_source_end']]==expected
    for corner in range(4):
        values=bytes(f[corner] if corner<3 else 0 for _ in range(copies) for f in asset['faces'])
        assert ram[l[f'face{corner}']+16:l[f'face{corner}']+16+8*copies]==values
        if corner<3:assert l[f'face{corner+1}']-l[f'face{corner}']==16+8*copies


def comparisons(build):
    replicated,rbuild=reference('replicated');room,cbuild=reference('room')
    labels={};runs={}
    for tag,root,name,plain in [('shared',ROOT,build,False),('replicated',replicated,rbuild,False),('room',room,cbuild,True)]:
        labels[tag],runs[tag]=capture(root,name,tag,plain)
    asset=read(ROOT/'assets/crystal-mesh.json');ui=[];results=[]
    for tag,copies in [('shared',1),('replicated',4)]:
        source_memory((ROOT/f'reports/shared-views/{tag}-initial.ram').read_bytes()[2:],labels[tag],asset,copies)
    for case,camera in specifications():
        for mask in [0,1,2,4,8,15]:
            memories=[];colors=[]
            for tag in ('shared','replicated'):
                m=memory(tag,case,mask);color=(ROOT/f'reports/shared-views/{tag}-{case}-{mask}.color.ram').read_bytes()[2:]
                ui.append(check_frame(m,color,labels[tag],tag+'-'+case+'-'+str(mask)))
                source_memory(m,labels[tag],asset,1 if tag=='shared' else 4)
                memories.append(m);colors.append(color)
            assert bitmap(memories[0])==bitmap(memories[1]),(case,mask,'shared/replicated pixels')
            assert colors[0]==colors[1],(case,mask,'shared/replicated palette')
            for a in (0x400,0x5c00):assert memories[0][a:a+1000]==memories[1][a:a+1000]
            if mask==0:
                ref=memory('room',case,0);color=(ROOT/f'reports/shared-views/room-{case}-0.color.ram').read_bytes()[2:]
                ui.append(check_frame(ref,color,labels['room'],'original-room-'+case))
                assert bitmap(memories[0])==bitmap(ref),(case,'world mesh changed by source compaction')
                assert colors[0]==color
                for a in (0x400,0x5c00):assert memories[0][a:a+1000]==ref[a:a+1000]
            elif case in ('front','rear'):assert bitmap(memories[0])!=bitmap(memory('shared',case,0)),(case,mask,'visible instance produced no pixels')
            results.append(dict(case=case,camera=camera,mask=mask,bitmapBytesCompared=16000,pixelsAndPaletteIdentical=True,originalRoomCompared=mask==0))
    return results,ui,labels,runs


def qround(n):return ((abs(n)+128)//256)*(1 if n>=0 else -1)
def trig(phase):
    table=[round(math.sin(i*math.tau/256)*256) for i in range(256)]
    hi=(phase>>8)&255;return table[hi]+qround((table[(hi+1)&255]-table[hi])*(phase&255))
def expected_vertices(config,asset,camera=(0,0,-18)):
    result=[];floating=[]
    for obj in config['instances']:
        phase=round(obj['yawDegrees']*65536/360)&65535;scale=round(obj['scale']*256)
        s=qround(trig(phase)*scale);c=qround(trig((phase+16384)&65535)*scale)
        p=[round(x*256) for x in obj['position']];a=math.radians(obj['yawDegrees'])
        vertices=[]
        for x,y,z in asset['vertices']:
            world=[p[0]+x*c-y*s,p[1]+x*s+y*c,p[2]+z*scale]
            vertices.append([world[0]-round(camera[0]*256),world[2]-round(camera[1]*256),world[1]-round(camera[2]*256)])
            ideal=[obj['position'][0]+obj['scale']*(x*math.cos(a)-y*math.sin(a)),obj['position'][1]+obj['scale']*(x*math.sin(a)+y*math.cos(a)),obj['position'][2]+obj['scale']*z]
            floating.append(max(abs(world[j]/256-ideal[j]) for j in range(3)))
        result.append(vertices)
    return result,max(floating)


def transform_proof(build):
    b,prg,l=native.paths(build);stem=ROOT/'reports/shared-state/native';cfg=read(ROOT/'assets/shared-meshes.json');asset=read(ROOT/'assets/crystal-mesh.json')
    variants=[('base',copy.deepcopy(cfg))]
    moved=copy.deepcopy(cfg);moved['instances'][0]['position'][0]+=1/256;variants.append(('move-west',moved))
    scaled=copy.deepcopy(cfg);scaled['instances'][1]['scale']=.5;variants.append(('scale-north',scaled))
    rotated=copy.deepcopy(cfg);rotated['instances'][2]['yawDegrees']=90;variants.append(('yaw-south',rotated))
    hidden=copy.deepcopy(cfg);hidden['instances'][3]['visible']=False;variants.append(('hide-east',hidden))
    cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x',f'> ${l["advance_sim_tick"]:04x} 60','disable 1','break exec .fps_frame_done','disable 2']
    for axis,value in zip('xyz',(0,0,-18*256)):
        for i,suffix in enumerate(('lo','hi','ext')):cmds.append(f'> ${l["explorer_cam_"+axis+"_"+suffix]:04x} {(value>>(8*i))&255:02x}')
    for n in ('explorer_cam_yaw','explorer_cam_pitch','qc_demo_yaw_lo','qc_demo_pitch_lo'):cmds.append(f'> ${l[n]:04x} 00')
    for tag,config in variants:
        for i,obj in enumerate(config['instances']):
            for axis,public in [('x',0),('y',2),('z',1)]:
                q=round(obj['position'][public]*256)
                for j in range(3):cmds.append(f'> ${l[f"sm_position_{axis}{j}"]+i:04x} {(q>>(8*j))&255:02x}')
            q=round(obj['yawDegrees']*65536/360)&65535
            for name,value in [('sm_yaw_lo',q),('sm_yaw_hi',q>>8),('sm_scale_q6',round(obj['scale']*64)),('sm_visible',int(obj['visible']))]:cmds.append(f'> ${l[name]+i:04x} {value&255:02x}')
        cmds+=['enable 1','ignore 1 2','x','disable 1','enable 2','x','disable 2','bank ram',f'save "{stem}-{tag}.ram" 0 $0000 $ffff','bank cpu']
    cmds.append('quit');info=native.run(prg,stem,cmds);rows=[];previous=None
    for index,(tag,config) in enumerate(variants):
        m=Path(str(stem)+f'-{tag}.ram').read_bytes()[2:];expected,error=expected_vertices(config,asset);actual=[]
        for i in range(4):
            values=[]
            for vertex in range(9+6*i,15+6*i):
                p=[]
                for axis in 'xyz':
                    q=sum(m[l[f'hc_cam_{axis}{j}']+vertex]<<(8*j) for j in range(3));p.append(q-(1<<24) if q&(1<<23) else q)
                values.append(p)
            actual.append(values)
        assert actual==expected,(tag,'independent exact Q8 vertex oracle',actual,expected)
        assert error<=.04,(tag,'floating rotation/scale error',error)
        source_memory(m,l,asset,1)
        if index==0:previous=actual
        else:
            changed={i for i,(a,b) in enumerate(zip(previous,actual)) if a!=b};wanted={index-1} if index<4 else set()
            assert changed==wanted,(tag,'another instance changed',changed,wanted)
        rows.append(dict(case=tag,exactVertices=24,independentBuffers=True,maxFloatingErrorWU=error,actualQ8=actual))
    info.update(result='PASS',cases=rows,fixture='monitor controls instance data only; exact native transform code and source geometry unchanged')
    write(stem.with_suffix('.json'),info);return rows


def pixel_oracles():
    cfg=read(ROOT/'assets/shared-meshes.json');asset=read(ROOT/'assets/crystal-mesh.json');levels=read(ROOT/'reports/surface-rendering.json')['faces']
    relative,_=expected_vertices(cfg,asset,camera=(0,0,0))
    vertices=[[[v[0]/256,v[2]/256,v[1]/256] for v in points] for points in relative]
    def sub(a,b):return [x-y for x,y in zip(a,b)]
    def cross(a,b):return [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
    def dot(a,b):return sum(x*y for x,y in zip(a,b))
    bayer=[1,9,3,11,13,5,15,7,4,12,2,10,16,8,14,6];rows=[]
    for case,camera in specifications()[:2]:
        sign=1 if camera[3]==0 else -1;origin=[camera[0],camera[2],camera[1]];hits=[0]*4;checked=0
        m=memory('shared',case,15);background=memory('shared',case,0)
        boxes=[]
        for i,points in enumerate(vertices):
            projected=[[48+sign*(p[0]-origin[0])*41/(sign*(p[1]-origin[1])),30-(p[2]-origin[2])*41/(sign*(p[1]-origin[1]))] for p in points]
            boxes.append([min(p[a] for p in projected) for a in range(2)]+[max(p[a] for p in projected) for a in range(2)])
            alone=memory('shared',case,1<<i)
            changed=[(x,y) for y in range(60) for x in range(96) if pixel(alone,x,y)!=pixel(background,x,y)]
            assert changed
            assert all(boxes[i][0]-2<=x<=boxes[i][2]+2 and boxes[i][1]-2<=y<=boxes[i][3]+2 for x,y in changed),(case,i,'independent projected instance footprint')
        for y in range(60):
            for x in range(96):
                direction=[sign*(x-48)/41,sign,(30-y)/41];nearest=None
                for i,points in enumerate(vertices):
                    for f,face in enumerate(asset['faces']):
                        a,b,c=[points[j] for j in face];e1=sub(b,a);e2=sub(c,a);p=cross(direction,e2);det=dot(e1,p)
                        if abs(det)<1e-10:continue
                        tvec=sub(origin,a);u=dot(tvec,p)/det;q=cross(tvec,e1);v=dot(direction,q)/det;t=dot(e2,q)/det
                        if t<=0 or u<0 or v<0 or u+v>1:continue
                        if nearest is None or t<nearest[0]:nearest=(t,i,f,[a,b,c])
                if nearest is None:continue
                _,i,f,triangle=nearest
                screen=[[48+sign*(p[0]-origin[0])*41/(sign*(p[1]-origin[1])),30-(p[2]-origin[2])*41/(sign*(p[1]-origin[1]))] for p in triangle]
                distances=[]
                for j in range(3):
                    a,b=screen[j],screen[(j+1)%3];dist=math.dist(a,b)
                    distances.append(abs((b[0]-a[0])*(y-a[1])-(b[1]-a[1])*(x-a[0]))/dist if dist else 0)
                if min(distances)<1.1:continue # exclude native Q2 coverage rounding at edges
                level=levels[16+8*i+f]['levels'][0]
                pigment=(1 if level<16 else 2)+int(bayer[(y&3)*4+(x&3)]<(level if level<16 else level-16))
                assert pixel(m,x,y)==pigment,(case,x,y,i,f,'independent nearest convex face/Gouraud level',pixel(m,x,y),pigment)
                hits[i]+=1;checked+=1
        assert checked>=30 and all(hits),(case,'insufficient independent interior samples',hits)
        rows.append(dict(case=case,checkedInteriorPixels=checked,samplesPerInstance=hits,projectedBounds=boxes,
            oracle='independent ray/triangle nearest hit and33-level Bayer pigment; conservative1.1pixel edge exclusion'))
    write(ROOT/'reports/shared-pixel-oracles.json',dict(result='PASS',cases=rows));return rows


def lod_proof(build):
    b,prg,l=native.paths(build);rows=[]
    for depth,wanted in [(14,16),(18,8),(22,0)]:
        stem=ROOT/f'reports/shared-lod/depth-{depth}'
        cmds=[f'logname "{stem}.monitor.log"','log on',f'load_labels "{b/"3Dvibe64.labels"}"',
            'break exec .render_frame_begin','x',f'> ${l["advance_sim_tick"]:04x} 60']
        for axis,value in zip('xyz',((24-depth)*256,0,0)):
            for i,suffix in enumerate(('lo','hi','ext')):
                cmds.append(f'> ${l["explorer_cam_"+axis+"_"+suffix]:04x} {(value>>(8*i))&255:02x}')
        for name,value in [('explorer_cam_yaw',192),('qc_demo_yaw_lo',0),('explorer_cam_pitch',0),('qc_demo_pitch_lo',0)]:
            cmds.append(f'> ${l[name]:04x} {value:02x}')
        cmds += [f'> ${l["sm_visible"]:04x} 00 00 00 00','ignore 1 2','x','disable 1',
            'trace exec .lg_set_weight','break exec .fps_frame_done','x','quit']
        info=native.run(prg,stem,cmds);text=Path(str(stem)+'.monitor.log').read_text()
        calls=[(int(a,16),int(y,16)) for a,y in re.findall(r'\.C:'+f'{l["lg_set_weight"]:04x}'+r'[^\n]*A:([0-9a-f]{2})[^\n]*Y:([0-9a-f]{2})',text,re.I)]
        wall=[a for a,face in calls if face in (2,3)]
        assert wanted in wall,(depth,'native right wall LOD',wall,calls)
        assert all(a in (16,wanted) for a in wall),(depth,wall)
        info.update(result='PASS',depthWU=depth,expectedWeight=wanted,nativeRightWallWeights=wall,
            fixture='original wall at X24; hidden instances; native topology resolver and LOD sampler unchanged')
        write(stem.with_suffix('.json'),info);rows.append(info)
    return rows


def checks(build):
    results,ui,labels,runs=comparisons(build)
    transforms=transform_proof(build)
    pixels=pixel_oracles()
    lod=lod_proof(build)
    result=dict(result='PASS',PRGSHA256=native.sha(native.paths(build)[1]),comparisons=results,UI=ui,transforms=transforms,pixelOracles=pixels,LOD=lod,referenceRuns=runs)
    write(ROOT/'reports/native-shared-meshes.json',result);return result
