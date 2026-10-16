"""Original multicolor bitmap adventure interface; no copied game artwork."""
import json,hashlib
from collections import Counter
from pathlib import Path
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parents[1]
ENABLED=True
RGB=[(0,0,0),(255,255,255),(129,51,56),(117,206,200),(142,60,151),(86,172,77),(46,44,155),(237,241,113),(142,80,41),(85,56,0),(196,108,113),(74,74,74),(123,123,123),(169,255,159),(112,109,235),(178,178,178)]
FONT={'A':['010','101','111','101','101'],'B':['110','101','110','101','110'],'C':['011','100','100','100','011'],'D':['110','101','101','101','110'],'E':['111','100','110','100','111'],'F':['111','100','110','100','100'],'G':['011','100','101','101','011'],'H':['101','101','111','101','101'],'I':['111','010','010','010','111'],'L':['100','100','100','100','111'],'M':['101','111','111','101','101'],'N':['101','111','111','111','101'],'O':['010','101','101','101','010'],'P':['110','101','110','100','100'],'R':['110','101','110','101','101'],'S':['011','100','010','001','110'],'T':['111','010','010','010','010'],'U':['101','101','101','101','111'],'V':['101','101','101','101','010'],'Z':['111','001','010','100','111'],'0':['111','101','101','101','111'],'1':['010','110','010','010','111'],'2':['110','001','010','100','111'],'3':['110','001','010','001','110'],'4':['101','101','111','001','001'],'5':['111','100','110','001','110'],'6':['011','100','111','101','111'],'7':['111','001','010','010','010'],'8':['111','101','111','101','111'],'9':['111','101','111','001','110'],'/':['001','001','010','100','100'],':':['000','010','000','010','000'],'-':['000','000','111','000','000']}
def artwork():
    from ui_art_refined import artwork as refined
    return refined(FONT)

def encode(im):
    histogram=im.histogram();rank={c:i for i,c in enumerate(sorted(range(16),key=lambda c:(-histogram[c],c)))}
    tiles=[];ids=[];decoded=Image.new('RGB',(320,200));pixels=decoded.load()
    for cy in range(25):
        for cx in range(40):
            values=[im.getpixel((cx*4+x,cy*8+y)) for y in range(8) for x in range(4)]
            counts=Counter(v for v in values if v)
            colors=sorted((v for v,_ in counts.most_common(3)),key=lambda v:rank[v])
            colors+=(3-len(colors))*[0];pal=[0]+colors
            def index(v):return min(range(4),key=lambda i:sum((a-b)**2 for a,b in zip(RGB[v],RGB[pal[i]])))
            bitmap=[]
            for y in range(8):
                byte=0
                for x in range(4):
                    idx=index(values[y*4+x]);byte=(byte<<2)|idx
                    pixels[cx*8+x*2,cy*8+y]=RGB[pal[idx]];pixels[cx*8+x*2+1,cy*8+y]=RGB[pal[idx]]
                bitmap.append(byte)
            tile=bytes(bitmap+[colors[0]*16+colors[1],colors[2]])
            if tile not in tiles:tiles.append(tile)
            ids.append(tiles.index(tile))
    bitmap=b''.join(tiles[i][:8] for i in ids)
    screen=bytes(tiles[i][8] for i in ids);color=bytes(tiles[i][9] for i in ids)
    return bitmap,screen,color,decoded,dict(tiles=len(tiles),bitmapBytes=8000,screenBytes=1000,colorBytes=1000,cells=1000)
def pack(raw):
    from ui_pack_optimal import pack as compress
    return compress(raw)

def parts():
    bitmap,screen,color,decoded,info=encode(artwork());(ROOT/'assets').mkdir(exist_ok=True)
    decoded.save(ROOT/'assets/interface-bitmap.png');decoded.resize((960,600),Image.Resampling.NEAREST).save(ROOT/'assets/interface-preview.png')
    # Store scanline order and a compact paired palette dictionary. Both are
    # expanded once before IRQ installation; no renderer changes or new buffers.
    raster=bytes(bitmap[cy*320+cx*8+row] for cy in range(25) for row in range(8) for cx in range(40))
    pairs=list(zip(screen,color));dictionary=[p for p,_ in Counter(pairs).most_common()]
    assert len(dictionary)<=64
    indexes=[dictionary.index(p) for p in pairs];bits=[]
    for value in indexes:
        bits.extend((value>>i)&1 for i in range(3)) if value<7 else bits.extend([1,1,1]+[(value>>i)&1 for i in range(6)])
    bits.extend([0]*((-len(bits))%8))
    paletteStream=bytes(sum(bits[i+j]<<j for j in range(8)) for i in range(0,len(bits),8))
    assert len(paletteStream)<=1125
    cursor=0
    def readbits(count):
        nonlocal cursor
        value=0
        for i in range(count):
            value|=((paletteStream[cursor//8]>>(cursor%8))&1)<<i;cursor+=1
        return value
    restored=[]
    for _ in range(1000):
        value=readbits(3);restored.append(readbits(6) if value==7 else value)
    assert restored==indexes
    assert bytes(dictionary[i][0] for i in restored)==screen
    assert bytes(dictionary[i][1] for i in restored)==color
    stream=pack(raster)+pack(paletteStream)
    (ROOT/'assets/ui-bitmap-raster.bin').write_bytes(raster)
    (ROOT/'assets/ui-palette-bits.bin').write_bytes(paletteStream)
    for name,raw in [('bitmap',bitmap),('screen',screen),('color',color)]: (ROOT/f'assets/ui-{name}.bin').write_bytes(raw)
    (ROOT/'assets/ui-packed.bin').write_bytes(stream)
    info.update(packedBytes=len(stream),paletteDictionaryBytes=len(dictionary)*2,paletteEntries=len(dictionary),bitmapStorage='scanline order; startup VIC transpose',paletteStorage='paired3/6bit dictionary; scratch in bitmapB before initialization',runtime='startup-only LZ decoder, copied to both bitmaps and screens; ColorRAM explicit')
    (ROOT/'reports/interface.json').write_text(json.dumps(info,indent=2))
    def data(label,values):return label+':\n'+''.join(' .byte '+','.join(map(str,values[i:i+24]))+'\n' for i in range(0,len(values),24))
    chunks=[stream[i:i+256] for i in range(0,len(stream),256)]
    result={'ui_code':(ROOT/'src/ui_decoder.asm').read_text()}
    for i,chunk in enumerate(chunks):result[f'ui_pack{i}']=data(f'ui_pack{i}',chunk)
    result['ui_pages']='ui_pages_lo: .byte '+','.join(f'<ui_pack{i}' for i in range(len(chunks)))+'\nui_pages_hi: .byte '+','.join(f'>ui_pack{i}' for i in range(len(chunks)))+'\n'
    result['ui_dictionary']=data('ui_screen_palette',[p[0] for p in dictionary])+data('ui_color_palette',[p[1] for p in dictionary])+' .cerror '+str(len(dictionary))+' >64,\"UI palette dictionary exceeds6bit domain\"\n'
    return result
def attach(source,blocks):
    # Global material activation used to repaint the whole screen/ColorRAM.
    # This demo owns the surrounding cells; initialize only the 3D window.
    a=source.index('apply_active_material:\n');b=source.index('\n.if FACE_SOLID_COLOR_ENABLE != 0\nload_face_solid_color_y:',a)
    source=source[:a]+'''apply_active_material:
 lda active_reflect_offset
 sta material_reflect_offset_cur
 clc
 adc active_material
 tay
 lda material_screen_bytes,y
 sta t1
 lda material_color_bytes,y
 sta t2
 ldx #0
ui_material_row:
 lda screenrowlo_a,x
 sta ptr0lo
 lda screenrowhi_a,x
 sta ptr0hi
 lda screenrowlo_b,x
 sta ptr1lo
 lda screenrowhi_b,x
 sta ptr1hi
 lda colorrowlo,x
 sta row0lo
 lda colorrowhi,x
 sta row0hi
 ldy #CAMERA_VIEWPORT_CELL_WIDTH-1
ui_material_cell:
 lda t1
 sta (ptr0lo),y
 sta (ptr1lo),y
 lda t2
 sta (row0lo),y
 dey
 bpl ui_material_cell
 txa
 clc
 adc #4
 tax
 cpx #CAMERA_VIEWPORT_HEIGHT
 bcc ui_material_row
 rts
'''+source[b:]
    if not ENABLED:return source,blocks
    source=source.replace(' jsr clear_bitmap_buffers\n rts\n',' jsr clear_bitmap_buffers\n jsr game_ui_init\n rts\n')
    assert source.count(' jsr game_ui_init\n')==1
    blocks.update(parts());return source,blocks
if __name__ == "__main__":
    parts()
    print((ROOT/"reports/interface.json").read_text())
