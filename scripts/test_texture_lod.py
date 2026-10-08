"""Property-based LOD selection and assembled sampler/SMC contracts.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. Run through the clean-copy release runner.
"""
import json,tempfile
from pathlib import Path
from test_texture_perspective import ROOT,Machine,builder

BAYER=((0,8,2,10),(12,4,14,6),(3,11,1,9),(15,7,13,5))

def check(k,meta,quality):
    tested=0;step=2 if quality=='fast' else 1
    for face,item in enumerate(meta['textureLOD']['faces']):
        tid=k.get('m7_face_texture',off=face)
        constant=meta['uniformTexturePigments'][tid]
        for depths in ((1,1,1,1),(28,28,28,28),(29,35,50,100),
                       (36,40,40,50),(43,44,100,200),(44,80,100,256),
                       (255,255,255,255),(-1,80,80,80),(2,80,80,80)):
            count=k.get('face_vertex_count',off=face)
            for corner in range(count):
                v=k.get('face'+str(corner),off=face)
                k.put('hc_cam_z0',0,off=v);k.put('hc_cam_z1',depths[corner]&255,off=v)
                k.put('hc_cam_z2',depths[corner]>>8&255,off=v)
            k.cpu.y=face;k.call('gouraud_load_face_raw_shades_y')
            depth=min(depths[:count])
            weight=16 if constant or depth<=28 else max(0,44-depth)
            assert k.get('ld_weight')==weight,(face,depths,weight,k.get('ld_weight'))
            assert k.get('pu_texel')==(constant or (item['modal'] if weight==0 else 0))
            assert k.cpu.memory[k.lab['ld_mix_site']]==(0x2c if weight==16 else 0x20)
            # Mixed-repeat address JMP must still point to a legal sampler.
            if k.cpu.memory[k.lab['m7_sample']+3]==0x4c:
                target=k.cpu.memory[k.lab['m7_sample']+4]+256*k.cpu.memory[k.lab['m7_sample']+5]
                assert target in [k.lab[n] for n in k.lab if n.startswith('m7_sampler_')]
            for y in range(4*step):
                for x in range(4):
                    row=y//step
                    far=item['accent'] if row%2==0 and x%2==0 else item['modal']
                    for pigment in (1,2,3):
                        expected=pigment if weight==16 or BAYER[row%4][x]<weight else far
                        k.put('yrow',y);k.put('gouraud_scan_x',x)
                        k.cpu.a=pigment;k.cpu.x=71;k.cpu.y=153
                        # BIT sites leave the sample unchanged; JSR sites execute mix.
                        if weight!=16:k.call('ld_mix')
                        assert k.cpu.a==expected and k.cpu.x==71 and k.cpu.y==153
                        tested+=1
            # Far path keeps encoder's domain check, even when UV sampling is skipped.
            k.put('ps_fault',0);k.put('hc_depth',257*256,3)
            k.call('ps_encode');assert k.get('ps_fault')!=0
    return tested

def main():
    results={}
    with tempfile.TemporaryDirectory(prefix='3dvibe64-lod-') as temporary:
        p=Path(temporary)
        original=json.loads((ROOT/'examples/mode7-perspective-cube.json').read_text())
        original.update(textureLOD='gradual',textureLODNear=28,textureLODFar=44)
        second=json.loads(json.dumps(original['textures'][0]));second.update(id='uniform',texels=[3]*256,repeat=[4,8])
        original['textures'].append(second)
        original['textures'][0]['repeat']=[1,1]
        original['meshes'][0]['faceTextures']=[None,'uniform',None,'uniform',None,'uniform']
        for quality,lighting in (('standard','gouraud'),('fast','gouraud'),('standard','none'),('standard','flat')):
            spec=json.loads(json.dumps(original));spec['textureQuality']=quality
            spec['textureLighting']=lighting
            if lighting!='gouraud':spec.pop('textureCompositor',None)
            name=quality+'-'+lighting
            scene=p/(name+'.json');scene.write_text(json.dumps(spec))
            out=builder.build(p/name,scene,mode=7)
            k=Machine(out);meta=json.loads((out/'build.json').read_text())
            results[name]=dict(samples=check(k,meta,quality),bytes=meta['bytes'],hash=meta['prgSHA256'])
        for bad in ((1,17),(28,45),(40,28),(240,256),(28.5,44.5),(True,17)):
            try:builder.build(p/'invalid',scene,mode=7,lod_near=bad[0],lod_far=bad[1])
            except ValueError as e:assert 'TEXTURE_LOD' in str(e)
            else:raise AssertionError(('invalid LOD accepted',bad))
    print('TEXTURE_LOD PASS',json.dumps(results),flush=True)

if __name__=='__main__':main()
