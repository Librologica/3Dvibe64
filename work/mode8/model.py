"""Adaptive event topology and shared perspective plane profiles."""
import math
from .tables import DIR
AUTO=[(1,299),(9,64),(1,172),(5,64),(1,425),(8,128),
      (1,425),(9,64),(1,172),(5,64),(1,299),(8,128)]
TOUR_TICKS=sum(t for _,t in AUTO)
def auto_key(n):
    n%=TOUR_TICKS
    for k,t in AUTO:
        if n<t:return k
        n-=t
INITIAL=(2432,2534,272,32,0)
W,H,N=128,144,32
TAN=math.tan(math.pi/6)
OFF=[round(math.atan(((2*x+1)/N-1)*TAN)*512/math.tau) for x in range(N)]
BOUND=[round(math.atan((2*x/N-1)*TAN)*512/math.tau) for x in range(N+1)]
FINE=[round(math.atan(((2*x+1)/W-1)*TAN)*512/math.tau) for x in range(W)]
G=[round((math.cos(a*math.tau/512)+TAN*math.sin(a*math.tau/512))*16384) for a in range(512)]
assert all(G[a+256]==-G[a] for a in range(256))
NUM=454047*256
RAMP=255
RAMPS={255:11,254:14}
SLOPE_FACTOR=round((128/TAN)*64)
SLOPE=[(1 if g>=0 else -1)*(SLOPE_FACTOR*abs(g)//16384) for g in G]

def scene():
    s=dict(schema='two-complex-levels-v1',size=[32,32],solid=[1]*1024,floor=[0]*1024,ceiling=[192]*1024,
           initial=INITIAL,heightUnit='1/32 cell',eyeHeight=32,playerHeight=48)
    def room(x0,y0,x1,y1,f,c):
        for y in range(y0,y1+1):
            for x in range(x0,x1+1):i=y*32+x;s['solid'][i]=0;s['floor'][i]=f;s['ceiling'][i]=c
    room(2,1,29,10,0,128)
    room(2,19,29,30,64,192)
    room(8,11,10,14,255,192)
    room(8,15,16,17,32,192)
    room(14,18,16,21,254,192)
    for y in range(18,22):
        for x in (13,17):s['solid'][y*32+x]=1
    doors=[]
    def partition(axis,plane,start,end,openings,floor):
        for v in range(start,end+1):
            x,y=(plane,v) if axis=='x' else (v,plane);i=y*32+x
            if any(a<=v<=b for a,b in openings):
                s['ceiling'][i]=floor+80
            else:s['solid'][i]=1
        for a,b in openings:doors.append(dict(axis=axis,plane=plane,start=a,end=b,floor=floor))
    partition('y',6,2,29,[(5,7),(16,18),(25,27)],0)
    partition('x',10,1,5,[(3,4)],0)
    partition('x',21,1,5,[(3,4)],0)
    partition('x',12,7,10,[(8,9)],0)
    partition('x',21,7,10,[(8,9)],0)
    partition('y',26,2,29,[(5,7),(18,20),(26,28)],64)
    partition('x',11,19,25,[(23,24)],64)
    partition('x',23,19,25,[(23,24)],64)
    partition('x',16,27,30,[(28,29)],64)
    for x,y in ((4,2),(24,2),(8,20),(28,20),(20,29)):
        s['solid'][y*32+x]=1
    s['doors']=doors
    s['zones']=[dict(name=n,floor=f,bounds=b) for n,f,b in [
        ('lower-west-gallery',0,[2,7,11,10]),('lower-west-room',0,[2,1,9,5]),
        ('lower-central-room',0,[11,1,20,5]),('lower-east-room',0,[22,1,29,5]),
        ('lower-east-gallery',0,[22,7,29,10]),('lower-central-gallery',0,[13,7,20,10]),
        ('upper-west-wing',64,[2,19,10,25]),('upper-west-gallery',64,[2,27,15,30]),
        ('upper-east-gallery',64,[17,27,29,30]),('upper-east-wing',64,[24,19,29,25]),
        ('upper-central-hall',64,[12,22,22,25])]]
    s['ramps']=[dict(marker=255,axis='y',origin=11,start=11,end=15,bottom=0,top=32),
                dict(marker=254,axis='y',origin=14,start=18,end=22,bottom=32,top=64)]
    s['notes']='Distinct complex floor plans, guided complete tour, screened continuous ramps; no room-over-room'
    return s

def floorq(s,x,y):
    f=s['floor'][(y>>8)*32+(x>>8)]
    return (y-RAMPS[f]*256)*8 if f in RAMPS else f*256

def validate(s):
    assert s['size']==[32,32]
    for k in ('floor','ceiling','solid'):assert len(s[k])==1024
    for i,(v,f,c) in enumerate(zip(s['solid'],s['floor'],s['ceiling'])):
        x,y=i%32,i//32
        assert v in (0,1) and f in (0,32,64,254,255) and 0<c<=192
        if x in (0,31) or y in (0,31):assert v==1
        if not v:
            assert c-(64 if f in RAMPS else f)>=48
            if f==255:assert 8<=x<11 and 11<=y<15
            if f==254:assert 14<=x<17 and 18<=y<22
            # Every traversable join is continuous. Collision can therefore
            # test footprint/clearance without an artificial per-cell step.
            for dx,dy in ((1,0),(0,1)):
                ni=i+dx+32*dy
                if s['solid'][ni]:continue
                xx=(x+dx)*256 if dx else x*256+128
                yy=(y+dy)*256 if dy else y*256+128
                f0=(yy-RAMPS[f]*256)*8 if f in RAMPS else f*256
                nf=s['floor'][ni]
                f1=(yy-RAMPS[nf]*256)*8 if nf in RAMPS else nf*256
                assert f0==f1,('discontinuous traversable join',i,ni,f0,f1)
    return s

def tick(s,p,k):
    x,y,a,*_=p;a=(a+2*bool(k&8)-2*bool(k&4))&511
    def free(xx,yy):
        return all(0<=cx<32 and 0<=cy<32 and not s['solid'][cy*32+cx]
                   for cy in ((yy-48)>>8,(yy+48)>>8) for cx in ((xx-48)>>8,(xx+48)>>8))
    if k&3 in (1,2):
        sign=-1 if k&2 else 1;dx,dy=DIR[a][3:];dx*=sign;dy*=sign
        if free(x+dx,y):x+=dx
        if free(x,y+dy):y+=dy
    z=floorq(s,x,y)+32*256
    return x,y,a,z>>8,z&255

def preprocess(s):
    keys=[];events=[(0,0,255,255,1)];maps=[]
    def key(p,h):
        k=(p,h)
        if k not in keys:keys.append(k)
        return keys.index(k)
    for axis,neg in ((0,0),(0,1),(1,0),(1,1)):
        m=[]
        for i in range(1024):
            x,y=i%32,i//32;ox=x+((-1 if not neg else 1) if axis==0 else 0);oy=y+((-1 if not neg else 1) if axis==1 else 0)
            if not(0<=ox<32 and 0<=oy<32):m.append(0);continue
            old=oy*32+ox
            if s['solid'][old]:m.append(0);continue
            f,c=s['floor'][old],s['ceiling'][old];nf,nc=s['floor'][i],s['ceiling'][i];wall=s['solid'][i]
            if not wall and f==nf and c==nc:m.append(0);continue
            plane=(y+neg+64) if axis else x+neg
            flags=int(bool(wall))|(4 if not wall and nc<c else 0)|(16 if axis else 0)|(32 if f in RAMPS else 0)
            e=(key(plane,f),key(plane,c),key(plane,nf) if flags&2 else 255,key(plane,nc) if flags&4 else 255,flags)
            if e not in events:events.append(e)
            m.append(events.index(e))
        maps.append(m)
    if len(keys)>255 or len(events)>255:
        raise ValueError(f'EVENT_CAPACITY: keys={len(keys)}, events={len(events)}; each table permits at most 255 entries')
    return dict(keys=keys,events=events,maps=maps)

def trace(p,pose,index,fine=False):
    px,py,yaw=pose[:3];dx,dy,flags,_,_=DIR[(yaw+(FINE if fine else BOUND)[index])&511]
    nx=bool(flags&1);ny=bool(flags&2);cx=px>>8;cy=py>>8
    sx=dx*(px&255)>>8;sy=dy*(py&255)>>8
    if not nx:sx=dx-sx
    if not ny:sy=dy-sy
    if flags&4:sx=65535
    if flags&8:sy=65535
    path=[]
    for n in range(1,65):
        if sx<=sy:sx=min(65535,sx+dx);cx+=-1 if nx else 1;direction=int(nx)
        else:sy=min(65535,sy+dy);cy+=-1 if ny else 1;direction=2+int(ny)
        assert 0<=cx<32 and 0<=cy<32
        event=p['maps'][direction][cy*32+cx]
        if event:
            path.append(event);assert len(path)<16
            if p['events'][event][4]&1:return path,n
    raise AssertionError('DDA did not terminate')

def line(key,pose):
    plane,alt=key;px,py,yaw,z=pose[:4];zf=pose[4] if len(pose)>4 else 0
    coord=py if plane&64 else px; a=yaw if plane&64 else (yaw-128)&511
    den=(plane&63)*256-coord;dz=z*256+zf-((py-RAMPS[alt]*256)*8 if alt in RAMPS else alt*256)
    if not den and dz:return bytes([144 if dz>0 else 0])*128
    unit=NUM//abs(den) if den else 0;r=unit*abs(dz)//65536
    def edge(g,side):
        v=r*abs(g)//16384
        return 72*256 +(-v if den*dz*g<0 else v)-(SLOPE[yaw if side==0 else -yaw&511] if alt in RAMPS else 0)
    left,right=edge(G[a],0),edge(G[-a&511],1);delta=(right-left)//128
    assert -(1<<31)<left<(1<<31) and -(1<<31)<right<(1<<31)
    start=left+delta//2+128
    return bytes(max(0,min(H,(start+x*delta)//256)) for x in range(128))

def render(p,pose,full=False):
    coarse=[trace(p,pose,c)[0] for c in range(33)]
    flags=[int(coarse[c]!=coarse[c+1]) for c in range(32)]
    pixels=bytearray(128*144);bitmap=bytearray(7040);cache={};counts=dict(fineGroups=sum(flags),coarseRays=33,fineRays=0,keys=0,maxPath=max(map(len,coarse)))
    def sample(k,x):
        if k not in cache:cache[k]=line(p['keys'][k],pose)
        return cache[k][x]
    for x in range(128):
        if full or flags[x//4]:path,_=trace(p,pose,x,True);counts['fineRays']+=1
        else:path=coarse[x//4]
        col=bytearray((1 if (x+y)%2==0 else 0) if y<72 else 1 for y in range(144));top=0;bottom=144
        def clamp(v):return max(top,min(bottom,v))
        def fill(a,b,c):col[a:b]=bytes([c])*(b-a)
        for event in path:
            f,c,r,h,fl=p['events'][event];shade=3-int(bool(fl&16));floor=2 if fl&32 else 1
            top=clamp(sample(c,x))
            y=clamp(sample(f,x));fill(y,bottom,floor);bottom=y
            if fl&1:fill(top,bottom,shade);top=bottom
            else:
                if fl&2:y=clamp(sample(r,x));fill(y,bottom,shade);bottom=y
                if fl&4:y=clamp(sample(h,x));fill(top,y,shade);top=y
            if top>=bottom:break
        assert top>=bottom,('unresolved',pose,x,path)
        for y,v in enumerate(col):
            pixels[y*128+x]=v;off=(y+16)//8*320+(x//4+4)*8+(y+16)%8
            bitmap[off]|=v<<(6-2*(x%4))
    counts['keys']=len(cache)
    return bytes(bitmap),bytes(pixels),dict(coarse=coarse,flags=flags,counts=counts)

if __name__=='__main__':
    s=validate(scene());p=preprocess(s);print('keys/events',len(p['keys']),len(p['events']))
    for pose in (INITIAL,(2432,3328,0,48),(2680,4212,128,64),(3954,5120,0,80),(3954,6016,256,96)):
        a,_,st=render(p,pose);b,_,_=render(p,pose,True)
        print(pose,st['counts'],'fine differences',sum(x!=y for x,y in zip(a,b)))
