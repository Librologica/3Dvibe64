"""RuntimeScene ownership/guards and optional emitted6502 correctness checks.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0. No FPS from CPU replay.
"""
import argparse
import copy
import json
from pathlib import Path
import random
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path[:0]=[str(ROOT/'work'),str(ROOT/'scripts')]
import runtime_scene as rs
from animated_mesh import table
from test_runtime_support import Machine


def host():
    fixture=dict(schema=1,axisConvention='engine-y-up',meshes=[],objects=[dict(id='a')],runtimeScene={})
    for change in [dict(unknown=True),dict(coordinateTerms='auto'),dict(rigidMatrixCache=1),dict(dynamicLens=1),dict(gouraudSaturation=0),dict(lighting={'missing':'solid'}),dict(lighting={'a':'solid'}),dict(beforePresent='foo+2')]:
        bad=copy.deepcopy(fixture);bad['runtimeScene']=change
        try:rs.prepare(bad,Path.cwd())
        except ValueError:pass
        else:raise AssertionError('Unknown configuration accepted: '+str(change))
    source=copy.deepcopy(fixture);scene,plan=rs.prepare(source,Path.cwd())
    assert source==fixture and 'runtimeScene' not in scene and plan['objects']==1
    fixture['objects']=[dict(id='a'),dict(id='b')]
    fixture['runtimeScene']={'support':{'lod':{'objects':2,'groups':[dict(near=0,far=1,enter=100,leave=200)]}}}
    scene,plan=rs.prepare(fixture,Path.cwd())
    assert not scene['objects'][0]['visible'] and scene['objects'][1]['visible']
    try:rs.emit('CAMERA_WALK_LITE = $00\n',plan)
    except ValueError:pass
    else:raise AssertionError('Wrong native profile accepted')
    assert b'\r' not in (ROOT/'work/build-3Dvibe64.ps1').read_bytes()
    from runtime_scene_view import roll
    combined=roll('render_frame_begin:\n\netpv_engine_walk_pitch_done:\n\ner_sphere_etpv_engine_walk_pitch_done:\n')
    assert combined.count(' jsr rs_view_roll\n')==2


def native(build):
    m=Machine(build);rng=random.Random(0x30)
    source=(build/'native.asm').read_text('utf-8-sig')
    for n in range(256):m.put('sqlo',(n*n//4),n);m.put('sqhi',(n*n//4)>>8,n)
    result={}
    if 'rs_build_terms' in m.labels:
        first,end=table(source,'mesh_vfirst'),table(source,'mesh_vend')
        indices=[table(source,'vert_'+a+'i') for a in 'xyz'];coords=[table(source,a+'coord') for a in 'xyz']
        for tick in range(80):
            obj=tick%m.labels['SCENE_OBJECT_COUNT'];m.put('objidx',obj);m.call('set_active_object')
            if tick%2==0:
                angles=[(rng.randrange(256),rng.randrange(256)) for _ in 'xyz'];scale=rng.choice([24,32,64,96])
            for a,(high,low) in zip('xyz',angles):m.put('ang'+a,high);m.put('ang'+a+'_lo',low)
            m.put('obj_scale_cur',scale)
            m.call('prepare_angles')
            mesh=m.get('meshidx');matrix=[m.get('rs_matrix_bytes',i) if 'rs_matrix_bytes' in m.labels else m.get('m00',i) for i in range(9)]
            for axis,k,coeffs in [('x',0,(0,3,6)),('y',1,(1,4,7)),('z',2,(2,5,8))]:
                for index in set(indices[k][first[mesh]:end[mesh]]):
                    for coeff in coeffs:
                        value=m.call('mul_s6',coords[k][index],matrix[coeff])[0]
                        assert m.get(axis+'_m'+str(coeff//3)+str(coeff%3),index)==value
            if 'rs_matrix_bytes' in m.labels:
                saved=[[m.get(a+'_m'+str(i//3)+str(i%3),j) for j in range(len(coords[k]))] for k,a in enumerate('xyz') for i in (k,3+k,6+k)]
                for i in range(9):m.put('m00',rng.randrange(256),i)
                m.call('prepare_angles')
                after=[[m.get(a+'_m'+str(i//3)+str(i%3),j) for j in range(len(coords[k]))] for k,a in enumerate('xyz') for i in (k,3+k,6+k)]
                assert after==saved,'Cache retained renderer scratch'
        result['coordinateAndRigidCases']=80
    if 'rs_view_multiply' in m.labels:
        for _ in range(1000):
            v=rng.randrange(-24000,24001);c=rng.randrange(-1024,1025)
            m.word('rs_view_value',v);m.word('rs_view_coef',c);m.call('rs_view_multiply')
            expected=(abs(v)*abs(c)+512)//1024*(-1 if (v<0)!=(c<0) else 1)
            assert (m.word('rs_view_result')+32768)%65536-32768==expected,(v,c,expected)
        result['rollProducts']=1000
    if 'rs_lens_set' in m.labels:
        for f in range(256):
            valid=64<=f<=254 and f%2==0
            assert bool(m.call('rs_lens_set',f)[1]&1)==valid,f
            if valid:assert m.get('rs_lens_focal')==f and m.get('rs_lens_half')==f//2 and m.word('rs_lens_times4')==4*f
        result['lensDomains']=256
    if 'rs_uniform_face' in m.labels:
        original=m.memory[:];checked=0
        for shade in (0,32):
            for clipped in (0,1):
                for buffer in (0,1):
                    for points in [[(20,20),(120,25),(95,80)],[(10,12),(130,13),(125,75),(15,80)]]:
                        snapshots=[]
                        for entry in ('draw_loaded_face_gouraud','rs_gouraud_original'):
                            m.memory[:]=original
                            for name,value in [('drawbuf',buffer),('clip_poly_active',clipped),('loaded_face_vertex_count',len(points)),('material_screen_cur',0x6e),('material_color_cur',1),('lowres_scanline_enabled',0),('sortj',0)]:
                                if name in m.labels:m.put(name,value)
                            for i in range(4):
                                x,y=points[min(i,len(points)-1)];m.put('vx'+str(i),x);m.put('vy'+str(i),y);m.put('gouraud_vshade'+str(i),shade)
                                for axis,value in [('x',x),('y',y)]:
                                    label=f'v{axis}q2_{i}lo'
                                    if label in m.labels:m.word(label,value*4)
                            if clipped:
                                m.put('clip_a_count',len(points))
                                for i,(x,y) in enumerate(points):
                                    for name,v in [('clip_a_x',x),('clip_a_y',y),('clip_a_shade',shade)]:m.put(name,v,i)
                            base=0x6000 if buffer==0 else m.labels['BITMAP_B_BASE']
                            m.memory[base:base+8192]=[0x39]*8192
                            try:m.call(entry)
                            except AssertionError as e:raise AssertionError((str(e),entry,shade,clipped,buffer,points)) from e
                            screen=m.labels['SCREEN_B_BASE'] if buffer else 0x5c00
                            snapshots.append((bytes(m.memory[base:base+8000]),bytes(m.memory[screen:screen+1024]),bytes(m.memory[0xd800:0xdc00])))
                        assert snapshots[0]==snapshots[1],('Uniform Gouraud mismatch',shade,clipped,buffer,points)
                        checked+=1
        result['uniformFramebufferCases']=checked
    if 'rs_light_valid' in m.labels and 'rs_frozen' in m.labels:
        for obj in range(m.labels['SCENE_OBJECT_COUNT']):
            if not m.get('rs_frozen',obj):continue
            m.put('objidx',obj);m.call('set_active_object')
            m.call('rs_invalidate_light',x=obj);m.call('gouraud_update_object_shades')
            first=m.get('object_runtime_shade_first',obj);end=m.get('object_runtime_shade_end',obj)
            snapshot=[m.get('gouraud_shade_value',i) for i in range(first,end)]
            m.put('light_intensity',0)
            m.call('gouraud_update_object_shades')
            assert snapshot==[m.get('gouraud_shade_value',i) for i in range(first,end)]
            assert m.get('rs_light_valid',obj)==1
        result['frozenOwnership']=True
    if 'rs_clear_tail_a' in m.labels:
        for bank,base in [(0,0x6000),(1,m.labels['BITMAP_B_BASE'])]:
            m.put('drawbuf',bank);m.memory[base:base+8192]=[0x5a]*8192
            m.call('clear_current_bitmap')
            assert m.memory[base:base+8000]==[0]*8000
            assert m.memory[base+8000:base+8192]==[0x5a]*192
        result['bitmapTails']=2
    return result


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--build',type=Path);args=p.parse_args()
    host();print('RUNTIME SCENE PASS',native(args.build) if args.build else 'host guards; native checks require --build')
