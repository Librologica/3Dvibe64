"""Independent fixed-point host oracles, isolated per mono map instance."""
import importlib.util, math
from pathlib import Path
from .build import validate
from . import model

def adapter(data):
    c=validate(data,route=False);s=data['scene']
    if c['backend']=='multi':
        p=model.preprocess(s)
        return c,lambda pose:model.render(p,pose),dict(p=p,nav=data['navigation'])
    spec=importlib.util.spec_from_file_location('mode8._mono_instance',Path(__file__).with_name('mono.py'))
    vm=importlib.util.module_from_spec(spec);spec.loader.exec_module(vm)
    def upper(grid):
        out=bytearray(grid)
        for i,(x0,y0,x1,y1) in enumerate(s['doors']):
            for y in range(y0,y1+1):
                for x in range(x0,x1+1):out[y*32+x]=9+i
        return bytes(out)
    vm.upper=upper
    if c['backend']=='mono-opaque':
        def raw(dep):
            dist=(min(1023,dep//16)+.5)/16;h=128/vm.TAN/dist
            clip=lambda v:max(0,min(144,math.floor(v+.5)))
            return clip(72-3*h),clip(72+h),clip(72-h)
        vm.raw_height=raw
        vm.project=lambda h:(max(0,72-(3*h+15)//32),min(144,72+(h+16)//32),max(0,72-(h+15)//32))
    g=bytes(s['solid'])
    return c,lambda pose:vm.raster(g,pose[:3]),dict(vm=vm,g=g,nav=data['navigation'])
