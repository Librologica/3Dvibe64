; Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
; Exact Euclidean row recurrence with an8-bit divisor/remainder.
; B and S retain all16 bits. R+RS uses carry as its ninth bit.
er_edge_select:
 lda xyq2_dhi
 beq er_edge_loop
 jmp er_edge_generic
er_edge_loop:
 jsr xyq2_pixel_from_exact
 ldx xyq2_row
 cmp leftb,x
 bcs +
 sta leftb,x
+
 cmp rightb,x
 bcc +
 sta rightb,x
+
 lda xyq2_row
 cmp xyq2_lastrow
 beq er_edge_done
 clc
 lda xyq2_blo
 adc xyq2_slo
 sta xyq2_blo
 lda xyq2_bhi
 adc xyq2_shi
 sta xyq2_bhi
 clc
 lda xyq2_rlo
 adc xyq2_rslo
 sta xyq2_rlo
 bcs er_reduce
 cmp xyq2_dlo
 bcc er_next
er_reduce:
 sec
 lda xyq2_rlo
 sbc xyq2_dlo
 sta xyq2_rlo
 inc xyq2_blo
 bne er_next
 inc xyq2_bhi
er_next:
 inc xyq2_row
 jmp er_edge_loop
er_edge_done:
 rts
