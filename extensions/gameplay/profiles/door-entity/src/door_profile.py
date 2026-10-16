"""Closed outer room split by one bounded plane and a retracting door."""
import json,math
from pathlib import Path
import door_runtime as door
ROOT=Path(__file__).resolve().parents[1]
FIRST=16
LEAF_FIRST=28
GEOMETRY=None
CONFIG=None
ROUTE_DESCRIPTION='48-key loop: approach guardian, open, traverse front-to-back, inspect, close/reopen, return through opening, close; vertical gaze sweeps'


def create(result):
    global GEOMETRY,CONFIG
    path,stats=result
    CONFIG=door.validate(json.loads((ROOT/'assets/door.json').read_text(encoding='utf-8-sig')))
    doc=json.loads(path.read_text(encoding='utf-8-sig'));m=doc['meshes'][0]
    def quad(points):
        ids=[]
        for x,y,z in points:
            p=[x,z,y]
            if p not in m['vertices']:
                m['vertices'].append(p);ids.append(len(m['vertices'])-1)
            else:ids.append(m['vertices'].index(p))
        for f in ([ids[0],ids[1],ids[2]],[ids[0],ids[2],ids[3]]):
            for face in (f,list(reversed(f))):
                m['faces'].append(face);m['faceUV'].append([[0,0]]*3)
                m['faceTextures'].append('plain-ceiling');m['faceMaterials'].append('brown')
        return ids
    quad([(-24,8,-10),(-5,8,-10),(-5,8,18),(-24,8,18)])
    quad([(5,8,-10),(24,8,-10),(24,8,18),(5,8,18)])
    quad([(-5,8,8),(5,8,8),(5,8,18),(-5,8,18)])
    # The inherited importer welds equal XYZ. Distinct integer rest positions
    # keep mobile bottom vertices independent from the fixed jambs; the Q8
    # runtime always replaces their height with floor+lift before projection.
    leaf=quad([(-5,8,-9),(5,8,-9),(5,8,8),(-5,8,8)])
    GEOMETRY=dict(vertices=len(m['vertices']),faces=len(m['faces']),first=FIRST,leafFirst=LEAF_FIRST,bottomVertices=leaf[:2],leafVertices=leaf)
    assert GEOMETRY['faces']==32
    path.write_text(json.dumps(doc,indent=2)+'\n',encoding='utf-8')
    cfg=json.loads((ROOT/'assets/surfaces.json').read_text(encoding='utf-8-sig'))
    entries=cfg['meshes'][m['id']]
    if len(entries)!=16:raise ValueError('Door profile requires the inherited16 surface descriptors')
    entries.extend({'mode':'flat','index':2 if i>=LEAF_FIRST else 1} for i in range(FIRST,32))
    (ROOT/'assets/surfaces.json').write_text(json.dumps(cfg,indent=2)+'\n',encoding='utf-8')
    game=json.loads((ROOT/'assets/gameplay-scene.json').read_text(encoding='utf-8-sig'))
    b=game['billboards'][0]
    # Half-space ordering is valid only while the whole billboard is on the
    # front side; this camera never exceeds14degrees pitch, manual pitch0.
    reach=b['size'][0]/2+b['size'][1]/2*math.sin(math.radians(14))
    if b['position'][1]+reach>=8 or not game['entity']['enabled']:
        raise ValueError('Door profile requires an enabled guardian wholly in front of divider for all supported camera pitches')
    stats.update(vertices=GEOMETRY['vertices'],triangles=32,dividerPlane=8,door=dict(halfWidth=5,height=18),actorNodes=[14,15])
    (ROOT/'reports/scene.json').write_text(json.dumps(stats,indent=2)+'\n',encoding='utf-8')
    (ROOT/'reports/door-geometry.json').write_text(json.dumps(GEOMETRY,indent=2)+'\n',encoding='utf-8')
    return path,stats


def counts():return GEOMETRY['vertices'],GEOMETRY['faces']


def adapt(source,parts):
    # The old actor node is a no-op; code/poses are released in this profile.
    parts['skeleton']='''wr_code_begin:
wr_collect:
wr_draw:
wr_tick:
 clc
 rts
wr_enabled: .byte 0
wr_pose: .byte 0
wr_dirty: .byte 0
wr_depth: .byte 0
wr_code_end:
'''
    parts['skeleton_poses']='wr_pose_tables_begin:\n .byte 0\nwr_pose_tables_end:\n'
    old=' jsr hp_build_vertices\n'
    if parts['core'].count(old)!=1:raise ValueError('Door vertex hook ABI changed')
    parts['core']=parts['core'].replace(old,old+' jsr dr_vertices\n')
    old=' jsr en_room\n bcc en_collision\n'
    if parts['entity_runtime'].count(old)!=1:raise ValueError('Entity collision ABI changed')
    parts['entity_runtime']=parts['entity_runtime'].replace(old,old+' jsr dr_can_stand\n bcc en_collision\n')
    old=' lda #0\n sta en_manual\n+\n'
    if parts['entity_runtime'].count(old)!=1:raise ValueError('Door automatic restart ABI changed')
    parts['entity_runtime']=parts['entity_runtime'].replace(old,' lda #0\n sta en_manual\n jsr dr_restart\n+\n')
    source=source.replace(' jsr en_tick\n',' jsr en_tick\n jsr dr_tick\n',1)
    old='bvf_depth_ready:\n lda faceidx\n'
    if source.count(old)!=1:raise ValueError('Door depth ABI changed')
    source=source.replace(old,'''bvf_depth_ready:
 lda faceidx
 cmp #16
 bcc dr_original_depth
 lda explorer_cam_z_hi
 eor #128
 cmp #136
 bcs dr_divider_near
 lda #128
 jmp cr_store_depth
dr_divider_near:
 lda #16
 jmp cr_store_depth
dr_original_depth:
 lda faceidx
''')
    source=source.replace('load_face_visible:\n','''load_face_visible:
 lda faceidx
 cmp #28
 bcc +
 lda dr_lift+1
 cmp #18
 bcc +
 clc
 rts
+
''',1)
    parts['door_runtime']=door.kernel(CONFIG,GEOMETRY['bottomVertices'])
    return source,parts


def configure_tour(human):
    points=[(0,-20,0),(8,-19,0),(15,-16,0),(10,-14,0),(3,-16,0),(0,-15,0),
        (7,-14,0),(4,-10,0),(0,0,0),(0,6,0),(0,10,0),(0,16,0),
        (5,18,60),(10,19,120),(14,17,180),(12,13,180),(6,15,180),(0,18,180),
        (-8,18,180),(-15,16,180),(-12,13,180),(-6,16,180),(-4,18,180),(0,17,180),
        (4,16,180),(2,20,180),(0,19,180),(-3,17,180),(-6,16,180),(-3,15,180),
        (0,16,180),(0,14,180),(0,12,180),(0,10,180),(0,6,180),(0,2,180),
        (0,-6,180),(-3,-13,180),(-10,-16,120),(-15,-18,60),(-10,-19,0),(-4,-18,0),
        (3,-19,0),(6,-18,0),(0,-16,0),(-5,-18,0),(-3,-20,0),(0,-19,0)]
    route=[]
    for i,(x,z,yaw) in enumerate(points):
        pitch=12*math.sin(i*math.tau/16)
        route.append([round(x*256),0,round(z*256),round(yaw*65536/360)&65535,round(pitch*65536/360)&65535])
    human.KEYS=48;human.PERIOD=3072;human.poses=lambda:route
    (ROOT/'reports/camera-design.json').write_text(json.dumps(dict(description=ROUTE_DESCRIPTION,posesQ8=route,stationarySegments=[]),indent=2)+'\n',encoding='utf-8')


def report():
    return dict(experimental=True,configuration=CONFIG,geometry=GEOMETRY,planeWorldY=8,openingWidth=10,openingHeight=18,
        states=['closed','opening','open','closing'],travelTicks=72,stepWU=.25,playerHeightWU=12,clearanceWU=.25,
        passableAtLiftWU=12.25,closureSafety='guardian target reverses to open while camera/player occupies passage',
        visibleLeaf='uniform panel retracts into lintel; lower edge in Q8, upper edge clipped at lintel',
        ordering='divider drawn behind guardian from front; in front from back; shared Q8 near/screen clipping and winding',
        collision='manual movement collides with divider outside aperture and with leaf below clearance',
        limits='one bounded plane, one guardian, camera pitch within14degrees; no general intersection solver',
        route=ROUTE_DESCRIPTION)
