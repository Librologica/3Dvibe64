"""VIS-01 conservative portal-connectivity PVS for sealed rectangular sectors.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
This computes a superset, without angular/frustum rejection. The scene adapter
must prove that opaque boundaries have no undeclared openings. Coordinates
are public X/forward/up, exact Q8. This module never edits its inputs.
"""
import hashlib
import json
import math
import re


def digest(value):
    return hashlib.sha256(json.dumps(value,sort_keys=True,separators=(',',':')).encode('utf-8')).hexdigest().upper()


def identifier(value):
    if not isinstance(value,str) or not re.fullmatch('[a-z][a-z0-9-]{0,31}',value):
        raise ValueError('Expected a short unique identifier')
    return value


def q8(value):
    if type(value) not in (int,float) or not math.isfinite(value) or not -127<=value<=127 or value*256!=round(value*256):
        raise ValueError('Expected exact finite Q8 coordinate within +/-127WU')
    return round(value*256)


def bounds(value,flat=False):
    if not isinstance(value,list) or len(value)!=3 or any(not isinstance(p,list) or len(p)!=2 for p in value):
        raise ValueError('Bounds require three [min,max] intervals')
    result=[[q8(x) for x in p] for p in value]
    if any(a>b for a,b in result) or sum(a==b for a,b in result)!=(1 if flat else 0):
        raise ValueError('Expected positive volume, or one flat axis for a portal')
    return result


def validate(config):
    keys={'schema','enabled','culling','worldBounds','sectors','doors','portals'}
    if not isinstance(config,dict) or set(config)!=keys or type(config['schema']) is not int or config['schema']!=1:
        raise ValueError('Visibility requires schema1 and the documented fields')
    if any(type(config[k]) is not bool for k in ('enabled','culling')):raise ValueError('Expected boolean switches')
    world=bounds(config['worldBounds']); sectors=config['sectors']; doors=config['doors']; portals=config['portals']
    if not isinstance(sectors,list) or not 2<=len(sectors)<=8:raise ValueError('Expected2..8sectors')
    if not isinstance(doors,list) or len(doors)>4:raise ValueError('Expected0..4doors')
    if not isinstance(portals,list) or not 1<=len(portals)<=16:raise ValueError('Expected1..16portals')
    for d in doors:identifier(d)
    if len(set(doors))!=len(doors):raise ValueError('Duplicate door')
    boxes=[]; ids=[]
    for sector in sectors:
        if not isinstance(sector,dict) or set(sector)!={'id','bounds'}:raise ValueError('Invalid sector descriptor')
        ids.append(identifier(sector['id'])); box=bounds(sector['bounds']); boxes.append(box)
        if any(a<wa or b>wb for (a,b),(wa,wb) in zip(box,world)):raise ValueError('Sector outside world bounds')
    if len(set(ids))!=len(ids):raise ValueError('Duplicate sector')
    for i,a in enumerate(boxes):
        for b in boxes[:i]:
            if all(max(x[0],y[0])<min(x[1],y[1]) for x,y in zip(a,b)):raise ValueError('Overlapping sector interiors')
    volume=lambda box:math.prod(b-a for a,b in box)
    if sum(volume(b) for b in boxes)!=volume(world):raise ValueError('Sector boxes must tile the whole world')
    edges=[]; portal_ids=[]
    for portal in portals:
        if not isinstance(portal,dict) or set(portal)!={'id','sectors','bounds','door'}:raise ValueError('Invalid portal descriptor')
        portal_ids.append(identifier(portal['id'])); pair=portal['sectors']
        if not isinstance(pair,list) or len(pair)!=2 or any(not isinstance(x,str) or x not in ids for x in pair) or pair[0]==pair[1]:raise ValueError('Portal requires two distinct configured sectors')
        i,j=map(ids.index,pair); a,b=boxes[i],boxes[j]; aperture=bounds(portal['bounds'],flat=True)
        shared=[[max(x[0],y[0]),min(x[1],y[1])] for x,y in zip(a,b)]
        if any(x>y for x,y in shared) or sum(x==y for x,y in shared)!=1:raise ValueError('Portal sectors must share a face')
        axis=next(k for k,(x,y) in enumerate(shared) if x==y)
        if aperture[axis]!=shared[axis] or any(x<lo or y>hi for (x,y),(lo,hi) in zip(aperture,shared)):raise ValueError('Aperture must lie on the shared face')
        door=portal['door']
        if door is not None and (not isinstance(door,str) or door not in doors):raise ValueError('Unknown portal door')
        edges.append((i,j,None if door is None else doors.index(door)))
    if len(set(portal_ids))!=len(portal_ids):raise ValueError('Duplicate portal')
    return world,boxes,edges


def reachability(count,edges,state):
    rows=[]
    for origin in range(count):
        reached={origin}; pending=[origin]
        while pending:
            node=pending.pop()
            for a,b,door in edges:
                if door is not None and not(state&(1<<door)):continue
                other=b if a==node else a if b==node else None
                if other is not None and other not in reached:reached.add(other);pending.append(other)
        rows.append(sum(1<<i for i in reached))
    return rows


def compile_pvs(config,vertices,faces,actor_masks=None):
    world,boxes,edges=validate(config); count=len(boxes); actor_masks={} if actor_masks is None else actor_masks
    if not isinstance(vertices,list) or not vertices or not isinstance(faces,list) or not 1<=len(faces)<=254:raise ValueError('Expected bounded source geometry')
    for p in vertices:
        if not isinstance(p,(list,tuple)) or len(p)!=3 or any(type(v) is not int or not lo<=v<=hi for v,(lo,hi) in zip(p,world)):raise ValueError('Expected public Q8 vertices inside world')
    if not isinstance(actor_masks,dict) or any(type(f) is not int or not 0<=f<len(faces) or type(m) is not int or not 0<m<(1<<count) for f,m in actor_masks.items()):raise ValueError('Invalid proven actor ownership')
    masks=[]
    for index,face in enumerate(faces):
        if not isinstance(face,list) or len(face)!=3 or any(type(i) is not int or not 0<=i<len(vertices) for i in face):raise ValueError('Expected source triangles')
        extent=[(min(vertices[i][a] for i in face),max(vertices[i][a] for i in face)) for a in range(3)]
        mask=sum(1<<s for s,box in enumerate(boxes) if all(lo<=b and hi>=a for (lo,hi),(a,b) in zip(extent,box)))
        # Cross-boundary triangles belong to every intersected cell. No centroid assignment.
        masks.append(actor_masks.get(index,mask))
    rows=[reachability(count,edges,state) for state in range(1<<len(config['doors']))]
    payload=b'PV01'+bytes([count,len(config['doors']),len(faces),*masks,*[m for row in rows for m in row]])
    report=dict(schema=1,method='conservative connected-sector superset per open-door bitmask; no angular rejection',
        contract='sealed opaque sector boundaries, all apertures declared; scene adapter must verify geometry',
        configuration=config,configurationSHA256=digest(config),geometrySHA256=digest([vertices,faces,sorted(actor_masks.items())]),
        sectorBoundsQ8=boxes,faceMasks=masks,PVS=rows,payloadBytes=len(payload),payloadSHA256=hashlib.sha256(payload).hexdigest().upper(),
        nearBoundaryPolicy='accept all sectors when camera cannot be safely classified')
    return payload,report


def decode(payload):
    if not isinstance(payload,bytes) or len(payload)<7 or payload[:4]!=b'PV01':raise ValueError('Invalid PVS magic/header')
    n,d,f=payload[4:7]
    if not 2<=n<=8 or d>4 or not 1<=f<=254 or len(payload)!=7+f+n*(1<<d):raise ValueError('Invalid PVS shape')
    masks=list(payload[7:7+f]); rows=[list(payload[7+f+i*n:7+f+(i+1)*n]) for i in range(1<<d)]
    if any(not 0<m<(1<<n) for m in masks+[v for row in rows for v in row]):raise ValueError('Invalid sector mask')
    if any(not(row[i]&(1<<i)) for row in rows for i in range(n)):raise ValueError('Origin omitted from PVS')
    return dict(sectors=n,doors=d,faces=f,faceMasks=masks,PVS=rows)
