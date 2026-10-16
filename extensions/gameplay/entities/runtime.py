"""First bounded Q8 entity: edge-triggered use, events and XY box collision.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
Gameplay state never depends on draw calls; all timing is PAL simulation ticks.
"""


def distance(axis,center):
    q=round(center*256)
    return f''' sec
 lda explorer_cam_{axis}_lo
 sbc #{q&255}
 sta en_d{axis}
 lda explorer_cam_{axis}_hi
 sbc #{(q>>8)&255}
 sta en_d{axis}+1
 bpl +
 sec
 lda #0
 sbc en_d{axis}
 sta en_d{axis}
 lda #0
 sbc en_d{axis}+1
 sta en_d{axis}+1
+
'''


def limits(name,x,z):
    out=name+':\n'
    for axis,v in [('x',x),('z',z)]:
        q=round(v*256)
        out+=f''' lda en_d{axis}+1
 cmp #{q>>8}
 bcc +
 bne {name}_outside
 lda en_d{axis}
 cmp #{q&255}
 bcc +
 beq +
 jmp {name}_outside
+
'''
    return out+f' sec\n rts\n{name}_outside:\n clc\n rts\n'


def kernel(config):
    b=config['billboards'][0];e=config['entity'];x,z=b['position'][:2]
    code=KERNEL
    origin=round(x*256)
    code=code.replace('en_manual_move:\n',f''' lda #{origin&255}
 sta explorer_cam_x_lo
 lda #{(origin>>8)&255}
 sta explorer_cam_x_hi
 lda #{255 if origin<0 else 0}
 sta explorer_cam_x_ext
en_manual_move:
''',1)
    code+='en_distance:\n'+distance('x',x)+distance('z',z)+' rts\n'
    code+=limits('en_range',e['useRange'],e['useRange'])
    code+=limits('en_solid',e['collisionHalfSize'][0]+.5,e['collisionHalfSize'][1]+.5)
    code+='en_room_distance:\n'+distance('x',0)+distance('z',0)+' rts\n'+limits('en_room',23,23)
    for axis in 'xz':
        for suffix in ('plus','minus'):
            code+=f'en_{axis}_{suffix}:\n ldx #{0 if axis=="x" else 1}\n'+(' clc\n' if suffix=='plus' else ' sec\n')
            for i,part in enumerate(('lo','hi')):
                code+=f' lda explorer_cam_{axis}_{part}\n '+('adc' if suffix=='plus' else 'sbc')+f' #{64 if i==0 else 0}\n sta en_candidate+{i}\n'
            code+=' jmp en_move\n'
    code+='en_demo_keys: .byte '+','.join(str(int(k in e['demoUseKeys'])) for k in range(48))+'\n'
    code+='en_enabled: .byte '+str(int(e['enabled']))+'\n'
    for n,v in [('last_key',255),('manual',0),('state',0),('event',0),('event_count',0),('rejected',0),('use_latch',0),('blocked',0),('axis',0),('key_override',0),('space_override',0)]:
        code+=f'en_{n}: .byte {v}\n'
    for n in ('dx','dz','candidate','saved'):code+=f'en_{n}: .word 0\n'
    code+='en_cam_lo: .word explorer_cam_x_lo,explorer_cam_z_lo\nen_cam_hi: .word explorer_cam_x_hi,explorer_cam_z_hi\n'
    return code


KERNEL='''en_tick:
 lda #0
 sta en_event
 sta en_blocked
 lda en_enabled
 bne +
 rts
+
 ; Native keyboard matrix routine already owns port setup/restoration.
 lda en_key_override
 bne +
 jsr explorer_scan_keys
+
 lda explorer_key_col2
 and #2
 bne +
 lda #0
 sta en_manual
+
 lda explorer_key_col1
 and #$26
 cmp #$26
 bne en_enter_manual
 lda explorer_key_col2
 and #4
 beq en_enter_manual
 jmp en_after_move
en_enter_manual:
 lda en_manual
 bne en_manual_move
 lda #1
 sta en_manual
 lda #0
 sta explorer_cam_x_lo
 sta explorer_cam_x_hi
 sta explorer_cam_x_ext
 sta explorer_cam_y_lo
 sta explorer_cam_y_hi
 sta explorer_cam_y_ext
 sta explorer_cam_z_lo
 sta explorer_cam_yaw
 sta explorer_cam_pitch
 sta qc_demo_yaw_lo
 sta qc_demo_pitch_lo
 lda #234
 sta explorer_cam_z_hi
 lda #255
 sta explorer_cam_z_ext
en_manual_move:
 lda explorer_key_col1
 and #$22
 beq en_no_ws
 cmp #$22
 beq en_no_ws
 and #2
 bne +
 jsr en_z_plus
 jmp en_no_ws
+
 jsr en_z_minus
en_no_ws:
 lda explorer_key_col1
 and #4
 bne en_check_d
 lda explorer_key_col2
 and #4
 beq en_after_move
 jsr en_x_minus
 jmp en_after_move
en_check_d:
 lda explorer_key_col2
 and #4
 bne en_after_move
 jsr en_x_plus
en_after_move:
 lda explorer_key_col7
 eor #255
 and #$10
 ora en_space_override
 beq en_release
 lda en_use_latch
 bne en_demo
 lda #1
 sta en_use_latch
 jsr en_use
 jmp en_demo
en_release:
 lda #0
 sta en_use_latch
en_demo:
 lda en_manual
 bne en_done
 lda demo_key
 cmp en_last_key
 beq en_done
 sta en_last_key
 tax
 lda en_demo_keys,x
 beq en_done
 jsr en_use
en_done:
 rts

en_use:
 jsr en_distance
 jsr en_range
 bcs en_use_allowed
 inc en_rejected
 lda #2
 sta en_event
 rts
en_use_allowed:
 lda en_state
 eor #1
 sta en_state
 sta bc_state
 inc en_event_count
 lda #1
 sta en_event
 rts

; Each temporary candidate is accepted or restored before the next render.
; Axis separation permits sliding; half sizes include player0.5WU.
en_move:
 stx en_axis
 txa
 asl
 tax
 lda en_cam_lo,x
 sta en_write_lo+1
 sta en_read_lo+1
 lda en_cam_lo+1,x
 sta en_write_lo+2
 sta en_read_lo+2
 lda en_cam_hi,x
 sta en_write_hi+1
 sta en_read_hi+1
 lda en_cam_hi+1,x
 sta en_write_hi+2
 sta en_read_hi+2
en_read_lo:
 lda $ffff
 sta en_saved
en_read_hi:
 lda $ffff
 sta en_saved+1
 jsr en_publish
 jsr en_room_distance
 jsr en_room
 bcc en_collision
 jsr en_distance
 jsr en_solid
 bcc en_moved
en_collision:
 lda #1
 sta en_blocked
 lda en_saved
 sta en_candidate
 lda en_saved+1
 sta en_candidate+1
 jsr en_publish
en_moved:
 lda en_candidate+1
 asl
 lda #0
 sbc #0
 eor #255
 ldx en_axis
 bne +
 sta explorer_cam_x_ext
 rts
+
 sta explorer_cam_z_ext
 rts
en_publish:
 lda en_candidate
en_write_lo:
 sta $ffff
 lda en_candidate+1
en_write_hi:
 sta $ffff
 rts
'''
