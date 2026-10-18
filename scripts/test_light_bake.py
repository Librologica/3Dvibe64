"""Analytical host light/shadow fixtures, compact format and input boundaries."""
import copy
import importlib.util
import json
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]


def main():
    sys.path.insert(0,str(ROOT/'work'))
    from mode8.common import require_qualification_checks
    require_qualification_checks()
    spec=importlib.util.spec_from_file_location('light_baker',ROOT/'extensions/gameplay/materials/light_bake.py')
    b=importlib.util.module_from_spec(spec);spec.loader.exec_module(b)
    q=lambda p:tuple(round(v*256) for v in p)
    config=dict(schema=1,enabled=True,ambient=3,biasWU=1/256,receivers=[0],occluders=[],
        lights=[dict(id='lamp',position=[0,0,8],radiusWU=16,strength=32)])
    n=(0,0,65536)
    assert b.sample(q((0,0,0)),n,config,[])[0]==19 # 32 * cos0 * half radius +3
    oblique=copy.deepcopy(config);oblique['lights'][0].update(position=[3,0,4],radiusWU=10,strength=40)
    assert b.sample(q((0,0,0)),n,oblique,[])[0]==19 # 3-4-5:40*(4/5)*(1/2)+3
    for position in ([0,0,-8],[0,0,16],[0,0,0]):
        d=copy.deepcopy(config);d['lights'][0]['position']=position
        assert b.sample(q((0,0,0)),n,d,[])[0]==3
    triangle=tuple(q(p) for p in [(-2,-2,2),(2,-2,2),(0,2,2)])
    shadow=copy.deepcopy(config);shadow['occluders']=[0]
    assert b.sample(q((0,0,0)),n,shadow,[triangle])[0]==3
    assert b.sample(q((0,0,0)),n,shadow,[tuple(reversed(triangle))])[0]==3
    assert b.segment_hits(q((0,0,0)),q((0,0,8)),triangle)
    assert not b.segment_hits(q((0,0,2)),q((0,0,8)),triangle) # segment endpoint excluded
    assert not b.segment_hits(q((0,0,0)),q((0,0,2)),triangle)
    assert not b.segment_hits(q((4,0,0)),q((4,0,8)),triangle)
    # Private mesh X/up/forward, clockwise after public conversion: upward normal.
    scene=dict(meshes=[dict(id='floor',vertices=[[-2,0,2],[2,0,2],[2,0,-2],[-2,0,-2]],faces=[[0,1,2],[0,2,3]])],
        objects=[dict(mesh='floor',position=[0,0,0],rotation=[0,0,0],scale=1,angularVelocity=[0,0,0],visible=True)])
    table=[dict(mode='gouraud',index=2,levels=[16]*3) for _ in range(2)]
    cfg=copy.deepcopy(config);cfg['receivers']=[0,1]
    original=copy.deepcopy((scene,cfg,table));one=b.compile_bake(scene,cfg,table);two=b.compile_bake(scene,cfg,table)
    assert one==two and (scene,cfg,table)==original
    assert all(s['normal'][2]>0 for s in one[2]['samples'])
    assert b.decode(one[1])==one[2]['records'] and len(one[1])==13
    disabled=copy.deepcopy(cfg);disabled['enabled']=False
    assert b.compile_bake(scene,disabled,table)[0]==table and b.compile_bake(scene,disabled,table)[1]==b'LB01\0'
    reversed_lights=copy.deepcopy(cfg);reversed_lights['lights'].append(dict(id='other',position=[-3,0,3],radiusWU=16,strength=12))
    first=b.compile_bake(scene,reversed_lights,table)[1];reversed_lights['lights'].reverse()
    assert first==b.compile_bake(scene,reversed_lights,table)[1]
    bad=[]
    def reject(edit):d=copy.deepcopy(cfg);edit(d);bad.append(d)
    reject(lambda d:d.update(schema=True));reject(lambda d:d.update(enabled=1))
    reject(lambda d:d.update(ambient=-1));reject(lambda d:d.update(ambient=33));reject(lambda d:d.update(biasWU=0))
    reject(lambda d:d.update(receivers=[0,0]));reject(lambda d:d.update(receivers=[2]));reject(lambda d:d.update(receivers=[True]))
    reject(lambda d:d.update(occluders=[2]));reject(lambda d:d['lights'].append(copy.deepcopy(d['lights'][0])))
    reject(lambda d:d['lights'][0].update(position=[float('nan'),0,0]));reject(lambda d:d['lights'][0].update(position=[.001,0,0]))
    reject(lambda d:d['lights'][0].update(radiusWU=0));reject(lambda d:d['lights'][0].update(strength=65));reject(lambda d:d.update(lights=[]))
    for d in bad:
        try:b.compile_bake(scene,d,table)
        except ValueError:pass
        else:raise AssertionError('Invalid light configuration accepted')
    for receivers in ([0],[1]):
        d=copy.deepcopy(cfg);d['receivers']=receivers
        try:b.compile_bake(scene,d,table,forbidden=receivers)
        except ValueError:pass
        else:raise AssertionError('Mobile/reserved receiver accepted')
    for key,value in [('rotation',[0,0,1]),('scale',2),('angularVelocity',[0,0,1])]:
        d=copy.deepcopy(scene);d['objects'][0][key]=value
        try:b.compile_bake(d,cfg,table)
        except ValueError:pass
        else:raise AssertionError('Unsupported object transform accepted')
    caster=copy.deepcopy(cfg);caster.update(receivers=[0],occluders=[1])
    try:b.compile_bake(scene,caster,table,forbidden=[1])
    except ValueError:pass
    else:raise AssertionError('Mobile/reserved caster accepted')
    textured=copy.deepcopy(table);textured[0]['mode']='texture'
    try:b.compile_bake(scene,cfg,textured)
    except ValueError:pass
    else:raise AssertionError('Unsupported textured light receiver accepted')
    degenerate=copy.deepcopy(scene);degenerate['meshes'][0]['vertices'][1]=degenerate['meshes'][0]['vertices'][0][:]
    try:b.compile_bake(degenerate,cfg,table)
    except ValueError:pass
    else:raise AssertionError('Degenerate receiver accepted')
    for payload in (b'',b'LB01',b'LB01\x01',b'LB01\x01\x00\x21\x00\x00',b'LB01\x02'+bytes([0,1,2,3])*2):
        try:b.decode(payload)
        except ValueError:pass
        else:raise AssertionError('Malformed compact bake accepted')
    print('STATIC LIGHT BAKE PASS; analytical Lambert/shadow, deterministic output, compact round-trip, disabled identity and28invalid cases')


if __name__=='__main__':main()
