"""External assembled convex pair/fan callbacks. Correctness only, never FPS.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import argparse,json,random
from pathlib import Path
from test_legacy_plus_exact import Machine

def convex(points):
    signs=[];n=len(points)
    for i,(x,y) in enumerate(points):
        a,b=points[(i+1)%n]
        for j,(c,d) in enumerate(points):
            if j in (i,(i+1)%n):continue
            cross=(a-x)*(d-y)-(b-y)*(c-x)
            signs.append(0 if not cross else 1 if cross>0 else -1)
    return 0 not in signs and len(set(signs))==1

def load(m,points):
    m.put('loaded_face_vertex_count',len(points));m.put('clip_poly_active',0);m.put('near_face_crossing',0)
    for i,(x,y) in enumerate(points):
        m.put('vx'+str(i),x);m.put('vy'+str(i),y//4);m.put('vxq2_'+str(i)+'lo',x*4,2);m.put('vyq2_'+str(i)+'lo',y,2)
    m.mem[m.lab['leftb']:m.lab['leftb']+100]=[255]*100;m.mem[m.lab['rightb']:m.lab['rightb']+100]=[0]*100

def bounds(m):return [m.mem[m.lab[k]:m.lab[k]+100] for k in ['leftb','rightb']]

def main():
    p=argparse.ArgumentParser();p.add_argument('--control',type=Path);p.add_argument('--exact',type=Path);p.add_argument('--out',type=Path);a=p.parse_args()
    if not a.control and not a.exact:
        assert convex([(0,0),(159,0),(159,396),(0,396)])
        assert not convex([(0,0),(159,396),(0,396),(159,0)])
        print('EXACT_PANEL contract PASS; native callbacks require external build inputs');return
    assert a.control and a.exact and __debug__
    ref,opt=Machine(a.control),Machine(a.exact);rng=random.Random(7439)
    assert ref.lab['HAS_TRI_FACES']==1, 'Control must retain the native triangle fallback'
    accepted=0;attempts=0
    while accepted<400:
        pts=[(rng.randrange(160),rng.randrange(397)) for _ in range(4)];attempts+=1
        if not convex(pts):continue
        # Actual original two triangle walks, including both diagonal directions.
        union=[[255]*100,[0]*100]
        for indices in [(0,1,2),(0,2,3)]:
            load(ref,[pts[i] for i in indices]);ref.call('build_loaded_face_bounds_xyq2');v=bounds(ref)
            union=[[min(x,y) for x,y in zip(union[0],v[0])],[max(x,y) for x,y in zip(union[1],v[1])]]
        load(opt,pts);opt.call('er_try_pair_bounds')
        if not opt.cpu.p&1:continue # valid geometric shape with no sample row may fall back
        got=bounds(opt);assert got==union,('pair boundaries',pts,got,union)
        accepted+=1
    # Concave, crossing and near-clipped panels must preserve the full fallback.
    for pts in [[(0,0),(159,396),(0,396),(159,0)],[(0,0),(159,0),(40,40),(0,396)]]:
        load(opt,pts);opt.call('er_try_pair_bounds');assert not opt.cpu.p&1
    load(opt,[(0,0),(159,0),(159,396),(0,396)]);opt.put('near_face_crossing',1);opt.call('er_try_pair_bounds');assert not opt.cpu.p&1
    merged=0
    for i in range(400):
        # Convex triangles clipped into4+vertices, random fan anchoring.
        x0=rng.randrange(0,40);x1=rng.randrange(90,160);y0=rng.randrange(0,30);y1=rng.randrange(60,100)
        pts=[(x0,y0),(x1,y0),(x1,y1),(x0,y1)]
        if i%2:pts=[(x0,y0+4),(x0+8,y0),(x1-8,y0),(x1,y0+8),(x1,y1-8),(x1-8,y1),(x0+8,y1),(x0,y1-8)]
        if not convex(pts):continue
        shift=i%len(pts);pts=pts[shift:]+pts[:shift];images=[]
        for m in (ref,opt):
            m.put('clip_a_count',len(pts));m.put('clip_poly_active',1);m.put('near_face_crossing',0);m.put('fillbyte',[0,85,170,255][i%4]);m.put('lowres_scanline_enabled',0)
            for j,(x,y) in enumerate(pts):m.mem[m.lab['clip_a_x']+j]=x;m.mem[m.lab['clip_a_y']+j]=y
            base=m.mem[m.lab['row0lo_a']]+256*m.mem[m.lab['row0hi_a']];initial=bytes((k*37+11)&255 for k in range(8000));m.mem[base:base+8000]=initial
            if m is opt:
                at=m.lab['er_clip_fill'];target=m.lab['fill_bounds_solid_a'];m.mem[at+1]=target&255;m.mem[at+2]=target>>8
                m.call('er_merge_begin');merged+=bool(m.get('er_merge_active'))
            m.call('draw_clip_poly_solid_a');images.append(bytes(m.mem[base:base+8000]))
        assert images[0]==images[1],('clipped fan pixels',pts)
    uniform=opt.lab['FACE_MATERIAL_ACTIVE_ONLY']==opt.lab['FACE_REFLECTIVITY_ACTIVE_ONLY']==1 and opt.lab['FACE_SOLID_COLOR_ENABLE']==opt.lab['VIC_COLOR_POLICY_ENABLE']==0
    assert merged>50 if uniform else merged==0,(uniform,merged)
    report=dict(passed=True,trianglePairs=accepted,trianglePairAttempts=attempts,clippedFanInputs=400,mergedFans=merged,explicitFallbackCases=3,uniformPaletteFastPathEnabled=uniform,nativeFPSMeasured=False)
    if a.out:a.out.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))

if __name__=='__main__':main()
