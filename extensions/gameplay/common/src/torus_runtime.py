"""Central-only Q8 rotation + smooth point lighting + two geometric LODs.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. No public engine changes.
"""
import math,re,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
FIRST=75; FACE=107; SHADE=33

def faces(step=1):
    verts=vertices();out=[]
    for i in range(0,8,step):
        for j in range(4):
            q=[i*4+j,((i+step)%8)*4+j,((i+step)%8)*4+(j+1)%4,i*4+(j+1)%4]
            for ids in ((0,1,2),(0,2,3)):
                f=[q[k] for k in ids];p,a,b=[verts[k] for k in f]
                u=[a[k]-p[k] for k in range(3)];v=[b[k]-p[k] for k in range(3)]
                n=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
                c=[sum(verts[k][d] for k in f)/3 for d in range(3)];rr=math.hypot(c[0],c[2])
                outward=[c[0]*(1-5/rr),c[1],c[2]*(1-5/rr)]
                assert any(n)
                if sum(n[k]*outward[k] for k in range(3))<0:f.reverse()
                out.append(f)
    return out

def vertices():
    return [[round((5+2*math.cos(j*math.tau/4))*math.cos(i*math.tau/8)),
             round(2*math.sin(j*math.tau/4)),
             round((5+2*math.cos(j*math.tau/4))*math.sin(i*math.tau/8))]
            for i in range(8) for j in range(4)]

def make():
    fs=faces()
    return dict(id='central-torus',type='mesh',geometry='solid',materialProfile='single',
                vertices=vertices(),faces=fs,texture='plain-ceiling',
                faceTextures=['plain-ceiling']*len(fs),faceUV=[[[0,0]]*3 for _ in fs],
                gouraud={'creaseAngle':180})

def array(source,label):
    m=re.search(r'(?m)^'+label+r':\n((?: \.byte[^\n]*\n)+)',source);assert m,label
    return m,[int(v[1:],16) if v.startswith('$') else int(v) for v in re.findall(r'\$[0-9a-fA-F]+|-?\d+',m[1])]

def put(source,label,values):
    m,_=array(source,label)
    return source[:m.start()]+label+':\n .byte '+','.join(str(v&255) for v in values)+'\n'+source[m.end():]

def bake(source):
    # Static room Q values stay exactly as baked. Only central shade indices
    # remain mutable: 33..64, shared by both LOD topologies.
    _,values=array(source,'gouraud_shade_value')
    for k in range(3):
        _,ids=array(source,'gouraud_face_shade'+str(k));_,vs=array(source,'face'+str(k))
        ids=[values[s] if f<FACE else SHADE+vs[f]-FIRST for f,s in enumerate(ids)]
        source=put(source,'gouraud_face_shade'+str(k),ids)
    source=put(source,'gouraud_shade_value',list(range(33))+[16]*32)
    source=put(source,'object_runtime_shade_first',[0,0,0,SHADE])
    source=put(source,'object_runtime_shade_end',[0,0,0,SHADE+32])
    a=source.index('m3_update_shades:\n');b=source.index('m3_update_shades_end = *',a)
    source=source[:a]+'''m3_update_shades:
 lda objidx
 cmp #3
 beq +
 rts
+
 jmp tr_update
'''+source[b:]
    for label in ['gouraud_normal_'+a for a in 'xyz']+['gouraud_center_dot_lo','gouraud_center_dot_hi']+['face_normal_'+a for a in 'xyz']+['face_center_dot_lo','face_center_dot_hi']:
        source,n=re.subn(r'(?m)^'+label+r':\n(?: \.byte[^\n]*\n)+','',source);assert n==1,label
    a=source.index('\nsubtract_face_center_dot:\n')+1;b=source.index(' rts\n',a)+len(' rts\n')
    source=source[:a]+'subtract_face_center_dot:\n rts ; inactive legacy shading ABI\n'+source[b:]
    # Q8 camera and our torus never consume the old Q6 object matrix/light.
    # Keep callable no-op entries, trap every retired internal label. Executed
    # CPU qualification must never reach hp_unreachable.
    a=source.index('prepare_angles:\n');b=source.index('build_coord_terms:\n',a)
    names=re.findall(r'(?m)^(\w+):',source[a:b])
    live=('prepare_angles','prepare_object_matrix','prepare_object_light_for_shade','gouraud_update_object_shades')
    body=''.join(n+':\n' for n in live)+' rts\n'
    body+=''.join(n+' = hp_unreachable\n' for n in names if n not in live)
    source=source[:a]+body+source[b:]
    # Engine maximum is mirror/index3. Brown dark/high, white highlight.
    for label,value in [('material_screen_bytes',0x98),('material_color_bytes',1)]:
        _,v=array(source,label);v[39]=value;source=put(source,label,v)
    return source

def adapt_vertices(parts):
    p=parts;s=p['vertices']
    s=s.replace('hp_build_vertices:\n','hp_build_vertices:\n lda objidx\n cmp #3\n bne +\n jmp tr_vertices\n+\n',1)
    p['vertices']=s
    return p

def hooks(source):
    # The specialized hook is not selected by material or texture IDs. The
    # private entry checks scene geometry, object and shade layouts below.
    # This scene is entirely Gouraud C (textured or uniform). The former
    # statue required native Mode4 solid/pattern fillers, now unreachable.
    # Retain the conditional label ABI, trap an unexpected caller. No bitmap
    # clear/palette/Gouraud routine is removed. Tests observe the trap address.
    recovered=[]
    for label,last in [('fill_bounds_solid_a','fbs_a_done'),('fill_bounds_solid_b','fbs_b_done'),
                       ('fill_bounds_pattern_a','fbp_a_done'),('fill_bounds_pattern_b','fbp_b_done')]:
        a=source.index(label+':\n');b=source.index(last+':\n rts\n',a)+len(last+':\n rts\n')
        old=source[a:b];new='; No native Mode4 dispatch in this Gouraud-only scene.\n'
        for line in old.splitlines():
            m=re.match(r'^(\w+):',line)
            if m:new+=m[1]+' = hp_unreachable\n'
            elif line.strip().startswith(('.if ','.else','.elsif ','.endif')):new+=line+'\n'
        source=source[:a]+new+source[b:];recovered.append(label)
    a=source.index('trace_edge_convex:\n');b=source.index('setup_face_y_bounds:\n',a)
    old=source[a:b];new='; Q8 edges are built only by tq/evenedges, not legacy integer tracing.\n'
    for line in old.splitlines():
        m=re.match(r'^(\w+):',line)
        if m:new+=m[1]+' = hp_unreachable\n'
        elif line.strip().startswith(('.if ','.else','.elsif ','.endif')):new+=line+'\n'
    source=source[:a]+new+source[b:];recovered.append('trace_edge_convex')
    (ROOT/'reports/retired-mode4-fillers.json').write_text(json.dumps(recovered,indent=2))
    return source+'\n*=$4000\n'+kernel()

def word(src,dst):
    return f' lda {src}\n sta {dst}\n lda {src}+1\n sta {dst}+1\n'

def kernel():
    code=f'''
 .cerror VERT_COUNT != 107 || FACE_COUNT != 170,"Torus layout changed"
tr_update:
 jsr tr_lod
'''
    for axis,offset in zip('xyz',(0,4,8)):
        code+=f''' lda ang{axis}_lo
 sta hp_fraction
 ldx ang{axis}_hi
 jsr hp_sine
'''+word('hp_r',f'tr_trig+{offset}')+f''' ldx hp_sine_index
 txa
 clc
 adc #64
 tax
 jsr hp_sine
'''+word('hp_r',f'tr_trig+{offset+2}')
    code+=' lda #0\n sta tr_index\ntr_vertex_light:\n'
    for axis,offset in zip('xyz',(0,2,4)):
        code+=f''' ldy tr_index
 lda vert_{axis}i+{FIRST},y
 tax
 lda {axis}coord,x
 sta tr_v+{offset+1}
 lda #0
 sta tr_v+{offset}
'''
    code+=' jsr tr_rotate\n'
    for axis,offset in zip('xyz',(0,2,4)):
        code+=f''' ldy tr_index
 lda tr_v+{offset}
 sta hc_cam_{axis}0+{FIRST},y
 lda tr_v+{offset+1}
 sta hc_cam_{axis}1+{FIRST},y
 asl
 lda #0
 sbc #0
 eor #255
 sta hc_cam_{axis}2+{FIRST},y
'''
    # Analytic smooth normals are signed Q0.6, rotated as signed Q8 unit vectors.
    for axis,offset in zip('xyz',(0,2,4)):
        code+=f''' ldy tr_index
 lda tr_normal_{axis},y
 sta tr_v+{offset}
 asl
 lda #0
 sbc #0
 eor #255
 sta tr_v+{offset+1}
 asl tr_v+{offset}
 rol tr_v+{offset+1}
 asl tr_v+{offset}
 rol tr_v+{offset+1}
'''
    code+=' jsr tr_rotate\n lda #0\n sta tr_dot\n sta tr_dot+1\n'
    # Static world point lamp relative to the torus center [-12,+14,-12].
    for axis,offset,lamp in zip('xyz',(0,2,4),(-12,14,-12)):
        code+=f''' ldy tr_index
 sec
 lda #0
 sbc hc_cam_{axis}0+{FIRST},y
 sta hp_b
 lda #{lamp&255}
 sbc hc_cam_{axis}1+{FIRST},y
 sta hp_b+1
'''+word(f'tr_v+{offset}','hp_a')+''' jsr hp_q8
 clc
 lda tr_dot
 adc hp_r
 sta tr_dot
 lda tr_dot+1
 adc hp_r+1
 sta tr_dot+1
'''
    code+=''' bmi tr_ambient
 asl tr_dot
 rol
 clc
 adc #6
 cmp #33
 bcc tr_store_light
 lda #32
 bne tr_store_light
tr_ambient:
 lda #6
tr_store_light:
 ldy tr_index
 sta gouraud_shade_value+33,y
 inc tr_index
 lda tr_index
 cmp #32
 bne tr_vertex_light
 rts
; Q8 Euler x,y,z. Four rounded Q8 products per planar rotation.
tr_rotate:
 lda #0
 sta tr_axis
tr_rotation:
 ldx tr_axis
 lda tr_pair_a,x
 sta tr_aindex
 tay
 lda tr_v,y
 sta tr_a
 lda tr_v+1,y
 sta tr_a+1
 lda tr_pair_b,x
 sta tr_bindex
 tay
 lda tr_v,y
 sta tr_b
 lda tr_v+1,y
 sta tr_b+1
 txa
 asl
 asl
 tax
 lda tr_trig,x
 sta tr_sin
 lda tr_trig+1,x
 sta tr_sin+1
 lda tr_trig+2,x
 sta tr_cos
 lda tr_trig+3,x
 sta tr_cos+1
'''
    code+=word('tr_a','hp_a')+word('tr_cos','hp_b')+' jsr hp_q8\n'+word('hp_r','tr_temp')
    code+=word('tr_b','hp_a')+word('tr_sin','hp_b')+''' jsr hp_q8
 ldy tr_aindex
 sec
 lda tr_temp
 sbc hp_r
 sta tr_v,y
 lda tr_temp+1
 sbc hp_r+1
 sta tr_v+1,y
'''
    code+=word('tr_a','hp_a')+word('tr_sin','hp_b')+' jsr hp_q8\n'+word('hp_r','tr_temp')
    code+=word('tr_b','hp_a')+word('tr_cos','hp_b')+''' jsr hp_q8
 ldy tr_bindex
 clc
 lda tr_temp
 adc hp_r
 sta tr_v,y
 lda tr_temp+1
 adc hp_r+1
 sta tr_v+1,y
 inc tr_axis
 lda tr_axis
 cmp #3
 bne tr_rotation
 rts
tr_vertices:
 lda active_vfirst
 sta hp_idx
tr_origins_loop:
 ldy hp_idx
'''
    for axis,cache in zip('xyz',('rxbuf','rybuf','sz')):
        code+=f''' clc
 lda hc_cam_{axis}0,y
 adc hc_origin_{axis}
 sta hc_cam_{axis}0,y
 lda hc_cam_{axis}1,y
 adc hc_origin_{axis}+1
 sta hc_cam_{axis}1,y
 sta v{axis}rawlo,y
 sta {cache},y
 lda hc_cam_{axis}2,y
 adc hc_origin_{axis}+2
 sta hc_cam_{axis}2,y
 sta v{axis}rawhi,y
'''
        if axis=='z':code+=' sta szhi,y\n'
    code+=''' inc hp_idx
 lda hp_idx
 cmp active_vend
 bne tr_origins_loop
 rts
; LOD chosen ONCE per complete frame, using acquired camera pose. Shared
; vertices/normals, high=8x4 rings/64tri, low=4x4 rings/32tri.
; Horizontal Chebyshev distance, 32/40WU hysteresis (no square roots).
tr_lod:
 lda #1
 sta tr_desired
 lda explorer_cam_z_ext
 bne tr_lod_apply
 sec
 lda explorer_cam_z_hi
 sbc #160
 bpl +
 eor #255
 clc
 adc #1
+
 sta tr_distance
 lda explorer_cam_x_hi
 bpl +
 eor #255
 clc
 adc #1
+
 cmp tr_distance
 bcc +
 sta tr_distance
+
 lda tr_distance
 cmp #32
 bcc tr_lod_high
 cmp #40
 bcs tr_lod_apply
 lda tr_lod_state
 cmp #2
 bcc tr_keep_lod
 lda #1
tr_keep_lod:
 sta tr_desired
 jmp tr_lod_apply
tr_lod_high:
 lda #0
 sta tr_desired
tr_lod_apply:
 lda tr_desired
 cmp tr_lod_state
 beq tr_lod_done
 sta tr_lod_state
 inc tr_lod_switches
 asl
 asl
 asl
 asl
 asl
 asl
 lsr
 sta tr_tri_count
 lda #64
 sec
 sbc tr_tri_count
 clc
 adc #106
 ; high(state0) count64; low(state1) count32.
 sta mesh_face_end+3
 lda #0
 sta tr_face_index
 sta tr_ring
tr_topology_loop:
 lda tr_face_index
 and #7
 tax
 lda tr_lod_state
 beq tr_high_offsets
 txa
 clc
 adc #8
 tax
tr_high_offsets:
'''
    for k in range(3):
        code+=f''' lda tr_corner{k},x
 clc
 adc tr_ring
 and #31
 tay
 clc
 adc #33
 pha
 tya
 clc
 adc #75
 ldy tr_face_index
 sta face{k}+106,y
 pla
 sta gouraud_face_shade{k}+106,y
'''
    code+=''' inc tr_face_index
 lda tr_face_index
 and #7
 bne tr_topology_next
 lda tr_lod_state
 asl
 asl
 clc
 adc #4
 adc tr_ring
 sta tr_ring
tr_topology_next:
 lda tr_face_index
 clc
 adc #106
 cmp mesh_face_end+3
 bne tr_topology_loop
tr_lod_done:
 lda mesh_face_end+3
 sta active_face_end
 rts
tr_v: .fill 6,0
tr_trig: .fill 12,0
tr_a: .word 0
tr_b: .word 0
tr_sin: .word 0
tr_cos: .word 0
tr_temp: .word 0
tr_dot: .word 0
tr_index: .byte 0
tr_axis: .byte 0
tr_aindex: .byte 0
tr_bindex: .byte 0
tr_pair_a: .byte 2,4,0
tr_pair_b: .byte 4,0,2
tr_lod_state: .byte 2
tr_lod_switches: .byte 0
tr_distance: .byte 0
tr_desired: .byte 0
tr_tri_count: .byte 0
tr_face_index: .byte 0
tr_ring: .byte 0
'''
    for k in range(3):code+='tr_corner'+str(k)+': .byte '+','.join(str(f[k]) for f in faces()[:8]+faces(2)[:8])+'\n'
    normals=[]
    for i in range(8):
        for j in range(4):
            a=i*math.tau/8;b=j*math.tau/4
            normals.append([round(64*math.cos(b)*math.cos(a)),round(64*math.sin(b)),round(64*math.cos(b)*math.sin(a))])
    for k,axis in enumerate('xyz'):code+='tr_normal_'+axis+': .byte '+','.join(str(n[k]&255) for n in normals)+'\n'
    return code
