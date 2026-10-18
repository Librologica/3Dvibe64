"""WORLD-01: external bounded room groups, transactional install and persistence.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
Files contain data only; resident whitelisted channels define all destinations.
"""
import binascii
import copy
import json
import re

CHANNELS=['xcoord','ycoord','zcoord','vert_xi','vert_yi','vert_zi']+[f'face{i}' for i in range(4)]+['face_vertex_count']+[f'm7_face_{a}{i}' for a in 'uv' for i in range(3)]+['m7_face_texture','face_material']+[f'gouraud_face_shade{i}' for i in range(3)]+['mx_face_mode','mx_face_index','op_face_axis','op_face_plane','sc_face_codes']
FIELDS=['en_state','en_event_count','en_rejected','dr_lift','dr_lift+1','dr_state','dr_safety_events','dr_seen_states','dr_passages','bc_state','bc_previous','bc_cursor','bc_hold','bb_frame']
CAPACITY=1024


def validate(config):
    if not isinstance(config,dict) or set(config)!={'schema','enabled','autoTransitions','capacityBytes','groups'} or type(config['schema']) is not int or config['schema']!=1 or type(config['enabled']) is not bool or type(config['autoTransitions']) is not bool or type(config['capacityBytes']) is not int or config['capacityBytes']!=CAPACITY:raise ValueError('World requires schema1, flags and1024byte staging capacity')
    groups=config['groups']
    if not isinstance(groups,list) or not 2<=len(groups)<=8:raise ValueError('Expected2..8groups')
    ids=[]
    for g in groups:
        if not isinstance(g,dict) or set(g)!={'id','rooms','halfWidth','floorLevel','doorIndex','initialOpen','neighbors'}:raise ValueError('Invalid group descriptor')
        name=g['id']
        if not isinstance(name,str) or not re.fullmatch('[a-z][a-z0-9-]{0,23}',name) or name in ids:raise ValueError('Invalid/duplicate group id')
        ids.append(name)
        if type(g['rooms']) is not int or g['rooms']!=2 or type(g['halfWidth']) is not int or not 18<=g['halfWidth']<=24:raise ValueError('Bounded two-room group: integer halfWidth18..24')
        if g['floorLevel'] is not None and (type(g['floorLevel']) is not int or not 0<=g['floorLevel']<=32):raise ValueError('Invalid floor Gouraud level')
        if type(g['doorIndex']) is not int or not 1<=g['doorIndex']<=3 or type(g['initialOpen']) is not bool:raise ValueError('Invalid door material/state')
        ns=g['neighbors']
        if not isinstance(ns,list) or not 1<=len(ns)<=2 or any(not isinstance(x,str) for x in ns) or len(set(ns))!=len(ns) or name in ns:raise ValueError('Expected1..2distinct neighbor ids')
    for g in groups:
        if any(n not in ids for n in g['neighbors']):raise ValueError('Unknown neighbor')
        if any(g['id'] not in groups[ids.index(n)]['neighbors'] for n in g['neighbors']):raise ValueError('Transitions must be reciprocal')
    reached={ids[0]}
    while True:
        more=reached|{n for g in groups if g['id'] in reached for n in g['neighbors']}
        if more==reached:break
        reached=more
    if reached!=set(ids):raise ValueError('Disconnected group graph')
    return copy.deepcopy(config)


def arrays(source,parts):
    containers={'source':source,**parts};result={}
    for name in CHANNELS:
        pattern=r'(?m)^'+name+r':[ \t]*(?:\n)?((?:[ \t]*\.byte[^\n]+\n)+)'
        owners=[v for v in containers.values() if re.search(pattern,v)];assert len(owners)==1,name
        body=re.search(pattern,owners[0])[1];values=[]
        for row in re.findall(r'\.byte ([^\n]+)',body):
            for v in row.split(','):values.append(int(v.strip().replace('$','0x'),0)&255)
        result[name]=values
    assert len(result['vert_xi'])==21 and len(result['face0'])==32
    return result


def compile_groups(config,base):
    config=validate(config);result=[]
    for i,g in enumerate(config['groups']):
        data=copy.deepcopy(base)
        data['xcoord']=[(-g['halfWidth'])&255 if x==232 else g['halfWidth'] if x==24 else x for x in data['xcoord']]
        data['op_face_plane'][:4]=[128-g['halfWidth']]*2+[128+g['halfWidth']]*2
        data['mx_face_index'][28:32]=[g['doorIndex']]*4
        if g['floorLevel'] is not None:
            for c in range(3):data[f'gouraud_face_shade{c}'][8:12]=[g['floorLevel']]*4
        payload=bytes(v for name in CHANNELS for v in data[name]);header=b'WG01'+bytes([i,2,21,32,len(payload)&255,len(payload)>>8,g['halfWidth'],int(g['initialOpen'])])
        crc=binascii.crc_hqx(header+payload,0xffff);blob=header+payload+crc.to_bytes(2,'little')
        if len(blob)>CAPACITY:raise ValueError('Group exceeds staging capacity')
        result.append(dict(id=g['id'],index=i,filename=f'wg{i:02d}',rooms=2,channels=data,payloadBytes=len(payload),bytes=len(blob),CRC16=crc,blob=blob))
    return result


def byte(n,values):return n+': .byte '+','.join(str(v&255) for v in values)+'\n'


def manager(config,compiled):
    n=len(compiled);size=compiled[0]['bytes'];ids=[g['id'] for g in config['groups']]
    code=f'''wg_request:
 cmp #{n}
 bcc +
 lda #1
 jmp wg_reject
+
 tay
 lda wg_pending
 cmp #255
 beq +
 lda #2
 jmp wg_reject
+
 lda wg_current
 cmp #255
 bne +
 cpy #0
 beq wg_queue
 lda #3
 jmp wg_reject
+
 cpy wg_current
 bne +
 sec
 rts
+
 ldx wg_current
 lda wg_bits,y
 and wg_links,x
 bne +
 lda #3
 jmp wg_reject
+
wg_queue:
 sty wg_pending
 lda #0
 sta wg_error
 sec
 rts
wg_reject:
 sta wg_error
 inc wg_rejected
 clc
 rts
wg_tick:
 lda wg_key_override
 bne +
 jsr wg_scan_keys
+
 lda #0
 sta wg_keys
 lda wg_col4
 and #$80
 bne +
 lda #1
 sta wg_keys
+
 lda wg_col5
 and #2
 bne +
 lda wg_keys
 ora #2
 sta wg_keys
+
 lda wg_last_keys
 eor #255
 and wg_keys
 pha
 lda wg_keys
 sta wg_last_keys
 pla
 beq wg_auto
 pha
 lda #1
 sta en_manual
 ldx wg_current
 cpx #255
 bne +
 pla
 lda #0
 jmp wg_request
+
 pla
 and #1
 beq wg_previous
 lda wg_next,x
 jmp wg_request
wg_previous:
 lda wg_previous_group,x
 jmp wg_request
wg_auto:
 lda wg_current
 cmp #255
 beq wg_tick_done
 lda wg_auto_transitions
 beq wg_tick_done
 lda en_manual
 bne wg_tick_done
 lda demo_key
 cmp wg_last_key
 beq wg_tick_done
 sta wg_last_key
 cmp #0
 bne +
 jsr en_use
 jmp wg_tick_done
+
 cmp #6
 bne +
 lda en_state
 bne wg_tick_done
 jsr en_use
 jmp wg_tick_done
+
 cmp #23
 bne wg_tick_done
 ldx wg_current
 lda wg_next,x
 jmp wg_request
wg_tick_done:
 rts
wg_scan_keys:
 lda #$ef
 sta $dc00
 lda $dc01
 sta wg_col4
 lda #$df
 sta $dc00
 lda $dc01
 sta wg_col5
 lda #255
 sta $dc00
 rts
wg_service:
 lda wg_pending
 cmp #255
 bne +
 rts
+
 sta wg_target
 jsr wg_read
 lda wg_io_error
 beq +
 lda #4
 jmp wg_failed
+
 lda wg_length
 cmp #<{size}
 bne wg_bad_group
 lda wg_length+1
 cmp #>{size}
 bne wg_bad_group
'''
    for j,v in enumerate(b'WG01'+bytes([0,2,21,32])):
        if j==4:code+=' lda wg_arena+4\n cmp wg_target\n'
        else:code+=f' lda wg_arena+{j}\n cmp #{v}\n'
        code+=' bne wg_bad_group\n'
    code+=f''' lda wg_arena+8
 cmp #<{size-14}
 bne wg_bad_group
 lda wg_arena+9
 cmp #>{size-14}
 bne wg_bad_group
 jsr wg_crc
 ldx wg_target
 lda wg_crc_lo
 cmp wg_expected_lo,x
 bne wg_bad_group
 cmp wg_arena+{size-2}
 bne wg_bad_group
 lda wg_crc_hi
 cmp wg_expected_hi,x
 bne wg_bad_group
 cmp wg_arena+{size-1}
 bne wg_bad_group
 jmp wg_install
wg_bad_group:
 lda #5
wg_failed:
 sta wg_error
 inc wg_failures
 lda #255
 sta wg_pending
 clc
 rts
wg_install:
 ldx wg_current
 cpx #255
 beq wg_first_install
 txa
 asl
 asl
 asl
 asl
 tax
'''
    for j,name in enumerate(FIELDS):code+=f' lda {name}\n sta wg_saved+{j},x\n'
    code+='wg_first_install:\n'
    offset=12
    for name in CHANNELS:
        length=len(compiled[0]['channels'][name]);code+=f' ldx #{length-1}\n-\n lda wg_arena+{offset},x\n sta {name},x\n dex\n bpl -\n';offset+=length
    code+=''' lda wg_target
 sta wg_current
 tax
 lda wg_visited,x
 bne wg_restore
 lda #1
 sta wg_visited,x
 txa
 asl
 asl
 asl
 asl
 tax
 lda #0
'''
    for j in range(16):code+=f' sta wg_saved+{j},x\n'
    code+=''' lda wg_arena+11
 sta wg_saved,x
 sta wg_saved+9,x
 sta wg_saved+10,x
 beq wg_restore
 lda #18
 sta wg_saved+4,x
 lda #2
 sta wg_saved+5,x
 lda #4
 sta wg_saved+13,x
wg_restore:
 lda wg_current
 asl
 asl
 asl
 asl
 tax
'''
    for j,name in enumerate(FIELDS):code+=f' lda wg_saved+{j},x\n sta {name}\n'
    code+=''' lda wg_arena+10
 sec
 sbc #1
 sta wg_x_limit
 lda #255
 sta bb_loaded
 sta en_last_key
 sta wg_last_key
 sta wg_pending
 lda #0
 sta en_use_latch
 sta en_event
 sta dr_side
 sta wg_error
 sta demo_key
 sta demo_subtick
 sta demo_bob_phase
 jsr qc_demo_tick
 inc wg_transitions
 bne +
 inc wg_transitions+1
+
 lda wg_current
wg_commit_done:
 sec
 rts
'''
    code+=f'''wg_crc:
 lda #255
 sta wg_crc_lo
 sta wg_crc_hi
 lda #<wg_arena
 sta wg_crc_read+1
 lda #>wg_arena
 sta wg_crc_read+2
 lda #<{size-2}
 sta wg_crc_left
 lda #>{size-2}
 sta wg_crc_left+1
wg_crc_byte:
wg_crc_read:
 lda wg_arena
 eor wg_crc_hi
 sta wg_crc_hi
 ldx #8
wg_crc_bit:
 asl wg_crc_lo
 rol wg_crc_hi
 bcc +
 lda wg_crc_lo
 eor #$21
 sta wg_crc_lo
 lda wg_crc_hi
 eor #$10
 sta wg_crc_hi
+
 dex
 bne wg_crc_bit
 inc wg_crc_read+1
 bne +
 inc wg_crc_read+2
+
 lda wg_crc_left
 bne +
 dec wg_crc_left+1
+
 dec wg_crc_left
 lda wg_crc_left
 ora wg_crc_left+1
 bne wg_crc_byte
 rts
'''
    code+=byte('wg_bits',[1<<i for i in range(n)])+byte('wg_links',[sum(1<<ids.index(x) for x in g['neighbors']) for g in config['groups']])
    code+=byte('wg_next',[ids.index(g['neighbors'][-1]) if i+1<n else ids.index(g['neighbors'][0]) for i,g in enumerate(config['groups'])])
    code+=byte('wg_previous_group',[ids.index(g['neighbors'][0]) for g in config['groups']])
    for j,suffix in enumerate(('lo','hi')):code+=byte('wg_expected_'+suffix,[c['CRC16']>>(8*j) for c in compiled])
    for name,v in [('current',255),('pending',0),('target',0),('error',0),('failures',0),('rejected',0),('x_limit',23),('last_key',255),('keys',0),('last_keys',0),('key_override',0),('col4',255),('col5',255),('auto_transitions',int(config['autoTransitions'])),('crc_lo',0),('crc_hi',0)]:code+=byte('wg_'+name,[v])
    code+='wg_transitions: .word 0\nwg_crc_left: .word 0\n'+f'wg_visited: .fill {n},0\nwg_saved: .fill {16*n},0\n'
    return code


def pack(sizes,lab):
    # PRIVATE demo all-RAM layout: KERNAL banked out, own IRQ/NMI wrapper.
    # Existing bitmap/screen windows untouched. Never allocate I/O/vectors.
    gaps=[(lab['mode3_high_basic_low_segment_end'],0x2000),(lab['mode3_high_basic_high_code_end'],0x5c00),
          (lab['mode3_high_basic_relocated_code_end'],0xa400),(lab['tr_fixed_high_end'],0xd000),
          (lab['mode3_high_basic_middle_end'],0xff00),
          (lab['RUNTIME_BUFFER_END']+32,0x9000)]
    items=sorted(sizes.items(),key=lambda x:-x[1]);seen=set();nodes=0
    def search(i,free,placed):
        nonlocal nodes
        nodes+=1
        if nodes>300000:return None
        if i==len(items):return placed,free
        state=(i,tuple(sorted(free)))
        if state in seen:return None
        seen.add(state)
        name,size=items[i];need=size+(0 if name in ('tables','data') else 8)
        if sum(b-a for a,b in free)<sum(s+(0 if n in ('tables','data') else 8) for n,s in items[i:]):return None
        options=[(b-((a+1)&~1)-need,j,(a+1)&~1) for j,(a,b) in enumerate(free) if ((a+1)&~1)+need<=b and (name!='world_io' or ((a+1)&~1)+need<=0xd000)]
        for _,j,start in sorted(options):
            a,b=free[j];nextfree=free[:j]+free[j+1:]
            if a<start:nextfree.append((a,start))
            if start+need<b:nextfree.append((start+need,b))
            result=search(i+1,nextfree,{**placed,name:(start,start+need)})
            if result:return result
        return None
    result=search(0,gaps,{})
    if not result:raise ValueError(f'WORLD_GROUP_MEMORY: exact search failed, need={sum(s+(0 if n in ("tables","data") else 8) for n,s in items)}, free={sum(b-a for a,b in gaps)}, nodes={nodes}, blocks={len(items)}')
    return result[0],gaps,result[1]
