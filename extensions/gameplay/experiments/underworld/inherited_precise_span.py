"""Exact Mode7 C span specialization, local experimental 1.10.3-dev1.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0. Deferred fast carriers remain inherited dev1.
No new zero page, tables, temporal samples or texture precision changes.
"""
def once(s,a,b):
 if s.count(a)!=1:raise ValueError(('candidate source contract',a[:80],s.count(a)))
 return s.replace(a,b)

def integrated(source,parts,lab):
 """Inline fast interior advancement, leave endpoints and exact tails intact."""
 if 'bk_advance_uv:' not in parts.get('perspective_span',''):raise ValueError('fast required')
 # ps_advance keeps the public register-preserving entry used by tails/tests.
 # The draw caller does not consume X after advance; eliminate its nested
 # loop/JSR only for cached blocks. No additional zero page or state.
 body='''m7_advance:
 lda bk_count
 beq fi_scalar
 dec bk_count
'''
 for off in ('','+1'):
  body+=f''' clc
 lda bk_cur0{off}
 adc bk_step0{off}
 sta bk_cur0{off}
 lda bk_cur1{off}
 adc bk_step1{off}
 sta bk_cur1{off}
'''
 body+=''' jsr m3_advance_q
 inc gouraud_scan_x
 rts
fi_scalar:
 jmp ps_advance
'''
 # Uniform/LOD must retain its bypass before the cached branch.
 if 'pu_advance:' in parts['perspective_span']:
  body=body.replace('m7_advance:\n','m7_advance:\n lda pu_texel\n beq fi_textured\n jmp pu_advance\nfi_textured:\n')
 source=once(source,'m7_advance:\n jmp ps_advance\n',body)
 return source,parts

def integrated2(source,parts,lab):
 source,parts=integrated(source,parts,lab)
 # Preserve m7_u/v output and the material-specific address/fetch jump.
 # Cached interiors avoid the nested ps_sample call and X spill/reload.
 mixed_dispatch=' jsr ps_sample\n jmp m7_sampler_' in source
 head='''m7_sample:
 lda bk_count
 beq fi_sample_boundary
 lda bk_cur1
 sta m7_u
 lda bk_cur1+1
 sta m7_v
 jmp m7_address_begin
fi_sample_boundary:
 jsr ps_sample
'''
 if mixed_dispatch:
  head=head.replace(' jmp m7_address_begin\n',' jmp fi_address_dispatch\n')+'fi_address_dispatch:\n'
 if 'pu_advance:' in parts['perspective_span']:
  head=head.replace('m7_sample:\n','m7_sample:\n lda pu_texel\n bne fi_sample_boundary\n')
 source=once(source,'m7_sample:\n jsr ps_sample\n',head)
 for off in (1,2):
  target='fi_address_dispatch' if mixed_dispatch else 'm7_address_begin'
  source=source.replace(f' sta m7_sample+{off+3}\n',f' sta {target}+{off}\n')
 return source,parts

def span_short_fixed(source,parts,lab):
 p=parts['perspective_span']
 p=once(p,' ldx #16\npss_loop:\n',''' ldx #16
 lda hc_result+1
 bne pss_loop
 lda hc_result
 sta hc_result+1
 lda #0
 sta hc_result
 ldx #8
pss_loop:
''')
 parts['perspective_span']=p
 return source,parts

def full_byte(source,parts,lab):
 """Fuse the cached four-pixel case; exact original partial/boundary paths.

 A direct material address body must exist. Mixed repeat dispatch remains on
 the integrated scalar body. This predicate is generator knowledge, not a
 scene-specific lookup or change in texture precision.
 """
 a=source.index('m7_address_begin:\n');b=source.index('m7_fetch_end:\n',a)
 fetch=source[a:b]
 if ' jmp ' in fetch or 'ld_mix_site:' in source:return source,parts
 # All consumers of self-modified texture operands must also patch the fused
 # sites. This includes material selection and optional LOD.
 old='m7_full_byte:\n';start='''m7_full_byte:
 lda pu_texel
 bne fb_original
 lda bk_count
 cmp #4
 bcs fb_cached
fb_original:
'''
 source=once(source,old,start)
 code='fb_cached:\n'
 advance=' dec bk_count\n'
 for off in ('','+1'):
  advance+=f' clc\n lda bk_cur0{off}\n adc bk_step0{off}\n sta bk_cur0{off}\n lda bk_cur1{off}\n adc bk_step1{off}\n sta bk_cur1{off}\n'
 advance+=' jsr m3_advance_q\n inc gouraud_scan_x\n'
 for i in range(4):
  body=fetch.replace('m7_address_begin:',f'fb_address{i}:').replace('m7_fetch:',f'fb_fetch{i}:')
  code+=' lda bk_cur1\n sta m7_u\n lda bk_cur1+1\n sta m7_v\n'+body+' jsr m3_composite\n'
  code+=' asl\n'*(6-2*i)
  if i:code+=' ora m7_packed\n'
  if i!=3:code+=' sta m7_packed\n'+advance
 code+=' jmp m7_full_write\n'
 # The legacy kernel is in the fixed source section; allocate the new body
 # with existing measured/guarded projective code to avoid a fixed address.
 parts['perspective_sample']+=code
 for off in (1,2):
  needle=f' sta m7_fetch+{off}\n'
  source=source.replace(needle,needle+''.join(f' sta fb_fetch{i}+{off}\n' for i in range(4)))
 return source,parts

def apply(source,parts,fast=False,uniform_pigments=None):
    if 'm3_q0:' not in source or 'perspective_span' not in parts:
        return source,parts,dict(applied=False,reason='unrelated visual contract')
    if uniform_pigments and all(uniform_pigments):
        return source,parts,dict(applied=False,reason='uniform sampler already bypasses UV; do not emit unreachable fused code',privateStateBytes=0,newZeroPageBytes=0)
    if fast:
        source,parts=integrated2(source,parts,None)
    source,parts=span_short_fixed(source,parts,None)
    fused=False
    if fast:
        source,parts=full_byte(source,parts,None)
        fused='fb_cached:' in parts['perspective_sample']
    return source,parts,dict(applied=True,privateStateBytes=0,newZeroPageBytes=0,
        exactShortNumeratorSetup=True,cachedFastSample=fast,cachedFastAdvance=fast,
        cachedFullByte=fused,partialAndBoundaryPath='original exact',
        inheritedFast='dev1 deferred block8 carriers and sg_prepare neutral bypass',
        memoryPolicy='existing measured guarded allocator; explicit Q8_MEMORY_BUDGET on failure')
