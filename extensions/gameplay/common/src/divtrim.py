"""Demo-only exact 48/24-bit divider: omit leading zero dividend bits.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. No SDK or frozen reference changes.
"""

def prefix(kind='bytes-bits'):
    s=' ldy #48\n'
    if kind=='bytes-bits':
        s+='dt_trim_bytes:\n lda hc_num+5\n bne dt_trim_bits\n'
        for i in range(5,0,-1):
            s+=f' lda hc_num+{i-1}\n sta hc_num+{i}\n'
        s+=' lda #0\n sta hc_num\n tya\n sec\n sbc #8\n tay\n bne dt_trim_bytes\n rts ; zero numerator: quotient and remainder are zero\n'
    elif kind!='bits':
        raise ValueError(kind)
    s+='dt_trim_bits:\n lda hc_num+5\n bmi hc_div_loop\n asl hc_num\n'
    for i in range(1,6):s+=f' rol hc_num+{i}\n'
    s+=' dey\n bne dt_trim_bits\n rts\n'
    return s

def adapt(source,parts,placed):
    if placed is None:
        old=' ldy #48\nhc_div_loop:\n'
        assert parts['projection'].count(old)==1
        parts['projection']=parts['projection'].replace(old,prefix()+'hc_div_loop:\n')
        # Isolate the existing divider as a placement unit; no runtime call
        # or buffer change. The old projection unit cannot grow in its gap.
        start=parts['projection'].index('hc_div40:\n')
        end=parts['projection'].index('; trunc(delta_s16',start)
        parts['division']=parts['projection'][start:end]
        parts['projection']=parts['projection'][:start]+parts['projection'][end:]
    return source,parts
