AUTO_COUNT=12
EXPERIMENT_AUTO=0
clamp8=$0200
times9=$0300
; raycast-stock autonomous 6510 backend. Copyright 2026 librologica.digital.
; PolyForm Noncommercial 1.0.0. No polygon renderer linked.
DIAGNOSTIC = 0
RAYCAST = 1
TEXTURED = 1
INITIAL_X=2432
INITIAL_Y=2534
INITIAL_ANGLE=272
AUTO_RUN=0
ROUTE_LENGTH=1
cpu_fast=$18
split_start=$19
split_value=$1a
cpu_probe=$1b
split_delay=$1c
ptr_l=$02
ptr_r=$04
drawbuf=$06
display_buf=$07
ready=$08
irq_phase=$09
video_standard=$0a
video_hz=$0b
pending_ticks=$0c
ntsc_phase=$0d
fps_count=$0e
fps_refresh=$0f
fps_value=$10
tick_overflow=$11
frame_count=$12 ; 16-bit complete presented frames
sim_ticks=$14 ; 16-bit simulation ticks
strip_lo=$3800
strip_hi=$3850
depth_lo=$3900
depth_hi=$3950

*=$0801
 .word $080b,10
 .byte $9e
 .text "2061"
 .byte 0
 .word 0
start:
 sei
 cld
 ldx #$ff
 txs
 lda #$7f
 sta $dc0d
 sta $dd0d
 lda $dc0d
 lda $dd0d
 lda #<nmi
 sta $fffa
 lda #>nmi
 sta $fffb
 lda #<irq
 sta $fffe
 lda #>irq
 sta $ffff
 lda #$35
 sta $01
 lda #$00
 sta $d01a
 sta $d015
 sta $d020
 lda #0
 sta $d021
 lda #0
 sta $d011
 ldx #$15
clear_state:
 sta $02,x
 dex
 bpl clear_state
 jsr init_video_standard
 lda #0
 sta cpu_fast
 lda #$ff
 sta $dd04
 sta $dd05
 lda #$11
 sta $dd0e ; CIA2 timer A free-running; NMI interrupts remain masked
 lda $dd02
 ora #3
 sta $dd02
 lda $dd00
 and #$fc
 ora #2
 sta $dd00
 lda #$ff
 sta $dc02
 sta $dc00
 lda #0
 sta $dc03
 ; Every screen byte outside 0..999, including sprite pointers, is guarded.
 ldx #0
 lda #$a5
init_screens:
 sta $4000,x
 sta $4100,x
 sta $4200,x
 sta $4300,x
 sta $cc00,x
 sta $cd00,x
 sta $ce00,x
 sta $cf00,x
 inx
 bne init_screens
 ldx #119
init_ui:
 lda ui_text,x
 sta $4000,x
 sta $cc00,x
 lda #1
 sta $d800,x
 dex
 bpl init_ui
 ldx #0
 lda #7
init_color:
 sta $d878,x
 sta $d978,x
 sta $da78,x
 inx
 bne init_color
 ldx #111
init_color_tail:
 sta $db78,x
 dex
 bpl init_color_tail
 ldx #0
 lda #$98
palette_screen:
 sta $4078,x
 sta $4178,x
 sta $4278,x
 sta $cc78,x
 sta $cd78,x
 sta $ce78,x
 inx
 bne palette_screen
 ldx #111
palette_tail:
 sta $4378,x
 sta $cf78,x
 dex
 bpl palette_tail
 lda #$34
 sta $01
 ldx #0
copy_second_font:
 lda $5800,x
 sta $d800,x
 lda $5900,x
 sta $d900,x
 lda $5a00,x
 sta $da00,x
 lda $5b00,x
 sta $db00,x
 lda $5c00,x
 sta $dc00,x
 lda $5d00,x
 sta $dd00,x
 lda $5e00,x
 sta $de00,x
 lda $5f00,x
 sta $df00,x
 inx
 bne copy_second_font
 lda #$35
 sta $01
 lda #11
 sta $d022
 lda #12
 sta $d023
.if TEXTURED = 0
 ldx #79
init_strips:
 lda synthetic_lo,x
 sta strip_lo,x
 lda synthetic_hi,x
 sta strip_hi,x
 dex
 bpl init_strips
.endif
.if RAYCAST != 0
 jsr init_camera
.endif
.if TEXTURED != 0
 jsr init_simulation
 jsr latch_pose
.endif
 jsr init_masks
 jsr vp_clear_frame
 lda #0
 sta drawbuf
 jsr compose_screen
 lda #1
 sta drawbuf
 jsr compose_screen
.if DIAGNOSTIC != 0
 ldx #0
diag_codes:
 txa
 sta $4078,x
 sta $4478,x
 inx
 bne diag_codes
.endif
 nop
 nop
 nop
 lda #$1b
 sta $d011
 lda #$18 ; UI cells have Color RAM bit3=0, so remain hires.
 sta $d016
 lda #$06
 sta $d018
 lda #0
 sta $d012
 lda #1
 sta $d019
 sta $d01a
 cli
main_loop:
 jsr consume_video_ticks
render_frame_begin:
.if RAYCAST != 0
 jsr latch_pose
.if TEXTURED != 0
.endif
.endif
.if DIAGNOSTIC = 0
 jsr compose_screen
.endif
render_frame_end:
 lda #1
 sta ready ; release flag set ONLY after all 880 cells and UI are complete
wait_present:
 lda ready
 bne wait_present
presentation_done:
 jmp main_loop

; Adapted from frozen build-3Dvibe64.ps1:10616 detect_video_standard.
; Same high-raster threshold, autonomous state; no KERNAL assumption.
init_video_standard:
detect_low:
 lda $d011
 bmi detect_low
detect_high:
 lda $d011
 bpl detect_high
detect_scan:
 lda $d011
 bpl detect_ntsc
 lda $d012
 cmp #$20
 bcc detect_scan
 lda #0
 sta video_standard
 lda #50
 sta video_hz
 rts
detect_ntsc:
 lda #1
 sta video_standard
 lda #60
 sta video_hz
 rts

; Adapted tick policy from generator:9912, mesh/light updates removed.
consume_video_ticks:
 sei
 lda pending_ticks
 beq ticks_done
 dec pending_ticks
 cli
 lda video_standard
 beq advance_sim_tick
 inc ntsc_phase
 lda ntsc_phase
 cmp #6
 bcc advance_sim_tick
 lda #0
 sta ntsc_phase
 jmp consume_video_ticks
advance_sim_tick:
.if TEXTURED != 0
 jsr simulation_tick
.endif
 inc sim_ticks
 bne tick_next
 inc sim_ticks+1
tick_next:
 jmp consume_video_ticks
ticks_done:
 cli
 rts

; Own RAM-vector IRQ, not KERNAL/bitmap split. No renderer ZP touched.
irq:
 pha
 txa
 pha
 tya
 pha
 lda #1
 sta $d019
 lda irq_phase
 beq irq_top
 ; IRQ line73, synchronize on74, then delay51 clocks. D018 changes after
 ; final UI glyph fetch (cycle55) and before body badline BA goes low.
 ; Waiting directly for75 is unsafe: one polling phase can stall until56.
 ; BIT zero-page +24 NOP =51; no SMC, A remains the prepared D018 value.
 lda display_buf
 beq body_bank_a
 lda #$30
body_bank_a:
 ora #8
 sta split_value
 ldy cpu_fast
 bne irq_fast_body
 ldx #74
irq_wait_body:
 cpx $d012
 bne irq_wait_body
 bit irq_phase
 .rept 24
 nop
 .endrept
 sta $d018
 jmp irq_split_body_done
irq_fast_body:
 ldx #74
irq_fast_wait_body:
 cpx $d012
 bne irq_fast_wait_body
 lda $dd04
 sta split_start
irq_timer_body:
 lda split_start
 sec
 sbc $dd04
 cmp split_delay
 bcc irq_timer_body
 lda split_value
 sta $d018
irq_split_body_done:
 lda #$3b
 sta $d011
 lda #0
 sta irq_phase
 sta $d012
 jmp irq_exit
irq_top:
 lda ready
 beq irq_no_swap
 lda drawbuf
 sta display_buf
 eor #1
 sta drawbuf
 lda #0
 sta ready
 inc frame_count
 bne fps_frame_done
 inc frame_count+1
fps_frame_done:
 ; Same semantic as 1.3.0: count only complete actually presented images.
 inc fps_count
irq_no_swap:
 ; Measure the same instruction sequence each refresh, so live CPU changes work.
 lda $dd04
 sta cpu_probe
 .rept 24
 nop
 .endrept
 lda cpu_probe
 sec
 sbc $dd04
 sta cpu_probe
 cmp #40
 lda #0
 bcs probe_stock
 lda #1
probe_stock:
 sta cpu_fast
 lda cpu_probe
 lsr
 lsr
 lsr
 sta cpu_probe
 lda #54
 sec
 sbc cpu_probe
 sta split_delay
 lda #$1b
 sta $d011
 lda $dd00
 and #$fc
 ldx display_buf
 bne ui_bank_b
 ora #2
ui_bank_b:
 sta $dd00
 lda display_buf
 beq ui_bank_a
 lda #$30
ui_bank_a:
 ora #6
 sta $d018
 inc pending_ticks
 bne irq_tick_ok
 dec pending_ticks
 lda #1
 sta tick_overflow
irq_tick_ok:
 inc fps_refresh
 lda fps_refresh
 cmp video_hz
 bcc irq_no_second
 lda #0
 sta fps_refresh
 lda fps_count
 sta fps_value
 ldx #0
fps_decimal:
 cmp #10
 bcc fps_decimal_done
 sec
 sbc #10
 inx
 bne fps_decimal
fps_decimal_done:
 ora #$30
 sta $402e
 sta $cc2e
 txa
 ora #$30
 sta $402d
 sta $cc2d
 lda #0
 sta fps_count
irq_no_second:
 lda #1
 sta irq_phase
 lda #72
 sta $d012
 nop
 nop
 nop
irq_exit:
 pla
 tay
 pla
 tax
 pla
 rti
nmi:
 rti


; Experimental heightfield extension. Documented 6510 instructions only.
cam_x=$20
cam_y=$22
cam_angle=$24
pose_x=$26
pose_y=$28
pose_angle=$2a
cam_z=$2c
pose_z=$2d
r_pixel=$30
r_group=$31
r_slot=$32
r_dx=$34
r_dy=$36
r_sx=$38
r_sy=$3a
r_t=$3c
r_flags=$3e
r_steps=$3f
r_index=$40
r_floor=$42
r_ceil=$43
r_newfloor=$44
r_newceil=$45
r_wall=$46
r_side=$47
r_factor=$49
clip_top=$4c
clip_bottom=$4d
r_addr=$4f
r_depth=$51
r_shade=$53
r_angle=$54
ma=$80
mb=$83
mr=$84
surface=$87
negative=$88
fill_start=$90
fill_end=$91
fill_color=$92
fill_value=$93
fill_limit=$94
fill_even=$95
fill_odd=$96
floor_here=$97
qlo=$98
qhi=$99
faults=$f2
frame_steps=$f3
frame_boundaries=$f5

init_camera:
 lda #<2432
 sta cam_x
 lda #>2432
 sta cam_x+1
 lda #<2534
 sta cam_y
 lda #>2534
 sta cam_y+1
 lda #<272
 sta cam_angle
 lda #>272
 sta cam_angle+1
 lda #0
 sta faults
 sta cam_z_frac
 lda #32
 sta cam_z
 rts
latch_pose:
 ldx #5
latch_loop:
 lda cam_x,x
 sta pose_x,x
 dex
 bpl latch_loop
 lda cam_z
 sta pose_z
 lda cam_z_frac
 sta pose_z_frac
 rts

; Exact unsigned16x8 ->24 via two quarter-square8x8 products.
; Only the four operand LOW bytes below are patched; foreground only.
multiply:
 lda ma
 jsr multiply8
 lda qlo
 sta mr
 lda qhi
 sta mr+1
 lda ma+1
 jsr multiply8
 clc
 lda qlo
 adc mr+1
 sta mr+1
 lda qhi
 adc #0
 sta mr+2
multiply_return:
 rts
multiply8:
 sta qs_sum_lo_load+1
 sta qs_sum_hi_load+1
 eor #$ff
 sta qs_diff_lo_load+1
 sta qs_diff_hi_load+1
 ldy mb
 sec
qs_sum_lo_load:
 lda qs_sum_lo,y
qs_diff_lo_load:
 sbc qs_diff_lo,y
 sta qlo
qs_sum_hi_load:
 lda qs_sum_hi,y
qs_diff_hi_load:
 sbc qs_diff_hi,y
 sta qhi
 rts

camera_cell:
 lda cam_y+1
 lsr
 lsr
 lsr
 sta r_index+1
 lda cam_y+1
 asl
 asl
 asl
 asl
 asl
 ora cam_x+1
 sta r_index
 rts
read_cell:
 lda r_index
 sta r_addr
 lda r_index+1
 clc
 adc #$3c
 sta r_addr+1
 ldy #0
 lda (r_addr),y
 sta r_wall
 lda r_index+1
 clc
 adc #$34
 sta r_addr+1
 lda (r_addr),y
 sta r_newfloor
 lda r_index+1
 clc
 adc #$38
 sta r_addr+1
 lda (r_addr),y
 sta r_newceil
 rts

collision_check:
 ; Check the four footprint corners; all thresholds remain grid-based.
 jsr camera_cell
 jsr read_cell
 lda r_newfloor
 sta floor_here
 sec
 lda candidate_x
 sbc #48
 lda candidate_x+1
 sbc #0
 cmp #32
 bcs collision_blocked
 sta box_x0
 clc
 lda candidate_x
 adc #48
 lda candidate_x+1
 adc #0
 cmp #32
 bcs collision_blocked
 sta box_x1
 sec
 lda candidate_y
 sbc #48
 lda candidate_y+1
 sbc #0
 cmp #32
 bcs collision_blocked
 sta box_y0
 clc
 lda candidate_y
 adc #48
 lda candidate_y+1
 adc #0
 cmp #32
 bcs collision_blocked
 sta box_y1
 lda box_y0
 jsr collision_row
 bcs collision_blocked
 lda box_y1
 jsr collision_row
 rts
collision_row:
 pha
 lsr
 lsr
 lsr
 sta r_index+1
 pla
 asl
 asl
 asl
 asl
 asl
 sta r_index
 ora box_x0
 sta r_index
 jsr collision_cell
 bcs collision_blocked
 lda r_index
 and #$e0
 ora box_x1
 sta r_index
 jsr collision_cell
 rts
collision_cell:
 jsr read_cell
 lda r_wall
 bne collision_blocked
 clc
 rts
collision_blocked:
 sec
 rts

auto_input:
 lda auto_left
 ora auto_left+1
 bne auto_active
 ldx auto_index
 lda auto_keys,x
 sta auto_key
 lda auto_duration_lo,x
 sta auto_left
 lda auto_duration_hi,x
 sta auto_left+1
 inx
 txa
 cmp #AUTO_COUNT
 bcc auto_index_ready
 lda #0
auto_index_ready:
 sta auto_index
auto_active:
 lda auto_key
 sta keys
 lda auto_left
 bne auto_decrement
 dec auto_left+1
auto_decrement:
 dec auto_left
 rts
candidate_x=$58
candidate_y=$5a
box_x0=$5c
box_x1=$5d
box_y0=$5e
box_y1=$5f
keys=$60
move_x=$61
move_y=$62
auto_index=$3290
auto_left=$3291
auto_key=$3293
key_row=$67
collision_ptr=$68
input_override=$6a ; $ff normal input; 0..15 deterministic monitor tests
init_simulation:
.if AUTO_RUN != 0
 jsr nav_init
.endif
 lda #0
 sta auto_index
 sta auto_left
 sta auto_left+1
 lda #$ff
 sta input_override
 rts
simulation_tick:
 jsr read_input
input_sampled:
 lda keys
 and #4
 beq sim_not_left
 sec
 lda cam_angle
 sbc #2
 sta cam_angle
 lda cam_angle+1
 sbc #0
 and #1
 sta cam_angle+1
sim_not_left:
 lda keys
 and #8
 beq sim_not_right
 clc
 lda cam_angle
 adc #2
 sta cam_angle
 lda cam_angle+1
 adc #0
 and #1
 sta cam_angle+1
sim_not_right:
 lda keys
 and #3
 beq simulation_done
 cmp #3
 beq simulation_done
 ldy cam_angle
 lda cam_angle+1
 bne sim_direction_high
 lda movement_x,y
 sta move_x
 lda movement_y,y
 jmp sim_direction_done
sim_direction_high:
 lda movement_x+256,y
 sta move_x
 lda movement_y+256,y
sim_direction_done:
 sta move_y
 lda keys
 and #2
 beq sim_forward
 lda #0
 sec
 sbc move_x
 sta move_x
 lda #0
 sec
 sbc move_y
 sta move_y
sim_forward:
.if AUTO_RUN != 0
 jsr nav_scale_speed
.endif
 ldx #0
 lda move_x
 bpl sim_dx_positive
 dex
sim_dx_positive:
 clc
 adc cam_x
 sta candidate_x
 txa
 adc cam_x+1
 sta candidate_x+1
 lda cam_y
 sta candidate_y
 lda cam_y+1
 sta candidate_y+1
 jsr collision_check
 bcs sim_x_blocked
 lda candidate_x
 sta cam_x
 lda candidate_x+1
 sta cam_x+1
sim_x_blocked:
 lda cam_x
 sta candidate_x
 lda cam_x+1
 sta candidate_x+1
 ldx #0
 lda move_y
 bpl sim_dy_positive
 dex
sim_dy_positive:
 clc
 adc cam_y
 sta candidate_y
 txa
 adc cam_y+1
 sta candidate_y+1
 jsr collision_check
 bcs simulation_done
 lda candidate_y
 sta cam_y
 lda candidate_y+1
 sta cam_y+1
simulation_done:
 jsr stairs_update_z
 rts

read_input:
 lda input_override
 cmp #$ff
 beq input_normal
 sta keys
 rts
input_normal:
.if AUTO_RUN != 0
 jmp nav_input
.else
 ; Joystick port2 active-low directions, no fire action in v1.
 lda #0
 sta $dc02
 lda $dc00
 eor #$ff
 and #15
 sta keys
 lda #$ff
 sta $dc02
 ; Row1: W(bit1), A(bit2), S(bit5). Row2: D(bit2).
 lda #$fd
 sta $dc00
 lda $dc01
 sta key_row
 and #2
 bne input_not_w
 lda keys
 ora #1
 sta keys
input_not_w:
 lda key_row
 and #$20
 bne input_not_s
 lda keys
 ora #2
 sta keys
input_not_s:
 lda key_row
 and #4
 bne input_not_a
 lda keys
 ora #4
 sta keys
input_not_a:
 lda #$fb
 sta $dc00
 lda $dc01
 and #4
 bne input_not_d
 lda keys
 ora #8
 sta keys
input_not_d:
 lda #$ff
 sta $dc00
 rts
.endif

; Ordered event DDA + shared surface profiles. Foreground-only SMC.
path_out=$b5
path_read=$b7
path_compare=$b9
path_count=$bb
map_page=$bc
col=$76
rowtop=$77
scratch_byte=$7d
outptr=$7e
glyphindex=$88
group=$3200
fine_mode=$3201
fine_lane=$3202
event_index=$3203
current_event=$3204
current_flags=$3205
wall_shade=$3206
cache_next=$3207
clip_t=$3210
clip_b=$3214
samples=$3218
refine=$3220
slot_keys=$a780
cache_map=$3300
cache_misses=$3270
frame_rays=$3272
frame_fine=$3274
unit_plane=$3276
unit_value=$3277
unit_sign=$327b
pixel_base=$327c
saved_path=$327d
fine_path=$32a0

compose_screen:
 lda #0
 sta group
 sta frame_steps
 sta frame_steps+1
 sta frame_boundaries
 sta frame_boundaries+1
 sta cache_next
 sta cache_misses
 sta cache_misses+1
 sta frame_rays
 sta frame_rays+1
 sta frame_fine
 lda #$ff
 sta unit_plane
 ldx #0
reset_cache:
 sta cache_map,x
 inx
 bne reset_cache
 ldx #31
reset_slots:
 sta slot_keys,x
 dex
 bpl reset_slots
geometry_begin:
 jsr ray_prepare
coarse_next:
 ldx group
 lda path_lo,x
 sta path_out
 lda path_hi,x
 sta path_out+1
 lda offsets_lo,x
 sta r_angle
 lda offsets_hi,x
 jsr trace_path
 inc group
 lda group
 cmp #33
 bne coarse_next
 lda #0
 ldx #31
clear_refine:
 sta refine,x
 dex
 bpl clear_refine
 lda #0
 sta group
compare_next:
 ldx group
 lda path_lo,x
 sta path_read
 lda path_hi,x
 sta path_read+1
 lda path_lo+1,x
 sta path_compare
 lda path_hi+1,x
 sta path_compare+1
 ldy #0
compare_event:
 lda (path_read),y
 cmp (path_compare),y
 bne compare_different
 cmp #0
 beq compare_done
 iny
 bne compare_event
compare_different:
 lda #1
 sta refine,x
compare_done:
 inc group
 lda group
 cmp #32
 bne compare_next
geometry_end:
 jsr clear_view
 lda #0
 sta group
group_next:
 lda group
 sta col
 asl
 asl
 sta pixel_base
 ldx #3
group_clip:
 lda #0
 sta clip_t,x
 lda #144
 sta clip_b,x
 dex
 bpl group_clip
 ldx group
 lda refine,x
 sta fine_mode
 beq group_coarse
 inc frame_fine
 jsr init_fine_group
 lda #0
 sta fine_lane
fine_next:
 jsr init_fine_column
 lda #<fine_path
 sta path_out
 lda #>fine_path
 sta path_out+1
 lda pixel_base
 clc
 adc fine_lane
 tax
 lda fine_offsets_lo,x
 sta r_angle
 lda fine_offsets_hi,x
 jsr trace_path
 lda #<fine_path
 sta saved_path
 lda #>fine_path
 sta saved_path+1
 jsr render_fine_path
 inc fine_lane
 lda fine_lane
 cmp #4
 bne fine_next
 jsr compose_fine
 jmp group_done
group_coarse:
 lda path_lo,x
 sta saved_path
 lda path_hi,x
 sta saved_path+1
 jsr render_path
group_done:
 inc group
 lda group
 cmp #32
 bne group_next
 rts

; Input angle offset high in A, low r_angle; output zero-terminated path.
trace_path:
 pha
 inc frame_rays
 bne trace_counted
 inc frame_rays+1
trace_counted:
 clc
 lda r_angle
 adc pose_angle
 sta r_angle
 pla
 adc pose_angle+1
 and #1
 tax
 ldy r_angle
 cpx #0
 bne trace_high
 lda dir_dx_lo,y
 sta r_dx
 lda dir_dx_hi,y
 sta r_dx+1
 lda dir_dy_lo,y
 sta r_dy
 lda dir_dy_hi,y
 sta r_dy+1
 lda dir_flags,y
 jmp trace_direction
trace_high:
 lda dir_dx_lo+256,y
 sta r_dx
 lda dir_dx_hi+256,y
 sta r_dx+1
 lda dir_dy_lo+256,y
 sta r_dy
 lda dir_dy_hi+256,y
 sta r_dy+1
 lda dir_flags+256,y
trace_direction:
 sta r_flags
 and #3
 cmp dda_quadrant
 beq dda_prepared
 tax
 sta dda_quadrant
 lda dda_x_lo_table,x
 sta dda_x_dispatch+1
 lda dda_x_hi_table,x
 sta dda_x_dispatch+2
 lda dda_y_lo_table,x
 sta dda_y_dispatch+1
 lda dda_y_hi_table,x
 sta dda_y_dispatch+2
 lda dda_x_base_table,x
 sta dda_x_base+1
 lda dda_y_base_table,x
 sta dda_y_base+1
dda_prepared:
 jsr ray_product_x
 lda r_flags
 and #1
 bne trace_x_ready
 sec
 lda r_dx
 sbc r_sx
 sta r_sx
 lda r_dx+1
 sbc r_sx+1
 sta r_sx+1
trace_x_ready:
 lda r_flags
 and #4
 beq trace_x_not_axis
 lda #$ff
 sta r_sx
 sta r_sx+1
trace_x_not_axis:
 jsr ray_product_y
 lda r_flags
 and #2
 bne trace_y_ready
 sec
 lda r_dy
 sbc r_sy
 sta r_sy
 lda r_dy+1
 sbc r_sy+1
 sta r_sy+1
trace_y_ready:
 lda r_flags
 and #8
 beq trace_y_not_axis
 lda #$ff
 sta r_sy
 sta r_sy+1
trace_y_not_axis:
 lda pose_y+1
 lsr
 lsr
 lsr
 sta r_index+1
 lda pose_y+1
 asl
 asl
 asl
 asl
 asl
 ora pose_x+1
 sta r_index
 lda #0
 sta path_count
 sta r_steps
trace_advance:
 inc frame_steps
 bne trace_step_counted
 inc frame_steps+1
trace_step_counted:
 inc r_steps
 lda r_steps
 cmp #65
 bcc trace_in_bounds
 inc faults
 jmp trace_done
trace_in_bounds:
 lda r_sx+1
 cmp r_sy+1
 bcc trace_cross_x
 bne trace_cross_y
 lda r_sy
 cmp r_sx
 bcc trace_cross_y
trace_cross_x:
 clc
 lda r_sx
 adc r_dx
 sta r_sx
 lda r_sx+1
 adc r_dx+1
 sta r_sx+1
 bcc trace_x_added
 lda #$ff
 sta r_sx
 sta r_sx+1
trace_x_added:
dda_x_dispatch:
 jmp dda_x_plus
dda_x_minus:
 lda r_index
 bne dda_x_dec
 dec r_index+1
dda_x_dec:
 dec r_index
 jmp dda_x_read
dda_x_plus:
 inc r_index
 bne dda_x_read
 inc r_index+1
dda_x_read:
 lda r_index+1
 clc
dda_x_base:
 adc #$44
 jmp dda_set_page
trace_cross_y:
 clc
 lda r_sy
 adc r_dy
 sta r_sy
 lda r_sy+1
 adc r_dy+1
 sta r_sy+1
 bcc trace_y_added
 lda #$ff
 sta r_sy
 sta r_sy+1
trace_y_added:
dda_y_dispatch:
 jmp dda_y_plus
dda_y_minus:
 sec
 lda r_index
 sbc #32
 sta r_index
 bcs dda_y_read
 dec r_index+1
 jmp dda_y_read
dda_y_plus:
 clc
 lda r_index
 adc #32
 sta r_index
 bcc dda_y_read
 inc r_index+1
dda_y_read:
 lda r_index+1
 clc
dda_y_base:
 adc #$4c
dda_set_page:
 sta dda_read+2
 ldy r_index
dda_read:
 lda $4400,y
 beq trace_advance
 tax
 ldy path_count
 sta (path_out),y
 inc path_count
 inc frame_boundaries
 bne trace_event_counted
 inc frame_boundaries+1
trace_event_counted:
 lda event_flags,x
 and #1
 bne trace_done
 lda path_count
 cmp #15
 bcc trace_advance
 inc faults
trace_done:
 ldy path_count
 lda #0
 sta (path_out),y
 rts

render_path:
 lda saved_path
 sta path_read
 lda saved_path+1
 sta path_read+1
 ldy #0
 lda (path_read),y
 beq render_empty
 tax
 lda event_flags,x
 and #33
 cmp #1
 bne render_multilevel
single_flat_dispatch:
 jmp render_single_flat
render_multilevel:
 lda #0
 sta event_index
 txa
 jmp render_have_event
render_event:
 lda saved_path
 sta path_read
 lda saved_path+1
 sta path_read+1
 ldy event_index
 lda (path_read),y
 bne render_have_event
render_empty:
 rts
render_have_event:
 tax
 stx current_event
 lda event_flags,x
 sta current_flags
 and #16
 beq render_xshade
 lda #$aa
 bne render_shade
render_xshade:
 lda #$ff
render_shade:
 sta wall_shade
 lda event_ceiling,x
 jsr get_ceiling_fused
 ldx current_event
 lda event_floor,x
 jsr get_bottom_band
 lda current_flags
 and #32
 beq floor_brown
 lda #$aa
 bne floor_draw
floor_brown:
 ; Brown background below the horizon is already correct and unresolved.
 lda top_samples
 and top_samples+1
 ; Check all four, not monotonic endpoints.
 ldx #3
floor_skip_test:
 lda top_samples,x
 cmp #72
 bcc floor_needed
 dex
 bpl floor_skip_test
 jmp floor_done
floor_needed:
 lda #$55
floor_draw:
 sta band_shade
 jsr emit_band
floor_done:
 lda current_flags
 and #1
 beq event_transparent
 ldx #3
wall_clip:
 lda clip_t,x
 sta top_samples,x
 lda clip_b,x
 sta bottom_samples,x
 sta clip_t,x
 dex
 bpl wall_clip
 lda wall_shade
 sta band_shade
 jsr emit_band
 rts
event_transparent:
 lda current_flags
 and #2
 beq event_header_test
 ldx current_event
 lda event_riser,x
 jsr get_bottom_band
 lda wall_shade
 sta band_shade
 jsr emit_band
event_header_test:
 lda current_flags
 and #4
 beq event_next
 ldx current_event
 lda event_header,x
 jsr get_header_fused
 lda wall_shade
 sta band_shade
 jsr emit_band
event_next:
 lda fine_mode
 beq event_coarse_open
 ldx fine_lane
 lda clip_t,x
 cmp clip_b,x
 bcs event_closed
 jmp event_continue
event_coarse_open:
 ldx #3
event_open_test:
 lda clip_t,x
 cmp clip_b,x
 bcc event_continue
 dex
 bpl event_open_test
event_closed:
 rts
event_continue:
 inc event_index
 jmp render_event

get_bottom_band:
 jsr get_profile
bottom_band_samples:
 ldy pixel_base
 lda clip_b+0
 sta bottom_samples+0
 lda (p_out),y
 cmp clip_t+0
 bcs bottom_band_lower_0
 lda clip_t+0
bottom_band_lower_0:
 cmp clip_b+0
 bcc bottom_band_upper_0
 lda clip_b+0
bottom_band_upper_0:
 sta top_samples+0
 sta clip_b+0
 iny
 lda clip_b+1
 sta bottom_samples+1
 lda (p_out),y
 cmp clip_t+1
 bcs bottom_band_lower_1
 lda clip_t+1
bottom_band_lower_1:
 cmp clip_b+1
 bcc bottom_band_upper_1
 lda clip_b+1
bottom_band_upper_1:
 sta top_samples+1
 sta clip_b+1
 iny
 lda clip_b+2
 sta bottom_samples+2
 lda (p_out),y
 cmp clip_t+2
 bcs bottom_band_lower_2
 lda clip_t+2
bottom_band_lower_2:
 cmp clip_b+2
 bcc bottom_band_upper_2
 lda clip_b+2
bottom_band_upper_2:
 sta top_samples+2
 sta clip_b+2
 iny
 lda clip_b+3
 sta bottom_samples+3
 lda (p_out),y
 cmp clip_t+3
 bcs bottom_band_lower_3
 lda clip_t+3
bottom_band_lower_3:
 cmp clip_b+3
 bcc bottom_band_upper_3
 lda clip_b+3
bottom_band_upper_3:
 sta top_samples+3
 sta clip_b+3
 iny
 rts
get_ceiling_fused:
 jsr get_profile
ceiling_fused_samples:
 ldy pixel_base
 lda (p_out),y
 cmp clip_t+0
 bcs ceiling_fused_lower_0
 lda clip_t+0
ceiling_fused_lower_0:
 cmp clip_b+0
 bcc ceiling_fused_upper_0
 lda clip_b+0
ceiling_fused_upper_0:
 sta clip_t+0
 iny
 lda (p_out),y
 cmp clip_t+1
 bcs ceiling_fused_lower_1
 lda clip_t+1
ceiling_fused_lower_1:
 cmp clip_b+1
 bcc ceiling_fused_upper_1
 lda clip_b+1
ceiling_fused_upper_1:
 sta clip_t+1
 iny
 lda (p_out),y
 cmp clip_t+2
 bcs ceiling_fused_lower_2
 lda clip_t+2
ceiling_fused_lower_2:
 cmp clip_b+2
 bcc ceiling_fused_upper_2
 lda clip_b+2
ceiling_fused_upper_2:
 sta clip_t+2
 iny
 lda (p_out),y
 cmp clip_t+3
 bcs ceiling_fused_lower_3
 lda clip_t+3
ceiling_fused_lower_3:
 cmp clip_b+3
 bcc ceiling_fused_upper_3
 lda clip_b+3
ceiling_fused_upper_3:
 sta clip_t+3
 iny
 rts
get_header_fused:
 jsr get_profile
header_fused_samples:
 ldy pixel_base
 lda clip_t+0
 sta top_samples+0
 lda (p_out),y
 cmp clip_t+0
 bcs header_fused_lower_0
 lda clip_t+0
header_fused_lower_0:
 cmp clip_b+0
 bcc header_fused_upper_0
 lda clip_b+0
header_fused_upper_0:
 sta bottom_samples+0
 sta clip_t+0
 iny
 lda clip_t+1
 sta top_samples+1
 lda (p_out),y
 cmp clip_t+1
 bcs header_fused_lower_1
 lda clip_t+1
header_fused_lower_1:
 cmp clip_b+1
 bcc header_fused_upper_1
 lda clip_b+1
header_fused_upper_1:
 sta bottom_samples+1
 sta clip_t+1
 iny
 lda clip_t+2
 sta top_samples+2
 lda (p_out),y
 cmp clip_t+2
 bcs header_fused_lower_2
 lda clip_t+2
header_fused_lower_2:
 cmp clip_b+2
 bcc header_fused_upper_2
 lda clip_b+2
header_fused_upper_2:
 sta bottom_samples+2
 sta clip_t+2
 iny
 lda clip_t+3
 sta top_samples+3
 lda (p_out),y
 cmp clip_t+3
 bcs header_fused_lower_3
 lda clip_t+3
header_fused_lower_3:
 cmp clip_b+3
 bcc header_fused_upper_3
 lda clip_b+3
header_fused_upper_3:
 sta bottom_samples+3
 sta clip_t+3
 iny
 rts
clamp_samples:
 ldx #3
clamp_next:
 lda samples,x
 cmp clip_t,x
 bcs clamp_lower
 lda clip_t,x
clamp_lower:
 cmp clip_b,x
 bcc clamp_save
 lda clip_b,x
clamp_save:
 sta samples,x
 dex
 bpl clamp_next
 rts

emit_band:
 lda fine_mode
 beq emit_coarse
 ldx fine_lane
 lda bottom_samples,x
 sta fill_end
 ldy top_samples,x
 cpy fill_end
 bcs emit_done
 lda band_shade
 and pixel_mask,x
fine_fill:
 sta $5400,y
 iny
 cpy fill_end
 bcc fine_fill
emit_done:
 rts
emit_coarse:
 jmp draw_samples
pixel_mask:
 .byte $c0,$30,$0c,$03
init_fine_group:
 ldy #0
shared_init_loop:
 lda $a500,y
 sta $5400,y
 lda $a501,y
 sta $5401,y
 lda $a502,y
 sta $5402,y
 lda $a503,y
 sta $5403,y
 lda $a504,y
 sta $5404,y
 lda $a505,y
 sta $5405,y
 lda $a506,y
 sta $5406,y
 lda $a507,y
 sta $5407,y
 tya
 clc
 adc #8
 tay
 cpy #144
 bne shared_init_loop
 rts
init_fine_column:
 ldx fine_lane
 lda pixel_mask,x
 eor #$ff
 sta shared_mask_0+1
 sta shared_mask_1+1
 sta shared_mask_2+1
 sta shared_mask_3+1
 sta shared_mask_4+1
 sta shared_mask_5+1
 sta shared_mask_6+1
 sta shared_mask_7+1
 sta shared_tail_mask+1
 lda #0
 sta clip_t
 lda #144
 sta clip_b
 rts
scalar_fill:
 sta fill_value
 ldy fill_start
 cpy fill_end
 bcs scalar_done
 lda fill_end
 sec
 sbc fill_start
 cmp #8
 bcc scalar_tail_start
 lda fill_end
 sec
 sbc #7
 sta fill_limit
scalar_bulk:
 lda $5400,y
shared_mask_0:
 and #$ff
 ora fill_value
 sta $5400,y
 lda $5401,y
shared_mask_1:
 and #$ff
 ora fill_value
 sta $5401,y
 lda $5402,y
shared_mask_2:
 and #$ff
 ora fill_value
 sta $5402,y
 lda $5403,y
shared_mask_3:
 and #$ff
 ora fill_value
 sta $5403,y
 lda $5404,y
shared_mask_4:
 and #$ff
 ora fill_value
 sta $5404,y
 lda $5405,y
shared_mask_5:
 and #$ff
 ora fill_value
 sta $5405,y
 lda $5406,y
shared_mask_6:
 and #$ff
 ora fill_value
 sta $5406,y
 lda $5407,y
shared_mask_7:
 and #$ff
 ora fill_value
 sta $5407,y
 tya
 clc
 adc #8
 tay
 cpy fill_limit
 bcc scalar_bulk
scalar_tail_start:
 cpy fill_end
 bcs scalar_done
scalar_tail:
 lda $5400,y
shared_tail_mask:
 and #$ff
 ora fill_value
 sta $5400,y
 iny
 cpy fill_end
 bcc scalar_tail
scalar_done:
 rts

compose_fine:
 lda col
 asl
 asl
 asl
 tax
 ldy #0
 lda drawbuf
 bne shared_compose_b
shared_compose_a:
 lda $5400,y
 sta $6660,x
 lda $5408,y
 sta $67a0,x
 lda $5410,y
 sta $68e0,x
 lda $5418,y
 sta $6a20,x
 lda $5420,y
 sta $6b60,x
 lda $5428,y
 sta $6ca0,x
 lda $5430,y
 sta $6de0,x
 lda $5438,y
 sta $6f20,x
 lda $5440,y
 sta $7060,x
 lda $5448,y
 sta $71a0,x
 lda $5450,y
 sta $72e0,x
 lda $5458,y
 sta $7420,x
 lda $5460,y
 sta $7560,x
 lda $5468,y
 sta $76a0,x
 lda $5470,y
 sta $77e0,x
 lda $5478,y
 sta $7920,x
 lda $5480,y
 sta $7a60,x
 lda $5488,y
 sta $7ba0,x
 inx
 iny
 cpy #8
 bne shared_compose_a
 rts
shared_compose_b:
 lda $5400,y
 sta $e660,x
 lda $5408,y
 sta $e7a0,x
 lda $5410,y
 sta $e8e0,x
 lda $5418,y
 sta $ea20,x
 lda $5420,y
 sta $eb60,x
 lda $5428,y
 sta $eca0,x
 lda $5430,y
 sta $ede0,x
 lda $5438,y
 sta $ef20,x
 lda $5440,y
 sta $f060,x
 lda $5448,y
 sta $f1a0,x
 lda $5450,y
 sta $f2e0,x
 lda $5458,y
 sta $f420,x
 lda $5460,y
 sta $f560,x
 lda $5468,y
 sta $f6a0,x
 lda $5470,y
 sta $f7e0,x
 lda $5478,y
 sta $f920,x
 lda $5480,y
 sta $fa60,x
 lda $5488,y
 sta $fba0,x
 inx
 iny
 cpy #8
 bne shared_compose_b
 rts

; Scalar control for refined topology; shared projection remains identical.
render_fine_path:
 lda saved_path
 sta path_read
 lda saved_path+1
 sta path_read+1
 ldy #0
 lda (path_read),y
 beq fine_empty
 tax
 lda event_flags,x
 and #33
 cmp #1
 bne fine_multilevel
single_fine_dispatch:
 jmp render_single_fine
fine_multilevel:
 lda #0
 sta event_index
 txa
 jmp fine_have_event
fine_event:
 lda saved_path
 sta path_read
 lda saved_path+1
 sta path_read+1
 ldy event_index
 lda (path_read),y
 bne fine_have_event
fine_empty:
 rts
fine_have_event:
 tax
 stx current_event
 lda event_flags,x
 sta current_flags
 and #16
 beq fine_xshade
 lda #$aa
 bne fine_shade
fine_xshade:
 lda #$ff
fine_shade:
 ldy fine_lane
 and pixel_mask,y
 sta wall_shade
 lda event_ceiling,x
 jsr get_fine_sample
 sta clip_t
 ldx current_event
 lda event_floor,x
 jsr get_fine_sample
 sta fill_start
 lda clip_b
 sta fill_end
 lda fill_start
 sta clip_b
 lda current_flags
 and #32
 beq fine_brown
 lda #$aa
 bne fine_floor_color
fine_brown:
 lda fill_start
 cmp #72
 bcs fine_floor_done
 lda #$55
fine_floor_color:
 ldy fine_lane
 and pixel_mask,y
 jsr scalar_fill
fine_floor_done:
 lda current_flags
 and #1
 beq fine_riser_test
 lda clip_t
 sta fill_start
 lda clip_b
 sta fill_end
 lda wall_shade
 jsr scalar_fill
 rts
fine_riser_test:
 lda current_flags
 and #2
 beq fine_header_test
 ldx current_event
 lda event_riser,x
 jsr get_fine_sample
 sta fill_start
 lda clip_b
 sta fill_end
 lda fill_start
 sta clip_b
 lda wall_shade
 jsr scalar_fill
fine_header_test:
 lda current_flags
 and #4
 beq fine_continue_test
 ldx current_event
 lda event_header,x
 jsr get_fine_sample
 sta fill_end
 lda clip_t
 sta fill_start
 lda fill_end
 sta clip_t
 lda wall_shade
 jsr scalar_fill
fine_continue_test:
 lda clip_t
 cmp clip_b
 bcs fine_closed
 inc event_index
 jmp fine_event
fine_closed:
 rts

get_fine_sample:
 jsr get_profile
 lda pixel_base
 clc
 adc fine_lane
 tay
 lda (p_out),y
 cmp clip_t
 bcs fine_clamp_bottom
 lda clip_t
fine_clamp_bottom:
 cmp clip_b
 bcc fine_sample_ready
 lda clip_b
fine_sample_ready:
 rts

dda_quadrant:
 .byte $ff
dda_x_lo_table:
 .byte <dda_x_plus,<dda_x_minus,<dda_x_plus,<dda_x_minus
dda_x_hi_table:
 .byte >dda_x_plus,>dda_x_minus,>dda_x_plus,>dda_x_minus
dda_y_lo_table:
 .byte <dda_y_plus,<dda_y_plus,<dda_y_minus,<dda_y_minus
dda_y_hi_table:
 .byte >dda_y_plus,>dda_y_plus,>dda_y_minus,>dda_y_minus
dda_x_base_table:
 .byte $44,$48,$44,$48
dda_y_base_table:
 .byte $4c,$4c,$50,$50
ray_prepare:
 lda pose_x
 sta rs_x_lo_sum_lo+1
 sta rs_x_lo_sum_hi+1
 sta rs_x_hi_sum_lo+1
 sta rs_x_hi_sum_hi+1
 eor #$ff
 sta rs_x_lo_diff_lo+1
 sta rs_x_lo_diff_hi+1
 sta rs_x_hi_diff_lo+1
 sta rs_x_hi_diff_hi+1
 lda pose_y
 sta rs_y_lo_sum_lo+1
 sta rs_y_lo_sum_hi+1
 sta rs_y_hi_sum_lo+1
 sta rs_y_hi_sum_hi+1
 eor #$ff
 sta rs_y_lo_diff_lo+1
 sta rs_y_lo_diff_hi+1
 sta rs_y_hi_diff_lo+1
 sta rs_y_hi_diff_hi+1
 rts
ray_product_x:
 ldy r_dx
 sec
rs_x_lo_sum_lo:
 lda qs_sum_lo,y
rs_x_lo_diff_lo:
 sbc qs_diff_lo,y
rs_x_lo_sum_hi:
 lda qs_sum_hi,y
rs_x_lo_diff_hi:
 sbc qs_diff_hi,y
 sta r_sx
 ldy r_dx+1
 sec
rs_x_hi_sum_lo:
 lda qs_sum_lo,y
rs_x_hi_diff_lo:
 sbc qs_diff_lo,y
 sta qlo
rs_x_hi_sum_hi:
 lda qs_sum_hi,y
rs_x_hi_diff_hi:
 sbc qs_diff_hi,y
 sta qhi
 clc
 lda qlo
 adc r_sx
 sta r_sx
 lda qhi
 adc #0
 sta r_sx+1
 rts
ray_product_y:
 ldy r_dy
 sec
rs_y_lo_sum_lo:
 lda qs_sum_lo,y
rs_y_lo_diff_lo:
 sbc qs_diff_lo,y
rs_y_lo_sum_hi:
 lda qs_sum_hi,y
rs_y_lo_diff_hi:
 sbc qs_diff_hi,y
 sta r_sy
 ldy r_dy+1
 sec
rs_y_hi_sum_lo:
 lda qs_sum_lo,y
rs_y_hi_diff_lo:
 sbc qs_diff_lo,y
 sta qlo
rs_y_hi_sum_hi:
 lda qs_sum_hi,y
rs_y_hi_diff_hi:
 sbc qs_diff_hi,y
 sta qhi
 clc
 lda qlo
 adc r_sy
 sta r_sy
 lda qhi
 adc #0
 sta r_sy+1
 rts
; First event is opaque and has a flat floor: no earlier opening/height change.
; X=event ID. Same projected samples as generic renderer; no simplification.
; Foreground-only. Scratch single_floor_needed is disjoint from IRQ state.
single_floor_needed=$3299
render_single_flat:
 stx current_event
 lda event_flags,x
 and #16
 beq single_xshade
 lda #$aa
 bne single_shade
single_xshade:
 lda #$ff
single_shade:
 sta wall_shade
 lda event_ceiling,x
 jsr get_profile
 ldy pixel_base
 ldx #0
single_top:
 lda (p_out),y
 sta top_samples,x
 iny
 inx
 cpx #4
 bne single_top
 ldx current_event
 lda event_floor,x
 jsr get_profile
 lda #0
 sta single_floor_needed
 ldy pixel_base
 ldx #0
single_bottom:
 lda (p_out),y
 cmp top_samples,x
 bcs single_bottom_clamped
 lda top_samples,x
single_bottom_clamped:
 sta bottom_samples,x
 cmp #72
 bcs single_background_ready
 inc single_floor_needed
single_background_ready:
 iny
 inx
 cpx #4
 bne single_bottom
 lda single_floor_needed
 beq single_wall
 ; Rare above-horizon floor: exact generic brown fill, not an assumption
 ; about camera height or plane orientation. Preserve wall sample bounds.
 ldx #3
single_save_bounds:
 lda top_samples,x
 sta clip_t,x
 lda bottom_samples,x
 sta clip_b,x
 sta top_samples,x
 lda #144
 sta bottom_samples,x
 dex
 bpl single_save_bounds
 lda #$55
 sta band_shade
 jsr draw_samples
 ldx #3
single_restore_bounds:
 lda clip_t,x
 sta top_samples,x
 lda clip_b,x
 sta bottom_samples,x
 dex
 bpl single_restore_bounds
single_wall:
 lda wall_shade
 sta band_shade
 jmp draw_samples

render_single_fine:
 stx current_event
 lda event_flags,x
 and #16
 beq single_fine_xshade
 lda #$aa
 bne single_fine_shade
single_fine_xshade:
 lda #$ff
single_fine_shade:
 ldy fine_lane
 and pixel_mask,y
 sta wall_shade
 lda event_ceiling,x
 jsr get_fine_sample
 sta clip_t
 ldx current_event
 lda event_floor,x
 jsr get_fine_sample
 sta clip_b
 cmp #72
 bcs single_fine_wall
 sta fill_start
 lda #144
 sta fill_end
 lda #$55
 ldy fine_lane
 and pixel_mask,y
 jsr scalar_fill
single_fine_wall:
 lda clip_t
 sta fill_start
 lda clip_b
 sta fill_end
 lda wall_shade
 jmp scalar_fill
; Lazy shared plane profiles, signed24.8 endpoints; exact32bit reciprocal.
; Scratch is disjoint from IRQ and persistent input/automatic state.
p_num=$30
p_den=$34
p_rem=$36
p_unit=$38
p_ratio=$3c
p_value=$40
p_multiplier=$44
p_product=$46
p_left=$4c
p_right=$50
p_delta=$54
p_out=$80
p_qlo=$82
p_qhi=$83
p_acc=$84
p_gl=$88
p_gr=$8a
p_sign=$8c
p_dsign=$8d
p_zsign=$8e
p_pass=$8f
p_key=$90
p_angle=$91
p_dz=$93

get_samples:
 jsr get_profile
 ldy pixel_base
 ldx #0
cache_copy:
 lda (p_out),y
 sta samples,x
 iny
 inx
 cpx #4
 bne cache_copy
 rts
get_profile:
 sta p_key
 tax
 lda cache_map,x
 cmp #$ff
 beq cache_miss
 bmi cache_complete
 tax
 stx lazy_slot
 lda cache_lo,x
 sta p_out
 lda cache_hi,x
 sta p_out+1
 jmp lazy_samples
cache_complete:
 and #31
 tax
 lda cache_lo,x
 sta p_out
 lda cache_hi,x
 sta p_out+1
 rts
cache_miss:
 inc cache_misses
 bne cache_miss_counted
 inc cache_misses+1
cache_miss_counted:
 ldx cache_next
 stx lazy_slot
 ldy slot_keys,x
 cpy #$ff
 beq cache_empty
 lda #$ff
 sta cache_map,y
cache_empty:
 ldy p_key
 txa
 sta cache_map,y
 tya
 sta slot_keys,x
 lda cache_lo,x
 sta p_out
 lda cache_hi,x
 sta p_out+1
 inc cache_next
 lda cache_next
 cmp #32
 bne cache_slot_ready
 lda #0
 sta cache_next
cache_slot_ready:
 lda #1
 sta lazy_mode
 jsr project_profile
 lda #0
 sta lazy_mode
cache_read:
 ldx p_key
 lda cache_map,x
 bmi cache_complete
 jmp lazy_samples

project_profile:
 ldx p_key
 lda key_plane,x
 and #64
 bne plane_y
 sec
 lda pose_angle
 sbc #128
 sta p_angle
 lda pose_angle+1
 sbc #0
 and #1
 sta p_angle+1
 lda pose_x
 sta p_den
 lda pose_x+1
 sta p_den+1
 jmp plane_ready
plane_y:
 lda pose_angle
 sta p_angle
 lda pose_angle+1
 sta p_angle+1
 lda pose_y
 sta p_den
 lda pose_y+1
 sta p_den+1
plane_ready:
 ldx p_key
 lda key_plane,x
 and #63
 tay
 sec
 lda #0
 sbc p_den
 sta p_den
 tya
 sbc p_den+1
 sta p_den+1
 lda #0
 sta p_dsign
 sta p_zsign
 lda p_den+1
 bpl plane_positive
 lda #$80
 sta p_dsign
 sec
 lda #0
 sbc p_den
 sta p_den
 lda #0
 sbc p_den+1
 sta p_den+1
plane_positive:
 jsr fh_height_delta
height_positive:
 lda p_dz
 ora p_dz+1
 bne height_nonzero
 lda p_ramp
 bne height_nonzero
 lda #72
 jmp p_uniform
height_nonzero:
 lda p_den
 ora p_den+1
 bne plane_nonzero
 lda p_dz
 ora p_dz+1
 beq plane_horizon
 lda p_zsign
 bmi p_all_above
 jmp p_all_below
plane_horizon:
 ldx #3
 lda #0
plane_zero_ratio:
 sta p_ratio,x
 dex
 bpl plane_zero_ratio
 jmp profile_coefficients
plane_nonzero:
 ldx p_key
 lda key_plane,x
 cmp unit_plane
 beq plane_cached_unit
 sta unit_plane
 jsr p_div32x16
 ldx #3
save_unit:
 lda p_num,x
 sta unit_value,x
 dex
 bpl save_unit
plane_cached_unit:
 jsr fh_ratio
profile_coefficients:
 lda p_angle
 ldx p_angle+1
 jsr p_lookup_g
 lda p_multiplier
 sta p_gl
 lda p_multiplier+1
 sta p_gl+1
 sec
 lda #0
 sbc p_angle
 tay
 lda #0
 sbc p_angle+1
 and #1
 tax
 tya
 jsr p_lookup_g
 lda p_multiplier
 sta p_gr
 lda p_multiplier+1
 sta p_gr+1
 lda #0
 sta p_pass
p_endpoint:
 ldx #3
p_restore_ratio:
 lda p_ratio,x
 sta p_value,x
 dex
 bpl p_restore_ratio
 ldx p_pass
 lda p_gl,x
 sta p_multiplier
 lda p_gl+1,x
 sta p_multiplier+1
 and #$80
 eor p_dsign
 eor p_zsign
 sta p_sign
 lda p_multiplier+1
 bpl p_gpositive
 sec
 lda #0
 sbc p_multiplier
 sta p_multiplier
 lda #0
 sbc p_multiplier+1
 sta p_multiplier+1
p_gpositive:
 jsr p_mul32x16
p_scale:
 lda #0
 asl p_product+1
 rol p_product+2
 rol p_product+3
 rol p_product+4
 rol p_product+5
 rol a
 asl p_product+1
 rol p_product+2
 rol p_product+3
 rol p_product+4
 rol p_product+5
 rol a
 tax
 lda p_product+2
 sta p_product+1
 lda p_product+3
 sta p_product+2
 lda p_product+4
 sta p_product+3
 lda p_product+5
 sta p_product+4
 stx p_product+5
 ldx #0
p_scale_done:
 lda p_sign
 bpl p_row_positive
 sec
 lda #0
 sbc p_product+1
 sta p_product+1
 lda #0
 sbc p_product+2
 sta p_product+2
 lda #0
 sbc p_product+3
 sta p_product+3
 lda #0
 sbc p_product+4
 sta p_product+4
p_row_positive:
 clc
 lda p_product+2
 adc #72
 sta p_product+2
 lda p_product+3
 adc #0
 sta p_product+3
 lda p_product+4
 adc #0
 sta p_product+4
 jsr ramp_endpoint_correction
 lda p_pass
 beq p_left_save
 ldx #3
p_right_copy:
 lda p_product+1,x
 sta p_right,x
 dex
 bpl p_right_copy
 jmp p_make_delta
p_left_save:
 ldx #3
p_left_copy:
 lda p_product+1,x
 sta p_left,x
 dex
 bpl p_left_copy
 lda p_ramp
 bne p_endpoint_again
 lda p_gl
 cmp p_gr
 bne p_endpoint_again
 lda p_gl+1
 cmp p_gr+1
 bne p_endpoint_again
 ldx #3
p_same:
 lda p_left,x
 sta p_right,x
 dex
 bpl p_same
 jmp p_make_delta
p_endpoint_again:
 lda #2
 sta p_pass
 jmp p_endpoint
p_make_delta:
 sec
 lda p_right
 sbc p_left
 sta p_delta
 lda p_right+1
 sbc p_left+1
 sta p_delta+1
 lda p_right+2
 sbc p_left+2
 sta p_delta+2
 lda p_right+3
 sbc p_left+3
 sta p_delta+3
p_delta_shift:
 asl p_delta
 rol p_delta+1
 rol p_delta+2
 rol p_delta+3
 lda p_delta+1
 sta p_delta+0
 lda p_delta+2
 sta p_delta+1
 lda p_delta+3
 sta p_delta+2
 lda #0
 bcc delta_sign_ready
 lda #$ff
delta_sign_ready:
 sta p_delta+3
 ldx #0
p_delta_shift_done:
 lda p_left+3
 and p_right+3
 bmi p_all_above
 lda p_left+3
 bmi p_accumulate
 bne p_left_below
 lda p_left+2
 bne p_left_below
 lda p_left+1
 cmp #144
 bcc p_accumulate
p_left_below:
 lda p_right+3
 bmi p_accumulate
 bne p_all_below
 lda p_right+2
 bne p_all_below
 lda p_right+1
 cmp #144
 bcc p_accumulate
p_all_below:
 lda #144
 bne p_uniform
p_all_above:
 lda #0
p_uniform:
 ldx lazy_mode
 beq p_uniform_full
 pha
 ldx lazy_slot
 lda #0
 sta lazy_group,x
 lda #31
 sta lazy_last,x
 lda lazy_slot
 ora #$80
 ldx p_key
 sta cache_map,x
 pla
p_uniform_full:
 ldy #127
p_uniform_loop:
 sta (p_out),y
 dey
 bpl p_uniform_loop
 rts
p_accumulate:
 ldx #3
p_delta_copy:
 lda p_delta,x
 sta p_acc,x
 dex
 bpl p_delta_copy
 lda p_acc+3
 cmp #$80
 ror p_acc+3
 ror p_acc+2
 ror p_acc+1
 ror p_acc
 clc
 lda p_acc
 adc #128
 sta p_acc
 lda p_acc+1
 adc #0
 sta p_acc+1
 lda p_acc+2
 adc #0
 sta p_acc+2
 lda p_acc+3
 adc #0
 sta p_acc+3
 clc
 lda p_acc
 adc p_left
 sta p_acc
 lda p_acc+1
 adc p_left+1
 sta p_acc+1
 lda p_acc+2
 adc p_left+2
 sta p_acc+2
 lda p_acc+3
 adc p_left+3
 sta p_acc+3
 lda p_delta
 ora p_delta+1
 ora p_delta+2
 ora p_delta+3
 bne p_varying
 lda p_acc+3
 bmi p_all_above
 bne p_all_below
 lda p_acc+2
 bne p_all_below
 lda p_acc+1
 cmp #144
 bcs p_all_below
 jmp p_uniform
p_varying:
 lda lazy_mode
 beq p_varying_full
 jmp lazy_store_parameters
p_varying_full:
 ldy #0
p_column:
 lda p_acc+3
 bmi p_above
 bne p_below
 lda p_acc+2
 bne p_below
 lda p_acc+1
 cmp #144
 bcc p_store
p_below:
 lda #144
 bne p_store
p_above:
 lda #0
p_store:
 sta (p_out),y
 clc
 lda p_acc
 adc p_delta
 sta p_acc
 lda p_acc+1
 adc p_delta+1
 sta p_acc+1
 lda p_acc+2
 adc p_delta+2
 sta p_acc+2
 lda p_acc+3
 adc p_delta+3
 sta p_acc+3
 iny
 cpy #128
 bne p_column
 rts

p_lookup_g:
 tay
 lda gl_lo,y
 sta p_multiplier
 lda gl_hi,y
 sta p_multiplier+1
 cpx #0
 beq p_gready
 sec
 lda #0
 sbc p_multiplier
 sta p_multiplier
 lda #0
 sbc p_multiplier+1
 sta p_multiplier+1
p_gready:
 rts
; Two continuous Y planes: floorQ8.8=8*(worldY_Q8.8-origin*256).
; Validated scene has continuous traversable joins, no artificial stair test.
cam_z_frac=$2e
pose_z_frac=$2f
p_ramp=$3294
p_extend=$96
ramp_origin_scratch=$329a
ramp_origins:
 .byte 14,11

stairs_update_z:
 jsr camera_cell
 jsr read_cell
 lda r_newfloor
 cmp #254
 bcs camera_on_ramp
 clc
 adc #32
 sta cam_z
 lda #0
 sta cam_z_frac
 rts
camera_on_ramp:
 and #1
 tax
 lda ramp_origins,x
 sta ramp_origin_scratch
 sec
 lda cam_y
 sbc #0
 sta cam_z_frac
 lda cam_y+1
 sbc ramp_origin_scratch
 sta cam_z
 asl cam_z_frac
 rol cam_z
 asl cam_z_frac
 rol cam_z
 asl cam_z_frac
 rol cam_z
 clc
 lda cam_z
 adc #32
 sta cam_z
 rts

; Return abs(eyeQ8.8-floorPlane(cameraXY)), plus sign. Signed24 temporary.
ramp_height_delta:
 lda #0
 sta p_ramp
 sta p_dz+2
 ldx p_key
 lda key_alt,x
 cmp #254
 bcs ramp_plane_height
 sta p_dz+1
 lda #0
 sta p_dz
 jmp ramp_eye_difference
ramp_plane_height:
 inc p_ramp
 and #1
 tax
 lda ramp_origins,x
 sta ramp_origin_scratch
 sec
 lda pose_y
 sbc #0
 sta p_dz
 lda pose_y+1
 sbc ramp_origin_scratch
 sta p_dz+1
 bpl ramp_height_nonnegative
 lda #$ff
 sta p_dz+2
ramp_height_nonnegative:
 ldx #3
ramp_height_scale:
 asl p_dz
 rol p_dz+1
 rol p_dz+2
 dex
 bne ramp_height_scale
ramp_eye_difference:
 sec
 lda pose_z_frac
 sbc p_dz
 sta p_dz
 lda pose_z
 sbc p_dz+1
 sta p_dz+1
 lda #0
 sbc p_dz+2
 sta p_dz+2
 bpl ramp_abs_ready
 lda #$80
 sta p_zsign
 sec
 lda #0
 sbc p_dz
 sta p_dz
 lda #0
 sbc p_dz+1
 sta p_dz+1
 lda #0
 sbc p_dz+2
 sta p_dz+2
ramp_abs_ready:
 ; Validated coordinate/height domain guarantees magnitude<65536.
 rts

; Signed slope contribution -F*(1/4)*directionY, prepared host-side Q8.
; Endpoints remain signed/unclipped until sampling, just like flat profiles.
ramp_endpoint_correction:
 lda p_ramp
 beq ramp_correction_done
 lda p_pass
 beq ramp_left_slope
 sec
 lda #0
 sbc pose_angle
 tay
 lda #0
 sbc pose_angle+1
 and #1
 tax
 tya
 jmp ramp_slope_lookup
ramp_left_slope:
 lda pose_angle
 ldx pose_angle+1
ramp_slope_lookup:
 tay
 lda ramp_slope_lo,y
 sta p_multiplier
 lda ramp_slope_hi,y
 sta p_multiplier+1
 cpx #0
 beq ramp_slope_ready
 sec
 lda #0
 sbc p_multiplier
 sta p_multiplier
 lda #0
 sbc p_multiplier+1
 sta p_multiplier+1
ramp_slope_ready:
 lda #0
 sta p_extend
 lda p_multiplier+1
 bpl ramp_subtract_slope
 lda #$ff
 sta p_extend
ramp_subtract_slope:
 sec
 lda p_product+1
 sbc p_multiplier
 sta p_product+1
 lda p_product+2
 sbc p_multiplier+1
 sta p_product+2
 lda p_product+3
 sbc p_extend
 sta p_product+3
 lda p_product+4
 sbc p_extend
 sta p_product+4
ramp_correction_done:
 rts
; Coefficients/accumulators are foreground only, IRQ disjoint.
lazy_slot=$3295
lazy_mode=$3296
lazy_count=$3297
lazy_end=$3298
lazy_start=$9a00
lazy_delta=$9a80
lazy_step=$9b00
lazy_group=$9b80
lazy_last=$9ba0
lazy_store_parameters:
 ldx lazy_slot
 lda p_acc+0
 sta lazy_start+0,x
 lda p_delta+0
 sta lazy_delta+0,x
 sta p_acc+0
 lda p_acc+1
 sta lazy_start+32,x
 lda p_delta+1
 sta lazy_delta+32,x
 sta p_acc+1
 lda p_acc+2
 sta lazy_start+64,x
 lda p_delta+2
 sta lazy_delta+64,x
 sta p_acc+2
 lda p_acc+3
 sta lazy_start+96,x
 lda p_delta+3
 sta lazy_delta+96,x
 sta p_acc+3
 asl p_acc
 rol p_acc+1
 rol p_acc+2
 rol p_acc+3
 asl p_acc
 rol p_acc+1
 rol p_acc+2
 rol p_acc+3
 lda p_acc+0
 sta lazy_step+0,x
 lda p_acc+1
 sta lazy_step+32,x
 lda p_acc+2
 sta lazy_step+64,x
 lda p_acc+3
 sta lazy_step+96,x
 lda #$ff
 sta lazy_group,x
 rts

lazy_samples:
 ldx lazy_slot
 lda lazy_group,x
 cmp #$ff
 beq lazy_need_group
 lda lazy_last,x
 cmp group
 bcc lazy_need_group
 rts
lazy_need_group:
 lda lazy_group,x
 cmp #$ff
 bne lazy_not_first
 lda #0
lazy_not_first:
 sta lazy_count
 lda group
 sec
 sbc lazy_count
 sta lazy_count
 lda group
 clc
 adc #4
 sta lazy_group,x
 lda lazy_start+0,x
 sta p_acc+0
 lda lazy_delta+0,x
 sta p_delta+0
 lda lazy_start+32,x
 sta p_acc+1
 lda lazy_delta+32,x
 sta p_delta+1
 lda lazy_start+64,x
 sta p_acc+2
 lda lazy_delta+64,x
 sta p_delta+2
 lda lazy_start+96,x
 sta p_acc+3
 lda lazy_delta+96,x
 sta p_delta+3
 lda lazy_count
 beq lazy_positioned
 cmp #4
 bcc lazy_skip_group
 lda lazy_step+0,x
 sta p_left+0
 lda lazy_step+32,x
 sta p_left+1
 lda lazy_step+64,x
 sta p_left+2
 lda lazy_step+96,x
 sta p_left+3
lazy_binary_skip:
 lsr lazy_count
 bcc lazy_binary_no_add
 clc
 lda p_acc+0
 adc p_left+0
 sta p_acc+0
 lda p_acc+1
 adc p_left+1
 sta p_acc+1
 lda p_acc+2
 adc p_left+2
 sta p_acc+2
 lda p_acc+3
 adc p_left+3
 sta p_acc+3
lazy_binary_no_add:
 lda lazy_count
 beq lazy_positioned
 asl p_left
 rol p_left+1
 rol p_left+2
 rol p_left+3
 jmp lazy_binary_skip
lazy_skip_group:
 clc
 lda p_acc+0
 adc lazy_step+0,x
 sta p_acc+0
 lda p_acc+1
 adc lazy_step+32,x
 sta p_acc+1
 lda p_acc+2
 adc lazy_step+64,x
 sta p_acc+2
 lda p_acc+3
 adc lazy_step+96,x
 sta p_acc+3
 dec lazy_count
 bne lazy_skip_group
lazy_positioned:
 lda pixel_base
 clc
 adc #16
 cmp #128
 bcc lazy_end_ready
 lda #128
lazy_end_ready:
 sta lazy_end
 sec
 sbc #1
 lsr
 lsr
 sta lazy_last,x
block_compute_end:
 lda lazy_step+0,x
 sta p_right+0
 lda lazy_step+32,x
 sta p_right+1
 lda lazy_step+64,x
 sta p_right+2
 lda lazy_step+96,x
 sta p_right+3
 asl p_right
 rol p_right+1
 rol p_right+2
 rol p_right+3
 asl p_right
 rol p_right+1
 rol p_right+2
 rol p_right+3
 clc
 lda p_right+0
 adc p_acc+0
 sta p_right+0
 lda p_right+1
 adc p_acc+1
 sta p_right+1
 lda p_right+2
 adc p_acc+2
 sta p_right+2
 lda p_right+3
 adc p_acc+3
 sta p_right+3
 lda p_right+0
 sta lazy_start+0,x
 lda p_right+1
 sta lazy_start+32,x
 lda p_right+2
 sta lazy_start+64,x
 lda p_right+3
 sta lazy_start+96,x
 bvs block_fallback
 lda p_acc+3
 bmi block_above_test
 ora p_acc+2
 bne block_below_test
 lda p_acc+1
 cmp #144
 bcs block_below_test
 lda p_right+3
 ora p_right+2
 bne block_fallback
 lda p_right+1
 cmp #144
 bcs block_fallback
 jmp block_visible
block_above_test:
 lda p_right+3
 bpl block_fallback
 lda #0
 beq block_constant
block_below_test:
 lda p_right+3
 bmi block_fallback
 ora p_right+2
 bne block_below
 lda p_right+1
 cmp #144
 bcc block_fallback
block_below:
 lda #144
block_constant:
 ldy pixel_base
block_constant_loop:
 sta (p_out),y
 iny
 sta (p_out),y
 iny
 sta (p_out),y
 iny
 sta (p_out),y
 iny
 cpy lazy_end
 bne block_constant_loop
 rts
block_visible:
 ldy pixel_base
block_visible_loop:
 lda p_acc+1
 sta (p_out),y
 clc
 lda p_acc
 adc p_delta
 sta p_acc
 lda p_acc+1
 adc p_delta+1
 sta p_acc+1
 iny
 lda p_acc+1
 sta (p_out),y
 clc
 lda p_acc
 adc p_delta
 sta p_acc
 lda p_acc+1
 adc p_delta+1
 sta p_acc+1
 iny
 lda p_acc+1
 sta (p_out),y
 clc
 lda p_acc
 adc p_delta
 sta p_acc
 lda p_acc+1
 adc p_delta+1
 sta p_acc+1
 iny
 lda p_acc+1
 sta (p_out),y
 clc
 lda p_acc
 adc p_delta
 sta p_acc
 lda p_acc+1
 adc p_delta+1
 sta p_acc+1
 iny
 cpy lazy_end
 bne block_visible_loop
 rts
block_fallback:
 ldy pixel_base
lazy_column:
 lda p_acc+3
 bmi lazy_above
 bne lazy_below
 lda p_acc+2
 bne lazy_below
 lda p_acc+1
 cmp #144
 bcc lazy_store
lazy_below:
 lda #144
 bne lazy_store
lazy_above:
 lda #0
lazy_store:
 sta (p_out),y
 clc
 lda p_acc+0
 adc p_delta+0
 sta p_acc+0
 lda p_acc+1
 adc p_delta+1
 sta p_acc+1
 lda p_acc+2
 adc p_delta+2
 sta p_acc+2
 lda p_acc+3
 adc p_delta+3
 sta p_acc+3
 iny
 cpy lazy_end
 bne lazy_column
 rts
p_mul32x16:
 lda #0
 sta p_product+0
 sta p_product+1
 sta p_product+2
 sta p_product+3
 sta p_product+4
 sta p_product+5
 lda p_value+0
 beq mul_row_0_done
 ldy p_multiplier+0
 beq mul_0_0_done
 lda p_value+0
 jsr p_mul8
 clc
 lda p_product+0
 adc p_qlo
 sta p_product+0
 lda p_product+1
 adc p_qhi
 sta p_product+1
 bcc mul_0_0_done
 inc p_product+2
 bne mul_0_0_done
 inc p_product+3
 bne mul_0_0_done
 inc p_product+4
 bne mul_0_0_done
 inc p_product+5
mul_0_0_done:
 ldy p_multiplier+1
 beq mul_0_1_done
 lda p_value+0
 jsr p_mul8
 clc
 lda p_product+1
 adc p_qlo
 sta p_product+1
 lda p_product+2
 adc p_qhi
 sta p_product+2
 bcc mul_0_1_done
 inc p_product+3
 bne mul_0_1_done
 inc p_product+4
 bne mul_0_1_done
 inc p_product+5
mul_0_1_done:
mul_row_0_done:
 lda p_value+1
 beq mul_row_1_done
 ldy p_multiplier+0
 beq mul_1_0_done
 lda p_value+1
 jsr p_mul8
 clc
 lda p_product+1
 adc p_qlo
 sta p_product+1
 lda p_product+2
 adc p_qhi
 sta p_product+2
 bcc mul_1_0_done
 inc p_product+3
 bne mul_1_0_done
 inc p_product+4
 bne mul_1_0_done
 inc p_product+5
mul_1_0_done:
 ldy p_multiplier+1
 beq mul_1_1_done
 lda p_value+1
 jsr p_mul8
 clc
 lda p_product+2
 adc p_qlo
 sta p_product+2
 lda p_product+3
 adc p_qhi
 sta p_product+3
 bcc mul_1_1_done
 inc p_product+4
 bne mul_1_1_done
 inc p_product+5
mul_1_1_done:
mul_row_1_done:
 lda p_value+2
 beq mul_row_2_done
 ldy p_multiplier+0
 beq mul_2_0_done
 lda p_value+2
 jsr p_mul8
 clc
 lda p_product+2
 adc p_qlo
 sta p_product+2
 lda p_product+3
 adc p_qhi
 sta p_product+3
 bcc mul_2_0_done
 inc p_product+4
 bne mul_2_0_done
 inc p_product+5
mul_2_0_done:
 ldy p_multiplier+1
 beq mul_2_1_done
 lda p_value+2
 jsr p_mul8
 clc
 lda p_product+3
 adc p_qlo
 sta p_product+3
 lda p_product+4
 adc p_qhi
 sta p_product+4
 bcc mul_2_1_done
 inc p_product+5
mul_2_1_done:
mul_row_2_done:
 lda p_value+3
 beq mul_row_3_done
 ldy p_multiplier+0
 beq mul_3_0_done
 lda p_value+3
 jsr p_mul8
 clc
 lda p_product+3
 adc p_qlo
 sta p_product+3
 lda p_product+4
 adc p_qhi
 sta p_product+4
 bcc mul_3_0_done
 inc p_product+5
mul_3_0_done:
 ldy p_multiplier+1
 beq mul_3_1_done
 lda p_value+3
 jsr p_mul8
 clc
 lda p_product+4
 adc p_qlo
 sta p_product+4
 lda p_product+5
 adc p_qhi
 sta p_product+5
mul_3_1_done:
mul_row_3_done:
 rts
p_div32x16:
 lda #0
 sta p_rem
 sta p_rem+1
 lda #0
 sta p_num+0
 lda #159
 sta p_num+1
 lda #237
 sta p_num+2
 lda #6
 sta p_num+3
 ldx #32
p_div_bit:
 asl p_num
 rol p_num+1
 rol p_num+2
 rol p_num+3
 rol p_rem
 rol p_rem+1
 bcs p_div_sub
 lda p_rem+1
 cmp p_den+1
 bcc p_div_next
 bne p_div_sub
 lda p_rem
 cmp p_den
 bcc p_div_next
p_div_sub:
 sec
 lda p_rem
 sbc p_den
 sta p_rem
 lda p_rem+1
 sbc p_den+1
 sta p_rem+1
 inc p_num
p_div_next:
 dex
 bne p_div_bit
 rts
p_mul8:
 sta p_qsumlo+1
 sta p_qsumhi+1
 eor #$ff
 sta p_qdifflo+1
 sta p_qdiffhi+1
 sec
p_qsumlo:
 lda qs_sum_lo,y
p_qdifflo:
 sbc qs_diff_lo,y
 sta p_qlo
p_qsumhi:
 lda qs_sum_hi,y
p_qdiffhi:
 sbc qs_diff_hi,y
 sta p_qhi
 rts
band_tl=$98
band_tr=$99
band_bl=$9a
band_br=$9b
band_top_end=$9c
band_bottom_start=$9d
band_row=$9e
band_last=$9f
band_shade=$a0
band_tmp=$a1
top_samples=$a2
bottom_samples=$a6
band_count=$aa
fill_ptr=$ab
mask_tl=$ad
mask_tr=$af
mask_bl=$b1
mask_br=$b3
draw_samples:
 lda top_samples
 cmp top_samples+1
 bcc b_min_top_1
 lda top_samples+1
b_min_top_1:
 cmp top_samples+2
 bcc b_min_top_2
 lda top_samples+2
b_min_top_2:
 cmp top_samples+3
 bcc b_min_top_3
 lda top_samples+3
b_min_top_3:
 lsr
 lsr
 lsr
 sta band_row
 lda top_samples
 cmp top_samples+1
 bcs b_max_top_1
 lda top_samples+1
b_max_top_1:
 cmp top_samples+2
 bcs b_max_top_2
 lda top_samples+2
b_max_top_2:
 cmp top_samples+3
 bcs b_max_top_3
 lda top_samples+3
b_max_top_3:
 clc
 adc #7
 lsr
 lsr
 lsr
 sta band_top_end
 lda bottom_samples
 cmp bottom_samples+1
 bcc b_min_bottom_1
 lda bottom_samples+1
b_min_bottom_1:
 cmp bottom_samples+2
 bcc b_min_bottom_2
 lda bottom_samples+2
b_min_bottom_2:
 cmp bottom_samples+3
 bcc b_min_bottom_3
 lda bottom_samples+3
b_min_bottom_3:
 lsr
 lsr
 lsr
 sta band_bottom_start
 lda bottom_samples
 cmp bottom_samples+1
 bcs b_max_bottom_1
 lda bottom_samples+1
b_max_bottom_1:
 cmp bottom_samples+2
 bcs b_max_bottom_2
 lda bottom_samples+2
b_max_bottom_2:
 cmp bottom_samples+3
 bcs b_max_bottom_3
 lda bottom_samples+3
b_max_bottom_3:
 clc
 adc #7
 lsr
 lsr
 lsr
 sta band_last
band_next_row:
 lda band_row
 cmp band_last
 bcs band_done
 cmp band_top_end
 bcc band_edge
 cmp band_bottom_start
 bcs band_edge
 sec
 lda band_bottom_start
 sbc band_row
 sta band_count
 jsr fill_rows
 lda band_bottom_start
 sta band_row
 jmp band_next_row
band_edge:
 jsr band_address
 lda band_row
 asl
 asl
 asl
 sta rowtop
 lda band_row
 cmp band_top_end
 bcs edge_bottom_only
 jsr build_top_mask
 lda band_row
 cmp band_bottom_start
 bcc edge_top_pixels
 jsr build_bottom_mask
 jmp edge_both_pixels
edge_bottom_only:
 jsr build_bottom_mask
 jmp edge_bottom_pixels
edge_top_pixels:
 ldy #7
edge_top_pixel:
 lda (mask_tl),y
 ora (mask_tr),y
 beq ec_top_next
 cmp #$ff
 beq ec_top_full
 sta band_tmp
 lda (outptr),y
 eor band_shade
 and band_tmp
 eor (outptr),y
 sta (outptr),y
ec_top_next:
 dey
 bpl edge_top_pixel
 jmp band_advance
ec_top_full:
 lda band_shade
 sta (outptr),y
 dey
 bpl edge_top_pixel
 jmp band_advance
edge_bottom_pixels:
 ldy #7
edge_bottom_pixel:
 lda (mask_bl),y
 ora (mask_br),y
 eor #$ff
 beq ec_bottom_next
 cmp #$ff
 beq ec_bottom_full
 sta band_tmp
 lda (outptr),y
 eor band_shade
 and band_tmp
 eor (outptr),y
 sta (outptr),y
ec_bottom_next:
 dey
 bpl edge_bottom_pixel
 jmp band_advance
ec_bottom_full:
 lda band_shade
 sta (outptr),y
 dey
 bpl edge_bottom_pixel
 jmp band_advance
edge_both_pixels:
 ldy #7
edge_both_pixel:
 lda (mask_tl),y
 ora (mask_tr),y
 sta band_tmp
 lda (mask_bl),y
 ora (mask_br),y
 eor #$ff
 and band_tmp
 beq ec_both_next
 cmp #$ff
 beq ec_both_full
 sta band_tmp
 lda (outptr),y
 eor band_shade
 and band_tmp
 eor (outptr),y
 sta (outptr),y
ec_both_next:
 dey
 bpl edge_both_pixel
 jmp band_advance
ec_both_full:
 lda band_shade
 sta (outptr),y
 dey
 bpl edge_both_pixel
 jmp band_advance
band_advance:
 inc band_row
 jmp band_next_row
band_done:
 rts
band_address:
 ldx band_row
 lda col
 asl
 asl
 asl
 clc
 adc bitmap_row_lo,x
 sta outptr
 lda drawbuf
 beq address_direct_bank
 lda #$80
address_direct_bank:
 eor bitmap_row_hi,x
 adc #0
 sta outptr+1
 rts
build_top_mask:
 lda top_samples+0
 sec
 sbc rowtop
 bcs pair_0_0_positive
 lda #0
pair_0_0_positive:
 tay
 lda clamp8,y
 tay
 lda times9,y
 sta glyphindex
 lda top_samples+1
 sec
 sbc rowtop
 bcs pair_0_1_positive
 lda #0
pair_0_1_positive:
 tay
 lda clamp8,y
 clc
 adc glyphindex
 tay
 lda pair_left_lo,y
 sta mask_tl
 lda pair_left_hi,y
 sta mask_tl+1
 lda top_samples+2
 sec
 sbc rowtop
 bcs pair_1_0_positive
 lda #0
pair_1_0_positive:
 tay
 lda clamp8,y
 tay
 lda times9,y
 sta glyphindex
 lda top_samples+3
 sec
 sbc rowtop
 bcs pair_1_1_positive
 lda #0
pair_1_1_positive:
 tay
 lda clamp8,y
 clc
 adc glyphindex
 tay
 lda pair_right_lo,y
 sta mask_tr
 lda pair_right_hi,y
 sta mask_tr+1
 rts
build_bottom_mask:
 lda bottom_samples+0
 sec
 sbc rowtop
 bcs pair_2_0_positive
 lda #0
pair_2_0_positive:
 tay
 lda clamp8,y
 tay
 lda times9,y
 sta glyphindex
 lda bottom_samples+1
 sec
 sbc rowtop
 bcs pair_2_1_positive
 lda #0
pair_2_1_positive:
 tay
 lda clamp8,y
 clc
 adc glyphindex
 tay
 lda pair_left_lo,y
 sta mask_bl
 lda pair_left_hi,y
 sta mask_bl+1
 lda bottom_samples+2
 sec
 sbc rowtop
 bcs pair_3_0_positive
 lda #0
pair_3_0_positive:
 tay
 lda clamp8,y
 tay
 lda times9,y
 sta glyphindex
 lda bottom_samples+3
 sec
 sbc rowtop
 bcs pair_3_1_positive
 lda #0
pair_3_1_positive:
 tay
 lda clamp8,y
 clc
 adc glyphindex
 tay
 lda pair_right_lo,y
 sta mask_br
 lda pair_right_hi,y
 sta mask_br+1
 rts
fill_rows:
 lda drawbuf
 beq fill_bank_a
 lda #44
fill_bank_a:
 clc
 adc band_row
 tay
 lda fill_entry_lo,y
 sta fill_ptr
 lda fill_entry_hi,y
 sta fill_ptr+1
 lda col
 asl
 asl
 asl
 tax
 lda band_shade
 jmp (fill_ptr)
fill_a_0_0:
 sta $6660,x
 sta $6661,x
 sta $6662,x
 sta $6663,x
 sta $6664,x
 sta $6665,x
 sta $6666,x
 sta $6667,x
 dec band_count
 beq fill_done
fill_a_0_1:
 sta $67a0,x
 sta $67a1,x
 sta $67a2,x
 sta $67a3,x
 sta $67a4,x
 sta $67a5,x
 sta $67a6,x
 sta $67a7,x
 dec band_count
 beq fill_done
fill_a_0_2:
 sta $68e0,x
 sta $68e1,x
 sta $68e2,x
 sta $68e3,x
 sta $68e4,x
 sta $68e5,x
 sta $68e6,x
 sta $68e7,x
 dec band_count
 beq fill_done
fill_a_0_3:
 sta $6a20,x
 sta $6a21,x
 sta $6a22,x
 sta $6a23,x
 sta $6a24,x
 sta $6a25,x
 sta $6a26,x
 sta $6a27,x
 dec band_count
 beq fill_done
fill_a_0_4:
 sta $6b60,x
 sta $6b61,x
 sta $6b62,x
 sta $6b63,x
 sta $6b64,x
 sta $6b65,x
 sta $6b66,x
 sta $6b67,x
 dec band_count
 beq fill_done
fill_a_0_5:
 sta $6ca0,x
 sta $6ca1,x
 sta $6ca2,x
 sta $6ca3,x
 sta $6ca4,x
 sta $6ca5,x
 sta $6ca6,x
 sta $6ca7,x
 dec band_count
 beq fill_done
fill_a_0_6:
 sta $6de0,x
 sta $6de1,x
 sta $6de2,x
 sta $6de3,x
 sta $6de4,x
 sta $6de5,x
 sta $6de6,x
 sta $6de7,x
 dec band_count
 beq fill_done
fill_a_0_7:
 sta $6f20,x
 sta $6f21,x
 sta $6f22,x
 sta $6f23,x
 sta $6f24,x
 sta $6f25,x
 sta $6f26,x
 sta $6f27,x
 dec band_count
 beq fill_done
fill_a_0_8:
 sta $7060,x
 sta $7061,x
 sta $7062,x
 sta $7063,x
 sta $7064,x
 sta $7065,x
 sta $7066,x
 sta $7067,x
 dec band_count
 beq fill_done
fill_a_0_9:
 sta $71a0,x
 sta $71a1,x
 sta $71a2,x
 sta $71a3,x
 sta $71a4,x
 sta $71a5,x
 sta $71a6,x
 sta $71a7,x
 dec band_count
 beq fill_done
fill_a_0_10:
 sta $72e0,x
 sta $72e1,x
 sta $72e2,x
 sta $72e3,x
 sta $72e4,x
 sta $72e5,x
 sta $72e6,x
 sta $72e7,x
 dec band_count
 beq fill_done
fill_a_0_11:
 sta $7420,x
 sta $7421,x
 sta $7422,x
 sta $7423,x
 sta $7424,x
 sta $7425,x
 sta $7426,x
 sta $7427,x
 dec band_count
 beq fill_done
fill_a_0_12:
 sta $7560,x
 sta $7561,x
 sta $7562,x
 sta $7563,x
 sta $7564,x
 sta $7565,x
 sta $7566,x
 sta $7567,x
 dec band_count
 beq fill_done
fill_a_0_13:
 sta $76a0,x
 sta $76a1,x
 sta $76a2,x
 sta $76a3,x
 sta $76a4,x
 sta $76a5,x
 sta $76a6,x
 sta $76a7,x
 dec band_count
 beq fill_done
fill_a_0_14:
 sta $77e0,x
 sta $77e1,x
 sta $77e2,x
 sta $77e3,x
 sta $77e4,x
 sta $77e5,x
 sta $77e6,x
 sta $77e7,x
 dec band_count
 beq fill_done
fill_a_0_15:
 sta $7920,x
 sta $7921,x
 sta $7922,x
 sta $7923,x
 sta $7924,x
 sta $7925,x
 sta $7926,x
 sta $7927,x
 dec band_count
 beq fill_done
fill_a_0_16:
 sta $7a60,x
 sta $7a61,x
 sta $7a62,x
 sta $7a63,x
 sta $7a64,x
 sta $7a65,x
 sta $7a66,x
 sta $7a67,x
 dec band_count
 beq fill_done
fill_a_0_17:
 sta $7ba0,x
 sta $7ba1,x
 sta $7ba2,x
 sta $7ba3,x
 sta $7ba4,x
 sta $7ba5,x
 sta $7ba6,x
 sta $7ba7,x
 dec band_count
 beq fill_done
fill_a_0_18:
 rts
fill_a_0_19:
 rts
fill_a_0_20:
 rts
fill_a_0_21:
 rts
 rts
fill_a_1_0:
 rts
fill_a_1_1:
 rts
fill_a_1_2:
 rts
fill_a_1_3:
 rts
fill_a_1_4:
 rts
fill_a_1_5:
 rts
fill_a_1_6:
 rts
fill_a_1_7:
 rts
fill_a_1_8:
 rts
fill_a_1_9:
 rts
fill_a_1_10:
 rts
fill_a_1_11:
 rts
fill_a_1_12:
 rts
fill_a_1_13:
 rts
fill_a_1_14:
 rts
fill_a_1_15:
 rts
fill_a_1_16:
 rts
fill_a_1_17:
 rts
fill_a_1_18:
 rts
fill_a_1_19:
 rts
fill_a_1_20:
 rts
fill_a_1_21:
 rts
 rts
fill_b_0_0:
 sta $e660,x
 sta $e661,x
 sta $e662,x
 sta $e663,x
 sta $e664,x
 sta $e665,x
 sta $e666,x
 sta $e667,x
 dec band_count
 beq fill_done
fill_b_0_1:
 sta $e7a0,x
 sta $e7a1,x
 sta $e7a2,x
 sta $e7a3,x
 sta $e7a4,x
 sta $e7a5,x
 sta $e7a6,x
 sta $e7a7,x
 dec band_count
 beq fill_done
fill_b_0_2:
 sta $e8e0,x
 sta $e8e1,x
 sta $e8e2,x
 sta $e8e3,x
 sta $e8e4,x
 sta $e8e5,x
 sta $e8e6,x
 sta $e8e7,x
 dec band_count
 beq fill_done
fill_b_0_3:
 sta $ea20,x
 sta $ea21,x
 sta $ea22,x
 sta $ea23,x
 sta $ea24,x
 sta $ea25,x
 sta $ea26,x
 sta $ea27,x
 dec band_count
 beq fill_done
fill_b_0_4:
 sta $eb60,x
 sta $eb61,x
 sta $eb62,x
 sta $eb63,x
 sta $eb64,x
 sta $eb65,x
 sta $eb66,x
 sta $eb67,x
 dec band_count
 beq fill_done
fill_b_0_5:
 sta $eca0,x
 sta $eca1,x
 sta $eca2,x
 sta $eca3,x
 sta $eca4,x
 sta $eca5,x
 sta $eca6,x
 sta $eca7,x
 dec band_count
 beq fill_done
fill_b_0_6:
 sta $ede0,x
 sta $ede1,x
 sta $ede2,x
 sta $ede3,x
 sta $ede4,x
 sta $ede5,x
 sta $ede6,x
 sta $ede7,x
 dec band_count
 beq fill_done
fill_b_0_7:
 sta $ef20,x
 sta $ef21,x
 sta $ef22,x
 sta $ef23,x
 sta $ef24,x
 sta $ef25,x
 sta $ef26,x
 sta $ef27,x
 dec band_count
 beq fill_done
fill_b_0_8:
 sta $f060,x
 sta $f061,x
 sta $f062,x
 sta $f063,x
 sta $f064,x
 sta $f065,x
 sta $f066,x
 sta $f067,x
 dec band_count
 beq fill_done
fill_b_0_9:
 sta $f1a0,x
 sta $f1a1,x
 sta $f1a2,x
 sta $f1a3,x
 sta $f1a4,x
 sta $f1a5,x
 sta $f1a6,x
 sta $f1a7,x
 dec band_count
 beq fill_done
fill_b_0_10:
 sta $f2e0,x
 sta $f2e1,x
 sta $f2e2,x
 sta $f2e3,x
 sta $f2e4,x
 sta $f2e5,x
 sta $f2e6,x
 sta $f2e7,x
 dec band_count
 beq fill_done
fill_b_0_11:
 sta $f420,x
 sta $f421,x
 sta $f422,x
 sta $f423,x
 sta $f424,x
 sta $f425,x
 sta $f426,x
 sta $f427,x
 dec band_count
 beq fill_done
fill_b_0_12:
 sta $f560,x
 sta $f561,x
 sta $f562,x
 sta $f563,x
 sta $f564,x
 sta $f565,x
 sta $f566,x
 sta $f567,x
 dec band_count
 beq fill_done
fill_b_0_13:
 sta $f6a0,x
 sta $f6a1,x
 sta $f6a2,x
 sta $f6a3,x
 sta $f6a4,x
 sta $f6a5,x
 sta $f6a6,x
 sta $f6a7,x
 dec band_count
 beq fill_done
fill_b_0_14:
 sta $f7e0,x
 sta $f7e1,x
 sta $f7e2,x
 sta $f7e3,x
 sta $f7e4,x
 sta $f7e5,x
 sta $f7e6,x
 sta $f7e7,x
 dec band_count
 beq fill_done
fill_b_0_15:
 sta $f920,x
 sta $f921,x
 sta $f922,x
 sta $f923,x
 sta $f924,x
 sta $f925,x
 sta $f926,x
 sta $f927,x
 dec band_count
 beq fill_done
fill_b_0_16:
 sta $fa60,x
 sta $fa61,x
 sta $fa62,x
 sta $fa63,x
 sta $fa64,x
 sta $fa65,x
 sta $fa66,x
 sta $fa67,x
 dec band_count
 beq fill_done
fill_b_0_17:
 sta $fba0,x
 sta $fba1,x
 sta $fba2,x
 sta $fba3,x
 sta $fba4,x
 sta $fba5,x
 sta $fba6,x
 sta $fba7,x
 dec band_count
 beq fill_done
fill_b_0_18:
 rts
fill_b_0_19:
 rts
fill_b_0_20:
 rts
fill_b_0_21:
 rts
 rts
fill_b_1_0:
 rts
fill_b_1_1:
 rts
fill_b_1_2:
 rts
fill_b_1_3:
 rts
fill_b_1_4:
 rts
fill_b_1_5:
 rts
fill_b_1_6:
 rts
fill_b_1_7:
 rts
fill_b_1_8:
 rts
fill_b_1_9:
 rts
fill_b_1_10:
 rts
fill_b_1_11:
 rts
fill_b_1_12:
 rts
fill_b_1_13:
 rts
fill_b_1_14:
 rts
fill_b_1_15:
 rts
fill_b_1_16:
 rts
fill_b_1_17:
 rts
fill_b_1_18:
 rts
fill_b_1_19:
 rts
fill_b_1_20:
 rts
fill_b_1_21:
 rts
 rts
fill_done:
 rts
fill_entry_lo:
 .byte <fill_a_0_0,<fill_a_0_1,<fill_a_0_2,<fill_a_0_3,<fill_a_0_4,<fill_a_0_5,<fill_a_0_6,<fill_a_0_7,<fill_a_0_8,<fill_a_0_9,<fill_a_0_10,<fill_a_0_11,<fill_a_0_12,<fill_a_0_13,<fill_a_0_14,<fill_a_0_15,<fill_a_0_16,<fill_a_0_17,<fill_a_0_18,<fill_a_0_19,<fill_a_0_20,<fill_a_0_21,<fill_a_1_0,<fill_a_1_1,<fill_a_1_2,<fill_a_1_3,<fill_a_1_4,<fill_a_1_5,<fill_a_1_6,<fill_a_1_7,<fill_a_1_8,<fill_a_1_9,<fill_a_1_10,<fill_a_1_11,<fill_a_1_12,<fill_a_1_13,<fill_a_1_14,<fill_a_1_15,<fill_a_1_16,<fill_a_1_17,<fill_a_1_18,<fill_a_1_19,<fill_a_1_20,<fill_a_1_21,<fill_b_0_0,<fill_b_0_1,<fill_b_0_2,<fill_b_0_3,<fill_b_0_4,<fill_b_0_5,<fill_b_0_6,<fill_b_0_7,<fill_b_0_8,<fill_b_0_9,<fill_b_0_10,<fill_b_0_11,<fill_b_0_12,<fill_b_0_13,<fill_b_0_14,<fill_b_0_15,<fill_b_0_16,<fill_b_0_17,<fill_b_0_18,<fill_b_0_19,<fill_b_0_20,<fill_b_0_21,<fill_b_1_0,<fill_b_1_1,<fill_b_1_2,<fill_b_1_3,<fill_b_1_4,<fill_b_1_5,<fill_b_1_6,<fill_b_1_7,<fill_b_1_8,<fill_b_1_9,<fill_b_1_10,<fill_b_1_11,<fill_b_1_12,<fill_b_1_13,<fill_b_1_14,<fill_b_1_15,<fill_b_1_16,<fill_b_1_17,<fill_b_1_18,<fill_b_1_19,<fill_b_1_20,<fill_b_1_21
fill_entry_hi:
 .byte >fill_a_0_0,>fill_a_0_1,>fill_a_0_2,>fill_a_0_3,>fill_a_0_4,>fill_a_0_5,>fill_a_0_6,>fill_a_0_7,>fill_a_0_8,>fill_a_0_9,>fill_a_0_10,>fill_a_0_11,>fill_a_0_12,>fill_a_0_13,>fill_a_0_14,>fill_a_0_15,>fill_a_0_16,>fill_a_0_17,>fill_a_0_18,>fill_a_0_19,>fill_a_0_20,>fill_a_0_21,>fill_a_1_0,>fill_a_1_1,>fill_a_1_2,>fill_a_1_3,>fill_a_1_4,>fill_a_1_5,>fill_a_1_6,>fill_a_1_7,>fill_a_1_8,>fill_a_1_9,>fill_a_1_10,>fill_a_1_11,>fill_a_1_12,>fill_a_1_13,>fill_a_1_14,>fill_a_1_15,>fill_a_1_16,>fill_a_1_17,>fill_a_1_18,>fill_a_1_19,>fill_a_1_20,>fill_a_1_21,>fill_b_0_0,>fill_b_0_1,>fill_b_0_2,>fill_b_0_3,>fill_b_0_4,>fill_b_0_5,>fill_b_0_6,>fill_b_0_7,>fill_b_0_8,>fill_b_0_9,>fill_b_0_10,>fill_b_0_11,>fill_b_0_12,>fill_b_0_13,>fill_b_0_14,>fill_b_0_15,>fill_b_0_16,>fill_b_0_17,>fill_b_0_18,>fill_b_0_19,>fill_b_0_20,>fill_b_0_21,>fill_b_1_0,>fill_b_1_1,>fill_b_1_2,>fill_b_1_3,>fill_b_1_4,>fill_b_1_5,>fill_b_1_6,>fill_b_1_7,>fill_b_1_8,>fill_b_1_9,>fill_b_1_10,>fill_b_1_11,>fill_b_1_12,>fill_b_1_13,>fill_b_1_14,>fill_b_1_15,>fill_b_1_16,>fill_b_1_17,>fill_b_1_18,>fill_b_1_19,>fill_b_1_20,>fill_b_1_21
clear_view:
 lda drawbuf
 bne clear_b
clear_a:
 ldx #0
clear_a_loop:
 txa
 and #1
 tay
 lda checker_bytes,y
 sta $6660,x
 sta $67a0,x
 sta $68e0,x
 sta $6a20,x
 sta $6b60,x
 sta $6ca0,x
 sta $6de0,x
 sta $6f20,x
 sta $7060,x
 lda #$55
 sta $71a0,x
 sta $72e0,x
 sta $7420,x
 sta $7560,x
 sta $76a0,x
 sta $77e0,x
 sta $7920,x
 sta $7a60,x
 sta $7ba0,x
 inx
 bne clear_a_loop
 rts
clear_b:
 ldx #0
clear_b_loop:
 txa
 and #1
 tay
 lda checker_bytes,y
 sta $e660,x
 sta $e7a0,x
 sta $e8e0,x
 sta $ea20,x
 sta $eb60,x
 sta $eca0,x
 sta $ede0,x
 sta $ef20,x
 sta $f060,x
 lda #$55
 sta $f1a0,x
 sta $f2e0,x
 sta $f420,x
 sta $f560,x
 sta $f6a0,x
 sta $f7e0,x
 sta $f920,x
 sta $fa60,x
 sta $fba0,x
 inx
 bne clear_b_loop
 rts
checker_bytes:
 .byte $44,$11
vp_clear_frame:
 lda #0
 tax
vp_clear_pages:
 sta $63c0,x
 sta $e3c0,x
 sta $64c0,x
 sta $e4c0,x
 sta $65c0,x
 sta $e5c0,x
 sta $66c0,x
 sta $e6c0,x
 sta $67c0,x
 sta $e7c0,x
 sta $68c0,x
 sta $e8c0,x
 sta $69c0,x
 sta $e9c0,x
 sta $6ac0,x
 sta $eac0,x
 sta $6bc0,x
 sta $ebc0,x
 sta $6cc0,x
 sta $ecc0,x
 sta $6dc0,x
 sta $edc0,x
 sta $6ec0,x
 sta $eec0,x
 sta $6fc0,x
 sta $efc0,x
 sta $70c0,x
 sta $f0c0,x
 sta $71c0,x
 sta $f1c0,x
 sta $72c0,x
 sta $f2c0,x
 sta $73c0,x
 sta $f3c0,x
 sta $74c0,x
 sta $f4c0,x
 sta $75c0,x
 sta $f5c0,x
 sta $76c0,x
 sta $f6c0,x
 sta $77c0,x
 sta $f7c0,x
 sta $78c0,x
 sta $f8c0,x
 sta $79c0,x
 sta $f9c0,x
 sta $7ac0,x
 sta $fac0,x
 sta $7bc0,x
 sta $fbc0,x
 sta $7cc0,x
 sta $fcc0,x
 sta $7dc0,x
 sta $fdc0,x
 inx
 bne vp_clear_pages
 ldx #127
vp_clear_tail:
 sta $7ec0,x
 sta $fec0,x
 dex
 bpl vp_clear_tail
 rts
; Guided full-world curved itinerary, foreground only. Heading is NOT cardinal.
; Eighth-yaw velocity ramps by 1/8 yaw unit per logical tick; maximum 1 yaw/tick.
; Hold counter retained as diagnostic steering state, not a route selector.
; Tight bends advance a subunit Q8 step every fourth logical tick, not frame.
; Original axis-separated collision routine still decides actual displacement.
.if AUTO_RUN != 0
nav_node=$d2
nav_previous=$d3
nav_target=$d4
nav_goal_lo=$d5
nav_goal_hi=$d6
nav_rng=$d7
nav_dir=$d9
nav_diff=$da
nav_visits=$db
nav_velocity=$dd
nav_fraction=$de
nav_slow=$df
nav_dx=$e0
nav_dy=$e2
nav_signs=$e4
nav_den=$e5
nav_rem=$e6
nav_ratio=$e7
nav_tmp=$e8
nav_negative=$e9
nav_hold=$ea
nav_course=$eb
nav_move_phase=$ec

nav_init:
 ; Initialize only the automatic camera in the center of its safe passage.
 lda #<2432
 sta cam_x
 lda #>2432
 sta cam_x+1
 lda #<2534
 sta cam_y
 lda #>2534
 sta cam_y+1
 lda #<272
 sta cam_angle
 lda #>272
 sta cam_angle+1
 lda #0
 sta nav_node
 lda #$ff
 sta nav_previous
 sta nav_target
 lda #<3073
 sta nav_rng
 lda #>3073
 sta nav_rng+1
 lda #0
 sta nav_goal_lo
 sta nav_goal_hi
 sta nav_visits
 sta nav_visits+1
 sta nav_velocity
 sta nav_fraction
 sta nav_slow
 sta nav_hold
 sta nav_course
 sta nav_move_phase
 rts

nav_input:
 ldx nav_target
 cpx #$ff
 beq nav_choose
 jsr nav_difference
 lda nav_dx+1
 ora nav_dy+1
 bne nav_heading
 lda nav_dx
 cmp #64
 bcs nav_heading
 lda nav_dy
 cmp #64
 bcs nav_heading
 lda nav_node
 sta nav_previous
 stx nav_node
 inc nav_visits
 bne nav_choose
 inc nav_visits+1
nav_choose:
 ; Non-cardinal next waypoint. Closure returns to node0, never resets camera.
 lda nav_node
 clc
 adc #1
 cmp #142
 bcc nav_accept
 lda #0
nav_accept:
 sta nav_target
 tax
 jsr nav_difference

nav_heading:
 lda nav_dx+1
 ora nav_dy+1
 beq nav_normalized
 lsr nav_dx+1
 ror nav_dx
 lsr nav_dy+1
 ror nav_dy
 jmp nav_heading
nav_normalized:
 lda nav_dx
 cmp nav_dy
 bcc nav_y_major
 beq nav_equal
 lda nav_signs
 ora #4
 sta nav_signs
 lda nav_dx
 sta nav_den
 lda nav_dy
 jmp nav_ratio_begin
nav_y_major:
 lda nav_dy
 sta nav_den
 lda nav_dx
nav_ratio_begin:
 sta nav_rem
 lda #0
 sta nav_ratio
 ldx #7
nav_ratio_bit:
 asl nav_rem
 bcs nav_ratio_subtract
 lda nav_rem
 cmp nav_den
 bcc nav_ratio_keep
nav_ratio_subtract:
 lda nav_rem
 sec
 sbc nav_den
 sta nav_rem
 sec
nav_ratio_keep:
 rol nav_ratio
 dex
 bne nav_ratio_bit
 ldx nav_ratio
 lda nav_atan,x
 jmp nav_octant
nav_equal:
 lda #64
nav_octant:
 sta nav_goal_lo
 lda nav_signs
 and #4
 beq nav_reflect_y
 lda #128
 sec
 sbc nav_goal_lo
 sta nav_goal_lo
nav_reflect_y:
 lda #0
 sta nav_goal_hi
 lda nav_signs
 and #2
 beq nav_reflect_x
 lda #0
 sec
 sbc nav_goal_lo
 sta nav_goal_lo
 lda #1
 sbc #0
 sta nav_goal_hi
nav_reflect_x:
 lda nav_signs
 and #1
 beq nav_steer
 lda #0
 sec
 sbc nav_goal_lo
 sta nav_goal_lo
 lda #0
 sbc nav_goal_hi
 and #1
 sta nav_goal_hi

nav_steer:
 lda #0
 sta nav_negative
 sec
 lda nav_goal_lo
 sbc cam_angle
 sta nav_diff
 lda nav_goal_hi
 sbc cam_angle+1
 and #1
 beq nav_positive_error
 dec nav_negative
 lda #0
 sec
 sbc nav_diff
 bne nav_abs_error
 lda #255 ; -256: saturate absolute magnitude for speed/turn clamps only
 bne nav_abs_error
nav_positive_error:
 lda nav_diff
nav_abs_error:
 ; Reload hold during a turn; count down only after yaw error is small.
 cmp #17
 bcc nav_hold_count
 ldx #150
 stx nav_hold
 jmp nav_hold_ready
nav_hold_count:
 ldx nav_hold
 beq nav_hold_ready
 dec nav_hold
nav_hold_ready:
 ; Earlier braking preserves safe radius with gentler angular motion.
 ; Hysteresis for translation speed: brake at 9/17, release at 6/12.
 ; Do not alternate speed at a quantized heading threshold.
 ldx nav_slow
 cpx #2
 bne nav_speed_normal
 cmp #13
 bcs nav_speed_chosen
 ldx #1
 cmp #7
 bcs nav_speed_chosen
 ldx #0
 beq nav_speed_chosen
nav_speed_normal:
 cmp #17
 bcc nav_speed_lower
 ldx #2
 bne nav_speed_chosen
nav_speed_lower:
 cpx #1
 bne nav_speed_fast
 cmp #7
 bcs nav_speed_chosen
 ldx #0
 beq nav_speed_chosen
nav_speed_fast:
 cmp #9
 bcc nav_speed_chosen
 ldx #1
nav_speed_chosen:
 stx nav_slow
 ; Ignore +/-2 integer yaw units of atan/coordinate rounding noise.
 ; Keep bounded angular acceleration; never snap the actual camera angle.
 sec
 sbc #2
 bcs nav_deadband_done
 lda #0
nav_deadband_done:
 cmp #9
 bcc nav_desired_magnitude
 lda #8
nav_desired_magnitude:
 ldx nav_negative
 beq nav_desired_signed
 eor #$ff
 clc
 adc #1
nav_desired_signed:
 eor #$80
 sta nav_tmp
 lda nav_velocity
 eor #$80
 cmp nav_tmp
 beq nav_integrate
 bcc nav_accelerate
 dec nav_velocity
 jmp nav_integrate
nav_accelerate:
 inc nav_velocity
nav_integrate:
 lda nav_velocity
 clc
 adc nav_fraction
 sta nav_tmp
 and #7
 sta nav_fraction
 lda nav_tmp
 cmp #$80
 ror
 cmp #$80
 ror
 cmp #$80
 ror
 ldx #0
 cmp #$80
 bcc nav_positive_turn
 dex
nav_positive_turn:
 clc
 adc cam_angle
 sta cam_angle
 txa
 adc cam_angle+1
 and #1
 sta cam_angle+1
 lda nav_move_phase
 clc
 adc #1
 and #3
 sta nav_move_phase
 ldx nav_slow
 cpx #2
 bne nav_move_forward
 cmp #0
 beq nav_move_forward
 lda #0
 sta keys
 rts
nav_move_forward:
 lda #1
 sta keys
 rts

; X remains the target node. Signed differences fit within +/-8191 Q8 units.
nav_difference:
 lda #0
 sta nav_signs
 sec
 lda nav_xlo,x
 sbc cam_x
 sta nav_dx
 lda nav_xhi,x
 sbc cam_x+1
 sta nav_dx+1
 bpl nav_dx_ready
 inc nav_signs
 sec
 lda #0
 sbc nav_dx
 sta nav_dx
 lda #0
 sbc nav_dx+1
 sta nav_dx+1
nav_dx_ready:
 sec
 lda nav_ylo,x
 sbc cam_y
 sta nav_dy
 lda nav_yhi,x
 sbc cam_y+1
 sta nav_dy+1
 bpl nav_difference_done
 inc nav_signs
 inc nav_signs
 sec
 lda #0
 sbc nav_dy
 sta nav_dy
 lda #0
 sbc nav_dy+1
 sta nav_dy+1
nav_difference_done:
 rts

nav_scale_speed:
 ldx nav_slow
 beq nav_scale_done
nav_scale_loop:
 lda move_x
 bpl nav_scale_x_positive
 clc
 adc #1 ; signed half, truncate toward zero
nav_scale_x_positive:
 cmp #$80
 ror
 sta move_x
 lda move_y
 bpl nav_scale_y_positive
 clc
 adc #1
nav_scale_y_positive:
 cmp #$80
 ror
 sta move_y
 dex
 bne nav_scale_loop
nav_scale_done:
 rts
.endif
init_masks:
 ldx #0
mask_init_loop:
 txa
 cmp #9
 bcc mask_init_store
 lda #8
mask_init_store:
 sta clamp8,x
 inx
 bne mask_init_loop
 ldx #0
 lda #0
times_init:
 sta times9,x
 clc
 adc #9
 inx
 cpx #9
 bne times_init
 rts
ui_text:
 .byte $20,$33,$44,$56,$49,$42,$45,$36,$34,$20,$31,$2e,$34,$2e,$30,$20
 .byte $2f,$20,$4d,$4f,$44,$45,$20,$38,$20,$2f,$20,$44,$45,$4d,$4f,$20
 .byte $33,$20,$20,$20,$20,$20,$20,$20,$20,$46,$50,$53,$20,$30,$30,$20
 .byte $2f,$20,$57,$20,$53,$20,$4d,$4f,$56,$45,$20,$41,$20,$44,$20,$54
 .byte $55,$52,$4e,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
 .byte $20,$54,$57,$4f,$20,$4c,$45,$56,$45,$4c,$53,$20,$41,$4e,$44,$20
 .byte $43,$4f,$4e,$54,$49,$4e,$55,$4f,$55,$53,$20,$52,$41,$4d,$50,$53
 .byte $20,$20,$20,$20,$20,$20,$20,$20
auto_keys:
 .byte $01,$09,$01,$05,$01,$08,$01,$09,$01,$05,$01,$08
auto_duration_lo:
 .byte $2b,$40,$ac,$40,$a9,$80,$a9,$40,$ac,$40,$2b,$80
auto_duration_hi:
 .byte $01,$00,$00,$00,$01,$00,$01,$00,$00,$00,$01,$00
offsets_lo:
 .byte $d5,$d8,$da,$dc,$df,$e1,$e4,$e6,$e9,$ec,$ef,$f1,$f4,$f7,$fa,$fd
 .byte $00,$03,$06,$09,$0c,$0f,$11,$14,$17,$1a,$1c,$1f,$21,$24,$26,$28
 .byte $2b
offsets_hi:
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00
fine_offsets_lo:
 .byte $d6,$d6,$d7,$d7,$d8,$d8,$d9,$da,$da,$db,$db,$dc,$dd,$dd,$de,$de
 .byte $df,$e0,$e0,$e1,$e2,$e2,$e3,$e3,$e4,$e5,$e5,$e6,$e7,$e7,$e8,$e9
 .byte $e9,$ea,$eb,$eb,$ec,$ed,$ee,$ee,$ef,$f0,$f0,$f1,$f2,$f3,$f3,$f4
 .byte $f5,$f5,$f6,$f7,$f8,$f8,$f9,$fa,$fa,$fb,$fc,$fd,$fd,$fe,$ff,$00
 .byte $00,$01,$02,$03,$03,$04,$05,$06,$06,$07,$08,$08,$09,$0a,$0b,$0b
 .byte $0c,$0d,$0d,$0e,$0f,$10,$10,$11,$12,$12,$13,$14,$15,$15,$16,$17
 .byte $17,$18,$19,$19,$1a,$1b,$1b,$1c,$1d,$1d,$1e,$1e,$1f,$20,$20,$21
 .byte $22,$22,$23,$23,$24,$25,$25,$26,$26,$27,$28,$28,$29,$29,$2a,$2a
fine_offsets_hi:
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
path_lo:
 .byte $00,$10,$20,$30,$40,$50,$60,$70,$80,$90,$a0,$b0,$c0,$d0,$e0,$f0
 .byte $00,$10,$20,$30,$40,$50,$60,$70,$80,$90,$a0,$b0,$c0,$d0,$e0,$f0
 .byte $b0
path_hi:
 .byte $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30
 .byte $31,$31,$31,$31,$31,$31,$31,$31,$31,$31,$31,$31,$31,$31,$31,$31
 .byte $32
cache_lo:
 .byte $00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80
 .byte $00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80
cache_hi:
 .byte $8a,$8a,$8b,$8b,$8c,$8c,$8d,$8d,$8e,$8e,$8f,$8f,$90,$90,$91,$91
 .byte $92,$92,$93,$93,$94,$94,$95,$95,$96,$96,$97,$97,$98,$98,$99,$99
bitmap_row_lo:
 .byte $60,$a0,$e0,$20,$60,$a0,$e0,$20,$60,$a0,$e0,$20,$60,$a0,$e0,$20
 .byte $60,$a0
bitmap_row_hi:
 .byte $66,$67,$68,$6a,$6b,$6c,$6d,$6f,$70,$71,$72,$74,$75,$76,$77,$79
 .byte $7a,$7b
code_end:
.cerror code_end>$3000,"code overlaps path buffers"
*=$3000
 .fill 1024,$00
*=$3400
floor_map:
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$20,$20,$20,$20,$20,$20,$20,$20
 .byte $20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$20,$20,$20,$20,$20,$20,$20,$20
 .byte $20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$20,$20,$20,$20,$20,$20,$20,$20
 .byte $20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fe,$fe
 .byte $fe,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$fe,$fe
 .byte $fe,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$00,$00
 .byte $00,$00,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$fe,$fe
 .byte $fe,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$00,$00
 .byte $00,$00,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$fe,$fe
 .byte $fe,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$00,$00
 .byte $00,$00,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
 .byte $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$00,$00
 .byte $00,$00,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
 .byte $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$00,$00
 .byte $00,$00,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
 .byte $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$00,$00
 .byte $00,$00,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
 .byte $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$00,$00
 .byte $00,$00,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
 .byte $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$00,$00
 .byte $00,$00,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
 .byte $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$00,$00
 .byte $00,$00,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
 .byte $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$00,$00
 .byte $00,$00,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
 .byte $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$00,$00
 .byte $00,$00,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
 .byte $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
*=$3800
ceiling_map:
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
 .byte $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$c0,$c0
 .byte $c0,$c0,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
 .byte $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$c0,$c0
 .byte $c0,$c0,$80,$80,$80,$80,$80,$80,$80,$80,$50,$80,$80,$80,$80,$80
 .byte $80,$80,$80,$80,$80,$50,$80,$80,$80,$80,$80,$80,$80,$80,$c0,$c0
 .byte $c0,$c0,$80,$80,$80,$80,$80,$80,$80,$80,$50,$80,$80,$80,$80,$80
 .byte $80,$80,$80,$80,$80,$50,$80,$80,$80,$80,$80,$80,$80,$80,$c0,$c0
 .byte $c0,$c0,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
 .byte $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$c0,$c0
 .byte $c0,$c0,$80,$80,$80,$50,$50,$50,$80,$80,$80,$80,$80,$80,$80,$80
 .byte $50,$50,$50,$80,$80,$80,$80,$80,$80,$50,$50,$50,$80,$80,$c0,$c0
 .byte $c0,$c0,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
 .byte $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$c0,$c0
 .byte $c0,$c0,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$50,$80,$80,$80
 .byte $80,$80,$80,$80,$80,$50,$80,$80,$80,$80,$80,$80,$80,$80,$c0,$c0
 .byte $c0,$c0,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$50,$80,$80,$80
 .byte $80,$80,$80,$80,$80,$50,$80,$80,$80,$80,$80,$80,$80,$80,$c0,$c0
 .byte $c0,$c0,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
 .byte $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$90,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$90,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$90,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$90,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$90,$90,$90,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$90,$90,$90,$c0,$c0,$c0,$c0,$c0,$90,$90,$90,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $90,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $90,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
*=$3c00
solid_map:
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$00,$00,$01,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$01,$00,$00,$01,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$01,$01,$01,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $00,$00,$00,$01,$01,$01,$01,$01,$01,$00,$00,$00,$01,$01,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00
 .byte $00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$01,$00,$00
 .byte $00,$01,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$01,$00,$00,$01,$00,$01,$00,$00
 .byte $00,$01,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$01,$00,$00
 .byte $00,$01,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$01,$01,$01,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$00,$00,$00,$01,$01,$01,$01,$01,$00,$00,$00,$01,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
*=$4000
 .fill 1024,$a5
*=$4400
event_map_0:
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00
 .byte $00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$02,$00,$00,$05,$00,$00,$00,$00,$00,$03,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$07,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$08,$09,$00,$00,$00,$00,$00,$00,$00,$03,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$07,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$08,$09,$00,$00,$00,$00,$00,$00,$00,$03,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$0a,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$0b,$00,$00,$00,$00,$00,$00,$00,$00,$0c,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0d,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0e,$0f,$00,$00
 .byte $00,$00,$00,$00,$00,$08,$09,$00,$00,$00,$00,$00,$00,$00,$03,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0e,$0f,$00,$00
 .byte $00,$00,$00,$00,$00,$08,$09,$00,$00,$00,$00,$00,$00,$00,$03,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0d,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$11,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$11,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$11,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13,$00,$14,$00,$00
 .byte $00,$12,$00,$00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$16,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$17,$00,$00,$13,$00,$14,$00,$00
 .byte $00,$12,$00,$00,$00,$00,$00,$15,$00,$00,$00,$00,$18,$00,$16,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13,$00,$14,$00,$00
 .byte $00,$12,$00,$00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$16,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$16,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$19,$1a,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$1b,$1c,$00,$00,$00,$00,$00,$16,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$19,$1a,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$1b,$1c,$00,$00,$00,$00,$00,$16,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$16,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$1d,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$1e,$00,$00,$00,$00,$00,$00,$00,$1f,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$16,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $21,$22,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$16,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $21,$22,$00,$00,$23,$00,$00,$00,$00,$00,$00,$00,$00,$00,$16,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$16,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
event_map_1:
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$24,$00,$00,$00,$00,$00,$00,$00,$00,$25,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$26,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$24,$00,$00,$27,$00,$00,$00,$00,$00,$25,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$26,$00,$00,$28,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$24,$00,$00,$00,$00,$00,$00,$00,$29,$2a,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$2b,$2c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$24,$00,$00,$00,$00,$00,$00,$00,$29,$2a,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$2b,$2c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$24,$00,$00,$00,$00,$00,$00,$00,$00,$25,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$26,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$2d,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$2e
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$2f,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$24,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$30,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$26,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$24,$00,$00,$00,$00,$00,$00,$00,$00,$00,$31,$32,$00,$00,$00
 .byte $00,$00,$00,$00,$2b,$2c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$24,$00,$00,$00,$00,$00,$00,$00,$00,$00,$31,$32,$00,$00,$00
 .byte $00,$00,$00,$00,$2b,$2c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$24,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$30,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$26,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$33,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$33,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$33,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$33,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$34,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$34,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$34,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$35,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$36,$00,$00,$00,$00,$00,$00,$00,$00,$00,$37,$00,$35,$00,$00
 .byte $00,$38,$00,$00,$00,$00,$00,$39,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$36,$00,$00,$00,$00,$00,$00,$3a,$00,$00,$37,$00,$35,$00,$00
 .byte $00,$38,$00,$00,$00,$00,$00,$39,$00,$00,$00,$00,$3b,$00,$00,$00
 .byte $00,$36,$00,$00,$00,$00,$00,$00,$00,$00,$00,$37,$00,$35,$00,$00
 .byte $00,$38,$00,$00,$00,$00,$00,$39,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$36,$00,$00,$00,$00,$00,$00,$00,$00,$00,$37,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$39,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$36,$00,$00,$00,$00,$00,$00,$00,$00,$3c,$3d,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$3e,$3f,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$36,$00,$00,$00,$00,$00,$00,$00,$00,$3c,$3d,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$3e,$3f,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$36,$00,$00,$00,$00,$00,$00,$00,$00,$00,$37,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$39,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$41,$00,$00,$00,$00,$00,$00,$00,$42,$00,$00,$00,$00,$00,$00
 .byte $00,$36,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $43,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$36,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$44
 .byte $45,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$36,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$44
 .byte $45,$00,$00,$00,$46,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$36,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $43,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
event_map_2:
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$47,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$47,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$48,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$48,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$49,$49,$49,$4a,$4a,$4a,$49,$49,$00,$49,$49,$49,$49,$49
 .byte $4a,$4a,$4a,$49,$49,$00,$49,$49,$49,$4a,$4a,$4a,$49,$49,$00,$00
 .byte $00,$00,$00,$00,$00,$4b,$4b,$4b,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $4b,$4b,$4b,$00,$00,$00,$00,$00,$00,$4b,$4b,$4b,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$4c,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$4c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$4d,$4d,$4d,$4d,$4d,$4d,$4e,$4e,$4e,$4d,$00,$4d,$4d,$4d
 .byte $4d,$4d,$4d,$4d,$4d,$00,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$4f,$4f,$4f,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$50,$50,$50,$50,$50,$50,$51,$51
 .byte $51,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$52,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$52,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$53,$53
 .byte $53,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$54,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$54,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$55,$55,$55,$56,$56,$56,$55,$55,$55,$00,$55,$55,$55,$55
 .byte $55,$55,$56,$56,$56,$55,$55,$00,$55,$55,$56,$56,$56,$55,$00,$00
 .byte $00,$00,$00,$00,$00,$57,$57,$57,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$57,$57,$57,$00,$00,$00,$00,$00,$57,$57,$57,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$58,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $59,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a
 .byte $00,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$00,$00
event_map_3:
 .byte $00,$00,$5b,$5b,$5b,$5b,$5b,$5b,$5b,$5b,$00,$5b,$5b,$5b,$5b,$5b
 .byte $5b,$5b,$5b,$5b,$5b,$00,$5b,$5b,$5b,$5b,$5b,$5b,$5b,$5b,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$5c,$00,$00,$00,$00,$00,$5d,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$5d,$00,$00,$5c,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$5e,$5e,$5e,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $5e,$5e,$5e,$00,$00,$00,$00,$00,$00,$5e,$5e,$5e,$00,$00,$00,$00
 .byte $00,$00,$5f,$5f,$5f,$60,$60,$60,$5f,$5f,$5f,$5f,$00,$5f,$5f,$5f
 .byte $60,$60,$60,$5f,$5f,$00,$5f,$5f,$5f,$60,$60,$60,$5f,$5f,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$61,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$61,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$62,$62,$62,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$63,$63,$63,$64,$64,$64,$64,$64
 .byte $64,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$65,$65
 .byte $65,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$66,$66,$66,$66,$66,$66,$66,$66,$66,$00,$66,$00,$00,$00
 .byte $00,$00,$66,$66,$66,$66,$66,$00,$66,$66,$66,$66,$66,$66,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$67,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$67,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$68,$69,$69
 .byte $69,$68,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$6a,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$6a,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$6b,$6b,$6b,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$6b,$6b,$6b,$00,$00,$00,$00,$00,$6b,$6b,$6b,$00,$00,$00
 .byte $00,$00,$6c,$6c,$6c,$6d,$6d,$6d,$6c,$6c,$6c,$6c,$6c,$6c,$6c,$6c
 .byte $00,$6c,$6d,$6d,$6d,$6c,$6c,$6c,$6c,$6c,$6d,$6d,$6d,$6c,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $6e,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$6f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
*=$5500
fixed_height_code:
; Fixed-height projection helper. $38 aliases p_unit/r_sx, dead after DDA.
fh_kind=$38
fh_height_delta:
 lda #0
 sta fh_kind
 lda pose_z_frac
 bne fh_height_generic
 ldx p_key
 lda key_alt,x
 and #$3f
 bne fh_height_generic
 lda key_alt,x
 and #$40
 ora #32
 cmp pose_z
 bne fh_height_generic
 lda #0
 sta p_ramp
 sta p_dz
 sta p_dz+2
 sta p_zsign
 lda key_alt,x
 bmi fh_ceiling
 lda #1
 sta fh_kind
 lda #32
 sta p_dz+1
 rts
fh_ceiling:
 lda #2
 sta fh_kind
 lda #$80
 sta p_zsign
 lda #96
 sta p_dz+1
 rts
fh_height_generic:
 jmp ramp_height_delta

fh_ratio:
 lda fh_kind
 beq fh_ratio_generic
 lda unit_value+0
 sta p_ratio+0
 lda unit_value+1
 sta p_ratio+1
 lda unit_value+2
 sta p_ratio+2
 lda unit_value+3
 sta p_ratio+3
 lda fh_kind
 cmp #2
 bne fh_ratio_shift
 asl p_ratio
 rol p_ratio+1
 rol p_ratio+2
 rol p_ratio+3
 clc
 lda p_ratio+0
 adc unit_value+0
 sta p_ratio+0
 lda p_ratio+1
 adc unit_value+1
 sta p_ratio+1
 lda p_ratio+2
 adc unit_value+2
 sta p_ratio+2
 lda p_ratio+3
 adc unit_value+3
 sta p_ratio+3
fh_ratio_shift:
 lsr p_ratio+3
 ror p_ratio+2
 ror p_ratio+1
 ror p_ratio
 lsr p_ratio+3
 ror p_ratio+2
 ror p_ratio+1
 ror p_ratio
 lsr p_ratio+3
 ror p_ratio+2
 ror p_ratio+1
 ror p_ratio
 rts
fh_ratio_generic:
 ldx #3
restore_unit:
 lda unit_value,x
 sta p_value,x
 dex
 bpl restore_unit
 lda p_dz
 sta p_multiplier
 lda p_dz+1
 sta p_multiplier+1
 jsr p_mul32x16
 ldx #3
save_ratio:
 lda p_product+2,x
 sta p_ratio,x
 dex
 bpl save_ratio
 rts
fixed_height_end:
.cerror fixed_height_end>$5800,"fixed height helper overlaps font"
*=$5800
 .binary "font.bin"
*=$8000
qs_sum_lo:
 .byte $00,$00,$01,$02,$04,$06,$09,$0c,$10,$14,$19,$1e,$24,$2a,$31,$38
 .byte $40,$48,$51,$5a,$64,$6e,$79,$84,$90,$9c,$a9,$b6,$c4,$d2,$e1,$f0
 .byte $00,$10,$21,$32,$44,$56,$69,$7c,$90,$a4,$b9,$ce,$e4,$fa,$11,$28
 .byte $40,$58,$71,$8a,$a4,$be,$d9,$f4,$10,$2c,$49,$66,$84,$a2,$c1,$e0
 .byte $00,$20,$41,$62,$84,$a6,$c9,$ec,$10,$34,$59,$7e,$a4,$ca,$f1,$18
 .byte $40,$68,$91,$ba,$e4,$0e,$39,$64,$90,$bc,$e9,$16,$44,$72,$a1,$d0
 .byte $00,$30,$61,$92,$c4,$f6,$29,$5c,$90,$c4,$f9,$2e,$64,$9a,$d1,$08
 .byte $40,$78,$b1,$ea,$24,$5e,$99,$d4,$10,$4c,$89,$c6,$04,$42,$81,$c0
 .byte $00,$40,$81,$c2,$04,$46,$89,$cc,$10,$54,$99,$de,$24,$6a,$b1,$f8
 .byte $40,$88,$d1,$1a,$64,$ae,$f9,$44,$90,$dc,$29,$76,$c4,$12,$61,$b0
 .byte $00,$50,$a1,$f2,$44,$96,$e9,$3c,$90,$e4,$39,$8e,$e4,$3a,$91,$e8
 .byte $40,$98,$f1,$4a,$a4,$fe,$59,$b4,$10,$6c,$c9,$26,$84,$e2,$41,$a0
 .byte $00,$60,$c1,$22,$84,$e6,$49,$ac,$10,$74,$d9,$3e,$a4,$0a,$71,$d8
 .byte $40,$a8,$11,$7a,$e4,$4e,$b9,$24,$90,$fc,$69,$d6,$44,$b2,$21,$90
 .byte $00,$70,$e1,$52,$c4,$36,$a9,$1c,$90,$04,$79,$ee,$64,$da,$51,$c8
 .byte $40,$b8,$31,$aa,$24,$9e,$19,$94,$10,$8c,$09,$86,$04,$82,$01,$80
 .byte $00,$80,$01,$82,$04,$86,$09,$8c,$10,$94,$19,$9e,$24,$aa,$31,$b8
 .byte $40,$c8,$51,$da,$64,$ee,$79,$04,$90,$1c,$a9,$36,$c4,$52,$e1,$70
 .byte $00,$90,$21,$b2,$44,$d6,$69,$fc,$90,$24,$b9,$4e,$e4,$7a,$11,$a8
 .byte $40,$d8,$71,$0a,$a4,$3e,$d9,$74,$10,$ac,$49,$e6,$84,$22,$c1,$60
 .byte $00,$a0,$41,$e2,$84,$26,$c9,$6c,$10,$b4,$59,$fe,$a4,$4a,$f1,$98
 .byte $40,$e8,$91,$3a,$e4,$8e,$39,$e4,$90,$3c,$e9,$96,$44,$f2,$a1,$50
 .byte $00,$b0,$61,$12,$c4,$76,$29,$dc,$90,$44,$f9,$ae,$64,$1a,$d1,$88
 .byte $40,$f8,$b1,$6a,$24,$de,$99,$54,$10,$cc,$89,$46,$04,$c2,$81,$40
 .byte $00,$c0,$81,$42,$04,$c6,$89,$4c,$10,$d4,$99,$5e,$24,$ea,$b1,$78
 .byte $40,$08,$d1,$9a,$64,$2e,$f9,$c4,$90,$5c,$29,$f6,$c4,$92,$61,$30
 .byte $00,$d0,$a1,$72,$44,$16,$e9,$bc,$90,$64,$39,$0e,$e4,$ba,$91,$68
 .byte $40,$18,$f1,$ca,$a4,$7e,$59,$34,$10,$ec,$c9,$a6,$84,$62,$41,$20
 .byte $00,$e0,$c1,$a2,$84,$66,$49,$2c,$10,$f4,$d9,$be,$a4,$8a,$71,$58
 .byte $40,$28,$11,$fa,$e4,$ce,$b9,$a4,$90,$7c,$69,$56,$44,$32,$21,$10
 .byte $00,$f0,$e1,$d2,$c4,$b6,$a9,$9c,$90,$84,$79,$6e,$64,$5a,$51,$48
 .byte $40,$38,$31,$2a,$24,$1e,$19,$14,$10,$0c,$09,$06,$04,$02,$01,$00
qs_sum_hi:
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $04,$04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$05,$06
 .byte $06,$06,$06,$06,$06,$07,$07,$07,$07,$07,$07,$08,$08,$08,$08,$08
 .byte $09,$09,$09,$09,$09,$09,$0a,$0a,$0a,$0a,$0a,$0b,$0b,$0b,$0b,$0c
 .byte $0c,$0c,$0c,$0c,$0d,$0d,$0d,$0d,$0e,$0e,$0e,$0e,$0f,$0f,$0f,$0f
 .byte $10,$10,$10,$10,$11,$11,$11,$11,$12,$12,$12,$12,$13,$13,$13,$13
 .byte $14,$14,$14,$15,$15,$15,$15,$16,$16,$16,$17,$17,$17,$18,$18,$18
 .byte $19,$19,$19,$19,$1a,$1a,$1a,$1b,$1b,$1b,$1c,$1c,$1c,$1d,$1d,$1d
 .byte $1e,$1e,$1e,$1f,$1f,$1f,$20,$20,$21,$21,$21,$22,$22,$22,$23,$23
 .byte $24,$24,$24,$25,$25,$25,$26,$26,$27,$27,$27,$28,$28,$29,$29,$29
 .byte $2a,$2a,$2b,$2b,$2b,$2c,$2c,$2d,$2d,$2d,$2e,$2e,$2f,$2f,$30,$30
 .byte $31,$31,$31,$32,$32,$33,$33,$34,$34,$35,$35,$35,$36,$36,$37,$37
 .byte $38,$38,$39,$39,$3a,$3a,$3b,$3b,$3c,$3c,$3d,$3d,$3e,$3e,$3f,$3f
 .byte $40,$40,$41,$41,$42,$42,$43,$43,$44,$44,$45,$45,$46,$46,$47,$47
 .byte $48,$48,$49,$49,$4a,$4a,$4b,$4c,$4c,$4d,$4d,$4e,$4e,$4f,$4f,$50
 .byte $51,$51,$52,$52,$53,$53,$54,$54,$55,$56,$56,$57,$57,$58,$59,$59
 .byte $5a,$5a,$5b,$5c,$5c,$5d,$5d,$5e,$5f,$5f,$60,$60,$61,$62,$62,$63
 .byte $64,$64,$65,$65,$66,$67,$67,$68,$69,$69,$6a,$6a,$6b,$6c,$6c,$6d
 .byte $6e,$6e,$6f,$70,$70,$71,$72,$72,$73,$74,$74,$75,$76,$76,$77,$78
 .byte $79,$79,$7a,$7b,$7b,$7c,$7d,$7d,$7e,$7f,$7f,$80,$81,$82,$82,$83
 .byte $84,$84,$85,$86,$87,$87,$88,$89,$8a,$8a,$8b,$8c,$8d,$8d,$8e,$8f
 .byte $90,$90,$91,$92,$93,$93,$94,$95,$96,$96,$97,$98,$99,$99,$9a,$9b
 .byte $9c,$9d,$9d,$9e,$9f,$a0,$a0,$a1,$a2,$a3,$a4,$a4,$a5,$a6,$a7,$a8
 .byte $a9,$a9,$aa,$ab,$ac,$ad,$ad,$ae,$af,$b0,$b1,$b2,$b2,$b3,$b4,$b5
 .byte $b6,$b7,$b7,$b8,$b9,$ba,$bb,$bc,$bd,$bd,$be,$bf,$c0,$c1,$c2,$c3
 .byte $c4,$c4,$c5,$c6,$c7,$c8,$c9,$ca,$cb,$cb,$cc,$cd,$ce,$cf,$d0,$d1
 .byte $d2,$d3,$d4,$d4,$d5,$d6,$d7,$d8,$d9,$da,$db,$dc,$dd,$de,$df,$e0
 .byte $e1,$e1,$e2,$e3,$e4,$e5,$e6,$e7,$e8,$e9,$ea,$eb,$ec,$ed,$ee,$ef
 .byte $f0,$f1,$f2,$f3,$f4,$f5,$f6,$f7,$f8,$f9,$fa,$fb,$fc,$fd,$fe,$ff
qs_diff_lo:
 .byte $80,$01,$82,$04,$86,$09,$8c,$10,$94,$19,$9e,$24,$aa,$31,$b8,$40
 .byte $c8,$51,$da,$64,$ee,$79,$04,$90,$1c,$a9,$36,$c4,$52,$e1,$70,$00
 .byte $90,$21,$b2,$44,$d6,$69,$fc,$90,$24,$b9,$4e,$e4,$7a,$11,$a8,$40
 .byte $d8,$71,$0a,$a4,$3e,$d9,$74,$10,$ac,$49,$e6,$84,$22,$c1,$60,$00
 .byte $a0,$41,$e2,$84,$26,$c9,$6c,$10,$b4,$59,$fe,$a4,$4a,$f1,$98,$40
 .byte $e8,$91,$3a,$e4,$8e,$39,$e4,$90,$3c,$e9,$96,$44,$f2,$a1,$50,$00
 .byte $b0,$61,$12,$c4,$76,$29,$dc,$90,$44,$f9,$ae,$64,$1a,$d1,$88,$40
 .byte $f8,$b1,$6a,$24,$de,$99,$54,$10,$cc,$89,$46,$04,$c2,$81,$40,$00
 .byte $c0,$81,$42,$04,$c6,$89,$4c,$10,$d4,$99,$5e,$24,$ea,$b1,$78,$40
 .byte $08,$d1,$9a,$64,$2e,$f9,$c4,$90,$5c,$29,$f6,$c4,$92,$61,$30,$00
 .byte $d0,$a1,$72,$44,$16,$e9,$bc,$90,$64,$39,$0e,$e4,$ba,$91,$68,$40
 .byte $18,$f1,$ca,$a4,$7e,$59,$34,$10,$ec,$c9,$a6,$84,$62,$41,$20,$00
 .byte $e0,$c1,$a2,$84,$66,$49,$2c,$10,$f4,$d9,$be,$a4,$8a,$71,$58,$40
 .byte $28,$11,$fa,$e4,$ce,$b9,$a4,$90,$7c,$69,$56,$44,$32,$21,$10,$00
 .byte $f0,$e1,$d2,$c4,$b6,$a9,$9c,$90,$84,$79,$6e,$64,$5a,$51,$48,$40
 .byte $38,$31,$2a,$24,$1e,$19,$14,$10,$0c,$09,$06,$04,$02,$01,$00,$00
 .byte $00,$01,$02,$04,$06,$09,$0c,$10,$14,$19,$1e,$24,$2a,$31,$38,$40
 .byte $48,$51,$5a,$64,$6e,$79,$84,$90,$9c,$a9,$b6,$c4,$d2,$e1,$f0,$00
 .byte $10,$21,$32,$44,$56,$69,$7c,$90,$a4,$b9,$ce,$e4,$fa,$11,$28,$40
 .byte $58,$71,$8a,$a4,$be,$d9,$f4,$10,$2c,$49,$66,$84,$a2,$c1,$e0,$00
 .byte $20,$41,$62,$84,$a6,$c9,$ec,$10,$34,$59,$7e,$a4,$ca,$f1,$18,$40
 .byte $68,$91,$ba,$e4,$0e,$39,$64,$90,$bc,$e9,$16,$44,$72,$a1,$d0,$00
 .byte $30,$61,$92,$c4,$f6,$29,$5c,$90,$c4,$f9,$2e,$64,$9a,$d1,$08,$40
 .byte $78,$b1,$ea,$24,$5e,$99,$d4,$10,$4c,$89,$c6,$04,$42,$81,$c0,$00
 .byte $40,$81,$c2,$04,$46,$89,$cc,$10,$54,$99,$de,$24,$6a,$b1,$f8,$40
 .byte $88,$d1,$1a,$64,$ae,$f9,$44,$90,$dc,$29,$76,$c4,$12,$61,$b0,$00
 .byte $50,$a1,$f2,$44,$96,$e9,$3c,$90,$e4,$39,$8e,$e4,$3a,$91,$e8,$40
 .byte $98,$f1,$4a,$a4,$fe,$59,$b4,$10,$6c,$c9,$26,$84,$e2,$41,$a0,$00
 .byte $60,$c1,$22,$84,$e6,$49,$ac,$10,$74,$d9,$3e,$a4,$0a,$71,$d8,$40
 .byte $a8,$11,$7a,$e4,$4e,$b9,$24,$90,$fc,$69,$d6,$44,$b2,$21,$90,$00
 .byte $70,$e1,$52,$c4,$36,$a9,$1c,$90,$04,$79,$ee,$64,$da,$51,$c8,$40
 .byte $b8,$31,$aa,$24,$9e,$19,$94,$10,$8c,$09,$86,$04,$82,$01,$80,$00
qs_diff_hi:
 .byte $3f,$3f,$3e,$3e,$3d,$3d,$3c,$3c,$3b,$3b,$3a,$3a,$39,$39,$38,$38
 .byte $37,$37,$36,$36,$35,$35,$35,$34,$34,$33,$33,$32,$32,$31,$31,$31
 .byte $30,$30,$2f,$2f,$2e,$2e,$2d,$2d,$2d,$2c,$2c,$2b,$2b,$2b,$2a,$2a
 .byte $29,$29,$29,$28,$28,$27,$27,$27,$26,$26,$25,$25,$25,$24,$24,$24
 .byte $23,$23,$22,$22,$22,$21,$21,$21,$20,$20,$1f,$1f,$1f,$1e,$1e,$1e
 .byte $1d,$1d,$1d,$1c,$1c,$1c,$1b,$1b,$1b,$1a,$1a,$1a,$19,$19,$19,$19
 .byte $18,$18,$18,$17,$17,$17,$16,$16,$16,$15,$15,$15,$15,$14,$14,$14
 .byte $13,$13,$13,$13,$12,$12,$12,$12,$11,$11,$11,$11,$10,$10,$10,$10
 .byte $0f,$0f,$0f,$0f,$0e,$0e,$0e,$0e,$0d,$0d,$0d,$0d,$0c,$0c,$0c,$0c
 .byte $0c,$0b,$0b,$0b,$0b,$0a,$0a,$0a,$0a,$0a,$09,$09,$09,$09,$09,$09
 .byte $08,$08,$08,$08,$08,$07,$07,$07,$07,$07,$07,$06,$06,$06,$06,$06
 .byte $06,$05,$05,$05,$05,$05,$05,$05,$04,$04,$04,$04,$04,$04,$04,$04
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$03,$03,$03,$03,$03,$03,$03,$03,$04
 .byte $04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$05,$06,$06
 .byte $06,$06,$06,$06,$07,$07,$07,$07,$07,$07,$08,$08,$08,$08,$08,$09
 .byte $09,$09,$09,$09,$09,$0a,$0a,$0a,$0a,$0a,$0b,$0b,$0b,$0b,$0c,$0c
 .byte $0c,$0c,$0c,$0d,$0d,$0d,$0d,$0e,$0e,$0e,$0e,$0f,$0f,$0f,$0f,$10
 .byte $10,$10,$10,$11,$11,$11,$11,$12,$12,$12,$12,$13,$13,$13,$13,$14
 .byte $14,$14,$15,$15,$15,$15,$16,$16,$16,$17,$17,$17,$18,$18,$18,$19
 .byte $19,$19,$19,$1a,$1a,$1a,$1b,$1b,$1b,$1c,$1c,$1c,$1d,$1d,$1d,$1e
 .byte $1e,$1e,$1f,$1f,$1f,$20,$20,$21,$21,$21,$22,$22,$22,$23,$23,$24
 .byte $24,$24,$25,$25,$25,$26,$26,$27,$27,$27,$28,$28,$29,$29,$29,$2a
 .byte $2a,$2b,$2b,$2b,$2c,$2c,$2d,$2d,$2d,$2e,$2e,$2f,$2f,$30,$30,$31
 .byte $31,$31,$32,$32,$33,$33,$34,$34,$35,$35,$35,$36,$36,$37,$37,$38
 .byte $38,$39,$39,$3a,$3a,$3b,$3b,$3c,$3c,$3d,$3d,$3e,$3e,$3f,$3f,$40
gl_lo:
 .byte $00,$73,$e3,$51,$bc,$25,$8b,$ef,$50,$af,$0b,$64,$bb,$0f,$60,$af
 .byte $fb,$44,$8a,$ce,$0f,$4e,$89,$c2,$f8,$2c,$5c,$8a,$b5,$dd,$03,$25
 .byte $45,$62,$7c,$93,$a7,$b9,$c8,$d3,$dc,$e3,$e6,$e6,$e4,$df,$d7,$cc
 .byte $be,$ae,$9a,$84,$6b,$4f,$30,$0e,$ea,$c3,$99,$6c,$3c,$0a,$d5,$9d
 .byte $62,$25,$e4,$a1,$5c,$13,$c8,$7a,$2a,$d7,$81,$29,$ce,$70,$10,$ad
 .byte $48,$e0,$75,$08,$99,$27,$b2,$3b,$c2,$46,$c8,$47,$c4,$3f,$b7,$2d
 .byte $a1,$13,$82,$ef,$5a,$c3,$29,$8e,$f0,$50,$ae,$0b,$65,$bd,$13,$68
 .byte $ba,$0a,$59,$a6,$f1,$3a,$82,$c8,$0c,$4e,$8f,$ce,$0c,$48,$83,$bc
 .byte $f3,$2a,$5e,$92,$c4,$f5,$24,$53,$80,$ac,$d7,$00,$29,$50,$77,$9d
 .byte $c1,$e5,$08,$2a,$4b,$6b,$8b,$aa,$c8,$e6,$03,$1f,$3b,$56,$71,$8b
 .byte $a5,$bf,$d8,$f1,$0a,$23,$3b,$53,$6b,$83,$9b,$b3,$ca,$e2,$fa,$12
 .byte $2b,$43,$5c,$75,$8e,$a7,$c1,$dc,$f6,$11,$2d,$49,$66,$83,$a1,$c0
 .byte $e0,$00,$21,$42,$65,$88,$ac,$d2,$f8,$1f,$47,$71,$9b,$c7,$f3,$21
 .byte $51,$81,$b3,$e6,$1a,$50,$87,$c0,$fa,$35,$72,$b1,$f1,$33,$77,$bc
 .byte $03,$4c,$96,$e2,$30,$80,$d2,$26,$7b,$d3,$2c,$88,$e5,$45,$a7,$0a
 .byte $70,$d8,$42,$af,$1d,$8e,$01,$76,$ee,$68,$e4,$63,$e4,$67,$ed,$75
gl_hi:
 .byte $40,$40,$40,$41,$41,$42,$42,$42,$43,$43,$44,$44,$44,$45,$45,$45
 .byte $45,$46,$46,$46,$47,$47,$47,$47,$47,$48,$48,$48,$48,$48,$49,$49
 .byte $49,$49,$49,$49,$49,$49,$49,$49,$49,$49,$49,$49,$49,$49,$49,$49
 .byte $49,$49,$49,$49,$49,$49,$49,$49,$48,$48,$48,$48,$48,$48,$47,$47
 .byte $47,$47,$46,$46,$46,$46,$45,$45,$45,$44,$44,$44,$43,$43,$43,$42
 .byte $42,$41,$41,$41,$40,$40,$3f,$3f,$3e,$3e,$3d,$3d,$3c,$3c,$3b,$3b
 .byte $3a,$3a,$39,$38,$38,$37,$37,$36,$35,$35,$34,$34,$33,$32,$32,$31
 .byte $30,$30,$2f,$2e,$2d,$2d,$2c,$2b,$2b,$2a,$29,$28,$28,$27,$26,$25
 .byte $24,$24,$23,$22,$21,$20,$20,$1f,$1e,$1d,$1c,$1c,$1b,$1a,$19,$18
 .byte $17,$16,$16,$15,$14,$13,$12,$11,$10,$0f,$0f,$0e,$0d,$0c,$0b,$0a
 .byte $09,$08,$07,$06,$06,$05,$04,$03,$02,$01,$00,$ff,$fe,$fd,$fc,$fc
 .byte $fb,$fa,$f9,$f8,$f7,$f6,$f5,$f4,$f3,$f3,$f2,$f1,$f0,$ef,$ee,$ed
 .byte $ec,$ec,$eb,$ea,$e9,$e8,$e7,$e6,$e5,$e5,$e4,$e3,$e2,$e1,$e0,$e0
 .byte $df,$de,$dd,$dc,$dc,$db,$da,$d9,$d8,$d8,$d7,$d6,$d5,$d5,$d4,$d3
 .byte $d3,$d2,$d1,$d0,$d0,$cf,$ce,$ce,$cd,$cc,$cc,$cb,$ca,$ca,$c9,$c9
 .byte $c8,$c7,$c7,$c6,$c6,$c5,$c5,$c4,$c3,$c3,$c2,$c2,$c1,$c1,$c0,$c0
*=$9e00
pair_left:
 .byte $f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$c0,$f0,$f0,$f0,$f0,$f0,$f0,$f0
 .byte $c0,$c0,$f0,$f0,$f0,$f0,$f0,$f0,$c0,$c0,$c0,$f0,$f0,$f0,$f0,$f0
 .byte $c0,$c0,$c0,$c0,$f0,$f0,$f0,$f0,$c0,$c0,$c0,$c0,$c0,$f0,$f0,$f0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$f0,$f0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$f0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$30,$f0,$f0,$f0,$f0,$f0,$f0,$f0
 .byte $00,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$00,$c0,$f0,$f0,$f0,$f0,$f0,$f0
 .byte $00,$c0,$c0,$f0,$f0,$f0,$f0,$f0,$00,$c0,$c0,$c0,$f0,$f0,$f0,$f0
 .byte $00,$c0,$c0,$c0,$c0,$f0,$f0,$f0,$00,$c0,$c0,$c0,$c0,$c0,$f0,$f0
 .byte $00,$c0,$c0,$c0,$c0,$c0,$c0,$f0,$00,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $30,$30,$f0,$f0,$f0,$f0,$f0,$f0,$00,$30,$f0,$f0,$f0,$f0,$f0,$f0
 .byte $00,$00,$f0,$f0,$f0,$f0,$f0,$f0,$00,$00,$c0,$f0,$f0,$f0,$f0,$f0
 .byte $00,$00,$c0,$c0,$f0,$f0,$f0,$f0,$00,$00,$c0,$c0,$c0,$f0,$f0,$f0
 .byte $00,$00,$c0,$c0,$c0,$c0,$f0,$f0,$00,$00,$c0,$c0,$c0,$c0,$c0,$f0
 .byte $00,$00,$c0,$c0,$c0,$c0,$c0,$c0,$30,$30,$30,$f0,$f0,$f0,$f0,$f0
 .byte $00,$30,$30,$f0,$f0,$f0,$f0,$f0,$00,$00,$30,$f0,$f0,$f0,$f0,$f0
 .byte $00,$00,$00,$f0,$f0,$f0,$f0,$f0,$00,$00,$00,$c0,$f0,$f0,$f0,$f0
 .byte $00,$00,$00,$c0,$c0,$f0,$f0,$f0,$00,$00,$00,$c0,$c0,$c0,$f0,$f0
 .byte $00,$00,$00,$c0,$c0,$c0,$c0,$f0,$00,$00,$00,$c0,$c0,$c0,$c0,$c0
 .byte $30,$30,$30,$30,$f0,$f0,$f0,$f0,$00,$30,$30,$30,$f0,$f0,$f0,$f0
 .byte $00,$00,$30,$30,$f0,$f0,$f0,$f0,$00,$00,$00,$30,$f0,$f0,$f0,$f0
 .byte $00,$00,$00,$00,$f0,$f0,$f0,$f0,$00,$00,$00,$00,$c0,$f0,$f0,$f0
 .byte $00,$00,$00,$00,$c0,$c0,$f0,$f0,$00,$00,$00,$00,$c0,$c0,$c0,$f0
 .byte $00,$00,$00,$00,$c0,$c0,$c0,$c0,$30,$30,$30,$30,$30,$f0,$f0,$f0
 .byte $00,$30,$30,$30,$30,$f0,$f0,$f0,$00,$00,$30,$30,$30,$f0,$f0,$f0
 .byte $00,$00,$00,$30,$30,$f0,$f0,$f0,$00,$00,$00,$00,$30,$f0,$f0,$f0
 .byte $00,$00,$00,$00,$00,$f0,$f0,$f0,$00,$00,$00,$00,$00,$c0,$f0,$f0
 .byte $00,$00,$00,$00,$00,$c0,$c0,$f0,$00,$00,$00,$00,$00,$c0,$c0,$c0
 .byte $30,$30,$30,$30,$30,$30,$f0,$f0,$00,$30,$30,$30,$30,$30,$f0,$f0
 .byte $00,$00,$30,$30,$30,$30,$f0,$f0,$00,$00,$00,$30,$30,$30,$f0,$f0
 .byte $00,$00,$00,$00,$30,$30,$f0,$f0,$00,$00,$00,$00,$00,$30,$f0,$f0
 .byte $00,$00,$00,$00,$00,$00,$f0,$f0,$00,$00,$00,$00,$00,$00,$c0,$f0
 .byte $00,$00,$00,$00,$00,$00,$c0,$c0,$30,$30,$30,$30,$30,$30,$30,$f0
 .byte $00,$30,$30,$30,$30,$30,$30,$f0,$00,$00,$30,$30,$30,$30,$30,$f0
 .byte $00,$00,$00,$30,$30,$30,$30,$f0,$00,$00,$00,$00,$30,$30,$30,$f0
 .byte $00,$00,$00,$00,$00,$30,$30,$f0,$00,$00,$00,$00,$00,$00,$30,$f0
 .byte $00,$00,$00,$00,$00,$00,$00,$f0,$00,$00,$00,$00,$00,$00,$00,$c0
 .byte $30,$30,$30,$30,$30,$30,$30,$30,$00,$30,$30,$30,$30,$30,$30,$30
 .byte $00,$00,$30,$30,$30,$30,$30,$30,$00,$00,$00,$30,$30,$30,$30,$30
 .byte $00,$00,$00,$00,$30,$30,$30,$30,$00,$00,$00,$00,$00,$30,$30,$30
 .byte $00,$00,$00,$00,$00,$00,$30,$30,$00,$00,$00,$00,$00,$00,$00,$30
 .byte $00,$00,$00,$00,$00,$00,$00,$00
pair_left_lo:
 .byte <(pair_left+0),<(pair_left+8),<(pair_left+16),<(pair_left+24),<(pair_left+32),<(pair_left+40),<(pair_left+48),<(pair_left+56),<(pair_left+64),<(pair_left+72),<(pair_left+80),<(pair_left+88),<(pair_left+96),<(pair_left+104),<(pair_left+112),<(pair_left+120),<(pair_left+128),<(pair_left+136),<(pair_left+144),<(pair_left+152),<(pair_left+160),<(pair_left+168),<(pair_left+176),<(pair_left+184),<(pair_left+192),<(pair_left+200),<(pair_left+208),<(pair_left+216),<(pair_left+224),<(pair_left+232),<(pair_left+240),<(pair_left+248),<(pair_left+256),<(pair_left+264),<(pair_left+272),<(pair_left+280),<(pair_left+288),<(pair_left+296),<(pair_left+304),<(pair_left+312),<(pair_left+320),<(pair_left+328),<(pair_left+336),<(pair_left+344),<(pair_left+352),<(pair_left+360),<(pair_left+368),<(pair_left+376),<(pair_left+384),<(pair_left+392),<(pair_left+400),<(pair_left+408),<(pair_left+416),<(pair_left+424),<(pair_left+432),<(pair_left+440),<(pair_left+448),<(pair_left+456),<(pair_left+464),<(pair_left+472),<(pair_left+480),<(pair_left+488),<(pair_left+496),<(pair_left+504),<(pair_left+512),<(pair_left+520),<(pair_left+528),<(pair_left+536),<(pair_left+544),<(pair_left+552),<(pair_left+560),<(pair_left+568),<(pair_left+576),<(pair_left+584),<(pair_left+592),<(pair_left+600),<(pair_left+608),<(pair_left+616),<(pair_left+624),<(pair_left+632),<(pair_left+640)
pair_left_hi:
 .byte >(pair_left+0),>(pair_left+8),>(pair_left+16),>(pair_left+24),>(pair_left+32),>(pair_left+40),>(pair_left+48),>(pair_left+56),>(pair_left+64),>(pair_left+72),>(pair_left+80),>(pair_left+88),>(pair_left+96),>(pair_left+104),>(pair_left+112),>(pair_left+120),>(pair_left+128),>(pair_left+136),>(pair_left+144),>(pair_left+152),>(pair_left+160),>(pair_left+168),>(pair_left+176),>(pair_left+184),>(pair_left+192),>(pair_left+200),>(pair_left+208),>(pair_left+216),>(pair_left+224),>(pair_left+232),>(pair_left+240),>(pair_left+248),>(pair_left+256),>(pair_left+264),>(pair_left+272),>(pair_left+280),>(pair_left+288),>(pair_left+296),>(pair_left+304),>(pair_left+312),>(pair_left+320),>(pair_left+328),>(pair_left+336),>(pair_left+344),>(pair_left+352),>(pair_left+360),>(pair_left+368),>(pair_left+376),>(pair_left+384),>(pair_left+392),>(pair_left+400),>(pair_left+408),>(pair_left+416),>(pair_left+424),>(pair_left+432),>(pair_left+440),>(pair_left+448),>(pair_left+456),>(pair_left+464),>(pair_left+472),>(pair_left+480),>(pair_left+488),>(pair_left+496),>(pair_left+504),>(pair_left+512),>(pair_left+520),>(pair_left+528),>(pair_left+536),>(pair_left+544),>(pair_left+552),>(pair_left+560),>(pair_left+568),>(pair_left+576),>(pair_left+584),>(pair_left+592),>(pair_left+600),>(pair_left+608),>(pair_left+616),>(pair_left+624),>(pair_left+632),>(pair_left+640)
pair_right:
 .byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0c,$0f,$0f,$0f,$0f,$0f,$0f,$0f
 .byte $0c,$0c,$0f,$0f,$0f,$0f,$0f,$0f,$0c,$0c,$0c,$0f,$0f,$0f,$0f,$0f
 .byte $0c,$0c,$0c,$0c,$0f,$0f,$0f,$0f,$0c,$0c,$0c,$0c,$0c,$0f,$0f,$0f
 .byte $0c,$0c,$0c,$0c,$0c,$0c,$0f,$0f,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0f
 .byte $0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$03,$0f,$0f,$0f,$0f,$0f,$0f,$0f
 .byte $00,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$00,$0c,$0f,$0f,$0f,$0f,$0f,$0f
 .byte $00,$0c,$0c,$0f,$0f,$0f,$0f,$0f,$00,$0c,$0c,$0c,$0f,$0f,$0f,$0f
 .byte $00,$0c,$0c,$0c,$0c,$0f,$0f,$0f,$00,$0c,$0c,$0c,$0c,$0c,$0f,$0f
 .byte $00,$0c,$0c,$0c,$0c,$0c,$0c,$0f,$00,$0c,$0c,$0c,$0c,$0c,$0c,$0c
 .byte $03,$03,$0f,$0f,$0f,$0f,$0f,$0f,$00,$03,$0f,$0f,$0f,$0f,$0f,$0f
 .byte $00,$00,$0f,$0f,$0f,$0f,$0f,$0f,$00,$00,$0c,$0f,$0f,$0f,$0f,$0f
 .byte $00,$00,$0c,$0c,$0f,$0f,$0f,$0f,$00,$00,$0c,$0c,$0c,$0f,$0f,$0f
 .byte $00,$00,$0c,$0c,$0c,$0c,$0f,$0f,$00,$00,$0c,$0c,$0c,$0c,$0c,$0f
 .byte $00,$00,$0c,$0c,$0c,$0c,$0c,$0c,$03,$03,$03,$0f,$0f,$0f,$0f,$0f
 .byte $00,$03,$03,$0f,$0f,$0f,$0f,$0f,$00,$00,$03,$0f,$0f,$0f,$0f,$0f
 .byte $00,$00,$00,$0f,$0f,$0f,$0f,$0f,$00,$00,$00,$0c,$0f,$0f,$0f,$0f
 .byte $00,$00,$00,$0c,$0c,$0f,$0f,$0f,$00,$00,$00,$0c,$0c,$0c,$0f,$0f
 .byte $00,$00,$00,$0c,$0c,$0c,$0c,$0f,$00,$00,$00,$0c,$0c,$0c,$0c,$0c
 .byte $03,$03,$03,$03,$0f,$0f,$0f,$0f,$00,$03,$03,$03,$0f,$0f,$0f,$0f
 .byte $00,$00,$03,$03,$0f,$0f,$0f,$0f,$00,$00,$00,$03,$0f,$0f,$0f,$0f
 .byte $00,$00,$00,$00,$0f,$0f,$0f,$0f,$00,$00,$00,$00,$0c,$0f,$0f,$0f
 .byte $00,$00,$00,$00,$0c,$0c,$0f,$0f,$00,$00,$00,$00,$0c,$0c,$0c,$0f
 .byte $00,$00,$00,$00,$0c,$0c,$0c,$0c,$03,$03,$03,$03,$03,$0f,$0f,$0f
 .byte $00,$03,$03,$03,$03,$0f,$0f,$0f,$00,$00,$03,$03,$03,$0f,$0f,$0f
 .byte $00,$00,$00,$03,$03,$0f,$0f,$0f,$00,$00,$00,$00,$03,$0f,$0f,$0f
 .byte $00,$00,$00,$00,$00,$0f,$0f,$0f,$00,$00,$00,$00,$00,$0c,$0f,$0f
 .byte $00,$00,$00,$00,$00,$0c,$0c,$0f,$00,$00,$00,$00,$00,$0c,$0c,$0c
 .byte $03,$03,$03,$03,$03,$03,$0f,$0f,$00,$03,$03,$03,$03,$03,$0f,$0f
 .byte $00,$00,$03,$03,$03,$03,$0f,$0f,$00,$00,$00,$03,$03,$03,$0f,$0f
 .byte $00,$00,$00,$00,$03,$03,$0f,$0f,$00,$00,$00,$00,$00,$03,$0f,$0f
 .byte $00,$00,$00,$00,$00,$00,$0f,$0f,$00,$00,$00,$00,$00,$00,$0c,$0f
 .byte $00,$00,$00,$00,$00,$00,$0c,$0c,$03,$03,$03,$03,$03,$03,$03,$0f
 .byte $00,$03,$03,$03,$03,$03,$03,$0f,$00,$00,$03,$03,$03,$03,$03,$0f
 .byte $00,$00,$00,$03,$03,$03,$03,$0f,$00,$00,$00,$00,$03,$03,$03,$0f
 .byte $00,$00,$00,$00,$00,$03,$03,$0f,$00,$00,$00,$00,$00,$00,$03,$0f
 .byte $00,$00,$00,$00,$00,$00,$00,$0f,$00,$00,$00,$00,$00,$00,$00,$0c
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$00,$03,$03,$03,$03,$03,$03,$03
 .byte $00,$00,$03,$03,$03,$03,$03,$03,$00,$00,$00,$03,$03,$03,$03,$03
 .byte $00,$00,$00,$00,$03,$03,$03,$03,$00,$00,$00,$00,$00,$03,$03,$03
 .byte $00,$00,$00,$00,$00,$00,$03,$03,$00,$00,$00,$00,$00,$00,$00,$03
 .byte $00,$00,$00,$00,$00,$00,$00,$00
pair_right_lo:
 .byte <(pair_right+0),<(pair_right+8),<(pair_right+16),<(pair_right+24),<(pair_right+32),<(pair_right+40),<(pair_right+48),<(pair_right+56),<(pair_right+64),<(pair_right+72),<(pair_right+80),<(pair_right+88),<(pair_right+96),<(pair_right+104),<(pair_right+112),<(pair_right+120),<(pair_right+128),<(pair_right+136),<(pair_right+144),<(pair_right+152),<(pair_right+160),<(pair_right+168),<(pair_right+176),<(pair_right+184),<(pair_right+192),<(pair_right+200),<(pair_right+208),<(pair_right+216),<(pair_right+224),<(pair_right+232),<(pair_right+240),<(pair_right+248),<(pair_right+256),<(pair_right+264),<(pair_right+272),<(pair_right+280),<(pair_right+288),<(pair_right+296),<(pair_right+304),<(pair_right+312),<(pair_right+320),<(pair_right+328),<(pair_right+336),<(pair_right+344),<(pair_right+352),<(pair_right+360),<(pair_right+368),<(pair_right+376),<(pair_right+384),<(pair_right+392),<(pair_right+400),<(pair_right+408),<(pair_right+416),<(pair_right+424),<(pair_right+432),<(pair_right+440),<(pair_right+448),<(pair_right+456),<(pair_right+464),<(pair_right+472),<(pair_right+480),<(pair_right+488),<(pair_right+496),<(pair_right+504),<(pair_right+512),<(pair_right+520),<(pair_right+528),<(pair_right+536),<(pair_right+544),<(pair_right+552),<(pair_right+560),<(pair_right+568),<(pair_right+576),<(pair_right+584),<(pair_right+592),<(pair_right+600),<(pair_right+608),<(pair_right+616),<(pair_right+624),<(pair_right+632),<(pair_right+640)
pair_right_hi:
 .byte >(pair_right+0),>(pair_right+8),>(pair_right+16),>(pair_right+24),>(pair_right+32),>(pair_right+40),>(pair_right+48),>(pair_right+56),>(pair_right+64),>(pair_right+72),>(pair_right+80),>(pair_right+88),>(pair_right+96),>(pair_right+104),>(pair_right+112),>(pair_right+120),>(pair_right+128),>(pair_right+136),>(pair_right+144),>(pair_right+152),>(pair_right+160),>(pair_right+168),>(pair_right+176),>(pair_right+184),>(pair_right+192),>(pair_right+200),>(pair_right+208),>(pair_right+216),>(pair_right+224),>(pair_right+232),>(pair_right+240),>(pair_right+248),>(pair_right+256),>(pair_right+264),>(pair_right+272),>(pair_right+280),>(pair_right+288),>(pair_right+296),>(pair_right+304),>(pair_right+312),>(pair_right+320),>(pair_right+328),>(pair_right+336),>(pair_right+344),>(pair_right+352),>(pair_right+360),>(pair_right+368),>(pair_right+376),>(pair_right+384),>(pair_right+392),>(pair_right+400),>(pair_right+408),>(pair_right+416),>(pair_right+424),>(pair_right+432),>(pair_right+440),>(pair_right+448),>(pair_right+456),>(pair_right+464),>(pair_right+472),>(pair_right+480),>(pair_right+488),>(pair_right+496),>(pair_right+504),>(pair_right+512),>(pair_right+520),>(pair_right+528),>(pair_right+536),>(pair_right+544),>(pair_right+552),>(pair_right+560),>(pair_right+568),>(pair_right+576),>(pair_right+584),>(pair_right+592),>(pair_right+600),>(pair_right+608),>(pair_right+616),>(pair_right+624),>(pair_right+632),>(pair_right+640)
mask_end:
.cerror mask_end>$a500,"masks overflow"
*=$a500
fine_initial_columns:
 .byte $44,$11,$44,$11,$44,$11,$44,$11,$44,$11,$44,$11,$44,$11,$44,$11
 .byte $44,$11,$44,$11,$44,$11,$44,$11,$44,$11,$44,$11,$44,$11,$44,$11
 .byte $44,$11,$44,$11,$44,$11,$44,$11,$44,$11,$44,$11,$44,$11,$44,$11
 .byte $44,$11,$44,$11,$44,$11,$44,$11,$44,$11,$44,$11,$44,$11,$44,$11
 .byte $44,$11,$44,$11,$44,$11,$44,$11,$55,$55,$55,$55,$55,$55,$55,$55
 .byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
 .byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
 .byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
 .byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
*=$a800
event_floor:
 .byte $00,$00,$02,$04,$06,$08,$00,$0b,$02,$0e,$10,$12,$14,$16,$16,$19
 .byte $1b,$1d,$1f,$20,$21,$23,$25,$27,$29,$20,$2c,$23,$2f,$27,$32,$34
 .byte $36,$36,$39,$3b,$3d,$0b,$0e,$41,$43,$00,$0b,$02,$0e,$41,$46,$43
 .byte $19,$16,$19,$4a,$4b,$4c,$4e,$2c,$51,$2f,$54,$34,$20,$2c,$23,$2f
 .byte $57,$51,$5a,$39,$36,$39,$32,$5d,$5f,$61,$61,$64,$66,$68,$68,$6a
 .byte $6c,$6c,$6e,$70,$72,$74,$74,$77,$79,$7b,$7d,$7f,$81,$81,$61,$64
 .byte $64,$85,$87,$89,$89,$8a,$8b,$8d,$8f,$8f,$90,$74,$77,$77,$93,$7b
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
event_ceiling:
 .byte $00,$01,$03,$05,$07,$09,$01,$0c,$03,$0f,$11,$13,$15,$17,$17,$1a
 .byte $1c,$1e,$1e,$1c,$22,$24,$26,$28,$2a,$1c,$2d,$24,$30,$31,$33,$35
 .byte $37,$37,$3a,$3c,$3e,$3f,$40,$42,$44,$0a,$3f,$0d,$40,$45,$47,$48
 .byte $49,$18,$49,$28,$28,$4d,$4f,$50,$52,$53,$55,$56,$2b,$50,$2e,$53
 .byte $58,$59,$5b,$1e,$38,$1e,$5c,$5e,$60,$62,$62,$65,$67,$69,$69,$6b
 .byte $6d,$6d,$6f,$71,$73,$75,$75,$78,$7a,$7c,$7e,$80,$82,$83,$63,$84
 .byte $84,$86,$88,$6b,$6b,$6d,$8c,$8e,$71,$71,$91,$76,$92,$92,$94,$95
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
event_riser:
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
event_header:
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$0a,$ff,$0d,$ff,$ff,$ff,$ff,$ff,$18,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$2b,$ff,$2e,$ff,$ff,$ff,$ff
 .byte $ff,$38,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0c,$ff,$0f,$ff,$ff,$ff
 .byte $ff,$ff,$1a,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$2d,$ff,$30
 .byte $ff,$ff,$ff,$ff,$ff,$3a,$ff,$ff,$ff,$ff,$63,$ff,$ff,$ff,$ff,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$76,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $65,$ff,$69,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$78,$ff,$ff
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
event_flags:
 .byte $01,$01,$01,$01,$01,$01,$04,$00,$04,$00,$01,$01,$01,$01,$04,$00
 .byte $21,$01,$21,$01,$01,$01,$01,$01,$01,$04,$00,$04,$00,$01,$01,$01
 .byte $01,$04,$00,$01,$01,$01,$01,$01,$01,$00,$04,$00,$04,$01,$01,$01
 .byte $01,$00,$04,$21,$01,$21,$01,$01,$01,$01,$01,$01,$00,$04,$00,$04
 .byte $01,$01,$01,$01,$00,$04,$01,$11,$11,$11,$14,$10,$11,$11,$10,$30
 .byte $11,$10,$11,$30,$11,$11,$14,$10,$11,$11,$11,$11,$11,$11,$10,$11
 .byte $14,$11,$34,$10,$11,$30,$11,$11,$11,$10,$11,$10,$11,$14,$11,$11
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
key_plane:
 .byte $0a,$0a,$15,$15,$1e,$1e,$04,$04,$18,$18,$0a,$0b,$0b,$15,$16,$16
 .byte $08,$08,$13,$13,$1c,$1c,$0c,$0c,$0c,$0d,$0d,$0b,$0b,$11,$11,$11
 .byte $0b,$0d,$0d,$17,$17,$1e,$1e,$08,$08,$1c,$1c,$0b,$0c,$0c,$17,$18
 .byte $18,$08,$15,$15,$1d,$1d,$10,$10,$10,$11,$11,$14,$14,$02,$02,$0b
 .byte $16,$05,$05,$19,$19,$05,$10,$10,$19,$0d,$08,$08,$0e,$0e,$02,$02
 .byte $0c,$12,$12,$18,$09,$09,$1d,$05,$05,$12,$1a,$1a,$15,$42,$42,$45
 .byte $45,$46,$46,$46,$47,$47,$4a,$4a,$4b,$4b,$4f,$4f,$52,$52,$54,$54
 .byte $56,$56,$59,$59,$5a,$5a,$5a,$5b,$5b,$5d,$5d,$5e,$5e,$5f,$5f,$41
 .byte $41,$43,$43,$43,$47,$48,$48,$4b,$4b,$4f,$52,$53,$53,$55,$55,$56
 .byte $57,$57,$5b,$5c,$5c,$5e,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
key_alt:
 .byte $00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$50,$00,$50,$50,$00,$50
 .byte $00,$50,$00,$50,$00,$50,$00,$80,$50,$00,$50,$ff,$c0,$20,$c0,$fe
 .byte $40,$40,$c0,$40,$c0,$40,$c0,$40,$c0,$40,$c0,$90,$40,$90,$90,$40
 .byte $90,$90,$40,$90,$40,$90,$40,$c0,$90,$40,$90,$40,$c0,$00,$80,$80
 .byte $80,$00,$80,$00,$80,$50,$00,$50,$50,$80,$ff,$20,$fe,$c0,$40,$c0
 .byte $c0,$40,$c0,$c0,$40,$c0,$c0,$40,$90,$90,$40,$90,$c0,$00,$80,$00
 .byte $50,$00,$80,$50,$00,$50,$00,$50,$00,$80,$ff,$c0,$20,$c0,$40,$c0
 .byte $fe,$c0,$40,$90,$40,$c0,$90,$40,$90,$40,$c0,$40,$90,$40,$c0,$00
 .byte $80,$00,$80,$50,$80,$00,$50,$ff,$c0,$20,$fe,$40,$c0,$40,$c0,$40
 .byte $40,$90,$c0,$40,$90,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
*=$b000
 .fill 2449,0
*=$ba00
dir_dx_lo:
 .byte $ff,$7d,$bf,$2b,$61,$4f,$98,$a8,$34,$13,$2b,$6e,$d1,$4c,$d9,$77
 .byte $20,$d4,$90,$54,$1e,$ec,$c0,$97,$72,$50,$30,$13,$f8,$df,$c7,$b1
 .byte $9d,$8a,$78,$67,$57,$48,$39,$2c,$1f,$13,$07,$fc,$f2,$e8,$df,$d5
 .byte $cd,$c5,$bd,$b5,$ae,$a7,$a0,$9a,$94,$8e,$88,$82,$7d,$78,$73,$6f
 .byte $6a,$66,$61,$5d,$5a,$56,$52,$4f,$4b,$48,$45,$42,$3f,$3c,$39,$36
 .byte $34,$31,$2f,$2d,$2a,$28,$26,$24,$22,$20,$1f,$1d,$1b,$1a,$18,$17
 .byte $15,$14,$12,$11,$10,$0f,$0e,$0d,$0c,$0b,$0a,$09,$08,$07,$06,$06
 .byte $05,$04,$04,$03,$03,$02,$02,$02,$01,$01,$01,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$04,$04
 .byte $05,$06,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$10,$11,$12,$14
 .byte $15,$17,$18,$1a,$1b,$1d,$1f,$20,$22,$24,$26,$28,$2a,$2d,$2f,$31
 .byte $34,$36,$39,$3c,$3f,$42,$45,$48,$4b,$4f,$52,$56,$5a,$5d,$61,$66
 .byte $6a,$6f,$73,$78,$7d,$82,$88,$8e,$94,$9a,$a0,$a7,$ae,$b5,$bd,$c5
 .byte $cd,$d5,$df,$e8,$f2,$fc,$07,$13,$1f,$2c,$39,$48,$57,$67,$78,$8a
 .byte $9d,$b1,$c7,$df,$f8,$13,$30,$50,$72,$97,$c0,$ec,$1e,$54,$90,$d4
 .byte $20,$77,$d9,$4c,$d1,$6e,$2b,$13,$34,$a8,$98,$4f,$61,$2b,$bf,$7d
 .byte $ff,$7d,$bf,$2b,$61,$4f,$98,$a8,$34,$13,$2b,$6e,$d1,$4c,$d9,$77
 .byte $20,$d4,$90,$54,$1e,$ec,$c0,$97,$72,$50,$30,$13,$f8,$df,$c7,$b1
 .byte $9d,$8a,$78,$67,$57,$48,$39,$2c,$1f,$13,$07,$fc,$f2,$e8,$df,$d5
 .byte $cd,$c5,$bd,$b5,$ae,$a7,$a0,$9a,$94,$8e,$88,$82,$7d,$78,$73,$6f
 .byte $6a,$66,$61,$5d,$5a,$56,$52,$4f,$4b,$48,$45,$42,$3f,$3c,$39,$36
 .byte $34,$31,$2f,$2d,$2a,$28,$26,$24,$22,$20,$1f,$1d,$1b,$1a,$18,$17
 .byte $15,$14,$12,$11,$10,$0f,$0e,$0d,$0c,$0b,$0a,$09,$08,$07,$06,$06
 .byte $05,$04,$04,$03,$03,$02,$02,$02,$01,$01,$01,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$04,$04
 .byte $05,$06,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$10,$11,$12,$14
 .byte $15,$17,$18,$1a,$1b,$1d,$1f,$20,$22,$24,$26,$28,$2a,$2d,$2f,$31
 .byte $34,$36,$39,$3c,$3f,$42,$45,$48,$4b,$4f,$52,$56,$5a,$5d,$61,$66
 .byte $6a,$6f,$73,$78,$7d,$82,$88,$8e,$94,$9a,$a0,$a7,$ae,$b5,$bd,$c5
 .byte $cd,$d5,$df,$e8,$f2,$fc,$07,$13,$1f,$2c,$39,$48,$57,$67,$78,$8a
 .byte $9d,$b1,$c7,$df,$f8,$13,$30,$50,$72,$97,$c0,$ec,$1e,$54,$90,$d4
 .byte $20,$77,$d9,$4c,$d1,$6e,$2b,$13,$34,$a8,$98,$4f,$61,$2b,$bf,$7d
dir_dx_hi:
 .byte $ff,$51,$28,$1b,$14,$10,$0d,$0b,$0a,$09,$08,$07,$06,$06,$05,$05
 .byte $05,$04,$04,$04,$04,$03,$03,$03,$03,$03,$03,$03,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$03,$03,$03,$03,$03,$03,$03,$04,$04,$04,$04
 .byte $05,$05,$05,$06,$06,$07,$08,$09,$0a,$0b,$0d,$10,$14,$1b,$28,$51
 .byte $ff,$51,$28,$1b,$14,$10,$0d,$0b,$0a,$09,$08,$07,$06,$06,$05,$05
 .byte $05,$04,$04,$04,$04,$03,$03,$03,$03,$03,$03,$03,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$03,$03,$03,$03,$03,$03,$03,$04,$04,$04,$04
 .byte $05,$05,$05,$06,$06,$07,$08,$09,$0a,$0b,$0d,$10,$14,$1b,$28,$51
dir_dy_lo:
 .byte $00,$00,$00,$00,$00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$04,$04
 .byte $05,$06,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$10,$11,$12,$14
 .byte $15,$17,$18,$1a,$1b,$1d,$1f,$20,$22,$24,$26,$28,$2a,$2d,$2f,$31
 .byte $34,$36,$39,$3c,$3f,$42,$45,$48,$4b,$4f,$52,$56,$5a,$5d,$61,$66
 .byte $6a,$6f,$73,$78,$7d,$82,$88,$8e,$94,$9a,$a0,$a7,$ae,$b5,$bd,$c5
 .byte $cd,$d5,$df,$e8,$f2,$fc,$07,$13,$1f,$2c,$39,$48,$57,$67,$78,$8a
 .byte $9d,$b1,$c7,$df,$f8,$13,$30,$50,$72,$97,$c0,$ec,$1e,$54,$90,$d4
 .byte $20,$77,$d9,$4c,$d1,$6e,$2b,$13,$34,$a8,$98,$4f,$61,$2b,$bf,$7d
 .byte $ff,$7d,$bf,$2b,$61,$4f,$98,$a8,$34,$13,$2b,$6e,$d1,$4c,$d9,$77
 .byte $20,$d4,$90,$54,$1e,$ec,$c0,$97,$72,$50,$30,$13,$f8,$df,$c7,$b1
 .byte $9d,$8a,$78,$67,$57,$48,$39,$2c,$1f,$13,$07,$fc,$f2,$e8,$df,$d5
 .byte $cd,$c5,$bd,$b5,$ae,$a7,$a0,$9a,$94,$8e,$88,$82,$7d,$78,$73,$6f
 .byte $6a,$66,$61,$5d,$5a,$56,$52,$4f,$4b,$48,$45,$42,$3f,$3c,$39,$36
 .byte $34,$31,$2f,$2d,$2a,$28,$26,$24,$22,$20,$1f,$1d,$1b,$1a,$18,$17
 .byte $15,$14,$12,$11,$10,$0f,$0e,$0d,$0c,$0b,$0a,$09,$08,$07,$06,$06
 .byte $05,$04,$04,$03,$03,$02,$02,$02,$01,$01,$01,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$04,$04
 .byte $05,$06,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$10,$11,$12,$14
 .byte $15,$17,$18,$1a,$1b,$1d,$1f,$20,$22,$24,$26,$28,$2a,$2d,$2f,$31
 .byte $34,$36,$39,$3c,$3f,$42,$45,$48,$4b,$4f,$52,$56,$5a,$5d,$61,$66
 .byte $6a,$6f,$73,$78,$7d,$82,$88,$8e,$94,$9a,$a0,$a7,$ae,$b5,$bd,$c5
 .byte $cd,$d5,$df,$e8,$f2,$fc,$07,$13,$1f,$2c,$39,$48,$57,$67,$78,$8a
 .byte $9d,$b1,$c7,$df,$f8,$13,$30,$50,$72,$97,$c0,$ec,$1e,$54,$90,$d4
 .byte $20,$77,$d9,$4c,$d1,$6e,$2b,$13,$34,$a8,$98,$4f,$61,$2b,$bf,$7d
 .byte $ff,$7d,$bf,$2b,$61,$4f,$98,$a8,$34,$13,$2b,$6e,$d1,$4c,$d9,$77
 .byte $20,$d4,$90,$54,$1e,$ec,$c0,$97,$72,$50,$30,$13,$f8,$df,$c7,$b1
 .byte $9d,$8a,$78,$67,$57,$48,$39,$2c,$1f,$13,$07,$fc,$f2,$e8,$df,$d5
 .byte $cd,$c5,$bd,$b5,$ae,$a7,$a0,$9a,$94,$8e,$88,$82,$7d,$78,$73,$6f
 .byte $6a,$66,$61,$5d,$5a,$56,$52,$4f,$4b,$48,$45,$42,$3f,$3c,$39,$36
 .byte $34,$31,$2f,$2d,$2a,$28,$26,$24,$22,$20,$1f,$1d,$1b,$1a,$18,$17
 .byte $15,$14,$12,$11,$10,$0f,$0e,$0d,$0c,$0b,$0a,$09,$08,$07,$06,$06
 .byte $05,$04,$04,$03,$03,$02,$02,$02,$01,$01,$01,$00,$00,$00,$00,$00
dir_dy_hi:
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$03,$03,$03,$03,$03,$03,$03,$04,$04,$04,$04
 .byte $05,$05,$05,$06,$06,$07,$08,$09,$0a,$0b,$0d,$10,$14,$1b,$28,$51
 .byte $ff,$51,$28,$1b,$14,$10,$0d,$0b,$0a,$09,$08,$07,$06,$06,$05,$05
 .byte $05,$04,$04,$04,$04,$03,$03,$03,$03,$03,$03,$03,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$03,$03,$03,$03,$03,$03,$03,$04,$04,$04,$04
 .byte $05,$05,$05,$06,$06,$07,$08,$09,$0a,$0b,$0d,$10,$14,$1b,$28,$51
 .byte $ff,$51,$28,$1b,$14,$10,$0d,$0b,$0a,$09,$08,$07,$06,$06,$05,$05
 .byte $05,$04,$04,$04,$04,$03,$03,$03,$03,$03,$03,$03,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
dir_flags:
 .byte $04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $08,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $06,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $09,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
movement_x:
 .byte $00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04
 .byte $04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
 .byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$06
 .byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 .byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 .byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 .byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 .byte $06,$06,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
 .byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$04,$04,$04,$04,$04
 .byte $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe
 .byte $fe,$fe,$fe,$fe,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd
 .byte $fd,$fd,$fd,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc
 .byte $fc,$fc,$fc,$fc,$fc,$fc,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb
 .byte $fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fa
 .byte $fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa
 .byte $fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa
 .byte $fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa
 .byte $fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa
 .byte $fa,$fa,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb
 .byte $fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fc,$fc,$fc,$fc,$fc
 .byte $fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fd,$fd
 .byte $fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fe,$fe,$fe
 .byte $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00
movement_y:
 .byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 .byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 .byte $06,$06,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
 .byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$04,$04,$04,$04,$04
 .byte $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe
 .byte $fe,$fe,$fe,$fe,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd
 .byte $fd,$fd,$fd,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc
 .byte $fc,$fc,$fc,$fc,$fc,$fc,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb
 .byte $fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fa
 .byte $fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa
 .byte $fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa
 .byte $fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa
 .byte $fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa,$fa
 .byte $fa,$fa,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb
 .byte $fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fc,$fc,$fc,$fc,$fc
 .byte $fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fd,$fd
 .byte $fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fe,$fe,$fe
 .byte $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04
 .byte $04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
 .byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$06
 .byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 .byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
table_end:
.cerror table_end>$c800,"tables overflow"
*=$c800
ramp_slope_lo:
 .byte $6d,$d0,$31,$90,$ed,$48,$a0,$f7,$4b,$9d,$ed,$3a,$85,$ce,$14,$59
 .byte $9a,$da,$16,$51,$89,$c0,$f3,$24,$53,$80,$aa,$d2,$f7,$1a,$3a,$58
 .byte $74,$8d,$a3,$b7,$c8,$d8,$e5,$ef,$f6,$fc,$ff,$ff,$fd,$f9,$f2,$e8
 .byte $dc,$cf,$bd,$aa,$94,$7c,$61,$44,$25,$03,$df,$b8,$8e,$63,$35,$04
 .byte $d1,$9c,$64,$2a,$ee,$af,$6e,$2b,$e5,$9e,$53,$07,$b8,$67,$13,$be
 .byte $66,$0c,$b0,$51,$f1,$8e,$29,$c2,$59,$ee,$81,$11,$9f,$2c,$b6,$3f
 .byte $c6,$4b,$cd,$4e,$cd,$4a,$c5,$3e,$b6,$2b,$9f,$12,$82,$f0,$5d,$c9
 .byte $32,$9a,$01,$66,$c9,$2a,$8b,$ea,$47,$a3,$fd,$56,$ae,$04,$5a,$ad
 .byte $ff,$51,$a1,$f0,$3d,$8a,$d5,$20,$69,$b2,$f9,$3f,$85,$c9,$0d,$50
 .byte $92,$d3,$14,$54,$93,$d1,$0f,$4c,$88,$c4,$00,$3a,$75,$ae,$e8,$21
 .byte $5a,$93,$ca,$02,$3a,$72,$a9,$e0,$18,$4f,$86,$be,$f4,$2b,$62,$99
 .byte $d1,$08,$40,$78,$b0,$e8,$21,$5b,$93,$cd,$08,$42,$7e,$b9,$f5,$32
 .byte $70,$ae,$ed,$2c,$6d,$ad,$ef,$32,$75,$b9,$fe,$45,$8c,$d4,$1c,$67
 .byte $b2,$fe,$4c,$9a,$ea,$3b,$8d,$e0,$35,$8a,$e1,$3a,$94,$ef,$4d,$ab
 .byte $0a,$6c,$ce,$32,$98,$00,$69,$d4,$40,$af,$1e,$90,$03,$78,$ef,$67
 .byte $e2,$5e,$dd,$5d,$df,$63,$e9,$71,$fb,$87,$14,$a5,$37,$ca,$61,$f9
ramp_slope_hi:
 .byte $37,$37,$38,$38,$38,$39,$39,$39,$3a,$3a,$3a,$3b,$3b,$3b,$3c,$3c
 .byte $3c,$3c,$3d,$3d,$3d,$3d,$3d,$3e,$3e,$3e,$3e,$3e,$3e,$3f,$3f,$3f
 .byte $3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f
 .byte $3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3e,$3e,$3e,$3e,$3e,$3e
 .byte $3d,$3d,$3d,$3d,$3c,$3c,$3c,$3c,$3b,$3b,$3b,$3b,$3a,$3a,$3a,$39
 .byte $39,$39,$38,$38,$37,$37,$37,$36,$36,$35,$35,$35,$34,$34,$33,$33
 .byte $32,$32,$31,$31,$30,$30,$2f,$2f,$2e,$2e,$2d,$2d,$2c,$2b,$2b,$2a
 .byte $2a,$29,$29,$28,$27,$27,$26,$25,$25,$24,$23,$23,$22,$22,$21,$20
 .byte $1f,$1f,$1e,$1d,$1d,$1c,$1b,$1b,$1a,$19,$18,$18,$17,$16,$16,$15
 .byte $14,$13,$13,$12,$11,$10,$10,$0f,$0e,$0d,$0d,$0c,$0b,$0a,$09,$09
 .byte $08,$07,$06,$06,$05,$04,$03,$02,$02,$01,$00,$ff,$fe,$fe,$fd,$fc
 .byte $fb,$fb,$fa,$f9,$f8,$f7,$f7,$f6,$f5,$f4,$f4,$f3,$f2,$f1,$f0,$f0
 .byte $ef,$ee,$ed,$ed,$ec,$eb,$ea,$ea,$e9,$e8,$e7,$e7,$e6,$e5,$e5,$e4
 .byte $e3,$e2,$e2,$e1,$e0,$e0,$df,$de,$de,$dd,$dc,$dc,$db,$da,$da,$d9
 .byte $d9,$d8,$d7,$d7,$d6,$d6,$d5,$d4,$d4,$d3,$d3,$d2,$d2,$d1,$d0,$d0
 .byte $cf,$cf,$ce,$ce,$cd,$cd,$cc,$cc,$cb,$cb,$cb,$ca,$ca,$c9,$c9,$c8
*=$ca00
layout_support:
layout_support_end:
.cerror layout_support_end>$cb00,"Layout overlaps screen"
