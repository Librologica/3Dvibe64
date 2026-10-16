"""BB-03 budget, unsupported geometry and shared source contract boundaries."""
import copy
import importlib.util
import json
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]


def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path)
    value=importlib.util.module_from_spec(spec);sys.modules[name]=value;spec.loader.exec_module(value)
    return value


def main():
    sys.path.insert(0,str(ROOT/'work'))
    from mode8.common import require_qualification_checks
    require_qualification_checks()
    module('billboard_scene',ROOT/'extensions/gameplay/billboards/scene.py')
    multi=module('billboard_multiple',ROOT/'extensions/gameplay/billboards/multiple.py')
    cfg=json.loads((ROOT/'extensions/gameplay/profiles/multiple-billboards/assets/gameplay-scene.json').read_text())
    asset=json.loads((ROOT/'extensions/gameplay/profiles/interactive-billboard/assets/guard-frames.json').read_text())
    multi.validate(cfg,asset)
    one=copy.deepcopy(cfg);one['billboards']=one['billboards'][:1];multi.validate(one,asset)
    equal=copy.deepcopy(cfg);equal['billboards'][1]['position']=equal['billboards'][0]['position'][:];multi.validate(equal,asset)
    bad=[]
    def reject(edit):
        d=copy.deepcopy(cfg);edit(d);bad.append(d)
    reject(lambda d:d.update(schema=1))
    reject(lambda d:d.update(schema=True))
    reject(lambda d:d.update(billboards=[]))
    reject(lambda d:d['billboards'].append(copy.deepcopy(d['billboards'][1])))
    reject(lambda d:d['billboards'][1].update(id='guardian'))
    reject(lambda d:d['billboards'][1].update(asset='another-asset.json'))
    reject(lambda d:d['billboards'][1].update(position=[0,4,-2.5]))
    reject(lambda d:d['billboards'][1].update(position=[20,0,-2.5]))
    reject(lambda d:d['billboards'][1].update(position=[0,-20,-2.5]))
    reject(lambda d:d['billboards'][1].update(rotation=[0,0,30]))
    reject(lambda d:d['billboards'][1].update(size=[6,22]))
    reject(lambda d:d['billboards'][1]['animations']['idle'].update(frames=[6]))
    reject(lambda d:d['billboards'][1]['animations']['idle'].update(ticksPerFrame=0))
    reject(lambda d:d['entity'].update(billboard='watcher'))
    reject(lambda d:d['entity'].update(enabled=False))
    reject(lambda d:d.update(visibleBillboards=['missing']))
    reject(lambda d:d.update(visibleBillboards=['guardian','guardian']))
    reject(lambda d:d.update(visibleBillboards=True))
    for d in bad:
        try:multi.validate(d,asset)
        except ValueError:pass
        else:raise AssertionError('Unsupported multi-instance scene accepted')
    print('MULTIPLE BILLBOARDS PASS;',len(bad),'invalid cases refused; one/two, coplanar tie and independent animation configurations accepted')


if __name__=='__main__':main()
