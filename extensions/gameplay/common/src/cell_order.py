"""Checked linear five-convex-cell painter for this private three-room demo.
Required Notice:3Dvibe64. PolyForm Noncommercial1.0.0. No engine changes.
"""
import json,math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def generate(scene,stats):
    owners=[];solid=[];bounds=[]
    for ri,(obj,mesh,rng,connectors) in enumerate(zip(scene['objects'][:3],scene['meshes'][:3],stats['ranges'],stats['connectors'])):
        assert obj['rotation']==[0,0,0] and obj['angularVelocity']==[0,0,0] and obj['scale']==1
        def world(v):
            x,y,z=mesh['vertices'][v];p=obj['position'];return (x+p[0],y+p[2],z+p[1])
        shell=[fi for fi in range(rng['first'],rng['cubeFirst']) if fi not in connectors]
        points=[world(v) for fi in shell for v in mesh['faces'][fi-rng['first']]]
        box=[(min(p[a] for p in points),max(p[a] for p in points)) for a in range(3)]
        assert box[:2]==[(-24,24),(-10,18)],box
        bounds.append(box[2])
        for fi in range(rng['first'],rng['end']):
            is_cube=fi>=rng['cubeFirst'];is_connector=fi in connectors
            owners.append(2*ri+int(is_connector));solid.append(is_cube)
            points=[world(v) for v in mesh['faces'][fi-rng['first']]]
            if is_cube:assert all(all(box[a][0]<=p[a]<=box[a][1] for a in range(3)) for p in points)
            elif not is_connector:
                assert any(all(p[a]==edge for p in points) for a in range(3) for edge in box[a]),('non-convex shell',fi)
    assert bounds==[(-24,23),(25,71),(137,184)],bounds
    assert len(owners)==107
    # Every connector is a convex axis-aligned corridor joining two rooms.
    for ri,ids in enumerate(stats['connectors'][:2]):
        obj=scene['objects'][ri];mesh=scene['meshes'][ri];first=stats['ranges'][ri]['first']
        for fi in ids:
            points=[(mesh['vertices'][v][0]+obj['position'][0],mesh['vertices'][v][1]+obj['position'][2],mesh['vertices'][v][2]+obj['position'][1]) for v in mesh['faces'][fi-first]]
            assert all(-7<=p[0]<=7 and -10<=p[1]<=18 and bounds[ri][1]<=p[2]<=bounds[ri+1][0] for p in points)
            assert any(all(p[a]==edge for p in points) for a,edges in ((0,(-7,7)),(1,(-10,18))) for edge in edges)
    obj=scene['objects'][3];mesh=scene['meshes'][3]
    assert obj['mesh']=='central-cube' and obj['position']==[0,160,4] and obj['scale']==1
    radius=max(math.sqrt(sum(x*x for x in p)) for p in mesh['vertices'])
    assert radius<7 and 137<160-radius and 160+radius<184 and -10<4-radius and 4+radius<18
    owners += [4]*len(mesh['faces']);solid += [True]*len(mesh['faces'])
    # Higher bucket is drawn first. A cube is after its own shell, but before
    # every cell closer to the camera. Preserve native depth within a bounded
    # 16-bucket band for the rotating cube; never wrap the ordering byte.
    tables=[]
    for current in range(5):
        tables.append([80+35*abs(owner-current)-(30 if cube else 0) for owner,cube in zip(owners,solid)])
    code='co_cell: .byte 0\nco_depth_base: .byte 0\n'
    code+=''.join(f'co_depth{i}: .byte '+','.join(map(str,t))+'\n' for i,t in enumerate(tables))
    code+='''co_select_cell:
 lda explorer_cam_z_ext
 bmi co_room0
 lda explorer_cam_z_hi
 cmp #23
 bcc co_room0
 cmp #25
 bcc co_corridor0
 cmp #71
 bcc co_room1
 cmp #137
 bcc co_corridor1
 lda #4
 bne co_save_cell
co_room0:
 lda #0
 beq co_save_cell
co_corridor0:
 lda #1
 bne co_save_cell
co_room1:
 lda #2
 bne co_save_cell
co_corridor1:
 lda #3
co_save_cell:
 sta co_cell
 rts
'''
    report=dict(scope='Private checked linear convex-cell chain only',bounds=[bounds[0],[23,25],bounds[1],[71,137],bounds[2]],
        faceOwners=owners,solidFaces=solid,depthTables=tables,tableBytes=len(owners)*5,stateBytes=2,
        signed24CameraClassification=True,centralDepthBand=[0,15],cameraTourUnchanged=True)
    (ROOT/'reports/cell-order.json').write_text(json.dumps(report,indent=2))
    return code

def hooks(source):
    a=source.index('bvf_depth_ready:\n');b=source.index(' sta p1lo\n',source.index('tr_depth_done:\n',a))+len(' sta p1lo\n')
    source=source[:a]+'''bvf_depth_ready:
 ldx faceidx
 lda co_cell
 beq co_depth0_read
 cmp #1
 beq co_depth1_read
 cmp #2
 beq co_depth2_read
 cmp #3
 beq co_depth3_read
 lda co_depth4,x
 jmp co_depth_loaded
co_depth0_read:
 lda co_depth0,x
 jmp co_depth_loaded
co_depth1_read:
 lda co_depth1,x
 jmp co_depth_loaded
co_depth2_read:
 lda co_depth2,x
 jmp co_depth_loaded
co_depth3_read:
 lda co_depth3,x
co_depth_loaded:
 cpx #107
 bcc tr_depth_done
 sta co_depth_base
 lda p1lo
 lsr
 lsr
 cmp #16
 bcc co_central_band
 lda #15
co_central_band:
 clc
 adc co_depth_base
tr_depth_done:
 sta p1lo
'''+source[b:]
    assert source.count('begin_depth_buckets:\n')==1
    return source.replace('begin_depth_buckets:\n','begin_depth_buckets:\n jsr co_select_cell\n',1)
