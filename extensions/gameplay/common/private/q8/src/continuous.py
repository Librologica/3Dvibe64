"""Isolated continuous-Q8 adapter, never applied to legacy output."""
import re
from pathlib import Path
from emit import chunks as bounded_chunks, ldword

ROOT=Path(__file__).resolve().parents[1]

# The continuous transform writes hc_cam_* and the SDK projection caches directly.
# These seven two-byte-per-vertex arrays belonged to the retired bounded pilot's
# hp_build_vertices/hp_project_all/hp_commit, none of which is emitted here.
RETIRED_VERTEX_ARRAYS=tuple('hp_'+name for name in ('vx','vy','vz','px','py','ix','iy'))

def remove_retired_vertex_arrays(data):
    for name in RETIRED_VERTEX_ARRAYS:
        declaration=f'{name}: .fill VERT_COUNT*2,0\n'
        assert data.count(declaration)==1,('retired array declaration changed',name)
        data=data.replace(declaration,'')
    return data

def verify_retired_state_absent(source):
    # Fail closed on any future consumer, including indexed accesses and aliases.
    # Comments are not executable consumers. Check the WHOLE generated program,
    # not just the adapter chunks: 64tass must not resolve an accidental old label.
    code='\n'.join(line.split(';',1)[0] for line in source.splitlines())
    for name in RETIRED_VERTEX_ARRAYS:
        if re.search(r'\b'+re.escape(name)+r'\b',code):
            raise ValueError('Q8_RETIRED_STATE_CONSUMER: '+name)

def retire(source,start,end):
    """Keep conditional label ABI for dead callers, but trap if reached.
    Only obsolete polygon clip implementation, not renderer/data, is retired.
    Every emitted old label points at an explicit unreachable BRK, never random RAM.
    """
    a=source.index(start);b=source.index(end,a)
    old=source[a:b];new='; Q8-only: old integer polygon clip retired.\n'
    for line in old.splitlines():
        m=re.match(r'^(\w+):',line)
        if m:new+=m[1]+' = hp_unreachable\n'
        elif line.strip().startswith(('.if ','.else','.elsif ','.endif')):new+=line+'\n'
    return source[:a]+new+source[b:]

def retire_unreferenced(source,start,end):
    """Remove replaced entry points only if no external label consumer remains."""
    a=source.index(start);b=source.index(end,a)
    names=re.findall(r'(?m)^(\w+):',source[a:b])
    rest='\n'.join(line.split(';',1)[0] for line in (source[:a]+source[b:]).splitlines())
    for name in names:
        if re.search(r'\b'+re.escape(name)+r'\b',rest):
            raise ValueError('Q8_REPLACED_ROUTINE_STILL_REFERENCED: '+name)
    return retire(source,start,end)

def prepare(source,music,motion=False,mode=6):
    if mode==3:
        source=static_q8_dispatch(source)
    # This region is within EXPLORER_SCREEN_CLIP_POLY; retain its conditional
    # balance and segment boundaries, retiring no shared multiply/raster code.
    source=retire(source,'clip_loaded_face_poly_x:','\n.if EXPLORER_SCREEN_CLIP_X != 0\nclip_loaded_face_screen_x:')
    for old,new in [('load_face_y:','hp_retired_load_face_y:'),
                    ('draw_clip_poly_gouraud:','hp_retired_draw_clip_poly_gouraud:')]:
        assert source.count(old)==1;source=source.replace(old,new)
    # New common loader replaces these bodies completely. Keep trap aliases,
    # but reclaim their code to fund the wider clip arithmetic within the same
    # memory layout; all callers must use the new public entry point.
    source=retire_unreferenced(source,'hp_retired_load_face_y:','screen_face_drawable:')
    source=retire_unreferenced(source,'hp_retired_draw_clip_poly_gouraud:','\n.endif\n\ndraw_clip_poly_solid_a:')
    assert source.count('explorer_transform_project_vertices:')==1
    source=source.replace('explorer_transform_project_vertices:','hp_legacy_transform_project_vertices:')
    source=retire_unreferenced(source,'hp_legacy_transform_project_vertices:','\nrotate_project_vertices:')
    if mode in (3,4,5):
        # Keep the four existing flat solid/pattern A/B wrappers and their SMC
        # fill selector. Replace ONLY the integer fan geometry with the same
        # whole clipped Q2 polygon used by Gouraud. Lighting/materials unchanged.
        start=source.index('draw_clip_poly_common:')
        end=source.index('\n.endif',start)
        source=source[:start]+'''draw_clip_poly_common:
 jsr hq_build_clip_bounds
 lda xyq2_face_valid
 beq dcp_done
dcp_fill_call:
 jsr fill_bounds_solid_a
dcp_done:
 rts
'''+source[end:]
    # Conservative cull asks whether a face may cross screen; do not call retired code.
    source=source.replace(' jsr clip_poly_needs_screen',' jsr hp_needs_screen')
    # Q8 vertices retain camera translation. The old XY-only cross product is
    # orthographic and may reject a perspective-visible face off the optical axis.
    # Delay facing until the projected/clipped polygon exists in load_face_y.
    assert source.count(' jsr face_visible\n')==1
    source=source.replace(' jsr face_visible\n',' sec ; Q8 perspective winding is checked after clipping\n nop\n nop\n')
    if music:
        source=source.replace(' jsr init_irq\n',' jsr gs_sid_init\n jsr init_irq\n')
        # Exactly one hook in each mutually exclusive frame-count IRQ arm.
        source=source.replace(' inc sim_vblank_count\n',' inc sim_vblank_count\n jsr gs_video_tick\n')
    if motion:
        source=source.replace('advance_sim_tick:\n','advance_sim_tick:\n jsr hc_demo_motion\n')
    return source

def static_q8_dispatch(source):
    """Keep Mode 3 prepare-once and static pigments; adapt ONLY Q8 geometry.

    Prepared faces are fully inside and already perspective-culled. Reload their
    Q2 endpoints from the projected vertex cache together with integer anchors.
    The direct integer fan/quad walker cannot consume those fractions, so use
    the existing Q2 bounds + original Mode 3 span fills. No dynamic light flags.
    """
    start=source.index('engine_mode3_load_prepared_face_y:')
    end=source.index('\nload_face_y:',start)
    block=source[start:end]
    for i in range(4):
        anchor=f' lda sy,x\n sta vy{i}\n'
        assert block.count(anchor)==1,('static cache anchor',i)
        extra=''
        for ax in 'xy':
            for part in ('lo','hi'):
                extra+=f' lda s{ax}q2_{part},x\n sta v{ax}q2_{i}{part}\n'
        block=block.replace(anchor,anchor+extra)
    anchor=' lda vy2\n sta vy3\n jmp sm3lpf_spans\n'
    assert block.count(anchor)==1
    extra=''
    for ax in 'xy':
        for part in ('lo','hi'):
            extra+=f' lda v{ax}q2_2{part}\n sta v{ax}q2_3{part}\n'
    block=block.replace(anchor,anchor.replace(' jmp sm3lpf_spans\n',extra+' jmp sm3lpf_spans\n'))
    source=source[:start]+block+source[end:]
    old='DIRECT_CONVEX_FAN_FILL = $01'
    assert source.count(old)==1
    return source.replace(old,'DIRECT_CONVEX_FAN_FILL = $00 ; Q8 Mode 3: integer-only direct fill bypassed')


def wide_origins_vertices():
    code='hp_origins:\n lda explorer_cam_yaw\n ora explorer_cam_pitch\n beq hp_origin_supported\n clc\n rts\nhp_origin_supported:\n'
    for ax in 'xyz':
        if ax=='z':code+=' lda object_pos_z_ext\n'
        else:code+=f' lda object_pos_{ax}_hi\n asl\n lda #0\n sbc #0\n eor #$ff\n'
        code+=' sta hc_ext\n sec\n'
        for j,suf in enumerate(('lo','hi','ext')):
            code+=(f' lda object_pos_{ax}_{suf}\n' if j<2 else ' lda hc_ext\n')
            code+=f' sbc explorer_cam_{ax}_{suf}\n sta hc_origin_{ax}+{j}\n'
    code+=' sec\n rts\nhp_build_vertices:\n lda #0\n sta hp_idx\nhc_vertex_loop:\n'
    for i,ax in enumerate('xyz'):
        for j in range(3):code+=f' lda hc_origin_{ax}+{j}\n sta hc_sum+{j}\n'
        for j,a in enumerate('xyz'):
            code+=f' ldy hp_idx\n ldx vert_{a}i,y\n lda hp_term{i}{j}_hi,x\n asl\n lda #0\n sbc #0\n eor #$ff\n sta hc_ext\n clc\n'
            for k,p in enumerate(('lo','hi')):code+=f' lda hc_sum+{k}\n adc hp_term{i}{j}_{p},x\n sta hc_sum+{k}\n'
            code+=' lda hc_sum+2\n adc hc_ext\n sta hc_sum+2\n'
        code+=' ldy hp_idx\n'
        for j in range(3):code+=f' lda hc_sum+{j}\n sta hc_cam_{ax}{j},y\n'
        if ax in 'xy':code+=f' lda hc_sum+1\n sta {"rxbuf" if ax=="x" else "rybuf"},y\n'
        else:code+=' lda hc_sum+1\n sta sz,y\n lda hc_sum+2\n sta szhi,y\n'
        code+=f' lda hc_sum+1\n sta v{ax}rawlo,y\n lda hc_sum+2\n sta v{ax}rawhi,y\n'
    code+=' inc hp_idx\n lda hp_idx\n cmp #VERT_COUNT\n bne hc_vertex_loop\n rts\n'
    return code

def pieces(lab,music=True,motion=False):
    p=bounded_chunks(lab)
    template=Path(__file__).with_name('kernel.asm').read_text()
    # Keep exact approved Q8 trig/products; replace bounded origins/projection.
    arithmetic=template[template.index('hp_mul:'):template.index('; Unsigned numerator')]
    p['core']='''hp_code_start:
explorer_transform_project_vertices:
 lda #0
 sta hp_used
 sta hp_fault
 jsr hp_origins
 bcs hc_go
 inc hp_fault
 ldx #VERT_COUNT-1
 lda #0
hc_invalid:
 sta projdone,x
 dex
 bpl hc_invalid
 rts
hc_go:
 jsr hp_prepare_matrix
 jsr hp_prepare_terms
 jsr hp_build_vertices
 jsr hc_project_vertices
 lda #1
 sta hp_used
 rts
hp_unreachable:
 brk
 jmp hp_unreachable
'''+arithmetic
    p['vertices']=wide_origins_vertices()
    p['projection']=Path(__file__).with_name('wide.asm').read_text()
    from screen import arithmetic as screen_arithmetic
    p['screen_precision']=screen_arithmetic()
    p['clip']=Path(__file__).with_name('clip.asm').read_text()
    p['clip_helpers']=helpers()
    p['poly_draw']=draw_poly(lab['GRAPHICS_MODE'])
    p['winding']=Path(__file__).with_name('winding.asm').read_text()
    if lab['VERT_COUNT']>8:
        # Same routines, two independently placed chunks for the tighter torus.
        # Both halves terminate with RTS; no layout/guard-band relaxation.
        split=p['winding'].index('cw_load_product:')
        p['winding_math']=p['winding'][split:]
        p['winding']=p['winding'][:split]
        if lab['VIDEO_STANDARD_FORCE_NTSC']:
            # NTSC music/timing makes the last gaps too small for both math
            # routines together. They already communicate through JSR/RTS;
            # place them separately, preserving every instruction and guard.
            split=p['winding_math'].index('cw_multiply:')
            p['winding_multiply']=p['winding_math'][split:]
            p['winding_math']=p['winding_math'][:split]
    data=remove_retired_vertex_arrays(p['data'])+'\nhp_fault: .byte 0\ncw_area: .fill 3,0\ncw_prev: .byte 0\ncw_cur: .byte 0\n'
    for n,size in [('origin_x',3),('origin_y',3),('origin_z',3),('sum',3),('ext',1),
                   ('coord',3),('depth',3),('num',6),('shift',6),('divisor',3),('remainder',4),
                   ('sign',1),('axis',1),('q',2),('integer',2),('value',3),('base',3),
                   ('factor',3),('den',3),('delta',3),('result',3),('corner',1),('previous',1),
                   ('current',1),('prev_inside',1),('cur_inside',1),('from',1),('to',1),
                   ('from_vertex',1),('to_vertex',1),('count',1),('out_count',1),('plane',1),
                   ('bound',3),('changed',1),('source_count',1),('face_vertices',4),
                   ('out_x',3),('out_y',3),('out_s',2),('poly_index',1),('edge_next',1)]:
        data+=f'hc_{n}: .fill {size},0\n'
    for ax in 'xyz':
        for j in range(3):data+=f'hc_cam_{ax}{j}: .fill VERT_COUNT,0\n'
    for bank in 'ab':
        for att in 'xys':
            for part in (('lo','hi') if att=='s' else ('lo','hi','ext')):data+=f'hc_{bank}_{att}{part}: .fill 12,0\n'
    data+='hq_residue: .byte 0\nhq_projected: .fill 3,0\nhq_sx_fraction: .fill VERT_COUNT,0\nhq_sy_fraction: .fill VERT_COUNT,0\n'
    p['data']=data
    if motion:
        p['demo_motion']='''; Demo-only lateral sweep; logical ticks, never render-frame pacing.
hc_demo_motion:
 clc
 lda hc_motion_phase
 adc #64
 sta hc_motion_phase
 sta hp_fraction
 lda hc_motion_phase+1
 adc #0
 sta hc_motion_phase+1
 tax
 jsr hp_sine
 lda hp_r
 sta hp_a
 lda hp_r+1
 sta hp_a+1
 lda #70
 sta hp_b
 lda #0
 sta hp_b+1
 jsr hp_int_product
 lda hp_r
 sta object_pos_x_lo
 lda hp_r+1
 sta object_pos_x_hi
 rts
hc_motion_phase: .word 0
'''
    if music:
        text=(ROOT/'music/player.asm').read_text()
        text=text[text.index('sid_init:'):text.index('code_end:')]+(ROOT/'music/player.asm').read_text().split('code_end:')[1].split('.include')[0]
        text+=(ROOT/'music/score.inc').read_text()
        names=set(re.findall(r'^(\w+):',text,re.M))
        for name in sorted(names,key=len,reverse=True):text=re.sub(r'\b'+name+r'\b','gs_'+name,text)
        # Tune PAL; on NTSC skip one in six refreshes and convert pitch tables.
        if lab['VIDEO_STANDARD_FORCE_NTSC']:
            # Generated table literals only: frequency correction by 985248/1022727.
            for voice in ('bass','mid','high','noise'):
                lo=re.search(r'gs_'+voice+r'_lo:\n((?: .byte [^\n]+\n)+)',text)
                hi=re.search(r'gs_'+voice+r'_hi:\n((?: .byte [^\n]+\n)+)',text)
                lows=[int(x,16) for x in re.findall(r'\$([\da-f]+)',lo[1])];highs=[int(x,16) for x in re.findall(r'\$([\da-f]+)',hi[1])]
                values=[round((l+256*h)*985248/1022727) for l,h in zip(lows,highs)]
                for m,shift in ((lo,0),(hi,8)):
                    arr=[(v>>shift)&255 for v in values]
                    repl=''.join(' .byte '+','.join(f'${n:02x}' for n in arr[i:i+16])+'\n' for i in range(0,128,16))
                    text=text.replace(m[1],repl,1)
        text+='''
gs_video_tick:
.if VIDEO_STANDARD_FORCE_NTSC != 0
 inc gs_ntsc_phase
 lda gs_ntsc_phase
 cmp #6
 bcc gs_tick_play
 lda #0
 sta gs_ntsc_phase
 rts
gs_tick_play:
.endif
 jmp gs_sid_play
gs_ntsc_phase: .byte 0
'''
        # Split score into own packable chunk, no new IRQ/zero page.
        split=text.index('gs_bass_lo:')
        p['music_code']=text[:split]+text[text.index('gs_video_tick:'):]
        p['music_tables']=text[split:text.index('gs_video_tick:')]
    return p

def helpers():
    code=''
    # Load a camera point by vertex index X. Output projected Q2 and integer.
    code+='hc_load_vertex_point:\n'
    for j in range(3):code+=f' lda hc_cam_z{j},x\n sta hc_depth+{j}\n'
    code+=' rts\n'
    for bank in ('a','b'):
        code+=f'hc_copy_{bank}_to_out:\n'
        for a in 'xys':
            for j,part in enumerate(('lo','hi') if a=='s' else ('lo','hi','ext')):code+=f' lda hc_{bank}_{a}{part},x\n sta hc_out_{a}+{j}\n'
        code+=' rts\n'
    for bank,count in (('a','count'),('b','out_count')):
        code+=f'hc_append_{bank}:\n ldy hc_{count}\n cpy #12\n bcs hp_unreachable\n'
        for a in 'xys':
            for j,part in enumerate(('lo','hi') if a=='s' else ('lo','hi','ext')):code+=f' lda hc_out_{a}+{j}\n sta hc_{bank}_{a}{part},y\n'
        code+=f' inc hc_{count}\n rts\n'
    code+='hc_copy_back:\n lda hc_out_count\n sta hc_count\n ldx #0\nhc_copy_back_loop:\n cpx hc_count\n beq hc_copy_back_done\n'
    for a in 'xys':
        for part in (('lo','hi') if a=='s' else ('lo','hi','ext')):code+=f' lda hc_b_{a}{part},x\n sta hc_a_{a}{part},x\n'
    code+=' inx\n bne hc_copy_back_loop\nhc_copy_back_done:\n rts\n'
    # Near intersection coordinate: difference fits signed16 (mesh diameter<=80 WU).
    for ax in 'xy':
        code+=f'hc_near_{ax}:\n ldx hc_to_vertex\n ldy hc_from_vertex\n sec\n'
        for j in range(2):code+=f' lda hc_cam_{ax}{j},x\n sbc hc_cam_{ax}{j},y\n sta hc_delta+{j}\n'
        code+=' jsr hc_ratio_product\n ldy hc_from_vertex\n lda hc_result+1\n asl\n lda #0\n sbc #0\n eor #$ff\n sta hc_ext\n clc\n'
        for j in range(2):code+=f' lda hc_cam_{ax}{j},y\n adc hc_result+{j}\n sta hc_coord+{j}\n'
        code+=f' lda hc_cam_{ax}2,y\n adc hc_ext\n sta hc_coord+2\n lda #{0 if ax=="x" else 1}\n sta hc_axis\n jsr hc_project_axis\n jsr hq_expand_q\n'
        for j in range(3):code+=f' lda hq_projected+{j}\n sta hc_out_{ax}+{j}\n'
        code+=' rts\n'
    for a in 'xys':
        code+=f'hc_interpolate_{a}:\n ldx hc_to\n ldy hc_from\n sec\n'
        parts=('lo','hi') if a=='s' else ('lo','hi','ext')
        for j,part in enumerate(parts):code+=f' lda hc_a_{a}{part},x\n sbc hc_a_{a}{part},y\n sta hc_delta+{j}\n'
        if a=='s':code+=' lda #0\n sbc #0\n sta hc_delta+2\n'
        code+=' jsr hq_ratio_product\n ldy hc_from\n clc\n'
        for j,part in enumerate(parts):code+=f' lda hc_a_{a}{part},y\n adc hc_result+{j}\n sta hc_out_{a}+{j}\n'
        code+=' rts\n'
    # Copy same exact endpoint/anchors into original 3/4-vertex fast raster path.
    code+='hc_load_fast_face:\n'
    for i in range(4):
        code+=f' lda hc_a_xlo+{i}\n sta vxq2_{i}lo\n lda hc_a_xhi+{i}\n sta vxq2_{i}hi\n lda hc_a_ylo+{i}\n sta vyq2_{i}lo\n lda hc_a_yhi+{i}\n sta vyq2_{i}hi\n lda clip_a_x+{i}\n sta vx{i}\n lda clip_a_y+{i}\n sta vy{i}\n'
    code+=' rts\n'
    return code

def draw_poly(mode):
    code=Path(__file__).with_name('poly.asm').read_text()
    if mode in (3,4,5):
        code=code[:code.index(' ldx face_ymin\n')]
        code=code.replace('draw_clip_poly_gouraud:','hq_build_clip_bounds:')
        code+='hc_poly_done:\n rts\n'
    return code
