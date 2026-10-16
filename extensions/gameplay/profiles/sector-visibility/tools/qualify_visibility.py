"""Native on/off pixel equivalence, compiled PVS data and boundary fallbacks."""
import json
import math
from pathlib import Path
from native_compare import ROOT,paths,run,sha
from verify_ui import check_frame


def cases():
    result=[]
    for side,y,base_yaw in [('front',-18,0),('rear',18,180)]:
        for x in (-18,0,18):
            for delta,pitch in [(0,0),(-50,14),(50,-14),(180,0)]:
                result.append((f'{side}-{x+18}-{delta+50}',[x,0,y,base_yaw+delta,pitch],0,False))
    for lift in (1/256,.25,6.25,12.25,17.75,18):
        for side,y,yaw in [('front',-18,0),('rear',18,180)]:
            result.append((f'{side}-lift-{round(lift*256)}',[0,0,y,yaw,0],lift,False))
    for y in (-1/256,0,8-1/256,8,8+1/256,16,17-1/256,17):
        result.append((f'boundary-{round(y*256)+256}',[0,0,y,180,14],0,False))
    for name,camera in [('left-envelope',[-23,0,-18,45,-14]),('outside-x',[-23-1/256,0,-18,45,-14]),
            ('low-envelope',[0,-9,18,180,0]),('outside-height',[0,-9-1/256,18,180,0]),('high-envelope',[0,18-1/256,18,180,0]),
            ('outside-forward',[0,0,24,180,0])]:result.append((name,camera,0,False))
    result += [('alternate-front',[0,0,-18,0,0],0,True),('alternate-rear',[0,0,18,180,0],0,True)]
    for x in (-23,-11,11,23):
        for h in (-9,7,17):
            for y in (-23,-8,-1/256,17,23):
                for yaw in (0,180):
                    result.append((f'grid-{x+23}-{h+9}-{round(y*256)+5888}-{yaw}',[x,h,y,yaw,0],0,False))
    assert len({r[0] for r in result})==len(result)
    return result


def expected(camera,lift,enabled,alternate):
    x,h,y=[round(v*256)/256 for v in camera[:3]]
    sector=0 if y<0 else 1 if y>=17 else 255
    if not(-23<=x<24 and -9<=h<18 and -23<=y<24):sector=255
    if round(camera[4]*65536/360)&65535 or (round(camera[3]*65536/360)&65535) not in (0,32768):sector=255
    if not enabled or sector==255:return 3,255,255
    row=sector+(2 if round(lift*256)!=0 else 0)
    return 3 if lift or alternate else 1<<sector,sector,row


def views(build):
    b,prg,l=paths(build);stem=ROOT/'reports/visibility-views/native'
    metadata=json.loads((ROOT/'reports/visibility.json').read_text(encoding='utf-8-sig'))
    raw=(ROOT/'reports/visibility.bin').read_bytes()
    expected_faces=[3]*32
    for f in (4,5,8,14,15):expected_faces[f]=1
    for f in (6,7):expected_faces[f]=2
    assert raw==b'PV01\x02\x01\x20'+bytes(expected_faces+[1,2,3,3])
    assert metadata['faceMasks']==expected_faces and metadata['PVS']==[[1,2],[3,3]]
    cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x','bank ram',
        f'save "{stem}-initial.ram" 0 $0000 $ffff','bank cpu',f'> ${l["advance_sim_tick"]:04x} 60',
        'disable 1','break exec .fps_frame_done','disable 2','break exec .raster_irq','disable 3']
    def put(n,v):cmds.append(f'> ${l[n]:04x} {v&255:02x}')
    for n in ('bc_cursor','sc_cursor','bc_state','sc_state'):put(n,0)
    for n in ('ta_cursor','ta_u','ta_v'):cmds.append(f'> ${l[n]:04x} 00 00')
    allcases=cases()
    for tag,camera,lift,alternate in allcases:
        for axis,value in zip('xyz',camera[:3]):
            q=round(value*256)
            for i,suffix in enumerate(('lo','hi','ext')):put('explorer_cam_'+axis+'_'+suffix,q>>(8*i))
        for axis,value in zip(('yaw','pitch'),camera[3:]):
            q=round(value*65536/360)&65535;put('explorer_cam_'+axis,q>>8);put('qc_demo_'+axis+'_lo',q)
        q=round(lift*256);cmds.append(f'> ${l["dr_lift"]:04x} {q&255:02x} {q>>8:02x}')
        cmds.append(f'> ${l["vs_pvs"]:04x} '+('03 03 03 03' if alternate else '01 02 03 03'))
        for enabled in (0,1):
            put('vs_enabled',enabled);put('bb_loaded',255)
            cmds+=['enable 1','ignore 1 2','x','disable 1','enable 2','x','disable 2','bank ram',
                f'save "{stem}-{tag}-{enabled}.ram" 0 $0000 $ffff','bank cpu',f'save "{stem}-{tag}-{enabled}.color.ram" 0 $d800 $dbe7']
            if enabled and tag in ('front-18-50','rear-18-50','rear-lift-1600','boundary-2304'):
                cmds+=['enable 3','ignore 3 1','x','disable 3',f'screenshot "{stem}-{tag}.png" 2']
    cmds.append('quit');info=run(prg,stem,cmds);ui=[];results=[]
    initial=Path(str(stem)+'-initial.ram').read_bytes()[2:]
    assert initial[l['vs_enabled']]==1
    assert initial[l['vs_face_sectors']:l['vs_face_sectors']+32]==bytes(expected_faces)
    assert initial[l['vs_pvs']:l['vs_pvs']+4]==bytes([1,2,3,3])
    bitmap=lambda m:m[0x2000:0x2000+8000]+m[0x6000:0x6000+8000]
    for tag,camera,lift,alternate in allcases:
        memories=[];colors=[];audit=[]
        for enabled in (0,1):
            p=Path(str(stem)+f'-{tag}-{enabled}');m=Path(str(p)+'.ram').read_bytes()[2:];color=Path(str(p)+'.color.ram').read_bytes()[2:]
            for name in ('hp_fault','ps_fault','xyq2_faulted'):assert m[l[name]]==0,(tag,name)
            ui.append(check_frame(m,color,l,tag+f'-{enabled}'))
            mask,sector,row=expected(camera,lift,enabled,alternate)
            for n,v in [('vs_mask',mask),('vs_sector',sector),('vs_row',row),('vs_rejected',sum(not(f&mask) for f in expected_faces))]:
                assert m[l[n]]==v,(tag,enabled,n,m[l[n]],v)
            audit.append(dict(enabled=enabled,mask=mask,sector=sector,row=row,rejectedFaces=m[l['vs_rejected']]))
            memories.append(m);colors.append(color)
        assert bitmap(memories[0])==bitmap(memories[1]),(tag,'complete native bitmap changed',sum(a!=b for a,b in zip(bitmap(memories[0]),bitmap(memories[1]))))
        assert colors[0]==colors[1],(tag,'color RAM changed')
        for address in (0x400,0x5c00):assert memories[0][address:address+1000]==memories[1][address:address+1000],(tag,'screen palette changed')
        results.append(dict(case=tag,camera=camera,liftWU=lift,alternateOpeningFixture=alternate,
            bitmapBytesCompared=16000,pixelsAndPaletteIdentical=True,audit=audit))
    assert any(r['audit'][1]['rejectedFaces']==5 for r in results)
    assert any(r['audit'][1]['rejectedFaces']==2 for r in results)
    assert all(r['audit'][1]['mask']==3 for r in results if r['liftWU'] or r['alternateOpeningFixture'])
    info.update(result='PASS',UI=ui,comparisons=results,PRGInstrumentationAdded=False,
        fixture='simulation frozen; camera, leaf lift, runtime culling flag and alternate-opening PVS data controlled in monitor only; shaders unmodified; FPS uses intact automatic PRG')
    stem.with_suffix('.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
    return results,ui


def checks(build):
    comparisons,ui=views(build)
    from qualify_static_light import checks as prior
    previous=prior(build)
    result=dict(result='PASS',PRGSHA256=sha(paths(build)[1]),visibilityComparisons=comparisons,UI=ui,previousCapabilities=previous)
    (ROOT/'reports/native-sector-visibility.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    return result
