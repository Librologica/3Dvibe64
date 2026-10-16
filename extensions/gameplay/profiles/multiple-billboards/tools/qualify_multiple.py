"""Native multi-instance composition, exact-order, clipping and animation proof."""
import json
from pathlib import Path
from native_compare import ROOT, paths, run, sha
from verify_ui import check_frame


def captures(build):
    b,prg,l=paths(build);stem=ROOT/'reports/multiple-views/native'
    defaults=[[7,0,-2.5],[-2,3,-2.5]]
    overlap=[[0,0,-2.5],[.75,.25,-2.5]]
    cases=[
        ('front',defaults,[0,0,-16,0,0],0,0),
        ('overlap-front',overlap,[0,0,-16,0,0],0,0),
        ('overlap-back',overlap,[0,0,18,180,0],0,0),
        ('equal-depth',[[0,0,-2.5],[0,0,-2.5]],[0,0,-16,0,0],0,0),
        ('near-four',overlap,[0,0,-4,0,0],0,0),
        ('near-reject',overlap,[0,0,-4+1/256,0,0],0,0),
        ('behind',overlap,[0,0,1,0,0],0,0),
        ('clip-left',overlap,[2,0,-4,0,0],0,0),
        ('clip-right',overlap,[-2,0,-4,0,0],0,0),
        ('clip-top',overlap,[0,-6,-4,0,0],0,0),
        ('clip-bottom',overlap,[0,2,-4,0,0],0,0),
        ('door-closed',overlap,[0,0,18,180,0],0,0),
        ('door-quarter',overlap,[0,0,18,180,0],6.25,0),
        ('pitch-up',defaults,[-12,0,-12,-25,14],6.25,0),
        ('pitch-down',defaults,[-12,0,18,150,-14],6.25,0),
        ('different-frames',overlap,[0,0,-16,0,0],0,1),
    ]
    cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x',
          f'> ${l["advance_sim_tick"]:04x} 60','disable 1','break exec .fps_frame_done','disable 2',
          'break exec .raster_irq','disable 3']
    def put(name,value):cmds.append(f'> ${l[name]:04x} {value&255:02x}')
    def word(name,value):cmds.append(f'> ${l[name]:04x} {value&255:02x} {(value>>8)&255:02x}')
    for tag,positions,camera,lift,cursor in cases:
        for i,pos in enumerate(positions):
            for axis,value in zip('xyz',(pos[0],pos[2],pos[1])):
                q=round(value*256)
                for j in range(3):cmds.append(f'> ${l[f"mb_origin_{axis}{j}"]+i:04x} {(q>>(8*j))&255:02x}')
        word('dr_lift',round(lift*256));put('bc_cursor',cursor);put('sc_cursor',cursor)
        for axis,value in zip('xyz',camera[:3]):
            q=round(value*256)
            for i,suffix in enumerate(('lo','hi','ext')):put('explorer_cam_'+axis+'_'+suffix,q>>(8*i))
        for axis,value in zip(('yaw','pitch'),camera[3:]):
            q=round(value*65536/360)&65535;put('explorer_cam_'+axis,q>>8);put('qc_demo_'+axis+'_lo',q)
        for mask in (0,1,2,3):
            put('mb_enable',mask);put('bb_loaded',255)
            cmds+=['enable 1','ignore 1 2','x','disable 1','enable 2','x','disable 2','bank ram',
                   f'save "{stem}-{tag}-{mask}.ram" 0 $0000 $ffff','bank cpu',
                   f'save "{stem}-{tag}-{mask}.color.ram" 0 $d800 $dbe7']
            if mask==3:
                cmds+=['enable 3','ignore 3 1','x','disable 3',f'screenshot "{stem}-{tag}.png" 2']
    cmds.append('quit');info=run(prg,stem,cmds)
    ui=[]
    for tag,_,_,_,_ in cases:
        for mask in (0,1,2,3):
            p=Path(str(stem)+f'-{tag}-{mask}')
            m=Path(str(p)+'.ram').read_bytes()[2:];color=Path(str(p)+'.color.ram').read_bytes()[2:]
            ui.append(check_frame(m,color,l,tag+f'-{mask}'))
            for name in ('hp_fault','ps_fault','xyq2_faulted'):assert m[l[name]]==0,(tag,name)
    info.update(result='PASS',UI=ui,cases=cases,shaderBytesModified=False,
        captureOverrides='Simulation frozen in monitor only; camera, instance origin data and animation cursors controlled. Delivered PRG unchanged. Timing uses the unmodified automatic program.')
    stem.with_suffix('.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
    return cases,ui


def composition(build,cases):
    _,_,l=paths(build);root=ROOT/'reports/multiple-views'
    frames=json.loads((ROOT/'assets/guard-frames.json').read_text(encoding='utf-8-sig'))['frames']
    results=[]
    def bitmap(m):return m[0x2000:0x2000+8000]+m[0x6000:0x6000+8000]
    def field(m,name,i,size=1):
        return sum(m[l[f'mb_{name}{j}']+i]<<(j*8) for j in range(size))
    def put(m,x,y,value):
        shift=6-2*(x&3)
        for bank in (0x2000,0x6000):
            for scan in (0,1):
                py=8+y*2+scan;a=bank+(py//8)*320+(6+x//4)*8+py%8
                m[a]=(m[a]&~(3<<shift))|((value&3)<<shift)
    for tag,positions,camera,lift,cursor in cases:
        if camera[3:] not in ([0,0],[180,0]):continue
        memories=[(root/f'native-{tag}-{mask}.ram').read_bytes()[2:] for mask in (0,1,2,3)]
        both=memories[3];rects=[];depths=[]
        for i in (0,1):
            rect=[]
            for name in ('left','right','top','bottom'):
                v=field(both,name,i,2);rect.append(v-65536 if v&32768 else v)
            rects.append(rect)
            z=int.from_bytes(bytes([both[l['mb_zlo']+i],both[l['mb_zhi']+i]]),'little',signed=True);depths.append(z)
            expected_depth=round((positions[i][1]-camera[2])*(1 if camera[3]==0 else -1)*256)
            assert z==expected_depth,(tag,'exact Q8 depth',z,expected_depth)
            if z>=4*256:
                # Independent cardinal camera projection: historical Q8 axis
                # projection rounds to nearest integer (checked below).
                cx=(positions[i][0]-camera[0])*(1 if camera[3]==0 else -1)
                cy=positions[i][2]-camera[1];depth=z/256
                expected=[round(48+(cx-3)*41/depth),round(48+(cx+3)*41/depth),round(30-(cy+8)*41/depth),round(30-(cy-8)*41/depth)]
                assert all(abs(a-b)<=1 for a,b in zip(rect,expected)),(tag,'projection',rect,expected)
        expected_order=sorted((0,1),key=lambda i:(depths[i],i),reverse=True)
        if depths[0]!=depths[1]:assert both[l['mb_rank']+expected_order[0]]==1,(tag,'exact depth order')
        else:assert both[l['mb_rank']]==0,(tag,'stable equal-depth tie')
        touched=[0,0];overlap=0;cover=[set(),set()]
        for mask in (1,2,3):
            expected=bytearray(memories[0])
            for i in expected_order:
                if not(mask&(1<<i)) or depths[i]<1024:continue
                left,right,top,bottom=rects[i];w=right-left;h=bottom-top
                assert 0<w<256 and 0<h<256,(tag,'bounded byte DDA',w,h)
                source=frames[field(both,'frame',i)]
                for y in range(max(0,top),min(60,bottom)):
                    for x in range(max(0,left),min(96,right)):
                        v=source[((y-top)*32//h)*16+(x-left)*16//w]
                        if not v:continue
                        if camera[3]==180:
                            # Divider at Y8, rear camera Y18. Half-open pixel
                            # coverage from the independent plane ray equation.
                            gap_y=math_ceil(30-(-10+lift)*41/10)
                            if not(28<=x<69 and y>=gap_y):continue
                        put(expected,x,y,v)
                        if mask==3:cover[i].add((x,y))
            assert bitmap(expected)==bitmap(memories[mask]),(tag,mask,'independent 16000-byte composition oracle')
        touched=[len(c) for c in cover];overlap=len(cover[0]&cover[1])
        results.append(dict(case=tag,depthQ8=depths,rects=rects,drawOrder=expected_order,visibleOpaqueSamples=touched,overlappingOpaqueSamples=overlap,bitmapBytesCompared=48000))
    assert next(r for r in results if r['case']=='overlap-front')['overlappingOpaqueSamples']>0
    assert next(r for r in results if r['case']=='overlap-front')['drawOrder']!=next(r for r in results if r['case']=='overlap-back')['drawOrder']
    assert next(r for r in results if r['case']=='near-reject')['visibleOpaqueSamples'][0]==0
    assert next(r for r in results if r['case']=='behind')['visibleOpaqueSamples']==[0,0]
    (ROOT/'reports/multiple-composition.json').write_text(json.dumps(dict(result='PASS',cases=results),indent=2)+'\n',encoding='utf-8')
    return results


def math_ceil(value):
    import math
    return math.ceil(value)


def animation(build):
    from qualify_door import state_proof
    # Existing entity/door native routines and R restart stay qualified in the
    # new delivered program, in addition to the independent animation fixture.
    door_cases=state_proof(build)
    b,prg,l=paths(build);meta=json.loads((b/'build.json').read_text())
    start,end=max(meta['remainingGaps'],key=lambda p:p[1]-p[0]);assert end-start>=16
    stem=ROOT/'reports/multiple-animation/native'
    cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x','disable 1',f'break exec ${start+12:04x}']
    for n in ('bc_state','bc_previous','bc_cursor','bc_hold','sc_state','sc_previous','sc_cursor','sc_hold'):
        cmds.append(f'> ${l[n]:04x} 00')
    ticks=[0,5,8,10,16,20,40]
    address=l['bb_tick']
    body=[0x20,address&255,address>>8]+[0xea]*9
    cmds.append(f'> ${start:04x} '+' '.join(f'{v:02x}' for v in body))
    for tick in range(41):
        if tick:cmds += [f'r pc=${start:04x}','x']
        if tick in ticks:cmds += ['bank ram',f'save "{stem}-{tick}.ram" 0 $0000 $ffff','bank cpu']
    cmds.append('quit');info=run(prg,stem,cmds);rows=[]
    for tick in ticks:
        m=Path(str(stem)+f'-{tick}.ram').read_bytes()[2:]
        first=m[l['bc_cursor']];second=m[l['sc_cursor']]
        assert first==(tick//8)%4 and second==(tick//5)%4,(tick,first,second)
        rows.append(dict(tick=tick,guardianCursor=first,watcherCursor=second))
    info.update(result='PASS',ticks=rows,fixtureRAM=[start,start+16],programFileUnmodified=True)
    stem.with_suffix('.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
    return rows,door_cases


def checks(build):
    cases,ui=captures(build);pixels=composition(build,cases);ticks,door_cases=animation(build)
    report=dict(result='PASS',PRGSHA256=sha(paths(build)[1]),UI=ui,composition=pixels,independentAnimation=ticks,doorStateAndPassage=door_cases)
    (ROOT/'reports/native-multiple.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    return report
