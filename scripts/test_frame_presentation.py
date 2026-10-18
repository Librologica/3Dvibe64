"""Compiled safe presentation on PAL/NTSC, with/without the text split.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. Timing model is not a VIC-II qualification.
"""
import json,shutil,subprocess,tempfile
from pathlib import Path
from test_release_contract import ROOT,build
from test_texture_perspective import Machine

class RasterMemory(list):
    def __init__(self,ram,cpu,lines,linecycles,speed,phase):
        super().__init__(ram);self.cpu=cpu;self.lines=lines
        self.period=linecycles*speed;self.phase=phase
    def raster(self):return (self.phase+self.cpu.processorCycles//self.period)%self.lines
    def __getitem__(self,index):
        if index==0xd012:return self.raster()&255
        return super().__getitem__(index)

def main():
    result=[]
    with tempfile.TemporaryDirectory(prefix='3dvibe64-presentation-') as temporary:
        p=Path(temporary)
        for standard,lines,linecycles in (('pal',312,63),('ntsc',263,65)):
            for viewport in ('normal','small'):
                for overlay in (False,True):
                    args=['-GraphicsMode','4','-VideoStandard',standard,'-CameraMode','fixed',
                          '-CameraViewport',viewport,'-Quality','balanced','-Projection','table',
                          '-MemoryLayout','stable','-FramePresentation','safe']
                    if not overlay:args+=['-NoFpsOverlay']
                    build(ROOT,'examples/basic-solid-reference.json',tuple(args))
                    out=p/f'{standard}-{viewport}-{overlay}';out.mkdir()
                    shutil.copy2(ROOT/'work/3Dvibe64.prg',out/'3Dvibe64.prg')
                    r=subprocess.run([shutil.which('64tass'),'-a','-B','--vice-labels-numeric',
                        '--labels='+str(out/'3Dvibe64.labels'),'-o',str(out/'reassembled.prg'),
                        str(ROOT/'work/3Dvibe64.asm')],capture_output=True,text=True)
                    assert r.returncode==0,r.stdout+r.stderr
                    assert (out/'reassembled.prg').read_bytes()==(out/'3Dvibe64.prg').read_bytes()
                    k=Machine(out)
                    a=k.lab['wait_raster'];ram=k.cpu.memory
                    if overlay:assert ram[a:a+2]==[0xa2,252]
                    else:
                        for n in ('wr1','wr2'):assert ram[k.lab[n]+3:k.lab[n]+5]==[0xc9,252]
                    for speed in (1,64):
                        for phase in (13,239,254):
                            k=Machine(out);k.cpu.memory=RasterMemory(k.cpu.memory,k.cpu,lines,linecycles,speed,phase)
                            k.cpu.pc=a;k.cpu.sp=0xfd;k.cpu.p=0x24
                            k.cpu.memory[0x1fe]=0xff;k.cpu.memory[0x1ff]=0xfd
                            for _ in range(1000000):
                                if k.cpu.pc==0xfe00:break
                                k.cpu.step()
                            else:raise AssertionError('raster wait runaway')
                            assert 253<=k.cpu.memory.raster()<256,(standard,overlay,speed,phase,k.cpu.memory.raster())
                    result.append(dict(standard=standard,viewport=viewport,overlay=overlay,waitRaster=252))
    print('FRAME_PRESENTATION PASS',json.dumps(result),flush=True)

if __name__=='__main__':main()
