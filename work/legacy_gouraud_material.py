"""Exact per-face material-cell write cache for ordinary Gouraud renderers.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import re
RESET_OLD='gouraud_fill_bounds:\n'
RESET_NEW='gouraud_fill_bounds:\n ; GR14_MATERIAL_CACHE_RESET\n lda #$ff\n sta material_last_cellrow\n'
BLOCK=re.compile(r'\n; Plus allocation block gouraud_material_cache\n(?:\* = \$[0-9a-f]+|\.virtual \$4000)\nlpa_block_gouraud_material_cache_begin:\n.*?lpa_block_gouraud_material_cache_end:\n(?:\.cerror[^\n]+\n|\.endvirtual\n)',re.S)

CODE='gr14_material_a:\n jsr gr14_material_guard\n jmp maybe_apply_material_span_a\ngr14_material_b:\n jsr gr14_material_guard\n jmp maybe_apply_material_span_b\ngr14_material_guard:\n ; Existing cache tracks a connected union. Reset it when the new span is\n ; disjoint: this never colors a gap and never claims an unwritten cell.\n lda endbyte\n cmp material_cell_min\n bcs gr14_material_check_right\n adc #1\n cmp material_cell_min\n bcc gr14_material_reset\ngr14_material_check_right:\n lda material_cell_max\n cmp startbyte\n bcs gr14_material_connected\n adc #1\n cmp startbyte\n bcs gr14_material_connected\ngr14_material_reset:\n lda #$ff\n sta material_last_cellrow\ngr14_material_connected:\n rts\n'

def region(s):
    a=s.index('gouraud_fill_bounds:\n');b=s.index('gfb_rows_ready:\n',a)
    return a,b,s[a:b]

def original_source(s):
    if RESET_NEW not in s:return s
    a,b,chunk=region(s)
    chunk=chunk.replace(RESET_NEW,RESET_OLD,1)
    for bank in 'ab':
        new=f' jsr gr14_material_{bank}\n'
        assert chunk.count(new)==1
        chunk=chunk.replace(new,f' jsr apply_material_span_{bank}\n',1)
    s=s[:a]+chunk+s[b:]
    if len(list(BLOCK.finditer(s)))!=1:raise ValueError('GOURAUD_MATERIAL_RESTORE_BLOCK')
    return BLOCK.sub('',s)

def row_group_proven(s):
    def table(name):
        m=re.search(r'(?m)^'+name+r':\n((?: \.byte [^\n]+\n)+)',s)
        if not m:return None
        return [int(v[1:],16) if v.startswith('$') else int(v) for v in re.findall(r'\$[0-9a-fA-F]+|\b\d+\b',m[1])]
    for low,high in [('screenrowlo_a','screenrowhi_a'),('screenrowlo_b','screenrowhi_b'),('colorrowlo','colorrowhi')]:
        lo,hi=table(low),table(high)
        if not lo or not hi or len(lo)!=len(hi):return False
        pointers=[a+256*b for a,b in zip(lo,hi)]
        if any(value!=pointers[(i//4)*4] for i,value in enumerate(pointers)):return False
    return True

def patch(s):
    s=original_source(s)
    if not re.search(r'(?m)^GRAPHICS_MODE = \$0[67]$',s):return s,dict(applied=False,reason='Mode6/7 only')
    if 'MATERIAL_CELL_SPAN_CACHE = $01' not in s or 'VIC_COLOR_POLICY_ENABLE = $00' not in s:
        return s,dict(applied=False,reason='Existing enabled cache and idempotent color policy required')
    if RESET_OLD not in s or 'gfb_rows_ready:\n' not in s:return s,dict(applied=False,reason='Other raster retained')
    if not row_group_proven(s):return s,dict(applied=False,reason='Physical material row grouping not proven')
    a,b,chunk=region(s)
    if any(chunk.count(f' jsr apply_material_span_{bank}\n')!=1 for bank in 'ab'):
        return s,dict(applied=False,reason='Other material caller retained')
    chunk=chunk.replace(RESET_OLD,RESET_NEW,1)
    for bank in 'ab':
        chunk=chunk.replace(f' jsr apply_material_span_{bank}\n',f' jsr gr14_material_{bank}\n',1)
    s=s[:a]+chunk+s[b:]
    s+='\n; Plus allocation block gouraud_material_cache\n.virtual $4000\nlpa_block_gouraud_material_cache_begin:\n'+CODE+'lpa_block_gouraud_material_cache_end:\n.endvirtual\n'
    return s,dict(applied=True,perFaceReset=True,connectedActuallyWrittenUnion=True,newRAMVariables=0,newRAMTables=0,
        qualityChanged=False,policy='Existing incremental cache with disconnected-union guard, fixed material/buffer and per-face reset')
