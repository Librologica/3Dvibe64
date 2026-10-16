"""Private, reproducible fullscreen three-room Q8 demo. No frozen trees edited.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0.
"""
import hashlib, json, os, re, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT/'src'))
import three_rooms as scene_builder
import optimizations as op
import span_shader, evenedges, texture_lod_gradual, cube_tour, cube_runtime
import unlit_rooms
import flat_cubes_ceiling
import q8_exact
import dev_block_state
import viewport, human_tour, game_ui, precise_pixels
import billboard_room
billboard_room.ENABLED='--without-billboard' not in sys.argv
if not billboard_room.ENABLED:sys.argv.remove('--without-billboard')
billboard_room.configure_tour(human_tour)
with_interface=False
if '--without-interface' in sys.argv:sys.argv.remove('--without-interface')
game_ui.ENABLED=with_interface
q8_option='combined'
artifact_tag=''
if '--artifact-tag' in sys.argv:
    index=sys.argv.index('--artifact-tag');artifact_tag=sys.argv[index+1];del sys.argv[index:index+2]
    assert re.fullmatch('[a-z0-9-]+',artifact_tag)
if '--q8-opt' in sys.argv:
    index=sys.argv.index('--q8-opt');q8_option=sys.argv[index+1];del sys.argv[index:index+2]
assert q8_option in q8_exact.OPTIONS
room = scene_builder.room
scene_builder.previous.frozen=ROOT/'sdk'
if not (scene_builder.previous.frozen/'MANIFEST.sha256').is_file():
    room.verify_release=lambda:dict(externalFrozenReleaseCheck='unavailable',privateSourcesOnly=True)
room.dynamic_objects = False
block_enabled = True  # select the private five-window allocator in room.main
room.viewport_adapter = viewport.adapt
name = sys.argv[sys.argv.index('--name')+1] if '--name' in sys.argv else 'game-pal-final'
fast = '--precise' not in sys.argv
no_lod = False
if no_lod:
    if '--full-noLOD' in sys.argv:sys.argv.remove('--full-noLOD')
    fast = False
if '--precise' in sys.argv: sys.argv.remove('--precise')
standard = 'ntsc' if '--ntsc' in sys.argv else 'pal'
if '--ntsc' in sys.argv: sys.argv.remove('--ntsc')
if '--silent' not in sys.argv: sys.argv.append('--silent')  # this demo never embeds music

original_create = scene_builder.create
def create():
    path, stats = original_create()
    doc = json.loads(path.read_text())
    # Replace only the central object; keep all room geometry and materials.
    cube=cube_runtime.make()
    doc['meshes'][-1]=cube
    doc['objects'][-1].update(id='floating-cube',mesh='central-cube',position=[0,160,4],
                             rotation=[64,8,16],angularVelocity=[0.45,0.65,0.35],scale=1,
                             material='gray',reflectivity='satin')
    doc['name']='three-rooms-flat-cubes-far-lod-ceiling-straight-corridor-q8'
    # Existing verified geometry/layout capability token; lighting has its
    # own explicit contract below and must not disable private relocation.
    doc['privateExperiment']='corridor-flatcube'
    doc['privateRenderContract']={'roomTextureLighting':'none','cubeLighting':'flat (all three cubes)',
        'ceiling':'fixed gray motif, original material','textureLOD':not no_lod,'smoothShading':False,
        'generatorABI':'Gouraud-shaped constant neutral Q scaffolding only; illumination shader bypassed'}
    stats={k:v for k,v in stats.items() if not k.startswith('torus')}
    stats.update(cubeVertices=len(cube['vertices']),cubeTriangles=len(cube['faces']),
                 cubeCenter=[0,160,4],cubeRenderMode=4,cubeSmooth=False,cubeMaterial='gray',
                 corridor=dict(startForward=71,endForward=137,lengthWU=66,widthWU=14),
                 vertices=sum(len(m['vertices']) for m in doc['meshes']),
                 triangles=sum(len(m['faces']) for m in doc['meshes']))
    assert stats['vertices']<=127 and stats['triangles']<255,stats
    path.write_text(json.dumps(doc,indent=2))
    (ROOT/'reports/scene.json').write_text(json.dumps(stats,indent=2))
    return path,stats
room.make_scene=billboard_room.scene(create)
room.trajectory=lambda:human_tour.trajectory(room)

original_bake=scene_builder.bake
def bake(source):
    source=original_bake(source)
    return unlit_rooms.bake(cube_runtime.bake(source))
room.bake_static_light=bake

def remove_fixed_placement(body):
    """Helpers inherit the checked Q8 allocator, never their old hard addresses."""
    body=re.sub(r'(?m)^\s*\.cerror .*$', '', body)
    return re.sub(r'(?m)^\*\s*=\s*\$[0-9a-fA-F]+\s*$', '', body)

def split_helpers(source, parts, transform):
    keys=list(parts)
    joined=source+''.join(f'\n; SP_PART_{key}\n'+parts[key] for key in keys)+'\n; SP_PART_END\n'
    joined=transform(joined)
    base=joined.split('\n; SP_PART_'+keys[0]+'\n',1)[0]
    for i,key in enumerate(keys):
        end='END' if i==len(keys)-1 else keys[i+1]
        parts[key]=joined.split(f'\n; SP_PART_{key}\n',1)[1].split(f'\n; SP_PART_{end}\n',1)[0]
    tail=joined.split('\n; SP_PART_END\n',1)[1]
    for i,block in enumerate(re.split(r'(?m)^\*\s*=\s*\$[0-9a-fA-F]+\s*\n',tail)):
        block=remove_fixed_placement(block)
        if block.strip():parts[f'sp_helper_{i}']=block
    return base,parts

def reconstruct():
    # Identical source and destination palette cell for every even/odd pair.
    # Upper logical sample covers physical rows 4k,4k+1; duplicate into +2,+3.
    code='''sp_render_and_fill:
 jsr draw_depth_buckets
 lda #0
 sta sp_gap
sp_gap_loop:
 ldx sp_gap
 lda sp_above_lo,x
 sta ptr0lo
 lda sp_above_hi,x
 sta ptr0hi
 lda drawbuf
 beq sp_a
 lda ptr0hi
 eor #$40
 sta ptr0hi
sp_a:
 lda ptr0lo
 clc
 adc #2
 sta row0lo
 adc #1
 sta row1lo
 lda ptr0hi
 sta row0hi
 sta row1hi
 ldy #0
sp_byte:
 lda (ptr0lo),y
 sta (row0lo),y
 sta (row1lo),y
 tya
 clc
 adc #8
 tay
 bcc sp_byte
 inc ptr0hi
 inc row0hi
 inc row1hi
 ldy #0
sp_second_page:
 lda (ptr0lo),y
 sta (row0lo),y
 sta (row1lo),y
 tya
 clc
 adc #8
 tay
 cpy #64
 bne sp_second_page
 inc sp_gap
 lda sp_gap
 cmp #50
 bne sp_gap_loop
 rts
sp_gap: .byte 0
'''
    addresses=[0x6000+(r//4)*320+(r%4)*2 for r in range(0,100,2)]
    for shift,suffix in ((0,'lo'),(8,'hi')):
        code+='sp_above_'+suffix+': .byte '+','.join(str((a>>shift)&255) for a in addresses)+'\n'
    return code

original_adapt=scene_builder.adapt
def adapt(source,parts,placed):
    global prepared_source
    source,parts=original_adapt(source,parts,placed)
    if placed is not None:return prepared_source,parts
    source,parts=game_ui.attach(source,parts)
    doc=json.loads((room.ROOT/'scenes/large-room.json').read_text())
    # All current generic optimizations; no old hardcoded two-room portal/PVS.
    flags=['carrier4','uvsetup','outcodes','defer','uniform','rows','backface','copies']
    if fast:flags+=['block8']
    def transform(code):
        # Retired Q6 coordinate-term tables have no instruction consumers.
        names=('x_m00','x_m10','x_m20','y_m01','y_m11','y_m21','z_m02','z_m12','z_m22')
        executable='\n'.join(l.split(';',1)[0] for l in code.splitlines() if not re.match(r'^\w+\s*=',l))
        assert all(not re.search(r'\b'+n+r'\b',executable) for n in names)
        code=op.once(code,'leftb = z_m22 + ZCOORD_COUNT','leftb = projdone + VERT_COUNT')
        # Mode7 exits the bucket drawer through its Gouraud path BEFORE the
        # legacy flat-cache read. Hidden/flat updates are compiled out. Keep a
        # valid immutable alias for the unreachable legacy drawer, no buffer.
        code=op.once(code,'frame_face_shade = RUNTIME_AFTER_FACE_PREPARE','frame_face_shade = face_shade')
        code=op.once(code,'RUNTIME_AFTER_FACE_SHADE = frame_face_shade + FACE_COUNT','RUNTIME_AFTER_FACE_SHADE = RUNTIME_AFTER_FACE_PREPARE')
        code+='\n .cerror HIDDEN_WIRE_ENABLE != 0 || FLAT_DYNAMIC_SHADE != 0 || FRAME_FACE_FILL_CACHE != 0 || FULL_DYNAMIC_SHADE != 0,"Static Mode7 legacy shade-cache proof invalid"\n'
        ref=(ROOT/'assets/optimized-two-rooms-reference.asm').read_text()
        assert hashlib.sha256((ROOT/'assets/optimized-two-rooms-reference.asm').read_bytes()).hexdigest().upper()=='CAAD7A8E2E5D375B2EBE2D1ACD29DF275B93D2641901456029026281DCC846D5'
        code=op.once(code,'m7_full_byte:\n jsr m7_sample\n','m7_full_byte:\n jmp fx_full_byte\nfx_old_after_first:\n')
        code=op.once(code,'tq_setup_channel:\n','tq_setup_channel:\n jmp es_setup_channel\n')
        code=op.once(code,'up_pair:\n','up_pair:\n jmp uz_pair\n')
        a=code.index('up_pair:\n jmp uz_pair\n')+len('up_pair:\n jmp uz_pair\n')
        b=code.index('up_fallback:\n',a)
        retired=code[a:b]
        labels=re.findall(r'(?m)^(\w+):',retired)
        rest=code[:a]+code[b:]
        executable='\n'.join(l.split(';',1)[0] for l in rest.splitlines())
        assert all(not re.search(r'\b'+label+r'\b',executable) for label in labels),'Live superseded paired-divider entry'
        code=rest
        fx=ref[ref.index('fx_full_byte:\n'):ref.index('lab_all_end:\n')]
        uz=ref[ref.index('uz_begin:\n'):ref.index('uz_all_end:\n')]
        if fast:
            code=evenedges.hook(code)
            # Gouraud's ordered dither is anchored to the ACTUAL sampled rows.
            # Keeping y&3 on even rows visits only Bayer rows0/2 and degenerates
            # into vertical stripes on this large untextured smooth surface.
            row=' lda yrow\n and #3\n asl\n asl\n sta m2_bayer_row\n'
            assert code.count(row)==2,('Mode7 Bayer row ABI',code.count(row))
            code=code.replace(row,row.replace(' and #3\n',' lsr\n and #3\n'))
            code=op.once(code,'gfb_row:\n lda leftb,x\n','gfb_row:\n jmp sp_filter_row\n')
            code=op.once(code,' bne resp_loop\n jsr draw_depth_buckets\n',' bne resp_loop\n jsr sp_render_and_fill\n')
        code=span_shader.hooks(code,op.once)+span_shader.helper()+'\n*=$4000\n'+fx+'\n*=$4000\n'+uz
        code=op.apply(code,flags,doc)
        code=texture_lod_gradual.apply(code,doc,dict(fadeNear=14,fadeFar=22,
            sampleRowStep=2 if fast else 1,relocatable=True,
            texturePalettes={'stone':[9,12,15],'stone-floor':[11,12,15]}))
        if no_lod:
            code=op.once(code,'lg_select:\n','''lg_select:
 stx lg_texture
 lda #16
 jsr lg_set_weight
 lda op_texture_constant,x
 rts
lg_lod_select_disabled:
''')
        code=cube_runtime.hooks(code)
        code=unlit_rooms.hooks(code)
        code=flat_cubes_ceiling.hooks(code,doc)
        if fast:
            # Same skipped-row palette requests as the qualified two-room fast.
            import importlib.util
            # Filter is kept here rather than importing a frozen demo builder.
            code+='''*=$f260
sp_filter_row:
 txa
 and #1
 bne sp_skipped_palette
 lda leftb,x
 jmp gfb_row+3
sp_skipped_palette:
 lda leftb,x
 sta leftval
 lda rightb,x
 sta rightval
 cmp leftval
 bcc sp_empty
 bne sp_nonempty
 lda tq_closed,x
 beq sp_empty
sp_nonempty:
 stx yrow
 ldx leftval
 lda xbyte,x
 sta startbyte
 ldx rightval
 lda xbyte,x
 sta endbyte
 lda drawbuf
 bne sp_palette_b
 jsr apply_material_span_a
 jmp gfb_next_restore
sp_palette_b:
 jsr apply_material_span_b
 jmp gfb_next_restore
sp_empty:
 jmp gfb_next
'''+reconstruct()+evenedges.kernel()
        code,optimization_info=q8_exact.projection(code,q8_option)
        # Retain the stable1.10.2 batching contract. The dev-only alias
        # transform is not qualified for this frozen SDK.
        if not fast:code=precise_pixels.apply(code, texture_lod=not no_lod)
        return code
    prepared_source,parts=split_helpers(source,parts,transform)
    prepared_source,parts=billboard_room.adapt(prepared_source,parts)
    return prepared_source,parts
room.render_adapter=adapt
original_post=room.post_attach_adapter
def post(source):
    source=original_post(source)
    a=source.index('camera_plane_add_dot:\n');b=source.index('\n.if MEMORY_LAYOUT_HIGH_BASIC_V2 = 0\ncamera_plane_cull_code_end',a)
    body=source[a:b]; names=re.findall(r'(?m)^(\w+):',body)
    outside=source[:a]+source[b:]
    executable='\n'.join(l.split(';',1)[0] for l in outside.splitlines())
    for label in names:assert not re.search(r'\b'+label+r'\b',executable),label
    return billboard_room.post(outside)
room.post_attach_adapter=post

if __name__=='__main__':
    # Standard is selected in the local generator invocation, never by editing
    # the frozen renderer or by relabeling PAL bytes as an NTSC build.
    room.main()
    from package_prg import package
    out=room.ROOT/'build'/name
    quality='fast' if fast else 'precise'
    target=ROOT/'artifacts'/f'dungeon-billboard-{quality}-LOD-{standard}.prg'
    if artifact_tag:target=target.with_name(target.stem+'-'+artifact_tag+target.suffix)
    package(out,target)
    info=json.loads((out/'build.json').read_text())
    info.update(rooms=3,cubeCenter=[0,160,4],cubeRenderMode=4,cubeSmooth=False,cubeMaterial='gray',corridorLengthWU=66,music=False,
                viewportLogical=[160,100],viewportPhysical=[320,200],viewportOriginPhysical=[0,0],bitmapInterface=False,
                renderedRows=50 if fast else 100,reconstruction='upper-row duplicate' if fast else 'none',
                perspectiveBlock=8 if fast else 1,textureLOD={'fadeNear':14,'fadeFar':22,'far':'modal pigment + vivid accent'},
                optimizations='property-derived static room faces and generic optimized shader; central Q8 rotation',
                distributionPRG=str(target.relative_to(ROOT)),cameraTicks=human_tour.PERIOD,
                demoCamera=dict(keyframes=human_tour.KEYS,ticksPerKey=64,periodTicks=human_tour.PERIOD,walkingBob=True),
                publicProfileExtension='Private silent four-object fullscreen demo; rotating Q8 gray cube, native flat solid fill',
                cubeLighting='runtime rotated plane normals, viewer-relative raised light; three constant gray levels, no texture or Gouraud',
                demoOnlySpecialization='static identity rooms; central sequential Q8 Euler transform, dynamic flat plane light',
                geometricLOD=None)
    info['roomTextureLighting']='none'
    info['postReleaseQ8']=dict(option=q8_option,source='qualified CP2 shift8/narrow16',
        exact=True,newStateBytes=0,newTablesBytes=0,officialEngineModified=False)
    info['occlusion']='five checked convex cells, including both corridors; signed24 camera; bounded central cube depth band'
    if no_lod:info['textureLOD']=False
    info['gouraudShading']=False
    info['smoothShading']=False
    info['allCubesFlat']=True
    info['ceiling']='shared lg_far_sample: gray base 75%, light-gray accent 25%'
    info['demoCamera'].update(style='asymmetric human-like exploration, independent gaze, inspections and unequal speeds',corridor='within x +/-4.5 WU; outward and return headings, different room paths')
    info['publicProfileExtension']='Private silent bitmap adventure simulation: precise Mode7 window, unlit rooms and original flat cubes'
    info['demoOnlySpecialization']='Constant neutral Q edge/clipping ABI; illumination compositor and Q advancement bypassed'
    info['rcSDK']={'version':(ROOT/'sdk/VERSION').read_text(encoding='utf-8').strip(),
        'builderSHA256':hashlib.sha256((ROOT/'sdk/work/build-3Dvibe64.ps1').read_bytes()).hexdigest().upper(),
        'manifestSHA256':hashlib.sha256((ROOT/'sdk/MANIFEST.sha256').read_bytes()).hexdigest().upper(),
        'presentation':'safe; wait after raster252',
        'privateAdapter':'private/q8; qualified four-object specialization, not public Q8 extension'}
    assert info['rcSDK']['version']=='1.10.2'
    assert info['rcSDK']['manifestSHA256']=='FB52FCC7529FC8E7F8C4E07D437E876B993743428ADDD7EA72AE1C58C2D51653'
    assert info['rcSDK']['builderSHA256']=='79510B085B6B786A87F2F2814B2BED0FE2C95313EDAF0A3C121B89EA02C9C14F'
    info['engineRelease']=dict(version='1.10.2',qualifiedLocalCommit='c2e13b5db3bbcbfae56723ce4211a0e376cab913',publishedCommit='e4f28abf8c01762c26b0537c45b5902e6ecce160',sourceZIP_SHA256='CE8F2026288D58C478CC0FC4F509BB5959C4541F4186C05FA363E738F3AE59B9',SDK=info['rcSDK'])
    info['runtimeProfile']=dict(version='1.10.2',runtimeSDK=info['rcSDK'],
        strategy='stable eight-pixel perspective blocks; even-row sampling and reconstruction' if fast else 'exact perspective at every pixel',
        affineBlocks=fast,skippedRows=fast,textureLOD=not no_lod,fastOptimizationActive=fast,engineExperiments='none')
    info['billboard']=dict(enabled=billboard_room.ENABLED,room=1,position=[4,0,-3],worldSize=[6,14],
        sourceSize=[16,32],frames=6,transparentIndex=0,mask='binary, zero skips destination write',
        palette='existing brown9,gray12,light-gray15; screen/ColorRAM unchanged',
        cameraFacing='spherical screen-aligned plane; native Q8 anchor and corner projection',
        nearWU=8,maxDepthWU=255,walkAmplitudeWU=.75,walkPeriodTicks=256,
        animation='4 walk frames, 2 raised-hand alert frames; every8 simulation ticks',
        reaction='world XZ trigger box +/-12 WU around animated anchor',
        RAM='512-byte resident frame; 3072-byte immutable bank under I/O; frame-pointer decode')
    info['geometricLOD']=None
    info['demoCamera'].update(firstRoomOrbit=dict(keys=24,radiusWU=17.5,center=[4,0,-.8],
        degrees=360,nominalSeconds=30.72),originalTourKeys=96,
        style='full billboard orbit, then original human-like three-room exploration')
    info['occlusion']='five checked convex cells; one non-intersecting room0 billboard, native bounded depth band shared with cube'
    asm=(out/'3Dvibe64.asm').read_text(encoding='ascii')
    assert 'cmp #$fc' in asm and 'cmp #$f0' not in asm[asm.index('wait_raster:'):asm.index('init_irq:')]
    lab={m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',(out/'3Dvibe64.labels').read_text(),re.M)}
    assert lab['RUNTIME_BUFFER_END']<=lab['mode3_high_basic_relocated_code_start'],'Runtime buffers overlap code'
    info['runtimeBufferEnd']=lab['RUNTIME_BUFFER_END']
    (out/'build.json').write_text(json.dumps(info,indent=2))
    reportPath=room.ROOT/'reports'/f'{name}-build.json'
    report=json.loads(reportPath.read_text())
    report.update(cameraTicks=human_tour.PERIOD,music=False,demoCamera=info['demoCamera'],
                  textureLOD=info['textureLOD'],geometricLOD=info['geometricLOD'],distributionPRG=info['distributionPRG'],
                  staticVertexLighting=False,lighting='unlit rooms; all cubes flat; original fixed ceiling material',gouraudShading=False)
    reportPath.write_text(json.dumps(report,indent=2))

