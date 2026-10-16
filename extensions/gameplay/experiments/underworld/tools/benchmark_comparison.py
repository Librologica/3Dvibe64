"""Native matched FPS on delivered load-safe PRGs. No instruction-replay FPS."""
import concurrent.futures,hashlib,json,math,re,subprocess,time
from pathlib import Path
from native_helpers import ROOT,VICE,labels,sha
def save(p,data):p.write_text(json.dumps(data,indent=2)+'\n')
def bench(version,standard,number,analyze_existing=False):
    build=ROOT/'reference/previous' if version=='previous' else ROOT/'room/build/adventure-pal'
    prg=(ROOT/'reference/previous/delivered.prg') if version=='previous' else (ROOT/'artifacts/underworld-adventure-pal.prg')
    lab=labels(build/'3Dvibe64.labels');out=ROOT/f'raw/fps/{version}-{standard}-run{number}';out.mkdir(parents=True,exist_ok=True)
    if (out/'benchmark.json').exists():return json.loads((out/'benchmark.json').read_text())
    refresh,clock=(19656,985248) if standard=='pal' else (17095,1022727)
    warm,count=(101,6400) if standard=='pal' else (120,7680)
    mon=[f'logname "{(out/"monitor.log").as_posix()}"','log on',
         f'load_labels "{(build/"3Dvibe64.labels").as_posix()}"',
         'break exec .render_frame_begin','x','bank ram',
         f'save "{(out/"initial.ram").as_posix()}" 0 $0000 $ffff','bank cpu','disable 1',
         'break exec .raster_irq',f'ignore 2 {warm-1:x}','x','disable 2','bank ram',
         f'save "{(out/"start.ram").as_posix()}" 0 $0000 $ffff','bank cpu','stopwatch reset',
         'trace exec .fps_frame_done','trace exec .raster_irq','break exec .raster_irq',
         f'ignore 5 {count-1:x}','trace exec .render_frame_begin','trace exec .render_frame_end','x','stopwatch','bank ram',
         f'save "{(out/"end.ram").as_posix()}" 0 $0000 $ffff','bank cpu','quit']
    script=out/'commands.mon';script.write_text('\n'.join(mon)+'\n')
    cmd=[str(VICE),'-default','+confirmonexit','-console','-warp','+sound','-'+standard,
         '-turbo6510','64','-autostartprgmode','1','-VICIIfilter','0','-VICIIextpal',
         '-VICIIpalette',str(ROOT/'assets/colodore.vpl'),'-initbreak','ready','-moncommands',str(script),str(prg)]
    digest=sha(prg);host=time.monotonic()
    if analyze_existing:
        assert json.loads((out/'command.json').read_text())==cmd
        assert all((out/n).is_file() for n in ['initial.ram','start.ram','end.ram','monitor.log','console.log'])
        packaging=json.loads(prg.with_suffix('.loader.json').read_text())
        assert packaging['packagedSHA256']==digest
    else:
        save(out/'command.json',cmd)
        save(out/'capture-identity.json',dict(prgSHA256=digest,emulatorSHA256=sha(VICE)))
        si=subprocess.STARTUPINFO();si.dwFlags|=subprocess.STARTF_USESHOWWINDOW;si.wShowWindow=0
        p=subprocess.run(cmd,capture_output=True,startupinfo=si,timeout=900)
        (out/'console.log').write_bytes(p.stdout+p.stderr);assert p.returncode==0,(p.returncode,out)
    text=(out/'monitor.log').read_text(errors='replace').rsplit('Stopwatch reset to 0.',1)[1]
    total=int(re.findall(r'Stopwatch:\s*(\d+)',text)[-1]);events=[]
    for m in re.finditer(r'#(3|4|6|7) \(Trace\s+exec [0-9a-f]+\)[^\n]*\n([^\n]+)',text,re.I):
        events.append((int(m[1]),int(re.search(r'(\d+)\s*$',m[2])[1])))
    frames=[t for n,t in events if n==3];irqs=[t for n,t in events if n==4]
    def stats(xs):
        xs=sorted(xs)
        return dict(n=len(xs),meanMs=sum(xs)/len(xs),p95Ms=xs[math.ceil(.95*len(xs))-1],maxMs=max(xs))
    active=None;finished=None;renders=[];waits=[];other=[];lastframe=None
    for n,t in events:
        if n==6:
            active=t
            if lastframe is not None:other.append((t-lastframe)*1000/clock)
        elif n==7 and active is not None:
            renders.append((t-active)*1000/clock);finished=t;active=None
        elif n==3:
            if finished is not None:waits.append((t-finished)*1000/clock);finished=None
            lastframe=t
    timing=dict(render=stats(renders),presentationWait=stats(waits),otherBetweenViews=stats(other))
    assert len(irqs)==count and abs(total-count*refresh)<refresh//2
    # IRQ may be deferred while RAM under I/O is read. Validate successive
    # VIC refresh slots rather than an unrelated100-cycle latency ceiling.
    slots=[(t+refresh//2)//refresh for t in irqs]
    assert all(b==a+1 for a,b in zip(slots,slots[1:]))
    irqDeviation=max(abs((b-a)-refresh) for a,b in zip(irqs,irqs[1:]))
    first=(out/'start.ram').read_bytes()[2:];last=(out/'end.ram').read_bytes()[2:]
    address=lab['demo_frames']
    frameDelta=(int.from_bytes(last[address:address+2],'little')-int.from_bytes(first[address:address+2],'little'))&65535
    assert frameDelta==len(frames),(frameDelta,len(frames))
    address=lab['demo_refreshes']
    refreshDelta=(int.from_bytes(last[address:address+2],'little')-int.from_bytes(first[address:address+2],'little'))&65535
    assert refreshDelta==count
    faults={n:last[lab[n]] for n in ['hp_fault','ps_fault','xyq2_faulted'] if n in lab}
    assert not any(faults.values()) and sha(prg)==digest
    ms=sorted((b-a)*1000/clock for a,b in zip(frames,frames[1:]))
    route=json.loads((ROOT/'room/scenes/camera-keyframes.json').read_text())
    poses=route['posesQ8'];stationary=[i for i,pose in enumerate(poses) if pose==poses[(i+1)%len(poses)]]
    windows=[]
    for i in range(4):
        lo=total*i/4;hi=total*(i+1)/4;n=sum(lo<=t<hi for t in frames)
        windows.append(dict(startSeconds=lo/clock,endSeconds=hi/clock,newViews=n,FPS=n*clock/(hi-lo)))
    scenePath=ROOT/'reference/previous/scene.json' if version=='previous' else ROOT/'room/scenes/large-room.json'
    scene=json.loads(scenePath.read_text());scene['privateRenderContract'].pop('textureLOD',None)
    geometrySHA=hashlib.sha256(json.dumps(scene,sort_keys=True).encode()).hexdigest().upper()
    result=dict(run_id=f'dungeon-ui-{version}-{standard}-x64-run{number}',emulatorSHA256=sha(VICE),timing=timing,version=version,standard=standard,prg=str(prg),prgSHA256=digest,
        target='VICE Turbo6510 multiplier64',music=False,overlay=False,viewport='96x60 logical / 192x120 physical, origin48,8 inside320x200',
        textureQuality='exact perspective per pixel / all60 sampled rows',textureLOD=dict(fadeNear=14,fadeFar=22) if version=='previous' else dict(fadeNear=14,fadeFar=22),framePresentation='safe',filter=0,palette='colodore.vpl',
        warmupRefreshes=warm,warmupSeconds=warm*refresh/clock,measureRefreshes=count,emulatedSeconds=total/clock,
        newCompleteViews=len(frames),averageFPS=len(frames)*clock/total,p95Ms=ms[math.ceil(.95*len(ms))-1],worstMs=max(ms),
        medianMs=ms[math.ceil(.5*len(ms))-1],frameTimesBaseCycles=frames,refreshTimesBaseCycles=irqs,windows=windows,
        route='Complete96-key/6144-tick actor orbit, inspections and three-room exploration',
        stationaryCameraKeySegments=stationary,startKey=first[lab['demo_key']],endKey=last[lab['demo_key']],
        sceneSHA256=sha(scenePath),sceneGeometrySHA256=geometrySHA,routeSHA256=sha(ROOT/'room/scenes/camera-keyframes.json'),
        countDefinition='fps_frame_done after complete show_buffer; duplicate refreshes excluded; existing 16-bit demo counter independently cross-checks traces',
        nativeCommand=cmd,faults=faults,PRGUnmodified=True,hostSecondsDiagnosticOnly=None if analyze_existing else time.monotonic()-host,
        analysisOfExistingNativeCapture=analyze_existing,consecutiveVICRefreshSlots=True,maxIRQIntervalDeviationBaseCycles=irqDeviation,
        nativeActorState={n:last[lab[n]] for n in ['en_event_count','en_state','bc_state','wr_stage','wr_pose','bb_frame','ad_culling']})
    save(out/'benchmark.json',result);print('NATIVE FPS',version,standard,number,result['averageFPS'],flush=True)
    return result
def main():
    import argparse
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--analyze-existing',action='store_true');args=parser.parse_args()
    results=[]
    for standard,repeats in [('pal',1)]:
        for number in range(1,repeats+1):
            with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
                futures=[pool.submit(bench,v,standard,number,args.analyze_existing) for v in ['previous','dev']]
                a,b=[f.result() for f in futures]
            for key in ['target','standard','music','viewport','textureQuality','warmupRefreshes','measureRefreshes','sceneGeometrySHA256','routeSHA256']:
                assert a[key]==b[key],key
            results.append(dict(standard=standard,run=number,beforeFPS=a['averageFPS'],afterFPS=b['averageFPS'],
                gainPercent=(b['averageFPS']/a['averageFPS']-1)*100,
                beforeP95Ms=a['p95Ms'],afterP95Ms=b['p95Ms'],beforeWorstMs=a['worstMs'],afterWorstMs=b['worstMs'],
                beforeTiming=a['timing'],afterTiming=b['timing'],emulatedSeconds=a['emulatedSeconds'],beforePRG=a['prgSHA256'],afterPRG=b['prgSHA256']))
            save(ROOT/'reports/fps-comparison.json',results)
    print(json.dumps(results,indent=2),flush=True)
if __name__=='__main__':main()
