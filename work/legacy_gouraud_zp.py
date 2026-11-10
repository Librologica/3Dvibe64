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
 return [('gr31-mode6-fill',r['fill'],fill),('gr31-mode6-span',r['raster'],raster),('gr31-mode6-coherent',r['coherent'],rewrite(r['coherent']))],block,dict(mode6SavedSpanRegisters=True,mode6BorrowedBytes=7,mode6PrivateStatePublished=True,mode6OriginalPointerAndAdvanceEntriesRetained=True,mode6AXYPAndScratchPreserved=True,newGlobalScratchAliases=False,mode6NewDataBytes=0,mode6ExtraSavedStackBytes=10)
