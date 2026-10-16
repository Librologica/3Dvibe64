"""Select existing exact sampler/DDA at EVERY pixel; no affine interiors."""
import re
from optimizations import once
def apply(source, texture_lod=False):
    # The current private adapter originally installs four-pixel batching.
    # Restore exact per-pixel entries after its compatibility transformations.
    a=source.index('ps_sample:\n');b=source.index('bk_predict_legacy:\n',a)
    source=source[:a]+'ps_sample:\n jmp bk_exact_sample\n'+source[b:]
    # ps_advance and full-byte copies take their original exact path when
    # bk_count is zero. No runtime writer can now activate bk_count.
    a=source.index('ps_advance:\n');b=source.index('ca_block:\n',a)
    source=source[:a]+'ps_advance:\n jmp bk_exact_advance\n'+source[b:]
    a=source.index('ca_block:\n');b=source.index(' rts\n',a)+len(' rts\n')
    source=source[:a]+source[b:]
    a=source.index('bk_predict_legacy:\n');b=source.index(' rts\n',a)+len(' rts\n')
    source=source[:a]+'bk_predict_legacy:\n rts ; unreachable with exact pixel sampling\n'+source[b:]
    # Delete unreachable batching in four-byte compositor copies while
    # preserving neutral-shader labels referenced by its established SMC.
    for i in range(3):
        a=source.index(f'fx{i}_ps_advance:\n');b=source.index(f'fx{i}_m3_advance_q:\n',a)
        source=source[:a]+f'fx{i}_ps_advance:\n jsr bk_exact_advance\n jmp fx{i}_advance_done\n'+source[b:]
    # Precision and row sampling stay exact independently of texture LOD.
    # The fixed ceiling pigment motif remains the original material.
    assert ('lg_lod_select_disabled:' in source) == (not texture_lod)
    assert 'sp_filter_row:' not in source and 'sp_render_and_fill:' not in source
    return source
