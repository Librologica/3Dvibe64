"""Private rotating Q8 cube; dynamic plane lighting, native Mode4 solid fill.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. Frozen renderer sources remain unchanged.
"""
import re,json
from pathlib import Path
import torus_runtime as base
FIRST=75; FACE=107
ROOT=Path(__file__).resolve().parents[1]

def vertices():
    return [[x,y,z] for z in (-4,4) for y in (-4,4) for x in (-4,4)]

def faces():
    # One outward-wound pair of triangles per plane: -Z,+Z,-Y,+Y,-X,+X.
    quads=((0,2,3,1),(4,5,7,6),(0,1,5,4),(2,6,7,3),(0,4,6,2),(1,3,7,5))
    return [[q[a] for a in t] for q in quads for t in ((0,1,2),(0,2,3))]

def make():
    fs=faces()
    return dict(id='central-cube',type='mesh',geometry='solid',materialProfile='single',
                vertices=vertices(),faces=fs,texture='plain-ceiling',
                faceTextures=['plain-ceiling']*12,faceUV=[[[0,0]]*3 for _ in fs],
                gouraud={'creaseAngle':0})

def bake(source):
    # Keep baked room lighting and retire the same unused Q6 ABI. Uniform
    # central Q values are coverage scaffolding only, never interpolated by
    # the native flat dispatcher below. No central Gouraud state is mutable.
    source=base.bake(source)
    for k in range(3):
        _,v=base.array(source,'gouraud_face_shade'+str(k))
        source=base.put(source,'gouraud_face_shade'+str(k),v[:FACE]+[16]*12)
    source=base.put(source,'gouraud_shade_value',list(range(33)))
    for label in ('object_runtime_shade_first','object_runtime_shade_end'):
        source=base.put(source,label,[0]*4)
    # base's brown/mirror palette override is not used by this gray/satin cube.
    return source

adapt_vertices=base.adapt_vertices
word=base.word

def hooks(source):
    # Native solid/pattern Mode4 fillers are LIVE. Only old integer edges can
    # be retired: Q8 coverage is produced by tq/evenedges for both objects.
    a=source.index('trace_edge_convex:\n');b=source.index('setup_face_y_bounds:\n',a)
    new='; Q8 edge coverage only; legacy integer tracer is unreachable.\n'
    for line in source[a:b].splitlines():
        m=re.match(r'^(\w+):',line)
        if m:new+=m[1]+' = hp_unreachable\n'
        elif line.strip().startswith(('.if ','.else','.elsif ','.endif')):new+=line+'\n'
    source=source[:a]+new+source[b:]
    assert source.count(' jmp gouraud_fill_bounds\n')==1
    source=source.replace(' jmp gouraud_fill_bounds\n',' jmp fc_finish_bounds\n',1)
    return source+'\n*=$4000\n'+kernel()+'\n*=$4000\n'+dispatch()

def kernel():
    code=''' .cerror VERT_COUNT != 83 || FACE_COUNT != 119,"Rotating cube layout changed"
tr_update:
 ; Camera-relative horizontal lamp, raised 14WU above cube center. Room
 ; lighting is untouched. Clamp distant forward poses to signed Q8 domain.
 lda explorer_cam_x_hi
 sta tr_lamp
 lda #14
 sta tr_lamp+1
 lda explorer_cam_z_ext
 bmi tr_lamp_far
 bne tr_lamp_forward
 lda explorer_cam_z_hi
 cmp #96
 bcc tr_lamp_far
 cmp #224
 bcs tr_lamp_forward
 sec
 sbc #160
 jmp tr_lamp_store
tr_lamp_far:
 lda #192
 bne tr_lamp_store
tr_lamp_forward:
 lda #64
tr_lamp_store:
 sta tr_lamp+2
'''
    for axis,offset in zip('xyz',(0,4,8)):
        code+=f' lda ang{axis}_lo\n sta hp_fraction\n ldx ang{axis}_hi\n jsr hp_sine\n'
        code+=word('hp_r',f'tr_trig+{offset}')
        code+=' ldx hp_sine_index\n txa\n clc\n adc #64\n tax\n jsr hp_sine\n'
        code+=word('hp_r',f'tr_trig+{offset+2}')
    code+=' lda #0\n sta tr_index\ntr_vertex_rotate:\n'
    for axis,offset in zip('xyz',(0,2,4)):
        code+=f' ldy tr_index\n lda vert_{axis}i+75,y\n tax\n lda {axis}coord,x\n sta tr_v+{offset+1}\n lda #0\n sta tr_v+{offset}\n'
    code+=' jsr tr_rotate\n'
    for axis,offset in zip('xyz',(0,2,4)):
        code+=f' ldy tr_index\n lda tr_v+{offset}\n sta hc_cam_{axis}0+75,y\n lda tr_v+{offset+1}\n sta hc_cam_{axis}1+75,y\n asl\n lda #0\n sbc #0\n eor #255\n sta hc_cam_{axis}2+75,y\n'
    code+=' inc tr_index\n lda tr_index\n cmp #8\n bne tr_vertex_rotate\n lda #0\n sta tr_index\ntr_plane_light:\n'
    normals=[(0,0,-1),(0,0,1),(0,-1,0),(0,1,0),(-1,0,0),(1,0,0)]
    for ax,o in zip('xyz',(0,2,4)):
        code+=f' ldy tr_index\n lda #0\n sta tr_v+{o}\n lda tr_normal_{ax},y\n sta tr_v+{o+1}\n'
    code+=' jsr tr_rotate\n lda #0\n sta tr_dot\n sta tr_dot+1\n'
    # Viewer-relative lamp. Plane-center dot is invariant 4WU
    # under Euler rotation; thresholds 3WU/13WU give three constant levels.
    for offset,axis in zip((0,2,4),(0,1,2)):
        code+=word(f'tr_v+{offset}','hp_a')+f' lda #0\n sta hp_b\n lda tr_lamp+{axis}\n sta hp_b+1\n jsr hp_q8\n'
        code+=' clc\n lda tr_dot\n adc hp_r\n sta tr_dot\n lda tr_dot+1\n adc hp_r+1\n sta tr_dot+1\n'
    code+=''' sec
 lda tr_dot+1
 sbc #4
 bmi tr_dark
 cmp #3
 bcc tr_dark
 cmp #13
 bcs tr_bright
 lda #2
 bne tr_save_code
tr_bright:
 lda #4
 bne tr_save_code
tr_dark:
 lda #0
tr_save_code:
 ldy tr_index
 sta tr_plane_codes,y
 pha
 tya
 asl
 tay
 pla
 sta fc_shade_codes,y
 sta fc_shade_codes+1,y
 inc tr_index
 lda tr_index
 cmp #6
 bne tr_plane_light
 rts
'''
    old=base.kernel()
    code+=old[old.index('tr_rotate:\n'):old.index('; LOD chosen ONCE')]
    code+='tr_v: .fill 6,0\ntr_trig: .fill 12,0\n'
    for n in ('a','b','sin','cos','temp','dot'):code+='tr_'+n+': .word 0\n'
    for n in ('index','axis','aindex','bindex'):code+='tr_'+n+': .byte 0\n'
    code+='tr_pair_a: .byte 2,4,0\ntr_pair_b: .byte 4,0,2\ntr_plane_codes: .fill 6,0\ntr_lamp: .fill 3,0\n'
    for k,ax in enumerate('xyz'):code+='tr_normal_'+ax+': .byte '+','.join(str(n[k]&255) for n in normals)+'\n'
    return code

def dispatch():
    return '''fc_begin:
fc_finish_bounds:
 lda sortj
 cmp #107
 bcs fc_cube
 jmp gouraud_fill_bounds
fc_cube:
 tay
 lda fc_shade_codes-107,y
 sta fc_code
 ldx face_ymin
fc_inclusive:
 lda leftb,x
 cmp rightb,x
 bcc fc_nonempty
 bne fc_next
 lda tq_closed,x
 bne fc_next
 lda #255
 sta leftb,x
 lda #0
 sta rightb,x
 jmp fc_next
fc_nonempty:
 lda tq_closed,x
 bne fc_next
 dec rightb,x
fc_next:
 cpx face_ymax
 beq fc_draw
 inx
 jmp fc_inclusive
fc_draw:
 lda fc_code
 tay
 lda shade_solid_bytes,y
 sta fillbyte
 lda drawbuf
 bne fc_solid_b
 jmp fill_bounds_solid_a
fc_solid_b:
 jmp fill_bounds_solid_b
fc_code: .byte 0
fc_shade_codes: .fill 12,0
fc_end:
'''
