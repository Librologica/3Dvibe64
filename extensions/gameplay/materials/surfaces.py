"""Experimental per-face texture/flat/Gouraud dispatch on the shared Q8 raster.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
No new transforms, clipper, visibility test, palette allocation or depth order.
"""
import re

MODES = {'texture': 0, 'flat': 1, 'gouraud': 2}


def compile_surfaces(scene, config):
    """Resolve one descriptor per source face, in the generator's mesh order.

    Texture inherits the precise Mode7 shader and LOD. Flat index is a VIC
    palette slot (1..3), constant over the face. Gouraud levels are explicit
    corner intensities (0..32), screen-linearly interpolated after clipping.
    This configuration is separate from the stable scene schema.
    """
    if not isinstance(config, dict) or set(config) != {'schema', 'meshes'} or type(config['schema']) is not int or config['schema'] != 1:
        raise ValueError('Surface configuration requires schema1 and meshes')
    meshes = config['meshes']
    if not isinstance(meshes, dict) or set(meshes) != {m['id'] for m in scene['meshes']}:
        raise ValueError('Configure every source mesh exactly once')
    result = []
    for mesh in scene['meshes']:
        entries = meshes[mesh['id']]
        if not isinstance(entries, list) or len(entries) != len(mesh['faces']):
            raise ValueError('Expected one surface descriptor per source face: '+mesh['id'])
        for face, entry in zip(mesh['faces'], entries):
            if not isinstance(entry, dict) or type(entry.get('mode')) is not str or entry['mode'] not in MODES:
                raise ValueError('Unknown surface mode')
            mode = entry['mode']
            expected = {'mode'} | ({'index'} if mode == 'flat' else {'levels'} if mode == 'gouraud' else set())
            if set(entry) != expected: raise ValueError('Unexpected surface fields: '+str(entry))
            index = entry.get('index', 2)
            if type(index) is not int or not 1 <= index <= 3: raise ValueError('Flat index must be1..3')
            levels = entry.get('levels', [16]*len(face))
            if not isinstance(levels, list) or len(levels) != len(face) or len(face) != 3:
                raise ValueError('Experimental surface dispatch requires triangulated faces')
            if any(type(v) is not int or not 0 <= v <= 32 for v in levels):
                raise ValueError('Gouraud levels must be integers0..32')
            result.append(dict(mode=mode, index=index, levels=levels.copy()))
    if not 1 <= len(result) <= 254: raise ValueError('Surface table requires1..254 faces')
    return result



def attribute_masks(table, *, gouraud_channel='q'):
    """Explicit shader contract for Q8 live-attributes adapters, not a shader.

    q: ordinary MAT-01 screen-linear Gouraud. s-w: adapter-defined unlit
    perspective scalar carrier. Flat shaders must not read any UV/Q channel.
    """
    if gouraud_channel not in ('q','s-w'):raise ValueError('Choose q or s-w Gouraud carrier')
    modes={'texture':31 if gouraud_channel=='q' else 15,'flat':1,
           'gouraud':17 if gouraud_channel=='q' else 11}
    return [modes[e['mode']] for e in table]

def bake(source, table):
    # The bounded profile has already retired dynamic lighting. Use the
    # existing Q channel all the way through near/screen clipping and edges.
    import torus_runtime as arrays
    for corner in range(3):
        _, values = arrays.array(source, 'gouraud_face_shade'+str(corner))
        if len(values) != len(table): raise ValueError('Generated/source face order mismatch')
        source = arrays.put(source, 'gouraud_face_shade'+str(corner), [e['levels'][corner] for e in table])
    return source


def hooks(source, table, *, optimize_flat=False):
    import optimizations as op
    # Select once per clipped polygon/fan. The existing fill loop owns the
    # coverage rule, row addresses, dirty spans and material-cell policy.
    source = op.once(source, 'gouraud_fill_bounds:\n', '''gouraud_fill_bounds:
 ldy sortj
 lda mx_face_mode,y
 sta mx_mode
 lda mx_face_index,y
 sta mx_flat
''')
    source = op.once(source, ' jsr m7_prepare_span\n jsr gouraud_draw_scan_span_bytes\n', ' jsr mx_draw_span\n')
    # Copy the stable Q DDA under a distinct label: the textured shader may
    # self-patch m3_advance_q to RTS for its neutral plateau.
    advance = source[source.index('m3_advance_q:\n'):source.index('m3_advance_q_end = *')]
    advance = re.sub(r'\bm3_(advance_q|q_correct|q_store)\b', lambda m: 'mx_'+m[1], advance)
    modes = ','.join(str(MODES[e['mode']]) for e in table)
    indexes = ','.join(str(e['index']) for e in table)
    kernel=KERNEL
    if optimize_flat:
        kernel=kernel.replace('mx_draw_span:\n','mx_draw_span:\n lda mx_mode\n cmp #1\n bne mx_full_dispatch\n jmp fc_draw\nmx_full_dispatch:\n',1)
        kernel+=FLAT_KERNEL
    return source + '\n*=$4000\n' + kernel + advance + f'''
mx_mode: .byte 0
mx_flat: .byte 2
mx_face_mode: .byte {modes}
mx_face_index: .byte {indexes}
'''


KERNEL = '''; Untextured spans skip texture addressing, UV division and LOD.
mx_draw_span:
 lda mx_mode
 bne mx_untextured
 jsr m7_prepare_span
 jmp gouraud_draw_scan_span_bytes
mx_untextured:
 sec
 lda rightval
 sbc leftval
 sta m7_den
 ldy yrow
 lda m3_leftq,y
 sta m3_qcur
 ldx m3_rightq,y
 jsr m7_dda_setup
 lda m7_q
 sta m3_qstep
 lda m7_r
 sta m3_qrem
 lda m7_dir
 sta m3_qdir
 lda #0
 sta m3_qerr
 lda yrow
 and #3
 asl
 asl
 sta m2_bayer_row
 lda leftval
 sta gouraud_scan_x
 lda rightval
 sta gouraud_scan_end
 ldx yrow
 lda tq_closed,x
 bne mx_closed
 dec gouraud_scan_end
mx_closed:
 jsr gouraud_init_span_pointers
mx_byte:
 lda #0
 sta m7_packed
 lda #255
 sta maskv
mx_pixel:
 lda gouraud_scan_x
 and #3
 sta shadeidx
 lda mx_mode
 cmp #1
 bne mx_lit_pixel
 lda mx_flat
 jmp mx_pack
mx_lit_pixel:
 ; Thirty-three monotonic levels between the three shared palette slots.
 lda m3_qcur
 cmp #16
 bcc mx_dark
 sec
 sbc #16
 ldx #2
 bne mx_dither
mx_dark:
 ldx #1
mx_dither:
 sta m3_threshold
 lda shadeidx
 ora m2_bayer_row
 tay
 lda m2_bayer,y
 cmp m3_threshold
 bcs mx_level_ready
 inx
mx_level_ready:
 txa
mx_pack:
 asl
 asl
 ora shadeidx
 tay
 lda m7_pair,y
 ora m7_packed
 sta m7_packed
 ldx shadeidx
 lda gouraud_pair_clear,x
 and maskv
 sta maskv
 cpx #3
 beq mx_write
 lda gouraud_scan_x
 cmp gouraud_scan_end
 beq mx_write
 jsr mx_advance
 jmp mx_pixel
mx_write:
 ldy #0
 lda (ptr0lo),y
 and maskv
 ora m7_packed
 sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora m7_packed
 sta (ptr1lo),y
 lda gouraud_scan_x
 cmp gouraud_scan_end
 beq mx_done
 jsr mx_advance
 clc
 lda ptr0lo
 adc #8
 sta ptr0lo
 bcc mx_ptr0
 inc ptr0hi
mx_ptr0:
 clc
 lda ptr1lo
 adc #8
 sta ptr1lo
 bcc mx_ptr1
 inc ptr1hi
mx_ptr1:
 jmp mx_byte
mx_done:
 rts
mx_advance:
 jsr mx_advance_q
 inc gouraud_scan_x
 rts
'''


FLAT_KERNEL = r'''fc_draw:
 ldx mx_flat
 lda fc_patterns,x
 sta fc_fill
 lda leftval
 sta gouraud_scan_x
 lda rightval
 sta gouraud_scan_end
 ldx yrow
 lda tq_closed,x
 bne +
 dec gouraud_scan_end
+
 lda gouraud_scan_end
 and #252
 sta fc_end
 jsr gouraud_init_span_pointers
 lda gouraud_scan_x
 and #3
 tax
 lda fc_left,x
 sta fc_mask
fc_byte:
 lda gouraud_scan_x
 and #252
 cmp fc_end
 bne fc_ready
 lda gouraud_scan_end
 and #3
 tax
 lda fc_right,x
 and fc_mask
 sta fc_mask
fc_ready:
 lda fc_mask
 cmp #255
 beq fc_whole
 eor #255
 sta fc_keep
 lda fc_fill
 and fc_mask
 sta fc_bits
 ldy #0
 lda (ptr0lo),y
 and fc_keep
 ora fc_bits
 sta (ptr0lo),y
 lda (ptr1lo),y
 and fc_keep
 ora fc_bits
 sta (ptr1lo),y
 jmp fc_next
fc_whole:
 ldy #0
 lda fc_fill
 sta (ptr0lo),y
 sta (ptr1lo),y
fc_next:
 lda gouraud_scan_x
 and #252
 cmp fc_end
 beq fc_done
 clc
 adc #4
 sta gouraud_scan_x
 clc
 lda ptr0lo
 adc #8
 sta ptr0lo
 bcc +
 inc ptr0hi
+
 clc
 lda ptr1lo
 adc #8
 sta ptr1lo
 bcc +
 inc ptr1hi
+
 lda #255
 sta fc_mask
 jmp fc_byte
fc_done:
 rts
fc_fill: .byte 0
fc_end: .byte 0
fc_mask: .byte 0
fc_keep: .byte 0
fc_bits: .byte 0
fc_patterns: .byte 0,85,170,255
fc_left: .byte 255,63,15,3
fc_right: .byte 192,240,252,255
'''
