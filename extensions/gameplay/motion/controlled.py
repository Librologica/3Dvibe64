"""Bounded Q8 clip playback and true view-space camera roll.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
Main-thread commands; immutable shared mesh and clip source data.
"""
import copy
import math


def phase(degrees):return round(degrees*65536/360)&65535
def rounded(n,d):return ((abs(n)+d//2)//d)*(1 if n>=0 else -1)
def byte(name,values):return name+': .byte '+','.join(str(v&255) for v in values)+'\n'


def validate(config,shared):
    if not isinstance(config,dict) or set(config)!={'schema','enabled','camera','clips'} or type(config['schema']) is not int or config['schema']!=1 or type(config['enabled']) is not bool:raise ValueError('Expected motion schema1, enabled, camera and clips')
    camera=config['camera']
    if not isinstance(camera,dict) or set(camera)!={'mode','bankDegrees'} or camera['mode'] not in ('dungeon','flight') or type(camera['bankDegrees']) not in (int,float) or not math.isfinite(camera['bankDegrees']) or not 0<=camera['bankDegrees']<=45:raise ValueError('Expected dungeon/flight camera, finite bank0..45degrees')
    instances=shared['instances'];clips=config['clips']
    if not isinstance(clips,list) or len(clips)!=len(instances):raise ValueError('One clip is required per native instance')
    envelopes=[]
    for obj,clip in zip(instances,clips):
        if not isinstance(clip,dict) or set(clip)!={'instance','ticksPerKey','playing','speed','loop','keys'} or clip['instance']!=obj['id']:raise ValueError('Clips must follow instance ids in order')
        if type(clip['ticksPerKey']) is not int or clip['ticksPerKey']!=64 or type(clip['playing']) is not bool or type(clip['loop']) is not bool or type(clip['speed']) is not int or clip['speed'] not in (1,2,4):raise ValueError('Expected64ticks/key, boolean playback/loop and speed1/2/4')
        keys=clip['keys']
        if not isinstance(keys,list) or not 1<=len(keys)<=8:raise ValueError('Expected1..8motion keys')
        for key in keys:
            if not isinstance(key,dict) or set(key)!={'position','yawDegrees','scale','visible'}:raise ValueError('Invalid motion key')
            p=key['position'];k=key['scale'];angle=key['yawDegrees']
            if not isinstance(p,list) or len(p)!=3 or any(type(v) not in (int,float) or not math.isfinite(v) or abs(v)>23 or v*256!=round(v*256) for v in p):raise ValueError('Motion positions must be bounded Q8')
            if type(k) not in (int,float) or not math.isfinite(k) or not .5<=k<=1 or k*64!=round(k*64):raise ValueError('Motion scale must be Q6 in0.5..1')
            if type(angle) not in (int,float) or not math.isfinite(angle) or not 0<=angle<360 or type(key['visible']) is not bool:raise ValueError('Invalid motion yaw/visibility')
            # Maximum sine-table/rounding envelope throughout linear segments.
            if abs(p[0])+3*k+1/8>=24 or abs(p[1])+3*k+1/8>=24 or p[2]-5*k<-10 or p[2]+5*k>=18:raise ValueError('Motion envelope leaves the room')
        initial={k:obj[k] for k in ('position','yawDegrees','scale','visible')}
        if keys[0]!=initial:raise ValueError('First motion key must match the instance descriptor')
        _,compiled=samples({'clips':[clip]});points=[]
        for row in compiled:
            for tick in range(64):
                v=[a+b*tick for a,b in zip(row['values'],row['steps'])]
                p=[v[a]/256 for a in (0,2,1)];scale=(v[4]>>8)/64
                if not .5<=scale<=1 or abs(p[0])+3*scale+1/8>=24 or abs(p[1])+3*scale+1/8>=24 or p[2]-5*scale<-10 or p[2]+5*scale>=18:raise ValueError('Quantized motion segment leaves its domain')
                points.append((p,3*scale+1/8))
        box=[min(p[a]-r for p,r in points) for a in range(2)]+[max(p[a]+r for p,r in points) for a in range(2)]
        for other in envelopes:
            if not any(box[a+2]<other[a] or other[a+2]<box[a] for a in range(2)):raise ValueError('Motion XY envelopes intersect')
        envelopes.append(box)
    return copy.deepcopy(config)


def samples(config):
    """Compile absolute key and signed Q8 step columns; endpoints reload exactly."""
    rows=[];first=[]
    for clip in config['clips']:
        first.append(len(rows))
        for i,key in enumerate(clip['keys']):
            # Always compile the closing segment: the application can enable loop.
            nxt=clip['keys'][(i+1)%len(clip['keys'])]
            values=[round(key['position'][a]*256) for a in (0,2,1)]+[phase(key['yawDegrees']),round(key['scale']*16384)]
            next_values=[round(nxt['position'][a]*256) for a in (0,2,1)]+[phase(nxt['yawDegrees']),round(nxt['scale']*16384)]
            delta=[b-a for a,b in zip(values,next_values)];delta[3]=((delta[3]+32768)&65535)-32768
            rows.append(dict(values=values,steps=[rounded(v,64) for v in delta],visible=int(key['visible'])))
    return first,rows


def state_and_tables(config):
    clips=config['clips'];n=len(clips);first,rows=samples(config);out='an_source_begin:\n'
    out+=byte('an_first',first)+byte('an_count',[len(c['keys']) for c in clips])
    for field,index in [('x',0),('y',1),('z',2),('yaw',3),('scale',4)]:
        for kind in ('values','steps'):
            for j in range(2):out+=byte(f'an_{field}_{kind}{j}',[r[kind][index]>>(8*j) for r in rows])
    out+=byte('an_visible_values',[r['visible'] for r in rows])+'an_source_end:\n'
    out+='an_state_begin:\n'
    for name,values in [('frame',[0]*n),('elapsed',[0]*n),('playing',[int(c['playing']) for c in clips]),('speed',[c['speed'] for c in clips]),('loop',[int(c['loop']) for c in clips]),('ready',[0]*n),('completed',[0]*n),('scale_frac',[0]*n)]:out+=byte('an_'+name,values)
    for field in ('x','y','z','yaw','scale'):
        for j in range(2):out+=byte(f'an_step_{field}{j}',[0]*n)
    for name,value in [('index',0),('remaining',0),('opcode',0),('argument',0),('selected',0),('last_keys',0),('keys',0),('key_override',0)]:out+=byte('an_'+name,[value])
    return out+'an_state_end:\n'


def player(config):
    n=len(config['clips'])
    out=f'''an_tick:
 jsr an_poll
 lda #0
 sta an_index
an_instance_loop:
 ldx an_index
 lda an_ready,x
 bne +
 jsr an_load
+
 ldx an_index
 lda an_playing,x
 beq an_next_instance
 lda an_speed,x
 sta an_remaining
an_substep:
 jsr an_advance
 ldx an_index
 lda an_playing,x
 beq an_next_instance
 dec an_remaining
 bne an_substep
an_next_instance:
 inc an_index
 lda an_index
 cmp #{n}
 bcc an_instance_loop
 rts

; A opcode, X instance, Y argument. Carry success; main thread only.
an_control:
 cpx #{n}
 bcc +
 clc
 rts
+
 sta an_opcode
 sty an_argument
 cmp #8
 bcc +
 clc
 rts
+
 cmp #4
 bne +
 cpy #1
 beq an_speed_ok
 cpy #2
 beq an_speed_ok
 cpy #4
 beq an_speed_ok
 clc
 rts
an_speed_ok:
 tya
 sta an_speed,x
 sec
 rts
+
 cmp #5
 bne +
 cpy #2
 bcc an_loop_ok
 clc
 rts
an_loop_ok:
 tya
 sta an_loop,x
 bne an_loop_done
 lda an_frame,x
 clc
 adc #1
 cmp an_count,x
 bcc an_loop_done
 jsr an_load
an_loop_done:
 sec
 rts
+
 cmp #3
 bne +
 tya
 cmp an_count,x
 bcc an_seek_ok
 clc
 rts
an_seek_ok:
 sta an_frame,x
 jmp an_seek
+
 cmp #0
 bne +
 lda #0
 sta an_playing,x
 sec
 rts
+
 cmp #1
 bne +
 lda #1
 sta an_playing,x
 lda #0
 sta an_completed,x
 sec
 rts
+
 cmp #6
 bne an_reset
 lda #0
 sta an_playing,x
 inc an_frame,x
 lda an_frame,x
 cmp an_count,x
 bcc an_seek
 lda an_loop,x
 beq an_step_clamp
 lda #0
 sta an_frame,x
 beq an_seek
an_step_clamp:
 dec an_frame,x
 jmp an_seek
an_reset:
 lda #0
 sta an_frame,x
 sta an_playing,x
 lda an_opcode
 cmp #7
 bne an_seek
 lda #1
 sta an_playing,x
an_seek:
 lda #0
 sta an_completed,x
 jsr an_load
 sec
 rts

an_advance:
 ldx an_index
 lda an_frame,x
 clc
 adc #1
 cmp an_count,x
 bcc an_interpolate
 lda an_loop,x
 bne an_interpolate
 lda #0
 sta an_playing,x
 lda #1
 sta an_completed,x
 rts
an_interpolate:
'''
    for axis in 'xyz':
        out+=' clc\n'
        for j in range(2):out+=f' lda sm_position_{axis}{j},x\n adc an_step_{axis}{j},x\n sta sm_position_{axis}{j},x\n'
        out+=f' lda sm_position_{axis}1,x\n asl\n lda #0\n sbc #0\n eor #255\n sta sm_position_{axis}2,x\n'
    out+=' clc\n lda sm_yaw_lo,x\n adc an_step_yaw0,x\n sta sm_yaw_lo,x\n lda sm_yaw_hi,x\n adc an_step_yaw1,x\n sta sm_yaw_hi,x\n'
    out+=' clc\n lda an_scale_frac,x\n adc an_step_scale0,x\n sta an_scale_frac,x\n lda sm_scale_q6,x\n adc an_step_scale1,x\n sta sm_scale_q6,x\n'
    out+=''' inc an_elapsed,x
 lda an_elapsed,x
 cmp #64
 bcc an_advance_done
 inc an_frame,x
 lda an_frame,x
 cmp an_count,x
 bcc an_load
 lda #0
 sta an_frame,x
an_load:
 lda #0
 sta an_elapsed,x
 lda #1
 sta an_ready,x
 lda an_frame,x
 clc
 adc an_first,x
 tay
'''
    for field in ('x','y','z','yaw','scale'):
        for j in range(2):out+=f' lda an_{field}_steps{j},y\n sta an_step_{field}{j},x\n'
        if field in 'xyz':
            for j in range(2):out+=f' lda an_{field}_values{j},y\n sta sm_position_{field}{j},x\n'
            out+=f' lda sm_position_{field}1,x\n asl\n lda #0\n sbc #0\n eor #255\n sta sm_position_{field}2,x\n'
        elif field=='yaw':out+=' lda an_yaw_values0,y\n sta sm_yaw_lo,x\n lda an_yaw_values1,y\n sta sm_yaw_hi,x\n'
        else:out+=' lda an_scale_values0,y\n sta an_scale_frac,x\n lda an_scale_values1,y\n sta sm_scale_q6,x\n'
    out+=''' lda an_visible_values,y
 sta sm_visible,x
 lda an_loop,x
 bne an_advance_done
 lda an_frame,x
 clc
 adc #1
 cmp an_count,x
 bcc an_advance_done
 lda #0
 sta an_playing,x
 lda #1
 sta an_completed,x
an_advance_done:
 rts
'''
    return out


def keyboard(config):
    n=len(config['clips'])
    out='''an_poll:
 lda an_key_override
 bne +
 jsr explorer_scan_keys
+
 lda #0
 sta an_keys
'''
    # Edge-triggered controls, reusing the existing native CIA scanner.
    for bit,col,mask in [(1,7,16),(2,2,2),(4,2,64),(8,2,32)]:
        out+=f' lda explorer_key_col{col}\n and #{mask}\n bne +\n lda an_keys\n ora #{bit}\n sta an_keys\n+\n'
    for i,col,mask in [(0,7,1),(1,7,8),(2,1,1),(3,1,8)][:n]:
        out+=f' lda explorer_key_col{col}\n and #{mask}\n bne +\n lda #{i}\n sta an_selected\n+\n'
    out+=' lda an_last_keys\n eor #255\n and an_keys\n pha\n lda an_keys\n sta an_last_keys\n pla\n sta an_keys\n ldx an_selected\n'
    out+=''' and #1
 beq +
 lda an_playing,x
 eor #1
 ldy #0
 jsr an_control
+
 lda an_keys
 and #2
 beq +
 lda #7
 ldy #0
 jsr an_control
+
 lda an_keys
 and #4
 beq +
 lda #6
 ldy #0
 jsr an_control
+
 lda an_keys
 and #8
 beq +
 lda an_speed,x
 asl
 cmp #5
 bcc an_key_speed
 lda #1
an_key_speed:
 tay
 lda #4
 jsr an_control
+
 lda cr_mode
 beq an_keys_done
 lda explorer_key_col7
 and #64
 bne +
 sec
 lda cr_roll_lo
 sbc #128
 pha
 lda cr_roll_hi
 sbc #0
 tay
 pla
 jsr cr_set_roll
+
 lda explorer_key_col1
 and #64
 bne +
 clc
 lda cr_roll_lo
 adc #128
 pha
 lda cr_roll_hi
 adc #0
 tay
 pla
 jsr cr_set_roll
+
 lda explorer_key_col6
 and #8
 bne +
 lda #0
 tay
 jsr cr_set_roll
+
 lda explorer_key_col2
 and #16
 bne an_keys_done
 jsr cr_resume
an_keys_done:
 rts
'''
    return out


def cp(src,dst,n=3):return f' ldx #{n-1}\n-\n lda {src},x\n sta {dst},x\n dex\n bpl -\n'
def term(src,trig,dst):return cp(src,'qc_a')+cp(trig,'qc_b',2)+' jsr qc_product\n'+cp('qc_r',dst)
def combine(a,b,dst,subtract=False):
    return (' sec\n' if subtract else ' clc\n')+f' ldy #0\n ldx #3\n-\n lda {a},y\n '+('sbc' if subtract else 'adc')+f' {b},y\n sta {dst},y\n iny\n dex\n bne -\n'


def roll(config):
    out='''; A low, Y high full-turn phase. Dungeon accepts only zero.
cr_set_roll:
 ldx cr_mode
 bne cr_accept_roll
 cmp #0
 bne cr_reject_roll
 cpy #0
 bne cr_reject_roll
cr_accept_roll:
 sta cr_roll_lo
 sty cr_roll_hi
 lda #0
 sta cr_auto
 sec
 rts
cr_reject_roll:
 clc
 rts
cr_resume:
 lda cr_mode
 sta cr_auto
 rts
cr_tick:
 lda cr_mode
 bne +
 lda #0
 sta cr_roll_lo
 sta cr_roll_hi
 rts
+
 lda cr_auto
 bne +
 rts
+
 ; Derive bank directly from the camera key/subtick, so resume has no drift.
 ldx demo_key
 lda demo_subtick
 sta cr_steps
 lda cr_bank_lo,x
 sta cr_roll_lo
 lda cr_bank_hi,x
 sta cr_roll_hi
 lda cr_steps
 beq cr_tick_done
cr_bank_loop:
 clc
 lda cr_roll_lo
 adc cr_bank_step_lo,x
 sta cr_roll_lo
 lda cr_roll_hi
 adc cr_bank_step_hi,x
 sta cr_roll_hi
 dec cr_steps
 bne cr_bank_loop
cr_tick_done:
 rts
cr_prepare:
 lda #0
 sec
 sbc cr_roll_lo
 sta hp_fraction
 lda #0
 sbc cr_roll_hi
 tax
 jsr hp_sine
 lda hp_r
 sta cr_rs
 lda hp_r+1
 sta cr_rs+1
 ldx hp_sine_index
 txa
 clc
 adc #64
 tax
 jsr hp_sine
 lda hp_r
 sta cr_rc
 lda hp_r+1
 sta cr_rc+1
 rts
cr_rotate_point:
 lda cr_roll_lo
 ora cr_roll_hi
 bne +
 rts
+
'''
    out+=term('qc_x','cr_rc','qc_t0')+term('qc_y','cr_rs','qc_t1')+combine('qc_t0','qc_t1','qc_tx',True)
    out+=term('qc_x','cr_rs','qc_t0')+term('qc_y','cr_rc','qc_t1')+combine('qc_t0','qc_t1','qc_y')+cp('qc_tx','qc_x')+' rts\n'
    return out


def camera_data(config):
    bank=[phase(config['camera']['bankDegrees']*math.sin(i*math.tau/48)) for i in range(48)]
    steps=[rounded(((bank[(i+1)%48]-v+32768)&65535)-32768,64) for i,v in enumerate(bank)]
    out='cr_source_begin:\n'
    for name,values in [('bank',bank),('bank_step',steps)]:
        for j,suffix in enumerate(('lo','hi')):out+=byte(f'cr_{name}_{suffix}',[v>>(8*j) for v in values])
    out+='cr_source_end:\ncr_state_begin:\n'
    for name,value in [('mode',int(config['camera']['mode']=='flight')),('auto',1),('roll_lo',0),('roll_hi',0),('steps',0)]:out+=byte('cr_'+name,[value])
    return out+'cr_rs: .word 0\ncr_rc: .word 256\ncr_state_end:\n'


def adapt(source,parts,config):
    if not config['enabled']:return source,parts
    old='advance_sim_tick:\n jsr wr_tick\n jsr bb_tick\n jsr qc_demo_tick\n';assert source.count(old)==1
    source=source.replace(old,old+' jsr an_tick\n jsr cr_tick\n',1)
    owners=[k for k,v in parts.items() if 'qc_rotate_vertices:\n' in v];assert len(owners)==1
    key=owners[0];code=parts[key]
    old=' ora explorer_cam_pitch\n';assert code.count(old)==1
    code=code.replace(old,old+' ora cr_roll_lo\n ora cr_roll_hi\n',1)
    code=code.replace('qc_rotate_active:\n','qc_rotate_active:\n jsr cr_prepare\n',1);parts[key]=code
    owners=[k for k,v in parts.items() if 'qc_store:\n' in v];assert len(owners)==1
    key=owners[0];code=parts[key];assert code.count('qc_store:\n')==1
    parts[key]=code.replace('qc_store:\n','qc_store:\n jsr cr_rotate_point\n',1)
    parts['animation_player']=player(config)
    parts['animation_keys']=keyboard(config)
    parts['animation_data']=state_and_tables(config)
    parts['camera_roll']=roll(config)
    parts['camera_roll_data']=camera_data(config)
    return source,parts
