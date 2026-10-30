"""Exact coherent Mode6 byte interpolation; production module template.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import re
MIN_SPAN = 31
ENTRY_OLD='gdsb_pointer_init:\n jsr gouraud_init_span_pointers\n'
ENTRY_NEW='gdsb_pointer_init:\n jmp gr14_enter\ngr14_pointer_init:\n jsr gouraud_init_span_pointers\n'
SAMPLES_OLD=' ldx gouraud_scan_err\n ldy gouraud_scan_shade\n ; Phase 0.\n'
SAMPLES_NEW='gr14_dispatch:\n jmp gr14_try_byte\ngr14_original_samples:\n'+SAMPLES_OLD
BLOCK=re.compile(r'\n; Plus allocation block gouraud_coherent\n(?:\* = \$[0-9a-f]+|\.virtual \$4000)\nlpa_block_gouraud_coherent_begin:\n.*?lpa_block_gouraud_coherent_end:\n(?:\.cerror[^\n]+\n|\.endvirtual\n)',re.S)

CODE='''gr14_enter:
 ; Default to the unchanged four-sample kernel. BIT absolute skips the
 ; dispatch operand without a branch; the sample kernel replaces its flags.
 lda #$2c
 sta gr14_dispatch
 lda gouraud_scan_span
 cmp #MIN_SPAN_ASM
 bcc gr14_enter_done
 lda gouraud_scan_delta
 cmp #33
 bcs gr14_enter_done
 asl
 clc
 adc gouraud_scan_delta
 cmp gouraud_scan_span
 bcs gr14_enter_done
 sta gr14_delta3+1
 ; Copy the caller's already-selected packed Bayer row. No new LUTs.
 lda gdsb_lut_phase0+1
 sta gr14_first_lut+1
 sta gr14_next_lut+1
 lda gdsb_lut_phase0+2
 sta gr14_first_lut+2
 sta gr14_next_lut+2
 lda #$4c
 sta gr14_dispatch
gr14_enter_done:
 jmp gr14_pointer_init

gr14_try_byte:
 ldy gouraud_scan_shade
gr14_first_lut:
 lda gouraud_bayer_code_lut_y0,y
 and #$fc
 sta p1lo
 clc
 lda gouraud_scan_err
gr14_delta3:
 adc #0
 cmp gouraud_scan_span
 bcs gr14_one_step
 tax
 jmp gdsb_lut_phase3

gr14_one_step:
 sbc gouraud_scan_span
 tax
 tya
 clc
 adc gouraud_scan_dir
 tay
gr14_next_lut:
 lda gouraud_bayer_code_lut_y0,y
 and #$fc
 cmp p1lo
 beq gr14_prefix_ready
 ; At most one shade transition occurs in the first three DDA steps.
 ; Locate it exactly, then combine the two packed codes with fixed masks.
 pha
 clc
 lda gouraud_scan_err
 adc gouraud_scan_delta
 cmp gouraud_scan_span
 bcs gr14_cut1
 ; CMP above supplied C=0; the second sum still fits a byte.
 adc gouraud_scan_delta
 cmp gouraud_scan_span
 bcs gr14_cut2
 ; Only pixel3 changed. The first three pixel pairs are already correct.
 pla
 jmp gdsb_lut_phase3
gr14_cut1:
 pla
 and #$3c
 sta gr14_or1+1
 lda p1lo
 and #$c0
gr14_or1:
 ora #0
 sta p1lo
 jmp gdsb_lut_phase3
gr14_cut2:
 pla
 and #$0c
 sta gr14_or2+1
 lda p1lo
 and #$f0
gr14_or2:
 ora #0
 sta p1lo
gr14_prefix_ready:
 ; X=remainder after three steps, Y=shade after three steps. Rejoin the
 ; original phase3 LUT/store/advance tail with its exact prefix in p1lo.
 jmp gdsb_lut_phase3
'''

def once(s,old,new):
    if s.count(old)!=1:raise ValueError('COHERENT_GOURAUD_ANCHOR: '+repr(old[:80]))
    return s.replace(old,new,1)

def _coherent_original_source(s):
    if ENTRY_NEW not in s:return s
    s=once(s,ENTRY_NEW,ENTRY_OLD);s=once(s,SAMPLES_NEW,SAMPLES_OLD)
    if len(list(BLOCK.finditer(s)))!=1:raise ValueError('COHERENT_GOURAUD_RESTORE_BLOCK')
    return BLOCK.sub('',s)

def _coherent_patch(s):
    s=_coherent_original_source(s)
    if not re.search(r'(?m)^GRAPHICS_MODE = \$06$',s):return s,dict(applied=False,reason='Mode6 only')
    if ENTRY_OLD not in s or SAMPLES_OLD not in s or 'gdsb_lut_phase3:\n lda gouraud_bayer_code_lut_y0,y\n and #$03\n ora p1lo\n' not in s:
        return s,dict(applied=False,reason='Unknown byte kernel retained')
    s=once(s,ENTRY_OLD,ENTRY_NEW);s=once(s,SAMPLES_OLD,SAMPLES_NEW)
    code=CODE.replace('MIN_SPAN_ASM',str(MIN_SPAN))
    s+='\n; Plus allocation block gouraud_coherent\n.virtual $4000\nlpa_block_gouraud_coherent_begin:\n'+code+'lpa_block_gouraud_coherent_end:\n.endvirtual\n'
    return s,dict(applied=True,minimumSpan=MIN_SPAN,newRAMVariables=0,newRAMTables=0,
        temporaryStackBytes=1,arithmetic='Exact three-step DDA endpoint; at most one transition, exact packed prefix masks',qualityChanged=False)


import legacy_gouraud_material as material_cache

def original_source(s):
    return material_cache.original_source(_coherent_original_source(s))

def patch(s):
    s=original_source(s)
    s,shader=_coherent_patch(s)
    s,material=material_cache.patch(s)
    return s,dict(applied=shader['applied'] or material['applied'],shader=shader,material=material,newRAMVariables=0,newRAMTables=0,qualityChanged=False)
