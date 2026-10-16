; Lossless bitmap UI initialization before IRQ install; no frame redraw.
game_ui_init:
 lda #0
 sta ui_page
 sta ui_offset
 lda ui_pages_lo
 sta ui_input
 lda ui_pages_hi
 sta ui_input+1
 lda #0
 sta ui_dest
 lda #$60
 sta ui_dest+1
 jsr ui_decode
 lda #0
 sta ui_dest
 lda #$20
 sta ui_dest+1
 jsr ui_decode
 jsr ui_expand_palette
 jsr ui_raster_to_vic
 ; Clone the identical immutable frame into the other display buffer.
 lda #0
 sta ui_copy
 sta ui_dest
 lda #$20
 sta ui_copy+1
 lda #$60
 sta ui_dest+1
 ldx #32
 jsr ui_clone
 lda #<$5c00
 sta ui_copy
 lda #>$5c00
 sta ui_copy+1
 lda #<SCREEN_B_BASE
 sta ui_dest
 lda #>SCREEN_B_BASE
 sta ui_dest+1
 ldx #4
 jsr ui_clone
game_ui_initialized:
 rts
; Palette bitstream lives temporarily in bitmapB, expanded to fixed screens.
ui_expand_palette:
 lda #0
 sta ui_input
 sta ui_count
 sta ui_dest
 sta ui_copy
 lda #$20
 sta ui_input+1
 lda #$5c
 sta ui_dest+1
 lda #$d8
 sta ui_copy+1
 lda #<1000
 sta ui_distance
 lda #>1000
 sta ui_distance+1
 ldy #0
ui_palette_cell:
 ldx #3
 jsr ui_palette_bits
 cmp #7
 bne ui_palette_index
 ldx #6
 jsr ui_palette_bits
ui_palette_index:
 tax
 lda ui_screen_palette,x
 sta (ui_dest),y
 lda ui_color_palette,x
 sta (ui_copy),y
 inc ui_dest
 bne ui_palette_screen_ready
 inc ui_dest+1
ui_palette_screen_ready:
 inc ui_copy
 bne ui_palette_color_ready
 inc ui_copy+1
ui_palette_color_ready:
 lda ui_distance
 bne ui_palette_count_low
 dec ui_distance+1
ui_palette_count_low:
 dec ui_distance
 lda ui_distance
 ora ui_distance+1
 bne ui_palette_cell
 rts
ui_palette_bits:
 lda #0
 sta ui_page
 lda #1
 sta t1
ui_palette_bit_loop:
 jsr ui_palette_bit
 bcc ui_palette_zero
 lda ui_page
 ora t1
 sta ui_page
ui_palette_zero:
 asl t1
 dex
 bne ui_palette_bit_loop
 lda ui_page
 rts
ui_palette_bit:
 lsr ui_offset
 dec ui_count
 bpl ui_palette_bit_ready
 lda (ui_input),y
 inc ui_input
 bne ui_palette_input_ready
 inc ui_input+1
ui_palette_input_ready:
 lsr
 sta ui_offset
 lda #7
 sta ui_count
ui_palette_bit_ready:
 rts
; Transform exactly8000 scanline-order bytes fromA to the final bitmapB.
; The packed palette scratch is dead now; IRQ and the renderer start later.
ui_raster_to_vic:
 lda #0
 sta ui_copy
 sta ui_input
 lda #$60
 sta ui_copy+1
 lda #$20
 sta ui_input+1
 lda #25
 sta ui_page
ui_raster_block:
 lda #8
 sta ui_offset
ui_raster_row:
 lda ui_input
 sta ui_dest
 lda ui_input+1
 sta ui_dest+1
 lda #40
 sta ui_count
 ldy #0
ui_raster_byte:
 lda (ui_copy),y
 sta (ui_dest),y
 inc ui_copy
 bne ui_raster_source_ready
 inc ui_copy+1
ui_raster_source_ready:
 clc
 lda ui_dest
 adc #8
 sta ui_dest
 bcc ui_raster_dest_ready
 inc ui_dest+1
ui_raster_dest_ready:
 dec ui_count
 bne ui_raster_byte
 inc ui_input
 bne ui_raster_row_ready
 inc ui_input+1
ui_raster_row_ready:
 dec ui_offset
 bne ui_raster_row
 clc
 lda ui_input
 adc #<312
 sta ui_input
 lda ui_input+1
 adc #>312
 sta ui_input+1
 dec ui_page
 bne ui_raster_block
 rts
ui_clone:
 ldy #0
ui_clone_byte:
 lda (ui_copy),y
 sta (ui_dest),y
 iny
 bne ui_clone_byte
 inc ui_copy+1
 inc ui_dest+1
 dex
 bne ui_clone
 rts
ui_decode:
 jsr ui_read
 beq ui_decoded
 bmi ui_backref
 sta ui_count
ui_literal:
 jsr ui_read
 jsr ui_write
 dec ui_count
 bne ui_literal
 jmp ui_decode
ui_backref:
 and #127
 clc
 adc #3
 sta ui_count
 jsr ui_read
 sta ui_distance
 jsr ui_read
 sta ui_distance+1
 sec
 lda ui_dest
 sbc ui_distance
 sta ui_copy
 lda ui_dest+1
 sbc ui_distance+1
 sta ui_copy+1
ui_repeat:
 ldy #0
 lda (ui_copy),y
 jsr ui_write
 inc ui_copy
 bne ui_copy_ready
 inc ui_copy+1
ui_copy_ready:
 dec ui_count
 bne ui_repeat
 jmp ui_decode
ui_decoded:
 rts
ui_write:
 ldy #0
 sta (ui_dest),y
 inc ui_dest
 bne ui_written
 inc ui_dest+1
ui_written:
 rts
ui_read:
 ldy ui_offset
 lda (ui_input),y
 pha
 inc ui_offset
 bne ui_read_done
 inc ui_page
 ldx ui_page
 lda ui_pages_lo,x
 sta ui_input
 lda ui_pages_hi,x
 sta ui_input+1
ui_read_done:
 pla
 rts
ui_input = row0lo
ui_dest = ptr0lo
ui_copy = ptr1lo
ui_offset: .byte 0
ui_page: .byte 0
ui_count: .byte 0
ui_distance: .word 0
