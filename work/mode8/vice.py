"""Stock VICE tests: trace counters are emulated CPU clocks, NOT host time."""
from pathlib import Path
import argparse,json,re,subprocess,os,shutil
def canonical(p):
    s=str(Path(p).resolve())
    if s.startswith('\\\\?\\UNC\\'):s='\\\\'+s[8:]
    elif s.startswith('\\\\?\\'):s=s[4:]
    return Path(s)
ROOT=canonical(__file__).parents[2]
VICE=Path(os.environ.get('VICE_X64SC') or shutil.which('x64sc') or shutil.which('x64sc.exe') or 'x64sc')

def capture(build,out,standard='pal',cycles=8000000,points=None,pose=None,keys=None,initial_pose=None,warp=True,extra=None,turbo=None,capture_once=False):
    build=canonical(build);out=canonical(out)
    if out.is_relative_to(ROOT):raise ValueError('VICE output must be outside SDK')
    out.mkdir(parents=True,exist_ok=True)
    # VICE appends monitor logs. Preserve prior attempts, never combine runs or
    # accidentally accept a stale snapshot after a failed invocation.
    prior=[out/n for n in ('trace.log','capture.vsf','color.bin','vic.bin','cia2.bin','screen.png','late.png','run.json','capture.mon','console.log') if (out/n).exists()]+list(out.glob('frame-*'))
    prior+=list(out.glob('tick-*.vsf'))
    prior+=list(out.glob('phase-*.vsf'))
    if (out/'tour-end.vsf').exists():prior.append(out/'tour-end.vsf')
    if prior:
        attempt=1
        while (out/f'previous-{attempt}').exists():attempt+=1
        archive=out/f'previous-{attempt}';archive.mkdir()
        for p in prior:p.rename(archive/p.name)
    points=points or ['render_frame_begin','render_frame_end','presentation_done']
    mon=[f'logname "{out.as_posix()}/trace.log"','log on','sidefx off',f'load_labels "{build.as_posix()}/labels.txt"']
    for label in points:mon += [f'trace .{label}']
    capture_label='.presentation_done'+(' if (@ram:$0012 == $02) && (@ram:$0013 == $00)' if capture_once else '')
    mon += ['trace '+capture_label]
    if not capture_once:mon += [f'ignore {len(points)+1} 1']
    mon += [f'command {len(points)+1} "dump \\"{out.as_posix()}/capture.vsf\\""']
    if pose is not None:
        data=' '.join(f'{b:02x}' for n in pose for b in (n&255,n>>8))
        mon+=['trace .render_frame_begin',f'command {len(points)+2} "> $0020 {data}"']
    next_id=len(points)+2+(pose is not None)
    for name,start,end in [('color',0xd800,0xdbe7),('vic',0xd000,0xd03f),('cia2',0xdd00,0xdd03)]:
        mon+=['trace '+capture_label,f'command {next_id} "bsave \\"{out.as_posix()}/{name}.bin\\" 0 ${start:04x} ${end:04x}"'];next_id+=1
    if keys is not None:
        mon+=['trace .read_input',f'command {next_id} "> $006a {keys:02x}"'];next_id+=1
    if initial_pose is not None:
        data=' '.join(f'{b:02x}' for n in initial_pose for b in (n&255,n>>8))
        mon+=['trace .init_simulation',f'command {next_id} "> $0020 {data}"'];next_id+=1
    extra_ids={}
    for label,command in extra or []:
        mon+=['trace '+(label if label.startswith(('store ','load ')) else '.'+label)];extra_ids[label]=next_id
        if command:mon+=[f'command {next_id} "{command}"']
        next_id+=1
    (out/'extra-traces.json').write_text(json.dumps(extra_ids,indent=2))
    mon+=['x']
    (out/'capture.mon').write_text('\n'.join(mon)+'\n')
    cmd=[str(VICE),'-default','+confirmonexit','-console','-warp','-'+standard,'-VICIIfilter','0','-autostartprgmode','1','-initbreak','ready','-moncommands',str(out/'capture.mon'),'-limitcycles',str(cycles),'-exitscreenshot',str(out/'screen.png'),str(build/'3Dvibe64.prg')]
    if not warp:cmd.remove('-warp')
    if turbo is not None:raise ValueError('This qualification requires stock x64sc')
    p=subprocess.run(cmd,capture_output=True,timeout=600)
    (out/'console.log').write_bytes(p.stdout+p.stderr)
    (out/'run.json').write_text(json.dumps(dict(command=cmd,returncode=p.returncode),indent=2))
    # This Windows VICE build also returns 1 at -limitcycles. Qualification
    # requires completed capture/trace outputs and checks their contents.
    if p.returncode not in (0,1) or not all((out/n).is_file() for n in ('trace.log','capture.vsf','screen.png')):
        raise RuntimeError('VICE failed or incomplete capture; inspect console.log')
    return out

def ram(snapshot):
    b=Path(snapshot).read_bytes();offset=b.index(b'C64MEM')+26
    return b[offset:offset+65536]

def traces(path):
    result=[]
    for line in Path(path).read_text(errors='replace').splitlines():
        m=re.search(r'\.C:([0-9a-fA-F]{4}).*\s(\d+)\s*$',line)
        if m:result.append((int(m[1],16),int(m[2])))
    return result
