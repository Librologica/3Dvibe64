"""Exact coefficient tables for Q8 camera products; selectable RAM tradeoff.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
from camera import copy
from perspective_exact import once

def apply(parts):
    if 'camera_math' not in parts:raise ValueError('ENGINE_CAMERA_TABLE: mobile Q8 camera required')
    for name in ['camera_yaw','camera_pitch']:
        for slot,trig in enumerate(['qc_ys','qc_yc','qc_ps','qc_pc']):
            old=copy(trig,'qc_b',2)+' jsr qc_product\n'
            parts[name]=parts[name].replace(old,copy(trig,'qc_b',2)+f' lda #{slot}\n sta qt_selector\n jsr qc_product\n')
    parts['camera_yaw']=once(parts['camera_yaw'],' sta qc_index\nqc_vertex:\n',
                             ' sta qc_index\n jsr qt_update\nqc_vertex:\n')
    old=parts['camera_math']
    prefix=old[:old.index('qc_product_b_positive:\n')+len('qc_product_b_positive:\n')]
    tail=old[old.index(' lda qc_prod\n cmp #128\n'):]
    product=prefix+' ldx qt_selector\n jsr qt_addresses\n lda #0\n ldx #3\nqt_clear:\n sta qc_prod,x\n dex\n bpl qt_clear\n'
    for byte in range(3):
        product+=f' ldx qc_a+{byte}\n jsr qt_lookup\n clc\n'
        for offset in range(byte,4):
            product+=f' lda qc_prod+{offset}\n'+(f' adc qt_part+{offset-byte}\n' if offset-byte<2 else ' adc #0\n')+f' sta qc_prod+{offset}\n'
    product+=tail
    helper='''qt_lookup:
qt_load_lo:
 lda qt_tables,x
 sta qt_part
qt_load_hi:
 lda qt_tables+256,x
 sta qt_part+1
 rts
qt_addresses:
 lda qt_page_lo,x
 sta qt_load_lo+1
 sta qt_load_hi+1
 sta qt_write_lo+1
 sta qt_write_hi+1
 lda qt_page_hi,x
 sta qt_load_lo+2
 sta qt_write_lo+2
 clc
 adc #1
 sta qt_load_hi+2
 sta qt_write_hi+2
 rts
qt_update:
 lda #0
 sta qt_slot
qt_slot_next:
 ldx qt_slot
 lda qt_valid,x
 beq qt_rebuild
 txa
 asl
 tay
 lda qc_ys,y
 cmp qt_keys,y
 bne qt_rebuild
 lda qc_ys+1,y
 cmp qt_keys+1,y
 beq qt_slot_done
qt_rebuild:
 lda #1
 sta qt_valid,x
 jsr qt_addresses
 txa
 asl
 tay
 lda qc_ys,y
 sta qt_keys,y
 sta qt_mag
 lda qc_ys+1,y
 sta qt_keys+1,y
 sta qt_mag+1
 bpl qt_magnitude_ready
 sec
 lda #0
 sbc qt_mag
 sta qt_mag
 lda #0
 sbc qt_mag+1
 sta qt_mag+1
qt_magnitude_ready:
 lda #0
 sta qt_acc
 sta qt_acc+1
 tax
qt_build_byte:
 lda qt_acc
qt_write_lo:
 sta qt_tables,x
 lda qt_acc+1
qt_write_hi:
 sta qt_tables+256,x
 clc
 lda qt_acc
 adc qt_mag
 sta qt_acc
 lda qt_acc+1
 adc qt_mag+1
 sta qt_acc+1
 inx
 bne qt_build_byte
qt_slot_done:
 inc qt_slot
 lda qt_slot
 cmp #4
 bne qt_slot_next
 rts
'''
    parts['camera_math']=product+helper
    parts['camera_tables']='qt_tables: .fill 2048,0\n'
    parts['data']+='''qt_selector: .byte 0
qt_slot: .byte 0
qt_part: .word 0
qt_acc: .word 0
qt_mag: .word 0
qt_keys: .fill 8,0
qt_valid: .fill 4,0
qt_page_lo: .byte <qt_tables,<(qt_tables+512),<(qt_tables+1024),<(qt_tables+1536)
qt_page_hi: .byte >qt_tables,>(qt_tables+512),>(qt_tables+1024),>(qt_tables+1536)
.cerror qc_yc!=qc_ys+2 || qc_ps!=qc_ys+4 || qc_pc!=qc_ys+6,"Camera coefficient ABI changed"
'''
    return dict(tableBytes=2048,coefficients=4,rounding='identical nearest magnitude, ties away from zero',
                refresh='only changed coefficients',SMC='foreground-only table operands',fallback='select compact original by disabling experiment')
