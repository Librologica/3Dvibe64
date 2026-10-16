"""Capture each completed native render with its actual camera, before swap."""
import argparse,json,subprocess
from pathlib import Path
from native_probe import labels,VICE
from sweep import decode
ROOT=Path(__file__).resolve().parents[1]

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--build',required=True);ap.add_argument('--name',required=True)
    ap.add_argument('--frames',type=int,default=128);ap.add_argument('--standard',default='pal');a=ap.parse_args()
    b=Path(a.build);L=labels(b/'3Dvibe64.labels');out=ROOT/'artifacts'/a.name;out.mkdir(exist_ok=False)
    cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_end','x']
    for k in range(a.frames):
        if k:cmds += ['x']
        cmds += [f'save "{out/f"{k:02d}.ram"}" 0 $0000 $ffff']
    cmds += ['quit'];mon=out/'moving.mon';mon.write_text('\n'.join(cmds)+'\n')
    si=subprocess.STARTUPINFO();si.dwFlags|=subprocess.STARTF_USESHOWWINDOW;si.wShowWindow=0
    cmd=[str(VICE),'-default','+confirmonexit','-console','-warp','-sounddev','dummy','-'+a.standard,
         '-turbo6510','64','-autostartprgmode','1','-moncommands',str(mon),'-initbreak','ready',
         '-logfile',str(out/'vice.log'),str(b/'3Dvibe64.prg')]
    r=subprocess.run(cmd,capture_output=True,text=True,startupinfo=si,timeout=900)
    (out/'stdout.txt').write_text(r.stdout+r.stderr);assert r.returncode==0,r.stderr
    poses=[];stats=[]
    for k in range(a.frames):
        path=out/f'{k:02d}.ram';ram=bytearray(path.read_bytes()[2:])
        pose=[]
        for axis in 'xyz':
            n=sum(ram[L[f'explorer_cam_{axis}_{suffix}']]<<(8*i) for i,suffix in enumerate(('lo','hi','ext')))
            if n&0x800000:n-=1<<24
            pose.append(n)
        for axis in ('yaw','pitch'):pose.append(256*ram[L['explorer_cam_'+axis]]+ram[L['qc_demo_'+axis+'_lo']])
        poses.append(pose)
        # decode() expects a published front, so flip the selector ONLY in the
        # host copy. Actual dump retains draw buffer and native program intact.
        ram[L['drawbuf']]^=1;im,holes=decode(ram,L)
        if holes:im.resize((448,280)).save(out/f'holes-{k:02d}.png')
        stats.append(dict(frame=k,black=holes,buffer=1-ram[L['drawbuf']],
                          psFault=ram[L['ps_fault']],hpFault=ram[L['hp_fault']],
                          refreshes=int.from_bytes(ram[L['demo_refreshes']:L['demo_refreshes']+2],'little')))
    (out/'poses.json').write_text(json.dumps(dict(posesQ8=poses,capture='render_frame_end; completed draw buffer'),indent=2))
    (out/'coverage.json').write_text(json.dumps(stats,indent=2));print(dict(frames=len(stats),
        blackSamples=sum(s['black'] for s in stats),faults=sum(s['psFault']+s['hpFault'] for s in stats),
        lastRefresh=stats[-1]['refreshes'],buffers=sorted(set(s['buffer'] for s in stats))))
if __name__=='__main__':main()
