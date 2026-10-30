"""Exact bounded binary setup division for large Mode7 affine quotients.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import re
OLD=' lda m7_r\nm7_dda_divide:\n'
NEW=' jmp gr15_dda_choose\nm7_dda_divide:\n'
BLOCK=re.compile(r'\n; Plus allocation block mode7_binary_divider\n(?:\* = \$[0-9a-f]+|\.virtual \$4000)\nlpa_block_mode7_binary_divider_begin:\n.*?lpa_block_mode7_binary_divider_end:\n(?:\.cerror[^\n]+\n|\.endvirtual\n)',re.S)
def original_source(s):
 if NEW not in s:return s
 assert s.count(NEW)==1 and len(list(BLOCK.finditer(s)))==1
 return BLOCK.sub('',s.replace(NEW,OLD,1))
def code():
 s='''gr15_dda_choose:
 lda m7_r
 ; Quotient zero keeps the exact old single comparison path.
 cmp m7_den
 bcc gr15_dda_small_done
 ; The binary path proves denominator<=31, so ROL remainder cannot overflow.
 lsr
 lsr
 lsr
 cmp m7_den
 bcs gr15_dda_binary
 lda m7_r
 jmp m7_dda_divide
gr15_dda_small_done:
 jmp m7_dda_remainder
gr15_dda_binary:
 lda m7_r
 sta m7_q
 lda #0
'''
 for i in range(8):
  s+=f''' asl m7_q
 rol
 cmp m7_den
 bcc gr15_div_bit{i}
 sbc m7_den
 inc m7_q
gr15_div_bit{i}:
'''
 s+=' sta m7_r\n clc\n jmp lp11_dda_sign\n'
 return s
def patch(s):
 s=original_source(s)
 if not re.search(r'(?m)^GRAPHICS_MODE = \$07$',s) or 'm31_c_instructions_end = *' not in s:return s,dict(applied=False,reason='Mode7-C only')
 if s.count(OLD)!=1 or ' beq lp11_dda_power2\n' not in s or 'lp11_dda_sign:\n' not in s:return s,dict(applied=False,reason='Unknown setup divider retained')
 s=s.replace(OLD,NEW,1)
 s+='\n; Plus allocation block mode7_binary_divider\n.virtual $4000\nlpa_block_mode7_binary_divider_begin:\n'+code()+'lpa_block_mode7_binary_divider_end:\n.endvirtual\n'
 return s,dict(applied=True,minimumQuotient=8,denominatorUpperBound=31,binaryRounds=8,newRAMVariables=0,newRAMTables=0,originalZeroUnitHalfAndSmallQuotientsRetained=True,exact=True,qualityChanged=False)
