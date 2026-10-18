"""Self-contained Mode7 projective opt-in and assembled arithmetic contracts.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. Run through the clean-copy release runner.
"""
import importlib.util,json,random,re,statistics,sys,tempfile
from pathlib import Path
from py65.devices.mpu6502 import MPU

ROOT=Path(__file__).resolve().parents[1]
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'work/q8/src'))
spec=importlib.util.spec_from_file_location('public_q8',ROOT/'work/q8/build.py')
builder=importlib.util.module_from_spec(spec);spec.loader.exec_module(builder)

class Machine:
    def __init__(self,build):
        self.lab=builder.labels(build/'3Dvibe64.labels');self.cpu=MPU()
        raw=(build/'3Dvibe64.prg').read_bytes();load=int.from_bytes(raw[:2],'little')
        self.cpu.memory[load:load+len(raw)-2]=raw[2:]
    def put(self,name,v,size=1,off=0):
        for j in range(size):self.cpu.memory[self.lab[name]+off+j]=(v>>(8*j))&255
    def get(self,name,size=1,off=0):
        return sum(self.cpu.memory[self.lab[name]+off+j]<<(8*j) for j in range(size))
    def call(self,name):
        self.cpu.pc=self.lab[name];self.cpu.sp=0xfd
        self.cpu.memory[0x1fe]=0xff;self.cpu.memory[0x1ff]=0xfd
        self.cpu.p=0x20
        start=self.cpu.processorCycles
        for _ in range(200000):
            if self.cpu.pc==0xfe00:return self.cpu.processorCycles-start
            self.cpu.step()
        raise AssertionError(('routine did not return',name,hex(self.cpu.pc)))

def arithmetic(k,rng):
    counts={}
    cases=[(0,1),((1<<48)-1,1),((1<<48)-1,(1<<24)-1)]
    cases += [(rng.randrange(1<<rng.randrange(1,49)),rng.randrange(1,1<<24)) for _ in range(2000)]
    for a,b in cases:
        k.put('hc_num',a,6);k.put('hc_divisor',b,3);k.call('hc_div40')
        assert (k.get('hc_num',6),k.get('hc_remainder',4))==divmod(a,b),(a,b)
    counts['assembled48x24']=len(cases)
    for _ in range(2500):
        a=rng.randrange(65536);b=rng.randrange(65536)
        k.put('ps_a',a,2);k.put('ps_b',b,2);k.call('ps_mul16')
        assert k.get('ps_prod',4)==a*b
        delta=rng.choice([0,a,-a,rng.randrange(-(1<<23),1<<23)])
        factor=rng.choice([b,rng.randrange(1<<24)]);den=rng.randrange(1,1<<24)
        k.put('hc_delta',delta&0xffffff,3);k.put('hc_factor',factor,3);k.put('hc_den',den,3)
        k.call('hq_ratio_product');q,r=divmod(abs(delta)*factor,den)
        assert k.get('hc_result',3)==((-q if delta<0 else q)&0xffffff)
        assert k.get('hc_remainder',3)==r
    counts['assembledProducts']=5000
    for i in range(2500):
        n=rng.randrange(1,160);a=rng.randrange(65536);b=rng.randrange(65536)
        k.put('m7_den',n);k.put('hc_delta',(b-a)&0xffffff,3);k.call('ps_setup')
        q,r=divmod(b-a,n)
        assert k.get('hc_result',2)==q&65535
        assert k.get('hc_remainder',2)==r
    counts['assembledSignedSpans']=2500
    # Cache/identity/miss/far endpoint: compare encoder to independent integer math.
    depths=[256,257,65535,65536]+[rng.randrange(256,65537) for _ in range(2500)]
    for depth in depths:
        for repeat in range(2):
            u=rng.randrange(65281);v=rng.randrange(65281)
            k.put('hc_depth',depth,3);k.put('hc_out_s',u,2);k.put('hc_out_v',v,2)
            k.call('ps_encode');w=8388608//depth
            assert (k.get('hc_out_w',2),k.get('hc_out_s',2),k.get('hc_out_v',2))==(w,u*w//32768,v*w//32768)
    assert k.get('ps_fault')==0
    counts['assembledEncoding']=len(depths)*2
    return counts

def sampler(k,rng):
    count=0;cycles=[]
    for i in range(300):
        n=rng.randrange(1,160)
        if i<150:
            w=rng.randrange(256,4000)
            a=[rng.randrange(2*w),rng.randrange(2*w),w]
            b=[max(0,min(65535,a[j]+rng.randrange(-16,17)*n)) for j in range(2)]
            b+=[max(256,min(8000,w+rng.randrange(-16,17)*n))]
        else:
            a=[rng.randrange(65536),rng.randrange(65536),rng.choice([0,1,255,256,8191,8192,32768,65535])]
            b=[rng.randrange(65536),rng.randrange(65536),rng.randrange(1,65536)]
        for ch in range(3):
            q,r=divmod(b[ch]-a[ch],n)
            for name,val in [('cur0',a[ch]&255),('cur1',a[ch]>>8),('step0',q&255),('step1',(q>>8)&255),('rem',r),('err',0)]:
                k.put('ps_'+name,val,off=ch)
        k.put('m7_den',n)
        if 'ri_select' in k.lab:k.call('ri_select')
        for x in range(n+1):
            expected=[a[ch]+(b[ch]-a[ch])*x//n for ch in range(3)]
            k.cpu.x=53;cycles.append(k.call('ps_sample'));assert k.cpu.x==53
            for ch in range(2):
                q=((expected[ch]*128//expected[2])&255) if expected[2] else 0
                assert k.get('m7_u',off=ch)==q,(i,x,ch,expected)
            count+=1
            if x<n:
                k.cpu.x=53;k.call('ps_advance');assert k.cpu.x==53
    return dict(samples=count,sampleMeanInstructionCycles=statistics.mean(cycles))

def main():
    rng=random.Random(0x1607);results={}
    original=json.loads((ROOT/'examples/mode7-perspective-cube.json').read_text())
    with tempfile.TemporaryDirectory(prefix='3dvibe64-perspective-') as temporary:
        p=Path(temporary)
        for lighting in ('none','flat','gouraud'):
            d=json.loads(json.dumps(original));d['textureLighting']=lighting
            if lighting!='gouraud':d.pop('textureCompositor',None)
            scene=p/(lighting+'.json');scene.write_text(json.dumps(d))
            out=builder.build(p/lighting,scene,mode=7)
            k=Machine(out);results[lighting]=dict(hash=builder.sha(out/'3Dvibe64.prg'),bytes=(out/'3Dvibe64.prg').stat().st_size)
            if lighting=='gouraud':results['arithmetic']=arithmetic(k,rng)
            results[lighting].update(sampler(k,rng))
            # Fault is sticky and an unsupported depth cannot divide by zero.
            k.put('ps_fault',0);k.put('hc_depth',0,3);k.call('ps_encode');assert k.get('ps_fault')==1
        d=json.loads(json.dumps(original));d['texturePrecision']='invalid'
        scene=p/'invalid.json';scene.write_text(json.dumps(d))
        try:builder.build(p/'bad',scene,mode=7)
        except ValueError as e:assert 'TEXTURE_PRECISION' in str(e)
        else:raise AssertionError('Invalid precision accepted')
        assert not (p/'bad').exists()
        # Multiple repeat samplers must patch the address JMP, not the preceding
        # projective JSR. The constant page is discovered, not texture-ID coded.
        d=json.loads(json.dumps(original));d['textureLighting']='none';d.pop('textureCompositor',None)
        d['textures'][0]['repeat']=[1,1]
        second=json.loads(json.dumps(d['textures'][0]));second['id']='uniform';second['texels']=[3]*256;second['repeat']=[4,8]
        d['textures'].append(second)
        d['meshes'][0]['faceTextures']=['uniform',None,'uniform',None,'uniform',None]
        scene=p/'mixed.json';scene.write_text(json.dumps(d));out=builder.build(p/'mixed',scene,mode=7)
        k=Machine(out)
        meta=json.loads((out/'build.json').read_text());assert meta['uniformTexturePigments']==[0,3]
        tested=0
        for face in range(k.lab['FACE_COUNT']):
            k.cpu.y=face;k.call('gouraud_load_face_raw_shades_y')
            assert k.cpu.memory[k.lab['m7_sample']]==0x20
            target=k.cpu.memory[k.lab['m7_sample']+1]+256*k.cpu.memory[k.lab['m7_sample']+2]
            assert target==k.lab['ps_sample']
            tid=k.get('m7_face_texture',off=face)
            for u,v in ((0,0),(17,33),(127,128),(255,255)):
                # W32768 makes encoder/reconstruction an exact identity.
                for ch,value in enumerate((u*256,v*256,32768)):
                    k.put('ps_cur0',value&255,off=ch);k.put('ps_cur1',value>>8,off=ch)
                k.call('m7_sample')
                tex=d['textures'][tid];ru,rv=tex['repeat']
                address=(((v*rv//16)&15)<<4)|((u*ru//16)&15)
                assert k.cpu.a==tex['texels'][address],(face,tid,u,v,k.cpu.a,address)
                tested+=1
        results['mixedRepeatAndUniformSamples']=tested
    print(json.dumps(results,indent=2));print('TEXTURE_PERSPECTIVE assembled arithmetic/recurrence/profile: PASS')

if __name__=='__main__':main()
