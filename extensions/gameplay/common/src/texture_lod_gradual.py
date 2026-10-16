"""Private screen-space detail fade and modal/accent far material, Gouraud C.
Required Notice:3Dvibe64. PolyForm Noncommercial1.0.0.
"""
import colorsys,json
from collections import Counter
from pathlib import Path
from optimizations import once
from reconstruct_base import rgb_palette

def apply(source,scene,options):
    near=options['fadeNear'];far=options['fadeFar'];step=options['sampleRowStep']
    assert type(near) is int and type(far) is int and 1<near<far<256 and far-near in (8,16)
    assert step in (1,2) and scene['world']['backgroundColor']==0
    rgb=rgb_palette(Path(__file__).resolve().parents[1])
    palettes=options['texturePalettes'];modal=[];accent=[];details=[]
    for t in scene['textures']:
        values=t['texels'];assert len(values)==256 and set(values)<=set((1,2,3))
        counts=Counter(values);m=min(counts,key=lambda p:(-counts[p],p));modal.append(m)
        if len(counts)==1:a=m
        else:
            colors=palettes[t['id']];assert len(colors)==3 and all(type(c) is int and 0<=c<16 for c in colors)
            def vivid(p):
                h,s,v=colorsys.rgb_to_hsv(*(c/255 for c in rgb[colors[p-1]]))
                return s,v,-p
            a=max(counts,key=vivid)
        accent.append(a);details.append(dict(texture=t['id'],counts=dict(counts),modal=m,accent=a))
    assert 'op_uniform_select:\n lda op_texture_constant,x\n' in source
    source=once(source,'op_uniform_select:\n lda op_texture_constant,x\n','op_uniform_select:\n jsr lg_select\n')
    source=once(source,' sta iu_sample_uniform+1\n',' jsr lg_bind_uniform\n')
    for label in ('ps_prepare_span','iu_prepare_uniform'):
        source=once(source,label+':\n',label+':\n jsr lg_phase\n')
    for i in range(4):
        source=once(source,f'fx{i}_composite_done:\n',f'fx{i}_composite_done:\n jsr lg_mix\n')
    source=once(source,' jsr m7_sample\n asl\n asl\n ora shadeidx\n',' jsr m7_sample\nlg_partial_mix:\n jsr lg_mix\n asl\n asl\n ora shadeidx\n')
    # Private additional call sites move inline metadata. Symbolic optional
    # state is moved as a group, never overlaid on the enlarged immutable data.
    for before,after in [('*=$b094\nop_state_begin:','*=$b0e0\nop_state_begin:'),
                         ('*=$b0a0\nop_code:','*=$b0ec\nop_code:'),
                         ('*=$b0b0\nop_uniform:','*=$b0f0\nop_uniform:'),
                         ('*=$b0c0\nop_axis:','*=$b0f4\nop_axis:'),
                         ('* > $b0a0,"Carrier4 state exceeds allocation"','* > $b0ec,"Carrier4 state exceeds allocation"'),
                         ('* > $b0b0,"Outcode state overflow"','* > $b0f0,"Outcode state overflow"'),
                         ('* > $b0c0,"Uniform state overflow"','* > $b100,"Uniform state overflow"')]:
        if not options.get('relocatable'):source=once(source,before,after)
    # Added inline calls grow lab_begin. 64tass silently allows positioned
    # overlap: move its 127-byte scaler out of the E700 reconstruction tables.
    if not options.get('relocatable'):
        source=once(source,'\nes_scale:\n','\n .cerror * > $e700,"Inline shader overlaps reconstruction tables"\n*=$8f80\nes_scale:\n')
        source=once(source,'es_done:\n rts\nes_q:', 'es_done:\n rts\n .cerror * > $9000,"Scaler exceeds audited scratch gap"\n*=$e8d7\nes_q:')
    blend_scale=' asl\n' if far-near==8 else '' # Preserve the 0..16 Bayer weight range over an8WU interval.
    hard=options.get('hardSwitch',False)
    classify=(f''' lda lg_min_depth
 cmp #{options.get('hardDistance',32)}
 bcc lg_original
''') if hard else f''' lda lg_min_depth
 cmp #{near}
 bcc lg_original
 beq lg_original
 cmp #{far}
 bcs lg_far_face
 sta lg_min_depth
 lda #{far}
 sec
 sbc lg_min_depth
{blend_scale} jsr lg_set_weight
 lda #0
 rts
'''
    code=f'''*=$fe60
lg_code_begin:
lg_select:
 stx lg_texture
 lda #16
 jsr lg_set_weight
 lda op_texture_constant,x
 bne lg_return
 stx lg_texture
 sty lg_face
 lda lg_modal_table,x
 sta lg_modal
 lda lg_accent_table,x
 sta lg_accent
 lda #255
 sta lg_min_depth
 lda #0
 sta lg_corner
lg_depth_loop:
 ldx lg_corner
 lda lg_face_offsets,x
 sta lg_vertex_load+1
 lda lg_face_offsets_hi,x
 sta lg_vertex_load+2
lg_vertex_load:
 lda face0,y
 tax
 lda hc_cam_z2,x
 bmi lg_original
 bne lg_next_vertex
 lda hc_cam_z1,x
 cmp lg_min_depth
 bcs lg_next_vertex
 sta lg_min_depth
lg_next_vertex:
 inc lg_corner
 lda lg_corner
 cmp face_vertex_count,y
 bcc lg_depth_loop
 ldx lg_texture
{classify}
lg_far_face:
 lda #0
 jsr lg_set_weight
 lda lg_modal
 rts
lg_original:
 ldx lg_texture
 lda #0
lg_return:
 rts
lg_set_weight:
 sta lg_weight
 cmp #0
 beq lg_mix_disabled
 cmp #16
 bcs lg_mix_disabled
 lda #$20
 bne lg_mix_opcode
lg_mix_disabled:
 lda #$2c
lg_mix_opcode:
 ; JSR -> BIT abs outside the blend band. A/X unchanged at sample sites,
 ; flags dead before following ASL; IRQ never enters shader or patches it.
 sta fx0_composite_done
 sta fx1_composite_done
 sta fx2_composite_done
 sta fx3_composite_done
 sta lg_partial_mix
 lda lg_weight
 rts
lg_bind_uniform:
 sta iu_sample_uniform+1
 lda lg_weight
 bne lg_bind_plain
 lda #<lg_far_sample
 ldx #>lg_far_sample
 bne lg_bind_store
lg_bind_plain:
 lda #<m3_composite
 ldx #>m3_composite
lg_bind_store:
 sta iu_sample_uniform+3
 stx iu_sample_uniform+4
 ldx lg_texture
 lda op_uniform
 rts
lg_phase:
 lda yrow
'''+(' lsr\n' if step==2 else '')+''' and #3
 asl
 asl
 sta lg_row
 rts
lg_mix:
 ldx lg_weight
 beq lg_mix_return
 cpx #16
 bcs lg_mix_return
 sta lg_saved_texel
 lda gouraud_scan_x
 and #3
 ora lg_row
 tay
 lda lg_bayer,y
 cmp lg_weight
 bcs lg_far_sample
 lda lg_saved_texel
lg_mix_return:
 rts
lg_far_sample:
 lda lg_row
 and #4
 bne lg_use_modal
 lda gouraud_scan_x
 and #1
 bne lg_use_modal
 lda lg_accent
 jmp m3_composite
lg_use_modal:
 lda lg_modal
 jmp m3_composite
lg_code_end:
 .cerror * > $fff0,"Gradual LOD code touches vectors"
 .cerror op_backface_end > lg_code_begin,"Gradual LOD code overlaps backface"
*=$e8b0
lg_state_begin:
lg_weight: .byte 16
lg_texture: .byte 0
lg_face: .byte 0
lg_corner: .byte 0
lg_min_depth: .byte 0
lg_modal: .byte 0
lg_accent: .byte 0
lg_row: .byte 0
lg_saved_texel: .byte 0
lg_modal_table: .byte '''+','.join(map(str,modal))+'''
lg_accent_table: .byte '''+','.join(map(str,accent))+'''
lg_face_offsets: .byte <face0,<face1,<face2,<face3
lg_face_offsets_hi: .byte >face0,>face1,>face2,>face3
lg_bayer: .byte 0,8,2,10,12,4,14,6,3,11,1,9,15,7,13,5
lg_state_end:
 .cerror * > $e8d7,"Gradual LOD state touches scaler state"
 .cerror lab_all_end > $e900,"Scaler state touches carrier helpers"
 .cerror op_rows_end > lg_state_begin,"Gradual LOD state overlaps row helpers"
 .cerror m2_lighting_data_end > op_state_begin,"Gradual LOD metadata overlap"
 .cerror FACE_COUNT != 64,"Requalify frozen two-room ABI"
 .cerror op_uniform+4 > $b100,"Optional state touches following code"
'''
    return source+code
