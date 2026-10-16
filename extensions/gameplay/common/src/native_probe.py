"""Same-pose native VICE snapshots; no host-rendered images masquerading as VICE."""
import argparse,json,os,re,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
VICE=Path(os.environ.get('VICE_TURBO6510',r'C:\Users\rapso\Documents\ChatGPT\VICE Fork\vice-turbo6510\dist\Turbo6510-x64sc\bin\x64sc_u.exe'))
def labels(p):return {m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',p.read_text(),re.M)}
def main():
    p=argparse.ArgumentParser();p.add_argument('--build',required=True);p.add_argument('--name',required=True)
    p.add_argument('--frames',type=int,default=4);p.add_argument('--freeze',action='store_true')
    p.add_argument('--warmup-frames',type=int,default=0)
    p.add_argument('--standard',choices=['pal','ntsc'],default='pal')
    p.add_argument('--prg',help='explicit startup-packaged PRG, absolute or relative to demo root')
    p.add_argument('--load-mode',type=int,choices=[0,1,2],default=1)
    p.add_argument('--vice',default=str(VICE))
    p.add_argument('--pose-key',type=int,help='room camera key0..63, forces identical fixed comparison pose')
    p.add_argument('--pose',type=float,nargs=5,help='internal X/up/forward and yaw/pitch angle units; frozen diagnostic')
    p.add_argument('--tour-refreshes',type=int,help='automatic moving tour, fixed emulated refresh window; not a framebuffer capture')
    p.add_argument('--successive-captures',type=int,default=1,help='consecutive render boundaries after initial capture; fixed-pose regression')
    p.add_argument('--settle-display',action='store_true',help='allow VIC display latches to settle after render boundary; frozen pose only')
    a=p.parse_args();b=ROOT/'room/build'/a.build;stem=ROOT/'artifacts'/a.name;lab=labels(b/'3Dvibe64.labels')
    cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x']
    if a.freeze:cmds += [f'> ${lab["advance_sim_tick"]:04x} 60']
    if a.pose_key is not None or a.pose is not None:
        assert a.freeze and not(a.pose_key is not None and a.pose is not None)
        pose=([round(n*256) for n in a.pose] if a.pose is not None else
              json.loads((ROOT/'room/scenes/camera-keyframes.json').read_text())['posesQ8'][a.pose_key])
        for axis,value in zip('xyz',pose[:3]):
            for suffix,byte in [('lo',value&255),('hi',(value>>8)&255),('ext',255 if value<0 else 0)]:
                cmds += [f'> ${lab["explorer_cam_"+axis+"_"+suffix]:04x} {byte:02x}']
        for axis,value in zip(('yaw','pitch'),pose[3:]):
            cmds += [f'> ${lab["explorer_cam_"+axis]:04x} {value>>8:02x}',f'> ${lab["qc_demo_"+axis+"_lo"]:04x} {value&255:02x}']
    if a.warmup_frames:
        cmds += [f'ignore 1 {a.warmup_frames:x}','x']
        names=('tp_frames','tp_refreshes') if 'tp_frames' in lab else ('demo_frames','demo_refreshes')
        for n in names:cmds += [f'> ${lab[n]:04x} 00 00']
    if a.tour_refreshes:
        assert not a.freeze and a.pose_key is None and a.warmup_frames
        pose=json.loads((ROOT/'room/scenes/camera-keyframes.json').read_text())['posesQ8'][0]
        for n in ('demo_key','demo_subtick'):cmds += [f'> ${lab[n]:04x} 00']
        for axis,value in zip('xyz',pose[:3]):
            for suffix,byte in [('lo',value&255),('hi',(value>>8)&255),('ext',255 if value<0 else 0)]:
                cmds += [f'> ${lab["explorer_cam_"+axis+"_"+suffix]:04x} {byte:02x}']
        for axis,value in zip(('yaw','pitch'),pose[3:]):
            cmds += [f'> ${lab["explorer_cam_"+axis]:04x} {value>>8:02x}',f'> ${lab["qc_demo_"+axis+"_lo"]:04x} {value&255:02x}']
        assert 'demo_count_refresh' in lab,'Missing verified per-refresh counter hook'
        cmds += ['disable 1','break exec .demo_count_refresh',f'ignore 2 {a.tour_refreshes:x}','x']
    else:cmds += [f'ignore 1 {a.frames:x}','x']
    assert a.successive_captures>=1
    assert a.successive_captures==1 or (a.freeze and not a.tour_refreshes)
    assert not a.settle_display or a.freeze
    for i in range(a.successive_captures):
        dest=stem if i==0 else stem.with_name(stem.name+'-'+str(i))
        if i:cmds += ['x']
        if a.settle_display:cmds += ['step $10000']
        cmds += [f'save "{dest.with_suffix(".ram")}" 0 $0000 $ffff',f'screenshot "{dest.with_suffix(".png")}" 2']
    cmds += ['quit']
    stem.with_suffix('.mon').write_text('\n'.join(cmds)+'\n')
    si=subprocess.STARTUPINFO();si.dwFlags|=subprocess.STARTF_USESHOWWINDOW;si.wShowWindow=0
    cmd=[a.vice,'-default','+confirmonexit','-console','-warp','-sounddev','dummy','-'+a.standard]
    if 'x64sc_u' in a.vice:cmd+=['-turbo6510','64']
    prg=ROOT/a.prg if a.prg else b/'3Dvibe64.prg'
    cmd+=['-autostartprgmode',str(a.load_mode),'-VICIIfilter','0','-VICIIextpal','-VICIIpalette',str(ROOT/'assets/colodore.vpl'),'-moncommands',str(stem.with_suffix('.mon')),
        '-initbreak','ready','-logfile',str(stem.with_suffix('.log')),str(prg)]
    r=subprocess.run(cmd,capture_output=True,text=True,startupinfo=si,
        timeout=max(240,(a.tour_refreshes or 0)//16))
    stem.with_suffix('.stdout').write_text(r.stdout+r.stderr)
    assert r.returncode==0,(r.returncode,r.stdout[-2000:]);assert stem.with_suffix('.ram').exists()
    print(a.name,'native probe captured')
if __name__=='__main__':main()
