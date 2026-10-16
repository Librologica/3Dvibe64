"""Private Venus scan reduction from the earlier qualified sculpture.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
Original scan rights are not established: no public redistribution authorized.
"""
import json,collections
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def make():
    old=json.loads((ROOT/'assets/previous-milo-scene.json').read_text())
    src=next(m for m in old['meshes'] if m['id']=='milo')
    lo=min(p[1] for p in src['vertices']);hi=max(p[1] for p in src['vertices'])
    factor=20/(hi-lo);verts=[];mapping=[]
    for p in src['vertices']:
        v=[round(p[0]*factor),round((p[1]-lo)*factor)-10,round(p[2]*factor)]
        if v not in verts:verts.append(v)
        mapping.append(verts.index(v))
    faces=[];seen=set()
    for f in src['faces']:
        g=[mapping[i] for i in f];p,q,r=[verts[i] for i in g]
        a=[q[i]-p[i] for i in range(3)];b=[r[i]-p[i] for i in range(3)]
        n=[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
        k=tuple(sorted(g))
        if any(n) and k not in seen:faces.append(g);seen.add(k)
    used=sorted(set(i for f in faces for i in f));remap={v:i for i,v in enumerate(used)}
    verts=[verts[i] for i in used];faces=[[remap[i] for i in f] for f in faces]
    edges=collections.defaultdict(list)
    for f in faces:
        for a,b in zip(f,f[1:]+f[:1]):edges[tuple(sorted((a,b)))].append((a,b))
    topology=dict(boundaryEdges=sum(len(v)==1 for v in edges.values()),
        nonmanifoldEdges=sum(len(v)>2 for v in edges.values()),
        orientationConflicts=sum(len(v)==2 and v[0]==v[1] for v in edges.values()))
    assert not topology['orientationConflicts'],topology
    mesh=dict(id='central-venus',type='mesh',geometry='solid',materialProfile='single',
        vertices=verts,faces=faces,texture='plain-ceiling',faceTextures=['plain-ceiling']*len(faces),
        faceUV=[[[0,0]]*3 for _ in faces],gouraud={'creaseAngle':180})
    report=dict(source='assets/previous-milo-scene.json: milo mesh; earlier QEM reduction',
        sourceVertices=len(src['vertices']),sourceTriangles=len(src['faces']),vertices=len(verts),
        triangles=len(faces),heightWU=20,centerPublic=[0,160,0],floorWU=-10,
        method='aspect-preserving integer-WU quantization; remove collapsed/duplicate triangles',
        flat=True,smooth=False,topology=topology,rights='private user-supplied scan; license not established')
    (ROOT/'reports/venus-mesh.json').write_text(json.dumps(report,indent=2))
    return mesh
