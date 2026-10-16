"""Two textured rooms with solid floor cubes, hard-normal Gouraud.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. Frozen SDKs/demos remain read-only.
"""
import importlib.util,json,math,re,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('room_common',ROOT/'src/room_common.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
frozen=room.RELEASE;devSDK=ROOT/'sdk';room.RELEASE=devSDK
room.ROOT=ROOT/'room';room.ROOT.mkdir(exist_ok=True)
original_verify=room.verify_release
def verify_frozen():
    room.RELEASE=frozen
    try:return original_verify()
    finally:room.RELEASE=devSDK
room.verify_release=verify_frozen
from viewport import adapt as viewport_adapter
room.viewport_adapter=viewport_adapter
from integer_fast import adapt as render_adapter
from block4 import adapt as block_adapter
from divtrim import adapt as division_adapter
from carrier4 import adapt as carrier_adapter
from ratiozero import adapt as ratio_adapter
from uvpair import adapt as pair_adapter
from memtrim import trim as memory_adapter
from divprefix import adapt as prefix_adapter
from predict4 import adapt as predict_adapter
from recipcache import adapt as reciprocal_adapter,recover_tables
from mul16 import adapt as multiply_adapter
from uvtrial import adapt as trial_adapter
from portalcull import adapt as portal_adapter,recover as portal_recover
portal_enabled='--portal' in sys.argv
if portal_enabled:sys.argv.remove('--portal')
if portal_enabled:
    # Only four absolute,X sin-table reads exist. No page-high pointer ABI.
    # Keep both table values and all legal memory windows/8-byte guards.
    # Allow their placement off a page boundary; charge page-crossing cycles.
    import block4
    original_pack=block4.pack
    block4.pack=lambda sizes,lab:original_pack(sizes,lab,align_tables=False)
uvtrial_kind='trial'
if '--uvtrial-kind' in sys.argv:
    index=sys.argv.index('--uvtrial-kind');uvtrial_kind=sys.argv[index+1];del sys.argv[index:index+2]
assert uvtrial_kind in ('baseline','trial','highfirst')
multiply_kind='shared'
if '--multiply-kind' in sys.argv:
    index=sys.argv.index('--multiply-kind');multiply_kind=sys.argv[index+1];del sys.argv[index:index+2]
assert multiply_kind in ('baseline','shared','fixed16')
reciprocal_kind='cache8'
if '--reciprocal-kind' in sys.argv:
    index=sys.argv.index('--reciprocal-kind');reciprocal_kind=sys.argv[index+1];del sys.argv[index:index+2]
assert reciprocal_kind in ('near','baseline','memory','cache2','cache4','cache8')
predict_kind='compact2'
if '--predict-kind' in sys.argv:
    index=sys.argv.index('--predict-kind');predict_kind=sys.argv[index+1];del sys.argv[index:index+2]
assert predict_kind in ('baseline','lowfast','threshold','compact','compact2')
prefix_enabled='--baseline-prefix' not in sys.argv
if '--baseline-prefix' in sys.argv:sys.argv.remove('--baseline-prefix')
memory_enabled='--baseline-memory' not in sys.argv
if '--baseline-memory' in sys.argv:sys.argv.remove('--baseline-memory')
pair_enabled='--memory-only' not in sys.argv
if '--memory-only' in sys.argv:sys.argv.remove('--memory-only')
if '--experimental-uvpair' in sys.argv:sys.argv.remove('--experimental-uvpair')
if '--baseline-uvpair' in sys.argv:sys.argv.remove('--baseline-uvpair')
ratio_enabled='--baseline-ratio' not in sys.argv
if '--baseline-ratio' in sys.argv:sys.argv.remove('--baseline-ratio')
carrier_enabled='--baseline-carriers' not in sys.argv
if '--baseline-carriers' in sys.argv:sys.argv.remove('--baseline-carriers')
division_enabled='--baseline-divider' not in sys.argv
if '--baseline-divider' in sys.argv:sys.argv.remove('--baseline-divider')
block_enabled='--exact' not in sys.argv
if '--exact' in sys.argv:sys.argv.remove('--exact')
integer_geometry=False # Keep the user-selected Q8 geometry.
uniform_fast='--no-uniform' not in sys.argv
for flag in ('--q8','--no-uniform'):
    if flag in sys.argv:sys.argv.remove(flag)
def adapt_scene(source,parts,placed):
    source,parts=render_adapter(source,parts,placed,False,uniform_fast)
    assert uniform_fast,'This scene requires the constant-texel fill specialization'
    # Texture2 is never fetched by this scene's uniform kernel. Keep the id
    # and pointer-table ABI, but not its unused 256-byte copy of constant2.
    pat=r'(?m)^m7_texture_2:\n(?: \.byte[^\n]*\n)+'
    block=re.search(pat,source);assert block
    values=[int(v) for v in re.findall(r'\d+',block[0].split(':',1)[1])]
    assert values==[2]*256
    source=source[:block.start()]+'m7_texture_2 = m7_texture_0 ; no fetch: uniform texel2 path\n'+source[block.end():]
    if placed is None:
        # These two residual caches are write-only in this Mode7 full-Q8 path.
        # Near/screen clipping uses tq_cache_* full coordinates, not residues.
        for label in ('hq_sx_fraction','hq_sy_fraction'):
            for key in list(parts):
                parts[key]=re.sub(r'(?m)^ sta '+label+r',[xy]\n','',parts[key])
            parts['data']=once_decl(parts['data'],label+': .fill VERT_COUNT,0\n')
            code='\n'.join(l.split(';',1)[0] for l in (source+'\n'+'\n'.join(parts.values())).splitlines())
            assert not re.search(r'\b'+label+r'\b',code)
        # Remove only declarations with no consumer anywhere in generated code.
        whole='\n'.join(l.split(';',1)[0] for l in (source+'\n'+'\n'.join(parts.values())).splitlines())
        for m in list(re.finditer(r'(?m)^(\w+): (?:\.word 0|\.byte 0|\.fill [^\n]+)\n',parts['data'])):
            if len(re.findall(r'\b'+m[1]+r'\b',whole))==1:
                parts['data']=parts['data'].replace(m[0],'')
        # Same legal RAM gaps and per-block guard, fewer adjacent placement units.
        for dest,old in [('data','perspective_state'),('core','vertices'),
                         ('camera_yaw','camera_demo'),('perspective_sample','iu_uniform'),
                         ('perspective_encode','demo_route_tables'),('perspective_span','texture_helpers'),
                         ('screen_precision','winding')]:
            parts[dest]+=parts.pop(old)
    if block_enabled:source,parts=block_adapter(source,parts,placed)
    if division_enabled:source,parts=division_adapter(source,parts,placed)
    if carrier_enabled:
        assert block_enabled and division_enabled,'Carrier batching qualified only with the latest block4/divtrim demo'
        source,parts=carrier_adapter(source,parts,placed)
    if ratio_enabled:source,parts=ratio_adapter(source,parts,placed)
    if pair_enabled:source,parts=pair_adapter(source,parts,placed)
    if prefix_enabled:source,parts=prefix_adapter(source,parts,placed)
    if predict_kind!='baseline':source,parts=predict_adapter(source,parts,placed,predict_kind)
    source,parts=reciprocal_adapter(source,parts,placed,reciprocal_kind)
    source,parts=multiply_adapter(source,parts,placed,multiply_kind)
    assert uvtrial_kind=='baseline' or pair_enabled,'UV trial requires the paired sampler'
    source,parts=trial_adapter(source,parts,placed,uvtrial_kind)
    source,parts=portal_adapter(source,parts,placed,portal_enabled)
    return source,parts
def once_decl(text,declaration):
    assert text.count(declaration)==1,declaration
    return text.replace(declaration,'')
room.render_adapter=adapt_scene
def post_attach(source):
    source=memory_adapter(source,{})[0] if memory_enabled else source
    source=recover_tables(source) if reciprocal_kind!='baseline' else source
    return portal_recover(source) if portal_enabled else source
room.post_attach_adapter=post_attach

def textures():
    # 16x16, three pigment codes. Brick period 12 WU: one brick 6x3 WU.
    wall=[1 if y%4==0 or (x+(4 if y//4&1 else 0))%8==0 else
          (3 if y%4==1 and (x+(4 if y//4&1 else 0))%8 in (2,3,4) else 2)
          for y in range(16) for x in range(16)]
    # Same tile pixels; two-room scene UVs now give 9-WU squares.
    floor=[1 if x==0 or y==0 else
           (3 if (x,y) in ((2,2),(3,2),(2,3),(13,13)) else 2)
           for y in range(16) for x in range(16)]
    return [dict(id=key,width=16,height=16,repeat=[8,8],texels=pixels)
            for key,pixels in [('stone',wall),('stone-floor',floor),('plain-ceiling',[2]*256)]]

def make_scene():
    m=room.Mesh('room',[0,0,0])
    for h0,h1 in ((-24,0),(0,24)):
        for x,n in ((-24,[1,0,0]),(24,[-1,0,0])):
            m.quad([(x,h0,-10),(x,h1,-10),(x,h1,18),(x,h0,18)],n)
        for y,n in ((-24,[0,1,0]),(24,[0,-1,0])):
            m.quad([(h0,y,-10),(h1,y,-10),(h1,y,18),(h0,y,18)],n)
    for z,n,t in ((-10,[0,0,1],'stone-floor'),(18,[0,0,-1],'plain-ceiling')):
        c=[(-24,-24,z),(24,-24,z),(24,24,z),(-24,24,z)]
        for i in range(4):m.quad([c[i],c[(i+1)%4],(0,0,z)],n,t)
    for face,uv,t in zip(m.faces,m.uv,m.tex):
        pts=[m.vertices[i] for i in face] # mesh X,up,forward
        if t=='stone':
            axis=2 if all(p[0]==pts[0][0] for p in pts) else 0
            for p,pair in zip(pts,uv):
                pair[:]=[round((p[axis]+24)/6*16)/16,round((p[1]+10)/6*16)/16]
        elif t=='stone-floor':
            for p,pair in zip(pts,uv):
                # Whole-room phase, not a per-triangle reset. Places a grout
                # line in the small floor portion visible at the initial pose.
                pair[:]=[round((p[0]+39)/9*16)/16,round((p[2]+39)/9*16)/16]
    mesh=m.scene();mesh['gouraud']={'creaseAngle':0};mesh['materialProfile']='multimaterial'
    # Explicit triangles keep face material identity unambiguous. Retain the
    # same 0->2 split; the floor/ceiling fans are already triangles.
    fs=[];uvs=[];ts=[];mats=[]
    for f,uv,t in zip(m.faces,m.uv,m.tex):
        for ids in (((0,1,2),(0,2,3)) if len(f)==4 else ((0,1,2),)):
            fs.append([f[j] for j in ids]);uvs.append([uv[j] for j in ids]);ts.append(t)
            mats.append('brown' if t=='stone' else 'gray')
    mesh.update(faces=fs,faceUV=uvs,faceTextures=ts,faceMaterials=mats)
    old=ROOT.parent/'3Dvibe64_demo_room-mode7-gouraud_64MHz/scenes/large-room.json'
    doc=json.loads(old.read_text());doc.update(name='room-stone-floor-gouraud-hard-q8',
        texturePrecision='perspective',textureLighting='gouraud',textureCompositor='C',
        textures=textures(),meshes=[mesh])
    doc.pop('texturePalette',None)
    doc['lights'][0]['position']=[-12,-8,12]
    path=room.ROOT/'scenes/large-room.json';path.write_text(json.dumps(doc,indent=2))
    return path,dict(vertices=len(m.vertices),triangles=len(fs),wallBrickWU=[6,3],floorTileWU=[18,18],creaseAngle=0)
import two_rooms
room.make_scene=lambda:two_rooms.create(room,textures,ROOT)
original_trajectory=room.trajectory
room.trajectory=lambda:two_rooms.trajectory(room,original_trajectory)

def bake(source):
    # Keep the previously demonstrated static point-light bake and native
    # runtime Gouraud UV/Q clipping/interpolation/compositor. Only scene color
    # ramps and light intensity are specialized, not renderer algorithms.
    source=two_rooms.bake(room,source)
    # Demo's dynamic Q8 yaw/pitch rotates hc_cam_* and raw vertex caches, not
    # the legacy Q6 face-normal matrix. That early original-facing test mixes
    # coordinate spaces on near-crossing faces. The common Q8 loader already
    # clips the whole polygon and checks its exact projected winding; keep
    # that authoritative test, and bypass ONLY the incompatible early test.
    old=' beq lfv_camera_plane_facing_done\n jsr camera_plane_original_facing\n'
    assert source.count(old)==1,'Legacy original-facing call contract changed'
    source=source.replace(old,' beq lfv_camera_plane_facing_done\n sec ; demo Q8: facing checked after clipping\n nop\n nop\n')
    # Scene-only convex-cell painter order, valid for these two convex rooms
    # separated by y=24 and one convex cube wholly inside each room. Draw the
    # far room shell/cube before the near shell/cube. The near partition masks
    # the remote cube outside the opening. Inside each convex room, its shell
    # cannot occlude an interior cube from a camera inside that room.
    # Representative-depth sorting of large wall/ceiling triangles is not a
    # Z-buffer and was overwriting cube interiors. No geometry or UV changed.
    scene=json.loads((room.ROOT/'scenes/large-room.json').read_text())
    groups=[];reveals=[];base=0
    for obj,mesh in zip(scene['objects'],scene['meshes']):
        ids=[base+i for i,(face,t) in enumerate(zip(mesh['faces'],mesh['faceTextures']))
             if t=='plain-ceiling' and all(mesh['vertices'][v][1]<0 for v in face)]
        assert ids==list(range(ids[0],base+len(mesh['faces'])));groups.append((base,ids[0]))
        for fi,face in enumerate(mesh['faces']):
            ys=[mesh['vertices'][v][2]+obj['position'][1] for v in face]
            if min(ys)==23 and max(ys)==25:reveals.append(base+fi)
        base+=len(mesh['faces'])
    assert len(groups)==2
    (a,b),(c,d)=groups
    assert reveals==list(range(reveals[0],reveals[-1]+1))
    patch=f'''bvf_depth_ready:
 ; Draw connector after both shells, before near-room cubes.
 lda faceidx
 cmp #{reveals[0]}
 bcc demo_regular_room_depth
 cmp #{reveals[-1]+1}
 bcs demo_regular_room_depth
 lda #75
 jmp demo_store_face_depth
demo_regular_room_depth:
 ; Y=24 is world forward, held in explorer_cam_z (Q8).
 lda explorer_cam_z_ext
 bmi demo_camera_room0
 lda explorer_cam_z_hi
 cmp #24
 bcc demo_camera_room0
 lda faceidx
 cmp #{c}
 bcc demo_far_room0
 cmp #{d}
 bcc demo_near_shell
 bcs demo_near_cube
demo_far_room0:
 cmp #{b}
 bcc demo_far_shell
 bcs demo_far_cube
demo_camera_room0:
 lda faceidx
 cmp #{c}
 bcs demo_far_room1
 cmp #{b}
 bcc demo_near_shell
 bcs demo_near_cube
demo_far_room1:
 cmp #{d}
 bcc demo_far_shell
demo_far_cube:
 lda #150
 bne demo_store_face_depth
demo_far_shell:
 lda #200
 bne demo_store_face_depth
demo_near_shell:
 lda #100
 bne demo_store_face_depth
demo_near_cube:
 lda #50
demo_store_face_depth:
 sta p1lo
'''
    assert source.count('bvf_depth_ready:\n')==1
    source=source.replace('bvf_depth_ready:\n',patch)
    for name in ('material_screen_bytes','material_color_bytes'):
        pat=r'(?m)^'+name+r':\n(?: \.byte[^\n]*\n)+'
        block=re.search(pat,source);assert block,name
        values=[int(x[1:],16) if x.startswith('$') else int(x)
                for x in re.findall(r'\$[0-9a-fA-F]+|(?<![A-Za-z_])\d+',block[0].split(':',1)[1])]
        assert len(values)==40,(name,len(values))
        for reflect in range(4):
            if name=='material_screen_bytes':
                values[reflect*10]=0xBC # gray: Dark11 High12
                values[reflect*10+9]=0x9C # wall: Dark9 High12
            else:
                values[reflect*10]=15;values[reflect*10+9]=15 # shared Highlight
        source=source[:block.start()]+name+':\n .byte '+','.join(map(str,values))+'\n'+source[block.end():]
    return source
room.bake_static_light=bake

if __name__=='__main__':
    # User removed music from this demo. Default build is now silent too.
    if '--silent' not in sys.argv:sys.argv.append('--silent')
    room.main()
    name=sys.argv[sys.argv.index('--name')+1] if '--name' in sys.argv else 'room-pal-final'
    out=room.ROOT/'build'/name
    for path in (out/'build.json',room.ROOT/'reports'/f'{name}-build.json'):
        info=json.loads(path.read_text());info.update(engineModified=False,developmentSDK=str(devSDK),originalTextures=False,
            lighting='gouraud',compositor='C',creaseAngle=0,staticVertexLighting=True,
            texturePrecision='perspective',floorTexture='stone-floor',wallBrickWU=[6,3],floorTileWU=[9,9],
            palettes={'wall':[9,12,15],'floor':[11,12,15]},
            precision='integer-geometry/perspective-uv' if integer_geometry else 'q8',
            generatorProfile='q8-derived-demo-only',
            geometryPrecision='integer' if integer_geometry else 'q8',
            uniformFastPath=uniform_fast,
            perspectiveBlockPixels=4 if block_enabled else 1,
            exactDivisionLeadingZeroTrim=division_enabled,
            exactPerspectiveCarrierBatch=4 if carrier_enabled else 1,
            exactClippingZeroDeltaShortcut=ratio_enabled,
            exactPairedUV=pair_enabled,
            exactPairedUVAlgorithm=uvtrial_kind,
            exactDivisionRemainderPrefix=prefix_enabled,
            exactFourPixelCorrection=predict_kind,
            exactDepthReciprocalReuse=reciprocal_kind,
            exactClippingProductSpecialization=multiply_kind,
            demoUnreferencedCullRecovery=memory_enabled,
            experimentalTextureApproximation=block_enabled,
            textureSamplingContract='exact four-pixel endpoints; affine interior UV; NOT framebuffer bit-exact' if block_enabled else 'exact per-pixel perspective UV',
            demoCodeGrowthGuardBytes=8 if block_enabled else 32,
            sampler='perspective textured surfaces; dedicated constant-texel Gouraud for cubes and ceiling' if uniform_fast else 'original shaded perspective',
            music=False,demoFocal=59.5,
            conservativePortalSelection=portal_enabled,
            portalScope='automatic two-convex-room trajectory only; horizontal bounds; complete triangle rejection; near/connector fallback' if portal_enabled else 'disabled',
            demoOnlySpecialization='two static rooms, host-baked vertex light, uniform floor cubes, native Gouraud UV/Q fill',
            demoCamera=dict(keyframes=32,ticksPerKey=64,periodTicks=2048,walkingBob=True),
            cameraTicks=2048,rooms=2,cubes=two_rooms.CUBES,
            openingThicknessWU=2,openingSlabY=[23,25],
            demoViewport=dict(logical=[112,70],physical=[224,140],originLogical=[24,15],
                              originPhysical=[48,30],areaFraction=0.49,focalQ8=15232),
            publicProfileExtension='Demo-only centered half-area viewport, focal59.5, static vertex light and per-face palettes; silent')
        path.write_text(json.dumps(info,indent=2))
