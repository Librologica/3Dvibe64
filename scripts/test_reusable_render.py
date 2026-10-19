"""Reusable APIs and exact fallback checks; callbacks never measure FPS.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import argparse,json,random,sys,tempfile,subprocess,os,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'work'))
from compact_keyframes import pack,unpack,emit
from legacy_plus_exact import parse,patch
from test_legacy_plus_exact import Machine,labels

def compact_checks():
    rng=random.Random(0x6510)
    tracks=[[0],[-32768],[32767],[i*16-2048 for i in range(256)],
            [-32768,32767]*128,[0]*256]
    for width in range(1,17):
        lo=-32768;hi=lo+(1<<width)-1
        tracks.append([lo,hi]+[rng.randint(lo,hi) for _ in range(254)])
    count=0
    for track in tracks:
        t=pack(track)
        assert [unpack(t,i) for i in range(len(track))]==track
        for bad in (-1,len(track)):
            try:unpack(t,bad)
            except IndexError:pass
            else:raise AssertionError('range guard')
        count+=len(track)
    for bad in ([],[32768],[-32769],[0]*257,[1.5],[True]):
        try:pack(bad)
        except ValueError:pass
        else:raise AssertionError(bad)
    # Native emitted decoder: padding, signed restoration, >256-byte offsets,
    # all alignment phases, full16bit spans, compact constants and invalid X.
    native=0
    assembler=os.environ.get('TASS64_EXE')
    if assembler:
        from py65.devices.mpu6502 import MPU
        with tempfile.TemporaryDirectory(prefix='compact-keys-') as td:
            td=Path(td)
            for i,track in enumerate(tracks):
                code,t=emit(track,'keys')
                (td/'keys.asm').write_text('*=$8000\n'+code,encoding='ascii')
                r=subprocess.run([assembler,'-a','-B','--vice-labels-numeric','--labels='+str(td/'keys.labels'),'-o',str(td/'keys.prg'),str(td/'keys.asm')],capture_output=True)
                assert not r.returncode,r.stdout+r.stderr
                data=(td/'keys.prg').read_bytes();base=int.from_bytes(data[:2],'little');mem=[0]*65536;mem[base:base+len(data)-2]=data[2:];lab=labels(td/'keys.labels');c=MPU(memory=mem)
                for idx in range(256):
                    c.pc=lab['keys_read'];c.x=idx;c.sp=0xfd;c.p=0x20;mem[0x1fe]=255;mem[0x1ff]=2
                    for step in range(20000):
                        if c.pc==0x300:break
                        c.step()
                    else:raise AssertionError('decoder did not return')
                    if idx<len(track):assert c.p&1 and (c.a|(c.y<<8))==track[idx]&65535,(i,idx,track[idx],c.a,c.y)
                    else:assert not c.p&1 and c.a==c.y==0
                    native+=1
    return dict(packedSamples=count,nativeDecoderCalls=native,nativeDecoderSkipped=not bool(assembler))

def edge_checks(ref,opt):
    rng=random.Random(0x8008);count=0
    cases=[(a,b,c,d) for a,c in ((0,159),(159,0),(1,158),(158,1),(0,0),(159,159)) for b,d in ((0,99),(99,0),(0,1),(1,0),(0,0),(99,99))]
    cases +=[tuple(rng.randrange(n) for n in (160,100,160,100)) for _ in range(8000)]
    for coords in cases:
        results=[]
        for m in (ref,opt):
            m.mem[m.lab['leftb']:m.lab['leftb']+100]=[255]*100;m.mem[m.lab['rightb']:m.lab['rightb']+100]=[0]*100
            m.put('wire_trace_active',0) if 'wire_trace_active' in m.lab else None
            for name,value in zip(('ex0','ey0','ex1','ey1'),coords):m.put(name,value)
            m.call('trace_edge_convex')
            results.append((m.mem[m.lab['leftb']:m.lab['leftb']+100],m.mem[m.lab['rightb']:m.lab['rightb']+100]))
        assert results[0]==results[1],('integer edge',coords)
        count+=1
    return count

def connected_points(coords):
    x0,y0,x1,y1=coords
    if y0>y1:x0,y0,x1,y1=x1,y1,x0,y0
    if y0==y1:return [(x,y0) for x in range(min(x0,x1),max(x0,x1)+1)]
    dx=abs(x1-x0);dy=y1-y0;step=1 if x1>=x0 else -1;x=x0;err=0;points=[]
    if dx==dy:return [(x0+step*n,y0+n) for n in range(dy+1)]
    for y in range(y0,y1+1):
        points.append((x,y))
        if y==y1:break
        err+=dx
        while err>=dy:
            err-=dy;x+=step;points.append((x,y))
    return points

def wire_checks(opt,reference=None):
    rng=random.Random(0xb8);count=0
    pristine=list(opt.mem)
    reference_pristine=list(reference.mem) if reference else None
    ranges=[(0x2000,0x3f40),(0x6000,0x7f40),(0x400,0x800),(0x5c00,0x6000),(0xd800,0xdc00)]
    cases=[(x,y,a,b) for x,y in ((0,0),(159,0),(0,99),(159,99),(80,50)) for a,b in ((0,0),(159,99),(159,0),(0,99),(80,50))]
    cases +=[tuple(rng.randrange(n) for n in (160,100,160,100)) for _ in range(1200)]
    for coords in cases:
        buf=count&1;pattern=(0,85,170,255)[count%4];results=[]
        for scalar in (True,False):
            opt.mem[:]=pristine
            for lo,hi in ranges:opt.mem[lo:hi]=[(i*37+19)&255 for i in range(hi-lo)]
            for name,val in [('drawbuf',buf),('fillbyte',pattern),('material_screen_cur',0x6f if count&2 else 0x21),('material_color_cur',1 if count&2 else 7),('lowres_scanline_enabled',0)]:opt.put(name,val)
            if scalar:
                for x,y in connected_points(coords):
                    opt.put('leftval',x);opt.put('rightval',y);opt.call('er_wire_plot_wire_point')
            else:
                for name,val in zip(('ex0','ey0','ex1','ey1'),coords):opt.put(name,val)
                opt.call('er_wire_line');assert opt.cpu.p&1
            results.append([opt.mem[lo:hi] for lo,hi in ranges])
        assert results[0]==results[1],('wire pixels/materials',coords,buf,pattern)
        if reference:
            reference.mem[:]=reference_pristine
            for lo,hi in ranges:reference.mem[lo:hi]=[(i*37+19)&255 for i in range(hi-lo)]
            for name,val in [('drawbuf',buf),('fillbyte',pattern),('material_screen_cur',0x6f if count&2 else 0x21),('material_color_cur',1 if count&2 else 7),('lowres_scanline_enabled',0)]:reference.put(name,val)
            for name,val in zip(('ex0','ey0','ex1','ey1'),coords):reference.put(name,val)
            reference.call('er_wire_line');assert reference.cpu.p&1
            assert results[1]==[reference.mem[lo:hi] for lo,hi in ranges],('native scalar wire',coords,buf,pattern)
        count+=1
    for coords in [(160,0,0,0),(0,100,0,0),(0,0,255,0),(0,0,0,255)]:
        before=list(opt.mem)
        for name,val in zip(('ex0','ey0','ex1','ey1'),coords):opt.put(name,val)
        opt.call('er_wire_line');assert not opt.cpu.p&1
        assert all(before[lo:hi]==opt.mem[lo:hi] for lo,hi in ranges)
    return count

def stream_checks(opt):
    rng=random.Random(0x514);lab=opt.lab;n=lab['VERT_COUNT'];pristine=list(opt.mem)
    raw=(opt_path/'3Dvibe64.prg').read_bytes();load=int.from_bytes(raw[:2],'little')
    start=lab['explorer_transform_project_vertices'];target=lab['lc_commit_q4'];needle=bytes([0x20,target&255,target>>8])
    # Invoke the real native producer tail; one owned slot makes its normal
    # loop terminate. No duplicated arithmetic reference in the test.
    address=raw.index(needle,2+start-load)+load-2
    lab['reference_producer']=address
    fields=('sx','sxhi','sy','syq2_lo','syq2_hi','sz','szhi','vxrawlo','vxrawhi','vyrawlo','vyrawhi','vzrawlo','vzrawhi','rxbuf','rybuf','projdone','lpn_xlo','lpn_xhi','lpn_ylo','lpn_yhi','lpn_zlo','lpn_zhi','er_outcodes')
    count=0
    for i in range(1500):
        idx=rng.randrange(n);coords=[rng.randrange(-16000,16000),rng.randrange(-12000,12000),rng.choice([-32768,-1,0,127,128,129,2048,32767]) if i<300 else rng.randrange(-1000,16000)]
        results=[]
        for api in (False,True):
            opt.mem[:]=pristine
            if api:
                opt.call('er_stream_begin',x=idx,y=1);assert opt.cpu.p&1
                for axis,val in zip('xyz',coords):opt.put('er_stream_'+axis,val,2)
                opt.call('er_stream_project',a=idx);assert opt.cpu.p&1
            else:
                opt.put('tmpidx',idx);opt.put('active_vend',idx+1)
                for name,val in zip(('explorer_view_x_lo','explorer_view_y_lo','p1lo'),coords):opt.put(name,val,2)
                opt.call('reference_producer')
            results.append([opt.mem[lab[f]+idx] for f in fields if f in lab])
        assert results[0]==results[1],('stream producer',idx,coords,results)
        count+=1
    for first,size in [(0,0),(n,1),(max(0,n-1),2),(255,2)]:
        opt.call('er_stream_begin',x=first,y=size);assert not opt.cpu.p&1 and opt.get('er_stream_active')==0
        opt.call('er_stream_project',a=0);assert not opt.cpu.p&1
    opt.call('er_stream_begin',x=0,y=n);assert opt.cpu.p&1
    for idx in range(n):assert opt.mem[lab['projdone']+idx]==0 and opt.mem[lab['er_outcodes']+idx]==16
    opt.call('er_stream_project',a=n);assert not opt.cpu.p&1
    opt.call('er_stream_end_pass');assert opt.get('er_stream_active')==0
    return count

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--control',type=Path);p.add_argument('--exact',type=Path);p.add_argument('--api',type=Path);p.add_argument('--wire-reference',type=Path);p.add_argument('--out',type=Path);a=p.parse_args()
    result=compact_checks()
    assert 'integer-edges' in parse('all') and 'wire' not in parse('all') and 'stream' not in parse('all')
    assert patch('unchanged','none')==('unchanged',[])
    if a.control or a.exact:
        assert a.control and a.exact;result['nativeIntegerEdges']=edge_checks(Machine(a.control),Machine(a.exact))
    if a.api:
        opt_path=a.api;machine=Machine(a.api)
        result['nativeWireLines']=wire_checks(machine,Machine(a.wire_reference) if a.wire_reference else None)
        result['nativeScalarWireCompared']=bool(a.wire_reference)
        result['nativeStreamVertices']=stream_checks(machine)
    result['FPSMeasured']=False
    if a.out:a.out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))
