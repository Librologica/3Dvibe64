"""Keep Gouraud/UV attributes attached to legacy-plus clipped vertices.

Near attributes use the same unsigned16 weight as Q4 near geometry. Screen
attributes keep the existing screen clipper's weight and signed delta rule.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import argparse,re
from pathlib import Path

def patch(s):
    if not re.search(r'(?m)^(?:GOURAUD_MODE6|MODE7_UV_CARRIER) = \$01$',s):return s
    assert 'lpn_helpers_begin:' in s
    textured='m7_clip_a_v:' in s or 'm7_clip_a_v =' in s
    def replace(old,new):
        nonlocal s
        assert s.count(old)==1,(old[:80],s.count(old))
        s=s.replace(old,new,1)
    # The original Gouraud transfer changes X from vertex index to face slot.
    # Reload the original vertex before copying its camera-space Q4 cache.
    a=s.index('near_append_current_vertex:\n');b=s.index('near_append_intersection:\n',a)
    code=s[a:b]
    old='.if EXPLORER_NEAR_POLY != 0 || CAMERA_PLANE_CLIP_PROFILE != 0\n'
    assert code.count(old)==1
    code=code.replace(old,old+' ldx clip_cur_idx\n jsr near_get_face_vertex\n tax\n ldy clip_a_count\n',1)
    s=s[:a]+code+s[b:]
    a=s.index('near_project_intersection:\n');b=s.index('near_interp_x_to_t1:\n',a)
    code=s[a:b];assert code.count(' jsr gouraud_interp_clip_shade\n')==1
    code=code.replace(' jsr gouraud_interp_clip_shade\n',' jsr lpa_near_attributes\n',1)
    s=s[:a]+code+s[b:]
    if not textured:
        for side,src,dst in [('right','a','b'),('left','b','a'),('top','a','b'),('bottom','b','a')]:
            a=s.index(f'clip_append_{side}_intersection_{src}_to_{dst}:\n');b=s.index('\n rts\n',a)
            code=s[a:b]
            old=f' inc clip_{dst}_count'
            assert code.count(old)==1
            code=code.replace(old,f' jsr gouraud_interp_clip_shade\n ldy clip_{dst}_count\n sta clip_{dst}_shade,y\n'+old,1)
            s=s[:a]+code+s[b:]
        replace(' lda clip_a_y,x\n sta clip_a_y,y\ncpcsa_inc_write:',
                ' lda clip_a_y,x\n sta clip_a_y,y\n lda clip_a_shade,x\n sta clip_a_shade,y\ncpcsa_inc_write:')
    # The Mode7 emitter has already added its V result store at the original
    # Gouraud call site. This helper preserves that ABI, returning U in A.
    code='\nlpa_attributes_begin:\nlpa_near_attributes:\n'
    channels=[('m3_clip_q','m3_clip_q_result')] if 'm3_q0:' in s else []
    if textured:channels.append(('m7_clip_v','m7_clip_v_result'))
    channels.append(('gouraud_clip_shade',None))
    for name,dest in channels:
        code+=f''' sec
 lda {name}_out
 sbc {name}_in
 sta p1lo
 lda #0
 sbc #0
 sta p1hi
 jsr lpn_mul_nearest
 clc
 lda p1lo
 adc {name}_in
'''
        if dest:code+=' sta '+dest+'\n'
    code+=' rts\nlpa_attributes_end:\n.cerror * > $d000,"Plus attributes overlap IO"\n'
    return s+code

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('asm',type=Path);a=p.parse_args()
    a.asm.write_text(patch(a.asm.read_text(encoding='utf-8-sig')),encoding='ascii')
