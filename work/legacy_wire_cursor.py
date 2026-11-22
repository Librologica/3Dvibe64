"""Exact adjacent-row bitmap cursors for wire points and horizontal/vertical runs.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import base64,hashlib,json,re,zlib
REGIONS=[('point','plot_wire_point:\n','pwp_done:\n'),('horizontal','plot_wire_horizontal:\n','plot_wire_vertical_run:\n'),('vertical','plot_wire_vertical_run:\n','pvwr_done:\n')]
MARKER=re.compile(r'; GR16_WIRE_RUNS ([0-9a-f]{64}) ([A-Za-z0-9+/=]+)\n')
def region(s,first,last):
 a=s.index(first);b=s.index(last,a);return a,b,s[a:b]
def original_source(s):
 matches=list(MARKER.finditer(s))
 if not matches:return s
 assert len(matches)==1;m=matches[0];raw=zlib.decompress(base64.b64decode(m[2]));assert hashlib.sha256(raw).hexdigest()==m[1]
 saved=json.loads(raw);s=MARKER.sub('',s)
 for name,first,last in REGIONS:
  a,b,_=region(s,first,last);s=s[:a]+saved[name]+s[b:]
 return s
def table(s,name):
 m=re.search(r'(?m)^'+name+r':\n((?: \.byte[^\n]*\n)+)',s)
 if not m:return None
 out=[]
 for line in m[1].splitlines():
  for part in line.removeprefix(' .byte ').split(','):
   part=part.strip()
   if not re.fullmatch(r'(?:\$[0-9a-fA-F]+|\d+)',part):return None
   v=int(part[1:],16) if part.startswith('$') else int(part)
   if not 0<=v<=255:return None
   out.append(v)
 return out
def proven(s):
 for bank in 'ab':
  arrays=[table(s,'row'+str(row)+part+'_'+bank) for row in [0,1] for part in ['lo','hi']]
  if any(a is None for a in arrays) or not arrays[0] or len({len(a) for a in arrays})!=1:return False
  lo,hi,lo1,hi1=arrays
  if any(c+256*d!=a+256*b+1 for a,b,c,d in zip(lo,hi,lo1,hi1)):return False
 return True


def indexed_writers(source):
    """Keep the cell/bitmap row bases and index them at the actual store."""
    if not re.search(r'(?m)^GRAPHICS_MODE = \$0[123]$', source):
        return []
    for setting in ('WIRE_RENDER_ENABLE = $01', 'VIC_COLOR_POLICY_ENABLE = $00',
                    'WORLD_GROUND_WIRE_OCCLUDE = $00'):
        if setting not in source:
            return []
    changes = []
    low_a, low_b = (table(source, f'row0lo_{bank}') for bank in 'ab')
    if low_a and low_a == low_b and proven(source):
        for prefix, axis in (('pwp', 'rightval'), ('pwh', 'yrow'), ('pvwr', 'ycur')):
            old = f''' ldx {axis}
 lda drawbuf
 bne {prefix}_buffer_b
 lda row0lo_a,x
 sta row0lo
 lda row0hi_a,x
 sta row0hi
 jmp {prefix}_rows_ready
{prefix}_buffer_b:
 lda row0lo_b,x
 sta row0lo
 lda row0hi_b,x
 sta row0hi
{prefix}_rows_ready:
 ldx leftval
 lda row0lo
 clc
 adc xofflo,x
 sta ptr0lo
 lda row0hi
 adc xoffhi,x
 sta ptr0hi
'''
            if source.count(old) != 1:
                continue
            new = f''' ldy {axis}
 ldx leftval
 lda row0lo_a,y
 clc
 adc xofflo,x
 sta ptr0lo
 lda drawbuf
 bne {prefix}_buffer_b
 lda row0hi_a,y
 jmp {prefix}_rows_ready
{prefix}_buffer_b:
 lda row0hi_b,y
{prefix}_rows_ready:
 adc xoffhi,x
 sta ptr0hi
'''
            if prefix == 'pvwr':
                entry = 'plot_wire_vertical_run:\n ldx leftval\n'
                if source.count(entry) == 1:
                    # No callback changes the horizontal coordinate during this run.
                    changes.append(('wire-vertical-offset-init', entry, entry + ''' lda xofflo,x
 sta pvwr_offset_low+1
 lda xoffhi,x
 sta pvwr_offset_high+1
'''))
                    new = new.replace(' ldx leftval\n', '')
                    new = new.replace(' adc xofflo,x\n', 'pvwr_offset_low:\n adc #0\n')
                    new = new.replace(' adc xoffhi,x\n', 'pvwr_offset_high:\n adc #0\n')
                    # The bitmap uses Y=0 below. The original left X is reloaded
                    # only by the material path when that path needs it.
                    dirty_start = source.index('pvwr_loop:\n')
                    dirty_end = source.index(old, dirty_start)
                    dirty = source[dirty_start:dirty_end]
                    dirty_y = dirty.replace(' lda ycur\n sta rightval\n', ' ldy ycur\n sty rightval\n', 1)
                    dirty_y = dirty_y.replace(' ldx ycur\n', '', 1)
                    for bank in 'ab':
                        dirty_y = dirty_y.replace(f'dirtymin_{bank},x', f'dirtymin_{bank},y')
                        dirty_y = dirty_y.replace(f'dirtymax_{bank},x', f'dirtymax_{bank},y')
                        dirty_y = dirty_y.replace(f'pvwr_dirty_{bank}_min_ok:\n lda startbyte\n',
                                                  f'pvwr_dirty_{bank}_min_ok:\n', 1)
                    if dirty_y != dirty and re.fullmatch(r'pvwr_loop:\n lda ycur\n sta rightval\n'
                            r'\.if TRACK_DIRTY_SPANS != 0\n ldx ycur\n(?:(?!\n ldy|\n iny|\n dey|\n tay).)*'
                            r'\.endif\n', dirty, re.S):
                        changes.append(('wire-vertical-dirty-index', dirty, dirty_y))
                        new = new.removeprefix(' ldy ycur\n')
            changes.append((f'wire-bitmap-indexed-{prefix}', old, new))

    colors = table(source, 'colorrowlo')
    screen_colors = all(table(source, f'screenrowlo_{bank}') == colors for bank in 'ab')
    high_tables = [table(source, name) for name in ('screenrowhi_a', 'screenrowhi_b', 'colorrowhi')]
    # Adding a possible carry to these high bytes cannot set C or V.
    safe_high = all(values and len(values) == len(colors or ()) and
                    not {0x7f, 0xff}.intersection(values) for values in high_tables)
    if colors and screen_colors and safe_high:
        changes += indexed_material(source)
    return changes


def indexed_material(source):
    first = 'plot_wire_material_write:\n'
    last = 'pwm_done:\n'
    if source.count(first) != 1 or source.count(last) != 1:
        return []
    start = source.index(first)
    original = source[start:source.index(last, start)]
    # Match the actual writer, including the optional color-cell ownership
    # branch that the caller has proved disabled.
    if original.count(' adc #$00\n') != 2 or original.count(' ldx leftval\n') != 3:
        return []
    if original.count(' sta (ptr0lo),y\n') != 1 or original.count(' sta (ptr1lo),y\n') != 1:
        return []
    new = first + ''' ldx rightval
 lda screenrowlo_a,x
 sta ptr0lo
 sta ptr1lo
 lda drawbuf
 bne pwm_buffer_b
 lda screenrowhi_a,x
 jmp pwm_screen_ready
pwm_buffer_b:
 lda screenrowhi_b,x
pwm_screen_ready:
 sta ptr0hi
 lda colorrowhi,x
 sta ptr1hi
.if ENGINE_MODE1_MATERIAL_STARTBYTE_REUSE != 0 || ENGINE_MODE2_MATERIAL_STARTBYTE_REUSE != 0
 ldy startbyte
.else
 ldx leftval
 ldy xbyte,x
.endif
 lda material_screen_cur
 sta (ptr0lo),y
 lda material_color_cur
 sta (ptr1lo),y
 ldy #0
 clc
 clv
'''
    # Both options already leave X in the required state.
    return [('wire-material-indexed', original, new)]

def shallow_wire_spans(source):
    """Send nonfinal rows directly to the span writer when dx is at least dy."""
    qualified = ('ENGINE_WIRE_SCANLINE_RUN_RASTERIZER = $01',
                 'ENGINE_WIRE_RASTER_CONSOLIDATION = $01',
                 'DIRECT_CONVEX_EDGE_SPANS = $00', 'WORLD_GROUND_WIRE_OCCLUDE = $00')
    if not all(setting in source for setting in qualified):
        return []
    start = source.find('tec_lspan_pos:\n')
    end = source.find('\ntec_horizontal:\n', start)
    if start < 0 or end < 0 or source.count('tfs_wire_run:\n') != 1:
        return []
    old = source[start:end]
    flush = ' clv\n jsr tec_flush_span\n inc ycur\n'
    tail = ' clv\n jsr tec_flush_span\n rts\n'
    if old.count(flush) != 4 or old.count(tail) != 4:
        return []
    # The guarded scanline dispatcher proves dx >= dy > 0. Each nonfinal
    # step therefore spans at least two pixels, including both endpoints.
    new = old.replace(flush, ' clv\n jsr tfs_wire_run\n inc ycur\n')
    new = new.replace(tail, ' clv\n jmp tec_flush_span\n')
    for direction in ('l', 'r'):
        for sign, first_bound, written_bound in (('pos', 'spanw', 'spanh'), ('neg', 'spanh', 'spanw')):
            name = f'tec_{direction}span_{sign}'
            row = f'{name}_row:\n lda xcur\n sta spanw\n sta spanh\n'
            final = f'{name}_done:\n sec\n'
            if new.count(row) != 1 or new.count(final) != 1:
                return []
            new = new.replace(row, f'{name}_row:\n lda xcur\n sta {first_bound}\n', 1)
            new = new.replace(final, f'{name}_done:\n lda {first_bound}\n sta {written_bound}\n sec\n', 1)
    return [('wire-shallow-span-direct', old, new)]


def wire_span_row_index(source):
    """Reuse the damage row index for the bitmap address and choose its bank once."""
    if 'TRACK_DIRTY_SPANS = $01' not in source or 'VIC_COLOR_POLICY_ENABLE = $00' not in source:
        return []
    bank_a, bank_b = (table(source, f'row0lo_{bank}') for bank in 'ab')
    if not bank_a or bank_a != bank_b:
        return []
    start = source.find('.if TRACK_DIRTY_SPANS != 0\n ldx yrow\n lda drawbuf\n bne pwh_dirty_b\n')
    end = source.find(' ldy #$00\n lda startbyte\n cmp endbyte\n', start)
    if start < 0 or end < 0:
        return []
    old = source[start:end]
    bitmap = '''.endif
 ldy yrow
 ldx leftval
 lda row0lo_a,y
 clc
 adc xofflo,x
 sta ptr0lo
 lda drawbuf
 bne pwh_buffer_b
 lda row0hi_a,y
 jmp pwh_rows_ready
pwh_buffer_b:
 lda row0hi_b,y
pwh_rows_ready:
 adc xoffhi,x
 sta ptr0hi
'''
    if not old.endswith(bitmap) or any(old.count(f' txa\n cmp dirty_ymax_{bank}') != 1 for bank in 'ab'):
        return []
    damage = old.removesuffix(bitmap)
    damage = damage.replace(' ldx yrow\n', ' ldy yrow\n', 1).replace(' txa\n', ' tya\n')
    for bank in 'ab':
        damage = damage.replace(f' tya\n cmp dirty_ymax_{bank}', f' cmp dirty_ymax_{bank}')
        for edge in ('min', 'max'):
            damage = damage.replace(f'dirty{edge}_{bank},x', f'dirty{edge}_{bank},y')
    damage = damage.replace(' bcc pwh_dirty_done\n sta dirtymax_a,y\n jmp pwh_dirty_done\n',
                            ' bcc pwh_keep_max_a\n sta dirtymax_a,y\npwh_keep_max_a:\n'
                            ' lda row0hi_a,y\n jmp pwh_dirty_done\n', 1)
    damage = damage.replace(' bcc pwh_dirty_done\n sta dirtymax_b,y\npwh_dirty_done:\n',
                            ' bcc pwh_keep_max_b\n sta dirtymax_b,y\npwh_keep_max_b:\n'
                            ' lda row0hi_b,y\npwh_dirty_done:\n', 1)
    if damage.count(' lda row0hi_') != 2 or len(old) > 2400:
        return []
    new = damage + ''' sta ptr0hi
.endif
 ldx leftval
 lda row0lo_a,y
 clc
 adc xofflo,x
 sta ptr0lo
 lda ptr0hi
 adc xoffhi,x
 sta ptr0hi
'''
    return [('wire-horizontal-row-index', old, new)]


def patch(s):
 s=original_source(s)
 if not re.search(r'(?m)^WIRE_RENDER_ENABLE = \$01$',s):return s,dict(applied=False,reason='Enabled wire renderer only')
 if any(first not in s or last not in s for name,first,last in REGIONS) or not proven(s):return s,dict(applied=False,reason='Known adjacent-row writers only')
 saved={n:region(s,a,b)[2] for n,a,b in REGIONS};patched={}
 pointer=' lda row1lo\n clc\n adc xofflo,x\n sta ptr1lo\n lda row1hi\n adc xoffhi,x\n sta ptr1hi\n'
 scalar=' lda (ptr1lo),y\n and maskv\n ora p1lo\n sta (ptr1lo),y\n'
 single=' iny\n lda (ptr0lo),y\n and maskv\n ora p1lo\n sta (ptr0lo),y\n dey\n'
 for name,first,last in REGIONS:
  body=saved[name]
  for bank in 'ab':
   old=f' lda row1lo_{bank},x\n sta row1lo\n lda row1hi_{bank},x\n sta row1hi\n'
   if body.count(old)!=1:return s,dict(applied=False,reason='Other row setup retained')
   body=body.replace(old,'',1)
  if body.count(pointer)!=1:return s,dict(applied=False,reason='Other second-row cursor retained')
  body=body.replace(pointer,'',1)
  expected=3 if name=='horizontal' else 1
  if body.count(scalar)!=expected:return s,dict(applied=False,reason='Other masked row stores retained')
  body=body.replace(scalar,single)
  if name=='horizontal':
   old='pwh_next0_ok:\n clc\n lda ptr1lo\n adc #$08\n sta ptr1lo\n bcc pwh_next1_ok\n inc ptr1hi\npwh_next1_ok:\n'
   if body.count(old)!=1:return s,dict(applied=False,reason='Other horizontal cursor increment retained')
   body=body.replace(old,'pwh_next0_ok:\npwh_next1_ok:\n',1)
   old=' sta (ptr0lo),y\n sta (ptr1lo),y\n'
   if body.count(old)!=1:return s,dict(applied=False,reason='Other full-byte writer retained')
   body=body.replace(old,' sta (ptr0lo),y\n iny\n sta (ptr0lo),y\n dey\n',1)
  patched[name]=body
 for name,first,last in REGIONS:
  a,b,_=region(s,first,last);s=s[:a]+patched[name]+s[b:]
 payload=json.dumps(saved,sort_keys=True,separators=(',',':')).encode('ascii');encoded=base64.b64encode(zlib.compress(payload,9)).decode('ascii')
 s+='; GR16_WIRE_RUNS '+hashlib.sha256(payload).hexdigest()+' '+encoded+'\n'
 return s,dict(applied=True,physicalRowAdjacencyProven=True,writers=['point','horizontal','vertical'],oneBitmapCursor=True,YRestored=True,dirtyAndMaterialCodeUnchanged=True,newRAMVariables=0,newRAMTables=0,extraDataStackBytes=0,qualityChanged=False,exact=True)

if __name__=='__main__':
 import argparse
 from pathlib import Path
 p=argparse.ArgumentParser();p.add_argument('asm',type=Path);a=p.parse_args()
 source=a.asm.read_text(encoding='utf-8-sig');result,info=patch(source)
 a.asm.write_bytes(result.encode('ascii'))
 a.asm.with_suffix('.wire-cursor.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
