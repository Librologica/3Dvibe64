"""Q8-02 configuration, swept animation domain and closed-form clip tests."""
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
    spec=importlib.util.spec_from_file_location('controlled',ROOT/'extensions/gameplay/motion/controlled.py')
    m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
    cfg=json.loads((ROOT/'extensions/gameplay/profiles/controlled-animation/assets/motion.json').read_text())
    shared=json.loads((ROOT/'extensions/gameplay/profiles/shared-meshes/assets/shared-meshes.json').read_text())
    old=copy.deepcopy(cfg);checked=m.validate(cfg,shared);assert checked==cfg==old
    checked['camera']['mode']='flight';assert cfg['camera']['mode']=='dungeon'
    m.validate(checked,shared)
    for count in (2,3,4):
        a=copy.deepcopy(cfg);b=copy.deepcopy(shared);a['clips']=a['clips'][:count];b['instances']=b['instances'][:count];m.validate(a,b)
    first,rows=m.samples(cfg);assert first==[0,4,8,12] and len(rows)==16
    # Uniform source examples have exact endpoint steps and independent speeds.
    assert rows[0]['values']==[-3072,-1280,-1024,0,16384]
    assert rows[0]['steps']==[4,4,0,256,-32]
    assert rows[3]['steps'][3]==256 #270->0 takes +90, not -270
    for c,start in zip(cfg['clips'],first):
        for i,key in enumerate(c['keys']):
            row=rows[start+i];end=[a+64*b for a,b in zip(row['values'],row['steps'])]
            nxt=rows[start+(i+1)%4]['values'];end[3]&=65535
            assert end==nxt
    changed=copy.deepcopy(cfg);changed['clips'][0]['loop']=False
    assert m.samples(changed)==(first,rows) # closing segment can be enabled later
    single=copy.deepcopy(cfg);single['clips'][0]['keys']=single['clips'][0]['keys'][:1];m.validate(single,shared)
    assert not any(m.samples(single)[1][0]['steps'])
    bad=[]
    def reject(fn):d=copy.deepcopy(cfg);fn(d);bad.append(d)
    reject(lambda d:d.update(schema=True));reject(lambda d:d.update(enabled=1));reject(lambda d:d.update(extra=0))
    reject(lambda d:d['camera'].update(mode='orbit'));reject(lambda d:d['camera'].update(bankDegrees=46));reject(lambda d:d['camera'].update(bankDegrees=True));reject(lambda d:d['camera'].update(bankDegrees=float('nan')))
    reject(lambda d:d.update(clips=d['clips'][:1]));reject(lambda d:d['clips'][0].update(instance='east'))
    reject(lambda d:d['clips'][0].update(speed=3));reject(lambda d:d['clips'][0].update(speed=True));reject(lambda d:d['clips'][0].update(ticksPerKey=32));reject(lambda d:d['clips'][0].update(playing=1));reject(lambda d:d['clips'][0].update(loop=1))
    reject(lambda d:d['clips'][0].update(keys=[]));reject(lambda d:d['clips'][0].update(keys=d['clips'][0]['keys']*3))
    reject(lambda d:d['clips'][0]['keys'][0].update(yawDegrees=1))
    for field,value in [('position',[0,0]),('position',[True,0,0]),('position',[.001,0,0]),('position',[float('inf'),0,0]),('position',[22,0,0]),('position',[-12,-4,-9]),('position',[13,6,-5]),('scale',1.1),('scale',.7),('scale',True),('yawDegrees',360),('yawDegrees',-1),('yawDegrees',float('nan')),('visible',1)]:
        reject(lambda d,f=field,v=value:d['clips'][0]['keys'][1].update({f:v}))
    # Fractional endpoint values are accepted when the complete quantized
    # trajectory remains inside the domain.
    d=copy.deepcopy(cfg);d['clips'][0]['keys'][1].update(position=[-12,-4,-5-1/256],scale=63/64)
    d['clips'][0]['keys'][2].update(position=[-12,-4,-5],scale=1)
    # Valid bounded quantized fractional key; full sweep must also be checked.
    m.validate(d,shared)
    for d in bad:
        try:m.validate(d,shared)
        except ValueError:pass
        else:raise AssertionError('Unsafe motion configuration accepted')
    print(f'CONTROLLED MOTION PASS;2/3/4instances, continuous64-tick segments, shortest yaw, runtime loop switches;{len(bad)}invalid inputs refused')


if __name__=='__main__':main()
