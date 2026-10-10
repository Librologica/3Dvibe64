"""Normalized16 homogeneous geometry, experimental Mode1..7 test adapter.
Copyright 2026 librologica.digital. PolyForm Noncommercial 1.0.0.
Q8 matrix/trig setup and Q2 raster ABI reused; no old wide projector/clip.
"""
from pathlib import Path

def copy(a,b,n=2):return ''.join(f' lda {a}+{i}\n sta {b}+{i}\n' for i in range(n))
def load(n,d):return f' lda #<{n&65535}\n sta {d}\n lda #>{n&65535}\n sta {d}+1\n'
def add(a,b,d,n=2,sub=False):return (' sec\n' if sub else ' clc\n')+''.join(f' lda {a}+{i}\n {"sbc" if sub else "adc"} {b}+{i}\n sta {d}+{i}\n' for i in range(n))
def product(a,b,d):return copy(a,'hp_a')+copy(b,'hp_b')+' jsr hp_q8\n'+copy('hp_r',d)
def ash(a,n):return f' lda {a}+{n-1}\n cmp #$80\n ror {a}+{n-1}\n'+''.join(f' ror {a}+{i}\n' for i in reversed(range(n-1)))
def negate(a,n):return ' sec\n'+''.join(f' lda #0\n sbc {a}+{i}\n sta {a}+{i}\n' for i in range(n))

def make_parts(p,lab=None):
    p=p.copy()
    mode=lab['GRAPHICS_MODE'] if lab else 4
    # Only shared coefficient setup math remains, not old camera/project/clip.
    arith=p['core'][p['core'].index('hp_mul:'):]
    p['core']='''explorer_transform_project_vertices:
 lda #0
 sta hp_fault
 jsr hp_origins
 jsr nf_normalize_origin
 lda hp_fault
 bne nf_failed
 jsr hp_prepare_matrix
 jsr nf_camera_matrix
 jsr hp_prepare_terms
 jsr nf_vertices
 rts
nf_failed:
 ldx active_vfirst
 lda #0
-
 sta projdone,x
 inx
 cpx active_vend
 bne -
 rts
hp_unreachable:
 brk
 jmp hp_unreachable
'''+arith
    v=p['vertices'].split('hp_build_vertices:')[0]
    a=v.index('hp_origins:');b=v.index('hp_origin_supported:')
    v=v[:a]+'hp_origins:\n'+v[b:]
    p['vertices']=v+origin(lab['CAMERA_FACE_MIN_DEPTH'] if lab else 8)
    p['normalized_matrix']=matrix()
    p['normalized_vertices']=vertices()
    p['normalized_math']=math_code()
    p['normalized_planes']=planes()
    p['projection']=projection()
    p['clip']=loader()
    p['normalized_intersection']=intersection()
    # Reuse ONLY output ABI, winding and raster; no screen clipping arithmetic.
    old=(Path(__file__).parent/'clip.asm').read_text()
    p['clip_helpers']=old[old.index('hc_commit_poly:'):]
    # hc_load_fast_face is a register/layout copy, no geometry operation.
    helpers=p.get('screen_precision','')
    del p['screen_precision']
    for key in ('camera_math','camera_yaw','camera_pitch','camera_trig_y','camera_trig_z'):
        p.pop(key,None)
    p['normalized_data']=state()
    values=[(680*32768+(512+i)//2)//(512+i) for i in range(512)]
    p['reciprocal_lut']='nf_reciprocal:\n'+''.join(' .word '+','.join(str(v) for v in values[i:i+8])+'\n' for i in range(0,512,8))
    if mode!=4:
        from nf_modes import extend
        p=extend(p,lab)
    return p

def origin(near=8):
    s='nf_normalize_origin:\n lda #0\n sta nf_exp\n'
    for ax in 'xyz':
        s+=copy('hc_origin_'+ax,'nf_o'+ax,3)+' ldx #4\n-\n'+ash('nf_o'+ax,3)+' dex\n bne -\n'
    s+='nf_origin_check:\n'
    for ax in 'xyz':
        s+=copy('nf_o'+ax,'nf_sum',3)+f' lda nf_sum+2\n bpl +\n'+negate('nf_sum',3)+'+\n lda nf_sum+2\n bne nf_origin_reduce\n lda nf_sum+1\n cmp #$30\n bcs nf_origin_reduce\n'
    s+=' lda #4\n clc\n adc nf_exp\n sta nf_shift\n jsr nf_set_near\n rts\nnf_origin_reduce:\n inc nf_exp\n lda nf_exp\n cmp #5\n bcs nf_origin_fault\n'
    for ax in 'xyz':s+=ash('nf_o'+ax,3)
    s+=' jmp nf_origin_check\nnf_origin_fault:\n inc hp_fault\n rts\nnf_set_near:\n'+load(near*16,'nf_near')+' ldx nf_exp\n beq +\n-\n lsr nf_near+1\n ror nf_near\n dex\n bne -\n+\n rts\n'
    return s

def matrix():
    s='nf_camera_matrix:\n'
    for angle,prefix in [('yaw','y'),('pitch','p')]:
        s+=f' lda #0\n sec\n sbc explorer_cam_{angle}\n tax\n'
        for kind in 'sc':
            if kind=='c':s+=' txa\n clc\n adc #64\n tax\n'
            s+=f' lda hp_sin_lo,x\n sta nf_{prefix}{kind}\n lda hp_sin_hi,x\n sta nf_{prefix}{kind}+1\n'
    # Rotate normalized origin once, not every vertex.
    s+=product('nf_ox','nf_yc','nf_t0')+product('nf_oz','nf_ys','nf_t1')+add('nf_t0','nf_t1','nf_tx',sub=True)
    s+=product('nf_ox','nf_ys','nf_t0')+product('nf_oz','nf_yc','nf_t1')+add('nf_t0','nf_t1','nf_oz')+copy('nf_tx','nf_ox')
    s+=product('nf_oy','nf_pc','nf_t0')+product('nf_oz','nf_ps','nf_t1')+add('nf_t0','nf_t1','nf_ty',sub=True)
    s+=product('nf_oy','nf_ps','nf_t0')+product('nf_oz','nf_pc','nf_t1')+add('nf_t0','nf_t1','nf_oz')+copy('nf_ty','nf_oy')
    # Fold view into object coefficient matrix before generating exact terms.
    for j in range(3):
        s+=product(f'hp_m0{j}','nf_yc','nf_t0')+product(f'hp_m2{j}','nf_ys','nf_t1')+add('nf_t0','nf_t1',f'nf_m0{j}',sub=True)
        s+=product(f'hp_m0{j}','nf_ys','nf_t0')+product(f'hp_m2{j}','nf_yc','nf_t1')+add('nf_t0','nf_t1',f'nf_m2{j}')
        s+=product(f'hp_m1{j}','nf_pc','nf_t0')+product(f'nf_m2{j}','nf_ps','nf_t1')+add('nf_t0','nf_t1',f'nf_m1{j}',sub=True)
        s+=product(f'hp_m1{j}','nf_ps','nf_t0')+product(f'nf_m2{j}','nf_pc','nf_t1')+add('nf_t0','nf_t1',f'nf_m2{j}')
    for i in range(3):
        for j in range(3):s+=copy(f'nf_m{i}{j}',f'hp_m{i}{j}')
    return s+' rts\n'

def vertices():
    s='nf_vertices:\n lda active_vfirst\n sta hp_idx\nnf_vertex_loop:\n'
    for i,ax in enumerate('xyz'):
        s+=' lda #0\n sta nf_sum\n sta nf_sum+1\n sta nf_sum+2\n'
        for j,a in enumerate('xyz'):
            s+=f' ldy hp_idx\n ldx vert_{a}i,y\n lda hp_term{i}{j}_hi,x\n asl\n lda #0\n sbc #0\n eor #$ff\n sta nf_ext\n clc\n'
            s+=f' lda nf_sum\n adc hp_term{i}{j}_lo,x\n sta nf_sum\n lda nf_sum+1\n adc hp_term{i}{j}_hi,x\n sta nf_sum+1\n lda nf_sum+2\n adc nf_ext\n sta nf_sum+2\n'
        s+=' ldx nf_shift\n-\n'+ash('nf_sum',3)+' dex\n bne -\n'+add('nf_sum','nf_o'+ax,'nf_p'+ax)
        s+=f' ldy hp_idx\n lda nf_p{ax}\n sta nf_v{ax}lo,y\n lda nf_p{ax}+1\n sta nf_v{ax}hi,y\n'
        # Expand only ABI diagnostic/depth caches, not geometry computation.
        s+=copy('nf_p'+ax,'nf_sum')+' lda nf_sum+1\n asl\n lda #0\n sbc #0\n eor #$ff\n sta nf_sum+2\n ldx nf_shift\n-\n asl nf_sum\n rol nf_sum+1\n rol nf_sum+2\n dex\n bne -\n ldy hp_idx\n'
        for k in range(3):s+=f' lda nf_sum+{k}\n sta hc_cam_{ax}{k},y\n'
        s+=f' lda nf_sum+1\n sta v{ax}rawlo,y\n sta '+dict(x='rxbuf',y='rybuf',z='sz')[ax]+',y\n'+f' lda nf_sum+2\n sta v{ax}rawhi,y\n'
        if ax=='z':s+=' sta szhi,y\n'
    s+=' ldy hp_idx\n lda nf_exp\n sta nf_vertex_exp,y\n sec\n lda nf_pz\n sbc nf_near\n lda nf_pz+1\n sbc nf_near+1\n bmi nf_vertex_behind\n lda #1\n sta projdone,y\n jsr nf_prepare_reciprocal\n'
    for axis,ax in enumerate('xy'):
        s+=copy('nf_p'+ax,'nf_coord')+f' lda #{axis}\n sta hc_axis\n jsr nf_project\n ldy hp_idx\n lda hc_q\n sta s{ax}q2_lo,y\n lda hc_q+1\n sta s{ax}q2_hi,y\n lda hc_integer\n sta p{ax}rawlo,y\n lda hc_integer+1\n sta p{ax}rawhi,y\n jsr hc_clamp_integer\n ldy hp_idx\n sta s{ax},y\n'
    s+=' jsr nf_fast_classify\n ldy hp_idx\n lda nf_code\n sta nf_outcodes,y\n jmp nf_vertex_next\nnf_vertex_behind:\n lda #0\n sta projdone,y\n sta sx,y\n sta sy,y\n sta sxq2_lo,y\n sta sxq2_hi,y\n sta syq2_lo,y\n sta syq2_hi,y\n jsr nf_classify\n ldy hp_idx\n lda nf_code\n sta nf_outcodes,y\nnf_vertex_next:\n inc hp_idx\n lda hp_idx\n cmp active_vend\n bne nf_vertex_loop\n rts\n'
    return s

def math_code():
    s='''; Unsigned16 x unsigned16 -> unsigned32, no hardware extension.
nf_umultiply:
 lda #0
 sta nf_product
 sta nf_product+1
 sta nf_product+2
 sta nf_product+3
 sta nf_mulshift+2
 sta nf_mulshift+3
 lda nf_a
 sta nf_mulshift
 lda nf_a+1
 sta nf_mulshift+1
 jmp nf_mul_check
nf_mul_loop:
 lsr nf_b+1
 ror nf_b
 bcc nf_mul_next
'''+add('nf_product','nf_mulshift','nf_product',4)+'''nf_mul_next:
 asl nf_mulshift
 rol nf_mulshift+1
 rol nf_mulshift+2
 rol nf_mulshift+3
nf_mul_check:
 lda nf_b
 ora nf_b+1
 bne nf_mul_loop
 rts
nf_smultiply:
 lda nf_a+1
 eor nf_b+1
 sta nf_sign
 lda nf_a+1
 bpl +
'''+negate('nf_a',2)+'''+
 lda nf_b+1
 bpl +
'''+negate('nf_b',2)+'''+
 jsr nf_umultiply
 lda nf_sign
 bpl +
'''+negate('nf_product',4)+'''+
 rts
; Ratio floor(65536*factor/den), factor<den; 32-bit remainder.
nf_ratio:
 lda #0
 sta nf_ratio_value
 sta nf_ratio_value+1
 ldy #16
nf_ratio_loop:
 asl nf_ratio_value
 rol nf_ratio_value+1
 asl nf_rem
 rol nf_rem+1
 rol nf_rem+2
 rol nf_rem+3
'''
    for k in reversed(range(4)):
        s+=f' lda nf_rem+{k}\n cmp nf_den+{k}\n bcc nf_ratio_next\n bne nf_ratio_sub\n'
    s+='nf_ratio_sub:\n'+add('nf_rem','nf_den','nf_rem',4,True)+' inc nf_ratio_value\nnf_ratio_next:\n dey\n bne nf_ratio_loop\n rts\n'
    return s

def planes():
    s='''; Reciprocal relative error <=1/512 plus LUT rounding; one-pixel margin.
nf_fast_classify:
 ldy hp_idx
 lda sxq2_hi,y
 bmi nf_classify
 cmp #2
 bcc nf_fast_xlow
 bne nf_classify
 lda sxq2_lo,y
 cmp #121
 bcs nf_classify
nf_fast_xlow:
 lda sxq2_hi,y
 bne nf_fast_y
 lda sxq2_lo,y
 cmp #4
 bcc nf_classify
nf_fast_y:
 lda syq2_hi,y
 bmi nf_classify
 cmp #1
 bcc nf_fast_ylow
 bne nf_classify
 lda syq2_lo,y
 cmp #137
 bcs nf_classify
nf_fast_ylow:
 lda syq2_hi,y
 bne nf_fast_yes
 lda syq2_lo,y
 cmp #4
 bcc nf_classify
nf_fast_yes:
 lda #0
 sta nf_code
 rts
nf_classify:
 lda #0
 sta nf_code
 sta nf_plane
nf_classify_loop:
 jsr nf_distance
 lda nf_d+3
 bpl +
 ldx nf_plane
 lda nf_code
 ora nf_plane_bit,x
 sta nf_code
+
 inc nf_plane
 lda nf_plane
 cmp #5
 bne nf_classify_loop
 rts
nf_distance:
 lda nf_plane
 bne nf_distance_side
'''+add('nf_pz','nf_near','nf_d',2,True)+''' lda nf_d+1
 asl
 lda #0
 sbc #0
 eor #$ff
 sta nf_d+2
 sta nf_d+3
 rts
nf_distance_side:
 cmp #3
 bcs nf_distance_y
'''+copy('nf_px','nf_a')+''' jmp nf_distance_axis
nf_distance_y:
'''+copy('nf_py','nf_a')+'''nf_distance_axis:
 ldx nf_plane
 lda nf_slope_lo,x
 sta nf_b
 lda nf_slope_hi,x
 sta nf_b+1
 jsr nf_smultiply
'''+copy('nf_product','nf_d',4)+copy('nf_pz','nf_a')+''' ldx nf_plane
 lda nf_zcoef,x
 sta nf_b
 lda #0
 sta nf_b+1
 jsr nf_smultiply
'''+add('nf_d','nf_product','nf_d',4)+''' rts
nf_plane_bit: .byte 1,2,4,8,16
nf_slope_lo: .byte 0,<170,<(-170),<(-170),<170
nf_slope_hi: .byte 0,>170,>(-170),>(-170),>170
nf_zcoef: .byte 0,80,79,50,49
'''
    return s

def projection():
    return '''nf_prepare_reciprocal:
 lda nf_pz
 sta nf_mantissa
 lda nf_pz+1
 sta nf_mantissa+1
 lda #15
 sta nf_project_shift
nf_recip_small:
 lda nf_mantissa+1
 cmp #2
 bcs nf_recip_large
 asl nf_mantissa
 rol nf_mantissa+1
 dec nf_project_shift
 jmp nf_recip_small
nf_recip_large:
 lda nf_mantissa+1
 cmp #4
 bcc nf_recip_ready
 lsr nf_mantissa+1
 ror nf_mantissa
 inc nf_project_shift
 jmp nf_recip_large
nf_recip_ready:
 sec
 lda nf_mantissa+1
 sbc #2
 sta nf_lut_offset+1
 lda nf_mantissa
 sta nf_lut_offset
 asl nf_lut_offset
 rol nf_lut_offset+1
 clc
 lda nf_lut_offset
 adc #<nf_reciprocal
 sta p1lo
 lda nf_lut_offset+1
 adc #>nf_reciprocal
 sta p1hi
 ldy #0
 lda (p1lo),y
 sta nf_recip
 iny
 lda (p1lo),y
 sta nf_recip+1
 rts
nf_project:
 lda nf_coord+1
 sta nf_axis_sign
 bpl +
'''+negate('nf_coord',2)+'''+
'''+copy('nf_coord','nf_a')+copy('nf_recip','nf_b')+''' jsr nf_umultiply
 ldx nf_project_shift
-
 lsr nf_product+3
 ror nf_product+2
 ror nf_product+1
 ror nf_product
 dex
 bne -
 lda nf_product+3
 ora nf_product+2
 bne nf_projection_sat
 lda nf_product+1
 cmp #$3e
 bcc nf_projection_sign
nf_projection_sat:
 lda #$ff
 sta nf_product
 lda #$3d
 sta nf_product+1
nf_projection_sign:
 lda hc_axis
 beq +
 lda nf_axis_sign
 eor #$80
 sta nf_axis_sign
+
'''+copy('nf_product','hc_q')+''' lda nf_axis_sign
 bpl +
'''+negate('hc_q',2)+'''+
 ldx hc_axis
 clc
 lda hc_q
 adc hc_center_lo,x
 sta hc_q
 lda hc_q+1
 adc hc_center_hi,x
 sta hc_q+1
 lsr nf_product+1
 ror nf_product
 lsr nf_product+1
 ror nf_product
 lda nf_axis_sign
 bpl +
'''+negate('nf_product',2)+'''+
 ldx hc_axis
 clc
 lda nf_product
 adc hc_centers,x
 sta hc_integer
 lda nf_product+1
 adc #0
 sta hc_integer+1
 rts
hc_centers: .byte 80,50
hc_center_lo: .byte <320,<200
hc_center_hi: .byte >320,>200
hc_limits: .byte 159,99
hc_clamp_integer:
 lda hc_integer+1
 bmi nf_clamp_zero
 bne nf_clamp_limit
 ldx hc_axis
 lda hc_integer
 cmp hc_limits,x
 bcc +
nf_clamp_limit:
 ldx hc_axis
 lda hc_limits,x
+
 rts
nf_clamp_zero:
 lda #0
 rts
'''

def loader():
    s='''load_face_y:
 sty sortj
 lda #0
 sta nf_or
 sta nf_poly_index
 sta clip_poly_active
 lda #31
 sta nf_and
 lda face0,y
 sta hc_face_vertices
 lda face1,y
 sta hc_face_vertices+1
 lda face2,y
 sta hc_face_vertices+2
 lda face3,y
 sta hc_face_vertices+3
 lda #4
 sta hc_count
 sta nf_count
 sta loaded_face_vertex_count
nf_face_load:
 ldy nf_poly_index
 ldx hc_face_vertices,y
 lda nf_vertex_exp,x
 sta nf_exp
 lda nf_outcodes,x
 ora nf_or
 sta nf_or
 lda nf_outcodes,x
 and nf_and
 sta nf_and
'''
    for ax in 'xyz':
        for part in ('lo','hi'):s+=f' lda nf_v{ax}{part},x\n sta nf_a_{ax}{part},y\n'
    s+=' inc nf_poly_index\n lda nf_poly_index\n cmp #4\n bne nf_face_load\n lda hp_fault\n ora nf_and\n bne nf_face_empty\n jsr nf_set_near\n lda nf_or\n bne nf_clip_begin\n lda #0\n sta nf_poly_index\nnf_face_cached:\n ldy nf_poly_index\n ldx hc_face_vertices,y\n'
    for ax in 'xy':
        for part in ('lo','hi'):s+=f' lda s{ax}q2_{part},x\n sta hc_a_{ax}{part},y\n'
    s+=' inc nf_poly_index\n lda nf_poly_index\n cmp #4\n bne nf_face_cached\n jmp nf_face_finish\nnf_clip_begin:\n lda #1\n sta clip_poly_active\n lda #0\n sta nf_plane\nnf_clip_plane:\n jsr nf_clip_pass\n lda nf_count\n cmp #3\n bcc nf_face_empty\n inc nf_plane\n lda nf_plane\n cmp #5\n bne nf_clip_plane\n lda nf_count\n sta hc_count\n lda #0\n sta nf_poly_index\nnf_project_polygon:\n ldx nf_poly_index\n jsr nf_load_a\n jsr nf_prepare_reciprocal\n'
    for axis,ax in enumerate('xy'):
        s+=copy('nf_p'+ax,'nf_coord')+f' lda #{axis}\n sta hc_axis\n jsr nf_project\n'
        # LUT error/rounded intersections can be just outside a boundary.
        s+=f' lda hc_q+1\n bmi nf_poly_{ax}_zero\n cmp #>{(159 if ax=="x" else 99)*4}\n bcc nf_poly_{ax}_store\n bne nf_poly_{ax}_max\n lda hc_q\n cmp #<{(159 if ax=="x" else 99)*4+1}\n bcc nf_poly_{ax}_store\nnf_poly_{ax}_max:\n'+load((159 if ax=='x' else 99)*4,'hc_q')+f' jmp nf_poly_{ax}_store\nnf_poly_{ax}_zero:\n'+load(0,'hc_q')+f'nf_poly_{ax}_store:\n ldy nf_poly_index\n lda hc_q\n sta hc_a_{ax}lo,y\n lda hc_q+1\n sta hc_a_{ax}hi,y\n'
    s+=' inc nf_poly_index\n lda nf_poly_index\n cmp hc_count\n bne nf_project_polygon\nnf_face_finish:\n jsr hc_commit_poly\n jsr hc_winding_visible\n bcc nf_face_empty\n lda #0\n sta spanw\n sta spanh\n lda #159\n sta nf_minx\n lda #99\n sta nf_miny\n ldx #0\nnf_metadata:\n lda clip_a_x,x\n cmp spanw\n bcc +\n sta spanw\n+\n cmp nf_minx\n bcs +\n sta nf_minx\n+\n lda clip_a_y,x\n cmp spanh\n bcc +\n sta spanh\n+\n cmp nf_miny\n bcs +\n sta nf_miny\n+\n inx\n cpx hc_count\n bne nf_metadata\n sec\n lda spanw\n sbc nf_minx\n sta spanw\n sec\n lda spanh\n sbc nf_miny\n sta spanh\n lda #1\n sta clip_poly_active\n sec\n rts\nnf_face_empty:\n lda #0\n sta hc_count\n sta clip_a_count\n lda #1\n sta clip_poly_active\n clc\n rts\n'
    s+='nf_clip_pass:\n lda #0\n sta nf_out_count\n sta nf_cur\n lda nf_count\n sec\n sbc #1\n sta nf_prev\n tax\n jsr nf_load_a\n jsr nf_distance\n'+copy('nf_d','nf_prev_d',4)+'nf_clip_edge:\n ldx nf_cur\n jsr nf_load_a\n jsr nf_distance\n'+copy('nf_d','nf_cur_d',4)+''' lda nf_prev_d+3
 eor nf_cur_d+3
 bpl nf_clip_same
 jsr nf_intersection
 jsr nf_append_b
nf_clip_same:
 lda nf_cur_d+3
 bmi nf_clip_next
 ldx nf_cur
 jsr nf_load_a
'''
    for ax in 'xyz':s+=copy('nf_p'+ax,'nf_out_'+ax)
    s+=' jsr nf_append_b\nnf_clip_next:\n'+copy('nf_cur_d','nf_prev_d',4)+' lda nf_cur\n sta nf_prev\n inc nf_cur\n lda nf_cur\n cmp nf_count\n bne nf_clip_edge\n lda nf_out_count\n sta nf_count\n ldx #0\nnf_copy_back:\n cpx nf_count\n beq +\n'
    for ax in 'xyz':
        for part in ('lo','hi'):s+=f' lda nf_b_{ax}{part},x\n sta nf_a_{ax}{part},x\n'
    s+=' inx\n jmp nf_copy_back\n+\n rts\nnf_load_a:\n'
    for ax in 'xyz':
        for i,part in enumerate(('lo','hi')):s+=f' lda nf_a_{ax}{part},x\n sta nf_p{ax}+{i}\n'
    s+=' rts\nnf_append_b:\n ldy nf_out_count\n cpy #12\n bcs hp_unreachable\n'
    for ax in 'xyz':
        for i,part in enumerate(('lo','hi')):s+=f' lda nf_out_{ax}+{i}\n sta nf_b_{ax}{part},y\n'
    s+=' inc nf_out_count\n rts\n'
    return s

def intersection():
    s='''nf_intersection:
 lda nf_prev_d+3
 bmi nf_prev_outside
 lda nf_cur
 sta nf_from
 lda nf_prev
 sta nf_to
'''+copy('nf_cur_d','nf_rem',4)+copy('nf_prev_d','nf_inside_d',4)+''' jmp nf_factor
nf_prev_outside:
 lda nf_prev
 sta nf_from
 lda nf_cur
 sta nf_to
'''+copy('nf_prev_d','nf_rem',4)+copy('nf_cur_d','nf_inside_d',4)+'''nf_factor:
'''+negate('nf_rem',4)+add('nf_rem','nf_inside_d','nf_den',4)+''' lda nf_inside_d
 ora nf_inside_d+1
 ora nf_inside_d+2
 ora nf_inside_d+3
 bne nf_ratio_needed
 ldx nf_to
 jsr nf_load_a
'''
    for ax in 'xyz':s+=copy('nf_p'+ax,'nf_out_'+ax)
    s+=' rts\nnf_ratio_needed:\n jsr nf_ratio\n'
    for ax in 'xyz':
        s+=f' ldx nf_to\n ldy nf_from\n sec\n lda nf_a_{ax}lo,x\n sbc nf_a_{ax}lo,y\n sta nf_a\n lda nf_a_{ax}hi,x\n sbc nf_a_{ax}hi,y\n sta nf_a+1\n sta nf_delta_sign\n bpl +\n'+negate('nf_a',2)+'+\n'+copy('nf_ratio_value','nf_b')+' jsr nf_umultiply\n clc\n lda nf_product+1\n adc #128\n sta nf_product+1\n lda nf_product+2\n adc #0\n sta nf_product+2\n lda nf_product+3\n adc #0\n sta nf_product+3\n lda nf_delta_sign\n bpl +\n'+negate('nf_product+2',2)+f'+\n ldy nf_from\n clc\n lda nf_a_{ax}lo,y\n adc nf_product+2\n sta nf_out_{ax}\n lda nf_a_{ax}hi,y\n adc nf_product+3\n sta nf_out_{ax}+1\n'
    return s+' lda nf_plane\n bne +\n'+copy('nf_near','nf_out_z')+'+\n rts\n'

def state():
    sizes={'exp':1,'shift':1,'ext':1,'sum':3,'ys':2,'yc':2,'ps':2,'pc':2,'tx':2,'ty':2,'t0':2,'t1':2,
           'near':2,'a':2,'b':2,'product':4,'mulshift':4,'sign':1,'axis_sign':1,'delta_sign':1,
           'coord':2,'mantissa':2,'project_shift':1,'lut_offset':2,'recip':2,'d':4,'code':1,'plane':1,
           'rem':4,'den':4,'ratio_value':2,'or':1,'and':1,'poly_index':1,'count':1,'out_count':1,
           'prev':1,'cur':1,'prev_d':4,'cur_d':4,'inside_d':4,'from':1,'to':1,'minx':1,'miny':1}
    for ax in 'xyz':sizes['o'+ax]=3;sizes['p'+ax]=2;sizes['out_'+ax]=2
    for i in range(3):
        for j in range(3):sizes[f'm{i}{j}']=2
    s=''.join(f'nf_{n}: .fill {size},0\n' for n,size in sizes.items())
    for ax in 'xyz':
        for part in ('lo','hi'):s+=f'nf_v{ax}{part}: .fill VERT_COUNT,0\n'
    s+='nf_vertex_exp: .fill VERT_COUNT,0\nnf_outcodes: .fill VERT_COUNT,0\n'
    for bank in 'ab':
        for ax in 'xyz':
            for part in ('lo','hi'):s+=f'nf_{bank}_{ax}{part}: .fill 12,0\n'
    return s
