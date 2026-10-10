"""Explicit experimental profile, actual assembled arithmetic/ABI, no FPS claims.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
"""
import copy,importlib.util,json,random,re,sys,tempfile
from pathlib import Path
from py65.devices.mpu6502 import MPU
ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT/'work/q8'),str(ROOT/'work/q8/src')]
spec=importlib.util.spec_from_file_location('normalized_public_builder',ROOT/'work/normalized_build.py')
builder=importlib.util.module_from_spec(spec);spec.loader.exec_module(builder)
def labels(p):return {m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',p.read_text(),re.M)}
def put(c,l,n,v,b=2):
    for i in range(b):c.memory[l[n]+i]=(v>>(8*i))&255
def get(c,l,n,b=2):return sum(c.memory[l[n]+i]<<(8*i) for i in range(b))
def call(c,l,n):
    c.sp=0xfd;c.memory[0x1fe]=0xff;c.memory[0x1ff]=2;c.pc=l[n]
    for _ in range(200000):
        if c.pc==0x300:return
        c.step()
    raise AssertionError(('routine timeout',n,c.pc))
def project(c,z,axis):
    m=z;e=0
    while m<512:m*=2;e-=1
    while m>=1024:m//=2;e+=1
    r=(680*32768+m//2)//m;mag=min(15871,abs(c)*r>>(15+e))
    sg=(-1 if c<0 else 1)*(-1 if axis else 1)
    return [320,200][axis]+sg*mag,[80,50][axis]+sg*(mag//4)
def test(out):
    lab=labels(out/'3Dvibe64.labels');data=(out/'3Dvibe64.prg').read_bytes();base=int.from_bytes(data[:2],'little');cpu=MPU();cpu.memory[base:base+len(data)-2]=data[2:]
    rng=random.Random(0x651016);n=0
    for _ in range(256):
        a,b=rng.randrange(65536),rng.randrange(65536);put(cpu,lab,'nf_a',a);put(cpu,lab,'nf_b',b);call(cpu,lab,'nf_umultiply');assert get(cpu,lab,'nf_product',4)==a*b
        den=rng.randrange(1,1<<25);r=rng.randrange(den);put(cpu,lab,'nf_den',den,4);put(cpu,lab,'nf_rem',r,4);call(cpu,lab,'nf_ratio');assert get(cpu,lab,'nf_ratio_value')==(r<<16)//den
    for z in (1,2,4,8,16,31,127,128,511,512,513,1023,1024,32767):
        for c in (-32768,-1500,-128,-1,0,1,128,1500,32767):
            for axis in (0,1):
                put(cpu,lab,'nf_pz',z);call(cpu,lab,'nf_prepare_reciprocal');put(cpu,lab,'nf_coord',c);put(cpu,lab,'hc_axis',axis,1);call(cpu,lab,'nf_project')
                q,anchor=project(c,z,axis);assert get(cpu,lab,'hc_q')==q%65536 and get(cpu,lab,'hc_integer')==anchor%65536;n+=1
    # All five clipping planes, near-plane snapping, canonical intersections.
    def plane(p,k):
        x,y,z=p;return (z-128,170*x+80*z,-170*x+79*z,-170*y+50*z,170*y+49*z)[k]
    poly=[[-500,-300,100],[500,-300,1000],[500,300,1000],[-500,300,100]]
    for k in range(5):
        put(cpu,lab,'nf_count',len(poly),1);put(cpu,lab,'nf_near',128);put(cpu,lab,'nf_plane',k,1)
        for i,p in enumerate(poly):
            for a,v in zip('xyz',p):cpu.memory[lab['nf_a_'+a+'lo']+i]=v&255;cpu.memory[lab['nf_a_'+a+'hi']+i]=v>>8&255
        call(cpu,lab,'nf_clip_pass');expected=[]
        for a,b in zip(poly[-1:]+poly[:-1],poly):
            da,db=plane(a,k),plane(b,k)
            if (da<0)!=(db<0):
                outside,inside,do,di=(a,b,da,db) if da<0 else (b,a,db,da)
                t=(-do<<16)//(di-do)
                q=[x+(-1 if y<x else 1)*((abs(y-x)*t+32768)>>16) for x,y in zip(outside,inside)]
                if k==0:q[2]=128
                expected.append(q)
            if db>=0:expected.append(b[:])
        actual=[]
        for i in range(get(cpu,lab,'nf_count',1)):
            row=[]
            for a in 'xyz':
                v=cpu.memory[lab['nf_a_'+a+'lo']+i]+256*cpu.memory[lab['nf_a_'+a+'hi']+i];row.append(v-65536 if v>=32768 else v)
            actual.append(row)
        assert actual==expected,(k,actual,expected);poly=expected
    return n
with tempfile.TemporaryDirectory(prefix='normalized16-public-') as temp:
    temp=Path(temp);projections=0
    for mode in range(1,8):
        scene=ROOT/f'examples/q8/two-objects-mode{mode}.json'
        for standard in ('pal','ntsc'):
            out=builder.build(temp/f'm{mode}-{standard}',scene,mode,standard,'interactive')
            info=json.loads((out/'build.json').read_text());assert info['precision']=='normalized16' and info['experimental']
            assert 'hc_project_axis' not in labels(out/'3Dvibe64.labels')
            if mode==4:projections+=test(out)
        # Identical regeneration from maintained source, no frozen ASM foundation.
        out=builder.build(temp/f'm{mode}-rebuild',scene,mode,'pal','interactive')
        assert (out/'3Dvibe64.prg').read_bytes()==(temp/f'm{mode}-pal/3Dvibe64.prg').read_bytes()
    base=json.loads((ROOT/'examples/q8/two-objects-mode7.json').read_text())
    for field,value in [('texturePrecision','perspective'),('textureQuality','fast'),('textureLOD','gradual')]:
        bad=copy.deepcopy(base);bad[field]=value
        try:builder.validate(bad,7,'pal',temp/field)
        except ValueError:pass
        else:raise AssertionError(('unsupported accepted',field))
    for camera in ('auto','unknown'):
        try:builder.build(temp/'rejected-camera',ROOT/'examples/q8/two-objects-mode4.json',4,camera=camera)
        except ValueError as e:assert 'NORMALIZED_CAMERA' in str(e)
        else:raise AssertionError(('unsupported camera accepted',camera))
    print(json.dumps(dict(result='PASS',builds=21,standards=['pal','ntsc'],cleanRebuildModes=7,projectionCases=projections,multiplyCases=512,ratioCases=512,clipStages=10,fixedDifferences=0,nativeFPS='separate qualification')))
