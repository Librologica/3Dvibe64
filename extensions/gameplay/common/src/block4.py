"""Demo-only four-pixel projective endpoints, affine interior UV.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
Geometry, carrier DDA and shade DDA stay exact. UV interiors are approximate.
"""
import re

def once(s,a,b):
    assert s.count(a)==1,(a,s.count(a))
    return s.replace(a,b)

def kernel():
    sample='''ps_sample:
 stx bk_saved_x
 lda bk_count
 beq bk_boundary
bk_cached:
 lda bk_cur1
 sta m7_u
 lda bk_cur1+1
 sta m7_v
 ldx bk_saved_x
 rts
bk_boundary:
 sec
 lda gouraud_scan_end
 sbc gouraud_scan_x
 cmp #4
 bcs bk_long
 jmp bk_exact_sample ; final 1..4 pixels: exact, never sample past edge
bk_long:
 lda bk_ready
 beq bk_seed
 lda bk_next
 sta m7_u
 lda bk_next+1
 sta m7_v
 jmp bk_start
bk_seed:
 jsr bk_exact_sample
bk_start:
 ldx #1
bk_copy_start:
 lda m7_u,x
 sta bk_cur1,x
 lda #0
 sta bk_cur0,x
 dex
 bpl bk_copy_start
 ldx #2
bk_predict_channels:
 jsr bk_predict
 lda bk_future
 sta bk_look0,x
 lda bk_future+1
 sta bk_look1,x
 dex
 bpl bk_predict_channels
 lda bk_look0+2
 sta ps_den
 lda bk_look1+2
 sta ps_den+1
'''
    for ch in range(2):
        sample+=f''' lda bk_look0+{ch}
 sta ps_a
 lda bk_look1+{ch}
 sta ps_a+1
 jsr ps_uv_divide
 sta bk_next+{ch}
'''
    sample+=''' ldx #1
bk_setup_steps:
 sec
 lda bk_next,x
 sbc bk_cur1,x
 sta bk_delta
 lda #0
 sbc #0
 sta bk_delta+1
 lda bk_delta
 asl
 asl
 asl
 asl
 asl
 asl
 sta bk_step0,x ; (delta mod4)*64, fraction of raw UV byte
 lsr bk_delta+1
 ror bk_delta
 lsr bk_delta+1
 ror bk_delta
 lda bk_delta
 sta bk_step1,x ; signed floor(delta/4), low byte
 dex
 bpl bk_setup_steps
 lda #4
 sta bk_count
 lda #1
 sta bk_ready
 jmp bk_cached
'''
    prediction='''; Predict exact existing Euclidean carrier DDA four steps ahead.
; cur +4*step +floor((err+4*rem)/width), all carriers unsigned16.
; Width1..111; err/rem<width; correction0..4; endpoint inside span.
bk_predict:
 lda ps_step1,x
 sta bk_future+1
 lda ps_step0,x
 asl
 rol bk_future+1
 asl
 rol bk_future+1
 clc
 adc ps_cur0,x
 sta bk_future
 lda bk_future+1
 adc ps_cur1,x
 sta bk_future+1
 lda #0
 sta bk_delta+1
 lda ps_rem,x
 asl
 rol bk_delta+1
 asl
 rol bk_delta+1
 clc
 adc ps_err,x
 sta bk_delta
 bcc bk_predict_test
 inc bk_delta+1
bk_predict_test:
 lda bk_delta+1
 bne bk_predict_correct
 lda bk_delta
 cmp m7_den
 bcc bk_predict_done
bk_predict_correct:
 sec
 lda bk_delta
 sbc m7_den
 sta bk_delta
 lda bk_delta+1
 sbc #0
 sta bk_delta+1
 inc bk_future
 bne bk_predict_test
 inc bk_future+1
 jmp bk_predict_test
bk_predict_done:
 rts
'''
    advance='''ps_advance:
 jsr bk_exact_advance ; exact UW/VW/W, Q and scan X
 lda bk_count
 beq bk_advance_done
 dec bk_count
'''
    for ch in range(2):
        advance+=f''' clc
 lda bk_cur0+{ch}
 adc bk_step0+{ch}
 sta bk_cur0+{ch}
 lda bk_cur1+{ch}
 adc bk_step1+{ch}
 sta bk_cur1+{ch}
'''
    advance+='bk_advance_done:\n rts\n'
    state='bk_count: .byte 0\nbk_ready: .byte 0\nbk_saved_x: .byte 0\n'
    for name,size in [('cur0',2),('cur1',2),('next',2),('step0',2),('step1',2),
                      ('look0',3),('look1',3),('delta',2),('future',2)]:
        state+=f'bk_{name}: .fill {size},0\n'
    return sample,prediction,advance,state

def adapt(source,parts,placed):
    # The old affine helper STILL serves Gouraud Q setup: do not remove it.
    # Only unused UV step/error declarations can be safely omitted here.
    for name in ('m7_ustep','m7_vstep','m7_urem','m7_vrem','m7_uerr','m7_verr',
                 'm7_udir','m7_vdir'):
        full=source+'\n'+'\n'.join(parts.values())
        assert len(re.findall(r'\b'+name+r'\b',full))==1,name
        source=once(source,name+': .byte 0\n','')
    # These obsolete affine clipping fields are never read or written by
    # either base code or Q8 blocks. No pointer references them. The active
    # camera clipper uses hc_a/b_*; retain m7_clip_a_v and all live aliases.
    for name,size in [('m7_clip_v_in',1),('m7_clip_v_out',1),
                      ('m7_clip_v_result',1),('m7_edge_errhi',1),('m7_clip_b_v',12)]:
        full=source+'\n'+'\n'.join(parts.values())
        assert len(re.findall(r'\b'+name+r'\b',full))==1,name
        decl=name+(': .byte 0\n' if size==1 else f': .fill {size},0\n')
        source=once(source,decl,'')
    if placed is None:
        sample,predict,advance,state=kernel()
        parts['perspective_sample']=once(parts['perspective_sample'],'ps_sample:\n','bk_exact_sample:\n')
        parts['perspective_sample']+=sample+predict
        parts['data']+=state
        parts['perspective_span']=once(parts['perspective_span'],'ps_advance:\n','bk_exact_advance:\n')
        parts['perspective_span']+=advance
        parts['perspective_span']=once(parts['perspective_span'],'ps_prepare_span:\n',
            'ps_prepare_span:\n lda #0\n sta bk_count\n sta bk_ready\n')
    return source,parts

def pack(sizes,lab,align_tables=True):
    """Same four legal windows;8-byte rather than32-byte code growth reserve.
    Assembly still checks every final block against its allocated end. If a
    relocated long branch exceeds the reserve, build fails; never spills.
    No runtime buffers moved or reduced. This allocator is demo-only.
    """
    gaps=[(lab['mode3_high_basic_low_segment_end'],0x2000),
          (lab['mode3_high_basic_middle_end'],0x5c00),
          (lab['mode3_high_basic_relocated_code_end'],0xa000),
          (lab['mode3_high_basic_high_code_end'],0xd000)]
    items=sorted(sizes.items(),key=lambda x:-x[1]);seen=set()
    def search(i,free,placed):
        if i==len(items):return placed,free
        state=(i,tuple(sorted(free)))
        if state in seen:return None
        seen.add(state)
        name,size=items[i];align=256 if name=='tables' and align_tables else 2
        need=size+(0 if name in ('tables','data') else 8)
        if sum(b-a for a,b in free)<sum(s+(0 if n in ('tables','data') else 8) for n,s in items[i:]):return None
        options=[]
        for gi,(a,b) in enumerate(free):
            start=(a+align-1)//align*align
            if start+need<=b:options.append((b-start-need,gi,start))
        for _,gi,start in sorted(options):
            a,b=free[gi];nextfree=free[:gi]+free[gi+1:]
            if a<start:nextfree.append((a,start))
            if start+need<b:nextfree.append((start+need,b))
            result=search(i+1,nextfree,{**placed,name:(start,start+need)})
            if result:return result
        return None
    result=search(0,gaps,{})
    if not result:raise ValueError('Demo block4 memory budget: no nonoverlapping placement')
    return result[0],gaps,result[1]
