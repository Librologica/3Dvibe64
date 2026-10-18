"""Independent reachability oracle, alternate openings and conservative ownership."""
import copy
import importlib.util
import itertools
import json
import math
import sys
from pathlib import Path
from gameplay_test_inputs import FIXTURES
ROOT=Path(__file__).resolve().parents[1]


def main():
    sys.path.insert(0,str(ROOT/'work'))
    from mode8.common import require_qualification_checks
    require_qualification_checks()
    spec=importlib.util.spec_from_file_location('visibility_compiler',ROOT/'extensions/gameplay/visibility/compiler.py')
    c=importlib.util.module_from_spec(spec);spec.loader.exec_module(c)
    config=json.loads((FIXTURES/'extensions/gameplay/profiles/sector-visibility/assets/visibility.json').read_text(encoding='utf-8'))
    q=lambda p:[round(x*256) for x in p]
    vertices=[q(p) for p in [(-1,-2,0),(1,-2,0),(0,2,1),(-1,12,0),(1,12,0),(0,16,1),(0,8,1)]]
    faces=[[0,1,2],[3,4,5],[2,5,6],[0,1,6]]
    original=copy.deepcopy((config,vertices,faces)); payload,report=c.compile_pvs(config,vertices,faces)
    assert (config,vertices,faces)==original
    assert c.compile_pvs(config,vertices,faces)==(payload,report)
    assert report['faceMasks']==[1,2,3,3] # complete extent, boundary-touching included
    assert report['PVS']==[[1,2],[3,3]]
    assert payload==b'PV01\x02\x01\x04\x01\x02\x03\x03\x01\x02\x03\x03'
    assert c.decode(payload)['PVS']==report['PVS']
    alternate=copy.deepcopy(config)
    alternate['portals'].append(dict(id='second-opening',sectors=['front','rear'],bounds=[[-12,-8],[8,8],[-4,2]],door=None))
    assert c.compile_pvs(alternate,vertices,faces)[1]['PVS']==[[3,3],[3,3]]
    # Eight cells and four independently controlled edges. Compare every table
    # entry against Boolean matrix transitive closure, independent of BFS.
    grid=dict(schema=1,enabled=True,culling=True,worldBounds=[[0,4],[0,2],[0,2]],sectors=[],doors=['a','b','c','d'],portals=[])
    for y in range(2):
        for x in range(4):grid['sectors'].append(dict(id=f'cell-{y*4+x}',bounds=[[x,x+1],[y,y+1],[0,2]]))
    edges=[]
    for y in range(2):
        for x in range(4):
            a=y*4+x
            for dx,dy in ((1,0),(0,1)):
                if x+dx>=4 or y+dy>=2:continue
                b=(y+dy)*4+x+dx;door=(a+b)%5;door=door if door<4 else None
                aperture=[[x+1,x+1],[y+.25,y+.75],[.25,1.75]] if dx else [[x+.25,x+.75],[y+1,y+1],[.25,1.75]]
                grid['portals'].append(dict(id=f'edge-{a}-{b}',sectors=[f'cell-{a}',f'cell-{b}'],bounds=aperture,door=None if door is None else grid['doors'][door]))
                edges.append((a,b,door))
    table=c.compile_pvs(grid,[q((.25,.25,.25)),q((.5,.25,.25)),q((.25,.5,.25))],[[0,1,2]])[1]['PVS']
    for state in range(16):
        matrix=[[i==j for j in range(8)] for i in range(8)]
        for a,b,d in edges:
            if d is None or state&(1<<d):matrix[a][b]=matrix[b][a]=True
        for k,i,j in itertools.product(range(8),repeat=3):matrix[i][j]|=matrix[i][k] and matrix[k][j]
        assert table[state]==[sum(1<<j for j in range(8) if matrix[i][j]) for i in range(8)]
        for door in range(4):
            if not state&(1<<door):
                assert all((a&b)==a for a,b in zip(table[state],table[state|(1<<door)]))
    bad=[]
    def reject(edit):d=copy.deepcopy(config);edit(d);bad.append(d)
    reject(lambda d:d.update(schema=True));reject(lambda d:d.update(enabled=1));reject(lambda d:d.update(culling=0))
    reject(lambda d:d.update(extra=True));reject(lambda d:d.update(sectors=[]));reject(lambda d:d.update(doors=['x']*5))
    reject(lambda d:d.update(doors=['guardian-door']*2));reject(lambda d:d.update(portals=[]))
    reject(lambda d:d['sectors'][0].update(id='rear'));reject(lambda d:d['sectors'][0].update(id='bad id'))
    reject(lambda d:d['sectors'][0]['bounds'][1].__setitem__(1,9))
    reject(lambda d:d['sectors'][0]['bounds'][1].__setitem__(1,7))
    reject(lambda d:d['sectors'][0]['bounds'][0].__setitem__(0,-25))
    reject(lambda d:d['worldBounds'][0].__setitem__(0,float('nan')))
    reject(lambda d:d['worldBounds'][0].__setitem__(0,.001))
    reject(lambda d:d['worldBounds'][0].__setitem__(0,True))
    reject(lambda d:d['portals'][0].update(door='unknown'));reject(lambda d:d['portals'][0].update(sectors=['front','front']))
    reject(lambda d:d['portals'][0].update(sectors=['front','missing']))
    reject(lambda d:d['portals'][0]['bounds'][1].__setitem__(0,7))
    reject(lambda d:d['portals'][0]['bounds'][0].__setitem__(1,25))
    reject(lambda d:d['portals'][0]['bounds'][0].__setitem__(1,-5))
    reject(lambda d:d['portals'].append(copy.deepcopy(d['portals'][0])))
    for d in bad:
        try:c.compile_pvs(d,vertices,faces)
        except ValueError:pass
        else:raise AssertionError('Unsafe topology accepted')
    invalid=0
    for v,f,m in [(vertices,[[0,1,99]],{}),(vertices,[[0,True,1]],{}),([q((128,0,0))],[[0,0,0]],{}),(vertices,faces,{0:0}),(vertices,faces,{0:4}),(vertices,faces,{4:1})]:
        try:c.compile_pvs(config,v,f,m)
        except ValueError:invalid+=1
        else:raise AssertionError('Unsafe source geometry accepted')
    for corrupt in (payload[:-1],b'WRNG'+payload[4:],payload+b'\0',payload[:7]+b'\0'+payload[8:],payload[:-4]+b'\x02'+payload[-3:]):
        try:c.decode(corrupt)
        except ValueError:invalid+=1
        else:raise AssertionError('Corrupt PVS accepted')
    assert 4*math.sqrt(1+(48/41)**2+(30/41)**2)<8
    print(f'SECTOR VISIBILITY PASS;128independent PVS rows, alternate opening, monotonic door visibility, crossing/touching ownership;{len(bad)+invalid}invalid inputs refused')


if __name__=='__main__':main()
