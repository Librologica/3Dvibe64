"""Validate real scene limits and reject unsupported billboard requests."""
import copy,importlib.util,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'work'))
spec=importlib.util.spec_from_file_location('bbscene',ROOT/'extensions/gameplay/billboards/scene.py')
scene=importlib.util.module_from_spec(spec);spec.loader.exec_module(scene)


def main():
    from mode8.common import require_qualification_checks
    require_qualification_checks()
    cfg,asset=scene.load(ROOT/'extensions/gameplay/profiles/interactive-billboard/assets/gameplay-scene.json')
    changed=copy.deepcopy(cfg);changed['billboards'][0].update(position=[-6,2,-1],size=[8,12])
    changed['billboards'][0]['animations']['idle']={'frames':[3,1,2],'ticksPerFrame':5}
    scene.validate(changed,asset)
    invalid=[]
    def bad(edit):
        d=copy.deepcopy(cfg);edit(d);invalid.append(d)
    bad(lambda d:d.update(schema=True))
    bad(lambda d:d['billboards'].append(copy.deepcopy(d['billboards'][0])))
    bad(lambda d:d['billboards'][0].update(position=[float('nan'),0,0]))
    bad(lambda d:d['billboards'][0].update(position=[0.001,0,0]))
    bad(lambda d:d['billboards'][0].update(size=[12,16]))
    bad(lambda d:d['billboards'][0]['animations']['idle'].update(frames=[6]))
    bad(lambda d:d['billboards'][0]['animations']['used'].update(ticksPerFrame=0))
    bad(lambda d:d['entity'].update(billboard='unknown'))
    bad(lambda d:d['entity'].update(useRange=0))
    bad(lambda d:d['entity'].update(demoUseKeys=[48]))
    for d in invalid:
        try:scene.validate(d,asset)
        except ValueError:pass
        else:raise AssertionError('Unsupported scene accepted')
    for value in (5,-1,True):
        a=copy.deepcopy(asset);a['frames'][0][0]=value
        try:scene.validate(cfg,a)
        except ValueError:pass
        else:raise AssertionError('Invalid pixel accepted')
    print('BILLBOARD SCENE PASS; JSON variation accepted;',len(invalid)+3,'invalid cases refused')


if __name__=='__main__':main()
