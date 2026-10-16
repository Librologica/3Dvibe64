"""Native WORLD-01 storage target and PAL complete-view benchmark."""
import json,math,re,subprocess,time
from pathlib import Path
from native_compare import ROOT,VICE,CLOCK,REFRESH,paths,sha,profile

def run(prg,stem,cmds,media=None):
    media=Path(media) if media else ROOT/'media'
    stem.parent.mkdir(parents=True,exist_ok=True);mon=stem.with_suffix('.mon');mon.write_text('\n'.join(cmds)+'\n')
    command=[str(VICE),'-default','+confirmonexit','-console','-warp','+sound','-pal','-turbo6510','64',
             '+drive8truedrive','-trapdevice8','+busdevice8','-devicebackend8','1','-fs8',str(media),'+fs8hidecbm','+fs8convertp00',
             '-autostartprgmode','1','-VICIIfilter','0','-VICIIextpal','-VICIIpalette',str(ROOT/'assets/colodore.vpl'),
             '-initbreak','ready','-moncommands',str(mon),'-logfile',str(stem)+'.vice.log',str(prg)]
    digest=sha(prg);si=subprocess.STARTUPINFO();si.dwFlags|=subprocess.STARTF_USESHOWWINDOW;si.wShowWindow=0
    started=time.monotonic();p=subprocess.run(command,capture_output=True,startupinfo=si,timeout=900)
    stem.with_suffix('.stdout').write_bytes(p.stdout+p.stderr);assert p.returncode==0,(p.returncode,stem)
    assert digest==sha(prg)
    settings=profile(prg)
    return dict(prg=str(prg),prgSHA256=digest,emulator=str(VICE),emulatorSHA256=sha(VICE),command=command,
        storage=dict(device=8,backend='VICE host filesystem; KERNAL sequential input; no physical1541 timing',directory=str(media),files={p.name:sha(p) for p in media.glob('wg*')}),target='VICE Turbo6510 PAL multiplier64',music=False,filter=0,palette='colodore.vpl',
        viewport='96x60 logical,192x120 physical at48,8; original2D adventure interface',
        textureQuality='fast blocks8/even rows50' if settings['perspectiveBlock']==8 else 'precise each pixel/all60 rows',
        textureLOD=settings['textureLOD'],renderedRows=settings['renderedRows'],perspectiveBlock=settings['perspectiveBlock'],
        framePresentation='safe',focal=41,PRGUnmodified=True,hostSecondsDiagnosticOnly=time.monotonic()-started)
def benchmark(build,refreshes=3072):
    b,prg,l=paths(build);stem=ROOT/'reports/fps'/build;warm=101
    cmds=[f'logname "{stem}.monitor.log"','log on',f'load_labels "{b/"3Dvibe64.labels"}"',
        'break exec .render_frame_begin','x','disable 1','break exec .demo_count_refresh',f'ignore 2 {warm-1:x}','x',
        'bank ram',f'save "{stem}.start.ram" 0 $0000 $ffff','bank cpu','disable 2','stopwatch reset',
        'trace exec .fps_frame_done','trace exec .demo_count_refresh','break exec .demo_count_refresh',f'ignore 5 {refreshes-1:x}',
        *((['trace exec .wg_commit_done','trace exec .wg_io_begin','trace exec .wg_io_end']) if 'wg_commit_done' in l else []),
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
    commits=[];io=[]
    for m in re.finditer(r'#(6|7|8) \(Trace\s+exec [0-9a-f]+\)[^\n]*\n([^\n]+)',text,re.I):
        t=int(re.search(r'(\d+)\s*$',m[2])[1]);entry=dict(baseCycles=t,seconds=t/CLOCK)
        if m[1]=='6':
            entry['group']=int(re.search(r'A:([0-9a-f]{2})',m[2],re.I)[1],16);commits.append(entry)
        else:entry['event']='begin' if m[1]=='7' else 'end';io.append(entry)
    holds=[]
    for event in io:
        if event['event']!='begin':continue
        done=next(c for c in commits if c['baseCycles']>event['baseCycles'])
        assert not any(event['baseCycles']<=t<=done['baseCycles'] for t in frames)
        holds.append(dict(startSeconds=event['seconds'],endSeconds=done['seconds'],milliseconds=(done['baseCycles']-event['baseCycles'])*1000/CLOCK,phase='hold last complete view during read, validation and install'))
    state={n:last[l[n]] for n in ('wg_current','wg_error','wg_failures','wg_transitions','dr_route_fault') if n in l}
    assert not any(state.get(n,0) for n in ('wg_error','wg_failures','dr_route_fault')),state
    info.update(worldEndState=state,loadHoldSegments=holds,groupCommits=commits,loadEvents=io,
        startGroup=first[l['wg_current']] if 'wg_current' in l else None,endGroup=last[l['wg_current']] if 'wg_current' in l else None,
        warmupRefreshes=warm,warmupEmulatedSeconds=warm*REFRESH/CLOCK,
        measureRefreshes=refreshes,measureBaseCycles=total,baseClockHz=CLOCK,
        emulatedSeconds=seconds,completeViews=delta,averageFPS=delta/seconds,
        p95IntervalMs=intervals[math.ceil(len(intervals)*.95)-1],worstIntervalMs=max(intervals),
        frameTimesBaseCycles=frames,refreshTimesBaseCycles=irqs,windows=windows,faults=faults,
        startKey=first[l['demo_key']],endKey=last[l['demo_key']],
        route=json.loads((b/'build.json').read_text(encoding='utf-8-sig')).get('demoCamera',{}).get('description','48-key360degree orbit around both subjects, two vertical gaze sweeps,3072 logical ticks'),
        stationaryCameraSegments=[],PRGInstrumentationAdded=False,
        intervalDefinition='successive complete-view commits, excluding first/last partial intervals',
        countDefinition='new complete buffer commits only; native counter cross-check; no repeated refresh')
    stem.with_suffix('.json').write_text(json.dumps(info,indent=2))
    print(json.dumps({k:v for k,v in info.items() if k not in ('command','frameTimesBaseCycles','refreshTimesBaseCycles')},indent=2))
