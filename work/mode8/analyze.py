"""python -B scripts/analyze_mode8.py --scene scene.json --sampling corpus.json --out reports/lab/..."""
import argparse,sys,csv,math
from collections import defaultdict
from pathlib import Path
from .common import ROOT,load,save,sha,writable,stats,digest
from .reference import adapter
from .contract import valid_pose
from .trace import Trace

def atlas(s,rows,out,invalid=()):
    from PIL import Image,ImageDraw
    cells=defaultdict(list)
    for r in rows:cells[(r['pose'][0]//256,r['pose'][1]//256)].append(r)
    mx=max(r['cycles'] for r in rows)
    start=s['initial'][0]//256+s['initial'][1]//256*32;reachable={start};todo=[start]
    while todo:
        i=todo.pop()
        for j in (i-1,i+1,i-32,i+32):
            if 0<=j<1024 and not s['solid'][j] and j not in reachable:reachable.add(j);todo.append(j)
    bad={(r['pose'][0]//256,r['pose'][1]//256) for r in invalid}
    im=Image.new('RGB',(1040,560),'white');d=ImageDraw.Draw(im)
    for panel,agg in enumerate(('mean','worst')):
        ox=panel*520;d.text((ox+8,4),agg+' instruction cycles (no VIC/IRQ)',fill='black')
        for y in range(32):
            for x in range(32):
                rr=cells.get((x,y));v=stats([r['cycles'] for r in rr])[agg] if rr else 0
                fill=(int(255*v/mx),int(230*(1-v/mx)),50) if rr else (35,35,35) if s['solid'][y*32+x] else (110,145,185) if y*32+x not in reachable else (215,215,215)
                box=(ox+x*16,24+y*16,ox+x*16+14,24+y*16+14);d.rectangle(box,fill=fill)
                if (x,y) in bad:d.rectangle(box,outline=(255,0,255),width=2)
                if rr:
                    po=max(rr,key=lambda r:r['cycles'])['pose'];a=po[2]*math.tau/512
                    cx,cy=ox+x*16+7,24+y*16+7;d.line((cx,cy,cx+6*math.sin(a),cy+6*math.cos(a)),fill='black')
        d.text((ox+3,540),'Black=solid grey=unsampled blue=unreachable pink=invalid',fill='black')
    im.save(out/'atlas-host.png')

def run(scene,sampling,out,build):
    out=writable(out);out.mkdir(parents=True,exist_ok=True);data=load(scene);cfg=load(sampling)
    contract,oracle,meta=adapter(data);b=Path(build)
    compiled=load(b/'scene.json');compiled=compiled.get('scene',compiled)
    if compiled!=data['scene']:raise ValueError('BUILD_SCENE_MISMATCH: use --build for the compiled input scene')
    trace=Trace(b,contract['backend'],meta)
    poses=cfg['poses'];rows=[];invalid=[]
    for i,p in enumerate(poses):
        po=p.get('pose') if isinstance(p,dict) else p
        if len(po)==3:po=po+[32,0]
        if not valid_pose(data['scene'],po):invalid.append(dict(index=i,pose=po,reason='collision/height/range'));continue
        r,bmp=trace.view(po);expected=oracle(po)
        assert bmp==expected[0],('BITMAP_MISMATCH',i,po,sum(a!=b for a,b in zip(bmp,expected[0])))
        r.update(index=i,origin=p.get('origin','explicit') if isinstance(p,dict) else 'explicit',oracleDifferentBytes=0)
        rows.append(r)
        if i%25==0:print('pose',i,'of',len(poses),'cycles',r['cycles'],flush=True)
    report=dict(scene=str(Path(scene).resolve()),sceneSHA256=sha(scene),samplingSHA256=sha(sampling),prgSHA256=sha(b/'3Dvibe64.prg'),
                build=str(b),contract=contract,tools=dict(python=sys.version,traceSHA256=sha(__file__.replace('analyze.py','trace.py'))),
                clockDomain='Instruction cycles only: no VIC stalls, IRQ, simulation or presentation. Not FPS.',
                persistentRAM=True,summary=stats([r['cycles'] for r in rows]),invalid=invalid,records=rows,
                attribution=dict(cells='direct executed map reads; frequency, not whole-cell cycle charge',events='direct encountered/processed, stable shared plane-height IDs',shared='exclusive profile arithmetic/sample cycles grouped by shared profile, not additive to exclusiveCycles',limits='Geometry causes hypotheses; no automatic causal credit. Not all reachable continuous poses sampled.'))
    save(out/'poses.json',report)
    keys=sorted(set(k for r in rows for k in r['counters']))
    with (out/'poses.csv').open('w',newline='',encoding='utf-8') as f:
        w=csv.writer(f);w.writerow(['index','xQ8','yQ8','yaw','eye','eyeFraction','cycles',*keys])
        for r in rows:w.writerow([r['index'],*r['pose'],r['cycles'],*[r['counters'].get(k,0) for k in keys]])
    if rows: atlas(data['scene'],rows,out,invalid)
    worst=sorted(rows,key=lambda r:-r['cycles'])[:10]
    (out/'REPORT.md').write_text('# Scene cost atlas\n\n'+report['clockDomain']+'\n\n'+str(report['summary'])+'\n\n'
        +'Persistent RAM; full 7040-byte assembly/model comparison: zero differences for '+str(len(rows))+' poses. Invalid poses: '+str(len(invalid))+'.\n\n'
        +'## Worst observed, not a global guarantee\n\n'
        +'\n'.join(f"- {r['pose']}: {r['cycles']} cycles; {r['counters']}" for r in worst)
        +'\n\n![Host map atlas](atlas-host.png)\n\n'+str(report['attribution'])+'\n',encoding='utf-8')
    print('RESULT',report['summary'],flush=True);return report

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--scene',required=True);p.add_argument('--sampling',required=True);p.add_argument('--out',required=True);p.add_argument('--build',required=True);a=p.parse_args()
    run(a.scene,a.sampling,a.out,a.build)
