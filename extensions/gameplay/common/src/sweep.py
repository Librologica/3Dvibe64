"""Frozen-pose native RAM coverage sweep, front buffer only."""
import argparse,json,subprocess
from pathlib import Path
from PIL import Image,ImageDraw
from native_probe import labels,VICE
ROOT=Path(__file__).resolve().parents[1]

def decode(r,L):
    base=0x2000 if r[L['drawbuf']]==0 else 0x6000
    im=Image.new('RGB',(112,70));holes=0
    colors=[(0,0,0),(100,70,40),(135,135,135),(215,215,215)]
    for y in range(70):
        yy=2*(y+15)
        for x in range(112):
            xx=x+24
            q=(r[base+(yy//8)*320+yy%8+(xx//4)*8]>>(6-2*(xx&3)))&3
            holes+=q==0;im.putpixel((x,y),colors[q])
    return im,holes

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--build',required=True);ap.add_argument('--name',required=True)
    ap.add_argument('--keys',default='all');ap.add_argument('--standard',default='pal');ap.add_argument('--bypass-legacy',action='store_true')
    ap.add_argument('--poses',type=Path);a=ap.parse_args()
    b=Path(a.build);L=labels(b/'3Dvibe64.labels');out=ROOT/'artifacts'/a.name;out.mkdir(exist_ok=False)
    poses=json.loads((a.poses or ROOT/'room/scenes/camera-keyframes.json').read_text())['posesQ8']
    ids=list(range(len(poses))) if a.keys=='all' else [int(n) for n in a.keys.split(',')]
    cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x',f'> ${L["advance_sim_tick"]:04x} 60']
    if a.bypass_legacy:
        target=L['lfv_bucket'];cmds += [f'> ${L["load_face_visible"]:04x} 4c {target&255:02x} {target>>8:02x}',f'> ${L["camera_plane_bucket_ready"]:04x} 00']
    for k in ids:
        pose=poses[k]
        for axis,value in zip('xyz',pose[:3]):
            for suffix,byte in [('lo',value&255),('hi',(value>>8)&255),('ext',255 if value<0 else 0)]:
                cmds.append(f'> ${L["explorer_cam_"+axis+"_"+suffix]:04x} {byte:02x}')
        for axis,value in zip(('yaw','pitch'),pose[3:]):
            cmds += [f'> ${L["explorer_cam_"+axis]:04x} {value>>8:02x}',f'> ${L["qc_demo_"+axis+"_lo"]:04x} {value&255:02x}']
        cmds += ['x','x',f'save "{out/f"{k:02d}.ram"}" 0 $0000 $ffff']
    cmds += ['quit'];mon=out/'sweep.mon';mon.write_text('\n'.join(cmds)+'\n')
    si=subprocess.STARTUPINFO();si.dwFlags|=subprocess.STARTF_USESHOWWINDOW;si.wShowWindow=0
    cmd=[str(VICE),'-default','+confirmonexit','-console','-warp','-sounddev','dummy','-'+a.standard,
         '-turbo6510','64','-autostartprgmode','1','-moncommands',str(mon),'-initbreak','ready',
         '-logfile',str(out/'vice.log'),str(b/'3Dvibe64.prg')]
    r=subprocess.run(cmd,capture_output=True,text=True,startupinfo=si,timeout=600)
    (out/'stdout.txt').write_text(r.stdout+r.stderr);assert r.returncode==0,r.stderr
    grid=Image.new('RGB',(4*224,((len(ids)+3)//4)*160));draw=ImageDraw.Draw(grid);report=[]
    for j,k in enumerate(ids):
        ram=(out/f'{k:02d}.ram').read_bytes()[2:];im,holes=decode(ram,L)
        grid.paste(im.resize((224,140)),((j%4)*224,(j//4)*160))
        draw.text(((j%4)*224,(j//4)*160+142),f'key{k} black={holes}',fill='white')
        report.append(dict(key=k,black=holes,psFault=ram[L['ps_fault']],hpFault=ram[L['hp_fault']]))
    grid.save(out/'grid.png');(out/'coverage.json').write_text(json.dumps(report,indent=2));print(report)
if __name__=='__main__':main()
