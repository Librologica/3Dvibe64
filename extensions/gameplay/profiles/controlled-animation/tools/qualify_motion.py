"""Native Q8-02 commands, independent geometry and dungeon/flight regressions."""
import copy
import json
import math
import os
import shutil
import subprocess
import sys
from pathlib import Path
import native_compare as native
import qualify_shared_meshes as shared
from verify_ui import check_frame
ROOT=native.ROOT


def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,d):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(d,indent=2)+'\n',encoding='utf-8')
def word(m,l,n):return int.from_bytes(bytes([m[l[n+'0']],m[l[n+'1']]]),'little',signed=True)


class Player:
    """Independent clip cursor/closed-form pose oracle; no generated ASM import."""
    def __init__(self,cfg):
        self.clips=copy.deepcopy(cfg['clips'])
        self.state=[dict(frame=0,elapsed=0,playing=0,speed=c['speed'],loop=int(c['loop']),completed=0) for c in self.clips]

    def control(self,op,i,arg=0):
        if not 0<=i<len(self.clips) or not 0<=op<8:return False
        s=self.state[i];count=len(self.clips[i]['keys'])
        if op==3 and not 0<=arg<count or op==4 and arg not in (1,2,4) or op==5 and arg not in (0,1):return False
        if op==0:s['playing']=0
        elif op==1:s.update(playing=1,completed=0)
        elif op==4:s['speed']=arg
        elif op==5:
            s['loop']=arg
            if not arg and s['frame']==count-1:s.update(elapsed=0,playing=0,completed=1)
        else:
            if op in (2,7):s.update(frame=0,playing=int(op==7))
            elif op==3:s['frame']=arg
            else:s.update(frame=(s['frame']+1)%count if s['loop'] else min(count-1,s['frame']+1),playing=0)
            s.update(elapsed=0,completed=0)
            if not s['loop'] and s['frame']==count-1:s.update(playing=0,completed=1)
        return True

    def tick(self):
        for c,s in zip(self.clips,self.state):
            if not s['playing']:continue
            if not s['loop'] and s['frame']==len(c['keys'])-1:s.update(playing=0,completed=1);continue
            t=s['frame']*64+s['elapsed']+s['speed'];end=(len(c['keys'])-1)*64
            if not s['loop'] and t>=end:s.update(frame=len(c['keys'])-1,elapsed=0,playing=0,completed=1)
            else:s.update(frame=(t//64)%len(c['keys']),elapsed=t%64)

    def poses(self):
        result=[]
        def step(a,b):
            delta=b-a;return (1 if delta>=0 else -1)*int(abs(delta)/64+.5)
        for c,s in zip(self.clips,self.state):
            a=c['keys'][s['frame']];b=c['keys'][(s['frame']+1)%len(c['keys'])];t=s['elapsed']
            p=[round(v*256)+step(round(v*256),round(w*256))*t for v,w in zip(a['position'],b['position'])]
            yaw=round(a['yawDegrees']*65536/360)&65535;next_yaw=round(b['yawDegrees']*65536/360)&65535
            delta=((next_yaw-yaw+32768)&65535)-32768;yaw=(yaw+step(0,delta)*t)&65535
            scale=(round(a['scale']*16384)+step(round(a['scale']*16384),round(b['scale']*16384))*t)>>8
            result.append(dict(positionQ8=p,yawPhase=yaw,scaleQ6=scale,visible=int(a['visible'])))
        return result


def native_poses(m,l,n=4):
    result=[]
    for i in range(n):
        pos=[]
        for axis in ('x','z','y'):
            q=sum(m[l[f'sm_position_{axis}{j}']+i]<<(8*j) for j in range(3));pos.append(q-(1<<24) if q&(1<<23) else q)
        result.append(dict(positionQ8=pos,yawPhase=m[l['sm_yaw_lo']+i]+256*m[l['sm_yaw_hi']+i],scaleQ6=m[l['sm_scale_q6']+i],visible=m[l['sm_visible']+i]))
    return result


def playback_proof(build):
    b,prg,l=native.paths(build);meta=read(b/'build.json');cfg=read(ROOT/'assets/motion.json');model=Player(cfg)
    start,end=max(meta['remainingGaps'],key=lambda p:p[1]-p[0]);assert end-start>=96
    stem=ROOT/'reports/motion-state/native';cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x','disable 1',f'break exec ${start+80:04x}']
    records=[]
    def put(n,v):cmds.append(f'> ${l[n]:04x} {v&255:02x}')
    def execute(routine,op=0,index=0,arg=0,tag=None,expected=True):
        addr=l[routine];data=[0xa9,op,0xa2,index,0xa0,arg,0x20,addr&255,addr>>8,0x08,0x68,0x8d,(start+95)&255,(start+95)>>8]
        data += [0xea]*(80-len(data));cmds.extend([f'> ${start:04x} '+' '.join(f'{v:02x}' for v in data),f'r pc=${start:04x}','x'])
        if tag:
            cmds.extend(['bank ram',f'save "{stem}-{tag}.ram" 0 $0000 $ffff','bank cpu'])
            records.append(dict(case=tag,poses=copy.deepcopy(model.poses()),states=copy.deepcopy(model.state),carry=expected if routine=='an_control' else None))
    put('an_key_override',1)
    for c in (0,1,2,6,7):put(f'explorer_key_col{c}',255)
    for i in range(4):model.control(2,i);execute('an_control',2,i)
    execute('cr_tick',tag='initial')
    def command(tag,op,i=0,arg=0):
        result=model.control(op,i,arg);execute('an_control',op,i,arg,tag,result)
    def ticks(count,tag):
        for i in range(count):model.tick();execute('an_tick',tag=tag if i==count-1 else None)
    command('play',1);ticks(1,'tick1');ticks(30,'tick31');ticks(32,'tick63');ticks(1,'key1');ticks(1,'key1-tick1')
    command('pause',0);ticks(10,'paused10');command('resume',1);ticks(7,'resumed7')
    command('speed4',4,arg=4);ticks(12,'fast12');command('seek3',3,arg=3);ticks(16,'loop-wrap')
    command('seek-closing',3,arg=3);ticks(4,'closing-segment');command('cut-closing-loop',5,arg=0)
    command('loop-off',5,arg=0);command('restart-nonloop',7);ticks(48,'nonloop-end');ticks(8,'completed-hold')
    command('speed2',4,arg=2);command('loop-on',5,arg=1);command('restart-loop',7);ticks(130,'loop-two-cycles')
    command('seek-north',3,1,2);command('play-north',1,1);ticks(5,'two-independent')
    command('stop-west',2);command('step-north',6,1);ticks(4,'north-held')
    for tag,op,i,arg in [('invalid-instance',1,4,0),('invalid-opcode',255,0,0),('invalid-key',3,0,8),('invalid-speed0',4,0,0),('invalid-speed3',4,0,3),('invalid-loop',5,0,2)]:command(tag,op,i,arg)
    # Exercise the actual keyboard polling entry, including held-key latches.
    put('an_selected',0);put('an_last_keys',0);put('explorer_key_col7',239)
    model.control(1,0);execute('an_poll',tag='keyboard-space')
    execute('an_poll',tag='keyboard-held')
    put('explorer_key_col7',255);execute('an_poll')
    put('explorer_key_col2',253);model.control(7,0);execute('an_poll',tag='keyboard-restart')
    put('explorer_key_col2',255);execute('an_poll')
    put('explorer_key_col2',191);model.control(6,0);execute('an_poll',tag='keyboard-step')
    put('explorer_key_col2',255);execute('an_poll')
    put('explorer_key_col2',223);model.control(4,0,4);execute('an_poll',tag='keyboard-speed')
    put('explorer_key_col2',255);execute('an_poll');put('explorer_key_col2',223);model.control(4,0,1);execute('an_poll',tag='keyboard-speed-wrap')
    put('explorer_key_col2',255);put('explorer_key_col7',247);execute('an_poll',tag='keyboard-select2')
    cmds.append('quit');info=native.run(prg,stem,cmds)
    source_ranges=[(l[a],l[z]) for a,z in [('an_source_begin','an_source_end'),('cr_source_begin','cr_source_end'),('sm_source_begin','sm_source_end')]]
    immutable=None;rows=[]
    for r in records:
        m=Path(str(stem)+'-'+r['case']+'.ram').read_bytes()[2:]
        assert native_poses(m,l)==r['poses'],(r['case'],'pose',native_poses(m,l),r['poses'])
        actual=[{k:m[l['an_'+k]+i] for k in r['states'][i]} for i in range(4)]
        assert actual==r['states'],(r['case'],'cursor/state',actual,r['states'])
        if r['carry'] is not None:assert bool(m[start+95]&1)==r['carry'],(r['case'],'command carry')
        source=b''.join(m[a:z] for a,z in source_ranges)
        if immutable is None:immutable=source
        else:assert source==immutable,(r['case'],'source modified')
        rows.append(dict(case=r['case'],poses=r['poses'],states=actual,sourceUnchanged=True))
    m=Path(str(stem)+'-keyboard-select2.ram').read_bytes()[2:];assert m[l['an_selected']]==1
    info.update(result='PASS',cases=rows,fixture='free-gap main-thread call trampoline only; native player/keyboard code and source data unchanged')
    write(stem.with_suffix('.json'),info);return rows


def reference():
    external=os.environ.get('Q8_MOTION_REFERENCE_PROJECT')
    if external:return Path(external).resolve(),'shared-meshes'
    root=ROOT/'verification/motion-reference';name='motion-reference'
    if (root/'qualification-build.json').exists():
        receipt=read(root/'qualification-build.json');assert native.sha(root/receipt['program'])==receipt['PRGSHA256'];return root,name
    assert not root.exists();root.mkdir(parents=True)
    for folder in ('src','sdk','private','assets'):shutil.copytree(ROOT/folder,root/folder,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
    shutil.copy2(ROOT/'build_demo.py',root/'build_demo.py')
    for folder in ('room','room/scenes','room/reports','reports','artifacts'):(root/folder).mkdir(exist_ok=True)
    cfg=read(root/'assets/motion.json');cfg['enabled']=False;write(root/'assets/motion.json',cfg)
    cfg=read(root/'assets/surfaces.json')
    for k in cfg['meshes']:cfg['meshes'][k]=cfg['meshes'][k][:16]
    write(root/'assets/surfaces.json',cfg)
    command=[sys.executable,'-B','build_demo.py','--name',name,'--artifact-tag',name,'--precise']
    p=subprocess.run(command,cwd=root,capture_output=True,timeout=300);(root/'reference-build.log').write_bytes(p.stdout+p.stderr);assert p.returncode==0
    info=read(root/f'room/build/{name}/build.json');write(root/'qualification-build.json',dict(command=command,program=info['distributionPRG'],PRGSHA256=native.sha(root/info['distributionPRG'])))
    return root,name


def poses_config(poses):
    cfg=read(ROOT/'assets/shared-meshes.json')
    for obj,p in zip(cfg['instances'],poses):obj.update(position=[v/256 for v in p['positionQ8']],yawDegrees=p['yawPhase']*360/65536,scale=p['scaleQ6']/64,visible=bool(p['visible']))
    return cfg


def camera_vertices(camera,poses):
    scene=read(ROOT/'room/scenes/large-room.json');asset=read(ROOT/'assets/crystal-mesh.json')
    objects,_=shared.expected_vertices(poses_config(poses),asset,camera=(0,0,0))
    world=[[round(v*256) for v in p] for p in scene['meshes'][0]['vertices'][:9]]+[v for points in objects for v in points]
    phases=[(-round(a*65536/360))&65535 for a in camera[3:]]
    trig=[(shared.trig(p),shared.trig((p+16384)&65535)) for p in phases];result=[]
    for p in world:
        x,y,z=[p[j]-round(camera[j]*256) for j in range(3)]
        if phases[0]:
            s,c=trig[0];x,z=shared.qround(x*c)-shared.qround(z*s),shared.qround(x*s)+shared.qround(z*c)
        if phases[1]:
            s,c=trig[1];y,z=shared.qround(y*c)-shared.qround(z*s),shared.qround(y*s)+shared.qround(z*c)
        if phases[2]:
            s,c=trig[2];x,y=shared.qround(x*c)-shared.qround(y*s),shared.qround(x*s)+shared.qround(y*c)
        result.append([x,y,z])
    return result


def view_specs(flight):
    cfg=read(ROOT/'assets/motion.json');model=Player(cfg);base=model.poses();cases=[]
    for name,camera in shared.specifications():cases.append(dict(name='legacy-'+name,camera=camera+[0],poses=base,reference=True))
    for i in range(4):model.control(3,i,(i+1)%4)
    for name,cam in [('animated-front',[0,0,-18,0,0,0]),('animated-rear',[0,0,18,180,0,0]),('animated-oblique',[-15,0,-15,-45,14,0])]:cases.append(dict(name=name,camera=cam,poses=model.poses(),reference=False))
    if flight:
        for angle in (24.5,90,180,270):cases.append(dict(name='roll-'+str(angle).replace('.','-'),camera=[0,0,-18,0,0,angle],poses=base,reference=False))
        for name,cam in [('roll-oblique',[-15,0,-15,-45,14,37]),('roll-near',[5,0,-10,0,0,58]),('roll-up',[0,0,-18,0,55,35]),('roll-down',[0,0,-18,0,-55,-35]),('roll-fractional',[1.25,.125,-17.75,11.125,-8.25,-24.5])]:cases.append(dict(name=name,camera=cam,poses=model.poses(),reference=False))
    return cases


def capture_views(root,build,tag,cases,extension):
    old=native.ROOT;native.ROOT=root
    try:
        b,prg,l=native.paths(build);stem=ROOT/'reports/motion-views'/tag
        cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x',f'> ${l["advance_sim_tick"]:04x} 60','disable 1','break exec .fps_frame_done','disable 2','break exec .raster_irq','disable 3']
        def put(n,v,offset=0):cmds.append(f'> ${l[n]+offset:04x} {v&255:02x}')
        for case in cases:
            cam=case['camera']
            for axis,v in zip('xyz',cam[:3]):
                q=round(v*256)
                for j,suffix in enumerate(('lo','hi','ext')):put(f'explorer_cam_{axis}_{suffix}',q>>(8*j))
            for angle,v in zip(('yaw','pitch'),cam[3:5]):
                q=round(v*65536/360)&65535;put('qc_demo_'+angle+'_lo',q);put('explorer_cam_'+angle,q>>8)
            if extension:
                q=round(cam[5]*65536/360)&65535;put('cr_roll_lo',q);put('cr_roll_hi',q>>8);put('cr_auto',0)
            for i,p in enumerate(case['poses']):
                for axis,j in [('x',0),('y',2),('z',1)]:
                    for k in range(3):put(f'sm_position_{axis}{k}',p['positionQ8'][j]>>(8*k),i)
                for n,v in [('sm_yaw_lo',p['yawPhase']),('sm_yaw_hi',p['yawPhase']>>8),('sm_scale_q6',p['scaleQ6']),('sm_visible',p['visible'])]:put(n,v,i)
            path=str(stem)+'-'+case['name']
            cmds+=['enable 1','ignore 1 2','x','disable 1','enable 2','x','disable 2','bank ram',f'save "{path}.ram" 0 $0000 $ffff','bank cpu',f'save "{path}.color.ram" 0 $d800 $dbe7']
            if extension and case['name'] in ('legacy-front','animated-front','roll-24-5','roll-90','roll-oblique'):
                cmds+=['enable 3','ignore 3 1','x','disable 3',f'screenshot "{path}.png" 2']
        cmds.append('quit');info=native.run(prg,stem,cmds);write(stem.with_suffix('.json'),info);return l,info
    finally:native.ROOT=old


def views(build):
    flight=read(ROOT/'assets/motion.json')['camera']['mode']=='flight';cases=view_specs(flight)
    l,run=capture_views(ROOT,build,'active',cases,True);ref,rname=reference()
    rl,rrun=capture_views(ref,rname,'reference',[c for c in cases if c['reference']],False)
    ui=[];rows=[];oracles=[];asset=read(ROOT/'assets/crystal-mesh.json')
    for case in cases:
        tag=case['name'];m=(ROOT/f'reports/motion-views/active-{tag}.ram').read_bytes()[2:];color=(ROOT/f'reports/motion-views/active-{tag}.color.ram').read_bytes()[2:]
        ui.append(check_frame(m,color,l,tag));expected=camera_vertices(case['camera'],case['poses']);actual=[]
        for vertex in range(33):
            point=[]
            for axis in 'xyz':
                v=sum(m[l[f'hc_cam_{axis}{j}']+vertex]<<(8*j) for j in range(3));point.append(v-(1<<24) if v&(1<<23) else v)
            actual.append(point)
        assert actual==expected,(tag,'independent signed24 yaw/pitch/roll oracle',actual,expected)
        shared.source_memory(m,l,asset,1)
        if case['reference']:
            r=(ROOT/f'reports/motion-views/reference-{tag}.ram').read_bytes()[2:];rc=(ROOT/f'reports/motion-views/reference-{tag}.color.ram').read_bytes()[2:]
            ui.append(check_frame(r,rc,rl,'reference-'+tag))
            assert shared.bitmap(m)==shared.bitmap(r),(tag,'zero-roll regression bitmap')
            assert color==rc
            for a in (0x400,0x5c00):assert m[a:a+1000]==r[a:a+1000]
        if tag in ('legacy-front','legacy-rear','roll-24-5','roll-90','roll-180','roll-270'):
            oracles.append(pixel_oracle(m,expected,tag))
        rows.append(dict(case=tag,camera=case['camera'],exactQ8Vertices=33,referencePixelsCompared=case['reference']))
    write(ROOT/'reports/motion-view-proof.json',dict(result='PASS',cases=rows,pixelOracles=oracles,UI=ui,activeRun=run,referenceRun=rrun))
    return rows,ui,oracles


def pixel_oracle(m,vertices,tag):
    levels=read(ROOT/'reports/surface-rendering.json')['faces'];faces=read(ROOT/'assets/crystal-mesh.json')['faces']
    models=[[[v/256 for v in p] for p in vertices[9+6*i:15+6*i]] for i in range(4)]
    def sub(a,b):return [x-y for x,y in zip(a,b)]
    def cross(a,b):return [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
    def dot(a,b):return sum(x*y for x,y in zip(a,b))
    bayer=[1,9,3,11,13,5,15,7,4,12,2,10,16,8,14,6];count=0
    for y in range(60):
        for x in range(96):
            ray=[(x-48)/41,(30-y)/41,1];nearest=None
            for i,points in enumerate(models):
                for f,face in enumerate(faces):
                    a,b,c=[points[j] for j in face]
                    if min(a[2],b[2],c[2])<4:continue
                    e1=sub(b,a);e2=sub(c,a);p=cross(ray,e2);det=dot(e1,p)
                    if abs(det)<1e-9:continue
                    tvec=[-v for v in a];u=dot(tvec,p)/det;q=cross(tvec,e1);v=dot(ray,q)/det;t=dot(e2,q)/det
                    if t<=0 or u<0 or v<0 or u+v>1:continue
                    if nearest is None or t<nearest[0]:nearest=(t,i,f,[a,b,c])
            if nearest is None:continue
            _,i,f,triangle=nearest;screen=[[48+p[0]*41/p[2],30-p[1]*41/p[2]] for p in triangle];distance=[]
            for j,a in enumerate(screen):
                b=screen[(j+1)%3];length=math.dist(a,b);distance.append(abs((b[0]-a[0])*(y-a[1])-(b[1]-a[1])*(x-a[0]))/length if length else 0)
            if min(distance)<1.25:continue
            level=levels[16+i*8+f]['levels'][0];pigment=(1 if level<16 else 2)+int(bayer[(y&3)*4+(x&3)]<(level if level<16 else level-16))
            assert shared.pixel(m,x,y)==pigment,(tag,x,y,i,f,'ray/triangle nearest-face pigment',shared.pixel(m,x,y),pigment)
            count+=1
    assert count>=25,(tag,'too few independent interior samples',count)
    return dict(case=tag,independentInteriorPixels=count,oracle='ray/triangle nearest hit in independently calculated Q8 camera space;1.25pixel edge exclusion')


def roll_commands(build):
    b,prg,l=native.paths(build);meta=read(b/'build.json');start,end=max(meta['remainingGaps'],key=lambda p:p[1]-p[0]);stem=ROOT/'reports/roll-controls/native'
    flight=read(ROOT/'assets/motion.json')['camera']['mode']=='flight'
    cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x','disable 1',f'break exec ${start+80:04x}'];expected=[];old=0
    for tag,angle in [('zero',0),('fraction',24.5),('quarter',90),('half',180),('negative',-24.5)]:
        p=round(angle*65536/360)&65535;a=l['cr_set_roll'];code=[0xa9,p&255,0xa0,p>>8,0x20,a&255,a>>8,0x08,0x68,0x8d,(start+95)&255,(start+95)>>8]+[0xea]*68
        cmds.extend([f'> ${start:04x} '+' '.join(f'{v:02x}' for v in code),f'r pc=${start:04x}','x','bank ram',f'save "{stem}-{tag}.ram" 0 $0000 $ffff','bank cpu'])
        success=flight or p==0
        if success:old=p
        expected.append((tag,old,success))
    auto_cases=[]
    def put(n,v):cmds.append(f'> ${l[n]:04x} {v&255:02x}')
    def call(names,tag):
        code=[]
        for name in names:
            a=l[name];code += [0x20,a&255,a>>8]
        code += [0xea]*(80-len(code))
        cmds.extend([f'> ${start:04x} '+' '.join(f'{v:02x}' for v in code),f'r pc=${start:04x}','x','bank ram',f'save "{stem}-{tag}.ram" 0 $0000 $ffff','bank cpu'])
    amplitude=read(ROOT/'assets/motion.json')['camera']['bankDegrees']
    for k,t in [(0,0),(0,1),(7,31),(12,0),(24,0),(35,63),(47,63)]:
        put('demo_key',k);put('demo_subtick',t);tag=f'bank-{k}-{t}';call(['cr_resume','cr_tick'],tag)
        a=round(amplitude*math.sin(k*math.tau/48)*65536/360)&65535
        b=round(amplitude*math.sin(((k+1)%48)*math.tau/48)*65536/360)&65535
        d=((b-a+32768)&65535)-32768;step=int(abs(d)/64+.5)*(1 if d>=0 else -1)
        auto_cases.append((tag,(a+step*t)&65535 if flight else 0))
    put('an_key_override',1)
    for c in (0,1,2,6,7):put(f'explorer_key_col{c}',255)
    put('cr_roll_lo',0);put('cr_roll_hi',0);put('explorer_key_col7',191);call(['an_poll'],'key-q');auto_cases.append(('key-q',65408 if flight else 0))
    put('explorer_key_col7',255);put('explorer_key_col1',191);call(['an_poll'],'key-e');auto_cases.append(('key-e',0))
    put('explorer_key_col1',255);put('cr_roll_lo',23 if flight else 0);put('cr_roll_hi',12 if flight else 0);put('explorer_key_col6',247);call(['an_poll'],'key-home');auto_cases.append(('key-home',0))
    put('explorer_key_col6',255);put('explorer_key_col2',239);put('demo_key',12);put('demo_subtick',0);call(['an_poll','cr_tick'],'key-auto');auto_cases.append(('key-auto',round(amplitude*65536/360)&65535 if flight else 0))
    cmds.append('quit');info=native.run(prg,stem,cmds);rows=[]
    for tag,p,success in expected:
        m=Path(str(stem)+'-'+tag+'.ram').read_bytes()[2:];actual=m[l['cr_roll_lo']]+256*m[l['cr_roll_hi']]
        assert actual==p and bool(m[start+95]&1)==success,(tag,actual,p,success)
        rows.append(dict(case=tag,phase=p,accepted=success))
    for tag,p in auto_cases:
        m=Path(str(stem)+'-'+tag+'.ram').read_bytes()[2:];actual=m[l['cr_roll_lo']]+256*m[l['cr_roll_hi']]
        assert actual==p,(tag,'native bank clock/keyboard',actual,p)
        rows.append(dict(case=tag,phase=p,clockAndKeyboard=True))
    info.update(result='PASS',mode='flight' if flight else 'dungeon',cases=rows);write(stem.with_suffix('.json'),info);return rows


def checks(build):
    state=playback_proof(build);rows,ui,pixels=views(build);roll=roll_commands(build);lod=shared.lod_proof(build)
    result=dict(result='PASS',PRGSHA256=native.sha(native.paths(build)[1]),playback=state,views=rows,UI=ui,pixelOracles=pixels,rollCommands=roll,LOD=lod)
    write(ROOT/'reports/native-motion.json',result);return result
