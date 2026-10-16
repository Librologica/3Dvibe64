"""Individually selectable Mode7 DEV transforms, exact unless marked otherwise.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
def once(source,old,new):
    assert source.count(old)==1,(old[:90],source.count(old));return source.replace(old,new)

def uv_setup(source):
    a=source.index('bk_setup_steps:\n');b=source.index(' dex\n bpl bk_setup_steps\n',a)
    return source[:a]+'''bk_setup_steps:
 sec
 lda bk_next,x
 sbc bk_cur1,x
 tay
 ; Preserve subtraction carry: sign byte is 00 for positive, FF for negative.
 lda #0
 sbc #0
 sta bk_delta+1
 tya
 asl
 asl
 asl
 asl
 asl
 asl
 sta bk_step0,x
 tya
 ; Insert sign directly into each logical shift. C from LSR sign is sign bit.
 lsr bk_delta+1
 ror
 lsr bk_delta+1
 ror
 sta bk_step1,x
'''+source[b:]

def carrier4(source,threshold=12):
    source=once(source,'bk_predict:\n','bk_predict_legacy:\n')
    marker=' sta ps_err+2\n rts\n; Exact signed17 delta'
    source=once(source,marker,' sta ps_err+2\n jsr op_setup4\n rts\n; Exact signed17 delta')
    helper=f'''*=$fb20
op_code_begin:
op_setup4:
 lda #0
 sta op_use4
 lda m7_den
 cmp #{threshold}
 bcc op_setup4_done
 lda #1
 sta op_use4
 ldx #2
op_setup4_channel:
 lda ps_step0,x
 sta op_step0,x
 lda ps_step1,x
 sta op_step1,x
 lda ps_rem,x
 sta op_rem,x
 ldy #2
op_setup4_double:
 asl op_step0,x
 rol op_step1,x
 lda op_rem,x
 asl
 bcs op_setup4_sub
 cmp m7_den
 bcc op_setup4_store
op_setup4_sub:
 ; For the carry case, subtraction modulo 256 restores the exact remainder.
 sec
 sbc m7_den
 inc op_step0,x
 bne op_setup4_store
 inc op_step1,x
op_setup4_store:
 sta op_rem,x
 dey
 bne op_setup4_double
 dex
 bpl op_setup4_channel
op_setup4_done:
 rts
bk_predict:
 lda op_use4
 bne op_predict4
 jmp bk_predict_legacy
op_predict4:
 clc
 lda ps_cur0,x
 adc op_step0,x
 sta bk_future
 lda ps_cur1,x
 adc op_step1,x
 sta bk_future+1
 clc
 lda ps_err,x
 adc op_rem,x
 bcs op_predict4_sub
 cmp m7_den
 bcc op_predict4_done
op_predict4_sub:
 sec
 sbc m7_den
 inc bk_future
 bne op_predict4_done
 inc bk_future+1
op_predict4_done:
 sta bk_delta
 rts
op_code_end:
 .cerror * > $fc20,"Carrier4 helper exceeds allocation"
*=$b094
op_state_begin:
op_step0: .fill 3,0
op_step1: .fill 3,0
op_rem: .fill 3,0
op_use4: .byte 0
op_state_end:
 .cerror * > $b0a0,"Carrier4 state exceeds allocation"
'''
    return source+helper

def apply(source,flags,scene=None):
    valid={'uvsetup','carrier4','outcodes','defer','uniform','rows','block8','duplicate','cache','backface','duplicate-write','adaptive','copies','portal','palette','cell-cache','portal-bytes'}
    assert set(flags)<=valid,('Unknown flags',set(flags)-valid)
    if 'uvsetup' in flags:source=uv_setup(source)
    if 'copies' in flags:source=copies(source)
    if 'carrier4' in flags:source=carrier4(source)
    if 'outcodes' in flags:source=outcodes(source)
    if 'defer' in flags:source=defer(source,scene)
    if 'uniform' in flags:source=uniform(source,scene)
    if 'rows' in flags:source=rows(source)
    if 'backface' in flags:source=backface(source,scene)
    if 'portal' in flags:source=portal(source,flags,scene)
    if 'portal-bytes' in flags:source=portal_bytes(source,flags)
    if 'palette' in flags:source=palette(source,flags)
    if 'cell-cache' in flags:source=cell_cache(source,flags)
    if 'block8' in flags:source=block8(source,flags)
    if 'adaptive' in flags:source=adaptive(source,flags)
    if 'duplicate' in flags:source=duplicate(source)
    if 'duplicate-write' in flags:source=duplicate_write(source)
    if 'cache' in flags:source=cache(source,flags)
    return source

def portal_bytes(source,flags):
    assert 'portal' in flags and 'uniform' in flags
    source=once(source,'op_portal_span:\n lda pc_remote\n','op_portal_span:\n lda #0\n sta po_active\n lda pc_remote\n')
    source=once(source,'po_remote:\n ldx yrow\n','po_remote:\n lda #1\n sta po_active\n ldx yrow\n')
    source=once(source,'m7_full_byte:\n jmp fx_full_byte\n','m7_full_byte:\n jmp po_byte\n')
    source=once(source,'m7_full_write:\n ldy #0\n sta (ptr0lo),y\n sta (ptr1lo),y\n','m7_full_write:\n ldy #0\n sta (ptr0lo),y\n sta (ptr1lo),y\nm7_full_after_write:\n')
    # Keep the ORIGINAL D, virtual-X and block phase. Do not re-anchor UV.
    # For fully occluded four-pixel bytes omit fetch/shader/write, while the
    # original sampler endpoints and Q/X advancement maintain live state.
    # Partial bytes and bytes intersecting the widened aperture use fallback.
    return source+'''*=$1f70
po_byte_begin:
po_byte:
 lda po_active
 beq po_draw_byte
 ldx yrow
 clc
 lda gouraud_scan_x
 adc #3
 cmp po_left,x
 bcc po_skip_byte
 lda po_right,x
 cmp gouraud_scan_x
 bcc po_skip_byte
po_draw_byte:
 jmp fx_full_byte
po_skip_byte:
 lda #3
 sta po_count
po_skip_pixel:
 lda op_uniform
 bne po_skip_advance
 jsr ps_sample
po_skip_advance:
 jsr m7_advance
 dec po_count
 bne po_skip_pixel
 lda op_uniform
 bne po_skip_last_done
 jsr ps_sample
po_skip_last_done:
 jmp m7_full_after_write
po_byte_end:
 .cerror * > $2000,"Portal byte skip overlaps bitmap"
*=$b0cb
po_active: .byte 0
po_count: .byte 0
'''

def cell_cache(source,flags):
    assert 'rc_fill:\n' in source and not set(flags)&{'adaptive','portal','cache','palette'}
    # Consecutive gap pairs share the destination VIC cell. Preserve lower
    # neighbour handling: only destination palette bytes are cached, not
    # predictor context or the lower row (which can belong to the next cell).
    source=once(source,' lda (rc_dest_screen_lo),y\n sta pf_dest_screen\n',' jsr dc_screen\n sta pf_dest_screen\n')
    source=once(source,' lda (rc_dest_color_lo),y\n and #15\n sta rc_dest_palette+3\n',' jsr dc_color\n and #15\n sta rc_dest_palette+3\n')
    return source+'''*=$fe60
dc_begin:
dc_screen:
 lda rc_gap
 and #1
 bne dc_screen_cached
 lda (rc_dest_screen_lo),y
 sta dc_screens,y
 rts
dc_screen_cached:
 lda dc_screens,y
 rts
dc_color:
 lda rc_gap
 and #1
 bne dc_color_cached
 lda (rc_dest_color_lo),y
 and #15
 sta dc_colors,y
 rts
dc_color_cached:
 lda dc_colors,y
 rts
dc_end:
 .cerror * > $fff0,"Cell cache code exceeds private helper"
*=$3f40
dc_screens: .fill 40,0
dc_colors: .fill 40,0
 .cerror * > $4000,"Cell palette cache exceeds nonvisible bitmap tail"
'''

def palette(source,flags):
    assert 'rc_neighbor_search:\n' in source,'Palette conversion applies only to contextual reconstruction'
    assert not any(f in flags for f in ('adaptive','portal','cache'))
    from pathlib import Path
    from reconstruct_base import rgb_palette,distance_table
    rgb=rgb_palette(Path(__file__).resolve().parents[1]);rank=distance_table(rgb)
    tables=[]
    for dark in (9,11):
        colors=[0,dark,12,15]
        tables.append([min(range(4),key=lambda j:rank[col*16+colors[j]]) for col in range(16)])
    source=once(source,'rc_neighbor_search:\n','rc_neighbor_search:\n jmp pp_search\npp_search_legacy:\n')
    return source+'''*=$fe60
pp_begin:
pp_search:
 sta pp_rgb
 lda rc_dest_palette
 bne pp_fallback
 lda rc_dest_palette+2
 cmp #12
 bne pp_fallback
 lda rc_dest_palette+3
 cmp #15
 bne pp_fallback
 ldx pp_rgb
 lda rc_dest_palette+1
 cmp #9
 beq pp_brown
 cmp #11
 bne pp_fallback
 lda pp_gray,x
 rts
pp_brown:
 lda pp_brown_map,x
 rts
pp_fallback:
 lda pp_rgb
 jmp pp_search_legacy
pp_end:
 .cerror * > $fff0,"Palette helper overlaps vectors"
*=$f780
pp_brown_map: .byte '''+','.join(map(str,tables[0]))+'''
pp_gray: .byte '''+','.join(map(str,tables[1]))+'''
 .cerror * > $f800,"Palette tables overlap output LUT"
*=$b0d0
pp_rgb: .byte 0
'''

def portal(source,flags,scene):
    assert not any(f in flags for f in ('backface','adaptive','cache')),'Portal envelope is an isolated layout experiment'
    assert [o['position'] for o in scene['objects']]==[[0,0,0],[0,48,0]]
    source=once(source,'pc_prepare_done:\n rts\n','pc_prepare_done:\n jmp op_portal_build\n')
    # Palette and dirty-span requests keep original order, including omitted
    # rows. Partial spans conservatively retain original sampling boundaries.
    source=once(source,' jsr m7_prepare_span\n jsr gouraud_draw_scan_span_bytes\n',' jsr op_portal_span\n bcc gfb_next_restore\n jsr m7_prepare_span\n jsr gouraud_draw_scan_span_bytes\n')
    return source+'''*=$fd60
op_portal_begin:
op_portal_span:
 lda pc_remote
 cmp #255
 beq po_keep
 cmp #1
 beq po_second
 lda sortj
 cmp #36
 bcs po_keep
 cmp #18
 bcc po_remote
 cmp #26
 bcc po_keep
 bcs po_remote
po_second:
 lda sortj
 cmp #36
 bcc po_keep
po_remote:
 ldx yrow
 lda rightval
 cmp po_left,x
 bcc po_skip
 lda po_right,x
 cmp leftval
 bcc po_skip
po_keep:
 sec
 rts
po_skip:
 clc
 rts
op_portal_build:
 lda pc_remote
 cmp #255
 beq po_done
 lda #0
 sta po_edge
 ldx #99
po_clear:
 lda #160
 sta po_left,x
 lda #0
 sta po_right,x
 dex
 bpl po_clear
po_edge_loop:
 lda pc_remote
 eor #1
 asl
 asl
 sta po_base
 ora po_edge
 tax
 ldy pc_vertices,x
 lda sx,y
 sta po_xa
 lda sy,y
 sta po_ya
 lda po_edge
 clc
 adc #1
 and #3
 ora po_base
 tax
 ldy pc_vertices,x
 lda sx,y
 sta po_xb
 lda sy,y
 sta po_yb
 cmp po_ya
 bcs po_ordered
 ldx po_ya
 sta po_ya
 stx po_yb
 lda po_xa
 ldx po_xb
 sta po_xb
 stx po_xa
po_ordered:
 sec
 lda po_yb
 sbc po_ya
 sta m7_den
 beq po_horizontal
 lda po_xa
 ldx po_xb
 jsr m7_dda_setup
 lda po_xa
 sta po_cur
 lda #0
 sta po_err
po_row:
 lda po_cur
 jsr po_add
 lda po_ya
 cmp po_yb
 beq po_edge_next
 clc
 lda po_cur
 adc m7_q
po_x_ready:
 sta po_cur
 clc
 lda po_err
 adc m7_r
 cmp m7_den
 bcc po_error_ready
 sec
 sbc m7_den
 pha
 lda po_cur
 clc
 adc m7_dir
 sta po_cur
 pla
po_error_ready:
 sta po_err
 inc po_ya
 jmp po_row
po_horizontal:
 lda po_xa
 jsr po_add
 lda po_xb
 jsr po_add
po_edge_next:
 inc po_edge
 lda po_edge
 cmp #4
 bne po_edge_loop
po_done:
 rts
po_add:
 pha
 sec
 sbc #5
 bcs po_left_ready
 lda #0
po_left_ready:
 sta po_min
 pla
 clc
 adc #5
 cmp #160
 bcc po_right_ready
 lda #159
po_right_ready:
 sta po_max
 lda po_ya
 sec
 sbc #3
 bcs po_y_ready
 lda #0
po_y_ready:
 tax
 clc
 lda po_ya
 adc #3
 cmp #100
 bcc po_yend_ready
 lda #99
po_yend_ready:
 sta po_end
po_add_row:
 lda po_min
 cmp po_left,x
 bcs po_max_row
 sta po_left,x
po_max_row:
 lda po_max
 cmp po_right,x
 bcc po_next_row
 sta po_right,x
po_next_row:
 cpx po_end
 beq po_added
 inx
 bne po_add_row
po_added:
 rts
op_portal_end:
 .cerror * > $fff0,"Portal code overlaps vectors"
*=$b0c0
po_edge: .byte 0
po_base: .byte 0
po_xa: .byte 0
po_xb: .byte 0
po_ya: .byte 0
po_yb: .byte 0
po_min: .byte 0
po_max: .byte 0
po_end: .byte 0
po_cur: .byte 0
po_err: .byte 0
*=$3f40
po_left: .fill 100,0
*=$7f40
po_right: .fill 100,159
'''

def copies(source):
    source=once(source,' lda bk_next\n sta m7_u\n lda bk_next+1\n sta m7_v\n jmp bk_start\n',''' ldx #1
bk_copy_next:
 lda bk_next,x
 sta bk_cur1,x
 lda #0
 sta bk_cur0,x
 dex
 bpl bk_copy_next
 jmp bk_predict_init
''')
    return once(source,' ldx #2\nbk_predict_channels:\n','bk_predict_init:\n ldx #2\nbk_predict_channels:\n')

def adaptive(source,flags):
    assert 'carrier4' in flags and 'uvsetup' in flags and 'block8' not in flags
    # Zero W derivative: no perspective curvature. Conservative 4 fallback
    # for every nonzero W delta, small denominator and short span. The original
    # endpoint byte-wrap policy is unchanged; classify its visible error.
    source=once(source,'op_setup4:\n lda #0\n','op_setup4:\n jsr ad_choose\n lda #0\n')
    source=once(source,' ldy #2\nop_setup4_double:\n',' ldy ad_shifts\nop_setup4_double:\n')
    source=once(source,' sbc gouraud_scan_x\n cmp #4\n bcs bk_long\n',' sbc gouraud_scan_x\nad_cmp:\n cmp #4\n bcs bk_long\n')
    source=once(source,' lda #4\n sta bk_count\n','ad_count:\n lda #4\n sta bk_count\n')
    source=once(source,'op_setup4_double:\n','op_setup4_double:\n')
    a=source.index('bk_setup_steps:\n');b=source.index(' dex\n bpl bk_setup_steps\n',a)
    s=source[a:b]
    s=s.replace(' asl\n sta bk_step0,x\n','ad_fraction_op:\n asl\n sta bk_step0,x\n')
    s=s.replace(' sta bk_step1,x\n','ad_third_shift:\n nop\n nop\n nop\n nop\n sta bk_step1,x\n')
    source=source[:a]+s+source[b:]
    return source+'''*=$fe60
ad_begin:
ad_choose:
 lda #2
 sta ad_shifts
 lda #4
 sta ad_cmp+1
 sta ad_count+1
 lda #$0a
 sta ad_fraction_op
 lda #$ea
 sta ad_third_shift
 sta ad_third_shift+1
 sta ad_third_shift+2
 sta ad_third_shift+3
 lda m7_den
 cmp #24
 bcc ad_done
 lda ps_step0+2
 ora ps_step1+2
 ora ps_rem+2
 bne ad_done
 lda ps_cur1+2
 beq ad_done
 lda #3
 sta ad_shifts
 lda #8
 sta ad_cmp+1
 sta ad_count+1
 lda #$ea
 sta ad_fraction_op
 lda #$4e
 sta ad_third_shift
 lda #<bk_delta+1
 sta ad_third_shift+1
 lda #>bk_delta+1
 sta ad_third_shift+2
 lda #$6a
 sta ad_third_shift+3
ad_done:
 rts
ad_end:
 .cerror * > $fff0,"Adaptive helper overlaps vectors"
*=$b0c2
ad_shifts: .byte 2
'''

def duplicate_write(source):
    assert 'rc_fill:\n' in source
    # All rendered rows have even logical Y. Original pointers target two
    # physical rows within a four-row group; Y=2 addresses the omitted pair.
    source=once(source,' jmp rc_fill\n',' rts\n')
    source=once(source,'m7_full_write:\n ldy #0\n sta (ptr0lo),y\n sta (ptr1lo),y\n','''m7_full_write:
 ldy #0
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #2
 sta (ptr0lo),y
 sta (ptr1lo),y
 ldy #0
''')
    source=once(source,' ora m7_packed\n sta (ptr0lo),y\n lda (ptr1lo),y\n',''' ora m7_packed
 sta (ptr0lo),y
 ldy #2
 sta (ptr0lo),y
 ldy #0
 lda (ptr1lo),y
''')
    source=once(source,' ora m7_packed\n sta (ptr1lo),y\n lda gouraud_scan_x\n',''' ora m7_packed
 sta (ptr1lo),y
 ldy #2
 sta (ptr1lo),y
 ldy #0
 lda gouraud_scan_x
''')
    # Additional write code moves inline legacy data past B094. Do NOT allow
    # the optional carrier scratch to overwrite texture-page/Bayer metadata.
    # This variant has no cache/portal state; relocated opt scratch fits B100.
    source=once(source,'*=$b094\nop_state_begin:\n','*=$b0e0\nop_state_begin:\n')
    source=once(source,' .cerror * > $b0a0,"Carrier4 state exceeds allocation"',' .cerror * > $b0ec,"Carrier4 state exceeds allocation"')
    source=once(source,'*=$b0a0\nop_code:','*=$b0ec\nop_code:')
    source=once(source,' .cerror * > $b0b0,"Outcode state overflow"',' .cerror * > $b0f0,"Outcode state overflow"')
    source=once(source,'*=$b0b0\nop_uniform:','*=$b0f0\nop_uniform:')
    source=once(source,' .cerror * > $b0c0,"Uniform state overflow"',' .cerror * > $b100,"Uniform state overflow"')
    source+='\n .cerror m2_lighting_data_end > $b0e0,"Inline data overlaps relocated optional scratch"\n'
    return source

def backface(source,scene):
    import re
    assert scene and all(o.get('rotation',[0,0,0])==[0,0,0] and o.get('angularVelocity',[0,0,0])==[0,0,0] and o.get('scale',1)==1 for o in scene['objects'][:3])
    assert scene['objects'][3]['mesh']=='central-cube'
    def table(name):
        body=source.split(name+':\n',1)[1].split('\n',1)[0]
        # Consecutive .byte lines, never infer coordinates from a texture index.
        body=re.match(r'(?: .byte [^\n]+\n?)+',source.split(name+':\n',1)[1])[0]
        return [int(v[1:],16) if v.startswith('$') else int(v) for v in body.replace(' .byte ','').replace('\n',',').split(',') if v]
    coordinates=[[v-256 if v>=128 else v for v in table(a+'coord')] for a in 'xyz']
    indices=[table('vert_'+a+'i') for a in 'xyz'];faces=[table('face'+str(i)) for i in range(3)]
    vertices=[];local=[]
    by_id={m['id']:m for m in scene['meshes']}
    for obj in scene['objects']:
        mesh=by_id[obj['mesh']];ox,oz,oy=obj['position']
        local.extend(tuple(p) for p in mesh['vertices'])
        vertices.extend((int(x+ox),int(y+oy),int(z+oz)) for x,y,z in mesh['vertices'])
    emitted=[tuple(coordinates[a][indices[a][i]] for a in range(3)) for i in range(len(indices[0]))]
    assert emitted==local,'Private mesh emission order changed'
    axes=[];planes=[]
    for face in zip(*faces):
        if min(face)>=75:axes.append(255);planes.append(0);continue  # rotating geometry never uses static plane culling
        p,q,r=[vertices[i] for i in face];u=[q[i]-p[i] for i in range(3)];v=[r[i]-p[i] for i in range(3)]
        n=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
        nonzero=[i for i in range(3) if n[i]]
        if len(nonzero)!=1:axes.append(255);planes.append(0);continue
        a=nonzero[0];assert all(point[a]==p[a] for point in (q,r))
        if not -126<=p[a]<=125:
            axes.append(255);planes.append(0);continue  # retain full Q8 culling outside compact plane domain
        axes.append(a|(128 if n[a]<0 else 0));planes.append((p[a]+128)&255)
    # Property-driven static plane culling also covers the central hard cube.
    # Non-axis-aligned faces retain the general clipped Q8 winding path.
    sphere_first=len(axes)
    # Test only during collection; uncertain/near-plane cases retain original.
    source=once(source,'load_face_visible:\n','load_face_visible:\n jsr op_backface\n bcc lfv_hidden\n')
    return source+f'''*=$fd60
op_backface_begin:
op_backface:
 ldy faceidx
 cpy #{sphere_first}
 bcs op_backface_keep
 lda op_face_axis,y
 cmp #255
 beq op_backface_keep
 sta op_axis
 and #3
 sta op_cam_axis
 asl
 clc
 adc op_cam_axis
 tax
 lda explorer_cam_x_ext,x
 beq op_backface_positive
 cmp #255
 bne op_backface_keep
 lda explorer_cam_x_hi,x
 bpl op_backface_keep
 jmp op_backface_compare
op_backface_positive:
 lda explorer_cam_x_hi,x
 bmi op_backface_keep
op_backface_compare:
 eor #128
 sta op_cam_axis
 lda op_axis
 bmi op_backface_negative
 lda op_face_plane,y
 sec
 sbc #2
 cmp op_cam_axis
 bcc op_backface_keep
 beq op_backface_keep
 clc
 rts
op_backface_negative:
 lda op_face_plane,y
 clc
 adc #2
 cmp op_cam_axis
 bcs op_backface_keep
 clc
 rts
op_backface_keep:
 sec
 rts
op_backface_end:
 .cerror * > $fde0,"Backface code overflow"
*=$fde0
op_face_axis: .byte '''+','.join(map(str,axes))+'''
op_face_plane: .byte '''+','.join(map(str,planes))+'''
 .cerror * > $fe60,"Backface table overflow"
 .cerror explorer_cam_y_hi-explorer_cam_x_hi != 3,"Camera high axis ABI"
 .cerror explorer_cam_z_hi-explorer_cam_x_hi != 6,"Camera high axis ABI"
 .cerror explorer_cam_y_ext-explorer_cam_x_ext != 3,"Camera extension axis ABI"
 .cerror explorer_cam_z_ext-explorer_cam_x_ext != 6,"Camera extension axis ABI"
*=$b0c0
op_axis: .byte 0
op_cam_axis: .byte 0
'''

def cache(source,flags):
    assert not any(f in flags for f in ('carrier4','outcodes','uniform','defer')),'Cache is an isolated alternative'
    fields=['hc_count','hc_changed','hc_source_count','loaded_face_vertex_count','clip_a_count','clip_poly_active','spanw','spanh','p1lo','p1hi','sortj']
    fields += ['hc_face_vertices+'+str(j) for j in range(4)]
    for axis in ('x','y'):
        fields += [f'v{axis}{j}' for j in range(4)]
        fields += [f'v{axis}q2_{j}{part}' for j in range(4) for part in ('lo','hi')]
    fields += [f'hc_a_{name}+{j}' for name in ('xlo','xhi','xext','ylo','yhi','yext','slo','shi','vlo','vhi','qlo','qhi','wlo','whi') for j in range(4)]
    fields += [f'clip_a_{name}+{j}' for name in ('x','y','shade') for j in range(4)]
    assert len(fields)<=192
    source=once(source,'load_face_y:\n','cc_uncached:\n')
    source=once(source,'begin_depth_buckets:\n jsr clear_depth_buckets\n','begin_depth_buckets:\n jsr cc_reset\n')
    source=once(source,'draw_depth_buckets:\n lda bucket_min\n','draw_depth_buckets:\n jsr cc_draw_begin\n lda bucket_min\n')
    # Main middle code is densely placed: reclaim unconditional dead metadata
    # path not used by this Mode7 specialized renderer to fit the 3-byte hook.
    source=once(source,' jmp ddb_face_loop\n .fill 2,$ea\n',' jmp ddb_face_loop\n .fill 2,$ea\n') if ' jmp ddb_face_loop\n .fill 2,$ea\n' in source else source
    return source+f'''*=$fb20
cc_begin:
cc_reset:
 lda #0
 sta cc_used
 sta cc_drawing
 lda #255
 sta cc_ids
 sta cc_ids+1
 jmp clear_depth_buckets
cc_draw_begin:
 lda #1
 sta cc_drawing
 rts
load_face_y:
 sty sortj
 sty cc_face
 lda cc_drawing
 beq cc_miss
 tya
 ldx #1
cc_find:
 cmp cc_ids,x
 beq cc_hit
 dex
 bpl cc_find
cc_miss:
 ldy cc_face
 jsr cc_uncached
 bcc cc_return
 lda cc_drawing
 bne cc_success
 lda hc_count
 cmp #5
 bcs cc_success
 ldx cc_used
 cpx #2
 bcs cc_success
 lda cc_face
 sta cc_ids,x
 inc cc_used
 jsr cc_pointer
 ldx #0
cc_save:
 jsr cc_field_pointer
 ldy #0
 lda (prodlo),y
 stx cc_offset
 ldy cc_offset
 sta (ptr1lo),y
 inx
 cpx #{len(fields)}
 bne cc_save
cc_success:
 sec
cc_return:
 rts
cc_hit:
 jsr cc_pointer
 ldx #0
cc_load:
 jsr cc_field_pointer
 txa
 tay
 lda (ptr1lo),y
 ldy #0
 sta (prodlo),y
 inx
 cpx #{len(fields)}
 bne cc_load
 sec
 rts
cc_pointer:
 lda cc_buffer_hi,x
 sta ptr1hi
 lda #$40
 sta ptr1lo
 rts
cc_field_pointer:
 lda cc_field_lo,x
 sta prodlo
 lda cc_field_hi,x
 sta prodhi
 rts
cc_buffer_hi: .byte $3f,$7f
cc_field_lo: .byte '''+','.join('<('+n+')' for n in fields)+'''
cc_field_hi: .byte '''+','.join('>('+n+')' for n in fields)+'''
cc_end:
 .cerror * > $fff0,"Cache code/table overlaps vectors"
*=$b0c0
cc_used: .byte 0
cc_drawing: .byte 0
cc_ids: .fill 2,255
cc_face: .byte 0
cc_offset: .byte 0
*=$3f40
cc_slot0: .fill 192,0
*=$7f40
cc_slot1: .fill 192,0
'''

def block8(source,flags):
    assert 'carrier4' in flags,'Block8 requires precomputed carriers'
    source=once(source,' sbc gouraud_scan_x\n cmp #4\n bcs bk_long\n',' sbc gouraud_scan_x\n cmp #8\n bcs bk_long\n')
    source=once(source,' lda #4\n sta bk_count\n',' lda #8\n sta bk_count\n')
    source=once(source,' cmp #12\n bcc op_setup4_done\n',' cmp #8\n bcc op_setup4_done\n')
    source=once(source,' ldy #2\nop_setup4_double:\n',' ldy #3\nop_setup4_double:\n')
    a=source.index('bk_setup_steps:\n');b=source.index(' dex\n bpl bk_setup_steps\n',a)
    s=source[a:b]
    assert s.count(' asl\n')==6
    s=s.replace(' asl\n','',1)
    s=s.replace(' sta bk_step1,x\n',' lsr bk_delta+1\n ror\n sta bk_step1,x\n')
    return source[:a]+s+source[b:]

def duplicate(source):
    assert 'rc_fill:\n' in source,'Duplicate is an interpolated-only variant'
    a=source.index('rc_fill:\n');b=source.index('rc_gap_start:\n',a)
    # Both destination physical lines share the exact palette cell with upper
    # retained logical row, proven by construction for all 50 rows.
    body='''rc_fill:
 lda #0
 sta rc_gap
 sta rc_bitmap_mask
 lda drawbuf
 beq dp_gap
 lda #$40
 sta rc_bitmap_mask
dp_gap:
 ldx rc_gap
 lda rc_above_lo,x
 sta ptr0lo
 lda rc_above_hi,x
 eor rc_bitmap_mask
 sta ptr0hi
 lda rc_dest0_lo,x
 sta row0lo
 lda rc_dest0_hi,x
 eor rc_bitmap_mask
 sta row0hi
 lda rc_dest1_lo,x
 sta row1lo
 lda rc_dest1_hi,x
 eor rc_bitmap_mask
 sta row1hi
 ldy #0
dp_byte:
 lda (ptr0lo),y
 sta (row0lo),y
 sta (row1lo),y
 tya
 clc
 adc #8
 tay
 bcc dp_byte
 ; The 40-cell row spans two pages; only first8cells are on second page.
 inc ptr0hi
 inc row0hi
 inc row1hi
 ldy #0
dp_page2:
 lda (ptr0lo),y
 sta (row0lo),y
 sta (row1lo),y
 tya
 clc
 adc #8
 tay
 cpy #64
 bne dp_page2
 inc rc_gap
 lda rc_gap
 cmp #50
 bne dp_gap
 rts
'''
    # The pointer includes row's scanline offset 0/2/4/6. Starting Y=0 and
    # indexing 0,8,..248 then next page0..56 visits exactly40 bitmap bytes.
    return source[:a]+body+source[b:]

def rows(source):
    source=once(source,'draw_clip_poly_gouraud:\n lda #0\n sta face_ymin\n lda #PROJ_SCREEN_MAX_Y\n sta face_ymax\n ldx #PROJ_SCREEN_MAX_Y\n','draw_clip_poly_gouraud:\n jsr op_row_bounds\n ldx face_ymax\n')
    source=once(source,' sta tq_closed,x\n dex\n bpl tq_clear\n',' sta tq_closed,x\n cpx face_ymin\n beq op_clear_done\n dex\n jmp tq_clear\nop_clear_done:\n')
    return source+'''*=$5b70
op_rows_begin:
op_row_bounds:
 lda #PROJ_SCREEN_MAX_Y
 sta face_ymin
 lda #0
 sta face_ymax
 ldx #0
op_row_vertex:
 clc
 lda hc_a_ylo,x
 adc #3
 sta tq_work
 lda hc_a_yhi,x
 adc #0
 lsr
 ror tq_work
 lsr
 ror tq_work
 lda tq_work
 cmp #PROJ_SCREEN_MAX_Y+1
 bcc op_row_clamped
 lda #PROJ_SCREEN_MAX_Y
op_row_clamped:
 cmp face_ymin
 bcs op_row_max
 sta face_ymin
op_row_max:
 cmp face_ymax
 bcc op_row_next
 sta face_ymax
op_row_next:
 inx
 cpx hc_count
 bne op_row_vertex
 rts
op_rows_end:
 .cerror * > $5c00,"Row helper overlaps Screen RAM B"
'''

def defer(source,scene):
    assert scene and scene['graphicsMode']==7
    assert all(o.get('rotation',[0,0,0])==[0,0,0] and o.get('angularVelocity',[0,0,0])==[0,0,0] and o.get('scale',1)==1 for o in scene['objects'][:3])
    assert scene['objects'][3]['mesh']=='central-cube'
    a=source.index('lfv_bucket:\n');b=source.index(' jmp bucket_visible_face\n',a)
    fragment=source[a:b]
    assert ' jsr load_face_y\n' in fragment and ' jsr face_conservative_sliver\n' in fragment
    # Bucket visibility/depth classification before this section is unchanged.
    # All complete face/sliver preparation is already repeated during drawing.
    start=fragment.index('.if SCENE_OBJECT_COUNT != 0\n ldy faceidx\n sty sortj\n')
    fragment=fragment[:start]+''' ; DEV static-room deferred preparation. Original bucket keys/insertion order.
 ; Drawing still performs exact near/screen/winding/sliver before palette claims.
'''
    return source[:a]+fragment+source[b:]

def uniform(source,scene):
    assert scene and scene['graphicsMode']==7
    constants=[]
    if 'tq_setup_channel:\n jmp es_setup_channel\n' in source:
        dead=source.index('tq_setup_channel:\n jmp es_setup_channel\n')
        end=source.index('tq_product:\n',dead)
        assert 'tq_setup_channel+' not in source
        source=source[:dead]+'tq_setup_channel:\n jmp es_setup_channel\n'+source[end:]
    for texture in scene['textures']:
        values=texture.get('texels',[])
        assert len(values)==256 and set(values)<=set((1,2,3))
        constants.append(values[0] if len(set(values))==1 else 0)
    source=once(source,' cpx #2\n beq iu_select_uniform\n',' jsr op_uniform_select\n bne iu_select_uniform\n')
    source=once(source,'hc_append_a:\n jsr ps_encode\n','hc_append_a:\n jsr op_uniform_encode\n')
    source=once(source,' jsr hc_interpolate_w\n jsr hc_interpolate_s\n jsr hc_interpolate_v\n jsr hc_interpolate_q\n',' jsr op_uniform_interpolate\n nop\n nop\n nop\n nop\n nop\n nop\n jsr hc_interpolate_q\n')
    a=source.index(' ldx hc_to\n ldy hc_from\n lda #0\n sta hc_delta\n',source.index('hc_near_intersection:\n'))
    b=source.index(' ldx hc_to\n ldy hc_from\n lda #0\n sta hc_delta\n',a+3)
    c=source.index(' ldx hc_to\n ldy hc_from\n lda #0\n sta hc_delta\n',b+3)
    near=source[a:c]
    source=source[:a]+' jsr op_uniform_near\n'+source[c:]
    marker=' lda #1\n sta tq_ch\n ldx tq_from\n ldy tq_to\n'
    source=once(source,marker,' lda op_uniform\n bne op_edge_only_q\n'+marker)
    source=once(source,' lda #4\n sta tq_ch\n ldx tq_from\n ldy tq_to\n','op_edge_only_q:\n lda #4\n sta tq_ch\n ldx tq_from\n ldy tq_to\n')
    source=once(source,'tq_advance_done:\n inx\n','tq_advance_done:\n jsr op_next_channel\n')
    # Even-row attribute helpers still advance geometry and Q exactly.
    for name in ('we_prime','we_double_next','we_advance_attributes'):
        marker=(' jsr we_advance_one\n inx\n cpx #5\n bne '+name+'\n') if name!='we_double_next' else 'we_double_next:\n inx\n cpx #5\n bne we_double\n'
        if marker in source:source=once(source,marker,marker.replace(' inx\n',' jsr op_next_channel\n'))
    table=','.join(map(str,constants))
    return source+'''*=$fca0
op_uniform_begin:
op_uniform_select:
 lda op_texture_constant,x
 sta op_uniform
 beq op_uniform_selected
 sta iu_sample_uniform+1
op_uniform_selected:
 rts
op_uniform_encode:
 lda op_uniform
 bne op_uniform_depth
 jmp ps_encode
op_uniform_depth:
 lda hc_depth+2
 bne op_uniform_far
 lda hc_depth+1
 beq op_uniform_fault
 rts
op_uniform_far:
 cmp #1
 bne op_uniform_fault
 lda hc_depth
 ora hc_depth+1
 bne op_uniform_fault
 rts
op_uniform_fault:
 inc ps_fault
 rts
op_uniform_interpolate:
 lda op_uniform
 bne op_uniform_return
 jsr hc_interpolate_w
 jsr hc_interpolate_s
 jmp hc_interpolate_v
op_uniform_return:
 rts
op_next_channel:
 inx
 cpx #1
 bne op_next_done
 lda op_uniform
 beq op_next_done
 ldx #4
op_next_done:
 rts
op_uniform_near:
 lda op_uniform
 bne op_uniform_return
'''+near+''' rts
op_uniform_end:
 .cerror * > $fe40,"Uniform helper overflow"
*=$b0b0
op_uniform: .byte 0
op_texture_constant: .byte '''+table+'''
 .cerror * > $b0c0,"Uniform state overflow"
'''

def outcodes(source):
    source=once(source,' lda #0\n sta hc_plane\nhc_screen_plane:\n',' jsr op_screen_codes\n bcc hc_face_empty\n beq hc_screen_finish\n lda #0\n sta hc_plane\nhc_screen_plane:\n')
    source=once(source,' jsr hq_quantize_poly\n jsr hc_commit_poly\n','hc_screen_finish:\n jsr hq_quantize_poly\n jsr hc_commit_poly\n')
    return source+'''*=$fc20
op_outcodes_begin:
op_screen_codes:
 lda #0
 sta op_codes_or
 lda #15
 sta op_codes_and
 ldx #0
op_codes_vertex:
 lda #0
 sta op_code
 lda hc_a_xext,x
 bmi op_code_left
 bne op_code_right
 lda hc_a_xhi,x
 cmp #PROJ_SCREEN_MAX_X
 bcc op_code_y
 bne op_code_right
 lda hc_a_xlo,x
 beq op_code_y
op_code_right:
 lda #2
 bne op_code_x_store
op_code_left:
 lda #1
op_code_x_store:
 sta op_code
op_code_y:
 lda hc_a_yext,x
 bmi op_code_top
 bne op_code_bottom
 lda hc_a_yhi,x
 cmp #PROJ_SCREEN_MAX_Y
 bcc op_code_combine
 bne op_code_bottom
 lda hc_a_ylo,x
 beq op_code_combine
op_code_bottom:
 lda #8
 bne op_code_y_store
op_code_top:
 lda #4
op_code_y_store:
 ora op_code
 sta op_code
op_code_combine:
 lda op_code
 ora op_codes_or
 sta op_codes_or
 lda op_code
 and op_codes_and
 sta op_codes_and
 inx
 cpx hc_count
 bne op_codes_vertex
 lda op_codes_and
 bne op_codes_reject
 sec
 lda op_codes_or
 rts
op_codes_reject:
 clc
 lda #1
 rts
op_outcodes_end:
 .cerror * > $fca0,"Outcode code overflow"
*=$b0a0
op_code: .byte 0
op_codes_or: .byte 0
op_codes_and: .byte 0
 .cerror * > $b0b0,"Outcode state overflow"
'''
