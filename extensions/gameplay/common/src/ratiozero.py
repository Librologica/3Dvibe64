"""Demo-only exact zero-delta shortcut; keep original division/fault contract.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. Frozen SDKs and references remain unchanged.
"""

def adapt(source, parts, placed):
    if placed is None:
        hits=0
        for name in list(parts):
            s=parts[name]
            if 'hq_ratio_product:\n' not in s:
                continue
            old=' sta hc_shift+5\nhq_mul_loop:\n'
            assert s.count(old)==1, name
            new=''' sta hc_shift+5
 ; Zero delta: quotient and remainder are zero. Use the existing divider
 ; nevertheless, so its denominator-zero fault and scratch contract survive.
 ; hc_value is private destructive scratch, not a caller-visible output.
 lda hc_shift
 ora hc_shift+1
 ora hc_shift+2
 beq hq_mul_done
hq_mul_loop:
'''
            parts[name]=s.replace(old,new)
            hits+=1
        assert hits==1, hits
        # Co-locate two complete routines, without an extra guard between
        # them. Same8-byte reserve at block end, same RAM windows and final
        # overflow assertions. Both routines end in RTS; no fallthrough.
        parts['screen_precision']+=parts.pop('carrier_advance')
    return source,parts
