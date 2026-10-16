"""Exact reusable focal product and normalized/narrow division, all Q8 modes.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
from perspective_exact import once,division_prefix

def shift(name,count,tag):
    return f' ldx #{count}\n{tag}:\n asl {name}\n'+''.join(f' rol {name}+{i}\n' for i in range(1,6))+f' dex\n bne {tag}\n'

def product():
    # All six bytes retained: |signed24| * 43520 fits40, not32 bits.
    s=shift('hc_shift',2,'ex_focal_times4')+' clc\n'
    for i in range(6):
        suffix='+'+str(i) if i else ''
        s+=f' lda hc_shift{suffix}\n'+(f' adc hc_coord{suffix}\n' if i<3 else ' adc #0\n')+f' sta hc_shift{suffix}\n'
    s+=' ldx #5\nex_focal_copy5:\n lda hc_shift,x\n sta hc_num,x\n dex\n bpl ex_focal_copy5\n'
    s+=shift('hc_shift',4,'ex_focal_times80')+' clc\n'
    for i in range(6):
        suffix='+'+str(i) if i else ''
        s+=f' lda hc_num{suffix}\n adc hc_shift{suffix}\n sta hc_num{suffix}\n'
    # Multiply85A by512: one bit shift followed by exact byte movement.
    s+=' asl hc_num\n'+''.join(f' rol hc_num+{i}\n' for i in range(1,6))
    for i in range(5,0,-1):s+=f' lda hc_num+{i-1}\n sta hc_num+{i}\n'
    return s+' lda #0\n sta hc_num\n'

def narrow_divider(body):
    start=body.index('hc_div_loop:\n');end=body.index(' rts\n',body.index('hc_div_next:\n',start))+len(' rts\n')
    original=body[start:end]
    narrow=original.replace('hc_div_loop','ex_div16_loop').replace('hc_div_sub','ex_div16_sub').replace('hc_div_next','ex_div16_next')
    narrow=narrow.replace(' rol hc_remainder+3\n','')
    a=narrow.index(' lda hc_remainder+3\n');b=narrow.index(' lda hc_remainder+1\n',a)
    narrow=narrow[:a]+' lda hc_remainder+2\n bne ex_div16_sub\n'+narrow[b:]
    narrow=narrow.replace(' lda hc_remainder+2\n sbc hc_divisor+2\n sta hc_remainder+2\n lda hc_remainder+3\n sbc #0\n sta hc_remainder+3\n',
                          ' lda hc_remainder+2\n sbc #0\n sta hc_remainder+2\n')
    dispatch=' lda hc_divisor+2\n bne hc_div_loop\n jmp ex_div16_loop\n'
    # Trimming must happen BEFORE dispatch and initialize Y identically.
    trim=division_prefix().replace('pd_trim','ex_trim').replace('bmi hc_div_loop','bmi ex_div_dispatch')
    head=once(body[:start],' ldy #48\n',trim+'ex_div_dispatch:\n'+dispatch)
    return head+original+narrow+body[end:]

def apply(parts):
    p=parts['projection'];a=p.index(' lda #<43520\n');b=p.index(' jsr hc_div40\n',a)
    p=p[:a]+product()+p[b:]
    owner='perspective_division' if 'perspective_division' in parts else 'projection'
    parts['projection']=p
    body=parts[owner]
    # Perspective already trims the numerator. Normalize its entry names so
    # the same division specialization can be applied once, without duplication.
    if 'pd_trim_bytes:' in body:
        a=body.index(' ldy #48\npd_trim_bytes:');b=body.index('hc_div_loop:\n',a)
        body=body[:a]+' ldy #48\n'+body[b:]
    parts[owner]=narrow_divider(body)
    return dict(focalProduct='exact85A-shift9-full48',division='normalized48/16 with48/24 fallback')
