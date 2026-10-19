"""Opt-in Mode4 connected wire raster; keeps native material/dirty handling.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import re


def conditional(source, marker):
    start = source.index(marker)
    end = start
    depth = 0
    for line in source[start:].splitlines(keepends=True):
        if line.lstrip().startswith('.if '):
            depth += 1
        if line.lstrip().startswith('.endif'):
            depth -= 1
        end += len(line)
        if depth == 0:
            return source[start:end]
    raise AssertionError(marker)


def install(source, reference=False):
    from legacy_plus_exact import constant
    if constant(source,'VIC_COLOR_POLICY_ENABLE')!=0:
        raise ValueError('EXACT_RENDER_WIRE: VIC cell-ownership policy needs a separate qualified adapter')
    # Copy the SDK's connected-edge fast kernels into a wire-only namespace.
    # The filled Mode4 faces continue using their original bounds tracer.
    a = source.index('trace_edge_convex:\n')
    b = source.index('.if ENGINE_MODE3_FAST_BOUNDS_TRACE != 0 || ENGINE_MODE4_FAST_BOUNDS_TRACE != 0\n; C64 fast bounds', a)
    kernel = source[a:b]
    kernel += conditional(source, '.if DIRECT_CONVEX_EDGE_SPANS != 0 || ENGINE_WIRE_SCANLINE_RUN_RASTERIZER != 0\ntec_flush_span:')
    kernel += 'tec_horizontal:\n jmp plot_wire_horizontal\n'
    kernel += 'update_convex_bounds:\n stx rightval\n sta leftval\n jmp plot_wire_point\n'

    a = source.index('plot_wire_point:\n')
    b = source.index('.if ENGINE_WIRE_CELL_WRITE_SKIP_SAME != 0\nengine_wire_reset_material_cell_cache:', a)
    kernel += source[a:b]
    a = source.index('plot_wire_horizontal:\n')
    b = source.index('.if ENGINE_WIRE_STEEP_LINE_FASTPATH != 0\n; Draw an inclusive same-column run.', a)
    horizontal = source[a:b].rstrip()
    assert horizontal.endswith('.endif')
    kernel += horizontal[:-len('.endif')] + '\n'
    kernel += conditional(source, '.if ENGINE_WIRE_STEEP_LINE_FASTPATH != 0\n; Draw an inclusive same-column run.')

    # Material writes remain active: no global or fixed-palette assumption.
    flags = dict(ENGINE_WIRE_SCANLINE_RUN_RASTERIZER=1,
                 ENGINE_WIRE_STEEP_LINE_FASTPATH=1, ENGINE_WIRE_8BIT_BRESENHAM=1,
                 ENGINE_WIRE_RASTER_CONSOLIDATION=1,
                 ENGINE_MODE1_WIRE_POINT_BOUNDS_STRIPPED=1,
                 ENGINE_MODE3_FAST_BOUNDS_TRACE=0, ENGINE_MODE4_FAST_BOUNDS_TRACE=0,
                 DIRECT_CONVEX_EDGE_SPANS=0)
    if reference:
        # Scalar connected walker for independent external qualification.
        # Never selected by the public optimization selector.
        for name in ('ENGINE_WIRE_SCANLINE_RUN_RASTERIZER','ENGINE_WIRE_STEEP_LINE_FASTPATH',
                     'ENGINE_WIRE_8BIT_BRESENHAM','ENGINE_WIRE_RASTER_CONSOLIDATION'):
            flags[name]=0
        # Scalar wire must visit every bridge pixel; solid bounds may retain
        # only extrema when FAST_FILL_BOUNDS_TRACE is enabled in the source.
        flags['FAST_FILL_BOUNDS_TRACE']=0
    for name, value in flags.items():
        kernel = re.sub(r'\b'+name+r'\b', str(value), kernel)

    # Shallow runs use an 8-bit remainder too. err<dy before adding dx;
    # if ADC carries, one subtraction resolves the ninth bit (dy<=99).
    # Subsequent subtractions form one complete horizontal byte span.
    for side in (() if reference else ('l', 'r')):
        for direction in ('pos', 'neg'):
            stem = f'tec_{side}span_{direction}'
            old = (' sta errlo\n lda errhi\n adc #$00\n sta errhi\n'+stem+'_check:\n'
                   ' lda errhi\n bne '+stem+'_x\n lda errlo\n cmp dyval\n bcc '+stem+'_y\n'+stem+'_x:\n'
                   ' sec\n lda errlo\n sbc dyval\n sta errlo\n lda errhi\n sbc #$00\n sta errhi\n')
            new = (' sta errlo\n bcs '+stem+'_x\n'+stem+'_check:\n'
                   ' lda errlo\n cmp dyval\n bcc '+stem+'_y\n'+stem+'_x:\n'
                   ' sec\n lda errlo\n sbc dyval\n sta errlo\n')
            assert kernel.count(old) == 1, stem
            kernel = kernel.replace(old, new)

    # The ordinary solid profile compiles out its wire-only single-cell writer.
    # Use the native span material writer with a one-cell inclusive interval.
    kernel += '''plot_wire_material:
plot_wire_material_write:
 ldx leftval
 lda xbyte,x
 sta startbyte
 sta endbyte
 lda rightval
 sta yrow
 lda drawbuf
 bne er_wire_material_b
 jmp apply_material_span_a
er_wire_material_b:
 jmp apply_material_span_b
'''
    names = set(re.findall(r'^([A-Za-z_]\w*):', kernel, re.M))
    # The conditional source has a few inactive fallback references to helpers
    # outside the slice; these stay inactive under this wire specialization.
    kernel = re.sub(r'\b[A-Za-z_]\w*\b', lambda m: 'grid_'+m[0] if m[0] in names else m[0], kernel)
    # Public entry validates clipped endpoints before touching lookup tables.
    # A screen line that needs clipping must use the original clipper first.
    kernel = kernel.replace('grid_', 'er_wire_')
    wrapper = """er_wire_line:
 lda ex0
 cmp #160
 bcs er_wire_invalid
 lda ex1
 cmp #160
 bcs er_wire_invalid
 lda ey0
 cmp #100
 bcs er_wire_invalid
 lda ey1
 cmp #100
 bcs er_wire_invalid
 jsr er_wire_trace_edge_convex
 sec
 rts
er_wire_invalid:
 clc
 rts
"""
    from legacy_plus_exact import block
    # Independent routines can occupy different real free-RAM gaps. Preserve
    # all intra-routine fallthrough; do not grow the allocator's address space.
    marks=[0,kernel.index('er_wire_plot_wire_point:\n'),
           kernel.index('er_wire_plot_wire_horizontal:\n'),
           kernel.index('.if '+str(flags['ENGINE_WIRE_STEEP_LINE_FASTPATH'])+' != 0\n; Draw an inclusive same-column run.'),
           kernel.index('er_wire_plot_wire_material:\n')]
    marks.append(len(kernel))
    return source+block('wire_entry',wrapper)+''.join(
        block('wire_'+str(i),kernel[a:b]) for i,(a,b) in enumerate(zip(marks,marks[1:])))
