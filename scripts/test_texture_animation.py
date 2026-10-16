"""Texture atlas, material binding, timing and unsupported data boundaries."""
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
    spec=importlib.util.spec_from_file_location('texture_animation',ROOT/'extensions/gameplay/materials/animation.py')
    mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
    cfg=json.loads((ROOT/'extensions/gameplay/profiles/animated-textures/assets/texture-animation.json').read_text(encoding='utf-8'))
    asset=json.loads((ROOT/'extensions/gameplay/profiles/animated-textures/assets/texture-frames.json').read_text(encoding='utf-8'))
    mesh=dict(id='room',faces=[[0,1,2]]*16,faceTextures=['stone']*16)
    scene=dict(meshes=[mesh],textures=[dict(id='stone',width=16,height=16,texels=asset['frames'][0])])
    surfaces=[dict(mode='texture') for _ in range(16)];surfaces[8]=dict(mode='gouraud')
    mod.validate(cfg,asset,scene,surfaces)
    empty=copy.deepcopy(cfg);empty['materials']=[];mod.validate(empty,asset,scene,surfaces)
    combined=copy.deepcopy(cfg);combined['materials'][1].update(frames=[3,0,2],ticksPerFrame=3);combined['materials'][1]['scroll']={'step':[-15,15],'ticks':255};mod.validate(combined,asset,scene,surfaces)
    bad=[]
    def reject(edit):
        d=copy.deepcopy(cfg);edit(d);bad.append(d)
    reject(lambda d:d.update(schema=True))
    reject(lambda d:d.update(running=1))
    reject(lambda d:d.update(sourceTexture='missing'))
    reject(lambda d:d['materials'].append(copy.deepcopy(d['materials'][0])))
    reject(lambda d:d['materials'][1].update(id='changing-wall'))
    reject(lambda d:d['materials'][1].update(faces=[6]))
    reject(lambda d:d['materials'][0].update(faces=[14]))
    reject(lambda d:d['materials'][0].update(faces=[8]))
    reject(lambda d:d['materials'][0].update(faces=[16]))
    reject(lambda d:d['materials'][0].update(faces=[True]))
    reject(lambda d:d['materials'][0].update(frames=[4]))
    reject(lambda d:d['materials'][0].update(frames=[]))
    reject(lambda d:d['materials'][0].update(ticksPerFrame=0))
    reject(lambda d:d['materials'][0].update(ticksPerFrame=256))
    reject(lambda d:d['materials'][0]['scroll'].update(ticks=True))
    reject(lambda d:d['materials'][0]['scroll'].update(step=[.5,0]))
    reject(lambda d:d['materials'][0]['scroll'].update(step=[16,0]))
    for d in bad:
        try:mod.validate(d,asset,scene,surfaces)
        except ValueError:pass
        else:raise AssertionError('Unsupported texture animation accepted')
    broken=[]
    for edit in [lambda a:a.update(width=8),lambda a:a['frames'].append(a['frames'][0]),lambda a:a['frames'][1].__setitem__(0,0),lambda a:a['frames'][1].__setitem__(0,True),lambda a:a['frames'][0].reverse(),lambda a:a['frames'][1].__setitem__(0,3 if a['frames'][1][0]!=3 else 1)]:
        a=copy.deepcopy(asset);edit(a);broken.append(a)
    for a in broken:
        try:mod.validate(cfg,a,scene,surfaces)
        except ValueError:pass
        else:raise AssertionError('Invalid resident atlas accepted')
    print('TEXTURE ANIMATION PASS;',len(bad)+len(broken),'invalid cases refused; empty and combined frame/UV groups accepted')


if __name__=='__main__':main()
