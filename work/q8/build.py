"""Public Q8 adapter; called only after explicit -Precision q8 dispatch.
Copyright 2026 librologica.digital. PolyForm Noncommercial 1.0.0.
Runtime generation is inherited from the qualified family checkpoint.
"""
import argparse,hashlib,json,math,os,re,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent
SDK_ROOT=ROOT.parents[1]
sys.path.insert(0,str(ROOT))
sys.path.insert(0,str(ROOT/'src'))
from emit import chunks,pack,attach
from continuous import prepare,pieces,verify_retired_state_absent,RETIRED_VERTEX_ARRAYS
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest().upper()
def labels(path):return {m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',path.read_text(),re.M)}
def assemble(source,out,stem):
    asm=out/(stem+'.asm');asm.write_text(source,encoding='ascii')
    tass=os.environ.get('TASS64_EXE') or shutil.which('64tass')
    if not tass:raise ValueError('Q8_TOOL: 64tass missing; set TASS64_EXE')
    cmd=[tass,'-a','-B','--vice-labels-numeric','--labels='+str(out/(stem+'.labels')),'--map='+str(out/(stem+'.map')),'-o',str(out/(stem+'.prg')),str(asm)]
    r=subprocess.run(cmd,capture_output=True,text=True,cwd=out);(out/(stem+'.log')).write_text(r.stdout+r.stderr)
    if r.returncode:raise RuntimeError(r.stdout+r.stderr)
    return labels(out/(stem+'.labels'))
def build(name,scene,precision='q8',standard='pal',mode=6,near='skip',music=False,motion=False,camera_mobile=False,camera_auto=False,memory_recovery=True,texture_precision=None,texture_quality=None,frame_presentation='safe',line_raster='precise',texture_lod=None,lod_near=None,lod_far=None):
    scene=Path(scene).resolve();spec=json.loads(scene.read_text(encoding='utf-8-sig'));out=Path(name).resolve()
    validate(spec,mode,standard,out)
    lod_distances_explicit=lod_near is not None or lod_far is not None or 'textureLODNear' in spec or 'textureLODFar' in spec
    texture_lod=texture_lod if texture_lod is not None else spec.get('textureLOD','off')
    lod_near=lod_near if lod_near is not None else spec.get('textureLODNear',28)
    lod_far=lod_far if lod_far is not None else spec.get('textureLODFar',44)
    if frame_presentation not in ('safe','legacy'):raise ValueError('FRAME_PRESENTATION: safe or legacy')
    if line_raster not in ('precise','hybrid') or (line_raster=='hybrid' and mode not in (1,2,5)):raise ValueError('LINE_RASTER: hybrid only for Q8 Modes1/2/5')
    if texture_lod not in ('off','gradual') or (texture_lod!='off' and mode!=7):raise ValueError('TEXTURE_LOD: Mode7 only')
    if texture_lod=='off' and lod_distances_explicit:raise ValueError('TEXTURE_LOD: distances require gradual LOD')
    if texture_lod!='off' and (type(lod_near) is not int or type(lod_far) is not int or not 1<lod_near<lod_far<256 or lod_far-lod_near!=16):raise ValueError('TEXTURE_LOD: integer 1<near<far<256, fade width16 required')
    texture_precision = texture_precision if texture_precision is not None else spec.get('texturePrecision','affine')
    if texture_precision not in ('affine','perspective'):raise ValueError('TEXTURE_PRECISION: affine or perspective required')
    if texture_precision=='perspective' and mode!=7:raise ValueError('TEXTURE_PERSPECTIVE_PROFILE: Mode 7 Q8 only')
    texture_quality=texture_quality if texture_quality is not None else spec.get('textureQuality','standard')
    if texture_quality not in ('standard','fast'):raise ValueError('TEXTURE_QUALITY: standard or fast required')
    if texture_quality=='fast' and (mode!=7 or texture_precision!='perspective' or spec.get('textureLighting')!='gouraud' or spec.get('textureCompositor','C')!='C'):
        raise ValueError('TEXTURE_FAST_PROFILE: requires Mode 7, Q8, perspective, Gouraud compositor C')
    if texture_lod!='off' and texture_precision!='perspective':
        raise ValueError('TEXTURE_LOD_PROFILE: Q8 perspective required')
    if precision!='q8' or music or motion:raise ValueError('Q8_INTERNAL: public adapter accepts only the silent Q8 profile')
    camera_mobile=camera_mobile or camera_auto
    if camera_mobile and precision!='q8':raise ValueError('Q8_CAMERA_REQUIRES_Q8')
    if camera_mobile and any(abs(n)>4095 for obj in spec['objects'] for n in obj['position']):raise ValueError('Q8_CAMERA_OBJECT_DOMAIN: +/-4095 WU')
    if precision=='q8':
        print(f'Q8 qualified profile: Mode {mode}, {len(spec["objects"])} object(s), {"mobile" if camera_mobile else "stationary"} walkLite; screen Q8 -> raster Q2.',flush=True)
        near='poly'
        if mode not in (1,2,3,4,5,6,7):raise ValueError('Q8_MODE_UNQUALIFIED: Mode 1..7 only in this family gate')
        if mode==7 and spec.get('textureLighting')=='gouraud' and spec.get('textureCompositor','C')!='C':raise ValueError('Q8_TEXTURE_COMPOSITOR: C only')
        if not 1<=len(spec['objects'])<=2:raise ValueError('Q8_OBJECT_BUDGET: one or two objects in this gate')
        if len(spec['objects'])>1 and motion:raise ValueError('Q8_MULTIOBJECT_SWEEP_UNQUALIFIED')
        if any(not 0<obj['scale']<=1 for obj in spec['objects']):raise ValueError('Q8_SCALE_DOMAIN: 0 < scale <= 1')
        if spec['camera']['rotation']!=[0,0,0]:raise ValueError('Q8_CAMERA_ROTATION_UNQUALIFIED')
        if spec['world']['grounds']:raise ValueError('Q8_GROUND_UNQUALIFIED')
    out.mkdir(parents=True,exist_ok=False);sdk=out/'sdk'
    shutil.copytree(SDK_ROOT,sdk,ignore=shutil.ignore_patterns('q8','__pycache__','*.pyc','3Dvibe64.asm','3Dvibe64.prg','3Dvibe64.cmd','3Dvibe64.log','build'))
    if texture_precision=='perspective' or 'texturePrecision' in spec:
        # Generate only the established affine intermediate geometry/materials.
        # Perspective interpolation is attached explicitly below, never ignored.
        intermediate=json.loads(json.dumps(spec))
        for key in ('texturePrecision','textureQuality','textureLOD','textureLODNear','textureLODFar'):intermediate.pop(key,None)
        for texture in intermediate.get('textures',[]):
            if 'source' in texture:texture['source']=str((scene.parent/texture['source']).resolve())
        scene=out/'intermediate-scene.json';scene.write_text(json.dumps(intermediate,indent=2))
    cmd=[shutil.which('pwsh'),'-NoProfile','-File',str(sdk/'work/build-3Dvibe64.ps1'),'-SceneFile',str(scene),'-GraphicsMode',str(mode),'-CameraMode','walkLite','-CameraViewport','normal','-VideoStandard',standard,'-Quality','fast','-Projection','extended-table','-MemoryLayout','high-basic-v2','-NoFpsOverlay','-SkipCmdUpdate','-NoCameraRuntimeControls','-ExplorerNearCrossMode',near]
    if mode==7:cmd[-1]='skip' # Mode 7 has its own camera-plane near profile.
    cmd+=['-FramePresentation',frame_presentation]
    if precision in ('q8','xq2-reference') and 3<=mode<=6:cmd+=['-ExperimentalSubpixelXProbe']
    if near=='poly' and mode!=7:cmd+=['-ExplorerClipMode','near']
    r=subprocess.run(cmd,cwd=sdk,capture_output=True,text=True,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'))
    (out/'build.log').write_text(r.stdout+r.stderr)
    if precision=='q8' and mode<=2:
        from wire_build import finish_wire
        return finish_wire(out,sdk,spec,cmd,r,music,motion,camera_mobile,camera_auto,memory_recovery,line_raster,frame_presentation)
    if r.returncode:raise RuntimeError(r.stdout+r.stderr)
    source=(sdk/'work/3Dvibe64.asm').read_text(encoding='utf-8-sig');lab=assemble(source,out,'base')
    info=dict(precision=precision,scene=spec,command=cmd,
              precisionContract=dict(default='legacy',q8OptIn=True,fullPrecisionClipping='bounded profile qualified',
                                     q8CameraRotation=False,internalFallback='none; nonzero camera angles set explicit fault',
                                     cameraTests='fractional translation only; controls disabled'))
    if precision=='q8':
        data=(out/'base.prg').read_bytes();load=data[0]+256*data[1]
        def byte(label,index=0):return data[lab[label]+index-load+2]
        def s8(n):return (n+128)%256-128
        vertices=[[s8(byte(axis+'coord',byte('vert_'+axis+'i',i))) for axis in 'xyz'] for i in range(lab['VERT_COUNT'])]
        from multiobject import metadata,adapt as multi_adapt
        object_ranges=metadata(lab,byte,vertices)
        radius=max(o['radiusWU'] for o in object_ranges)
        info.update(vertices=vertices,scaleQ6=byte('object_scale'),scaledRadiusWU=radius)
        info['objectRanges']=object_ranges
        parts=pieces(lab,music,motion)
        if mode<=2:
            from wire import prepare_wire,wire_pieces
            source=prepare_wire(source,music,motion,mode)
            parts=wire_pieces(parts,lab)
        elif mode==7:
            from texture import prepare_texture,texture_pieces
            source=prepare_texture(source,music,motion)
            parts=texture_pieces(parts,lab)
        else:source=prepare(source,music,motion,mode)
        if camera_mobile:
            from camera import adapt
            source,parts=adapt(source,parts,camera_auto)
            info['precisionContract'].update(q8CameraRotation=True,internalFallback='none; camera outside +/-4096 WU sets fault',cameraTests='mobile yaw/pitch, inherited walkLite input')
            info.update(cameraMobile=True,cameraAutomatic=camera_auto)
        if memory_recovery:
            from q8_memory import recover,compact_matrix
            source,info['q8MemoryRecovery']=recover(source,lab)
            parts=compact_matrix(parts)
        if lab['SCENE_OBJECT_COUNT']>1:
            parts=multi_adapt(parts)
            info['precisionContract']['multiobject']='two disjoint nonshared objects, Mode 1-7'
        if mode==5 and line_raster=='hybrid':
            from hybrid import apply as hybrid_apply
            source,parts=hybrid_apply(source,parts,mode)
        if texture_precision=='perspective':
            from perspective import adapt as perspective_adapt
            source,parts=perspective_adapt(source,parts)
            from perspective_exact import apply as exact_perspective
            source,parts=exact_perspective(source,parts)
            from perspective_uniform import apply as uniform_perspective
            source,parts,uniform=uniform_perspective(source,parts,lab,byte,force=texture_lod!='off')
            from perspective_uvzp import apply as paired_uv
            source,parts=paired_uv(source,parts,[0] if texture_quality=='fast' else uniform)
            info.update(texturePrecision='perspective',perspectiveDepthDomainWU=[1,256],
                        perspectiveFaultLabel='ps_fault',perspectiveSampling='exact-fixed-point-per-sample',
                        uniformTexturePigments=uniform)
            if texture_quality=='fast':
                from texture_fast import apply as fast_texture
                source,parts=fast_texture(source,parts)
                info.update(textureQuality='fast',perspectiveSampling='block8-exact-endpoints-affine-interior-exact-tail',
                            spatialReconstruction='even logical rows sampled; upper duplication in same VIC color cell',
                            palettePolicy='full per-face claim order including omitted rows',sceneSpecificLUT=False)
            if texture_lod!='off':
                from texture_lod import apply as lod_apply
                source,parts,lod_info=lod_apply(source,parts,lab,byte,lod_near,lod_far,texture_quality)
                info['textureLOD']=lod_info
        sizing_source=attach(source,parts)
        verify_retired_state_absent(sizing_source)
        sizing=assemble(sizing_source,out,'sizing')
        sizes={n:sizing[f'hp_block_{n}_end']-sizing[f'hp_block_{n}_begin'] for n in parts}
        placed,gaps,free=pack(sizes,sizing);source=attach(source,parts,placed)
        verify_retired_state_absent(source)
        info.update(blockSizes=sizes,allocation=placed,originalGaps=gaps,remainingGaps=free,music=music,demoLateralSweep=motion,
                    removedUnusedState=dict(labels=RETIRED_VERTEX_ARRAYS,bytes=14*lab['VERT_COUNT'],wholeProgramNoReferences=True))
    final=assemble(source,out,'3Dvibe64')
    shutil.copy2(out/'3Dvibe64.labels',out/'labels.txt');shutil.copy2(out/'3Dvibe64.map',out/'memory.map')
    if precision!='q8':assert sha(out/'3Dvibe64.prg')==sha(sdk/'work/3Dvibe64.prg')
    info.update(prgSHA256=sha(out/'3Dvibe64.prg'),bytes=(out/'3Dvibe64.prg').stat().st_size,framePresentation=frame_presentation,lineRaster=line_raster)
    (out/'build.json').write_text(json.dumps(info,indent=2));print(name,precision,info['prgSHA256'],flush=True)
    return out
def validate(spec,mode,standard,out):
    if out==SDK_ROOT or SDK_ROOT in out.parents:raise ValueError('Q8_OUTPUT: output must be outside the SDK')
    if out.exists():raise ValueError('Q8_OUTPUT: output directory already exists; choose a new directory')
    if mode not in range(1,8):raise ValueError('Q8_MODE: only 1-7')
    if standard not in ('pal','ntsc'):raise ValueError('Q8_STANDARD: pal or ntsc')
    if spec.get('graphicsMode',mode)!=mode:raise ValueError('Q8_MODE: scene graphicsMode differs from CLI')
    if spec.get('meshSourceSharing'):raise ValueError('Q8_SHARING: source sharing is not qualified')
    if spec.get('timeline'):raise ValueError('Q8_TIMELINE: scene timeline is not qualified')
    if spec.get('camera',{}).get('mode','walkLite')!='walkLite':raise ValueError('Q8_CAMERA: scene camera must use walkLite, not fixed or walkFull')
    if spec.get('contract',{}).get('viewportProfile','normal')!='normal':raise ValueError('Q8_VIEWPORT: normal only')
    if not isinstance(spec.get('objects'),list) or not 1<=len(spec['objects'])<=2:raise ValueError('Q8_OBJECT_BUDGET: one or two objects')
    if spec.get('world',{}).get('grounds'):raise ValueError('Q8_GROUND: no Ground in this profile')
    if spec.get('camera',{}).get('rotation')!=[0,0,0]:raise ValueError('Q8_CAMERA_ROTATION: initial rotation must be zero; runtime yaw/pitch is supported')
    for obj in spec['objects']:
        if not isinstance(obj.get('scale'),(int,float)) or not math.isfinite(obj['scale']) or not 0<obj['scale']<=1:raise ValueError('Q8_SCALE: finite 0 < scale <= 1 required')
    for pos in [spec['camera']['position']]+[o['position'] for o in spec['objects']]:
        if len(pos)!=3 or any(not isinstance(n,(int,float)) or not math.isfinite(n) or abs(n)>4095 for n in pos):raise ValueError('Q8_POSITION: three finite coordinates within +/-4095 WU required')

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);p.add_argument('--scene',type=Path,required=True)
    p.add_argument('--standard',choices=['pal','ntsc'],default='pal');p.add_argument('--mode',type=int,required=True)
    p.add_argument('--camera',choices=['stationary','interactive','auto'],default='stationary')
    p.add_argument('--texture-precision',choices=['affine','perspective'],default=None)
    p.add_argument('--texture-quality',choices=['standard','fast'],default=None)
    p.add_argument('--frame-presentation',choices=['safe','legacy'],default='safe');p.add_argument('--line-raster',choices=['precise','hybrid'],default='precise')
    p.add_argument('--texture-lod',choices=['off','gradual'],default=None);p.add_argument('--lod-near',type=int,default=None);p.add_argument('--lod-far',type=int,default=None);a=p.parse_args()
    try:build(a.out,a.scene,standard=a.standard,mode=a.mode,camera_mobile=a.camera!='stationary',camera_auto=a.camera=='auto',texture_precision=getattr(a,'texture_precision',None),texture_quality=a.texture_quality,frame_presentation=a.frame_presentation,line_raster=a.line_raster,texture_lod=a.texture_lod,lod_near=a.lod_near,lod_far=a.lod_far)
    except (ValueError,KeyError,TypeError) as e:raise SystemExit(f'Q8 validation/build refused: {e}')
