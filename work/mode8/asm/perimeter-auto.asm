; Qualified standalone layout. $0200..$07ff no longer KERNAL workspace.
clamp8=$0200
times9=$0300
fx_cos=$0400
fx_negsin=$0600
door_bottom=$c600
; Engine zero-page allocation ends at $ec.
; raycast-stock autonomous 6510 backend. Copyright 2026 librologica.digital.
; PolyForm Noncommercial 1.0.0. No polygon renderer linked.
DIAGNOSTIC = 0
RAYCAST = 1
TEXTURED = 1
INITIAL_X=2688
INITIAL_Y=1408
INITIAL_ANGLE=0
AUTO_RUN=1
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
 jsr layout_copy_tables
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
 jsr raycast_layers
 jsr select_strips
.endif
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
 jsr raycast_layers
.if TEXTURED != 0
 jsr select_strips
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
compose_screen:
 lda #0
 sta col
ef_col_low=$cc
ef_col_hi=$cd
ef_fill_index=$ce
ef_background=$cf
ef_saved_row=$d0
ef_saved_shade=$d1
compose_column:
 lda #1
 sta ef_background
 lda col
 asl
 asl
 asl
 sta ef_col_low
 lda col
 lsr
 lsr
 lsr
 lsr
 lsr
 sta ef_col_hi
 tax
 lda ef_page_index,x
 ldx drawbuf
 beq ef_address_bank
 clc
 adc #44
 ldx #$80
 stx ef_col_hi
 lda col
 cmp #32
 bcc ef_bank_b_first
 inc ef_col_hi
 lda #66
 bne ef_address_bank
ef_bank_b_first:
 lda #44
ef_address_bank:
 sta ef_fill_index
 ldx col
 lda ss_flags,x
 beq ss_regular_column
 jsr ss_refine
 jsr ss_compose
 jmp compose_next_column
ss_regular_column:
 ldx col
 txa
 asl
 tay
 lda lower_side,y
 beq far_white
 lda #$aa
 bne far_set
far_white:
 lda #$ff
far_set:
 sta band_shade
 lda edge_data,x
 sta band_tl
 lda edge_data+40,x
 sta band_tr
 lda edge_data+80,x
 sta band_bl
 lda edge_data+120,x
 sta band_br
 jsr draw_band
 ldx col
 txa
 asl
 tay
 lda upper_owner,y
 beq compose_next_column
 lda upper_side,y
 beq near_white
 lda #$aa
 bne near_set
near_white:
 lda #$ff
near_set:
 sta band_shade
 lda edge_data+160,x
 sta band_tl
 lda edge_data+200,x
 sta band_tr
 lda edge_data+240,x
 sta band_bl
 lda edge_data+280,x
 sta band_br
 jsr oc_near_regular
 ldx col
 lda #$55
 sta band_shade
 lda edge_data+240,x
 sta band_tl
 lda edge_data+280,x
 sta band_tr
 lda edge_data+320,x
 sta band_bl
 lda edge_data+360,x
 sta band_br
 jsr oc_near_regular
compose_next_column:
 inc col
 lda col
 cmp #32
 bne compose_column
 rts
draw_band:
 lda band_tr
 sec
 sbc band_tl
 tay
 bcc sample_top_neg
sample_top_pos:
 lda slope_pos_0,y
 clc
 adc band_tl
 sta top_samples+0
 lda slope_pos_1,y
 clc
 adc band_tl
 sta top_samples+1
 lda slope_pos_2,y
 clc
 adc band_tl
 sta top_samples+2
 lda slope_pos_3,y
 clc
 adc band_tl
 sta top_samples+3
 jmp sample_top_done
sample_top_neg:
 lda slope_neg_0,y
 clc
 adc band_tl
 sta top_samples+0
 lda slope_neg_1,y
 clc
 adc band_tl
 sta top_samples+1
 lda slope_neg_2,y
 clc
 adc band_tl
 sta top_samples+2
 lda slope_neg_3,y
 clc
 adc band_tl
 sta top_samples+3
sample_top_done:
 lda band_br
 sec
 sbc band_bl
 tay
 bcc sample_bottom_neg
sample_bottom_pos:
 lda slope_pos_0,y
 clc
 adc band_bl
 sta bottom_samples+0
 lda slope_pos_1,y
 clc
 adc band_bl
 sta bottom_samples+1
 lda slope_pos_2,y
 clc
 adc band_bl
 sta bottom_samples+2
 lda slope_pos_3,y
 clc
 adc band_bl
 sta bottom_samples+3
 jmp sample_bottom_done
sample_bottom_neg:
 lda slope_neg_0,y
 clc
 adc band_bl
 sta bottom_samples+0
 lda slope_neg_1,y
 clc
 adc band_bl
 sta bottom_samples+1
 lda slope_neg_2,y
 clc
 adc band_bl
 sta bottom_samples+2
 lda slope_neg_3,y
 clc
 adc band_bl
 sta bottom_samples+3
sample_bottom_done:
 lda top_samples
 cmp top_samples+3
 bcc bound_min_top
 lda top_samples+3
bound_min_top:
 lsr
 lsr
 lsr
 sta band_row
 lda top_samples
 cmp top_samples+3
 bcs bound_max_top
 lda top_samples+3
bound_max_top:
 clc
 adc #7
 lsr
 lsr
 lsr
 sta band_top_end
 lda bottom_samples
 cmp bottom_samples+3
 bcc bound_min_bottom
 lda bottom_samples+3
bound_min_bottom:
 lsr
 lsr
 lsr
 sta band_bottom_start
 lda bottom_samples
 cmp bottom_samples+3
 bcs bound_max_bottom
 lda bottom_samples+3
bound_max_bottom:
 clc
 adc #7
 lsr
 lsr
 lsr
 sta band_last
 jsr ef_clear_gaps
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
 ldx band_row
 lda bitmap_row_lo,x
 clc
 adc ef_col_low
 sta outptr
 lda bitmap_row_hi,x
 adc ef_col_hi
 sta outptr+1
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
 lda band_shade
 cmp #$ff
 beq ef_white_top
 ldy #7
edge_top_pixel:
 lda (mask_tl),y
 ora (mask_tr),y
 beq em_top_next
 cmp #$ff
 beq em_top_full
 sta band_tmp
 lda (outptr),y
 eor band_shade
 and band_tmp
 eor (outptr),y
 sta (outptr),y
em_top_next:
 dey
 bpl edge_top_pixel
 jmp band_advance
em_top_full:
 lda band_shade
 sta (outptr),y
 dey
 bpl edge_top_pixel
 jmp band_advance
edge_bottom_pixels:
 lda band_shade
 cmp #$ff
 beq ef_white_bottom
 ldy #7
edge_bottom_pixel:
 lda (mask_bl),y
 ora (mask_br),y
 eor #$ff
 beq em_bottom_next
 cmp #$ff
 beq em_bottom_full
 sta band_tmp
 lda (outptr),y
 eor band_shade
 and band_tmp
 eor (outptr),y
 sta (outptr),y
em_bottom_next:
 dey
 bpl edge_bottom_pixel
 jmp band_advance
em_bottom_full:
 lda band_shade
 sta (outptr),y
 dey
 bpl edge_bottom_pixel
 jmp band_advance
edge_both_pixels:
 lda band_shade
 cmp #$ff
 beq ef_white_both
 ldy #7
edge_both_pixel:
 lda (mask_tl),y
 ora (mask_tr),y
 sta band_tmp
 lda (mask_bl),y
 ora (mask_br),y
 eor #$ff
 and band_tmp
 beq em_both_next
 cmp #$ff
 beq em_both_full
 sta band_tmp
 lda (outptr),y
 eor band_shade
 and band_tmp
 eor (outptr),y
 sta (outptr),y
em_both_next:
 dey
 bpl edge_both_pixel
 jmp band_advance
em_both_full:
 lda band_shade
 sta (outptr),y
 dey
 bpl edge_both_pixel
 jmp band_advance
ef_white_top:
 ldy #7
ef_white_top_loop:
 lda (mask_tl),y
 ora (mask_tr),y
 beq em_white_top_next
 ora (outptr),y
 sta (outptr),y
em_white_top_next:
 dey
 bpl ef_white_top_loop
 jmp band_advance
ef_white_bottom:
 ldy #7
ef_white_bottom_loop:
 lda (mask_bl),y
 ora (mask_br),y
 eor #$ff
 beq em_white_bottom_next
 ora (outptr),y
 sta (outptr),y
em_white_bottom_next:
 dey
 bpl ef_white_bottom_loop
 jmp band_advance
ef_white_both:
 ldy #7
ef_white_both_loop:
 lda (mask_tl),y
 ora (mask_tr),y
 sta band_tmp
 lda (mask_bl),y
 ora (mask_br),y
 eor #$ff
 and band_tmp
 beq em_white_both_next
 ora (outptr),y
 sta (outptr),y
em_white_both_next:
 dey
 bpl ef_white_both_loop
 jmp band_advance
band_advance:
 inc band_row
 jmp band_next_row
band_done:
 rts
band_address:
 ldx band_row
 lda bitmap_row_lo,x
 clc
 adc ef_col_low
 sta outptr
 lda bitmap_row_hi,x
 adc ef_col_hi
 sta outptr+1
 rts
ef_page_index:
 .byte 0,22
build_top_mask:
 lda top_samples+0
 sec
 sbc rowtop
 bcs pair_0_0_positive
 lda #0
pair_0_0_positive:
 tay
 lda mi_clamp9,y
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
 lda mi_clamp9,y
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
 lda mi_clamp9,y
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
 lda mi_clamp9,y
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
 lda ef_fill_index
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
fill_a_0_19:
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
fill_a_0_20:
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
fill_a_0_21:
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
 rts
fill_a_1_0:
 sta $6760,x
 sta $6761,x
 sta $6762,x
 sta $6763,x
 sta $6764,x
 sta $6765,x
 sta $6766,x
 sta $6767,x
 dec band_count
 beq fill_done
fill_a_1_1:
 sta $68a0,x
 sta $68a1,x
 sta $68a2,x
 sta $68a3,x
 sta $68a4,x
 sta $68a5,x
 sta $68a6,x
 sta $68a7,x
 dec band_count
 beq fill_done
fill_a_1_2:
 sta $69e0,x
 sta $69e1,x
 sta $69e2,x
 sta $69e3,x
 sta $69e4,x
 sta $69e5,x
 sta $69e6,x
 sta $69e7,x
 dec band_count
 beq fill_done
fill_a_1_3:
 sta $6b20,x
 sta $6b21,x
 sta $6b22,x
 sta $6b23,x
 sta $6b24,x
 sta $6b25,x
 sta $6b26,x
 sta $6b27,x
 dec band_count
 beq fill_done
fill_a_1_4:
 sta $6c60,x
 sta $6c61,x
 sta $6c62,x
 sta $6c63,x
 sta $6c64,x
 sta $6c65,x
 sta $6c66,x
 sta $6c67,x
 dec band_count
 beq fill_done
fill_a_1_5:
 sta $6da0,x
 sta $6da1,x
 sta $6da2,x
 sta $6da3,x
 sta $6da4,x
 sta $6da5,x
 sta $6da6,x
 sta $6da7,x
 dec band_count
 beq fill_done
fill_a_1_6:
 sta $6ee0,x
 sta $6ee1,x
 sta $6ee2,x
 sta $6ee3,x
 sta $6ee4,x
 sta $6ee5,x
 sta $6ee6,x
 sta $6ee7,x
 dec band_count
 beq fill_done
fill_a_1_7:
 sta $7020,x
 sta $7021,x
 sta $7022,x
 sta $7023,x
 sta $7024,x
 sta $7025,x
 sta $7026,x
 sta $7027,x
 dec band_count
 beq fill_done
fill_a_1_8:
 sta $7160,x
 sta $7161,x
 sta $7162,x
 sta $7163,x
 sta $7164,x
 sta $7165,x
 sta $7166,x
 sta $7167,x
 dec band_count
 beq fill_done
fill_a_1_9:
 sta $72a0,x
 sta $72a1,x
 sta $72a2,x
 sta $72a3,x
 sta $72a4,x
 sta $72a5,x
 sta $72a6,x
 sta $72a7,x
 dec band_count
 beq fill_done
fill_a_1_10:
 sta $73e0,x
 sta $73e1,x
 sta $73e2,x
 sta $73e3,x
 sta $73e4,x
 sta $73e5,x
 sta $73e6,x
 sta $73e7,x
 dec band_count
 beq fill_done
fill_a_1_11:
 sta $7520,x
 sta $7521,x
 sta $7522,x
 sta $7523,x
 sta $7524,x
 sta $7525,x
 sta $7526,x
 sta $7527,x
 dec band_count
 beq fill_done
fill_a_1_12:
 sta $7660,x
 sta $7661,x
 sta $7662,x
 sta $7663,x
 sta $7664,x
 sta $7665,x
 sta $7666,x
 sta $7667,x
 dec band_count
 beq fill_done
fill_a_1_13:
 sta $77a0,x
 sta $77a1,x
 sta $77a2,x
 sta $77a3,x
 sta $77a4,x
 sta $77a5,x
 sta $77a6,x
 sta $77a7,x
 dec band_count
 beq fill_done
fill_a_1_14:
 sta $78e0,x
 sta $78e1,x
 sta $78e2,x
 sta $78e3,x
 sta $78e4,x
 sta $78e5,x
 sta $78e6,x
 sta $78e7,x
 dec band_count
 beq fill_done
fill_a_1_15:
 sta $7a20,x
 sta $7a21,x
 sta $7a22,x
 sta $7a23,x
 sta $7a24,x
 sta $7a25,x
 sta $7a26,x
 sta $7a27,x
 dec band_count
 beq fill_done
fill_a_1_16:
 sta $7b60,x
 sta $7b61,x
 sta $7b62,x
 sta $7b63,x
 sta $7b64,x
 sta $7b65,x
 sta $7b66,x
 sta $7b67,x
 dec band_count
 beq fill_done
fill_a_1_17:
 sta $7ca0,x
 sta $7ca1,x
 sta $7ca2,x
 sta $7ca3,x
 sta $7ca4,x
 sta $7ca5,x
 sta $7ca6,x
 sta $7ca7,x
 dec band_count
 beq fill_done
fill_a_1_18:
 sta $7ca0,x
 sta $7ca1,x
 sta $7ca2,x
 sta $7ca3,x
 sta $7ca4,x
 sta $7ca5,x
 sta $7ca6,x
 sta $7ca7,x
 dec band_count
 beq fill_done
fill_a_1_19:
 sta $7ca0,x
 sta $7ca1,x
 sta $7ca2,x
 sta $7ca3,x
 sta $7ca4,x
 sta $7ca5,x
 sta $7ca6,x
 sta $7ca7,x
 dec band_count
 beq fill_done
fill_a_1_20:
 sta $7ca0,x
 sta $7ca1,x
 sta $7ca2,x
 sta $7ca3,x
 sta $7ca4,x
 sta $7ca5,x
 sta $7ca6,x
 sta $7ca7,x
 dec band_count
 beq fill_done
fill_a_1_21:
 sta $7ca0,x
 sta $7ca1,x
 sta $7ca2,x
 sta $7ca3,x
 sta $7ca4,x
 sta $7ca5,x
 sta $7ca6,x
 sta $7ca7,x
 dec band_count
 beq fill_done
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
fill_b_0_19:
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
fill_b_0_20:
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
fill_b_0_21:
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
 rts
fill_b_1_0:
 sta $e760,x
 sta $e761,x
 sta $e762,x
 sta $e763,x
 sta $e764,x
 sta $e765,x
 sta $e766,x
 sta $e767,x
 dec band_count
 beq fill_done
fill_b_1_1:
 sta $e8a0,x
 sta $e8a1,x
 sta $e8a2,x
 sta $e8a3,x
 sta $e8a4,x
 sta $e8a5,x
 sta $e8a6,x
 sta $e8a7,x
 dec band_count
 beq fill_done
fill_b_1_2:
 sta $e9e0,x
 sta $e9e1,x
 sta $e9e2,x
 sta $e9e3,x
 sta $e9e4,x
 sta $e9e5,x
 sta $e9e6,x
 sta $e9e7,x
 dec band_count
 beq fill_done
fill_b_1_3:
 sta $eb20,x
 sta $eb21,x
 sta $eb22,x
 sta $eb23,x
 sta $eb24,x
 sta $eb25,x
 sta $eb26,x
 sta $eb27,x
 dec band_count
 beq fill_done
fill_b_1_4:
 sta $ec60,x
 sta $ec61,x
 sta $ec62,x
 sta $ec63,x
 sta $ec64,x
 sta $ec65,x
 sta $ec66,x
 sta $ec67,x
 dec band_count
 beq fill_done
fill_b_1_5:
 sta $eda0,x
 sta $eda1,x
 sta $eda2,x
 sta $eda3,x
 sta $eda4,x
 sta $eda5,x
 sta $eda6,x
 sta $eda7,x
 dec band_count
 beq fill_done
fill_b_1_6:
 sta $eee0,x
 sta $eee1,x
 sta $eee2,x
 sta $eee3,x
 sta $eee4,x
 sta $eee5,x
 sta $eee6,x
 sta $eee7,x
 dec band_count
 beq fill_done
fill_b_1_7:
 sta $f020,x
 sta $f021,x
 sta $f022,x
 sta $f023,x
 sta $f024,x
 sta $f025,x
 sta $f026,x
 sta $f027,x
 dec band_count
 beq fill_done
fill_b_1_8:
 sta $f160,x
 sta $f161,x
 sta $f162,x
 sta $f163,x
 sta $f164,x
 sta $f165,x
 sta $f166,x
 sta $f167,x
 dec band_count
 beq fill_done
fill_b_1_9:
 sta $f2a0,x
 sta $f2a1,x
 sta $f2a2,x
 sta $f2a3,x
 sta $f2a4,x
 sta $f2a5,x
 sta $f2a6,x
 sta $f2a7,x
 dec band_count
 beq fill_done
fill_b_1_10:
 sta $f3e0,x
 sta $f3e1,x
 sta $f3e2,x
 sta $f3e3,x
 sta $f3e4,x
 sta $f3e5,x
 sta $f3e6,x
 sta $f3e7,x
 dec band_count
 beq fill_done
fill_b_1_11:
 sta $f520,x
 sta $f521,x
 sta $f522,x
 sta $f523,x
 sta $f524,x
 sta $f525,x
 sta $f526,x
 sta $f527,x
 dec band_count
 beq fill_done
fill_b_1_12:
 sta $f660,x
 sta $f661,x
 sta $f662,x
 sta $f663,x
 sta $f664,x
 sta $f665,x
 sta $f666,x
 sta $f667,x
 dec band_count
 beq fill_done
fill_b_1_13:
 sta $f7a0,x
 sta $f7a1,x
 sta $f7a2,x
 sta $f7a3,x
 sta $f7a4,x
 sta $f7a5,x
 sta $f7a6,x
 sta $f7a7,x
 dec band_count
 beq fill_done
fill_b_1_14:
 sta $f8e0,x
 sta $f8e1,x
 sta $f8e2,x
 sta $f8e3,x
 sta $f8e4,x
 sta $f8e5,x
 sta $f8e6,x
 sta $f8e7,x
 dec band_count
 beq fill_done
fill_b_1_15:
 sta $fa20,x
 sta $fa21,x
 sta $fa22,x
 sta $fa23,x
 sta $fa24,x
 sta $fa25,x
 sta $fa26,x
 sta $fa27,x
 dec band_count
 beq fill_done
fill_b_1_16:
 sta $fb60,x
 sta $fb61,x
 sta $fb62,x
 sta $fb63,x
 sta $fb64,x
 sta $fb65,x
 sta $fb66,x
 sta $fb67,x
 dec band_count
 beq fill_done
fill_b_1_17:
 sta $fca0,x
 sta $fca1,x
 sta $fca2,x
 sta $fca3,x
 sta $fca4,x
 sta $fca5,x
 sta $fca6,x
 sta $fca7,x
 dec band_count
 beq fill_done
fill_b_1_18:
 sta $fca0,x
 sta $fca1,x
 sta $fca2,x
 sta $fca3,x
 sta $fca4,x
 sta $fca5,x
 sta $fca6,x
 sta $fca7,x
 dec band_count
 beq fill_done
fill_b_1_19:
 sta $fca0,x
 sta $fca1,x
 sta $fca2,x
 sta $fca3,x
 sta $fca4,x
 sta $fca5,x
 sta $fca6,x
 sta $fca7,x
 dec band_count
 beq fill_done
fill_b_1_20:
 sta $fca0,x
 sta $fca1,x
 sta $fca2,x
 sta $fca3,x
 sta $fca4,x
 sta $fca5,x
 sta $fca6,x
 sta $fca7,x
 dec band_count
 beq fill_done
fill_b_1_21:
 sta $fca0,x
 sta $fca1,x
 sta $fca2,x
 sta $fca3,x
 sta $fca4,x
 sta $fca5,x
 sta $fca6,x
 sta $fca7,x
 dec band_count
 beq fill_done
 rts
fill_done:
 rts
fill_entry_lo:
 .byte <fill_a_0_0,<fill_a_0_1,<fill_a_0_2,<fill_a_0_3,<fill_a_0_4,<fill_a_0_5,<fill_a_0_6,<fill_a_0_7,<fill_a_0_8,<fill_a_0_9,<fill_a_0_10,<fill_a_0_11,<fill_a_0_12,<fill_a_0_13,<fill_a_0_14,<fill_a_0_15,<fill_a_0_16,<fill_a_0_17,<fill_a_0_18,<fill_a_0_19,<fill_a_0_20,<fill_a_0_21,<fill_a_1_0,<fill_a_1_1,<fill_a_1_2,<fill_a_1_3,<fill_a_1_4,<fill_a_1_5,<fill_a_1_6,<fill_a_1_7,<fill_a_1_8,<fill_a_1_9,<fill_a_1_10,<fill_a_1_11,<fill_a_1_12,<fill_a_1_13,<fill_a_1_14,<fill_a_1_15,<fill_a_1_16,<fill_a_1_17,<fill_a_1_18,<fill_a_1_19,<fill_a_1_20,<fill_a_1_21,<fill_b_0_0,<fill_b_0_1,<fill_b_0_2,<fill_b_0_3,<fill_b_0_4,<fill_b_0_5,<fill_b_0_6,<fill_b_0_7,<fill_b_0_8,<fill_b_0_9,<fill_b_0_10,<fill_b_0_11,<fill_b_0_12,<fill_b_0_13,<fill_b_0_14,<fill_b_0_15,<fill_b_0_16,<fill_b_0_17,<fill_b_0_18,<fill_b_0_19,<fill_b_0_20,<fill_b_0_21,<fill_b_1_0,<fill_b_1_1,<fill_b_1_2,<fill_b_1_3,<fill_b_1_4,<fill_b_1_5,<fill_b_1_6,<fill_b_1_7,<fill_b_1_8,<fill_b_1_9,<fill_b_1_10,<fill_b_1_11,<fill_b_1_12,<fill_b_1_13,<fill_b_1_14,<fill_b_1_15,<fill_b_1_16,<fill_b_1_17,<fill_b_1_18,<fill_b_1_19,<fill_b_1_20,<fill_b_1_21
fill_entry_hi:
 .byte >fill_a_0_0,>fill_a_0_1,>fill_a_0_2,>fill_a_0_3,>fill_a_0_4,>fill_a_0_5,>fill_a_0_6,>fill_a_0_7,>fill_a_0_8,>fill_a_0_9,>fill_a_0_10,>fill_a_0_11,>fill_a_0_12,>fill_a_0_13,>fill_a_0_14,>fill_a_0_15,>fill_a_0_16,>fill_a_0_17,>fill_a_0_18,>fill_a_0_19,>fill_a_0_20,>fill_a_0_21,>fill_a_1_0,>fill_a_1_1,>fill_a_1_2,>fill_a_1_3,>fill_a_1_4,>fill_a_1_5,>fill_a_1_6,>fill_a_1_7,>fill_a_1_8,>fill_a_1_9,>fill_a_1_10,>fill_a_1_11,>fill_a_1_12,>fill_a_1_13,>fill_a_1_14,>fill_a_1_15,>fill_a_1_16,>fill_a_1_17,>fill_a_1_18,>fill_a_1_19,>fill_a_1_20,>fill_a_1_21,>fill_b_0_0,>fill_b_0_1,>fill_b_0_2,>fill_b_0_3,>fill_b_0_4,>fill_b_0_5,>fill_b_0_6,>fill_b_0_7,>fill_b_0_8,>fill_b_0_9,>fill_b_0_10,>fill_b_0_11,>fill_b_0_12,>fill_b_0_13,>fill_b_0_14,>fill_b_0_15,>fill_b_0_16,>fill_b_0_17,>fill_b_0_18,>fill_b_0_19,>fill_b_0_20,>fill_b_0_21,>fill_b_1_0,>fill_b_1_1,>fill_b_1_2,>fill_b_1_3,>fill_b_1_4,>fill_b_1_5,>fill_b_1_6,>fill_b_1_7,>fill_b_1_8,>fill_b_1_9,>fill_b_1_10,>fill_b_1_11,>fill_b_1_12,>fill_b_1_13,>fill_b_1_14,>fill_b_1_15,>fill_b_1_16,>fill_b_1_17,>fill_b_1_18,>fill_b_1_19,>fill_b_1_20,>fill_b_1_21
clear_view:
ef_clear_gaps:
 lda ef_background
 bne ef_clear_needed
 rts
ef_clear_needed:
 lda #0
 sta ef_background
 lda band_row
 sta ef_saved_row
 lda band_shade
 sta ef_saved_shade
 lda band_top_end
 sta band_count
 beq ef_no_ceiling
 lda #0
 sta band_row
 jsr band_address
ef_clear_ceiling_row:
 lda #$44
 ldy #0
 sta (outptr),y
 ldy #2
 sta (outptr),y
 ldy #4
 sta (outptr),y
 ldy #6
 sta (outptr),y
 lda #$11
 ldy #1
 sta (outptr),y
 ldy #3
 sta (outptr),y
 ldy #5
 sta (outptr),y
 ldy #7
 sta (outptr),y
 dec band_count
 beq ef_no_ceiling
 ; C=0: band_address and every ceiling high-byte addition stay below $100.
 ; The last row needs no next address. outptr is not live on this exit.
 lda outptr
 adc #$40
 sta outptr
 lda outptr+1
 adc #1
 sta outptr+1
 bcc ef_clear_ceiling_row
ef_no_ceiling:
 lda #18
 sec
 sbc band_bottom_start
 sta band_count
 beq ef_no_floor
 lda band_bottom_start
 sta band_row
 lda #$55
 sta band_shade
 jsr fill_rows
ef_no_floor:
 lda ef_saved_row
 sta band_row
 lda ef_saved_shade
 sta band_shade
 rts
bitmap_row_lo:
 .byte $60,$a0,$e0,$20,$60,$a0,$e0,$20,$60,$a0,$e0,$20,$60,$a0,$e0,$20
 .byte $60,$a0,$a0,$a0,$a0,$a0
bitmap_row_hi:
 .byte $66,$67,$68,$6a,$6b,$6c,$6d,$6f,$70,$71,$72,$74,$75,$76,$77,$79
 .byte $7a,$7b,$7b,$7b,$7b,$7b
; Standalone Q8.8 512-direction grid DDA. No polygon code/buffers.
cam_x=$20
cam_y=$22
cam_angle=$24
pose_x=$26
pose_y=$28
pose_angle=$2a
ray_index=$2c
cell_x=$2d
cell_y=$2e
mo_base_lo=cell_x
mo_base_hi=cell_y
map_ptr=$30
delta_x=$32
delta_y=$34
side_x=$36
side_y=$38
hit_t=$3a
dir_x=$3c
dir_y=$3e
dir_sign=$40
steps=$41
hit_side=$42
hit_u=$43
hit_mat=$44
angle=$45
mul_a=$48
mul_b=$4a
mul_r=$4b
temp=$50
ray_t_lo=$3a00
ray_t_hi=$3a50
ray_u=$3aa0
ray_mat=$3af0
ray_side=$3b40
ray_steps=$3b90

init_camera:
 lda #<INITIAL_X
 sta cam_x
 lda #>INITIAL_X
 sta cam_x+1
 lda #<INITIAL_Y
 sta cam_y
 lda #>INITIAL_Y
 sta cam_y+1
 lda #<INITIAL_ANGLE
 sta cam_angle
 lda #>INITIAL_ANGLE
 sta cam_angle+1
 rts
latch_pose:
 ldx #5
latch_pose_loop:
 lda cam_x,x
 sta pose_x,x
 dex
 bpl latch_pose_loop
 rts

ub_present=$2f95 ; reserved adaptive workspace; coarse hits only
raycast_all:
 jsr dm_patch
 lda #0
 sta ss_active
 sta ub_present
 sta ray_index
ray_next:
 ldx ray_index
 lda ss_active
 bne rx_init_fine
 lda #0
 sta upper_top,x
 sta upper_bottom,x
 sta upper_exit,x
rx_init_fine:
 lda #0
 sta upper_owner,x
 sta upper_side,x
 sta fx_exit_plane,x
 sta fx_near_plane,x
 sta steps
 ldx ray_index
 clc
 lda pose_angle
 adc ray_offset_lo,x
 sta angle
 lda pose_angle+1
 adc ray_offset_hi,x
 and #1
 sta angle+1
 tay
 jsr load_direction
mo_reload:
 lda mo_base_lo
 sta map_ptr
 lda mo_base_hi
 sta map_ptr+1
mo_reload_end:
 lda delta_x
 sta mul_a
 lda delta_x+1
 sta mul_a+1
 jsr dm_x
 lda mul_r
 sta side_x
 lda mul_r+1
 sta side_x+1
 lda dir_sign
 and #1
 bne ray_x_negative
 sec
 lda delta_x
 sbc side_x
 sta side_x
 lda delta_x+1
 sbc side_x+1
 sta side_x+1
ray_x_negative:
 lda delta_x+1
 cmp #$ff
 bne ray_x_nonparallel
 lda #$ff
 sta side_x
 sta side_x+1
ray_x_nonparallel:
 lda delta_y
 sta mul_a
 lda delta_y+1
 sta mul_a+1
 jsr dm_y
 lda mul_r
 sta side_y
 lda mul_r+1
 sta side_y+1
 lda dir_sign
 and #2
 bne ray_y_negative
 sec
 lda delta_y
 sbc side_y
 sta side_y
 lda delta_y+1
 sbc side_y+1
 sta side_y+1
ray_y_negative:
 lda delta_y+1
 cmp #$ff
 bne ray_y_nonparallel
 lda #$ff
 sta side_y
 sta side_y+1
ray_y_nonparallel:
 lda #0
 sta portal_inside
 ldy #0
 lda (map_ptr),y
 cmp #9
 bcc dda_dispatch
 pha
 lda #1
 sta portal_inside
 lda #0
 sta hit_side
 sta hit_t
 sta hit_t+1
 sta steps
 pla
 jmp ray_hit
dda_dispatch:
 lda dir_sign
 cmp #1
 beq dda_q1
 cmp #2
 beq dda_q2
 cmp #3
 beq dda_q3
 jmp dda_q0
dda_q0:
 lda #64
 sec
 sbc steps
 tax
dda_q0_begin:
 dex
 bpl dda_q0_valid
 lda #64
 sta steps
 jmp ray_miss
dda_q0_valid:
 lda side_y+1
 cmp side_x+1
 bcc dda_q0_y
 bne dda_q0_x
 lda side_y
 cmp side_x
 bcc dda_q0_y
dda_q0_x:
 inc map_ptr
 bne dda_q0_xr
 inc map_ptr+1
dda_q0_xr:
 ldy #0
 lda (map_ptr),y
 bne dda_q0_hit_x
 clc
 lda side_x
 adc delta_x
 sta side_x
 lda side_x+1
 adc delta_x+1
 sta side_x+1
 jmp dda_q0_begin
dda_q0_y:
 clc
 lda map_ptr
 adc #32
 sta map_ptr
 bcc dda_q0_yr
 inc map_ptr+1
dda_q0_yr:
 ldy #0
 lda (map_ptr),y
 bne dda_q0_hit_y
 clc
 lda side_y
 adc delta_y
 sta side_y
 lda side_y+1
 adc delta_y+1
 sta side_y+1
 jmp dda_q0_begin
dda_q0_hit_x:
 sta hit_mat
 lda #0
 sta hit_side
 lda side_x
 sta hit_t
 lda side_x+1
 sta hit_t+1
 txa
 eor #$ff
 clc
 adc #65
 sta steps
 lda hit_mat
 jmp ray_hit
dda_q0_hit_y:
 sta hit_mat
 lda #1
 sta hit_side
 lda side_y
 sta hit_t
 lda side_y+1
 sta hit_t+1
 txa
 eor #$ff
 clc
 adc #65
 sta steps
 lda hit_mat
 jmp ray_hit
dda_q1:
 lda #64
 sec
 sbc steps
 tax
dda_q1_begin:
 dex
 bpl dda_q1_valid
 lda #64
 sta steps
 jmp ray_miss
dda_q1_valid:
 lda side_y+1
 cmp side_x+1
 bcc dda_q1_y
 bne dda_q1_x
 lda side_y
 cmp side_x
 bcc dda_q1_y
dda_q1_x:
 lda map_ptr
 bne dda_q1_xd
 dec map_ptr+1
dda_q1_xd:
 dec map_ptr
 ldy #0
 lda (map_ptr),y
 bne dda_q1_hit_x
 clc
 lda side_x
 adc delta_x
 sta side_x
 lda side_x+1
 adc delta_x+1
 sta side_x+1
 jmp dda_q1_begin
dda_q1_y:
 clc
 lda map_ptr
 adc #32
 sta map_ptr
 bcc dda_q1_yr
 inc map_ptr+1
dda_q1_yr:
 ldy #0
 lda (map_ptr),y
 bne dda_q1_hit_y
 clc
 lda side_y
 adc delta_y
 sta side_y
 lda side_y+1
 adc delta_y+1
 sta side_y+1
 jmp dda_q1_begin
dda_q1_hit_x:
 sta hit_mat
 lda #0
 sta hit_side
 lda side_x
 sta hit_t
 lda side_x+1
 sta hit_t+1
 txa
 eor #$ff
 clc
 adc #65
 sta steps
 lda hit_mat
 jmp ray_hit
dda_q1_hit_y:
 sta hit_mat
 lda #1
 sta hit_side
 lda side_y
 sta hit_t
 lda side_y+1
 sta hit_t+1
 txa
 eor #$ff
 clc
 adc #65
 sta steps
 lda hit_mat
 jmp ray_hit
dda_q2:
 lda #64
 sec
 sbc steps
 tax
dda_q2_begin:
 dex
 bpl dda_q2_valid
 lda #64
 sta steps
 jmp ray_miss
dda_q2_valid:
 lda side_y+1
 cmp side_x+1
 bcc dda_q2_y
 bne dda_q2_x
 lda side_y
 cmp side_x
 bcc dda_q2_y
dda_q2_x:
 inc map_ptr
 bne dda_q2_xr
 inc map_ptr+1
dda_q2_xr:
 ldy #0
 lda (map_ptr),y
 bne dda_q2_hit_x
 clc
 lda side_x
 adc delta_x
 sta side_x
 lda side_x+1
 adc delta_x+1
 sta side_x+1
 jmp dda_q2_begin
dda_q2_y:
 sec
 lda map_ptr
 sbc #32
 sta map_ptr
 bcs dda_q2_yr
 dec map_ptr+1
dda_q2_yr:
 ldy #0
 lda (map_ptr),y
 bne dda_q2_hit_y
 clc
 lda side_y
 adc delta_y
 sta side_y
 lda side_y+1
 adc delta_y+1
 sta side_y+1
 jmp dda_q2_begin
dda_q2_hit_x:
 sta hit_mat
 lda #0
 sta hit_side
 lda side_x
 sta hit_t
 lda side_x+1
 sta hit_t+1
 txa
 eor #$ff
 clc
 adc #65
 sta steps
 lda hit_mat
 jmp ray_hit
dda_q2_hit_y:
 sta hit_mat
 lda #1
 sta hit_side
 lda side_y
 sta hit_t
 lda side_y+1
 sta hit_t+1
 txa
 eor #$ff
 clc
 adc #65
 sta steps
 lda hit_mat
 jmp ray_hit
dda_q3:
 lda #64
 sec
 sbc steps
 tax
dda_q3_begin:
 dex
 bpl dda_q3_valid
 lda #64
 sta steps
 jmp ray_miss
dda_q3_valid:
 lda side_y+1
 cmp side_x+1
 bcc dda_q3_y
 bne dda_q3_x
 lda side_y
 cmp side_x
 bcc dda_q3_y
dda_q3_x:
 lda map_ptr
 bne dda_q3_xd
 dec map_ptr+1
dda_q3_xd:
 dec map_ptr
 ldy #0
 lda (map_ptr),y
 bne dda_q3_hit_x
 clc
 lda side_x
 adc delta_x
 sta side_x
 lda side_x+1
 adc delta_x+1
 sta side_x+1
 jmp dda_q3_begin
dda_q3_y:
 sec
 lda map_ptr
 sbc #32
 sta map_ptr
 bcs dda_q3_yr
 dec map_ptr+1
dda_q3_yr:
 ldy #0
 lda (map_ptr),y
 bne dda_q3_hit_y
 clc
 lda side_y
 adc delta_y
 sta side_y
 lda side_y+1
 adc delta_y+1
 sta side_y+1
 jmp dda_q3_begin
dda_q3_hit_x:
 sta hit_mat
 lda #0
 sta hit_side
 lda side_x
 sta hit_t
 lda side_x+1
 sta hit_t+1
 txa
 eor #$ff
 clc
 adc #65
 sta steps
 lda hit_mat
 jmp ray_hit
dda_q3_hit_y:
 sta hit_mat
 lda #1
 sta hit_side
 lda side_y
 sta hit_t
 lda side_y+1
 sta hit_t+1
 txa
 eor #$ff
 clc
 adc #65
 sta steps
 lda hit_mat
 jmp ray_hit
ray_miss:
 lda #0
 sta hit_mat
 sta hit_u
 lda #$ff
 sta hit_t
 sta hit_t+1
 sta mul_r
 sta mul_r+1
 jmp ray_store
ray_hit:
 sta hit_mat
 lda #0
 sta hit_u

 ldx ray_index
 lda ray_cos_axis,x
 beq depth_multiply
 lda hit_t
 sta mul_r
 lda hit_t+1
 sta mul_r+1
 jmp ray_store
depth_multiply:
 lda hit_t
 sta mul_a
 lda hit_t+1
 sta mul_a+1
 lda ray_cos,x
 sta mul_b
 jsr mul16x8_shift8
ray_store:
 lda ss_active
 beq rx_coarse_store
 jmp rx_store
rx_coarse_store:
 ldx ray_index
 lda hit_t
 sta ray_t_lo,x
 sta ray_t_lo+1,x
 lda hit_t+1
 sta ray_t_hi,x
 sta ray_t_hi+1,x
 lda mul_r
 sta depth_lo,x
 sta depth_lo+1,x
 lda mul_r+1
 sta depth_hi,x
 sta depth_hi+1,x
 lda hit_u
 sta ray_u,x
 sta ray_u+1,x
 lda hit_mat
 sta ray_mat,x
 sta ray_mat+1,x
 lda hit_side
 sta ray_side,x
 sta ray_side+1,x
 lda steps
 sta ray_steps,x
 sta ray_steps+1,x
 lda hit_mat
 cmp #9
 bcs fused_overhead
 jsr store_wall_owner
 lda #0
 sta layer
 jsr layer_heights
 jmp fused_ray_done
fused_overhead:
 sta ub_present ; A is the nonzero coarse overhead material
 lda #$ff
 ldy portal_inside
 bne fx_inside_plane
 lda hit_side
 jsr fx_capture_plane
fx_inside_plane:
 sta fx_near_plane,x
 jsr portal_exit
 lda exit_side
 jsr fx_capture_plane
 sta fx_exit_plane,x
 lda #1
 sta layer
 jsr layer_heights
rx_continue_portal:
 ; The exit routine leaves map_ptr at the first cell beyond the volume.
 ; This cell has already been counted, but its side distance not incremented.
 ldy #0
 lda (map_ptr),y
 beq fused_exit_free
 sta hit_mat
 lda exit_t
 sta hit_t
 lda exit_t+1
 sta hit_t+1
 lda exit_side
 sta hit_side
 lda hit_mat
 jmp ray_hit
fused_exit_free:
 lda exit_side
 bne fused_advance_y
 clc
 lda side_x
 adc delta_x
 sta side_x
 lda side_x+1
 adc delta_x+1
 sta side_x+1
 jmp dda_dispatch
fused_advance_y:
 clc
 lda side_y
 adc delta_y
 sta side_y
 lda side_y+1
 adc delta_y+1
 sta side_y+1
 jmp dda_dispatch
fused_ray_done:
 lda ss_active
 beq ss_main_ray
 rts
ss_main_ray:
 inc ray_index
 inc ray_index
 lda ray_index
 cmp #64
 bne ray_next
raycast_done:
 rts

; Exact floor(unsigned16 * unsigned8 /256). Decimal mode is clear.
; Fixed 8 iterations; carry represents the 17th bit before right shift.
; Exact floor(u16*u8/256). Main-thread only. IRQ never calls this kernel
; or changes operands/ZP. Eight absolute-indexed operands patched atomically
; with respect to main execution; interrupt may occur between patches safely.
; quarter table Q(n)=floor(n*n/4), difference table D(n)=Q(n-255).
; Q(a+b)-D(a+255-b)=a*b. No signed/rounding approximation.
qs_carry=$6d
mul16x8_shift8:
 lda mul_b
 sta low_sum_lo+1
 sta low_sum_hi+1
 sta high_sum_lo+1
 sta high_sum_hi+1
 eor #$ff
 sta low_diff_lo+1
 sta low_diff_hi+1
 sta high_diff_lo+1
 sta high_diff_hi+1
 ldx mul_a
 sec
low_sum_lo:
 lda quarter_lo,x
low_diff_lo:
 sbc difference_lo,x
low_sum_hi:
 lda quarter_hi,x
low_diff_hi:
 sbc difference_hi,x
 sta qs_carry
 ldx mul_a+1
 beq smc_high_zero
 sec
high_sum_lo:
 lda quarter_lo,x
high_diff_lo:
 sbc difference_lo,x
 sta mul_r
high_sum_hi:
 lda quarter_hi,x
high_diff_hi:
 sbc difference_hi,x
 sta mul_r+1
 clc
 lda mul_r
 adc qs_carry
 sta mul_r
 bcc smc_done
 inc mul_r+1
smc_done:
 rts
smc_high_zero:
 lda qs_carry
 sta mul_r
 lda #0
 sta mul_r+1
 rts

dm_patch:
mo_prepare:
 lda pose_y+1
 lsr
 lsr
 lsr
 clc
 adc #$3c
 sta mo_base_hi
 lda pose_y+1
 asl
 asl
 asl
 asl
 asl
 ora pose_x+1
 sta mo_base_lo
mo_prepare_end:
 lda pose_x
 sta dm_x_low_sum_lo+1
 sta dm_x_low_sum_hi+1
 sta dm_x_high_sum_lo+1
 sta dm_x_high_sum_hi+1
 eor #$ff
 sta dm_x_low_diff_lo+1
 sta dm_x_low_diff_hi+1
 sta dm_x_high_diff_lo+1
 sta dm_x_high_diff_hi+1
 lda pose_y
 sta dm_y_low_sum_lo+1
 sta dm_y_low_sum_hi+1
 sta dm_y_high_sum_lo+1
 sta dm_y_high_sum_hi+1
 eor #$ff
 sta dm_y_low_diff_lo+1
 sta dm_y_low_diff_hi+1
 sta dm_y_high_diff_lo+1
 sta dm_y_high_diff_hi+1
 rts
dm_x:
 ldx mul_a
 sec
dm_x_low_sum_lo:
 lda quarter_lo,x
dm_x_low_diff_lo:
 sbc difference_lo,x
dm_x_low_sum_hi:
 lda quarter_hi,x
dm_x_low_diff_hi:
 sbc difference_hi,x
 sta qs_carry
 ldx mul_a+1
 beq dm_x_smc_high_zero
 sec
dm_x_high_sum_lo:
 lda quarter_lo,x
dm_x_high_diff_lo:
 sbc difference_lo,x
 sta mul_r
dm_x_high_sum_hi:
 lda quarter_hi,x
dm_x_high_diff_hi:
 sbc difference_hi,x
 sta mul_r+1
 clc
 lda mul_r
 adc qs_carry
 sta mul_r
 bcc dm_x_smc_done
 inc mul_r+1
dm_x_smc_done:
 rts
dm_x_smc_high_zero:
 lda qs_carry
 sta mul_r
 lda #0
 sta mul_r+1
 rts
dm_y:
 ldx mul_a
 sec
dm_y_low_sum_lo:
 lda quarter_lo,x
dm_y_low_diff_lo:
 sbc difference_lo,x
dm_y_low_sum_hi:
 lda quarter_hi,x
dm_y_low_diff_hi:
 sbc difference_hi,x
 sta qs_carry
 ldx mul_a+1
 beq dm_y_smc_high_zero
 sec
dm_y_high_sum_lo:
 lda quarter_lo,x
dm_y_high_diff_lo:
 sbc difference_lo,x
 sta mul_r
dm_y_high_sum_hi:
 lda quarter_hi,x
dm_y_high_diff_hi:
 sbc difference_hi,x
 sta mul_r+1
 clc
 lda mul_r
 adc qs_carry
 sta mul_r
 bcc dm_y_smc_done
 inc mul_r+1
dm_y_smc_done:
 rts
dm_y_smc_high_zero:
 lda qs_carry
 sta mul_r
 lda #0
 sta mul_r+1
 rts
load_direction:
 ldy angle
 lda angle+1
 bne load_direction_high
 lda direction_0+0,y
 sta delta_x
 lda direction_1+0,y
 sta delta_x+1
 lda direction_2+0,y
 sta delta_y
 lda direction_3+0,y
 sta delta_y+1
 lda direction_8+0,y
 sta dir_sign
 rts
load_direction_high:
 lda direction_0+256,y
 sta delta_x
 lda direction_1+256,y
 sta delta_x+1
 lda direction_2+256,y
 sta delta_y
 lda direction_3+256,y
 sta delta_y+1
 lda direction_8+256,y
 sta dir_sign
 rts

class_ptr=$52
selected_class=$54
; Only height reconstruction. Geometric descriptors remain original duplicated40.
smooth_ids=$3700
smooth_q=$3750
smooth_ptr=$70
smooth_adj=$72
smooth_sum=$73
smooth_hi=$74

store_wall_owner:
 lda hit_mat
 beq owner_missing
 lda map_ptr
 sta smooth_ptr
 lda hit_side
 bne owner_y
 lda dir_sign
 and #1
 asl
 asl
 jmp owner_bank
owner_y:
 lda dir_sign
 and #2
 asl
 ora #8
owner_bank:
 clc
 adc map_ptr+1
 adc #(>wall_ids)-$3c
 sta smooth_ptr+1
 ldy #0
 lda (smooth_ptr),y
 sta smooth_ids,x
 sta smooth_ids+1,x
 rts
owner_missing:
 lda #0
 sta smooth_ids,x
 sta smooth_ids+1,x
 rts


layer=$75
lower_top=$3000
lower_bottom=$3050
lower_owner=$30a0
lower_side=$30f0
upper_top=$3140
upper_bottom=$3190
upper_owner=$31e0
upper_side=$3230
saved_lower_depth=$3280
saved_lower_depth_hi=$32d0
exit_depth=$3330
exit_depth_hi=$3380
upper_exit=$3600
edge_data=$3400
; Arrays 4 edges x2 endpoints x40 =320 bytes, plus two shade masks.
col=$76
rowtop=$77
rowcount=$78
rowoffset=$79
edge_index=$7a
shade_far=$7b
shade_near=$7c
scratch_byte=$7d
outptr=$7e
mask0=$80
mask1=$82
mask2=$84
mask3=$86
glyphindex=$88
edge_ptr=$89
edge_owner_ptr=$8b
edge_output_ptr=$8d
portal_inside=$90
exit_side=$91
exit_t=$92
mask4=$94
front_byte=$96
partial_row=$97

raycast_layers:
 jsr raycast_all
 lda #0
 rts
layer_heights:
layer_height_loop:
 lda depth_hi,x
 cmp #64
 bcc layer_depth_ok
 lda #$ff
 sta class_ptr
 lda #3
 jmp layer_depth_hi
layer_depth_ok:
 lda depth_hi,x
 asl
 asl
 asl
 asl
 sta class_ptr
 lda depth_lo,x
 lsr
 lsr
 lsr
 lsr
 ora class_ptr
 sta class_ptr
 lda depth_hi,x
 lsr
 lsr
 lsr
 lsr
layer_depth_hi:
 clc
 adc #>wall_top
 sta class_ptr+1
 ldy #0
 lda layer
 bne layer_upper
 lda (class_ptr),y
 sta lower_top,x
 clc
 lda class_ptr+1
 adc #4
 sta class_ptr+1
 lda (class_ptr),y
 sta lower_bottom,x
 lda smooth_ids,x
 sta lower_owner,x
 lda ray_side,x
 sta lower_side,x
 lda depth_lo,x
 sta saved_lower_depth,x
 lda depth_hi,x
 sta saved_lower_depth_hi,x
 jmp layer_next
layer_upper:
 lda depth_lo,x
 sta fx_near_depth,x
 lda depth_hi,x
 sta fx_near_depth_hi,x
 lda ray_mat,x
 cmp #9
 bcc layer_no_portal
 lda (class_ptr),y
 sta upper_top,x
 clc
 lda class_ptr+1
 adc #((>door_bottom)-(>wall_top))
 sta class_ptr+1
 lda (class_ptr),y
 sta upper_bottom,x
 lda class_ptr
 pha
 lda class_ptr+1
 pha
 lda exit_depth_hi,x
 lsr
 lsr
 lsr
 lsr
 clc
 adc #>door_bottom
 sta class_ptr+1
 lda exit_depth_hi,x
 asl
 asl
 asl
 asl
 sta class_ptr
 lda exit_depth,x
 lsr
 lsr
 lsr
 lsr
 ora class_ptr
 sta class_ptr
 lda (class_ptr),y
 sta upper_exit,x
 pla
 sta class_ptr+1
 pla
 sta class_ptr
 lda ray_side,x
 sta upper_side,x
 ; Material differentiates door rectangles, direction differentiates faces.
 asl
 asl
 asl
 asl
 clc
 adc ray_mat,x
 sta upper_owner,x
 jmp layer_next
layer_no_portal:
 lda #0
 sta upper_top,x
 sta upper_bottom,x
 sta upper_exit,x
 sta upper_owner,x
 sta upper_side,x
layer_next:
 rts
select_strips:
 ldx #0
 ldy #0
ep_pair_0_next:
 lda lower_top,y
 sta smooth_adj
 lda lower_bottom,y
 sta smooth_sum
 lda lower_owner,y
 sta scratch_byte
 cpx #0
 beq ep_pair_0_left_same
 lda scratch_byte
 beq ep_pair_0_left_same
 cmp lower_owner-2,y
 bne ep_pair_0_left_same
 lda lower_top-2,y
 clc
 adc smooth_adj
 ror
 sta edge_data+0,x
 lda lower_bottom-2,y
 clc
 adc smooth_sum
 ror
 jmp ep_pair_0_left_store
ep_pair_0_left_same:
 lda smooth_adj
 sta edge_data+0,x
 lda smooth_sum
ep_pair_0_left_store:
 sta edge_data+80,x
 cpx #31
 beq ep_pair_0_right_same
 lda scratch_byte
 beq ep_pair_0_right_same
 cmp lower_owner+2,y
 bne ep_pair_0_right_same
 lda lower_top+2,y
 clc
 adc smooth_adj
 ror
 sta edge_data+40,x
 lda lower_bottom+2,y
 clc
 adc smooth_sum
 ror
 jmp ep_pair_0_right_store
ep_pair_0_right_same:
 lda smooth_adj
 sta edge_data+40,x
 lda smooth_sum
ep_pair_0_right_store:
 sta edge_data+120,x
 inx
 iny
 iny
 cpx #32
 bne ep_pair_0_next
 lda ub_present
 bne ub_upper_endpoints
 ; All coarse upper inputs are zero, but stale endpoints must be overwritten.
 ldx #119
 lda #0
ub_clear_endpoints:
 sta edge_data+160,x
 sta edge_data+280,x
 dex
 bpl ub_clear_endpoints
 jmp select_strips_done
ub_upper_endpoints:
 ldx #0
 ldy #0
ep_pair_2_next:
 lda upper_top,y
 sta smooth_adj
 lda upper_bottom,y
 sta smooth_sum
 lda upper_owner,y
 sta scratch_byte
 cpx #0
 beq ep_pair_2_left_same
 lda scratch_byte
 beq ep_pair_2_left_same
 cmp upper_owner-2,y
 bne ep_pair_2_left_same
 lda upper_top-2,y
 clc
 adc smooth_adj
 ror
 sta edge_data+160,x
 lda upper_bottom-2,y
 clc
 adc smooth_sum
 ror
 jmp ep_pair_2_left_store
ep_pair_2_left_same:
 lda smooth_adj
 sta edge_data+160,x
 lda smooth_sum
ep_pair_2_left_store:
 sta edge_data+240,x
 cpx #31
 beq ep_pair_2_right_same
 lda scratch_byte
 beq ep_pair_2_right_same
 cmp upper_owner+2,y
 bne ep_pair_2_right_same
 lda upper_top+2,y
 clc
 adc smooth_adj
 ror
 sta edge_data+200,x
 lda upper_bottom+2,y
 clc
 adc smooth_sum
 ror
 jmp ep_pair_2_right_store
ep_pair_2_right_same:
 lda smooth_adj
 sta edge_data+200,x
 lda smooth_sum
ep_pair_2_right_store:
 sta edge_data+280,x
 inx
 iny
 iny
 cpx #32
 bne ep_pair_2_next
 ldx #0
 ldy #0
ep_4_next:
 lda upper_exit,y
 sta smooth_adj
 lda fx_exit_plane,y
 sta scratch_byte
 cpx #0
 beq ep_4_left_same
 lda scratch_byte
 beq ep_4_left_same
 cmp fx_exit_plane-2,y
 bne ep_4_left_same
 lda upper_exit-2,y
 clc
 adc smooth_adj
 ror
 jmp ep_4_left_store
ep_4_left_same:
 lda smooth_adj
ep_4_left_store:
 sta edge_data+320,x
 cpx #31
 beq ep_4_right_same
 lda scratch_byte
 beq ep_4_right_same
 cmp fx_exit_plane+2,y
 bne ep_4_right_same
 lda upper_exit+2,y
 clc
 adc smooth_adj
 ror
 jmp ep_4_right_store
ep_4_right_same:
 lda smooth_adj
ep_4_right_store:
 sta edge_data+360,x
 inx
 iny
 iny
 cpx #32
 bne ep_4_next
select_strips_done:
 jsr ss_mark
 jsr fx_edges
 rts
; Find the exit from a rectangular overhead volume using the same grid metric.
; Called after descriptors/owner are stored; DDA scratch is dead at this point.
; No simulation runs until both maps are restored. IRQ touches none of this ZP.
portal_exit:
 lda portal_inside
 bne portal_exit_next
 lda hit_side
 beq portal_advance_x
 jmp portal_advance_y
portal_advance_x:
 clc
 lda side_x
 adc delta_x
 sta side_x
 lda side_x+1
 adc delta_x+1
 sta side_x+1
 jmp portal_exit_next
portal_advance_y:
 clc
 lda side_y
 adc delta_y
 sta side_y
 lda side_y+1
 adc delta_y+1
 sta side_y+1
portal_exit_next:
 inc steps
 lda side_y+1
 cmp side_x+1
 bcc portal_cross_y
 bne portal_cross_x
 lda side_y
 cmp side_x
 bcc portal_cross_y
portal_cross_x:
 lda #0
 sta exit_side
 lda side_x
 sta exit_t
 lda side_x+1
 sta exit_t+1
 lda dir_sign
 and #1
 bne portal_cross_x_neg
 inc map_ptr
 bne portal_exit_test
 inc map_ptr+1
 jmp portal_exit_test
portal_cross_x_neg:
 lda map_ptr
 bne portal_x_no_borrow
 dec map_ptr+1
portal_x_no_borrow:
 dec map_ptr
 jmp portal_exit_test
portal_cross_y:
 lda #1
 sta exit_side
 lda side_y
 sta exit_t
 lda side_y+1
 sta exit_t+1
 lda dir_sign
 and #2
 bne portal_cross_y_neg
 clc
 lda map_ptr
 adc #32
 sta map_ptr
 bcc portal_exit_test
 inc map_ptr+1
 jmp portal_exit_test
portal_cross_y_neg:
 sec
 lda map_ptr
 sbc #32
 sta map_ptr
 bcs portal_exit_test
 dec map_ptr+1
portal_exit_test:
 ldy #0
 lda (map_ptr),y
 cmp hit_mat
 bne portal_exit_found
 lda exit_side
 beq portal_advance_x
 jmp portal_advance_y
portal_exit_found:
 ldx ray_index
 lda ray_cos_axis,x
 beq portal_exit_multiply
 lda exit_t
 sta mul_r
 lda exit_t+1
 sta mul_r+1
 jmp portal_exit_store
portal_exit_multiply:
 lda exit_t
 sta mul_a
 lda exit_t+1
 sta mul_a+1
 lda ray_cos,x
 sta mul_b
 jsr mul16x8_shift8
portal_exit_store:
 ldx ray_index
 lda mul_r
 sta exit_depth,x
 lda mul_r+1
 sta exit_depth_hi,x
 rts


; Standalone tick simulation. CIA row choice adapted from 1.3.0 keyboard scan.
; Square radius48/256 cell, conservative at corners; independent axis rejection
; gives wall sliding. Each queued logical tick performs its own <=6/256 step.
candidate_x=$58
candidate_y=$5a
box_x0=$5c
box_x1=$5d
box_y0=$5e
box_y1=$5f
keys=$60
move_x=$61
move_y=$62
auto_index=$63
auto_left=$64
auto_key=$66
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

collision_check:
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
 .if AUTO_RUN != 0
nav_collision_rows:
 lda box_y0
 jsr collision_row
 bcs collision_blocked
 inc box_y0
 lda box_y0
 cmp box_y1
 bcc nav_collision_rows
 beq nav_collision_rows
 clc
 rts
 .else
 lda box_y0
 jsr collision_row
 bcs collision_blocked
 lda box_y1
 jsr collision_row
 rts
 .endif
collision_row:
 pha
 lsr
 lsr
 lsr
 clc
 adc #$3c
 sta collision_ptr+1
 pla
 asl
 asl
 asl
 asl
 asl
 sta collision_ptr
 .if AUTO_RUN != 0
 ldy box_x0
nav_collision_columns:
 lda (collision_ptr),y
 bne collision_blocked
 cpy box_x1
 beq nav_collision_clear
 iny
 bne nav_collision_columns
nav_collision_clear:
 clc
 rts
 .else
 ldy box_x0
 lda (collision_ptr),y
 bne collision_blocked
 ldy box_x1
 lda (collision_ptr),y
 bne collision_blocked
 clc
 rts
 .endif
collision_blocked:
 sec
 rts


; Isolated scratch, never used by IRQ. Cache is reset once per latched view.
fx_base=$b5
fx_delta=$b7
fx_sign=$b9
fx_h=$ba
fx_num=$bc
fx_den=$be
fx_rem=$c0
fx_plane=$c2
fx_index=$c3
fx_comp=$c4
fx_count=$c5
fx_col=$c6
fx_tmp=$c7
fx_near_depth=$3650
fx_near_depth_hi=$36a0
fx_near_plane=$3750
fx_exit_plane=$37a0
fx_cache_lo=$3800
fx_cache_hi=$3880

; A=hit/exit side, X=ray index; map_ptr refers to the entered cell.
fx_capture_plane:
 bne fx_capture_y
 lda dir_sign
 and #1
 sta fx_tmp
 lda map_ptr
 and #31
 clc
 adc fx_tmp
 rts
fx_capture_y:
 lda dir_sign
 and #2
 lsr
 sta fx_tmp
 lda map_ptr+1
 and #3
 asl
 asl
 asl
 sta fx_comp
 lda map_ptr
 lsr
 lsr
 lsr
 lsr
 lsr
 ora fx_comp
 clc
 adc fx_tmp
 ora #64
 rts

fx_edges:
 ldx #127
 lda #0
fx_clear_cache:
 sta fx_cache_hi,x
 dex
 bpl fx_clear_cache
 ldx #0
fx_floor_next:
 stx fx_index
 txa
 lsr
 sta fx_col
 tay
 lda ss_flags,y
 bne fx_floor_advance
 lda lower_owner,x
 beq fx_floor_advance
 cpx #0
 beq fx_floor_work
 lda lower_owner,x
 cmp lower_owner-2,x
 bne fx_floor_work
 cpx #62
 beq fx_floor_work
 cmp lower_owner+2,x
 beq fx_floor_advance
fx_floor_work:
 lda lower_owner,x
 tay
 lda fx_wall_plane,y
 jsr fx_slope
 ldx fx_index
 lda saved_lower_depth_hi,x
 ldy saved_lower_depth,x
 jsr fx_height
 ldx fx_index
 cpx #0
 beq fx_floor_left
 lda lower_owner,x
 cmp lower_owner-2,x
 beq fx_floor_left_done
fx_floor_left:
 lda fx_sign
 eor #$80
 jsr fx_offset
 jsr pf_project_floor
 ldy fx_col
 sta edge_data+0,y
 txa
 sta edge_data+80,y
fx_floor_left_done:
 ldx fx_index
 cpx #62
 beq fx_floor_right
 lda lower_owner,x
 cmp lower_owner+2,x
 beq fx_floor_right_done
fx_floor_right:
 lda fx_sign
 jsr fx_offset
 jsr pf_project_floor
 ldy fx_col
 sta edge_data+40,y
 txa
 sta edge_data+120,y
fx_floor_right_done:
fx_floor_advance:
 ldx fx_index
 inx
 inx
 cpx #64
 bne fx_floor_next
 lda ub_present
 bne ub_upper_corrections
 ; Zero upper endpoints already satisfy exit>=bottom. Fine path is untouched.
 rts
ub_upper_corrections:
 ldx #0
fx_front_next:
 stx fx_index
 txa
 lsr
 sta fx_col
 tay
 lda ss_flags,y
 bne fx_front_advance
 lda upper_owner,x
 beq fx_front_advance
 lda fx_near_plane,x
 cmp #$ff
 beq fx_front_advance
 cpx #0
 beq fx_front_work
 lda upper_owner,x
 cmp upper_owner-2,x
 bne fx_front_work
 cpx #62
 beq fx_front_work
 cmp upper_owner+2,x
 beq fx_front_advance
fx_front_work:
 lda fx_near_plane,x
 jsr fx_slope
 ldx fx_index
 lda fx_near_depth_hi,x
 ldy fx_near_depth,x
 jsr fx_height
 ldx fx_index
 cpx #0
 beq fx_front_left
 lda upper_owner,x
 cmp upper_owner-2,x
 beq fx_front_left_done
fx_front_left:
 lda fx_sign
 eor #$80
 jsr fx_offset
 jsr pf_project_front
 ldy fx_col
 sta edge_data+160,y
 txa
 sta edge_data+240,y
fx_front_left_done:
 ldx fx_index
 cpx #62
 beq fx_front_right
 lda upper_owner,x
 cmp upper_owner+2,x
 beq fx_front_right_done
fx_front_right:
 lda fx_sign
 jsr fx_offset
 jsr pf_project_front
 ldy fx_col
 sta edge_data+200,y
 txa
 sta edge_data+280,y
fx_front_right_done:
fx_front_advance:
 ldx fx_index
 inx
 inx
 cpx #64
 bne fx_front_next
 ldx #0
fx_exit_next:
 stx fx_index
 txa
 lsr
 sta fx_col
 tay
 lda ss_flags,y
 bne fx_exit_advance
 lda fx_exit_plane,x
 beq fx_exit_advance
 cpx #0
 beq fx_exit_work
 lda fx_exit_plane,x
 cmp fx_exit_plane-2,x
 bne fx_exit_work
 cpx #62
 beq fx_exit_work
 cmp fx_exit_plane+2,x
 beq fx_exit_advance
fx_exit_work:
 lda fx_exit_plane,x
 jsr fx_slope
 ldx fx_index
 lda exit_depth_hi,x
 ldy exit_depth,x
 jsr fx_height
 ldx fx_index
 cpx #0
 beq fx_exit_left
 lda fx_exit_plane,x
 cmp fx_exit_plane-2,x
 beq fx_exit_left_done
fx_exit_left:
 lda fx_sign
 eor #$80
 jsr fx_offset
 jsr fx_project_door
 ldy fx_col
 sta edge_data+320,y
fx_exit_left_done:
 ldx fx_index
 cpx #62
 beq fx_exit_right
 lda fx_exit_plane,x
 cmp fx_exit_plane+2,x
 beq fx_exit_right_done
fx_exit_right:
 lda fx_sign
 jsr fx_offset
 jsr fx_project_door
 ldy fx_col
 sta edge_data+360,y
fx_exit_right_done:
fx_exit_advance:
 ldx fx_index
 inx
 inx
 cpx #64
 bne fx_exit_next
 ldx #79
fx_volume_order:
 lda edge_data+320,x
 cmp edge_data+240,x
 bcs fx_volume_next
 lda edge_data+240,x
 sta edge_data+320,x
fx_volume_next:
 dex
 bpl fx_volume_order
 rts

; A=depth high, Y=depth low. Same 1/16-cell depth bins as parent, but Q11.5
; unclipped height avoids extrapolating an already-clipped screen coordinate.
fx_height:
 cmp #64
 bcc fx_height_index
 lda #63
 ldy #$ff
fx_height_index:
 ; A=clamped high depth0..63,Y=low depth. Preserve caller X exactly.
 stx fx_tmp
 tax
 lda hi_nibble,x
 ora hi_low,y
 sta class_ptr
 lda hi_page,x
 sta class_ptr+1
 ldx fx_tmp
 ldy #0
 lda (class_ptr),y
 sta fx_base
 lda class_ptr+1
 clc
 adc #4
 sta class_ptr+1
 lda (class_ptr),y
 sta fx_base+1
 lda ss_active
 beq rx_height_regular
 sec
 lda fx_base
 sbc fx_delta
 sta fx_h
 lda fx_base+1
 sbc fx_delta+1
 bcc rx_height_regular
 cmp #10
 bcc rx_height_regular
 bne rx_height_clipped
 lda fx_h
 cmp #241
 bcc rx_height_regular
rx_height_clipped:
 lda fx_base
 sta fx_h
 lda fx_base+1
 sta fx_h+1
 rts
rx_height_regular:
 ; Direction LUT rays are angle-quantized, not exactly at the ideal byte centre.
 ; Transfer h to that centre with the plane slope before evaluating endpoints.
 lda fx_delta
 sta mul_a
 pha
 lda fx_delta+1
 sta mul_a+1
 pha
 jsr ss_center_magnitude
 sta mul_b
 jsr mul16x8_shift8
 lda mul_r
 sta fx_delta
 lda mul_r+1
 sta fx_delta+1
 jsr ss_center_signed
 eor #$80
 jsr fx_offset
 lda fx_h
 sta fx_base
 lda fx_h+1
 sta fx_base+1
 pla
 sta fx_delta+1
 pla
 sta fx_delta
 rts

; A bit7 chooses subtraction. Saturate at0; largest sum <24576.
fx_offset:
 bmi fx_subtract
 clc
 lda fx_base
 adc fx_delta
 sta fx_h
 lda fx_base+1
 adc fx_delta+1
 sta fx_h+1
 rts
fx_subtract:
 sec
 lda fx_base
 sbc fx_delta
 sta fx_h
 lda fx_base+1
 sbc fx_delta+1
 sta fx_h+1
 bcs fx_offset_done
 lda #0
 sta fx_h
 sta fx_h+1
fx_offset_done:
 rts

pf_project_floor:
 lda fx_h+1
 cmp #9
 bcs pf_floor_clipped
 asl
 asl
 asl
 asl
 sta fx_num
 lda fx_h
 lsr
 lsr
 lsr
 lsr
 ora fx_num
 sta fx_num
 lsr
 ; Carry is q bit0: ADC computes88+ceil(q/2), no extra rounding work.
 adc #72
 tax
pf_top:
 lda fx_h+1
 cmp #3
 bcs pf_top_clipped
 lda fx_h
 asl
 sta fx_tmp
 lda fx_h+1
 rol
 sta fx_num+1
 lda fx_tmp
 clc
 adc fx_h
 sta fx_tmp
 lda fx_num+1
 adc fx_h+1
 sta fx_num+1
 lda fx_tmp
 clc
 adc #15
 sta fx_tmp
 bcc legacy_top_shift
 inc fx_num+1
legacy_top_shift:
 lda fx_num+1
 asl
 asl
 asl
 sta fx_num
 lda fx_tmp
 lsr
 lsr
 lsr
 lsr
 lsr
 ora fx_num
 cmp #72
 bcs pf_top_clipped
 sta fx_tmp
 lda #72
 sec
 sbc fx_tmp
 rts
pf_top_clipped:
 lda #0
 rts
pf_floor_clipped:
 ldx #144
 lda #0
 rts
pf_project_front:
 lda fx_h+1
 cmp #9
 bcs pf_front_clipped
 asl
 asl
 asl
 asl
 sta fx_num
 lda fx_h
 lsr
 lsr
 lsr
 lsr
 ora fx_num
 sta fx_num
 lsr
 sta fx_tmp
 lda fx_h
 and #31
 sta fx_num+1
 lda #16
 cmp fx_num+1
 lda #72
 sbc fx_tmp
 tax
 jmp pf_top
pf_front_clipped:
 ldx #0
 lda #0
 rts
fx_project_door:
 lda fx_h+1
 cmp #10
 bcs ef_door_clipped
 lda fx_h
 clc
 adc #15
 sta fx_tmp
 lda fx_h+1
 adc #0
 asl
 asl
 asl
 sta fx_num
 lda fx_tmp
 lsr
 lsr
 lsr
 lsr
 lsr
 ora fx_num
 cmp #72
 bcs ef_door_clipped
 sta fx_tmp
 lda #72
 sec
 sbc fx_tmp
 rts
ef_door_clipped:
 lda #0
 rts
; Q11.5 half-column delta cached by world plane, only at ownership boundaries.
; The divide is outside DDA/compositor. 16 unsigned restoring steps, no SMC.
fx_slope:
 sta fx_plane
 tay
 lda fx_cache_hi,y
 bmi fx_slope_cached
 lda #0
 sta fx_sign
 lda fx_plane
 and #63
 sta fx_comp
 lda fx_plane
 and #64
 bne fx_slope_y
 lda #0
 sec
 sbc pose_x
 sta fx_den
 lda fx_comp
 sbc pose_x+1
 sta fx_den+1
 ldy pose_angle
 lda pose_angle+1
 bne fx_cos_high
 lda fx_cos,y
 jmp fx_component
fx_cos_high:
 lda fx_cos+256,y
 jmp fx_component
fx_slope_y:
 lda #0
 sec
 sbc pose_y
 sta fx_den
 lda fx_comp
 sbc pose_y+1
 sta fx_den+1
 ldy pose_angle
 lda pose_angle+1
 bne fx_sin_high
 lda fx_negsin,y
 jmp fx_component
fx_sin_high:
 lda fx_negsin+256,y
fx_component:
 bpl fx_component_positive
 eor #$ff
 clc
 adc #1
 pha
 lda #$80
 sta fx_sign
 pla
fx_component_positive:
 asl
 sta fx_num+1
 lda #0
 sta fx_num
 lda fx_den+1
 bpl fx_den_positive
 lda fx_sign
 eor #$80
 sta fx_sign
 lda #0
 sec
 sbc fx_den
 sta fx_den
 lda #0
 sbc fx_den+1
 sta fx_den+1
fx_den_positive:
 lda fx_den
 ora fx_den+1
 bne fx_divide
 sta fx_num
 sta fx_num+1
 jmp fx_save_slope
fx_divide:
 lda #0
 sta fx_rem
 sta fx_rem+1
 ldx #16
fx_divide_bit:
 asl fx_num
 rol fx_num+1
 rol fx_rem
 rol fx_rem+1
 lda fx_rem+1
 cmp fx_den+1
 bcc fx_divide_next
 bne fx_divide_sub
 lda fx_rem
 cmp fx_den
 bcc fx_divide_next
fx_divide_sub:
 sec
 lda fx_rem
 sbc fx_den
 sta fx_rem
 lda fx_rem+1
 sbc fx_den+1
 sta fx_rem+1
 inc fx_num
fx_divide_next:
 dex
 bne fx_divide_bit
 lda fx_num+1
 cmp #16
 bcc fx_save_slope
 lda #15
 sta fx_num+1
 lda #$ff
 sta fx_num
fx_save_slope:
 ldy fx_plane
 lda fx_num
 sta fx_cache_lo,y
 lda fx_sign
 lsr
 ora fx_num+1
 ora #$80
 sta fx_cache_hi,y
fx_slope_cached:
 and #15
 sta fx_delta+1
 lda fx_cache_lo,y
 sta fx_delta
 lda fx_cache_hi,y
 and #$40
 asl
 sta fx_sign
 rts

ss_active=$c8
ss_pixel=$c9
ss_sub=$ca
ss_saved_index=$cb
ss_flags=$2f00
ss_save=$2f30
ss_top=$2f70
ss_bottom=$2f74
ss_near_top=$2f78
ss_near_bottom=$2f7c
ss_near_exit=$2f80
ss_far_shade=$2f84
ss_near_shade=$2f85
ss_refined_count=$2f90
ss_steps_lo=$2f91
ss_steps_hi=$2f92
ss_rays=$2f93
ss_owner=$cb00

sr_hits=$2f94
ss_mark:
 lda #0
 sta ss_active
 sta ss_refined_count
 sta ss_steps_lo
 sta ss_steps_hi
 sta ss_rays
 sta sr_hits
 ldx #159
ss_clear_owners:
 sta ss_owner,x
 dex
 cpx #$ff
 bne ss_clear_owners
 ldx #0
 ldy #0
ss_mark_column:
 lda #0
 sta ss_flags,y
 cpx #0
 beq ss_mark_left_done
 lda lower_owner,x
 cmp lower_owner-2,x
 bne ss_mark_yes
 lda upper_owner,x
 cmp upper_owner-2,x
 bne ss_mark_yes
 lda fx_exit_plane,x
 cmp fx_exit_plane-2,x
 bne ss_mark_yes
ss_mark_left_done:
 cpx #62
 beq ss_mark_right_done
 lda lower_owner,x
 cmp lower_owner+2,x
 bne ss_mark_yes
 lda upper_owner,x
 cmp upper_owner+2,x
 bne ss_mark_yes
 lda fx_exit_plane,x
 cmp fx_exit_plane+2,x
 bne ss_mark_yes
ss_mark_right_done:
 jmp ss_mark_next
ss_mark_yes:
 lda #1
 sta ss_flags,y
 inc ss_refined_count
ss_mark_next:
 inx
 inx
 iny
 cpy #32
 bne ss_mark_column
 rts

ss_center_magnitude:
 lda ss_active
 beq ss_old_magnitude
 ldy ss_pixel
 lda ss_center_mag,y
 rts
ss_old_magnitude:
 ldy fx_col
 lda fx_center_mag,y
 rts
ss_center_signed:
 lda ss_active
 beq ss_old_sign
 ldy ss_pixel
 lda fx_sign
 eor ss_center_sign,y
 rts
ss_old_sign:
 ldy fx_col
 lda fx_sign
 eor fx_center_sign,y
 rts

ss_refine:
 lda col
 asl
 sta ss_saved_index
 sta ray_index
 tax
 lda smooth_ids,x
 sta ss_save+16
 lda smooth_ids+1,x
 sta ss_save+17
 lda lower_owner,x
 sta ss_save+20
 lda lower_side,x
 sta ss_save+21
 lda saved_lower_depth,x
 sta ss_save+22
 lda saved_lower_depth_hi,x
 sta ss_save+23
 lda upper_owner,x
 sta ss_save+26
 lda upper_side,x
 sta ss_save+27
 lda exit_depth,x
 sta ss_save+29
 lda exit_depth_hi,x
 sta ss_save+30
 lda fx_near_depth,x
 sta ss_save+31
 lda fx_near_depth_hi,x
 sta ss_save+32
 lda fx_near_plane,x
 sta ss_save+33
 lda fx_exit_plane,x
 sta ss_save+34
 lda ray_offset_lo,x
 sta ss_save+35
 lda ray_offset_hi,x
 sta ss_save+36
 lda ray_cos,x
 sta ss_save+37
 lda ray_cos_axis,x
 sta ss_save+38
 lda #1
 sta ss_active
 lda #0
 sta ss_sub
 sta ss_far_shade
 sta ss_near_shade
ss_sample:
 lda col
 asl
 asl
 clc
 adc ss_sub
 sta ss_pixel
 tay
 ldx ss_saved_index
 stx ray_index
 ; Adjacent subpixels may have exactly the same quantized direction. Reuse
 ; that SAME-view geometric result; still project/sample each pixel separately.
 lda ss_offset_lo,y
 cmp ray_offset_lo,x
 bne ss_cast_sample
 lda ss_offset_hi,y
 cmp ray_offset_hi,x
 beq ss_reuse_sample
ss_cast_sample:
 inc ss_rays
 lda ss_offset_lo,y
 cmp ss_save+35
 bne sr_cast_new
 lda ss_offset_hi,y
 cmp ss_save+36
 bne sr_cast_new
 ; Same pose, direction, cosine and map: exact saved main-ray result.
 jsr sr_restore_coarse
 lda ray_steps,x
 sta steps
 inc sr_hits
 jmp sr_accumulate_steps
sr_cast_new:
 lda ss_offset_lo,y
 sta ray_offset_lo,x
 lda ss_offset_hi,y
 sta ray_offset_hi,x
 lda ss_cos,y
 sta ray_cos,x
 lda ss_cos_axis,y
 sta ray_cos_axis,x
 jsr ray_next
sr_accumulate_steps:
 ldx ss_saved_index
 lda steps
 clc
 adc ss_steps_lo
 sta ss_steps_lo
 bcc ss_steps_done
 inc ss_steps_hi
ss_steps_done:
ss_reuse_sample:
 ldx ss_saved_index
 lda lower_owner,x
 ldy ss_pixel
 sta ss_owner,y
 tay
 lda fx_wall_plane,y
 jsr fx_slope
 ldx ss_saved_index
 lda saved_lower_depth_hi,x
 ldy saved_lower_depth,x
 jsr fx_height
 jsr pf_project_floor
 ldy ss_sub
 sta ss_top,y
 txa
 sta ss_bottom,y
 ldx ss_saved_index
 lda lower_side,x
 eor #3
 asl ss_far_shade
 asl ss_far_shade
 ora ss_far_shade
 sta ss_far_shade
 lda upper_owner,x
 bne ss_upper
 lda #0
 ldy ss_sub
 sta ss_near_top,y
 sta ss_near_bottom,y
 sta ss_near_exit,y
 jmp ss_upper_shade
ss_upper:
 lda fx_near_plane,x
 cmp #$ff
 bne ss_upper_front
 lda #0
 ldy ss_sub
 sta ss_near_top,y
 sta ss_near_bottom,y
 jmp ss_upper_exit
ss_upper_front:
 jsr fx_slope
 ldx ss_saved_index
 lda fx_near_depth_hi,x
 ldy fx_near_depth,x
 jsr fx_height
 jsr pf_project_front
 ldy ss_sub
 sta ss_near_top,y
 txa
 sta ss_near_bottom,y
ss_upper_exit:
 ldx ss_saved_index
 lda fx_exit_plane,x
 jsr fx_slope
 ldx ss_saved_index
 lda exit_depth_hi,x
 ldy exit_depth,x
 jsr fx_height
 jsr fx_project_door
 ldy ss_sub
 cmp ss_near_bottom,y
 bcs ss_exit_ordered
 lda ss_near_bottom,y
ss_exit_ordered:
 sta ss_near_exit,y
 ldx ss_saved_index
 lda upper_side,x
 eor #3
ss_upper_shade:
 asl ss_near_shade
 asl ss_near_shade
 ora ss_near_shade
 sta ss_near_shade
 inc ss_sub
 lda ss_sub
 cmp #4
 bne ss_sample
 ldx ss_saved_index
 jsr sr_restore_coarse
 lda #0
 sta ss_active
 rts
sr_restore_coarse:
 lda ss_save+16
 sta smooth_ids,x
 lda ss_save+17
 sta smooth_ids+1,x
 lda ss_save+20
 sta lower_owner,x
 lda ss_save+21
 sta lower_side,x
 lda ss_save+22
 sta saved_lower_depth,x
 lda ss_save+23
 sta saved_lower_depth_hi,x
 lda ss_save+26
 sta upper_owner,x
 lda ss_save+27
 sta upper_side,x
 lda ss_save+29
 sta exit_depth,x
 lda ss_save+30
 sta exit_depth_hi,x
 lda ss_save+31
 sta fx_near_depth,x
 lda ss_save+32
 sta fx_near_depth_hi,x
 lda ss_save+33
 sta fx_near_plane,x
 lda ss_save+34
 sta fx_exit_plane,x
 lda ss_save+35
 sta ray_offset_lo,x
 lda ss_save+36
 sta ray_offset_hi,x
 lda ss_save+37
 sta ray_cos,x
 lda ss_save+38
 sta ray_cos_axis,x
 rts
ss_compose:
 ldx #3
ss_copy_0:
 lda ss_top,x
 sta top_samples,x
 lda ss_bottom,x
 sta bottom_samples,x
 dex
 bpl ss_copy_0
 lda ss_far_shade
 sta band_shade
 jsr ss_draw_band
 lda ss_near_shade
 beq oc_no_near_band
 ldx #3
ss_copy_1:
 lda ss_near_top,x
 sta top_samples,x
 lda ss_near_bottom,x
 sta bottom_samples,x
 dex
 bpl ss_copy_1
 lda ss_near_shade
 sta band_shade
 jsr oc_near_refined
 ldx #3
ss_copy_2:
 lda ss_near_bottom,x
 sta top_samples,x
 lda ss_near_exit,x
 sta bottom_samples,x
 dex
 bpl ss_copy_2
 lda #$55
 sta band_shade
 jsr oc_near_refined
oc_no_near_band:
 rts
ss_draw_band:
 lda top_samples
 ldx #1
ss_top_min_loop:
 cmp top_samples,x
 bcc ss_top_min_next
 lda top_samples,x
ss_top_min_next:
 inx
 cpx #4
 bne ss_top_min_loop
 lsr
 lsr
 lsr
 sta band_row
 lda top_samples
 ldx #1
ss_top_max_loop:
 cmp top_samples,x
 bcs ss_top_max_next
 lda top_samples,x
ss_top_max_next:
 inx
 cpx #4
 bne ss_top_max_loop
 clc
 adc #7
 lsr
 lsr
 lsr
 sta band_top_end
 lda bottom_samples
 ldx #1
ss_bottom_min_loop:
 cmp bottom_samples,x
 bcc ss_bottom_min_next
 lda bottom_samples,x
ss_bottom_min_next:
 inx
 cpx #4
 bne ss_bottom_min_loop
 lsr
 lsr
 lsr
 sta band_bottom_start
 lda bottom_samples
 ldx #1
ss_bottom_max_loop:
 cmp bottom_samples,x
 bcs ss_bottom_max_next
 lda bottom_samples,x
ss_bottom_max_next:
 inx
 cpx #4
 bne ss_bottom_max_loop
 clc
 adc #7
 lsr
 lsr
 lsr
 sta band_last
 jsr ef_clear_gaps
 jmp band_next_row

; Fine samples: direct final geometry only, no coarse-height projection.
rx_store:
 ldx ray_index
 lda hit_mat
 cmp #9
 bcs rx_overhead
 lda mul_r
 sta saved_lower_depth,x
 lda mul_r+1
 sta saved_lower_depth_hi,x
 jsr store_wall_owner
 lda smooth_ids,x
 sta lower_owner,x
 lda hit_side
 sta lower_side,x
 rts
rx_overhead:
 lda mul_r
 sta fx_near_depth,x
 lda mul_r+1
 sta fx_near_depth_hi,x
 lda hit_side
 sta upper_side,x
 asl
 asl
 asl
 asl
 clc
 adc hit_mat
 sta upper_owner,x
 lda #$ff
 ldy portal_inside
 bne rx_inside
 lda hit_side
 jsr fx_capture_plane
rx_inside:
 sta fx_near_plane,x
 jsr portal_exit
 lda exit_side
 jsr fx_capture_plane
 sta fx_exit_plane,x
 jmp rx_continue_portal
oc_near_regular:
 lda band_tl
 ora band_tr
 ora band_bl
 ora band_br
 bne oc_regular_nonempty
 rts
oc_regular_nonempty:
 jmp draw_band
oc_near_refined:
 lda top_samples
 ora top_samples+1
 ora top_samples+2
 ora top_samples+3
 ora bottom_samples
 ora bottom_samples+1
 ora bottom_samples+2
 ora bottom_samples+3
 bne oc_refined_nonempty
 rts
oc_refined_nonempty:
 jmp ss_draw_band
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
 lda #<2406
 sta cam_x
 lda #>2406
 sta cam_x+1
 lda #<4864
 sta cam_y
 lda #>4864
 sta cam_y+1
 lda #<128
 sta cam_angle
 lda #>128
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
 cmp #36
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

code_end:
.if code_end > $2f00
 .error "portal code overlaps layer buffers"
.endif
*=$3c00
 .binary "map.bin"
*=$4000
 .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$08,$08,$08,$08,$08,$08,$08
 .byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
 .byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
 .byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
 .byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
 .byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
 .byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
 .byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
 .byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
 .byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
 .byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
 .byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
 .byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
 .byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
 .byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
 .byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
 .byte $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$3f,$3f,$3f,$3f,$3f
 .byte $3f,$3f,$3e,$3e,$3e,$3e,$3e,$3d,$3d,$3d,$3d,$3d,$3c,$3c,$3c,$3b
 .byte $3b,$3b,$3b,$3a,$3a,$3a,$39,$39,$38,$38,$38,$37,$37,$36,$36,$36
 .byte $35,$35,$34,$34,$33,$33,$32,$32,$31,$31,$30,$30,$2f,$2f,$2e,$2e
 .byte $2d,$2d,$2c,$2c,$2b,$2a,$2a,$29,$29,$28,$27,$27,$26,$25,$25,$24
 .byte $24,$23,$22,$22,$21,$20,$20,$1f,$1e,$1d,$1d,$1c,$1b,$1b,$1a,$19
 .byte $18,$18,$17,$16,$16,$15,$14,$13,$13,$12,$11,$10,$10,$0f,$0e,$0d
 .byte $0c,$0c,$0b,$0a,$09,$09,$08,$07,$06,$05,$05,$04,$03,$02,$02,$01
 .byte $00,$ff,$fe,$fe,$fd,$fc,$fb,$fb,$fa,$f9,$f8,$f7,$f7,$f6,$f5,$f4
 .byte $f4,$f3,$f2,$f1,$f0,$f0,$ef,$ee,$ed,$ed,$ec,$eb,$ea,$ea,$e9,$e8
 .byte $e8,$e7,$e6,$e5,$e5,$e4,$e3,$e3,$e2,$e1,$e0,$e0,$df,$de,$de,$dd
 .byte $dc,$dc,$db,$db,$da,$d9,$d9,$d8,$d7,$d7,$d6,$d6,$d5,$d4,$d4,$d3
 .byte $d3,$d2,$d2,$d1,$d1,$d0,$d0,$cf,$cf,$ce,$ce,$cd,$cd,$cc,$cc,$cb
 .byte $cb,$ca,$ca,$ca,$c9,$c9,$c8,$c8,$c8,$c7,$c7,$c6,$c6,$c6,$c5,$c5
 .byte $c5,$c5,$c4,$c4,$c4,$c3,$c3,$c3,$c3,$c3,$c2,$c2,$c2,$c2,$c2,$c1
 .byte $c1,$c1,$c1,$c1,$c1,$c1,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c1,$c1,$c1,$c1,$c1
 .byte $c1,$c1,$c2,$c2,$c2,$c2,$c2,$c3,$c3,$c3,$c3,$c3,$c4,$c4,$c4,$c5
 .byte $c5,$c5,$c5,$c6,$c6,$c6,$c7,$c7,$c8,$c8,$c8,$c9,$c9,$ca,$ca,$ca
 .byte $cb,$cb,$cc,$cc,$cd,$cd,$ce,$ce,$cf,$cf,$d0,$d0,$d1,$d1,$d2,$d2
 .byte $d3,$d3,$d4,$d4,$d5,$d6,$d6,$d7,$d7,$d8,$d9,$d9,$da,$db,$db,$dc
 .byte $dc,$dd,$de,$de,$df,$e0,$e0,$e1,$e2,$e3,$e3,$e4,$e5,$e5,$e6,$e7
 .byte $e8,$e8,$e9,$ea,$ea,$eb,$ec,$ed,$ed,$ee,$ef,$f0,$f0,$f1,$f2,$f3
 .byte $f4,$f4,$f5,$f6,$f7,$f7,$f8,$f9,$fa,$fb,$fb,$fc,$fd,$fe,$fe,$ff
 .byte $00,$01,$02,$02,$03,$04,$05,$05,$06,$07,$08,$09,$09,$0a,$0b,$0c
 .byte $0c,$0d,$0e,$0f,$10,$10,$11,$12,$13,$13,$14,$15,$16,$16,$17,$18
 .byte $18,$19,$1a,$1b,$1b,$1c,$1d,$1d,$1e,$1f,$20,$20,$21,$22,$22,$23
 .byte $24,$24,$25,$25,$26,$27,$27,$28,$29,$29,$2a,$2a,$2b,$2c,$2c,$2d
 .byte $2d,$2e,$2e,$2f,$2f,$30,$30,$31,$31,$32,$32,$33,$33,$34,$34,$35
 .byte $35,$36,$36,$36,$37,$37,$38,$38,$38,$39,$39,$3a,$3a,$3a,$3b,$3b
 .byte $3b,$3b,$3c,$3c,$3c,$3d,$3d,$3d,$3d,$3d,$3e,$3e,$3e,$3e,$3e,$3f
 .byte $3f,$3f,$3f,$3f,$3f,$3f,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
 .byte $00,$09,$12,$1b,$24,$2d,$36,$3f,$48,$a5,$a5,$a5,$a5,$a5,$a5,$a5
 .byte $a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5
 .byte $a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5
 .byte $a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5
 .byte $a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5
 .byte $a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5
 .byte $a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5
 .byte $a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5
 .byte $a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5
 .byte $a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5
 .byte $a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5
 .byte $a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5
 .byte $a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5
 .byte $a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5
 .byte $a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5
 .byte $a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5
*=$4400
ss_offset_lo:
 .byte $d6,$d6,$d7,$d7,$d8,$d8,$d9,$da,$da,$db,$db,$dc,$dd,$dd,$de,$de
 .byte $df,$e0,$e0,$e1,$e2,$e2,$e3,$e3,$e4,$e5,$e5,$e6,$e7,$e7,$e8,$e9
 .byte $e9,$ea,$eb,$eb,$ec,$ed,$ee,$ee,$ef,$f0,$f0,$f1,$f2,$f3,$f3,$f4
 .byte $f5,$f5,$f6,$f7,$f8,$f8,$f9,$fa,$fa,$fb,$fc,$fd,$fd,$fe,$ff,$00
 .byte $00,$01,$02,$03,$03,$04,$05,$06,$06,$07,$08,$08,$09,$0a,$0b,$0b
 .byte $0c,$0d,$0d,$0e,$0f,$10,$10,$11,$12,$12,$13,$14,$15,$15,$16,$17
 .byte $17,$18,$19,$19,$1a,$1b,$1b,$1c,$1d,$1d,$1e,$1e,$1f,$20,$20,$21
 .byte $22,$22,$23,$23,$24,$25,$25,$26,$26,$27,$28,$28,$29,$29,$2a,$2a
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
ss_offset_hi:
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
ss_cos:
 .byte $df,$df,$e0,$e0,$e2,$e2,$e3,$e5,$e5,$e6,$e6,$e7,$e9,$e9,$ea,$ea
 .byte $eb,$ed,$ed,$ee,$ef,$ef,$f0,$f0,$f1,$f2,$f2,$f3,$f4,$f4,$f5,$f6
 .byte $f6,$f7,$f8,$f8,$f8,$f9,$fa,$fa,$fa,$fb,$fb,$fc,$fc,$fd,$fd,$fd
 .byte $fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$fe,$fe,$fe,$fe
 .byte $fd,$fd,$fd,$fc,$fc,$fb,$fb,$fa,$fa,$fa,$f9,$f8,$f8,$f8,$f7,$f6
 .byte $f6,$f5,$f4,$f4,$f3,$f2,$f2,$f1,$f0,$f0,$ef,$ef,$ee,$ed,$ed,$eb
 .byte $ea,$ea,$e9,$e9,$e7,$e6,$e6,$e5,$e5,$e3,$e2,$e2,$e0,$e0,$df,$df
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
ss_cos_axis:
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
ss_center_mag:
 .byte $5a,$26,$3e,$42,$20,$60,$02,$5a,$26,$33,$4d,$09,$5d,$23,$2e,$52
 .byte $02,$4b,$35,$16,$5f,$21,$26,$5a,$15,$2f,$51,$0f,$31,$4f,$10,$2d
 .byte $53,$17,$24,$5c,$22,$16,$4e,$32,$04,$3a,$46,$12,$22,$55,$2b,$07
 .byte $39,$47,$16,$1a,$4b,$35,$06,$29,$57,$28,$07,$35,$4b,$1c,$12,$40
 .byte $40,$12,$1c,$4b,$35,$07,$28,$57,$29,$06,$35,$4b,$1a,$16,$47,$39
 .byte $07,$2b,$55,$22,$12,$46,$3a,$04,$32,$4e,$16,$22,$5c,$24,$17,$53
 .byte $2d,$10,$4f,$31,$0f,$51,$2f,$15,$5a,$26,$21,$5f,$16,$35,$4b,$02
 .byte $52,$2e,$23,$5d,$09,$4d,$33,$26,$5a,$02,$60,$20,$42,$3e,$26,$5a
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
ss_center_sign:
 .byte $00,$80,$00,$80,$00,$80,$80,$00,$80,$00,$80,$00,$00,$80,$00,$80
 .byte $80,$00,$80,$00,$00,$80,$00,$80,$80,$00,$80,$80,$00,$80,$80,$00
 .byte $80,$80,$00,$80,$80,$00,$00,$80,$00,$00,$80,$80,$00,$00,$80,$00
 .byte $00,$80,$80,$00,$00,$80,$80,$00,$80,$80,$00,$00,$80,$80,$00,$00
 .byte $80,$80,$00,$00,$80,$80,$00,$00,$80,$00,$00,$80,$80,$00,$00,$80
 .byte $80,$00,$80,$80,$00,$00,$80,$80,$00,$80,$80,$00,$00,$80,$00,$00
 .byte $80,$00,$00,$80,$00,$00,$80,$00,$00,$80,$00,$80,$80,$00,$80,$00
 .byte $00,$80,$00,$80,$80,$00,$80,$00,$80,$00,$00,$80,$00,$80,$00,$80
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
ss_table_end:
.if ss_table_end > $4800
 .error "coverage tables overlap edge LUTs"
.endif
*=$4800
slope_pos_0:
 .byte $00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$03,$03,$03,$03,$03,$03,$03,$03,$04,$04,$04
 .byte $04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$05,$05,$06,$06,$06
 .byte $06,$06,$06,$06,$06,$07,$07,$07,$07,$07,$07,$07,$07,$08,$08,$08
 .byte $08,$08,$08,$08,$08,$09,$09,$09,$09,$09,$09,$09,$09,$0a,$0a,$0a
 .byte $0a,$0a,$0a,$0a,$0a,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0c,$0c,$0c
 .byte $0c,$0c,$0c,$0c,$0c,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0e,$0e,$0e
 .byte $0e,$0e,$0e,$0e,$0e,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$10,$10,$10
 .byte $10,$10,$10,$10,$10,$11,$11,$11,$11,$11,$11,$11,$11,$12,$12,$12
 .byte $12,$12,$12,$12,$12,$13,$13,$13,$13,$13,$13,$13,$13,$14,$14,$14
 .byte $14,$14,$14,$14,$14,$15,$15,$15,$15,$15,$15,$15,$15,$16,$16,$16
 .byte $16,$16,$16,$16,$16,$17,$17,$17,$17,$17,$17,$17,$17,$18,$18,$18
 .byte $18,$18,$18,$18,$18,$19,$19,$19,$19,$19,$19,$19,$19,$1a,$1a,$1a
 .byte $1a,$1a,$1a,$1a,$1a,$1b,$1b,$1b,$1b,$1b,$1b,$1b,$1b,$1c,$1c,$1c
 .byte $1c,$1c,$1c,$1c,$1c,$1d,$1d,$1d,$1d,$1d,$1d,$1d,$1d,$1e,$1e,$1e
 .byte $1e,$1e,$1e,$1e,$1e,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$20,$20,$20
slope_pos_1:
 .byte $00,$00,$01,$01,$01,$02,$02,$03,$03,$03,$04,$04,$04,$05,$05,$06
 .byte $06,$06,$07,$07,$07,$08,$08,$09,$09,$09,$0a,$0a,$0a,$0b,$0b,$0c
 .byte $0c,$0c,$0d,$0d,$0d,$0e,$0e,$0f,$0f,$0f,$10,$10,$10,$11,$11,$12
 .byte $12,$12,$13,$13,$13,$14,$14,$15,$15,$15,$16,$16,$16,$17,$17,$18
 .byte $18,$18,$19,$19,$19,$1a,$1a,$1b,$1b,$1b,$1c,$1c,$1c,$1d,$1d,$1e
 .byte $1e,$1e,$1f,$1f,$1f,$20,$20,$21,$21,$21,$22,$22,$22,$23,$23,$24
 .byte $24,$24,$25,$25,$25,$26,$26,$27,$27,$27,$28,$28,$28,$29,$29,$2a
 .byte $2a,$2a,$2b,$2b,$2b,$2c,$2c,$2d,$2d,$2d,$2e,$2e,$2e,$2f,$2f,$30
 .byte $30,$30,$31,$31,$31,$32,$32,$33,$33,$33,$34,$34,$34,$35,$35,$36
 .byte $36,$36,$37,$37,$37,$38,$38,$39,$39,$39,$3a,$3a,$3a,$3b,$3b,$3c
 .byte $3c,$3c,$3d,$3d,$3d,$3e,$3e,$3f,$3f,$3f,$40,$40,$40,$41,$41,$42
 .byte $42,$42,$43,$43,$43,$44,$44,$45,$45,$45,$46,$46,$46,$47,$47,$48
 .byte $48,$48,$49,$49,$49,$4a,$4a,$4b,$4b,$4b,$4c,$4c,$4c,$4d,$4d,$4e
 .byte $4e,$4e,$4f,$4f,$4f,$50,$50,$51,$51,$51,$52,$52,$52,$53,$53,$54
 .byte $54,$54,$55,$55,$55,$56,$56,$57,$57,$57,$58,$58,$58,$59,$59,$5a
 .byte $5a,$5a,$5b,$5b,$5b,$5c,$5c,$5d,$5d,$5d,$5e,$5e,$5e,$5f,$5f,$60
slope_pos_2:
 .byte $00,$01,$01,$02,$02,$03,$04,$04,$05,$06,$06,$07,$07,$08,$09,$09
 .byte $0a,$0b,$0b,$0c,$0c,$0d,$0e,$0e,$0f,$10,$10,$11,$11,$12,$13,$13
 .byte $14,$15,$15,$16,$16,$17,$18,$18,$19,$1a,$1a,$1b,$1b,$1c,$1d,$1d
 .byte $1e,$1f,$1f,$20,$20,$21,$22,$22,$23,$24,$24,$25,$25,$26,$27,$27
 .byte $28,$29,$29,$2a,$2a,$2b,$2c,$2c,$2d,$2e,$2e,$2f,$2f,$30,$31,$31
 .byte $32,$33,$33,$34,$34,$35,$36,$36,$37,$38,$38,$39,$39,$3a,$3b,$3b
 .byte $3c,$3d,$3d,$3e,$3e,$3f,$40,$40,$41,$42,$42,$43,$43,$44,$45,$45
 .byte $46,$47,$47,$48,$48,$49,$4a,$4a,$4b,$4c,$4c,$4d,$4d,$4e,$4f,$4f
 .byte $50,$51,$51,$52,$52,$53,$54,$54,$55,$56,$56,$57,$57,$58,$59,$59
 .byte $5a,$5b,$5b,$5c,$5c,$5d,$5e,$5e,$5f,$60,$60,$61,$61,$62,$63,$63
 .byte $64,$65,$65,$66,$66,$67,$68,$68,$69,$6a,$6a,$6b,$6b,$6c,$6d,$6d
 .byte $6e,$6f,$6f,$70,$70,$71,$72,$72,$73,$74,$74,$75,$75,$76,$77,$77
 .byte $78,$79,$79,$7a,$7a,$7b,$7c,$7c,$7d,$7e,$7e,$7f,$7f,$80,$81,$81
 .byte $82,$83,$83,$84,$84,$85,$86,$86,$87,$88,$88,$89,$89,$8a,$8b,$8b
 .byte $8c,$8d,$8d,$8e,$8e,$8f,$90,$90,$91,$92,$92,$93,$93,$94,$95,$95
 .byte $96,$97,$97,$98,$98,$99,$9a,$9a,$9b,$9c,$9c,$9d,$9d,$9e,$9f,$9f
slope_pos_3:
 .byte $00,$01,$02,$03,$03,$04,$05,$06,$07,$08,$09,$0a,$0a,$0b,$0c,$0d
 .byte $0e,$0f,$10,$11,$11,$12,$13,$14,$15,$16,$17,$18,$18,$19,$1a,$1b
 .byte $1c,$1d,$1e,$1f,$1f,$20,$21,$22,$23,$24,$25,$26,$26,$27,$28,$29
 .byte $2a,$2b,$2c,$2d,$2d,$2e,$2f,$30,$31,$32,$33,$34,$34,$35,$36,$37
 .byte $38,$39,$3a,$3b,$3b,$3c,$3d,$3e,$3f,$40,$41,$42,$42,$43,$44,$45
 .byte $46,$47,$48,$49,$49,$4a,$4b,$4c,$4d,$4e,$4f,$50,$50,$51,$52,$53
 .byte $54,$55,$56,$57,$57,$58,$59,$5a,$5b,$5c,$5d,$5e,$5e,$5f,$60,$61
 .byte $62,$63,$64,$65,$65,$66,$67,$68,$69,$6a,$6b,$6c,$6c,$6d,$6e,$6f
 .byte $70,$71,$72,$73,$73,$74,$75,$76,$77,$78,$79,$7a,$7a,$7b,$7c,$7d
 .byte $7e,$7f,$80,$81,$81,$82,$83,$84,$85,$86,$87,$88,$88,$89,$8a,$8b
 .byte $8c,$8d,$8e,$8f,$8f,$90,$91,$92,$93,$94,$95,$96,$96,$97,$98,$99
 .byte $9a,$9b,$9c,$9d,$9d,$9e,$9f,$a0,$a1,$a2,$a3,$a4,$a4,$a5,$a6,$a7
 .byte $a8,$a9,$aa,$ab,$ab,$ac,$ad,$ae,$af,$b0,$b1,$b2,$b2,$b3,$b4,$b5
 .byte $b6,$b7,$b8,$b9,$b9,$ba,$bb,$bc,$bd,$be,$bf,$c0,$c0,$c1,$c2,$c3
 .byte $c4,$c5,$c6,$c7,$c7,$c8,$c9,$ca,$cb,$cc,$cd,$ce,$ce,$cf,$d0,$d1
 .byte $d2,$d3,$d4,$d5,$d5,$d6,$d7,$d8,$d9,$da,$db,$dc,$dc,$dd,$de,$df
slope_neg_0:
 .byte $e0,$e0,$e0,$e0,$e0,$e1,$e1,$e1,$e1,$e1,$e1,$e1,$e1,$e2,$e2,$e2
 .byte $e2,$e2,$e2,$e2,$e2,$e3,$e3,$e3,$e3,$e3,$e3,$e3,$e3,$e4,$e4,$e4
 .byte $e4,$e4,$e4,$e4,$e4,$e5,$e5,$e5,$e5,$e5,$e5,$e5,$e5,$e6,$e6,$e6
 .byte $e6,$e6,$e6,$e6,$e6,$e7,$e7,$e7,$e7,$e7,$e7,$e7,$e7,$e8,$e8,$e8
 .byte $e8,$e8,$e8,$e8,$e8,$e9,$e9,$e9,$e9,$e9,$e9,$e9,$e9,$ea,$ea,$ea
 .byte $ea,$ea,$ea,$ea,$ea,$eb,$eb,$eb,$eb,$eb,$eb,$eb,$eb,$ec,$ec,$ec
 .byte $ec,$ec,$ec,$ec,$ec,$ed,$ed,$ed,$ed,$ed,$ed,$ed,$ed,$ee,$ee,$ee
 .byte $ee,$ee,$ee,$ee,$ee,$ef,$ef,$ef,$ef,$ef,$ef,$ef,$ef,$f0,$f0,$f0
 .byte $f0,$f0,$f0,$f0,$f0,$f1,$f1,$f1,$f1,$f1,$f1,$f1,$f1,$f2,$f2,$f2
 .byte $f2,$f2,$f2,$f2,$f2,$f3,$f3,$f3,$f3,$f3,$f3,$f3,$f3,$f4,$f4,$f4
 .byte $f4,$f4,$f4,$f4,$f4,$f5,$f5,$f5,$f5,$f5,$f5,$f5,$f5,$f6,$f6,$f6
 .byte $f6,$f6,$f6,$f6,$f6,$f7,$f7,$f7,$f7,$f7,$f7,$f7,$f7,$f8,$f8,$f8
 .byte $f8,$f8,$f8,$f8,$f8,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$fa,$fa,$fa
 .byte $fa,$fa,$fa,$fa,$fa,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fb,$fc,$fc,$fc
 .byte $fc,$fc,$fc,$fc,$fc,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fd,$fe,$fe,$fe
 .byte $fe,$fe,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00
slope_neg_1:
 .byte $a0,$a0,$a1,$a1,$a1,$a2,$a2,$a3,$a3,$a3,$a4,$a4,$a4,$a5,$a5,$a6
 .byte $a6,$a6,$a7,$a7,$a7,$a8,$a8,$a9,$a9,$a9,$aa,$aa,$aa,$ab,$ab,$ac
 .byte $ac,$ac,$ad,$ad,$ad,$ae,$ae,$af,$af,$af,$b0,$b0,$b0,$b1,$b1,$b2
 .byte $b2,$b2,$b3,$b3,$b3,$b4,$b4,$b5,$b5,$b5,$b6,$b6,$b6,$b7,$b7,$b8
 .byte $b8,$b8,$b9,$b9,$b9,$ba,$ba,$bb,$bb,$bb,$bc,$bc,$bc,$bd,$bd,$be
 .byte $be,$be,$bf,$bf,$bf,$c0,$c0,$c1,$c1,$c1,$c2,$c2,$c2,$c3,$c3,$c4
 .byte $c4,$c4,$c5,$c5,$c5,$c6,$c6,$c7,$c7,$c7,$c8,$c8,$c8,$c9,$c9,$ca
 .byte $ca,$ca,$cb,$cb,$cb,$cc,$cc,$cd,$cd,$cd,$ce,$ce,$ce,$cf,$cf,$d0
 .byte $d0,$d0,$d1,$d1,$d1,$d2,$d2,$d3,$d3,$d3,$d4,$d4,$d4,$d5,$d5,$d6
 .byte $d6,$d6,$d7,$d7,$d7,$d8,$d8,$d9,$d9,$d9,$da,$da,$da,$db,$db,$dc
 .byte $dc,$dc,$dd,$dd,$dd,$de,$de,$df,$df,$df,$e0,$e0,$e0,$e1,$e1,$e2
 .byte $e2,$e2,$e3,$e3,$e3,$e4,$e4,$e5,$e5,$e5,$e6,$e6,$e6,$e7,$e7,$e8
 .byte $e8,$e8,$e9,$e9,$e9,$ea,$ea,$eb,$eb,$eb,$ec,$ec,$ec,$ed,$ed,$ee
 .byte $ee,$ee,$ef,$ef,$ef,$f0,$f0,$f1,$f1,$f1,$f2,$f2,$f2,$f3,$f3,$f4
 .byte $f4,$f4,$f5,$f5,$f5,$f6,$f6,$f7,$f7,$f7,$f8,$f8,$f8,$f9,$f9,$fa
 .byte $fa,$fa,$fb,$fb,$fb,$fc,$fc,$fd,$fd,$fd,$fe,$fe,$fe,$ff,$ff,$00
slope_neg_2:
 .byte $60,$61,$61,$62,$62,$63,$64,$64,$65,$66,$66,$67,$67,$68,$69,$69
 .byte $6a,$6b,$6b,$6c,$6c,$6d,$6e,$6e,$6f,$70,$70,$71,$71,$72,$73,$73
 .byte $74,$75,$75,$76,$76,$77,$78,$78,$79,$7a,$7a,$7b,$7b,$7c,$7d,$7d
 .byte $7e,$7f,$7f,$80,$80,$81,$82,$82,$83,$84,$84,$85,$85,$86,$87,$87
 .byte $88,$89,$89,$8a,$8a,$8b,$8c,$8c,$8d,$8e,$8e,$8f,$8f,$90,$91,$91
 .byte $92,$93,$93,$94,$94,$95,$96,$96,$97,$98,$98,$99,$99,$9a,$9b,$9b
 .byte $9c,$9d,$9d,$9e,$9e,$9f,$a0,$a0,$a1,$a2,$a2,$a3,$a3,$a4,$a5,$a5
 .byte $a6,$a7,$a7,$a8,$a8,$a9,$aa,$aa,$ab,$ac,$ac,$ad,$ad,$ae,$af,$af
 .byte $b0,$b1,$b1,$b2,$b2,$b3,$b4,$b4,$b5,$b6,$b6,$b7,$b7,$b8,$b9,$b9
 .byte $ba,$bb,$bb,$bc,$bc,$bd,$be,$be,$bf,$c0,$c0,$c1,$c1,$c2,$c3,$c3
 .byte $c4,$c5,$c5,$c6,$c6,$c7,$c8,$c8,$c9,$ca,$ca,$cb,$cb,$cc,$cd,$cd
 .byte $ce,$cf,$cf,$d0,$d0,$d1,$d2,$d2,$d3,$d4,$d4,$d5,$d5,$d6,$d7,$d7
 .byte $d8,$d9,$d9,$da,$da,$db,$dc,$dc,$dd,$de,$de,$df,$df,$e0,$e1,$e1
 .byte $e2,$e3,$e3,$e4,$e4,$e5,$e6,$e6,$e7,$e8,$e8,$e9,$e9,$ea,$eb,$eb
 .byte $ec,$ed,$ed,$ee,$ee,$ef,$f0,$f0,$f1,$f2,$f2,$f3,$f3,$f4,$f5,$f5
 .byte $f6,$f7,$f7,$f8,$f8,$f9,$fa,$fa,$fb,$fc,$fc,$fd,$fd,$fe,$ff,$ff
slope_neg_3:
 .byte $20,$21,$22,$23,$23,$24,$25,$26,$27,$28,$29,$2a,$2a,$2b,$2c,$2d
 .byte $2e,$2f,$30,$31,$31,$32,$33,$34,$35,$36,$37,$38,$38,$39,$3a,$3b
 .byte $3c,$3d,$3e,$3f,$3f,$40,$41,$42,$43,$44,$45,$46,$46,$47,$48,$49
 .byte $4a,$4b,$4c,$4d,$4d,$4e,$4f,$50,$51,$52,$53,$54,$54,$55,$56,$57
 .byte $58,$59,$5a,$5b,$5b,$5c,$5d,$5e,$5f,$60,$61,$62,$62,$63,$64,$65
 .byte $66,$67,$68,$69,$69,$6a,$6b,$6c,$6d,$6e,$6f,$70,$70,$71,$72,$73
 .byte $74,$75,$76,$77,$77,$78,$79,$7a,$7b,$7c,$7d,$7e,$7e,$7f,$80,$81
 .byte $82,$83,$84,$85,$85,$86,$87,$88,$89,$8a,$8b,$8c,$8c,$8d,$8e,$8f
 .byte $90,$91,$92,$93,$93,$94,$95,$96,$97,$98,$99,$9a,$9a,$9b,$9c,$9d
 .byte $9e,$9f,$a0,$a1,$a1,$a2,$a3,$a4,$a5,$a6,$a7,$a8,$a8,$a9,$aa,$ab
 .byte $ac,$ad,$ae,$af,$af,$b0,$b1,$b2,$b3,$b4,$b5,$b6,$b6,$b7,$b8,$b9
 .byte $ba,$bb,$bc,$bd,$bd,$be,$bf,$c0,$c1,$c2,$c3,$c4,$c4,$c5,$c6,$c7
 .byte $c8,$c9,$ca,$cb,$cb,$cc,$cd,$ce,$cf,$d0,$d1,$d2,$d2,$d3,$d4,$d5
 .byte $d6,$d7,$d8,$d9,$d9,$da,$db,$dc,$dd,$de,$df,$e0,$e0,$e1,$e2,$e3
 .byte $e4,$e5,$e6,$e7,$e7,$e8,$e9,$ea,$eb,$ec,$ed,$ee,$ee,$ef,$f0,$f1
 .byte $f2,$f3,$f4,$f5,$f5,$f6,$f7,$f8,$f9,$fa,$fb,$fc,$fc,$fd,$fe,$ff
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
adaptive_low_end:
.if adaptive_low_end > $5800
 .error "edge LUTs overlap font"
.endif

.if AUTO_RUN != 0
*=$5654
nav_atan:
 .byte $00,$01,$01,$02,$03,$03,$04,$04,$05,$06,$06,$07,$08,$08,$09,$0a
 .byte $0a,$0b,$0b,$0c,$0d,$0d,$0e,$0e,$0f,$10,$10,$11,$12,$12,$13,$13
 .byte $14,$15,$15,$16,$16,$17,$18,$18,$19,$19,$1a,$1a,$1b,$1c,$1c,$1d
 .byte $1d,$1e,$1e,$1f,$1f,$20,$21,$21,$22,$22,$23,$23,$24,$24,$25,$25
 .byte $26,$26,$27,$27,$28,$28,$29,$29,$2a,$2a,$2b,$2b,$2c,$2c,$2d,$2d
 .byte $2e,$2e,$2e,$2f,$2f,$30,$30,$31,$31,$32,$32,$32,$33,$33,$34,$34
 .byte $34,$35,$35,$36,$36,$36,$37,$37,$38,$38,$38,$39,$39,$39,$3a,$3a
 .byte $3b,$3b,$3b,$3c,$3c,$3c,$3d,$3d,$3d,$3e,$3e,$3e,$3f,$3f,$3f,$40
 .byte $40
nav_atan_end:
.if nav_atan_end > $5800
 .error "navigation LUT overlaps font"
.endif
.endif
 .if adaptive_low_end > $5700
 .error "mask LUT overlaps edge tables"
 .endif
 .if AUTO_RUN != 0
 .if nav_atan_end > $5700
 .error "mask LUT overlaps navigation"
 .endif
 .endif
*=$5700
mi_clamp9:
 .byte $00,$09,$12,$1b,$24,$2d,$36,$3f,$48,$48,$48,$48,$48,$48,$48,$48
 .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48
 .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48
 .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48
 .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48
 .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48
 .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48
 .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48
 .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48
 .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48
 .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48
 .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48
 .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48
 .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48
 .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48
 .byte $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48
mi_clamp9_end:
.if mi_clamp9_end != $5800
 .error "mask LUT must end at font boundary"
.endif
*=$5800
 .binary "font.bin"
*=$6000
nav_tables_begin:
.if AUTO_RUN != 0
nav_xlo:
 .byte $66,$9a,$89,$77,$66,$9a,$61,$d8,$00,$00,$ea,$a6,$36,$8a,$0a,$97
 .byte $31,$fd,$49,$7d,$9a,$66,$8c,$da,$50,$41,$de,$61,$ca,$f6,$72,$2c
 .byte $25,$cd,$11,$9a,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00
nav_xhi:
 .byte $09,$10,$11,$12,$13,$16,$17,$17,$18,$18,$17,$17,$17,$16,$16,$15
 .byte $15,$12,$12,$11,$10,$0d,$0c,$0b,$0b,$0a,$09,$09,$08,$07,$07,$07
 .byte $07,$07,$08,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00
nav_ylo:
 .byte $00,$00,$00,$00,$00,$00,$d8,$61,$9a,$cb,$58,$0d,$ea,$d6,$ba,$83
 .byte $31,$fd,$71,$1c,$00,$00,$23,$8b,$38,$1b,$a4,$0e,$5a,$a6,$f5,$69
 .byte $04,$9d,$62,$d9,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00
nav_yhi:
 .byte $13,$13,$13,$13,$13,$13,$12,$12,$11,$0b,$0b,$0b,$0a,$0a,$0a,$0a
 .byte $0a,$07,$07,$07,$07,$07,$07,$07,$08,$0a,$0a,$0b,$0b,$0b,$0b,$0c
 .byte $0d,$11,$12,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00
.else
nav_xlo:
 .byte $00,$02,$80,$fe,$02,$fe,$00,$fe,$00,$02,$80,$fe,$00,$02,$fe,$00
 .byte $fe,$00,$02,$80,$fe,$00,$02,$fe,$00,$fe,$00,$02,$80,$fe,$02,$fe
 .byte $00,$fe,$00,$02,$80,$fe,$00,$02,$fe,$00,$fe,$00,$02,$80,$fe,$00
 .byte $fe,$00,$fe,$00,$02,$80,$fe,$02,$fe,$00,$fe,$00,$02,$80,$fe,$00
 .byte $02,$fe,$00,$fe,$02,$fe,$00,$fe
nav_xhi:
 .byte $03,$07,$0a,$0a,$13,$16,$1b,$1c,$03,$07,$0a,$0a,$0f,$13,$16,$1b
 .byte $1c,$03,$07,$0a,$0a,$0f,$13,$16,$1b,$1c,$03,$07,$0a,$0a,$13,$16
 .byte $1b,$1c,$03,$07,$0a,$0a,$0f,$13,$16,$1b,$1c,$03,$07,$0a,$0a,$0f
 .byte $16,$1b,$1c,$03,$07,$0a,$0a,$13,$16,$1b,$1c,$03,$07,$0a,$0a,$0f
 .byte $13,$16,$1b,$1c,$07,$16,$1b,$1c
nav_ylo:
 .byte $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$80,$80,$80,$80,$80,$80,$80,$80
 .byte $80,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$02,$02,$02,$02,$02,$02,$02,$02,$fe,$fe,$fe,$fe,$fe
 .byte $fe,$fe,$fe,$fe,$00,$00,$00,$00
nav_yhi:
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$05,$05,$05,$05,$05,$05,$05,$05
 .byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$0a,$0a,$0a,$0a,$0a,$0a
 .byte $0a,$0a,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$10,$10,$10,$10,$10
 .byte $10,$10,$10,$14,$14,$14,$14,$14,$14,$14,$14,$17,$17,$17,$17,$17
 .byte $17,$17,$17,$17,$1c,$1c,$1c,$1c
nav_neighbor_0:
 .byte $08,$09,$0a,$0b,$0d,$0e,$0f,$10,$11,$12,$13,$14,$15,$16,$17,$18
 .byte $19,$ff,$1b,$ff,$ff,$ff,$1e,$ff,$20,$21,$ff,$23,$24,$25,$27,$28
 .byte $ff,$ff,$ff,$ff,$2d,$2e,$ff,$ff,$30,$ff,$ff,$33,$34,$35,$36,$ff
 .byte $38,$39,$3a,$ff,$3c,$ff,$ff,$40,$ff,$42,$ff,$ff,$44,$ff,$ff,$ff
 .byte $ff,$45,$46,$47,$ff,$ff,$ff,$ff
nav_neighbor_1:
 .byte $01,$02,$03,$ff,$05,$06,$07,$ff,$09,$0a,$0b,$0c,$0d,$0e,$0f,$10
 .byte $ff,$12,$13,$14,$15,$16,$17,$18,$19,$ff,$1b,$1c,$1d,$ff,$1f,$20
 .byte $21,$ff,$23,$24,$25,$26,$27,$28,$29,$2a,$ff,$2c,$2d,$2e,$2f,$ff
 .byte $31,$32,$ff,$34,$35,$36,$ff,$38,$39,$3a,$ff,$3c,$3d,$3e,$3f,$40
 .byte $41,$42,$43,$ff,$ff,$46,$47,$ff
nav_neighbor_2:
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$01,$02,$03,$ff,$04,$05,$06
 .byte $07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$10,$ff,$12,$ff,$ff,$16,$ff
 .byte $18,$19,$ff,$1b,$1c,$1d,$ff,$1e,$1f,$ff,$ff,$ff,$ff,$24,$25,$ff
 .byte $28,$ff,$ff,$2b,$2c,$2d,$2e,$ff,$30,$31,$32,$ff,$34,$ff,$ff,$ff
 .byte $37,$ff,$39,$ff,$3c,$41,$42,$43
nav_neighbor_3:
 .byte $ff,$00,$01,$02,$ff,$04,$05,$06,$ff,$08,$09,$0a,$0b,$0c,$0d,$0e
 .byte $0f,$ff,$11,$12,$13,$14,$15,$16,$17,$18,$ff,$1a,$1b,$1c,$ff,$1e
 .byte $1f,$20,$ff,$22,$23,$24,$25,$26,$27,$28,$29,$ff,$2b,$2c,$2d,$2e
 .byte $ff,$30,$31,$ff,$33,$34,$35,$ff,$37,$38,$39,$ff,$3b,$3c,$3d,$3e
 .byte $3f,$40,$41,$42,$ff,$ff,$45,$46
nav_degree:
 .byte $02,$03,$03,$02,$02,$03,$03,$02,$03,$04,$04,$04,$03,$04,$04,$04
 .byte $03,$02,$04,$03,$03,$03,$04,$03,$04,$03,$01,$04,$03,$02,$03,$03
 .byte $03,$02,$01,$03,$04,$04,$02,$03,$04,$02,$01,$02,$03,$04,$04,$01
 .byte $03,$03,$02,$02,$04,$03,$02,$02,$03,$04,$02,$01,$04,$02,$02,$02
 .byte $03,$03,$04,$02,$01,$02,$03,$02
.endif
nav_tables_end:
.if nav_tables_end > $63c0
 .error "navigation overlaps displayed bitmap"
.endif
*=$8000
ui_text:
 .byte $20,$33,$44,$56,$49,$42,$45,$36,$34,$20,$31,$2e,$34,$2e,$30,$20
 .byte $2f,$20,$4d,$4f,$44,$45,$20,$38,$20,$2f,$20,$44,$45,$4d,$4f,$20
 .byte $31,$20,$20,$20,$20,$20,$20,$20,$20,$46,$50,$53,$20,$30,$30,$20
 .byte $2f,$20,$41,$55,$54,$4f,$20,$54,$4f,$55,$52,$20,$20,$20,$20,$20
 .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
 .byte $20,$50,$45,$52,$49,$4d,$45,$54,$45,$52,$20,$41,$4e,$44,$20,$50
 .byte $49,$4c,$4c,$41,$52,$53,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
 .byte $20,$20,$20,$20,$20,$20,$20,$20
direction_0:
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
direction_1:
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
direction_2:
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
direction_3:
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
direction_8:
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
ray_offset_lo:
 .byte $d6,$d6,$d9,$d9,$db,$db,$dd,$dd,$e0,$e0,$e2,$e2,$e5,$e5,$e8,$e8
 .byte $ea,$ea,$ed,$ed,$f0,$f0,$f3,$f3,$f6,$f6,$f9,$f9,$fc,$fc,$ff,$ff
 .byte $01,$01,$04,$04,$07,$07,$0a,$0a,$0d,$0d,$10,$10,$13,$13,$16,$16
 .byte $18,$18,$1b,$1b,$1e,$1e,$20,$20,$23,$23,$25,$25,$27,$27,$2a,$2a
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
ray_offset_hi:
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
ray_cos:
 .byte $df,$df,$e3,$e3,$e6,$e6,$e9,$e9,$ed,$ed,$ef,$ef,$f2,$f2,$f5,$f5
 .byte $f7,$f7,$f9,$f9,$fb,$fb,$fd,$fd,$fe,$fe,$ff,$ff,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$ff,$ff,$fe,$fe,$fd,$fd,$fb,$fb,$f9,$f9,$f7,$f7
 .byte $f5,$f5,$f2,$f2,$ef,$ef,$ed,$ed,$e9,$e9,$e6,$e6,$e3,$e3,$df,$df
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
ray_cos_axis:
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
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
auto_keys:
 .byte $00
auto_duration_lo:
 .byte $01
auto_duration_hi:
 .byte $00
 .align 256
quarter_lo:
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
quarter_hi:
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
difference_lo:
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
difference_hi:
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
 .align 256
wall_ids:
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00,$06,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00
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
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$09,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$09,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$09,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$09,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$09,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$09,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$07,$00,$00,$00,$00,$00,$00,$00,$0a,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$0c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$0b
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00
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
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0d,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$0e,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
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
 .byte $00,$00,$00,$00,$0f,$0f,$0f,$00,$00,$00,$00,$00,$00,$00,$00,$10
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$11,$11,$11,$00,$00,$00,$00
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
 .byte $00,$00,$00,$00,$00,$00,$00,$12,$12,$12,$12,$12,$12,$12,$12,$12
 .byte $12,$12,$12,$12,$12,$12,$12,$12,$12,$00,$00,$00,$00,$00,$00,$00
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
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$13,$13,$13,$13,$13,$13,$13
 .byte $13,$13,$13,$13,$13,$13,$13,$00,$00,$00,$00,$00,$00,$00,$00,$00
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
 .byte $00,$00,$00,$00,$14,$14,$14,$14,$14,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$15,$15,$15,$15,$15,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$16,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$17,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
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
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$18
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
 .align 256
wall_top:
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$01,$01,$02,$02,$03,$03,$04,$04,$04,$05,$05
 .byte $06,$06,$07,$07,$07,$08,$08,$08,$09,$09,$0a,$0a,$0a,$0b,$0b,$0b
 .byte $0c,$0c,$0c,$0d,$0d,$0d,$0e,$0e,$0e,$0f,$0f,$0f,$10,$10,$10,$10
 .byte $11,$11,$11,$12,$12,$12,$12,$13,$13,$13,$13,$14,$14,$14,$14,$15
 .byte $15,$15,$15,$16,$16,$16,$16,$17,$17,$17,$17,$18,$18,$18,$18,$18
 .byte $19,$19,$19,$19,$19,$1a,$1a,$1a,$1a,$1a,$1b,$1b,$1b,$1b,$1b,$1c
 .byte $1c,$1c,$1c,$1c,$1c,$1d,$1d,$1d,$1d,$1d,$1e,$1e,$1e,$1e,$1e,$1e
 .byte $1f,$1f,$1f,$1f,$1f,$1f,$1f,$20,$20,$20,$20,$20,$20,$21,$21,$21
 .byte $21,$21,$21,$21,$22,$22,$22,$22,$22,$22,$22,$22,$23,$23,$23,$23
 .byte $23,$23,$23,$23,$24,$24,$24,$24,$24,$24,$24,$24,$25,$25,$25,$25
 .byte $25,$25,$25,$25,$26,$26,$26,$26,$26,$26,$26,$26,$26,$26,$27,$27
 .byte $27,$27,$27,$27,$27,$27,$27,$28,$28,$28,$28,$28,$28,$28,$28,$28
 .byte $28,$28,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$29,$2a,$2a,$2a
 .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a,$2b,$2b,$2b,$2b,$2b,$2b,$2b
 .byte $2b,$2b,$2b,$2b,$2b,$2c,$2c,$2c,$2c,$2c,$2c,$2c,$2c,$2c,$2c,$2c
 .byte $2c,$2c,$2c,$2d,$2d,$2d,$2d,$2d,$2d,$2d,$2d,$2d,$2d,$2d,$2d,$2d
 .byte $2d,$2d,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
 .byte $2e,$2f,$2f,$2f,$2f,$2f,$2f,$2f,$2f,$2f,$2f,$2f,$2f,$2f,$2f,$2f
 .byte $2f,$2f,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30
 .byte $30,$30,$30,$30,$30,$31,$31,$31,$31,$31,$31,$31,$31,$31,$31,$31
 .byte $31,$31,$31,$31,$31,$31,$31,$31,$31,$32,$32,$32,$32,$32,$32,$32
 .byte $32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$33
 .byte $33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33
 .byte $33,$33,$33,$33,$33,$33,$33,$34,$34,$34,$34,$34,$34,$34,$34,$34
 .byte $34,$34,$34,$34,$34,$34,$34,$34,$34,$34,$34,$34,$34,$34,$34,$34
 .byte $34,$34,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35
 .byte $35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$36
 .byte $36,$36,$36,$36,$36,$36,$36,$36,$36,$36,$36,$36,$36,$36,$36,$36
 .byte $36,$36,$36,$36,$36,$36,$36,$36,$36,$36,$36,$36,$36,$36,$36,$36
 .byte $37,$37,$37,$37,$37,$37,$37,$37,$37,$37,$37,$37,$37,$37,$37,$37
 .byte $37,$37,$37,$37,$37,$37,$37,$37,$37,$37,$37,$37,$37,$37,$37,$37
 .byte $37,$37,$37,$37,$37,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38
 .byte $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38
 .byte $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$39
 .byte $39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39
 .byte $39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39
 .byte $39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$3a,$3a
 .byte $3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a
 .byte $3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a
 .byte $3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a
 .byte $3a,$3a,$3a,$3a,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b
 .byte $3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b
 .byte $3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b
 .byte $3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b
 .byte $3b,$3b,$3b,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c
 .byte $3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c
 .byte $3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c
 .byte $3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c
 .byte $3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3d,$3d,$3d
 .byte $3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d
 .byte $3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d
 .byte $3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d
 .byte $3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d
 .byte $3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d
 .byte $3d,$3d,$3d,$3d,$3d,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e
wall_bottom:
 .byte $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90
 .byte $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90
 .byte $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90
 .byte $90,$90,$8e,$8d,$8c,$8a,$89,$88,$87,$86,$85,$84,$83,$82,$81,$80
 .byte $7f,$7e,$7d,$7d,$7c,$7b,$7a,$7a,$79,$78,$78,$77,$76,$76,$75,$75
 .byte $74,$74,$73,$72,$72,$71,$71,$71,$70,$70,$6f,$6f,$6e,$6e,$6e,$6d
 .byte $6d,$6c,$6c,$6c,$6b,$6b,$6b,$6a,$6a,$6a,$69,$69,$69,$68,$68,$68
 .byte $68,$67,$67,$67,$66,$66,$66,$66,$65,$65,$65,$65,$64,$64,$64,$64
 .byte $64,$63,$63,$63,$63,$63,$62,$62,$62,$62,$62,$61,$61,$61,$61,$61
 .byte $61,$60,$60,$60,$60,$60,$60,$5f,$5f,$5f,$5f,$5f,$5f,$5f,$5e,$5e
 .byte $5e,$5e,$5e,$5e,$5e,$5d,$5d,$5d,$5d,$5d,$5d,$5d,$5d,$5c,$5c,$5c
 .byte $5c,$5c,$5c,$5c,$5c,$5c,$5b,$5b,$5b,$5b,$5b,$5b,$5b,$5b,$5b,$5b
 .byte $5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$59,$59,$59,$59,$59
 .byte $59,$59,$59,$59,$59,$59,$59,$58,$58,$58,$58,$58,$58,$58,$58,$58
 .byte $58,$58,$58,$58,$58,$57,$57,$57,$57,$57,$57,$57,$57,$57,$57,$57
 .byte $57,$57,$57,$57,$57,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56
 .byte $56,$56,$56,$56,$56,$56,$56,$55,$55,$55,$55,$55,$55,$55,$55,$55
 .byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$54,$54,$54,$54
 .byte $54,$54,$54,$54,$54,$54,$54,$54,$54,$54,$54,$54,$54,$54,$54,$54
 .byte $54,$54,$54,$54,$53,$53,$53,$53,$53,$53,$53,$53,$53,$53,$53,$53
 .byte $53,$53,$53,$53,$53,$53,$53,$53,$53,$53,$53,$53,$53,$53,$53,$53
 .byte $53,$53,$52,$52,$52,$52,$52,$52,$52,$52,$52,$52,$52,$52,$52,$52
 .byte $52,$52,$52,$52,$52,$52,$52,$52,$52,$52,$52,$52,$52,$52,$52,$52
 .byte $52,$52,$52,$52,$52,$51,$51,$51,$51,$51,$51,$51,$51,$51,$51,$51
 .byte $51,$51,$51,$51,$51,$51,$51,$51,$51,$51,$51,$51,$51,$51,$51,$51
 .byte $51,$51,$51,$51,$51,$51,$51,$51,$51,$51,$51,$51,$51,$51,$51,$51
 .byte $51,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50
 .byte $50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50
 .byte $50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50
 .byte $50,$50,$50,$50,$50,$50,$50,$50,$50,$4f,$4f,$4f,$4f,$4f,$4f,$4f
 .byte $4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f
 .byte $4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f
 .byte $4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f
 .byte $4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f,$4f
 .byte $4f,$4f,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
 .byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
 .byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
 .byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
 .byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
 .byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
 .byte $4e,$4e,$4e,$4e,$4e,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d
 .byte $4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d
 .byte $4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d
 .byte $4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d
 .byte $4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d
 .byte $4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d
 .byte $4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d
 .byte $4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d
 .byte $4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d
 .byte $4d,$4d,$4d,$4d,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c
 .byte $4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c
 .byte $4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c
 .byte $4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c
 .byte $4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c
 .byte $4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c
 .byte $4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c
 .byte $4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c
 .byte $4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c
 .byte $4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c
 .byte $4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c
 .byte $4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c
 .byte $4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c
 .byte $4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c
 .byte $4c,$4c,$4c,$4c,$4c,$4b,$4b,$4b,$4b,$4b,$4b,$4b,$4b,$4b,$4b,$4b
reserved_payload:
 .fill 2449,0
 .fill $ba00-*,$00
fx_height_lo:
 .byte $00,$00,$00,$00,$00,$00,$00,$1f,$2a,$ad,$3b,$8f,$79,$d8,$94,$9b
 .byte $df,$56,$f8,$bd,$a1,$a0,$b5,$de,$19,$63,$bb,$20,$8f,$08,$8a,$14
 .byte $a5,$3c,$da,$7e,$26,$d3,$84,$3a,$f3,$af,$6f,$31,$f7,$bf,$89,$56
 .byte $24,$f5,$c8,$9c,$72,$4a,$23,$fd,$d9,$b6,$94,$74,$54,$36,$18,$fc
 .byte $e0,$c5,$ab,$92,$79,$61,$4a,$34,$1e,$08,$f4,$df,$cc,$b9,$a6,$94
 .byte $82,$71,$60,$4f,$3f,$30,$20,$11,$03,$f4,$e6,$d9,$cb,$be,$b1,$a5
 .byte $98,$8c,$80,$75,$69,$5e,$53,$49,$3e,$34,$2a,$20,$16,$0d,$03,$fa
 .byte $f1,$e8,$df,$d7,$ce,$c6,$be,$b6,$ae,$a6,$9f,$97,$90,$88,$81,$7a
 .byte $73,$6d,$66,$5f,$59,$52,$4c,$46,$40,$3a,$34,$2e,$28,$22,$1d,$17
 .byte $12,$0c,$07,$02,$fc,$f7,$f2,$ed,$e8,$e3,$df,$da,$d5,$d1,$cc,$c8
 .byte $c3,$bf,$bb,$b6,$b2,$ae,$aa,$a6,$a2,$9e,$9a,$96,$92,$8e,$8a,$87
 .byte $83,$80,$7c,$78,$75,$71,$6e,$6b,$67,$64,$61,$5d,$5a,$57,$54,$51
 .byte $4e,$4b,$48,$45,$42,$3f,$3c,$39,$36,$33,$31,$2e,$2b,$28,$26,$23
 .byte $20,$1e,$1b,$19,$16,$14,$11,$0f,$0c,$0a,$08,$05,$03,$00,$fe,$fc
 .byte $fa,$f7,$f5,$f3,$f1,$ef,$ec,$ea,$e8,$e6,$e4,$e2,$e0,$de,$dc,$da
 .byte $d8,$d6,$d4,$d2,$d0,$ce,$cc,$cb,$c9,$c7,$c5,$c3,$c2,$c0,$be,$bc
 .byte $bb,$b9,$b7,$b5,$b4,$b2,$b0,$af,$ad,$ac,$aa,$a8,$a7,$a5,$a4,$a2
 .byte $a1,$9f,$9e,$9c,$9b,$99,$98,$96,$95,$93,$92,$90,$8f,$8e,$8c,$8b
 .byte $89,$88,$87,$85,$84,$83,$81,$80,$7f,$7e,$7c,$7b,$7a,$78,$77,$76
 .byte $75,$74,$72,$71,$70,$6f,$6e,$6c,$6b,$6a,$69,$68,$67,$66,$64,$63
 .byte $62,$61,$60,$5f,$5e,$5d,$5c,$5b,$5a,$58,$57,$56,$55,$54,$53,$52
 .byte $51,$50,$4f,$4e,$4d,$4c,$4b,$4a,$49,$49,$48,$47,$46,$45,$44,$43
 .byte $42,$41,$40,$3f,$3e,$3e,$3d,$3c,$3b,$3a,$39,$38,$37,$37,$36,$35
 .byte $34,$33,$32,$32,$31,$30,$2f,$2e,$2d,$2d,$2c,$2b,$2a,$2a,$29,$28
 .byte $27,$26,$26,$25,$24,$23,$23,$22,$21,$20,$20,$1f,$1e,$1e,$1d,$1c
 .byte $1b,$1b,$1a,$19,$19,$18,$17,$17,$16,$15,$15,$14,$13,$13,$12,$11
 .byte $11,$10,$0f,$0f,$0e,$0d,$0d,$0c,$0b,$0b,$0a,$0a,$09,$08,$08,$07
 .byte $06,$06,$05,$05,$04,$03,$03,$02,$02,$01,$01,$00,$ff,$ff,$fe,$fe
 .byte $fd,$fd,$fc,$fb,$fb,$fa,$fa,$f9,$f9,$f8,$f8,$f7,$f6,$f6,$f5,$f5
 .byte $f4,$f4,$f3,$f3,$f2,$f2,$f1,$f1,$f0,$f0,$ef,$ef,$ee,$ee,$ed,$ed
 .byte $ec,$ec,$eb,$eb,$ea,$ea,$e9,$e9,$e8,$e8,$e7,$e7,$e6,$e6,$e6,$e5
 .byte $e5,$e4,$e4,$e3,$e3,$e2,$e2,$e1,$e1,$e1,$e0,$e0,$df,$df,$de,$de
 .byte $dd,$dd,$dd,$dc,$dc,$db,$db,$db,$da,$da,$d9,$d9,$d8,$d8,$d8,$d7
 .byte $d7,$d6,$d6,$d6,$d5,$d5,$d4,$d4,$d4,$d3,$d3,$d2,$d2,$d2,$d1,$d1
 .byte $d0,$d0,$d0,$cf,$cf,$cf,$ce,$ce,$cd,$cd,$cd,$cc,$cc,$cc,$cb,$cb
 .byte $cb,$ca,$ca,$c9,$c9,$c9,$c8,$c8,$c8,$c7,$c7,$c7,$c6,$c6,$c6,$c5
 .byte $c5,$c5,$c4,$c4,$c4,$c3,$c3,$c3,$c2,$c2,$c2,$c1,$c1,$c1,$c0,$c0
 .byte $c0,$bf,$bf,$bf,$be,$be,$be,$bd,$bd,$bd,$bc,$bc,$bc,$bb,$bb,$bb
 .byte $bb,$ba,$ba,$ba,$b9,$b9,$b9,$b8,$b8,$b8,$b8,$b7,$b7,$b7,$b6,$b6
 .byte $b6,$b5,$b5,$b5,$b5,$b4,$b4,$b4,$b3,$b3,$b3,$b3,$b2,$b2,$b2,$b2
 .byte $b1,$b1,$b1,$b0,$b0,$b0,$b0,$af,$af,$af,$ae,$ae,$ae,$ae,$ad,$ad
 .byte $ad,$ad,$ac,$ac,$ac,$ac,$ab,$ab,$ab,$ab,$aa,$aa,$aa,$aa,$a9,$a9
 .byte $a9,$a9,$a8,$a8,$a8,$a8,$a7,$a7,$a7,$a7,$a6,$a6,$a6,$a6,$a5,$a5
 .byte $a5,$a5,$a4,$a4,$a4,$a4,$a3,$a3,$a3,$a3,$a3,$a2,$a2,$a2,$a2,$a1
 .byte $a1,$a1,$a1,$a0,$a0,$a0,$a0,$a0,$9f,$9f,$9f,$9f,$9e,$9e,$9e,$9e
 .byte $9e,$9d,$9d,$9d,$9d,$9c,$9c,$9c,$9c,$9c,$9b,$9b,$9b,$9b,$9b,$9a
 .byte $9a,$9a,$9a,$99,$99,$99,$99,$99,$98,$98,$98,$98,$98,$97,$97,$97
 .byte $97,$97,$96,$96,$96,$96,$96,$95,$95,$95,$95,$95,$94,$94,$94,$94
 .byte $94,$94,$93,$93,$93,$93,$93,$92,$92,$92,$92,$92,$91,$91,$91,$91
 .byte $91,$91,$90,$90,$90,$90,$90,$8f,$8f,$8f,$8f,$8f,$8f,$8e,$8e,$8e
 .byte $8e,$8e,$8d,$8d,$8d,$8d,$8d,$8d,$8c,$8c,$8c,$8c,$8c,$8c,$8b,$8b
 .byte $8b,$8b,$8b,$8b,$8a,$8a,$8a,$8a,$8a,$8a,$89,$89,$89,$89,$89,$89
 .byte $88,$88,$88,$88,$88,$88,$87,$87,$87,$87,$87,$87,$86,$86,$86,$86
 .byte $86,$86,$85,$85,$85,$85,$85,$85,$85,$84,$84,$84,$84,$84,$84,$83
 .byte $83,$83,$83,$83,$83,$83,$82,$82,$82,$82,$82,$82,$82,$81,$81,$81
 .byte $81,$81,$81,$80,$80,$80,$80,$80,$80,$80,$7f,$7f,$7f,$7f,$7f,$7f
 .byte $7f,$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7d,$7d,$7d,$7d,$7d,$7d,$7d,$7d
 .byte $7c,$7c,$7c,$7c,$7c,$7c,$7c,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7a
 .byte $7a,$7a,$7a,$7a,$7a,$7a,$79,$79,$79,$79,$79,$79,$79,$79,$78,$78
 .byte $78,$78,$78,$78,$78,$78,$77,$77,$77,$77,$77,$77,$77,$77,$76,$76
 .byte $76,$76,$76,$76,$76,$76,$75,$75,$75,$75,$75,$75,$75,$75,$74,$74
 .byte $74,$74,$74,$74,$74,$74,$74,$73,$73,$73,$73,$73,$73,$73,$73,$72
 .byte $72,$72,$72,$72,$72,$72,$72,$72,$71,$71,$71,$71,$71,$71,$71,$71
 .byte $71,$70,$70,$70,$70,$70,$70,$70,$70,$70,$6f,$6f,$6f,$6f,$6f,$6f
fx_height_hi:
 .byte $40,$40,$40,$40,$40,$40,$40,$3b,$34,$2e,$2a,$26,$23,$20,$1e,$1c
 .byte $1a,$19,$17,$16,$15,$14,$13,$12,$12,$11,$10,$10,$0f,$0f,$0e,$0e
 .byte $0d,$0d,$0c,$0c,$0c,$0b,$0b,$0b,$0a,$0a,$0a,$0a,$09,$09,$09,$09
 .byte $09,$08,$08,$08,$08,$08,$08,$07,$07,$07,$07,$07,$07,$07,$07,$06
 .byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$05,$05,$05,$05,$05,$05
 .byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$04,$04,$04,$04,$04,$04,$04
 .byte $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$01,$01
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
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00
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
fx_wall_plane:
 .byte $00,$0b,$0f,$15,$17,$19,$1c,$04,$07,$09,$0c,$10,$16,$4d,$4f,$56
 .byte $56,$56,$5c,$44,$4a,$4a,$4e,$50,$57,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00
fx_center_mag:
 .byte $66,$3e,$0d,$63,$0b,$61,$11,$30,$57,$2a,$06,$15,$2a,$3a,$47,$52
 .byte $52,$47,$3a,$2a,$15,$06,$2a,$57,$30,$11,$61,$0b,$63,$0d,$3e,$66
 .byte $00,$00,$00,$00,$00,$00,$00,$00
fx_center_sign:
 .byte $80,$00,$80,$80,$00,$80,$80,$00,$80,$80,$80,$00,$00,$00,$00,$00
 .byte $80,$80,$80,$80,$80,$00,$00,$00,$80,$00,$00,$80,$00,$00,$80,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00
height_index_padding_begin:
 .align 256
height_index_tables_begin:
hi_low:
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
 .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
 .byte $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04
 .byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
 .byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
 .byte $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07
 .byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
 .byte $09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
 .byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
 .byte $0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b
 .byte $0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c
 .byte $0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d
 .byte $0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e
 .byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
hi_nibble:
 .byte $00,$10,$20,$30,$40,$50,$60,$70,$80,$90,$a0,$b0,$c0,$d0,$e0,$f0
 .byte $00,$10,$20,$30,$40,$50,$60,$70,$80,$90,$a0,$b0,$c0,$d0,$e0,$f0
 .byte $00,$10,$20,$30,$40,$50,$60,$70,$80,$90,$a0,$b0,$c0,$d0,$e0,$f0
 .byte $00,$10,$20,$30,$40,$50,$60,$70,$80,$90,$a0,$b0,$c0,$d0,$e0,$f0
hi_page:
 .byte (>fx_height_lo)+0,(>fx_height_lo)+0,(>fx_height_lo)+0,(>fx_height_lo)+0,(>fx_height_lo)+0,(>fx_height_lo)+0,(>fx_height_lo)+0,(>fx_height_lo)+0,(>fx_height_lo)+0,(>fx_height_lo)+0,(>fx_height_lo)+0,(>fx_height_lo)+0,(>fx_height_lo)+0,(>fx_height_lo)+0,(>fx_height_lo)+0,(>fx_height_lo)+0
 .byte (>fx_height_lo)+1,(>fx_height_lo)+1,(>fx_height_lo)+1,(>fx_height_lo)+1,(>fx_height_lo)+1,(>fx_height_lo)+1,(>fx_height_lo)+1,(>fx_height_lo)+1,(>fx_height_lo)+1,(>fx_height_lo)+1,(>fx_height_lo)+1,(>fx_height_lo)+1,(>fx_height_lo)+1,(>fx_height_lo)+1,(>fx_height_lo)+1,(>fx_height_lo)+1
 .byte (>fx_height_lo)+2,(>fx_height_lo)+2,(>fx_height_lo)+2,(>fx_height_lo)+2,(>fx_height_lo)+2,(>fx_height_lo)+2,(>fx_height_lo)+2,(>fx_height_lo)+2,(>fx_height_lo)+2,(>fx_height_lo)+2,(>fx_height_lo)+2,(>fx_height_lo)+2,(>fx_height_lo)+2,(>fx_height_lo)+2,(>fx_height_lo)+2,(>fx_height_lo)+2
 .byte (>fx_height_lo)+3,(>fx_height_lo)+3,(>fx_height_lo)+3,(>fx_height_lo)+3,(>fx_height_lo)+3,(>fx_height_lo)+3,(>fx_height_lo)+3,(>fx_height_lo)+3,(>fx_height_lo)+3,(>fx_height_lo)+3,(>fx_height_lo)+3,(>fx_height_lo)+3,(>fx_height_lo)+3,(>fx_height_lo)+3,(>fx_height_lo)+3,(>fx_height_lo)+3
height_index_tables_end:
.if height_index_tables_end-height_index_tables_begin != 384
 .error "height index LUT size must be384bytes"
.endif
.if (hi_low & $ff) != 0 || (hi_nibble & $ff) != 0 || (hi_page & $ff) != 64
 .error "height index LUT alignment contract"
.endif
.if (fx_height_lo & $ff) != 0 || fx_height_hi-fx_height_lo != 1024
 .error "original height table layout changed"
.endif
.if height_index_tables_end > $cb00
 .error "height index LUT exceeds recovered high-table budget"
.endif
table_end:
.if table_end > $cb00
 .error "portal tables overlap second screen"
.endif

*=$c480
vp_helper_start:
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
vp_helper_end:
.cerror vp_helper_end>$cb00,"viewport initializer overlaps owners"
.cerror code_end>$2f00,"viewport hooks overlap workspace"

*=$c600
layout_door_table:
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$02,$03,$04,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$10
 .byte $11,$12,$13,$13,$14,$15,$16,$16,$17,$18,$18,$19,$1a,$1a,$1b,$1b
 .byte $1c,$1c,$1d,$1e,$1e,$1f,$1f,$1f,$20,$20,$21,$21,$22,$22,$22,$23
 .byte $23,$24,$24,$24,$25,$25,$25,$26,$26,$26,$27,$27,$27,$28,$28,$28
 .byte $28,$29,$29,$29,$2a,$2a,$2a,$2a,$2b,$2b,$2b,$2b,$2c,$2c,$2c,$2c
 .byte $2c,$2d,$2d,$2d,$2d,$2d,$2e,$2e,$2e,$2e,$2e,$2f,$2f,$2f,$2f,$2f
 .byte $2f,$30,$30,$30,$30,$30,$30,$31,$31,$31,$31,$31,$31,$31,$32,$32
 .byte $32,$32,$32,$32,$32,$33,$33,$33,$33,$33,$33,$33,$33,$34,$34,$34
 .byte $34,$34,$34,$34,$34,$34,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35
 .byte $36,$36,$36,$36,$36,$36,$36,$36,$36,$36,$36,$37,$37,$37,$37,$37
 .byte $37,$37,$37,$37,$37,$37,$37,$38,$38,$38,$38,$38,$38,$38,$38,$38
 .byte $38,$38,$38,$38,$38,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39
 .byte $39,$39,$39,$39,$39,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a
 .byte $3a,$3a,$3a,$3a,$3a,$3a,$3a,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b
 .byte $3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3c,$3c,$3c,$3c
 .byte $3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c
 .byte $3c,$3c,$3c,$3c,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d
 .byte $3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d,$3d
 .byte $3d,$3d,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e
 .byte $3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e,$3e
 .byte $3e,$3e,$3e,$3e,$3e,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f
 .byte $3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f
 .byte $3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f
 .byte $3f,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
 .byte $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
 .byte $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
 .byte $40,$40,$40,$40,$40,$40,$40,$40,$40,$41,$41,$41,$41,$41,$41,$41
 .byte $41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41
 .byte $41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41
 .byte $41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41
 .byte $41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41
 .byte $41,$41,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42
 .byte $42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42
 .byte $42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42
 .byte $42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42
 .byte $42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42
 .byte $42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42
 .byte $42,$42,$42,$42,$42,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43
 .byte $43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43
 .byte $43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43
 .byte $43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43
 .byte $43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43
 .byte $43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43
 .byte $43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43
 .byte $43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43
 .byte $43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43
 .byte $43,$43,$43,$43,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
 .byte $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
 .byte $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
 .byte $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
 .byte $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
 .byte $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
 .byte $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
 .byte $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
 .byte $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
 .byte $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
 .byte $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
 .byte $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
 .byte $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
 .byte $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
 .byte $44,$44,$44,$44,$44,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45

*=$ca00
layout_support:
layout_copy_tables:
 ldx #0
layout_copy_loop:
 lda $4000,x
 sta $0200,x
 lda $4100,x
 sta $0400,x
 lda $4200,x
 sta $0500,x
 lda $cc00,x
 sta $0600,x
 lda $cd00,x
 sta $0700,x
 inx
 bne layout_copy_loop
 ldx #8
layout_copy_tail:
 lda $4300,x
 sta $0300,x
 dex
 bpl layout_copy_tail
 rts
layout_support_end:
.cerror layout_support_end>$cb00,"Layout support overlaps fine owners"
.cerror code_end>$2f00,"Startup padding overlap renderer workspace"
.cerror reserved_payload!=$b000,"Reserved address changed"
.cerror fx_height_lo!=$ba00,"height table moved unexpectedly"
*=$cc00
layout_staged_negsin:
 .byte $00,$ff,$fe,$fe,$fd,$fc,$fb,$fb,$fa,$f9,$f8,$f7,$f7,$f6,$f5,$f4
 .byte $f4,$f3,$f2,$f1,$f0,$f0,$ef,$ee,$ed,$ed,$ec,$eb,$ea,$ea,$e9,$e8
 .byte $e8,$e7,$e6,$e5,$e5,$e4,$e3,$e3,$e2,$e1,$e0,$e0,$df,$de,$de,$dd
 .byte $dc,$dc,$db,$db,$da,$d9,$d9,$d8,$d7,$d7,$d6,$d6,$d5,$d4,$d4,$d3
 .byte $d3,$d2,$d2,$d1,$d1,$d0,$d0,$cf,$cf,$ce,$ce,$cd,$cd,$cc,$cc,$cb
 .byte $cb,$ca,$ca,$ca,$c9,$c9,$c8,$c8,$c8,$c7,$c7,$c6,$c6,$c6,$c5,$c5
 .byte $c5,$c5,$c4,$c4,$c4,$c3,$c3,$c3,$c3,$c3,$c2,$c2,$c2,$c2,$c2,$c1
 .byte $c1,$c1,$c1,$c1,$c1,$c1,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
 .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c1,$c1,$c1,$c1,$c1
 .byte $c1,$c1,$c2,$c2,$c2,$c2,$c2,$c3,$c3,$c3,$c3,$c3,$c4,$c4,$c4,$c5
 .byte $c5,$c5,$c5,$c6,$c6,$c6,$c7,$c7,$c8,$c8,$c8,$c9,$c9,$ca,$ca,$ca
 .byte $cb,$cb,$cc,$cc,$cd,$cd,$ce,$ce,$cf,$cf,$d0,$d0,$d1,$d1,$d2,$d2
 .byte $d3,$d3,$d4,$d4,$d5,$d6,$d6,$d7,$d7,$d8,$d9,$d9,$da,$db,$db,$dc
 .byte $dc,$dd,$de,$de,$df,$e0,$e0,$e1,$e2,$e3,$e3,$e4,$e5,$e5,$e6,$e7
 .byte $e8,$e8,$e9,$ea,$ea,$eb,$ec,$ed,$ed,$ee,$ef,$f0,$f0,$f1,$f2,$f3
 .byte $f4,$f4,$f5,$f6,$f7,$f7,$f8,$f9,$fa,$fb,$fb,$fc,$fd,$fe,$fe,$ff
 .byte $00,$01,$02,$02,$03,$04,$05,$05,$06,$07,$08,$09,$09,$0a,$0b,$0c
 .byte $0c,$0d,$0e,$0f,$10,$10,$11,$12,$13,$13,$14,$15,$16,$16,$17,$18
 .byte $18,$19,$1a,$1b,$1b,$1c,$1d,$1d,$1e,$1f,$20,$20,$21,$22,$22,$23
 .byte $24,$24,$25,$25,$26,$27,$27,$28,$29,$29,$2a,$2a,$2b,$2c,$2c,$2d
 .byte $2d,$2e,$2e,$2f,$2f,$30,$30,$31,$31,$32,$32,$33,$33,$34,$34,$35
 .byte $35,$36,$36,$36,$37,$37,$38,$38,$38,$39,$39,$3a,$3a,$3a,$3b,$3b
 .byte $3b,$3b,$3c,$3c,$3c,$3d,$3d,$3d,$3d,$3d,$3e,$3e,$3e,$3e,$3e,$3f
 .byte $3f,$3f,$3f,$3f,$3f,$3f,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
 .byte $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$3f,$3f,$3f,$3f,$3f
 .byte $3f,$3f,$3e,$3e,$3e,$3e,$3e,$3d,$3d,$3d,$3d,$3d,$3c,$3c,$3c,$3b
 .byte $3b,$3b,$3b,$3a,$3a,$3a,$39,$39,$38,$38,$38,$37,$37,$36,$36,$36
 .byte $35,$35,$34,$34,$33,$33,$32,$32,$31,$31,$30,$30,$2f,$2f,$2e,$2e
 .byte $2d,$2d,$2c,$2c,$2b,$2a,$2a,$29,$29,$28,$27,$27,$26,$25,$25,$24
 .byte $24,$23,$22,$22,$21,$20,$20,$1f,$1e,$1d,$1d,$1c,$1b,$1b,$1a,$19
 .byte $18,$18,$17,$16,$16,$15,$14,$13,$13,$12,$11,$10,$10,$0f,$0e,$0d
 .byte $0c,$0c,$0b,$0a,$09,$09,$08,$07,$06,$05,$05,$04,$03,$02,$02,$01
