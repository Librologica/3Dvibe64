"""Asset-free host and assembled6502 contracts. Correctness only, never FPS.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import math
from pathlib import Path
import random
import re
import shutil
import subprocess
import sys
import tempfile

ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT/'work'),str(ROOT/'extensions/gameplay')]
import dynamics as d
import runtime_support_native as rs
from runtime_scene_view import roll


class Machine:
    def __init__(self,path):
        from py65.devices.mpu6502 import MPU
        self.labels={m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',(path/'native.labels').read_text(),re.M)}
        self.memory=[0]*65536
        raw=(path/'native.prg').read_bytes();base=int.from_bytes(raw[:2],'little');self.memory[base:base+len(raw)-2]=raw[2:]
        self.cpu=MPU(memory=self.memory)
    def get(self,n,i=0):return self.memory[self.labels[n]+i]
    def put(self,n,v,i=0):self.memory[self.labels[n]+i]=v&255
    def word(self,n,v=None,i=0):
        if v is None:return self.get(n,i)+256*self.get(n,i+1)
        self.put(n,v,i);self.put(n,v>>8,i+1)
    def call(self,n,a=0,x=0,y=0):
        c=self.cpu;c.pc=self.labels[n];c.a=a;c.x=x;c.y=y;c.sp=0xfd;c.p=32
        self.memory[0x1fe]=255;self.memory[0x1ff]=2
        for _ in range(2000000):
            if c.pc==0x300:return c.a,c.p
            c.step()
        raise AssertionError('Native routine did not return: '+n+' PC='+hex(c.pc))


def assemble(source,dest):
    # Only test harness placement; production uses the bounded engine allocator.
    source=source.replace('.virtual $4000\n','').replace('.endvirtual\n','')
    (dest/'native.asm').write_text('*=$2000\n'+source,encoding='ascii')
    cmd=[shutil.which('64tass'),'-a','-B','--vice-labels-numeric','--labels='+str(dest/'native.labels'),'-o',str(dest/'native.prg'),str(dest/'native.asm')]
    p=subprocess.run(cmd,capture_output=True)
    assert p.returncode==0,(p.stdout+p.stderr).decode(errors='replace')
    return Machine(dest)


def host():
    # Winding alone must never admit a self-intersecting star.
    for poly in [[(0,0),(1,1),(0,1),(1,0)],[(0,6),(4,-5),(-6,2),(6,2),(-4,-5)],[(0,0),(0,0),(1,0)]]:
        try:d.convex_polygon(poly)
        except ValueError:pass
        else:raise AssertionError('Invalid convex collider accepted')
    h=d.Hysteresis(10,20)
    assert [h.update(x) for x in [11,10,15,20,21,15,0]]==[False,True,True,True,False,False,True]
    assert d.easing_table()[0]==0 and d.easing_table()[-1]==256
    assert d.fragment_choices('p',['p','a','b'],1)[1] in [('a','b'),('b','a')]
    plan=d.fragment_plan('p',['a','b'],{'p':1,'a':1.2,'b':.8})
    assert abs(plan['relativeVolumeError'])<.04
    out=d.fragment_spawn([1,2,3],[4,5,6],[1,-2,3],fraction=.3)
    for name,expected in [('position',[1,2,3]),('velocity',[4,5,6])]:
        assert all(abs(.3*out[0][name][i]+.7*out[1][name][i]-v)<1e-12 for i,v in enumerate(expected))
    assert math.dist(out[0]['position'],out[1]['position'])<=.250001
    verts=[[0,0,0],[1,0,0],[0,1,0],[0,0,1]];faces=[[0,2,1],[0,1,3],[1,2,3],[2,0,3]]
    assert abs(d.mesh_volume(verts,faces)-1/6)<1e-12
    colors=d.solid_lamp_colors([[-2,0,0],[2,0,0],[0,1,2],[0,1,-2]],[[0,1,2],[1,0,3]],[0,10,0],dark=6,bright=14)
    assert colors[0]==colors[1]


def native():
    cfg=dict(random={},camera={},frustum={},particles=dict(slots=8),sat={},
             origin=dict(channels=[dict(low='test_x_lo',high='test_x_hi',count=4)]),
             contacts=dict(bodies=4,passes=3,pairBudget=8,priority=0,query='test_query',resolve='test_resolve',positions=[dict(low='test_x_lo',high='test_x_hi')],velocities=[dict(low='test_v_lo',high='test_v_hi')]),
             lod=dict(objects=4,groups=[dict(near=0,far=1,enter=100,leave=200)]),rigidPose=dict(objects=4))
    source=rs.emit_support(cfg)
    source+='''test_query:
 lda test_contact
 cmp #1
 rts
test_resolve:
 inc test_responses
 rts
test_contact: .byte 0
test_responses: .byte 0
test_x_lo: .fill 4,0
test_x_hi: .fill 4,0
test_v_lo: .fill 4,0
test_v_hi: .fill 4,0
lr_prepare: rts
'''
    for axis in 'xyz':
        for part in ('lo','hi','ext'):source+=f'explorer_cam_{axis}_{part}: .byte 0\n'
    for field in ('yaw_frac','pitch_frac','yaw','pitch'):source+=f'explorer_cam_{field}: .byte 0\n'
    for field in ('pos_x_lo','pos_x_hi','pos_y_lo','pos_y_hi','pos_z_lo','pos_z_hi','pos_z_ext','ang_x_lo','ang_x_hi','ang_y_lo','ang_y_hi','ang_z_lo','ang_z_hi','scale','visible'):source+=f'object_{field}: .fill 4,0\n'
    rng=random.Random(20261107)
    with tempfile.TemporaryDirectory(prefix='3dvibe64-support-') as temporary:
        m=assemble(source,Path(temporary))
        state=0xace1
        for _ in range(512):
            state,v=d.lfsr16(state);assert m.call('rs_sim_random')[0]==v
        sim=m.word('rs_sim_seed');fx=0x7319
        for i in reversed(range(8)):
            fx,point=d.sphere_sample(fx)
            # emit fills every slot; compare after one complete call below.
            if i==7:m.call('rs_particles_emit')
            actual=tuple(d.signed(m.get('rs_particle_v'+a,i),8) for a in 'xyz')
            assert actual==point,(actual,point)
        assert m.word('rs_fx_seed')==fx and m.word('rs_sim_seed')==sim
        positions=[[d.signed(m.get('rs_particle_'+a+'_lo',i)+256*m.get('rs_particle_'+a+'_hi',i)) for a in 'xyz'] for i in range(8)]
        velocities=[[d.signed(m.get('rs_particle_v'+a,i),8) for a in 'xyz'] for i in range(8)]
        for tick in range(40):
            positions,lives=d.advance_particles(positions,velocities,[max(0,32-tick)]*8);m.call('rs_particles_tick')
            for i in range(8):
                assert m.get('rs_particle_life',i)==lives[i]
                assert [d.signed(m.get('rs_particle_'+a+'_lo',i)+256*m.get('rs_particle_'+a+'_hi',i)) for a in 'xyz']==list(positions[i])
        for _ in range(300):
            vals=[rng.randrange(-32768,32768) for _ in range(12)]
            pose,target=vals[:6],vals[6:]
            for i in range(6):m.word('rs_camera_pose',pose[i],2*i);m.word('rs_camera_target',target[i],2*i)
            target[5]=max(-2048,min(2048,target[5]))
            m.call('rs_camera_tick')
            actual=[d.signed(m.word('rs_camera_pose',i=2*i)) for i in range(6)]
            expected=[d.smooth(a,b,angular=3<=i<=4) for i,(a,b) in enumerate(zip(pose,target))]
            assert actual==expected,(pose,target,actual,expected)
        for _ in range(500):
            center=[rng.randrange(-20000,20001) for _ in range(3)];radius=rng.randrange(3000);focal=rng.randrange(64,255)
            for i,v in enumerate(center):m.word('rs_bound_center',v,2*i)
            m.word('rs_bound_radius',radius);m.put('rs_bound_focal',focal)
            assert bool(m.call('rs_bounds_visible')[1]&1)==(not d.sphere_outside(center,radius,focal,near=128)),(center,radius,focal)
        for _ in range(100):
            values=[rng.randrange(-32768,32768) for _ in range(4)];delta=rng.randrange(-32768,32768)
            for i,v in enumerate(values):m.put('test_x_lo',v,i);m.put('test_x_hi',v>>8,i)
            m.call('rs_origin_shift',delta&255,y=(delta>>8)&255)
            assert [d.signed(m.get('test_x_lo',i)+256*m.get('test_x_hi',i)) for i in range(4)]==d.rebase([values],delta)[0]
        for _ in range(400):
            polygons=[]
            for p in 'ab':
                cx,cz=[rng.randrange(-35,36) for _ in range(2)];r=rng.randrange(3,20);n=rng.randrange(3,9);phase=rng.random()*math.tau
                poly=[(round(cx+r*math.cos(phase+i*math.tau/n)),round(cz+r*math.sin(phase+i*math.tau/n))) for i in range(n)]
                d.convex_polygon(poly);polygons.append(poly);m.put('rs_sat_'+p+'_count',n)
                for i,(x,z) in enumerate(poly):m.put('rs_sat_'+p+'_x',x,i);m.put('rs_sat_'+p+'_z',z,i)
            contact=d.sat_overlap(*polygons)[0];actual=bool(m.call('rs_sat_query')[1]&1)
            assert actual==contact,(polygons,actual,contact,m.get('rs_sat_status'))
            # Cached separating axis remains safe after arbitrary geometry change.
        m.put('rs_sat_a_count',2);assert not m.call('rs_sat_query')[1]&1 and m.get('rs_sat_status')==2
        for distance,expected in [(101,0),(100,1),(150,1),(201,0),(150,0)]:
            assert m.call('rs_lod_tick',distance&255,y=distance>>8)[0]==expected
            assert m.get('object_visible',0)==expected and m.get('object_visible',1)==1-expected
        assert not m.call('rs_lod_tick',x=255)[1]&1
        fields=('pos_x_lo','pos_x_hi','pos_y_lo','pos_y_hi','pos_z_lo','pos_z_hi','pos_z_ext','ang_x_lo','ang_x_hi','ang_y_lo','ang_y_hi','ang_z_lo','ang_z_hi','scale')
        values={field:rng.randrange(256) for field in fields}
        for field,value in values.items():m.put('object_'+field,value,1)
        assert m.call('rs_rigid_pose',x=1,y=3)[1]&1
        assert all(m.get('object_'+field,3)==value for field,value in values.items())
        before=m.memory[:];assert not m.call('rs_rigid_pose',x=4,y=3)[1]&1
        assert all(m.get('object_'+field,3)==before[m.labels['object_'+field]+3] for field in fields)
        for i in range(4):m.put('test_x_lo',i+1,i);m.put('test_x_hi',0,i);m.put('test_v_lo',-10,i);m.put('test_v_hi',255,i)
        m.call('rs_contacts_snapshot')
        for i in range(4):m.put('test_x_lo',99,i)
        m.put('test_contact',1);assert not m.call('rs_contacts_solve')[1]&1
        assert m.get('rs_contact_status')==1 and m.word('rs_contact_queries')==8
        assert [m.get('test_x_lo',i) for i in range(4)]==[1,2,3,4]
        assert [d.signed(m.get('test_v_lo',i)+256*m.get('test_v_hi',i)) for i in range(4)]==[-5]*4
        m.call('rs_contacts_snapshot');m.put('test_contact',0)
        assert m.call('rs_contacts_solve')[1]&1 and m.word('rs_contact_queries')==6
        assert not m.call('rs_contacts_solve')[1]&1 and m.get('rs_contact_status')==2
    return dict(random=512,camera=300,frustum=500,origin=100,convexSAT=400,particleTicks=40,contacts='budget/rollback/priority/snapshot',lod='hysteresis',rigidPose='copy/bounds')


if __name__=='__main__':
    host();print('RUNTIME SUPPORT PASS',native())
