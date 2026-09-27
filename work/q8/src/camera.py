"""Opt-in Q8 camera adapter. No edits to SDK, fill, clipping or legacy paths."""
from pathlib import Path


def copy(src,dst,n=3):
    # Tiny local loops keep all seven families inside the existing RAM gaps.
    # X is private scratch here; live vertex index is in Y/qc_index.
    return f' ldx #{n-1}\n-\n lda {src},x\n sta {dst},x\n dex\n bpl -\n'


def term(src,trig,dst):
    return copy(src,'qc_a')+copy(trig,'qc_b',2)+' jsr qc_product\n'+copy('qc_r',dst)


def combine(a,b,dst,sub=False):
    # INY/DEX/BNE preserve carry across the three bytes (CPY would not).
    return (' sec\n' if sub else ' clc\n')+f''' ldy #0
 ldx #3
-
 lda {a},y
 {"sbc" if sub else "adc"} {b},y
 sta {dst},y
 iny
 dex
 bne -
'''


def adapt(source,parts,automatic=False):
    # The SDK emits these routines and all conditional dependencies even in
    # controls-disabled probe builds. Enable their ASM branches only in this
    # opt-in adapter; retain build-time legacy validation unchanged.
    for label in ('explorer_scan_keys:', 'explorer_advance_camera_tick:',
                  'explorer_prepare_view:', 'explorer_yaw_repeat_phase:'):
        assert label in source,label
    if not automatic:
        old='CAMERA_RUNTIME_CONTROLS = $00'
        assert source.count(old)==1
        source=source.replace(old,'CAMERA_RUNTIME_CONTROLS = $01 ; Q8 camera opt-in')
    old='hp_origins:\n lda explorer_cam_yaw\n ora explorer_cam_pitch\n beq hp_origin_supported\n clc\n rts\nhp_origin_supported:\n'
    assert old in parts['vertices']
    # Bounded profile: reject extreme camera translations before subtracting.
    guard='hp_origins:\n'
    for ax in 'xyz':
        guard+=f' lda explorer_cam_{ax}_ext\n clc\n adc #16\n cmp #32\n bcs qc_origin_fail\n'
    # Jump across the common failure stub without changing carry ABI.
    guard+=' jmp hp_origin_supported\nqc_origin_fail:\n clc\n rts\nhp_origin_supported:\n'
    parts['vertices']=parts['vertices'].replace(old,guard)
    old=' jsr hp_build_vertices\n jsr hc_project_vertices\n'
    assert old in parts['core']
    parts['core']=parts['core'].replace(old,' jsr hp_build_vertices\n jsr qc_rotate_vertices\n jsr hc_project_vertices\n')
    code='qc_rotate_vertices:\n lda explorer_cam_yaw\n'
    if automatic:code+=' ora qc_demo_yaw_lo\n ora qc_demo_pitch_lo\n'
    code+='''
 ora explorer_cam_pitch
 bne qc_rotate_active
 rts
qc_rotate_active:
'''
    # View convention identical to SDK: sin/cos(-camera angle).
    for angle,prefix in [('yaw','y'),('pitch','p')]:
        code+=' lda #0\n sec\n'
        if automatic:
            code+=f' sbc qc_demo_{angle}_lo\n sta hp_fraction\n lda #0\n'
        code+=f' sbc explorer_cam_{angle}\n tax\n'
        for kind in ('s','c'):
            if kind=='c':
                if automatic:code+=' ldx hp_sine_index\n'
                code+=' txa\n clc\n adc #64\n tax\n'
            if automatic:
                code+=' jsr hp_sine\n'
                for offset in range(2):code+=f' lda hp_r+{offset}\n sta qc_{prefix}{kind}+{offset}\n'
            else:
                for part,offset in [('lo',0),('hi',1)]:
                    code+=f' lda hp_sin_{part},x\n sta qc_{prefix}{kind}+{offset}\n'
    code+=' lda #0\n sta qc_index\nqc_vertex:\n ldy qc_index\n'
    for ax in 'xyz':
        for i in range(3):code+=f' lda hc_cam_{ax}{i},y\n sta qc_{ax}+{i}\n'
    code+=' lda explorer_cam_yaw\n'
    if automatic:code+=' ora qc_demo_yaw_lo\n'
    code+=' beq qc_pitch\n'
    code+=term('qc_x','qc_yc','qc_t0')+term('qc_z','qc_ys','qc_t1')+combine('qc_t0','qc_t1','qc_tx',True)
    code+=term('qc_x','qc_ys','qc_t0')+term('qc_z','qc_yc','qc_t1')+combine('qc_t0','qc_t1','qc_z')+copy('qc_tx','qc_x')
    code+='qc_pitch:\n lda explorer_cam_pitch\n'
    if automatic:code+=' ora qc_demo_pitch_lo\n'
    code+=' beq qc_store\n'
    code+=term('qc_y','qc_pc','qc_t0')+term('qc_z','qc_ps','qc_t1')+combine('qc_t0','qc_t1','qc_ty',True)
    code+=term('qc_y','qc_ps','qc_t0')+term('qc_z','qc_pc','qc_t1')+combine('qc_t0','qc_t1','qc_z')+copy('qc_ty','qc_y')
    code+='qc_store:\n ldy qc_index\n'
    for ax in 'xyz':
        for i in range(3):code+=f' lda qc_{ax}+{i}\n sta hc_cam_{ax}{i},y\n'
        code+=f' lda qc_{ax}+1\n sta v{ax}rawlo,y\n sta '+dict(x='rxbuf',y='rybuf',z='sz')[ax]+',y\n'
        code+=f' lda qc_{ax}+2\n sta v{ax}rawhi,y\n'
        if ax=='z':code+=' sta szhi,y\n'
    code+=' inc qc_index\n lda qc_index\n cmp #VERT_COUNT\n bne qc_vertex\n rts\n'
    # Separate placement units retain guard bands in tight Mode 7 builds.
    split=code.index('qc_pitch:')
    parts['camera_yaw']=code[:split]+' jmp qc_pitch\n'
    parts['camera_pitch']=code[split:]
    parts['camera_math']=Path(__file__).with_name('camera.asm').read_text()
    data=''
    for n,size in [('a',3),('b',2),('r',3),('m',4),('prod',4),('sign',1),('index',1),
                   ('ys',2),('yc',2),('ps',2),('pc',2),('x',3),('y',3),('z',3),
                   ('tx',3),('ty',3),('t0',3),('t1',3)]:
        data+=f'qc_{n}: .fill {size},0\n'
    parts['data']+=data
    # Same object trigonometry, smaller placement units for the tight Mode 7
    # layout. Explicit tail jumps; no guard-band or reserved-memory changes.
    trig=parts['trig']
    for ax in ('z','y'):
        cut=trig.index(f' lda object_ang_{ax}_lo\n')
        parts[f'camera_trig_{ax}']=f'qc_trig_{ax}:\n'+trig[cut:]
        trig=trig[:cut]+f' jmp qc_trig_{ax}\n'
    parts['trig']=trig
    if 'music_code' in parts:
        # Init ends with RTS. Only placement changes; player instructions and
        # video-timed IRQ calls remain identical, with both guard bands kept.
        cut=parts['music_code'].index('gs_play:')
        parts['camera_music_play']=parts['music_code'][cut:]
        parts['music_code']=parts['music_code'][:cut]
        if 'GRAPHICS_MODE = $06\n' in source:
            cut=parts['music_code'].index('gs_init_voice:')
            parts['camera_music_init']=parts['music_code'][cut:]
            parts['music_code']=parts['music_code'][:cut]+' jmp gs_init_voice\n'
    if automatic:
        # Same 1024-logical-tick period and +/-16 / +/-8 angle-unit amplitudes.
        # Advance 1/4 phase unit EVERY tick, retaining camera-angle fractions.
        # hp_sine scratch is main-thread-only; IRQ music never touches it.
        source=source.replace('advance_sim_tick:\n','advance_sim_tick:\n jsr qc_demo_tick\n')
        parts['camera_demo']='''qc_demo_tick:
 clc
 lda qc_demo_phase
 adc #64
 sta qc_demo_phase
 sta hp_fraction
 lda qc_demo_phase+1
 adc #0
 sta qc_demo_phase+1
 tax
 jsr hp_sine
 ; Q8 sine * 16 -> signed camera angle Q8, without truncating low bits.
 ldx #4
-
 asl hp_r
 rol hp_r+1
 dex
 bne -
 lda hp_r
 sta qc_demo_yaw_lo
 lda hp_r+1
 sta explorer_cam_yaw
 ; Half-amplitude pitch with a signed 16-bit arithmetic shift.
 cmp #$80
 ror
 sta explorer_cam_pitch
 lda hp_r
 ror
 sta qc_demo_pitch_lo
 rts
qc_demo_phase: .word 0
qc_demo_yaw_lo: .byte 0
qc_demo_pitch_lo: .byte 0
'''
    return source,parts
