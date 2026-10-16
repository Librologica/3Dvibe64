"""Native timing, resident-page integrity and independent pre-baked UV oracle."""
import hashlib
import json
import re
from pathlib import Path
from native_compare import ROOT,paths,run,sha
from verify_ui import check_frame


def timing(build):
    b,prg,l=paths(build);meta=json.loads((b/'build.json').read_text(encoding='utf-8-sig'))
    start,end=max(meta['remainingGaps'],key=lambda p:p[1]-p[0]);assert end-start>=24
    stem=ROOT/'reports/texture-timing/native'
    cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x','disable 1',f'break exec ${start+12:04x}']
    for n in ('cursor','frame_hold','scroll_hold','u','v'):cmds.append(f'> ${l["ta_"+n]:04x} 00 00')
    cmds.append(f'> ${l["ta_running"]:04x} 01')
    a=l['ta_tick'];body=[0x20,a&255,a>>8]+[0xea]*9
    cmds.append(f'> ${start:04x} '+' '.join(f'{v:02x}' for v in body))
    ticks=[0,7,8,15,16,31,32,63,64,127,128]
    for tick in range(129):
        if tick:cmds += [f'r pc=${start:04x}','x']
        if tick in ticks:cmds+=['bank ram',f'save "{stem}-{tick}.ram" 0 $0000 $ffff','bank cpu']
    cmds.append(f'> ${l["ta_running"]:04x} 00')
    for _ in range(24):cmds += [f'r pc=${start:04x}','x']
    cmds+=['bank ram',f'save "{stem}-frozen.ram" 0 $0000 $ffff','bank cpu','quit']
    info=run(prg,stem,cmds);rows=[]
    asset=json.loads((ROOT/'assets/texture-frames.json').read_text(encoding='utf-8-sig'))
    page_addresses=[l['m7_texture_0']]+[l['ta_frame_page'+str(i)] for i in range(1,4)]
    for tick in ticks:
        m=Path(str(stem)+f'-{tick}.ram').read_bytes()[2:]
        for i in (0,1):
            assert m[l['ta_cursor']+i]==((tick//16)%4 if i==0 else 0),(tick,i,'cursor')
            assert m[l['ta_frame_hold']+i]==tick%16,(tick,i,'frame hold')
            assert m[l['ta_scroll_hold']+i]==tick%8,(tick,i,'scroll hold')
            assert m[l['ta_u']+i]==(0 if i==0 else tick//8%16),(tick,i,'U')
            assert m[l['ta_v']+i]==(0 if i==0 else (-(tick//8))%16),(tick,i,'V')
        for address,frame in zip(page_addresses,asset['frames']):
            assert address%256==0 and m[address:address+256]==bytes(frame),(tick,'resident source page changed',hex(address))
        rows.append(dict(tick=tick,cursors=list(m[l['ta_cursor']:l['ta_cursor']+2]),U=list(m[l['ta_u']:l['ta_u']+2]),V=list(m[l['ta_v']:l['ta_v']+2])))
    last=Path(str(stem)+'-128.ram').read_bytes()[2:];frozen=Path(str(stem)+'-frozen.ram').read_bytes()[2:]
    for n in ('cursor','frame_hold','scroll_hold','u','v'):assert last[l['ta_'+n]:l['ta_'+n]+2]==frozen[l['ta_'+n]:l['ta_'+n]+2],('frozen animation changed',n)
    info.update(result='PASS',ticks=rows,frozenTicks=24,residentSourcePagesUnchanged=True,pageAddresses=page_addresses,fixtureRAM=[start,start+24],PRGFileUnmodified=True)
    stem.with_suffix('.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
    return rows,page_addresses


def pictures(build):
    b,prg,l=paths(build);stem=ROOT/'reports/texture-views/native'
    frames=json.loads((ROOT/'assets/texture-frames.json').read_text(encoding='utf-8-sig'))['frames']
    # The reference source is independently pre-baked on the host. Renderer,
    # projection and shader bytes are unchanged; only resident source texels,
    # sequence data and UV state are controlled for this correctness fixture.
    cases=[
        ('back-frame0',[0,0,18,0,0],[0,0],[(0,0),(0,0)]),
        ('back-frame1',[0,0,18,0,0],[1,0],[(0,0),(0,0)]),
        ('back-frame2',[0,0,18,0,0],[2,0],[(0,0),(0,0)]),
        ('back-frame3',[0,0,18,0,0],[3,0],[(0,0),(0,0)]),
        ('left-zero',[-18,0,-6,90,0],[0,0],[(0,0),(0,0)]),
        ('left-scroll',[-18,0,-6,90,0],[0,0],[(0,0),(3,13)]),
        ('combined',[-18,0,4,60,14],[2,3],[(7,15),(15,1)]),
        ('clipped-near',[0,0,22.5,0,-14],[3,0],[(15,15),(1,15)]),
        ('LOD-near',[0,0,10,0,0],[1,0],[(5,11),(1,15)]),
        ('LOD-blend',[0,0,6,0,0],[2,0],[(11,3),(2,14)]),
        ('LOD-far',[0,0,2,0,0],[3,0],[(9,1),(3,13)]),
        ('LOD-far-zero',[0,0,2,0,0],[0,0],[(0,0),(0,0)]),
    ]
    cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x',f'> ${l["advance_sim_tick"]:04x} 60',
        'disable 1','break exec .fps_frame_done','disable 2','break exec .raster_irq','disable 3']
    def put(name,value):cmds.append(f'> ${l[name]:04x} {value&255:02x}')
    def pixels(address,values):
        for i in range(0,len(values),32):cmds.append(f'> ${address+i:04x} '+' '.join(f'{v:02x}' for v in values[i:i+32]))
    for tag,camera,selected,offsets in cases:
        for axis,value in zip('xyz',camera[:3]):
            q=round(value*256)
            for i,suffix in enumerate(('lo','hi','ext')):put('explorer_cam_'+axis+'_'+suffix,q>>(8*i))
        for axis,value in zip(('yaw','pitch'),camera[3:]):
            q=round(value*65536/360)&65535;put('explorer_cam_'+axis,q>>8);put('qc_demo_'+axis+'_lo',q)
        cmds.append(f'> ${l["dr_lift"]:04x} 00 12')
        for variant in ('animated','baked'):
            put('ta_cursor',0);cmds.append(f'> ${l["ta_cursor"]+1:04x} 00')
            if variant=='animated':
                for i,frame in enumerate(frames):pixels(l['m7_texture_0'] if i==0 else l['ta_frame_page'+str(i)],frame)
                cmds += [f'> ${l["ta_sequences"]:04x} {selected[0]:02x}',f'> ${l["ta_sequences"]+4:04x} {selected[1]:02x}']
                for i,(u,v) in enumerate(offsets):cmds += [f'> ${l["ta_u"]+i:04x} {u:02x}',f'> ${l["ta_v"]+i:04x} {v:02x}']
            else:
                for i,(frame,(u,v)) in enumerate(zip(selected,offsets)):
                    baked=[frames[frame][((y+v)%16)*16+(x+u)%16] for y in range(16) for x in range(16)]
                    pixels(l['ta_frame_page'+str(i+1)],baked)
                cmds += [f'> ${l["ta_sequences"]:04x} 01',f'> ${l["ta_sequences"]+4:04x} 02']
                for n in ('ta_u','ta_v'):cmds.append(f'> ${l[n]:04x} 00 00')
            cmds+=['enable 1','ignore 1 2','x','disable 1','enable 2','x','disable 2','bank ram',
                f'save "{stem}-{tag}-{variant}.ram" 0 $0000 $ffff','bank cpu',
                f'save "{stem}-{tag}-{variant}.color.ram" 0 $d800 $dbe7']
            if variant=='animated':cmds+=['enable 3','ignore 3 1','x','disable 3',f'screenshot "{stem}-{tag}.png" 2']
    cmds.append('quit');info=run(prg,stem,cmds);ui=[];oracles=[]
    hashes={}
    for tag,camera,selected,offsets in cases:
        pair=[]
        for variant in ('animated','baked'):
            p=Path(str(stem)+f'-{tag}-{variant}');m=Path(str(p)+'.ram').read_bytes()[2:]
            color=Path(str(p)+'.color.ram').read_bytes()[2:];ui.append(check_frame(m,color,l,tag+'-'+variant));pair.append(m)
        for bank in (0x2000,0x6000):assert pair[0][bank:bank+8000]==pair[1][bank:bank+8000],(tag,'independent prebaked frame/UV oracle',hex(bank))
        hashes[tag]=hashlib.sha256(pair[0][0x2000:0x2000+8000]+pair[0][0x6000:0x6000+8000]).hexdigest().upper()
        oracles.append(dict(case=tag,camera=camera,frames=selected,offsets=offsets,bitmapBytesCompared=16000,result='PASS',bitmapSHA256=hashes[tag]))
    assert len({hashes['back-frame'+str(i)] for i in range(4)})==4,'Frame changes not visible in the native bitmap'
    assert hashes['left-zero']!=hashes['left-scroll'],'UV scrolling not visible in the native bitmap'
    assert hashes['LOD-far']==hashes['LOD-far-zero'],'Far LOD fallback must remain invariant under frame/UV changes'
    info.update(result='PASS',UI=ui,independentPrebakedOracles=oracles,shaderBytesModified=False,PRGFileUnmodified=True)
    stem.with_suffix('.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
    return ui,oracles


def lod(build):
    b,prg,l=paths(build);rows=[]
    for camera_y,weight in [(10,16),(6,8),(2,0)]:
        stem=ROOT/f'reports/texture-lod/depth{24-camera_y}'
        cmds=[f'logname "{stem}.monitor.log"','log on',f'load_labels "{b/"3Dvibe64.labels"}"',
            'break exec .render_frame_begin','x',f'> ${l["advance_sim_tick"]:04x} 60']
        for axis,value in zip('xyz',(0,0,camera_y*256)):
            for i,suffix in enumerate(('lo','hi','ext')):cmds.append(f'> ${l["explorer_cam_"+axis+"_"+suffix]:04x} {(value>>(8*i))&255:02x}')
        for axis in ('yaw','pitch'):cmds += [f'> ${l["explorer_cam_"+axis]:04x} 00',f'> ${l["qc_demo_"+axis+"_lo"]:04x} 00']
        cmds += [f'> ${l["dr_lift"]:04x} 00 12','ignore 1 2','x','disable 1','trace exec .lg_set_weight','break exec .fps_frame_done','x','quit']
        info=run(prg,stem,cmds);text=Path(str(stem)+'.monitor.log').read_text(encoding='utf-8',errors='replace')
        samples=re.findall(r'\.C:'+f'{l["lg_set_weight"]:04x}'+r'[^\n]*A:([0-9a-f]{2})[^\n]*Y:([0-9a-f]{2})',text,re.I)
        final={}
        for a,y in samples:
            if int(y,16) in (6,7):final[int(y,16)]=int(a,16)
        assert final=={6:weight,7:weight},('animated wall LOD',camera_y,final,weight)
        info.update(result='PASS',camera=[0,0,camera_y,0,0],animatedFaces=final,depthWU=24-camera_y)
        stem.with_suffix('.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8');rows.append(info)
    return rows


def checks(build):
    ticks,pages=timing(build);ui,oracles=pictures(build)
    from qualify_multiple import checks as prior
    previous=prior(build)
    weights=lod(build)
    report=dict(result='PASS',PRGSHA256=sha(paths(build)[1]),timing=ticks,sourcePages=pages,UI=ui,pixelOracles=oracles,LOD=weights,previousCapabilities=previous)
    (ROOT/'reports/native-texture-animation.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    return report
