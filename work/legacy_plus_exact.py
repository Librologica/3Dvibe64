"""Exact opt-in kernels for ordinary Mode4 legacy-plus; no application data.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
Every shortcut retains native Q4/Q10 rounding and the original full fallback.
"""
import argparse,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent
OPTIONS=('arithmetic','edges','spans','outcodes','convex','frozen-lighting')

def once(s,old,new):
    if s.count(old)!=1:raise ValueError('EXACT_RENDER_HOOK: '+repr(old[:90]))
    return s.replace(old,new,1)

def block(name,code):
    return f'\n; Plus allocation block er_{name}\n.virtual $4000\nlpa_block_er_{name}_begin:\n'+code+f'\nlpa_block_er_{name}_end:\n.endvirtual\n'

def parse(value):
    names=value.split(',')
    if names==['none']:return []
    if names==['all']:return list(OPTIONS[:-1])
    if not names or len(names)!=len(set(names)) or any(x not in OPTIONS for x in names):
        raise ValueError('EXACT_RENDER_OPTIONS: use none, all, or unique comma-separated '+','.join(OPTIONS))
    return [x for x in OPTIONS if x in names]

def constant(s,name):
    m=re.search(r'(?m)^'+re.escape(name)+r' = (\$[0-9a-fA-F]+|\d+)\b',s)
    if not m:raise ValueError('EXACT_RENDER_CONSTANT: '+name)
    return int(m[1][1:],16) if m[1].startswith('$') else int(m[1])

def flag(s,name,value=1):
    return once(s,f'{name} = ${constant(s,name):02X}',f'{name} = ${value:02X}')

def arithmetic(s):
    s=once(s,'lr_mul_s16_q10:\n','''lr_mul_s16_q10:
 lda p1lo
 ora p1hi
 beq er_unit_return
 lda lr_coeff_lo,x
 bne er_general_product
 lda lr_coeff_hi,x
 beq er_zero_return
 cmp #4
 beq er_unit_return
 cmp #$fc
 bne er_general_product
 sec
 lda #0
 sbc p1lo
 sta p1lo
 lda #0
 sbc p1hi
 sta p1hi
er_unit_return:
 ldx #0
 rts
er_zero_return:
 sta p1lo
 sta p1hi
 ldx #0
 rts
er_general_product:
''')
    a=s.index('lr_mul_coefficient_positive:\n');b=s.index(' clc\n lda lr_product+1\n adc #2\n',a)
    s=s[:a]+'''lr_mul_coefficient_positive:
 jsr er_product
 ldx #0
'''+s[b:]
    s=once(s,'div16u:\n lda #$00\n sta crosslo\n sta crosshi\n ldx #$10\nd16_loop:\n','''div16u:
 lda #0
 sta crosshi
 lda p1hi
 bne er_div8
 lda prodhi
 cmp p1lo
 bcc er_div8
 lda #0
 sta crosslo
 ldx #16
 bne d16_loop
er_div8:
 lda prodhi
 sta crosslo
 lda prodlo
 sta prodhi
 lda #0
 sta prodlo
 ldx #8
d16_loop:
''')
    # Normalization has already made the absolute numerator byte-sized.
    a=s.index('lc_ratio_mul_start:\n');b=s.index('lc_ratio_divide:\n',a)
    s=s[:a]+'''lc_ratio_mul_start:
 lda mul16lo
 ldx #EXPLORER_PROJ_FOCAL
 jsr er_mul_u8
'''+s[b:]
    return s

def edges(s):
    if constant(s,'YQ2_INLINE_BOUNDS')!=1 or constant(s,'YQ2_FAST_PIXEL_CONVERT')!=1:
        raise ValueError('EXACT_RENDER_EDGES: native inline bounds/pixel converter required')
    s=once(s,'xyq2_edge_row_loop:\n','xyq2_edge_row_loop:\n jmp er_edge_select\ner_edge_generic:\n')
    s=once(s,' jmp xyq2_edge_row_loop\n',' jmp er_edge_generic\n')
    return s+block('edges',(HERE/'exact_render/edges.asm').read_text())

def table(s,name):
    m=re.search(r'(?m)^'+name+r':\n((?: \.byte [^\n]+\n)+)',s)
    if not m:raise ValueError('EXACT_RENDER_TABLE: '+name)
    return [int(x[1:],16) if x.startswith('$') else int(x) for x in re.findall(r'\$[0-9a-fA-F]+|\b\d+\b',m[1])]

def spans(s):
    for name in ('MATERIAL_CELL_SPAN_CACHE','INDEXED_OFFSET_SPAN_FILL','ENGINE_MODE3_BOUNDS_INDEXED_LONG_SPANS'):
        s=flag(s,name)
    # A single min/max cache may represent only a connected union of cells.
    # Thin/sloped rows can be disjoint even inside one physical cell row.
    # Forget an old interval rather than coloring the gap or claiming it cached.
    for buf in 'ab':
        hook=f'mas_{buf}_same_cell:\n'
        code=f'''mas_{buf}_same_cell:
 lda endbyte
 cmp material_cell_min
 bcs er_material_{buf}_check_right
 clc
 adc #1
 cmp material_cell_min
 bcc er_material_{buf}_reset
er_material_{buf}_check_right:
 lda material_cell_max
 cmp startbyte
 bcs er_material_{buf}_connected
 clc
 adc #1
 cmp startbyte
 bcs er_material_{buf}_connected
er_material_{buf}_reset:
 lda startbyte
 sta material_cell_min
 lda endbyte
 sta material_cell_max
 jmp apply_material_span_{buf}
er_material_{buf}_connected:
'''
        s=once(s,hook,code)
    for buf in 'ab':
        lo,hi=table(s,'row0lo_'+buf),table(s,'row0hi_'+buf)
        lo1,hi1=table(s,'row1lo_'+buf),table(s,'row1hi_'+buf)
        if not (len(lo)==len(hi)==len(lo1)==len(hi1) and all(a%2==0 and b==a+1 for a,b in zip(lo,lo1)) and hi==hi1 and all(x%8==0 for x in table(s,'xofflo'))):
            raise ValueError('EXACT_RENDER_ROWS: paired even physical rows and8byte X offsets required')
        a=s.index(f'fill_bounds_solid_{buf}:\n');b=s.index(f'fbs_{buf}_done:\n rts\n',a);p=s[a:b]
        p=once(p,f' lda row1lo_{buf},x\n sta row1lo\n lda row1hi_{buf},x\n sta row1hi\n','')
        p=once(p,' sta ptr0hi\n lda row1lo\n clc\n adc xofflo,x\n sta ptr1lo\n lda row1hi\n adc xoffhi,x\n sta ptr1hi\n',' sta ptr0hi\n sta ptr1hi\n lda ptr0lo\n ora #1\n sta ptr1lo\n')
        # Keep the original fallback, selected if a future viewport exceeds40bytes.
        p=once(p,f' cmp #$06\n bcc fbs_{buf}_indexed_fallback\n','')
        p=once(p,f' cmp #$20\n bcs fbs_{buf}_indexed_fallback\n',f' cmp #40\n bcs fbs_{buf}_indexed_fallback\n')
        x=p.index(' sec\n sbc #$01\n sta p1hi\n');y=p.index(f'fbs_{buf}_indexed_end_at_08:',x)
        p=p[:x]+f''' sec
 sbc #1
 tax
 jsr er_long_span
 lda fullcount
 cmp #32
 bcc +
 inc ptr0hi
 inc ptr1hi
+
 lda fullcount
 asl
 asl
 asl
 tay
 jmp fbs_{buf}_indexed_draw_end_y
'''+p[y:]
        s=s[:a]+p+s[b:]
    helper='''er_long_span:
 cpx #32
 bcc +
 inc ptr0hi
 inc ptr1hi
+
 txa
 asl
 sta er_span_delta
 asl
 clc
 adc er_span_delta
 cpx #32
 bcc +
 clc
 adc #4
+
 sta er_span_delta
 sec
 lda #<er_span_0
 sbc er_span_delta
 sta er_span_jump
 lda #>er_span_0
 sbc #0
 sta er_span_jump+1
 lda fillbyte
 jmp (er_span_jump)
'''
    for n in range(38,0,-1):
        helper+=f'er_span_{n}:\n ldy #{(n*8)&255}\n sta (ptr0lo),y\n sta (ptr1lo),y\n'
        if n==32:helper+=' dec ptr0hi\n dec ptr1hi\n'
    helper+='er_span_0:\n rts\ner_span_jump: .word 0\ner_span_delta: .byte 0\n'
    return s+block('spans',helper)

def outcodes(s):
    # Each original vertex is already transformed/projected once per view.
    # Attach classification to that existing producer; never reuse across views.
    s=once(s,'etpv_next:\n','etpv_next:\n tya\n tax\n jsr er_cache_outcode\n')
    helper='''er_cache_outcode:
 lda projdone,x
 beq er_outcode_near
 lda #0
 sta er_code
 jsr clip_right_outside_x_poly
 beq +
 inc er_code
+
 jsr clip_left_outside_x_poly
 beq +
 lda er_code
 ora #2
 sta er_code
+
 jsr clip_top_outside_y_poly
 beq +
 lda er_code
 ora #4
 sta er_code
+
 jsr clip_bottom_outside_y_poly
 beq +
 lda er_code
 ora #8
 sta er_code
+
 lda er_code
 sta er_outcodes,x
 rts
er_outcode_near:
 lda #16
 sta er_outcodes,x
 rts
'''
    for routine,op in [('clip_poly_all_outside_screen','and'),('clip_poly_needs_screen','ora')]:
        lines=[routine+':',' ldy sortj']
        for n in range(4):
            if n==3:lines+=['.if HAS_TRI_FACES != 0',' lda loaded_face_vertex_count',' cmp #4',' bne er_'+op+'_done','.endif']
            lines+=['.if MESH_SOURCE_SHARING_RUNTIME != 0',f' ldx shared_fv{n}','.else',f' ldx face{n},y','.endif',' lda er_outcodes,x' if n==0 else f' {op} er_outcodes,x']
            if n==0:lines+=[' sta er_combined']
            else:
                # AND/ORA operands must be combined with the accumulator saved
                # across the triangle/quad count check.
                lines[-1]=' lda er_outcodes,x';lines +=[f' {op} er_combined',' sta er_combined']
        lines+=['er_'+op+'_done:',' lda er_combined']
        if op=='and':lines+=[' and #15']
        lines+=[' rts','']
        helper+='\n'.join(lines)
        # Replace only the entry with a jump, retaining full original kernels.
        s=once(s,routine+':\n',routine+'_original:\n')
    helper+='er_outcodes: .fill VERT_COUNT,0\ner_code: .byte 0\ner_combined: .byte 0\n'
    return s+block('outcodes',helper)

def frozen_lighting(s):
    if constant(s,'SCENE_OBJECT_COUNT')<1 or constant(s,'MESH_SOURCE_SHARING_RUNTIME') or not constant(s,'DYNAMIC_LIGHT'):
        raise ValueError('EXACT_RENDER_LIGHTING: dynamic-light, nonshared scene objects required')
    a=s.index('.if FLAT_DYNAMIC_SHADE != 0 && DYNAMIC_LIGHT != 0\n',s.index('lfv_visible:\n'));b=s.index('lfv_shade_done:\n.endif\n',a)+len('lfv_shade_done:\n.endif\n')
    s=s[:a]+'; Explicit first-active-pose per-object lighting cache.\n'+s[b:]
    s=s.replace(' jsr prepare_object_light_for_shade\n',' jsr er_prime_object_light\n')
    helper='''er_prime_object_light:
 ldx objidx
 lda er_light_ready,x
 bne er_light_return
 tya
 pha
 jsr prepare_object_light_for_shade
 lda active_face_first
 sta er_light_face
er_light_loop:
 lda er_light_face
 cmp active_face_end
 beq er_light_commit
 tay
.if FACE_SOLID_COLOR_ENABLE != 0
 lda face_solid_color,y
 cmp #$ff
 bne er_light_next
.endif
 jsr update_face_shade
er_light_next:
 inc er_light_face
 jmp er_light_loop
er_light_commit:
 ldx objidx
 lda #1
 sta er_light_ready,x
 pla
 tay
er_light_return:
 rts
; X=object; call between complete views after geometry/material/light edits.
er_light_invalidate:
 cpx #SCENE_OBJECT_COUNT
 bcs er_light_invalid
 lda #0
 sta er_light_ready,x
 sec
 rts
er_light_invalid:
 clc
 rts
er_light_face: .byte 0
er_light_ready: .fill SCENE_OBJECT_COUNT,0
'''
    return s+block('lighting',helper)

def patch(s,selection):
    opts=parse(selection)
    if not opts:return s,opts
    for name,value in [('GRAPHICS_MODE',4),('CAMERA_WALK_LITE',1),('MEMORY_LAYOUT_HIGH_BASIC_V2',1),('FPS_OVERLAY_ENABLE',0)]:
        if constant(s,name)!=value:raise ValueError('EXACT_RENDER_PROFILE: requires Mode4 legacy-plus walkLite normal/high-basic-v2/NoFpsOverlay')
    if 'LEGACY_PLUS_NEAR_SCREEN_Q4=1' not in s:raise ValueError('EXACT_RENDER_PROFILE: Q4 near/screen clipping required')
    for name in opts:
        if name=='convex':
            from exact_render_convex import patch as apply
        else:apply=globals()[name.replace('-','_')]
        s=apply(s)
    if 'arithmetic' in opts or 'convex' in opts:
        code=(HERE/'exact_render/product.asm').read_text()
        if 'arithmetic' not in opts:code=code[:code.index('; |signed16|')]
        s+=block('product',code)
    s='LEGACY_PLUS_EXACT_RENDER = 1\n'+''.join('EXACT_RENDER_'+n.upper().replace('-','_')+' = 1\n' for n in opts)+s
    return s,opts

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('asm',type=Path);p.add_argument('--options',required=True);a=p.parse_args()
    original=a.asm.read_text(encoding='utf-8-sig');result,opts=patch(original,a.options)
    a.asm.write_text(result,encoding='ascii')
    a.asm.with_suffix('.exact-render.json').write_text(json.dumps(dict(options=opts,geometry='native signed16 Q4',coefficients='native Q10',precisionReduced=False,alternateScanlines=False,defaultChanged=False),indent=2)+'\n')
