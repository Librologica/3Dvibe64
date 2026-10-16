"""Materialize the experimental precise three-room Underworld integration."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[1]
EXT=ROOT/'extensions/gameplay'
EXP=EXT/'experiments/underworld'


def build(out, name='adventure-pal', culling=True, scene_config=None):
    out=Path(out).resolve()
    if out.exists() or out.is_relative_to(ROOT):raise ValueError('Choose a new directory outside the source SDK')
    out.mkdir(parents=True)
    shutil.copytree(EXT/'common',out,dirs_exist_ok=True)
    shutil.copytree(ROOT,out/'sdk',ignore=shutil.ignore_patterns('.git','__pycache__','*.pyc'))
    sdk=out/'sdk'
    lines=[hashlib.sha256(p.read_bytes()).hexdigest().upper()+'  '+p.relative_to(sdk).as_posix()
           for p in sorted(sdk.rglob('*')) if p.is_file() and p!=sdk/'MANIFEST.sha256']
    (sdk/'MANIFEST.sha256').write_text('\n'.join(lines)+'\n',encoding='utf-8',newline='\n')
    for n in ['reports','artifacts','room','room/scenes','room/reports']:(out/n).mkdir(exist_ok=True)
    shutil.copytree(EXP/'tools',out/'tools')
    (out/'assets/adventure-render.json').write_text(json.dumps(dict(culling=culling))+'\n',encoding='utf-8')
    if scene_config is not None:
        scene_config=Path(scene_config).resolve(strict=True)
        cfg=json.loads(scene_config.read_text(encoding='utf-8-sig'))
        asset=(scene_config.parent/cfg['billboards'][0]['asset']).resolve(strict=True)
        if not asset.is_relative_to(scene_config.parent):raise ValueError('Asset must be inside the scene directory')
        shutil.copy2(asset,out/'assets/configured-guardian.json')
        cfg['billboards'][0]['asset']='configured-guardian.json'
        (out/'assets/adventure-scene.json').write_text(json.dumps(cfg,indent=2)+'\n',encoding='utf-8')
    for n in ['launch-demo.cmd','launch-64mhz.ps1']:shutil.copy2(EXP/n,out/n)
    for n in ['build_demo.py','adventure.py','viewport.py','inherited_precise_span.py']:
        shutil.copy2(EXP/n,out/('' if n=='build_demo.py' else 'src')/n)
    shutil.copy2(EXP/'private_build.py',out/'private/q8/build.py')
    for n in ['single_room.py','comparison_actors.py','optimizations.py']:
        shutil.copy2(EXT/'profiles/comparison-ui/src'/n,out/'src'/n)
    shutil.copy2(EXT/'billboards/outlined.py',out/'src/billboard_room.py')
    shutil.copy2(EXT/'billboards/scene.py',out/'src/billboard_scene.py')
    shutil.copy2(EXT/'entities/runtime.py',out/'src/entity_runtime.py')
    p=out/'src/cell_order.py';s=p.read_text(encoding='utf-8-sig')
    s=s.replace('assert len(owners)==107',"assert len(owners)==stats['ranges'][-1]['end']")
    s=s.replace("owners += [4]*len(mesh['faces'])", "owners += [0]*len(mesh['faces'])")
    s=s.replace('cpx #107','cpx #106')
    p.write_text(s,encoding='utf-8',newline='\n')
    command=[sys.executable,'-B','build_demo.py','--name',name]
    (out/'reports/build-command.json').write_text(json.dumps(command,indent=2)+'\n',encoding='utf-8')
    run=subprocess.run(command,cwd=out,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1',PYTHONIOENCODING='utf-8'),capture_output=True,timeout=600)
    (out/'reports/build.log').write_bytes(run.stdout+run.stderr)
    if run.returncode:raise RuntimeError('Build failed: '+str(out/'reports/build.log'))
    print('BUILT',out,flush=True)


if __name__=='__main__':
    if not __debug__:raise SystemExit('QUALIFICATION_OPTIMIZED_PYTHON: run without -O/-OO')
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out',required=True,type=Path)
    ap.add_argument('--name',default='adventure-pal')
    ap.add_argument('--no-room-culling',action='store_true')
    ap.add_argument('--scene-config',type=Path)
    args=ap.parse_args();build(args.out,args.name,not args.no_room_culling,args.scene_config)
