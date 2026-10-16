"""Native door states, bidirectional passage and independent occlusion oracle."""
import json,math
from fractions import Fraction
from pathlib import Path
from native_compare import ROOT,paths,run,sha
from verify_ui import check_frame


def state_proof(build):
    b,prg,l=paths(build);meta=json.loads((b/'build.json').read_text(encoding='utf-8-sig'))
    start,end=max(meta['remainingGaps'],key=lambda p:p[1]-p[0]);assert end-start>=32
    stem=ROOT/'reports/door-states/native'
    cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x','disable 1',f'break exec ${start+24:04x}']
    def put(n,v):cmds.append(f'> ${l[n]:04x} {v&255:02x}')
    def word(n,v):cmds.append(f'> ${l[n]:04x} {v&255:02x} {(v>>8)&255:02x}')
    def camera(x,z):
        for axis,value in [('x',x),('z',z)]:
            q=round(value*256)
            for i,suffix in enumerate(('lo','hi','ext')):put('explorer_cam_'+axis+'_'+suffix,q>>(i*8))
    def call(target='dr_tick',tag=None):
        data=[]
        for name in target.split('+'):
            a=l[name];data += [0x20,a&255,a>>8]
        data += [0xa9,0,0x69,0,0x8d,(start+31)&255,(start+31)>>8]
        data += [0xea]*(24-len(data))
        cmds.extend([f'> ${start:04x} '+' '.join(f'{v:02x}' for v in data),f'r pc=${start:04x}','x'])
        if tag:cmds.extend(['bank ram',f'save "{stem}-{tag}.ram" 0 $0000 $ffff','bank cpu'])
    for n,v in [('en_enabled',1),('en_key_override',1),('en_manual',1),('en_state',0),('bc_state',0),('en_event_count',0),('en_rejected',0),('en_use_latch',0),('en_space_override',1),('explorer_key_col1',255),('explorer_key_col2',255),('explorer_key_col7',255),('dr_state',0),('dr_seen_states',0),('dr_motion',1),('dr_safety_events',0)]:put(n,v)
    word('dr_lift',0);camera(7,-14)
    call('en_tick+dr_tick','use-open')
    call('en_tick+dr_tick','held-space')
    for _ in range(46):call()
    call('dr_sync','opening48')
    camera(0,6.75);put('en_blocked',0);call('en_z_plus','threshold-blocked')
    call('dr_tick','opening49')
    put('en_blocked',0);call('en_z_plus','threshold-passage')
    for _ in range(9):call('en_z_plus')
    call('dr_sync','crossed-front-back')
    for _ in range(23):call()
    call('dr_sync','fully-open')
    for tag,x in [('right-edge',4.5),('right-frame',4.75),('left-edge',-4.5),('left-frame',-4.75)]:
        camera(x,9.25);put('en_blocked',0);call('en_z_minus',tag)
    camera(7,-14);put('en_space_override',0);call('en_tick+dr_tick')
    put('en_space_override',1);call('en_tick+dr_tick','use-close')
    for _ in range(22):call()
    call('dr_sync','closing23')
    call('dr_tick','closing24')
    camera(0,9.25);put('en_blocked',0);call('en_z_minus','back-blocked')
    word('dr_lift',12*256+128);put('en_state',0);camera(0,8)
    call('dr_tick','safety-reopen')
    word('dr_lift',18*256);put('en_state',0);call('dr_tick','safety-full-open')
    camera(0,-16);put('en_state',0)
    for _ in range(72):call()
    call('dr_sync','fully-closed')
    # Manual changes must not leave an automatic camera crossing a closed leaf.
    word('dr_lift',18*256);put('en_state',1);put('bc_state',1);put('en_manual',1)
    put('explorer_key_col2',253);put('en_space_override',0);call('en_tick+dr_tick','restart-auto')
    cmds.append('quit');info=run(prg,stem,cmds)
    def ram(tag):return Path(str(stem)+'-'+tag+'.ram').read_bytes()[2:]
    cases=[]
    def expect(tag,fields,lift=None,position=None):
        m=ram(tag)
        for n,v in fields.items():assert m[l[n]]==v,(tag,n,m[l[n]],v)
        actual=int.from_bytes(m[l['dr_lift']:l['dr_lift']+2],'little')/256
        if lift is not None:assert actual==lift,(tag,actual,lift)
        if position is not None:
            pos=tuple(int.from_bytes(bytes([m[l['explorer_cam_'+a+'_lo']],m[l['explorer_cam_'+a+'_hi']]]),'little',signed=True)/256 for a in ('x','z'))
            assert pos==position,(tag,pos,position)
        cases.append(dict(case=tag,fields=fields,liftWU=actual,position=position,result='PASS'))
    expect('use-open',{'en_state':1,'bc_state':1,'en_event_count':1,'dr_state':1,'dr_passable':0},.25)
    expect('held-space',{'en_event_count':1,'dr_state':1},.5)
    expect('opening48',{'dr_state':1,'dr_passable':0},12)
    expect('threshold-blocked',{'en_blocked':1},12,(0,6.75))
    expect('opening49',{'dr_state':1,'dr_passable':1},12.25)
    expect('threshold-passage',{'en_blocked':0},12.25,(0,7))
    expect('crossed-front-back',{'en_blocked':0},12.25,(0,9.25))
    expect('fully-open',{'dr_state':2,'dr_passable':1},18)
    expect('right-edge',{'en_blocked':0},18,(4.5,9))
    expect('right-frame',{'en_blocked':1},18,(4.75,9.25))
    expect('left-edge',{'en_blocked':0},18,(-4.5,9))
    expect('left-frame',{'en_blocked':1},18,(-4.75,9.25))
    expect('use-close',{'en_state':0,'en_event_count':2,'dr_state':3,'dr_passable':1},17.75)
    expect('closing23',{'dr_state':3,'dr_passable':1},12.25)
    expect('closing24',{'dr_state':3,'dr_passable':0},12)
    expect('back-blocked',{'en_blocked':1},12,(0,9.25))
    expect('safety-reopen',{'en_state':1,'bc_state':1,'dr_state':1,'dr_safety_events':1},12.75)
    expect('safety-full-open',{'en_state':1,'dr_state':2,'dr_safety_events':2},18)
    expect('fully-closed',{'dr_state':0,'dr_passable':0,'dr_seen_states':15},0)
    expect('restart-auto',{'en_manual':0,'en_state':0,'bc_state':0,'dr_state':0,'demo_key':0,'dr_route_fault':0},0)
    info.update(result='PASS',cases=cases,fixtureRAM=[start,start+32],
        programFileUnmodified=True,shaderBytesModified=False,
        protocol='Native delivered routines called from unused RAM; matrix input data controlled by monitor; no timing inferred from fixture')
    stem.with_suffix('.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
    return cases


def views(build):
    b,prg,l=paths(build);stem=ROOT/'reports/door-views/native'
    cases=[]
    for name,lift in [('closed',0),('quarter',6.25),('clearance',12.25),('open',18)]:
        for enabled in (0,1):cases.append((name+('-on' if enabled else '-off'),lift,enabled,[0,0,18,180,0]))
    cases += [('front-off',0,0,[0,0,-16,0,0]),('front-on',0,1,[0,0,-16,0,0]),
        ('near-front',6.25,0,[0,0,7,0,14]),('near-back',6.25,0,[0,0,9,180,-14]),
        ('oblique-front',6.25,1,[-12,0,-12,-25,12]),('oblique-back',6.25,1,[-12,0,18,150,-12])]
    cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x',
        f'> ${l["advance_sim_tick"]:04x} 60',f'> ${l["bb_frame_ready"]:04x} ea ea ea',
        f'> ${l["bb_frame"]:04x} 00','disable 1','break exec .fps_frame_done','disable 2','break exec .raster_irq','disable 3']
    for tag,lift,enabled,camera in cases:
        q=round(lift*256)
        cmds += [f'> ${l["dr_lift"]:04x} {q&255:02x} {q>>8:02x}',f'> ${l["bb_enabled"]:04x} {enabled:02x}',f'> ${l["bb_loaded"]:04x} ff']
        cp=[round(v*256) for v in camera[:3]]+[round(v*65536/360)&65535 for v in camera[3:]]
        for axis,value in zip('xyz',cp[:3]):
            for i,suffix in enumerate(('lo','hi','ext')):cmds.append(f'> ${l["explorer_cam_"+axis+"_"+suffix]:04x} {(value>>(8*i))&255:02x}')
        for axis,v in zip(('yaw','pitch'),cp[3:]):
            cmds += [f'> ${l["explorer_cam_"+axis]:04x} {v>>8:02x}',f'> ${l["qc_demo_"+axis+"_lo"]:04x} {v&255:02x}']
        cmds += ['enable 1','ignore 1 2','x','disable 1','enable 2','x','disable 2','bank ram',
            f'save "{stem}-{tag}.ram" 0 $0000 $ffff','bank cpu',f'save "{stem}-{tag}.color.ram" 0 $d800 $dbe7',
            'enable 3','ignore 3 1','x','disable 3',f'screenshot "{stem}-{tag}.png" 2']
    cmds.append('quit');info=run(prg,stem,cmds);ui=[]
    for tag,_,_,_ in cases:
        m=Path(str(stem)+'-'+tag+'.ram').read_bytes()[2:]
        color=Path(str(stem)+'-'+tag+'.color.ram').read_bytes()[2:]
        ui.append(check_frame(m,color,l,tag))
    info.update(result='PASS',views=ui)
    stem.with_suffix('.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
    return ui


def occlusion(build):
    _,_,l=paths(build);root=ROOT/'reports/door-views';src=json.loads((ROOT/'assets/guard-frames.json').read_text(encoding='utf-8-sig'))['frames'][0]
    rows=[]
    geometry=json.loads((ROOT/'reports/door-geometry.json').read_text(encoding='utf-8-sig'))
    for tag,lift in [('closed',0),('quarter',6.25),('clearance',12.25),('open',18),('front',0)]:
        off=(root/f'native-{tag}-off.ram').read_bytes()[2:];on=(root/f'native-{tag}-on.ram').read_bytes()[2:]
        expected=bytearray(off)
        left,right,top,bottom=[int.from_bytes(on[l['bb_'+n]:l['bb_'+n]+2],'little',signed=True) for n in ('left','right','top','bottom')]
        assert 0<right-left<256 and 0<bottom-top<256,(tag,left,right,top,bottom)
        visible=hidden=0
        gap_y=math.ceil(Fraction(30)-Fraction(round((-10+lift)*256)*41,2560))
        for y in range(max(0,top),min(60,bottom)):
            for x in range(max(0,left),min(96,right)):
                value=src[(y-top)*32//(bottom-top)*16+(x-left)*16//(right-left)]
                if value==0:continue
                # Independent ray/plane rectangle at worldY8, cameraY18,
                # focal41, X aperture[-5,5]. Integer sample/top-left coverage.
                exposed=tag=='front' or (28<=x<69 and y>=gap_y)
                if exposed:
                    visible+=1;shift=6-2*(x&3)
                    for bank in (0x2000,0x6000):
                        for scan in (0,1):
                            py=8+y*2+scan;a=bank+(py//8)*320+(6+x//4)*8+py%8
                            expected[a]=(expected[a]&~(3<<shift))|((value&3)<<shift)
                else:hidden+=1
        for bank in (0x2000,0x6000):
            assert on[bank:bank+8000]==expected[bank:bank+8000],('independent door/guardian occlusion oracle',tag,hex(bank))
        if tag=='quarter':
            # Q8 fraction survives the moving-vertex stage before projection.
            q=round((-10+lift)*256)&0xffffff
            for v in geometry['bottomVertices']:
                actual=sum(on[l[f'hc_cam_y{i}']+v]<<(8*i) for i in range(3))
                assert actual==q,('moving Q8 vertex',actual,q)
        rows.append(dict(case=tag,visibleOpaqueSamples=visible,hiddenOpaqueSamples=hidden,bitmapBytesCompared=16000,apertureFirstVisibleRow=gap_y))
    assert rows[0]['visibleOpaqueSamples']==0
    assert 0<rows[1]['visibleOpaqueSamples']<rows[3]['visibleOpaqueSamples']
    assert rows[3]['hiddenOpaqueSamples']>0 and rows[4]['hiddenOpaqueSamples']==0
    (ROOT/'reports/door-occlusion.json').write_text(json.dumps(dict(result='PASS',oracles=rows),indent=2)+'\n',encoding='utf-8')
    return rows


def checks(build):
    cases=state_proof(build);ui=views(build);pixels=occlusion(build)
    report=dict(result='PASS',PRGSHA256=sha(paths(build)[1]),statesAndPassage=cases,UI=ui,occlusion=pixels)
    (ROOT/'reports/native-door.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    return report
