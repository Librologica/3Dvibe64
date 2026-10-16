"""LIGHT-01: deterministic host-only Q8 static vertex light and shadow bake.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
Input uses the bounded profile's local X/up/forward mesh, clockwise after
conversion to public X/forward/up. Identity object placement is required.
All arithmetic after Q8 conversion is integer; no runtime light evaluator.
"""
import copy
import hashlib
import json
import math


def digest(value):
    return hashlib.sha256(json.dumps(value,sort_keys=True,separators=(',',':'),ensure_ascii=False).encode('utf-8')).hexdigest().upper()


def q8(value,low,high):
    if type(value) not in (int,float) or not math.isfinite(value) or not low<=value<=high or value*256!=round(value*256):
        raise ValueError('Expected finite Q8 value in range '+str((low,high)))
    return round(value*256)


def sub(a,b):return tuple(x-y for x,y in zip(a,b))
def dot(a,b):return sum(x*y for x,y in zip(a,b))
def cross(a,b):return (a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0])


def segment_hits(origin,target,triangle):
    """Exact two-sided segment/triangle predicate; opaque edges included.
    Segment endpoints are excluded, so a receiver on a wall does not shadow
    itself at t=0. Integer determinant ratios avoid floating tolerances.
    """
    a,b,c=triangle;direction=sub(target,origin);e1=sub(b,a);e2=sub(c,a)
    p=cross(direction,e2);det=dot(e1,p)
    if det==0:return False
    tvec=sub(origin,a);u=dot(tvec,p);q=cross(tvec,e1);v=dot(direction,q);t=dot(e2,q)
    if det<0:det,u,v,t=-det,-u,-v,-t
    return 0<=u<=det and 0<=v and u+v<=det and 0<t<det


def geometry(scene):
    if not isinstance(scene.get('meshes'),list) or len(scene['meshes'])!=1 or not isinstance(scene.get('objects'),list) or len(scene['objects'])!=1:
        raise ValueError('Static bake currently requires one mesh and one identity object')
    mesh=scene['meshes'][0];obj=scene['objects'][0]
    if obj.get('mesh')!=mesh['id'] or obj.get('position')!=[0,0,0] or obj.get('rotation')!=[0,0,0] or obj.get('scale')!=1 or obj.get('angularVelocity')!=[0,0,0] or obj.get('visible') is not True:
        raise ValueError('Static bake requires visible identity placement and zero angular velocity')
    vertices=[]
    for p in mesh['vertices']:
        if not isinstance(p,list) or len(p)!=3:raise ValueError('Expected mesh XYZ triples')
        vertices.append(tuple(q8(p[i],-127,127) for i in (0,2,1)))
    faces=mesh['faces']
    if not isinstance(faces,list) or not 1<=len(faces)<=254:raise ValueError('Expected1..254 source faces')
    triangles=[]
    for face in faces:
        if not isinstance(face,list) or len(face)!=3 or any(type(i) is not int or not 0<=i<len(vertices) for i in face):raise ValueError('Static bake requires valid triangles')
        triangles.append(tuple(vertices[i] for i in face))
    return triangles


def validate(config,scene,table,forbidden=()):
    if not isinstance(config,dict) or set(config)!={'schema','enabled','ambient','biasWU','receivers','occluders','lights'} or type(config['schema']) is not int or config['schema']!=1 or type(config['enabled']) is not bool:
        raise ValueError('Static light schema1 requires enabled, ambient, biasWU, receivers, occluders and lights')
    q8(config['ambient'],0,32);q8(config['biasWU'],1/256,.25)
    triangles=geometry(scene)
    if len(table)!=len(triangles):raise ValueError('Static light/source surface count mismatch')
    for name in ('receivers','occluders'):
        values=config[name]
        if not isinstance(values,list) or any(type(i) is not int or not 0<=i<len(triangles) or i in forbidden for i in values) or len(values)!=len(set(values)):
            raise ValueError('Invalid, duplicate or mobile/reserved '+name)
        for i in values:
            a,b,c=triangles[i]
            if dot(cross(sub(b,a),sub(c,a)),cross(sub(b,a),sub(c,a)))==0:raise ValueError('Degenerate bake geometry')
    if any(table[i]['mode']!='gouraud' for i in config['receivers']):raise ValueError('This checkpoint bakes only existing untextured Gouraud receivers')
    lights=config['lights']
    if not isinstance(lights,list) or not 1<=len(lights)<=8:raise ValueError('Configure1..8 static point lights')
    ids=set()
    for light in lights:
        if not isinstance(light,dict) or set(light)!={'id','position','radiusWU','strength'} or not isinstance(light['id'],str) or not light['id'] or light['id'] in ids:raise ValueError('Unique static light id required')
        ids.add(light['id'])
        if not isinstance(light['position'],list) or len(light['position'])!=3:raise ValueError('Expected public X/forward/up light position')
        for v in light['position']:q8(v,-127,127)
        q8(light['radiusWU'],1,128);q8(light['strength'],0,64)
    return config


def sample(point,normal,config,triangles):
    length=math.isqrt(dot(normal,normal))
    if length==0:raise ValueError('Zero receiver normal')
    bias=q8(config['biasWU'],1/256,.25)
    origin=tuple(p+(1 if n>=0 else -1)*((abs(n)*bias+length//2)//length) for p,n in zip(point,normal))
    total=q8(config['ambient'],0,32);parts=[]
    for lamp in config['lights']:
        light=tuple(q8(v,-127,127) for v in lamp['position']);delta=sub(light,point)
        distance=math.isqrt(dot(delta,delta));radius=q8(lamp['radiusWU'],1,128)
        cosine=dot(normal,delta);blocker=None;amount=0
        if distance and distance<radius and cosine>0:
            blocker=next((face for face in sorted(config['occluders']) if segment_hits(origin,light,triangles[face])),None)
            if blocker is None:
                cosine=min(cosine,length*distance)
                amount=q8(lamp['strength'],0,64)*cosine*(radius-distance)//(length*distance*radius)
                total+=amount
        parts.append(dict(light=lamp['id'],distanceQ8=distance,normalDot=cosine,blocker=blocker,contributionQ8=amount))
    level=min(32,max(0,(total+128)//256))
    return level,dict(pointQ8=point,normal=normal,biasOriginQ8=origin,totalQ8=total,level=level,lights=parts)


def encode(records):
    if len(records)>254:raise ValueError('Too many compact light records')
    out=bytearray(b'LB01'+bytes([len(records)]));seen=set()
    for r in records:
        face=r['face'];levels=r['levels']
        if type(face) is not int or not 0<=face<=253 or face in seen or not isinstance(levels,list) or len(levels)!=3 or any(type(v) is not int or not 0<=v<=32 for v in levels):raise ValueError('Invalid compact light record')
        seen.add(face);out.extend([face,*levels])
    return bytes(out)


def decode(payload):
    if not isinstance(payload,bytes) or payload[:4]!=b'LB01' or len(payload)<5 or len(payload)!=5+payload[4]*4:raise ValueError('Invalid compact light payload')
    records=[dict(face=payload[i],levels=list(payload[i+1:i+4])) for i in range(5,len(payload),4)]
    if encode(records)!=payload:raise ValueError('Noncanonical light payload')
    return records


def compile_bake(scene,config,table,forbidden=()):
    validate(config,scene,table,forbidden);triangles=geometry(scene);result=copy.deepcopy(table)
    records=[];samples=[]
    if config['enabled']:
        for face in sorted(config['receivers']):
            a,b,c=triangles[face]
            # The profile mesh has clockwise public winding (X,Z,Y swap).
            normal=tuple(-v for v in cross(sub(b,a),sub(c,a)))
            levels=[]
            for corner,p in enumerate(triangles[face]):
                level,detail=sample(p,normal,config,triangles);levels.append(level)
                samples.append(dict(face=face,corner=corner,**detail))
            result[face]['levels']=levels
            records.append(dict(face=face,levels=levels))
    payload=encode(records)
    report=dict(schema=1,model='integer Q8 normalized Lambert * linear radius falloff + ambient; exact two-sided static segment visibility',
        geometrySpace='profile mesh X/up/forward converted to public X/forward/up; clockwise source winding',
        configuration=config,forbiddenFaces=sorted(forbidden),
        geometrySHA256=digest(scene),configurationSHA256=digest(config),inputSurfacesSHA256=digest(table),
        outputSurfacesSHA256=digest(result),payloadSHA256=hashlib.sha256(payload).hexdigest().upper(),
        payloadBytes=len(payload),records=records,samples=samples,
        runtime='existing Gouraud per-corner byte tables; no new runtime code or resident buffers',
        limitations='vertex-sampled static shadows, interpolated by existing Gouraud shader; textured/flat surfaces and mobile actors/door are not light receivers')
    return result,payload,report
