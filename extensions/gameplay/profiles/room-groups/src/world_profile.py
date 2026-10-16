"""Two-room resident layout loaded transactionally from external group files."""
import hashlib
import json
import re
from pathlib import Path
import world_groups as world
ROOT=Path(__file__).resolve().parents[1]
CONFIG=world.validate(json.loads((ROOT/'assets/world-groups.json').read_text(encoding='utf-8-sig')))
COMPILED=None
if CONFIG['enabled']:
    import block4
    block4.pack=world.pack


def configure_tour(human):
    if CONFIG['enabled'] and CONFIG['autoTransitions']:
        route=human.poses()[:24];human.KEYS=24;human.PERIOD=1536;human.poses=lambda:route


def adapt(source,parts):
    global COMPILED
    base=world.arrays(source,parts);COMPILED=world.compile_groups(CONFIG,base)
    if not CONFIG['enabled']:return source,parts
    old='advance_sim_tick:\n';assert source.count(old)==1
    source=source.replace(old,old+''' lda wg_pending
 cmp #255
 beq +
 rts
+
 lda wg_current
 cmp #255
 bne +
 jmp wg_tick
+
''',1)
    old=' jsr en_tick\n jsr dr_tick\n';assert source.count(old)==1
    source=source.replace(old,old+' jsr wg_tick\n',1)
    old='render_frame_begin:\n';assert source.count(old)==1
    source=source.replace(old,old+' jsr wg_service\n',1)
    # Preserve all UI/geometry work buffers during ROM ownership of zero page.
    io=(ROOT/'src/world_io.asm').read_text(encoding='utf-8')+parts['tr_irq']
    parts['tr_irq']=' .byte 0\n'
    pattern=r'demo_count_refresh:\n.*?demo_refreshes: \.word 0\n'
    owners=[k for k,v in parts.items() if re.search(pattern,v,re.S)];assert len(owners)==1
    owner=owners[0];match=re.search(pattern,parts[owner],re.S);io+=match[0];parts[owner]=parts[owner][:match.start()]+parts[owner][match.end():]
    parts['world_io']=io
    parts['world_arena']='wg_arena: .fill 1024,0\nwg_arena_end:\n'
    parts['world_manager']=world.manager(CONFIG,COMPILED)
    code=parts['entity_runtime']
    old='en_room:\n';a=code.index(old);b=code.index('en_room_outside:',a)
    section=code[a:b];assert section.count(' cmp #23\n')==2
    section=section.replace(' cmp #23\n',' cmp wg_x_limit\n',1)
    parts['entity_runtime']=code[:a]+section+code[b:]
    if CONFIG['autoTransitions']:
        code=parts['entity_runtime'];code,count=re.subn(r'(?m)^en_demo_keys: \.byte [^\n]+','en_demo_keys: .byte '+','.join(['0']*48),code);assert count==1;parts['entity_runtime']=code
    return source,parts


def finalize(labels,metadata):
    if CONFIG['enabled']:
        assert labels['hp_block_world_io_end']<=0xd000
        assert all(labels[n]<0xd000 for n in ('sim_vblank_count','fps_vblank_count','fps_second_flag'))
        assert labels['wg_read']<0xd000 and labels['wg_zp']+254<=0xd000,'KERNAL-visible I/O block must remain below I/O/ROM'
        assert labels['tr_irq_exit']<0xd000 and labels['demo_count_refresh']<0xd000 and labels['demo_refreshes']<0xd000
        assert labels['wg_arena_end']-labels['wg_arena']==1024
    media=ROOT/'media';media.mkdir(exist_ok=True)
    descriptions=[]
    for group in COMPILED:
        path=media/group['filename'];path.write_bytes(group['blob'])
        descriptions.append({k:v for k,v in group.items() if k!='blob'}|dict(SHA256=hashlib.sha256(group['blob']).hexdigest().upper()))
    (ROOT/'reports/world-groups.json').write_text(json.dumps(dict(configuration=CONFIG,groups=descriptions,channels=world.CHANNELS,persistentFields=world.FIELDS),indent=2)+'\n',encoding='utf-8')
    return dict(worldGroups=dict(configuration=CONFIG,enabled=CONFIG['enabled'],groups=len(COMPILED),roomsPerGroup=2,totalRooms=2*len(COMPILED),residentGroups=1,
        stagingBytes=1024,groupFileBytes=COMPILED[0]['bytes'],payloadBytes=COMPILED[0]['payloadBytes'],persistentBytes=17*len(COMPILED),
        media='external files on VICE filesystem device8; KERNAL OPEN/CHKIN/CHRIN with bounded reads',
        integrity='WG01 fixed counts/layout, exact length and CRC16-CCITT against resident expected CRC and file trailer before install',
        controls='WASD manual;SPACE guardian/door;N next group;P previous;R current automatic tour',
        persistence='guardian target, exact door height/state, animation cursor/hold/frame and per-group event counters; inactive groups freeze',
        scope='2..8 groups, each two connected bounded rooms in a fixed21vertex/32face template; shared resident textures/guardian; no arbitrary topology or physical1541 timing'))
