"""Executed routine correctness and native UI/visibility/actor qualification."""
import argparse
import json
import math
from pathlib import Path
import sys
import native_helpers as native


def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))


class BankedMemory:
    """Separate I/O/ColorRAM from physical RAM under I/O, as on the C64."""
    def __init__(self):
        self.ram=[0]*65536;self.io=[0]*4096;self.io[0xc01]=255
    def __len__(self):return 65536
    def __getitem__(self,key):
        if isinstance(key,slice):return [self[i] for i in range(*key.indices(65536))]
        return self.io[key-0xd000] if 0xd000<=key<0xe000 and self.ram[1]&4 and self.ram[1]&3 else self.ram[key]
    def __setitem__(self,key,value):
        if isinstance(key,slice):self.ram[key]=value;return
        if 0xd000<=key<0xe000 and self.ram[1]&4 and self.ram[1]&3:self.io[key-0xd000]=value
        else:self.ram[key]=value


def machine(build):
    try:from py65.devices.mpu6502 import MPU
    except ImportError:
        sys.path.insert(0,r'C:\Users\rapso\Desktop\3Dvibe64\Gouraud\3Dvibe64_dev_1.5.5_Mode7-perspective\build\test-venv\Lib\site-packages')
        from py65.devices.mpu6502 import MPU
    m=MPU(memory=BankedMemory());raw=(build/'3Dvibe64.prg').read_bytes();start=int.from_bytes(raw[:2],'little')
    m.memory[start:start+len(raw)-2]=raw[2:];m.memory[1]=0x35
    return m,native.labels(build/'3Dvibe64.labels')


def call(m,l,name):
    m.pc=l[name];m.sp=0xfd;m.p=0x20;m.memory[0x1fe]=0xff;m.memory[0x1ff]=0xfd
    for _ in range(800000):
        if m.pc==0xfe00:return
        m.step()
    raise AssertionError(('no return',name,hex(m.pc)))


def routines(root,build):
    m,l=machine(build);r=m.memory
    call(m,l,'game_ui_init')
    bitmap=(root/'assets/ui-bitmap.bin').read_bytes();screen=(root/'assets/ui-screen.bin').read_bytes();color=(root/'assets/ui-color.bin').read_bytes()
    for a in [0x2000,0x6000]:assert bytes(r[a:a+8000])==bitmap
    for a in [l['SCREEN_B_BASE'],0x5c00]:assert bytes(r[a:a+1000])==screen
    assert bytes(r[0xd800:0xd800+1000])==color
    call(m,l,'ad_init')
    phases=[]
    for src,end,dst in [('ad_bb_initial','ad_bb_initial_end',l['game_ui_init']+304),('ad_wr_initial','ad_wr_initial_end',l['ui_pack2']),('ad_rank_initial','ad_rank_initial_end',l['ui_pack3'])]:
        size=l[end]-l[src];assert bytes(r[dst:dst+size])==bytes(r.ram[l[src]:l[end]])
        phases.append(dict(source=[l[src],l[end]],runtime=[dst,dst+size],bytes=size))
    assert l['wr_valid']+38<=l['bb_enabled'] and l['bb_enabled']>=l['game_ui_init']+304
    assert l['bb_pixels']==l['ui_pack0'] and l['ui_pack1']==l['bb_pixels']+256
    vertex_bytes=l['VERT_COUNT']
    vertex_overlays=[[l['hc_cam_x0'],l['hc_cam_x0']+9*vertex_bytes],
        [l['sx'],l['sx']+4*vertex_bytes],[l['vxrawlo'],l['vxrawlo']+6*vertex_bytes]]
    runtime=sorted([x['runtime'] for x in phases]+[[l['wr_coords'],l['wr_coords']+304],[l['bb_pixels'],l['bb_pixels']+512]]+vertex_overlays)
    for a,b in zip(runtime,runtime[1:]):assert a[1]<=b[0]
    # Runtime I/O decoders must restore banking and leave the UI bitmaps alone.
    original=read(root/'assets/warrior-poses.json')['poses'];ids=list(range(0,16,2))+list(range(16,32,2))+list(range(32,48))
    for pose,index in enumerate(ids):
        r[l['wr_pose']]=pose;r[l['wr_dirty']]=1;call(m,l,'wr_decode')
        expected=bytes(v[a]&255 for v in original[index] for a in [0,2,1])
        assert bytes(r[l['wr_coords']:l['wr_coords']+114])==expected,('pose',pose)
        assert r[1]==0x35
    frames=read(root/'assets/billboard-frames.json')['frames']
    for i,frame in enumerate(frames):
        r[l['bb_frame']]=i;r[l['bb_loaded']]=255;call(m,l,'bb_decode')
        assert bytes(r[l['bb_pixels']:l['bb_pixels']+512])==bytes(frame),('frame',i)
        assert r[1]==0x35
    for a in [0x2000,0x6000]:assert bytes(r[a:a+8000])==bitmap
    for i in range(5):
        row=read(root/'reports/cell-order.json')['depthTables'][i]
        actual=[r[l['ad_depth_levels']+i*10+r[l['ad_face_class']+f]] for f in range(len(row))]
        assert actual==row
    # Execute the actual painter selector for every shell/cube/actor face.
    # Native cube depths are WU; actor nodes already supply depth/4. Both
    # must retain a common bounded band, including camera-side order changes.
    stop=l['tr_depth_done'];saved=r[stop];r[stop]=0x60;depth_checks=0
    faces=read(root/'reports/scene.json');actor_first=faces['actorNodes'][0]
    order=read(root/'reports/cell-order.json')
    for cell in range(5):
        for face,solid in enumerate(order['solidFaces']):
            for depth in [0,8,28,60,128,254]:
                r[l['co_cell']]=cell;r[l['faceidx']]=face;r[l['p1lo']]=depth
                call(m,l,'bvf_depth_ready')
                fraction=min(15,depth if face>=actor_first else depth//4) if solid else 0
                assert m.a==order['depthTables'][cell][face]+fraction,(cell,face,depth,m.a)
                depth_checks+=1
    r[stop]=saved
    surfaces=read(root/'reports/surface-contract.json')['staticCubeTriangles']
    assert len(surfaces)==32 and all(a['flatCode']==b['flatCode'] for a,b in zip(surfaces[::2],surfaces[1::2]))
    def camera(x,z):
        for axis,v in [('x',x),('z',z)]:
            q=round(v*256)
            for j,suffix in enumerate(['lo','hi','ext']):r[l['explorer_cam_'+axis+'_'+suffix]]=(q>>(8*j))&255
    camera(7,-11);r[l['en_state']]=0;r[l['en_event_count']]=0
    call(m,l,'en_use');assert (r[l['en_state']],r[l['bc_state']],r[l['wr_stage']],r[l['wr_pose']],r[l['en_event_count']])==(1,1,2,16,1)
    for _ in range(400):
        call(m,l,'wr_tick');assert r[l['wr_stage']]==2 and 16<=r[l['wr_pose']]<32
    camera(7,80);call(m,l,'en_use');assert r[l['en_state']]==1 and r[l['en_rejected']]==1
    camera(7,-11);call(m,l,'en_use');assert (r[l['en_state']],r[l['bc_state']],r[l['wr_stage']])==(0,0,0)
    # Independent conservative cull: only an entirely negative-Z object rejects.
    checks=0
    for values in [[-257,-1,-65536],[-1,0,-1],[-1,1,-1],[256,512,65536]]:
        r[l['objidx']]=0;r[l['active_vfirst']]=0;r[l['active_vend']]=3
        for i,v in enumerate(values):
            for j in range(3):r[l['hc_cam_z'+str(j)]+i]=(v>>(8*j))&255
        call(m,l,'ad_room_visible');assert bool(m.p&1)==any(v>=0 for v in values);checks+=1
    m,l=machine(build);r=m.memory;positions=[];minimum=[999.,999.];cube_clearances=[999.,999.,999.]
    for tick in range(6144):
        call(m,l,'qc_demo_tick')
        def coord(axis):
            v=sum(r[l['explorer_cam_'+axis+'_'+s]]<<(8*j) for j,s in enumerate(['lo','hi','ext']))
            return (v-(1<<24) if v&(1<<23) else v)/256
        x,z=coord('x'),coord('z');assert -24<x<24 and -24<z<184
        if 23<=z<=25 or 71<=z<=137:assert abs(x)<7
        minimum=[min(minimum[i],math.hypot(x-a,z)) for i,a in enumerate([-7,7])]
        for i,(cx,cz,half) in enumerate([(-16,0,3),(16,48,4),(0,160,4)]):
            clearance=max(abs(x-cx)-half,abs(z-cz)-half)
            assert clearance>0,('camera crosses cube',tick,i,x,z)
            cube_clearances[i]=min(cube_clearances[i],clearance)
        positions.append([x,z])
    assert r[l['demo_key']]==0 and r[l['demo_subtick']]==0
    assert min(minimum)>1,minimum
    result=dict(status='PASS',poseDecodes=32,frameDecodes=6,UIExact=True,bankRestored=True,
        eventAcceptReject=True,controlledSkeletonClips=True,cullCases=checks,tourTicks=6144,
        minimumCharacterDistanceWU=minimum,minimumCubeClearanceWU=cube_clearances,
        phaseCopies=phases,vertexOverlays=vertex_overlays,
        reusedRuntimeBytes=sum(b-a for a,b in runtime),cubes=3,
        painterDepthCases=depth_checks,uniformCubePlanes=16)
    (root/'reports/routine-validation.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print('ROUTINES PASS',json.dumps(result),flush=True)
    return result


def views(root, build,control,keys):
    program=root/'artifacts/underworld-adventure-pal.prg';poses=read(root/'room/scenes/camera-keyframes.json')['posesQ8']
    bitmap=(root/'assets/ui-bitmap.bin').read_bytes();screen=(root/'assets/ui-screen.bin').read_bytes();color=(root/'assets/ui-color.bin').read_bytes()
    outside=[i for i in range(1000) if not(1<=i//40<16 and 6<=i%40<30)]
    results=[]
    for key in keys:
        dest,l=native.capture(build,program,key,key%8,'pal','actors',poses[key])
        ram=(dest/'after.ram').read_bytes()[2:];cr=(dest/'color.ram').read_bytes()[2:]
        for a in [0x2000,0x6000]:assert all(ram[a+i*8+j]==bitmap[i*8+j] for i in outside for j in range(8)),('bitmap UI',key)
        for a in [l['SCREEN_B_BASE'],0x5c00]:assert all(ram[a+i]==screen[i] for i in outside),('screen UI',key)
        assert all((cr[i]&15)==color[i] for i in outside),('ColorRAM UI',key)
        faults={n:ram[l[n]] for n in ['hp_fault','ps_fault','xyq2_faulted'] if n in l}
        assert not any(faults.values()),(key,faults)
        diffs={}
        if control:
            rb=control/'room/build/adventure-pal';rp=control/'artifacts/underworld-adventure-pal.prg'
            other,lo=native.capture(rb,rp,key,key%8,'pal','control',poses[key])
            ro=(other/'after.ram').read_bytes()[2:];co=(other/'color.ram').read_bytes()[2:]
            for name,a,n in [('bitmapA',0x6000,8000),('bitmapB',0x2000,8000),('screenA',0x5c00,1000),('screenB',l['SCREEN_B_BASE'],1000)]:diffs[name]=sum(x!=y for x,y in zip(ram[a:a+n],ro[a:a+n]))
            diffs['color']=sum((x&15)!=(y&15) for x,y in zip(cr,co));assert not any(diffs.values()),(key,diffs)
        results.append(dict(key=key,phase=key%8,faults=faults,controlDifferences=diffs,roomsRejected=ram[l['ad_rooms_rejected']],
            skeletonVerticesVisible=sum(ram[l['wr_valid']+i]!=0 for i in range(38)),billboardFrame=ram[l['bb_frame']]))
        (root/'reports/native-validation.json').write_text(json.dumps(dict(status='PASS',checks=results),indent=2)+'\n',encoding='utf-8')
        print('NATIVE VIEW PASS',key,flush=True)


if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--project',required=True,type=Path);ap.add_argument('--control',type=Path)
    ap.add_argument('--keys',default='0,4,8,12,18,22,36,52,68,84');ap.add_argument('--routines-only',action='store_true')
    args=ap.parse_args();root=args.project.resolve();native.ROOT=root;build=root/'room/build/adventure-pal'
    routines(root,build)
    if not args.routines_only:views(root,build,args.control.resolve() if args.control else None,[int(k) for k in args.keys.split(',')])
