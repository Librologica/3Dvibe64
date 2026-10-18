"""Native PAL Turbo6510 complete-view measurement / deterministic image probe.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
Builds, logs, commands, RAM and images must be outside the source repository.
"""
import argparse,hashlib,json,math,os,re,subprocess,shutil
from pathlib import Path
CLOCK=985248;REFRESH=312*63

def labels(path):return {m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',path.read_text(),re.M)}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest().upper()
def main():
    p=argparse.ArgumentParser();p.add_argument('--prg',type=Path,required=True);p.add_argument('--labels',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True);p.add_argument('--palette',type=Path)
    p.add_argument('--vice',type=Path,default=os.environ.get('VICE_TURBO6510') or shutil.which('x64sc_u') or shutil.which('x64sc'))
    p.add_argument('--warmup',type=int,default=101);p.add_argument('--refreshes',type=int,default=2048)
    p.add_argument('--route',required=True);p.add_argument('--poses',action='store_true');p.add_argument('--reference',type=Path);p.add_argument('--sound-off',action='store_true')
    a=p.parse_args();a.prg=a.prg.resolve();a.labels=a.labels.resolve();stem=a.out.resolve()
    if not a.sound_off:p.error('This public probe requires --sound-off; use a validated SID-aware probe for music-active projects')
    if a.vice is None:p.error('Set VICE_TURBO6510 or pass --vice for the real Turbo6510 executable')
    repo=Path(__file__).resolve().parents[1]
    if stem.is_relative_to(repo):raise ValueError('Output must be outside source repository')
    if Path(str(stem)+'.json').exists():raise ValueError('Choose a fresh measurement name')
    stem.parent.mkdir(parents=True,exist_ok=True);lab=labels(a.labels);digest=sha(a.prg)
    cmd=[f'logname "{stem}.monitor.log"','log on',f'load_labels "{a.labels}"','break exec .render_frame_begin','x','disable 1']
    ticks=[100,300,550,800,1100]
    if a.poses:
        payload=a.prg.read_bytes()
        # All startup/unpacking is complete. Read the original opcode from
        # monitor memory when a packaged PRG does not map native addresses.
        cmd+=['break exec .advance_sim_tick'];previous=0
        for index,tick in enumerate(ticks):
            # The qualified families start this routine with a JSR to the
            # auto-camera tick; assert the runtime byte in saved RAM below.
            cmd += [f'ignore 2 {tick-previous-1:x}','x',f'save "{stem}.{tick}.before.ram" 0 $0000 $ffff',
                    '> .advance_sim_tick 60','disable 2']
            cmd+=['break exec .fps_frame_done'] if index==0 else ['enable 3']
            cmd+=['ignore 3 2','x',f'screenshot "{stem}.{tick}.png" 2',f'save "{stem}.{tick}.ram" 0 $0000 $ffff',
                  'disable 3','> .advance_sim_tick 20','enable 2'];previous=tick-1
    else:
        if a.refreshes*REFRESH/CLOCK<20:raise ValueError('Measure at least20 emulated seconds')
        cmd+=['break exec .raster_irq',f'ignore 2 {a.warmup-1:x}','x','disable 2','stopwatch reset',
              'trace exec .fps_frame_done','trace exec .raster_irq','break exec .raster_irq',f'ignore 5 {a.refreshes-1:x}','x',
              'stopwatch',f'save "{stem}.ram" 0 $0000 $ffff',f'screenshot "{stem}.png" 2']
    cmd+=['quit'];mon=Path(str(stem)+'.mon');mon.write_text('\n'.join(cmd)+'\n')
    command=[str(a.vice),'-default','+confirmonexit','-console','+warp','-sounddev','dummy','-pal','-turbo6510','64',
             '-autostartprgmode','1','-VICIIfilter','0','-moncommands',str(mon),'-initbreak','ready','-logfile',str(stem)+'.vice.log']
    if a.sound_off:command+=['+sound']
    if a.palette:command+=['-VICIIextpal','-VICIIpalette',str(a.palette.resolve())]
    command+=[str(a.prg)];Path(str(stem)+'.command.json').write_text(json.dumps(command,indent=2))
    si=subprocess.STARTUPINFO();si.dwFlags|=subprocess.STARTF_USESHOWWINDOW;si.wShowWindow=0
    r=subprocess.run(command,capture_output=True,text=True,startupinfo=si,timeout=600)
    Path(str(stem)+'.stdout').write_text(r.stdout+r.stderr);assert r.returncode==0,(r.returncode,r.stderr[-1000:])
    result=dict(prg=str(a.prg),prgSHA256=digest,target='VICE Turbo6510 PAL x64; silent',route=a.route,command=command,
                warmupRefreshes=a.warmup,warmupSeconds=a.warmup*REFRESH/CLOCK,hostTimeUsedForFPS=False)
    if a.poses:
        from PIL import Image,ImageChops
        checks=[]
        for tick in ticks:
            original=Path(str(stem)+f'.{tick}.before.ram').read_bytes()[2:]
            assert original[lab['advance_sim_tick']]==0x20,'Unexpected tick entry; do not restore a guessed opcode'
            ram=Path(str(stem)+f'.{tick}.ram').read_bytes()[2:]
            faults={n:ram[lab[n]] for n in ['hp_fault','xyq2_faulted','ps_fault'] if n in lab};assert not any(faults.values()),faults
            item=dict(tick=tick,faults=faults)
            if a.reference:
                old=Image.open(str(a.reference)+f'.{tick}.png').convert('RGB');new=Image.open(str(stem)+f'.{tick}.png').convert('RGB')
                diff=ImageChops.difference(old.crop((32,35,352,235)),new.crop((32,35,352,235)))
                item['differentPixels']=sum(v!=(0,0,0) for v in diff.get_flattened_data());assert item['differentPixels']==0,item
            checks.append(item)
        result.update(imageChecks=checks,FPSMeasured=False,simulationFrozenForImagesOnly=True)
    else:
        log=Path(str(stem)+'.monitor.log').read_text(errors='replace').rsplit('Stopwatch reset to 0.',1)[1]
        events=[(int(m[1]),int(re.search(r'(\d+)\s*$',m[2])[1])) for m in re.finditer(r'#(3|4) \(Trace\s+exec [0-9a-f]+\)[^\n]*\n([^\n]+)',log,re.I)]
        frames=[t for k,t in events if k==3];refresh=[t for k,t in events if k==4]
        cycles=int(re.findall(r'Stopwatch:\s*(\d+)',log)[-1]);assert len(refresh)==a.refreshes
        assert abs(cycles-a.refreshes*REFRESH)<80
        assert max(abs(y-x-REFRESH) for x,y in zip(refresh,refresh[1:]))<80
        intervals=[(y-x)/CLOCK*1000 for x,y in zip(frames,frames[1:])];assert intervals
        ram=Path(str(stem)+'.ram').read_bytes()[2:]
        faults={n:ram[lab[n]] for n in ['hp_fault','xyq2_faulted','ps_fault'] if n in lab};assert not any(faults.values()),faults
        result.update(FPSMeasured=True,emulatedSeconds=cycles/CLOCK,emulatedBaseCycles=cycles,measureRefreshes=a.refreshes,
                      completeNewViews=len(frames),averageFPS=len(frames)/(cycles/CLOCK),
                      p95IntervalMs=sorted(intervals)[math.ceil(len(intervals)*.95)-1],worstIntervalMs=max(intervals),
                      frameTimesBaseCycles=frames,refreshTimesBaseCycles=refresh,faultBytes=faults,
                      countDefinition='fps_frame_done after a new complete rendered buffer; duplicate refreshes excluded')
    assert sha(a.prg)==digest;Path(str(stem)+'.json').write_text(json.dumps(result,indent=2))
    print(json.dumps({k:v for k,v in result.items() if k not in ['command','frameTimesBaseCycles','refreshTimesBaseCycles']},indent=2))
if __name__=='__main__':main()
