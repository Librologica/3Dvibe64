"""Demo-only integer geometry / exact constant-texel fast path.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. Public generator remains unchanged.
"""
import re


def once(s,old,new):
    assert s.count(old)==1,(old,s.count(old))
    return s.replace(old,new)


UNIFORM='''iu_select_surface:
 ; X is the scene texture id. Texture 2 is provably all texel 2.
 ; Patch only main-thread call sites, between faces. IRQ never calls fill.
 cpx #2
 beq iu_select_uniform
 lda #$20
 sta m7_sample
 lda #<ps_sample
 sta m7_sample+1
 lda #>ps_sample
 sta m7_sample+2
 lda #<ps_advance
 sta m7_advance+1
 lda #>ps_advance
 sta m7_advance+2
 lda #<ps_prepare_span
 sta m7_prepare_span+1
 lda #>ps_prepare_span
 sta m7_prepare_span+2
 rts
iu_select_uniform:
 lda #$4c
 sta m7_sample
 lda #<iu_sample_uniform
 sta m7_sample+1
 lda #>iu_sample_uniform
 sta m7_sample+2
 lda #<iu_advance_uniform
 sta m7_advance+1
 lda #>iu_advance_uniform
 sta m7_advance+2
 lda #<iu_prepare_uniform
 sta m7_prepare_span+1
 lda #>iu_prepare_uniform
 sta m7_prepare_span+2
 rts
iu_sample_uniform:
 lda #2
 jmp m3_composite
iu_advance_uniform:
 jsr m3_advance_q
 inc gouraud_scan_x
 rts
iu_prepare_uniform:
 jsr m3_prepare_span
 lda yrow
 and #3
 asl
 asl
 sta m2_bayer_row
 lda leftval
 sta gouraud_scan_x
 lda rightval
 sta gouraud_scan_end
 ldx yrow
 lda tq_closed,x
 bne iu_span_closed
 dec gouraud_scan_end
iu_span_closed:
 rts
'''


def camera():
    s='qc_rotate_vertices:\n'
    for angle,prefix in [('yaw','y'),('pitch','p')]:
        s+=f''' lda #0
 sec
 sbc explorer_cam_{angle}
 tax
 lda sintab,x
 sta iu_{prefix}s
 txa
 clc
 adc #64
 tax
 lda sintab,x
 sta iu_{prefix}c
'''
    s+=' lda active_vfirst\n sta qc_index\niu_vertex:\n ldy qc_index\n'
    for ax in 'xyz':
        # Integer camera-space coordinates. Camera simulation remains fractional.
        s+=f' lda hc_cam_{ax}1,y\n sta qc_{ax}+1\n lda hc_cam_{ax}2,y\n sta qc_{ax}+2\n'
    def term(ax,trig,dst):
        return f' lda qc_{ax}+1\n sta p1lo\n lda qc_{ax}+2\n sta p1hi\n lda iu_{trig}\n jsr camera_plane_mul_s16_s6\n lda p1lo\n sta {dst}+1\n lda p1hi\n sta {dst}+2\n'
    def combine(a,b,dst,subtract=False):
        op='sbc' if subtract else 'adc'
        return f' {"sec" if subtract else "clc"}\n lda {a}+1\n {op} {b}+1\n sta {dst}+1\n lda {a}+2\n {op} {b}+2\n sta {dst}+2\n'
    s+=term('x','yc','qc_t0')+term('z','ys','qc_t1')+combine('qc_t0','qc_t1','qc_tx',True)
    s+=term('x','ys','qc_t0')+term('z','yc','qc_t1')+combine('qc_t0','qc_t1','qc_z')
    s+=term('y','pc','qc_t0')+term('z','ps','qc_t1')+combine('qc_t0','qc_t1','qc_ty',True)
    s+=term('y','ps','qc_t0')+term('z','pc','qc_t1')+combine('qc_t0','qc_t1','qc_z')
    s+=' ldy qc_index\n'
    for ax,cache in zip('xyz',('rxbuf','rybuf','sz')):
        src={'x':'qc_tx','y':'qc_ty','z':'qc_z'}[ax]
        s+=f' lda #0\n sta hc_cam_{ax}0,y\n lda {src}+1\n sta hc_cam_{ax}1,y\n sta v{ax}rawlo,y\n sta {cache},y\n lda {src}+2\n sta hc_cam_{ax}2,y\n sta v{ax}rawhi,y\n'
        if ax=='z':s+=' sta szhi,y\n'
    s+=' inc qc_index\n lda qc_index\n cmp active_vend\n beq iu_vertex_done\n jmp iu_vertex\niu_vertex_done:\n rts\n'
    s+='iu_ys: .byte 0\niu_yc: .byte 0\niu_ps: .byte 0\niu_pc: .byte 0\n'
    return s


PROJECT='''hc_project_axis:
 ; Bounded scene coordinates: |integer coordinate| < 256.
 ; Floor magnitude, multiply by focal 119/2, unsigned 16/16 divide.
 lda hc_coord+2
 sta hc_sign
 bpl iu_abs_done
 sec
 lda #0
 sbc hc_coord
 sta hc_coord
 lda #0
 sbc hc_coord+1
 sta hc_coord+1
 lda #0
 sbc hc_coord+2
 sta hc_coord+2
iu_abs_done:
 lda hc_coord+1
 sta iu_magnitude
 sta prodlo
 lda #0
 sta prodhi
 ldx #7
iu_times128:
 asl prodlo
 rol prodhi
 dex
 bne iu_times128
 lda iu_magnitude
 sta hc_value
 lda #0
 sta hc_value+1
 ldx #3
iu_times8:
 asl hc_value
 rol hc_value+1
 dex
 bne iu_times8
 sec
 lda prodlo
 sbc hc_value
 sta prodlo
 lda prodhi
 sbc hc_value+1
 sta prodhi
 sec
 lda prodlo
 sbc iu_magnitude
 sta prodlo
 lda prodhi
 sbc #0
 sta prodhi
 lda hc_depth+1
 sta p1lo
 lda hc_depth+2
 sta p1hi
 asl p1lo
 rol p1hi
 jsr div16u
 lda hc_axis
 beq iu_projection_sign
 lda hc_sign
 eor #128
 sta hc_sign
iu_projection_sign:
 lda hc_sign
 bpl iu_projection_center
 sec
 lda #0
 sbc prodlo
 sta prodlo
 lda #0
 sbc prodhi
 sta prodhi
iu_projection_center:
 ldx hc_axis
 clc
 lda prodlo
 adc hc_centers,x
 sta hc_integer
 sta tq_full+1
 sta hc_q
 lda prodhi
 adc #0
 sta hc_integer+1
 sta tq_full+2
 sta hc_q+1
 lda #0
 sta tq_full
 sta hq_residue
 asl hc_q
 rol hc_q+1
 asl hc_q
 rol hc_q+1
 rts
iu_magnitude: .byte 0
'''


def adapt(source,parts,placed,integer=True,uniform=True):
    if uniform:
        assert 'm7_sample:\n jsr ps_sample\n' in source
        source=once(source,' sta m7_fetch+2\n',' sta m7_fetch+2\n jsr iu_select_surface\n')
    if placed is not None:return source,parts
    if uniform:parts['iu_uniform']=UNIFORM
    if integer:
        p=parts['projection'];start=p.index('hc_project_axis:\n');end=p.index('hc_centers:',start)
        parts['projection']=p[:start]+PROJECT+p[end:]
        parts['camera_yaw']=camera()
        # The previous camera math is now unreachable. Keep only state labels
        # used by other clipping/helpers, not its expensive Q8 product routine.
        p=parts['screen_precision'];start=p.index('hq_quantize_poly:\n')
        assert p[start:].endswith(' rts\n')
        s='hq_quantize_poly:\n ldx #0\niu_quantize_loop:\n'
        for ax in 'xy':
            s+=f' lda hc_a_{ax}hi,x\n sta hc_a_{ax}lo,x\n lda #0\n sta hc_a_{ax}hi,x\n'
            for _ in range(2):s+=f' asl hc_a_{ax}lo,x\n rol hc_a_{ax}hi,x\n'
        s+=' inx\n cpx hc_count\n bne iu_quantize_loop\n rts\n'
        parts['screen_precision']=p[:start]+s
    return source,parts
