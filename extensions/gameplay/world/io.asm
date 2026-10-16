; Bounded KERNAL sequential input. Entire block must remain below $D000.
; Save native zero page and RAM vectors: the bootstrap used dead KERNAL RAM.
wg_read:
wg_io_begin:
 sei
 lda $01
 sta wg_port
 lda $dd00
 sta wg_dd00
 lda $dd02
 sta wg_dd02
 ldx #0
-
 lda $02,x
 sta wg_zp,x
 inx
 cpx #254
 bne -
 ldx #31
-
 lda $0314,x
 sta wg_vectors,x
 dex
 bpl -
 lda wg_target
 clc
 adc #$30
 sta wg_name+3
 lda #$36
 sta $01
 jsr $ff8a
 lda #<wg_io_irq
 sta $0314
 lda #>wg_io_irq
 sta $0315
 lda #0
 sta $02a1 ; stale bootstrap RAM must not enable RS232 wait
 ldx #0
-
 sta $02,x
 inx
 cpx #254
 bne -
 sta wg_io_error
 sta wg_length
 sta wg_length+1
 sta $98
 sta $99
 sta $90
 jsr $ff90
 lda #3
 sta $9a
 lda #<wg_arena
 sta $fb
 lda #>wg_arena
 sta $fc
 lda #8
 ldx #<wg_name
 ldy #>wg_name
 jsr $ffbd
 lda #2
 ldx #8
 ldy #2
 jsr $ffba
 cli
 jsr $ffc0
 bcs wg_io_fail
 ldx #2
 jsr $ffc6
 bcs wg_io_fail
wg_read_byte:
 jsr $ffcf
 sta wg_io_byte
 jsr $ffb7
 sta wg_io_status
 and #$bf
 bne wg_io_fail
 lda wg_length+1
 cmp #4
 bcs wg_io_fail
 ldy #0
 lda wg_io_byte
 sta ($fb),y
 inc $fb
 bne +
 inc $fc
+
 inc wg_length
 bne +
 inc wg_length+1
+
 lda wg_io_status
 and #$40
 beq wg_read_byte
 jmp wg_io_close
wg_io_fail:
 lda #1
 sta wg_io_error
wg_io_close:
 jsr $ffcc
 lda #2
 jsr $ffc3
 sei
 ldx #31
-
 lda wg_vectors,x
 sta $0314,x
 dex
 bpl -
 ldx #0
-
 lda wg_zp,x
 sta $02,x
 inx
 cpx #254
 bne -
 lda wg_dd00
 sta $dd00
 lda wg_dd02
 sta $dd02
 lda wg_port
 sta $01
 cli
wg_io_end:
 rts
; KERNAL IRQ entry pushes A/X/Y just like the native RAM entry. Keep the
; displayed bitmap fixed, and count every PAL refresh while zero page is ROM-owned.
wg_io_irq:
 lda #1
 sta $d019
 inc sim_vblank_count
 inc fps_vblank_count
 jsr demo_count_refresh
 lda fps_vblank_count
 cmp #50
 bcc +
 lda #0
 sta fps_vblank_count
 lda #1
 sta fps_second_flag
+
 lda #0
 sta $d012
 jmp tr_irq_exit
wg_name: .text "WG00,S,R"
wg_port: .byte 0
wg_dd00: .byte 0
wg_dd02: .byte 0
wg_io_error: .byte 0
wg_io_byte: .byte 0
wg_io_status: .byte 0
wg_length: .word 0
wg_vectors: .fill 32,0
wg_zp: .fill 254,0
