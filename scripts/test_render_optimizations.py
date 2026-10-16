"""Execute optimized 6502 arithmetic and packed spans against exact oracles.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0. Never estimates FPS.
"""
import argparse,importlib.util,json,random,sys
from pathlib import Path
from test_texture_perspective import Machine,builder,ROOT
from render_optimizations import degenerate_faces

def main():
    sys.path.insert(0,str(ROOT/'work'))
    from mode8.common import require_qualification_checks
    require_qualification_checks()
    p=argparse.ArgumentParser();p.add_argument('--control',type=Path,required=True);p.add_argument('--exact',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--mode4-scene',type=Path,required=True);a=p.parse_args();a.out=a.out.resolve();a.control=a.control.resolve();a.exact=a.exact.resolve()
    assert not a.out.resolve().is_relative_to(ROOT);a.out.mkdir(parents=True,exist_ok=True)
    old=Machine(a.control);new=Machine(a.exact);rng=random.Random(111014);vertices=0
    for pose in range(200):
        matrix=[rng.choice([0,0,256,-256,rng.randrange(-256,257)]) for _ in range(9)]
        if pose<4:
            matrix=[256,0,0,0,256,0,0,0,256]
            if pose&1:matrix=[0,0,256,0,256,0,-256,0,0]
            if pose&2:matrix=[-v for v in matrix]
        origins=[rng.randrange(-1048576,1048576) for _ in range(3)]
        for m in [old,new]:
            m.put('active_vfirst',0);m.put('active_vend',m.lab['VERT_COUNT'])
            for index,value in enumerate(matrix):m.put(f'hp_m{index//3}{index%3}',value&65535,2)
            for axis,value in zip('xyz',origins):m.put('hc_origin_'+axis,value&0xffffff,3)
            m.call('hp_prepare_terms');m.call('hp_build_vertices')
        arrays=[f'hc_cam_{axis}{n}' for axis in 'xyz' for n in range(3)]
        arrays+=['rxbuf','rybuf','sz','szhi']+[f'v{axis}raw{half}' for axis in 'xyz' for half in ['lo','hi']]
        for name in arrays:
            for index in range(old.lab['VERT_COUNT']):assert old.get(name,off=index)==new.get(name,off=index),(pose,name,index)
        vertices+=old.lab['VERT_COUNT']
    products=0
    for coefficient in range(-256,257):
        for value in [-8388608,-65536,-129,-128,-1,0,1,127,128,65535,8388607]:
            new.put('qc_a',value&0xffffff,3);new.put('qc_b',coefficient&65535,2);new.call('qc_product')
            expected=(abs(value*coefficient)+128)//256
            if value*coefficient<0:expected=-expected
            assert new.get('qc_r',3)==expected&0xffffff,(coefficient,value)
            products+=1
    module_path=ROOT/'extensions/gameplay/materials/surfaces.py'
    spec=importlib.util.spec_from_file_location('material_test',module_path);surfaces=importlib.util.module_from_spec(spec);spec.loader.exec_module(surfaces)
    table=[dict(mode=v) for v in ['texture','flat','gouraud']]
    assert surfaces.attribute_masks(table)==[31,1,17]
    assert surfaces.attribute_masks(table,gouraud_channel='s-w')==[15,1,11]
    try:
        builder.build(a.out/'must-not-build',a.mode4_scene,mode=4,camera_auto=True,engine_experiments='camera-extremes')
    except ValueError as ex:assert 'RENDER_CAMERA_UNQUALIFIED' in str(ex)
    else:raise AssertionError('Unqualified Mode4 camera option accepted')
    assert not (a.out/'must-not-build').exists()
    stub='''ptr0lo=$20
ptr0hi=$21
ptr1lo=$22
ptr1hi=$23
leftval=$24
rightval=$25
yrow=$26
gouraud_scan_x=$27
gouraud_scan_end=$28
mx_flat=$29
*=$0801
'''+surfaces.FLAT_KERNEL+'''
tq_closed: .fill 100,0
gouraud_init_span_pointers:
 lda gouraud_scan_x
 and #252
 asl
 sta ptr0lo
 sta ptr1lo
 lda #$10
 adc #0
 sta ptr0hi
 clc
 adc #4
 sta ptr1hi
 rts
'''
    builder.assemble(stub,a.out,'flat');(a.out/'3Dvibe64.prg').write_bytes((a.out/'flat.prg').read_bytes());(a.out/'3Dvibe64.labels').write_bytes((a.out/'flat.labels').read_bytes());m=Machine(a.out);spans=0
    for start in range(160):
        for length in [1,2,3,4,5,7,16,31,64,160]:
            last=min(159,start+length-1)
            for closed in [0,1]:
                if not closed and last==159:continue
                pigment=1+spans%3;row=spans%100
                before=[[rng.randrange(256) for _ in range(1024)] for _ in range(2)];expected=[v.copy() for v in before]
                for pixel in range(start,last+1):
                    offset=(pixel//4)*8;shift=6-2*(pixel&3)
                    for block in expected:block[offset]=(block[offset]&~(3<<shift))|(pigment<<shift)
                for address,block in zip([0x1000,0x1400],before):m.cpu.memory[address:address+1024]=block
                m.put('mx_flat',pigment);m.put('leftval',start);m.put('rightval',last if closed else last+1);m.put('yrow',row);m.put('tq_closed',closed,off=row);m.call('fc_draw')
                assert m.cpu.memory[0x1000:0x1400]==expected[0] and m.cpu.memory[0x1400:0x1800]==expected[1],(start,last,closed,pigment)
                spans+=1
    deg='''HAS_TRI_FACES=1
*=$0801
dm_collect_loop:
 jsr load_face_visible
dm_skip:
 inc faceidx
 lda faceidx
 cmp #5
 bne dm_collect_loop
 rts
load_face_visible:
 ldy faceidx
 inc visited,y
 rts
faceidx: .byte 0
face_vertex_count: .byte 3,3,3,4,3
face0: .byte 0,0,0,0,0
face1: .byte 0,1,1,0,1
face2: .byte 2,0,1,2,2
visited: .fill 5,0
'''
    # NMOS6502 has no INC absolute,Y: make the harness use X instead.
    deg=deg.replace(' ldy faceidx\n inc visited,y',' ldx faceidx\n inc visited,x')
    builder.assemble(degenerate_faces(deg),a.out,'degenerate')
    (a.out/'3Dvibe64.prg').write_bytes((a.out/'degenerate.prg').read_bytes());(a.out/'3Dvibe64.labels').write_bytes((a.out/'degenerate.labels').read_bytes());d=Machine(a.out);d.call('dm_collect_loop')
    assert [d.get('visited',off=i) for i in range(5)]==[0,0,0,1,1]
    result=dict(status='PASS',vertices=vertices,cameraProducts=products,flatSpans=spans,repeatedIndexTriangleCases=5,
                controlSHA256=builder.sha(a.control/'3Dvibe64.prg'),optimizedSHA256=builder.sha(a.exact/'3Dvibe64.prg'),FPSMeasured=False)
    (a.out/'result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
if __name__=='__main__':main()
