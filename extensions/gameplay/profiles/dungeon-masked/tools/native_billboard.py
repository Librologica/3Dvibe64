"""Native screenshots/FPS on unmodified packaged PRGs; monitor-only capture."""
import argparse,hashlib,json,math,os,re,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
VICE=Path(os.environ.get('VICE_TURBO6510',r'C:\Users\rapso\Documents\ChatGPT\VICE Fork\vice-turbo6510\dist\Turbo6510-x64sc\bin\x64sc_u.exe'))
CLOCK=985248;REFRESH=312*63
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest().upper()
def labels(p):return {m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',p.read_text(),re.M)}
def run(prg,stem,cmds):
    stem.parent.mkdir(parents=True,exist_ok=True);mon=stem.with_suffix('.mon');mon.write_text('\n'.join(cmds)+'\n')
    command=[str(VICE),'-default','+confirmonexit','-console','-warp','+sound','-pal','-turbo6510','64',
             '-autostartprgmode','1','-VICIIfilter','0','-VICIIextpal','-VICIIpalette',str(ROOT/'assets/colodore.vpl'),
             '-initbreak','ready','-moncommands',str(mon),'-logfile',str(stem)+'.vice.log',str(prg)]
    digest=sha(prg);si=subprocess.STARTUPINFO();si.dwFlags|=subprocess.STARTF_USESHOWWINDOW;si.wShowWindow=0
    started=time.monotonic();p=subprocess.run(command,capture_output=True,startupinfo=si,timeout=900)
    stem.with_suffix('.stdout').write_bytes(p.stdout+p.stderr);assert p.returncode==0,(p.returncode,stem)
    assert digest==sha(prg)
    return dict(prg=str(prg),prgSHA256=digest,emulator=str(VICE),emulatorSHA256=sha(VICE),command=command,
        target='VICE Turbo6510 PAL multiplier64',music=False,filter=0,palette='colodore.vpl',
        viewport='160x100 logical,320x200 physical at0,0; no interface',
        textureQuality='fast blocks8/even rows50' if 'fast' in prg.name else 'precise each pixel/all100 rows',textureLOD=[14,22],
        framePresentation='safe',PRGUnmodified=True,hostSecondsDiagnosticOnly=time.monotonic()-started)
def paths(build):
    directory=ROOT/'room/build'/build
    quality='precise' if 'precise' in build else 'fast'
    prg=ROOT/'artifacts'/f'dungeon-billboard-{quality}-LOD-pal-{build}.prg'
    return directory,prg,labels(directory/'3Dvibe64.labels')
def capture(build,key,pose,enabled=None,camera=None,tag=None,open_wall=False):
    b,prg,l=paths(build);route=json.loads((ROOT/'room/scenes/camera-keyframes.json').read_text())['posesQ8']
    cp=route[key]
    if camera is not None:
        cp=[round(v*256) for v in camera[:3]]+[round(v*65536/360)&65535 for v in camera[3:]]
    suffix=tag or f'k{key:03d}-p{pose:02d}'+('' if enabled is None else f'-visible{enabled}')
    assert re.fullmatch('[a-zA-Z0-9-]+',suffix)
    stem=ROOT/'reports/views'/f'{build}-{suffix}'
    cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x',
          f'> ${l["advance_sim_tick"]:04x} 60',f'> ${l["bb_frame_ready"]:04x} ea ea ea',f'> ${l["bb_frame"]:04x} {pose:02x}',f'> ${l["bb_loaded"]:04x} ff']
    if enabled is not None:cmds += [f'> ${l["bb_enabled"]:04x} {int(enabled):02x}']
    if open_wall:
        # Native correctness control only: collapse room1's back-wall triangles.
        # The packed PRG, measured camera route and benchmark are untouched.
        source=(b/'3Dvibe64.prg').read_bytes();origin=int.from_bytes(source[:2],'little')
        for fi in range(41,45):
            v=source[2+l['face0']+fi-origin]
            for name in ('face1','face2','face3'):
                cmds.append(f'> ${l[name]+fi:04x} {v:02x}')
    for axis,value in zip('xyz',cp[:3]):
        for suffix,v in [('lo',value&255),('hi',value>>8&255),('ext',255 if value<0 else 0)]:
            cmds += [f'> ${l["explorer_cam_"+axis+"_"+suffix]:04x} {v:02x}']
    for axis,value in zip(('yaw','pitch'),cp[3:]):
        cmds += [f'> ${l["explorer_cam_"+axis]:04x} {value>>8:02x}',f'> ${l["qc_demo_"+axis+"_lo"]:04x} {value&255:02x}']
    cmds += ['ignore 1 2','x','disable 1','break exec .fps_frame_done','x','disable 2',
             'bank ram',f'save "{stem}.ram" 0 $0000 $ffff','bank cpu',
             'break exec .raster_irq','x',f'screenshot "{stem}.png" 2','quit']
    info=run(prg,stem,cmds);assert stem.with_suffix('.png').exists()
    ram=stem.with_suffix('.ram').read_bytes()[2:]
    faults={name:ram[l[name]] for name in ('hp_fault','ps_fault','xyq2_faulted') if name in l}
    assert not any(faults.values()),faults
    info.update(key=key,pose=pose,faults=faults,enabled=ram[l['bb_enabled']],overlayAddress=l['bb_code_begin'],
        overlayBytes=l['bb_code_end']-l['bb_code_begin'],UIStorageBytes=0,
        poseTablesBytes=l['bb_frames_end']-l['bb_frames'])
    if info['enabled']:
        pixels=json.loads((ROOT/'assets/billboard-frames.json').read_text())['frames'][pose]
        assert ram[l['bb_pixels']:l['bb_pixels']+512]==bytes(pixels),'Frame decode mismatch'
        info['decodedFrameMatches']=True
        info['projectedRect']={n:int.from_bytes(ram[l['bb_'+n]:l['bb_'+n]+2],'little',signed=True) for n in ('left','right','top','bottom')}
        info['alert']=ram[l['bb_alert']]
    info['cameraQ8']=cp
    info['diagnosticOpenWall']=open_wall
    stem.with_suffix('.json').write_text(json.dumps(info,indent=2));print(json.dumps({k:info[k] for k in ('prgSHA256','key','pose','faults','enabled','overlayBytes')},indent=2))
def benchmark(build,refreshes=7680):
    b,prg,l=paths(build);stem=ROOT/'reports/fps'/build;warm=101
    cmds=[f'logname "{stem}.monitor.log"','log on',f'load_labels "{b/"3Dvibe64.labels"}"',
        'break exec .render_frame_begin','x','disable 1','break exec .raster_irq',f'ignore 2 {warm-1:x}','x',
        'bank ram',f'save "{stem}.start.ram" 0 $0000 $ffff','bank cpu','disable 2','stopwatch reset',
        'trace exec .fps_frame_done','trace exec .raster_irq','break exec .raster_irq',f'ignore 5 {refreshes-1:x}',
        'x','stopwatch','bank ram',f'save "{stem}.end.ram" 0 $0000 $ffff','bank cpu','quit']
    info=run(prg,stem,cmds)
    text=Path(str(stem)+'.monitor.log').read_text(errors='replace').rsplit('Stopwatch reset to 0.',1)[1]
    events=[]
    for m in re.finditer(r'#(3|4) \(Trace\s+exec [0-9a-f]+\)[^\n]*\n([^\n]+)',text,re.I):
        events.append((int(m[1]),int(re.search(r'(\d+)\s*$',m[2])[1])))
    frames=[t for n,t in events if n==3];irqs=[t for n,t in events if n==4]
    total=int(re.findall(r'Stopwatch:\s*(\d+)',text)[-1])
    assert len(irqs)==refreshes and abs(total-refreshes*REFRESH)<100
    assert max(abs((b-a)-REFRESH) for a,b in zip(irqs,irqs[1:]))<100
    first=Path(str(stem)+'.start.ram').read_bytes()[2:];last=Path(str(stem)+'.end.ram').read_bytes()[2:]
    addr=l['demo_frames'];delta=(int.from_bytes(last[addr:addr+2],'little')-int.from_bytes(first[addr:addr+2],'little'))&65535
    assert delta==len(frames)
    faults={n:last[l[n]] for n in ('hp_fault','ps_fault','xyq2_faulted') if n in l};assert not any(faults.values()),faults
    intervals=sorted((b-a)*1000/CLOCK for a,b in zip(frames,frames[1:]));seconds=total/CLOCK;assert seconds>=20
    windows=[]
    for i in range(8):
        lo=total*i/8;hi=total*(i+1)/8;n=sum(lo<=t<hi for t in frames)
        windows.append(dict(startSeconds=lo/CLOCK,endSeconds=hi/CLOCK,completeViews=n,FPS=n*CLOCK/(hi-lo)))
    info.update(warmupRefreshes=warm,warmupEmulatedSeconds=warm*REFRESH/CLOCK,
        measureRefreshes=refreshes,measureBaseCycles=total,baseClockHz=CLOCK,
        emulatedSeconds=seconds,completeViews=delta,averageFPS=delta/seconds,
        p95IntervalMs=intervals[math.ceil(len(intervals)*.95)-1],worstIntervalMs=max(intervals),
        frameTimesBaseCycles=frames,refreshTimesBaseCycles=irqs,windows=windows,faults=faults,
        startKey=first[l['demo_key']],endKey=last[l['demo_key']],
        route='24-key360degree billboard orbit then all original96 tour keys;7680 logical ticks',
        stationaryCameraSegments=[],PRGInstrumentationAdded=False,
        intervalDefinition='successive complete-view commits, excluding first/last partial intervals',
        countDefinition='new complete buffer commits only; native counter cross-check; no repeated refresh')
    stem.with_suffix('.json').write_text(json.dumps(info,indent=2))
    print(json.dumps({k:v for k,v in info.items() if k not in ('command','frameTimesBaseCycles','refreshTimesBaseCycles')},indent=2))
def movie(build):
    from PIL import Image
    b,prg,l=paths(build);root=ROOT/'reports/movie';root.mkdir(parents=True,exist_ok=True);stem=root/'native'
    cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .fps_frame_done','disable 1',
          'break exec .raster_irq','disable 2']
    for i in range(64):
        cmds += ['enable 1','ignore 1 2','x','disable 1','enable 2','x','disable 2',
                 f'screenshot "{root/f"f{i:03d}.png"}" 2','bank ram',
                 f'save "{root/f"f{i:03d}.ram"}" 0 $0000 $ffff','bank cpu']
    cmds+=['quit'];info=run(prg,stem,cmds)
    frames=[];ticks=[];keys=[];pose_ids=[]
    for i in range(64):
        ram=(root/f'f{i:03d}.ram').read_bytes()[2:]
        for name in ('hp_fault','ps_fault','xyq2_faulted'):assert ram[l[name]]==0,(i,name)
        ticks.append(int.from_bytes(ram[l['demo_refreshes']:l['demo_refreshes']+2],'little'))
        keys.append(ram[l['demo_key']]);pose_ids.append(ram[l['bb_frame']])
        frames.append(Image.open(root/f'f{i:03d}.png').convert('RGB').resize((768,544),Image.Resampling.NEAREST))
    assert keys[0]<3 and max(keys)>=24,(keys[0],max(keys))
    durations=[round((b-a)*REFRESH/CLOCK*1000) for a,b in zip(ticks,ticks[1:])]
    durations.append(durations[-1]);assert all(d>0 for d in durations)
    gif=ROOT/'artifacts/dungeon-billboard-fast-native.gif'
    frames[0].save(gif,save_all=True,append_images=frames[1:],duration=durations,loop=0,optimize=True,disposal=2)
    info.update(preview=str(gif),captures=64,keys=keys,poseIds=pose_ids,nativeRefreshCounts=ticks,
        durationsMs=durations,completeOrbitObserved=True,source='native VICE screenshots,2x nearest-neighbor display only',
        GIFTimingIsNotAnFPSBenchmark=True)
    stem.with_suffix('.json').write_text(json.dumps(info,indent=2));print(json.dumps(dict(gif=str(gif),seconds=sum(durations)/1000,lastKey=keys[-1]),indent=2))
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--build',default='billboard-final');p.add_argument('--capture',action='store_true')
    p.add_argument('--key',type=int,default=0);p.add_argument('--pose',type=int,default=0)
    p.add_argument('--enabled',type=int,choices=(0,1));p.add_argument('--camera',type=float,nargs=5);p.add_argument('--tag')
    p.add_argument('--benchmark',action='store_true');p.add_argument('--movie',action='store_true');p.add_argument('--refreshes',type=int,default=7680)
    a=p.parse_args()
    if a.capture:capture(a.build,a.key,a.pose,a.enabled,a.camera,a.tag)
    if a.benchmark:benchmark(a.build,a.refreshes)
    if a.movie:movie(a.build)

