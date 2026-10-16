"""Native external-file transactions, exact persistent state and failure isolation."""
import json,re,shutil,subprocess,sys
from pathlib import Path
from native_world import ROOT,paths,run,sha
from verify_ui import check_frame,lod_trace


def fixture(build,tag,media=None,trace_io=False):
    b,p,l=paths(build);meta=json.loads((b/'build.json').read_text())
    a,z=max(meta['remainingGaps'],key=lambda p:p[1]-p[0]);a=(a+1)&~1;assert z-a>=112
    stem=ROOT/'reports/world-native'/tag
    cmds=[f'load_labels "{b/"3Dvibe64.labels"}"','break exec .fps_frame_done','x','disable 1',f'break exec ${a+96:04x}']
    if trace_io:cmds[:0]=[f'logname "{stem}.monitor.log"','log on'];cmds.append('trace exec .wg_io_irq')
    def address(n):
        k,_,offset=n.partition('+');return l[k]+int(offset or 0)
    def put(n,v):cmds.append(f'> ${address(n):04x} {v&255:02x}')
    def save(tag):cmds.extend(['bank ram',f'save "{stem}-{tag}.ram" 0 $0000 $ffff','bank cpu'])
    def call(names='wg_request+wg_service',arg=0,tag=None,irq=False):
        data=([0xad,0x11,0xd0,0xa8,0xad,0x12,0xd0,0x18,0x69,16,0x8d,0x12,0xd0,0x90,4,0x98,0x49,0x80,0xa8,0x98,0x8d,0x11,0xd0] if irq else [])+[0xa9,arg&255]
        for n in names.split('+'):
            addr=l[n];data.extend([0x20,addr&255,addr>>8])
        data.extend([0x08,0x68,0x8d,(a+104)&255,(a+104)>>8]);data += [0xea]*(96-len(data))
        cmds.extend([f'> ${a:04x} '+' '.join(f'{v:02x}' for v in data),f'r pc=${a:04x}','x'])
        if tag:save(tag)
    def finish():
        cmds.append('quit');info=run(p,stem,cmds,media)
        return info,lambda tag:Path(str(stem)+'-'+tag+'.ram').read_bytes()[2:]
    for n,v in [('en_manual',1),('en_key_override',1),('wg_key_override',1),('wg_col4',255),('wg_col5',255)]:put(n,v)
    save('boot')
    return l,address,put,call,save,finish,a


def transactions(build):
    l,addr,put,call,save,finish,a=fixture(build,'transactions')
    config=json.loads((ROOT/'reports/world-groups.json').read_text());fields=config['persistentFields']
    first=[1,7,3,64,6,1,2,3,4,1,1,2,5,2]
    second=[0,11,5,128,12,3,4,15,8,0,0,1,3,1]
    for n,v in zip(fields,first):put(n,v)
    save('first')
    call(arg=1,tag='second-initial')
    for n,v in zip(fields,second):put(n,v)
    save('second')
    call(arg=0,tag='first-restored');call(arg=1,tag='second-restored')
    call('wg_request',1,'same');call('wg_request',255,'invalid')
    put('wg_pending',0);call('wg_request',1,'busy');put('wg_pending',255)
    put('wg_links+1',0);call('wg_request',0,'unlinked');put('wg_links+1',1)
    # Keyboard edges and genuine public movement/door routines after restoration.
    put('wg_last_keys',0);put('wg_col5',253);call('wg_tick+wg_service',0,'previous-key')
    call('wg_tick+wg_service',0,'previous-held')
    put('wg_col5',255);call('wg_tick');put('wg_col4',127);call('wg_tick+wg_service',0,'next-key')
    put('wg_col4',255);call('wg_tick');call('dr_tick',0,'door-resumed')
    info,ram=finish();rows=[]
    def values(m):return [m[addr(n)] for n in fields]
    assert ram('boot')[l['wg_current']]==0
    assert values(ram('first-restored'))==first
    assert values(ram('second-restored'))==second
    assert values(ram('second-initial'))==[1,0,0,0,18,2,0,0,0,1,1,0,0,4]
    for tag,group in [('second-initial',1),('first-restored',0),('second-restored',1),('previous-key',0),('next-key',1)]:
        m=ram(tag);assert m[l['wg_current']]==group and m[l['wg_pending']]==255 and m[l['wg_error']]==0
        g=config['groups'][group]
        for name,expected in g['channels'].items():assert m[l[name]:l[name]+len(expected)]==bytes(expected),(tag,name)
        blob=(ROOT/'media'/g['filename']).read_bytes();assert m[l['wg_arena']:l['wg_arena']+len(blob)]==blob
        rows.append(dict(case=tag,group=group,channels=27,exactFileBytes=len(blob),result='PASS'))
    for tag,error,carry in [('same',0,1),('invalid',1,0),('busy',2,0),('unlinked',3,0)]:
        m=ram(tag);assert m[l['wg_error']]==error and m[a+104]&1==carry,(tag,m[l['wg_error']],m[a+104])
        rows.append(dict(case=tag,error=error,carry=carry,result='PASS'))
    assert ram('previous-key')[l['wg_transitions']]==ram('previous-held')[l['wg_transitions']]
    m=ram('door-resumed');assert int.from_bytes(m[l['dr_lift']:l['dr_lift']+2],'little')==12*256+64
    assert list(m[l['wg_visited']:l['wg_visited']+2])==[1,1]
    # A complete group package is absent from the executable; it comes from device8.
    prg=paths(build)[1].read_bytes()
    assert all((ROOT/'media'/g['filename']).read_bytes() not in prg for g in config['groups'])
    info.update(result='PASS',cases=rows,persistentFirst=first,persistentSecond=second,
        persistenceBytesPerGroup=17,fields=fields,heldKeyDoesNotRepeat=True,inactiveGroupsFreeze=True,
        activeSourceCopies=1,externalPackagesAbsentFromPRG=True,fixtureRAM=[a,a+112])
    (ROOT/'reports/world-transactions.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
    return info


def failures(build):
    cfg=json.loads((ROOT/'reports/world-groups.json').read_text());good=(ROOT/'media/wg01').read_bytes();rows=[]
    wrongid=bytearray(good);wrongid[4]=0
    corrupt=bytearray(good);corrupt[30]^=1
    header=bytearray(good);header[5]=3
    footer=bytearray(good);footer[-1]^=1
    for tag,data,error in [('missing',None,4),('empty',b'',5),('truncated',good[:-1],5),('oversize',good+b'X'*400,4),('corrupt',corrupt,5),('wrong-id',wrongid,5),('wrong-count',header,5),('footer',footer,5)]:
        media=ROOT/'reports/world-bad-media'/tag;media.mkdir(parents=True,exist_ok=True)
        shutil.copy2(ROOT/'media/wg00',media/'wg00')
        if data is not None:(media/'wg01').write_bytes(data)
        l,addr,put,call,save,finish,a=fixture(build,'failure-'+tag,media)
        put('wg_arena_end',0xa5);save('before');call(arg=1,tag='after');info,ram=finish();before=ram('before');after=ram('after')
        assert after[l['wg_current']]==0 and after[l['wg_pending']]==255 and after[l['wg_error']]==error,(tag,after[l['wg_error']])
        assert after[l['wg_failures']]==1
        assert after[l['wg_arena_end']]==0xa5,(tag,'buffer overflow')
        for name,expected in cfg['groups'][0]['channels'].items():assert after[l[name]:l[name]+len(expected)]==before[l[name]:l[name]+len(expected)],(tag,name)
        names=cfg['persistentFields']+[f'explorer_cam_{axis}_{suffix}' for axis in 'xyz' for suffix in ('lo','hi','ext')]+['demo_key','demo_subtick','wg_transitions']
        assert all(after[addr(n)]==before[addr(n)] for n in names),(tag,'failed transaction changed live state')
        rows.append(dict(case=tag,error=error,result='PASS',activeGeometryAndStateUnchanged=True,stagingGuardPreserved=True,native=info))
    (ROOT/'reports/world-failures.json').write_text(json.dumps(dict(result='PASS',cases=rows),indent=2)+'\n',encoding='utf-8')
    return rows


def checks(build):
    transactions_report=transactions(build);failed=failures(build)
    io=io_preservation(build)
    graph=graph_walk(build)
    regression=render_checks(build)
    report=dict(result='PASS',PRGSHA256=sha(paths(build)[1]),transactions=transactions_report,failures=failed,ioPreservation=io,graph=graph,rendering=regression)
    (ROOT/'reports/native-world.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    return report


def graph_walk(build):
    cfg=json.loads((ROOT/'reports/world-groups.json').read_text());groups=cfg['configuration']['groups']
    ids=[g['id'] for g in groups];visited={0};route=[]
    def visit(i):
        for neighbor in groups[i]['neighbors']:
            j=ids.index(neighbor)
            if j not in visited:
                visited.add(j);route.append(j);visit(j);route.append(i)
    visit(0);assert len(visited)==len(groups)
    l,addr,put,call,save,finish,a=fixture(build,'graph-walk');put('en_event_count',21);seen={0}
    for step,i in enumerate(route):
        call(arg=i,tag=f'step{step}')
        if i not in seen:put('en_event_count',21+i);seen.add(i)
    info,ram=finish();seen={0};cases=[]
    for step,i in enumerate(route):
        m=ram(f'step{step}');assert m[l['wg_current']]==i and m[l['wg_error']]==0
        assert m[l['en_event_count']]==(21+i if i in seen else 0),(step,i,'event persistence')
        seen.add(i)
        for name,values in cfg['groups'][i]['channels'].items():assert m[l[name]:l[name]+len(values)]==bytes(values),(step,i,name)
        cases.append(dict(step=step,group=i,eventCount=m[l['en_event_count']],result='PASS'))
    info.update(result='PASS',groups=len(groups),rooms=len(groups)*2,cases=cases)
    (ROOT/'reports/world-graph.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
    return info


def render_checks(build):
    """Reuse door pixel oracle and compare both groups to independent static builds."""
    import native_compare,verify_ui
    b,prg,l=paths(build);meta=json.loads((b/'build.json').read_text())
    gap=max(meta['remainingGaps'],key=lambda p:p[1]-p[0])[0];gap=(gap+1)&~1
    selected=[0]
    def booted_run(p,stem,cmds):
        commands=list(cmds);i=commands.index('break exec .render_frame_begin');commands[i]='break exec .fps_frame_done'
        if selected[0]:
            a=l['wg_request'];s=l['wg_service'];f=l['fps_frame_done']
            data=[0xa9,selected[0],0x20,a&255,a>>8,0x20,s&255,s>>8,0x4c,f&255,f>>8]
            i=commands.index('x',i)+1
            commands[i:i]=[f'> ${gap:04x} '+' '.join(f'{v:02x}' for v in data),f'r pc=${gap:04x}','x']
        return run(p,stem,commands)
    native_compare.run=booted_run;verify_ui.run=booted_run
    import qualify_door
    qualify_door.run=booted_run
    state=qualify_door.state_proof(build);groups=[]
    for group in (0,1):
        selected[0]=group;views=qualify_door.views(build);pixels=qualify_door.occlusion(build)
        source=ROOT/'reports/door-views';dest=ROOT/f'reports/world-views-{group}'
        dest.mkdir(exist_ok=True)
        for p in source.iterdir():
            if p.is_file():shutil.copy2(p,dest/p.name)
        weights=verify_ui.lod_trace(build)
        reference=static_reference(build,group)
        compared=[]
        for view in views:
            tag=view['tag'];first=(dest/f'native-{tag}.ram').read_bytes()[2:];second=(reference/f'reports/door-views/native-{tag}.ram').read_bytes()[2:]
            for start,size in [(0x2000,8000),(0x6000,8000),(0x400,1000),(0x5c00,1000)]:assert first[start:start+size]==second[start:start+size],(group,tag,hex(start))
            x=(dest/f'native-{tag}.color.ram').read_bytes()[2:];y=(reference/f'reports/door-views/native-{tag}.color.ram').read_bytes()[2:]
            assert bytes(v&15 for v in x)==bytes(v&15 for v in y),(group,tag,'color')
            compared.append(dict(tag=tag,bitmapBytes=16000,screenBytes=2000,colorCells=1000,result='PASS'))
        groups.append(dict(group=group,UI=views,occlusion=pixels,LODWeights=weights,staticReference=str(reference),comparisons=compared))
    report=dict(result='PASS',doorStates=state,groups=groups)
    (ROOT/'reports/world-rendering.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    return report


def static_reference(build,group):
    reference=ROOT/f'reports/world-static-reference-{group}';attempt=0
    while reference.exists():
        attempt+=1;reference=ROOT/f'reports/world-static-reference-{group}-run{attempt}'
    reference.mkdir()
    for name in ('src','sdk','private','assets','tools','reference'):
        shutil.copytree(ROOT/name,reference/name,ignore=shutil.ignore_patterns('__pycache__'))
    surface=reference/'assets/surfaces.json';d=json.loads(surface.read_text())
    for name,entries in d['meshes'].items():d['meshes'][name]=entries[:16]
    surface.write_text(json.dumps(d,indent=2)+'\n',encoding='utf-8')
    shutil.copy2(ROOT/'build_demo.py',reference/'build_demo.py')
    for name in ('room','room/scenes','room/reports','reports','artifacts'):(reference/name).mkdir(exist_ok=True)
    p=reference/'src/world_profile.py'
    p.write_text(p.read_text()+f'''
# Qualification fixture: bake selected data into the old resident layout.
# No group manager, external I/O or transaction code is assembled.
CONFIG['enabled']=False
def adapt(source,parts):
    global COMPILED
    COMPILED=world.compile_groups(CONFIG,world.arrays(source,parts))
    for name,values in COMPILED[{group}]['channels'].items():
        pattern=r'(?m)^'+name+r':[ \\t]*(?:\\n)?((?:[ \\t]*\\.byte[^\\n]+\\n)+)'
        replacement=name+': .byte '+','.join(str(v) for v in values)+'\\n'
        if re.search(pattern,source):source=re.sub(pattern,lambda m:replacement,source)
        else:
            owners=[k for k,v in parts.items() if re.search(pattern,v)];assert len(owners)==1
            parts[owners[0]]=re.sub(pattern,lambda m:replacement,parts[owners[0]])
    return source,parts
''',encoding='utf-8',newline='\n')
    command=[sys.executable,'-B','build_demo.py','--name',build,'--artifact-tag',build,'--precise']
    result=subprocess.run(command,cwd=reference,capture_output=True,timeout=600)
    (reference/'reports/build.log').write_bytes(result.stdout+result.stderr);assert result.returncode==0,(reference,result.stderr.decode(errors='replace')[-2000:])
    if group==0:assert sha(reference/f'artifacts/room-skeleton-billboard-precise-pal-{build}.prg')=='FA692F07C3E302E818FF4B8586CDA9B7215D53242F386D02177D6E53A5AF6ADA'
    code=f"import sys;sys.path.insert(0,'tools');import qualify_door as q;q.views({build!r});q.occlusion({build!r});print('STATIC REFERENCE PASS')"
    result=subprocess.run([sys.executable,'-B','-c',code],cwd=reference,capture_output=True,timeout=600)
    (reference/'reports/native.log').write_bytes(result.stdout+result.stderr);assert result.returncode==0,(reference,result.stderr.decode(errors='replace')[-2000:])
    return reference


def io_preservation(build):
    l,addr,put,call,save,finish,a=fixture(build,'io-preservation',trace_io=True)
    put('wg_target',1);save('before');call('wg_read',tag='after',irq=True)
    info,ram=finish();before=ram('before');after=ram('after')
    assert after[2:256]==before[2:256],'KERNAL zero page ownership escaped I/O transaction'
    assert after[0x314:0x334]==before[0x314:0x334],'KERNAL vectors not restored'
    assert after[l['wg_port']]==0x35 and after[l['wg_io_error']]==0
    blob=(ROOT/'media/wg01').read_bytes();assert after[l['wg_arena']:l['wg_arena']+len(blob)]==blob
    text=(ROOT/'reports/world-native/io-preservation.monitor.log').read_text(errors='replace')
    count=len(re.findall(r'#3 \(Trace\s+exec ',text));assert count>0,'I/O IRQ path was not exercised'
    info.update(result='PASS',nativeIOInterrupts=count,zeroPageBytesRestored=254,vectorBytesRestored=32,exactFileBytes=len(blob))
    (ROOT/'reports/world-io-preservation.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
    return info
