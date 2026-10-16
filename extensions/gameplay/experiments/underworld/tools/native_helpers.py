"""Identical-pose native captures of the previous and rebuilt three-room demo."""
import hashlib,json,os,re,subprocess
if not __debug__:
    raise SystemExit('Qualification requires unoptimized Python; remove -O/-OO and PYTHONOPTIMIZE.')
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
VICE=Path(os.environ.get('VICE_TURBO6510',r'C:\Users\rapso\Documents\ChatGPT\VICE Fork\vice-turbo6510\dist\Turbo6510-x64sc\bin\x64sc_u.exe'))
def labels(p):return {m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',p.read_text(),re.M)}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest().upper()
def run(cmd,log):
    si=subprocess.STARTUPINFO();si.dwFlags|=subprocess.STARTF_USESHOWWINDOW;si.wShowWindow=0
    p=subprocess.run(cmd,capture_output=True,startupinfo=si,timeout=240)
    log.write_bytes(p.stdout+p.stderr);assert p.returncode==0,(p.returncode,log)
def capture(build,prg,key,phase,standard,version,pose,disable_texture_lod=False):
    l=labels(build/'3Dvibe64.labels');dest=ROOT/f'raw/views/{version}-{standard}-key{key:02d}'
    dest.mkdir(parents=True,exist_ok=True)
    if (dest/'after.ram').exists():return dest,l
    mon=[f'load_labels "{(build/"3Dvibe64.labels").as_posix()}"','break exec .render_frame_begin','x',
         f'> ${l["advance_sim_tick"]:04x} $60']
    if disable_texture_lod:
        lo=lambda n:[l[n]&255,(l[n]>>8)&255]
        code=[0x8e,*lo('lg_texture'),0xa9,16,0x20,*lo('lg_set_weight'),0xbd,*lo('op_texture_constant'),0x60]
        mon.append(f'> ${l["lg_select"]:04x} '+ ' '.join(f'{v:02x}' for v in code))
    for axis,value in zip('xyz',[(64*256+phase*1203)&65535,(8*256+phase*1777)&65535,(16*256+phase*937)&65535]):
        mon += [f'> ${l["object_ang_"+axis+"_lo"]+3:04x} ${value&255:02x}',
                f'> ${l["object_ang_"+axis+"_hi"]+3:04x} ${value>>8:02x}']
    for name,value in [('wr_pose',phase%32),('wr_dirty',1),('bc_state',(phase//4)%2),('bc_cursor',phase%(2 if (phase//4)%2 else 4)),('bb_loaded',255)]:
        mon.append(f'> ${l[name]:04x} ${value:02x}')
    for axis,value in zip('xyz',pose[:3]):
        for suffix,byte in [('lo',value&255),('hi',(value>>8)&255),('ext',255 if value<0 else 0)]:
            mon.append(f'> ${l["explorer_cam_"+axis+"_"+suffix]:04x} ${byte:02x}')
    for axis,value in zip(['yaw','pitch'],pose[3:]):
        mon += [f'> ${l["explorer_cam_"+axis]:04x} ${value>>8:02x}',f'> ${l["qc_demo_"+axis+"_lo"]:04x} ${value&255:02x}']
    mon += ['ignore 1 3','x','delete 1','break exec .fps_frame_done','x',
            'bank ram',f'save "{(dest/"after.ram").as_posix()}" 0 $0000 $ffff','bank cpu',
            f'save "{(dest/"color.ram").as_posix()}" 0 $d800 $dbff',
            f'screenshot "{(dest/"native.png").as_posix()}" 2','quit']
    script=dest/'commands.mon';script.write_text('\n'.join(mon)+'\n')
    cmd=[str(VICE),'-default','+confirmonexit','-console','-warp','+sound','-'+standard,'-turbo6510','64',
         '-autostartprgmode','1','-VICIIfilter','0','-VICIIextpal','-VICIIpalette',str(ROOT/'assets/colodore.vpl'),
         '-initbreak','ready','-moncommands',str(script),str(prg)]
    (dest/'command.json').write_text(json.dumps(cmd,indent=2)+'\n')
    digest=sha(prg);run(cmd,dest/'console.log');assert sha(prg)==digest
    return dest,l