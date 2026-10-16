"""Opt-in X-Q2 feasibility probe, not full subpixel clipping.
Copyright 2026 librologica.digital. PolyForm Noncommercial 1.0.0.
Retains the public XY walker, Y, culling, integer shade anchors and clipped paths.
"""
from pathlib import Path
import re
import sys

def emit(source):
    s=source.replace('\r\n','\n')
    mobile=bool(re.search(r'^CAMERA_MOVABLE = \$01$',s,re.M))
    assert re.search(r'^SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y = \$01$',s,re.M)
    assert 'sxq2_hi = sxq2_lo + VERT_COUNT' in s
    a=s.index('load_face_y:\n');b=s.index('load_face_y_clip:\n',a)
    block=s[a:b]
    for i in range(4):
        old=f''' sta vx{i}
 sta vxq2_{i}lo
 lda #$00
 sta vxq2_{i}hi
 asl vxq2_{i}lo
 rol vxq2_{i}hi
 asl vxq2_{i}lo
 rol vxq2_{i}hi
'''
        new=f''' sta vx{i}
 lda sxq2_lo,x
 sta vxq2_{i}lo
 lda sxq2_hi,x
 sta vxq2_{i}hi
'''
        assert block.count(old)==1
        block=block.replace(old,new)
    s=s[:a]+block+s[b:]
    if mobile:
        assert re.search(r'^EXPLORER_TABLE_PROJECTION = \$00$',s,re.M)
        # Hook ONLY original mesh vertices. Generated clipping intersections
        # keep the old projector, without overwriting source Q2 caches.
        old=' lda explorer_view_x_hi\n sta p1hi\n jsr explorer_project_x16\n'
        assert s.count(old)==1
        s=s.replace(old,old.replace('explorer_project_x16','probe_mobile_project_x'))
        old='explorer_project_x16:\n jsr explorer_project_axis_offset\n'
        assert s.count(old)==1
        s=s.replace(old,old+'probe_mobile_x_legacy:\n')
    else:
        old=' jsr smooth_projected_vertex\n jsr solid_subpixel_yq2_store\n'
        assert s.count(old)==3
        s=s.replace(old,' jsr smooth_projected_vertex\n jsr probe_xq2_store\n jsr solid_subpixel_yq2_store\n')
    # Legacy Gate 4 intentionally retained 11-bit magnitude truncation. New
    # numeric contract cannot inherit that for long normal-viewport edges.
    assert s.count(' jsr xyq2_div_signed_euclid_11x8\n')==2
    s=s.replace(' jsr xyq2_div_signed_euclid_11x8\n',' jsr probe_div_checked\n')
    kernel=(Path(__file__).with_name('subpixel-x-probe.asm')).read_text()
    if mobile:
        # Retain the common checked edge divider; omit unused fixed projection.
        kernel=kernel[kernel.index('; Checked use of the old fast divisor'):]
        kernel=(Path(__file__).with_name('subpixel-mobile-x.asm')).read_text()+'\n'+kernel
    # Use the existing low-code segment's spare capacity, not scarce high RAM.
    # No new segment/org and no changed memory-boundary constants.
    assert s.count('clear_bitmap_buffers:\n')==1
    s=s.replace('clear_bitmap_buffers:\n',kernel+'\nclear_bitmap_buffers:\n')
    return s

if __name__=='__main__':
    p=Path(sys.argv[1]);p.write_text(emit(p.read_text()),encoding='ascii')
