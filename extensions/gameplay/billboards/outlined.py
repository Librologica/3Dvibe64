"""Private masked billboard, one checked convex room; no public SDK changes.

Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. Original character artwork, no third-party assets.
"""
import json, math, re
from pathlib import Path
import warrior_room as binding
from warrior_room import copy, term, combine

ROOT=Path(__file__).resolve().parents[1]
ENABLED=True
FACE=36

def scene(create):
    previous=binding.scene(create)
    def make():
        path,stats=previous()
        doc=json.loads(path.read_text())
        doc['billboard']=doc.pop('warrior')
        doc['billboard'].update(position=[4,0,-2.5],worldSize=[6,16],bodyHeight=15,frames=6,
            rendering='screen-aligned masked nearest-neighbor, convex-cell painter')
        path.write_text(json.dumps(doc,indent=2))
        return path,stats
    return make

configure_tour=binding.configure_tour

def artwork():
    """16x32: 0 transparent, 1..3 color, 4 opaque black silhouette outline.

    Index4 is deliberately different from transparent0. The bitmap writer
    masks opaque texels with3, so4 writes VIC-II background color0 (black).
    """
    frames=[]
    for frame in range(6):
        p=[[0]*16 for _ in range(32)]
        def rect(x0,y0,x1,y1,c):
            for y in range(y0,y1+1):
                for x in range(x0,x1+1):
                    if 0<=x<16 and 0<=y<32:p[y][x]=c
        # Helmet, face, eyes, breastplate and belt. Clear pixels separate limbs.
        rect(5,1,10,2,2);rect(4,3,11,6,2);rect(5,3,10,4,3)
        rect(5,6,10,8,1);rect(5,6,5,6,3);rect(10,6,10,6,3)
        rect(6,9,9,10,1);rect(4,11,11,18,2);rect(5,11,9,15,3)
        rect(7,12,7,17,2);rect(4,19,11,20,1);rect(7,19,8,20,3)
        if frame<4:
            d=(0,1,0,-1)[frame]
            rect(2,12+d,3,20+d,2);rect(2,21+d,3,22+d,1)
            rect(12,12-d,13,20-d,2);rect(12,21-d,13,22-d,1)
            rect(4,21,6,28+d,2);rect(9,21,11,28-d,2)
            rect(3,29+d,6,30+d,1);rect(9,29-d,12,30-d,1)
        else:
            # Raised hands: two alert poses when the camera enters the trigger.
            d=frame-4
            rect(2,8+d,3,15,2);rect(1,6+d,3,8+d,1)
            rect(12,8-d,13,15,2);rect(12,6-d,14,8-d,1)
            rect(4,21,6,29,2);rect(9,21,11,29,2)
            rect(3,30,6,31,1);rect(9,30,12,31,1)
        # Fit each animated silhouette into rows1..30. Reserve a complete
        # transparent border before dilation, including below the feet.
        bottom=max(y for y,row in enumerate(p) if any(row))
        body=[[0]*16]+[p[1+round(y*(bottom-1)/29)][:] for y in range(30)]+[[0]*16]
        outlined=[row[:] for row in body]
        for y in range(32):
            for x in range(16):
                if body[y][x]:continue
                if any(body[ny][nx] for ny in range(max(0,y-1),min(32,y+2))
                       for nx in range(max(0,x-1),min(16,x+2))):
                    outlined[y][x]=4
        frames.append([v for row in outlined for v in row])
    assert all(len(p)==512 and set(p)=={0,1,2,3,4} for p in frames)
    (ROOT/'assets/billboard-frames.json').write_text(json.dumps(dict(
        width=16,height=32,transparentIndex=0,opaqueBlackIndex=4,paletteVICII=[0,9,12,15,0],
        outline=dict(color='black',VICIIColor=0,radiusSourcePixels=1,neighbors=8,
                     includesFeet=True,transparentExterior=True),
        names=['walk0','walk1','walk2','walk3','alert0','alert1'],frames=frames),indent=2))
    return frames

def data(label,values):
    return label+': .byte '+','.join(str(v&255) for v in values)+'\n'

def kernel():
    code='''bb_tick:
 inc bb_phase
 rts
bb_collect:
 lda bb_enabled
 bne +
 rts
+
'''
    # Colored body: 30/32 of a16WU plane =15WU, like the skeleton.
    # Body head+5 and feet-10; the black contour extends0.5WU beyond each.
    # The comparison adapter removes the legacy lateral walking offset.
    for axis,center in zip('xyz',(4,-2.5,0)):
        q=round(center*256)
        code+=f' lda #{q&255}\n sta qc_{axis}\n lda #{(q>>8)&255}\n sta qc_{axis}+1\n lda #{(q>>16)&255}\n sta qc_{axis}+2\n'
        if axis=='x':
            code+=''' lda bb_phase
 lsr
 lsr
 lsr
 tax
 clc
 lda qc_x
 adc bb_walk_lo,x
 sta qc_x
 lda qc_x+1
 adc bb_walk_hi,x
 sta qc_x+1
'''
        code+=' sec\n'
        for i,suffix in enumerate(('lo','hi','ext')):
            code+=f' lda qc_{axis}+{i}\n sbc explorer_cam_{axis}_{suffix}\n sta qc_{axis}+{i}\n'
    code+=''' lda #0
 sta bb_alert
'''
    for axis in 'xz':
        code+=f''' lda qc_{axis}+2
 bmi bb_near_negative_{axis}
 bne bb_far
 lda qc_{axis}+1
 cmp #12
 bcs bb_far
 jmp bb_near_ok_{axis}
bb_near_negative_{axis}:
 cmp #255
 bne bb_far
 lda qc_{axis}+1
 cmp #244
 bcc bb_far
bb_near_ok_{axis}:
'''
    code+=''' inc bb_alert
bb_far:
 lda bb_phase
 lsr
 lsr
 lsr
 ldx bb_alert
 beq bb_walk_frame
 and #1
 ora #4
 bne bb_frame_ready
bb_walk_frame:
 and #3
bb_frame_ready:
 sta bb_frame
 lda explorer_cam_yaw
 ora qc_demo_yaw_lo
 beq bb_pitch
'''
    code+=term('qc_x','qc_yc','qc_t0')+term('qc_z','qc_ys','qc_t1')+combine('qc_t0','qc_t1','qc_tx',True)
    code+=term('qc_x','qc_ys','qc_t0')+term('qc_z','qc_yc','qc_t1')+combine('qc_t0','qc_t1','qc_z')+copy('qc_tx','qc_x')
    code+='bb_pitch:\n lda explorer_cam_pitch\n ora qc_demo_pitch_lo\n beq bb_depth_test\n'
    code+=term('qc_y','qc_pc','qc_t0')+term('qc_z','qc_ps','qc_t1')+combine('qc_t0','qc_t1','qc_ty',True)
    code+=term('qc_y','qc_ps','qc_t0')+term('qc_z','qc_pc','qc_t1')+combine('qc_t0','qc_t1','qc_z')+copy('qc_ty','qc_y')
    code+='''bb_depth_test:
 lda qc_z+2
 bne bb_reject
 lda qc_z+1
 cmp #8
 bcc bb_reject
 sta bb_depth
'''+copy('qc_z','hc_depth')
    # Project view-plane corners, sharing exact native Q8 axis projection.
    for axis,offsets,names in [('x',(-3,3),('left','right')),('y',(8,-8),('top','bottom'))]:
        for delta,name in zip(offsets,names):
            code+=copy('qc_'+axis,'hc_coord')
            q=round(delta*256)
            code+=' clc\n'
            for i in range(3):
                code+=f' lda hc_coord+{i}\n adc #{(q>>(8*i))&255}\n sta hc_coord+{i}\n'
            code+=f''' lda #{int(axis=='y')}
 sta hc_axis
 jsr hc_project_axis
 lda hc_integer
 sta bb_{name}
 lda hc_integer+1
 sta bb_{name}+1
'''
    code+=''' sec
 lda bb_right
 sbc bb_left
 sta bb_width
 beq bb_reject
 sec
 lda bb_bottom
 sbc bb_top
 sta bb_height
 beq bb_reject
 jsr bb_decode
 lda bb_depth
 lsr
 lsr
 sta p1lo
 jmp bvf_depth_ready
bb_reject:
 rts
bb_decode:
 lda bb_frame
 cmp bb_loaded
 beq bb_decode_done
 sta bb_loaded
 asl
 clc
 adc #>bb_frames
 sta bb_copy0+2
 clc
 adc #1
 sta bb_copy1+2
 php
 sei
 lda $01
 pha
 lda #$34
 sta $01
 ldx #0
bb_copy:
bb_copy0:
 lda bb_frames,x
 sta bb_pixels,x
bb_copy1:
 lda bb_frames+256,x
 sta bb_pixels+256,x
 inx
 bne bb_copy
 pla
 sta $01
 plp
bb_decode_done:
 rts
bb_draw:
 lda bb_top
 sta bb_yy
 lda bb_top+1
 sta bb_yy+1
 lda #0
 sta bb_sy
 sta bb_yerror
 lda bb_height
 sta bb_rows
bb_row:
 ldx bb_sy
 lda bb_src_lo,x
 sta bb_fetch+1
 lda bb_src_hi,x
 sta bb_fetch+2
 lda bb_left
 sta bb_xx
 lda bb_left+1
 sta bb_xx+1
 lda #0
 sta bb_sx
 sta bb_xerror
 lda bb_width
 sta bb_columns
bb_pixel:
 ldx bb_sx
bb_fetch:
 lda bb_pixels,x
 beq bb_transparent
 sta bb_texel
 jsr bb_plot
bb_transparent:
 inc bb_xx
 bne +
 inc bb_xx+1
+
 clc
 lda bb_xerror
 adc #16
bb_xadvance:
 cmp bb_width
 bcc bb_xready
 sbc bb_width
 inc bb_sx
 jmp bb_xadvance
bb_xready:
 sta bb_xerror
 dec bb_columns
 bne bb_pixel
 inc bb_yy
 bne +
 inc bb_yy+1
+
 clc
 lda bb_yerror
 adc #32
bb_yadvance:
 cmp bb_height
 bcc bb_yready
 sbc bb_height
 inc bb_sy
 jmp bb_yadvance
bb_yready:
 sta bb_yerror
 dec bb_rows
 bne bb_row
 rts
bb_plot:
 lda bb_xx+1
 ora bb_yy+1
 bne bb_plot_done
 lda bb_xx
 cmp #160
 bcs bb_plot_done
 lda bb_yy
 cmp #100
 bcs bb_plot_done
 tax
 lda drawbuf
 bne bb_plot_b
 lda row0lo_a,x
 sta ptr0lo
 lda row0hi_a,x
 sta ptr0hi
 lda row1lo_a,x
 sta ptr1lo
 lda row1hi_a,x
 sta ptr1hi
 jmp bb_plot_ready
bb_plot_b:
 lda row0lo_b,x
 sta ptr0lo
 lda row0hi_b,x
 sta ptr0hi
 lda row1lo_b,x
 sta ptr1lo
 lda row1hi_b,x
 sta ptr1hi
bb_plot_ready:
 lda bb_xx
 cmp #128
 bcc +
 inc ptr0hi
 inc ptr1hi
+
 and #3
 tax
 lda bb_texel
 and #3
bb_shift:
 cpx #3
 beq bb_shift_done
 asl
 asl
 inx
 bne bb_shift
bb_shift_done:
 sta bb_bits
 lda bb_xx
 lsr
 lsr
 asl
 asl
 asl
 tay
 lda bb_xx
 and #3
 tax
 lda (ptr0lo),y
 and bb_clear,x
 ora bb_bits
 sta (ptr0lo),y
 lda (ptr1lo),y
 and bb_clear,x
 ora bb_bits
 sta (ptr1lo),y
bb_plot_done:
 rts
'''
    # Keep each allocation small enough for the verified fragmented RAM layout.
    state='bb_enabled: .byte '+str(int(ENABLED))+'\nbb_loaded: .byte 255\n'
    for name in ('phase','frame','alert','depth','width','height','rows','columns','sx','sy','xerror','yerror','texel','bits'):
        state+='bb_'+name+': .byte 0\n'
    for name in ('left','right','top','bottom','xx','yy'):state+='bb_'+name+': .word 0\n'
    state+=data('bb_clear',[63,207,243,252])
    for shift,suffix in ((0,'lo'),(8,'hi')):
        state+=data('bb_walk_'+suffix,[round(.75*256*math.sin(i*math.tau/32))>>shift for i in range(32)])
        state+='bb_src_'+suffix+': .byte '+','.join(('<' if shift==0 else '>')+f'(bb_pixels+{i*16})' for i in range(32))+'\n'
    return code,state

def adapt(source,parts):
    for label,last in [('fill_bounds_pattern_a','fbp_a_done'),('fill_bounds_pattern_b','fbp_b_done')]:
        a=source.index(label+':\n');b=source.index(last+':\n rts\n',a)+len(last+':\n rts\n')
        replacement='; Unreachable patterned Mode4 fill in this closed profile.\n'
        for line in source[a:b].splitlines():
            m=re.match(r'^(\w+):',line)
            if m:replacement+=m[1]+' = hp_unreachable\n'
            elif line.strip().startswith(('.if ','.else','.elsif ','.endif')):replacement+=line+'\n'
        source=source[:a]+replacement+source[b:]
    code,state=kernel()
    parts['billboard']='bb_code_begin:\n'+code+'bb_code_end:\n'
    parts['bb_state']=state
    parts['bb_pixels']='bb_pixels: .fill 512,0\n'
    for anchor,text in (
        ('load_face_visible:\n',f' lda faceidx\n cmp #{FACE}\n bne +\n jmp bb_collect\n+\n'),
        ('ddb_face_loop:\n',f' lda sortj\n cmp #{FACE}\n bne +\n jsr bb_draw\n jmp ddb_after_draw\n+\n'),
        ('advance_sim_tick:\n',' jsr bb_tick\n')):
        assert source.count(anchor)==1
        source=source.replace(anchor,anchor+text)
    old='co_depth_loaded:\n cpx #107\n bcc tr_depth_done\n'
    new='co_depth_loaded:\n cpx #26\n bcc tr_depth_done\n cpx #37\n bcc bb_depth_band\n cpx #107\n bcc tr_depth_done\nbb_depth_band:\n'
    assert source.count(old)==1
    return source.replace(old,new),parts

def post(source):
    frames=artwork()
    source+='\n*=$d000\nbb_frames:\n'
    for i,frame in enumerate(frames):source+=data('bb_frame'+str(i),frame)
    return source+'''bb_frames_end:
 .cerror * > $e000,"Billboard frames exceed RAM under I/O"
bb_payload_end = *
'''
