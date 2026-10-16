"""Reusable engine experimental contracts; assembled correctness, no replay FPS.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import importlib.util,json,random,re,sys,tempfile
from pathlib import Path
from py65.devices.mpu6502 import MPU
from test_texture_perspective import ROOT,Machine,builder
sys.path.insert(0,str(ROOT/'work'))
from experiments import parse
def main():
    rng=random.Random(110202)
    assert parse('none','q8')==set() and len(parse('all','q8'))==4
    for value,family in [('mode8-rays','q8'),('camera-table','mode8'),('unknown','q8')]:
        try:parse(value,family)
        except ValueError:pass
        else:raise AssertionError('invalid option accepted')
    with tempfile.TemporaryDirectory(prefix='3dvibe64-engine-') as temporary:
        out=Path(temporary)
        q=Machine(builder.build(out/'q',ROOT/'examples/mode7-perspective-cube.json',mode=7,engine_experiments='q8-arithmetic,uv-texel'))
        for i in range(3000):
            a=rng.randrange(1<<48);b=rng.choice([1,65535,65536,0xffffff,rng.randrange(1,1<<24)])
            q.put('hc_num',a,6);q.put('hc_divisor',b,3);q.call('hc_div40')
            assert (q.get('hc_num',6),q.get('hc_remainder',4))==divmod(a,b)
        # All addressing precisions and mixed-axis repeats, including full fallback.
        import perspective_uvzp
        for bits in [(3,3),(3,7),(4,5),(5,4),(6,6),(7,7)]:
            source='*=$0800\n'+perspective_uvzp.kernel(bits)
            for name in ['ps_den','up_inputlo','up_inputhi','uz_remlo','uz_remhi','uz_denlo','uz_denhi','uz_quotient','m7_u','m7_v','ps_a','ps_uv_divide']:
                source+=f'{name}=${q.lab[name]:04x}\n'
            bld=out/('uv-'+''.join(map(str,bits)));bld.mkdir();builder.assemble(source,bld,'uv')
            raw=(bld/'uv.prg').read_bytes();q.cpu.memory[0x800:0x800+len(raw)-2]=raw[2:]
            q.lab['up_pair']=0x800
            for i in range(1000):
                den=rng.randrange(1,65536);q.put('ps_den',den,2)
                values=[rng.randrange(65536) for _ in range(2)]
                for ch,a in enumerate(values):q.put('up_inputlo',a&255,off=ch);q.put('up_inputhi',a>>8,off=ch)
                q.call('up_pair')
                for ch,a in enumerate(values):
                    mask=(255<<(7-bits[ch]))&255
                    assert q.get('m7_u',off=ch)&mask==((128*a//den)&mask)
        camera=Machine(builder.build(out/'camera',ROOT/'examples/q8/two-objects-mode4.json',mode=4,camera_auto=True,engine_experiments='camera-table,visibility,q8-arithmetic'))
        sparse=Machine(builder.build(out/'sparse',ROOT/'examples/experiments/visibility-sparse.json',mode=4,engine_experiments='visibility'))
        for obj in range(6):
            sparse.put('objidx',obj);sparse.call('ev_object_visible');visible=bool(sparse.cpu.p&1)
            pos=[sparse.get('ev_'+ax,3) for ax in 'xyz'];pos=[v if v<0x800000 else v-0x1000000 for v in pos]
            radius=sparse.get('ev_radius',off=obj)*256
            expected=pos[2]+radius>=0 and all(abs(v)-pos[2]<=2*radius+255 for v in pos[:2])
            assert visible==expected and visible==(obj in [0,1,5]),(obj,pos,radius,visible)
        sparse.put('objidx',2);radius=sparse.get('ev_radius',off=2)*256
        for _ in range(600):
            pos=[rng.randrange(-256*256,256*256) for _ in range(3)]
            for ax,v in zip('xyz',pos):sparse.put('hc_origin_'+ax,v&0xffffff,3)
            sparse.call('ev_origin_ok')
            expected=pos[2]+radius>=0 and all(abs(v)-pos[2]<=2*radius+255 for v in pos[:2])
            assert bool(sparse.cpu.p&1)==expected,(pos,radius)
        for _ in range(80):
            coefs=[rng.randrange(-256,257) for _ in range(4)]
            for n,v in zip(['qc_ys','qc_yc','qc_ps','qc_pc'],coefs):camera.put(n,v&65535,2)
            camera.call('qt_update')
            for slot,b in enumerate(coefs):
                for a in [-0x800000,-129,-128,-1,0,1,128,129,0x7fffff]:
                    camera.put('qt_selector',slot);camera.put('qc_a',a&0xffffff,3);camera.put('qc_b',b&65535,2);camera.call('qc_product')
                    v=(abs(a*b)+128)//256;v=-v if a*b<0 else v
                    assert camera.get('qc_r',3)==v&0xffffff
    print('ENGINE_EXPERIMENTS: PASS; division=3000 UV=6000 camera=2880 visibility=606; no replay FPS')
if __name__=='__main__':main()
