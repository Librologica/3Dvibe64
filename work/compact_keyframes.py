"""Lossless signed16 keyframe packing and standalone 6502 decoder emission.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
No sampling, quantization, interpolation change or application data.
"""
import argparse,json,re
from pathlib import Path

def pack(values):
    if not 1<=len(values)<=256 or any(type(v) is not int or not -32768<=v<=32767 for v in values):
        raise ValueError('COMPACT_KEYS: require 1..256 signed16 integer samples')
    shift=0
    while shift<15 and all(v%(1<<(shift+1))==0 for v in values):shift+=1
    scaled=[v>>shift for v in values];minimum=min(scaled)
    width=max(1,(max(scaled)-minimum).bit_length())
    bits=sum((v-minimum)<<(i*width) for i,v in enumerate(scaled))
    data=bits.to_bytes((len(values)*width+7)//8,'little')+b'\0\0'
    return dict(count=len(values),shift=shift,minimum=minimum,width=width,data=list(data),
                originalBytes=2*len(values),packedBytes=len(data))

def unpack(track,index):
    if not 0<=index<track['count']:raise IndexError(index)
    bits=int.from_bytes(bytes(track['data']),'little')
    return (((bits>>(index*track['width']))&((1<<track['width'])-1))+track['minimum'])<<track['shift']

def emit(values,prefix='compact_keys'):
    if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*',prefix):raise ValueError('COMPACT_KEYS: invalid ASM prefix')
    t=pack(values);w=t['width'];mask=(1<<w)-1
    # Absolute self-modifying loads avoid claiming any application's zero page.
    # Decoder and data belong in writable RAM, called outside IRQ; not reentrant.
    s=f'''; Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
; X=index, C=1/A=low/Y=high signed16 result; C=0 invalid, A=Y=0.
; Clobbers A/X/Y/flags and private scratch only; no zero-page ownership.
{prefix}_read:
'''
    if t['count']<256:s+=f' cpx #{t["count"]}\n bcc +\n jmp {prefix}_bad\n+\n'
    s+=f''' stx {prefix}_index
 lda #0
 sta {prefix}_pos
 sta {prefix}_pos+1
 ldx #{w}
{prefix}_mul:
 clc
 lda {prefix}_pos
 adc {prefix}_index
 sta {prefix}_pos
 bcc +
 inc {prefix}_pos+1
+
 dex
 bne {prefix}_mul
 lda {prefix}_pos
 and #7
 sta {prefix}_align
'''
    s+=(f' lsr {prefix}_pos+1\n ror {prefix}_pos\n')*3
    for k in range(3):
        s+=f''' clc
 lda {prefix}_pos
 adc #<({prefix}_data+{k})
 sta {prefix}_load{k}+1
 lda {prefix}_pos+1
 adc #>({prefix}_data+{k})
 sta {prefix}_load{k}+2
{prefix}_load{k}:
 lda $ffff
 sta {prefix}_value+{k}
'''
    s+=f''' ldx {prefix}_align
 beq {prefix}_aligned
{prefix}_align_loop:
 lsr {prefix}_value+2
 ror {prefix}_value+1
 ror {prefix}_value
 dex
 bne {prefix}_align_loop
{prefix}_aligned:
 lda {prefix}_value
 and #{mask&255}
 clc
 adc #{t['minimum']&255}
 sta {prefix}_value
 lda {prefix}_value+1
 and #{mask>>8}
 adc #{(t['minimum']>>8)&255}
 sta {prefix}_value+1
'''
    s+=(f' asl {prefix}_value\n rol {prefix}_value+1\n')*t['shift']
    s+=f''' lda {prefix}_value
 ldy {prefix}_value+1
 sec
 rts
{prefix}_bad:
 lda #0
 tay
 clc
 rts
{prefix}_index: .byte 0
{prefix}_pos: .word 0
{prefix}_align: .byte 0
{prefix}_value: .fill 3,0
{prefix}_data:
'''
    s+='\n'.join(' .byte '+','.join(str(v) for v in t['data'][i:i+16]) for i in range(0,len(t['data']),16))+'\n'
    return s,t

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('input',type=Path);p.add_argument('output',type=Path);p.add_argument('--prefix',default='compact_keys');a=p.parse_args()
    asm,info=emit(json.loads(a.input.read_text(encoding='utf-8-sig')),a.prefix)
    a.output.write_text(asm,encoding='ascii');a.output.with_suffix('.json').write_text(json.dumps(info,indent=2)+'\n')
