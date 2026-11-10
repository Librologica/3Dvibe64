; AnimatedMesh v1, foreground only. Required Notice: 3Dvibe64.
; PolyForm Noncommercial 1.0.0. Private scratch has no lifetime aliases.
am_reset_all:
 ldx #0
am_reset_loop:
 lda am_initial_clip,x
 sta am_clip,x
 lda am_initial_lo,x
 sta am_phase_lo,x
 lda am_initial_hi,x
 sta am_phase_hi,x
 lda #0
 sta am_light_valid,x
 inx
 cpx #AM_OBJECTS
 bne am_reset_loop
 ldx #0
 lda #255
am_reset_cache:
 sta am_cache_clip,x
 inx
 cpx #AM_MESHES
 bne am_reset_cache
 rts

; X=scene object index, A=global clip index. C=1 invalid, no mutation.
; Valid: reset phase to zero, C=0. Registers/flags other than C volatile.
am_set_clip:
 cpx #AM_OBJECTS
 bcs am_api_bad
 cmp #AM_CLIPS
 bcs am_api_bad
 tay
 lda am_map,x
 cmp #255
 beq am_api_bad
 cmp am_clip_owner,y
 bne am_api_bad
 tya
 sta am_clip,x
 lda #0
 sta am_phase_lo,x
 sta am_phase_hi,x
 clc
 rts
am_api_bad:
 sec
 rts

; Unreachable under the explicitly selected pure Gouraud profile.
; Retained counter/trap makes any qualification violation observable.
am_compact_violation:
 inc am_cold_calls
 jmp am_compact_violation

; X=scene object index. Next visible view recomputes frozen reference lighting.
am_invalidate_light:
 cpx #AM_OBJECTS
 bcs am_api_bad
 lda #0
 sta am_light_valid,x
 clc
 rts

; One update per engine logical tick (50Hz on PAL and NTSC).
am_tick:
 ldx #0
am_tick_loop:
 lda am_map,x
 cmp #255
 beq am_tick_next
 ldy am_clip,x
 clc
 lda am_phase_lo,x
 adc am_step,x
 sta am_phase_lo,x
 lda am_phase_hi,x
 adc #0
 and am_phase_mask,y
 sta am_phase_hi,x
 lda am_frame_mask,y
 cmp #15
 bcs am_tick_next
 asl
 asl
 asl
 asl
 ora #15
 and am_phase_lo,x
 sta am_phase_lo,x
am_tick_next:
 inx
 cpx #AM_OBJECTS
 bne am_tick_loop
 rts

; Called only after set_active_object selected source and runtime ranges.
am_prepare_object:
 ldx objidx
 lda am_map,x
 cmp #255
 bne am_prepare_active
 rts
am_prepare_active:
 ; Key the current SOURCE contents, not an instance's private previous pose.
 ; Another phase of a shared asset invalidates this key by replacing it.
 lda am_phase_lo,x
 sta am_key_lo
 lda am_linear,x
 bne am_cache_key_ready
 lda am_key_lo
 and #240
 sta am_key_lo
am_cache_key_ready:
 lda am_phase_hi,x
 sta am_key_hi
 lda am_clip,x
 sta am_key_clip
 ldx meshidx
 lda am_cache_clip,x
 cmp am_key_clip
 bne am_cache_miss
 lda am_cache_lo,x
 cmp am_key_lo
 bne am_cache_miss
 lda am_cache_hi,x
 cmp am_key_hi
 bne am_cache_miss
 rts
am_cache_miss:
 lda am_key_clip
 sta am_cache_clip,x
 lda am_key_lo
 sta am_cache_lo,x
 lda am_key_hi
 sta am_cache_hi,x
 ldx objidx
 ldy am_clip,x
 sty am_current_clip
 lda am_vertices,y
 sta am_count
 lda am_frame_mask,y
 sta am_mask
 lda am_phase_lo,x
 and #15
 sta am_fraction
 lda am_linear,x
 bne am_linear_ready
 lda #0
 sta am_fraction
am_linear_ready:
 lda am_phase_hi,x
 sta am_frame
 lda am_phase_lo,x
 lsr am_frame
 ror
 lsr am_frame
 ror
 lsr am_frame
 ror
 lsr am_frame
 ror
 sta am_frame
 clc
 adc #1
 and am_mask
 sta am_next_frame
 lda am_base_lo,y
 sta am_load_base+1
 lda am_base_hi,y
 sta am_load_base+2
 lda am_ptrlo_lo,y
 sta am_load_ptrlo+1
 lda am_ptrlo_hi,y
 sta am_load_ptrlo+2
 lda am_ptrhi_lo,y
 sta am_load_ptrhi+1
 lda am_ptrhi_hi,y
 sta am_load_ptrhi+2
 lda am_bits_lo,y
 sta am_load_bits+1
 lda am_bits_hi,y
 sta am_load_bits+2
 ldx meshidx
 lda mesh_vfirst,x
 sta am_first_vertex
 lda #0
 sta am_column
 lda #AM_OFFSET_X
 sta am_offset+1
 lda #<vert_xi
 sta am_store+1
 lda #>vert_xi
 sta am_store+2
 jsr am_decode_axis
 lda #AM_OFFSET_Y
 sta am_offset+1
 lda #<vert_yi
 sta am_store+1
 lda #>vert_yi
 sta am_store+2
 jsr am_decode_axis
 lda #AM_OFFSET_Z
 sta am_offset+1
 lda #<vert_zi
 sta am_store+1
 lda #>vert_zi
 sta am_store+2
 jmp am_decode_axis

am_decode_axis:
 lda #0
 sta am_vertex
am_decode_loop:
 ldx am_column
am_load_base:
 lda $ffff,x
 sta am_base
am_load_bits:
 lda $ffff,x
 sta am_bits
 beq am_constant
am_load_ptrlo:
 lda $ffff,x
 sta am_read+1
am_load_ptrhi:
 lda $ffff,x
 sta am_read+2
 lda am_frame
 jsr am_sample
 sta am_a
 lda am_fraction
 beq am_first_only
 lda am_next_frame
 jsr am_sample
 sta am_b
 jsr am_interpolate
 jmp am_have_delta
am_first_only:
 lda am_a
 jmp am_have_delta
am_constant:
 lda #0
am_have_delta:
 clc
 adc am_base
 clc
am_offset:
 adc #0
 sta am_value
 clc
 lda am_first_vertex
 adc am_vertex
 tax
 lda am_value
am_store:
 sta $ffff,x
 inc am_column
 inc am_vertex
 lda am_vertex
 cmp am_count
 bne am_decode_loop
 rts

; A=frame index. Read packed unsigned delta, 0..126.
am_sample:
 ldx am_bits
 cpx #8
 beq am_sample_byte
 sta am_sample_frame
 cpx #4
 beq am_sample_four
 cpx #2
 beq am_sample_two
 lda am_sample_frame
 and #7
 sta am_shift
 lda am_sample_frame
 lsr
 lsr
 lsr
 tay
 lda #1
 sta am_sample_mask
 jmp am_sample_read
am_sample_two:
 lda am_sample_frame
 and #3
 asl
 sta am_shift
 lda am_sample_frame
 lsr
 lsr
 tay
 lda #3
 sta am_sample_mask
 jmp am_sample_read
am_sample_four:
 lda am_sample_frame
 and #1
 asl
 asl
 sta am_shift
 lda am_sample_frame
 lsr
 tay
 lda #15
 sta am_sample_mask
am_sample_read:
 jsr am_read
 ldx am_shift
 beq am_sample_masked
am_sample_shift:
 lsr
 dex
 bne am_sample_shift
am_sample_masked:
 and am_sample_mask
 rts
am_sample_byte:
 tay
 jmp am_read
am_read:
 lda $ffff,y
 rts

; Exact a + sign(b-a)*floor(abs(b-a)*fraction/16), no signed overflow.
; a/b are unsigned column deltas, fraction 0..15. No floating point.
am_interpolate:
 lda #0
 sta am_negative
 sta am_product_hi
 sta am_product_lo
 lda am_b
 sec
 sbc am_a
 bcs am_positive
 eor #255
 clc
 adc #1
 inc am_negative
am_positive:
 sta am_multiplicand_lo
 lda #0
 sta am_multiplicand_hi
 lda am_fraction
 sta am_multiplier
 ldx #4
am_multiply:
 lsr am_multiplier
 bcc am_no_add
 clc
 lda am_product_lo
 adc am_multiplicand_lo
 sta am_product_lo
 lda am_product_hi
 adc am_multiplicand_hi
 sta am_product_hi
am_no_add:
 asl am_multiplicand_lo
 rol am_multiplicand_hi
 dex
 bne am_multiply
 ldx #4
am_divide:
 lsr am_product_hi
 ror am_product_lo
 dex
 bne am_divide
 lda am_negative
 bne am_subtract
 lda am_a
 clc
 adc am_product_lo
 rts
am_subtract:
 lda am_a
 sec
 sbc am_product_lo
 rts

am_current_clip: .byte 0
am_count: .byte 0
am_mask: .byte 0
am_fraction: .byte 0
am_frame: .byte 0
am_next_frame: .byte 0
am_first_vertex: .byte 0
am_column: .byte 0
am_vertex: .byte 0
am_base: .byte 0
am_bits: .byte 0
am_a: .byte 0
am_b: .byte 0
am_value: .byte 0
am_sample_frame: .byte 0
am_shift: .byte 0
am_sample_mask: .byte 0
am_negative: .byte 0
am_product_lo: .byte 0
am_product_hi: .byte 0
am_multiplicand_lo: .byte 0
am_multiplicand_hi: .byte 0
am_multiplier: .byte 0
am_key_lo: .byte 0
am_key_hi: .byte 0
am_key_clip: .byte 0
am_cold_calls: .byte 0
am_light_end: .byte 0
