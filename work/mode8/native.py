"""Stock x64sc complete-frame qualification; no FPS from host elapsed time."""
import argparse,sys,re,importlib.util
from pathlib import Path
from .common import ROOT,load,save,sha,stats
from .reference import adapter
from .navigation import simulate
from .build import labels

def run(scene,build,out,standard='pal',reuse=False,short=False,interactive=False):
    data=load(scene);c,oracle,meta=adapter(data);multi=c['backend']=='multi';b=Path(build);out=Path(out);lab=labels(b)
    if out.resolve().is_relative_to(ROOT):raise ValueError('Native output must be outside SDK')
    if load(b/'scene.json')!=data:raise ValueError('BUILD_SCENE_MISMATCH: build and scene must match')
    expected_run='interactive' if interactive else 'auto'
    if load(b/'build.json')['run']!=expected_run:raise ValueError('BUILD_RUN_MISMATCH: interactive flag must match build')
    planned,states,blocked=simulate(data['scene'],data['navigation'],backend=c['backend'])
    if not multi:planned=[p[:3] for p in planned]
    assert not blocked
    lap=next(i for i,st in enumerate(states) if st['visits']>=len(meta['nav']['nodes']))
    from . import vice as v
    hz=985248 if standard=='pal' else 1022727;q=chr(92)+'"';extra=[]
    # A full frame's pose is read from RAM by monitor, not instrumented code.
    extra.append(('presentation_done','m $0026 $002f'))
    frames=list(range(1,9));pages=[] if short or interactive else list(range(1,(lap+300)//256+1))
    for n in frames:extra.append((f'presentation_done if (@ram:$0012 == ${n:02x}) && (@ram:$0013 == $00)',f'dump {q}{out.as_posix()}/frame-{n:04d}.vsf{q}'))
    for page in pages:extra.append((f'presentation_done if (@ram:$0015 == ${page:02x})',f'dump {q}{out.as_posix()}/phase-{page:02d}.vsf{q}'))
    if not reuse:v.capture(b,out,standard,int(hz*(30 if short or interactive else (lap+800)/50+6)),points=['render_frame_begin','render_frame_end','presentation_done'],extra=extra,capture_once=True)
    word=lambda m,a:m[a]+256*m[a+1]
    pose=lambda m:tuple(word(m,a) for a in (0x26,0x28,0x2a))+((m[0x2d],m[0x2f]) if multi else ())
    views=[]
    for file in [out/f'frame-{n:04d}.vsf' for n in frames]+[out/f'phase-{p:02d}.vsf' for p in pages]:
        m=v.ram(file);po=pose(m);bmp=oracle(po)[0];base=0x63c0 if not m[7] else 0xe3c0
        assert bytes(m[base:base+7040])==bmp,('bitmap',file.name,po)
        n=word(m,0x12);t=word(m,0x14)
        cam=tuple(word(m,a) for a in (0x20,0x22,0x24))+((m[0x2c],m[0x2e]) if multi else ())
        if interactive:assert cam==po==tuple(data['scene']['initial'] if multi else data['scene']['initial'][:3])
        else:
            assert cam==planned[t],('camera',t,cam,planned[t])
            assert po in planned[max(0,t-250):t+1],('latched pose',t,po)
        assert m[7]==n%2 and m[6]==m[7]^1 and not m[8] and not m[0x11]
        if multi:assert not m[0xf2]
        font=(b/'font.bin').read_bytes();assert m[0x5800:0x6000]==font and m[0xd800:0xe000]==font
        program=(b/'3Dvibe64.prg').read_bytes();load_address=program[0]+256*program[1]
        ui_offset=lab['ui_text']-load_address+2
        ui=bytearray(program[ui_offset:ui_offset+120])
        ui[45]=0x30|(m[0x10]//10);ui[46]=0x30|(m[0x10]%10)
        assert m[0x4000:0x4078]==ui and m[0xcc00:0xcc78]==ui,('UI',file.name)
        for a in (0x4000,0xcc00):assert m[a+120:a+1000]==bytes([0x98])*880 and m[a+1000:a+1024]==bytes([0xa5])*24
        views.append(dict(frame=n,tick=t,pose=po,bitmapDifferences=0))
    color=(out/'color.bin').read_bytes();vic=(out/'vic.bin').read_bytes();cia=(out/'cia2.bin').read_bytes()
    assert bytes(x&15 for x in color)==bytes([1])*120+bytes([7])*880
    assert vic[0x11]&0x7f==0x1b and vic[0x16]&0x3f==0x18 and vic[0x18]&0xfe==6 and cia[0]&3==2
    ev=v.traces(out/'trace.log');pub=sorted(set(t for pc,t in ev if pc==lab['presentation_done']))
    begin=pub[0]+2*hz
    def window(seconds):
        end=begin+seconds*hz;assert pub[-1]>end
        seq=[bb-aa for aa,bb in zip(pub,pub[1:]) if begin<=bb<end];ms=[x*1000/hz for x in seq]
        return dict(seconds=seconds,completeImages=len(seq),fps=len(seq)/seconds,clocks=stats(seq),milliseconds=stats(ms),
                    pauses={str(k):sum(x>k for x in ms) for k in (300,500,750)},intervals=seq)
    # Preserve exact memory text plus frame clocks; parsed rows are sanity checked.
    shown=[];clock=None;readbytes={}
    for line in (out/'trace.log').read_text(errors='replace').splitlines():
        mt=re.search(r'\.C:([0-9a-fA-F]{4}).*\s(\d+)\s*$',line)
        if mt and int(mt[1],16)==lab['presentation_done']:clock=int(mt[2])
        mm=re.search(r'^>C:(0026|002a|002e) +((?:[0-9a-fA-F]{2} +){1,4})',line)
        if mm:
            addr=int(mm[1],16)
            if addr==0x26:readbytes={}
            for i,vv in enumerate(bytes.fromhex(mm[2])):readbytes[addr+i]=vv
            if addr==0x2e:
                rr=bytes(readbytes[a] for a in range(0x26,0x30));po=tuple(word(rr,a) for a in (0,2,4))+((rr[7],rr[9]) if multi else ())
                shown.append(dict(clock=clock,pose=po))
    assert len(shown)==len(pub),('pose trace',len(shown),len(pub))
    physical=None
    if interactive:
        from PIL import Image
        pixels=oracle(data['scene']['initial'] if multi else data['scene']['initial'][:3])[1];im=Image.open(out/'screen.png').convert('RGB');top=59 if standard=='pal' else 47
        colors=[(0,0,0),(119,83,0),(183,99,30),(255,255,70)] if standard=='pal' else [(0,0,0),(143,68,0),(195,96,69),(255,248,148)]
        physical=sum(im.getpixel((32+x,top+y))!=colors[pixels[(y-16)*128+(x-32)//2] if 16<=y<160 and 32<=x<288 else 0] for y in range(176) for x in range(320))
        assert physical==0,('VIC physical pixels',physical)
    result=dict(sceneSHA256=sha(scene),prgSHA256=sha(b/'3Dvibe64.prg'),standard=standard,stock=True,interactive=interactive,physicalPixelDifferences=physical,
                warmupSeconds=2,short=window(20),tour=None if short or interactive else window(lap/50),lapTicks=lap,
                views=views,bitmapDifferentBytes=0,VICRegisters=True,colorRAM=True,font=True,UITextAndFPS=True,doubleBuffer=True,
                shownPoseCount=len(shown),presentedClocks=pub,shownPoses=shown,
                noHardwareTest=True,measurement='Emulated clocks, UI on; monitor reads add no 6510 instructions. Warp only accelerates host execution.')
    save(out/'qualification.json',result)
    print('NATIVE',standard,scene,'FPS20',result['short']['fps'],'tour',result['tour']['fps'] if result['tour'] else None,'poses',len(shown),flush=True)
    return result

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--scene',required=True);p.add_argument('--build',required=True);p.add_argument('--out',required=True);p.add_argument('--standard',default='pal',choices=['pal','ntsc']);p.add_argument('--reuse',action='store_true');p.add_argument('--short',action='store_true');p.add_argument('--interactive',action='store_true');a=p.parse_args();run(a.scene,a.build,a.out,a.standard,a.reuse,a.short,a.interactive)
