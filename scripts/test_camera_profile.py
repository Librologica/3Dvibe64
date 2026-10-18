"""Independent arithmetic checks on an external assembled camera experiment.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0. Not an FPS benchmark.
"""
import argparse,json,random
from test_legacy_stability import Machine

def main():
    p=argparse.ArgumentParser();p.add_argument('--build',type=__import__('pathlib').Path,required=True);p.add_argument('--out',type=__import__('pathlib').Path,required=True);a=p.parse_args()
    m=Machine(a.build);rng=random.Random(112102);pack=projection=commit=0
    for _ in range(2500):
        whole=rng.randrange(-1024,1024);fraction=rng.randrange(256)
        m.put('p1lo',whole,2);m.put('lc_fraction',fraction);m.call('lc_pack_q4')
        assert m.get('p1lo',2,True)==whole*16+(fraction>>4)
        assert m.get('legacy_camera_fault')==0;pack+=1
    for whole in (-32768,-1025,1024,32767):
        m.put('legacy_camera_fault',0);m.put('p1lo',whole,2);m.put('lc_fraction',123);m.call('lc_pack_q4')
        assert m.get('legacy_camera_fault')==1 and m.get('p1lo',2)==0
    for _ in range(1500):
        x=rng.randrange(-20000,20001);z=rng.randrange(-1000,20001)
        m.put('p1lo',x,2);m.put('lc_qz',z,2);m.call('lc_project_offset')
        n=abs(x);d=max(z,128)
        while n>=256:n//=2;d=max(1,d//2)
        expected=(n*170)//d
        assert m.get('mul16reslo',2)==expected,(x,z,m.get('mul16reslo',2),expected)
        assert bool(m.get('mul16sign')&128)==(x<0)
        projection+=1
    for _ in range(1000):
        x,y,z=[rng.randrange(-28000,28001)for _ in range(3)]
        m.put('explorer_view_x_lo',x,2);m.put('explorer_view_y_lo',y,2);m.put('p1lo',z,2);m.call('lc_commit_q4')
        assert [m.get(k,2,True)for k in ('lc_qx','lc_qy','lc_qz')]==[x,y,z]
        assert [m.get(k,2,True)for k in ('explorer_view_x_lo','explorer_view_y_lo','p1lo')]==[(v+8)//16 for v in (x,y,z)]
        commit+=1
    result=dict(passed=True,assembledPRGSHA256=m.hash,packCases=pack,rangeGuards=4,projectionCases=projection,commitCases=commit,FPS=False)
    a.out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))

if __name__=='__main__':main()
