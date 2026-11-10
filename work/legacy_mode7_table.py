"""Exact guarded shared Mode7-C byte sampler and compositor tables.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import hashlib,re
BLOCK=re.compile(r'\n; Plus allocation block gr33_m7_\w+\n(?:\* = \$[0-9a-f]+|\.virtual \$4000)\nlpa_block_gr33_m7_\w+_begin:\n.*?lpa_block_gr33_m7_\w+_end:\n(?:\.cerror[^\n]+\n|\.endvirtual\n)',re.S)
def strip(s):return BLOCK.sub('',s)
def plan(s):
 no=dict(mode7Tables=False)
 if not re.search(r'(?m)^GRAPHICS_MODE = \$07$',s) or 'm31_c_instructions_end = *' not in s:return [],'',no
 if re.search(r'(?mi)^(?:rs|rscn|dyn)_',s):return [],'',no
 if 'm3_composite:\n sta m3_base\n ldy mul16reslo\n' not in s:return [],'',no
 for first,last,digest in CONTRACTS:
  if s.count(first)!=1 or s.count(last)!=1:return [],'',dict(no,reason='Unknown kernel retained')
  a=s.index(first);b=s.index(last,a)
  if hashlib.sha256(s[a:b].encode('ascii')).hexdigest()!=digest:return [],'',dict(no,reason='Unknown kernel retained')
 def body(first,last):
  assert s.count(first)==s.count(last)==1,(first,last)
  a=s.index(first);return s[a:s.index(last,a)]
 normal=body('lp8_normal_full_byte:\n','m7_partial:\n')
 fast=body('lp8_fast_m7_full_byte:\n','lpa_block_mode7_immediate_kernel_end:\n')
 setup=body('lp8_select_full_kernel:\n','lpa_block_mode7_immediate_setup_end:\n')
 assert normal.count(' jsr m7_sample\n')==4
 new=normal
 address=''' txa
 lsr
 lsr
 lsr
 lsr
 eor p1hi
 and #$0f
 eor p1hi
 tay
'''
 for phase in range(4):
  inline=address+f'''gr33_m7_fetch_{phase}:
 lda m7_texture_0,y
 ora mul16reslo
 tay
gr33_m7_lookup_{phase}:
 lda gr33_m7_lut0,y
'''
  new=new.replace(' jsr m7_sample\n',inline,1)
 # Absolute byte phases select the exact original Bayer ranks. Cursor is
 # published at phase3, matching the prior stable sampler's batching.
 assert new.count(' inc gouraud_scan_x\n')==4
 new=new.replace(' inc gouraud_scan_x\n','',2).replace(' inc gouraud_scan_x\n',' clc\n lda gouraud_scan_x\n adc #3\n sta gouraud_scan_x\n',1)
 for phase in range(4):
  old=f' ldy #0\nlp8_phase{phase}_lp7_q_advance_site:';assert new.count(old)==1
  new=new.replace(old,f'gr33_m7_qmode_{phase}:\n ldy #0\nlp8_phase{phase}_lp7_q_advance_site:',1)
 split='lp8_phase2_m7_span_uv_begin:\n';assert new.count(split)==1
 new=new.replace(' asl\n asl\n sta p1lo\n',' and #$c0\n sta p1lo\n clc\n',1)
 for mask in ('$30','$0c'):
  new=new.replace(' ora p1lo\n asl\n asl\n sta p1lo\n',f' and #{mask}\n ora p1lo\n sta p1lo\n clc\n',1)
 final='gr33_m7_lookup_3:\n lda gr33_m7_lut0,y\n ora p1lo\n';assert new.count(final)==1
 new=new.replace(final,final.replace(' ora',' and #$03\n ora'),1)
 a=new.index(split);first=new[:a]+' jmp '+split.rstrip(':\n')+'\n';second=new[a:]
 changes=[('gr33-unified-normal',normal,'; GR33 normal byte moved to bounded helpers.\n'),('gr33-remove-duplicate-stable',fast,'lp8_fast_m7_full_byte = lp8_normal_full_byte\n .byte 0\n')]
 # Set all texture operands together, including their low bytes. Unaligned
 # custom textures retain the original address semantics.
 newsetup="""lp8_select_full_kernel:
+ lda gouraud_scan_x
+ clc
+ adc #3
+ and #$fc
+ ora #3
+ cmp gouraud_scan_end
+ bcc gr33_m7_prepare
+ beq gr33_m7_prepare
+ rts
+lp8_patch_uv_constants:
+gr33_m7_prepare:
+ lda m7_fetch+1
+ cmp gr33_m7_fetch_0+1
+ beq gr33_m7_same_low
""".replace('+ ','').replace('+lp','lp').replace('+gr','gr')
 for phase in range(4):newsetup+=f' sta gr33_m7_fetch_{phase}+1\n'
 newsetup+='gr33_m7_same_low:\n lda m7_fetch+2\n cmp gr33_m7_fetch_0+2\n beq gr33_m7_same_high\n'
 for phase in range(4):newsetup+=f' sta gr33_m7_fetch_{phase}+2\n'
 newsetup+='gr33_m7_same_high:\n lda #0\n'
 for phase in range(4):newsetup+=f' sta gr33_m7_qmode_{phase}+1\n'
 newsetup+=' lda yrow\n and #1\ngr33_m7_last_row:\n cmp #255\n beq gr33_m7_ready\n sta gr33_m7_last_row+1\n tax\n lda gr33_m7_table_lo,x\n'
 for phase in range(4):newsetup+=f' sta gr33_m7_lookup_{phase}+1\n'
 newsetup+=' lda gr33_m7_table_hi,x\n'
 for phase in range(4):newsetup+=f' sta gr33_m7_lookup_{phase}+2\n'
 newsetup+='gr33_m7_ready:\n rts\n'
 changes.append(('gr33-table-selector',setup,newsetup))
 for name in ('m3_qcur','m3_qstep'):
  target=' lda '+name+'\n sta '+('mul16reslo' if name=='m3_qcur' else 'mul16sign')+'\n'
  assert s.count(target)==1
  changes.append(('gr33-scale-'+name,target,target.split(' sta ')[0]+' asl\n asl\n sta '+target.split(' sta ')[1]))
 target=' clc\n lda m3_qstep\n adc m3_qdir\n sta mulb\n';assert s.count(target)==1
 changes.append(('gr33-scale-corrected-qstep',target,target.replace(' sta mulb\n',' asl\n asl\n sta mulb\n')))
 target=' lda mul16reslo\n sta m3_qcur\n';assert s.count(target)==1
 changes.append(('gr33-publish-unscaled-q',target,target.replace(' sta',' lsr\n lsr\n sta')))
 # Partial bytes retain the original comparator, reading the unscaled Q.
 target='m3_composite:\n sta m3_base\n ldy mul16reslo\n';assert s.count(target)==1
 changes.append(('gr33-partial-q-unscale',target,'m3_composite:\n sta m3_base\n lda mul16reslo\n lsr\n lsr\n tay\n lda m3_base\n'))
 # The original Bayer thresholds are 1..16. Thresholds 4/8/12 give
 # the same two-bit value at x and x+2. Pack all four horizontal
 # positions, then select each contribution with its physical mask.
 parts={'gr33_m7_byte0':first,'gr33_m7_byte1':second}
 def light(texel,q,rank):
  if q<10 and texel!=1:return texel-1+(q>=7 and (q-6)*4>=rank)
  if q>=23 and texel!=3:return texel+1 if q>=26 else texel+((q-22)*4>=rank)
  return texel
 for row,ranks in enumerate(((1,9,3,11),(13,5,15,7))):
  values=[]
  for q in range(33):
   for texel in range(4):
    packed=0
    for rank in ranks:packed=(packed<<2)|(light(texel,q,rank)&3)
    values.append(packed)
  parts['gr33_m7_lut'+str(row)]='gr33_m7_lut'+str(row)+':\n .byte '+','.join(map(str,values))+'\n'
 parts['gr33_m7_phases']='gr33_m7_table_lo:\n .byte <gr33_m7_lut0,<gr33_m7_lut1\ngr33_m7_table_hi:\n .byte >gr33_m7_lut0,>gr33_m7_lut1\n'
 parts={'gr33_m7_combined':''.join(parts.values())}
 block=''
 for name,text in parts.items():block+='\n; Plus allocation block '+name+'\n.virtual $4000\nlpa_block_'+name+'_begin:\n'+text+'lpa_block_'+name+'_end:\n.endvirtual\n'
 return changes,block,dict(mode7Tables=True,tableBytes=264,privateQScale=4,mergedStableAndVaryingKernel=True)

CONTRACTS=[('lp8_normal_full_byte:\n', 'm7_partial:\n', 'a5605160c9d8a00db55673548dcd33a06d89c380b18e400f5b95bbc49d5ebc2d'), ('lp8_fast_m7_full_byte:\n', 'lpa_block_mode7_immediate_kernel_end:\n', '1a0382df45bfda85bc3c0e2a22eb849d8e8109d2e008ea123c38e220b9867330'), ('lp8_select_full_kernel:\n', 'lpa_block_mode7_immediate_setup_end:\n', '8cfb98fd7447685127143872458ad62a8511a0a1eda12472df210a3d53464a63'), ('gr28_span_core:\n', 'm7_byte_dispatch:\n', '2ba8ac025ef78a6041fa61c722140c398f06ddb6844e1c5c2994505b3349f985'), ('m3_advance_q:\n', 'm3_advance_q_end = *\n', '44882a794d5ded28bd578ac2a9ed48c7622f977f5e9d536e6840b6ba6cb5b165'), ('m3_composite:\n', 'm31_c_instructions_end = *\n', '8de0ac8a3838752154c4687a839efb1ac8ebad91314211da548f789fd3d5c47a')]
