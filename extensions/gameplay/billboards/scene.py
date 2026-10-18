"""Experimental single-billboard scene compiler, separated from demo settings.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import json,math,re
from pathlib import Path


def number(v,low,high):
    if type(v) not in (int,float) or not math.isfinite(v) or not low<=v<=high or round(v*256)!=v*256:
        raise ValueError('Expected finite Q8 value in range '+str((low,high)))
    return v


def validate(config,asset):
    if set(config)!={'schema','billboards','entity'} or type(config['schema']) is not int or config['schema']!=1:
        raise ValueError('Gameplay scene schema1 required')
    if not isinstance(config['billboards'],list) or len(config['billboards'])!=1:
        raise ValueError('This adapter supports exactly one billboard; use multiple-billboards for BB-03')
    b=config['billboards'][0]
    if set(b)!={'id','asset','position','size','animations'} or not isinstance(b['id'],str) or not b['id']:
        raise ValueError('Invalid billboard descriptor')
    if len(b['position'])!=3 or len(b['size'])!=2:raise ValueError('Invalid billboard dimensions')
    x,y,z=[number(v,-20,20) for v in b['position']]
    w,h=[number(v,1,20) for v in b['size']]
    if any(round(v*128)!=v*128 for v in (w,h)):raise ValueError('World half sizes must be exactly representable in Q8')
    if w>10 or z-h/2 < -10.5 or z+h/2>18:raise ValueError('Billboard outside bounded room/size budget')
    if asset.get('width')!=16 or asset.get('height')!=32 or asset.get('transparentIndex')!=0 or asset.get('opaqueBlackIndex')!=4:
        raise ValueError('Asset requires16x32, transparent0 and opaque black4')
    frames=asset.get('frames')
    if not isinstance(frames,list) or not 1<=len(frames)<=6:raise ValueError('Asset requires1..6 frames')
    if any(not isinstance(f,list) or len(f)!=512 or any(type(p) is not int or not 0<=p<=4 for p in f) for f in frames):
        raise ValueError('Invalid frame pixels')
    if set(b['animations'])!={'idle','used'}:raise ValueError('Configure idle and used animations')
    for a in b['animations'].values():
        if set(a)!={'frames','ticksPerFrame'} or type(a['ticksPerFrame']) is not int or not 1<=a['ticksPerFrame']<=255:
            raise ValueError('Invalid animation timing')
        if not isinstance(a['frames'],list) or not 1<=len(a['frames'])<=16 or any(type(f) is not int or not 0<=f<len(frames) for f in a['frames']):
            raise ValueError('Invalid animation frame reference')
    e=config['entity']
    if set(e)!={'billboard','enabled','useRange','collisionHalfSize','demoUseKeys'} or e['billboard']!=b['id'] or type(e['enabled']) is not bool:
        raise ValueError('Invalid entity binding')
    number(e['useRange'],1,24)
    if len(e['collisionHalfSize'])!=2:raise ValueError('Expected XY collision half size')
    for v in e['collisionHalfSize']:number(v,.25,10)
    if not isinstance(e['demoUseKeys'],list) or any(type(k) is not int or not 0<=k<48 for k in e['demoUseKeys']):
        raise ValueError('Invalid demonstration event keys')
    return config


def load(path):
    path=Path(path).resolve();config=json.loads(path.read_text(encoding='utf-8-sig'))
    if not isinstance(config.get('billboards'),list) or len(config['billboards'])!=1:raise ValueError('Exactly one billboard required')
    asset_path=(path.parent/config['billboards'][0]['asset']).resolve(strict=True)
    if not asset_path.is_relative_to(path.parent):raise ValueError('Asset must be inside scene directory')
    asset=json.loads(asset_path.read_text(encoding='utf-8-sig'))
    return validate(config,asset),asset


def vector(axis,value,target):
    q=round(value*256)
    return ''.join(f' lda #{(q>>(i*8))&255}\n sta {target}_{axis}'+(f'+{i}' if i else '')+'\n' for i in range(3))


def bind(code,config):
    b=config['billboards'][0]
    # Bind after the historical comparison adapter; no source text edits are
    # needed when a scene changes. Runtime24-bit origins and corner offsets.
    for axis,v in zip('xyz',(b['position'][0],b['position'][2],b['position'][1])):
        pattern=''.join(r' lda #\d+\n sta qc_'+axis+re.escape('' if i==0 else '+'+str(i))+r'\n' for i in range(3))
        code,n=re.subn(pattern,lambda _:vector(axis,v,'qc'),code,count=1)
        if n!=1:raise ValueError('Billboard origin ABI changed: '+axis)
    a=code.index(' lda #0\n sta bb_alert\n');end=code.index('bb_frame_ready:\n',a)
    code=code[:a]+' jsr bc_choose_frame\n'+code[end:]
    pattern=r' clc\n((?: lda hc_coord\+\d\n adc #\d+\n sta hc_coord\+\d\n){3})(?= lda #[01]\n sta hc_axis)'
    matches=list(re.finditer(pattern,code))
    if len(matches)!=4:raise ValueError('Billboard projection ABI changed')
    offsets=(-b['size'][0]/2,b['size'][0]/2,b['size'][1]/2,-b['size'][1]/2)
    for match,delta in reversed(list(zip(matches,offsets))):
        q=round(delta*256)
        block=''.join(f' lda hc_coord+{i}\n adc #{(q>>(i*8))&255}\n sta hc_coord+{i}\n' for i in range(3))
        code=code[:match.start(1)]+block+code[match.end(1):]
    code=code.replace('bb_tick:\n inc bb_phase\n rts\n','bb_tick:\n inc bb_phase\n jmp bc_tick\n',1)
    return code


def animation(config):
    b=config['billboards'][0];idle=b['animations']['idle'];used=b['animations']['used']
    code='''bc_tick:
 lda bc_state
 cmp bc_previous
 beq bc_same
 sta bc_previous
 lda #0
 sta bc_cursor
 sta bc_hold
 rts
bc_same:
 tax
 inc bc_hold
 lda bc_hold
 cmp bc_ticks,x
 bcc bc_done
 lda #0
 sta bc_hold
 inc bc_cursor
 lda bc_cursor
 cmp bc_lengths,x
 bcc bc_done
 lda #0
 sta bc_cursor
bc_done:
 rts
bc_choose_frame:
 lda bc_state
 sta bb_alert
 tax
 lda bc_offsets,x
 clc
 adc bc_cursor
 tax
 lda bc_frames,x
 rts
bc_state: .byte 0
bc_previous: .byte 0
bc_cursor: .byte 0
bc_hold: .byte 0
'''
    for name,values in [('ticks',[idle['ticksPerFrame'],used['ticksPerFrame']]),('lengths',[len(idle['frames']),len(used['frames'])]),('offsets',[0,len(idle['frames'])]),('frames',idle['frames']+used['frames'])]:
        code+='bc_'+name+': .byte '+','.join(map(str,values))+'\n'
    return code
