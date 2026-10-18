"""Independent assembled 6502 camera phase/trig/product checks; never FPS.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import argparse,json,math,random
from pathlib import Path
from test_legacy_stability import Machine

def main():
    p=argparse.ArgumentParser();p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    m=Machine(a.build);rng=random.Random(112103);table=[round(1024*math.sin(i*math.tau/256))for i in range(256)]
    def expected(phase):
        h=(phase>>8)&255;w=(phase&255)>>4
        return (table[h]*16+(table[(h+1)&255]-table[h])*w+8)//16
    error=0
    for phase in range(0,65536,16):
        m.put('lr_phase_lo',phase&255);m.put('lr_phase_hi',phase>>8);m.call('lr_interp')
        value=m.get('p1lo',2,True);assert value==expected(phase),(phase,value,expected(phase))
        error=max(error,abs(value-1024*math.sin(phase*math.tau/65536)))
    assert error<1.1,error
    phase_cases=0
    for yaw,pitch in [(0,0),(65535,65535),(16384,49152),(32768,0)]+[(rng.randrange(65536),rng.randrange(65536))for _ in range(500)]:
        for name,phase in [('yaw',yaw),('pitch',pitch)]:
            m.cpu.y=phase>>8;m.call('legacy_camera_set_'+name+'_phase',phase&255)
            assert m.get('explorer_cam_'+name)==phase>>8 and m.get('explorer_cam_'+name+'_frac')==(phase&240)
        m.call('lr_prepare')
        coefficients=[m.cpu.memory[m.lab['lr_coeff_lo']+i]+256*m.cpu.memory[m.lab['lr_coeff_hi']+i]for i in range(4)]
        coefficients=[v-65536 if v&32768 else v for v in coefficients]
        ey=(-(yaw&65520))&65535;ep=(-(pitch&65520))&65535
        assert coefficients==[expected((ey+16384)&65535),expected(ey),expected((ep+16384)&65535),expected(ep)],(yaw,pitch,coefficients)
        phase_cases+=1
    cases=[(v,c)for v in (-32768,-28000,-1024,-1,0,1,1024,28000,32767)for c in (-1024,-1023,-512,-1,0,1,512,1023,1024)]
    cases +=[(rng.randrange(-32768,32768),rng.randrange(-1024,1025))for _ in range(5000)]
    lut='lr_lookup_product'in m.lab;table_entries=0;last_coefficient=None
    if lut:cases += [(rng.randrange(-32768,32768),coefficient)for coefficient in range(-1024,1025)]
    for value,coefficient in sorted(cases,key=lambda v:v[1]):
        m.put('p1lo',value,2);m.put('lr_coeff_lo',coefficient&255);m.put('lr_coeff_hi',(coefficient>>8)&255)
        if lut and coefficient!=last_coefficient:
            m.call('lr_build_product_lut_index',x=0)
            base=m.lab['LR_PRODUCT_LUT_BASE']
            for index in range(256):
                product=sum(m.cpu.memory[base+index+plane*256]<<(8*plane)for plane in range(3))
                assert product==index*abs(coefficient),(coefficient,index,product)
                table_entries+=1
            last_coefficient=coefficient
        m.call('lr_mul_s16_q10',x=0)
        raw=value*coefficient;result=(abs(raw)+512)//1024
        if raw<0:result=-result
        expected_bits=result&65535
        assert m.get('p1lo',2)==expected_bits,(value,coefficient,m.get('p1lo',2),expected_bits)
    result=dict(passed=True,assembledPRGSHA256=m.hash,interpolatedPhases=4096,maximumTrigCoefficientErrorQ10=error,
                publicPhaseCases=phase_cases,signedProductCases=len(cases),angularStepDegrees=360/4096,
                productLUTActive=lut,productLUTEntriesVerified=table_entries,
                productLUTBase=m.lab.get('LR_PRODUCT_LUT_BASE'),productLUTEnd=m.lab.get('LR_PRODUCT_LUT_END'),FPS=False)
    a.out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))

if __name__=='__main__':main()
