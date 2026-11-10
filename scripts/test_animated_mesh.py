"""AnimatedMesh contract, packed formats and exact native decoder checks.

Native CPU execution verifies correctness only. It never reports FPS.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import argparse
import copy
import json
from pathlib import Path
import random
import re
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'work'))
import animated_mesh as am


def oracle(frames, phase, linear=True):
    f,r=divmod(phase % (len(frames)*16),16)
    if not linear:r=0
    result=[]
    for a,b in zip(frames[f],frames[(f+1)%len(frames)]):
        result.append([x+(1 if y>=x else -1)*(abs(y-x)*r//16) for x,y in zip(a,b)])
    return result


def fixture():
    return dict(schema=1,axisConvention='engine-y-up',animatedMeshes=[dict(id='test',
        faces=[[0,1,2]],clips=[dict(id='move',frames=[[[0,0,0],[2,0,0],[0,2,0]],
                                                  [[0,0,0],[3,0,0],[0,2,1]]])])],
        objects=[dict(id='one',mesh='test',animation=dict(phase=3,step=19))])


def host():
    rng=random.Random(20261104)
    checked=0
    for n in (2,4,8,16,32,64):
        # All packed widths, zero/negative bases and >127 product intermediates.
        frames=[[[rng.randrange(-63,64) for a in range(3)] for v in range(7)] for f in range(n)]
        for f in range(n):
            frames[f][0]=[-63,-63+(f%2),-20+(f%4)]
            frames[f][1][0]=-6+(f%16)
        p=am.pack_clip(frames)
        for phase in range(n*16):
            assert am.sample(p,phase)==oracle(frames,phase)
            assert am.sample(p,phase,'step')==oracle(frames,phase,False)
            checked+=1
    original=fixture();before=copy.deepcopy(original)
    scene,plan=am.prepare(original,Path.cwd())
    assert original==before and 'animatedMeshes' not in scene
    assert plan['instances'][0]['phase']==3
    bad=[]
    def reject(fn):
        value=fixture();fn(value);bad.append(value)
    reject(lambda d:d.update(schema=True))
    reject(lambda d:d.update(axisConvention='world-z-up'))
    reject(lambda d:d.update(animatedMeshes=[]))
    reject(lambda d:d['animatedMeshes'][0].update(extra=1))
    reject(lambda d:d['animatedMeshes'][0].update(lighting='dynamic'))
    reject(lambda d:d['animatedMeshes'][0].update(creaseAngle=True))
    reject(lambda d:d.update(animatedMeshRenderer='auto'))
    reject(lambda d:d.update(animatedMeshRenderer='compact-gouraud',world={'grounds':[{}]}))
    reject(lambda d:d['animatedMeshes'][0]['faces'][0].__setitem__(0,9))
    reject(lambda d:d['animatedMeshes'][0]['faces'][0].__setitem__(0,True))
    reject(lambda d:d['animatedMeshes'][0]['clips'][0]['frames'][0][0].__setitem__(0,64))
    reject(lambda d:d['animatedMeshes'][0]['clips'][0]['frames'][0][0].__setitem__(0,True))
    reject(lambda d:d['animatedMeshes'][0]['clips'][0]['frames'].pop())
    reject(lambda d:d['animatedMeshes'][0]['clips'][0]['frames'][0].pop())
    reject(lambda d:d['objects'][0]['animation'].update(phase=32))
    reject(lambda d:d['objects'][0]['animation'].update(step=-1))
    reject(lambda d:d['objects'][0]['animation'].update(interpolation='spline'))
    reject(lambda d:d['objects'][0]['animation'].update(clip='missing'))
    reject(lambda d:d.update(timeline={'states':[{}]}))
    reject(lambda d:d.update(objects=[]))
    for value in bad:
        try:am.prepare(value,Path.cwd())
        except ValueError:pass
        else:raise AssertionError('Invalid AnimatedMesh accepted: '+str(value))
    compact=fixture();compact['animatedMeshRenderer']='compact-gouraud'
    _,plan=am.prepare(compact,Path.cwd())
    template=(ROOT/'work/build-3Dvibe64.ps1').read_text('utf-8-sig')
    body=''
    for kind,short in [('solid','fbs'),('pattern','fbp')]:
        for buffer in 'ab':
            first=f'fill_bounds_{kind}_{buffer}:\n';last=f'{short}_{buffer}_done:\n rts\n'
            body+=template[template.index(first):template.index(last,template.index(first))+len(last)]
    header=''.join(f'{n} = ${v:02x}\n' for n,v in {'GRAPHICS_MODE':6,'GOURAUD_MODE6':1,
        'RUNTIME_GRAPHICS_MODE_SWITCH':0,'HIDDEN_WIRE_ENABLE':0,'WIRE_MESH_COUNT':0,
        'FLAT_DYNAMIC_SHADE':0,'FACE_SOLID_COLOR_ENABLE':0,'WORLD_GROUND_ENABLE':0}.items())
    altered=header+body.replace(' lda row0lo_a,x\n',' nop\n lda row0lo_a,x\n',1)
    try:am.emit(altered,plan)
    except ValueError as error:assert 'unknown compact filler body hash' in str(error)
    else:raise AssertionError('Unknown compact template accepted')
    return dict(hostPhases=checked,invalidConfigurations=len(bad))


class Machine:
    def __init__(self, build):
        from py65.devices.mpu6502 import MPU
        self.labels={m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',
            (build/'labels.txt').read_text(),re.M)}
        self.memory=[0]*65536
        b=(build/'raw.prg').read_bytes();load=int.from_bytes(b[:2],'little')
        self.memory[load:load+len(b)-2]=b[2:]
        self.cpu=MPU(memory=self.memory)
    def get(self,n,i=0):return self.memory[self.labels[n]+i]
    def put(self,n,v,i=0):self.memory[self.labels[n]+i]=v&255
    def call(self,n,a=0,x=0):
        c=self.cpu;c.pc=self.labels[n];c.a=a;c.x=x;c.y=0;c.sp=0xfd;c.p=32
        self.memory[0x1fe]=255;self.memory[0x1ff]=2
        for _ in range(200000):
            if c.pc==0x300:return c.a,c.p
            c.step()
        raise AssertionError('Native call did not return '+n)


def native(build,scene_path):
    document=json.loads(scene_path.read_text('utf-8-sig'))
    scene,plan=am.prepare(document,scene_path.parent)
    m=Machine(build);m.call('am_reset_all')
    original_frames={asset['id']:{clip['id']:clip['frames'] for clip in asset['clips']}
                     for asset in document['animatedMeshes']}
    clip_keys=[(asset['id'],clip['id']) for asset in document['animatedMeshes'] for clip in asset['clips']]
    coordinate_minimum=[min(n-256 if n>127 else n for n in
        am.table((build/'3Dvibe64.asm').read_text('utf-8-sig'),axis+'coord')) for axis in 'xyz']
    phases=0
    for instance in plan['instances']:
        obj=instance['object'];mesh=m.get('object_mesh',obj);first=m.get('mesh_vfirst',mesh)
        for clip_index,(asset,cid) in enumerate(clip_keys):
            if asset!=plan['assets'][instance['asset']]:continue
            m.call('am_set_clip',clip_index,obj)
            frames=original_frames[asset][cid]
            for phase in range(16*len(frames)):
                m.put('objidx',obj);m.put('meshidx',mesh)
                m.put('am_phase_lo',phase,obj);m.put('am_phase_hi',phase>>8,obj)
                m.call('am_prepare_object')
                expected=oracle(frames,phase,instance['interpolation']=='linear')
                actual=[[m.get('vert_'+axis+'i',first+v)+coordinate_minimum[a] for a,axis in enumerate('xyz')]
                        for v in range(len(frames[0]))]
                assert actual==expected,(obj,clip_index,phase,actual,expected)
                phases+=1
    # Alternating instances sharing the source must never retain another phase.
    m.call('am_reset_all')
    for tick in range(160):
        m.call('am_tick')
        for instance in reversed(plan['instances']):
            obj=instance['object'];mesh=m.get('object_mesh',obj);first=m.get('mesh_vfirst',mesh)
            phase=(instance['phase']+(tick+1)*instance['step']) % (plan['clips'][instance['clip']]['packed']['frames']*16)
            assert m.get('am_phase_lo',obj)+256*m.get('am_phase_hi',obj)==phase
            m.put('objidx',obj);m.put('meshidx',mesh);m.call('am_prepare_object')
            expected=oracle(original_frames[clip_keys[instance['clip']][0]][clip_keys[instance['clip']][1]],phase,instance['interpolation']=='linear')
            actual=[[m.get('vert_'+axis+'i',first+v)+coordinate_minimum[a] for a,axis in enumerate('xyz')]
                    for v in range(len(expected))]
            assert actual==expected,('shared phase',tick,obj)
    before=[m.get('am_clip',i) for i in range(plan['objects'])]
    assert m.call('am_set_clip',255,0)[1]&1
    assert m.call('am_set_clip',0,255)[1]&1
    assert before==[m.get('am_clip',i) for i in range(plan['objects'])]
    if len(plan['assets'])>1:
        first=plan['instances'][0]
        other=next(i for i,c in enumerate(plan['clips']) if c['asset']!=first['asset'])
        assert m.call('am_set_clip',other,first['object'])[1]&1
        assert before==[m.get('am_clip',i) for i in range(plan['objects'])]
    # Static objects sharing the scene must never be decoded by this extension.
    animated={i['object'] for i in plan['instances']}
    for obj in set(range(plan['objects']))-animated:
        m.put('objidx',obj);m.put('meshidx',m.get('object_mesh',obj))
        saved=m.memory[:]
        m.call('am_prepare_object')
        for name in ('vert_xi','vert_yi','vert_zi'):
            start=m.labels[name]
            assert m.memory[start:start+len(am.table((build/'3Dvibe64.asm').read_text('utf-8-sig'),name))]==saved[start:start+len(am.table((build/'3Dvibe64.asm').read_text('utf-8-sig'),name))]
    if 'am_light_first' in m.labels:
        obj=next(i['object'] for i in plan['instances'] if i['frozen'])
        m.put('objidx',obj);first=m.get('object_runtime_shade_first',obj);end=m.get('object_runtime_shade_end',obj)
        for name in ('sh_nx','sh_ny','sh_nz','light_intensity'):m.put(name,0)
        for v in range(first,end):
            for name in ('gouraud_normal_x','gouraud_normal_y','gouraud_normal_z','gouraud_center_dot_lo','gouraud_center_dot_hi'):m.put(name,0,v)
            m.put('gouraud_shade_value',32,v)
        for n in range(256):
            q=n*n//4;m.put('sqlo',q,n);m.put('sqhi',q>>8,n)
        m.call('am_invalidate_light',x=obj);m.call('gouraud_update_object_shades')
        # A zero reference dot/intensity yields target0; the old hysteresis
        # would have left28 here if invalidation had not cleared stale values.
        assert all(m.get('gouraud_shade_value',v)==0 for v in range(first,end))
        assert m.get('am_light_valid',obj)==1
    # Product test uses original arithmetic, independently of the packed decoder.
    arithmetic=0
    rng=random.Random(714)
    for _ in range(2500):
        a=rng.randrange(127);b=rng.randrange(127);f=rng.randrange(16)
        m.put('am_a',a);m.put('am_b',b);m.put('am_fraction',f)
        actual=m.call('am_interpolate')[0]
        expected=a+(1 if b>=a else -1)*(abs(b-a)*f//16)
        assert actual==expected,(a,b,f,actual,expected)
        arithmetic+=1
    return dict(nativePhases=phases,nativeSharedTicks=160,nativeProducts=arithmetic,
                frozenRelightChecked='am_light_first' in m.labels)


def main():
    parser=argparse.ArgumentParser();parser.add_argument('--native-build',type=Path)
    parser.add_argument('--scene',type=Path);parser.add_argument('--out',type=Path)
    args=parser.parse_args();result=host()
    if args.native_build:
        assert args.scene
        result.update(native(args.native_build,args.scene))
    result.update(status='passed',FPSMeasured=False)
    if args.out:args.out.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(result))


if __name__=='__main__':main()
