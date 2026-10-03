"""Exact projective-only arithmetic specializations; scalar contracts retained.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0.
No scene paths, lighting replacement, viewport change or approximate sampling.
"""

def once(source, old, new):
    assert source.count(old) == 1, (old[:70], source.count(old))
    return source.replace(old, new)

def division_prefix():
    # Leading zero bits do not contribute to the remainder or quotient.
    s = ' ldy #48\npd_trim_bytes:\n lda hc_num+5\n bne pd_trim_bits\n'
    for j in range(5, 0, -1):
        s += f' lda hc_num+{j-1}\n sta hc_num+{j}\n'
    s += ' lda #0\n sta hc_num\n tya\n sec\n sbc #8\n tay\n bne pd_trim_bytes\n rts\n'
    s += 'pd_trim_bits:\n lda hc_num+5\n bmi hc_div_loop\n asl hc_num\n'
    for j in range(1, 6):
        s += f' rol hc_num+{j}\n'
    return s + ' dey\n bne pd_trim_bits\n rts\n'

NARROW_PRODUCT = ''' lda hc_shift
 ora hc_shift+1
 ora hc_shift+2
 beq hq_mul_done
 lda hc_shift+2
 ora hc_value+2
 bne hq_mul_loop
 ldx #16
pd_mul16:
 lsr hc_value+1
 ror hc_value
 bcc pd_shift16
 clc
 lda hc_num+2
 adc hc_shift
 sta hc_num+2
 lda hc_num+3
 adc hc_shift+1
 sta hc_num+3
pd_shift16:
 ; Carry is the 17th sum bit, or zero from multiplier test.
 ror hc_num+3
 ror hc_num+2
 ror hc_num+1
 ror hc_num
 dex
 bne pd_mul16
 jmp hq_mul_done
'''

def encoder(body):
    # W at near=1 WU is exactly32768: both attribute products are identities.
    begin = body.index('ps_encode:\n')
    end = body.index('ps_encode_valid:\n')
    body = body[:begin] + '''ps_encode:
 lda hc_depth+2
 bne ps_far_error
 lda hc_depth+1
 beq ps_depth_error
 cmp #1
 bne ps_encode_valid
 lda hc_depth
 bne ps_encode_valid
 sta hc_out_w
 lda #128
 sta hc_out_w+1
 rts
ps_far_error:
 cmp #1
 bne ps_depth_error
 lda hc_depth
 ora hc_depth+1
 beq ps_encode_valid
ps_depth_error:
 lda #1
 sta ps_fault
 ; Do not divide invalid depth or publish an unsupported frame.
 lda #0
 sta hc_out_w
 sta hc_out_w+1
 rts
''' + body[end:]
    # Exact8-entry FIFO keyed by complete fractional Q8 depth, not integer bins.
    search = '''ps_encode_valid:
 lda #255
 sta pc_slot
 lda hc_depth+2
 bne pc_uncached
 lda hc_depth+1
 beq pc_uncached
 ldx #7
pc_search:
 lda hc_depth+1
 cmp pc_keyhi,x
 bne pc_next
 lda hc_depth
 cmp pc_keylo,x
 beq pc_hit
pc_next:
 dex
 bpl pc_search
 ldx pc_next_slot
 stx pc_slot
 inx
 txa
 and #7
 sta pc_next_slot
 jmp pc_uncached
pc_hit:
 lda pc_wlo,x
 sta hc_num
 lda pc_whi,x
 sta hc_num+1
 jmp pc_ready
pc_uncached:
'''
    body = once(body, 'ps_encode_valid:\n', search)
    body = once(body, ' jsr hc_div40\n lda hc_num\n', ' jsr hc_div40\npc_ready:\n lda hc_num\n')
    return once(body, ' sta ps_b+1\n lda hc_out_s\n', ''' sta ps_b+1
 ldx pc_slot
 bmi pc_uv
 lda hc_depth
 sta pc_keylo,x
 lda hc_depth+1
 sta pc_keyhi,x
 lda hc_out_w
 sta pc_wlo,x
 lda hc_out_w+1
 sta pc_whi,x
pc_uv:
 lda hc_out_s
''')

def apply(source, parts):
    parts['projection'] = once(parts['projection'], ' ldy #48\nhc_div_loop:\n', division_prefix() + 'hc_div_loop:\n')
    # Place the complete divider independently, with existing32-byte guard.
    p = parts['projection']; a = p.index('hc_div40:\n'); b = p.index('; trunc(delta_s16', a)
    parts['perspective_division'] = p[a:b]
    parts['projection'] = p[:a] + p[b:]
    p = parts['screen_precision']
    p = once(p, ' sta hc_shift+5\nhq_mul_loop:\n', ' sta hc_shift+5\n' + NARROW_PRODUCT + 'hq_mul_loop:\n')
    a = p.index('hq_ratio_product:\n'); b = p.index('hq_quantize_poly:\n', a)
    parts['perspective_product'] = p[a:b]
    parts['screen_precision'] = p[:a] + p[b:]
    parts['perspective_encode'] = encoder(parts['perspective_encode'])
    parts['data'] += 'pc_next_slot: .byte 0\npc_slot: .byte 255\n'
    for name in ('keylo','keyhi','wlo','whi'):
        parts['data'] += f'pc_{name}: .fill 8,0\n'
    # The profile is bounded. Faults are sticky; never present a corrupted frame.
    source = once(source, 'render_frame_end:\n', '''render_frame_end:
 lda ps_fault
 beq pp_frame_valid
pp_profile_fault:
 lda #2
 sta $d020
 jmp pp_profile_fault
pp_frame_valid:
''')
    return source, parts
