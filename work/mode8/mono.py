"""Small viewport fixed model, independent of the generated ASM execution."""
import math
from .directions import DIR
from .walls import walls

W,H,N=128,144,32
HALF=72
TAN=math.tan(math.pi/6)
COARSE=[round(math.atan((2*i+1-N)*TAN/N)*512/math.tau) for i in range(N)]
FINE=[round(math.atan((2*i+1-W)*TAN/W)*512/math.tau) for i in range(W)]

def trace(g,pose,pixel,fine=False,overhead=False):
    off=(FINE if fine else COARSE)[pixel];px,py,yaw=pose;d=DIR[(yaw+off)%512]
    corr=round(256*math.cos(off*math.tau/512));nx=bool(d['sign']&1);ny=bool(d['sign']&2)
    x,y=px>>8,py>>8;sx=d['dx']*(px&255)//256;sy=d['dy']*(py&255)//256
    if not nx:sx=d['dx']-sx
    if not ny:sy=d['dy']-sy
    if not d['ax']:sx=65535
    if not d['ay']:sy=65535
    mat=g[y*32+x]
    if overhead and mat>=9:t=0;side=0;plane=255;steps=0
    else:
        for steps in range(1,65):
            side=int(sy<sx)
            if side:t=sy;y+=-1 if ny else 1;sy=min(65535,sy+d['dy'])
            else:t=sx;x+=-1 if nx else 1;sx=min(65535,sx+d['dx'])
            mat=g[y*32+x]
            if mat:break
        else:raise AssertionError('DDA did not stop')
        plane=y+ny+64 if side else x+nx
    r=dict(t=t,depth=min(65535,t*corr//256),side=side,plane=plane,cell=y*32+x,mat=mat,steps=steps,nx=nx,ny=ny)
    if overhead and mat>=9:
        for _ in range(5):
            if sy<sx:et=sy;y+=-1 if ny else 1;sy+=d['dy'];ep=y+ny+64
            else:et=sx;x+=-1 if nx else 1;sx+=d['dx'];ep=x+nx
            if g[y*32+x]!=mat:
                r.update(exitdepth=et*corr//256,exitplane=ep);return r
        raise AssertionError('door exit did not stop')
    return r

def raw_height(dep):
    dist=(min(1023,dep//16)+.5)/16
    h=128/TAN/dist
    def clip(v):return max(0,min(H,math.floor(v+.5)))
    return clip(HALF-2*h),clip(HALF+h),clip(HALF-h)
def qheight(dep):
    dist=(min(1023,dep//16)+.5)/16
    return min(16384,math.floor(4096/TAN/dist+.5))
def slope(plane,pose):
    axis=int(bool(plane&64));den=(plane&63)*256-pose[axis];a=pose[2]*math.tau/512
    comp=round(64*(-math.sin(a) if axis else math.cos(a)))
    if not den:return 0
    return min(4095,abs(comp)*512//abs(den))*(-1 if comp*den<0 else 1)
def corrected(plane,depth,pose,pixel,fine=False):
    count=W if fine else N;off=(FINE if fine else COARSE)[pixel]
    k=(math.tan(off*math.tau/512)-(2*pixel+1-count)*TAN/count)*N/TAN
    s=slope(plane,pose);mag=abs(s)*round(abs(k)*256)//256
    h=max(0,qheight(depth)+(-mag if s*k>0 else mag))
    return h,s
def project(h):return max(0,HALF-(h+7)//16),min(H,HALF+(h+16)//32),max(0,HALF-(h+15)//32)

def raster(g,pose):
    ids,_=walls(g);ug=upper(g);far=[];near=[];owners=[]
    for col in range(N):
        f=trace(g,pose,col);u=trace(ug,pose,col,overhead=True)
        bank=2+int(f['ny']) if f['side'] else int(f['nx']);owners.append(ids[bank*1024+f['cell']])
        far.append(f);near.append(u)
    nowners=[u['mat']+16*u['side'] if u['mat']>=9 else 0 for u in near]
    exits=[u.get('exitplane',0) for u in near]
    raw=[[raw_height(f['depth'])[i] for f in far] for i in (0,1)]
    raw+=[[raw_height(u['depth'])[i] if u['mat']>=9 else 0 for u in near] for i in (0,2)]
    raw+=[[raw_height(u['exitdepth'])[2] if u['mat']>=9 else 0 for u in near]]
    ends=[]
    for i,a in enumerate(raw):
        own=owners if i<2 else exits if i==4 else nowners
        ends.append([(v+a[c-1])//2 if c and own[c] and own[c]==own[c-1] else v for c,v in enumerate(a)]+
                    [(v+a[c+1])//2 if c<N-1 and own[c] and own[c]==own[c+1] else v for c,v in enumerate(a)])
    for col in range(N):
        for own,hit,plane,depth,kinds in [
            (owners,far[col],far[col]['plane'],far[col]['depth'],((0,0),(1,1))),
            (nowners,near[col],near[col]['plane'],near[col]['depth'],((2,0),(3,2))),
            (exits,near[col],near[col].get('exitplane',0),near[col].get('exitdepth',0),((4,2),))]:
            if not own[col] or plane==255:continue
            base,delta=corrected(plane,depth,pose,col)
            for other,sign,offset in ((col-1,-1,0),(col+1,1,N)):
                if 0<=other<N and own[other]==own[col]:continue
                h=max(0,base+sign*delta);p=project(h)
                for idx,kind in kinds:ends[idx][col+offset]=p[kind]
    ends[4]=[max(a,b) for a,b in zip(ends[4],ends[3])]
    flags=[int(any(a[c]!=a[n] for a in (owners,nowners,exits) for n in (c-1,c+1) if 0<=n<N)) for c in range(N)]
    samples=[];extra=0;steps=0;covowner=bytearray(160)
    for col in range(N):
        previous=COARSE[col]
        for sub in range(4):
            p=col*4+sub
            if flags[col]:
                f=trace(g,pose,p,True);u=trace(ug,pose,p,True,True)
                if FINE[p]!=previous:extra+=1;steps+=f['steps']
                previous=FINE[p]
                ft,fb,_=project(corrected(f['plane'],f['depth'],pose,p,True)[0]);nt=nb=ne=ns=0
                bank=2+int(f['ny']) if f['side'] else int(f['nx']);covowner[p]=ids[bank*1024+f['cell']]
                if u['mat']>=9:
                    if u['plane']!=255:nt,_,nb=project(corrected(u['plane'],u['depth'],pose,p,True)[0])
                    _,_,ne=project(corrected(u['exitplane'],u['exitdepth'],pose,p,True)[0]);ne=max(nb,ne);ns=3-u['side']
                samples.append((ft,fb,nt,nb,ne,3-f['side'],ns))
            else:
                bounds=[((7-2*sub)*e[col]+(2*sub+1)*e[col+N]+3)//8 for e in ends]
                samples.append((*bounds,3-far[col]['side'],3-near[col]['side'] if nowners[col] else 0))
    pix=bytearray(W*H);bitmap=bytearray(7040)
    for x,v in enumerate(samples):
        ft,fb,nt,nb,ne,fs,ns=v
        for y in range(H):
            color=(1 if (x+y)%2==0 else 0) if y<HALF else 1
            if ft<=y<fb:color=fs
            if ns and nt<=y<nb:color=ns
            if ns and nb<=y<ne:color=1
            pix[y*W+x]=color
            # Bitmap physical origin is old body offset(+16logical,+16scanlines).
            off=(y+16)//8*320+(x//4+4)*8+(y+16)%8
            bitmap[off]|=color<<(6-2*(x%4))
    return bytes(bitmap),bytes(pix),dict(flags=flags,ends=ends,raw=raw,far=far,near=near,owners=owners,
        nowners=nowners,exits=exits,coverageOwners=bytes(covowner),extraRays=extra,extraSteps=steps,samples=samples)
