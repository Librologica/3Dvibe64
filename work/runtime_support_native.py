"""Composable scene-independent6502 support, allocated by the plus linker.

Required Notice: 3Dvibe64. PolyForm Noncommercial1.0.0.
All state has an explicit rs_ owner. No borrowed zero page or game assets.
"""
import math
import re
from legacy_plus_exact import block
from animated_mesh import data


def integer(v, lo, hi, name):
    if type(v) is not int or not lo <= v <= hi:
        raise ValueError(f'RUNTIME_SUPPORT: {name} must be {lo}..{hi}')
    return v


def symbol(s):
    if not isinstance(s, str) or not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*', s):
        raise ValueError('RUNTIME_SUPPORT: invalid symbol')
    return s


def config(c, fields, name):
    if not isinstance(c, dict) or set(c)-set(fields):
        raise ValueError('RUNTIME_SUPPORT: invalid '+name+' configuration')


def random_code(c):
    config(c, ('simulationSeed', 'cosmeticSeed'), 'random')
    code = ''
    for channel, key, default in [('sim', 'simulationSeed', 0xace1), ('fx', 'cosmeticSeed', 0x7319)]:
        seed = integer(c.get(key, default), 1, 65535, key)
        code += f'''rs_{channel}_random:
 lda rs_{channel}_seed
 ora rs_{channel}_seed+1
 bne +
 inc rs_{channel}_seed
+
 lsr rs_{channel}_seed+1
 ror rs_{channel}_seed
 bcc +
 lda rs_{channel}_seed+1
 eor #$b4
 sta rs_{channel}_seed+1
+
 lda rs_{channel}_seed
 eor rs_{channel}_seed+1
 rts
rs_{channel}_seed: .word {seed}
'''
    return code


def camera_code(c):
    config(c, ('shift', 'zoomEnter', 'zoomLeave', 'bankLimit'), 'camera')
    shift = integer(c.get('shift', 3), 1, 7, 'shift')
    enter = integer(c.get('zoomEnter', 14*256), 0, 32766, 'zoomEnter')
    leave = integer(c.get('zoomLeave', 26*256), enter+1, 32767, 'zoomLeave')
    bank = integer(c.get('bankLimit', 8*256), 1, 16383, 'bankLimit')
    code = '''; Caller ticks independently of render; positions signed16 Q8.
rs_camera_tick:
 ldx #0
rs_camera_position:
 sec
 lda rs_camera_target,x
 sbc rs_camera_pose,x
 sta rs_camera_error
 lda rs_camera_target+1,x
 sbc rs_camera_pose+1,x
 sta rs_camera_error+1
 bvs rs_camera_snap
 jsr rs_camera_filter
 jmp rs_camera_next_position
rs_camera_snap:
 lda rs_camera_target,x
 sta rs_camera_pose,x
 lda rs_camera_target+1,x
 sta rs_camera_pose+1,x
rs_camera_next_position:
 inx
 inx
 cpx #6
 bne rs_camera_position
 ; Yaw/pitch are circular signed16 Q8 phase values.
rs_camera_angle:
 sec
 lda rs_camera_target,x
 sbc rs_camera_pose,x
 sta rs_camera_error
 lda rs_camera_target+1,x
 sbc rs_camera_pose+1,x
 sta rs_camera_error+1
 jsr rs_camera_filter
 inx
 inx
 cpx #10
 bne rs_camera_angle
 ; The bank goal is explicitly bounded; current bank uses the same filter.
 lda rs_camera_target+11
 bmi rs_camera_bank_negative
 cmp #>RS_BANK
 bcc rs_camera_bank_ready
 bne rs_camera_bank_positive_clamp
 lda rs_camera_target+10
 cmp #<RS_BANK
 bcc rs_camera_bank_ready
rs_camera_bank_positive_clamp:
 lda #<RS_BANK
 sta rs_camera_target+10
 lda #>RS_BANK
 sta rs_camera_target+11
 jmp rs_camera_bank_ready
rs_camera_bank_negative:
 cmp #>(65536-RS_BANK)
 bcc rs_camera_bank_negative_clamp
 bne rs_camera_bank_ready
 lda rs_camera_target+10
 cmp #<(65536-RS_BANK)
 bcs rs_camera_bank_ready
rs_camera_bank_negative_clamp:
 lda #<(65536-RS_BANK)
 sta rs_camera_target+10
 lda #>(65536-RS_BANK)
 sta rs_camera_target+11
rs_camera_bank_ready:
 ldx #10
 sec
 lda rs_camera_target,x
 sbc rs_camera_pose,x
 sta rs_camera_error
 lda rs_camera_target+1,x
 sbc rs_camera_pose+1,x
 sta rs_camera_error+1
 bvs rs_camera_filter_snap
 jmp rs_camera_filter
rs_camera_filter:
 ; Snap small positive AND negative residuals to eliminate terminal drift.
 lda rs_camera_error+1
 bne rs_camera_filter_negative
 lda rs_camera_error
 cmp #RS_EPSILON
 bcc rs_camera_filter_snap
 bcs rs_camera_filter_shift
rs_camera_filter_negative:
 cmp #255
 bne rs_camera_filter_shift
 lda rs_camera_error
 cmp #(256-RS_EPSILON+1)
 bcs rs_camera_filter_snap
rs_camera_filter_shift:
 ldy #RS_SHIFT
rs_camera_filter_bit:
 lda rs_camera_error+1
 cmp #128
 ror rs_camera_error+1
 ror rs_camera_error
 dey
 bne rs_camera_filter_bit
 clc
 lda rs_camera_pose,x
 adc rs_camera_error
 sta rs_camera_pose,x
 lda rs_camera_pose+1,x
 adc rs_camera_error+1
 sta rs_camera_pose+1,x
 rts
rs_camera_filter_snap:
 lda rs_camera_target,x
 sta rs_camera_pose,x
 lda rs_camera_target+1,x
 sta rs_camera_pose+1,x
 rts
; Input rs_camera_distance unsigned Q8. Return A=0/1, persistent hysteresis.
rs_camera_zoom_tick:
 lda rs_camera_zoom
 bne rs_camera_zoom_leave
 lda #<RS_ENTER
 sta rs_camera_threshold
 lda #>RS_ENTER
 bne rs_camera_zoom_compare
 beq rs_camera_zoom_compare
rs_camera_zoom_leave:
 lda #<RS_LEAVE
 sta rs_camera_threshold
 lda #>RS_LEAVE
rs_camera_zoom_compare:
 sta rs_camera_threshold+1
 lda rs_camera_threshold+1
 cmp rs_camera_distance+1
 bcc rs_camera_zoom_far
 bne rs_camera_zoom_near
 lda rs_camera_threshold
 cmp rs_camera_distance
 bcc rs_camera_zoom_far
rs_camera_zoom_near:
 lda #1
 bne rs_camera_zoom_store
rs_camera_zoom_far:
 lda #0
rs_camera_zoom_store:
 sta rs_camera_zoom
 rts
; Copy position/yaw/pitch to native camera, preserving its public Q8 ABI.
; Bank is published separately for applications; see camera-roll contract.
rs_camera_apply:
 lda rs_camera_pose
 sta explorer_cam_x_lo
 lda rs_camera_pose+1
 sta explorer_cam_x_hi
 cmp #128
 lda #0
 bcc +
 lda #255
+
 sta explorer_cam_x_ext
 lda rs_camera_pose+2
 sta explorer_cam_y_lo
 lda rs_camera_pose+3
 sta explorer_cam_y_hi
 cmp #128
 lda #0
 bcc +
 lda #255
+
 sta explorer_cam_y_ext
 lda rs_camera_pose+4
 sta explorer_cam_z_lo
 lda rs_camera_pose+5
 sta explorer_cam_z_hi
 cmp #128
 lda #0
 bcc +
 lda #255
+
 sta explorer_cam_z_ext
 lda rs_camera_pose+6
 and #$f0
 sta explorer_cam_yaw_frac
 lda rs_camera_pose+7
 sta explorer_cam_yaw
 lda rs_camera_pose+8
 and #$f0
 sta explorer_cam_pitch_frac
 lda rs_camera_pose+9
 sta explorer_cam_pitch
 jmp lr_prepare
rs_camera_pose: .fill 12,0
rs_camera_target: .fill 12,0
rs_camera_error: .word 0
rs_camera_distance: .word 32767
rs_camera_zoom: .byte 0
rs_camera_threshold: .word 0
'''
    for key, value in [('RS_SHIFT', shift), ('RS_EPSILON', 1 << shift), ('RS_ENTER', enter), ('RS_LEAVE', leave), ('RS_BANK', bank)]:
        code = code.replace(key, str(value))
    easing = [round((1-math.cos(math.pi*i/64))*128) for i in range(65)]
    code += data('rs_camera_ease_lo', [v & 255 for v in easing])+data('rs_camera_ease_hi', [v >> 8 for v in easing])
    return code


def origin_code(c):
    if isinstance(c,dict) and 'axes' in c:
        config(c,('axes',),'origin')
        axes=c['axes']
        if not isinstance(axes,dict) or not axes or set(axes)-{'x','y','z'}:
            raise ValueError('RUNTIME_SUPPORT: origin axes must be x/y/z')
        return ''.join(origin_code(axes[a]).replace('rs_origin_',f'rs_origin_{a}_') for a in 'xyz' if a in axes)
    config(c, ('channels',), 'origin')
    channels = c.get('channels', [])
    if not isinstance(channels, list) or not 1 <= len(channels) <= 32:
        raise ValueError('RUNTIME_SUPPORT: origin channels must contain1..32 descriptors')
    code = '; A=delta low,Y=delta high, signed Q8. Shift all registered channels atomically.\nrs_origin_shift:\n php\n sei\n sta rs_origin_delta\n sty rs_origin_delta+1\n'
    code += ''' cpy #128
 lda #0
 bcc +
 lda #255
+
 sta rs_origin_sign
 clc
 lda rs_origin_world
 adc rs_origin_delta
 sta rs_origin_world
 lda rs_origin_world+1
 adc rs_origin_delta+1
 sta rs_origin_world+1
 lda rs_origin_world+2
 adc rs_origin_sign
 sta rs_origin_world+2
 lda rs_origin_world+3
 adc rs_origin_sign
 sta rs_origin_world+3
'''
    for i, channel in enumerate(channels):
        config(channel, ('low', 'high', 'extension', 'count'), 'origin channel')
        lo, hi = symbol(channel.get('low')), symbol(channel.get('high'))
        ext = symbol(channel['extension']) if 'extension' in channel else None
        count = integer(channel.get('count'), 1, 255, 'channel count')
        code += f' ldx #{count-1}\nrs_origin_channel_{i}:\n sec\n lda {lo},x\n sbc rs_origin_delta\n sta {lo},x\n lda {hi},x\n sbc rs_origin_delta+1\n sta {hi},x\n'
        if ext:
            code += f' lda {ext},x\n sbc rs_origin_sign\n sta {ext},x\n'
        code += f' dex\n bpl rs_origin_channel_{i}\n' if count <= 128 else f' dex\n cpx #255\n bne rs_origin_channel_{i}\n'
    code += ' plp\n rts\nrs_origin_delta: .word 0\nrs_origin_sign: .byte 0\nrs_origin_world: .fill 4,0\n'
    return code


def multiply_code():
    return '''; Unsigned16 multiplicand and unsigned8 multiplier -> exact24 product.
; Inputs preserved. Private state, no shared raster/zero-page aliases.
rs_mul_u16_u8:
 lda rs_mul_a
 sta rs_mul_shift
 lda rs_mul_a+1
 sta rs_mul_shift+1
 lda #0
 sta rs_mul_shift+2
 sta rs_mul_result
 sta rs_mul_result+1
 sta rs_mul_result+2
 lda rs_mul_b
 sta rs_mul_bits
 ldx #8
rs_mul_loop:
 lsr rs_mul_bits
 bcc rs_mul_next
 clc
 lda rs_mul_result
 adc rs_mul_shift
 sta rs_mul_result
 lda rs_mul_result+1
 adc rs_mul_shift+1
 sta rs_mul_result+1
 lda rs_mul_result+2
 adc rs_mul_shift+2
 sta rs_mul_result+2
rs_mul_next:
 asl rs_mul_shift
 rol rs_mul_shift+1
 rol rs_mul_shift+2
 dex
 bne rs_mul_loop
 rts
rs_mul_a: .word 0
rs_mul_b: .byte 0
rs_mul_result: .fill 3,0
rs_mul_shift: .fill 3,0
rs_mul_bits: .byte 0
'''


def frustum_code(c):
    config(c, ('focal', 'nearQ4'), 'frustum')
    focal = integer(c.get('focal', 170), 1, 255, 'focal')
    near = integer(c.get('nearQ4', 128), 1, 32767, 'nearQ4')
    code = '''; signed16 Q4 center, unsigned16 radius <=32767, focal1..255.
; C=1 possibly visible, C=0 proven outside. A containing box is conservative.
rs_bounds_visible:
 lda rs_bound_radius+1
 bmi rs_bound_accept
 clc
 lda rs_bound_center+4
 adc rs_bound_radius
 sta rs_bound_far
 lda rs_bound_center+5
 adc rs_bound_radius+1
 sta rs_bound_far+1
 bvs rs_bound_accept
 bmi rs_bound_reject
 cmp #>RS_NEAR
 bcc rs_bound_reject
 bne rs_bound_sides
 lda rs_bound_far
 cmp #<RS_NEAR
 bcc rs_bound_reject
rs_bound_sides:
 lda #0
 sta rs_bound_axis
rs_bound_axis_loop:
 ldx rs_bound_axis
 lda rs_bound_center,x
 sta rs_bound_abs
 lda rs_bound_center+1,x
 sta rs_bound_abs+1
 bpl rs_bound_positive
 sec
 lda #0
 sbc rs_bound_abs
 sta rs_bound_abs
 lda #0
 sbc rs_bound_abs+1
 sta rs_bound_abs+1
rs_bound_positive:
 sec
 lda rs_bound_abs
 sbc rs_bound_radius
 sta rs_mul_a
 lda rs_bound_abs+1
 sbc rs_bound_radius+1
 sta rs_mul_a+1
 bcc rs_bound_next_axis
 lda rs_bound_focal
 beq rs_bound_accept
 sta rs_mul_b
 jsr rs_mul_u16_u8
 ldx #2
rs_bound_save_left:
 lda rs_mul_result,x
 sta rs_bound_left,x
 dex
 bpl rs_bound_save_left
 lda rs_bound_far
 sta rs_mul_a
 lda rs_bound_far+1
 sta rs_mul_a+1
 lda #81
 ldx rs_bound_axis
 beq +
 lda #51
+
 sta rs_mul_b
 jsr rs_mul_u16_u8
 ldx #2
rs_bound_compare:
 lda rs_bound_left,x
 cmp rs_mul_result,x
 bcc rs_bound_next_axis
 bne rs_bound_reject
 dex
 bpl rs_bound_compare
rs_bound_next_axis:
 inc rs_bound_axis
 inc rs_bound_axis
 lda rs_bound_axis
 cmp #4
 bcc rs_bound_axis_loop
rs_bound_accept:
 sec
 rts
rs_bound_reject:
 clc
 rts
rs_bound_center: .fill 6,0
rs_bound_radius: .word 0
rs_bound_focal: .byte RS_FOCAL
rs_bound_far: .word 0
rs_bound_abs: .word 0
rs_bound_left: .fill 3,0
rs_bound_axis: .byte 0
'''
    return code.replace('RS_NEAR', str(near)).replace('RS_FOCAL', str(focal))


def particles_code(c):
    config(c, ('slots', 'attempts', 'life'), 'particles')
    slots = integer(c.get('slots', 16), 1, 32, 'particle slots')
    attempts = integer(c.get('attempts', 8), 1, 32, 'sample attempts')
    life = integer(c.get('life', 32), 1, 255, 'particle life')
    code = f'''rs_particles_emit:
 lda #{slots-1}
 sta rs_particle_slot
rs_particles_emit_one:
 lda #{attempts}
 sta rs_particle_attempt
rs_particle_sample:
 ldx #0
rs_particle_sample_axis:
 stx rs_particle_axis
 jsr rs_fx_random
 and #63
 sec
 sbc #31
 ldx rs_particle_axis
 sta rs_particle_vector,x
 inx
 cpx #3
 bcc rs_particle_sample_axis
 lda #0
 sta rs_particle_square
 sta rs_particle_square+1
 ldx #2
rs_particle_check_axis:
 lda rs_particle_vector,x
 bpl +
 eor #255
 clc
 adc #1
+
 tay
 clc
 lda rs_particle_square
 adc rs_particle_sq_lo,y
 sta rs_particle_square
 lda rs_particle_square+1
 adc rs_particle_sq_hi,y
 sta rs_particle_square+1
 dex
 bpl rs_particle_check_axis
 lda rs_particle_square+1
 cmp #3
 bcc rs_particle_sample_ok
 bne rs_particle_sample_retry
 lda rs_particle_square
 cmp #194
 bcc rs_particle_sample_ok
rs_particle_sample_retry:
 dec rs_particle_attempt
 bne rs_particle_sample
 lda #0
 sta rs_particle_vector
 sta rs_particle_vector+1
 sta rs_particle_vector+2
rs_particle_sample_ok:
 ldx rs_particle_slot
 lda #{life}
 sta rs_particle_life,x
'''
    for i, axis in enumerate('xyz'):
        code += f''' lda rs_particle_vector+{i}
 sta rs_particle_v{axis},x
 sta rs_particle_temp
 cmp #128
 lda #0
 bcc +
 lda #255
+
 sta rs_particle_temp+1
 asl rs_particle_temp
 rol rs_particle_temp+1
 asl rs_particle_temp
 rol rs_particle_temp+1
 asl rs_particle_temp
 rol rs_particle_temp+1
 clc
 lda rs_particle_origin+{i*2}
 adc rs_particle_temp
 sta rs_particle_{axis}_lo,x
 lda rs_particle_origin+{i*2+1}
 adc rs_particle_temp+1
 sta rs_particle_{axis}_hi,x
'''
    code += f''' dec rs_particle_slot
 bpl rs_particles_emit_one
 rts
rs_particles_tick:
 ldx #{slots-1}
rs_particle_tick_slot:
 lda rs_particle_life,x
 beq rs_particle_tick_next
 dec rs_particle_life,x
'''
    for axis in 'xyz':
        code += f''' lda rs_particle_v{axis},x
 cmp #128
 lda #0
 bcc +
 lda #255
+
 sta rs_particle_temp
 clc
 lda rs_particle_{axis}_lo,x
 adc rs_particle_v{axis},x
 sta rs_particle_{axis}_lo,x
 lda rs_particle_{axis}_hi,x
 adc rs_particle_temp
 sta rs_particle_{axis}_hi,x
'''
    code += '''rs_particle_tick_next:
 dex
 bpl rs_particle_tick_slot
 rts
rs_particle_slot: .byte 0
rs_particle_attempt: .byte 0
rs_particle_axis: .byte 0
rs_particle_vector: .fill 3,0
rs_particle_square: .word 0
rs_particle_temp: .word 0
rs_particle_origin: .fill 6,0
'''
    for name in ['life']+[f'{a}_{b}' for a in 'xyz' for b in ('lo', 'hi')]+['v'+a for a in 'xyz']:
        code += f'rs_particle_{name}: .fill {slots},0\n'
    code += data('rs_particle_sq_lo', [(i*i) & 255 for i in range(33)])+data('rs_particle_sq_hi', [(i*i) >> 8 for i in range(33)])
    return code


def emit_support(configuration):
    from runtime_contacts import sat_code, contacts_code
    config(configuration, ('random', 'camera', 'origin', 'frustum', 'particles', 'sat', 'contacts', 'lod', 'rigidPose'), 'support')
    generators = dict(random=random_code, camera=camera_code, origin=origin_code,
                      frustum=frustum_code, particles=particles_code,
                      sat=sat_code,contacts=contacts_code,lod=lod_code,rigidPose=rigid_pose_code)
    cfg = dict(configuration)
    if 'particles' in cfg:
        cfg.setdefault('random', {})
    result = ''
    if 'frustum' in cfg or 'sat' in cfg:
        result += block('support_multiply', multiply_code())
    for name, generator in generators.items():
        if name in cfg:
            result += block('support_'+name, generator(cfg[name]))
    return result


def rigid_pose_code(c):
    config(c, ('objects',), 'rigidPose')
    count=integer(c.get('objects'),1,255,'objects')
    code=f''' ; X=source object,Y=destination. All pose fields copied atomically.
rs_rigid_pose:
 cpx #{count}
 bcs rs_rigid_bad
 cpy #{count}
 bcs rs_rigid_bad
 php
 sei
'''
    for field in ('pos_x_lo','pos_x_hi','pos_y_lo','pos_y_hi','pos_z_lo','pos_z_hi','pos_z_ext','ang_x_lo','ang_x_hi','ang_y_lo','ang_y_hi','ang_z_lo','ang_z_hi','scale'):
        code+=f' lda object_{field},x\n sta object_{field},y\n'
    code+=' plp\n sec\n rts\nrs_rigid_bad:\n clc\n rts\n'
    return code


def lod_code(c):
    config(c, ('objects','groups'), 'lod')
    count=integer(c.get('objects'),2,255,'objects');groups=c.get('groups')
    if not isinstance(groups,list) or not 1<=len(groups)<=32:
        raise ValueError('RUNTIME_SUPPORT: lod requires1..32 groups')
    used=[]
    for group in groups:
        config(group,('near','far','enter','leave'),'lod group')
        used += [integer(group.get(k),0,count-1,k) for k in ('near','far')]
        integer(group.get('enter'),0,32766,'enter');integer(group.get('leave'),group['enter']+1,32767,'leave')
    if len(set(used))!=len(used):raise ValueError('RUNTIME_SUPPORT: LOD object ownership must be disjoint')
    code=f''' ; X=group,A=distance low,Y=distance high, unsigned Q8.
; Only render visibility changes; collider ownership remains with application.
rs_lod_tick:
 cpx #{len(groups)}
 bcs rs_lod_bad
 sta rs_lod_distance
 sty rs_lod_distance+1
 stx rs_lod_group
 lda rs_lod_state,x
 bne rs_lod_leave
 lda rs_lod_enter_lo,x
 sta rs_lod_threshold
 lda rs_lod_enter_hi,x
 jmp rs_lod_compare
rs_lod_leave:
 lda rs_lod_leave_lo,x
 sta rs_lod_threshold
 lda rs_lod_leave_hi,x
rs_lod_compare:
 cmp rs_lod_distance+1
 bcc rs_lod_far
 bne rs_lod_near
 lda rs_lod_threshold
 cmp rs_lod_distance
 bcc rs_lod_far
rs_lod_near:
 lda #1
 bne rs_lod_store
rs_lod_far:
 lda #0
rs_lod_store:
 sta rs_lod_state,x
 ldy rs_lod_near_object,x
 sta object_visible,y
 eor #1
 ldy rs_lod_far_object,x
 sta object_visible,y
 ldx rs_lod_group
 lda rs_lod_state,x
 sec
 rts
rs_lod_bad:
 clc
 rts
rs_lod_distance: .word 0
rs_lod_threshold: .word 0
rs_lod_group: .byte 0
'''
    for name,values in [('near_object',[g['near'] for g in groups]),('far_object',[g['far'] for g in groups]),('state',[0]*len(groups))]:code+=data('rs_lod_'+name,values)
    for kind in ('enter','leave'):
        for suffix,shift in [('lo',0),('hi',8)]:code+=data('rs_lod_'+kind+'_'+suffix,[(g[kind]>>shift)&255 for g in groups])
    return code
