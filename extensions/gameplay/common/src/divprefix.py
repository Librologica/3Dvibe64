"""Exact48/24 division: preload quotient-zero prefix into the remainder.
Required Notice:3Dvibe64. PolyForm Noncommercial1.0.0.
"""

def adapt_body(body,kind='bits'):
    assert body.count(' bmi hc_div_loop\n')==1
    body=body.replace(' bmi hc_div_loop\n',' bmi dp_prepare\n')
    assert body.count('hc_div_loop:\n')==1
    prefix='''dp_prepare:
 ; X=bit_length(divisor)-1. Prefix of this length is necessarily <divisor.
 lda hc_divisor+2
 beq dp_mid
 ldx #23
 jmp dp_bit_count
dp_mid:
 lda hc_divisor+1
 beq dp_low
 ldx #15
 jmp dp_bit_count
dp_low:
 lda hc_divisor
 ldx #7
dp_bit_count:
 cmp #128
 bcs dp_count_done
 asl
 dex
 jmp dp_bit_count
dp_count_done:
 cpx #0
 beq dp_ready
dp_prefix:
 asl hc_num
 rol hc_num+1
 rol hc_num+2
 rol hc_num+3
 rol hc_num+4
 rol hc_num+5
 rol hc_remainder
 rol hc_remainder+1
 rol hc_remainder+2
 dey
 beq dp_small_result
 dex
 bne dp_prefix
dp_ready:
 ldx #255
 jmp hc_div_loop
dp_small_result:
 ; All N bits consumed, N<divisor: quotient0, exact remainderN.
 ldx #255
 rts
'''
    if kind in ('byte','compact'):
        shift=''
        for i in range(5,0,-1):shift+=f' lda hc_num+{i-1}\n sta hc_num+{i}\n'
        shift+=' lda #0\n sta hc_num\n'
        assert body.count(shift)==1
        body=body.replace(shift,' jsr dp_shift_byte\n')
        prefix=prefix.replace('dp_bit_count:\n cmp #128\n bcs dp_count_done\n asl\n dex\n jmp dp_bit_count\n',
            'dp_bit_count:\n asl\n bcs dp_count_done\n dex\n jmp dp_bit_count\n')
        prefix=prefix.replace(' cpx #0\n beq dp_ready\n', ''' txa
 beq dp_ready
 cpx #8
 bcc dp_prefix
 cpy #8
 bcc dp_prefix
 lda hc_num+5
 sta hc_remainder
 jsr dp_shift_byte
 txa
 sec
 sbc #8
 tax
 tya
 sec
 sbc #8
 tay
 beq dp_small_result
 txa
 beq dp_ready
''')
        suffix=''
        if kind=='compact':
            # Initial LDX23/15 always nonzero. In the shift-count loop X0
            # already means the only low-byte set bit was at position0.
            prefix=prefix.replace(' jmp dp_bit_count\n',' bne dp_bit_count\n')
            # Share the Y-=8 update too; branch immediately on helper's TAY.
            update=' tya\n sec\n sbc #8\n tay\n'
            body=body.replace(' jsr dp_shift_byte\n'+update,' jsr dp_shift_byte\n')
            prefix=prefix.replace(' jsr dp_shift_byte\n txa\n sec\n sbc #8\n tax\n'+update,
                                  ' txa\n sec\n sbc #8\n tax\n jsr dp_shift_byte\n')
            suffix=update
            # Place the early-return stub before dp_prepare, leaving core entry
            # fallthrough. No new code path can enter it by fallthrough.
            early='dp_small_result:\n ; All N bits consumed, N<divisor: quotient0, exact remainderN.\n ldx #255\n rts\n'
            assert early in prefix
            prefix=prefix.replace(early,'').replace('dp_prepare:\n',early+'dp_prepare:\n')
            prefix=prefix.replace('dp_ready:\n ldx #255\n jmp hc_div_loop\n','dp_ready:\n ldx #255\n')
        # Shared byte-shift helper avoids emitting the six-byte move twice.
        body+='dp_shift_byte:\n'+shift+suffix+' rts\n'
    elif kind!='bits':raise ValueError(kind)
    return body.replace('hc_div_loop:\n',prefix+'hc_div_loop:\n')

def adapt(source,parts,placed):
    if placed is None:
        divider=adapt_body(parts['division'],'compact')
        assert divider.count('dp_shift_byte:\n')==1
        code,helper=divider.split('dp_shift_byte:\n')
        parts['division']=code;parts['division_helper']='dp_shift_byte:\n'+helper
        # Allocation-only grouping selected by placement_probe. Same four
        # legal windows and eight-byte end guard for each whole unit.
        # The first member ends in RTS, hence no new fallthrough.
        for dest,other in [('projection','clip'),('clip_helpers','perspective_encode')]:
            assert parts[dest].rstrip().endswith('rts'),dest
            parts[dest]+=parts.pop(other)
    return source,parts
