"""Bounded billboard assembly emitter; caller supplies frames and scene bindings.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
No bundled scene, character artwork, camera route or UI.
"""
import math,re,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[3]/'work/q8/src'))
from camera import copy,term,combine
ENABLED=True
FACE=36

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
    # Q8 world anchor: lateral walk of +/-0.75 WU, center z=0, feet=-10.
    for axis,center in zip('xyz',(4,-3,0)):
        code+=f' lda #0\n sta qc_{axis}\n lda #{center&255}\n sta qc_{axis}+1\n lda #{255 if center<0 else 0}\n sta qc_{axis}+2\n'
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
    for axis,offsets,names in [('x',(-3,3),('left','right')),('y',(7,-7),('top','bottom'))]:
        for delta,name in zip(offsets,names):
            code+=copy('qc_'+axis,'hc_coord')
            code+=f''' clc
 lda hc_coord+1
 adc #{delta&255}
 sta hc_coord+1
 lda hc_coord+2
 adc #{255 if delta<0 else 0}
 sta hc_coord+2
 lda #{int(axis=='y')}
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

def post(source, frames):
    if not isinstance(frames,list) or len(frames)!=6 or any(
            not isinstance(frame,list) or len(frame)!=512 or any(
                type(pixel) is not int or not 0<=pixel<=3 for pixel in frame)
            for frame in frames):
        raise ValueError('Caller must supply six 16x32 indexed frames')
    source+='\n*=$d000\nbb_frames:\n'
    for i,frame in enumerate(frames):source+=data('bb_frame'+str(i),frame)
    return source+'''bb_frames_end:
 .cerror * > $e000,"Billboard frames exceed RAM under I/O"
bb_payload_end = *
'''
