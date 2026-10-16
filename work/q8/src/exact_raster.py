"""Exact perspective raster emitter helpers. No fixed RAM addresses or assets.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
from perspective_exact import once

BOUNDED_DIVIDE = '; Exact unsigned 24/16 division. Prove an 8-bit quotient first.\ner_divide_guard:\n lda ps_num+2\n cmp ps_den+1\n bcc er_divide_short\n bne er_divide_full\n lda ps_num+1\n cmp ps_den\n bcc er_divide_short\ner_divide_full:\n jmp ps_div24_16_general\ner_divide_short:\n lda ps_num+1\n sta ps_remainder\n lda ps_num+2\n sta ps_remainder+1\n lda #0\n sta ps_num+1\n sta ps_num+2\n ldx #8\ner_divide_loop:\n asl ps_num\n rol ps_remainder\n rol ps_remainder+1\n bcs er_divide_subtract\n lda ps_remainder+1\n cmp ps_den+1\n bcc er_divide_next\n bne er_divide_subtract\n lda ps_remainder\n cmp ps_den\n bcc er_divide_next\ner_divide_subtract:\n sec\n lda ps_remainder\n sbc ps_den\n sta ps_remainder\n lda ps_remainder+1\n sbc ps_den+1\n sta ps_remainder+1\n inc ps_num\ner_divide_next:\n dex\n bne er_divide_loop\n rts\n'


def bounded_divide(parts):
    owners=[k for k,v in parts.items() if 'ps_div24_16:\n' in v]
    if len(owners)!=1:raise ValueError('EXACT_DIVIDE: standard 24/16 perspective ABI required')
    owner=owners[0]
    parts[owner]=once(parts[owner],'ps_div24_16:\n','ps_div24_16:\n jmp er_divide_guard\nps_div24_16_general:\n')
    parts['exact_bounded_divide']=BOUNDED_DIVIDE


def pack_four(samples):
    if len(samples)!=4 or any(type(v)is not int or not 0<=v<=3 for v in samples):
        raise ValueError('Four two-bit pixel codes required')
    value=0
    for pixel in samples:value=(value<<2)|pixel
    return value


def uniform_gouraud(patterns,*,bulk_entry='sp_solid',row_cache='sp_current_row',prefix='er_uniform'):
    """Adapter assembly for identical Bayer bytes over an entire shade interval.
    patterns is shade-major, four row bytes per shade (1..64 shades). Endpoint
    equality must imply equality of every intermediate byte, checked here.
    Runtime shade endpoints must be within that same table; caller validates it.
    Returns code+data; adapter routes eligible spans here and supplies bulk ABI.
    """
    import re
    if any(not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*',v) for v in (bulk_entry,row_cache,prefix)):raise ValueError('Invalid assembly symbol')
    if not isinstance(patterns,(list,tuple)) or not 1<=len(patterns)<=64 or any(len(v)!=4 or any(type(b)is not int or not 0<=b<=255 for b in v) for v in patterns):raise ValueError('Expected 1..64 shade levels of four packed row bytes')
    for row in range(4):
        for a in range(len(patterns)):
            for b in range(a,len(patterns)):
                if patterns[a][row]==patterns[b][row] and any(patterns[k][row]!=patterns[a][row] for k in range(a,b+1)):raise ValueError('Endpoint equality does not prove a constant interval')
    p=prefix
    return f'{p}_span:\n lda yrow\n and #3\n sta {p}_row\n lda gouraud_scan_shade\n asl\n asl\n ora {p}_row\n tax\n lda {p}_patterns,x\n sta {p}_fill\n ldx yrow\n lda rightshade,x\n asl\n asl\n ora {p}_row\n tax\n lda {p}_patterns,x\n cmp {p}_fill\n bne {p}_gradient\n ldx {p}_row\n sta {row_cache},x\n jmp {bulk_entry}\n{p}_gradient:\n jmp gouraud_draw_scan_span_bytes\n{p}_row: .byte 0\n{p}_fill: .byte 0\n{p}_patterns: .byte \n'.rstrip()+' '+','.join(str(b) for row in patterns for b in row)+'\n'


def inline_gouraud(source,*,sites=1):
    """Expand exact standard DDA calls; allocator still decides RAM feasibility."""
    import re
    start=source.index('gouraud_advance_scan_pixel:\n');end=source.index(' rts\n',start)
    body=source[start+len('gouraud_advance_scan_pixel:\n'):end]
    labels=set(re.findall(r'(?m)^(\w+):',body))
    if labels-{'gasp_step_check','gasp_step_done'}:raise ValueError('Unrecognized DDA local labels')
    if type(sites)is not int or not 1<=sites<=source.count(' jsr gouraud_advance_scan_pixel\n'):raise ValueError('Invalid expansion count')
    for i in range(sites):
        copy=body
        for label in labels:copy=re.sub(r'\b'+label+r'\b',f'er_inline_{i}_{label}',copy)
        source=source.replace(' jsr gouraud_advance_scan_pixel\n',copy,1)
    return source


def texture_page(texels):
    """Exact 16x16 data for a caller-allocated page; no built-in texture."""
    if not isinstance(texels,(list,tuple)) or len(texels)!=256 or any(type(v)is not int or not 0<=v<=3 for v in texels):raise ValueError('256 two-bit texels required')
    return bytes(texels)


UNROLLED_ADVANCE = 'er_advance_0:\n lda #0\n sta ri_ca+0\n clc\n lda ps_cur0+0\n adc ps_step0+0\n sta ps_cur0+0\n lda ps_cur1+0\n adc ps_step1+0\n sta ps_cur1+0\n clc\n lda ps_err+0\n adc ps_rem+0\n bcs er_advance_correct_0\n cmp m7_den\n bcc er_advance_store_0\ner_advance_correct_0:\n inc ri_ca+0\n sec\n sbc m7_den\n sta ps_err+0\n inc ps_cur0+0\n bne er_advance_next_0\n inc ps_cur1+0\n jmp er_advance_next_0\ner_advance_store_0:\n sta ps_err+0\ner_advance_next_0:\ner_advance_1:\n lda #0\n sta ri_ca+1\n clc\n lda ps_cur0+1\n adc ps_step0+1\n sta ps_cur0+1\n lda ps_cur1+1\n adc ps_step1+1\n sta ps_cur1+1\n clc\n lda ps_err+1\n adc ps_rem+1\n bcs er_advance_correct_1\n cmp m7_den\n bcc er_advance_store_1\ner_advance_correct_1:\n inc ri_ca+1\n sec\n sbc m7_den\n sta ps_err+1\n inc ps_cur0+1\n bne er_advance_next_1\n inc ps_cur1+1\n jmp er_advance_next_1\ner_advance_store_1:\n sta ps_err+1\ner_advance_next_1:\ner_advance_2:\n lda #0\n sta ri_ca+2\n clc\n lda ps_cur0+2\n adc ps_step0+2\n sta ps_cur0+2\n lda ps_cur1+2\n adc ps_step1+2\n sta ps_cur1+2\n clc\n lda ps_err+2\n adc ps_rem+2\n bcs er_advance_correct_2\n cmp m7_den\n bcc er_advance_store_2\ner_advance_correct_2:\n inc ri_ca+2\n sec\n sbc m7_den\n sta ps_err+2\n inc ps_cur0+2\n bne er_advance_next_2\n inc ps_cur1+2\n jmp er_advance_next_2\ner_advance_store_2:\n sta ps_err+2\ner_advance_next_2:\n inc gouraud_scan_x\n rts\n'


def unrolled_advance(source,parts):
    if 'm3_q0:' in source:raise ValueError('EXACT_ADVANCE: unlit perspective shader required')
    owners=[k for k,v in parts.items() if 'pu_advance_general:\n' in v]
    if len(owners)!=1 or 'ri_ca =' not in source+'\n'.join(parts.values()):raise ValueError('EXACT_ADVANCE: standard rational carrier ABI required')
    owner=owners[0];p=parts[owner];a=p.index('pu_advance_general:\n');b=p.index('pu_prepare:\n',a)
    parts[owner]=p[:a]+'pu_advance_general:\n jmp er_advance_0\n'+p[b:]
    parts['exact_unrolled_advance']=UNROLLED_ADVANCE
