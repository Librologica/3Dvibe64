"""Load-safe sparse PRG wrapper for this PRIVATE all-RAM demo.

Ordinary KERNAL LOAD must not stream padding through $D000 I/O. Stage only
assembled data below I/O, then copy it to its original addresses with ROM off.
The relocated loader runs at $0200, outside all renderer/source data. Copy high
segments in descending order, then the initial low segment forward. IRQ/NMI
are disabled during relocation; the original entry installs its own vectors.
No renderer instruction or data byte is changed.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import argparse, hashlib, json, os, re, shutil, subprocess
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
TASS = Path(os.environ.get('TASS64_EXE') or shutil.which('64tass') or r'C:\Users\rapso\Desktop\c64\tools\64tass\64tass-1.60.3243\64tass.exe')

def package(build, output):
    original = (build/'3Dvibe64.prg').read_bytes()
    origin = int.from_bytes(original[:2], 'little')
    ranges = [(int(a,16),int(b,16)+1) for a,b in re.findall(
        r'^Data:\s+\d+\s+\$([0-9a-f]+)-\$([0-9a-f]+)',
        (build/'3Dvibe64.map').read_text(), re.M)]
    assert ranges and ranges[0][0] == origin == 0x0801
    # Merge adjacent/small-gap blocks: preserve even initialized guard bytes.
    merged = []
    for a,b in ranges:
        if merged and a-merged[-1][1] < 32: merged[-1] = (merged[-1][0], b)
        else: merged.append((a,b))
    cursor = 0x0b00
    moves = []
    for a,b in merged:
        moves.append(dict(source=cursor,destination=a,size=b-a))
        cursor += b-a
    assert cursor < 0xd000, f'LOAD exceeds safe RAM: ${cursor:04X}'
    # Formal overlap proof: each copy may only overwrite staging bytes that
    # have already been consumed. Low block is the sole forward-copy block.
    pending = moves.copy()
    for move in reversed(moves):
        pending.remove(move)
        a,b = move['destination'],move['destination']+move['size']
        assert all(b<=m['source'] or a>=m['source']+m['size'] for m in pending), (move,pending)
        assert a>=0x0801
        # Dedicated actor payload is staged in RAM UNDER I/O, with $01=$34
        # during relocation. It is copied to dead UI storage after UI init.
        assert not(a<0xe000 and b>0xd000) or (a==0xd000 and b<=0xe000)
    body = '''
 sei
 cld
 lda #$7f
 sta $dc0d
 sta $dd0d
 lda $dc0d
 lda $dd0d
 lda #0
 sta $d01a
 lda #$34
 sta $01
'''
    for i,m in enumerate(reversed(moves)):
        s,d,n=m['source'],m['destination'],m['size']
        forward=d<s
        if not forward:s+=n-1;d+=n-1
        body += f'''
 lda #<{s}
 sta $f7
 lda #>{s}
 sta $f8
 lda #<{d}
 sta $f9
 lda #>{d}
 sta $fa
 lda #<{n}
 sta $fb
 lda #>{n}
 sta $fc
 ldy #0
copy_{i}:
 lda ($f7),y
 sta ($f9),y
'''
        if forward:
            body += f'''
 inc $f7
 bne source_{i}
 inc $f8
source_{i}:
 inc $f9
 bne dest_{i}
 inc $fa
dest_{i}:
'''
        else:
            body += f'''
 lda $f7
 bne source_{i}
 dec $f8
source_{i}:
 dec $f7
 lda $f9
 bne dest_{i}
 dec $fa
dest_{i}:
 dec $f9
'''
        body += f'''
 lda $fb
 bne count_{i}
 dec $fc
count_{i}:
 dec $fb
 lda $fb
 ora $fc
 bne copy_{i}
'''
    body += ' lda #$35\n sta $01\n jmp $080d\n'
    # Four merged regions -> < $0400 loader. ScreenB initialized afterwards.
    # Copy stub before any staged payload relocation begins.
    asm = '''* = $0801
 .byte $0b,$08,$0a,$00,$9e
 .text "2061"
 .byte 0,0,0
* = $080d
 sei
 cld
 ldx #0
loader_copy:
 lda loader_image,x
 sta $0200,x
 lda loader_image+$100,x
 sta $0300,x
 inx
 bne loader_copy
 jmp $0200
loader_image:
 .logical $0200
'''+body+'''
loader_end:
 .if * > $0400
 .error "Loader exceeds reserved relocation window"
 .endif
 .here
 .fill $0200-(loader_end-$0200),0
 .if * > $0b00
 .error "Bootstrap overlaps staging"
 .endif
* = $0b00
'''
    for a,b in merged:
        data=original[2+a-origin:2+b-origin]
        for i in range(0,len(data),24):
            asm += ' .byte '+','.join(f'${v:02x}' for v in data[i:i+24])+'\n'
    output.parent.mkdir(parents=True,exist_ok=True)
    source=output.with_suffix('.loader.asm');source.write_text(asm)
    result=subprocess.run([str(TASS),'--cbm-prg','-o',str(output),str(source)],capture_output=True,text=True)
    output.with_suffix('.loader.log').write_text(result.stdout+result.stderr)
    assert result.returncode==0,result.stdout+result.stderr
    data=output.read_bytes()
    assert origin+len(data)-2==cursor
    # Host relocation reproduces every assembled byte, not merely screenshots.
    ram=bytearray(65536);ram[origin:origin+len(data)-2]=data[2:]
    for m in reversed(moves):
        s,d,n=m['source'],m['destination'],m['size']
        for i in (range(n) if d<s else range(n-1,-1,-1)): ram[d+i]=ram[s+i]
    assert all(ram[a:b]==original[2+a-origin:2+b-origin] for a,b in ranges)
    info=dict(originalSHA256=hashlib.sha256(original).hexdigest().upper(),
              packagedSHA256=hashlib.sha256(data).hexdigest().upper(),
              originalBytes=len(original),packagedBytes=len(data),
              stagedEnd=cursor,moves=moves,hostRelocationExact=True)
    output.with_suffix('.loader.json').write_text(json.dumps(info,indent=2))
    print(json.dumps(info,indent=2))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--build',default='room/build/three-rooms-small')
    p.add_argument('--output',default='artifacts/three-rooms-torus-smooth-auto-q8-pal-64mhz-loadfix.prg')
    a=p.parse_args();package(ROOT/a.build,ROOT/a.output)
