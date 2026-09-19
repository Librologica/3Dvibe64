import math
N=512
DIR=[]
for a in range(N):
    x=math.sin(a*2*math.pi/N);y=math.cos(a*2*math.pi/N)
    if abs(x)<1e-12:x=0
    if abs(y)<1e-12:y=0
    DIR.append(dict(dx=min(65535,round(256/abs(x))) if x else 65535,dy=min(65535,round(256/abs(y))) if y else 65535,
        ax=round(abs(x)*256),ay=round(abs(y)*256),sign=(1 if x<0 else 0)|(2 if y<0 else 0),x=x,y=y))
