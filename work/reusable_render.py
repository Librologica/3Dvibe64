"""Bounded exact integer edges and explicit streamed camera-space vertices.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import re

def integer_edges(s):
    from legacy_plus_exact import once,flag
    s=flag(s,'ENGINE_MODE4_FAST_BOUNDS_TRACE')
    for side in ('l','r'):
        old=f''' clc
 lda dxabs
 adc dyval
 bcc sm3_fbt_{side}_dispatch
 beq sm3_fbt_{side}_dispatch
 jmp sm3_fbt_{side}_fallback16
'''
        # Wire/bounds sharing must keep the old path. Only solid bounds take
        # the carry-aware loop; all endpoints were clipped to byte coordinates.
        s=once(s,old,f'''.if WIRE_RENDER_ENABLE != 0
 lda wire_trace_active
 beq sm3_fbt_{side}_dispatch
 jmp sm3_fbt_{side}_fallback16
.else
 jmp sm3_fbt_{side}_dispatch
.endif
''')
    for direction in ('pos','neg'):
        old=f''' sta errlo
sm3_fbt_span_{direction}_check:
 cmp dyval
 bcc sm3_fbt_span_{direction}_y
 sec
'''
        new=f''' sta errlo
 bcs er_integer_{direction}_reduce
sm3_fbt_span_{direction}_check:
 cmp dyval
 bcc sm3_fbt_span_{direction}_y
er_integer_{direction}_reduce:
 sec
'''
        s=once(s,old,new)
    return s

def stream(s):
    from legacy_plus_exact import block,constant
    if constant(s,'MESH_SOURCE_SHARING_RUNTIME'):
        raise ValueError('EXACT_RENDER_STREAM: shared-source instances need a separate owner adapter')
    if constant(s,'VERT_COUNT')>255:
        raise ValueError('EXACT_RENDER_STREAM: byte-index ABI requires at most255 resident vertices')
    # Reuse the exact producer's emitted commit/projection/classification body.
    # Unlike an application copy, this follows future native projector changes.
    a=s.index(' jsr lc_commit_q4\n',s.index('explorer_transform_project_vertices:\n'))
    b=s.index('etpv_next:\n',a)
    tail=s[a:b]
    names=set(re.findall(r'(?m)^([A-Za-z_]\w*):',tail))
    names.add('etpv_next')
    tail=re.sub(r'\b[A-Za-z_]\w*\b',lambda m:'er_stream_'+m[0] if m[0] in names else m[0],tail)
    code='''; Reserve a nonempty existing vertex interval. X=first,Y=count.
; Caller owns the interval during this pass; no automatic source-table edits.
er_stream_begin:
 tya
 beq er_stream_invalid
 stx er_stream_first
 clc
 adc er_stream_first
 bcs er_stream_invalid
 cmp #VERT_COUNT
 bcc +
 beq +
 jmp er_stream_invalid
+
 sta er_stream_end
 lda #1
 sta er_stream_active
er_stream_clear:
 lda #0
 sta projdone,x
 lda #16
 sta er_outcodes,x
 inx
 cpx er_stream_end
 bcc er_stream_clear
 sec
 rts
er_stream_invalid:
 lda #0
 sta er_stream_active
 clc
 rts
; A=owned slot; inputs er_stream_x/y/z are signed16 camera-space Q4.
; C=1 means producer completed; projdone=0 means native near clipping needed.
er_stream_project:
 ldx er_stream_active
 beq er_stream_reject
 cmp er_stream_first
 bcc er_stream_reject
 cmp er_stream_end
 bcs er_stream_reject
 sta tmpidx
 lda er_stream_x
 sta explorer_view_x_lo
 lda er_stream_x+1
 sta explorer_view_x_hi
 lda er_stream_y
 sta explorer_view_y_lo
 lda er_stream_y+1
 sta explorer_view_y_hi
 lda er_stream_z
 sta p1lo
 lda er_stream_z+1
 sta p1hi
'''+tail+'''er_stream_etpv_next:
 ldx tmpidx
 jsr er_cache_outcode
 sec
 rts
er_stream_reject:
 clc
 rts
er_stream_end_pass:
 lda #0
 sta er_stream_active
 rts
er_stream_first: .byte 0
er_stream_end: .byte 0
er_stream_active: .byte 0
er_stream_x: .word 0
er_stream_y: .word 0
er_stream_z: .word 0
'''
    return s+block('stream',code)
