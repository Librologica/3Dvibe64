"""Bounded three-room integration: actors, events and phased startup memory.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import json
import math
import re
from pathlib import Path
import comparison_actors as actors
import single_room
import torus_runtime as arrays
import cell_order
import billboard_room as bb
import billboard_scene
import entity_runtime
import human_tour
import cube_runtime

ROOT = Path(__file__).resolve().parents[1]
ENGINE_VERSION = (ROOT/'sdk/VERSION').read_text(encoding='utf-8-sig').strip()
CONFIG = None
STATS = None
BB_STATE = ''
WR_STATE = ''
RANK_STATE = ''
CUBE_CENTERS = [(-16, 0, -7), (16, 48, -6), (0, 160, 4)]


def configure_tour():
    old=human_tour.poses();intro=[]
    def pose(x,z,tx=0):
        yaw=-math.atan2(tx-x,-z)
        pitch=math.atan2(2.5,math.hypot(tx-x,z))
        return [round(x*256),0,round(z*256),round(yaw*65536/math.tau)&65535,round(pitch*65536/math.tau)&65535]
    for i in range(16):
        a=math.pi+i*math.tau/16
        p=pose(21*math.sin(a),21*math.cos(a))
        p[4]=round(math.atan2(2.5+2*math.sin(2*a),21)*65536/math.tau)&65535
        intro.append(p)
    intro += [pose(0,-21),pose(7,-17,7),pose(7,-11,7),pose(7,-15,7),
              pose(0,-20),pose(-7,-17,-7),pose(-7,-12,-7),pose(-7,-10,-7)]
    tail=[]
    for i in range(72):
        k=i*len(old)/72;lo=math.floor(k);fraction=k-lo
        p=old[lo];q=old[(lo+1)%len(old)];out=[]
        for j in range(5):
            delta=q[j]-p[j]
            if j>=3:delta=((delta+32768)&65535)-32768
            v=p[j]+round(fraction*delta)
            out.append(v&65535 if j>=3 else v)
        tail.append(out)
    # Keep clear of the floor cube and new character bodies while retaining
    # both portal crossings and the measured camera route.
    for p in tail:
        if abs(p[2])<6*256:p[0]=(-12 if p[0]<0 else 14)*256
    route=intro+tail
    assert len(route)==96
    human_tour.KEYS=96;human_tour.PERIOD=6144;human_tour.poses=lambda:[p.copy() for p in route]
    save(ROOT/'reports/camera-design.json',dict(posesQ8=route,introKeys=24,keys=96,periodTicks=6144,
        description='Full orbit around both characters, guardian/skeleton inspections, then three-room exploration resampled to72keys'))


def save(p, x):
    p.write_text(json.dumps(x, indent=2)+'\n', encoding='utf-8', newline='\n')


configure_tour()


def create(result):
    global CONFIG, STATS
    path, old = result
    doc = json.loads(path.read_text(encoding='utf-8'))
    meshes = doc['meshes'][:3]
    # Retain both original floor cubes. The third cube is part of room3's
    # static mesh, leaving the fourth object for the two actor painter nodes.
    central = cube_runtime.make()
    third = meshes[2]
    base = len(third['vertices'])
    third['vertices'] += [[x, y+4, z] for x,y,z in central['vertices']]
    third['faces'] += [[v+base for v in face] for face in central['faces']]
    third['faceUV'] += central['faceUV']
    third['faceTextures'] += central['faceTextures']
    third['faceMaterials'] += ['gray']*12
    ranges = []
    connectors = []
    total = 0
    for i, mesh in enumerate(meshes):
        first = old['ranges'][i]['first']
        count = len(mesh['faces'])
        used = sorted({v for face in mesh['faces'] for v in face})
        remap = {v:j for j,v in enumerate(used)}
        mesh['vertices'] = [mesh['vertices'][v] for v in used]
        mesh['faces'] = [[remap[v] for v in face] for face in mesh['faces']]
        cube_first = old['ranges'][i]['cubeFirst']-first
        ranges.append(dict(first=total, end=total+count, cubeFirst=total+cube_first))
        connectors.append([total+f-first for f in old['connectors'][i]])
        total += count
    # Last object supplies two synthetic painter nodes, never triangles.
    carrier = dict(meshes[0])
    carrier.update(id='central-cube', vertices=[[-4,-4,-4],[-4,4,-4],[4,4,-4],[4,-4,-4]],
        faces=[[0,1,2],[0,2,3]], faceUV=[[[0,0]]*3]*2,
        faceTextures=['plain-ceiling']*2, faceMaterials=['gray']*2,
        gouraud={'creaseAngle':0})
    doc['meshes'] = meshes+[carrier]
    doc['objects'][-1].update(id='actor-nodes', mesh='central-cube', position=[0,160,4],
        rotation=[0,0,0], angularVelocity=[0,0,0], scale=1)
    doc['name'] = 'underworld-three-rooms-actors-events'
    doc['privateExperiment'] = 'corridor-flatcube'
    doc['actors'] = dict(skeleton=[-7,0,-2.5], billboard=[7,0,-2.5], nodeFaces=[total,total+1])
    doc['privateRenderContract']=dict(roomTextureLighting='none',textureLOD=[14,22],
        actors='Q8 38-vertex skeleton and outlined masked billboard, owned by room0',
        cubeLighting='three static flat cubes, one in each room')
    STATS = dict(rooms=3, ranges=ranges, connectors=connectors, vertices=sum(len(m['vertices']) for m in doc['meshes']),
        triangles=total+2, roomTriangles=total-32, actorNodes=[total,total+1], cubes=3,
        cubeCenters=[list(p) for p in CUBE_CENTERS], cubeTriangles=32, centralCubeMotion='static')
    single_room.WIRE_FACE = total
    single_room.BILLBOARD_FACE = total+1
    actors.WIRE_FACE = total
    actors.BILLBOARD_FACE = total+1
    arrays.FACE = total
    save(path,doc)
    save(ROOT/'reports/scene.json',STATS)
    asset = ROOT/'assets/billboard-frames.json'
    cfg = ROOT/'assets/adventure-scene.json'
    if not cfg.exists():
        bb.artwork()
        save(cfg,dict(schema=1,billboards=[dict(id='guardian',asset=asset.name,position=[7,0,-2.5],size=[6,16],
            animations=dict(idle=dict(frames=[0,1,2,3],ticksPerFrame=12),used=dict(frames=[4,5],ticksPerFrame=6)))],
            entity=dict(billboard='guardian',enabled=True,useRange=12,collisionHalfSize=[1,1],demoUseKeys=[])))
    CONFIG, art = billboard_scene.load(cfg)
    b=CONFIG['billboards'][0];radius=math.hypot(b['size'][0]/2,b['size'][1]/2)
    if abs(b['position'][0])+radius>=23 or abs(b['position'][1])+radius>=23:
        raise ValueError('The full billboard envelope must remain inside room0')
    if abs(b['position'][0]+7)<10 and abs(b['position'][1])<8:
        raise ValueError('This bounded painter requires disjoint actor envelopes')
    def artwork():
        return art['frames']
    bb.artwork = artwork
    save(ROOT/'reports/adventure-config.json', CONFIG)
    return path, STATS


def bake(source, original):
    source = original(source)
    source = arrays.bake(source)
    for c in range(3):
        _, values = arrays.array(source, 'gouraud_face_shade'+str(c))
        source = arrays.put(source, 'gouraud_face_shade'+str(c), [16]*len(values))
    source = arrays.put(source, 'gouraud_shade_value', list(range(33)))
    for label in ['object_runtime_shade_first','object_runtime_shade_end']:
        source = arrays.put(source,label,[0]*4)
    a=source.index('m3_update_shades:\n');b=source.index('m3_update_shades_end = *',a)
    source=source[:a]+'m3_update_shades:\n rts\n'+source[b:]
    # Actor nodes have first-room ownership and retain a native depth band.
    source=source.replace('co_depth_loaded:\n cpx #106\n', f'co_depth_loaded:\n cpx #{STATS["actorNodes"][0]}\n')
    source=source.replace(' lda p1lo\n lsr\n lsr\n cmp #16\n', ' lda p1lo\n cmp #16\n', 1)
    return source


def surface_hooks(source, doc):
    import flat_cubes_ceiling as flat
    # The existing Mode4 flat dispatcher supplies inclusive coverage and
    # three solid gray levels. The property-derived classifier also retains
    # the original ceiling, rather than applying ceiling texture to cubes.
    original = flat.classify
    def classify(scene):
        codes, planes, ceilings = [], [], []
        for oi,(obj,mesh) in enumerate(zip(scene['objects'],scene['meshes'])):
            if oi==3:
                codes += [255]*len(mesh['faces'])
                continue
            first=STATS['ranges'][oi]['first']
            cube_first=STATS['ranges'][oi]['cubeFirst']-first
            for fi,(face,texture) in enumerate(zip(mesh['faces'],mesh['faceTextures'])):
                pts=[mesh['vertices'][v] for v in face]
                if fi<cube_first:
                    ceiling=all(p[1]+obj['position'][2]==18 for p in pts)
                    codes.append(253 if ceiling else 255)
                    if ceiling:ceilings.append(first+fi)
                    continue
                p,q,r=pts
                u=[q[a]-p[a] for a in range(3)];v=[r[a]-p[a] for a in range(3)]
                n=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
                # Both triangles of a plane use the same quad center/light.
                center=[(min(p[a] for p in pts)+max(p[a] for p in pts))/2 for a in range(3)]
                world=[center[0]+obj['position'][0],center[1]+obj['position'][2],center[2]+obj['position'][1]]
                lamp=[-12,12,(0,48,160)[oi]+16]
                delta=[lamp[a]-world[a] for a in range(3)]
                cosine=max(0,sum(n[a]*delta[a] for a in range(3))/math.sqrt(sum(t*t for t in n)*sum(t*t for t in delta)))
                code=0 if cosine<.2 else 4 if cosine>=.65 else 2
                codes.append(code);planes.append(dict(object=oi,face=first+fi,flatCode=code))
        assert len(codes)==STATS['triangles'] and len(planes)==32
        return codes,dict(staticCubeTriangles=planes,ceilingFaces=ceilings,cubes=3,
            centralCubeMotion='static',renderer='native solid Mode4, precise Q8 coverage')
    flat.classify=classify
    try:
        # Install the original flat coverage conversion without its rotating
        # cube dispatch; per-face property codes select all three cubes.
        dispatch=cube_runtime.dispatch()
        a=dispatch.index('fc_cube:\n');b=dispatch.index(' ldx face_ymin\n',a)
        dispatch=dispatch[:dispatch.index(' lda sortj\n')]+' lda sortj\n jmp gouraud_fill_bounds\nfc_cube:\n sta fc_code\n'+dispatch[b:]
        dispatch=dispatch.replace('fc_shade_codes: .fill 12,0\n','')
        old='fc_finish_bounds:\n lda sortj\n sta fc_code\nsc_inclusive_setup:\n jmp gouraud_fill_bounds\nfc_code: .byte 0\n'
        assert source.count(old)==1
        # The classifier routes non-cube faces directly to the precise shader.
        source=source.replace(old,dispatch)
        return flat.hooks(source,doc)
    finally:flat.classify=original


def entity_code():
    e=CONFIG['entity'];x,z=CONFIG['billboards'][0]['position'][:2]
    # Reuse the dev entity distance/range and accepted/rejected use semantics.
    use=entity_runtime.KERNEL.split('en_use:\n',1)[1].split('; Each temporary',1)[0]
    use=use.replace(' sta bc_state\n',''' sta bc_state
 beq ad_walk_clip
 ldx #2
 bne ad_bind_clip
ad_walk_clip:
 ldx #0
ad_bind_clip:
 stx wr_stage
 lda wr_first,x
 sta wr_pose
 lda #0
 sta wr_subtick
 sta wr_age
 sta wr_age_hi
 lda #1
 sta wr_dirty
''')
    return '''en_tick:
 lda en_enabled
 bne +
 rts
+
 lda #0
 sta en_event
 jsr en_distance
 jsr en_range
 bcc ad_leave
 lda ad_near_latch
 bne ad_space
 inc ad_near_latch
 jsr en_use
 jmp ad_space
ad_leave:
 lda #0
 sta ad_near_latch
ad_space:
 jsr explorer_scan_keys
 lda explorer_key_col7
 eor #255
 and #$10
 beq ad_release
 lda en_use_latch
 bne ad_done
 inc en_use_latch
 jmp en_use
ad_release:
 lda #0
 sta en_use_latch
ad_done:
 rts
en_use:
'''+use+'en_distance:\n'+entity_runtime.distance('x',x)+entity_runtime.distance('z',z)+' rts\n'+entity_runtime.limits('en_range',e['useRange'],e['useRange'])+'''
ad_near_latch: .byte 0
en_use_latch: .byte 0
en_state: .byte 0
en_event: .byte 0
en_event_count: .byte 0
en_rejected: .byte 0
en_dx: .word 0
en_dz: .word 0
en_enabled: .byte '''+str(int(e['enabled']))+'\n'


DECODER = '''bb_decode:
 lda bb_frame
 cmp bb_loaded
 beq bb_decode_done
 sta bb_loaded
 tax
 php
 sei
 lda $01
 pha
 lda #$34
 sta $01
 lda ad_frame_lo,x
 sta ad_read+1
 lda ad_frame_hi,x
 sta ad_read+2
 lda #<bb_pixels
 sta ad_write+1
 lda #>bb_pixels
 sta ad_write+2
 lda #2
 sta ad_pages_left
 ldy #0
ad_run:
 jsr ad_read
 pha
 and #7
 sta ad_value
 pla
 lsr
 lsr
 lsr
 tax
 inx
 lda ad_value
ad_run_pixel:
ad_write:
 sta bb_pixels,y
 iny
 bne ad_run_next
 inc ad_write+2
 dec ad_pages_left
 beq ad_rle_done
ad_run_next:
 dex
 bne ad_run_pixel
 jmp ad_run
ad_rle_done:
 pla
 sta $01
 plp
bb_decode_done:
 rts
ad_read:
 lda $d000
 inc ad_read+1
 bne +
 inc ad_read+2
+
 rts
ad_pages_left: .byte 0
ad_value: .byte 0
'''


VISIBILITY = '''ad_room_visible:
 lda ad_culling
 beq ad_room_accept
 lda objidx
 cmp #3
 beq ad_room_accept
 ldx active_vfirst
ad_room_vertex:
 lda hc_cam_z2,x
 bpl ad_room_accept
 inx
 cpx active_vend
 bne ad_room_vertex
 inc ad_rooms_rejected
 clc
 rts
ad_room_accept:
 sec
 rts
ad_culling: .byte 1
ad_rooms_rejected: .byte 0
'''


def adapt(source, parts):
    global BB_STATE, WR_STATE, RANK_STATE
    source,parts=actors.adapt(source,parts)
    # No geometric LOD: the full 38-vertex /52-edge model is always selected.
    parts['billboard']=billboard_scene.bind(parts['billboard'],CONFIG)
    parts['billboard_animation']=billboard_scene.animation(CONFIG)
    parts['adventure_entities']=entity_code()
    code=parts['billboard'];a=code.index('bb_decode:\n');b=code.index('bb_draw:\n',a)
    parts['billboard']=code[:a]+DECODER+code[b:]
    old='advance_sim_tick:\n jsr wr_tick\n jsr bb_tick\n jsr qc_demo_tick\n'
    assert source.count(old)==1
    source=source.replace(old,'advance_sim_tick:\n jsr wr_tick\n jsr qc_demo_tick\n jsr en_tick\n jsr bb_tick\n')
    # Explicit lifetime reuse: UI decoder dies before actors begin. Buffers
    # have no startup initializer and are fully written before their first read.
    code=parts['skeleton']
    # Application events select a clip; tick advances only within that clip.
    # The imported demo's automatic walk/idle/attack cycling is retired here.
    a=code.index('wr_tick_exit:\n');b=code.index('wr_decode:\n',a)
    code=code[:a]+'wr_tick_exit:\nwr_return:\n rts\n'+code[b:]
    m=re.search(r'(?m)^wr_coords: \.byte [^\n]+\n',code);assert m
    code=code[:m.start()]+'wr_coords = game_ui_init\n'+code[m.end():]
    for i,name in enumerate(['xlo','xhi','ylo','yhi','valid']):
        old=f'wr_{name}: .fill 38,0\n';assert code.count(old)==1
        code=code.replace(old,f'wr_{name} = game_ui_init+{114+i*38}\n')
    a=code.index('wr_edge0:');b=code.index('wr_code_end:',a)
    WR_STATE=code[a:b]
    parts['skeleton']=code[:a]+code[b:]
    # Pose streams and the BB initial state are immutable under I/O, not RAM
    # reserved in the active renderer. The BB frame itself overlays UI pages0/1.
    parts.pop('skeleton_poses')
    state=parts.pop('bb_state')
    state=re.sub(r'(?m)^bb_walk_(?:lo|hi): \.byte [^\n]+\n','',state)
    BB_STATE=state
    for i in range(5):
        pattern=rf'(?m)^co_depth{i}: \.byte [^\n]+\n'
        m=re.search(pattern,parts['data']);assert m
        parts['data']=parts['data'][:m.start()]+parts['data'][m.end():]
    order=json.loads((ROOT/'reports/cell-order.json').read_text(encoding='utf-8'))
    classes=[2*owner+int(solid) for owner,solid in zip(order['faceOwners'],order['solidFaces'])]
    levels=[80+35*abs(owner-current)-(30 if solid else 0)
            for current in range(5) for owner in range(5) for solid in [False,True]]
    assert [[levels[current*10+c] for c in classes] for current in range(5)]==order['depthTables']
    RANK_STATE=bb.data('ad_face_class',classes)+bb.data('ad_depth_levels',levels)+bb.data('ad_cell_offsets',[0,10,20,30,40])
    a=source.index('bvf_depth_ready:\n');b=source.index('co_depth_loaded:\n',a)
    source=source[:a]+'''bvf_depth_ready:
 ldx faceidx
 ldy co_cell
 lda ad_cell_offsets,y
 clc
 adc ad_face_class,x
 tay
 lda ad_depth_levels,y
'''+source[b:]
    a=source.index('co_depth_loaded:\n');b=source.index('tr_depth_done:\n',a)
    source=source[:a]+f'''co_depth_loaded:
 sta co_depth_base
 lda ad_face_class,x
 lsr
 bcc ad_shell_depth
 lda p1lo
 cpx #{STATS['actorNodes'][0]}
 bcs ad_depth_units
 ; Ordinary faces supply WU depth; actors already supply depth/4 (four-WU) buckets.
 lsr
 lsr
ad_depth_units:
 cmp #16
 bcc co_central_band
 lda #15
co_central_band:
 clc
 adc co_depth_base
 jmp tr_depth_done
ad_shell_depth:
 lda co_depth_base
'''+source[b:]
    # All these arrays are fully produced by the first render, after the UI
    # decoder has returned. Reuse its remaining input pages without changing
    # either displayed bitmap, screen or ColorRAM.
    for i,name in enumerate('hc_cam_'+a+str(j) for a in 'xyz' for j in range(3)):
        old=name+': .fill VERT_COUNT,0\n'
        assert parts['data'].count(old)==1,name
        parts['data']=parts['data'].replace(old,name+f' = ui_pack6+{i}*VERT_COUNT\n')
    source=source.replace('sx = RUNTIME_BUFFER_BASE\n','sx = ui_pack10\n',1)
    source=source.replace('RUNTIME_AFTER_SXQ2 = syq2_hi + VERT_COUNT\n','RUNTIME_AFTER_SXQ2 = RUNTIME_BUFFER_BASE\n',1)
    source=source.replace('RUNTIME_AFTER_SXQ2 != syq2_hi + VERT_COUNT','syq2_hi+VERT_COUNT > ui_pack11+223',1)
    source=source.replace('vxrawlo = RUNTIME_AFTER_RAW\n','vxrawlo = ui_pack3+ad_rank_initial_end-ad_rank_initial\n',1)
    source=source.replace('RUNTIME_AFTER_NEAR = vzrawhi + VERT_COUNT\n','RUNTIME_AFTER_NEAR = RUNTIME_AFTER_RAW\n',1)
    parts['bb_pixels']='bb_pixels = ui_pack0\n .cerror ui_pack1-ui_pack0 !=256,"BB overlay pages must be contiguous"\n'
    parts['ui_pack0']+=parts.pop('ui_pack1')
    parts['ui_pack3']+=parts.pop('ui_pack4')
    parts['ui_pack3']+=parts.pop('ui_pack5')
    for i in [7,8,9]:parts['ui_pack6']+=parts.pop('ui_pack'+str(i))
    parts['ui_pack10']+=parts.pop('ui_pack11')
    source=source.replace(' jsr game_ui_init\n',' jsr game_ui_init\n jsr ad_init\n')
    parts['actor_init']='''ad_init:
 php
 sei
 lda $01
 pha
 lda #$34
 sta $01
 ldx #0
ad_init_byte:
 lda ad_bb_initial,x
 sta game_ui_init+304,x
 inx
 cpx #ad_bb_initial_end-ad_bb_initial
 bne ad_init_byte
 ldx #0
ad_init_wire:
 lda ad_wr_initial,x
 sta ui_pack2,x
 inx
 cpx #ad_wr_initial_end-ad_wr_initial
 bne ad_init_wire
 ldx #0
ad_init_ranking:
 lda ad_rank_initial,x
 sta ui_pack3,x
 inx
 cpx #ad_rank_initial_end-ad_rank_initial
 bne ad_init_ranking
 ldx #0
 pla
 sta $01
 plp
 rts
 .cerror ad_bb_initial_end-ad_bb_initial >170,"UI code overlay exceeds dead decoder"
 .cerror ad_wr_initial_end-ad_wr_initial >256,"Wire state exceeds dead UI page"
 .cerror ad_rank_initial_end-ad_rank_initial >256,"Compact depth tables exceed one page"
 .cerror vzrawhi+VERT_COUNT >ui_pack3+768,"Raw vertex overlay exceeds dead UI pages"
 .cerror hc_cam_z2+VERT_COUNT >ui_pack6+1024,"Q8 vertex overlay exceeds dead UI pages"
 .cerror ui_pack4-ui_pack3 !=256,"Depth overlay pages must be contiguous"
 .cerror ui_pack5-ui_pack3 !=512,"Depth overlay pages must be contiguous"
'''
    source=source.replace('collect_active_mesh_faces:\n','collect_active_mesh_faces:\n jsr ad_room_visible\n bcs +\n rts\n+\n',1)
    source=source.replace('begin_depth_buckets:\n','begin_depth_buckets:\n lda #0\n sta ad_rooms_rejected\n',1)
    render=ROOT/'assets/adventure-render.json'
    cfg=json.loads(render.read_text(encoding='utf-8')) if render.exists() else dict(culling=True)
    parts['room_visibility']=VISIBILITY.replace('ad_culling: .byte 1','ad_culling: .byte '+str(int(cfg['culling'])))
    return source,parts


def rle(frame):
    out=[];i=0
    while i<len(frame):
        j=i+1
        while j<len(frame) and frame[j]==frame[i] and j-i<32:j+=1
        out += [((j-i-1)<<3)|frame[i]];i=j
    return out


def post(source):
    frames=bb.artwork();packed=[rle(f) for f in frames]
    source+='\n*=$d000\n'
    for i,frame in enumerate(packed):source+=bb.data('ad_rle'+str(i),frame)
    source+='ad_frame_lo: .byte '+','.join('<ad_rle'+str(i) for i in range(len(frames)))+'\n'
    source+='ad_frame_hi: .byte '+','.join('>ad_rle'+str(i) for i in range(len(frames)))+'\n'
    source+='wr_pose_tables_begin:\n'+actors.wire.POSE_TABLES+'wr_pose_tables_end:\n'
    source+='ad_bb_initial:\n .logical game_ui_init+304\n'+BB_STATE+' .here\nad_bb_initial_end:\n'
    source+='ad_wr_initial:\n .logical ui_pack2\n'+WR_STATE+' .here\nad_wr_initial_end:\n'
    source+='ad_rank_initial:\n .logical ui_pack3\n'+RANK_STATE+' .here\nad_rank_initial_end:\n'
    source+=' .cerror * >$e000,"Actors exceed RAM under I/O"\nbb_payload_end = *\n'
    save(ROOT/'reports/actor-storage.json',dict(frameRLEBytes=sum(map(len,packed)),
        reuse=dict(startupDecoder='game_ui_init',runtimeSkeletonBuffers=304,runtimeBBState='at game_ui_init+304',
            decodedBillboardFrame='ui_pack0/ui_pack1',decodedBillboardBytes=512,
            wireState='ui_pack2',compactDepthTables='ui_pack3',
            vertexCoordinates='ui_pack6..9',screenCoordinates='ui_pack10..11',
            rawVertexCoordinates='ui_pack3+175 through ui_pack5',totalRuntimeBytes=2904,
            contract='after game_ui_init returns; decoder/source pages never called/read again'),
        poseStorage='immutable streams under I/O',geometricLOD=False))
    return source


def finish(out):
    p=out/'build.json';x=json.loads(p.read_text(encoding='utf-8'))
    for k in ['cubeCenter','cubeRenderMode','cubeSmooth','cubeMaterial','cubeLighting','allCubesFlat']:x.pop(k,None)
    x.update(rooms=3,cubes=3,cubeCenters=STATS['cubeCenters'],centralCubeMotion='static',
        cubeLighting='native flat solid, three gray levels',vertices=STATS['vertices'],triangles=STATS['triangles'],actorNodes=STATS['actorNodes'],
        skeleton=dict(vertices=38,segments=52,position=[-7,0,-2.5],heightWU=15,clipControl='entity events select walking/attack'),
        billboard=dict(position=CONFIG['billboards'][0]['position'],worldSize=CONFIG['billboards'][0]['size'],frames=len(bb.artwork()),
            opaqueOutline=True,configuration='assets/adventure-scene.json',animationClock='simulation ticks'),
        integration=['BB-02 configuration/animation','entity use events and clip control','conservative per-room behind-camera rejection','startup-only UI storage reused after init'],
        worldGroups=False,commonLevelSchema=False,publicGeneralAPI=False)
    x.update(publicProfileExtension='Private integrated three-room actors/events/phased-memory experiment',
        demoOnlySpecialization='Five checked convex cells; two disjoint first-room actors',
        occlusion='Five-cell painter; actor nodes share room0 bounded native depth band',
        lighting='unlit room textures; three static flat cubes; original wire skeleton and masked outlined guardian',geometricLOD=False)
    x['demoCamera']['style']='character orbit/inspections followed by three-room exploration'
    save(p,x);save(ROOT/'reports/integration.json',x)
    for folder in [ROOT/'reports',ROOT/'room/reports']:save(folder/(out.name+'-build.json'),x)
