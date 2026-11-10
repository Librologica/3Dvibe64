"""Exact post-emission affine Mode7-C optimization for ordinary legacy-plus.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
Raw templates and other precision/lighting paths remain available unchanged.
"""
import argparse,json,re
from pathlib import Path
VARIANT = 'bands'
def once(s,old,new):
    if s.count(old)!=1:raise ValueError('MODE7_EXACT_ANCHOR: '+repr(old[:90]))
    return s.replace(old,new,1)
def array(s,name):
    m=re.search(r'(?m)^'+name+r':\n((?: \.byte[^\n]*\n)+)',s)
    if not m:raise ValueError('MODE7_EXACT_ROW_TABLE: '+name)
    return [int(x[1:],16) if x.startswith('$') else int(x) for x in re.findall(r'\$[0-9a-fA-F]+|-?\d+',m[1])]
"""Exact full-byte UV step expansion after the accepted parent Mode7 pass."""
INLINE_STEPS = 4
ARITHMETIC = True

def expand_full_byte(s):
    if ARITHMETIC:
        # Same modulo-byte coordinate; store once after quotient/correction.
        for axis,next_label in [('u','m7_v_advance'),('v','m7_uv_done')]:
            cur='m7_'+axis;step=cur+'step';rem=cur+'rem';error=cur+'err';direction=cur+'dir'
            old=f''' clc
 lda {cur}
 adc {step}
 sta {cur}
 clc
 lda {error}
 adc {rem}
 bcs m7_{axis}_correct
 cmp m7_den
 bcc m7_{axis}_store
m7_{axis}_correct:
 sec
 sbc m7_den
 sta {error}
 clc
 lda {cur}
 adc {direction}
 sta {cur}
 jmp {next_label}
m7_{axis}_store:
 sta {error}
{next_label}:
'''
            new=f''' clc
 lda {error}
 adc {rem}
 bcs m7_{axis}_correct
 cmp m7_den
 bcc m7_{axis}_store
m7_{axis}_correct:
 sec
 sbc m7_den
 sta {error}
 clc
 lda {step}
 adc {direction}
 jmp lp8_{axis}_apply
m7_{axis}_store:
 sta {error}
 lda {step}
lp8_{axis}_apply:
 clc
 adc {cur}
 sta {cur}
{next_label}:
'''
            s=once(s,old,new)
    a=s.index('m7_advance:\n')+len('m7_advance:\n')
    b=s.index('m7_prepare_span:\n',a)
    block=s[a:b]
    match=re.fullmatch(r'(.*) rts\n*',block,re.S)
    if not match:raise ValueError('MODE7_INLINE_STEP_BODY')
    body=match[1]
    if body.count('lp7_q_advance_site:\n jsr m3_advance_q\n')!=1:
        raise ValueError('MODE7_INLINE_Q_SITE')
    labels=re.findall(r'(?m)^(\w+):',body)
    a=s.index('m7_full_byte:\n');b=s.index('m7_partial:\n',a)
    full=s[a:b]
    if full.count(' jsr m7_advance\n')!=4:
        raise ValueError('MODE7_INLINE_FULL_BYTE_STEPS')
    sites=[]
    for phase in range(INLINE_STEPS):
        names={n:f'lp8_phase{phase}_'+n for n in labels}
        inline=re.sub(r'\b('+ '|'.join(map(re.escape,labels))+r')\b',lambda m:names[m[0]],body)
        full=once(full,' jsr m7_advance\n',inline) if full.count(' jsr m7_advance\n')==1 else full.replace(' jsr m7_advance\n',inline,1)
        sites.append(names['lp7_q_advance_site'])
    s=s[:a]+full+s[b:]
    # Every duplicated Q opcode follows the same exact span-band selection.
    old=' sty lp7_q_advance_site\n'
    s=once(s,old,old+''.join(' sty '+name+'\n' for name in sites))
    return s


"""Long constant-light spans can use cached immediate UV operands exactly."""



def specialize_uv_steps(fast):
    for phase in range(4):
        prefix='lp8_fast_lp8_phase'+str(phase)+'_'
        for axis in 'uv':
            old=(prefix+'m7_'+axis+'_correct:\n sec\n sbc m7_den\n sta m7_'+axis+'err\n'
                 ' clc\n lda m7_'+axis+'step\n adc m7_'+axis+'dir\n jmp '+prefix+'lp8_'+axis+'_apply\n')
            new=(prefix+'m7_'+axis+'_correct:\n sbc m7_den\n sta m7_'+axis+'err\n'
                 ' lda m7_'+axis+'corrected\n jmp '+prefix+'lp8_'+axis+'_apply\n')
            # Entry carry is1 from either ADC overflow or successful CMP.
            # This retains the exact wrapped subtraction for denominators>128.
            fast=once(fast,old,new)
    return fast


def specialize_stable_spans(s):
    a=s.index('m7_full_byte:\n');b=s.index('m7_partial:\n',a)
    full=s[a:b]
    if full.count(' jsr m3_advance_q\n')!=4:
        raise ValueError('MODE7_IMMEDIATE_INLINE_Q')
    labels=re.findall(r'(?m)^(\w+):',full)
    names={n:'lp8_fast_'+n for n in labels}
    fast=re.sub(r'\b('+ '|'.join(map(re.escape,labels))+r')\b',lambda m:names[m[0]],full)
    # Eligibility proves C output independent of Q. Original final-Q restore
    # still runs; the four intermediate calls/skip-opcodes are unnecessary.
    fast=fast.replace(' jsr m3_advance_q\n','')
    fast=specialize_uv_steps(fast)
    sites={}
    def immediate(match):
        op,symbol=match.groups();group=sites.setdefault(symbol,[])
        label='lp8_fast_imm_'+symbol+'_'+str(len(group));group.append(label)
        return label+':\n '+op+' '+symbol+'\n'
    fast=re.sub(r'(?m)^ (lda|adc|cmp|sbc) (m7_(?:den|ustep|urem|udir|vstep|vrem|vdir|ucorrected|vcorrected))\n',immediate,fast)
    if len(sites)!=7 or sum(map(len,sites.values()))!=40:
        raise ValueError('MODE7_IMMEDIATE_OPERAND_SET')
    patch='lp8_patch_uv_constants:\n rts\n'
    select='''lp8_select_full_kernel:
 lda lp7_q_advance_site
 cmp #$2c
 bne lp8_full_normal
 lda gouraud_scan_x
 clc
 adc #3
 and #$fc
 ora #3
 cmp gouraud_scan_end
 bcc gr29_first_full_byte
 beq gr29_first_full_byte
 jmp lp8_full_normal
gr29_first_full_byte:
 jsr lp8_patch_uv_constants
 lda #<lp8_fast_m7_full_byte
 ldx #>lp8_fast_m7_full_byte
 jmp lp8_full_patch
lp8_full_normal:
 lda #<lp8_normal_full_byte
 ldx #>lp8_normal_full_byte
lp8_full_patch:
 sta lp8_full_dispatch+1
 stx lp8_full_dispatch+2
 rts
'''
    s=once(s,'m7_full_byte:\n','m7_full_byte:\nlp8_full_dispatch:\n jmp lp8_normal_full_byte\nlp8_normal_full_byte:\n')
    # UV setup and band selection have both completed at this public kernel
    # entry. The direct emitted-code oracle uses this exact entry too.
    s=once(s,'gouraud_draw_scan_span_bytes:\n','gouraud_draw_scan_span_bytes:\n jsr lp8_select_full_kernel\n')
    for name,code in [('mode7_immediate_setup',select+patch),('mode7_immediate_kernel',fast)]:
        s+='\n; Plus allocation block '+name+'\n.virtual $4000\nlpa_block_'+name+'_begin:\n'+code+'lpa_block_'+name+'_end:\n.endvirtual\n'
    return s



def install_sampler_tail(s):
    prefixes={'lp7_band_fallback': ' lda #$4c\n sta m7_fetch_end\n',
 'lp7_band_dark': ' lda #$4c\n sta m7_fetch_end\n',
 'lp7_band_neutral': ' lda #$60\n sta m7_fetch_end\n',
 'lp7_band_bright': ' lda #$4c\n sta m7_fetch_end\n'}
    for label,prefix in prefixes.items():
        s=once(s,label+':\n',label+':\n'+prefix)
    return once(s,'m7_fetch_end:\n jmp m3_composite\n','m7_fetch_end:\nlp10_neutral_return_slot:\n jmp m3_composite\n')


def optimize_dda_setup(s):
    s=once(s,' beq m7_dda_zero\n lda m7_r\nm7_dda_divide:\n',' beq m7_dda_zero\n cmp #1\n beq lp11_dda_power1\n cmp #2\n beq lp11_dda_power2\n lda m7_r\nm7_dda_divide:\n')
    s=once(s,'m7_dda_remainder:\n sta m7_r\n','m7_dda_remainder:\n sta m7_r\nlp11_dda_sign:\n')
    return once(s,'m7_dda_zero:\n sta m7_r\n rts\n','m7_dda_zero:\n sta m7_r\n rts\nlp11_dda_power1:\n lda m7_r\n sta m7_q\n lda m7_r\n and #0\n sta m7_r\n jmp lp11_dda_sign\nlp11_dda_power2:\n lda m7_r\n lsr\n sta m7_q\n lda m7_r\n and #1\n sta m7_r\n jmp lp11_dda_sign\n')



def zero_page_raster(s):
    # Each shadow exists only between the public span entry and its common
    # exit. Existing private ZP bytes are saved on the stack and restored.
    # Setup/other helpers keep the real RAM state; final values are published
    # before the existing final-Q helper. No new persistent storage or tables.
    # These private math registers are inactive in this closed span call tree.
    # Save every byte before borrowing; publish only original mutable UV state.
    mutable = {'m7_u': 'p1lo', 'm7_v': 'p1hi', 'm7_uerr': 'prodlo', 'm7_verr': 'prodhi', 'm3_qcur': 'mul16reslo', 'm3_qerr': 'mul16reshi'}
    shadow = dict(mutable, m7_ustep='crosslo', m7_urem='crosshi',
                  m7_vstep='mul16lo', m7_vrem='mul16hi', m7_den='mul16mul',
                  m7_ucorrected='mul16abs', m7_vcorrected='mul16rem',
                  m3_qstep='mul16sign', m3_qrem='mula', m3_qcorrected='mulb')
    # Apply the same exact precomputed correction to the original partial and
    # normal full-byte paths, as already used by the fast kernel.
    for axis in 'uv':
        old=' clc\n lda m7_'+axis+'step\n adc m7_'+axis+'dir\n'
        new=' lda m7_'+axis+'corrected\n'
        if s.count(old)!=5:raise ValueError('GR28_NORMAL_CORRECTION_CONTEXT')
        s=s.replace(old,new)
    a=s.index('m3_advance_q:\n');b=s.index('m3_advance_q_end = *\n',a)
    s=s[:a]+'''m3_advance_q:
 clc
 lda m3_qerr
 adc m3_qrem
 bcc gr28_q_store
 sbc m7_den
 sta m3_qerr
 lda m3_qcorrected
 jmp gr28_q_apply
gr28_q_store:
 sta m3_qerr
 lda m3_qstep
gr28_q_apply:
 adc m3_qcur
 sta m3_qcur
 rts
'''+s[b:]
    a=s.index('m3_advance_q:\n');b=s.index('m3_advance_q_end = *\n',a)
    qbody=s[a:b].removeprefix('m3_advance_q:\n').removesuffix(' rts\n')
    assert qbody.endswith(' sta m3_qcur\n')
    sites=[]
    for phase in range(4):
        site='lp8_phase'+str(phase)+'_lp7_q_advance_site';end='gr28_inline_q_end_'+str(phase)
        code=qbody.replace('gr28_q_store','gr28_inline_q_store_'+str(phase)).replace('gr28_q_apply','gr28_inline_q_apply_'+str(phase))
        s=once(s,site+':\n jsr m3_advance_q\n',' ldy #0\n'+site+':\n bne '+end+'\n'+code+end+':\n')
        s=once(s,' sty '+site+'\n','');sites.append(site)
    gate=' pha\n tya\n cmp #$2c\n beq gr28_inline_q_stable\n lda #$d0\n bne gr28_inline_q_patch\ngr28_inline_q_stable:\n lda #$f0\ngr28_inline_q_patch:\n'+''.join(' sta '+site+'\n' for site in sites)+' pla\n'
    s=once(s,' sty lp7_q_advance_site\n',' sty lp7_q_advance_site\n'+gate)
    addresses = {}
    for scratch in shadow.values():
        m = re.search(r'(?m)^' + scratch + r' = \$([0-9a-fA-F]+)$', s)
        if not m or not 2 <= int(m[1],16) <= 255:
            return s, dict(applied=False, reason='Private zero-page layout not proven')
        addresses[scratch] = int(m[1],16)
    if len(set(addresses.values())) != len(shadow):
        raise ValueError('MODE7_RASTER_SHADOW_ALIAS')
    pattern = re.compile(r'\b(' + '|'.join(map(re.escape,shadow)) + r')\b')
    def replace_region(source, first, last):
        a = source.index(first); b = source.index(last,a)
        return source[:a] + pattern.sub(lambda m:shadow[m[0]],source[a:b]) + source[b:]
    s = replace_region(s, 'gouraud_draw_scan_span_bytes:\n', '; Texture is page aligned.')
    s = replace_region(s, 'm7_sample:\n', 'm7_prepare_span:\n')
    if 'm3_qcur' in shadow:
        s = replace_region(s, 'm3_advance_q:\n', 'm3_advance_q_end = *\n')
        s = replace_region(s, 'm3_composite:\n', 'm3_composite_end = *\n')
    s = replace_region(s, 'lpa_block_mode7_immediate_kernel_begin:\n',
                       'lpa_block_mode7_immediate_kernel_end:\n')
    save = ''.join(' lda '+scratch+'\n pha\n' for scratch in shadow.values())
    entry = ''
    for state,scratch in shadow.items():
        if state=='m3_qcorrected':
            entry+=' clc\n lda m3_qstep\n adc m3_qdir\n sta '+scratch+'\n'
        elif state=='m3_qerr':
            entry+=' sec\n lda m3_qerr\n sbc m7_den\n sta '+scratch+'\n'
        elif state in ('m7_ucorrected','m7_vcorrected'):
            axis=state[3];entry+=' clc\n lda m7_'+axis+'step\n adc m7_'+axis+'dir\n sta '+scratch+'\n'
        else:entry+=' lda '+state+'\n sta '+scratch+'\n'
    publish = ''.join(' lda '+scratch+'\n sta '+state+'\n' for state,scratch in mutable.items())
    old=' lda mul16reshi\n sta m3_qerr\n';assert publish.count(old)==1
    publish=publish.replace(old,' clc\n lda mul16reshi\n adc m7_den\n sta m3_qerr\n')
    restore = ''.join(' pla\n sta '+scratch+'\n' for scratch in reversed(list(shadow.values())))
    # Keep the original callable span ABI. The known fill loop borrows once
    # for the whole face and calls the same core without per-row save/restore.
    s = once(s, 'gouraud_draw_scan_span_bytes:\n', 'gouraud_draw_scan_span_bytes:\n'+save+' jsr gr28_span_core\n'+restore+' rts\ngr28_span_core:\n'+entry)
    s = once(s, 'gouraud_fill_bounds:\n', 'gouraud_fill_bounds:\n'+save+' jsr gr28_fill_core\n'+restore+' rts\ngr28_fill_core:\n')
    s = once(s, ' jsr m7_prepare_span\n jsr gouraud_draw_scan_span_bytes\n', ' jsr m7_prepare_span\n jsr gr28_span_core\n')
    s = once(s, 'm7_span_done:\n jsr lp7_finish_q\n rts\n',
             'm7_span_done:\n'+publish+' jsr lp7_finish_q\n rts\n')
    return s, dict(applied=True, state=shadow, stackBytes=len(shadow),
                  existingScratchSavedAndRestored=True, finalRAMStatePublished=True,
                  newRAMTables=False, originalSetupAndFinalQRetained=True)

def patch(s):
    if 'm31_c_instructions_end = *' not in s:return s,dict(applied=False,reason='Existing compositor retained; C-only optimization')
    if not re.search(r'(?m)^GRAPHICS_MODE = \$07$',s):raise ValueError('MODE7_EXACT_MODE')
    a=s.index('gouraud_draw_scan_span_bytes:\n');b=s.index('; Texture is page aligned.',a);kernel=s[a:b]
    old='''m7_full_byte:
 jsr m7_sample
 asl
 asl
 asl
 asl
 asl
 asl
 sta m7_packed
 jsr m7_advance
 jsr m7_sample
 asl
 asl
 asl
 asl
 ora m7_packed
 sta m7_packed
 jsr m7_advance
 jsr m7_sample
 asl
 asl
 ora m7_packed
 sta m7_packed
'''
    new='''m7_full_byte:
 ; Horner composition of four exact two-bit texels.
 jsr m7_sample
 asl
 asl
 sta m7_packed
 jsr m7_advance
 jsr m7_sample
 ora m7_packed
 asl
 asl
 sta m7_packed
 jsr m7_advance
 jsr m7_sample
 ora m7_packed
 asl
 asl
 sta m7_packed
'''
    kernel=once(kernel,old,new)
    kernel=once(kernel,''' and #3
 bne m7_partial
 lda gouraud_scan_end''',''' and #3
 bne m7_partial
lp7_aligned_byte:
 lda gouraud_scan_end''')
    kernel=once(kernel,' jmp m7_byte_dispatch\n',' jmp lp7_aligned_byte\n')
    if VARIANT in ('cursor','bands'):
        for buf in 'ab':
            lo,hi=[array(s,'row0'+part+'_'+buf) for part in ('lo','hi')]
            lo1,hi1=[array(s,'row1'+part+'_'+buf) for part in ('lo','hi')]
            if not len(lo)==len(hi)==len(lo1)==len(hi1):raise ValueError('MODE7_EXACT_ROW_LENGTH')
            if not all(c+256*d==a+256*b+1 for a,b,c,d in zip(lo,hi,lo1,hi1)):
                raise ValueError('MODE7_EXACT_ROWS_NOT_ADJACENT')
        kernel=once(kernel,' sta (ptr0lo),y\n sta (ptr1lo),y\n',' sta (ptr0lo),y\n iny\n sta (ptr0lo),y\n')
        kernel=once(kernel,''' sta (ptr0lo),y
 lda (ptr1lo),y
 and maskv
 ora m7_packed
 sta (ptr1lo),y''',''' sta (ptr0lo),y
 iny
 lda (ptr0lo),y
 and maskv
 ora m7_packed
 sta (ptr0lo),y''')
        kernel=once(kernel,'''m7_ptr0_done:
 clc
 lda ptr1lo
 adc #8
 sta ptr1lo
 bcc m7_ptr1_done
 inc ptr1hi
m7_ptr1_done:
''','''m7_ptr0_done:
m7_ptr1_done:
 ; The second physical row is ptr0+1; only one byte cursor advances.
''')
    s=s[:a]+kernel+s[b:]
    if VARIANT=='bands':
        # The existing Q DDA stays intact. For endpoints wholly in one stable
        # C band, every interpolated shade has the identical texel mapping.
        # Keep its true denominator even when top-left coverage trims the end.
        s=once(s,'m3_prepare_span:\n','m3_prepare_span:\n jsr lp7_select_band\n')
        code='''lp7_select_band:
 ldy yrow
 lda m3_leftq,y
 cmp #7
 bcs lp7_band_not_dark
 lda m3_rightq,y
 cmp #7
 bcc lp7_band_dark
 jmp lp7_band_fallback
lp7_band_not_dark:
 cmp #10
 bcc lp7_band_fallback
 cmp #23
 bcs lp7_band_not_neutral
 lda m3_rightq,y
 cmp #10
 bcc lp7_band_fallback
 cmp #23
 bcc lp7_band_neutral
 jmp lp7_band_fallback
lp7_band_not_neutral:
 cmp #26
 bcc lp7_band_fallback
 lda m3_rightq,y
 cmp #26
 bcs lp7_band_bright
lp7_band_fallback:
 ldx #<m3_composite
 lda #>m3_composite
 jmp lp7_band_patch
lp7_band_dark:
 ldx #<lp7_composite_dark
 lda #>lp7_composite_dark
 jmp lp7_band_patch
lp7_band_neutral:
 ldx #<lp7_composite_neutral
 lda #>lp7_composite_neutral
 jmp lp7_band_patch
lp7_band_bright:
 ldx #<lp7_composite_bright
 lda #>lp7_composite_bright
lp7_band_patch:
 stx m7_fetch_end+1
 sta m7_fetch_end+2
 rts
lp7_composite_dark:
 cmp #2
 bcc lp7_composite_neutral
 sbc #1
lp7_composite_neutral:
 rts
lp7_composite_bright:
 cmp #3
 bcs lp7_composite_neutral
 adc #1
 rts
'''
        s+='\n; Plus allocation block mode7_exact\n.virtual $4000\nlpa_block_mode7_exact_begin:\n'+code+'lpa_block_mode7_exact_end:\n.endvirtual\n'
    # Stable compositors do not inspect Q. Retain the exact original helper
    # for transitions; skip only its calls in a proven constant output band.
    # Materialize the exact Q/error once at the last covered sample. C's
    # denominator is the untrimmed right anchor, including half-open spans.
    s=once(s,'m7_uv_done:\n jsr m3_advance_q\n','m7_uv_done:\nlp7_q_advance_site:\n jsr m3_advance_q\n')
    s=once(s,'m7_span_done:\n rts\n','m7_span_done:\n jsr lp7_finish_q\n rts\n')
    for label,opcode in [('lp7_band_fallback',0x20),('lp7_band_dark',0x2c),('lp7_band_neutral',0x2c),('lp7_band_bright',0x2c)]:
        s=once(s,label+':\n',label+':\n ldy #$'+format(opcode,'02x')+'\n')
    s=once(s,'lp7_band_patch:\n','lp7_band_patch:\n sty lp7_q_advance_site\n')
    finish="""lp7_finish_q:
 lda lp7_q_advance_site
 cmp #$2c
 bne lp7_finish_done
 lda m7_den
 beq lp7_finish_done
 ldy yrow
 lda gouraud_scan_x
 cmp rightval
 bne lp7_finish_open
 lda m3_rightq,y
 sta m3_qcur
 lda #0
 sta m3_qerr
 rts
lp7_finish_open:
 sec
 lda m3_rightq,y
 sbc m3_qstep
 sta m3_qcur
 lda m3_qrem
 beq lp7_finish_done
 sec
 lda m3_qcur
 sbc m3_qdir
 sta m3_qcur
 sec
 lda m7_den
 sbc m3_qrem
 sta m3_qerr
lp7_finish_done:
 rts
"""
    s+='\n; Plus allocation block mode7_finish\n.virtual $4000\nlpa_block_mode7_finish_begin:\n'+finish+'lpa_block_mode7_finish_end:\n.endvirtual\n'
    s=install_sampler_tail(s)
    s=expand_full_byte(s)
    s=specialize_stable_spans(s)
    s=optimize_dda_setup(s)
    s,raster_zero_page=zero_page_raster(s)
    return s,dict(applied=True,variant='dda-unit-half-zp4',rasterZeroPage=raster_zero_page,exactDDASmallDenominators=[1, 2],directNeutralReturn=True,inlineStableCompositors=False,correctedStepCache=True,indexedStableCursor=False,stableImmediateMinimumPixels=4,stableFirstCompleteByteRequired=True,operandCache=True,scope='Mode7-C affine legacy-plus',exact=True,UVQInterpolationChanged=False,stableQExecutionDeferred=True,inlineUVSteps=4,oneUVStore=True,qualityChanged=False,rawTemplatesChanged=False)


# The private closed call tree is part of this optimization's ABI. Any unknown
# producer/consumer or shader retains the delivered parent's complete pass.
_agentic28_patch = patch
_SPAN_CONTRACTS = [('r1_span_closed_cap:\n', 'gouraud_fill_bounds:\n', '44fc8fb14f04e077462da0e2a74b07c6e1203a8c2ac07d8ae45aa0779654017e'), ('gouraud_fill_bounds:\n', 'gfb_done:\n rts\n', '527504df6fcf448a09ba47da6367ae697a8a6850d705f533cf74d2635cc14ff7'), ('gouraud_draw_scan_span_bytes:\n', '; Texture is page aligned.', 'da6d53c3159559cc6d01a0bbac8b32fb5f707c999eb7ccffd8aac9cfe891b430'), ('m7_sample:\n', 'm7_advance:\n', '0315665953b3891f592148e3baf46951fbce88344d0d43e964925aec449dbc31'), ('m7_advance:\n', 'm7_prepare_span:\n', 'f595563d1d61e2f9a61fa570133678a54ff4cc9e5208f276b05dc28c3dd144ff'), ('m7_prepare_span:\n', 'm7_dda_setup:\n', '7af653be04c49fcbd0a716f7cc45a4931c0063f4f2333ca61fe849d8c9a7f1a1'), ('m7_dda_setup:\n', 'm7_store_fixed_raw_x:\n', '3c3433f7fe2c643c5c4d7e7264dd99fd9e21a85bf3aa54555a32ed1716a0ba61'), ('m3_prepare_span:\n', 'm3_prepare_span_end = *\n', 'e2d4a570e07af9531f34d11aaf10862a83d7372138d62edacba72ec1af82a6fe'), ('m3_advance_q:\n', 'm3_advance_q_end = *\n', '3cdfad07276fdc4c7d2e97ed2231f299fe6242c2a1635e50e7980c45396c398f'), ('m3_composite:\n', 'm3_composite_end = *\n', 'c21325c719b47319017298613011ab16796916bb368402ffe1bbea00f1ab11ad')]
_SPAN_CALLS = ['13b6fbf9f01ac6275600bc5f9ed6a6e4d8041279d03c9c78e881421d5fab640a', '1be6afe7d6d350c80a9b151bdd91c05dd336c35fd66b1faecb92849878762900', '1c1052c6150fa9dc1bf508b2093bbb3a8a957dbe70f8d113af53d4941f59b1bd', '55a8b601f9ef8cc0b7661eb8212a4ba3e31c715d6e2018352fd12d6cfffcf7e3', '57cb32b244ad0df349c891626b15ac7c24bf7c79a11aaf84a6e64083abb450d1', '5c4c9ae9129393b8167fb6d983ec927b364536baa3a0c4176b8c847f3ef29de7', '7111ac6dec95e9e9edbbef8712650863e563cbb51e9bf25ebfe283581a6a9c3e', '730e58cf05c2728e67297e2494c07c362dd010920bcaef0a0c79fcdb6b9fbddd', '80a78b145453abc4a3463c3689ce80cb3b130a3ecc5beb64415362cdd47f76a5', '8780df45c1c67f8909d26cdf498bf6dfa1c99c57d7c0679211462ac18d951cc1', '8a9031dd2bbbeeca8442dd42bfe1cda581e9b116cd4478b88bc609590c61c614', '9122be7c436981c6380ee5f76d6c7485752e12cdb8aacfb37dd725cd01a5996f', '928530a9021c48b8fc83028d2a9c155db271bc96625ebd38457f091483984f6c', 'a2115db501b82ad37e6337493e10026d44164c06433a18f52844b935111da22b', 'd8935d29bad977010523d6b667ac081db7cef4fbe04dd3dd32f8b41c43e13a8e', 'e0796b0fd038b09870bdfacf1d5f8380b143f276112ddd9eea1f1798e9bac6cd']
def span_contract_supported(s):
    import hashlib
    if not re.search(r'(?m)^GRAPHICS_MODE = \$07$',s) or 'm31_c_instructions_end = *' not in s:return False
    if 'VIC_COLOR_POLICY_ENABLE = $00' not in s:return False
    try:
        for first,last,digest in _SPAN_CONTRACTS:
            a=s.index(first);b=s.index(last,a)
            if last=='gfb_done:\n rts\n':b+=len(last)
            if hashlib.sha256(s[a:b].encode('ascii')).hexdigest()!=digest:return False
    except ValueError:return False
    lines=s.splitlines();calls=sorted(hashlib.sha256('\n'.join(lines[max(0,i-3):i+4]).encode('ascii')).hexdigest() for i,line in enumerate(lines) if re.fullmatch(r' (?:jsr|jmp) (gouraud_fill_bounds|gouraud_draw_scan_span_bytes|m7_sample|m7_advance|m3_composite|m3_advance_q)',line))
    return calls==_SPAN_CALLS

def patch(s):
    if not span_contract_supported(s):
        from legacy_mode7_parent_exact import patch as parent_patch
        result,report=parent_patch(s);report['agentic28ParentFallback']=True
        return result,report
    result,report=_agentic28_patch(s)
    report.update(agentic28SpanContract=True,operandCache=False,slopesInSavedPrivateRegisters=True,
                  savedPrivateBytes=16,originalSavedPrivateBytes=4,privateSpanEntryRetained=True,
                  privateFillCallerRegistersVolatile=True,sharedCoreBorrowScope='one fill call or standalone span',
                  registerUAfterRenderTuning=True,inlineNormalFullByteQ=True,newGlobalScratchAliases=False)
    return result,report

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('asm',type=Path);a=p.parse_args()
    s,report=patch(a.asm.read_text(encoding='utf-8-sig'));a.asm.write_bytes(s.encode('ascii'))
    a.asm.with_suffix('.mode7-exact.json').write_text(json.dumps(report,indent=2))
