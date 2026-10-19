"""Native mixed-material cell writes against the unoptimized kernel.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0. No FPS measured.
"""
import argparse,json,random
from pathlib import Path
from test_legacy_plus_exact import Machine

def main():
 p=argparse.ArgumentParser();p.add_argument('--control',type=Path);p.add_argument('--exact',type=Path);p.add_argument('--out',type=Path);a=p.parse_args()
 if not a.control and not a.exact:
  print('MATERIAL_CACHE contract: actual callback checks require external mixed-material control/exact builds');return
 assert a.control and a.exact and __debug__
 ref,opt=Machine(a.control),Machine(a.exact);rng=random.Random(0x6510);checks=0
 sequences=[[(0,0),(10,10),(5,5),(2,3)],[(30,33),(0,1),(35,39),(15,20)],[(5,15),(0,4),(16,20),(6,7)]]
 sequences +=[[(lambda left:(left,min(39,left+rng.randrange(1,12))))(rng.randrange(40)) for _ in range(4)] for _ in range(500)]
 for buf in 'ab':
  for seq in sequences:
   row=rng.randrange(25)*4;screen=[]
   for m in (ref,opt):
    base=m.mem[m.lab['screenrowlo_'+buf]]+256*m.mem[m.lab['screenrowhi_'+buf]];screen.append(base)
    m.mem[base:base+1000]=[0x3c]*1000;m.mem[0xd800:0xd800+1000]=[8]*1000
    if 'material_last_cellrow' in m.lab:m.put('material_last_cellrow',255)
   for i,(left,right) in enumerate(seq):
    for m in (ref,opt):
     m.put('yrow',row+i);m.put('startbyte',left);m.put('endbyte',right);m.put('material_screen_cur',0x6f);m.put('material_color_cur',7)
     m.call(('apply_material_span_' if m is ref else 'maybe_apply_material_span_')+buf)
    assert ref.mem[screen[0]:screen[0]+1000]==opt.mem[screen[1]:screen[1]+1000],(buf,row,seq,i,'screen palette')
    assert ref.mem[0xd800:0xd800+1000]==opt.mem[0xd800:0xd800+1000],(buf,row,seq,i,'color RAM')
    checks+=1
 report=dict(passed=True,perRowComparisons=checks,sequenceCount=len(sequences)*2,checks='Both buffers, sparse/disconnected/adjacent/overlapping span unions; screen palette and color RAM compared after every row',nativeFPSMeasured=False)
 if a.out:a.out.write_text(json.dumps(report,indent=2)+'\n')
 print(json.dumps(report,indent=2))

if __name__=='__main__':main()
