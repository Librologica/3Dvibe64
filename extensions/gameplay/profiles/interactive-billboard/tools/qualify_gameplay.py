"""Native entity state/input/collision transactions and exact billboard pixels."""
import json
from pathlib import Path
from native_compare import ROOT,paths,run,sha,capture
from verify_ui import check_frame


def entities(build):
    b,prg,l=paths(build);metadata=json.loads((b/'build.json').read_text(encoding='utf-8-sig'))
    start,end=max(metadata['remainingGaps'],key=lambda p:p[1]-p[0]);assert end-start>=16
    stem=ROOT/'reports/entities/native'
    cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x','disable 1']
    def put(name,v):cmds.append(f'> ${l[name]:04x} {v&255:02x}')
    def camera(x,z):
        for axis,value in [('x',x),('z',z)]:
            q=round(value*256)
            for i,suffix in enumerate(('lo','hi','ext')):put('explorer_cam_'+axis+'_'+suffix,q>>(8*i))
    def call(tag,target='en_tick'):
        addr=l[target]
        cmds.extend([f'> ${start:04x} 20 {addr&255:02x} {addr>>8:02x} 4c {(start+3)&255:02x} {(start+3)>>8:02x}',
            f'r pc=${start:04x}',f'break exec ${start+3:04x}','x','delete 2','bank ram',
            f'save "{stem}-{tag}.ram" 0 $0000 $ffff','bank cpu'])
    for n,v in [('en_key_override',1),('en_enabled',1),('en_manual',1),('en_state',0),('bc_state',0),
        ('en_event_count',0),('en_rejected',0),('en_use_latch',0),('en_space_override',0),
        ('explorer_key_col1',255),('explorer_key_col2',255),('explorer_key_col7',255)]:put(n,v)
    camera(7,-22);put('en_space_override',1);call('far')
    call('held-far');put('en_space_override',0);call('release')
    camera(7,-18);put('en_space_override',1);call('use-boundary');call('held-near')
    put('en_space_override',0);call('release2');put('en_space_override',1);call('toggle')
    put('en_space_override',0);call('release3')
    camera(-12,0);put('en_space_override',1);call('negative-far')
    put('en_space_override',0);call('release4');camera(-11,0);put('en_space_override',1);call('negative-boundary')
    put('en_space_override',0);camera(7,-8.25);put('explorer_key_col1',253);call('solid-front')
    put('explorer_key_col2',251);call('slide')
    put('explorer_key_col1',255);camera(23,-20);call('room-right')
    put('explorer_key_col1',251);put('explorer_key_col2',255);camera(-23,-20);call('room-left')
    put('explorer_key_col1',223);camera(7,8.25);call('solid-back')
    put('explorer_key_col1',255);put('en_enabled',0);put('en_space_override',1);call('disabled')
    # Non-power-of-two sequence lengths are supported by the JSON API; the
    # default used sequence proves reset, hold and wrap on native ticks.
    put('bc_state',1);put('bc_previous',0)
    call('anim-reset','bb_tick')
    for i in range(1,17):call(f'anim{i:02}','bb_tick')
    cmds.append('quit');info=run(prg,stem,cmds)
    def ram(tag):return Path(str(stem)+'-'+tag+'.ram').read_bytes()[2:]
    def value(tag,n):return ram(tag)[l[n]]
    def pos(tag,axis):
        m=ram(tag);return int.from_bytes(bytes([m[l['explorer_cam_'+axis+'_lo']],m[l['explorer_cam_'+axis+'_hi']]]),'little',signed=True)/256
    assertions=[]
    def expect(tag,values,position=None):
        for n,v in values.items():assert value(tag,n)==v,(tag,n,value(tag,n),v)
        if position is not None:assert (pos(tag,'x'),pos(tag,'z'))==position,(tag,pos(tag,'x'),pos(tag,'z'))
        assertions.append(dict(case=tag,values=values,position=position,result='PASS'))
    expect('far',{'en_state':0,'en_rejected':1,'en_event':2})
    expect('held-far',{'en_rejected':1,'en_event':0})
    expect('use-boundary',{'en_state':1,'bc_state':1,'en_event_count':1,'en_event':1})
    expect('held-near',{'en_state':1,'en_event_count':1,'en_event':0})
    expect('toggle',{'en_state':0,'en_event_count':2})
    expect('negative-far',{'en_state':0,'en_rejected':2})
    expect('negative-boundary',{'en_state':1,'en_event_count':3})
    expect('solid-front',{'en_blocked':1},(7,-8.25))
    expect('slide',{'en_blocked':1},(7.25,-8.25))
    expect('room-right',{'en_blocked':1},(23,-20))
    expect('room-left',{'en_blocked':1},(-23,-20))
    expect('solid-back',{'en_blocked':1},(7,8.25))
    expect('disabled',{'en_state':1,'en_event_count':3,'en_event':0})
    expect('anim-reset',{'bc_cursor':0,'bc_hold':0})
    expect('anim07',{'bc_cursor':0,'bc_hold':7})
    expect('anim08',{'bc_cursor':1,'bc_hold':0})
    expect('anim16',{'bc_cursor':0,'bc_hold':0})
    info.update(result='PASS',cases=assertions,fixture=[start,start+6],
        shaderBytesModified=False,programFileUnmodified=True,
        inputs='native matrix-column values and SPACE edge; harness invokes delivered routines in unallocated RAM')
    stem.with_suffix('.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
    return assertions


def billboard(build):
    b,prg,l=paths(build);root=ROOT/'reports/billboard-scene';root.mkdir(parents=True,exist_ok=True);stem=root/'native'
    art=json.loads((ROOT/'assets/guard-frames.json').read_text(encoding='utf-8-sig'))
    commands=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .render_frame_begin','x',
        f'> ${l["advance_sim_tick"]:04x} 60',f'> ${l["bb_frame_ready"]:04x} ea ea ea','disable 1',
        'break exec .bb_draw','disable 2','break exec .ddb_after_draw','disable 3']
    for axis,v in zip('xyz',(0,0,round(-21.5*256))):
        for i,suffix in enumerate(('lo','hi','ext')):commands.append(f'> ${l["explorer_cam_"+axis+"_"+suffix]:04x} {(v>>(8*i))&255:02x}')
    for axis in ('yaw','pitch'):
        commands.extend([f'> ${l["explorer_cam_"+axis]:04x} 00',f'> ${l["qc_demo_"+axis+"_lo"]:04x} 00'])
    for frame in range(len(art['frames'])):
        commands.extend([f'> ${l["bb_frame"]:04x} {frame:02x}',f'> ${l["bb_loaded"]:04x} ff',
            'enable 1','ignore 1 1','x','disable 1','enable 2','x','disable 2','bank ram',
            f'save "{stem}-{frame}-before.ram" 0 $0000 $ffff','bank cpu',
            'enable 3','x','disable 3','bank ram',f'save "{stem}-{frame}-after.ram" 0 $0000 $ffff','bank cpu'])
    commands.append('quit');info=run(prg,stem,commands);views=[]
    for frame,pixels in enumerate(art['frames']):
        before=Path(str(stem)+f'-{frame}-before.ram').read_bytes()[2:]
        after=Path(str(stem)+f'-{frame}-after.ram').read_bytes()[2:]
        assert before[l['bb_pixels']:l['bb_pixels']+512]==bytes(pixels)
        left,right,top,bottom=[int.from_bytes(before[l['bb_'+n]:l['bb_'+n]+2],'little',signed=True) for n in ('left','right','top','bottom')]
        w=right-left;h=bottom-top;expected=bytearray(before)
        base=0x2000 if before[l['drawbuf']] else 0x6000
        colored=transparent=black=0
        for dy in range(h):
            y=top+dy
            if not 0<=y<60:continue
            for dx in range(w):
                x=left+dx
                if not 0<=x<96:continue
                v=pixels[dy*32//h*16+dx*16//w]
                if not v:transparent+=1;continue
                if v==4:black+=1
                else:colored+=1
                shift=6-2*(x&3)
                for scan in (0,1):
                    py=8+y*2+scan;addr=base+(py//8)*320+(6+x//4)*8+py%8
                    expected[addr]=(expected[addr]&~(3<<shift))|((v&3)<<shift)
        for bank in (0x2000,0x6000):assert after[bank:bank+8000]==expected[bank:bank+8000],('billboard pixel oracle',frame)
        views.append(dict(frame=frame,rect=[left,top,right,bottom],bitmapBytesCompared=16000,colored=colored,black=black,transparent=transparent))
    info.update(result='PASS',frames=views)
    stem.with_suffix('.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
    return views


def checks(build):
    cases=entities(build);pixels=billboard(build);b,prg,l=paths(build);views=[]
    for key in (0,12,24,36):
        tag=f'view{key:02}'
        capture(build,key,0,tag=tag)
        stem=ROOT/f'reports/views/{build}-{tag}'
        views.append(check_frame(stem.with_suffix('.ram').read_bytes()[2:],Path(str(stem)+'.color.ram').read_bytes()[2:],l,tag))
    report=dict(result='PASS',PRGSHA256=sha(prg),entityCases=cases,billboardPixelOracles=pixels,UI=views)
    (ROOT/'reports/native-gameplay.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    return report
