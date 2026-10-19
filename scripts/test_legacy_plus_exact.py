"""Exact native 6502 kernel checks; CPU callbacks never measure FPS.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
External --control/--exact builds exercise the actual emitted kernels.
"""
import argparse,hashlib,json,random,re,sys,subprocess,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'work'))
from legacy_plus_exact import parse,patch

def labels(p):return {m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',p.read_text(),re.M)}

class Machine:
    def __init__(self,path):
        from py65.devices.mpu6502 import MPU
        self.lab=labels(path/'3Dvibe64.labels');self.mem=[0]*65536
        b=(path/'3Dvibe64.prg').read_bytes();load=int.from_bytes(b[:2],'little');self.mem[load:load+len(b)-2]=b[2:]
        self.cpu=MPU(memory=self.mem)
        for n in range(256):
            q=n*n//4;self.mem[self.lab['sqlo']+n]=q&255;self.mem[self.lab['sqhi']+n]=q>>8
    def put(self,name,value,size=1):
        for n in range(size):self.mem[self.lab[name]+n]=(value>>(8*n))&255
    def get(self,name,size=1):return sum(self.mem[self.lab[name]+n]<<(8*n) for n in range(size))
    def call(self,name,a=0,x=0,y=0):
        c=self.cpu;c.pc=self.lab[name];c.sp=0xfd;c.a=a;c.x=x;c.y=y;c.p=0x20
        self.mem[0x1fe]=0xff;self.mem[0x1ff]=2
        self.put('xyq2_builder_sp',0xfd) if 'xyq2_builder_sp' in self.lab else None
        for i in range(200000):
            if c.pc==0x300:return c.a,c.x,c.y,c.p
            c.step()
        raise AssertionError(('native kernel did not return',name,hex(c.pc)))

def main():
    p=argparse.ArgumentParser();p.add_argument('--control',type=Path);p.add_argument('--exact',type=Path);p.add_argument('--out',type=Path);a=p.parse_args()
    assert __debug__,'Checks must not be optimized away'
    assert parse('all')==['arithmetic','edges','spans','outcodes','convex','integer-edges']
    assert parse('frozen-lighting')==['frozen-lighting'] and parse('none')==[]
    for bad in ['','all,frozen-lighting','arithmetic,arithmetic','none,edges','random']:
        try:parse(bad)
        except ValueError:pass
        else:raise AssertionError(bad)
    assert patch('unchanged','none')==('unchanged',[])
    if not a.control and not a.exact:
        for precision,mode in [('legacy','4'),('q8','4'),('legacy-plus','3')]:
            r=subprocess.run([shutil.which('pwsh'),'-NoProfile','-File',str(ROOT/'work/build-3Dvibe64.ps1'),'-Precision',precision,'-GraphicsMode',mode,'-LegacyPlusOptimizations','all'],capture_output=True,text=True,encoding='utf-8',errors='replace')
            assert r.returncode and 'LegacyPlusOptimizations requires' in r.stdout+r.stderr,(precision,mode,r.stdout,r.stderr)
        print('EXACT_RENDER API PASS; emitted-kernel checks require external --control/--exact builds; no FPS measured');return
    assert a.control and a.exact
    ref=Machine(a.control);opt=Machine(a.exact);rng=random.Random(0x1d0f);counts={}
    # Exhaustive unsigned8x8: every overflow of the quarter-square sum included.
    for x in range(256):
        for y in range(256):
            opt.call('er_mul_u8',a=x,x=y,y=173)
            assert opt.get('prodlo',2)==x*y,(x,y,opt.get('prodlo',2))
            assert opt.cpu.y==173
    counts['unsigned8Products']=65536
    # Signed Q10 products compared with both the native fallback and integer math.
    values=[-32768,-32767,-2049,-1025,-1024,-513,-512,-1,0,1,511,512,1023,1024,32766,32767]
    coefficients=[-1024,-1023,-512,-1,0,1,511,512,1023,1024]
    cases=[(v,k) for v in values for k in coefficients]+[(rng.randrange(-32768,32768),rng.randrange(-1024,1025)) for _ in range(4000)]
    for v,k in cases:
        result=[]
        for m in (ref,opt):
            m.put('p1lo',v,2);m.put('lr_coeff_lo',k&255);m.put('lr_coeff_hi',(k>>8)&255);m.call('lr_mul_s16_q10');result.append(m.get('p1lo',2))
        expected=((abs(v)*abs(k)+512)//1024)*(-1 if (v<0)!=(k<0) else 1)&65535
        assert result[0]==result[1]==expected,(v,k,result,expected)
    counts['signedQ10Products']=len(cases)
    cases=[(n,d) for n in [0,1,255,256,32767,65535] for d in [0,1,2,127,128,255,256,257,32768,65535]]
    cases +=[(rng.randrange(65536),rng.randrange(65536)) for _ in range(4000)]
    for n,d in cases:
        result=[]
        for m in (ref,opt):
            m.put('prodlo',n,2);m.put('p1lo',d,2);m.call('div16u');result.append((m.get('prodlo',2),m.get('crosslo',2)))
        assert result[0]==result[1],(n,d,result)
        if d:assert result[1]==divmod(n,d)
    counts['divisionsWithRemainder']=len(cases)
    # Whole exact-rational edge walk, including >255 denominators and carry.
    for i in range(5000):
        coords=[rng.randrange(637),rng.randrange(397),rng.randrange(637),rng.randrange(397)]
        if i<200:coords=[rng.randrange(160)*4,i%100*4,rng.randrange(160)*4,i%100*4]
        result=[]
        for m in (ref,opt):
            m.put('face_ymin',0);m.put('face_ymax',99);m.put('xyq2_faulted',0)
            m.mem[m.lab['leftb']:m.lab['leftb']+100]=[255]*100;m.mem[m.lab['rightb']:m.lab['rightb']+100]=[0]*100
            for name,value in zip(('xyq2_x0lo','xyq2_y0lo','xyq2_x1lo','xyq2_y1lo'),coords):m.put(name,value,2)
            m.call('trace_edge_convex_xyq2');result.append((m.mem[m.lab['leftb']:m.lab['leftb']+100],m.mem[m.lab['rightb']:m.lab['rightb']+100],m.get('xyq2_faulted')))
        assert result[0]==result[1],(coords,result)
    counts['exactRationalEdges']=5000
    # All ordered pixel endpoint pairs, alternating physical buffers and fill patterns.
    initial=bytes((i*37+19)&255 for i in range(8000));spanCount=0
    for left in range(160):
        for right in range(left,160):
            buf='a' if spanCount%2==0 else 'b';row=spanCount%100;pattern=[0,85,170,255][spanCount%4]
            expected=bytearray(initial);addresses=[]
            for m in (ref,opt):
                base=m.mem[m.lab['row0lo_'+buf]]+256*m.mem[m.lab['row0hi_'+buf]];m.mem[base:base+8000]=initial
                m.put('lowres_scanline_enabled',0);m.put('face_ymin',row);m.put('face_ymax',row);m.put('leftb',left) if row==0 else None
                m.mem[m.lab['leftb']+row]=left;m.mem[m.lab['rightb']+row]=right
                m.put('fillbyte',pattern);m.put('material_screen_cur',0x6f);m.put('material_color_cur',1)
                m.call('fill_bounds_solid_'+buf)
                addresses.append(bytes(m.mem[base:base+8000]))
            assert addresses[0]==addresses[1],('span',left,right,row,buf)
            base=opt.mem[opt.lab['row0lo_'+buf]]+256*opt.mem[opt.lab['row0hi_'+buf]];rowaddr=opt.mem[opt.lab['row0lo_'+buf]+row]+256*opt.mem[opt.lab['row0hi_'+buf]+row]-base
            for x in range(left,right+1):
                at=rowaddr+(x//4)*8;mask=0xc0>>(2*(x%4))
                for delta in (0,1):expected[at+delta]=(expected[at+delta]&(~mask&255))|(pattern&mask)
            assert addresses[1]==expected,('span independent mask oracle',left,right,row,buf)
            spanCount+=1
    counts['solidSpanEndpointPairs']=spanCount
    for i in range(3000):
        x=rng.randrange(-32768,32768);y=rng.randrange(-32768,32768);valid=i%9!=0
        opt.put('projdone',int(valid));opt.put('pxrawlo',x&255);opt.put('pxrawhi',(x>>8)&255);opt.put('pyrawlo',y&255);opt.put('pyrawhi',(y>>8)&255)
        opt.call('er_cache_outcode',x=0,y=173)
        code=(int(x>159)|int(x<0)*2|int(y<0)*4|int(y>99)*8) if valid else 16
        assert opt.get('er_outcodes')==code and opt.cpu.y==173
    counts['vertexOutcodes']=3000
    # Strong convexity checks every point against every edge, including stars.
    stars=[[(80,0),(120,396),(0,150),(159,150),(40,396)],[(0,0),(159,396),(0,396),(159,0)]]
    polygons=stars+[[ (rng.randrange(160),rng.randrange(397)) for _ in range(rng.randrange(3,13))] for _ in range(2000)]
    polygons +=[[(x,y),(x+w,y),(x+w,y+h),(x,y+h)] for x,y,w,h in [(0,0,159,396),(20,2,30,300),(1,1,1,1)]]
    for points in polygons:
        signs=[];n=len(points)
        for i,(x0,y0) in enumerate(points):
            x1,y1=points[(i+1)%n]
            for j,(x2,y2) in enumerate(points):
                if j in (i,(i+1)%n):continue
                cross=(x1-x0)*(y2-y0)-(y1-y0)*(x2-x0);signs.append(0 if cross==0 else 1 if cross>0 else -1)
        expected=0 not in signs and len(set(signs))==1
        opt.put('er_shape_count',n)
        for j,(x,y) in enumerate(points):
            opt.mem[opt.lab['er_shape_x']+j]=x;opt.mem[opt.lab['er_shape_ylo']+j]=y&255;opt.mem[opt.lab['er_shape_yhi']+j]=y>>8
        opt.call('er_convex_shape');assert bool(opt.cpu.p&1)==expected,('convex',points,expected)
    counts['convexShapesIncludingSelfIntersections']=len(polygons)
    result=dict(passed=True,checks=counts,nativeFPSMeasured=False,definition='Actual emitted6502 callbacks for correctness only. Independent integer/mask/convex oracles plus unoptimized native controls. No CPU replay FPS.',sourceSHA256={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in [a.control/'3Dvibe64.prg',a.exact/'3Dvibe64.prg']})
    if a.out:a.out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))

if __name__=='__main__':main()
