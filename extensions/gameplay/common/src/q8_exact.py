"""Opt-in common Q8 arithmetic, not a reduction of precision.
Required Notice: 3Dvibe64. PolyForm Noncommercial1.0.0.
Frozen SDK is imported, never edited. Transformations fail closed on drift.
"""
import re

OPTIONS=('baseline','shift8','narrow16','combined')

def narrow_division(source):
    a=source.index('hc_div_loop:\n')
    b=source.index(' rts\n',source.index('hc_div_next:\n',a))+len(' rts\n')
    wide=source[a:b]
    assert wide.count(' bne hc_div_loop\n')==1
    wide=wide.replace('hc_div_loop:\n','hc_div_loop_wide:\n',1).replace(' bne hc_div_loop\n',' bne hc_div_loop_wide\n')
    dispatch='''hc_div_loop:
 lda hc_divisor+2
 beq nd16_loop
 jmp hc_div_loop_wide
'''
    narrow='''; Exact unsigned48/16: R<D implies next shifted R fits17bits.
; Fourth remainder byte stays zero. No new scratch and no SMC.
nd16_loop:
 asl hc_num
 rol hc_num+1
 rol hc_num+2
 rol hc_num+3
 rol hc_num+4
 rol hc_num+5
 rol hc_remainder
 rol hc_remainder+1
 rol hc_remainder+2
 lda hc_remainder+2
 bne nd16_sub
 lda hc_remainder+1
 cmp hc_divisor+1
 bcc nd16_next
 bne nd16_sub
 lda hc_remainder
 cmp hc_divisor
 bcc nd16_next
nd16_sub:
 sec
 lda hc_remainder
 sbc hc_divisor
 sta hc_remainder
 lda hc_remainder+1
 sbc hc_divisor+1
 sta hc_remainder+1
 lda hc_remainder+2
 sbc #0
 sta hc_remainder+2
 inc hc_num
nd16_next:
 dey
 bne nd16_loop
 rts
'''
    return source[:a]+dispatch+wide+narrow+source[b:]

def projection(source, option):
    assert option in OPTIONS
    info={'option':option,'newScratchBytes':0,'newTablesBytes':0}
    if option=='baseline':return source,info
    if option in ('shift8','combined'):
        a=source.index('hc_project_axis:\n');b=source.index(' jsr hc_div40\n',a)
        block=source[a:b]
        assert block.count(' sta hc_shift,x\n')==2 # clear plus copy
        old=' lda hc_coord,x\n sta hc_shift,x\n'
        assert block.count(old)==1
        block=block.replace(old,' lda hc_coord,x\n sta hc_shift+1,x\n')
        pattern=r' lda #<(\d+)\n sta hc_value\n lda #>\1\n sta hc_value\+1\n'
        m=re.search(pattern,block);assert m
        factor=int(m[1]);assert factor%256==0 and 0<factor//256<256
        replacement=f' lda #<{factor//256}\n sta hc_value\n lda #>{factor//256}\n sta hc_value+1\n'
        block=block[:m.start()]+replacement+block[m.end():]
        source=source[:a]+block+source[b:]
        info['focal']=factor//256
    if option in ('narrow16','combined'):source=narrow_division(source)
    return source,info

def apply_parts(parts, option):
    # Wide divide may be split into another placement unit by the SDK.
    info={'option':option,'newScratchBytes':0,'newTablesBytes':0}
    for kind,anchor in [('shift8','hc_project_axis:\n'),('narrow16','hc_div40:\n')]:
        if option not in (kind,'combined'):continue
        owners=[key for key,text in parts.items() if anchor in text]
        assert len(owners)==1,(kind,owners)
        key=owners[0];parts[key],detail=projection(parts[key],kind)
        if 'focal' in detail:info['focal']=detail['focal']
    return parts,info
