"""Verified binding of conservative sector connectivity to the bounded room."""
import json
from pathlib import Path
import visibility_compiler as compiler
import light_baker
import gameplay_profile
import billboard_multiple
ROOT=Path(__file__).resolve().parents[1]
REPORT=None
CAMERA={}
LEVEL_KEYS=list(range(5))+list(range(24,29))+list(range(44,48))


def configure_tour(human):
    global CAMERA
    config=json.loads((ROOT/'assets/visibility.json').read_text(encoding='utf-8-sig'))
    compiler.validate(config)
    if not config['enabled']:return
    route=[pose.copy() for pose in human.poses()]
    for key in LEVEL_KEYS:route[key][4]=0
    human.poses=lambda:[pose.copy() for pose in route]
    p=ROOT/'reports/camera-design.json';design=json.loads(p.read_text(encoding='utf-8-sig'))
    CAMERA=dict(description=design['description']+'; level gaze in visibility demonstration segments; other vertical sweeps retained',levelGazeKeys=LEVEL_KEYS)
    design.update(CAMERA,posesQ8=route)
    p.write_text(json.dumps(design,indent=2)+'\n',encoding='utf-8')


def configure(path):
    global REPORT
    config=json.loads((ROOT/'assets/visibility.json').read_text(encoding='utf-8-sig'))
    compiler.validate(config)
    scene=json.loads(path.read_text(encoding='utf-8-sig')); mesh=scene['meshes'][0]
    light_baker.geometry(scene) # identity placement, exact Q8 triangles
    if compiler.digest([mesh['vertices'],mesh['faces']])!='89DAF2105CDC45BFE90BF3BEA76DD27DA0FE0D8811EFAC8392A5EBF5C013D12B':
        raise ValueError('Visibility binding requires the sealed outer shell, divider and retracting leaf geometry')
    expected=dict(worldBounds=[[-24,24],[-24,24],[-10,18]],
        sectors=[dict(id='front',bounds=[[-24,24],[-24,8],[-10,18]]),dict(id='rear',bounds=[[-24,24],[8,24],[-10,18]])],
        doors=['guardian-door'],portals=[dict(id='passage',sectors=['front','rear'],bounds=[[-5,5],[8,8],[-10,8]],door='guardian-door')])
    if any(config[k]!=v for k,v in expected.items()):raise ValueError('Native adapter requires exactly the two sealed cells and the actual door aperture')
    # Validator proves the complete animated view-facing rectangle is in front
    # of the divider for every supported pitch, including source outline.
    billboard_multiple.validate(gameplay_profile.CONFIG,gameplay_profile.ASSET)
    vertices=[tuple(round(p[a]*256) for a in (0,2,1)) for p in mesh['vertices']]
    payload,REPORT=compiler.compile_pvs(config,vertices,mesh['faces'],{14:1,15:1})
    assert compiler.decode(payload)['PVS']==REPORT['PVS']
    REPORT.update(nativeScope='one fixed divider, two sealed rectangular cells, one retracting opaque door; both actor envelopes in front',
        classifier='cardinal yaw0/180 and pitch0 only; full sign-extended Q8 camera inside envelope, >8WU from divider; all sectors elsewhere',
        rasterSafety='oblique projection may expose legacy shell/divider edge seams; all sectors retained for every other view angle',
        nearSafety='4WU near depth times sqrt(1+(48/41)^2+(30/41)^2) <8WU; full viewport and pitch/yaw rotations bounded',
        doorPolicy='closed only if both bytes of dr_lift are zero; any nonzero opening connects cells',
        compilerLimits=dict(sectors=8,doors=4,portals=16),angularCulling=False)
    (ROOT/'reports/visibility.bin').write_bytes(payload)
    (ROOT/'reports/visibility.json').write_text(json.dumps(REPORT,indent=2)+'\n',encoding='utf-8')


def adapt(source,parts):
    if not REPORT['configuration']['enabled']:return source,parts
    old='collect_active_mesh_faces:\n'
    if source.count(old)!=1:raise ValueError('Visibility prepare ABI changed')
    source=source.replace(old,old+' jsr vs_prepare\n',1)
    old=' jsr load_face_visible\ndm_skip:\n'
    if source.count(old)!=1:raise ValueError('Visibility collection ABI changed')
    source=source.replace(old,' jsr vs_test\n bcc dm_skip\n'+old,1)
    code='''vs_prepare:
 lda #3
 sta vs_mask
 lda #255
 sta vs_sector
 sta vs_row
 lda #0
 sta vs_rejected
 lda vs_enabled
 bne +
 rts
+
 lda explorer_cam_pitch
 ora qc_demo_pitch_lo
 beq +
 rts
+
 lda qc_demo_yaw_lo
 beq +
 rts
+
 lda explorer_cam_yaw
 and #127
 beq +
 rts
+
'''
    for axis,low,high in [('x',-23,24),('y',-9,18),('z',-23,24)]:
        code+=f''' lda explorer_cam_{axis}_hi
 and #128
 beq +
 lda #255
+
 cmp explorer_cam_{axis}_ext
 bne vs_done
 lda explorer_cam_{axis}_hi
 eor #128
 cmp #{low+128}
 bcc vs_done
 cmp #{high+128}
 bcs vs_done
'''
    code+=''' ldx #0
 lda explorer_cam_z_hi
 bmi vs_classified
 cmp #17
 bcc vs_done
 inx
vs_classified:
 stx vs_sector
 lda dr_lift
 ora dr_lift+1
 beq +
 inx
 inx
+
 stx vs_row
 lda vs_pvs,x
 sta vs_mask
vs_done:
 rts
vs_test:
 ldx faceidx
 lda vs_face_sectors,x
 and vs_mask
 bne vs_accept
 inc vs_rejected
 clc
 rts
vs_accept:
 sec
 rts
'''
    parts['sector_visibility']=code
    def data(label,values):return label+': .byte '+','.join(map(str,values))+'\n'
    parts['sector_visibility_data']=data('vs_enabled',[int(REPORT['configuration']['culling'])])+data('vs_mask',[3])+data('vs_sector',[255])+data('vs_row',[255])+data('vs_rejected',[0])+data('vs_face_sectors',REPORT['faceMasks'])+data('vs_pvs',[v for row in REPORT['PVS'] for v in row])
    return source,parts


def report():return dict(sectorVisibility=REPORT)
