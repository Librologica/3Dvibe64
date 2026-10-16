; Mode 7 affine Q4.4. No lighting and no division/multiply in the texel loop.
gouraud_draw_scan_span_bytes:
 jsr gouraud_init_span_pointers
m7_byte_dispatch:
 lda gouraud_scan_x
 and #3
 bne m7_partial
 lda gouraud_scan_end
 sec
 sbc gouraud_scan_x
 cmp #3
 bcc m7_partial
m7_full_byte:
 jsr m7_sample
 asl
 asl
 asl
 asl
 asl
 asl
 sta m7_packed
 jsr m7_advance
 jsr m7_sample
 asl
 asl
 asl
 asl
 ora m7_packed
 sta m7_packed
 jsr m7_advance
 jsr m7_sample
 asl
 asl
 ora m7_packed
 sta m7_packed
 jsr m7_advance
 jsr m7_sample
 ora m7_packed
m7_full_write:
 ldy #0
 sta (ptr0lo),y
 sta (ptr1lo),y
 lda gouraud_scan_x
 cmp gouraud_scan_end
 beq m7_span_done
 jsr m7_advance
 jmp m7_next_byte
m7_partial:
 lda #0
 sta m7_packed
 lda #255
 sta maskv
m7_partial_sample:
 lda gouraud_scan_x
 and #3
 sta shadeidx
 jsr m7_sample
 asl
 asl
 ora shadeidx
 tay
 lda m7_pair,y
 ora m7_packed
 sta m7_packed
 ldx shadeidx
 lda gouraud_pair_clear,x
 and maskv
 sta maskv
 cpx #3
 beq m7_partial_write
 lda gouraud_scan_x
 cmp gouraud_scan_end
 beq m7_partial_write
 jsr m7_advance
 jmp m7_partial_sample
m7_partial_write:
 ldy #0
 lda (ptr0lo),y
 and maskv
 ora m7_packed
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora m7_packed
 sta (ptr1lo),y
 lda gouraud_scan_x
 cmp gouraud_scan_end
 beq m7_span_done
 jsr m7_advance
m7_next_byte:
 clc
 lda ptr0lo
 adc #8
 sta ptr0lo
 bcc m7_ptr0_done
 inc ptr0hi
m7_ptr0_done:
 clc
 lda ptr1lo
 adc #8
 sta ptr1lo
 bcc m7_ptr1_done
 inc ptr1hi
m7_ptr1_done:
 jmp m7_byte_dispatch
m7_span_done:
 rts

; Texture is page aligned. (V & $f0) | (U >> 4) selects one of 256 texels.
; Operand high byte is set once per face; same texture for clipped fan.
m7_sample:
m7_address_begin:
 lda m7_v
 and #$f0
 sta m7_index
 lda m7_u
 lsr
 lsr
 lsr
 lsr
 ora m7_index
 tay
m7_fetch:
 lda m7_texture_0,y
m7_fetch_end:
 rts

; One quotient add and at most one remainder correction per channel.
; Carry from the error sum is explicitly included (span can exceed 128).
m7_advance:
m7_span_uv_begin:
 clc
 lda m7_u
 adc m7_ustep
 sta m7_u
 clc
 lda m7_uerr
 adc m7_urem
 bcs m7_u_correct
 cmp m7_den
 bcc m7_u_store
m7_u_correct:
 sec
 sbc m7_den
 sta m7_uerr
 clc
 lda m7_u
 adc m7_udir
 sta m7_u
 jmp m7_v_advance
m7_u_store:
 sta m7_uerr
m7_v_advance:
 clc
 lda m7_v
 adc m7_vstep
 sta m7_v
 clc
 lda m7_verr
 adc m7_vrem
 bcs m7_v_correct
 cmp m7_den
 bcc m7_v_store
m7_v_correct:
 sec
 sbc m7_den
 sta m7_verr
 clc
 lda m7_v
 adc m7_vdir
 sta m7_v
 jmp m7_uv_done
m7_v_store:
 sta m7_verr
m7_uv_done:
 inc gouraud_scan_x
 rts

m7_prepare_span:
 sec
 lda rightval
 sbc leftval
 sta m7_den
 lda leftval
 sta gouraud_scan_x
 lda rightval
 sta gouraud_scan_end
 ldy yrow
 lda leftshade,y
 sta m7_u
 ldx rightshade,y
 jsr m7_dda_setup
 lda m7_q
 sta m7_ustep
 lda m7_r
 sta m7_urem
 lda m7_dir
 sta m7_udir
 ldy yrow
 lda m7_leftv,y
 sta m7_v
 ldx m7_rightv,y
 jsr m7_dda_setup
 lda m7_q
 sta m7_vstep
 lda m7_r
 sta m7_vrem
 lda m7_dir
 sta m7_vdir
 lda #0
 sta m7_uerr
 sta m7_verr
 rts

; A=start, X=end, m7_den=length. Signed magnitude quotient/remainder.
; Setup only, never in the texture fetch / per-pixel hot loop.
m7_dda_setup:
 sta m7_start
 stx m7_delta
 lda #1
 sta m7_dir
 sec
 lda m7_delta
 sbc m7_start
 bcs m7_dda_positive
 eor #255
 clc
 adc #1
 ldx #255
 stx m7_dir
m7_dda_positive:
 sta m7_r
 lda #0
 sta m7_q
 lda m7_den
 beq m7_dda_zero
 lda m7_r
m7_dda_divide:
 cmp m7_den
 bcc m7_dda_remainder
 sec
 sbc m7_den
 inc m7_q
 jmp m7_dda_divide
m7_dda_remainder:
 sta m7_r
 lda m7_dir
 bpl m7_dda_done
 sec
 lda #0
 sbc m7_q
 sta m7_q
m7_dda_done:
 rts
m7_dda_zero:
 sta m7_r
 rts

; Signed, pre-viewport table-projection result in A; return A unchanged.
; This fills the raw coordinates required by polygon UV clipping for fixed
; cameras. Walk cameras already produce their own raw 16-bit coordinates.
m7_store_fixed_raw_x:
 sta p1lo
 ldy #0
 cmp #$80
 bcc m7_raw_x_positive
 dey
m7_raw_x_positive:
 sty p1hi
 ldy tmpidx
 clc
 adc #PROJ_CENTER_X
 sta pxrawlo,y
 lda p1hi
 adc #0
 sta pxrawhi,y
 lda p1lo
 rts
m7_store_fixed_raw_y:
 sta p1lo
 ldy #0
 cmp #$80
 bcc m7_raw_y_positive
 dey
m7_raw_y_positive:
 sty p1hi
 ldy tmpidx
 sec
 lda #PROJ_CENTER_Y
 sbc p1lo
 sta pyrawlo,y
 lda #0
 sbc p1hi
 sta pyrawhi,y
 lda p1lo
 rts
