"""Private, reproducible one-room Q8 demo inside the original2D interface.
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
import single_room, comparison_actors
material_profile = None
if (ROOT/'src/material_profile.py').is_file():
    import material_profile
gameplay_profile = None
if (ROOT/'src/gameplay_profile.py').is_file():
    import gameplay_profile
door_profile = None
if (ROOT/'src/door_profile.py').is_file():
    import door_profile
multiple_profile = None
if (ROOT/'src/multiple_profile.py').is_file():
    import multiple_profile
texture_animation_profile = None
if (ROOT/'src/texture_animation_profile.py').is_file():
    import texture_animation_profile
light_bake_profile = None
if (ROOT/'src/light_bake_profile.py').is_file():
    import light_bake_profile
visibility_profile = None
if (ROOT/'src/visibility_profile.py').is_file():
    import visibility_profile
shared_mesh_profile = None
if (ROOT/'src/shared_mesh_profile.py').is_file():
    import shared_mesh_profile
motion_profile = None
if (ROOT/'src/motion_profile.py').is_file():
    import motion_profile
world_profile = None
if (ROOT/'src/world_profile.py').is_file():
    import world_profile
comparison_actors.WIRE_ENABLED='--without-skeleton' not in sys.argv
comparison_actors.BB_ENABLED='--without-billboard' not in sys.argv
for flag in ('--without-skeleton','--without-billboard'):
    if flag in sys.argv:sys.argv.remove(flag)
if shared_mesh_profile is not None:
    comparison_actors.WIRE_ENABLED=False
    comparison_actors.BB_ENABLED=False
single_room.configure_tour(human_tour)
if door_profile is not None:
    door_profile.configure_tour(human_tour)
    comparison_actors.WIRE_ENABLED=False
if visibility_profile is not None:visibility_profile.configure_tour(human_tour)
if world_profile is not None:world_profile.configure_tour(human_tour)
cube_runtime.adapt_vertices=lambda parts:parts
scene_builder.bake.depth=''
with_interface=True
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
name = sys.argv[sys.argv.index('--name')+1] if '--name' in sys.argv else 'ui-outline'
fast = False  # delivered profile: exact perspective, every pixel and row
no_lod = '--no-lod' in sys.argv or '--full-noLOD' in sys.argv
if '--no-lod' in sys.argv:sys.argv.remove('--no-lod')
if no_lod:
    if '--full-noLOD' in sys.argv:sys.argv.remove('--full-noLOD')
    fast = False
if '--precise' in sys.argv: sys.argv.remove('--precise')
standard = 'ntsc' if '--ntsc' in sys.argv else 'pal'
if '--ntsc' in sys.argv: sys.argv.remove('--ntsc')
if '--silent' not in sys.argv: sys.argv.append('--silent')  # this demo never embeds music

def create():
    result = single_room.create(room,scene_builder.previous.textures)
    if door_profile is not None:result=door_profile.create(result)
    if shared_mesh_profile is not None:result=shared_mesh_profile.create(result)
    if motion_profile is not None:motion_profile.configure()
    if material_profile is not None: material_profile.configure(result[0])
    if light_bake_profile is not None:light_bake_profile.configure(result[0])
    if gameplay_profile is not None:gameplay_profile.configure(result[0])
    if texture_animation_profile is not None:texture_animation_profile.configure(result[0])
    if visibility_profile is not None:visibility_profile.configure(result[0])
    return result
room.make_scene=create
room.trajectory=lambda:human_tour.trajectory(room)
room.bake_static_light=lambda source: (material_profile.bake(single_room.bake(source))
    if material_profile is not None else single_room.bake(source))


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
        code=single_room.filler_hooks(code)
        code=unlit_rooms.hooks(code)
        code=single_room.surface_hooks(code,doc)
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
        if material_profile is not None:code=material_profile.hooks(code)
        return code
    prepared_source,parts=split_helpers(source,parts,transform)
    prepared_source,parts=comparison_actors.adapt(prepared_source,parts)
    if gameplay_profile is not None:prepared_source,parts=gameplay_profile.adapt(prepared_source,parts)
    if door_profile is not None:prepared_source,parts=door_profile.adapt(prepared_source,parts)
    if multiple_profile is not None:prepared_source,parts=multiple_profile.adapt(prepared_source,parts)
    if texture_animation_profile is not None:prepared_source,parts=texture_animation_profile.adapt(prepared_source,parts)
    if visibility_profile is not None:prepared_source,parts=visibility_profile.adapt(prepared_source,parts)
    if shared_mesh_profile is not None:prepared_source,parts=shared_mesh_profile.adapt(prepared_source,parts)
    if motion_profile is not None:prepared_source,parts=motion_profile.adapt(prepared_source,parts)
    if world_profile is not None:prepared_source,parts=world_profile.adapt(prepared_source,parts)
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
    return outside if shared_mesh_profile is not None else comparison_actors.post(outside)
room.post_attach_adapter=post

if __name__=='__main__':
    if '--name' not in sys.argv:sys.argv.extend(['--name',name])
    # Standard is selected in the local generator invocation, never by editing
    # the frozen renderer or by relabeling PAL bytes as an NTSC build.
    room.main()
    from package_prg import package
    out=room.ROOT/'build'/name
    quality='fast' if fast else 'precise'
    target=ROOT/'artifacts'/f'room-skeleton-billboard-{quality}-{standard}-{artifact_tag or name}.prg'
    package(out,target)
    info=json.loads((out/'build.json').read_text())
    info.update(rooms=1,closedRoom=True,cubes=0,corridors=0,music=False,
        viewportLogical=[96,60],viewportPhysical=[192,120],viewportOriginPhysical=[48,8],bitmapInterface=True,focal=41,
        renderedRows=30 if fast else 60,perspectiveBlock=8 if fast else 1,
        reconstruction='upper-row duplicate' if fast else 'none',
        textureLOD=False if no_lod else {'fadeNear':14,'fadeFar':22},roomTextureLighting='none',
        distributionPRG=str(target.relative_to(ROOT)),cameraTicks=human_tour.PERIOD,
        demoCamera=dict(keys=human_tour.KEYS,ticksPerKey=64,periodTicks=human_tour.PERIOD,
                        orbitDegrees=360,looksUpAndDown=True,stationarySegments=[]),
        skeleton=dict(enabled=comparison_actors.WIRE_ENABLED,position=[-7,0,-2.5],scale=.5,
                      sourceVertices=38,edges=52,source='original 3D wire skeleton with sword/shield',
                      animation='walk, combat/sword strike, head turn; 32 sampled source poses'),
        billboard=dict(enabled=comparison_actors.BB_ENABLED,position=[7,0,-2.5],worldSize=[6,16],
                       bodyHeight=15,outlineWorldMarginVertical=.5,
                       sourceSize=[16,32],frames=6,transparentIndex=0,opaqueBlackIndex=4,
                       outline='black 8-neighbor source-pixel contour, including feet',
                       statureReference='skeleton body base pose: Z=-15..15 at scale0.5, center=-2.5',
                       feetWorldZ=-10,headWorldZ=5,cameraFacing='screen-aligned'),
        comparison='3D skeleton at world X=-7; camera-facing 2D billboard at world X=+7',
        occlusion='single convex closed room; shell behind both actors; native depth order between actor nodes',
        publicEngineModified=False,Mode8Modified=False,
        runtimeSDK=(ROOT/'sdk/VERSION').read_text().strip(),privateAdapter=True,q8Option=q8_option)
    lab={m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',(out/'3Dvibe64.labels').read_text(),re.M)}
    expected=shared_mesh_profile.counts() if shared_mesh_profile is not None else door_profile.counts() if door_profile is not None else (9,16)
    assert (lab['VERT_COUNT'],lab['FACE_COUNT'])==expected and lab['SCENE_OBJECT_COUNT']==1
    assert lab['RUNTIME_BUFFER_END']<=lab['mode3_high_basic_relocated_code_start']
    info['runtimeBufferEnd']=lab['RUNTIME_BUFFER_END']
    info['blockSizesActors']={k:info['blockSizes'][k] for k in ('skeleton','skeleton_poses','billboard','bb_state','bb_pixels')}
    if material_profile is not None:
        info['surfaceRendering']=material_profile.report()
        info.update(demoFocal=41,staticVertexLighting=True,
            lighting='explicit static corner levels for untextured Gouraud surfaces; textures unlit',
            publicProfileExtension='experimental per-face shader selection in the bounded Q8 comparison room')
    if gameplay_profile is not None:
        info['gameplay']=gameplay_profile.report()
        info['billboard']=gameplay_profile.billboard_metadata()
        info['comparison']='original3D skeleton and scene-configured masked billboard'
    if door_profile is not None:
        info['door']=door_profile.report()
        info['gameplay']['limits']=info['door']['limits']
        info['gameplay']['controls']='WASD enters manual front visit; SPACE uses guardian; R restarts automatic cycle with closed door'
        info['skeleton']=dict(enabled=False,reason='door profile reserves its code/pose budget for door geometry and logic')
        info['comparison']='guard-operated moving polygonal door and traversable opening'
        info['occlusion']='convex outer shell; bounded divider plane separates all actor geometry; half-space ordering'
        info['demoCamera'].update(orbitDegrees=None,description=door_profile.ROUTE_DESCRIPTION)
    if multiple_profile is not None:info.update(multiple_profile.report())
    if texture_animation_profile is not None:info.update(texture_animation_profile.report())
    if light_bake_profile is not None:info.update(light_bake_profile.report())
    if visibility_profile is not None:info.update(visibility_profile.report())
    if visibility_profile is not None:info['demoCamera'].update(visibility_profile.CAMERA)
    if shared_mesh_profile is not None:info.update(shared_mesh_profile.report())
    if shared_mesh_profile is not None:info['demoCamera']['description']='48-key closed-room360degree orbit around native mesh instances, vertical gaze sweeps,3072ticks'
    if motion_profile is not None:info.update(motion_profile.report())
    if motion_profile is not None and motion_profile.CONFIG['enabled']:info['demoCamera']['description']='48-key closed-room360degree orbit, vertical gaze and controlled mesh animation; '+motion_profile.CONFIG['camera']['mode']+' camera;3072ticks'
    if world_profile is not None:info.update(world_profile.finalize(lab,info))
    if world_profile is not None and world_profile.CONFIG['enabled']:info['demoCamera']['description']='native external room group visits, guardian/door state, backward and forward return; '+('automatic transitions' if world_profile.CONFIG['autoTransitions'] else 'fixed group control')
    (out/'build.json').write_text(json.dumps(info,indent=2))
    (ROOT/'reports'/f'{name}-build.json').write_text(json.dumps(info,indent=2))
    (room.ROOT/'reports'/f'{name}-build.json').write_text(json.dumps(info,indent=2))
