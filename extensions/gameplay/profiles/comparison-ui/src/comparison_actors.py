"""Original 3D skeleton/sword and masked billboard in one closed room.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import json,re
import warrior_room as wire
import billboard_room as bb
from single_room import WIRE_FACE,BILLBOARD_FACE
ENABLED=True
WIRE_ENABLED=True
BB_ENABLED=True

def adapt(source,parts):
    for label,last in [('fill_bounds_pattern_a','fbp_a_done'),('fill_bounds_pattern_b','fbp_b_done')]:
        a=source.index(label+':\n');b=source.index(last+':\n rts\n',a)+len(last+':\n rts\n')
        replacement='; Unreachable patterned Mode4 fill in this private Mode7 scene.\n'
        for line in source[a:b].splitlines():
            m=re.match(r'^(\w+):',line)
            if m:replacement+=m[1]+' = hp_unreachable\n'
            elif line.strip().startswith(('.if ','.else','.elsif ','.endif')):replacement+=line+'\n'
        source=source[:a]+replacement+source[b:]
    wire.ENABLED=WIRE_ENABLED
    code=wire.kernel()
    old='adc #4\n sta qc_x+1';assert code.count(old)==1
    code=code.replace(old,'adc #249\n sta qc_x+1')
    code=code.replace('cmp #160\n bcs wr_plot_return','cmp #96\n bcs wr_plot_return').replace('cmp #100\n bcs wr_plot_return','cmp #60\n bcs wr_plot_return').replace('cmp #159\n beq wr_plot_return','cmp #95\n beq wr_plot_return')
    code+='''wr_set_shadow:
 rts
wr_project_needed:
 lda wr_point
 asl
 clc
 adc wr_point
 sta wr_coord
 lda #1
 rts
'''
    parts['skeleton']='wr_code_begin:\n'+code+'wr_code_end:\n'
    # The compressed skeleton tables fit resident RAM after removing two
    # rooms and all cubes; only billboard source frames occupy RAM under I/O.
    parts['skeleton_poses']='wr_pose_tables_begin:\n'+wire.POSE_TABLES+'wr_pose_tables_end:\n'
    path=wire.ROOT/'reports/warrior-model.json'
    report=json.loads(path.read_text())
    report.update(worldPosition=[-7,0,-2.5],modelLOD=False,projectedVertices=38,
        shadow='black adjacent edge at all comparison distances',
        occlusion='single closed convex room; actor node ordered against billboard by depth',
        lifecycle='resident code/state and compressed pose tables; decoder preserves existing IRQ banking convention')
    for field in ('shadowNearWU','shadowDepthReference'):report.pop(field,None)
    path.write_text(json.dumps(report,indent=2))
    bb.ENABLED=BB_ENABLED
    code,state=bb.kernel()
    old='lda #4\n sta qc_x+1';assert code.count(old)==1
    code=code.replace(old,'lda #7\n sta qc_x+1')
    a=code.index(' lda bb_phase\n lsr\n lsr\n lsr\n tax\n clc\n lda qc_x\n')
    b=code.index(' sec\n',a)
    code=code[:a]+code[b:] # Fixed world anchor, no sideways drift.
    code=code.replace('cmp #160\n bcs bb_plot_done','cmp #96\n bcs bb_plot_done').replace('cmp #100\n bcs bb_plot_done','cmp #60\n bcs bb_plot_done')
    parts['billboard']='bb_code_begin:\n'+code+'bb_code_end:\n'
    parts['bb_state']=state
    parts['bb_pixels']='bb_pixels: .fill 512,0\n'
    source=source.replace('load_face_visible:\n',f'''load_face_visible:
 lda faceidx
 cmp #{WIRE_FACE}
 bne +
 jmp wr_collect
+
 cmp #{BILLBOARD_FACE}
 bne +
 jmp bb_collect
+
''')
    source=source.replace('ddb_face_loop:\n',f'''ddb_face_loop:
 lda sortj
 cmp #{WIRE_FACE}
 bne +
 jsr wr_draw
 jmp ddb_after_draw
+
 cmp #{BILLBOARD_FACE}
 bne +
 jsr bb_draw
 jmp ddb_after_draw
+
''')
    source=source.replace('advance_sim_tick:\n','advance_sim_tick:\n jsr wr_tick\n jsr bb_tick\n')
    return source,parts

post=bb.post
