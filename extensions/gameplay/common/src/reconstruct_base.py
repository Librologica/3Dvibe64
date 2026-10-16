"""Palette-aware spatial reconstruction; no texture/geometry work in this pass.
Required Notice: 3Dvibe64. PolyForm Noncommercial1.0.0.
"""
import re
def rgb_palette(root):
    data=[]
    for line in (root/'src/colodore.vpl').read_text().splitlines():
        if re.match(r'^[0-9a-fA-F]{2} [0-9a-fA-F]{2} [0-9a-fA-F]{2}',line):data.append(tuple(int(x,16) for x in line.split()[:3]))
    assert len(data)==16;return data
def distance_table(rgb):
    table=[]
    for a in rgb:
        d=[sum((u-v)**2 for u,v in zip(a,b)) for b in rgb];ranks={v:i for i,v in enumerate(sorted(set(d)))}
        table.extend(ranks[v] for v in d)
    return table
def emit_data(name,data):
    s=name+':\n'
    for i in range(0,len(data),24):s+=' .byte '+','.join(str(v) for v in data[i:i+24])+'\n'
    return s
def generate(root,lab,raw,base):
    rgb=rgb_palette(root)
    lut=[]
    for m in range(64):
        mapping=[0,m&3,(m>>2)&3,(m>>4)&3]
        lut.extend((mapping[n>>2]<<2)|mapping[n&3] for n in range(16))
    data='*=$8a00\nrc_nibble_lut_begin:\n'+emit_data('rc_nibble_lut',lut)+'rc_nibble_lut_end:\n'
    data+='*=$8e00\n'+emit_data('rc_color_rank',distance_table(rgb))
    data+='*=$8f00\nrc_scratch_begin:\n'
    for n,size in [('rc_gap',1),('rc_cell',1),('rc_bitmap_mask',1),('rc_screen_mask',1),('rc_dest_palette',4),('rc_src_palette',4),('rc_mapped',4),('rc_channel',1),('rc_source_base',1),('rc_best_cost',1),('rc_best_code',1),('rc_map_index',1),('rc_raw',1),('rc_low',1),('rc_above',1),('rc_below',1)]:data+=n+f': .fill {size},0\n'
    data+='rc_scratch_end:\n'
    # Cell offsets independent of selected bitmap bank. Source below shares the
    # destination cell except the last gap, where we clamp to the last real row.
    offsets={k:[] for k in ('rc_dest_cell_lo','rc_dest_cell_hi','rc_above_cell_lo','rc_above_cell_hi','rc_below_cell_lo','rc_below_cell_hi')}
    pointers={k:[] for k in ('rc_above_lo','rc_above_hi','rc_below_lo','rc_below_hi','rc_dest0_lo','rc_dest0_hi','rc_dest1_lo','rc_dest1_hi')}
    def ptr(line,r):return raw[2+lab[f'row{line}lo_a']+r-base]+256*raw[2+lab[f'row{line}hi_a']+r-base]
    for gap in range(50):
        r=2*gap+1
        for name,line,row in [('above',0,r-1),('below',0,min(r+1,98)),('dest0',0,r),('dest1',1,r)]:
            a=ptr(line,row);pointers[f'rc_{name}_lo'].append(a&255);pointers[f'rc_{name}_hi'].append(a>>8)
        for name,row in [('dest',r),('above',r-1),('below',min(r+1,98))]:
            off=((ptr(0,row)-0x6000)//8);offsets[f'rc_{name}_cell_lo'].append(off&255);offsets[f'rc_{name}_cell_hi'].append(off>>8)
    data+=' .cerror * > $9000,"Reconstruction scratch exceeds free runtime gap"\n*=$e700\n'
    for k,v in offsets.items():data+=emit_data(k,v)
    data+=' .cerror * > $ed00,"Reconstruction offsets overlap context LUT"\n'
    code='''
rc_dest_screen_lo = $35
rc_dest_screen_hi = $36
rc_dest_color_lo = $37
rc_dest_color_hi = $38
rc_kernel_begin:
rc_render_and_fill:
 jsr draw_depth_buckets
 jmp rc_fill
rc_fill:
 lda #0
 sta rc_gap
 sta rc_bitmap_mask
 sta rc_screen_mask
 lda drawbuf
 beq rc_gap_start
 lda #$40
 sta rc_bitmap_mask
 lda #$58
 sta rc_screen_mask
rc_gap_start:
 ldx rc_gap
 lda rc_above_lo,x
 sta ptr0lo
 lda rc_above_hi,x
 eor rc_bitmap_mask
 sta ptr0hi
 lda rc_below_lo,x
 sta ptr1lo
 lda rc_below_hi,x
 eor rc_bitmap_mask
 sta ptr1hi
 lda rc_dest0_lo,x
 sta row0lo
 lda rc_dest0_hi,x
 eor rc_bitmap_mask
 sta row0hi
 lda rc_dest1_lo,x
 sta row1lo
 lda rc_dest1_hi,x
 eor rc_bitmap_mask
 sta row1hi
 lda rc_dest_cell_lo,x
 sta rc_dest_screen_lo
 sta rc_dest_color_lo
 lda rc_dest_cell_hi,x
 ora #$d8
 sta rc_dest_color_hi
 lda rc_dest_cell_hi,x
 ora #$5c
 eor rc_screen_mask
 sta rc_dest_screen_hi
 lda rc_below_cell_lo,x
 sta p1lo
 sta vx0
 lda rc_below_cell_hi,x
 ora #$d8
 sta vy0
 lda rc_below_cell_hi,x
 ora #$5c
 eor rc_screen_mask
 sta p1hi
 lda rc_above_cell_lo,x
 sta prodlo
 sta vx1
 lda rc_above_cell_hi,x
 ora #$d8
 sta vy1
 lda rc_above_cell_hi,x
 ora #$5c
 eor rc_screen_mask
 sta prodhi
 lda $d021
 and #15
 sta rc_dest_palette
 sta rc_src_palette
 lda #0
 sta rc_cell
rc_cell_start:
 lda rc_cell
 cmp #32
 bne rc_cell_page_ready
 inc ptr0hi
 inc ptr1hi
 inc row0hi
 inc row1hi
rc_cell_page_ready:
 ldy rc_cell
 lda (rc_dest_screen_lo),y
 pha
 and #15
 sta rc_dest_palette+2
 pla
 lsr
 lsr
 lsr
 lsr
 sta rc_dest_palette+1
 lda (rc_dest_color_lo),y
 and #15
 sta rc_dest_palette+3
 lda (prodlo),y
 pha
 and #15
 sta rc_src_palette+2
 pla
 lsr
 lsr
 lsr
 lsr
 sta rc_src_palette+1
 lda (vx1),y
 and #15
 sta rc_src_palette+3
 lda #1
 sta rc_channel
rc_map_channel:
 ldx rc_channel
 lda rc_src_palette,x
 cmp rc_dest_palette,x
 bne rc_search_color
 txa
 jmp rc_store_map
rc_search_color:
 asl
 asl
 asl
 asl
 sta rc_source_base
 lda #255
 sta rc_best_cost
 ldy #0
rc_search_next:
 lda rc_dest_palette,y
 ora rc_source_base
 tax
 lda rc_color_rank,x
 cmp rc_best_cost
 bcs rc_search_skip
 sta rc_best_cost
 sty rc_best_code
rc_search_skip:
 iny
 cpy #4
 bne rc_search_next
 lda rc_best_code
rc_store_map:
 ldx rc_channel
 sta rc_mapped,x
 inc rc_channel
 lda rc_channel
 cmp #4
 bne rc_map_channel
 lda rc_mapped+3
 asl
 asl
 asl
 asl
 sta rc_map_index
 lda rc_mapped+2
 asl
 asl
 ora rc_map_index
 ora rc_mapped+1
 sta rc_map_index
 and #15
 asl
 asl
 asl
 asl
 sta leftval
 lda rc_map_index
 lsr
 lsr
 lsr
 lsr
 clc
 adc #$8a
 sta rightval
 lda rc_cell
 asl
 asl
 asl
 tay
 lda (ptr0lo),y
 jsr rc_translate
 sta rc_above
 lda rc_cell
 asl
 asl
 asl
 tay
 lda (ptr1lo),y
 jsr rc_translate_lower
rc_below_ready:
 sta rc_below
 lda rc_cell
 asl
 asl
 asl
 tay
 lda rc_above
 and #$cc
 sta rc_low
 lda rc_below
 and #$33
 ora rc_low
 sta (row0lo),y
 lda rc_above
 and #$33
 sta rc_low
 lda rc_below
 and #$cc
 ora rc_low
 sta (row1lo),y
 inc rc_cell
 lda rc_cell
 cmp #40
 beq rc_gap_next
 jmp rc_cell_start
rc_gap_next:
 inc rc_gap
 lda rc_gap
 cmp #50
 beq rc_done
 jmp rc_gap_start
rc_done:
 rts
rc_translate:
 beq rc_translate_return
 ldx rc_map_index
 cpx #57
 beq rc_translate_return
 sta rc_raw
 and #15
 tay
 lda (leftval),y
 sta rc_low
 lda rc_raw
 lsr
 lsr
 lsr
 lsr
 tay
 lda (leftval),y
 asl
 asl
 asl
 asl
 ora rc_low
rc_translate_return:
 rts
'''
    for k,v in pointers.items():code+=emit_data(k,v)
    code+='rc_kernel_end:\n .cerror * > $fa00,"Reconstruction code overlaps music"\n'
    return code,data
