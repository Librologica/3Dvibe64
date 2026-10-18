"""Arithmetic regression checks on caller-supplied legacy builds. Never FPS.

The SDK contains no qualification scene or compiled PRG. Supply external
before/after directories containing 3Dvibe64.prg and numeric VICE labels.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import argparse
import hashlib
import json
import random
import re
from pathlib import Path

from py65.devices.mpu6502 import MPU


class Machine:
    def __init__(self, folder):
        self.lab={m[2]:int(m[1],16)for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',
                  (folder/'3Dvibe64.labels').read_text(),re.M)}
        data=(folder/'3Dvibe64.prg').read_bytes();self.hash=hashlib.sha256(data).hexdigest()
        self.cpu=MPU(memory=[0]*65536);base=int.from_bytes(data[:2],'little')
        self.cpu.memory[base:base+len(data)-2]=data[2:]

    def put(self,key,value,size=1):
        for i in range(size):self.cpu.memory[self.lab[key]+i]=(value>>(8*i))&255

    def get(self,key,size=1,signed=False):
        a=self.lab[key]
        return int.from_bytes(bytes(self.cpu.memory[a:a+size]),'little',signed=signed)

    def call(self,name,a=None,x=None):
        self.cpu.sp=255;self.cpu.stPushWord(0x01ff);self.cpu.pc=self.lab[name];self.cpu.p=0x24
        if a is not None:self.cpu.a=a&255
        if x is not None:self.cpu.x=x&255
        for _ in range(200000):
            if self.cpu.pc==0x0200:return
            self.cpu.step()
        raise AssertionError('Routine did not return: '+name)

    def winding(self,pts):
        if 'clip_poly_active'in self.lab:self.put('clip_poly_active',0)
        self.put('loaded_face_vertex_count',len(pts))
        for i,(x,y)in enumerate(pts):self.put('vx'+str(i),x);self.put('vy'+str(i),y)
        self.call('mode2_screen_winding_visible')
        return bool(self.cpu.p&1)


def area(pts):
    return sum(x*pts[(i+1)%len(pts)][1]-y*pts[(i+1)%len(pts)][0]for i,(x,y)in enumerate(pts))


def main():
    p=argparse.ArgumentParser();p.add_argument('--before',type=Path,required=True)
    p.add_argument('--after',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    args=p.parse_args();before=Machine(args.before);after=Machine(args.after);rng=random.Random(112101)
    assert after.lab['EXPLORER_MATRIX_FOLD']==0
    # The face-bucket Mode 2 path already omits the old preliminary X/Y
    # prefilter. Check assembled paths rather than assuming every ASM branch
    # present in the generator is active in this target.
    assert before.lab['MODE2_FACE_BUCKET_PIPELINE']==after.lab['MODE2_FACE_BUCKET_PIPELINE']==1
    assert 'lfv_cull'not in before.lab and 'lfv_cull'not in after.lab
    diagnostic=[]
    for shift in range(8):
        pts=[(20+shift,9),(69+shift,53),(120+shift,99)]
        diagnostic.append(dict(shift=shift,exactVisible=area(pts)>0,before=before.winding(pts),after=after.winding(pts)))
    assert [v['before']for v in diagnostic]==[False,True]*4
    assert all(v['after']==v['exactVisible']for v in diagnostic)
    winding=0;old_disagreements=0
    for n in (3,4):
        for _ in range(2500):
            pts=[(rng.randrange(160),rng.randrange(100))for _ in range(n)]
            expected=area(pts)>0
            assert after.winding(pts)==expected,pts
            old_disagreements+=before.winding(pts)!=expected;winding+=1
    products=0;old_sqerr=new_sqerr=0
    for value in range(-128,128):
        for coefficient in range(-80,81):
            raw=value*coefficient
            rounded=(abs(raw)+32)//64
            expected=max(-128,min(127,-rounded if raw<0 else rounded))
            after.call('mul_s6',value,coefficient)
            got=after.cpu.a-256 if after.cpu.a>=128 else after.cpu.a
            assert got==expected,(value,coefficient,got,expected)
            # Compare geometric-domain rounding to an independent real product.
            if abs(value)<=63:
                before.call('mul_s6',value,coefficient)
                old=before.cpu.a-256 if before.cpu.a>=128 else before.cpu.a
                old_sqerr+=(old-raw/64)**2;new_sqerr+=(got-raw/64)**2
            products+=1
    matrix_cases=0;max_coefficient=0
    # A rounded rotation matrix may reach magnitude65. Keep this real emitted
    # domain covered rather than testing only sine-table magnitudes<=64.
    for angles in [(69,105,5)]+[tuple(rng.randrange(256)for _ in range(3))for _ in range(1000)]:
        for axis,angle in zip('xyz',angles):
            after.put('sin'+axis+'v',after.cpu.memory[after.lab['sintab']+angle])
            after.put('cos'+axis+'v',after.cpu.memory[after.lab['sintab']+(angle+64)%256])
        after.call('prepare_matrix')
        coefficients=[after.get('m'+str(r)+str(c),signed=True)for r in range(3)for c in range(3)]
        max_coefficient=max(max_coefficient,max(map(abs,coefficients)));matrix_cases+=1
    assert 65<=max_coefficient<=80,max_coefficient
    wide=0
    for _ in range(2500):
        value=rng.randrange(-8191,8192);coefficient=rng.randrange(-80,81);raw=value*coefficient
        expected=(abs(raw)+32)//64
        if raw<0:expected=-expected
        after.put('p1lo',value,2);after.call('mul_s16_s6',coefficient)
        assert after.get('p1lo',2,True)==expected,(value,coefficient)
        wide+=1
    translations=0
    for axis,reg in [('x','rx0'),('y','ry1')]:
        for _ in range(4000):
            local=rng.randrange(-127,128);origin=rng.randrange(-127,128);camera=rng.randrange(-8191*256,8191*256)
            after.put(reg,local);after.put('obj_pos_'+axis+'_cur',origin)
            for suffix,shift in [('lo',0),('hi',8),('ext',16)]:after.put('explorer_cam_'+axis+'_'+suffix,camera>>shift)
            after.call('legacy_world_sub_camera_'+axis)
            expected=((local+origin)*256-camera+128)//256
            assert after.get('explorer_rel_'+axis+'_lo',2,True)==expected,(axis,local,origin,camera)
            translations+=1
    report=dict(kind='6502 correctness, not native FPS',beforePRGSHA256=before.hash,afterPRGSHA256=after.hash,
                windingCases=winding,windingBeforeDisagreements=old_disagreements,windingAfterDisagreements=0,
                translationCases=translations,q6Products=products,wideProducts=wide,
                rotationMatrices=matrix_cases,maxObservedCoefficient=max_coefficient,diagnostic=diagnostic,
                geometricProductSquaredErrorBefore=old_sqerr,geometricProductSquaredErrorAfter=new_sqerr)
    args.out.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))


if __name__=='__main__':main()
