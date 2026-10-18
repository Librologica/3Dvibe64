"""Preserve existing camera Q4 through plus near intersections (dev6).

The original integer geometry buffers, camera transforms, projection of mesh
vertices and raster remain unchanged. A bounded Q4 cache feeds only near-poly
classification/intersections. Its depth and coordinates have the same scale;
the ordinary projector can consume them without conversion to integer WU.
This is not a Q8 backend or a change to historical rotation/Q8 profiles.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import argparse
import re
from pathlib import Path


def patch(source):
    # Retain the previous behavior of unrelated camera/ground clip selections.
    for name, value in [('EXPLORER_NEAR_POLY',1), ('CAMERA_PLANE_CLIP_PROFILE',0),
                        ('WORLD_GROUND_PLANE_CLIP',0)]:
        if not re.search(r'(?m)^'+name+fr' = \${value:02X}$',source):
            return source

    def replace(old,new):
        nonlocal source
        assert source.count(old)==1,old[:100]
        source=source.replace(old,new,1)

    # Dev7, one isolated timing change. Expand the four identical signed
    # shifts, retaining the original addition, A/Y, final X=0 and flags.
    # Only this explicit plus near path receives the expansion; the original
    # legacy_camera generator and every other backend remain byte-preserved.
    replace(''' ldx #4
lc_round_shift:
 lda p1hi
 cmp #$80
 ror p1hi
 ror p1lo
 dex
 bne lc_round_shift
 rts

lc_commit_q4:''', '''lc_round_shift:
 lda p1hi
 cmp #$80
 ror p1hi
 ror p1lo
 lda p1hi
 cmp #$80
 ror p1hi
 ror p1lo
 lda p1hi
 cmp #$80
 ror p1hi
 ror p1lo
 lda p1hi
 cmp #$80
 ror p1hi
 ror p1lo
 ldx #0
 rts

lc_commit_q4:''')

    # Third isolated step: store the already-loaded Q4 components directly.
    # lc_round_q4 preserves Y, and the caller reloads Y from tmpidx afterwards.
    start=source.index('lc_commit_q4:\n');end=source.index('lc_project_x:\n',start)
    code=source[start:end].replace('lc_commit_q4:\n','lc_commit_q4:\n ldy tmpidx\n',1)
    for axis in 'xyz':
        for suffix,offset in [('lo',''),('hi','+1')]:
            hook=' sta lc_q'+axis+offset+'\n'
            assert code.count(hook)==1
            code=code.replace(hook,hook+' sta lpn_'+axis+suffix+',y\n',1)
    source=source[:start]+code+source[end:]
    replace('etpv_mark_valid:\n.if EXPLORER_NEAR_POLY != 0\n lda vzrawhi,y\n bmi lp_depth_invalid\n bne lp_depth_valid\n lda vzrawlo,y\n cmp #CAMERA_FACE_MIN_DEPTH',
            'etpv_mark_valid:\n.if EXPLORER_NEAR_POLY != 0\n lda lpn_zhi,y\n bmi lp_depth_invalid\n bne lp_depth_valid\n lda lpn_zlo,y\n cmp #(CAMERA_FACE_MIN_DEPTH * 16)')

    start=source.index('near_project_intersection:\n')
    end=source.index('near_depth_byte:\n',start)
    code=source[start:end]
    # Ratios and interpolated coordinates retain the native Q4 camera scale.
    for axis in 'xyz':
        code=code.replace('v'+axis+'rawlo','lpn_'+axis+'lo').replace('v'+axis+'rawhi','lpn_'+axis+'hi')
    code=code.replace('lda #CAMERA_FACE_MIN_DEPTH','lda #(CAMERA_FACE_MIN_DEPTH * 16)')
    assert code.count(' jsr clip_ratio_to_scale8\n')==1
    assert code.count(' jsr mul_s16_u8_frac\n')==2
    code=code.replace(' jsr clip_ratio_to_scale8\n',' jsr lpn_ratio_nearest\n')
    code=code.replace(' jsr mul_s16_u8_frac\n',' jsr lpn_mul_nearest\n')
    source=source[:start]+code+source[end:]

    # Reuse the engine's existing signed product, rounding its absolute
    # discarded remainder once before restoring the original sign.
    start=source.index('mul_s16_u8_frac:\n')
    end=source.index('ms16u8_done:\n',start)+len('ms16u8_done:\n rts\n')
    multiply=source[start:end].replace('mul_s16_u8_frac','lpn_mul_nearest').replace('ms16u8_','lpn_mul_')
    old=' lda prodhi\n sta p1lo\n lda mul16reslo\n sta p1hi'
    assert multiply.count(old)==1
    multiply=multiply.replace(old,''' clc
 lda prodlo
 adc #$80
 lda prodhi
 adc #$00
 sta p1lo
 lda mul16reslo
 adc #$00
 sta p1hi''')
    helpers='''
; Plus-only Q4 near cache. No new zero-page storage or original-buffer ABI.
lpn_helpers_begin:
lpn_ratio_nearest:
 jsr clip_ratio_to_scale8
 ; That divider leaves the unsigned remainder in prodhi:prodlo.
 ; Round the 8-bit interpolation weight, saturating instead of wrapping.
 lda scalev
 cmp #$ff
 beq lpn_ratio_done
 sec
 lda clip_den16_lo
 sbc prodlo
 sta p1lo
 lda clip_den16_hi
 sbc prodhi
 sta p1hi
 lda prodhi
 cmp p1hi
 bcc lpn_ratio_done
 bne lpn_ratio_up
 lda prodlo
 cmp p1lo
 bcc lpn_ratio_done
lpn_ratio_up:
 inc scalev
lpn_ratio_done:
 rts

'''+multiply+'''
lpn_xlo: .fill VERT_COUNT,0
lpn_xhi: .fill VERT_COUNT,0
lpn_ylo: .fill VERT_COUNT,0
lpn_yhi: .fill VERT_COUNT,0
lpn_zlo: .fill VERT_COUNT,0
lpn_zhi: .fill VERT_COUNT,0
lpn_helpers_end:
.cerror * > $d000,"Plus Q4 near cache overlaps IO; reduce scene size"
; LEGACY_PLUS_NEAR_Q4=1
'''
    return source+helpers


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('asm',type=Path)
    args=parser.parse_args()
    args.asm.write_text(patch(args.asm.read_text(encoding='utf-8-sig')),encoding='ascii')


if __name__=='__main__':
    main()
