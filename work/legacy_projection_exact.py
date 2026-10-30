"""Exact shared projection shortcuts for legacy-plus modes3..7.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
Unchanged projection, division remainder/ABI, normalization, quality and precision.
"""
import re

UNROLL_ROUNDS = 8
EXPECTED_BYTE='gate4_div16_low_loop:\n asl prodlo\n rol a\n bcs gate4_div16_low_sub\n cmp p1lo\n bcc gate4_div16_low_skip\ngate4_div16_low_sub:\n sbc p1lo\n inc prodlo\ngate4_div16_low_skip:\n dex\n bne gate4_div16_low_loop\n'
BYTE_START='; LP13_BYTE_BEGIN\n'
BYTE_END='; LP13_BYTE_END\n'
BYTE_SAVED='\n.if 0 ; LP13_ORIGINAL_BYTE\n'
BYTE_SAVED_END='\n.endif ; LP13_ORIGINAL_BYTE\n'
DIVISION = True
FOCAL = True
EXPECTED_LOOP='d16_loop:\n asl prodlo\n rol prodhi\n rol crosslo\n rol crosshi\n lda crosslo\n sec\n sbc p1lo\n tay\n lda crosshi\n sbc p1hi\n bcc d16_skip_sub\n sta crosshi\n sty crosslo\n inc prodlo\nd16_skip_sub:\n dex\n bne d16_loop\n rts\n'
EXPECTED_FOCAL='lc_ratio_mul_start:\n lda #EXPLORER_PROJ_FOCAL\n sta mul16mul\n lda #$00\n sta prodlo\n sta prodhi\n sta mul16rem\n ldx #$08\nlc_ratio_mul_loop:\n lsr mul16mul\n bcc lc_ratio_no_add\n lda mul16rem\n bne lc_ratio_saturate\n clc\n lda prodlo\n adc mul16lo\n sta prodlo\n lda prodhi\n adc mul16hi\n sta prodhi\n bcs lc_ratio_saturate\nlc_ratio_no_add:\n asl mul16lo\n rol mul16hi\n bcc lc_ratio_shift_ok\n lda #$01\n sta mul16rem\nlc_ratio_shift_ok:\n dex\n bne lc_ratio_mul_loop\n jmp lc_ratio_divide\nlc_ratio_saturate:\n lda #$ff\n sta prodlo\n sta prodhi\n'
HOOK='div16u:\n jmp lp12_div_select\nlp12_div_original:\n'
BLOCK=re.compile(r'\n; Plus allocation block projection_exact\n(?:\* = \$[0-9a-f]+|\.virtual \$4000)\nlpa_block_projection_exact_begin:\n.*?lpa_block_projection_exact_end:\n(?:\.cerror[^\n]+\n|\.endvirtual\n)',re.S)
START='; LP12_FOCAL_BEGIN\n'
SAVED='\n.if 0 ; LP12_ORIGINAL_FOCAL\n'
END='\n.endif ; LP12_ORIGINAL_FOCAL\n; LP12_FOCAL_END\n'


def once(s,old,new):
    if s.count(old)!=1:raise ValueError('EXACT_PROJECTION_ANCHOR: '+repr(old[:80]))
    return s.replace(old,new,1)


def original_source(s):
    if BYTE_START in s:
        a=s.index(BYTE_START);b=s.index(BYTE_SAVED,a)+len(BYTE_SAVED);c=s.index(BYTE_SAVED_END,b)
        end=s.index(BYTE_END,c)+len(BYTE_END)
        s=s[:a]+s[b:c]+s[end:]
    if HOOK in s:
        s=once(s,HOOK,'div16u:\n')
        matches=list(BLOCK.finditer(s))
        if len(matches)!=1:raise ValueError('EXACT_PROJECTION_REENTRANT_DIVISION')
        s=BLOCK.sub('',s)
    if START in s:
        a=s.index(START);b=s.index(SAVED,a)+len(SAVED);c=s.index(END,b)
        s=s[:a]+s[b:c]+s[c+len(END):]
    if 'lp12_div_select:' in s or START in s:raise ValueError('EXACT_PROJECTION_RESTORE')
    return s


def patch(s,unroll=UNROLL_ROUNDS):
    s=original_source(s)
    if not re.search(r'(?m)^GRAPHICS_MODE = \$0[3-7]$',s):return s,dict(applied=False,reason='Other mode retained')
    info=dict(applied=False,wideDivision8=False,constantFocal=False,newRAMTables=False,qualityChanged=False)
    if DIVISION and s.count('\ndiv16u:\n')==1 and EXPECTED_LOOP in s:
        # After eight original rounds, a byte-sized quotient has no high
        # bits: remainder=N.hi, prod.hi=N.lo, prod.lo=0. Enter the identical
        # final eight rounds, including the original final scratch/flag ABI.
        code='lp12_div_select:\n lda p1hi\n bne lp12_div_fast8\n'
        if 'gate4_div16_low_loop:\n' not in s:
            code+=' lda p1lo\n beq lp12_div_ordinary\n lda prodhi\n cmp p1lo\n bcs lp12_div_ordinary\n'
        else:
            # The pre-existing Mode6/7 one-byte-divisor fast path stays.
            code+=' jmp lp12_div_ordinary\n'
        code+="""lp12_div_fast8:
 lda prodhi
 sta crosslo
 lda prodlo
 sta prodhi
 lda #0
 sta prodlo
 sta crosshi
"""
        if unroll==1:
            code+=' ldx #8\n jmp d16_loop\n'
        else:
            # Only loop control is removed. Every original trial-subtraction
            # and quotient/remainder update executes in the same order.
            assert unroll in (2,4,8)
            body=EXPECTED_LOOP.partition('d16_loop:\n')[2].partition(' dex\n')[0]
            if unroll<8:code+=f' ldx #{8//unroll}\nlp13_div_group:\n'
            for i in range(unroll):
                code+=body.replace('d16_skip_sub',f'lp13_div_skip_{i}')
            if unroll<8:code+=' dex\n bne lp13_div_group\n'
            else:code+=' ldx #0\n'
            code+=' rts\n'
        code+='lp12_div_ordinary:\n jmp lp12_div_original\n'
        info['divisionRoundsPerLoop']=unroll
        if unroll>1 and EXPECTED_BYTE in s:
            body=EXPECTED_BYTE.partition('gate4_div16_low_loop:\n')[2].partition(' dex\n')[0]
            hook=BYTE_START+'gate4_div16_low_loop:\n jmp lp13_byte_group\n'+BYTE_SAVED+EXPECTED_BYTE+BYTE_SAVED_END+'gate4_div16_low_done:\n'+BYTE_END
            s=once(s,EXPECTED_BYTE,hook)
            code+='lp13_byte_group:\n'
            if unroll<8:code+=f' ldx #{8//unroll}\nlp13_byte_rounds:\n'
            for i in range(unroll):
                code+=body.replace('gate4_div16_low_sub',f'lp13_byte_sub_{i}').replace('gate4_div16_low_skip',f'lp13_byte_skip_{i}')
            if unroll<8:code+=' dex\n bne lp13_byte_rounds\n'
            else:code+=' ldx #0\n'
            code+=' jmp gate4_div16_low_done\n'
            info['byteDivisionGrouped']=True
        s=once(s,'\ndiv16u:\n','\n'+HOOK)
        s+='\n; Plus allocation block projection_exact\n.virtual $4000\nlpa_block_projection_exact_begin:\n'+code+'lpa_block_projection_exact_end:\n.endvirtual\n'
        info.update(applied=True,wideDivision8=True)
    if FOCAL and 'lc_ratio_mul_start:\n' in s:
        m=re.search(r'(?m)^PROJ_FOCAL = \$([0-9a-fA-F]+)$',s)
        normalized='lc_ratio_depth_nonzero:\n lda mul16hi\n bne lc_ratio_scale_loop\nlc_ratio_mul_start:\n'
        if m and normalized in s and 0<=int(m[1],16)<=255:
            focal=int(m[1],16);a=s.index('lc_ratio_mul_start:\n');b=s.index('lc_ratio_divide:\n',a)
            old=s[a:b]
            if old!=EXPECTED_FOCAL:
                info['focalReason']='Original multiply shape not proven'
                return s,info
            if focal:
                code=' lda mul16lo\n sta prodlo\n lda #0\n sta prodhi\n'
                for bit in bin(focal)[3:]:
                    code+=' asl prodlo\n rol prodhi\n'
                    if bit=='1':code+=' clc\n lda prodlo\n adc mul16lo\n sta prodlo\n lda prodhi\n adc #0\n sta prodhi\n'
            else:code=' lda #0\n sta prodlo\n sta prodhi\n'
            # Reproduce the old multiply's setup scratch on exit as well.
            code+=' lda mul16lo\n sta mul16hi\n lda #0\n sta mul16lo\n sta mul16mul\n sta mul16rem\n ldx #0\n jmp lc_ratio_divide\n'
            s=s[:a]+START+'lc_ratio_mul_start:\n'+code+SAVED+old+END+s[b:]
            info.update(applied=True,constantFocal=True,focal=focal)
    return s,info
