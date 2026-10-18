"""Independent assembled local-term cache checks; never a native FPS test.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import argparse,json,random
from pathlib import Path
from test_legacy_stability import Machine

def main():
    p=argparse.ArgumentParser();p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    m=Machine(a.build);rng=random.Random(112104);checked=0;cache_hits=0
    axes=[('x','XCOORD_COUNT',[0,3,6]),('y','YCOORD_COUNT',[1,4,7]),('z','ZCOORD_COUNT',[2,5,8])]
    def signed(x):return x-256 if x&128 else x
    def rounded(x):return max(-128,min(127,-((abs(x)+32)//64)if x<0 else(x+32)//64))&255
    def run(matrix,invalid=False):
        nonlocal checked,cache_hits
        for i,value in enumerate(matrix):m.cpu.memory[m.lab['m00']+i]=value&255
        if invalid:m.put('lr_terms_valid',0)
        hit=m.get('lr_terms_valid')and matrix==[signed(m.cpu.memory[m.lab['lr_terms_matrix']+i])for i in range(9)]
        m.call('build_coord_terms');cache_hits+=bool(hit)
        for axis,count,indices in axes:
            coords=m.cpu.memory[m.lab[axis+'coord']:m.lab[axis+'coord']+m.lab[count]]
            for index in indices:
                name=axis+'_m'+str(index//3)+str(index%3)
                native=m.cpu.memory[m.lab[name]:m.lab[name]+len(coords)]
                expected=[rounded(signed(v)*matrix[index])for v in coords]
                assert native==expected,(matrix,name,native,expected)
        checked+=1
    for _ in range(24):
        matrix=[rng.randrange(-80,81)for _ in range(9)];run(matrix,True);run(matrix)
        # Every individual matrix byte must invalidate the reuse condition.
        for i in range(9):
            altered=matrix[:];altered[i]=altered[i]+1 if altered[i]<80 else 79
            run(altered);run(altered);run(matrix)
    result=dict(passed=True,assembledPRGSHA256=m.hash,matrixCases=checked,cacheHitCases=cache_hits,
      comparedTo='Independent signed Q6 nearest/ties-away rounded and saturated products of immutable scene coordinate dictionaries; all nine matrix bytes varied individually; per-view invalidation covered.',FPS=False)
    a.out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))

if __name__=='__main__':main()
