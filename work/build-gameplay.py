"""Build the bounded experimental gameplay profiles from this source SDK.
Required Notice: 3Dvibe64. PolyForm Noncommercial1.0.0.
"""
import argparse,hashlib,json,os,shutil,subprocess,sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
EXT=ROOT/'extensions/gameplay'
PROFILES=('comparison-ui','dungeon-masked','mixed-surfaces','interactive-billboard','door-entity','multiple-billboards','animated-textures','static-light','sector-visibility','shared-meshes','controlled-animation','camera-roll','room-groups')


def profile_chain(profile, seen=(), project_source=None):
    if profile not in PROFILES or profile in seen: raise ValueError('Invalid/cyclic profile inheritance')
    project_source=Path(project_source).resolve(strict=True) if project_source is not None else None
    if project_source is None:raise ValueError('--project-source is required; demo templates are not distributed')
    preset=json.loads((project_source/f'examples/gameplay/{profile}.json').read_text(encoding='utf-8-sig'))
    return (profile_chain(preset['extends'],seen+(profile,),project_source) if 'extends' in preset else [])+[profile]


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def foundation_identity():
    root=ROOT
    entries={name:digest for line in (root/'MANIFEST.sha256').read_text().splitlines()
             for digest,name in [line.split('  ',1)]}
    assert set(entries)|{'MANIFEST.sha256'}=={p.relative_to(root).as_posix() for p in root.rglob('*') if p.is_file() and '.git' not in p.relative_to(root).parts}
    for name,digest in entries.items():assert sha(root/name)==digest,name
    return dict(version=(root/'VERSION').read_text().strip(),manifestSHA256=sha(root/'MANIFEST.sha256'))


def build(profile,out,surface_config=None,gameplay_scene=None,door_config=None,texture_animation=None,light_bake=None,visibility=None,shared_meshes=None,motion_controls=None,world_groups=None,project_source=None):
    if profile not in PROFILES:raise ValueError('Unknown gameplay profile')
    out=Path(out).resolve()
    if out.is_relative_to(ROOT) or out.exists():
        raise ValueError('Choose a new output directory outside the source repository')
    if project_source is None:raise ValueError('--project-source is required; new demo sources/assets are not distributed')
    project_source=Path(project_source).resolve(strict=True)
    if project_source.is_relative_to(ROOT) or project_source==ROOT:
        raise ValueError('Project templates must be outside this SDK')
    project_ext=project_source/'extensions/gameplay'
    chain=profile_chain(profile,project_source=project_source)
    required=[project_ext/'common',project_ext/'billboards',project_source/'examples/gameplay'/f'{profile}.json']
    required.extend(project_ext/'profiles'/p for p in chain)
    if any(not path.exists() for path in required):raise ValueError('Incomplete external project adapter inputs')
    if project_source.is_relative_to(out) or out.is_relative_to(project_source):raise ValueError('Output must not overlap project inputs')
    identity=foundation_identity()
    preset=json.loads((project_source/f'examples/gameplay/{profile}.json').read_text())
    if surface_config is not None and profile not in ('mixed-surfaces','interactive-billboard','door-entity','multiple-billboards','animated-textures','static-light','sector-visibility','shared-meshes','controlled-animation','camera-roll','room-groups'):
        raise ValueError('Surface configuration requires mixed-surfaces')
    if surface_config is not None: surface_config=Path(surface_config).resolve(strict=True)
    if gameplay_scene is not None and profile not in ('interactive-billboard','door-entity','multiple-billboards','animated-textures','static-light','sector-visibility','room-groups'):raise ValueError('Gameplay scene requires billboard profile')
    if door_config is not None and profile not in ('door-entity','multiple-billboards','animated-textures','static-light','sector-visibility','room-groups'):raise ValueError('Door configuration requires door-entity')
    if texture_animation is not None and profile not in ('animated-textures','static-light','sector-visibility'):raise ValueError('Texture animation requires animated-textures profile')
    if light_bake is not None and profile not in ('static-light','sector-visibility'):raise ValueError('Light bake requires static-light profile')
    if visibility is not None and profile!='sector-visibility':raise ValueError('Visibility configuration requires sector-visibility profile')
    if shared_meshes is not None and profile not in ('shared-meshes','controlled-animation','camera-roll'):raise ValueError('Shared mesh configuration requires shared-meshes profile')
    if motion_controls is not None and profile not in ('controlled-animation','camera-roll'):raise ValueError('Motion controls require a Q8-02 profile')
    if world_groups is not None and profile!='room-groups':raise ValueError('World configuration requires room-groups profile')
    if preset['engineVersion']!=(ROOT/'VERSION').read_text().strip():raise ValueError('Preset/dev version mismatch')
    out.mkdir(parents=True);project=out/'project';project.mkdir()
    shutil.copytree(project_ext/'common',project,dirs_exist_ok=True)
    for profile_name in chain:
        for path in (project_ext/'profiles'/profile_name).iterdir():
            if path.name=='origin.json':continue
            if path.is_dir():shutil.copytree(path,project/path.name,dirs_exist_ok=True)
            else:shutil.copy2(path,project/path.name)
    if profile in ('mixed-surfaces','interactive-billboard','door-entity','multiple-billboards','animated-textures','static-light','sector-visibility','shared-meshes','controlled-animation','camera-roll','room-groups'):
        shutil.copy2(EXT/'materials/surfaces.py',project/'src/surfaces.py')
        if surface_config is not None:shutil.copy2(surface_config,project/'assets/surfaces.json')
    if profile in ('interactive-billboard','door-entity','multiple-billboards','animated-textures','static-light','sector-visibility','room-groups'):
        shutil.copy2(EXT/'billboards/scene.py',project/'src/billboard_scene.py')
        shutil.copy2(EXT/'entities/runtime.py',project/'src/entity_runtime.py')
        if gameplay_scene is not None:
            gameplay_scene=Path(gameplay_scene).resolve(strict=True)
            cfg=json.loads(gameplay_scene.read_text(encoding='utf-8-sig'))
            asset=(gameplay_scene.parent/cfg['billboards'][0]['asset']).resolve(strict=True)
            if not asset.is_relative_to(gameplay_scene.parent):raise ValueError('Asset must be inside the scene directory')
            shutil.copy2(asset,project/'assets/guard-frames.json')
            for billboard in cfg['billboards']:
                if (gameplay_scene.parent/billboard['asset']).resolve(strict=True)!=asset:raise ValueError('Multiple instances require a shared asset')
                billboard['asset']='guard-frames.json'
            (project/'assets/gameplay-scene.json').write_text(json.dumps(cfg,indent=2)+'\n',encoding='utf-8')
    if profile in ('door-entity','multiple-billboards','animated-textures','static-light','sector-visibility','room-groups'):
        shutil.copy2(EXT/'entities/door.py',project/'src/door_runtime.py')
        if door_config is not None:
            door_config=Path(door_config).resolve(strict=True)
            shutil.copy2(door_config,project/'assets/door.json')
    if profile in ('multiple-billboards','animated-textures','static-light','sector-visibility'):
        shutil.copy2(EXT/'billboards/multiple.py',project/'src/billboard_multiple.py')
    if profile in ('animated-textures','static-light','sector-visibility'):
        shutil.copy2(EXT/'materials/animation.py',project/'src/texture_animation.py')
        if texture_animation is not None:
            texture_animation=Path(texture_animation).resolve(strict=True)
            cfg=json.loads(texture_animation.read_text(encoding='utf-8-sig'))
            asset=(texture_animation.parent/cfg['asset']).resolve(strict=True)
            if not asset.is_relative_to(texture_animation.parent):raise ValueError('Texture asset must be inside configuration directory')
            shutil.copy2(asset,project/'assets/texture-frames.json')
            cfg['asset']='texture-frames.json'
            (project/'assets/texture-animation.json').write_text(json.dumps(cfg,indent=2)+'\n',encoding='utf-8')
    if profile in ('static-light','sector-visibility'):
        shutil.copy2(EXT/'materials/light_bake.py',project/'src/light_baker.py')
        if light_bake is not None:
            light_bake=Path(light_bake).resolve(strict=True)
            shutil.copy2(light_bake,project/'assets/light-bake.json')
    if profile=='sector-visibility':
        shutil.copy2(EXT/'visibility/compiler.py',project/'src/visibility_compiler.py')
        if visibility is not None:shutil.copy2(Path(visibility).resolve(strict=True),project/'assets/visibility.json')
    if profile in ('shared-meshes','controlled-animation','camera-roll'):
        shutil.copy2(EXT/'meshes/shared.py',project/'src/shared_mesh_runtime.py')
        if shared_meshes is not None:shutil.copy2(Path(shared_meshes).resolve(strict=True),project/'assets/shared-meshes.json')
    if profile in ('controlled-animation','camera-roll'):
        shutil.copy2(EXT/'motion/controlled.py',project/'src/controlled_motion.py')
        if motion_controls is not None:shutil.copy2(Path(motion_controls).resolve(strict=True),project/'assets/motion.json')
    if profile=='room-groups':
        shutil.copy2(EXT/'world/groups.py',project/'src/world_groups.py')
        shutil.copy2(EXT/'world/io.asm',project/'src/world_io.asm')
        if world_groups is not None:shutil.copy2(Path(world_groups).resolve(strict=True),project/'assets/world-groups.json')
    shutil.copy2(project_ext/'billboards'/f"{preset['billboardImplementation']}.py",project/'src/billboard_room.py')
    shutil.copytree(ROOT,project/'sdk',ignore=shutil.ignore_patterns('.git','__pycache__','*.pyc'))
    for name in ('room','room/scenes','room/reports','reports','artifacts'):(project/name).mkdir(exist_ok=True)
    command=[sys.executable,'-B','build_demo.py','--name',preset['buildName'],'--artifact-tag',preset['buildName']]
    if preset['textureQuality']=='precise':command.append('--precise')
    env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1')
    result=subprocess.run(command,cwd=project,env=env,capture_output=True,timeout=300)
    (out/'build.log').write_bytes(result.stdout+result.stderr)
    if result.returncode:raise RuntimeError('Build failed; see '+str(out/'build.log'))
    program=project/preset['distributionPRG'];target=out/f'{profile}.prg';shutil.copy2(program,target)
    digest=sha(target)
    (out/'launch-demo.cmd').write_bytes(b'@echo off\r\ncall "%~dp0project\\launch-demo.cmd" %*\r\n')
    info=dict(engineVersion=preset['engineVersion'],profile=profile,experimental=True,
        foundation=identity,program=target.name,PRGSHA256=digest,
        checkpointPRGSHA256=preset['expectedCheckpointPRGSHA256'],
        checkpointPRGIdentical=digest==preset['expectedCheckpointPRGSHA256'],
        presetData=preset,projectInputsExternal=True,command=command,
        scope=preset.get('scope','bounded imported profile; no general public scene API'),target='VICE Turbo6510 PAL multiplier64',
        music=False,viewportLogical=preset['viewportLogical'],textureQuality=preset['textureQuality'],textureLOD=preset['textureLOD'],
        rootSourceVersion=(ROOT/'VERSION').read_text().strip())
    if profile in ('mixed-surfaces','interactive-billboard','door-entity','multiple-billboards','animated-textures','static-light','sector-visibility','shared-meshes','controlled-animation','camera-roll','room-groups'):
        info['surfaceConfiguration']=dict(source=str(surface_config) if surface_config else 'profile default',
            projectFile='assets/surfaces.json',SHA256=sha(project/'assets/surfaces.json'))
    if profile in ('interactive-billboard','door-entity','multiple-billboards','animated-textures','static-light','sector-visibility','room-groups'):
        info['gameplayConfiguration']=dict(source=str(gameplay_scene) if gameplay_scene else 'profile default',
            projectFile='assets/gameplay-scene.json',SHA256=sha(project/'assets/gameplay-scene.json'))
    if profile in ('door-entity','multiple-billboards','animated-textures','static-light','sector-visibility','room-groups'):
        info['doorConfiguration']=dict(source=str(door_config) if door_config else 'profile default',
            projectFile='assets/door.json',SHA256=sha(project/'assets/door.json'))
    if profile in ('animated-textures','static-light','sector-visibility'):
        info['textureAnimationConfiguration']=dict(source=str(texture_animation) if texture_animation else 'profile default',projectFile='assets/texture-animation.json',SHA256=sha(project/'assets/texture-animation.json'))
    if profile in ('static-light','sector-visibility'):
        info['lightBakeConfiguration']=dict(source=str(light_bake) if light_bake else 'profile default',projectFile='assets/light-bake.json',SHA256=sha(project/'assets/light-bake.json'))
    if profile=='sector-visibility':
        info['visibilityConfiguration']=dict(source=str(visibility) if visibility else 'profile default',projectFile='assets/visibility.json',SHA256=sha(project/'assets/visibility.json'))
    if profile in ('shared-meshes','controlled-animation','camera-roll'):
        info['sharedMeshConfiguration']=dict(source=str(shared_meshes) if shared_meshes else 'profile default',projectFile='assets/shared-meshes.json',SHA256=sha(project/'assets/shared-meshes.json'))
    if profile in ('controlled-animation','camera-roll'):
        info['motionConfiguration']=dict(source=str(motion_controls) if motion_controls else 'profile default',projectFile='assets/motion.json',SHA256=sha(project/'assets/motion.json'))
    if profile=='room-groups':
        info['worldConfiguration']=dict(source=str(world_groups) if world_groups else 'profile default',projectFile='assets/world-groups.json',SHA256=sha(project/'assets/world-groups.json'))
    (out/'build.json').write_text(json.dumps(info,indent=2)+'\n')
    print(json.dumps(info,indent=2),flush=True)
    return info


if __name__=='__main__':
    from mode8.common import require_qualification_checks
    require_qualification_checks()
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--profile',choices=PROFILES,default='comparison-ui')
    parser.add_argument('--out',required=True,type=Path)
    parser.add_argument('--project-source',required=True,type=Path,help='External project adapter root; no demo inputs are bundled')
    parser.add_argument('--surface-config',type=Path,help='Experimental mixed-surfaces face configuration')
    parser.add_argument('--gameplay-scene',type=Path,help='Experimental billboard/entity scene JSON')
    parser.add_argument('--door-config',type=Path,help='Door motion switch for equal-condition native control')
    parser.add_argument('--texture-animation',type=Path,help='Optional per-material frame and UV animation JSON')
    parser.add_argument('--light-bake',type=Path,help='Optional host-side static vertex light/shadow configuration')
    parser.add_argument('--visibility',type=Path,help='Optional conservative sector/portal configuration')
    parser.add_argument('--shared-meshes',type=Path,help='Optional Q8 shared mesh instance configuration')
    parser.add_argument('--motion-controls',type=Path,help='Optional Q8-02 playback and camera configuration')
    parser.add_argument('--world-groups',type=Path,help='Optional WORLD-01 group and transition configuration')
    args=parser.parse_args();build(args.profile,args.out,args.surface_config,args.gameplay_scene,args.door_config,args.texture_animation,args.light_bake,args.visibility,args.shared_meshes,args.motion_controls,args.world_groups,args.project_source)
