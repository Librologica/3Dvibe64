"""Check actual native bitmap writes, silhouette height and binary transparency."""
import json
from pathlib import Path
from native_compare import ROOT,paths,run,sha


def word(ram,address):
    return int.from_bytes(ram[address:address+2],'little',signed=True)


def main():
    b,prg,l=paths('ui-outline')
    root=ROOT/'reports/outline';root.mkdir(parents=True,exist_ok=True)
    stem=root/'native'
    commands=[f'load_labels "{b/"3Dvibe64.labels"}"',
        'break exec .render_frame_begin','x',f'> ${l["advance_sim_tick"]:04x} 60',
        f'> ${l["bb_frame_ready"]:04x} ea ea ea',f'> ${l["wr_pose"]:04x} 00',
        f'> ${l["wr_dirty"]:04x} 01','disable 1',
        'break exec .bb_draw','disable 2','break exec .ddb_after_draw','disable 3']
    for axis,value in zip('xyz',(0,0,round(-21.5*256))):
        for suffix,v in [('lo',value&255),('hi',value>>8&255),('ext',255 if value<0 else 0)]:
            commands.append(f'> ${l["explorer_cam_"+axis+"_"+suffix]:04x} {v:02x}')
    for axis in ('yaw','pitch'):
        commands += [f'> ${l["explorer_cam_"+axis]:04x} 00',f'> ${l["qc_demo_"+axis+"_lo"]:04x} 00']
    for frame in range(6):
        commands += [f'> ${l["bb_frame"]:04x} {frame:02x}',f'> ${l["bb_loaded"]:04x} ff',
            'enable 1','ignore 1 1','x','disable 1','enable 2','x','disable 2',
            'bank ram',f'save "{root/f"pose{frame}-before.ram"}" 0 $0000 $ffff','bank cpu',
            'enable 3','x','disable 3','bank ram',
            f'save "{root/f"pose{frame}-after.ram"}" 0 $0000 $ffff','bank cpu']
    commands.append('quit')
    info=run(prg,stem,commands)
    art=json.loads((ROOT/'assets/billboard-frames.json').read_text())
    assert art['transparentIndex']==0 and art['opaqueBlackIndex']==4
    results=[]
    for frame,source in enumerate(art['frames']):
        before=(root/f'pose{frame}-before.ram').read_bytes()[2:]
        after=(root/f'pose{frame}-after.ram').read_bytes()[2:]
        assert before[l['bb_frame']]==frame
        assert before[l['bb_pixels']:l['bb_pixels']+512]==bytes(source)
        left,right,top,bottom=[word(before,l['bb_'+n]) for n in ('left','right','top','bottom')]
        width=right-left;height=bottom-top
        expected=bytearray(before);counts=dict(transparent=0,colored=0,black=0,blackReplacedBackground=0)
        suffix='b' if before[l['drawbuf']] else 'a'
        base=0x2000 if suffix=='b' else 0x6000
        for dy in range(height):
            y=top+dy
            if not 0<=y<60:continue
            for dx in range(width):
                x=left+dx
                if not 0<=x<96:continue
                v=source[(dy*32//height)*16+dx*16//width]
                if v==0:
                    counts['transparent']+=1;continue
                counts['black' if v==4 else 'colored']+=1
                shift=2*(3-x%4);mask=3<<shift
                old=None
                for scan in (0,1):
                    # Independent C64 bitmap address using physical origin48,8.
                    py=8+y*2+scan
                    address=base+(py//8)*320+(6+x//4)*8+py%8
                    ptr=before[l[f'row{scan}lo_{suffix}']+y]+256*before[l[f'row{scan}hi_{suffix}']+y]
                    assert address==ptr+(x//4)*8
                    if scan==0:old=(before[address]>>shift)&3
                    expected[address]=(expected[address]&(~mask&255))|((v&3)<<shift)
                if v==4 and old!=0:counts['blackReplacedBackground']+=1
        # Both bitmap banks: verifies transparency and preservation of every
        # pixel outside the opaque silhouette, including adjacent packed bits.
        for bank in (0x2000,0x6000):
            assert after[bank:bank+8000]==expected[bank:bank+8000],('bitmap mismatch',frame,bank)
        assert all(counts[k]>0 for k in counts),counts
        ys=[before[l['wr_ylo']+i]+256*before[l['wr_yhi']+i] for i in range(26)]
        assert max(ys)-min(ys)+1==height==30,(ys,height)
        assert top==min(ys) and bottom-1==max(ys)
        results.append(dict(frame=frame,projectedRect=[left,top,right,bottom],
            skeletonBodyPixelHeight=max(ys)-min(ys)+1,billboardPixelHeight=height,
            exactBitmapBytesChecked=16000,**counts))
    model=json.loads((ROOT/'assets/warrior-model.json').read_text())
    zs=[p[2]*.5-2.5 for p in model['meshes'][0]['vertices']]
    metadata=json.loads((b/'build.json').read_text())['billboard']
    assert min(zs)==metadata['feetWorldZ']==-10
    assert max(zs)==metadata['headWorldZ']==5
    assert max(zs)-min(zs)==metadata['bodyHeight']==15
    assert metadata['worldSize'][1]*30/32==metadata['bodyHeight']
    previous=json.loads((ROOT/'reference/previous-demo-sha256.json').read_text())
    old=ROOT/'reference/checkpoint'
    old_scene=json.loads((old/'large-room.json').read_text())
    new_scene=json.loads((ROOT/'room/scenes/large-room.json').read_text())
    for scene in (old_scene,new_scene):scene['comparison'].pop('billboard')
    assert old_scene==new_scene,'Room or textures changed'
    assert (old/'camera-keyframes.json').read_bytes()==(ROOT/'room/scenes/camera-keyframes.json').read_bytes()
    for name in ('warrior-model.json','warrior-poses.json'):
        assert (old/name).read_bytes()==(ROOT/'assets'/name).read_bytes()
    info.update(result='PASS',finalPRGSHA256=sha(prg),nativeFrames=results,
        bodyWorldHeight=15,feetWorldZ=-10,headWorldZ=5,outlineWorldMarginVertical=.5,
        nativeFrontalHeightBoth=30,transparentExteriorPreserved=True,blackActuallyOpaque=True,
        allOtherBitmapPixelsPreserved=True,roomAndTexturesUnchanged=True,
        cameraUnchanged=True,skeletonAssetsUnchanged=True)
    (ROOT/'reports/outline-qa.json').write_text(json.dumps(info,indent=2))
    print(json.dumps({k:v for k,v in info.items() if k not in ('command','nativeFrames')},indent=2))


if __name__=='__main__':main()
