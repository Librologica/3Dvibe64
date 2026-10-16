"""Bounded vertical sliding door, driven by the existing guardian entity.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
The leaf retracts into its lintel. Visible bottom vertices retain full Q8.
"""
from entity_runtime import distance,limits

WIDTH=10
PLANE=8
HEIGHT=18
CLEAR_Q8=12*256+64 # floor-10, head+2, clearance0.25WU
STEP_Q8=64


def validate(config):
    if not isinstance(config,dict) or set(config)!={'schema','motion'} or type(config['schema']) is not int or config['schema']!=1 or type(config['motion']) is not bool:
        raise ValueError('Door configuration requires schema1 and boolean motion')
    return config


def kernel(config,bottom_vertices):
    validate(config)
    code=KERNEL
    code+='dr_plane_distance:\n'+distance('z',PLANE)+distance('x',0)+' rts\n'
    code+=limits('dr_plane',24,1)+limits('dr_aperture',4.5,1)+limits('dr_occupant',5.5,1)
    code+='''dr_vertices:
 clc
 lda hc_origin_y
 adc dr_lift
 sta dr_y
 lda hc_origin_y+1
 adc dr_lift+1
 sta dr_y+1
 lda hc_origin_y+2
 adc #0
 sta dr_y+2
 sec
 lda dr_y+1
 sbc #10
 sta dr_y+1
 lda dr_y+2
 sbc #0
 sta dr_y+2
'''
    for v in bottom_vertices:
        for i in range(3):
            code+=f' lda dr_y+{i}\n sta hc_cam_y{i}+{v}\n'
            if i==1:code+=f' sta rybuf+{v}\n sta vyrawlo+{v}\n'
            if i==2:code+=f' sta vyrawhi+{v}\n'
    code+=' rts\n'
    code+='dr_motion: .byte '+str(int(config['motion']))+'\ndr_state: .byte 0\ndr_lift: .word 0\ndr_passable: .byte 0\ndr_safety_events: .byte 0\ndr_y: .fill 3,0\n'
    code+='dr_seen_states: .byte 0\ndr_state_bits: .byte 1,2,4,8\ndr_route_fault: .byte 0\ndr_passages: .byte 0\ndr_side: .byte 0\n'
    return code


KERNEL='''; States:0 closed,1 opening,2 open,3 closing.
dr_restart:
 lda #0
 sta en_state
 sta bc_state
 sta dr_lift
 sta dr_lift+1
 sta dr_state
 sta dr_passable
 sta dr_seen_states
 sta dr_route_fault
 sta dr_passages
 sta dr_side
 sta dr_safety_events
 sta demo_key
 sta demo_subtick
 sta en_last_key
 ; Restart the demo route atomically with the closed door, before rendering.
 jsr qc_demo_tick
 rts
dr_tick:
 lda dr_motion
 bne +
 jmp dr_sync
+
 lda en_state
 bne dr_open_request
 lda dr_lift
 ora dr_lift+1
 bne dr_close_request
 lda #0
 sta dr_state
 jmp dr_sync
dr_close_request:
 jsr dr_plane_distance
 jsr dr_occupant
 bcc dr_close_clear
 ; An actor in the passage reverses closing before head clearance shrinks.
 lda #1
 sta en_state
 sta bc_state
 inc dr_safety_events
 jmp dr_open_request
dr_close_clear:
 lda #3
 sta dr_state
 sec
 lda dr_lift
 sbc #64
 sta dr_lift
 lda dr_lift+1
 sbc #0
 sta dr_lift+1
 bcc dr_closed
 ora dr_lift
 bne dr_sync
dr_closed:
 lda #0
 sta dr_lift
 sta dr_lift+1
 sta dr_state
 jmp dr_sync
dr_open_request:
 lda dr_lift+1
 cmp #18
 bcs dr_opened
 lda #1
 sta dr_state
 clc
 lda dr_lift
 adc #64
 sta dr_lift
 lda dr_lift+1
 adc #0
 sta dr_lift+1
 cmp #18
 bcc dr_sync
dr_opened:
 lda #18
 sta dr_lift+1
 lda #0
 sta dr_lift
 lda #2
 sta dr_state
dr_sync:
 ldx dr_state
 lda dr_state_bits,x
 ora dr_seen_states
 sta dr_seen_states
 lda #0
 sta dr_passable
 jsr dr_height_clear
 bcc +
 inc dr_passable
+
 lda dr_motion
 beq dr_sync_done
 lda en_manual
 bne dr_sync_done
 ; Audit every actual automatic-camera tick, including the full pass.
 jsr dr_can_stand
 bcs dr_route_valid
 lda dr_route_fault
 cmp #255
 beq dr_route_valid
 inc dr_route_fault
dr_route_valid:
 lda explorer_cam_z_hi
 eor #128
 cmp #136
 lda #0
 rol
 cmp dr_side
 beq dr_sync_done
 sta dr_side
 inc dr_passages
dr_sync_done:
 rts
dr_height_clear:
 lda dr_lift+1
 cmp #12
 bcc dr_height_blocked
 bne dr_height_open
 lda dr_lift
 cmp #64
 rts
dr_height_open:
 sec
 rts
dr_height_blocked:
 clc
 rts
dr_can_stand:
 jsr dr_plane_distance
 jsr dr_plane
 bcc dr_height_open
 jsr dr_aperture
 bcc dr_height_blocked
 jmp dr_height_clear
'''
