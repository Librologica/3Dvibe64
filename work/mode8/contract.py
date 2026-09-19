import math

def require(ok,code,detail):
    if not ok:raise ValueError(f'{code}: {detail}')

def contract(data):
    s=data['scene'];nav=data['navigation']
    require(s.get('size')==[32,32],'SIZE','requires 32x32')
    for key in ('solid','floor','ceiling'):
        require(len(s.get(key,[]))==1024,'ARRAY',key+' needs 1024 entries')
        require(all(type(v)is int for v in s[key]),'INTEGER',key)
    require(set(s['solid'])<={0,1},'SOLID','only 0/1')
    for i,v in enumerate(s['solid']):
        require(v or (i%32 not in (0,31) and i//32 not in (0,31)),'BORDER',str((i%32,i//32)))
    require(s.get('eyeHeight')==32 and s.get('playerHeight',48)==48,'CAMERA_HEIGHT','eye32/player48')
    require(len(s.get('initial',[]))==5,'CAMERA_FORMAT','xQ8,yQ8,yaw9,eyeInteger,eyeFraction')
    require(tuple(nav['camera'])==tuple(s['initial'][:3]),'CAMERA','scene/navigation disagree')
    require(2<=len(nav['nodes'])<=193,'NAV_CAPACITY','2..193 waypoints')
    require(all(len(p)==2 and all(type(v)is int and 0<v<8192 for v in p) for p in nav['nodes']),'NAV_COORD','Q8.8 coordinates')
    multi=bool(s.get('ramps')) or len({s['floor'][i] for i,v in enumerate(s['solid']) if not v})>1
    if multi:
        from . import model
        require(len(nav['nodes'])<=160,'MULTI_NAV_CAPACITY','at most160 waypoints in this unrelocated layout adapter')
        # Markers are executable ramp formula selectors, not arbitrary heights.
        require(s.get('ramps')==model.scene()['ramps'],'RAMP_FORMULA','only the two documented y-ramp formulae/footprints')
        for marker,x0,x1,y0,y1 in ((255,8,11,11,15),(254,14,17,18,22)):
            expected={y*32+x for y in range(y0,y1) for x in range(x0,x1)}
            actual={i for i,f in enumerate(s['floor']) if f==marker and not s['solid'][i]}
            require(actual==expected,'RAMP_FOOTPRINT',f'marker {marker}: missing {sorted(expected-actual)}, extra {sorted(actual-expected)}')
        for i,(v,f,h) in enumerate(zip(s['solid'],s['floor'],s['ceiling'])):
            require(f in (0,32,64,254,255) and 0<h<=192,'MULTI_QUOTE',str((i%32,i//32,f,h)))
            if not v:require(h-(64 if f in (254,255) else f)>=48,'HEADROOM',str((i%32,i//32)))
        try:model.validate(s);p=model.preprocess(s)
        except (AssertionError,IndexError,KeyError) as e:raise ValueError('MULTI_GEOMETRY: '+str(e)) from e
        require(len(p['keys'])<=255 and len(p['events'])<=255,'EVENT_CAPACITY','8-bit IDs')
        declared=set()
        for d in s.get('doors',[]):
            require(isinstance(d,dict) and d.get('axis') in ('x','y'),'DOOR_FORMAT',str(d))
            require(0<d['plane']<31 and 0<d['start']<=d['end']<31,'DOOR_BOUNDS',str(d))
            for v in range(d['start'],d['end']+1):
                x,y=(d['plane'],v) if d['axis']=='x' else (v,d['plane']);i=32*y+x;declared.add(i)
                require(not s['solid'][i] and s['floor'][i]==d['floor'] and s['ceiling'][i]==d['floor']+80,'DOOR_CELL',str((x,y)))
        require(declared=={i for i in range(1024) if not s['solid'][i] and s['ceiling'][i]-s['floor'][i]==80},'DOOR_METADATA','all low-ceiling aperture cells must be declared')
        from functools import lru_cache
        maximum=0
        for dx,dy in ((1,1),(-1,1),(1,-1),(-1,-1)):
            @lru_cache(None)
            def longest(x,y):
                if s['solid'][y*32+x]:return 0
                return max(bool(p['maps'][di][yy*32+xx])+longest(xx,yy)
                           for xx,yy,di in ((x+dx,y,int(dx<0)),(x,y+dy,2+int(dy<0))) if 0<=xx<32 and 0<=yy<32)
            maximum=max(maximum,max(longest(x,y) for y in range(32) for x in range(32)))
        require(maximum<15,'PATH_CAPACITY',f'conservative monotone-grid bound {maximum}; runtime stops at15')
        backend='multi'
    else:
        require(set(s['floor'])=={0} and not s.get('ramps'),'MONO_FLOOR','only floor0, no ramps')
        doors=s.get('doors',[])
        if not doors:
            require(set(s['ceiling'])=={128},'MONO_CEILING','opaque contract requires uniform128')
            backend='mono-opaque'
        else:
            # Proven subset: one separating band, two original apertures.
            # No automatic fallback or renaming bypass for other volumes.
            require(doors==[[10,14,11,14],[22,14,23,14]],'MONO_APERTURES','supported slots: x10..11 /22..23, y14, thickness1')
            dc={14*32+x for x in (10,11,22,23)}
            for i in range(1024):
                require(s['ceiling'][i]==(64 if i in dc else 96),'MONO_QUOTE',str((i%32,i//32)))
            require(all(s['solid'][14*32+x]==(0 if 14*32+x in dc else 1) for x in range(32)),
                    'MONO_SEPARATOR','y14 must be solid except the two apertures; proves at most one upper volume before opaque wall')
            backend='mono-portals'
        # Independent geometric count, before byte table emission can overflow.
        from collections import defaultdict
        boundaries=defaultdict(set)
        for i,solid in enumerate(s['solid']):
            if not solid:continue
            x,y=i%32,i//32
            for bank,(dx,dy) in enumerate(((-1,0),(1,0),(0,-1),(0,1))):
                xx,yy=x+dx,y+dy
                if 0<=xx<32 and 0<=yy<32 and not s['solid'][32*yy+xx]:boundaries[bank,(x if bank<2 else y)+(bank&1)].add(y if bank<2 else x)
        owners=sum(sum(v-1 not in seq for v in seq) for seq in boundaries.values())
        require(owners<=96,'OWNER_CAPACITY',f'{owners} connected boundary segments; frozen table permits96 plus sentinel')
    require(valid_pose(s,s['initial']), 'INITIAL_POSE',str(s['initial']))
    return dict(backend=backend,monotoneEventBound=maximum if multi else None,support='Mode 8 conservative map contract; qualification remains per scene',
                automaticFallback=False,roomOverRoom=False,eye=32,viewport=[128,144])

def valid_pose(s,pose):
    if len(pose)<3 or any(type(v)is not int for v in pose):return False
    x,y,a=pose[:3]
    if not(48<=x<8192-48 and 48<=y<8192-48 and 0<=a<512):return False
    if any(s['solid'][yy*32+xx] for xx in ((x-48)>>8,(x+48)>>8) for yy in ((y-48)>>8,(y+48)>>8)):return False
    f=s['floor'][(y>>8)*32+(x>>8)]
    z=((y-{255:11,254:14}[f]*256)*8 if f in (254,255) else f*256)+8192
    return len(pose)==3 or (len(pose)==5 and pose[3]==z//256 and pose[4]==z%256)

def pose_at(s,x,y,a):
    f=s['floor'][(y>>8)*32+(x>>8)];z=((y-{255:11,254:14}[f]*256)*8 if f in (254,255) else f*256)+8192
    return [x,y,a,z>>8,z&255]
