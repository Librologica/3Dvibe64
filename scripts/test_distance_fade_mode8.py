"""Compiled Mode8 fade thresholds, fractional camera distance and band merging.
Temporary kernel artifacts only; no demo scenes; CPU execution is not FPS.
"""
import sys,re,shutil,tempfile,subprocess,math,random,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'work'))
from distance_fade import config,BAYER
from distance_fade_mode8 import apply
from py65.devices.mpu6502 import MPU

def main():
    planes=bands=cache_reads=cache_resets=scalar_rows=0
    for family in ['perimeter','two-levels']:
        s=(ROOT/f'work/mode8/asm/{family}-auto.asm').read_text(encoding='utf-8');s=apply(s,config({},'dither',2,8),family=='two-levels')
        with tempfile.TemporaryDirectory(prefix='3dvibe64-mode8-fade-') as tmp:
            p=Path(tmp);(p/'map.bin').write_bytes(bytes(1024));shutil.copy2(ROOT/'work/mode8/font.bin',p/'font.bin');(p/'kernel.asm').write_text(s,encoding='utf-8')
            cmd=[shutil.which('64tass'),'-a','-B','--vice-labels-numeric','--labels='+str(p/'labels'),'-o',str(p/'kernel.prg'),str(p/'kernel.asm')]
            r=subprocess.run(cmd,cwd=p,capture_output=True,text=True);assert r.returncode==0,r.stdout+r.stderr
            l={m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',(p/'labels').read_text(),re.M)}
            assert l['df8_payload_end']-l['df8_payload_begin']<=2449
            raw=(p/'kernel.prg').read_bytes();o=int.from_bytes(raw[:2],'little');c=MPU();c.memory[o:o+len(raw)-2]=raw[2:]
            def put(n,v,k=1,off=0):
                for j in range(k):c.memory[l[n]+off+j]=v>>(8*j)&255
            def get(n,k=1,off=0):return sum(c.memory[l[n]+off+j]<<(8*j) for j in range(k))
            def call(n):
                c.pc=l[n];c.sp=0xfd;c.p=0x20;c.memory[0x1fe]=255;c.memory[0x1ff]=1
                for _ in range(100000):
                    if c.pc==512:return
                    c.step()
                raise AssertionError(('No return',n,hex(c.pc)))
            thresholds=[math.ceil((8-6*k/16)*256) for k in range(17)]
            for axis in [0,64]:
                for plane in [1,8,16,30]:
                    for camera in [0,1,255,256,300,1023,2048,4095,7000,8000]:
                        put('pose_x',camera,2);put('pose_y',camera,2);c.a=axis|plane;call('df8_plane');d=abs(plane*256-camera);assert get('df8_distance',2)==d
                        call('df8_classify');expected=next((k for k,t in enumerate(thresholds) if d>=t),16);assert get('df8_level')==expected
                        planes+=1
            if family=='two-levels':
                # Unit-only stand-ins isolate the private cache, not native FPS.
                c.memory[l['get_profile']]=0x60
                c.memory[l['gr17_clear_units']]=0x60
                for camera in [0,1,255,256,1023,2048,4095,7000,8000]:
                    put('pose_x',camera,2);put('pose_y',8000-camera,2)
                    call('df8_clear_units');cache_resets+=1
                    assert all(c.memory[l['df8_plane_levels']+i]==255 for i in range(128))
                    for encoded in range(128):
                        put('key_plane',encoded,off=encoded)
                        distance=abs((encoded&63)*256-(8000-camera if encoded&64 else camera))
                        expected=next((k for k,t in enumerate(thresholds) if distance>=t),16)
                        for repeat in range(2):
                            c.a=encoded;c.x=117;c.y=43;call('df8_get_profile');cache_reads+=1
                            assert get('df8_level')==expected and c.x==117 and c.y==43
                            assert get('df8_plane_levels',off=encoded)==expected
                # Check the strided four-phase fill against the independent pixel oracle.
                for lane in range(4):
                    put('fine_lane',lane);call('init_fine_column')
                    for level in range(17):
                        for first,last in [(0,0),(0,1),(1,3),(0,144),(17,120),(143,144),(250,255),(254,255),(255,255),(120,17)]+[(i*11%256,(i*37+51)%256) for i in range(12)]:
                            put('df8_level',level);put('fill_start',first);put('fill_end',last)
                            c.memory[0x5400:0x5500]=[0x69]*256
                            color=0xaa & (3<<(6-2*lane));c.a=color;call('df8_scalar')
                            for row in range(256):
                                mask=(3<<(6-2*lane)) if first<=row<last and BAYER[row&3][lane]<level else 0
                                expected=0x69^((0x69^color)&mask)
                                scalar_rows+=1
                                assert c.memory[0x5400+row]==expected,('scalar',lane,level,first,last,row)
            # Original bitmap values outside the masked polygon must survive.
            rng=random.Random(650235)
            configurations=[([10,54,72,100],[90,55,120,144]),([144]*4,[255]*4),([0]*4,[0]*4),([255]*4,[0]*4),([0,143,72,255],[144,144,73,255])]
            configurations += [([rng.randrange(256) for _ in range(4)],[rng.randrange(256) for _ in range(4)]) for _ in range(24)]
            for tops,bottoms in configurations:
                for lane in range(4):put('top_samples',tops[lane],off=lane);put('bottom_samples',bottoms[lane],off=lane)
                for bank in [0,1]:
                    for level in range(16):
                        put('col',9);put('drawbuf',bank);put('df8_level',level);put('band_shade',0xaa)
                        addresses=[]
                        for y in range(144):
                            row=y//8;addr=get('bitmap_row_lo',off=row)+256*get('bitmap_row_hi',off=row)+9*8+bank*0x8000+(y&7);addresses.append(addr);c.memory[addr]=0x69
                        call('df8_samples')
                        for y,addr in enumerate(addresses):
                            mask=sum(3<<(6-2*x) for x in range(4) if tops[x]<=y<bottoms[x] and BAYER[y&3][x]<level)
                            expected=0x69^((0x69^0xaa)&mask);assert c.memory[addr]==expected,(family,bank,level,y,expected,c.memory[addr]);bands+=1
            if family=='perimeter':
                c.memory[l['compose_screen']]=0x60
                for bank in [0,1]:
                    put('drawbuf',bank)
                    base=get('bitmap_row_lo')+256*get('bitmap_row_hi')-0x660+bank*0x8000
                    initial=bytes((i*37+19)&255 for i in range(8192));c.memory[base:base+8192]=initial;expected=bytearray(initial)
                    for row in range(144):
                        offset=get('bitmap_row_lo',off=row//8)+256*get('bitmap_row_hi',off=row//8)+bank*0x8000+(row&7)-base
                        for col in range(32):expected[offset+col*8]=0 if row<72 else 0x55
                    call('df8_compose')
                    assert bytes(c.memory[base:base+8192])==expected,('viewport clear/border',bank)
    print('DISTANCE_FADE_MODE8 PASS',json.dumps(dict(planeCases=planes,bandRows=bands,cacheReads=cache_reads,cacheResets=cache_resets,scalarRows=scalar_rows,errors=0,CPUCorrectnessOnly=True)))
if __name__=='__main__':main()
