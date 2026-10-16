"""Independent floor-light reference, native tables and lighting-only image diff."""
import json
import math
from pathlib import Path
from native_compare import ROOT,paths,run,sha
from verify_ui import check_frame


def reference(build):
    b,prg,l=paths(build)
    scene=json.loads((ROOT/'room/scenes/large-room.json').read_text(encoding='utf-8-sig'))
    config=json.loads((ROOT/'assets/light-bake.json').read_text(encoding='utf-8-sig'))
    report=json.loads((ROOT/'reports/static-light.json').read_text(encoding='utf-8-sig'))
    mesh=scene['meshes'][0];records=[];checks=[]
    # Independent fixture for this room: all receivers are the upward floor
    # at Z=-10. Both lamps are inside the outer shell. The only interior
    # blocker is the static Y8 divider, with X[-5,5], Z[-10,8] aperture.
    # This uses floating Euclidean lengths and analytic ray/plane rectangles,
    # not the integer baker's normal, distance or triangle predicate.
    for face in config['receivers']:
        assert face in (8,9,10,11)
        levels=[]
        for corner,index in enumerate(mesh['faces'][face]):
            raw=mesh['vertices'][index];p=(raw[0],raw[2],raw[1]);assert p[2]==-10
            total=config['ambient'];blocked=[]
            for lamp in config['lights']:
                x,y,z=lamp['position'];distance=math.dist(p,lamp['position'])
                hit=False
                oy=p[1];oz=p[2]+config['biasWU']
                if 0<distance<lamp['radiusWU'] and z>p[2] and y!=oy:
                    t=(8-oy)/(y-oy)
                    if 0<t<1:
                        ix=p[0]+t*(x-p[0]);iz=oz+t*(z-oz)
                        hit=(-24<=ix<=24 and -10<=iz<=18 and (abs(ix)>=5 or iz>=8))
                blocked.append(hit)
                if not hit and 0<distance<lamp['radiusWU']:
                    total+=lamp['strength']*max(0,(z-p[2])/distance)*(1-distance/lamp['radiusWU'])
            value=min(32,max(0,math.floor(total+.5)));levels.append(value)
            sample=next(s for s in report['samples'] if s['face']==face and s['corner']==corner)
            assert sample['level']==value,(face,corner,'independent Euclidean light value',sample['level'],value)
            assert [p['blocker'] is not None for p in sample['lights']]==blocked,(face,corner,'independent divider visibility')
            checks.append(dict(face=face,corner=corner,publicPosition=p,level=value,blocked=blocked))
        records.append(dict(face=face,levels=levels))
    assert report['records']==records
    expected=b'LB01'+bytes([len(records)])+bytes(v for r in records for v in [r['face'],*r['levels']])
    assert (ROOT/'reports/static-light.bin').read_bytes()==expected and len(expected)==21
    assert any(any(r['blocked']) for r in checks) and len({r['level'] for r in checks})>=4
    base=json.loads((ROOT/'assets/surfaces.json').read_text(encoding='utf-8-sig'))
    manual=json.loads(json.dumps(base));manual['meshes'][mesh['id']]=manual['meshes'][mesh['id']][:16]
    for r in records:manual['meshes'][mesh['id']][r['face']]['levels']=r['levels']
    (ROOT/'reports/manual-reference-surfaces.json').write_text(json.dumps(manual,indent=2)+'\n',encoding='utf-8')
    result=dict(result='PASS',records=records,analyticSamples=checks,compactBytes=len(expected),
        method='independent floating Lambert/radius model and analytic divider-plane rectangles; fixed floor normal')
    (ROOT/'reports/independent-static-light.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    return result,base


def views(build,expected,base):
    b,prg,l=paths(build);stem=ROOT/'reports/light-views/native'
    scenes=[('front',[0,0,-16,0,0]),('rear',[0,0,18,180,0]),('front-floor',[0,0,0,180,0]),
        ('left',[0,0,-8,90,0]),('right',[0,0,-8,-90,0]),('oblique',[-4,0,-4,45,0])]
    baked={r['face']:r['levels'] for r in expected['records']}
    original={f:base['meshes']['comparison-room'][f]['levels'] for f in baked}
    cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x','bank ram',
        f'save "{stem}-initial.ram" 0 $0000 $ffff','bank cpu',f'> ${l["advance_sim_tick"]:04x} 60',
        'disable 1','break exec .fps_frame_done','disable 2','break exec .raster_irq','disable 3']
    for n in ('ta_cursor','ta_u','ta_v'):cmds.append(f'> ${l[n]:04x} 00 00')
    for n in ('bc_cursor','sc_cursor','bc_state','sc_state'):cmds.append(f'> ${l[n]:04x} 00')
    for tag,camera in scenes:
        for axis,value in zip('xyz',camera[:3]):
            q=round(value*256)
            for i,suffix in enumerate(('lo','hi','ext')):cmds.append(f'> ${l["explorer_cam_"+axis+"_"+suffix]:04x} {(q>>(8*i))&255:02x}')
        for axis,value in zip(('yaw','pitch'),camera[3:]):
            q=round(value*65536/360)&65535
            cmds += [f'> ${l["explorer_cam_"+axis]:04x} {q>>8:02x}',f'> ${l["qc_demo_"+axis+"_lo"]:04x} {q&255:02x}']
        cmds.append(f'> ${l["dr_lift"]:04x} 00 12')
        for variant,values in [('baked',baked),('manual',original)]:
            for face,levels in values.items():
                for corner,value in enumerate(levels):cmds.append(f'> ${l["gouraud_face_shade"+str(corner)]+face:04x} {value:02x}')
            cmds+=['enable 1','ignore 1 2','x','disable 1','enable 2','x','disable 2','bank ram',
                f'save "{stem}-{tag}-{variant}.ram" 0 $0000 $ffff','bank cpu',
                f'save "{stem}-{tag}-{variant}.color.ram" 0 $d800 $dbe7']
            if variant=='baked':cmds+=['enable 3','ignore 3 1','x','disable 3',f'screenshot "{stem}-{tag}.png" 2']
    cmds.append('quit');info=run(prg,stem,cmds);ui=[];changes=[]
    initial=Path(str(stem)+'-initial.ram').read_bytes()[2:]
    for r in expected['records']:
        for corner,value in enumerate(r['levels']):assert initial[l['gouraud_face_shade'+str(corner)]+r['face']]==value,('actual native resident light byte',r['face'],corner)
    def pixel(m,bank,x,y):
        py=8+y*2;a=bank+(py//8)*320+(6+x//4)*8+py%8
        return (m[a]>>(6-2*(x&3)))&3
    def floor_candidate(camera,x,y):
        # One-pixel neighborhood allows existing integer coverage rounding.
        for sx in range(max(0,x-1),min(95,x+1)+1):
            for sy in range(max(31,y-1),min(59,y+1)+1):
                t=(camera[1]+10)*41/(sy-30);dx=(sx-48)/41;a=math.radians(camera[3])
                wx=camera[0]+t*(dx*math.cos(a)-math.sin(a))
                wy=camera[2]+t*(dx*math.sin(a)+math.cos(a))
                if -24.5<=wx<=24.5 and -24.5<=wy<=24.5:return True
        return False
    for tag,camera in scenes:
        memories=[];colors=[]
        for variant in ('baked','manual'):
            p=Path(str(stem)+f'-{tag}-{variant}');m=Path(str(p)+'.ram').read_bytes()[2:];color=Path(str(p)+'.color.ram').read_bytes()[2:]
            ui.append(check_frame(m,color,l,tag+'-'+variant));memories.append(m);colors.append(color)
        assert colors[0]==colors[1]
        for address in (0x400,0x5c00):assert memories[0][address:address+1000]==memories[1][address:address+1000]
        changed=[]
        for y in range(60):
            for x in range(96):
                if any(pixel(memories[0],bank,x,y)!=pixel(memories[1],bank,x,y) for bank in (0x2000,0x6000)):
                    assert floor_candidate(camera,x,y),(tag,'lighting changed a pixel outside floor',x,y)
                    changed.append([x,y])
        assert changed,(tag,'bake not visible')
        changes.append(dict(case=tag,camera=camera,changedLogicalPixels=len(changed),changesConfinedToFloor=True,UIAndPaletteUnchanged=True))
    info.update(result='PASS',UI=ui,visibleLightChanges=changes,nativeResidentValuesMatch=True,shaderBytesModified=False,
        fixture='simulation frozen, camera and existing shade-table data controlled in monitor; packaged PRG unmodified')
    stem.with_suffix('.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
    return ui,changes


def checks(build):
    expected,base=reference(build);ui,changes=views(build,expected,base)
    from qualify_texture_animation import checks as prior
    previous=prior(build)
    result=dict(result='PASS',PRGSHA256=sha(paths(build)[1]),independentLightReference=expected,UI=ui,visibleLightChanges=changes,previousCapabilities=previous)
    (ROOT/'reports/native-static-light.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    return result
