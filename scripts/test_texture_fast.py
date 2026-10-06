"""Opt-in Mode 7 fast: assembled arithmetic, sampling, edges and duplication.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. Use the clean-copy release runner.
"""
import json,random,statistics,tempfile
from pathlib import Path
from test_texture_perspective import ROOT,Machine,builder


def carriers(k,rng):
    tested=0
    for d in range(8,160):
        for _ in range(12):
            for ch in range(3):
                step=rng.randrange(-32768,32768);r=rng.randrange(d)
                k.put('ps_step0',step&255,off=ch);k.put('ps_step1',(step>>8)&255,off=ch)
                k.put('ps_rem',r,off=ch)
            k.put('m7_den',d);k.call('bk_setup_carriers')
            for ch in range(3):
                step=k.get('ps_step0',off=ch)+256*k.get('ps_step1',off=ch)
                r=k.get('ps_rem',off=ch);whole,rem=divmod(8*r,d)
                assert k.get('bk_step8lo',off=ch)+256*k.get('bk_step8hi',off=ch)==(8*step+whole)&65535
                assert k.get('bk_rem8',off=ch)==rem
                for e in (0,d-1,rng.randrange(d)):
                    a=rng.randrange(65536);k.put('ps_cur0',a&255,off=ch);k.put('ps_cur1',a>>8,off=ch)
                    k.put('ps_err',e,off=ch);k.cpu.x=ch;k.call('bk_predict')
                    assert k.get('bk_future',2)==(a+8*step+(e+8*r)//d)&65535
                    tested+=1
    return tested


def uv_steps(k):
    # Execute precisely the emitted step setup, stopping before count is set.
    stop=k.lab['bk_setup_steps']+0
    # The end is identified by the actual LDA #8 / STA bk_count sequence.
    addr=k.lab['bk_count'];pattern=[0xa9,8,0x8d,addr&255,addr>>8]
    end=next(p for p in range(stop,stop+100) if k.cpu.memory[p:p+5]==pattern)
    for a in range(256):
        for b in range(256):
            k.put('bk_cur1',a,off=0);k.put('bk_cur1',b,off=1)
            k.put('bk_next',b,off=0);k.put('bk_next',a,off=1)
            k.cpu.pc=stop;k.cpu.x=1;k.cpu.p=0x20
            for _ in range(100):
                if k.cpu.pc==end:break
                k.cpu.step()
            else:raise AssertionError('UV setup did not finish')
            for ch,delta in enumerate((b-a,a-b)):
                q,r=divmod(delta,8)
                assert (k.get('bk_step1',off=ch),k.get('bk_step0',off=ch))==(q&255,r*32),(a,b,ch)
    return 131072


def spans(k,rng):
    samples=0;cycles=[];starts=[]
    for n in range(1,160):
        for _ in range(2):
            a=[rng.randrange(512),rng.randrange(512),rng.randrange(512,32769)]
            b=[rng.randrange(512),rng.randrange(512),rng.randrange(512,32769)]
            k.put('pu_texel',0);k.put('bk_count',0);k.put('bk_ready',0);k.put('m7_den',n)
            k.put('gouraud_scan_end',n);k.put('gouraud_scan_x',0)
            for ch in range(3):
                q,r=divmod(b[ch]-a[ch],n)
                for name,val in [('cur0',a[ch]&255),('cur1',a[ch]>>8),('step0',q&255),('step1',(q>>8)&255),('rem',r),('err',0)]:
                    k.put('ps_'+name,val,off=ch)
            k.call('bk_setup_carriers')
            uv=lambda x:[(128*(a[ch]+(b[ch]-a[ch])*x//n)//(a[2]+(b[2]-a[2])*x//n))&255 for ch in range(2)]
            block_start=None
            for x in range(n+1):
                if k.get('bk_count')==0:
                    block_start=x if n-x>=8 else None
                if block_start is None:expected=uv(x)
                else:
                    lo,hi=uv(block_start),uv(block_start+8)
                    expected=[(lo[ch]+(hi[ch]-lo[ch])*(x-block_start)//8)&255 for ch in range(2)]
                k.cpu.x=53;t=k.call('ps_sample');assert k.cpu.x==53
                assert [k.get('m7_u',off=ch) for ch in range(2)]==expected,(n,x,a,b,expected)
                (starts if block_start==x else cycles).append(t);samples+=1
                if x<n:
                    k.cpu.x=53;k.call('ps_advance');assert k.cpu.x==53
                    for ch in range(3):
                        assert k.get('ps_cur0',off=ch)+256*k.get('ps_cur1',off=ch)==a[ch]+(b[ch]-a[ch])*(x+1)//n
    assert k.get('ps_fault')==0
    return dict(samples=samples,sampleCyclesMean=statistics.mean(cycles),blockSetupCyclesMean=statistics.mean(starts))


def edges(k,rng):
    count=0
    for _ in range(1500):
        d=rng.randrange(1,397);row=rng.randrange(100)
        k.put('tq_dy',d,2);k.put('tq_row',row)
        values=[]
        for ch in range(5):
            a=rng.randrange(1<<24);s=rng.randrange(-50000,50001);r=rng.randrange(d);e=rng.randrange(d)
            values.append((a,s,r,e))
            for label,val in [('cur',a),('step',s&0xffffff)]:
                for byte in range(3):k.put('tq_'+label+str(byte),(val>>(8*byte))&255,off=ch)
            for label,val in [('rem',r),('err',e)]:
                for byte in range(2):k.put('tq_'+label+str(byte),(val>>(8*byte))&255,off=ch)
        k.call('we_prepare_steps')
        for ch,(a,s,r,e) in enumerate(values):
            advances=(row&1) if ch else 0
            for j in range(5):
                v=sum(k.get('tq_cur'+str(b),off=ch)<<(8*b) for b in range(3))
                assert v==(a+s*advances+(e+r*advances)//d)&0xffffff,(ch,j,row)
                k.cpu.x=ch;k.call('we_advance_one');advances+=2 if ch else 1;count+=1
    return count


def duplicate(k,rng):
    pixels=0
    for bank in (0,1):
        k.put('drawbuf',bank)
        name='a' if not bank else 'b';retained=[];dest=[]
        for row in range(100):
            p=k.get('row0lo_'+name,off=row)+256*k.get('row0hi_'+name,off=row)
            p1=k.get('row1lo_'+name,off=row)+256*k.get('row1hi_'+name,off=row)
            for x in range(40):
                if row&1:dest.extend((p+x*8,p1+x*8))
                else:
                    value=rng.randrange(256);k.cpu.memory[p+x*8]=value;k.cpu.memory[p1+x*8]=value
                    retained.append((p+x*8,value))
        before=bytes(k.cpu.memory);k.call('sl_duplicate')
        allowed=set(dest)
        changed=[p for p in range(65536) if before[p]!=k.cpu.memory[p]]
        scratch={k.lab[n] for n in ('sl_gap','sl_bytes','ptr0lo','ptr0hi','row0lo','row0hi','row1lo','row1hi')}
        assert all(p in allowed or p in scratch or 0x100<=p<0x200 for p in changed)
        for row in range(1,100,2):
            p=k.get('row0lo_'+name,off=row-1)+256*k.get('row0hi_'+name,off=row-1)
            q=k.get('row0lo_'+name,off=row)+256*k.get('row0hi_'+name,off=row)
            r=k.get('row1lo_'+name,off=row)+256*k.get('row1hi_'+name,off=row)
            for x in range(40):
                assert k.cpu.memory[p+8*x]==k.cpu.memory[q+8*x]==k.cpu.memory[r+8*x];pixels+=4
        assert all(k.cpu.memory[p]==v for p,v in retained)
    return pixels


def neutral(k):
    tested=0
    k.put('yrow',0);k.put('leftval',0);k.put('rightval',15)
    for a,b in ((15,20),(0,30),(10,22),(23,31),(22,10),(9,9),(10,10),(0,0)):
        k.put('m3_leftq',a);k.put('m3_rightq',b);k.call('m3_prepare_span')
        is_neutral=10<=a<=22 and 10<=b<=22
        assert k.cpu.memory[k.lab['m3_advance_q']]==(0x60 if is_neutral else 0x18)
        for x in range(16):
            q=k.get('m3_qcur')
            assert (10<=q<=22) if is_neutral else q==a+(1 if b>=a else -1)*(abs(b-a)*x//15)
            k.call('m3_advance_q');tested+=1
    return tested


def check(build):
    rng=random.Random(0x1707);k=Machine(Path(build))
    # Packed private state has disjoint consumers at even row indices.
    for side in ('left','right'):
        arrays=[k.lab['ps_'+side+s] for s in ('s_lo','s_hi','v_lo','v_hi','w_lo','w_hi')]+[k.lab['m3_'+side+'q']]
        used=[a+y for a in arrays for y in range(0,100,2)]
        assert len(used)==len(set(used))
    for _ in range(1000):
        a=rng.randrange(65536);d=rng.randrange(1,65536)
        k.put('ps_a',a,2);k.put('ps_den',d,2);k.call('ps_uv_divide')
        assert k.get('ps_num',3)==a*128//d
        assert k.get('ps_remainder',2)==a*128%d
    return dict(carrierPredictions=carriers(k,rng),uvEndpointPairs=uv_steps(k),
                spanSampling=spans(k,rng),edgeAdvances=edges(k,rng),
                duplicatedPixels=duplicate(k,rng),shaderAdvances=neutral(k))


def main():
    result={}
    scene=ROOT/'examples/mode7-perspective-cube.json'
    with tempfile.TemporaryDirectory(prefix='3dvibe64-fast-') as temporary:
        p=Path(temporary)
        for standard in ('pal','ntsc'):
            out=builder.build(p/standard,scene,mode=7,standard=standard,texture_quality='fast')
            result[standard]=dict(sha256=builder.sha(out/'3Dvibe64.prg'),tests=check(out))
        uniform=json.loads(scene.read_text());uniform['textures'][0]['texels']=[3]*256
        uniform['textureQuality']='fast'
        f=p/'uniform.json';f.write_text(json.dumps(uniform))
        out=builder.build(p/'uniform',f,mode=7);k=Machine(out)
        assert json.loads((out/'build.json').read_text())['uniformTexturePigments']==[3]
        k.put('yrow',0);k.put('leftval',0);k.put('rightval',15);k.put('tq_closed',1)
        k.put('m3_leftq',15);k.put('m3_rightq',20)
        for texel in (3,0,3,0):
            k.put('pu_texel',texel);k.put('bk_count',7);k.put('bk_ready',1)
            if not texel:
                for s,v in [('s_lo',0),('s_hi',0),('v_lo',0),('v_hi',0),('w_lo',0),('w_hi',128)]:
                    k.put('ps_left'+s,v);k.put('ps_right'+s,v)
            k.call('ps_prepare_span');assert k.get('bk_count')==k.get('bk_ready')==0
            k.put('m7_u',17);k.put('m7_v',33);before=[k.get('ps_cur0',off=c) for c in range(3)]
            k.cpu.x=53;k.call('ps_sample');assert k.cpu.x==53
            if texel:assert (k.get('m7_u'),k.get('m7_v'))==(17,33)
            k.call('ps_advance')
            if texel:assert before==[k.get('ps_cur0',off=c) for c in range(3)]
        result['uniformTransitions']=4
        bad=json.loads(scene.read_text());bad['textureLighting']='none';bad['textureQuality']='fast'
        f=p/'invalid.json';f.write_text(json.dumps(bad))
        try:builder.build(p/'rejected',f,mode=7)
        except ValueError as e:assert 'TEXTURE_FAST_PROFILE' in str(e)
        else:raise AssertionError('Invalid fast configuration accepted')
        assert not (p/'rejected').exists()
    print(json.dumps(result,indent=2))


if __name__=='__main__':main()
