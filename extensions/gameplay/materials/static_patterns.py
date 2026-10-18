"""Caller-owned flat lighting cache and exact packed Bayer spans.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import re
BAYER=((0,8,2,10),(12,4,14,6),(3,11,1,9),(15,7,13,5))


def pattern(level,low=0,high=1):
    if type(level)is not int or not 0<=level<=16:raise ValueError('Pattern level must be integer 0..16')
    if any(type(v)is not int or not 0<=v<=3 for v in (low,high)):raise ValueError('Pixel code must be 0..3')
    return tuple(sum((high if n<level else low)<<(6-2*x) for x,n in enumerate(row)) for row in BAYER)


def constant_interval(patterns,start,end):
    if any(type(v)is not int or not 0<=v<len(patterns) for v in (start,end)):raise ValueError('Invalid shade endpoint')
    lo,hi=sorted((start,end));first=patterns[lo]
    return first if all(v==first for v in patterns[lo:hi+1]) else None


class FlatCache:
    """Host authoring cache; invalidation is explicit, never inferred per frame."""
    def __init__(self):self.entries={}
    def assign(self,key,revision,level,low=0,high=1):
        try:hash(key);hash(revision)
        except TypeError as ex:raise ValueError('Cache key and revision must be immutable/hashable') from ex
        stamp=(revision,type(level),level,type(low),low,type(high),high)
        old=self.entries.get(key)
        if old is None or old[0]!=stamp:self.entries[key]=(stamp,pattern(level,low,high))
        return self.entries[key][1]
    def invalidate(self,key):self.entries.pop(key,None)


def shared_palette(source,*,immutable=False):
    """Skip span palette claims only for a caller-guaranteed immutable palette.
    Existing full-screen initialization stays intact; runtime material changes
    must retain the same palette, otherwise this optimization is invalid.
    """
    if not immutable:raise ValueError('Immutable palette contract required')
    for label in ('material_screen_bytes','material_color_bytes'):
        m=re.search(r'(?m)^'+label+r':\n((?: \.byte[^\n]*\n)+)',source)
        if not m:raise ValueError('Palette table missing: '+label)
        values=[int(x[1:],16) if x.startswith('$') else int(x) for x in re.findall(r'\$[0-9a-fA-F]+|\d+',m[1])]
        if not values or len(set(values))!=1:raise ValueError('Palette is not shared: '+label)
    a=source.index('apply_material_span_a:\n');b=source.index('\n.if MATERIAL_CELL_SPAN_CACHE',a)
    dead=source[a:b];labels=re.findall(r'(?m)^(\w+):',dead)
    # Preserve every callable entry in the palette-only block as a no-op.
    return source[:a]+''.join(n+':\n' for n in labels)+' rts\n'+source[b:]


BULK_SPAN = '; Mask only the two boundary bytes, stream whole interior bytes.\nsp_solid:\n lda leftval\n sta gouraud_scan_x\n and #$fc\n sta sp_end_byte\n lda rightval\n sta gouraud_scan_end\n lda gouraud_scan_end\n and #$fc\n sec\n sbc sp_end_byte\n lsr\n lsr\n sta sp_bulk_count\n lda gouraud_scan_end\n and #$fc\n sta sp_end_byte\n lda yrow\n and #3\n tax\n lda sp_current_row,x\n sta sp_fill\n jsr gouraud_init_span_pointers\n lda gouraud_scan_x\n and #3\n tax\n lda sp_left_mask,x\n ldy #0\n ldx sp_bulk_count\n beq sp_bulk_single\n cmp #255\n beq sp_bulk_begin\n jsr sp_bulk_masked\n jsr sp_bulk_advance\n dec sp_bulk_count\nsp_bulk_begin:\n ldx sp_bulk_count\n beq sp_bulk_final\nsp_bulk_whole:\n lda sp_fill\n sta (ptr0lo),y\n sta (ptr1lo),y\n tya\n clc\n adc #8\n tay\n bcc +\n inc ptr0hi\n inc ptr1hi\n+\n dex\n bne sp_bulk_whole\nsp_bulk_final:\n lda #255\nsp_bulk_single:\n sta sp_mask\n lda gouraud_scan_end\n and #3\n tax\n lda sp_right_mask,x\n and sp_mask\n cmp #255\n bne sp_bulk_last_masked\n lda sp_fill\n sta (ptr0lo),y\n sta (ptr1lo),y\n jmp sp_bulk_done\nsp_bulk_last_masked:\n jsr sp_bulk_masked\nsp_bulk_done:\n lda sp_end_byte\n sta gouraud_scan_x\n rts\nsp_bulk_masked:\n sta sp_mask\n eor #255\n sta sp_preserve\n lda sp_fill\n and sp_mask\n sta sp_bits\n lda (ptr0lo),y\n and sp_preserve\n ora sp_bits\n sta (ptr0lo),y\n lda (ptr1lo),y\n and sp_preserve\n ora sp_bits\n sta (ptr1lo),y\n rts\nsp_bulk_advance:\n tya\n clc\n adc #8\n tay\n bcc +\n inc ptr0hi\n inc ptr1hi\n+\n rts\nsp_bulk_count: .byte 0\n'


def bulk_span(*,closed_edges=False):
    """Emit Q8 Mode6 span ABI; caller supplies sp_current_row[4] and scratch.
    ptr0/ptr1 and gouraud_init_span_pointers address the two physical rows.
    leftval/rightval must be a nonempty 0..159 span. Empty spans are rejected
    by the outer raster. closed_edges=False preserves tq_closed half-open edges.
    Returns code plus scratch/mask declarations; no absolute placement.
    """
    body=BULK_SPAN
    if not closed_edges:
        body=body.replace(' sta gouraud_scan_end\n',' sta gouraud_scan_end\n ldx yrow\n lda tq_closed,x\n bne +\n dec gouraud_scan_end\n+\n',1)
    return body+'sp_current_row: .fill 4,255\nsp_end_byte: .byte 0\nsp_fill: .byte 0\nsp_mask: .byte 0\nsp_preserve: .byte 0\nsp_bits: .byte 0\nsp_left_mask: .byte 255,63,15,3\nsp_right_mask: .byte 192,240,252,255\n'


def native_cache(face_count,*,low=0,high=1,prefix='sf',row_cache='sp_current_row'):
    """Native generation-time face cache; code/data placement is caller-owned.
    assign: A=level0..16,X=face; load/invalidate: X=face. Carry indicates success.
    Load of an unassigned/invalid face keeps the active row cache unchanged.
    A/Y are clobbered; X preserved. Mutate only between rendered views.
    """
    if type(face_count)is not int or not 1<=face_count<=255:raise ValueError('1..255 cached faces required')
    if any(not isinstance(n,str) or not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*',n) for n in (prefix,row_cache)):raise ValueError('Invalid cache assembly symbol')
    table=[byte for level in range(17) for byte in pattern(level,low,high)];p=prefix
    code=f'{p}_assign:\n cmp #17\n bcs {p}_fail\n cpx #{face_count}\n bcs {p}_fail\n sta {p}_level,x\n asl\n asl\n tay\n'
    for row in range(4):
        code+=f' lda {p}_patterns+{row},y\n sta {p}_row{row},x\n'
    code+=f' lda #1\n sta {p}_ready,x\n sec\n rts\n{p}_load:\n cpx #{face_count}\n bcs {p}_fail\n lda {p}_ready,x\n beq {p}_fail\n'
    for row in range(4):code+=f' lda {p}_row{row},x\n sta {row_cache}+{row}\n'
    code+=f'sec\n rts\n{p}_invalidate:\n cpx #{face_count}\n bcs {p}_fail\n lda #0\n sta {p}_ready,x\n sec\n rts\n{p}_fail:\n clc\n rts\n'
    code+=f'{p}_level: .fill {face_count},0\n{p}_ready: .fill {face_count},0\n'
    for row in range(4):code+=f'{p}_row{row}: .fill {face_count},0\n'
    return code+f'{p}_patterns: .byte '+','.join(map(str,table))+'\n'
