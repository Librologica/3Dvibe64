"""Execute the emitted 6510 line kernel against an independent closed form.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. Run through the clean-copy release runner.
"""
import json,random,tempfile
from pathlib import Path
from test_texture_perspective import ROOT,Machine,builder

def oracle(q):
    x0,y0,x1,y1=[(v+2)//4 for v in q]
    major=abs(y1-y0)>abs(x1-x0)
    a,b,c,d=(y0,y1,x0,x1) if major else (x0,x1,y0,y1)
    if b<a:a,b,c,d=b,a,d,c
    n=b-a;delta=abs(d-c);sign=1 if d>=c else -1
    return [((c+sign*((j*delta+n//2)//n if n else 0),a+j) if major else
             (a+j,c+sign*((j*delta+n//2)//n if n else 0))) for j in range(n+1)]

def raster(k):
    rng=random.Random(1982)
    cases=[(0,0,636,396),(0,396,636,0),(0,0,0,0),(1,1,2,2),
           (0,0,636,0),(0,0,0,396),(635,395,636,396)]
    cases += [tuple(rng.randrange(v+1) for v in (636,396,636,396)) for _ in range(1600)]
    k.cpu.memory[k.lab['qw_emit']]=0x60
    count=0;cycles=[]
    for q in cases:
        for endpoints in (q,(q[2],q[3],q[0],q[1])):
            for name,val in zip(('x0','y0','x1','y1'),endpoints):k.put('qw_'+name,val,2)
            k.cpu.pc=k.lab['qw_line'];k.cpu.sp=0xfd;k.cpu.p=0x20
            k.cpu.memory[0x1fe]=0xff;k.cpu.memory[0x1ff]=0xfd
            start=k.cpu.processorCycles;points=[]
            for _ in range(20000):
                if k.cpu.pc==0xfe00:break
                if k.cpu.pc==k.lab['qw_emit']:
                    a,b=k.get('qw_pos'),k.get('qw_minor')
                    points.append((b,a) if k.get('qw_major') else (a,b))
                assert k.cpu.pc not in (k.lab['hp_mul'],k.lab['hc_div40'])
                k.cpu.step()
            else:raise AssertionError('line runaway')
            assert points==oracle(endpoints),(endpoints,points)
            assert all(0<=x<160 and 0<=y<100 for x,y in points)
            assert all(max(abs(x-u),abs(y-v))==1 for (x,y),(u,v) in zip(points,points[1:]))
            cycles.append(k.cpu.processorCycles-start);count+=1
    return dict(cases=count,maxInstructionCyclesEmitterStubbed=max(cycles))

def main():
    result={}
    with tempfile.TemporaryDirectory(prefix='3dvibe64-hybrid-') as temporary:
        p=Path(temporary)
        for mode in (1,2,5):
            out=builder.build(p/f'm{mode}',ROOT/f'examples/q8/two-objects-mode{mode}.json',
                              mode=mode,line_raster='hybrid',camera_mobile=True)
            k=Machine(out);result[mode]=raster(k)
            precise=builder.build(p/f'm{mode}-precise',ROOT/f'examples/q8/two-objects-mode{mode}.json',
                                  mode=mode,camera_mobile=True)
            compared=0
            for pose in ((0,0,4*256,0,0),(3*256+127,0,4*256,4,0),
                         (-8*256,5*256,6*256,252,2),(12*256,18*256,1*256,8,248),
                         (0,45*256,4*256,0,0),(20*256,35*256,10*256,16,8)):
                a,b=Machine(precise),Machine(out)
                for m in (a,b):
                    for axis,value in zip('xyz',pose[:3]):
                        for i,suf in enumerate(('lo','hi','ext')):m.put('explorer_cam_'+axis+'_'+suf,value>>(8*i)&255)
                    for axis,value in zip(('yaw','pitch'),pose[3:]):m.put('explorer_cam_'+axis,value)
                    for obj in range(2):
                        m.put('objidx',obj);m.call('set_active_object');m.call('explorer_transform_project_vertices')
                    assert m.get('hp_fault')==0
                names=[f'hc_cam_{axis}{i}' for axis in 'xyz' for i in range(3)]+['sxq2_lo','sxq2_hi','syq2_lo','syq2_hi','projdone']
                for name in names:
                    n=a.lab['VERT_COUNT']
                    assert a.cpu.memory[a.lab[name]:a.lab[name]+n]==b.cpu.memory[b.lab[name]:b.lab[name]+n],(mode,pose,name)
                    compared+=n
            result[mode].update(geometryPoses=6,geometryBytesCompared=compared)
            if mode==5:
                # Exercise the actual clipped-polygon dispatch, not just the line routine.
                k=Machine(out);k.put('xyq2_face_valid',1);k.put('hc_count',4)
                corners=[(4,4),(632,4),(632,392),(4,392)]
                for i,(x,y) in enumerate(corners):
                    for axis,v in (('x',x),('y',y)):
                        k.put('hc_a_'+axis+'lo',v&255,off=i);k.put('hc_a_'+axis+'hi',v>>8,off=i)
                k.cpu.memory[k.lab['qw_line']]=0x60
                k.call('mode5_draw_loaded_polygon_outline')
                assert k.get('qw_poly_i')==4
                assert k.get('qw_x0',2)==4 and k.get('qw_y0',2)==392
                assert k.get('qw_x1',2)==4 and k.get('qw_y1',2)==4
        try:builder.build(p/'wrong-mode',ROOT/'examples/q8/two-objects-mode4.json',mode=4,line_raster='hybrid')
        except ValueError as e:assert 'LINE_RASTER' in str(e)
        else:raise AssertionError('hybrid accepted in Mode4')
    print('LINE_HYBRID PASS',json.dumps(result),flush=True)

if __name__=='__main__':main()
