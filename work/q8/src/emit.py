"""Indexed-mesh Q8 transform adapter. No baked poses, no official engine edits.
Copyright 2026 librologica.digital. PolyForm Noncommercial 1.0.0.
"""
import math,re
from pathlib import Path

def ldword(src,dst):
    if isinstance(src,int):return f' lda #<{src&65535}\n sta {dst}\n lda #>{src&65535}\n sta {dst}+1\n'
    return f' lda {src}\n sta {dst}\n lda {src}+1\n sta {dst}+1\n'
def product(a,b,out,kind='hp_q8'):
    return ldword(a,'hp_a')+ldword(b,'hp_b')+f' jsr {kind}\n'+ldword('hp_r',out)
def combine(a,b,out,sub=False):
    op='sbc' if sub else 'adc'
    return f' {"sec" if sub else "clc"}\n lda {a}\n {op} {b}\n sta {out}\n lda {a}+1\n {op} {b}+1\n sta {out}+1\n'

def validate(lab):
    if lab.get('GRAPHICS_MODE') not in (1,2,3,4,5,6,7):raise ValueError('Q8_MODE_UNQUALIFIED: requires Mode 1..7')
    if lab.get('SCENE_OBJECT_COUNT') not in (1,2):raise ValueError('Q8_OBJECT_BUDGET: 1..2')
    needed={'MESH_SOURCE_SHARING_RUNTIME':0,
            'CAMERA_RUNTIME_CONTROLS':0,'EXPLORER_MATRIX_FOLD':1,'WORLD_GROUND_OCCLUDE':0,
            'STABLE_FACE_CULL_PROFILE':0,'CAMERA_WALK_LITE':1,'EXPLORER_CAMERA_YAW':0,
            'EXPLORER_CAMERA_PITCH':0,'EXPLORER_CAMERA_ROLL':0,'PROJ_CENTER_X':80,
            'PROJ_CENTER_Y':50,'PROJ_FOCAL':170}
    for n,v in needed.items():
        if lab.get(n)!=v:raise ValueError(f'Q8_PROFILE_UNQUALIFIED: {n}={lab.get(n)} (requires {v})')
    if not 1<=lab['VERT_COUNT']<=96:raise ValueError('Q8_VERTEX_BUDGET: 1..96 vertices in this gate')

def chunks(lab):
    validate(lab)
    kernel=Path(__file__).with_name('kernel.asm').read_text()
    core=kernel[kernel.index('hp_code_start:'):kernel.index('hp_template_end:')]
    # Generic runtime scale; unchanged multiply/round convention.
    core=core.replace(' lda object_scale\n cmp #45\n bne hp_origin_fail\n','')
    # Camera positions are 24-bit Q8, object X/Y are signed 16-bit Q8.
    # Verify the full subtraction before narrowing: no modulo-65536 aliases.
    for axis in 'xy':
        old=f''' sec
 lda object_pos_{axis}_lo
 sbc explorer_cam_{axis}_lo
 sta hp_origin_{axis}
 lda object_pos_{axis}_hi
 sbc explorer_cam_{axis}_hi
 sta hp_origin_{axis}+1
 jsr hp_check_origin_axis
'''
        new=f''' lda object_pos_{axis}_hi
 bpl hp_origin_{axis}_obj_pos
 lda #$ff
 bne hp_origin_{axis}_obj_ext
hp_origin_{axis}_obj_pos:
 lda #0
hp_origin_{axis}_obj_ext:
 sta hp_origin_ext
 sec
 lda object_pos_{axis}_lo
 sbc explorer_cam_{axis}_lo
 sta hp_origin_{axis}
 lda object_pos_{axis}_hi
 sbc explorer_cam_{axis}_hi
 sta hp_origin_{axis}+1
 lda hp_origin_ext
 sbc explorer_cam_{axis}_ext
 sta hp_origin_ext
 lda hp_origin_{axis}+1
 bpl hp_origin_{axis}_result_pos
 lda #$ff
 bne hp_origin_{axis}_compare_ext
hp_origin_{axis}_result_pos:
 lda #0
hp_origin_{axis}_compare_ext:
 cmp hp_origin_ext
 bne hp_origin_fail
 lda hp_origin_{axis}+1
 jsr hp_check_origin_axis
'''
        assert old in core;core=core.replace(old,new)
    core=core.replace(' cmp #8\n bne hp_project_vertex',' cmp #VERT_COUNT\n bne hp_project_vertex')
    core=core.replace(' cpy #8\n bne hp_commit_loop',' cpy #VERT_COUNT\n bne hp_commit_loop')
    # When near-poly is emitted, preserve its integer camera cache convention.
    core=core.replace(' lda #1\n sta projdone,y', '''.if EXPLORER_NEAR_POLY != 0
 lda hp_vx+1,x
 sta vxrawlo,y
 cmp #$80
 lda #0
 bcc hp_cache_x_positive
 lda #$ff
hp_cache_x_positive:
 sta vxrawhi,y
 lda hp_vy+1,x
 sta vyrawlo,y
 cmp #$80
 lda #0
 bcc hp_cache_y_positive
 lda #$ff
hp_cache_y_positive:
 sta vyrawhi,y
 lda hp_vz+1,x
 sta vzrawlo,y
 lda #0
 sta vzrawhi,y
.endif
 lda #1
 sta projdone,y''')
    trig='hp_prepare_trig:\n'
    for axis in 'xyz':
        for offset,name in ((0,'s'),(64,'c')):
            trig+=f' lda object_ang_{axis}_lo\n sta hp_fraction\n lda object_ang_{axis}_hi\n clc\n adc #{offset}\n tax\n jsr hp_sine\n'+ldword('hp_r',f'hp_{name}{axis}')
    trig+=' rts\n'
    matrix='hp_prepare_matrix:\n jsr hp_prepare_trig\n'
    matrix+=product('hp_sx','hp_sy','hp_t1')+product('hp_cx','hp_sy','hp_t2')
    for a,b,out in [('hp_cy','hp_cz','hp_m00'),('hp_cy','hp_sz','hp_m10'),('hp_sx','hp_cy','hp_m21'),('hp_cx','hp_cy','hp_m22')]:matrix+=product(a,b,out)
    matrix+=ldword(0,'hp_t3')+combine('hp_t3','hp_sy','hp_m20',True)
    for a,b,c,d,out,sub in [('hp_t1','hp_cz','hp_cx','hp_sz','hp_m01',True),('hp_t2','hp_cz','hp_sx','hp_sz','hp_m02',False),('hp_t1','hp_sz','hp_cx','hp_cz','hp_m11',False),('hp_t2','hp_sz','hp_sx','hp_cz','hp_m12',True)]:
        matrix+=product(a,b,'hp_t3')+product(c,d,'hp_t4')+combine('hp_t3','hp_t4',out,sub)
    matrix+=' lda object_scale\n sta hp_scale\n lda #0\n sta hp_scale+1\n asl hp_scale\n rol hp_scale+1\n asl hp_scale\n rol hp_scale+1\n'
    for i in range(3):
        for j in range(3):matrix+=product(f'hp_m{i}{j}','hp_scale',f'hp_m{i}{j}')
    matrix+=' rts\n'
    terms='hp_prepare_terms:\n'
    for i in range(3):
        for j,axis in enumerate('xyz'):
            name=f'hp_term{i}{j}'
            terms+=f''' lda #0
 sta hp_term_index
{name}_loop:
 ldx hp_term_index
 lda {axis}coord,x
 sta hp_b
 cmp #$80
 lda #0
 bcc {name}_positive
 lda #$ff
{name}_positive:
 sta hp_b+1
'''+ldword(f'hp_m{i}{j}','hp_a')+f''' jsr hp_int_product
 ldx hp_term_index
 lda hp_r
 sta {name}_lo,x
 lda hp_r+1
 sta {name}_hi,x
 inc hp_term_index
 lda hp_term_index
 cmp #{axis.upper()}COORD_COUNT
 bne {name}_loop
'''
    terms+=' rts\n'
    vertices='hp_build_vertices:\n lda #0\n sta hp_idx\nhp_vertex_loop:\n'
    for i,axis in enumerate('xyz'):
        vertices+=ldword(f'hp_origin_{axis}','hp_vertex_sum')
        for j,ax in enumerate('xyz'):
            vertices+=f''' ldy hp_idx
 ldx vert_{ax}i,y
 clc
 lda hp_vertex_sum
 adc hp_term{i}{j}_lo,x
 sta hp_vertex_sum
 lda hp_vertex_sum+1
 adc hp_term{i}{j}_hi,x
 sta hp_vertex_sum+1
'''
        vertices+=f''' lda hp_idx
 asl
 tax
 lda hp_vertex_sum
 sta hp_v{axis},x
 lda hp_vertex_sum+1
 sta hp_v{axis}+1,x
'''
    vertices+=' inc hp_idx\n lda hp_idx\n cmp #VERT_COUNT\n bne hp_vertex_loop\n rts\n'
    data=[]
    for n in ('a','b','r','base','rem','den','projection','integer','origin_x','origin_y','origin_z','t1','t2','t3','t4','scale','vertex_sum'):
        data.append(f'hp_{n}: .word 0')
    for n in ['sx','cx','sy','cy','sz','cz']+[f'm{i}{j}' for i in range(3) for j in range(3)]:data.append(f'hp_{n}: .word 0')
    for n in ('fraction','sine_index','sign','idx','axis','fallback','used','count','term_index','origin_ext'):data.append(f'hp_{n}: .byte 0')
    data+=['hp_p: .fill 4,0','hp_shift: .fill 4,0']
    for n in ('vx','vy','vz','px','py','ix','iy'):data.append(f'hp_{n}: .fill VERT_COUNT*2,0')
    for i in range(3):
        for j,axis in enumerate('XYZ'):
            for part in ('lo','hi'):data.append(f'hp_term{i}{j}_{part}: .fill {axis}COORD_COUNT,0')
    table=[round(math.sin(i*math.tau/256)*256) for i in range(256)]
    tables='hp_sin_lo:\n .byte '+','.join(str(x&255) for x in table)+'\nhp_sin_hi:\n .byte '+','.join(str((x>>8)&255) for x in table)+'\n'
    return dict(core=core,trig=trig,matrix=matrix,terms=terms,vertices=vertices,data='\n'.join(data)+'\n',tables=tables)

def pack_greedy(sizes,lab):
    gaps=[(lab['mode3_high_basic_low_segment_end'],0x2000),
          (lab['mode3_high_basic_middle_end'],0x5c00),
          (lab['mode3_high_basic_relocated_code_end'],0xa000),
          (lab['mode3_high_basic_high_code_end'],0xd000)]
    original=gaps[:];placed={}
    for name,size in sorted(sizes.items(),key=lambda x:-x[1]):
        # Tables need page-aligned halves. Others only word alignment.
        align=256 if name=='tables' else 2;need=size+(32 if name not in ('tables','data') else 0)
        choices=[]
        for i,(start,end) in enumerate(gaps):
            start=(start+align-1)//align*align
            if start+need<=end:choices.append((end-start-need,i,start))
        if not choices:raise ValueError(f'Q8_MEMORY_BUDGET: no safe gap for {name}, {need} bytes; remaining={gaps}')
        _,i,start=min(choices);oldstart,end=gaps.pop(i)
        if oldstart<start:gaps.append((oldstart,start))
        if start+need<end:gaps.append((start+need,end))
        placed[name]=(start,start+need)
    return placed,original,gaps


def pack(sizes,lab):
    try:return pack_greedy(sizes,lab)
    except ValueError as initial:
        # Placement-only fallback. Preserve every original range, alignment and
        # 32-byte code guard; never spill into graphics or lower precision.
        gaps=[(lab['mode3_high_basic_low_segment_end'],0x2000),
              (lab['mode3_high_basic_middle_end'],0x5c00),
              (lab['mode3_high_basic_relocated_code_end'],0xa000),
              (lab['mode3_high_basic_high_code_end'],0xd000)]
        items=sorted(sizes.items(),key=lambda x:-x[1]);seen=set();nodes=0
        def search(i,free,placed):
            nonlocal nodes
            nodes+=1
            if nodes>60000:return None
            if i==len(items):return placed,free
            state=(i,tuple(sorted(free)))
            if state in seen:return None
            seen.add(state)
            name,size=items[i];align=256 if name=='tables' else 2
            need=size+(0 if name in ('tables','data') else 32)
            remaining=sum(s+(0 if n in ('tables','data') else 32) for n,s in items[i:])
            if sum(b-a for a,b in free)<remaining:return None
            options=[]
            for gi,(a,b) in enumerate(free):
                start=(a+align-1)//align*align
                if start+need<=b:options.append((b-start-need,gi,start))
            for _,gi,start in sorted(options):
                a,b=free[gi];nextfree=free[:gi]+free[gi+1:]
                if a<start:nextfree.append((a,start))
                if start+need<b:nextfree.append((start+need,b))
                result=search(i+1,nextfree,{**placed,name:(start,start+need)})
                if result:return result
            return None
        result=search(0,gaps,{})
        if result:return result[0],gaps,result[1]
        raise ValueError(f'{initial}; exact-placement fallback exhausted {nodes} states') from initial

def attach(source,parts,placed=None):
    assert source.count('hp_legacy_transform_project_vertices = hp_unreachable')==1
    for name,code in parts.items():
        source+=f'\n; Q8 block {name}\n'
        source+=f'* = ${placed[name][0]:04x}\n' if placed else '.virtual $4000\n'
        source+=f'hp_block_{name}_begin:\n'+code+f'hp_block_{name}_end:\n'
        source+=f'.if * > ${placed[name][1]:04x}\n .error "Q8 allocation overflow: {name}"\n.endif\n' if placed else '.endvirtual\n'
    return source
