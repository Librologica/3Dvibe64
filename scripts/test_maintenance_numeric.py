"""Compiled Mode7 projection/UV and light regressions; these are not FPS."""
import copy,importlib.util,json,random,sys,tempfile
from pathlib import Path
from py65.devices.mpu6502 import MPU
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'work/q8/src'))
spec=importlib.util.spec_from_file_location('maintenance_q8',ROOT/'work/q8/build.py')
builder=importlib.util.module_from_spec(spec);spec.loader.exec_module(builder)

class Machine:
    def __init__(self,path):
        self.l=builder.labels(path/'3Dvibe64.labels');self.c=MPU()
        raw=(path/'3Dvibe64.prg').read_bytes();o=int.from_bytes(raw[:2],'little')
        self.c.memory[o:o+len(raw)-2]=raw[2:]
    def put(self,n,v,size=1,off=0):
        for j in range(size):self.c.memory[self.l[n]+off+j]=(v>>(8*j))&255
    def get(self,n,size=1,off=0,signed=False):
        v=sum(self.c.memory[self.l[n]+off+j]<<(8*j) for j in range(size))
        return v-(1<<(size*8)) if signed and v>>(size*8-1) else v
    def call(self,n):
        c=self.c;c.pc=self.l[n];c.sp=0xfd;c.memory[0x1fe:0x200]=[0xff,0xfd];c.p=0x20
        for i in range(500000):
            if c.pc==0xfe00:return
            c.step()
        raise AssertionError(('runaway',n,hex(c.pc)))

def trunc(n,d):return (1 if n>=0 else -1)*(abs(n)//d)

def oracle(vertices,uv):
    # Near clipping in camera Q8, then affine attributes in screen Q8. Use
    # independently written integer formulas with canonical outside endpoints.
    source=[list(p)+[u*256,v*256] for p,(u,v) in zip(vertices,uv)]
    near=[]
    for a,b in zip(source[-1:]+source[:-1],source):
        ia,ib=a[2]>=256,b[2]>=256
        if ia!=ib:
            out,ins=(a,b) if not ia else (b,a);f=256-out[2];d=ins[2]-out[2]
            q=[x+trunc((y-x)*f,d) for x,y in zip(out,ins)];q[2]=256;near.append(q)
        if ib:near.append(b[:])
    poly=[[80*256+trunc(x*43520,z),50*256-trunc(y*43520,z),u,v] for x,y,z,u,v in near]
    for axis,bound,lower in [(0,0,True),(0,159*256,False),(1,0,True),(1,99*256,False)]:
        if not poly:break
        output=[]
        inside=lambda p:p[axis]>=bound if lower else p[axis]<=bound
        for a,b in zip(poly[-1:]+poly[:-1],poly):
            ia,ib=inside(a),inside(b)
            if ia!=ib:
                out,ins=(a,b) if not ia else (b,a)
                factor=bound-out[axis];den=ins[axis]-out[axis]
                if den<0:den=-den;factor=-factor
                q=[x+trunc((y-x)*factor,den) for x,y in zip(out,ins)];q[axis]=bound;output.append(q)
            if ib:output.append(b[:])
        poly=output
    for p in poly:
        for axis,center in [(0,80),(1,50)]:p[axis]=(p[axis]+(63 if p[axis]<center*256 else 0))>>6
    area=sum(a[0]*b[1]-b[0]*a[1] for a,b in zip(poly[-1:]+poly[:-1],poly))
    return poly if len(poly)>=3 and area>0 else []

def classifier(k):
    rng=random.Random(0x1101)
    cases=[0,1,49*256,49*256+1,50*256,79*256,80*256,80*256+1,
           (32768-80)*256-1,(32768-80)*256,(32768-80)*256+1,35100*256,
           (1<<24)-1,1<<24,(1<<32)-1,1<<32,(1<<48)-1]
    cases += [rng.randrange(1<<48) for _ in range(200)]
    for axis in [0,1]:
        for negative in [False,True]:
            for value in cases:
                k.put('hc_axis',axis);k.put('hc_sign',128 if negative else 0)
                k.put('hc_num',value,6);k.put('tq_point_code',0);k.call('tq_full_projection')
                screen_negative=negative^bool(axis)
                limit=[(79,80),(49,50)][axis][screen_negative]*256
                bit=[(2,1),(8,4)][axis][screen_negative]
                assert k.get('tq_point_code')==(bit if value>limit else 0)
    return len(cases)*4

def crossing(k):
    rng=random.Random(0x1701101);count=0;visible=0
    positions=[]
    for x in [-4095,-220,-206,-192.30,-192.25,-192,-64,-20,0,20,64,192,192.25,192.30,206,220,4095]:
        for z in [.5,1,17,33,128,256]:positions.append((x,0,z))
    positions += [(rng.uniform(-120,120),rng.uniform(-80,80),rng.uniform(-10,180)) for _ in range(100)]
    for x,y,z in positions:
        vertices=[[round((x+16)*256),round((y+dy)*256),round((z+dz)*256)] for dy,dz in [(-16,-16),(16,-16),(16,16),(-16,16)]]
        for i,p in enumerate(vertices):
            for axis,v in zip('xyz',p):
                for j in range(3):k.put('hc_cam_'+axis+str(j),(v>>(8*j))&255,off=i)
        k.call('hc_project_vertices')
        for face in range(k.l['FACE_COUNT']):
            ids=[k.get('face'+str(j),off=face) for j in range(3)]
            uv=[(k.get('m7_face_u'+str(j),off=face),k.get('m7_face_v'+str(j),off=face)) for j in range(3)]
            expected=oracle([vertices[i] for i in ids],uv)
            k.c.y=face;k.call('load_face_y')
            actual=[]
            if k.c.p&1:
                for i in range(k.get('hc_count')):
                    actual.append([k.get('hc_a_'+a+'lo',off=i)+256*k.get('hc_a_'+a+'hi',off=i) for a in 'xysv'])
            assert actual==expected,dict(position=(x,y,z),face=face,actual=actual,expected=expected)
            visible+=bool(actual);count+=1
    assert visible>30,visible
    return dict(screenAndNearPolygonCases=count,visiblePolygonCases=visible,geometryAndAffineUVExact=True)

def light(k):
    count=0
    for a in range(-128,128):
        for b in range(-64,65):
            k.c.a=a&255;k.c.x=b&255;k.call('m2_light_mul_s6')
            expected=max(-128,min(127,trunc(a*b,64)))
            actual=k.c.a-256 if k.c.a>=128 else k.c.a
            assert actual==expected,(a,b,actual,expected);count+=1
    return count

def main():
    d=json.loads((ROOT/'examples/mode7-cube.json').read_text())
    d['axisConvention']='engine-y-up';d.pop('contract',None);d['camera'].update(position=[0,0,0],rotation=[0,0,0])
    d['meshes'][0]=dict(id='plane',type='mesh',geometry='solid',materialProfile='single',vertices=[[16,-16,-16],[16,16,-16],[16,16,16],[16,-16,16]],faces=[[0,1,2,3],[3,2,1,0]],uv=[[0,0],[0,15],[15,15],[15,0]],texture=d['textures'][0]['id'])
    d['objects'][0].update(mesh='plane',position=[0,0,17],rotation=[0,0,0],angularVelocity=[0,0,0],scale=1)
    results=[]
    with tempfile.TemporaryDirectory(prefix='3dvibe64-maintenance-numeric-') as temp:
        temp=Path(temp)
        for standard in ['pal','ntsc']:
            for lighting,precision,quality in [('none','affine','standard'),('flat','affine','standard'),('gouraud','affine','standard'),('none','perspective','standard'),('flat','perspective','standard'),('gouraud','perspective','standard'),('gouraud','perspective','fast')]:
                scene=copy.deepcopy(d);scene.update(textureLighting=lighting,texturePrecision=precision,textureQuality=quality)
                if lighting=='gouraud':scene['textureCompositor']='C'
                path=temp/f'{standard}-{lighting}-{precision}-{quality}.json';path.write_text(json.dumps(scene))
                out=builder.build(path.with_suffix(''),path,mode=7,standard=standard)
                k=Machine(out);r=dict(standard=standard,lighting=lighting,texturePrecision=precision,textureQuality=quality,classifierCases=classifier(k))
                if lighting=='none' and precision=='affine':r.update(crossing(k))
                if lighting=='flat' and precision=='affine':r['lightProductCases']=light(k)
                results.append(r);print('PASS',r,flush=True)
    print(json.dumps(dict(result='PASS',profiles=results,nativeFPS='measured separately'),indent=2))

if __name__=='__main__':main()
