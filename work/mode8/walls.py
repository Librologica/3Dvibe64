from collections import defaultdict

def walls(grid):
    groups=defaultdict(list);tables=[bytearray(1024) for _ in range(4)]
    for y in range(32):
        for x in range(32):
            if not grid[y*32+x]:continue
            for bank,(dx,dy) in enumerate([(-1,0),(1,0),(0,-1),(0,1)]):
                nx,ny=x+dx,y+dy
                if 0<=nx<32 and 0<=ny<32 and not grid[ny*32+nx]:
                    plane=(x if bank<2 else y)+(bank&1);along=y if bank<2 else x
                    groups[bank,plane].append((along,y*32+x))
    ident=0;segments=[]
    for (bank,plane),v in sorted(groups.items()):
        last=-2
        for along,index in sorted(v):
            if along!=last+1:
                ident+=1;segments.append(dict(id=ident,bank=bank,plane=plane,start=along,end=along+1))
            else:segments[-1]['end']=along+1
            if ident>255:raise ValueError('connected wall ID budget exceeds255')
            tables[bank][index]=ident;last=along
    return b''.join(tables),segments

