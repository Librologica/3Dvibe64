"""A world-space wire actor in the first convex room, native painter ordering.

The actor is resident; immutable compressed poses occupy RAM under I/O.
Pose decoding disables IRQ and I/O briefly and restores both afterwards.
Rendering, projection, room textures, UI pixels and frozen SDK stay intact.
"""
import json,math,re,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'private/q8/src'))
from camera import copy,term,combine
ROOT=Path(__file__).resolve().parents[1]
FACE=36
SHADOW_NEAR=32 # Covers the17.5WU orbit and the first model simplification.
LOD_MEDIUM=28
LOD_FAR=48
ENABLED=True
POSE_TABLES=''
MODEL=json.loads((ROOT/'assets/warrior-model.json').read_text())
ORIGINAL=json.loads((ROOT/'assets/warrior-poses.json').read_text())['poses']
FRAME_IDS=list(range(0,16,2))+list(range(16,32,2))+list(range(32,48))
POSES=[ORIGINAL[i] for i in FRAME_IDS]
EDGES=[];offset=0
for mesh in MODEL['meshes']:
    EDGES += [(a+offset,b+offset) for a,b in mesh['edges']]
    offset+=len(mesh['vertices'])
assert offset==38 and len(EDGES)==52
MEDIUM_EDGES=[EDGES[i] for i in (0,1,3,4,5,7,8,9,10,11,14,15,17,18,20,21,22,23,32,36,37,38,39,40)]
MEDIUM_EDGES += [(17,21),(21,19),(32,35),(35,36),(36,37),(37,35)]
FAR_EDGES=[(0,3),(3,6),(3,7),(7,9),(3,8),(8,10),(0,11),(11,12),(0,14),(14,15),
           (6,17),(17,19),(19,21),(21,17),(26,28),(28,30),(30,26),(32,36)]
LOD_EDGES=(EDGES,MEDIUM_EDGES,FAR_EDGES)
LOD_VERTICES=[sorted({v for e in edges for v in e}) for edges in LOD_EDGES]
assert list(map(len,LOD_EDGES))==[52,30,18]
assert list(map(len,LOD_VERTICES))==[38,29,19]

def lod_info():
    return dict(depthReference='animated pelvis, camera-space Q8 depth',
        mediumWU=LOD_MEDIUM,farWU=LOD_FAR,segments=list(map(len,LOD_EDGES)),
        projectedVertices=list(map(len,LOD_VERTICES)),shadowBelowWU=SHADOW_NEAR)


def data(label,values):
    return label+': .byte '+','.join(str(v&255) for v in values)+'\n'


def packed():
    global POSE_TABLES
    streams=[];indexes=[];bases=[]
    for v in range(38):
        for axis in (0,2,1):
            values=[p[v][axis] for p in POSES];base=min(values)
            stream=tuple(a-base for a in values)
            if stream not in streams:streams.append(stream)
            indexes.append(streams.index(stream)|(128 if max(stream)>15 else 0));bases.append(base)
    result=data('wr_column_stream',indexes)+data('wr_column_base',bases)
    result+='wr_stream_lo: .byte '+','.join(f'<wr_stream{i}' for i in range(len(streams)))+'\n'
    result+='wr_stream_hi: .byte '+','.join(f'>wr_stream{i}' for i in range(len(streams)))+'\n'
    for i,stream in enumerate(streams):
        values=list(stream) if max(stream)>15 else [stream[j]|(stream[j+1]<<4) for j in range(0,32,2)]
        result+=data(f'wr_stream{i}',values)
    POSE_TABLES=result
    result=data('wr_edge0',[a for a,b in EDGES])+data('wr_edge1',[b for a,b in EDGES])
    result+=data('wr_masks',[192,48,12,3])+data('wr_shadow_masks',[207,243,252,255])
    initial=[p[a] for p in POSES[0] for a in (0,2,1)]
    result+=data('wr_coords',initial)
    for label in ('xlo','xhi','ylo','yhi','valid'):result+=f'wr_{label}: .fill 38,0\n'
    for label in ('pose','stage','subtick','age','age_hi','point','coord','format','odd',
                  'edge','dx','dy','signx','signy','major','minor',
                  'remaining','error','axis','depth'):
        result+=f'wr_{label}: .byte 0\n'
    for label in ('xx','yy','delta'):result+=f'wr_{label}: .word 0\n'
    result+=f'wr_enabled: .byte {int(ENABLED)}\nwr_dirty: .byte 1\n'
    result+='wr_divisors: .byte 8,10,10\nwr_first: .byte 0,8,16\nwr_masks_pose: .byte 7,7,15\n'
    (ROOT/'reports/warrior-model.json').write_text(json.dumps(dict(
        sourceVertices=38,edges=52,sourceFrames=48,sampledFrames=32,
        sampledOriginalFrames=FRAME_IDS,compressedStreams=len(streams),
        worldPosition=[4,0,-2.5],scale=.5,feetWorldZ=-10,
        rendering='world-space Q8 wire, original painter, room0 owner',
        palette=f'existing light gray15 highlight; black edge only below{SHADOW_NEAR}WU view depth',
        modelLOD=lod_info(),
        shadowNearWU=SHADOW_NEAR,shadowDepthReference='animated pelvis, camera-space depth as scene LOD',
        occlusion='convex-cell painter; room0 cube and actor share native depth band',
        lifecycle='resident actor; immutable pose tables in RAM under I/O, read with IRQ and I/O disabled'),indent=2))
    return result


def kernel():
    code='''wr_tick:
 inc wr_age
 bne +
 inc wr_age_hi
+
 inc wr_subtick
 ldx wr_stage
 lda wr_subtick
 cmp wr_divisors,x
 bcc wr_tick_exit
 lda #0
 sta wr_subtick
 inc wr_pose
 lda wr_pose
 and wr_masks_pose,x
 ora wr_first,x
 sta wr_pose
 lda #1
 sta wr_dirty
wr_tick_exit:
 lda wr_age_hi
 beq wr_return
 lda wr_stage
 beq wr_next_stage
 lda wr_age
 cmp #64
 bcc wr_return
wr_next_stage:
 lda #0
 sta wr_age
 sta wr_age_hi
 sta wr_subtick
 inc wr_stage
 lda wr_stage
 cmp #3
 bcc +
 lda #0
 sta wr_stage
+
 tax
 lda wr_first,x
 sta wr_pose
 lda #1
 sta wr_dirty
wr_return:
 rts
wr_decode:
 lda wr_dirty
 beq wr_return
 php
 sei
 lda #$34
 sta $01
 jsr wr_decode_columns
 lda #$35
 sta $01
 plp
 rts
wr_decode_columns:
 lda #0
 sta wr_dirty
 lda wr_pose
 and #1
 sta wr_odd
 ldx #113
wr_decode_column:
 stx wr_coord
 lda wr_column_stream,x
 sta wr_format
 and #127
 tay
 lda wr_stream_lo,y
 sta ptr0lo
 lda wr_stream_hi,y
 sta ptr0hi
 ldy wr_pose
 lda wr_format
 bmi wr_full_column
 tya
 lsr
 tay
 lda (ptr0lo),y
 ldy wr_odd
 beq wr_low_nibble
 lsr
 lsr
 lsr
 lsr
wr_low_nibble:
 and #15
 jmp wr_save_column
wr_full_column:
 lda (ptr0lo),y
wr_save_column:
 ldx wr_coord
 clc
 adc wr_column_base,x
 sta wr_coords,x
 dex
 bpl wr_decode_column
 rts
wr_project:
 lda #0
 sta wr_point
wr_project_point:
 jsr wr_project_needed
 beq wr_project_next
'''
    for axis,center in zip('xyz',(4,-2,0)):
        half_shift=' sec\n sbc #1\n' if axis=='y' else ''
        code+=f''' ldy wr_coord
 lda wr_coords,y
{half_shift} and #1
 lsr
 ror
 sta qc_{axis}
 lda wr_coords,y
{half_shift} cmp #128
 ror
 clc
 adc #{center&255}
 sta qc_{axis}+1
 cmp #128
 lda #0
 sbc #0
 eor #255
 sta qc_{axis}+2
 sec
'''
        for i,suffix in enumerate(('lo','hi','ext')):
            code+=f' lda qc_{axis}+{i}\n sbc explorer_cam_{axis}_{suffix}\n sta qc_{axis}+{i}\n'
        code+=' inc wr_coord\n'
    code+=''' lda explorer_cam_yaw
 ora qc_demo_yaw_lo
 beq wr_pitch
'''
    code+=term('qc_x','qc_yc','qc_t0')+term('qc_z','qc_ys','qc_t1')+combine('qc_t0','qc_t1','qc_tx',True)
    code+=term('qc_x','qc_ys','qc_t0')+term('qc_z','qc_yc','qc_t1')+combine('qc_t0','qc_t1','qc_z')+copy('qc_tx','qc_x')
    code+='wr_pitch:\n lda explorer_cam_pitch\n ora qc_demo_pitch_lo\n beq wr_project_depth\n'
    code+=term('qc_y','qc_pc','qc_t0')+term('qc_z','qc_ps','qc_t1')+combine('qc_t0','qc_t1','qc_ty',True)
    code+=term('qc_y','qc_ps','qc_t0')+term('qc_z','qc_pc','qc_t1')+combine('qc_t0','qc_t1','qc_z')+copy('qc_ty','qc_y')
    code+='''wr_project_depth:
 ldx wr_point
 lda qc_z+1
 cpx #0
 bne +
 sta wr_depth
 jsr wr_set_shadow
+
 lda #0
 sta wr_valid,x
 lda qc_z+2
 bmi wr_project_next
 bne wr_positive_depth
 lda qc_z+1
 beq wr_project_next
wr_positive_depth:
 lda #1
 sta wr_valid,x
'''+copy('qc_z','hc_depth')
    for axis,index in (('x',0),('y',1)):
        code+=copy('qc_'+axis,'hc_coord')+f' lda #{index}\n sta hc_axis\n jsr hc_project_axis\n ldx wr_point\n lda hc_integer\n sta wr_{axis}lo,x\n lda hc_integer+1\n sta wr_{axis}hi,x\n'
    code+='''wr_project_next:
 inc wr_point
 lda wr_point
 cmp #38
 bne wr_project_point
 rts
wr_collect:
 lda wr_enabled
 beq wr_return_far
 jsr wr_decode
 jsr wr_project
 lda wr_depth
 lsr
 lsr
 sta p1lo
 jmp bvf_depth_ready
wr_return_far:
 rts
wr_draw:
 lda #0
 sta wr_edge
wr_draw_edge:
 ldx wr_edge
wr_edge_load0:
 lda wr_edge0,x
 tax
 lda wr_valid,x
 beq wr_next_edge
 lda wr_xlo,x
 sta wr_xx
 lda wr_xhi,x
 sta wr_xx+1
 lda wr_ylo,x
 sta wr_yy
 lda wr_yhi,x
 sta wr_yy+1
 ldx wr_edge
wr_edge_load1:
 lda wr_edge1,x
 tax
 lda wr_valid,x
 beq wr_next_edge
'''
    for axis,position,delta in [('x','xx','dx'),('y','yy','dy')]:
        code+=f''' sec
 lda wr_{axis}lo,x
 sbc wr_{position}
 sta wr_delta
 lda wr_{axis}hi,x
 sbc wr_{position}+1
 sta wr_delta+1
 lda #1
 sta wr_sign{axis}
 lda wr_delta+1
 bpl wr_positive_{axis}
 lda #255
 sta wr_sign{axis}
 sec
 lda #0
 sbc wr_delta
 sta wr_delta
 lda #0
 sbc wr_delta+1
 sta wr_delta+1
wr_positive_{axis}:
 lda wr_delta+1
 bne wr_next_edge
 lda wr_delta
 sta wr_{delta}
'''
    code+=''' lda #0
 sta wr_axis
 lda wr_dx
 cmp wr_dy
 bcs wr_x_major
 inc wr_axis
 lda wr_dy
 sta wr_major
 lda wr_dx
 sta wr_minor
 jmp wr_line_begin
wr_x_major:
 sta wr_major
 lda wr_dy
 sta wr_minor
wr_line_begin:
 lda wr_major
 sta wr_remaining
 lsr
 sta wr_error
wr_line_pixel:
 jsr wr_plot
 lda wr_remaining
 beq wr_next_edge
 dec wr_remaining
 lda wr_axis
 bne wr_main_y
 jsr wr_step_x
 jmp wr_minor_step
wr_main_y:
 jsr wr_step_y
wr_minor_step:
 sec
 lda wr_error
 sbc wr_minor
 sta wr_error
 bcs wr_line_pixel
 clc
 adc wr_major
 sta wr_error
 lda wr_axis
 bne wr_minor_x
 jsr wr_step_y
 jmp wr_line_pixel
wr_minor_x:
 jsr wr_step_x
 jmp wr_line_pixel
wr_next_edge:
 inc wr_edge
 lda wr_edge
wr_edge_limit:
 cmp #52
 bne wr_draw_edge
 rts
'''
    for axis,position in [('x','xx'),('y','yy')]:
        code+=f'''wr_step_{axis}:
 lda wr_sign{axis}
 bmi wr_decrement_{axis}
 inc wr_{position}
 bne +
 inc wr_{position}+1
+
 rts
wr_decrement_{axis}:
 lda wr_{position}
 bne +
 dec wr_{position}+1
+
 dec wr_{position}
 rts
'''
    code+='''wr_plot:
 lda wr_xx+1
 ora wr_yy+1
 bne wr_plot_return
 lda wr_xx
 cmp #160
 bcs wr_plot_return
 lda wr_yy
 cmp #100
 bcs wr_plot_return
 tax
 lda drawbuf
 bne wr_plot_b
 lda row0lo_a,x
 sta ptr0lo
 lda row0hi_a,x
 sta ptr0hi
 lda row1lo_a,x
 sta ptr1lo
 lda row1hi_a,x
 sta ptr1hi
 jmp wr_plot_ready
wr_plot_b:
 lda row0lo_b,x
 sta ptr0lo
 lda row0hi_b,x
 sta ptr0hi
 lda row1lo_b,x
 sta ptr1lo
 lda row1hi_b,x
 sta ptr1hi
wr_plot_ready:
 lda wr_xx
 cmp #128
 bcc +
 inc ptr0hi
 inc ptr1hi
+
 lda wr_xx
 lsr
 lsr
 asl
 asl
 asl
 tay
 lda wr_xx
 and #3
 tax
 lda (ptr0lo),y
wr_shadow0:
 and wr_shadow_masks,x
 ora wr_masks,x
 sta (ptr0lo),y
 lda (ptr1lo),y
wr_shadow1:
 and wr_shadow_masks,x
 ora wr_masks,x
 sta (ptr1lo),y
wr_cross_test:
 cpx #3
 bne wr_plot_return
 lda wr_xx
 cmp #159
 beq wr_plot_return
 tya
 clc
 adc #8
 bcc +
 inc ptr0hi
 inc ptr1hi
+
 tay
 lda (ptr0lo),y
 and #63
 sta (ptr0lo),y
 lda (ptr1lo),y
 and #63
 sta (ptr1lo),y
wr_plot_return:
 rts
'''
    return code+packed()


def scene(create):
    def make():
        path,stats=create();doc=json.loads(path.read_text());m=doc['meshes'][0]
        m['faces'].append(m['faces'][26].copy())
        for field in ('faceUV','faceTextures','faceMaterials'):
            m[field].append(m[field][26])
        stats['ranges'][0]['end']+=1
        for r in stats['ranges'][1:]:
            for k in ('first','end','cubeFirst'):r[k]+=1
        stats['connectors']=[[f+int(f>=FACE) for f in fs] for fs in stats['connectors']]
        stats['triangles']+=1
        doc['warrior']=dict(room=0,position=[4,0,-2.5],scale=.5,painterFace=FACE,
            topology='synthetic painter node; world-space actor geometry is not the binding triangle')
        path.write_text(json.dumps(doc,indent=2));(ROOT/'reports/scene.json').write_text(json.dumps(stats,indent=2))
        return path,stats
    return make


def configure_tour(human_tour):
    original=human_tour.poses
    old=original();new=[]
    first=math.atan2(-7-4,-9)
    for i in range(24):
        angle=first+i*math.tau/24;x=4+17.5*math.sin(angle);z=17.5*math.cos(angle)
        yaw=-math.atan2(4-x,-z)
        pitch=math.atan2(.8,17.5)
        new.append([round(x*256),0,round(z*256),round(yaw*65536/math.tau)&65535,round(pitch*65536/math.tau)&65535])
    new+=old
    assert len(new)==120
    human_tour.KEYS=120;human_tour.PERIOD=7680;human_tour.poses=lambda:new
    for i,p in enumerate(new[:24]):
        x,z=p[0]/256,p[2]/256
        assert -23<x<23 and -23<z<22
    (ROOT/'reports/orbit.json').write_text(json.dumps(dict(center=[4,0,-.8],radiusWU=17.5,
        orbitKeys=24,ticksPerKey=64,orbitNominalSeconds=30.72,wholeTourKeys=120,
        wholeTourTicks=7680,originalTourKeysPreserved=96,
        gaze='continuous yaw around warrior; fractional Q8 camera angles',posesQ8=new),indent=2))


def adapt(source,parts):
    # Mode7 uses its texture compositor; all three flat cubes dispatch only
    # fill_bounds_solid_a/b. The legacy patterned Mode4 drawers have no live
    # caller in this closed profile. Keep trap aliases and conditional ABI.
    for label,last in [('fill_bounds_pattern_a','fbp_a_done'),('fill_bounds_pattern_b','fbp_b_done')]:
        a=source.index(label+':\n');b=source.index(last+':\n rts\n',a)+len(last+':\n rts\n')
        replacement='; Patterned Mode4 fill is unreachable in this private Mode7 profile.\n'
        for line in source[a:b].splitlines():
            m=re.match(r'^(\w+):',line)
            if m:replacement+=m[1]+' = hp_unreachable\n'
            elif line.strip().startswith(('.if ','.else','.elsif ','.endif')):replacement+=line+'\n'
        source=source[:a]+replacement+source[b:]
    assert not any(k.startswith('ui_') for k in parts)
    parts['warrior']='wr_overlay_begin:\n'+kernel()+'wr_overlay_end:\n'
    # The binding face is enqueued without triangle clipping/culling; render
    # strokes use the actual animated coordinates, never this dummy topology.
    source=source.replace('load_face_visible:\n',f'load_face_visible:\n lda faceidx\n cmp #{FACE}\n bne +\n jmp wr_collect\n+\n')
    source=source.replace('ddb_face_loop:\n',f'ddb_face_loop:\n lda sortj\n cmp #{FACE}\n bne +\n jsr wr_draw\n jmp ddb_after_draw\n+\n')
    source=source.replace('advance_sim_tick:\n','advance_sim_tick:\n jsr wr_tick\n')
    # Sort the stationary room0 cube and warrior in the same bounded depth
    # band. Other cell rankings and original dynamic cube stay unchanged.
    old='co_depth_loaded:\n cpx #107\n bcc tr_depth_done\n'
    new='co_depth_loaded:\n cpx #26\n bcc tr_depth_done\n cpx #37\n bcc wr_depth_band\n cpx #107\n bcc tr_depth_done\nwr_depth_band:\n'
    assert source.count(old)==1;source=source.replace(old,new)
    assert ' jsr game_ui_init\n' not in source
    # Decide once from the projected pelvis. Far strokes keep OR highlight,
    # replace AND abs,X by BIT abs, and skip the adjacent-byte black pixel.
    # BIT only changes dead flags. No IRQ renders or enters this selector.
    parts['wr_installer']=f'''wr_installer:
wr_set_shadow:
 jsr wr_select_lod
 lda qc_z+2
 bne wr_shadow_far
 lda qc_z+1
 cmp #{SHADOW_NEAR}
 bcs wr_shadow_far
 lda #$3d
 bne wr_shadow_bind
wr_shadow_far:
 lda #$2c
wr_shadow_bind:
 sta wr_shadow0
 sta wr_shadow1
 and #1
 eor #1
 clc
 adc #3
 sta wr_cross_test+1
 rts
wr_select_lod:
 lda qc_z+2
 bne wr_choose_far
 lda qc_z+1
 cmp #{LOD_FAR}
 bcs wr_choose_far
 cmp #{LOD_MEDIUM}
 bcs wr_choose_medium
 ldy #0
 beq wr_bind_lod
wr_choose_medium:
 ldy #1
 bne wr_bind_lod
wr_choose_far:
 ldy #2
wr_bind_lod:
 sty wr_lod
 lda wr_lod_edge0_lo,y
 sta wr_edge_load0+1
 lda wr_lod_edge0_hi,y
 sta wr_edge_load0+2
 lda wr_lod_edge1_lo,y
 sta wr_edge_load1+1
 lda wr_lod_edge1_hi,y
 sta wr_edge_load1+2
 lda wr_lod_counts,y
 sta wr_edge_limit+1
 lda wr_lod_masks,y
 sta wr_vertex_mask+1
 rts
wr_project_needed:
 ldx wr_point
 txa
 asl
 clc
 adc wr_point
 sta wr_coord
 lda wr_vertex_used,x
wr_vertex_mask:
 and #1
 rts
wr_lod: .byte 0
wr_lod_counts: .byte 52,30,18
wr_lod_masks: .byte 1,2,4
wr_lod_edge0_lo: .byte <wr_edge0,<wr_medium0,<wr_far0
wr_lod_edge0_hi: .byte >wr_edge0,>wr_medium0,>wr_far0
wr_lod_edge1_lo: .byte <wr_edge1,<wr_medium1,<wr_far1
wr_lod_edge1_hi: .byte >wr_edge1,>wr_medium1,>wr_far1
'''
    parts['wr_installer']+=data('wr_vertex_used',[sum(1<<i for i,vertices in enumerate(LOD_VERTICES) if v in vertices) for v in range(38)])
    for name,edges in [('medium',MEDIUM_EDGES),('far',FAR_EDGES)]:
        for axis in (0,1):parts['wr_installer']+=data(f'wr_{name}{axis}',[e[axis] for e in edges])
    return source,parts


def post(source):
    assert POSE_TABLES
    return source+'\n*=$d000\nwr_pose_tables_begin:\n'+POSE_TABLES+'''wr_pose_tables_end:
 .cerror * > $e000,"Pose tables exceed RAM under I/O"
wr_payload_end = *
'''
