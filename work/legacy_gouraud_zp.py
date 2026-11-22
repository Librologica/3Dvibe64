"""Closed Mode6 fill lifetime borrowing seven saved private math bytes.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
Original callable entries publish identical state and restore A/X/Y/flags.
Public pointer/advance helpers remain unchanged. No new data or ZP alias.
"""
import hashlib,re
CONTRACTS=[('fill', 'gouraud_fill_bounds:\n', 'gfb_done:\n rts\n', True, '9dbeadba76ebac5eb8f34f0240a73e0f7fd772e64a77b72eae4b8f001aa95e24'), ('raster', 'gouraud_draw_scan_span_bytes:\n', '; Bit-exact extraction of the original per-pixel shade DDA step.', False, 'c5059282e3db18b4136ffdf343c360b212f2967475bba6880e625ef616b8cfa9'), ('pointer', 'gouraud_init_span_pointers:\n', ' rts\n', True, 'b2701a7f6f502d750d1662ea43289c5915c828daa7a19e0c754d9550875dd271'), ('advance', 'gouraud_advance_scan_pixel:\n', 'gasp_step_done:\n sta gouraud_scan_err\n inc gouraud_scan_x\n rts\n', True, 'c28ec3a6cdf18821daa17c65972084070ae0718b784afdee2f28538f25536ee1'), ('coherent', 'gr14_enter:\n', 'lpa_block_gouraud_coherent_end:\n', False, '7dc83a391b8fd2f6519b90d6712cb152e5c68845ea4af50a39e7781ed14de5fa')]
SHADOW={'gouraud_scan_span':'mul16lo','gouraud_scan_delta':'mul16hi','gouraud_scan_dir':'mul16mul','gouraud_scan_shade':'mul16abs','gouraud_scan_err':'mul16rem','gouraud_scan_x':'mul16reslo','gouraud_scan_end':'mul16reshi'}
BLOCK=re.compile(r'\n; Plus allocation block gouraud_zp_fill\n(?:\* = \$[0-9a-f]+|\.virtual \$4000)\nlpa_block_gouraud_zp_fill_begin:\n.*?lpa_block_gouraud_zp_fill_end:\n(?:\.cerror[^\n]+\n|\.endvirtual\n)',re.S)
def strip(s):return BLOCK.sub('',s)
def regions(s):
 out={}
 for name,first,last,inclusive,digest in CONTRACTS:
  a=s.index(first);b=s.index(last,a)+(len(last) if inclusive else 0);body=s[a:b]
  if hashlib.sha256(body.encode('ascii')).hexdigest()!=digest:raise ValueError('Unknown Mode6 '+name)
  out[name]=body
 return out

def transpose_bayer(source, fill, raster, coherent, advance):
    """Pack the shade and Bayer row in one index for the closed Mode 6 span."""
    from legacy_wire_cursor import table
    names = [f'gouraud_bayer_code_lut_y{row}' for row in range(4)]
    rows = [table(source, name) for name in names]
    if any(row is None or len(row) != 33 for row in rows):
        return None
    old_table = re.search(r'(?m)^gouraud_bayer_code_lut_y0:\n'
                          r'(?: \.byte[^\n]*\n)+'
                          r'(?:gouraud_bayer_code_lut_y[123]:\n(?: \.byte[^\n]*\n)+){3}', source)
    operands = re.search(r'(?m)^gouraud_bayer_code_lut_row_lo:\n \.byte[^\n]*\n'
                         r'gouraud_bayer_code_lut_row_hi:\n \.byte[^\n]*\n', source)
    if not old_table or not operands:
        return None
    first = fill.index(' ; Select one screen-anchored Bayer row')
    last = fill.index(' ldx yrow\n lda leftshade,x\n', first)
    fill = fill[:first] + fill[last:]
    setup = '''gr31_span_core:
 ; Keep the screen row in bits 0..1 and the shade in bits 2..7.
 lda yrow
 and #3
 sta gr38_bayer_row+1
 lda mul16abs
 asl
 asl
gr38_bayer_row:
 ora #0
 sta mul16abs
 lda mul16mul
 asl
 asl
 sta gr38_bayer_step
'''
    start = raster.index(' lda mul16mul\n bmi gdsb_uniform_negative\n')
    end = raster.index('gdsb_uniform_shade_ready:\n', start)
    raster = raster[:start] + ''' lda mul16hi
 asl
 asl
 sta gouraud_uniform_endshade
 lda mul16mul
 bmi gdsb_uniform_negative
 clc
 lda mul16abs
 adc gouraud_uniform_endshade
 clv
 jmp gdsb_uniform_shade_ready
gdsb_uniform_negative:
 sec
 lda mul16abs
 sbc gouraud_uniform_endshade
 clv
''' + raster[end:]
    raster = raster.replace('gr31_span_core:\n', setup, 1)
    raster = raster.replace(' adc mul16mul\n', ' adc gr38_bayer_step\n clv\n')
    raster = raster.replace('gdsb_done:\n rts\n', '''gdsb_done:
 ; Restore the caller's unscaled shade and the terminal comparison.
 lda mul16abs
 lsr
 lsr
 sta mul16abs
 lda mul16reslo
 cmp mul16reshi
 rts
''', 1)
    raster = raster.replace(' lda gouraud_uniform_endshade\n sta mul16abs\n rts\n',''' php
 lda gouraud_uniform_endshade
 lsr
 lsr
 sta gouraud_uniform_endshade
 sta mul16abs
 plp
 lda mul16abs
 rts
''',1)
    start = coherent.index(' ; Copy the caller')
    end = coherent.index(' lda #$4c\n', start)
    coherent = coherent[:start] + coherent[end:]
    coherent = coherent.replace(' adc mul16mul\n',' adc gr38_bayer_step\n clv\n')

    # A valid unscaled shade step never sets overflow. Clear it after
    # packed additions so the callable span also keeps that flag.
    # A coherent run without a shade transition already has the complete
    # packed byte. Skip the prefix mask and second load from the same LUT.
    pack = ' ora p1lo\n sty mul16abs\n stx mul16rem\n'
    if raster.count(pack) != 1:
        return None
    raster = raster.replace(pack, ' ora p1lo\ngr38_store_packed:\n sty mul16abs\n stx mul16rem\n')
    coherent = coherent.replace(' cmp #31\n', ' cmp #12\n', 1)
    a = coherent.index('gr14_try_byte:\n')
    b = coherent.index(' tya\n', coherent.index('gr14_one_step:\n', a))
    coherent = coherent[:a] + '''gr14_try_byte:
 ldy mul16abs
 clc
 lda mul16rem
gr14_delta3:
 adc #0
 cmp mul16lo
 bcs gr14_one_step
 tax
 lda gouraud_bayer_code_lut_y0,y
 jmp gr38_store_packed

gr14_one_step:
 sbc mul16lo
 tax
gr14_first_lut:
 lda gouraud_bayer_code_lut_y0,y
 and #$fc
 sta p1lo
''' + coherent[b:]
    advance = advance.replace(' adc mul16mul\n',' adc gr38_bayer_step\n clv\n')
    advance += 'gr38_bayer_step: .byte 0\n'
    # The inactive scalar branch still needs its original symbol to assemble.
    # Confirm that every executable read and relocation of the old table is
    # inside the transformed kernel or the inactive scalar implementation.
    outside = source
    for _, first, last, inclusive, _ in CONTRACTS:
        a = outside.index(first)
        b = outside.index(last, a) + (len(last) if inclusive else 0)
        outside = outside[:a] + outside[b:]
    outside = outside.replace(old_table.group(), '').replace(operands.group(), '')
    references = [line.strip() for line in outside.splitlines() if 'gouraud_bayer_code_lut_y' in line]
    if references != ['lda gouraud_bayer_code_lut_y0,y']:
        return None
    if 'gouraud_bayer_code_lut_row_' in outside:
        return None
    order = [row[shade] for shade in range(33) for row in rows]
    data = 'gouraud_bayer_code_lut_y0:\n' + ''.join(
        ' .byte ' + ','.join(str(value) for value in order[i:i+16]) + '\n'
        for i in range(0, len(order), 16))
    changes = [('gr38-bayer-index-table', old_table.group(), data),
               ('gr38-bayer-retire-row-pointers', operands.group(), '; Bayer row is in the shade index.\n')]
    return fill, raster, coherent, advance, changes


def plan(s):
 if re.search(r'(?mi)^(?:rs|rscn|dyn)_',s):return [],'',dict(mode6SavedSpanRegisters=False,mode6Reason='RuntimeScene/Dynamics retain delivered parent')
 if not re.search(r'(?m)^GRAPHICS_MODE = \$06$',s) or 'GOURAUD_BYTE_SPAN_KERNEL = $01' not in s or 'VIC_COLOR_POLICY_ENABLE = $00' not in s:return [],'',dict(mode6SavedSpanRegisters=False)
 try:r=regions(s)
 except ValueError:return [],'',dict(mode6SavedSpanRegisters=False,mode6Reason='Unknown parent kernel retained')
 addresses=[]
 for n in SHADOW.values():
  m=re.search(r'(?m)^'+n+r' = \$([0-9a-fA-F]+)$',s)
  if not m or not 2<=int(m[1],16)<256:return [],'',dict(mode6SavedSpanRegisters=False,mode6Reason='Private layout not proven')
  addresses.append(int(m[1],16))
 if len(set(addresses))!=len(SHADOW):return [],'',dict(mode6SavedSpanRegisters=False,mode6Reason='Private registers alias')
 outside=s
 for body in r.values():outside=outside.replace(body,'',1)
 if re.search(r'(?m)^ (?:jsr|jmp) gr14_(?:enter|try_byte)\b',outside):return [],'',dict(mode6SavedSpanRegisters=False,mode6Reason='Custom private coherent caller retained')
 pattern=re.compile(r'\b('+'|'.join(SHADOW)+r')\b')
 rewrite=lambda x:pattern.sub(lambda m:SHADOW[m[0]],x)
 fill=rewrite(r['fill']).replace('gouraud_fill_bounds:\n','gouraud_fill_bounds:\n jmp gr31_fill_wrapper\ngr31_fill_core:\n',1)
 assert fill.count(' jsr gouraud_draw_scan_span_bytes\n')==1
 fill=fill.replace(' jsr gouraud_draw_scan_span_bytes\n',' jsr gr31_span_core\n')
 raster=rewrite(r['raster']).replace('gouraud_draw_scan_span_bytes:\n','gouraud_draw_scan_span_bytes:\n jmp gr31_span_wrapper\ngr31_span_core:\n',1)
 raster=raster.replace(' jsr gouraud_init_span_pointers\n',' jsr gr31_init_pointers\n').replace(' jsr gouraud_advance_scan_pixel\n',' jsr gr31_advance_pixel\n')
 pointer=rewrite(r['pointer']).replace('gouraud_init_span_pointers:','gr31_init_pointers:',1)
 advance=rewrite(r['advance']).replace('gouraud_advance_scan_pixel:','gr31_advance_pixel:',1)
 advance=re.sub(r'\bgasp_(\w+)\b',lambda m:'gr31_gasp_'+m[1],advance)
 coherent=rewrite(r['coherent'])
 bayer=transpose_bayer(s,fill,raster,coherent,advance)
 changes=[]
 if bayer is not None:
  fill,raster,coherent,advance,changes=bayer
 saves=''.join(' lda '+n+'\n pha\n' for n in SHADOW.values())
 loads=''.join(' lda '+n+'\n sta '+v+'\n' for n,v in SHADOW.items())
 code=''
 for entry,core in [('fill','fill'),('span','span')]:code+=f'gr31_{entry}_wrapper:\n'+saves+loads+f' jsr gr31_{core}_core\n jmp gr31_publish_restore\n'
 # X indexes only the private owned stack frame; original X/A/P are copied
 # above the seven released slots before SP changes. IRQ pushes below SP.
 code+='gr31_publish_restore:\n php\n pha\n txa\n pha\n tsx\n'
 code+=''.join(' lda '+v+'\n sta '+n+'\n' for n,v in SHADOW.items())
 code+=''.join(f' lda $01{offset:02x},x\n sta {n}\n' for offset,n in enumerate(reversed(list(SHADOW.values())),4))
 for offset in range(1,4):code+=f' lda $01{offset:02x},x\n sta $01{offset+7:02x},x\n'
 code+=' txa\n clc\n adc #7\n tax\n txs\n pla\n tax\n pla\n plp\n rts\n'+pointer+advance
 block='\n; Plus allocation block gouraud_zp_fill\n.virtual $4000\nlpa_block_gouraud_zp_fill_begin:\n'+code+'lpa_block_gouraud_zp_fill_end:\n.endvirtual\n'
 return [('gr31-mode6-fill',r['fill'],fill),('gr31-mode6-span',r['raster'],raster),('gr31-mode6-coherent',r['coherent'],coherent)]+changes,block,dict(mode6TransposedBayer=bayer is not None,mode6SavedSpanRegisters=True,mode6BorrowedBytes=7,mode6PrivateStatePublished=True,mode6OriginalPointerAndAdvanceEntriesRetained=True,mode6AXYPAndScratchPreserved=True,newGlobalScratchAliases=False,mode6NewDataBytes=0,mode6ExtraSavedStackBytes=10)
