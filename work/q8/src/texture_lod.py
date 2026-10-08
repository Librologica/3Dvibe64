"""Property-derived gradual Mode7 texture LOD. No room or texture-ID ABI.
Required Notice: 3Dvibe64. Copyright 2026 librologica.digital.
PolyForm Noncommercial 1.0.0.
"""
import colorsys
import re
from collections import Counter
from perspective_exact import once

# Deterministic host ranking, not a replacement emulator/display palette.
VIC_RGB = ((0,0,0),(255,255,255),(136,0,0),(170,255,238),
           (204,68,204),(0,204,85),(0,0,170),(238,238,119),
           (221,136,85),(102,68,0),(255,119,119),(51,51,51),
           (119,119,119),(170,255,102),(0,136,255),(187,187,187))
BAYER = (0,8,2,10,12,4,14,6,3,11,1,9,15,7,13,5)

def pigments(texels, palette):
    counts=Counter(texels)
    modal=min(counts,key=lambda p:(-counts[p],p))
    def vivid(p):
        _,s,v=colorsys.rgb_to_hsv(*(c/255 for c in VIC_RGB[palette[p-1]]))
        return s,v,-p
    accent=max(counts,key=vivid)
    return modal,accent,dict(sorted(counts.items()))

def apply(source,parts,lab,byte,near,far,quality):
    assert 1<near<far<256 and far-near==16
    pages=sorted((int(m[1]),name) for name in lab
                 if (m:=re.fullmatch(r'm7_texture_(\d+)',name)))
    assert [i for i,_ in pages]==list(range(len(pages)))
    texels=[[byte(name,j) for j in range(256)] for _,name in pages]
    modal=[];accent=[];details=[]
    for face in range(lab['FACE_COUNT']):
        texture=byte('m7_face_texture',face) if len(pages)>1 else 0
        mat=byte('face_material',face)+byte('face_reflect_offset',face)
        screen=byte('material_screen_bytes',mat)
        palette=[screen>>4,screen&15,byte('material_color_bytes',mat)&15]
        m,a,counts=pigments(texels[texture],palette)
        modal.append(m);accent.append(a)
        details.append(dict(face=face,texture=texture,palette=palette,
                            modal=m,accent=a,counts=counts))
    start=source.index('gouraud_load_face_raw_shades_y:\n')
    pos=source.index(' sta pu_texel\n',start)+len(' sta pu_texel\n')
    source=source[:pos]+' jsr ld_select\n'+source[pos:]
    # Keep the sampler's patched address jump and m7_fetch operands intact.
    # The single original safe page read is retained even at far LOD.
    source=once(source,'m7_fetch_end:\n','m7_fetch_end:\nld_mix_site:\n jsr ld_mix\n')
    data='''ld_weight: .byte 16
ld_face: .byte 0
ld_min: .byte 255
ld_modal: .byte 0
ld_accent: .byte 0
ld_saved_x: .byte 0
ld_saved_y: .byte 0
ld_saved_texel: .byte 0
ld_result: .byte 0
ld_bayer: .byte '''+','.join(map(str,BAYER))+'\n'
    data+='ld_modals: .byte '+','.join(map(str,modal))+'\n'
    data+='ld_accents: .byte '+','.join(map(str,accent))+'\n'
    parts['data']+=data
    code=f'''ld_select:
 sty ld_face
 lda #16
 sta ld_weight
 lda #$2c
 sta ld_mix_site
 lda pu_texel
 bne ld_select_done
 lda ld_modals,y
 sta ld_modal
 lda ld_accents,y
 sta ld_accent
 lda #255
 sta ld_min
'''
    for corner in range(4):
        if corner==3:
            code+=' lda face_vertex_count,y\n cmp #4\n bcc ld_classify\n'
        code+=f''' lda face{corner},y
 tax
 lda hc_cam_z2,x
 bmi ld_select_done
 bne ld_corner{corner}_done
 lda hc_cam_z1,x
 cmp ld_min
 bcs ld_corner{corner}_done
 sta ld_min
ld_corner{corner}_done:
'''
    code+=f'''ld_classify:
 lda ld_min
 cmp #{near+1}
 bcc ld_select_done
 cmp #{far}
 bcs ld_far
 sta ld_min
 lda #{far}
 sec
 sbc ld_min
 sta ld_weight
 jmp ld_enable_mix
ld_far:
 lda #0
 sta ld_weight
 lda ld_modal
 sta pu_texel
ld_enable_mix:
 ; JSR/BIT patch is made once per face, outside the sample loop.
 ; IRQ never calls this renderer. Only flags (dead after fetch) differ.
 lda #$20
 sta ld_mix_site
ld_select_done:
 ldy ld_face
 rts
ld_mix:
 stx ld_saved_x
 sty ld_saved_y
 sta ld_saved_texel
 lda ld_weight
 beq ld_far_sample
 lda yrow
'''+(' lsr\n' if quality=='fast' else '')+''' and #3
 asl
 asl
 sta ld_result
 lda gouraud_scan_x
 and #3
 ora ld_result
 tay
 lda ld_bayer,y
 cmp ld_weight
 bcs ld_far_sample
 lda ld_saved_texel
 jmp ld_mix_done
ld_far_sample:
 lda yrow
'''+(' lsr\n' if quality=='fast' else '')+''' and #1
 bne ld_use_modal
 lda gouraud_scan_x
 and #1
 bne ld_use_modal
 lda ld_accent
 jmp ld_mix_done
ld_use_modal:
 lda ld_modal
ld_mix_done:
 ldx ld_saved_x
 ldy ld_saved_y
 rts
'''
    # Small independent guarded units fit the fragmented C64 address space.
    # Do not enlarge the already large projective sampler packing unit.
    select,mix=code.split('ld_mix:\n',1)
    parts['lod_select']=select
    parts['lod_mix']='ld_mix:\n'+mix
    return source,parts,dict(mode='gradual',nearWU=near,farWU=far,
        fadeWidthWU=16,classifier='minimum original corner camera depth; behind corner keeps full detail',
        farPattern='75% modal + 25% vivid present pigment, screen anchored',
        statistics='runtime texture page; palette-specific deterministic HSV ranking',
        preservesLighting=True,uniformTexturesUnchanged=True,faces=details,
        smc='one JSR/BIT opcode at m7_fetch_end, outside IRQ; address/fetch SMC operands unchanged')
