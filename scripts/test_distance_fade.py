"""Distance-fade contracts and actual compiled arithmetic/store preservation.
No scene/demo assets. Temporary assembler output is correctness-only, never FPS.
"""
import sys,random,math,subprocess,tempfile,re,shutil,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'work'))
from distance_fade import config,adapt,BAYER

def main():
    assert config()['mode']=='off'
    assert config({'distanceFade':{'mode':'dither','start':12,'end':24}},'off')['mode']=='off'
    for bad in [{'distanceFade':None},{'distanceFade':{'extra':1}},{'distanceFade':{'mode':'on'}},{'distanceFade':{'mode':'off','start':1}},{'distanceFade':{'mode':'dither','start':True}},{'distanceFade':{'mode':'dither','start':12,'end':12}},{'distanceFade':{'mode':'dither','end':32768}}]:
        try:config(bad)
        except ValueError:pass
        else:raise AssertionError(bad)
    for graphics in (4,7):run_profile(graphics)
    for near,far in [(0,1),(254,255),(255,256),(256,257),(4095,4096),(32766,32767),(0,32767)]:run_profile(4,near,far)

def run_profile(graphics,near=32,far=80):
    from py65.devices.mpu6502 import MPU
    source='*=$1000\nSCENE_OBJECT_COUNT=1\nMESH_SOURCE_SHARING_RUNTIME=0\nFACE_COUNT=1\nCAMERA_MOVABLE=1\nBITMAP_B_BASE=$2000\nobjidx=$20\nptr0lo=$22\nptr1lo=$24\nactive_face_first=$26\nactive_face_end=$27\nset_active_object:\n rts\n'
    source+='GRAPHICS_MODE='+str(graphics)+'\n'
    for i,axis in enumerate('xyz'):
        for j,part in enumerate(['lo','hi','ext']):
            source+=f'object_pos_{axis}_{part}=${0x3000+i*3+j:04x}\nexplorer_cam_{axis}_{part}=${0x3100+i*3+j:04x}\n'
    source,parts=adapt(source,{},config({},'dither',near,far))
    source+='\n'.join(parts.values())
    rng=random.Random(34)
    with tempfile.TemporaryDirectory(prefix='3dvibe64-fade-test-') as tmp:
        p=Path(tmp);(p/'kernel.asm').write_text(source)
        cmd=[shutil.which('64tass'),'-a','-B','--vice-labels-numeric','--labels='+str(p/'labels'),'-o',str(p/'kernel.prg'),str(p/'kernel.asm')]
        r=subprocess.run(cmd,capture_output=True,text=True);assert r.returncode==0,r.stdout+r.stderr
        l={m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',(p/'labels').read_text(),re.M)}
        raw=(p/'kernel.prg').read_bytes();o=int.from_bytes(raw[:2],'little');c=MPU();c.memory[o:o+len(raw)-2]=raw[2:]
        def put(n,v,k=1):
            for j in range(k):c.memory[l[n]+j]=v>>(8*j)&255
        def get(n,k=1):return sum(c.memory[l[n]+j]<<(8*j) for j in range(k))
        def call(n):
            c.pc=l[n];c.sp=0xfd;c.memory[0x1fe]=255;c.memory[0x1ff]=1
            for _ in range(40000):
                if c.pc==512:return
                c.step()
            raise AssertionError(('No return',n,hex(c.pc)))
        threshold=[math.ceil(far-(far-near)*k/16)**2 for k in range(17)]
        vector_cases=[([0,0,d*256],[0,0,0]) for d in [0,31,32,33,35,56,77,79,80,81,4095,32767]]
        vector_cases += [([rng.randrange(-32000,32000) for _ in range(3)],[rng.randrange(-32000,32000) for _ in range(3)]) for _ in range(1000)]
        vector_cases += [([0,0,max(0,far-1)*256+fraction],[0,0,0]) for fraction in (0,1,255)]
        vector_cases += [([0,0,far*256+fraction],[0,0,0]) for fraction in (0,1,255)]
        vector_cases += [([0,0,dz*256+17],[-dx*256,dy*256,0]) for dx,dy,dz in [(far//3,far//3,far//3),(far-1,far-1,0),(far//2,far//2,far//2),(max(0,near-1),0,0),(0,0,far//2)]]
        vector_cases += [([32767*256,0,-32768*256],[-32768*256,0,32767*256])]
        for obj,cam in vector_cases:
            for axis,a,b in zip('xyz',obj,cam):put('object_pos_'+axis+'_lo',a,3);put('explorer_cam_'+axis+'_lo',b,3)
            c.p=0x20;call('df_classify');square=sum((abs(a-b)//256)**2 for a,b in zip(obj,cam))
            expected=next((k for k,t in enumerate(threshold) if square>=t),16)
            assert get('df_level')==expected,(obj,cam,square,expected,get('df_level'))
        for _ in range(512):
            level=rng.randrange(17);c.a=level;c.x=rng.randrange(256);c.y=rng.randrange(256);c.p=rng.randrange(256)|0x20
            before=(c.a,c.x,c.y,c.p&0xcf);call('df_set_level')
            assert (c.a,c.x,c.y,c.p&0xcf)==before and get('df_level')==level,('level setter ABI',graphics,level)
        stores=0
        for name in ['ptr0lo','ptr1lo']:
            for level in range(17):
                for addr in [0x2000,0x6200,0x63ff,0x4000,0x9000]:
                    for y in range(8):
                        old=rng.randrange(256);v=rng.randrange(256);put(name,addr,2);c.a=level;call('df_set_level');c.memory[addr+y]=old
                        c.a=v;c.x=91;c.y=y;c.p=rng.randrange(256)&0xc3|0x20;before=c.p;call('df_store_'+name)
                        row=((addr+y)&7)//2;mask=sum(3<<(6-2*x) for x in range(4) if BAYER[row][x]<level)
                        expected=(old^((old^v)&mask)) if addr<0x4000 or 0x6000<=addr<0x8000 else v
                        assert c.memory[addr+y]==expected,(name,level,addr,y,old,v,expected,c.memory[addr+y])
                        assert (c.a,c.x,c.y,c.p&0xcf)==(v,91,y,before&0xcf),(name,level,c.a,c.x,c.y,c.p,before)
                        stores+=1
    print('DISTANCE_FADE PASS',json.dumps(dict(graphicsProfile=graphics,near=near,far=far,setterABICases=512,vectorCases=len(vector_cases),storeCases=stores,registerFlagsPreserved=True,CPUCorrectnessOnly=True)))
if __name__=='__main__':main()
