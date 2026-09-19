"""Qualified cyclic pursuit, with explicit scene data instead of global templates."""
import math
from .tables import DIR
from .model import floorq

ATAN=bytes(round(math.atan(i/128)*512/math.tau) for i in range(129))

def heading(dx,dy):
    ax,ay=abs(dx),abs(dy)
    while max(ax,ay)>255:ax>>=1;ay>>=1
    a=128-ATAN[ay*128//ax] if ax>ay else ATAN[ax*128//ay] if ay else 0
    if dy<0:a=256-a
    if dx<0:a=-a
    return a&511

def free(s,x,y,radius):
    return all(0<=xx<32 and 0<=yy<32 and not s['solid'][yy*32+xx]
        for xx in range((x-radius)>>8,((x+radius)>>8)+1)
        for yy in range((y-radius)>>8,((y+radius)>>8)+1))

def tick(s,pose,state,nodes,radius):
    x,y,yaw=pose[:3]
    if state['target']!=255:
        tx,ty=nodes[state['target']]
        if abs(tx-x)<64 and abs(ty-y)<64:
            state['node']=state['target'];state['target']=255;state['visits']=(state['visits']+1)&65535
    if state['target']==255:state['target']=(state['node']+1)%len(nodes)
    tx,ty=nodes[state['target']];goal=heading(tx-x,ty-y)
    delta=((goal-yaw+256)&511)-256
    if abs(delta)>16:state['hold']=150
    elif state['hold']:state['hold']-=1
    desired=min(8,max(0,abs(delta)-2))*(1 if delta>=0 else -1)
    v=state['velocity'];v+=int(v<desired)-int(v>desired);state['velocity']=v
    turn,state['fraction']=divmod(state['fraction']+v,8);yaw=(yaw+turn)&511
    mag=abs(delta);slow=state['slow']
    if slow==2:slow=2 if mag>12 else 1 if mag>6 else 0
    elif mag>16:slow=2
    elif slow==1:slow=1 if mag>6 else 0
    elif mag>8:slow=1
    state['slow']=slow;state['movePhase']=(state['movePhase']+1)&3
    dx,dy=(math.trunc(v/(1<<slow)) for v in DIR[yaw][3:])
    if slow==2 and state['movePhase']:dx=dy=0
    before=(x,y)
    if free(s,x+dx,y,radius):x+=dx
    if free(s,x,y+dy,radius):y+=dy
    z=floorq(s,x,y)+8192
    return (x,y,yaw,z>>8,z&255),((x,y)==before and bool(dx or dy))

def simulate(s,nav,ticks=30000,backend='multi'):
    state=dict(node=0,target=255,visits=0,velocity=0,fraction=0,slow=0,hold=0,movePhase=0)
    pose=tuple(s['initial']);poses=[pose];states=[dict(state)];blocked=0
    radius=224 if backend=='mono-portals' else 48
    for _ in range(ticks):
        pose,b=tick(s,pose,state,nav['nodes'],radius)
        blocked+=b;poses.append(pose);states.append(dict(state))
    return poses,states,blocked
