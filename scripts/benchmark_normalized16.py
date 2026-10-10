"""Rebuild public scenes, count native complete views, or replay an identical pose.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. VICE/Python dependencies are external.
"""
import argparse,hashlib,json,math,os,re,shutil,statistics,subprocess,time
from pathlib import Path

SDK=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest().upper()
def labels(p):return {m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',p.read_text(),re.M)}

def build(root,mode,precision,standard):
    out=root/f'build/m{mode}-{precision}-{standard}'
    scene=SDK/f'examples/q8/two-objects-mode{mode}.json'
    if not out.exists():
        cmd=[shutil.which('pwsh') or 'pwsh','-NoProfile','-File',str(SDK/'work/build-3Dvibe64.ps1'),'-Precision',precision,'-GraphicsMode',str(mode),'-SceneFile',str(scene),'-Q8Camera','interactive','-VideoStandard',standard,'-OutputDirectory',str(out)]
        p=subprocess.run(cmd,capture_output=True,text=True)
        (root/'reports').mkdir(exist_ok=True);(root/f'reports/build-m{mode}-{precision}-{standard}.log').write_text(p.stdout+p.stderr)
        assert p.returncode==0,(cmd,p.stdout+p.stderr)
    assert json.loads((out/'build.json').read_text())['prgSHA256']==sha(out/'3Dvibe64.prg')
    return out

def execute(vice,out,raw,standard,mon):
    (raw/'commands.mon').write_text('\n'.join(mon)+'\n')
    cmd=[str(vice),'-default','+confirmonexit','-console','-warp','+sound','-'+standard,'-turbo6510','64','-autostartprgmode','1','-VICIIfilter','0','-initbreak','ready','-moncommands',str(raw/'commands.mon'),str(out/'3Dvibe64.prg')]
    (raw/'command.json').write_text(json.dumps(cmd,indent=2))
    extra={}
    if os.name=='nt':
        si=subprocess.STARTUPINFO();si.dwFlags|=subprocess.STARTF_USESHOWWINDOW;si.wShowWindow=0;extra['startupinfo']=si
    start=time.monotonic();p=subprocess.run(cmd,capture_output=True,text=True,timeout=600,**extra)
    (raw/'console.log').write_text(p.stdout+p.stderr);assert p.returncode==0
    return time.monotonic()-start

def benchmark(root,vice,mode,precision,standard,trial):
    out=build(root,mode,precision,standard);lab=labels(out/'3Dvibe64.labels')
    raw=root/f'raw/m{mode}-{precision}-{standard}-r{trial}';raw.mkdir(parents=True,exist_ok=False)
    refresh,clock=(19656,985248) if standard=='pal' else (17095,1022727)
    count=math.ceil(20*clock/refresh);warm=math.ceil(2*clock/refresh)
    mon=[f'logname "{(raw/"monitor.log").as_posix()}"','log on',f'load_labels "{(out/"3Dvibe64.labels").as_posix()}"','break exec .render_frame_begin','x',
         'bank ram',f'save "{(raw/"initial.ram").as_posix()}" 0 $0000 $ffff','bank cpu','disable 1',
         'break exec .raster_irq',f'ignore 2 {warm-1:x}','x','disable 2','stopwatch reset','trace exec .fps_frame_done','trace exec .raster_irq',
         'break exec .raster_irq',f'ignore 5 {count-1:x}','x','stopwatch','bank ram',f'save "{(raw/"final.ram").as_posix()}" 0 $0000 $ffff','bank cpu','quit']
    host=execute(vice,out,raw,standard,mon)
    log=(raw/'monitor.log').read_text(errors='replace').rsplit('Stopwatch reset to 0.',1)[1]
    total=int(re.findall(r'Stopwatch:\s*(\d+)',log)[-1]);events=[]
    for m in re.finditer(r'#(3|4) \(Trace\s+exec [0-9a-f]+\)[^\n]*\n([^\n]+)',log,re.I):events.append((int(m[1]),int(re.search(r'(\d+)\s*$',m[2])[1])))
    frames=[v for k,v in events if k==3];irqs=[v for k,v in events if k==4]
    assert len(irqs)==count and abs(total-count*refresh)<refresh/2,(len(irqs),count,total)
    gaps=[(b-a)*1000/clock for a,b in zip(frames,frames[1:])];s=sorted(gaps)
    ram=(raw/'final.ram').read_bytes()[2:];faults={n:ram[lab[n]] for n in ('hp_fault','xyq2_faulted') if n in lab};assert not any(faults.values()),faults
    result=dict(mode=mode,precision=precision,standard=standard,target='VICE Turbo6510 multiplier64',music=False,overlay=False,
        warmupRefreshes=warm,warmupSeconds=warm*refresh/clock,emulatedSeconds=total/clock,newCompleteViews=len(frames),FPS=len(frames)*clock/total,
        medianMs=statistics.median(gaps),p95Ms=s[math.ceil(.95*len(s))-1],worstMs=max(gaps),PRGInstrumentationAdded=False,prgSHA256=sha(out/'3Dvibe64.prg'),
        faults=faults,framesBaseCycles=frames,refreshBaseCycles=irqs,hostSecondsDiagnosticOnly=host,
        sceneSHA256=sha(SDK/f'examples/q8/two-objects-mode{mode}.json'),camera='interactive, no injected input; objects rotate on unchanged logical ticks',
        countDefinition='fps_frame_done after show_buffer; only new complete renders, not duplicated refreshes')
    (raw/'benchmark.json').write_text(json.dumps(result,indent=2));print({k:v for k,v in result.items() if k not in ('framesBaseCycles','refreshBaseCycles')},flush=True)

def capture(root,vice,mode,precision,standard):
    from py65.devices.mpu6502 import MPU
    out=build(root,mode,precision,standard);lab=labels(out/'3Dvibe64.labels');raw=root/f'raw/pose-m{mode}-{precision}-{standard}';raw.mkdir(parents=True,exist_ok=False)
    mon=[f'load_labels "{(out/"3Dvibe64.labels").as_posix()}"','break exec .render_frame_begin','x',
         f'> ${lab["sim_vblank_count"]:04x} 00',f'> ${lab["explorer_cam_yaw"]:04x} 08',f'> ${lab["explorer_cam_pitch"]:04x} 04',
         'bank cpu',f'save "{(raw/"before-color.ram").as_posix()}" 0 $d800 $dbff',
         'bank ram',f'save "{(raw/"before.ram").as_posix()}" 0 $0000 $ffff','bank cpu','disable 1','break exec .render_frame_end','x',
         f'save "{(raw/"after-color.ram").as_posix()}" 0 $d800 $dbff',
         'bank ram',f'save "{(raw/"after.ram").as_posix()}" 0 $0000 $ffff','bank cpu','quit']
    execute(vice,out,raw,standard,mon)
    before=list((raw/'before.ram').read_bytes()[2:]);native=list((raw/'after.ram').read_bytes()[2:])
    # Color RAM is a separate 4-bit chip, not DRAM underneath I/O. Keep the
    # full DRAM dump for code under ROM and capture the actual color chip too.
    before[0xd800:0xdc00]=list((raw/'before-color.ram').read_bytes()[2:])
    native[0xd800:0xdc00]=list((raw/'after-color.ram').read_bytes()[2:])
    cpu=MPU(memory=before);cpu.pc=lab['render_frame_begin'];cpu.sp=0xfd
    for instructions in range(10000000):
        if cpu.pc==lab['render_frame_end']:break
        cpu.step()
    else:raise AssertionError(('replay timeout',mode,precision,cpu.pc))
    regions=[('bitmapA',lab.get('BITMAP_A_BASE',0x6000),8000,255),('bitmapB',lab['BITMAP_B_BASE'],8000,255),
        ('screenA',lab.get('SCREEN_A_BASE',0x5c00),1000,255),('screenB',lab['SCREEN_B_BASE'],1000,255),('color',0xd800,1000,15)]
    diff={n:sum((cpu.memory[i]&mask)!=(native[i]&mask) for i in range(a,a+size)) for n,a,size,mask in regions}
    vertex={n:sum(cpu.memory[lab[n]+i]!=native[lab[n]+i] for i in range(lab['VERT_COUNT'])) for n in ('sx','sy','sz','szhi','projdone')}
    faults={n:native[lab[n]] for n in ('hp_fault','xyq2_faulted') if n in lab}
    result=dict(mode=mode,precision=precision,standard=standard,differences=diff,vertexDifferences=vertex,faults=faults,instructionCycles=cpu.processorCycles,
        instructions=instructions,prgSHA256=sha(out/'3Dvibe64.prg'),nativeFPS='not inferred from this CPU replay',cameraYaw=8,cameraPitch=4)
    (raw/'verification.json').write_text(json.dumps(result,indent=2));(raw/'cpu.ram').write_bytes(bytes(cpu.memory));print(result,flush=True)
    assert not any(diff.values()) and not any(vertex.values()) and not any(faults.values()),result

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);p.add_argument('--modes',default='1,2,3,4,5,6,7')
    p.add_argument('--precision',default='q8,normalized16');p.add_argument('--standard',choices=['pal','ntsc'],default='pal');p.add_argument('--run',type=int,default=1)
    p.add_argument('--capture',action='store_true');a=p.parse_args();root=a.out.resolve();assert root!=SDK and SDK not in root.parents
    vice=Path(os.environ['VICE_TURBO6510']).resolve();assert vice.is_file();root.mkdir(parents=True,exist_ok=True)
    for mode in map(int,a.modes.split(',')):
        assert mode in range(1,8)
        for precision in a.precision.split(','):
            assert precision in ('q8','normalized16')
            capture(root,vice,mode,precision,a.standard) if a.capture else benchmark(root,vice,mode,precision,a.standard,a.run)
