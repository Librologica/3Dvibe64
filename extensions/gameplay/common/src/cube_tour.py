"""Preserve the old32-key tour; insert64keys and track the sculpture center.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
Public XYZ = right,forward,up; runtime XYZ = right,up,forward.
The look-at runs at logical ticks, independently of rendering and IRQs.
"""
import json,math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
GAZE_END_KEY=60  # turn toward the exit BEFORE entering the corridor

def poses():
    old=json.loads((ROOT/'assets/two-rooms-camera.json').read_text())['posesQ8']
    assert len(old)==32 and old[16][:3]==[0,0,14848]
    # Corridor motion is deliberately linear, on its axis, not Catmull-Rom:
    # a spline influenced by the room orbit previously drifted at the mouth.
    nodes=[(0,149),(-6,149),(-14,151),(-18,160),(-16,170),(-8,177),(0,179),
           (8,177),(16,170),(18,160),(14,151),(6,149),(0,149)]
    def point(t):
        i=min(int(t),len(nodes)-2);u=t-i
        p0,p1,p2,p3=[nodes[max(0,min(len(nodes)-1,k))] for k in (i-1,i,i+1,i+2)]
        return [0.5*(2*p1[a]+(-p0[a]+p2[a])*u+(2*p0[a]-5*p1[a]+4*p2[a]-p3[a])*u*u+
            (-p0[a]+3*p1[a]-3*p2[a]+p3[a])*u*u*u) for a in range(2)]
    extra=[]
    def add(x,z,yaw,pitch):
        extra.append([round(x*256),0,round(z*256),round(yaw*65536/math.tau)&65535,
                      round(pitch*65536/math.tau)&65535])
    def smooth(t):
        t=max(0,min(1,t));return t*t*(3-2*t)
    base=old[16][3]*math.tau/65536
    outward=[64,71,77,83,89,95,101,107,113,119,125,131,137,141,145,149]
    for z in outward:
        yaw=base*(1-smooth((z-58)/13))
        pitch=math.atan2(-4,160-z)*smooth((z-119)/18)
        add(0,z,yaw,pitch)
    for i in range(28):
        x,z=point((i+1)*(len(nodes)-1)/28)
        add(x,z,math.atan2(x,160-z),math.atan2(-4,math.hypot(x,160-z)))
    # Four keys turn in place, safely inside room3 at forward149 (>137).
    # Then walk OUT facing the corridor; no sideways/backward departure.
    start_pitch=math.atan2(-4,11)
    for i in range(1,5):add(0,149,i*math.pi/4,start_pitch*(1-i/4))
    back_heading=old[17][3]*math.tau/65536
    back_pitch=(old[17][4]-65536 if old[17][4]>=32768 else old[17][4])*math.tau/65536
    for z in [145,141,137,131,125,119,113,107,101,95,89,83,77,71,64,58]:
        w=smooth((71-z)/13)
        add(0,z,math.pi+w*((back_heading-math.pi+math.pi)%math.tau-math.pi),w*back_pitch)
    assert len(extra)==64
    return old[:17]+extra+old[17:]

def trajectory(room,original):
    route=poses();code,_=original()
    code=code.replace(' and #15\n',' and #63\n')
    code=code.replace(' lda demo_key\n and #63\n sta demo_key\n',
        ' lda demo_key\n cmp #96\n bcc gc_key_valid\n lda #0\ngc_key_valid:\n sta demo_key\n')
    for suffix in ('lo','hi'):
        code=code.replace(f' lda demo_y_pos_{suffix},x\n sta demo_y_{suffix}\n','')
        code=code.replace(f' lda demo_y_delta_{suffix},x\n sta demo_y_step_{suffix}\n','')
        code=code.replace(f'demo_y_step_{suffix}: .byte 0\n','')
    code=code.replace(' clc\n lda demo_y_lo\n adc demo_y_step_lo\n sta demo_y_lo\n lda demo_y_hi\n adc demo_y_step_hi\n sta demo_y_hi\n','')
    # The excursion exceeds signed16 Q8's positive range. Camera coordinates
    # are signed24 Q8: explicitly extend its known-positive forward trajectory.
    code=code.replace(' ; Head bob is tied to logical time, never to rendered frames.\n',
        ' lda demo_key\n cmp #17\n bcc gc_z_extended\n cmp #81\n bcs gc_z_extended\n lda #0\n sta explorer_cam_z_ext\ngc_z_extended:\n ; Head bob is tied to logical time, never to rendered frames.\n')
    code=code.replace('demo_tick_done:\n rts\n','demo_tick_done:\n jsr gc_update\n rts\n')
    code+=look_code()
    data=''
    for f,name in enumerate(('x','y','z','yaw','pitch')):
        if name=='y':continue
        vals=[p[f]&65535 for p in route]
        ds=[round((((vals[(i+1)%96]-v+32768)&65535)-32768)/64)&65535 for i,v in enumerate(vals)]
        for kind,arr in (('pos',vals),('delta',ds)):
            for shift,suffix in ((0,'lo'),(8,'hi')):
                data+=f'demo_{name}_{kind}_{suffix}: .byte '+','.join(str((v>>shift)&255) for v in arr)+'\n'
    data+='demo_bob: .byte '+','.join(str(round(16*(1-math.cos(i*math.tau/32)))) for i in range(32))+'\n'
    angles=[round(math.atan(i/256)*65536/math.tau) for i in range(256)]
    norms=[round((math.sqrt(1+(i/256)**2)-1)*256) for i in range(256)]
    for name,arr in [('gc_atan_lo',[a&255 for a in angles]),('gc_atan_hi',[a>>8 for a in angles]),('gc_norm',norms)]:
        data+=name+': .byte '+','.join(map(str,arr))+'\n'
    (room.ROOT/'scenes/camera-keyframes.json').write_text(json.dumps(dict(ticksPerKey=64,
        posesQ8=route,periodTicks=6144,nominalSeconds=122.88,originalKeyMapping=list(range(17))+list(range(81,96)),
        gazeTargetPublic=[0,160,4],gazeRegionForwardWU=[137,184],gazeUpdate='each logical tick until exit turn',
        gazeEndKey=GAZE_END_KEY,turnKeys=[60,64],turnPositionPublic=[0,149,0],
        corridorPolicy='x=0; enter yaw0, exit yaw180; turn inside room3 before departure',
        corridorBounds=[-7,7,71,137],roomBounds=[[-24,24,-24,23],[-24,24,25,71],[-24,24,137,184]]),indent=2))
    return code,data

def look_code():
    return '''
; Q8 look-at. 16-bit unsigned ratio, 8 iterations; atan LUT is Q0.16 turns.
; Norm correction is Q0.8, 16x8 ->24 only per logical tick, never per pixel.
; State is renderer-owned RAM, not accessed by IRQ; no self modification.
gc_update:
 lda explorer_cam_z_ext
 bne gc_not_room3
 lda explorer_cam_z_hi
 cmp #71
 bcc gc_not_room3
 cmp #137
 bcs gc_gaze_region
 ; Axis heading is exact even at the boundary tick where the generic
 ; rounded key delta can leave a few phase units before its next reset.
 lda #0
 sta qc_demo_yaw_lo
 lda demo_key
 cmp #60
 lda #0
 bcc gc_corridor_heading
 lda #128
gc_corridor_heading:
 sta explorer_cam_yaw
 rts
gc_gaze_region:
 lda demo_key
 cmp #60
 bcs gc_not_room3
 jmp gc_in_room3
gc_not_room3:
 rts
gc_in_room3:
 lda explorer_cam_x_lo
 sta gc_x
 lda explorer_cam_x_hi
 sta gc_x+1
 and #$80
 sta gc_negx
 beq gc_x_positive
 sec
 lda #0
 sbc gc_x
 sta gc_x
 lda #0
 sbc gc_x+1
 sta gc_x+1
gc_x_positive:
 sec
 lda #0
 sbc explorer_cam_z_lo
 sta gc_z
 lda #160
 sbc explorer_cam_z_hi
 sta gc_z+1
 and #$80
 sta gc_negz
 beq gc_z_positive
 sec
 lda #0
 sbc gc_z
 sta gc_z
 lda #0
 sbc gc_z+1
 sta gc_z+1
gc_z_positive:
 lda #0
 sta gc_swap
 lda gc_x+1
 cmp gc_z+1
 bne gc_compare
 lda gc_x
 cmp gc_z
gc_compare:
 bcc gc_z_major
 inc gc_swap
 lda gc_x
 sta gc_max
 lda gc_x+1
 sta gc_max+1
 lda gc_z
 sta gc_min
 lda gc_z+1
 sta gc_min+1
 jmp gc_horizontal
gc_z_major:
 lda gc_z
 sta gc_max
 lda gc_z+1
 sta gc_max+1
 lda gc_x
 sta gc_min
 lda gc_x+1
 sta gc_min+1
gc_horizontal:
 jsr gc_ratio_angle
 lda gc_swap
 beq gc_azimuth
 sec
 lda #0
 sbc gc_angle
 sta gc_angle
 lda #$40
 sbc gc_angle+1
 sta gc_angle+1
gc_azimuth:
 lda gc_negz
 beq gc_yaw_x
 sec
 lda #0
 sbc gc_angle
 sta gc_angle
 lda #$80
 sbc gc_angle+1
 sta gc_angle+1
gc_yaw_x:
 lda gc_negx
 beq gc_yaw_store
 sec
 lda #0
 sbc gc_angle
 sta gc_angle
 lda #0
 sbc gc_angle+1
 sta gc_angle+1
gc_yaw_store:
 lda gc_angle
 sta qc_demo_yaw_lo
 lda gc_angle+1
 sta explorer_cam_yaw
 ; distance = max + (max * norm(ratio) >>8).
 ldx gc_ratio
 lda gc_norm,x
 sta gc_factor
 lda gc_max
 sta gc_mul
 lda gc_max+1
 sta gc_mul+1
 lda #0
 sta gc_mul+2
 sta gc_product
 sta gc_product+1
 sta gc_product+2
 ldx #8
gc_multiply:
 lsr gc_factor
 bcc gc_mul_skip
 clc
 lda gc_product
 adc gc_mul
 sta gc_product
 lda gc_product+1
 adc gc_mul+1
 sta gc_product+1
 lda gc_product+2
 adc gc_mul+2
 sta gc_product+2
gc_mul_skip:
 asl gc_mul
 rol gc_mul+1
 rol gc_mul+2
 dex
 bne gc_multiply
 clc
 lda gc_max
 adc gc_product+1
 sta gc_max
 lda gc_max+1
 adc gc_product+2
 sta gc_max+1
 sec
 lda explorer_cam_y_lo
 sbc #0
 sta gc_min
 lda explorer_cam_y_hi
 sbc #4
 sta gc_min+1
 and #$80
 sta gc_negpitch
 beq gc_pitch_positive
 sec
 lda #0
 sbc gc_min
 sta gc_min
 lda #0
 sbc gc_min+1
 sta gc_min+1
gc_pitch_positive:
 jsr gc_ratio_angle
 lda gc_negpitch
 beq gc_pitch_store
 sec
 lda #0
 sbc gc_angle
 sta gc_angle
 lda #0
 sbc gc_angle+1
 sta gc_angle+1
gc_pitch_store:
 lda gc_angle
 sta qc_demo_pitch_lo
 lda gc_angle+1
 sta explorer_cam_pitch
 rts
gc_ratio_angle:
 lda #0
 sta gc_ratio
 lda gc_min+1
 cmp gc_max+1
 bne gc_ratio_compare
 lda gc_min
 cmp gc_max
gc_ratio_compare:
 bcc gc_ratio_start
 ; Equal axes: exact 45 degrees, ratio 255 for approximate norm (<.2%).
 lda #255
 sta gc_ratio
 lda #0
 sta gc_angle
 lda #$20
 sta gc_angle+1
 rts
gc_ratio_start:
 ldx #8
gc_ratio_loop:
 asl gc_min
 rol gc_min+1
 lda gc_min+1
 cmp gc_max+1
 bne gc_ratio_test
 lda gc_min
 cmp gc_max
gc_ratio_test:
 bcc gc_ratio_no
 sec
 lda gc_min
 sbc gc_max
 sta gc_min
 lda gc_min+1
 sbc gc_max+1
 sta gc_min+1
 sec
gc_ratio_no:
 rol gc_ratio
 dex
 bne gc_ratio_loop
 ldx gc_ratio
 lda gc_atan_lo,x
 sta gc_angle
 lda gc_atan_hi,x
 sta gc_angle+1
 rts
gc_state_begin:
gc_x: .word 0
gc_z: .word 0
gc_min: .word 0
gc_max: .word 0
gc_angle: .word 0
gc_mul: .fill 3,0
gc_product: .fill 3,0
gc_ratio: .byte 0
gc_factor: .byte 0
gc_swap: .byte 0
gc_negx: .byte 0
gc_negz: .byte 0
gc_negpitch: .byte 0
gc_state_end:
'''
