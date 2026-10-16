"""Exact paired UV divider: self-contained assembled and ownership contracts.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. Run via the disposable-copy release runner.
"""
import json,random,tempfile
from pathlib import Path
from test_texture_perspective import ROOT,builder,Machine
import perspective_uvzp as uv

def restoring(a,d):
    if not d:return 0
    if a>=2*d:return (128*a//d)&255
    q=128 if a>=d else 0;r=a-d if a>=d else a
    for bit in (64,32,16,8,4,2,1):
        r*=2
        if r>=d:r-=d;q|=bit
    assert 0<=r<d
    return q

def guards():
    old=''.join(f' lda ps_cur0+{c}\n sta ps_a\n lda ps_cur1+{c}\n sta ps_a+1\n jsr ps_uv_divide\n sta m7_{n}\n' for c,n in ((0,'u'),(1,'v')))
    def apply(s):return uv.apply(s,{'perspective_sample':old,'data':''},[0])
    for s in ('FACE_COUNT = $E8\n',' lda #$e8\n'):
        assert 'perspective_uv_pair' in apply(s)[1]
    for s in ('irq_tmp = $00E8\n',' sta $e8\n','ZP_EXTERNAL = $ef\n'):
        try:apply(s)
        except ValueError as e:assert 'UV_ZP_CONFLICT' in str(e)
        else:raise AssertionError(s)
    for parts,pigments in (({'perspective_sample':'ri_full_channel:\n','data':''},[0]),({'perspective_sample':old,'data':''},[2])):
        before=json.dumps(parts,sort_keys=True);s,p=uv.apply('unchanged',parts,pigments)
        assert s=='unchanged' and json.dumps(p,sort_keys=True)==before

def main():
    guards();rng=random.Random(0x160e8);cases=[]
    for d in (0,1,2,3,127,128,255,256,257,511,512,1023,32767,32768,32769,65534,65535):
        values=sorted({max(0,min(65535,n)) for n in (0,1,d-1,d,d+1,2*d-1,2*d,65535)})
        cases.extend((u,v,d) for u in values for v in values)
    cases.extend((rng.randrange(65536),rng.randrange(65536),rng.randrange(65536)) for _ in range(12000))
    with tempfile.TemporaryDirectory(prefix='3dvibe64-uvzp-') as temporary:
        out=builder.build(Path(temporary)/'kernel',ROOT/'examples/mode7-perspective-cube.json',mode=7)
        k=Machine(out);assert k.lab['uz_remlo']==0xe8 and k.lab['uz_quotient']==0xee
        for u,v,d in cases:
            k.put('up_inputlo',u&255,off=0);k.put('up_inputlo',v&255,off=1)
            k.put('up_inputhi',u>>8,off=0);k.put('up_inputhi',v>>8,off=1)
            k.put('ps_den',d,2);k.put('ps_fault',0);k.call('up_pair')
            expected=[(128*x//d)&255 for x in (u,v)] if d else [0,0]
            assert [k.get('m7_u'),k.get('m7_v')]==expected,(u,v,d,expected)
            assert k.get('ps_fault')==(0 if d else 2)
    host=0
    for d in (1,2,3,127,128,255,256,257,511,512,1023,32767,32768,32769,65534,65535):
        for a in range(65536):
            assert restoring(a,d)==(128*a//d)&255;host+=1
    print(json.dumps({'assembledCases':len(cases),'hostSubsetInputs':host,'ownershipCases':5,'skipCases':2,'differences':0}))
    print('TEXTURE_UVZP: PASS; full 16-bit triples not exhaustively enumerated')

if __name__=='__main__':main()
