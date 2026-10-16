"""Private unlit texture shader; cube native plane-flat dispatcher unchanged.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0.
"""
import torus_runtime as arrays
import optimizations as op

def bake(source):
    # Constant neutral Q is retained only for the generated clipping/edge ABI.
    # It is NOT a light estimate: no normal, lamp or smooth shade is evaluated.
    for channel in range(3):
        label='gouraud_face_shade'+str(channel)
        _,values=arrays.array(source,label)
        assert len(values)==119
        source=arrays.put(source,label,[16]*len(values))
    return source

def hooks(source):
    # Always install raw-pigment compositor and no-op Q advance. The old
    # neutral specialization already preserves A=texel exactly. Keep its
    # safe between-span SMC; IRQ never executes these renderer entries.
    source=op.once(source,'''sg_prepare:
 ldy yrow
 lda m3_leftq,y
 cmp #10
 bcc sg_dynamic
 cmp #23
 bcs sg_dynamic
 lda m3_rightq,y
 cmp #10
 bcc sg_dynamic
 cmp #23
 bcs sg_dynamic
 lda #1
''','''sg_prepare:
 ldy yrow
 lda #1
''')
    return source
