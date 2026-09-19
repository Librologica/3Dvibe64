import math
DIR=[]
for a in range(512):
    x=math.sin(a*math.tau/512);y=math.cos(a*math.tau/512)
    if abs(x)<1e-12:x=0
    if abs(y)<1e-12:y=0
    DIR.append((min(65535,round(256/abs(x))) if x else 65535,min(65535,round(256/abs(y))) if y else 65535,
                int(x<0)+2*int(y<0)+4*int(x==0)+8*int(y==0),round(6*x),round(6*y)))
