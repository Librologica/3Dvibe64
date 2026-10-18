"""Clip near polygons in screen Q4 before integer raster conversion.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import argparse,re
from pathlib import Path


def patch(source):
    if 'lpn_helpers_begin:' not in source:return source
    def replace(old,new,label=None):
        nonlocal source
        if label:
            a=source.index(label+':\n');b=source.index('\n rts',a)+len('\n rts')
            code=source[a:b];assert code.count(old)==1,(label,old[:100])
            source=source[:a]+code.replace(old,new,1)+source[b:]
        else:
            assert source.count(old)==1,old[:100]
            source=source.replace(old,new,1)
    def block(label,next_label):
        a=source.index(label+':\n');b=source.index(next_label+':',a)
        return a,b,source[a:b]
    # More accurate interpolation weights, while coordinates remain Q4.
    a,b,_=block('lpn_ratio_nearest','lpn_mul_nearest')
    source=source[:a]+'''lpn_ratio_nearest:
 lda clip_num16_lo
 sta prodlo
 lda clip_num16_hi
 sta prodhi
 lda #0
 sta clip_rem_ext
 sta lps_weightlo
 sta lps_weighthi
 lda clip_num16_hi
 cmp clip_den16_hi
 bcc lps_ratio_fraction
 bne lps_ratio_max
 lda clip_num16_lo
 cmp clip_den16_lo
 bcc lps_ratio_fraction
lps_ratio_max:
 lda #$ff
 sta lps_weightlo
 sta lps_weighthi
 rts
lps_ratio_fraction:
 ldx #16
lps_ratio_loop:
 asl prodlo
 rol prodhi
 lda #0
 rol clip_rem_ext
 lda clip_rem_ext
 bne lps_ratio_sub
 lda prodhi
 cmp clip_den16_hi
 bcc lps_ratio_no_sub
 bne lps_ratio_sub
 lda prodlo
 cmp clip_den16_lo
 bcc lps_ratio_no_sub
lps_ratio_sub:
 sec
 lda prodlo
 sbc clip_den16_lo
 sta prodlo
 lda prodhi
 sbc clip_den16_hi
 sta prodhi
 lda clip_rem_ext
 sbc #0
 sta clip_rem_ext
 sec
 jmp lps_ratio_shift
lps_ratio_no_sub:
 clc
lps_ratio_shift:
 rol lps_weightlo
 rol lps_weighthi
 dex
 bne lps_ratio_loop
 rts

'''+source[b:]
    a,b,_=block('lpn_mul_nearest','lpn_xlo')
    source=source[:a]+'''lpn_mul_nearest:
 lda #0
 sta mul16sign
 lda p1hi
 bpl lps_mul_abs
 sec
 lda #0
 sbc p1lo
 sta p1lo
 lda #0
 sbc p1hi
 sta p1hi
 lda #$80
 sta mul16sign
lps_mul_abs:
 lda p1lo
 sta mul16lo
 lda p1hi
 sta mul16hi
 lda lps_weightlo
 sta lps_mwlo
 lda lps_weighthi
 sta lps_mwhi
 lda #0
 sta mul16rem
 sta lps_mc3
 sta prodlo
 sta prodhi
 sta mul16reslo
 sta mul16reshi
 ldx #16
lps_mul_loop:
 lsr lps_mwhi
 ror lps_mwlo
 bcc lps_mul_skip
 clc
 lda prodlo
 adc mul16lo
 sta prodlo
 lda prodhi
 adc mul16hi
 sta prodhi
 lda mul16reslo
 adc mul16rem
 sta mul16reslo
 lda mul16reshi
 adc lps_mc3
 sta mul16reshi
lps_mul_skip:
 asl mul16lo
 rol mul16hi
 rol mul16rem
 rol lps_mc3
 dex
 bne lps_mul_loop
 clc
 lda prodhi
 adc #$80
 lda mul16reslo
 adc #0
 sta p1lo
 lda mul16reshi
 adc #0
 sta p1hi
 lda mul16sign
 bpl lps_mul_done
 sec
 lda #0
 sbc p1lo
 sta p1lo
 lda #0
 sbc p1hi
 sta p1hi
lps_mul_done:
 rts

'''+source[b:]
    # All near-polygon camera coordinates share Q4; existing integer geometry
    # buffers and the projection of ordinary mesh vertices are unchanged.
    a,b,code=block('near_append_current_vertex','near_append_intersection')
    for axis in 'xyz':
        code=code.replace('v'+axis+'rawlo','lpn_'+axis+'lo').replace('v'+axis+'rawhi','lpn_'+axis+'hi')
    source=source[:a]+code+source[b:]
    a,b,code=block('near_project_intersection','near_interp_x_to_t1')
    code=code.replace(' ldx clip_a_count\n jsr clip_project_a_x_from_camera\n ldx clip_a_count\n jsr clip_project_a_y_from_camera\n','')
    source=source[:a]+code+source[b:]
    a,b,code=block('clip_loaded_face_near_poly','cln_done')
    assert code.count(' jsr clip_poly_clip_screen_current')==1
    source=source[:a]+code.replace(' jsr clip_poly_clip_screen_current',' jsr lps_near_screen')+source[b:]
    # Reuse the native Sutherland-Hodgman stages with dynamic 16-bit bounds.
    # Bounds default to integer pixels and are changed only around near clips.
    for label,buf,axis,bound,yes,no in [
        ('clip_a_right_inside','a','x','x','cari_yes','cari_no'),
        ('clip_b_bottom_inside','b','y','y','cbbi_yes','cbbi_no')]:
        start=source.index(label+':\n');end=source.index(no+':\n',start)
        source=source[:start]+f'''{label}:
 lda clip_{buf}_{axis}hi,x
 bmi {yes}
 cmp lps_bound_{bound}+1
 bcc {yes}
 bne {no}
 lda clip_{buf}_{axis}lo,x
 cmp lps_bound_{bound}
 bcc {yes}
 beq {yes}
 bne {no}
{yes}:
 lda #1
 rts
'''+source[end:]
    replace(' lda #PROJ_SCREEN_MAX_X\n sta clip_b_x,y\n sta clip_b_xlo,y\n lda #PROJ_SCREEN_MIN_X\n sta clip_b_xhi,y',
            ' lda #PROJ_SCREEN_MAX_X\n sta clip_b_x,y\n lda lps_bound_x\n sta clip_b_xlo,y\n lda lps_bound_x+1\n sta clip_b_xhi,y','clip_append_right_intersection_a_to_b')
    replace(' lda #PROJ_SCREEN_MAX_Y\n sta clip_a_y,y\n sta clip_a_ylo,y\n lda #PROJ_SCREEN_MIN_Y\n sta clip_a_yhi,y',
            ' lda #PROJ_SCREEN_MAX_Y\n sta clip_a_y,y\n lda lps_bound_y\n sta clip_a_ylo,y\n lda lps_bound_y+1\n sta clip_a_yhi,y','clip_append_bottom_intersection_b_to_a')
    for label,next_label,bound in [('clip_load_inside_right_a','clip_load_outside_right_a','x'),('clip_load_inside_bottom_b','clip_load_outside_bottom_b','y')]:
        a,b,code=block(label,next_label)
        code=code.replace('lda #PROJ_SCREEN_MAX_'+bound.upper(),'lda lps_bound_'+bound)
        code=code.replace(' lda #$00\n sbc clip_axis_in_hi',' lda lps_bound_'+bound+'+1\n sbc clip_axis_in_hi')
        source=source[:a]+code+source[b:]
    replace(' jsr clip_poly_compact_screen_a\n',' jsr lps_to_pixels\n jsr clip_poly_compact_screen_a\n')
    helpers='''
lps_helpers_begin:
lps_near_screen:
 lda #0
 sta lps_wide
 sta clip_cur_idx
lps_project_loop:
 ldx clip_cur_idx
 lda clip_a_vzlo,x
 sta p1lo
 lda clip_a_vzhi,x
 sta p1hi
 lda clip_a_vxlo,x
 sta mul16lo
 lda clip_a_vxhi,x
 sta mul16hi
 jsr lps_project_offset
 clc
 lda mul16reslo
 adc #<(PROJ_CENTER_X * 16)
 ldx clip_cur_idx
 sta clip_a_xlo,x
 lda mul16reshi
 adc #>(PROJ_CENTER_X * 16)
 sta clip_a_xhi,x
 lda clip_a_vzlo,x
 sta p1lo
 lda clip_a_vzhi,x
 sta p1hi
 lda clip_a_vylo,x
 sta mul16lo
 lda clip_a_vyhi,x
 sta mul16hi
 jsr lps_project_offset
 sec
 lda #<(PROJ_CENTER_Y * 16)
 sbc mul16reslo
 ldx clip_cur_idx
 sta clip_a_ylo,x
 lda #>(PROJ_CENTER_Y * 16)
 sbc mul16reshi
 sta clip_a_yhi,x
 inc clip_cur_idx
 lda clip_cur_idx
 cmp clip_a_count
 bne lps_project_loop
 lda lps_wide
 beq lps_project_fits
 ; Preserve the old wide-projection range when screen Q4 cannot fit.
 jsr clip_poly_project_a_from_camera
 jmp clip_poly_clip_screen_current
lps_project_fits:
 lda #1
 sta lps_active
 lda #<(PROJ_SCREEN_MAX_X * 16)
 sta lps_bound_x
 lda #>(PROJ_SCREEN_MAX_X * 16)
 sta lps_bound_x+1
 lda #<(PROJ_SCREEN_MAX_Y * 16)
 sta lps_bound_y
 lda #>(PROJ_SCREEN_MAX_Y * 16)
 sta lps_bound_y+1
 jsr clip_poly_clip_screen_current
 lda #0
 sta lps_active
 sta lps_bound_x+1
 sta lps_bound_y+1
 lda #PROJ_SCREEN_MAX_X
 sta lps_bound_x
 lda #PROJ_SCREEN_MAX_Y
 sta lps_bound_y
 rts

; Signed Q4 coordinate / positive Q4 depth -> signed Q4 screen offset.
; Full 32-bit numerator and native integer division, no Q8 coordinates.
lps_project_offset:
 lda #0
 sta mul16sign
 lda mul16hi
 bpl lps_proj_abs
 sec
 lda #0
 sbc mul16lo
 sta mul16lo
 lda #0
 sbc mul16hi
 sta mul16hi
 lda #$80
 sta mul16sign
lps_proj_abs:
 lda #0
 sta mul16rem
 sta prodlo
 sta prodhi
 sta lps_prod2
 sta lps_prod3
 lda #EXPLORER_PROJ_FOCAL
 sta mul16mul
 ldx #8
lps_proj_mul:
 lsr mul16mul
 bcc lps_proj_mul_skip
 clc
 lda prodlo
 adc mul16lo
 sta prodlo
 lda prodhi
 adc mul16hi
 sta prodhi
 lda lps_prod2
 adc mul16rem
 sta lps_prod2
lps_proj_mul_skip:
 asl mul16lo
 rol mul16hi
 rol mul16rem
 dex
 bne lps_proj_mul
 ldx #4
lps_proj_fraction:
 asl prodlo
 rol prodhi
 rol lps_prod2
 rol lps_prod3
 dex
 bne lps_proj_fraction
 lda #0
 sta lps_remlo
 sta lps_remhi
 ldx #32
lps_proj_div:
 asl prodlo
 rol prodhi
 rol lps_prod2
 rol lps_prod3
 rol lps_remlo
 rol lps_remhi
 bcs lps_proj_sub
 lda lps_remhi
 cmp p1hi
 bcc lps_proj_div_next
 bne lps_proj_sub
 lda lps_remlo
 cmp p1lo
 bcc lps_proj_div_next
lps_proj_sub:
 sec
 lda lps_remlo
 sbc p1lo
 sta lps_remlo
 lda lps_remhi
 sbc p1hi
 sta lps_remhi
 inc prodlo
lps_proj_div_next:
 dex
 bne lps_proj_div
 lda lps_prod2
 ora lps_prod3
 bne lps_proj_wide
 lda prodhi
 ; Keep both signed coordinate spans below32768 for the reused native
 ; signed16 interpolation: each absolute offset < $3a00 implies total
 ; span <= 2*$39ff =29694. Center offsets cancel in differences.
 cmp #$3a
 bcc lps_proj_sign
lps_proj_wide:
 lda #1
 sta lps_wide
 lda #0
 sta prodlo
 sta prodhi
lps_proj_sign:
 lda prodlo
 sta mul16reslo
 lda prodhi
 sta mul16reshi
 lda mul16sign
 bpl lps_proj_done
 sec
 lda #0
 sbc mul16reslo
 sta mul16reslo
 lda #0
 sbc mul16reshi
 sta mul16reshi
lps_proj_done:
 rts

lps_to_pixels:
 lda lps_active
 beq lps_pixels_done
 ldx #0
lps_pixels_loop:
 lda clip_a_xlo,x
 sta p1lo
 lda clip_a_xhi,x
 sta p1hi
 jsr lps_shift_pixel
 lda p1lo
 sta clip_a_x,x
 lda clip_a_ylo,x
 sta p1lo
 lda clip_a_yhi,x
 sta p1hi
 jsr lps_shift_pixel
 lda p1lo
 sta clip_a_y,x
 inx
 cpx clip_a_count
 bne lps_pixels_loop
lps_pixels_done:
 rts
lps_shift_pixel:
 ldy #4
lps_shift_loop:
 lsr p1hi
 ror p1lo
 dey
 bne lps_shift_loop
 rts

lps_weightlo: .byte 0
lps_weighthi: .byte 0
lps_mwlo: .byte 0
lps_mwhi: .byte 0
lps_mc3: .byte 0
lps_prod2: .byte 0
lps_prod3: .byte 0
lps_remlo: .byte 0
lps_remhi: .byte 0
lps_bound_x: .word PROJ_SCREEN_MAX_X
lps_bound_y: .word PROJ_SCREEN_MAX_Y
lps_active: .byte 0
lps_wide: .byte 0
lps_helpers_end:
.cerror * > $d000,"Plus subpixel near helpers overlap IO; reduce scene size"
; LEGACY_PLUS_NEAR_SCREEN_Q4=1
'''
    return source+helpers


def main():
    p=argparse.ArgumentParser();p.add_argument('asm',type=Path);a=p.parse_args()
    a.asm.write_text(patch(a.asm.read_text(encoding='utf-8-sig')),encoding='ascii')
if __name__=='__main__':main()
