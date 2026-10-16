"""Native mask/nearest-neighbor oracle and end-to-end convex-cell occlusion.

Diagnostic monitor changes freeze camera/animation; measured PRGs stay untouched.
The oracle checks image correctness, never estimates emulated FPS.
"""
import argparse, json
from pathlib import Path
from PIL import Image, ImageChops
from native_billboard import ROOT, paths, run, capture, sha

def freeze(l,camera,pose=0):
    cp=[round(v*256) for v in camera[:3]]+[round(v*65536/360)&65535 for v in camera[3:]]
    cmds=[f'> ${l["advance_sim_tick"]:04x} 60',
          f'> ${l["bb_frame_ready"]:04x} ea ea ea',
          f'> ${l["bb_frame"]:04x} {pose:02x}',f'> ${l["bb_loaded"]:04x} ff']
    for axis,value in zip('xyz',cp[:3]):
        for suffix,v in [('lo',value&255),('hi',value>>8&255),('ext',255 if value<0 else 0)]:
            cmds.append(f'> ${l["explorer_cam_"+axis+"_"+suffix]:04x} {v:02x}')
    for axis,value in zip(('yaw','pitch'),cp[3:]):
        cmds += [f'> ${l["explorer_cam_"+axis]:04x} {value>>8:02x}',f'> ${l["qc_demo_"+axis+"_lo"]:04x} {value&255:02x}']
    return cmds

def save(stem,suffix):
    return ['bank ram',f'save "{stem}.{suffix}.ram" 0 $0000 $ffff','bank cpu']

def oracle(build,tag,camera,pose):
    b,prg,l=paths(build);stem=ROOT/'reports/oracle'/tag
    cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x']
    cmds+=freeze(l,camera,pose)
    cmds+=['ignore 1 2','x','disable 1','break exec .bb_draw','x','disable 2']+save(stem,'before')
    cmds+=['break exec .ddb_after_draw','x','disable 3']+save(stem,'after')+['quit']
    info=run(prg,stem,cmds)
    before=Path(str(stem)+'.before.ram').read_bytes()[2:]
    after=Path(str(stem)+'.after.ram').read_bytes()[2:]
    word=lambda n:int.from_bytes(before[l['bb_'+n]:l['bb_'+n]+2],'little',signed=True)
    left,right,top,bottom=[word(n) for n in ('left','right','top','bottom')]
    w,h=right-left,bottom-top
    assert 0<w<256 and 0<h<256,(tag,left,right,top,bottom)
    expected=bytearray(before)
    pixels=json.loads((ROOT/'assets/billboard-frames.json').read_text())['frames'][pose]
    assert before[l['bb_pixels']:l['bb_pixels']+512]==bytes(pixels)
    bank='b' if before[l['drawbuf']] else 'a'
    opaque=transparent=0;addresses=set();transparent_addresses=set()
    for yy in range(h):
        y=top+yy
        if not 0<=y<100:continue
        sy=yy*32//h
        for xx in range(w):
            x=left+xx
            if not 0<=x<160:continue
            texel=pixels[sy*16+xx*16//w]
            for scan in (0,1):
                row=before[l[f'row{scan}lo_{bank}']+y]+256*before[l[f'row{scan}hi_{bank}']+y]
                address=row+(x//4)*8
                if texel:
                    shift=(3-x%4)*2;mask=3<<shift
                    expected[address]=(expected[address]&~mask)|(texel<<shift)
                    addresses.add(address);opaque+=1
                else:transparent+=1;transparent_addresses.add(address)
    # Compare both complete bitmap buffers, including untouched bytes/pixels.
    bitmap=list(range(0x2000,0x3f40))+list(range(0x6000,0x7f40))
    bad=[i for i in bitmap if expected[i]!=after[i]]
    assert not bad,(tag,len(bad),[hex(i) for i in bad[:10]])
    for start in (0x400,0x5c00,0xd800):assert before[start:start+1000]==after[start:start+1000],(tag,'palette write')
    assert opaque>0 and transparent>0
    info.update(result='PASS',camera=camera,pose=pose,projectedRect=[left,top,right,bottom],
        opaquePhysicalSamples=opaque,transparentPhysicalSamples=transparent,
        all16000BitmapBytesMatchOracle=True,paletteUnchanged=True,alert=before[l['bb_alert']],
        expectedRule='floor(destOffset*sourceSize/projectedSize), index0 skips write, signed viewport clipping')
    stem.with_suffix('.json').write_text(json.dumps(info,indent=2))
    return {k:info[k] for k in ('result','camera','pose','projectedRect','opaquePhysicalSamples','transparentPhysicalSamples')}

def pair(build,tag,camera,pose=0):
    for enabled in (0,1):capture(build,0,pose,enabled,camera,tag+('-on' if enabled else '-off'))
    root=ROOT/'reports/views';stem=root/(build+'-'+tag)
    a=Path(str(stem)+'-off.ram').read_bytes()[2:];b=Path(str(stem)+'-on.ram').read_bytes()[2:]
    changed=[i for start in (0x2000,0x6000) for i in range(start,start+8000) if a[i]!=b[i]]
    for start in (0x400,0x5c00,0xd800):assert a[start:start+1000]==b[start:start+1000]
    on=Image.open(str(stem)+'-on.png').convert('RGB');off=Image.open(str(stem)+'-off.png').convert('RGB')
    box=ImageChops.difference(on,off).getbbox()
    return dict(changedBitmapBytes=len(changed),imageDifferenceBounds=box,camera=camera)

def partial_proof(build):
    camera=[-12,0,35,180,0]
    for opened in (False,True):
        for enabled in (0,1):
            tag='partial'+('-open' if opened else '')+('-on' if enabled else '-off')
            path=ROOT/f'reports/views/{build}-{tag}.ram'
            if not path.exists():capture(build,0,0,enabled,camera,tag,opened)
    l=paths(build)[2]
    read=lambda tag:(ROOT/f'reports/views/{build}-{tag}.ram').read_bytes()[2:]
    closed,off,opened=read('partial-on'),read('partial-off'),read('partial-open-on')
    word=lambda n:int.from_bytes(closed[l['bb_'+n]:l['bb_'+n]+2],'little',signed=True)
    left,right,top,bottom=[word(n) for n in ('left','right','top','bottom')]
    src=json.loads((ROOT/'assets/billboard-frames.json').read_text())['frames'][0]
    visible=hidden=0
    for y in range(max(0,top),min(100,bottom)):
        # Delivered fast reconstruction duplicates the upper even logical row.
        sampled_y=y&~1
        if sampled_y<top:continue
        sy=(sampled_y-top)*32//(bottom-top)
        for x in range(max(0,left),min(160,right)):
            texel=src[sy*16+(x-left)*16//(right-left)]
            if not texel:continue
            row=closed[l['row0lo_a']+y]+256*closed[l['row0hi_a']+y]
            addr=row+(x//4)*8;shift=(3-x%4)*2
            value=lambda ram:(ram[addr]>>shift)&3
            assert value(opened)==texel,('open-wall control does not show whole sprite',x,y)
            if value(closed)!=texel:
                assert value(closed)==value(off),('wall pixel changed',x,y)
                hidden+=1
            elif value(closed)!=value(off):visible+=1
    assert hidden>0 and visible>0,(hidden,visible)
    proof=dict(result='PASS',camera=camera,visibleOpaqueLogicalSamples=visible,
        occludedOpaqueLogicalSamples=hidden,openWallAllOpaqueSamplesMatch=True,
        method='same delivered PRG; diagnostic collapse of room1 back wall only; original PRG and benchmark untouched')
    (ROOT/'reports/partial-occlusion.json').write_text(json.dumps(proof,indent=2))
    return proof

def reactions(build):
    b,prg,l=paths(build);results=[]
    for tag,camera,phase,expected in (
        ('far-walk0',[4,0,-18,0,0],0,0),('far-walk1',[4,0,-18,0,0],8,1),
        ('near-alert0',[4,0,-10,0,0],0,4),('near-alert1',[4,0,-10,0,0],8,5)):
        stem=ROOT/'reports/reaction'/tag
        cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x']
        # Keep the actual runtime frame selector intact for this test.
        cmds+= [c for c in freeze(l,camera) if f'{l["bb_frame_ready"]:04x}' not in c]
        cmds += [f'> ${l["bb_phase"]:04x} {phase:02x}','ignore 1 2','x','disable 1',
                 'break exec .fps_frame_done','x']+save(stem,'result')+['quit']
        info=run(prg,stem,cmds);ram=Path(str(stem)+'.result.ram').read_bytes()[2:]
        frame=ram[l['bb_frame']];assert frame==expected,(tag,frame,expected)
        info.update(result='PASS',selectedFrame=frame,expectedFrame=expected,alert=ram[l['bb_alert']],
                    frameSelectorUnmodified=True,phase=phase,camera=camera)
        stem.with_suffix('.json').write_text(json.dumps(info,indent=2))
        results.append(dict(case=tag,frame=frame,alert=ram[l['bb_alert']]))
    return results

def main(build):
    result={'oracles':{},'occlusion':{}}
    for tag,camera,pose in (
        ('center',[4,0,-18,0,0],0),('walk1',[4,0,-18,0,0],1),
        ('walk2',[4,0,-18,0,0],2),('walk3',[4,0,-18,0,0],3),
        ('alert0',[4,0,-10,0,0],4),('alert1',[4,0,-10,0,0],5),
        ('right-clipped',[-14,0,-18,0,0],0),('left-clipped',[22,0,-18,0,0],0),
        ('top-clipped',[4,-16,-18,0,0],0),('bottom-clipped',[4,10,-18,0,0],0),
        ('near-eight',[4,0,-8,0,0],0),('yaw-pitch',[-8,0,-16,-30,12],2)):
        result['oracles'][tag]=oracle(build,tag,camera,pose)
        print('ORACLE PASS',tag,flush=True)
    for tag,camera in (
        ('wall-hidden',[18,0,35,180,0]),
        ('portal-visible',[0,0,35,180,0]),
        ('portal-partial',[-12,0,35,180,0])):
        result['occlusion'][tag]=pair(build,tag,camera)
        n=result['occlusion'][tag]['changedBitmapBytes']
        assert (n==0) if tag=='wall-hidden' else (n>0),(tag,n)
        print('OCCLUSION PASS',tag,n,flush=True)
    result['partialOcclusion']=partial_proof(build)
    result['automaticReactions']=reactions(build)
    result['prgSHA256']=sha(paths(build)[1]);result['result']='PASS'
    (ROOT/'reports/qualification.json').write_text(json.dumps(result,indent=2))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--build',default='billboard-final');a=p.parse_args();main(a.build)
