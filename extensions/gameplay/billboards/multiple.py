"""BB-03: two screen-aligned instances, shared source/cache, exact Q8 order.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
The bounded divider contract is enforced at compilation, not inferred at draw.
"""
import copy
import json
import math
import re
from pathlib import Path
import billboard_scene as single


def validate(config, asset):
    if not isinstance(config, dict) or set(config) not in ({'schema', 'billboards', 'entity'}, {'schema', 'billboards', 'entity', 'visibleBillboards'}) or type(config['schema']) is not int or config['schema'] != 2:
        raise ValueError('Multiple billboard scene requires schema2')
    bs = config['billboards']
    if not isinstance(bs, list) or not 1 <= len(bs) <= 2:
        raise ValueError('This checkpoint supports one or two billboards')
    ids = []
    for b in bs:
        e = copy.deepcopy(config['entity'])
        if not isinstance(b, dict): raise ValueError('Invalid billboard descriptor')
        e['billboard'] = b.get('id')
        single.validate(dict(schema=1, billboards=[b], entity=e), asset)
        if b['id'] in ids: raise ValueError('Billboard ids must be unique')
        ids.append(b['id'])
        if b['asset'] != bs[0]['asset']: raise ValueError('Two instances must share one source asset within the under-I/O budget')
        x, y, z = b['position']; w, h = b['size']
        reach = w/2 + h/2 * math.sin(math.radians(14))
        if abs(x)+reach >= 24 or y+reach >= 8 or y-reach <= -24:
            raise ValueError('Billboard must remain inside outer shell and wholly in front of divider for pitch within14degrees')
    if config['entity']['billboard'] != ids[0] or not config['entity']['enabled']:
        raise ValueError('First billboard must be the enabled guardian entity')
    visible=config.get('visibleBillboards',ids)
    if not isinstance(visible,list) or any(not isinstance(v,str) or v not in ids for v in visible) or len(visible)!=len(set(visible)):
        raise ValueError('Visible billboard ids must be unique configured instances')
    return config


def load(path):
    path = Path(path).resolve(); config = json.loads(path.read_text(encoding='utf-8-sig'))
    if not isinstance(config.get('billboards'), list) or not 1 <= len(config['billboards']) <= 2:
        raise ValueError('One or two billboards required')
    asset_path = (path.parent/config['billboards'][0]['asset']).resolve(strict=True)
    if not asset_path.is_relative_to(path.parent): raise ValueError('Asset must be inside scene directory')
    asset = json.loads(asset_path.read_text(encoding='utf-8-sig'))
    return validate(config, asset), asset


FIELDS = [('left',2),('right',2),('top',2),('bottom',2),('width',1),('height',1),('frame',1)]


def data(label, values):
    return label+': .byte '+','.join(str(v & 255) for v in values)+'\n'


def adapt(source, parts, config):
    """Keep all old profiles byte-identical: this adapter exists only in dev5."""
    bs = config['billboards']; pair = bs if len(bs)==2 else bs*2
    code = parts['billboard']
    code = code.replace('bb_collect:\n', 'bb_project_instance:\n', 1)
    for axis, public_axis in [('x',0),('y',2),('z',1)]:
        pattern = ''.join(r' lda #\d+\n sta qc_'+axis+re.escape('' if i==0 else '+'+str(i))+r'\n' for i in range(3))
        replacement = ' ldx mb_index\n'+''.join(f' lda mb_origin_{axis}{i},x\n sta qc_{axis}'+('' if i==0 else '+'+str(i))+'\n' for i in range(3))
        code,n = re.subn(pattern, lambda _:replacement, code, count=1)
        if n != 1: raise ValueError('Multiple origin ABI changed')
    code = code.replace(' jsr bc_choose_frame\n',' jsr mb_choose_frame\n',1)
    code = code.replace(' cmp #8\n bcc bb_reject\n',' cmp #4\n bcc bb_reject\n',1)
    pattern = r' clc\n((?: lda hc_coord\+\d\n adc #\d+\n sta hc_coord\+\d\n){3})(?= lda #[01]\n sta hc_axis)'
    matches = list(re.finditer(pattern,code))
    if len(matches)!=4: raise ValueError('Multiple projection ABI changed')
    for j,match in reversed(list(enumerate(matches))):
        replacement = ' ldx mb_index\n clc\n'+''.join(f' lda hc_coord+{i}\n adc mb_offset_{j}{i},x\n sta hc_coord+{i}\n' for i in range(3))
        code = code[:match.start()]+replacement+code[match.end():]
    old = ' jsr bb_decode\n lda bb_depth\n lsr\n lsr\n sta p1lo\n jmp bvf_depth_ready\nbb_reject:\n rts\n'
    new = ' sec\n rts\nbb_reject:\n clc\n rts\n'
    if code.count(old)!=1: raise ValueError('Multiple collection ABI changed')
    code = code.replace(old,new)
    code = code.replace(' inc bb_phase\n jmp bc_tick\n',' inc bb_phase\n jsr bc_tick\n jmp sc_tick\n',1)
    parts['billboard']=code
    second = dict(schema=1,billboards=[pair[1]],entity=config['entity'])
    parts['second_animation'] = single.animation(second).replace('bc_','sc_')
    kernel = '''mb_choose_frame:
 lda mb_index
 beq +
 jmp sc_choose_frame
+
 jmp bc_choose_frame
mb_prepare:
 lda #0
 sta mb_index
mb_prepare_loop:
 jsr bb_project_instance
 ldx mb_index
 lda #0
 rol
 sta mb_visible,x
 lda mb_enable
 and mb_bits,x
 bne +
 lda #0
 sta mb_visible,x
+
 lda qc_z
 sta mb_zlo,x
 lda qc_z+1
 sta mb_zhi,x
'''
    for name, size in FIELDS:
        for byte in range(size):
            suffix = '' if byte==0 else '+'+str(byte)
            kernel += f' lda bb_{name}{suffix}\n sta mb_{name}{byte},x\n'
    kernel += ''' inc mb_index
 lda mb_index
 cmp #2
 bcc mb_prepare_loop
 lda #0
 sta mb_rank
 lda #1
 sta mb_rank+1
 ; Planes are parallel to the view, so full center Q8 depth orders every texel.
 lda mb_zhi+1
 cmp mb_zhi
 bcc mb_first_far
 bne mb_order_done
 lda mb_zlo+1
 cmp mb_zlo
 bcs mb_order_done
mb_first_far:
 lda #1
 sta mb_rank
 lda #0
 sta mb_rank+1
mb_order_done:
 rts
mb_collect_second:
 ldx #1
 bne mb_collect
bb_collect:
 ldx #0
mb_collect:
 lda mb_visible,x
 beq mb_hidden
 lda mb_rank,x
 sta p1lo
 jmp bvf_depth_ready
mb_hidden:
 clc
 rts
mb_draw_second:
 lda #1
 bne mb_draw
mb_draw_first:
 lda #0
mb_draw:
 sta mb_index
 tax
'''
    for name,size in FIELDS:
        for byte in range(size):
            suffix = '' if byte==0 else '+'+str(byte)
            kernel += f' lda mb_{name}{byte},x\n sta bb_{name}{suffix}\n'
    kernel += ' jsr bb_decode\n jmp bb_draw\n'
    # Separate small allocations fit the already qualified fragmented RAM map.
    parts['multiple_runtime'] = kernel
    visible=config.get('visibleBillboards',[b['id'] for b in bs])
    mask=sum(1<<i for i,b in enumerate(bs) if b['id'] in visible)
    state = 'mb_index: .byte 0\n'+data('mb_enable',[mask])+data('mb_bits',[1,2])
    for label in ('visible','rank','zlo','zhi'):state+=data('mb_'+label,[0,0])
    for name,size in FIELDS:
        for byte in range(size):state+=data(f'mb_{name}{byte}',[0,0])
    for axis,public_axis in [('x',0),('y',2),('z',1)]:
        for i in range(3):state+=data(f'mb_origin_{axis}{i}',[round(b['position'][public_axis]*256)>>(8*i) for b in pair])
    for j in range(4):
        for i in range(3):
            state+=data(f'mb_offset_{j}{i}',[round(((-1 if j in (0,3) else 1)*b['size'][0 if j<2 else 1]/2)*256)>>(8*i) for b in pair])
    parts['multiple_state']=state
    old = ' jsr hc_project_vertices\n'
    if parts['core'].count(old)!=1: raise ValueError('Multiple per-view hook ABI changed')
    parts['core']=parts['core'].replace(old,old+' jsr mb_prepare\n')
    source=source.replace(' jmp wr_collect\n',' jmp mb_collect_second\n',1)
    source=source.replace(' jsr wr_draw\n',' jsr mb_draw_second\n',1)
    source=source.replace(' jsr bb_draw\n',' jsr mb_draw_first\n',1)
    return source,parts
