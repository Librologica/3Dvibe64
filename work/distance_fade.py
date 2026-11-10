"""Optional screen-door distance fading. No code is emitted when disabled.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import argparse,json,math,re
from pathlib import Path
BAYER=((0,8,2,10),(12,4,14,6),(3,11,1,9),(15,7,13,5))

def config(spec=None,mode=None,start=None,end=None):
    spec=spec or {};value=spec.get('distanceFade',{})
    if not isinstance(value,dict) or set(value)-{'mode','start','end'}:raise ValueError('DISTANCE_FADE: object with mode/start/end required')
    override_off=mode=='off'
    mode=mode if mode is not None else value.get('mode','off')
    explicit=start is not None or end is not None or (not override_off and ('start' in value or 'end' in value))
    start=start if start is not None else value.get('start',64)
    end=end if end is not None else value.get('end',96)
    if mode not in ('off','dither'):raise ValueError('DISTANCE_FADE: off or dither')
    if type(start)is not int or type(end)is not int or not 0<=start<end<=32767:raise ValueError('DISTANCE_FADE: integer 0 <= start < end <= 32767')
    if mode=='off' and explicit:raise ValueError('DISTANCE_FADE: distances require dither')
    return dict(mode=mode,start=start,end=end,levels=16,default='off')

def masks():
    return [sum((3<<(6-2*x)) for x in range(4) if BAYER[y][x]<level) for level in range(17) for y in range(4)]

def axis_code(axis):
    # Extend both operands before subtracting: opposite signed24 endpoints do not wrap.
    z=axis=='z';code=' ldx objidx\n'
    for prefix,name,ext in [('o','object_pos_'+axis,('ext' if z else 'hi')),('c','explorer_cam_'+axis,'ext')]:
        if prefix=='c':
            code+='.if CAMERA_MOVABLE != 0\n'
        if prefix=='o':
            code+='.if SCENE_OBJECT_COUNT != 0\n'
            code+=f' lda {name}_{ext},x\n'
        else:code+=f' lda {name}_ext\n'
        code+=f' cmp #128\n lda #0\n bcc df_{prefix}_{axis}_sign\n lda #255\ndf_{prefix}_{axis}_sign:\n sta df_{prefix}+3\n'
        for j,suffix in enumerate(['lo','hi','ext']):
            if prefix=='o' and suffix=='ext' and not z:code+=' lda df_o+3\n'
            else:code+=f' lda {name}_{suffix}'+(',x' if prefix=='o' else '')+'\n'
            code+=f' sta df_{prefix}+{j}\n'
        code+='.else\n lda #0\n'+''.join(f' sta df_{prefix}+{j}\n' for j in range(4))+'.endif\n'
    code+=' sec\n'
    for j in range(4):code+=f' lda df_o+{j}\n sbc df_c+{j}\n sta df_o+{j}\n'
    code+=f' lda df_o+3\n bpl df_{axis}_positive\n sec\n'
    for j in range(4):code+=f' lda #0\n sbc df_o+{j}\n sta df_o+{j}\n'
    code+=f'df_{axis}_positive:\n lda df_o+3\n bne df_far\n lda df_o+1\n sta df_factor\n sta df_shift\n lda df_o+2\n sta df_factor+1\n sta df_shift+1\n jsr df_square_add\n'
    return code

def classifier(c):
    code='df_classify:\n lda #0\n sta df_level\n ldx #4\ndf_sum_clear:\n sta df_sum,x\n dex\n bpl df_sum_clear\n'
    for a in 'xyz':code+=axis_code(a)
    code+=' lda df_sum+4\n bne df_far\n ldx #0\ndf_threshold:\n'
    # 17 thresholds, descending. Full at <=start, zero at >=end; integer origin metric.
    for j in range(3,-1,-1):
        code+=f' lda df_sum+{j}\n cmp df_threshold_{j},x\n bcc df_nearer\n bne df_match\n'
    code+='df_match:\n txa\n sta df_level\n rts\ndf_nearer:\n inx\n cpx #17\n bne df_threshold\n lda #16\n sta df_level\ndf_far:\n rts\n'
    code+='df_square_add:\n lda #0\n sta df_shift+2\n sta df_shift+3\n ldx #16\ndf_square_loop:\n lsr df_factor+1\n ror df_factor\n bcc df_square_next\n clc\n'
    for j in range(4):code+=f' lda df_sum+{j}\n adc df_shift+{j}\n sta df_sum+{j}\n'
    code+=' lda df_sum+4\n adc #0\n sta df_sum+4\ndf_square_next:\n asl df_shift\n rol df_shift+1\n rol df_shift+2\n rol df_shift+3\n dex\n bne df_square_loop\n rts\n'
    return code

def store(pointer,compact=False):
    n='df_store_'+pointer
    code=f"""{n}:
 jmp {n}_full
{n}_partial:
 php
 pha
 lda {pointer}+1
 cmp #$60
 bcc {n}_bank_b
 cmp #$80
 bcc {n}_bitmap
{n}_bank_b:
 cmp #>BITMAP_B_BASE
 bcc {n}_plain
 cmp #>(BITMAP_B_BASE+$2000)
 bcs {n}_plain
{n}_bitmap:
 lda df_level
 beq {n}_skip
 stx df_saved_x
 tya
 clc
 adc {pointer}
 and #7
 lsr
{n}_base:
 ora #0
 tax
 pla
 sta df_value
 eor ({pointer}),y
{n}_mask:
 and df_masks-4,x
 eor ({pointer}),y
 sta ({pointer}),y
 lda df_value
 ldx df_saved_x
 plp
 rts
{n}_plain:
 pla
 plp
{n}_full:
 sta ({pointer}),y
 rts
{n}_skip:
 pla
 plp
 rts
"""
    if compact:
        code=code.replace(f'{n}:\n jmp {n}_full\n{n}_partial:\n php\n pha\n',f'{n}:\n php\n pha\n lda df_level\n cmp #16\n beq {n}_plain\n')
    return code

def select_level(compact=False):
    if compact:return "df_set_level:\n sta df_level\n php\n pha\n asl\n asl\n sta df_store_ptr0lo_base+1\n sta df_store_ptr1lo_base+1\n pla\n plp\n rts\n"
    code="""df_set_level:
 ; Exact STA contract; cached dispatch/mask operands are private foreground state.
 sta df_level
 php
 pha
 cmp #16
 beq df_select_full
 asl
 asl
"""
    for p in ['ptr0lo','ptr1lo']:code+=f' sta df_store_{p}_base+1\n'
    for p in ['ptr0lo','ptr1lo']:
        code+=f' lda #<df_store_{p}_partial\n sta df_store_{p}+1\n lda #>df_store_{p}_partial\n sta df_store_{p}+2\n'
    code+=' jmp df_set_level_restore\ndf_select_full:\n'
    for p in ['ptr0lo','ptr1lo']:
        code+=f' lda #<df_store_{p}_full\n sta df_store_{p}+1\n lda #>df_store_{p}_full\n sta df_store_{p}+2\n'
    code+='df_set_level_restore:\n pla\ndf_set_level_done:\n plp\n rts\n'
    return code

def adapt(source,parts,c):
    if c['mode']=='off':return source,parts
    parts=dict(parts)
    compact=bool(re.search(r'(?m)^GRAPHICS_MODE\s*=\s*(?:\$0?7|7)\s*$',source))
    source=source.replace('render_frame_begin:\n','render_frame_begin:\n jsr df_reset\n').replace('render_frame_end:\n','render_frame_end:\n jsr df_reset\n')
    source=source.replace(' jsr render_world_ground_wire_mask_finalize\n',' jsr df_reset\n jsr render_world_ground_wire_mask_finalize\n')
    source=source.replace(' jsr vic_color_policy_overlay_conflicts\n',' jsr df_reset\n jsr vic_color_policy_overlay_conflicts\n')
    source=source.replace('set_active_object:\n','df_original_set_active_object:\n',1)
    code="""df_reset:
 php
 pha
 lda #16
 sta df_level
 pla
 plp
 rts
set_active_object:
 jsr df_original_set_active_object
 php
 pha
 txa
 pha
 tya
 pha
 jsr df_classify
 ldx objidx
 lda df_level
 sta df_object_levels,x
 lda objidx
 ldx active_face_first
df_owner_loop:
 cpx active_face_end
 beq df_owner_done
 sta df_face_owners,x
 inx
 bne df_owner_loop
df_owner_done:
 pla
 tay
 pla
 tax
 pla
 plp
 rts
df_face_level:
 php
 pha
 txa
 pha
.if SCENE_OBJECT_COUNT != 0
.if MESH_SOURCE_SHARING_RUNTIME != 0
 ldx objidx
.else
 lda df_face_owners,y
 tax
.endif
 lda df_object_levels,x
 sta df_level
.endif
 pla
 tax
 pla
 plp
 rts
"""
    # The owner is reselected for sorted faces and prepared-face fast paths.
    for call in ['load_face_y','gouraud_load_face_raw_shades_y','engine_mode3_load_prepared_face_y']:
        source=source.replace(' jsr '+call+'\n',' jsr df_face_level\n jsr '+call+'\n')
    # Cheap object rejection before matrix, vertex transform/projection and face collection.
    loops={'resp_loop':'resp_next_object','resp_wire_loop':'resp_wire_next_object','rso_loop':'rso_next_object','rso_wire_loop':'rso_wire_next_object','dwso_loop':'dwso_next_object','dhpso_loop':'dhpso_next_object','dwoss_scan_loop':'dwoss_next_candidate','draw_wire_sorted_active_object':'dwso_sorted_done'}
    for first,last in loops.items():
        pos=source.find(first+':\n')
        if pos<0:continue
        anchor=source.find(' jsr set_active_object\n',pos)
        if anchor<0 or anchor>source.find(last+':\n',pos):continue
        anchor+=len(' jsr set_active_object\n');source=source[:anchor]+f' lda df_level\n beq {last}\n'+source[anchor:]
    # Only bitmap writes are masked; color/metadata pointer uses pass unchanged.
    # The helper performs the original store and preserves A, X, Y and flags.
    pointers=['ptr0lo','ptr1lo']
    def patch(s):
        for p in pointers:s=s.replace(f' sta ({p}),y\n',f' jsr df_store_{p}\n')
        return s.replace(' jsr df_store_ptr0lo\n jsr df_store_ptr1lo\n',' jsr df_store_pair\n')
    source=patch(source);parts={n:patch(s) for n,s in parts.items()}
    parts['distance_control']=code
    # Split independent arithmetic/axis chunks to retain the existing bounded allocator.
    cls=classifier(c);square=cls[cls.index('df_square_add:'):]
    classify=cls[:cls.index(' ldx objidx\n')]
    classify=classify.replace(' sta df_level\n',' sta df_level\n sta df_overflow\n',1)
    classify+=' jsr df_vectors\n lda df_overflow\n bne df_far\n'+cls[cls.index(' lda df_sum+4\n',cls.index(' ldx objidx\n')):cls.index('df_square_add:')]
    vectors="""df_vectors:
 lda #0
 sta df_vector_i
df_vector_axis:
 lda #0
 sta df_byte
df_vector_field:
 ldx df_vector_i
 lda df_obj_fields,x
 sta df_fetch+1
 lda df_obj_fields+1,x
 sta df_fetch+2
 ldy objidx
 jsr df_fetch
 ldx df_byte
 sta df_o,x
 ldx df_vector_i
 lda df_cam_fields,x
 sta df_fetch+1
 lda df_cam_fields+1,x
 sta df_fetch+2
 ldy #0
 jsr df_fetch
 ldx df_byte
 sta df_c,x
 inc df_vector_i
 inc df_vector_i
 inc df_byte
 lda df_byte
 cmp #3
 bne df_vector_field
 lda df_vector_i
 cmp #18
 beq df_vector_sign
 lda df_o+1
 cmp #128
 lda #0
 bcc df_vector_xy_positive
 lda #255
df_vector_xy_positive:
 sta df_o+2
df_vector_sign:
 lda df_o+2
 cmp #128
 lda #0
 bcc df_object_positive
 lda #255
df_object_positive:
 sta df_o+3
 lda df_c+2
 cmp #128
 lda #0
 bcc df_camera_positive
 lda #255
df_camera_positive:
 sta df_c+3
 sec
"""
    for j in range(4):vectors+=f' lda df_o+{j}\n sbc df_c+{j}\n sta df_o+{j}\n'
    vectors+=' lda df_o+3\n bpl df_vector_positive\n sec\n'
    for j in range(4):vectors+=f' lda #0\n sbc df_o+{j}\n sta df_o+{j}\n'
    vectors+="""df_vector_positive:
 lda df_o+3
 bne df_vectors_overflow
 lda df_o+1
 sta df_factor
 sta df_shift
 lda df_o+2
 sta df_factor+1
 sta df_shift+1
 jsr df_square_add
 lda df_vector_i
 cmp #18
 bne df_vector_axis
 rts
df_vectors_overflow:
 lda #1
 sta df_overflow
 rts
df_fetch:
 lda $ffff,y
 rts
"""
    # Any single integer absolute axis >=end implies d2>=end2. This is
    # exactly the original zero-level condition, including Q8 signed fractions.
    bound=f' lda df_o+2\n cmp #{c["end"]>>8}\n bcc df_vector_in_range\n bne df_vectors_overflow\n lda df_o+1\n cmp #{c["end"]&255}\n bcs df_vectors_overflow\ndf_vector_in_range:\n'
    vectors=vectors.replace(' lda df_o+1\n sta df_factor\n',bound+' lda df_o+1\n sta df_factor\n',1)
    # All accepted factors fit this compile-time bit width. Keep the full
    # 40-bit accumulator and original nonwrapping signed subtraction.
    square=square.replace(' ldx #16\ndf_square_loop:',f' ldx #{max(1,(c["end"]-1).bit_length())}\ndf_square_loop:')
    # Explicit wire edge ranges are not polygon face-owner ranges.
    owner_guard=''
    if re.search(r'(?m)^WIRE_MESH_COUNT\s*=',source):
        owner_guard='.if WIRE_MESH_COUNT != 0\n ldx meshidx\n lda mesh_is_wire,x\n bne df_owner_done\n.endif\n'
    code=code.replace(' lda objidx\n ldx active_face_first\n','.if FACE_COUNT != 0\n'+owner_guard+' lda objidx\n ldx active_face_first\n')
    code=code.replace('df_owner_done:\n','.endif\ndf_owner_done:\n')
    parts['distance_vectors']=vectors
    parts['distance_math']=square+classify
    parts['distance_control']=code
    parts['distance_stores']=''.join(store(p,compact) for p in pointers)+'df_store_pair:\n jsr df_store_ptr0lo\n jmp df_store_ptr1lo\n'
    parts['distance_math']+=parts.pop('distance_control')
    parts['distance_math']+=parts.pop('distance_vectors')
    source=source.replace(' sta df_level\n',' jsr df_set_level\n')
    parts={name:text.replace(' sta df_level\n',' jsr df_set_level\n') for name,text in parts.items()}
    parts['distance_math']+=select_level(compact)
    values=[math.ceil((c['end']-(c['end']-c['start'])*k/16))**2 for k in range(17)]
    data='df_level: .byte 16\ndf_overflow: .byte 0\ndf_row: .byte 0\ndf_saved_x: .byte 0\ndf_value: .byte 0\n'
    for n,count in [('sum',5),('o',4),('c',4),('factor',2),('shift',4)]:data+=f'df_{n}: .fill {count},0\n'
    data+='df_face_owners: .fill (FACE_COUNT+1),0\ndf_object_levels: .fill (SCENE_OBJECT_COUNT+1),16\ndf_masks: .byte '+','.join(map(str,masks()[4:64]))+'\n'
    for j in range(4):
        vals=[v>>(8*j)&255 for v in values]
        if not any(vals):parts['distance_math']=parts['distance_math'].replace(f' cmp df_threshold_{j},x\n',' cmp #0\n')
        else:data+=f'df_threshold_{j}: .byte '+','.join(map(str,vals))+'\n'
    data+='df_vector_i: .byte 0\ndf_byte: .byte 0\n'
    fields=[f'object_pos_{axis}_{part}' for axis in 'xyz' for part in ('lo','hi','ext' if axis=='z' else 'hi')]
    data+='.if CAMERA_MOVABLE = 0 || SCENE_OBJECT_COUNT = 0\ndf_camera_zero: .byte 0\n.endif\n.if SCENE_OBJECT_COUNT != 0\ndf_obj_fields: .word '+','.join(fields)+'\n.else\ndf_obj_fields: .word '+','.join(['df_camera_zero']*9)+'\n.endif\n'
    fields=[f'explorer_cam_{axis}_{part}' for axis in 'xyz' for part in ('lo','hi','ext')]
    data+='.if CAMERA_MOVABLE != 0\ndf_cam_fields: .word '+','.join(fields)+'\n.else\ndf_cam_fields: .word '+','.join(['df_camera_zero']*9)+'\n.endif\n'
    if 'data' in parts:parts['data']+=data
    else:parts['distance_data']=data
    source+=f'\nDISTANCE_FADE_ENABLE = 1\nDISTANCE_FADE_START = {c["start"]}\nDISTANCE_FADE_END = {c["end"]}\n'
    return source,parts
