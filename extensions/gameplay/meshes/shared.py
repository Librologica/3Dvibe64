"""Q8-01: indexed source geometry shared by independent bounded instances.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
One solid octahedral asset, 2..4 instances. World X/forward/up; Q8 positions,
Q6 scale, 16-bit yaw. Runtime view/projection caches remain per instance.
"""
import hashlib
import json
import math
import re

VERTICES=[[-3,0,0],[3,0,0],[0,-3,0],[0,3,0],[0,0,-5],[0,0,5]]
FACES=[[5,1,3],[5,3,0],[5,0,2],[5,2,1],[4,3,1],[4,0,3],[4,2,0],[4,1,2]]
# The private room importer swaps forward/up: its public mesh winding is clockwise.
FACES=[list(reversed(f)) for f in FACES]
WORLD_VERTICES=9
FIRST_FACE=16


def digest(value):return hashlib.sha256(json.dumps(value,sort_keys=True,separators=(',',':')).encode()).hexdigest().upper()
def configure_asset(asset):
    """Bounded editable source asset: six vertices, eight convex closed triangles."""
    global VERTICES,FACES
    if not isinstance(asset,dict) or set(asset)!={'schema','id','vertices','faces'} or type(asset['schema']) is not int or asset['schema']!=1 or not isinstance(asset['id'],str) or not re.fullmatch('[a-z][a-z0-9-]{0,31}',asset['id']):raise ValueError('Invalid shared source asset')
    vertices=asset['vertices'];faces=asset['faces']
    if not isinstance(vertices,list) or len(vertices)!=6 or any(not isinstance(p,list) or len(p)!=3 or any(type(v) is not int for v in p) or math.hypot(p[0],p[1])>3 or abs(p[2])>5 for p in vertices):raise ValueError('Expected6integer vertices within radius3/height5')
    if len({tuple(p) for p in vertices})!=6 or not isinstance(faces,list) or len(faces)!=8:raise ValueError('Expected distinct vertices and8triangles')
    edges=[];center=[sum(p[a] for p in vertices)/6 for a in range(3)]
    for face in faces:
        if not isinstance(face,list) or len(face)!=3 or any(type(i) is not int or not 0<=i<6 for i in face) or len(set(face))!=3:raise ValueError('Invalid source triangle')
        a,b,c=[vertices[i] for i in face];u=[b[k]-a[k] for k in range(3)];v=[c[k]-a[k] for k in range(3)]
        normal=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
        dot=lambda p:sum(normal[k]*(p[k]-a[k]) for k in range(3))
        if not any(normal) or dot(center)<=0 or any(dot(p)<0 for p in vertices):raise ValueError('Source must be convex with clockwise public winding')
        edges.extend((face[k],face[(k+1)%3]) for k in range(3))
    if len(set(edges))!=24 or any((b,a) not in edges for a,b in edges) or {i for f in faces for i in f}!=set(range(6)):raise ValueError('Source mesh must be closed and manifold')
    VERTICES=[p.copy() for p in vertices];FACES=[f.copy() for f in faces]
    return asset


def exact(value,step,low,high):
    if type(value) not in (int,float) or not math.isfinite(value) or not low<=value<=high or value/step!=round(value/step):
        raise ValueError('Expected finite quantized coordinate/scale')
    return round(value/step)


def validate(config):
    if not isinstance(config,dict) or set(config)!={'schema','sharing','instances'} or type(config['schema']) is not int or config['schema']!=1 or type(config['sharing']) is not bool:
        raise ValueError('Shared mesh requires schema1, boolean sharing and instances')
    instances=config['instances']
    if not isinstance(instances,list) or not 2<=len(instances)<=4:raise ValueError('Expected2..4instances')
    ids=[];spheres=[]
    for instance in instances:
        if not isinstance(instance,dict) or set(instance)!={'id','position','yawDegrees','scale','visible','level'}:raise ValueError('Invalid instance descriptor')
        name=instance['id']
        if not isinstance(name,str) or not re.fullmatch('[a-z][a-z0-9-]{0,31}',name) or name in ids:raise ValueError('Instance ids must be unique')
        ids.append(name);p=instance['position']
        if not isinstance(p,list) or len(p)!=3:raise ValueError('Expected XYZ position')
        for x in p:exact(x,1/256,-23,23)
        scale=exact(instance['scale'],1/64,.5,1)/64
        if type(instance['yawDegrees']) not in (int,float) or not math.isfinite(instance['yawDegrees']) or not 0<=instance['yawDegrees']<360:raise ValueError('Yaw must be finite in0..360degrees')
        if type(instance['visible']) is not bool or type(instance['level']) is not int or not 4<=instance['level']<=28:raise ValueError('Expected visibility flag and shade level4..28')
        # Envelopes include every yaw phase and exact Q8 coefficient rounding.
        r=max(math.hypot(v[0],v[1]) for v in VERTICES)*scale+1/16
        lo=min(v[2] for v in VERTICES)*scale;hi=max(v[2] for v in VERTICES)*scale
        if abs(p[0])+r>=24 or abs(p[1])+r>=24 or p[2]+lo<-10 or p[2]+hi>=18:raise ValueError('Instance envelope outside the convex room')
        for other,other_r in spheres:
            if math.dist(p[:2],other[:2])<=r+other_r:raise ValueError('Intersecting XY envelopes are not qualified')
        spheres.append((p,r))
    return config


def model_vertices(instance):
    """Host geometry oracle, not used for native runtime construction."""
    a=math.radians(instance['yawDegrees']);s=math.sin(a);c=math.cos(a);k=instance['scale'];p=instance['position']
    return [[p[0]+k*(x*c-y*s),p[1]+k*(x*s+y*c),p[2]+k*z] for x,y,z in VERTICES]


def data(name,values):return name+': .byte '+','.join(str(int(v)&255) for v in values)+'\n'


def kernel(config):
    count=len(config['instances'])
    code='''sm_update:
 lda #0
 sta sm_instance
sm_object_loop:
 ldx sm_instance
 lda sm_source_first,x
 sta sm_source_index
 lda sm_runtime_first,x
 sta sm_runtime_index
 lda sm_scale_q6,x
 asl
 asl
 sta sm_scale
 lda #0
 rol
 sta sm_scale+1
 lda sm_yaw_lo,x
 sta hp_fraction
 lda sm_yaw_hi,x
 tax
 jsr hp_sine
 lda hp_r
 sta sm_sine
 lda hp_r+1
 sta sm_sine+1
 ldx sm_instance
 lda sm_yaw_lo,x
 sta hp_fraction
 lda sm_yaw_hi,x
 clc
 adc #64
 tax
 jsr hp_sine
 lda hp_r
 sta sm_cosine
 lda hp_r+1
 sta sm_cosine+1
'''
    # Scale the basis with the same signed Q8 nearest rounding as the renderer.
    for trig in ('sine','cosine'):
        for i in (0,1):code+=f' lda sm_{trig}+{i}\n sta hp_a+{i}\n lda sm_scale+{i}\n sta hp_b+{i}\n'
        code+=' jsr hp_q8\n'
        for i in (0,1):code+=f' lda hp_r+{i}\n sta sm_{trig}+{i}\n'
    for axis in 'xyz':
        code+=' ldx sm_instance\n clc\n'
        for j in range(3):code+=f' lda hc_origin_{axis}+{j}\n adc sm_position_{axis}{j},x\n sta sm_origin_{axis}+{j}\n'
    code+=' lda #0\n sta sm_vertex\nsm_vertex_loop:\n'
    def product(axis,coefficient,target):
        result=f' ldx sm_source_index\n lda sm_source_{axis},x\n sta hp_b\n asl\n lda #0\n sbc #0\n eor #255\n sta hp_b+1\n'
        for j in (0,1):result+=f' lda sm_{coefficient}+{j}\n sta hp_a+{j}\n'
        result+=' jsr hp_int_product\n'
        for j in (0,1):result+=f' lda hp_r+{j}\n sta sm_{target}+{j}\n'
        return result
    code+=product('x','cosine','v_x')+product('z','sine','temp')
    code+=' sec\n'
    for j in (0,1):code+=f' lda sm_v_x+{j}\n sbc sm_temp+{j}\n sta sm_v_x+{j}\n'
    code+=product('x','sine','v_z')+product('z','cosine','temp')
    code+=' clc\n'
    for j in (0,1):code+=f' lda sm_v_z+{j}\n adc sm_temp+{j}\n sta sm_v_z+{j}\n'
    code+=product('y','scale','v_y')
    for axis,cache in [('x','rxbuf'),('y','rybuf'),('z','sz')]:
        code+=f' lda sm_v_{axis}+1\n asl\n lda #0\n sbc #0\n eor #255\n sta sm_ext\n ldy sm_runtime_index\n clc\n'
        for j in (0,1):code+=f' lda sm_origin_{axis}+{j}\n adc sm_v_{axis}+{j}\n sta hc_cam_{axis}{j},y\n'
        code+=f' sta {cache},y\n sta v{axis}rawlo,y\n lda sm_origin_{axis}+2\n adc sm_ext\n sta hc_cam_{axis}2,y\n sta v{axis}rawhi,y\n'
        if axis=='z':code+=' sta szhi,y\n'
    code+=''' inc sm_source_index
 inc sm_runtime_index
 inc sm_vertex
 lda sm_vertex
 cmp #6
 beq +
 jmp sm_vertex_loop
+
 inc sm_instance
 lda sm_instance
'''+f' cmp #{count}\n beq +\n jmp sm_object_loop\n+\n rts\n'
    return code


def topology_kernel():
    code='''sm_collect_face:
 lda faceidx
 jsr sm_resolve
 lda sm_face_instance
 bmi sm_visible_face
 tax
 lda sm_visible,x
 bne sm_visible_face
 clc
 rts
sm_visible_face:
 sec
 rts
sm_draw_face:
 lda sortj
sm_resolve:
 cmp #16
 bcs sm_model_face
 tax
 lda #0
 sta sm_vertex_delta
 lda #255
 sta sm_face_instance
 jmp sm_load_topology
sm_model_face:
 sec
 sbc #16
 pha
 and #7
 sta sm_local_face
 pla
 lsr
 lsr
 lsr
 tay
 sty sm_face_instance
 lda sm_runtime_first,y
 sta sm_vertex_delta
 lda sm_source_face_first,y
 clc
 adc sm_local_face
 tax
sm_load_topology:
'''
    for corner in range(4):code+=f' lda face{corner},x\n clc\n adc sm_vertex_delta\n sta sm_fv{corner}\n'
    return code+' rts\n'


def state(config):
    instances=config['instances'];n=len(instances);copies=1 if config['sharing'] else n
    code=data('sm_source_first',[0 if copies==1 else 6*i for i in range(n)])
    code+=data('sm_source_face_first',[16 if copies==1 else 16+8*i for i in range(n)])
    code+=data('sm_runtime_first',[9+6*i for i in range(n)])
    code+=data('sm_visible',[int(i['visible']) for i in instances])+data('sm_scale_q6',[round(i['scale']*64) for i in instances])
    angles=[round(i['yawDegrees']*65536/360)&65535 for i in instances]
    code+=data('sm_yaw_lo',angles)+data('sm_yaw_hi',[v>>8 for v in angles])
    for axis,public in [('x',0),('y',2),('z',1)]:
        for byte in range(3):code+=data(f'sm_position_{axis}{byte}',[round(i['position'][public]*256)>>(8*byte) for i in instances])
    for name in ('instance','source_index','runtime_index','vertex','ext','vertex_delta','local_face','face_instance'):code+=data('sm_'+name,[0])
    for name in ('scale','sine','cosine','v_x','v_y','v_z','temp'):code+=f'sm_{name}: .word 0\n'
    for axis in 'xyz':code+=f'sm_origin_{axis}: .fill 3,0\n'
    for c in range(4):code+=data(f'sm_fv{c}',[0])
    return code


def source_vertices(config):
    copies=1 if config['sharing'] else len(config['instances']);code='sm_source_begin:\n'
    for axis,public in [('x',0),('y',2),('z',1)]:code+=data('sm_source_'+axis,[p[public] for _ in range(copies) for p in VERTICES])
    return code+'sm_source_end:\n'
