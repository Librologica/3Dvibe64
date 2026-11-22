"""Mode8 distance fade, bounded inside the existing unused reserved payload.
Map units are cells; plane-normal distance, retaining near surface groups.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import re,math
from distance_fade import masks

def apply(s,c,multi):
    if c['mode']=='off':return s
    # No allocator or runtime buffer boundary is moved. The payload has no consumers.
    code='df8_level: .byte 16\ndf8_distance: .word 0\ndf8_min: .word 0\ndf8_camera: .word 0\ndf8_value: .byte 0\ndf8_scan: .byte 0\ndf8_mask: .byte 0\ndf8_y: .byte 0\ndf8_x: .byte 0\n'
    code+='df8_masks: .byte '+','.join(map(str,masks()))+'\n'
    values=[math.ceil((c['end']-(c['end']-c['start'])*k/16)*256) for k in range(17)]
    code+='df8_threshold_lo: .byte '+','.join(str(v&255) for v in values)+'\n'
    code+='df8_threshold_hi: .byte '+','.join(str(v>>8&255) for v in values)+'\n'
    code+='df8_threshold_ext: .byte '+','.join(str(v>>16) for v in values)+'\n'
    code+="""df8_plane:
 ; A=encoded plane: bit6 selects Y, low6 coordinate in map cells.
 pha
 and #64
 beq df8_plane_x
 lda pose_y
 sta df8_camera
 lda pose_y+1
 jmp df8_camera_axis
df8_plane_x:
 lda pose_x
 sta df8_camera
 lda pose_x+1
df8_camera_axis:
 sta df8_camera+1
 sec
 lda #0
 sbc df8_camera
 sta df8_distance
 pla
 and #63
 sbc df8_camera+1
 sta df8_distance+1
 bpl df8_plane_positive
 sec
 lda #0
 sbc df8_distance
 sta df8_distance
 lda #0
 sbc df8_distance+1
 sta df8_distance+1
df8_plane_positive:
 rts
df8_classify:
 ldx #0
df8_threshold:
 lda df8_threshold_ext,x
 bne df8_nearer
 lda df8_distance+1
 cmp df8_threshold_hi,x
 bcc df8_nearer
 bne df8_match
 lda df8_distance
 cmp df8_threshold_lo,x
 bcs df8_match
df8_nearer:
 inx
 cpx #17
 bne df8_threshold
 ldx #16
df8_match:
 stx df8_level
 rts
df8_address:
 lda df8_scan
 lsr
 lsr
 lsr
 tax
 lda col
 asl
 asl
 asl
 clc
 adc bitmap_row_lo,x
 sta fill_ptr
 lda bitmap_row_hi,x
 adc #0
 ldx drawbuf
 beq df8_address_ready
 clc
 adc #128
df8_address_ready:
 sta fill_ptr+1
 lda df8_scan
 and #7
 tay
 rts
df8_samples:
 lda df8_level
 beq df8_samples_done
 cmp #16
 beq df8_samples_opaque
 ; Every surviving old sample lies in [min(top),max(bottom)), clipped to144.
 lda #144
 sta df8_scan
 lda #0
 sta df8_y
 ldx #3
df8_sample_bounds:
 lda top_samples,x
 cmp df8_scan
 bcs df8_sample_top_ready
 sta df8_scan
df8_sample_top_ready:
 lda bottom_samples,x
 cmp df8_y
 bcc df8_sample_bottom_ready
 sta df8_y
df8_sample_bottom_ready:
 dex
 bpl df8_sample_bounds
 lda df8_y
 cmp #144
 bcc df8_sample_limit_ready
 lda #144
 sta df8_y
df8_sample_limit_ready:
 lda df8_scan
 cmp df8_y
 bcs df8_samples_done
df8_sample_row:
 lda df8_level
 asl
 asl
 sta df8_mask
 lda df8_scan
 and #3
 ora df8_mask
 tax
 lda df8_masks,x
 sta df8_mask
 ldx #3
 lda #0
 sta df8_value
df8_lane:
 lda df8_scan
 cmp top_samples,x
 bcc df8_lane_next
 cmp bottom_samples,x
 bcs df8_lane_next
 lda df8_value
 ora df8_pixel_mask,x
 sta df8_value
df8_lane_next:
 dex
 bpl df8_lane
 lda df8_value
 and df8_mask
 beq df8_row_next
 sta df8_mask
 jsr df8_address
 lda (fill_ptr),y
 eor band_shade
 and df8_mask
 eor (fill_ptr),y
 sta (fill_ptr),y
df8_row_next:
 inc df8_scan
 lda df8_scan
 cmp df8_y
 bcc df8_sample_row
df8_samples_done:
 rts
df8_samples_opaque:
 jmp df8_original_samples
df8_pixel_mask: .byte 192,48,12,3
"""
    if multi:
        # Pose is latched before compose_screen; reset the private plane cache once
        # per composition through an existing same-size call site. No low-code growth.
        assert s.count(' jsr gr17_clear_units\n')==1
        s=s.replace(' jsr gr17_clear_units\n',' jsr df8_clear_units\n')
        code+="""df8_plane_index: .byte 0
df8_plane_levels: .fill 128,255
df8_clear_units:
 jsr gr17_clear_units
 lda #255
 ldx #127
df8_clear_plane_levels:
 sta df8_plane_levels,x
 dex
 bpl df8_clear_plane_levels
 rts
"""
        # Existing get_profile calls are same-size hooks: low-code budget stays bounded.
        s=s.replace('MODE8_FINE_ZERO_FAST = 1','MODE8_FINE_ZERO_FAST = 0')
        s=s.replace(' jsr get_profile\n',' jsr df8_get_profile\n')
        s=s.replace(' jsr draw_samples\n',' jsr df8_samples\n').replace(' jmp draw_samples\n',' jmp df8_samples\n')
        s=s.replace('draw_samples:\n','df8_original_samples:\n',1)
        s=s.replace(' jsr scalar_fill\n',' jsr df8_scalar\n')
        s=s.replace(' sta $5400,y\n',' jsr df8_fine_store\n',1)
        code+="""df8_profile_key: .byte 0
df8_saved_x: .byte 0
df8_get_profile:
 ; Neither distance helper touches Y; preserve X and key in private foreground state.
 sta df8_profile_key
 stx df8_saved_x
 tax
 lda key_plane,x
 tax
 lda df8_plane_levels,x
 bpl df8_cached_level
 stx df8_plane_index
 txa
 jsr df8_plane
 jsr df8_classify
 ldx df8_plane_index
 lda df8_level
 sta df8_plane_levels,x
df8_cached_level:
 sta df8_level
df8_level_ready:
 beq df8_profile_far
 ldx df8_saved_x
 lda df8_profile_key
 jmp get_profile
df8_profile_far:
 ldx df8_saved_x
 lda #<df8_zero
 sta p_out
 lda #>df8_zero
 sta p_out+1
 rts
df8_scalar_row: .byte 0
df8_scalar:
 sta df8_value
 lda df8_level
 beq df8_scalar_done
 cmp #16
 beq df8_scalar_opaque
 asl
 asl
 sta df8_scalar_level+1
 lda fill_start
 sta df8_scalar_row
df8_scalar_phase:
 ldy df8_scalar_row
 cpy fill_end
 bcs df8_scalar_done
 tya
 and #3
df8_scalar_level:
 ora #0
 tax
 lda df8_masks,x
 ldx fine_lane
 and df8_pixel_mask,x
 beq df8_scalar_next_phase
 sta df8_mask
 eor #255
 sta df8_scalar_keep+1
 lda df8_value
 and df8_mask
 sta df8_scalar_ink+1
df8_scalar_stride:
 lda $5400,y
df8_scalar_keep:
 and #0
df8_scalar_ink:
 ora #0
 sta $5400,y
 tya
 clc
 adc #4
 bcs df8_scalar_next_phase
 tay
 cpy fill_end
 bcc df8_scalar_stride
df8_scalar_next_phase:
 inc df8_scalar_row
 lda df8_scalar_row
 sec
 sbc fill_start
 cmp #4
 bcc df8_scalar_phase
df8_scalar_done:
 rts
df8_scalar_opaque:
 lda df8_value
 jmp scalar_fill
df8_fine_store:
 php
 sta df8_value
 stx df8_x
 tya
 and #3
 sta df8_y
 lda df8_level
 asl
 asl
 ora df8_y
 tax
 lda $5400,y
 eor df8_value
 and df8_masks,x
 eor $5400,y
 sta $5400,y
 lda df8_value
 ldx df8_x
 plp
 rts
df8_zero: .fill 128,0
"""
    else:
        # Clear stale pixels to the renderer's black/brown background before drawing.
        s=s.replace(' jsr compose_screen\n',' jsr df8_compose\n')
        s=s.replace('draw_band:\n','df8_original_band:\n',1).replace('ss_draw_band:\n','df8_original_refined:\n',1)
        # The partial path uses the exact original top/bottom interpolation.
        a=s.index('df8_original_band:\n')+len('df8_original_band:\n');b=s.index('sample_bottom_done:\n',a)
        prefix=s[a:b];names=re.findall(r'(?m)^(\w+):',prefix)
        for n in sorted(names,key=len,reverse=True):prefix=re.sub(r'\b'+n+r'\b','df8_copy_'+n,prefix)
        # sample_bottom_done target is just after the copied prefix.
        prefix=prefix.replace('sample_bottom_done','df8_copy_bottom_done')
        code+="""df8_compose:
 ; One contiguous256-byte viewport slice per character row;64 border bytes untouched.
 ldx #0
df8_clear_character_row:
 lda bitmap_row_lo,x
 sta fill_ptr
 lda bitmap_row_hi,x
 ldy drawbuf
 beq df8_clear_bank_ready
 clc
 adc #128
df8_clear_bank_ready:
 sta fill_ptr+1
 cpx #9
 lda #0
 bcc df8_clear_background_ready
 lda #$55
df8_clear_background_ready:
 ldy #0
df8_clear_slice:
 sta (fill_ptr),y
 iny
 bne df8_clear_slice
 inx
 cpx #18
 bne df8_clear_character_row
 jmp compose_screen
df8_column_level:
 lda #255
 sta df8_min
 sta df8_min+1
 lda col
 asl
 sta df8_x
 tax
 lda lower_owner,x
 beq df8_column_near
 tay
 lda fx_wall_plane,y
 jsr df8_plane
 lda df8_distance
 sta df8_min
 lda df8_distance+1
 sta df8_min+1
df8_column_near:
 ldx df8_x
 lda fx_near_plane,x
 cmp #255
 beq df8_column_ready
 jsr df8_plane
 lda df8_distance+1
 cmp df8_min+1
 bcc df8_column_take
 bne df8_column_ready
 lda df8_distance
 cmp df8_min
 bcs df8_column_ready
df8_column_take:
 lda df8_distance
 sta df8_min
 lda df8_distance+1
 sta df8_min+1
df8_column_ready:
 lda df8_min
 sta df8_distance
 lda df8_min+1
 sta df8_distance+1
 jmp df8_classify
draw_band:
 jsr df8_column_level
 lda df8_level
 beq df8_band_done
 cmp #16
 bne df8_partial_band
 jmp df8_original_band
df8_partial_band:
"""+prefix+"""df8_copy_bottom_done:
 jmp df8_samples
df8_band_done:
 rts
ss_draw_band:
 jsr df8_column_level
 lda df8_level
 cmp #16
 bne df8_partial_refined
 jmp df8_original_refined
df8_partial_refined:
 jmp df8_samples
df8_original_samples:
 jmp df8_original_refined
"""
    # Fill the same2449-byte reserved window. Never widen the old payload or guards.
    marker=' .fill 2449,0\n';assert s.count(marker)==1
    s=s.replace(marker,'df8_payload_begin:\n'+code+'df8_payload_end:\n.cerror df8_payload_end-df8_payload_begin > 2449,"Mode8 distance fade payload overflow"\n .fill 2449-(df8_payload_end-df8_payload_begin),0\n')
    return s
