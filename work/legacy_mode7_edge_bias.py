"""Exact private E-D edge errors for known Mode7-C fused XYUVQ traversal.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
No new variables/tables/ZP aliases. Four errors are restored before return.
A/X/Y/architectural flags and stack balance retain the parent contract.
"""
import hashlib,re
def plan(s):
 no=dict(mode7EdgeBias=False)
 if not re.search(r'(?m)^GRAPHICS_MODE = \$07$',s) or 'm31_c_instructions_end = *' not in s:return [],'',no
 if re.search(r'(?mi)^(?:rs|rscn|dyn)_',s):return [],'',no
 first='gr15_trace:\n';last='gr15_store:\n'
 if s.count(first)!=1 or s.count(last)!=1:return [],'',no
 a=s.index(first);b=s.index(last,a);old=s[a:b]
 if hashlib.sha256(old.encode('ascii')).hexdigest()!=EXPECTED:return [],'',dict(no,reason='Unknown fused edge retained')
 for first,last,digest in CONTRACTS:
  if s.count(first)!=1 or s.count(last)!=1:return [],'',dict(no,reason='Other DDA/store retained')
  a=s.index(first);b=s.index(last,a)
  if hashlib.sha256(s[a:b].encode('ascii')).hexdigest()!=digest:return [],'',dict(no,reason='Unknown DDA/store retained')
 new=old
 init=' lda #0\n sta m7_uerr\n sta m7_verr\n sta m3_qerr\n sta gouraud_edge_xerr_lo\n'
 if new.count(init)!=1:return [],'',no
 new=new.replace(init,init.replace(' lda #0\n',' sec\n lda #0\n sbc m7_den\n'),1)
 pos=' lda gouraud_edge_dy\n sec\n sbc #1\n sta gouraud_edge_xerr_lo\n'
 if new.count(pos)!=1:return [],'',no
 new=new.replace(pos,' lda #255\n sta gouraud_edge_xerr_lo\n',1)
 for axis in 'xuvq':
  text=' bcs gr15_'+axis+'_correct\n cmp m7_den\n bcc gr15_'+axis+'_no_correction\n'
  if new.count(text)!=1:return [],'',no
  new=new.replace(text,' bcc gr15_'+axis+'_no_correction\n',1)
 done='gr15_done:\n rts\n';assert new.count(done)==1
 unbias='gr15_done:\n php\n pha\n'
 for name in ('gouraud_edge_xerr_lo','m7_uerr','m7_verr','m3_qerr'):unbias+=' clc\n lda '+name+'\n adc m7_den\n sta '+name+'\n'
 unbias+=' pla\n plp\n rts\n';new=new.replace(done,unbias,1)
 changes=[('gr32-mode7-private-edge-bias',old,new)]
 zero_old='gr15_dda_small_done:\n jmp m7_dda_remainder\n'
 zero_new='gr15_dda_small_done:\n jmp lp11_dda_sign\n'
 divide_old='m7_dda_divide:\n cmp m7_den\n bcc m7_dda_remainder\n sec\n'
 divide_new=divide_old.replace(' sec\n','gr32_dda_known_subtract:\n sec\n')
 jump_old=' lda m7_r\n jmp m7_dda_divide\n'
 jump_new=' lda m7_r\n jmp gr32_dda_known_subtract\n'
 if s.count(zero_old)==s.count(divide_old)==s.count(jump_old)==1:
  changes.extend([('gr32-dda-zero-no-redundant-store',zero_old,zero_new),('gr32-dda-known-subtract-label',divide_old,divide_new),('gr32-dda-known-positive-quotient',jump_old,jump_new)])
 compact=False
 if s.count(PAL_OLD)==1 and s.count(' jsr gr17_prepare_sampler\n')==s.count(' jsr lp8_patch_uv_constants\n')==1:
  changes.append(('gr32-compact-stable-palettes',PAL_OLD,PAL_NEW));compact=True
 return changes,'',dict(mode7EdgeBias=True,errorRepresentation='E-D modulo256 inside fused edge only',channels=['x','u','v','q'],originalErrorStateRestored=True,AXYPAndStackPreserved=True,extraPeakStackDataBytes=2,newVariables=0,newDataTableBytes=0,newGlobalZeroPageAliases=False,compactPalette=compact)

EXPECTED='858665b60fb3176fff1e843c3aa842e904f59a14cd610124f057159e9dcbeaf7'
PAL_OLD=' cmp #1\n bcc gr17_write_dark\n bne gr17_write_bright\n lda #0\n sta gr17_texel_codes+0\n lda #1\n sta gr17_texel_codes+1\n lda #2\n sta gr17_texel_codes+2\n lda #3\n sta gr17_texel_codes+3\n rts\ngr17_write_dark:\n lda #0\n sta gr17_texel_codes+0\n lda #1\n sta gr17_texel_codes+1\n lda #1\n sta gr17_texel_codes+2\n lda #2\n sta gr17_texel_codes+3\n rts\ngr17_write_bright:\n lda #1\n sta gr17_texel_codes+0\n lda #2\n sta gr17_texel_codes+1\n lda #3\n sta gr17_texel_codes+2\n lda #3\n sta gr17_texel_codes+3\ngr17_palette_done:\n rts\n'
PAL_NEW=' ; Exact palettes for class A=0/1/2. X is dead until selector reloads it.\n tax\n clc\n adc #1\n sta gr17_texel_codes+2\n cpx #2\n lda #0\n adc #0\n sta gr17_texel_codes+0\n adc #1\n sta gr17_texel_codes+1\n cpx #1\n lda #2\n adc #0\n sta gr17_texel_codes+3\ngr17_palette_done:\n rts\n'

CONTRACTS=[('m7_dda_setup:\n', '; Signed, pre-viewport table-projection result', '56d8934ed4fa045b3bbdaefc766ff050ae01bd808c912a03431b8c499faecd09'), ('gr15_dda_choose:\n', 'lpa_block_mode7_binary_divider_end:\n', 'c2eb3db3bd04196ae65c2b477197179844839fc9a360686e85fc7fc9e4a8024e'), ('gr15_store:\n', 'gr29_set_store_range:\n', 'fa5d015e3c19af975da8b28a299534637a73bf8cd64ab16cecb7cb6ce5044d9e')]
