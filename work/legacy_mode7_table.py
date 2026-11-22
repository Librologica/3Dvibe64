"""Exact guarded shared Mode7-C byte sampler and compositor tables.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import hashlib,re
BLOCK=re.compile(r'\n; Plus allocation block gr33_m7_\w+\n(?:\* = \$[0-9a-f]+|\.virtual \$4000)\nlpa_block_gr33_m7_\w+_begin:\n.*?lpa_block_gr33_m7_\w+_end:\n(?:\.cerror[^\n]+\n|\.endvirtual\n)',re.S)
def strip(s):return BLOCK.sub('',s)

def retain_v_for_index(code, phase):
    """Advance independent Q before V, then use the new V already in A."""
    v = f'lp8_phase{phase}_m7_v_advance:\n'
    q = f'lp8_phase{phase}_m7_uv_done:\n'
    end = f'gr28_inline_q_end_{phase}:\n'
    if any(code.count(key) != 1 for key in (v, q, end)):
        return code
    a = code.index(v)
    b = code.index(q, a)
    c = code.index(end, b) + len(end)
    index = ' lda p1hi\n and #$f0\n ora gr34_m7_u_nibble,x\n'
    if not code.startswith(index, c):
        return code
    v_code, q_code = code[a:b], code[b:c]
    if not v_code.endswith(' adc p1hi\n sta p1hi\n'):
        return code
    to_v = ' jmp ' + v.removesuffix(':\n') + '\n'
    if code[:a].count(to_v) != 1:
        return code
    prefix = code[:a].replace(to_v, ' jmp ' + q.removesuffix(':\n') + '\n', 1)
    return prefix + q_code + v_code + code[c+len(' lda p1hi\n'):]


def carry_divider(source):
    """Use small exact quotients and accumulate binary quotient bits via carry."""
    start = 'gr15_dda_choose:\n'
    end = 'lpa_block_mode7_binary_divider_end:\n'
    if source.count(start) != 1 or source.count(end) != 1:
        return None
    a = source.index(start)
    b = source.index(end, a)
    old = source[a:b]
    if hashlib.sha256(old.encode('ascii')).hexdigest() != 'c3b2c8ff375b461e95564b6cf43f3a30321f2918ab0a9100b7af43fe4120dd82':
        return None
    new = '''gr15_dda_choose:
 ; The caller holds the magnitude in A and carry is set for n >= D.
 sbc m7_den
 cmp m7_den
 bcc gr41_m7_quotient_one
 sbc m7_den
 cmp m7_den
 bcc gr41_m7_quotient_two
 lda m7_r
 ; Test n >= 8*D without overflowing the denominator.
 lsr
 lsr
 lsr
 cmp m7_den
 bcs gr15_dda_binary
 lda m7_r
 jmp gr32_dda_known_subtract
gr41_m7_quotient_two:
 inc m7_q
gr41_m7_quotient_one:
 inc m7_q
 jmp m7_dda_remainder
gr15_dda_binary:
 ; D <= 31 here. The final comparison supplies each quotient bit,
 ; and ROL writes it while extracting the next numerator bit.
 lda m7_r
 sta m7_q
 lda #0
 asl m7_q
'''
    for i in range(8):
        new += f''' rol
 cmp m7_den
 bcc gr15_div_bit{i}
 sbc m7_den
gr15_div_bit{i}:
 rol m7_q
'''
    new += ' sta m7_r\n clc\n jmp lp11_dda_sign\n'
    return ('gr41-m7-carry-divider', old, new)


def plan(s, coordinate_lookup=False):
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
 coordinate_lookup = coordinate_lookup and screen_cell_lookup(s) is not None
 scalar_address = None
 if coordinate_lookup:
  short_address = ' lda p1hi\n and #$f0\n ora gr34_m7_u_nibble,x\n tay\n'
  scalar_address = ('gr34-scalar-texture-index','m7_address_begin:\n'+address+'m7_fetch:\n',
                    'm7_address_begin:\n'+short_address+'m7_fetch:\n')
  address = short_address
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
 split='lp8_phase2_m7_span_uv_begin:\n';assert new.count(split)==1
 new=new.replace(' asl\n asl\n sta p1lo\n',' and #$c0\n sta p1lo\n clc\n',1)
 for mask in ('$30','$0c'):
  new=new.replace(' ora p1lo\n asl\n asl\n sta p1lo\n',f' and #{mask}\n ora p1lo\n sta p1lo\n clc\n',1)
 final='gr33_m7_lookup_3:\n lda gr33_m7_lut0,y\n ora p1lo\n';assert new.count(final)==1
 new=new.replace(final,final.replace(' ora',' and #$03\n ora'),1)
 a=new.index(split);first=new[:a]+' jmp '+split.rstrip(':\n')+'\n';second=new[a:]
 changes=[('gr33-unified-normal',normal,'; GR33 normal byte moved to bounded helpers.\n'),('gr33-remove-duplicate-stable',fast,'lp8_fast_m7_full_byte = lp8_normal_full_byte\n .byte 0\n')]
 fetch_users = [line.strip() for line in s.splitlines() if re.search(r'\bm7_fetch\b', line)]
 fixed_texture = (s.count('m7_fetch:\n lda m7_texture_0,y\n') == 1
                  and all(line in ('m7_fetch:', 'lda m7_fetch+1', 'lda m7_fetch+2')
                          for line in fetch_users))

 partial = '''m7_partial_sample:
 lda gouraud_scan_x
 and #3
 sta shadeidx
 jsr m7_sample
 asl
 asl
 ora shadeidx
 tay
 lda m7_pair,y
 ora p1lo
 sta p1lo
 ldy shadeidx
 lda gouraud_pair_clear,y
'''
 packed_partial = (coordinate_lookup and fixed_texture and s.count(partial) == 1
                   and 'gouraud_pair_clear: .byte $3f,$cf,$f3,$fc' in s)
 if packed_partial:
  packed = '''m7_partial_sample:
 lda gouraud_scan_x
 and #3
 sta shadeidx
 lda p1hi
 and #$f0
 ora gr34_m7_u_nibble,x
 tay
 lda m7_texture_0,y
 ora mul16reslo
 tay
gr40_m7_partial_lut:
 lda gr33_m7_lut0,y
 ldy shadeidx
 and gr40_m7_pair_keep,y
 ora p1lo
 sta p1lo
 lda gouraud_pair_clear,y
'''
  changes.append(('gr40-packed-partial-sampler', partial, packed))
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
 newsetup+='gr33_m7_same_high:\n'
 if fixed_texture:
  # With no operand writer, the byte and scalar samplers already refer
  # to the same immutable texture. Keep the mutable path for other sources.
  newsetup = newsetup[:newsetup.index('lda m7_fetch+1\n')]
 if packed_partial:
  newsetup = 'lp8_select_full_kernel:\nlp8_patch_uv_constants:\ngr33_m7_prepare:\n'
 newsetup+=' lda yrow\n and #1\ngr33_m7_last_row:\n cmp #255\n beq gr33_m7_ready\n sta gr33_m7_last_row+1\n tax\n'
 if not fixed_texture:
  newsetup+=' lda gr33_m7_table_lo,x\n'
  for phase in range(4):newsetup+=f' sta gr33_m7_lookup_{phase}+1\n'
 newsetup+=' lda gr33_m7_table_hi,x\n'
 for phase in range(4):newsetup+=f' sta gr33_m7_lookup_{phase}+2\n'
 if packed_partial:
  newsetup += ' sta gr40_m7_partial_lut+2\n'
 newsetup+='gr33_m7_ready:\n rts\n'
 changes.append(('gr33-table-selector',setup,newsetup))
 # The full-byte Q branches depend only on whether the band is stable.
 # Partial sampling still installs its own compositor target for every band.
 band_patch='''lp7_band_patch:
 sty lp7_q_advance_site
 pha
 tya
 cmp #$2c
 beq gr28_inline_q_stable
 lda #$d0
 bne gr28_inline_q_patch
gr28_inline_q_stable:
 lda #$f0
gr28_inline_q_patch:
 sta lp8_phase0_lp7_q_advance_site
 sta lp8_phase1_lp7_q_advance_site
 sta lp8_phase2_lp7_q_advance_site
 sta lp8_phase3_lp7_q_advance_site
 pla
 stx m7_fetch_end+1
 sta m7_fetch_end+2
 rts
'''
 q_sites=[]
 for phase in range(4):
  site=f'lp8_phase{phase}_lp7_q_advance_site:'
  old=f' ldy #0\n{site}\n bne gr28_inline_q_end_{phase}\n clc\n'
  short=f' clc\n{site}\n bcs gr28_inline_q_end_{phase}\n'
  q_sites.append((old,short))
 if s.count(band_patch)==1 and all(first.count(old)+second.count(old)==1 for old,_ in q_sites):
  for old,short in q_sites:
   first=first.replace(old,short,1)
   second=second.replace(old,short,1)
 if s.count(band_patch)==1:
  cached_patch=band_patch.replace(' sty lp7_q_advance_site\n',' cpy lp7_q_advance_site\n beq gr33_m7_band_target\n sty lp7_q_advance_site\n')
  cached_patch=cached_patch.replace(' stx m7_fetch_end+1\n','gr33_m7_band_target:\n stx m7_fetch_end+1\n')
  if all(old not in first and old not in second for old,_ in q_sites):
   # Carry is always clear here. BCS runs the varying DDA and BCC skips
   # it in stable bands. This saves a register load for every texel.
   cached_patch=cached_patch.replace(' lda #$d0\n',' lda #$b0\n').replace(' lda #$f0\n',' lda #$90\n')
  changes.append(('gr33-reuse-full-byte-q-branches',band_patch,cached_patch))

 if packed_partial:
  # Byte phases and the packed compositor do not read the scan cursor.
  # Keep it at the byte start; advance to the exclusive end in one add.
  last_phase = ' clc\n lda gouraud_scan_x\n adc #3\n sta gouraud_scan_x\n'
  write_test = ' lda gouraud_scan_x\n cmp gouraud_scan_end\n beq m7_span_done\n'
  advance = ' inc gouraud_scan_x\n jmp m7_next_byte\n'
  if all(second.count(text) == 1 for text in (last_phase, write_test, advance)):
   setup_end = 'gr33_m7_prepare:\n'
   cache_limit = ' ldy gouraud_scan_end\n iny\n sty gr41_m7_full_limit+1\n'
   setup_change = changes.index(('gr33-table-selector', setup, newsetup))
   newsetup = newsetup.replace(setup_end, setup_end + cache_limit, 1)
   changes[setup_change] = ('gr33-table-selector', setup, newsetup)
   second = second.replace(last_phase, '', 1)
   second = second.replace(write_test, ''' clc
 lda gouraud_scan_x
 adc #4
 sta gouraud_scan_x
gr41_m7_full_limit:
 cmp #0
 beq gr41_m7_full_end
''', 1)
   second = second.replace(advance, ''' jmp m7_next_byte
gr41_m7_full_end:
 dec gouraud_scan_x
 jmp m7_span_done
''', 1)

 if coordinate_lookup and all(old not in first and old not in second for old,_ in q_sites):
  first = retain_v_for_index(retain_v_for_index(first, 0), 1)
  second = retain_v_for_index(second, 2)
  # A numerator below D has zero quotient for either sign. Return it
  # before checking the rarer unit / half denominators or binary division.
  original = '''m7_dda_positive:
 sta m7_r
 lda #0
 sta m7_q
 lda m7_den
 beq m7_dda_zero
 cmp #1
 beq lp11_dda_power1
 cmp #2
 beq lp11_dda_power2
 lda m7_r
 cmp m7_den
 bcc lp11_dda_sign
 jmp gr15_dda_choose
'''
  if s.count(original) == 1:
   division = carry_divider(s)
   fast = '''m7_dda_positive:
 sta m7_r
 cmp m7_den
 lda #0
 sta m7_q
 bcc gr39_m7_zero_quotient
 lda m7_den
 beq m7_dda_zero
 cmp #1
 beq lp11_dda_power1
 cmp #2
 beq lp11_dda_power2
 lda m7_r
 jmp gr15_dda_choose
gr39_m7_zero_quotient:
 rts
'''
   changes.append(('gr39-m7-small-numerator', original, fast))
   if division is not None:
    changes.append(division)
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
 high_table='gr33_m7_table_hi:\n .byte >gr33_m7_lut0,>gr33_m7_lut1\n'
 if fixed_texture:
  # Interleave the unchanged first part of the sampler with the two LUTs.
  # The LUTs now share a low byte, using the existing jump in the byte loop.
  combined=first.removesuffix(' jmp '+split.rstrip(':\n')+'\n')+second
  a=combined.index('gr33_m7_lookup_1:\n')
  core_head=combined[:a]+' jmp gr33_m7_lookup_1\n'
  padding=('.cerror *-gr33_m7_lut0 > 256,"Mode 7 sampler exceeds interleaved table"\n'
           ' .fill 256-(*-gr33_m7_lut0),0\n')
  combined=parts['gr33_m7_lut0']+core_head+padding+parts['gr33_m7_lut1']+combined[a:]+high_table
 else:
  low_table='gr33_m7_table_lo:\n .byte <gr33_m7_lut0,<gr33_m7_lut1\n'
  combined=''.join(parts.values())+low_table+high_table
 if packed_partial:
  combined += 'gr40_m7_pair_keep: .byte $c0,$30,$0c,$03\n'
 parts={'gr33_m7_combined':combined}
 block=''
 for name,text in parts.items():block+='\n; Plus allocation block '+name+'\n.virtual $4000\nlpa_block_'+name+'_begin:\n'+text+'lpa_block_'+name+'_end:\n.endvirtual\n'
 if scalar_address:
  changes.append(scalar_address)
  projected = s
  for _, before, after in changes:
   projected = projected.replace(before, after, 1)
  changes.extend(screen_cell_lookup(projected))
 return changes,block,dict(mode7Tables=True,tableBytes=264,privateQScale=4,mergedStableAndVaryingKernel=True,
                           fixedTextureOperands=fixed_texture, highByteOnlyShadeTableSwitch=fixed_texture, coordinateLookup=coordinate_lookup, packedPartialSampler=packed_partial)


def screen_cell_lookup(source):
    """Use the space of the screen-cell lookup for an exact UV nibble table."""
    if not re.search(r'^PROJ_SCREEN_MAX_X = \$9[fF]$', source, re.M):
        return None
    match = re.search(r'^xbyte:\n(?: \.byte [^\n]+\n)+', source, re.M)
    if match is None:
        return None
    table = match.group()
    values = [int(value, 16) for value in re.findall(r'\$([0-9a-fA-F]{2})', table)]
    if values != [x >> 2 for x in range(160)]:
        return None
    load = ' lda xbyte,x\n'
    sites = list(re.finditer(re.escape(load), source))
    if len(sites) != 25 or len(re.findall(r'\bxbyte\b', source)) != 26:
        return None
    # Every qualified consumer overwrites carry before using it. Fingerprint
    # the load continuations so unfamiliar assembly keeps the original table.
    contexts = '\n'.join('\n'.join(source[m.start():].splitlines()[1:8]) for m in sites)
    if hashlib.sha256(contexts.encode('ascii')).hexdigest() != '0ff5c7ca9dc88c0178d03a3de946983bbc343085250bf08cc4ffffbfeae11e5e':
        return None
    high_add = ' adc xoffhi,x\n'
    high_sites = list(re.finditer(re.escape(high_add), source))
    if len(high_sites) != 19 or len(re.findall(r'\bxoffhi\b', source)) != 20:
        return None
    high_table = re.search(r'^xoffhi:\n(?: \.byte [^\n]+\n)+', source, re.M)
    if high_table is None:
        return None
    high = [int(value, 16) for value in re.findall(r'\$([0-9a-fA-F]{2})', high_table.group())]
    if high != [x >> 7 for x in range(160)]:
        return None
    contexts = '\n'.join(
        source[m.start()-48:m.end()+48] for m in high_sites)
    if hashlib.sha256(contexts.encode('ascii')).hexdigest() != '10c2d5be510d7f98ec2f69746ebed67f005154d40b1d646634d67a73e35790d1':
        return None
    # The bitmap rows have a bounded high byte. Accumulate the low carry
    # first, then add bit 7 of X. No second table is needed for the offset.
    nibble_table = 'gr34_m7_u_nibble:\n' + ''.join(f' .fill 16,{n}\n' for n in range(16))
    start = min(sites[0].start(), high_sites[0].start())
    end = max(sites[-1].end(), high_sites[-1].end())
    region = source[start:end]
    indices = region.replace(load, ' txa\n lsr\n lsr\n')
    indices = indices.replace(high_add, ' adc #0\n cpx #$80\n adc #0\n')
    return [('gr34-screen-cell-table-reuse', table, nibble_table),
            ('gr34-screen-offset-high-byte', high_table.group(), '; Screen offset high byte is computed in code.\n'),
            ('gr34-screen-cell-indices', region, indices)]


CONTRACTS=[('lp8_normal_full_byte:\n', 'm7_partial:\n', 'a5605160c9d8a00db55673548dcd33a06d89c380b18e400f5b95bbc49d5ebc2d'), ('lp8_fast_m7_full_byte:\n', 'lpa_block_mode7_immediate_kernel_end:\n', '1a0382df45bfda85bc3c0e2a22eb849d8e8109d2e008ea123c38e220b9867330'), ('lp8_select_full_kernel:\n', 'lpa_block_mode7_immediate_setup_end:\n', '8cfb98fd7447685127143872458ad62a8511a0a1eda12472df210a3d53464a63'), ('gr28_span_core:\n', 'm7_byte_dispatch:\n', '2ba8ac025ef78a6041fa61c722140c398f06ddb6844e1c5c2994505b3349f985'), ('m3_advance_q:\n', 'm3_advance_q_end = *\n', '44882a794d5ded28bd578ac2a9ed48c7622f977f5e9d536e6840b6ba6cb5b165'), ('m3_composite:\n', 'm31_c_instructions_end = *\n', '8de0ac8a3838752154c4687a839efb1ac8ebad91314211da548f789fd3d5c47a')]
