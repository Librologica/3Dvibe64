"""Closed convex source contract, per-instance Q8 domain and sharing controls."""
import copy
import importlib.util
import json
import math
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]


def main():
    sys.path.insert(0,str(ROOT/'work'))
    from mode8.common import require_qualification_checks
    require_qualification_checks()
    spec=importlib.util.spec_from_file_location('shared_mesh',ROOT/'extensions/gameplay/meshes/shared.py')
    m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
    asset=json.loads((ROOT/'extensions/gameplay/profiles/shared-meshes/assets/crystal-mesh.json').read_text(encoding='utf-8'))
    config=json.loads((ROOT/'extensions/gameplay/profiles/shared-meshes/assets/shared-meshes.json').read_text(encoding='utf-8'))
    original=copy.deepcopy((asset,config));m.configure_asset(asset);m.validate(config)
    assert (asset,config)==original
    for count in (2,3,4):
        d=copy.deepcopy(config);d['instances']=d['instances'][:count]
        assert m.validate(d)==d
        d['sharing']=False;assert m.validate(d)==d
    # Editable source asset, same bounded layout, remains closed/convex.
    changed=copy.deepcopy(asset);changed['vertices'][5][2]=4;m.configure_asset(changed)
    assert m.VERTICES[5][2]==4
    changed['vertices'][5][2]=3;assert m.VERTICES[5][2]==4 # copy, no shared Python list ownership
    m.configure_asset(asset)
    for angle in (0,90,180,270):
        instance=copy.deepcopy(config['instances'][0]);instance.update(position=[0,0,0],yawDegrees=angle,scale=1)
        p=m.model_vertices(instance)[1]
        expected=[3*math.cos(math.radians(angle)),3*math.sin(math.radians(angle)),0]
        assert math.dist(p,expected)<1e-12
    bad=[]
    def reject(edit):d=copy.deepcopy(config);edit(d);bad.append(d)
    reject(lambda d:d.update(schema=True));reject(lambda d:d.update(sharing=1));reject(lambda d:d.update(extra=0))
    reject(lambda d:d.update(instances=[]));reject(lambda d:d.update(instances=d['instances'][:1]))
    reject(lambda d:d['instances'].append(copy.deepcopy(d['instances'][0])))
    reject(lambda d:d['instances'][1].update(id='west'));reject(lambda d:d['instances'][0].update(id='bad name'))
    reject(lambda d:d['instances'][0].update(scale=1.1));reject(lambda d:d['instances'][0].update(scale=.1))
    reject(lambda d:d['instances'][0].update(scale=.7));reject(lambda d:d['instances'][0].update(scale=True))
    reject(lambda d:d['instances'][0].update(position=[0,0]));reject(lambda d:d['instances'][0].update(position=[float('nan'),0,0]))
    reject(lambda d:d['instances'][0].update(position=[.001,0,0]));reject(lambda d:d['instances'][0].update(position=[True,0,0]))
    reject(lambda d:d['instances'][0].update(position=[23,0,0]));reject(lambda d:d['instances'][0].update(position=[0,0,-6]))
    reject(lambda d:d['instances'][1].update(position=d['instances'][0]['position'].copy()))
    reject(lambda d:d['instances'][0].update(yawDegrees=-1));reject(lambda d:d['instances'][0].update(yawDegrees=360))
    reject(lambda d:d['instances'][0].update(yawDegrees=float('inf')));reject(lambda d:d['instances'][0].update(visible=1))
    reject(lambda d:d['instances'][0].update(level=3));reject(lambda d:d['instances'][0].update(level=29))
    for d in bad:
        try:m.validate(d)
        except ValueError:pass
        else:raise AssertionError('Unsafe instance configuration accepted')
    bad_assets=[]
    def reject_asset(edit):d=copy.deepcopy(asset);edit(d);bad_assets.append(d)
    reject_asset(lambda d:d.update(schema=True));reject_asset(lambda d:d.update(extra=True))
    reject_asset(lambda d:d.update(vertices=d['vertices'][:5]));reject_asset(lambda d:d['vertices'][0].__setitem__(0,-4))
    reject_asset(lambda d:d['vertices'][0].__setitem__(0,-2.5));reject_asset(lambda d:d['vertices'][0].__setitem__(0,True))
    reject_asset(lambda d:d['vertices'].__setitem__(1,d['vertices'][0].copy()))
    reject_asset(lambda d:d.update(faces=d['faces'][:7]));reject_asset(lambda d:d['faces'][0].reverse())
    reject_asset(lambda d:d['faces'][0].__setitem__(0,7));reject_asset(lambda d:d['faces'][0].__setitem__(0,True))
    reject_asset(lambda d:d['faces'][0].__setitem__(0,[]));reject_asset(lambda d:d['faces'].__setitem__(1,d['faces'][0].copy()))
    for d in bad_assets:
        try:m.configure_asset(d)
        except ValueError:pass
        else:raise AssertionError('Unsafe source topology accepted')
        assert m.VERTICES==asset['vertices'] and m.FACES==asset['faces']
    print(f'SHARED MESH PASS; closed convex editable source,2/3/4instances, exact coordinate/scale domains;{len(bad)+len(bad_assets)}invalid cases refused')


if __name__=='__main__':main()
