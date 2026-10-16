"""Private demo: exact two-row attribute DDA, full one-row geometry.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""

def hook(text):
    pairs=[
        ('tq_row_loop:\n ; ceil((integer-Q2 + remainder/dy)/4), including exact fractional ties.\n lda tq_cur0\n',
         'tq_row_loop:\n ; ceil((integer-Q2 + remainder/dy)/4), including exact fractional ties.\n jmp we_edge_ready\n'),
        (' sta leftb,x\n lda tq_cur0+1\n', ' sta leftb,x\nwe_left_callsite:\n jmp we_write_left\n'),
        (' sta tq_closed,x\n lda tq_cur0+1\n', ' sta tq_closed,x\nwe_right_callsite:\n jmp we_write_right\n'),
        ('tq_advance:\n clc\n lda tq_cur0,x\n','tq_advance:\n jmp we_advance_rows\n nop\n')]
    for before,after in pairs:
        assert text.count(before)==1,(before,text.count(before))
        text=text.replace(before,after)
    return text

def kernel():
    return '''
 .cerror PROJ_SCREEN_MAX_Y != 99,"Even-edge proof expects 100 logical rows"
 .cerror PROJ_SCREEN_MAX_Y*8 >= 65536,"Double remainder could overflow"
; Three private free gaps; no original engine address is moved.
*=$8f20
we_advance_one:
 clc
 lda tq_cur0,x
 adc tq_step0,x
 sta tq_cur0,x
 lda tq_cur1,x
 adc tq_step1,x
 sta tq_cur1,x
 lda tq_cur2,x
 adc tq_step2,x
 sta tq_cur2,x
 clc
 lda tq_err0,x
 adc tq_rem0,x
 sta tq_err0,x
 lda tq_err1,x
 adc tq_rem1,x
 sta tq_err1,x
 cmp tq_dy+1
 bcc we_one_done
 bne we_one_correct
 lda tq_err0,x
 cmp tq_dy
 bcc we_one_done
we_one_correct:
 sec
 lda tq_err0,x
 sbc tq_dy
 sta tq_err0,x
 lda tq_err1,x
 sbc tq_dy+1
 sta tq_err1,x
 inc tq_cur0,x
 bne we_one_done
 inc tq_cur1,x
 bne we_one_done
 inc tq_cur2,x
we_one_done:
 rts
we_one_end:
 .cerror * > $9000,"Even-edge helper exceeds private runtime gap"

*=$ef00
we_prepare_steps:
 ; Prime attributes to first even row using ORIGINAL one-row increments.
 ; Geometry remains at the original first row.
 lda tq_row
 and #1
 beq we_double_begin
 ldx #1
we_prime:
 jsr we_advance_one
 inx
 cpx #5
 bne we_prime
we_double_begin:
 ldx #1
we_double:
 ; q' = 2q + floor(2r/dy), r' = 2r mod dy. 24-bit signed q.
 asl tq_step0,x
 rol tq_step1,x
 rol tq_step2,x
 asl tq_rem0,x
 rol tq_rem1,x
 lda tq_rem1,x
 cmp tq_dy+1
 bcc we_double_next
 bne we_double_correct
 lda tq_rem0,x
 cmp tq_dy
 bcc we_double_next
we_double_correct:
 sec
 lda tq_rem0,x
 sbc tq_dy
 sta tq_rem0,x
 lda tq_rem1,x
 sbc tq_dy+1
 sta tq_rem1,x
 inc tq_step0,x
 bne we_double_next
 inc tq_step1,x
 bne we_double_next
 inc tq_step2,x
we_double_next:
 inx
 cpx #5
 bne we_double
 rts
we_prepare_end:
 .cerror * > $efd0,"Even-edge preparation overlaps exact divider"

*=$e866
we_edge_ready:
 jsr we_prepare_steps
we_geometry_row:
 lda tq_cur0
 jmp tq_row_loop+3
we_write_left:
 txa
 and #1
 bne we_left_skip
 lda tq_cur0+1
 jmp we_left_callsite+3
we_left_skip:
 jmp tq_right
we_write_right:
 txa
 and #1
 bne we_right_skip
 lda tq_cur0+1
 jmp we_right_callsite+3
we_right_skip:
 jmp tq_next_row
we_advance_rows:
 ldx #0
 jsr we_advance_one
 ; When entering an odd row, prepare attributes for the FOLLOWING even row.
 ; When entering an even row, its attributes are already ready.
 lda tq_row
 and #1
 beq we_rows_ready
 ldx #1
we_advance_attributes:
 jsr we_advance_one
 inx
 cpx #5
 bne we_advance_attributes
we_rows_ready:
 jmp we_geometry_row
we_dispatch_end:
 .cerror * > $e900,"Even-edge dispatch overlaps byte contribution LUTs"
'''
