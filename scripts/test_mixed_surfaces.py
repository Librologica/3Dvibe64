"""Check meaningful scene/configuration failures before native qualification."""
import copy,importlib.util,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'work'))
sys.path.insert(0,str(ROOT/'extensions/gameplay/materials'))
import surfaces


def main():
    from mode8.common import require_qualification_checks
    require_qualification_checks()
    # Shared vertices may have different intensities at a deliberate hard
    # crease. Values are per corner, not a single global vertex cache.
    scene={'meshes':[{'id':'room','faces':[[0,1,2],[0,2,3],[3,2,4]]}]}
    config={'schema':1,'meshes':{'room':[{'mode':'texture'}, {'mode':'flat','index':3},
        {'mode':'gouraud','levels':[0,16,32]}]}}
    original=copy.deepcopy(config)
    table=surfaces.compile_surfaces(scene,config)
    assert config==original
    assert [e['mode'] for e in table]==['texture','flat','gouraud']
    assert table[2]['levels']==[0,16,32] and table[1]['index']==3
    bad=[]
    def changed(edit):
        d=copy.deepcopy(config);edit(d);bad.append(d)
    changed(lambda d:d.update(schema=2))
    changed(lambda d:d.update(unknown=True))
    changed(lambda d:d['meshes'].update(other=[]))
    changed(lambda d:d['meshes']['room'].pop())
    changed(lambda d:d['meshes']['room'][0].update(mode='wire'))
    changed(lambda d:d['meshes']['room'][0].update(index=2))
    for value in (0,4,True,1.5):
        changed(lambda d,v=value:d['meshes']['room'][1].update(index=v))
    for levels in ([0,16],[-1,16,32],[0,16,33],[0,False,32],[0,16,31.5]):
        changed(lambda d,v=levels:d['meshes']['room'][2].update(levels=v))
    for d in bad:
        try:surfaces.compile_surfaces(scene,d)
        except ValueError:pass
        else:raise AssertionError('Invalid configuration accepted: '+str(d))
    print('MIXED SURFACES CONFIG PASS;',len(bad),'invalid configurations refused; corner levels preserved')


if __name__=='__main__':main()
