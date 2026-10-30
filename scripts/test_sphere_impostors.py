"""Emitted6502 checks against independent circle/projection/transform arithmetic.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
CPU execution is a correctness check, never an FPS measurement.
"""
import argparse,json,math,random,re,subprocess,sys
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'work'))


class Machine:
    def __init__(self,path):
        from py65.devices.mpu6502 import MPU
        self.lab={m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',(path/'3Dvibe64.labels').read_text(),re.M)}
        self.mem=[0]*65536;data=(path/'3Dvibe64.prg').read_bytes();start=int.from_bytes(data[:2],'little');self.mem[start:start+len(data)-2]=data[2:]
        self.cpu=MPU(memory=self.mem)
        for n in range(256):
            self.mem[self.lab['sqlo']+n]=(n*n//4)&255;self.mem[self.lab['sqhi']+n]=(n*n//4)>>8
    def put(self,name,value,size=1):
        for n in range(size):self.mem[self.lab[name]+n]=(value>>(n*8))&255
    def get(self,name,size=1,signed=False):
        value=sum(self.mem[self.lab[name]+n]<<(n*8) for n in range(size))
        return value-(1<<(size*8)) if signed and value>>(size*8-1) else value
    def call(self,name):
        c=self.cpu;c.pc=self.lab[name];c.p=0x20;c.sp=0xfd;self.mem[0x1fe]=255;self.mem[0x1ff]=2
        for i in range(1000000):
            if c.pc==0x300:return bool(c.p&1)
            c.step()
        raise AssertionError(('Native API failed to return',name,hex(c.pc)))


def mask(cx,cy,radius,trim):
    # Work in the complete local disc before clipping; otherwise isolated
    # columns at the viewport edge would be incorrectly removed.
    fx,fy=cx//4,cy//4;reach=(radius+3)//4+2
    xs=np.arange(fx-reach,fx+reach+1);ys=np.arange(fy-reach,fy+reach+1)
    y,x=np.meshgrid(ys,xs,indexing='ij');inside=(4*x-cx)**2+(4*y-cy)**2<radius*radius
    if trim:
        inside[inside.sum(axis=1)<=1]=False;inside[:,inside.sum(axis=0)<=1]=False
    if radius<6 and not inside.any():inside[reach+(cy%4>=2),reach+(cx%4>=2)]=True
    result=np.zeros((100,160),dtype=bool);yy,xx=np.where(inside);xx=xs[xx];yy=ys[yy]
    valid=(xx>=0)&(xx<160)&(yy>=0)&(yy<100);result[yy[valid],xx[valid]]=True
    return result


def circles(m):
    rng=random.Random(0xc1ac1e);original=list(m.mem);total=0
    samples=[(320+fx,200+fy,r,t) for r in (1,2,3,4,5,6,7,8,31,63,124,128,200,252) for fx in range(4) for fy in range(4) for t in (0,1)]
    samples += [(x,y,r,1) for r in (4,17,64,124,252) for x,y in ((0,0),(636,0),(0,396),(636,396),(-r+1,200),(636+r-1,200),(320,-r+1),(320,396+r-1))]
    samples += [(x,y,r,t) for r in range(1,6) for t in (0,1) for x,y in ((-2,0),(0,-2),(638,396),(636,398))]
    samples += [(rng.randrange(-256,1024),rng.randrange(-256,1024),rng.randrange(1,253),rng.randrange(2)) for _ in range(200)]
    for case,(cx,cy,r,trim) in enumerate(samples):
        m.mem[:]=original;buf=case&1;pattern=(0,85,170,255,57,78)[case%6]
        for name,value in [('drawbuf',buf),('fillbyte',pattern),('material_screen_cur',0x6f),('material_color_cur',1),('lowres_scanline_enabled',0)]:
            if name in m.lab:m.put(name,value)
        base=0x6000 if buf==0 else m.lab['BITMAP_B_BASE'];initial=bytes((i*37+19)&255 for i in range(8000));m.mem[base:base+8000]=initial
        m.put('er_circle_xq2',cx,2);m.put('er_circle_yq2',cy,2);m.put('er_circle_radius_q2',r);m.put('er_circle_trim_tips',trim)
        ok=m.call('er_circle_draw');expected_mask=mask(cx,cy,r,trim);assert ok==bool(expected_mask.any()),(cx,cy,r,trim,ok,m.get('er_sphere_status'))
        expected=bytearray(initial)
        for y,x in np.argwhere(expected_mask):
            offset=(y//4)*320+(x//4)*8+(y%4)*2;bits=192>>(2*(x%4))
            for row in (0,1):expected[offset+row]=(expected[offset+row]&(~bits&255))|(pattern&bits)
        actual=bytes(m.mem[base:base+8000])
        assert actual==expected,(case,cx,cy,r,trim,[(i,a,b) for i,(a,b) in enumerate(zip(actual,expected)) if a!=b][:10])
        total+=1
    for radius,cx,cy in ((0,320,200),(253,320,200),(255,320,200),(4,-32768,0),(4,32767,0),(4,0,-32768),(4,0,32767)):
        m.mem[:]=original;m.put('er_circle_radius_q2',radius);m.put('er_circle_xq2',cx,2);m.put('er_circle_yq2',cy,2)
        old=list(m.mem);assert not m.call('er_circle_draw')
        for lo,hi in ((0x2000,0x3f40),(0x6000,0x7f40),(0x400,0x800),(0x5c00,0x6000),(0xd800,0xdc00)):assert m.mem[lo:hi]==old[lo:hi]
    return total


def projection(m):
    rng=random.Random(0x5fee);count=0;f=m.lab['PROJ_FOCAL']
    def projected(v,z,offset,orientation):
        n=abs(v)
        while n>255:n//=2;z=max(1,z//2)
        q,r=divmod(f*4*n,z);q+=2*r>=z
        return offset+orientation*(-1 if v<0 else 1)*q
    cases=[(0,0,z,r) for z in (127,128,129,256,2048,32767) for r in (0,1,20,64,1024,16383,16384,65535)]
    cases += [(rng.randrange(-250,251),rng.randrange(-160,161),rng.randrange(128,32768),rng.randrange(1,300)) for _ in range(400)]
    for x,y,z,r in cases:
        for name,value in [('x',x),('y',y),('z',z)]:m.put('er_sphere_camera_'+name,value,2)
        m.put('er_sphere_radius',r,2);m.put('er_sphere_min_radius_q2',0)
        ok=m.call('er_sphere_project')
        rq=(2*f*4*r+z)//(2*z)
        valid=z>=128 and 0<r<16384 and 0<rq<=252
        assert ok==valid,(x,y,z,r,rq,ok,m.get('er_sphere_status'))
        if ok:
            assert m.get('er_circle_radius_q2')==rq
            assert m.get('er_circle_xq2',2,True)==projected(x,z,320,1)
            assert m.get('er_circle_yq2',2,True)==projected(y,z,200,-1)
        count+=1
    for z in (128,32767):
        m.put('er_sphere_camera_z',z,2);m.put('er_sphere_camera_x',0,2);m.put('er_sphere_camera_y',0,2);m.put('er_sphere_radius',1,2);m.put('er_sphere_min_radius_q2',4)
        assert m.call('er_sphere_project') and m.get('er_circle_radius_q2')>=4
    return count


def world(m):
    rng=random.Random(0x103d);count=0
    def product(v,k):return ((abs(v)*abs(k)+512)//1024)*(-1 if (v<0)!=(k<0) else 1)
    for _ in range(160):
        camera=[rng.randrange(-200*256,200*256) for a in 'xyz'];point=[v+rng.randrange(-150*256,150*256) for v in camera]
        yaw=rng.randrange(65536);pitch=rng.randrange(65536)
        m.put('explorer_cam_yaw',yaw>>8);m.put('explorer_cam_yaw_frac',yaw&255);m.put('explorer_cam_pitch',pitch>>8);m.put('explorer_cam_pitch_frac',pitch&255)
        for axis,c,p in zip('xyz',camera,point):
            m.put('explorer_cam_'+axis+'_lo',c,3);m.put('er_sphere_world_'+axis,p,3)
        m.call('er_sphere_begin_view');assert m.call('er_sphere_world_to_camera')
        coeff=[int.from_bytes(bytes((m.mem[m.lab['lr_coeff_lo']+i],m.mem[m.lab['lr_coeff_hi']+i])),'little',signed=True) for i in range(4)]
        x,y,z=[(p-c)//16 for p,c in zip(point,camera)];c,s,cp,sp=coeff
        vx=product(x,c)-product(z,s);vz=product(z,c)+product(x,s)
        vy=product(y,cp)-product(vz,sp);vz=product(vz,cp)+product(y,sp)
        assert [m.get('er_sphere_camera_'+a,2,True) for a in 'xyz']==[vx,vy,vz]
        count+=1
    for p,c in ((1024*256,0),(-1024*256-1,0),(0x7fffff,-0x800000),(-0x800000,0x7fffff)):
        for a in 'xyz':m.put('er_sphere_world_'+a,0,3);m.put('explorer_cam_'+a+'_lo',0,3)
        m.put('er_sphere_world_x',p,3);m.put('explorer_cam_x_lo',c,3)
        m.put('er_sphere_valid',1)
        assert not m.call('er_sphere_world_to_camera') and m.get('er_sphere_status')==6 and m.get('er_sphere_valid')==0
    return count


def main():
    p=argparse.ArgumentParser();p.add_argument('--build',type=Path);p.add_argument('--out',type=Path);args=p.parse_args()
    from sphere_impostors import install
    try:install('ENGINE_CIRCLE_SPHERES = 1\n')
    except ValueError:pass
    else:raise AssertionError('Duplicate integration accepted')
    if not args.build:
        base=['pwsh','-NoProfile','-File',str(ROOT/'work/build-3Dvibe64.ps1'),'-SphereRenderer','circles']
        profiles=[[],['-Precision','q8'],['-Precision','legacy-plus','-GraphicsMode','7'],
                  ['-Precision','legacy-plus','-GraphicsMode','4','-CameraMode','walkLite','-MemoryLayout','high-basic-v2','-CameraViewport','normal'],
                  ['-Precision','legacy-plus','-GraphicsMode','6','-CameraMode','fixed','-MemoryLayout','high-basic-v2','-NoFpsOverlay']]
        for profile in profiles:
            result=subprocess.run(base+profile,cwd=ROOT,capture_output=True,text=True)
            assert result.returncode and 'SphereRenderer circles requires' in result.stdout+result.stderr,profile
        print('SPHERE API host contract PASS (duplicate install and five unsupported profiles); emitted6502 checks require --build; no FPS measured');return
    m=Machine(args.build.resolve());result=dict(circleFramebufferCases=circles(m),projectionCases=projection(m),worldTransformCases=world(m),FPSMeasured=False,oracle='Independent strict circle coverage, complete pixel masks, integer perspective quotient, signed Q10 products')
    if args.out:args.out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))

if __name__=='__main__':main()
