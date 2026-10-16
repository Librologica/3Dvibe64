"""Deterministic, asymmetric human-like tour; tick driven, independent of FPS."""
import json,math
KEYS=96
PERIOD=KEYS*64
def poses():
    # Public forward is runtime Z. Brief inspections, unequal walking speeds,
    # lateral checks and a different return path replace the sculpture orbit.
    anchors=[(-7,-9,32,15),(-8,1,64,25),(-3,8,-16,0),(1,20,0,1),
      (0,30,-4,-1),(6,42,-36,18),(7,55,-50,18),(-3,62,14,0),(0,70,0,0),
      (1,95,-2,-1),(-1,118,2,1),(0,145,0,-4),(-11,151,-50,-9),
      (-12,169,-128,-7),(6,176,160,-9),(13,162,90,-10),(10,149,40,-8),
      (0,144,180,0),(0,116,178,0),(0,86,182,-1),(0,67,180,0),
      (-6,48,128,-5),(-3,28,174,0),(0,17,180,-1)]
    # Durations reflect walk distance, with extra time on two inspections.
    weights=[3,3,3,2,4,4,3,2,6,5,6,4,5,4,4,3,4,6,6,4,4,4,3,5]
    ends=[0]
    for w in weights:ends.append(ends[-1]+w)
    route=[]
    for key in range(KEYS):
        t=key*ends[-1]/KEYS
        i=next(i for i in range(len(weights)) if ends[i]<=t<ends[i+1])
        u=(t-ends[i])/weights[i];a=anchors[i];b=anchors[(i+1)%len(anchors)]
        prev=anchors[(i-1)%len(anchors)];nxt=anchors[(i+2)%len(anchors)]
        vals=[]
        for axis in [0,1]:
            # Hermite slopes tied to time, not a constant-speed circular tour.
            m0=(b[axis]-prev[axis])*weights[i]/(weights[i-1]+weights[i])
            m1=(nxt[axis]-a[axis])*weights[i]/(weights[i]+weights[(i+1)%len(weights)])
            vals.append((2*u**3-3*u*u+1)*a[axis]+(u**3-2*u*u+u)*m0+(-2*u**3+3*u*u)*b[axis]+(u**3-u*u)*m1)
        x,z=vals
        if 21<z<27 or 69<z<140:x=max(-4.5,min(4.5,x))
        else:x=max(-19,min(19,x))
        z=max(-19,min(180,z))
        if math.hypot(x,z-160)<9:
            scale=9/math.hypot(x,z-160);x*=scale;z=160+(z-160)*scale
        s=u*u*(3-2*u)
        delta=(b[2]-a[2]+180)%360-180
        yaw=a[2]+delta*s+0.75*math.sin(key*1.73)
        pitch=a[3]+(b[3]-a[3])*s+0.35*math.sin(key*.71)
        route.append([round(x*256),0,round(z*256),round(yaw*65536/360)&65535,round(pitch*65536/360)&65535])
    return route
def trajectory(room):
    route=poses();fields=('x','z','yaw','pitch');data='';code='''qc_demo_tick:
 lda demo_subtick
 bne demo_increment
 ldx demo_key
'''
    for f,name in zip((0,2,3,4),fields):
        vals=[p[f] for p in route]
        diffs=[(vals[(i+1)%KEYS]-v) if name in ('x','z') else ((vals[(i+1)%KEYS]-v+32768)&65535)-32768 for i,v in enumerate(vals)]
        steps=[round(d/64)&65535 for d in diffs]
        for kind,arr in [('pos',vals),('delta',steps)]:
            for shift,suffix in [(0,'lo'),(8,'hi')]:
                data+=f'demo_{name}_{kind}_{suffix}: .byte '+','.join(str((v>>shift)&255) for v in arr)+'\n'
                code+=f' lda demo_{name}_{kind}_{suffix},x\n sta demo_{name}_{"step_" if kind=="delta" else ""}{suffix}\n'
    data+='demo_z_pos_ext: .byte '+','.join(str((p[2]>>16)&255) for p in route)+'\n'
    code+=' lda demo_z_pos_ext,x\n sta demo_z_ext\ndemo_increment:\n'
    for name in fields:
        code+=f' clc\n lda demo_{name}_lo\n adc demo_{name}_step_lo\n sta demo_{name}_lo\n lda demo_{name}_hi\n adc demo_{name}_step_hi\n sta demo_{name}_hi\n'
        if name=='z':code+=' lda demo_z_step_hi\n bmi hu_z_negative\n lda #0\n jmp hu_z_sign\nhu_z_negative:\n lda #255\nhu_z_sign:\n adc demo_z_ext\n sta demo_z_ext\n'
    for name in ('x','z'):
        for suffix in ('lo','hi'):code+=f' lda demo_{name}_{suffix}\n sta explorer_cam_{name}_{suffix}\n'
    code+=''' lda demo_x_hi
 asl
 lda #0
 sbc #0
 eor #255
 sta explorer_cam_x_ext
 lda demo_z_ext
 sta explorer_cam_z_ext
 inc demo_bob_phase
 lda demo_bob_phase
 and #31
 tax
 lda demo_bob,x
 sta explorer_cam_y_lo
 lda #0
 sta explorer_cam_y_hi
 sta explorer_cam_y_ext
'''
    for name in ('yaw','pitch'):code+=f' lda demo_{name}_lo\n sta qc_demo_{name}_lo\n lda demo_{name}_hi\n sta explorer_cam_{name}\n'
    code+=f''' inc demo_subtick
 lda demo_subtick
 and #63
 sta demo_subtick
 bne demo_tick_done
 inc demo_key
 lda demo_key
 cmp #{KEYS}
 bcc hu_key_valid
 lda #0
hu_key_valid:
 sta demo_key
demo_tick_done:
 rts
demo_key: .byte 0
demo_subtick: .byte 0
demo_bob_phase: .byte 0
demo_z_ext: .byte 0
qc_demo_yaw_lo: .byte 0
qc_demo_pitch_lo: .byte 0
'''
    for name in fields:
        for suffix in ('lo','hi','step_lo','step_hi'):code+=f'demo_{name}_{suffix}: .byte 0\n'
    data+='demo_bob: .byte '+','.join(str(round(10*(1-math.cos(i*math.tau/32)))) for i in range(32))+'\n'
    (room.ROOT/'scenes/camera-keyframes.json').write_text(json.dumps(dict(posesQ8=route,ticksPerKey=64,periodTicks=PERIOD,nominalSeconds=PERIOD/50,style='asymmetric inspections, independent gaze, slower turns, unequal walking speeds',music=False,loop=True),indent=2))
    return code,data
