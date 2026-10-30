"""Exact optional known-shape raster tuning. PolyForm Noncommercial 1.0.0."""
import base64,hashlib,json,re,zlib
MATERIAL=True
MATERIAL_KEEP_POINTERS=False
SHADE_EDGES=True
OUTLINE=True
SAMPLER=True
BULKFILL=True
MATERIAL_CONTEXTS=set(['032d4b2ba4e63aba6537b98a3052eeb18748753dacf6e83524723caefaddf60a', '0a2729c31bf1f6c7d717d24b5b7caa854398f00ee55d95519ddca193da5406e8', '227a2b96bb10e2005bb5f0ce9b55dcf9e7a04ce893bb87f00bb1a0808772fa2a', '27e93c287d5bdab38f8b5405053495231fea24bf409cedce40e9c2858a29b823', '2d5c918913a0333cb85e5221693e37aac9db57fca56e63e212700f7ab0cfc506', '3444d49890499ba60ecf64fee1ead79f53c3d8696392433ee28ff64f885b9033', '36b75b80a862fda76bc6b4f026b61c4265eeef6279bd457f507e8fbc746b71ec', '541bbf6d159dadac14ba34f9e0e00f8d441e7137d6fafc030e29ed345d335187', '6343032c8bb426a31b2903bab0233dc2d44508122f7582e757cd7173d35d5045', '7d5d07de5b1cad764b51305461c67843608d290eb0ada397c7873c8a00892dc5', 'aec2a37a899d2694443dc34ebf5ad97055cf109d1f33b4a68bcfa3b108321d38', 'e49f8ab45677771c1ff66cfb32b2ff6e10fef38f22c995ff3ce59f372ec6968e', 'f4487e995a317811f9d6afd4cf5145ce22422beb5d4c3d23a9bc01c53f23a6b6'])
EDGE_CONTEXTS=set(['0d807d6f9cac25d53972a59ec93cd37c3ef58a12203fd79618dbdc189449f20e', '915cd493f2ecefcd3da2623d981d9f4f0398f4913ff6efb2dc4efe686752b802', 'acd627740f6ec2a7a11c06ecc05721651d6f6ff0d7070a76dbb6331261bc4de9', 'b7f774a889afe9889b7a88badbcbace5c4493a531fa2b3b8e93a1253320a349e'])
MARKER=re.compile(r'; GR17_RENDER_TUNING ([0-9a-f]{64}) ([A-Za-z0-9+/=]+)\n')
MATERIAL_OLD='''apply_material_span_common:
 ldx startbyte
 ldy #$00
ams_loop:
.if VIC_COLOR_POLICY_ENABLE != 0
 jsr vic_color_policy_claim_cell
 bcc ams_skip_write
.endif
 lda material_screen_cur
 sta (ptr0lo),y
 lda material_color_cur
 sta (ptr1lo),y
ams_skip_write:
 cpx endbyte
 beq ams_done
 inc ptr0lo
 bne ams_screen_ok
 inc ptr0hi
ams_screen_ok:
 inc ptr1lo
 bne ams_color_ok
 inc ptr1hi
ams_color_ok:
 inx
 jmp ams_loop
ams_done:
 rts
'''
MATERIAL_NEW='''apply_material_span_common:
 ldx startbyte
 ldy #$00
ams_loop:
 lda material_screen_cur
 sta (ptr0lo),y
 lda material_color_cur
 sta (ptr1lo),y
ams_skip_write:
 cpx endbyte
 beq ams_done
 iny
 inx
 jmp ams_loop
ams_done:
 ; Restore the exact parent pointers, A/X/Y and flags once per span.
 php
 cpy #0
 beq gr17_material_done
 tya
 clc
 adc ptr0lo
 sta ptr0lo
 bcc ams_screen_ok
 inc ptr0hi
ams_screen_ok:
 tya
 clc
 adc ptr1lo
 sta ptr1lo
 bcc ams_color_ok
 inc ptr1hi
ams_color_ok:
gr17_material_done:
 lda material_color_cur
 ldy #0
 plp
 rts
'''
if not MATERIAL_KEEP_POINTERS:
    MATERIAL_NEW=MATERIAL_NEW[:MATERIAL_NEW.index('ams_done:\n')]+'''ams_done:
 ; Both pointers are internal scratch, rebuilt by the next bitmap/material call.
 ; Preserve A/X/Y and all architectural flags; Y=0 also reproduces CPX's Z/N.
 ldy #0
 rts
'''
def call_contexts(s,targets):
    lines=s.splitlines();out=[]
    for i,line in enumerate(lines):
        if re.match(r'\s*(?:jsr|jmp)\s+(?:'+targets+r')\s*$',line):
            out.append(hashlib.sha256('\n'.join(lines[max(0,i-3):i+4]).encode('ascii')).hexdigest())
    return out
def original_source(s):
    matches=list(MARKER.finditer(s))
    if not matches:return s
    assert len(matches)==1;m=matches[0];raw=zlib.decompress(base64.b64decode(m[2]));assert hashlib.sha256(raw).hexdigest()==m[1]
    s=MARKER.sub('',s)
    for r in reversed(json.loads(raw)):
        assert s.count(r['new'])==1,('GR17_RESTORE',r['name'])
        s=s.replace(r['new'],r['old'],1)
    return s
def patch(s):
    s=original_source(s);replacements=[];info=dict(applied=False,material=False,shadeEdges=False,outline=False,sampler=False,newRAMVariables=0,newRAMTables=0,extraPeakDataStackBytes=0)
    def replace(name,old,new):
        nonlocal s
        if s.count(old)!=1:return False
        s=s.replace(old,new,1);replacements.append(dict(name=name,old=old,new=new));return True
    contexts_ok=MATERIAL_KEEP_POINTERS or all(c in MATERIAL_CONTEXTS for c in call_contexts(s,'apply_material_span_[ab](?:_common)?|apply_material_span_common'))
    if MATERIAL and 'VIC_COLOR_POLICY_ENABLE = $00' in s and contexts_ok:
        if replace('indexed-material',MATERIAL_OLD,MATERIAL_NEW):info.update(material=True,extraPeakDataStackBytes=1 if MATERIAL_KEEP_POINTERS else 0,materialScratchPointersVolatile=not MATERIAL_KEEP_POINTERS)
    if SHADE_EDGES and re.search(r'(?m)^GRAPHICS_MODE = \$06$',s):
        a=s.index('gouraud_trace_shade_edge:\n');b=s.index('gouraud_store_edge_sample:\n',a);old=s[a:b]
        # Only known internal calls; preserve external/private helper use.
        y=re.search(r'(?m)^PROJ_SCREEN_MAX_Y = \$([0-9a-fA-F]+)$',s)
        if y and int(y[1],16)<128 and all(c in EDGE_CONTEXTS for c in call_contexts(s,'gouraud_trace_shade_edge')):
            new=old
            init=' lda #$00\n sta gouraud_edge_xerr_lo\n sta gouraud_edge_xerr_hi\n sta gouraud_edge_serr\n'
            setup=''' txa
 pha
 ldx #0
 lda gouraud_edge_dx
gr17_edge_divide:
 cmp gouraud_edge_dy
 bcc gr17_edge_remainder
 sbc gouraud_edge_dy
 inx
 bne gr17_edge_divide
gr17_edge_remainder:
 sta gouraud_edge_dx
 txa
 ldx gouraud_edge_xdir
 bpl gr17_edge_positive
 eor #255
 clc
 adc #1
gr17_edge_positive:
 sta gouraud_edge_xerr_hi
 lda #0
 sta gouraud_edge_xerr_lo
 sta gouraud_edge_serr
 pla
 tax
'''
            x0=new.find(' clc\n lda gouraud_edge_xerr_lo',new.index('gtse_loop:\n'));x1=new.index('gtse_xstep_done:\n',x0)
            step=''' lda gouraud_edge_xerr_hi
 beq gr17_edge_quotient_done
 clc
 adc gouraud_edge_xcur
 sta gouraud_edge_xcur
gr17_edge_quotient_done:
 clc
 lda gouraud_edge_xerr_lo
 adc gouraud_edge_dx
 cmp gouraud_edge_dy
 bcc gr17_edge_no_correction
 sbc gouraud_edge_dy
 sta gouraud_edge_xerr_lo
 clc
 lda gouraud_edge_xcur
 adc gouraud_edge_xdir
 sta gouraud_edge_xcur
 jmp gtse_xstep_done
gr17_edge_no_correction:
 sta gouraud_edge_xerr_lo
'''
            new=new[:x0]+step+new[x1:];assert new.count(init)==1;new=new.replace(init,setup,1)
            done='''gtse_done:
 php
 pha
 sec
 lda gouraud_edge_x1
 sbc gouraud_edge_x0
 bcs gr17_edge_restore_dx
 eor #255
 clc
 adc #1
gr17_edge_restore_dx:
 sta gouraud_edge_dx
 lda #0
 sta gouraud_edge_xerr_hi
 pla
 plp
 rts
'''
            assert new.count('gtse_done:\n rts\n')==1;new=new.replace('gtse_done:\n rts\n',done,1)
            if replace('quotient-shade-edge',old,new):info.update(shadeEdges=True,extraPeakDataStackBytes=max(2,info['extraPeakDataStackBytes']))
    if OUTLINE and re.search(r'(?m)^GRAPHICS_MODE = \$05$',s) and 'lpa_block_projection_exact_end:\n' in s:
        old=''' stx rightval
 sta leftval
 lda mode5_outline_trace_active
 beq ucb_mode5_bounds
 jmp mode5_plot_background_point
ucb_mode5_bounds:
'''
        new=''' stx rightval
 sta leftval
gr17_outline_dispatch:
 jmp ucb_mode5_bounds
ucb_mode5_bounds:
'''
        writers=re.findall(r'(?m)^\s*(sta|stx|sty|inc|dec) mode5_outline_trace_active\s*$',s)
        if s.count(old)==1 and sorted(writers)==['dec','inc']:
            replace('outline-dispatch',old,new)
            for op in ('inc','dec'):
                old=f' {op} mode5_outline_trace_active\n';replace('outline-'+op,old,old+' jsr gr17_select_outline\n')
            code='''gr17_select_outline:
 php
 pha
 lda mode5_outline_trace_active
 beq gr17_outline_normal
 lda #<mode5_plot_background_point
 sta gr17_outline_dispatch+1
 lda #>mode5_plot_background_point
 sta gr17_outline_dispatch+2
 jmp gr17_outline_selected
gr17_outline_normal:
 lda #<ucb_mode5_bounds
 sta gr17_outline_dispatch+1
 lda #>ucb_mode5_bounds
 sta gr17_outline_dispatch+2
gr17_outline_selected:
 pla
 plp
 rts
'''
            end='lpa_block_projection_exact_end:\n';replace('outline-selector',end,code+end);info.update(outline=True,extraPeakDataStackBytes=max(2,info['extraPeakDataStackBytes']))
    if SAMPLER and re.search(r'(?m)^GRAPHICS_MODE = \$07$',s) and 'lp8_fast_m7_full_byte:\n' in s and 'm31_c_transition:\n' in s and 'lpa_block_mode7_immediate_setup_end:\n' in s:
        a=s.index('lp8_fast_m7_full_byte:\n');b=s.index('lpa_block_mode7_immediate_kernel_end:\n',a);body=s[a:b]
        expected='''m7_sample:
m7_address_begin:
 lda p1hi
 and #$f0
 sta m7_index
 lda p1lo
 lsr
 lsr
 lsr
 lsr
 ora m7_index
 tay
m7_fetch:
 lda m7_texture_0,y
m7_fetch_end:
'''
        if expected in s and body.count(' jsr m7_sample\n')==4:
            for i in range(4):
                call=' jsr m7_sample\n';start=body.index(call)
                # A unique adjacent UV label anchors each replacement and makes
                # restoration independent of the parent's biased-UV metadata.
                end=body.find('\n',start+len(call));suffix=body[start+len(call):end+1]
                inline=f''' ; GR17 inline stable-band sampler {i}
 lda p1hi
 and #$f0
 sta m7_index
 lda p1lo
 lsr
 lsr
 lsr
 lsr
 ora m7_index
 tay
gr17_texture_fetch_{i}:
 lda m7_texture_0,y
 tay
 lda gr17_texel_codes,y
'''
                old=call+suffix;new=inline+suffix
                # Restrict the replacement to this particular fast-block site.
                prefix=body[:start];local=body[start:].replace(old,new,1);body=prefix+local
                replacements.append(dict(name=f'inline-sampler-{i}',old=old,new=new))
            s=s[:a]+body+s[b:]
            replace('sampler-prepare','lp8_patch_uv_constants:\n','lp8_patch_uv_constants:\n jsr gr17_prepare_sampler\n')
            helper='gr17_prepare_sampler:\n'
            for byte in (1,2):
                helper+=f' lda m7_fetch+{byte}\n cmp gr17_texture_fetch_0+{byte}\n beq gr17_fetch_same_{byte}\n'+''.join(f' sta gr17_texture_fetch_{i}+{byte}\n' for i in range(4))+f'gr17_fetch_same_{byte}:\n'
            helper+=''' ldy yrow
 lda m3_leftq,y
 cmp #7
 bcc gr17_palette_dark
 cmp #26
 bcs gr17_palette_bright
 lda #1
 bne gr17_palette_select
gr17_palette_dark:
 lda #0
 beq gr17_palette_select
gr17_palette_bright:
 lda #2
gr17_palette_select:
gr17_last_palette:
 cmp #255
 beq gr17_palette_done
 sta gr17_last_palette+1
 cmp #1
 bcc gr17_write_dark
 bne gr17_write_bright
'''
            for i in range(4):helper+=f' lda #{i}\n sta gr17_texel_codes+{i}\n'
            helper+=' rts\ngr17_write_dark:\n'
            for i,v in enumerate((0,1,1,2)):helper+=f' lda #{v}\n sta gr17_texel_codes+{i}\n'
            helper+=' rts\ngr17_write_bright:\n'
            for i,v in enumerate((1,2,3,3)):helper+=f' lda #{v}\n sta gr17_texel_codes+{i}\n'
            helper+='gr17_palette_done:\n rts\ngr17_texel_codes:\n .byte 0,1,2,3\n'
            end='lpa_block_mode7_immediate_setup_end:\n';replace('sampler-helpers',end,helper+end);info.update(sampler=True,newRAMTables=1,newRAMTableBytes=4)
    if BULKFILL and re.search(r'(?m)^GRAPHICS_MODE = \$0[3456]$',s) and 'lpa_block_projection_exact_end:\n' in s:
        loops=[]
        for prefix in ('dfsp','fbs_a','fbs_b','fbp_a','fbp_b'):
            old=f'''{prefix}_indexed_mid_loop:
 sta (ptr0lo),y
 sta (ptr1lo),y
 tya
 adc #$08
 tay
 lda fillbyte
 dex
 bne {prefix}_indexed_mid_loop
 stx p1hi
'''
            if s.count(old)==1:loops.append((prefix,old))
        if loops:
            for prefix,old in loops:
                new=f''' ; GR17: long interior spans share an exact descending unrolled writer.
 cpx #5
 bcc {prefix}_indexed_mid_loop
 jsr gr17_fill_interior
 jmp {prefix}_gr17_mid_done
'''+old+f'{prefix}_gr17_mid_done:\n'
                replace('bulk-'+prefix,old,new)
            helper='''gr17_fill_interior:
 lda gr17_fill_entry_lo,x
 sta gr17_fill_jump+1
 lda gr17_fill_entry_hi,x
 sta gr17_fill_jump+2
 lda fillbyte
gr17_fill_jump:
 jmp gr17_fill_1
'''
            for n in range(30,0,-1):helper+=f'gr17_fill_{n}:\n ldy #{8*n}\n sta (ptr0lo),y\n sta (ptr1lo),y\n'
            helper+=''' ldx #0
 stx p1hi
 lda fullcount
 asl
 asl
 asl
 tay
 lda fillbyte
 clc
 rts
gr17_fill_entry_lo:
 .byte 0,'''+','.join(f'<gr17_fill_{n}' for n in range(1,31))+'''
gr17_fill_entry_hi:
 .byte 0,'''+','.join(f'>gr17_fill_{n}' for n in range(1,31))+'\n'
            end='lpa_block_projection_exact_end:\n';replace('bulk-helper',end,helper+end);info.update(bulkFill=True,bulkInteriorThreshold=5,newRAMTables=info.get('newRAMTables',0)+2,newRAMTableBytes=info.get('newRAMTableBytes',0)+62)
    if replacements:
        raw=json.dumps(replacements,sort_keys=True,separators=(',',':')).encode('ascii');s+='; GR17_RENDER_TUNING '+hashlib.sha256(raw).hexdigest()+' '+base64.b64encode(zlib.compress(raw,9)).decode('ascii')+'\n';info['applied']=True
    return s,info
if __name__=='__main__':
    import argparse
    from pathlib import Path
    p=argparse.ArgumentParser();p.add_argument('asm',type=Path);a=p.parse_args();s=a.asm.read_text(encoding='utf-8-sig');s,info=patch(s);a.asm.write_bytes(s.encode('ascii'));a.asm.with_suffix('.render-tuning.json').write_text(json.dumps(info,indent=2)+'\n')
