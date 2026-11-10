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
    from legacy_mode7_table import strip as strip_mode7_table
    s=strip_mode7_table(s)
    matches=list(MARKER.finditer(s))
    if not matches:return s
    from legacy_gouraud_zp import strip
    s=strip(s)
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
    # GR19: only the existing known volatile-pointer material contexts.
    # All pointer producers and the consumer are replaced atomically.
    if info['material'] and not MATERIAL_KEEP_POINTERS:
        row_templates=[]
        row_templates.append(('apply_material_span_a:\n ldx yrow\n lda screenrowlo_a,x\n clc\n adc startbyte\n sta ptr0lo\n lda screenrowhi_a,x\n adc #$00\n sta ptr0hi\n lda colorrowlo,x\n clc\n adc startbyte\n sta ptr1lo\n lda colorrowhi,x\n adc #$00\n sta ptr1hi\n','apply_material_span_a:\n ldx yrow\n lda screenrowlo_a,x\n sta ptr0lo\n lda screenrowhi_a,x\n sta ptr0hi\n lda colorrowlo,x\n sta ptr1lo\n lda colorrowhi,x\n sta ptr1hi\n ; Parent high-byte ADC #0 always clears V in the known screen/color banks.\n clv\n'))
        row_templates.append(('apply_material_span_b:\n ldx yrow\n lda screenrowlo_b,x\n clc\n adc startbyte\n sta ptr0lo\n lda screenrowhi_b,x\n adc #$00\n sta ptr0hi\n lda colorrowlo,x\n clc\n adc startbyte\n sta ptr1lo\n lda colorrowhi,x\n adc #$00\n sta ptr1hi\n','apply_material_span_b:\n ldx yrow\n lda screenrowlo_b,x\n sta ptr0lo\n lda screenrowhi_b,x\n sta ptr0hi\n lda colorrowlo,x\n sta ptr1lo\n lda colorrowhi,x\n sta ptr1hi\n ; Parent high-byte ADC #0 always clears V in the known screen/color banks.\n clv\n'))
        row_consumer='apply_material_span_common:\n ldy startbyte\nams_loop:\n lda material_screen_cur\n sta (ptr0lo),y\n lda material_color_cur\n sta (ptr1lo),y\nams_skip_write:\n cpy endbyte\n beq ams_done\n iny\n jmp ams_loop\nams_done:\n ldx endbyte\n ldy #0\n rts\n'
        if all(s.count(old)==1 for old,new in row_templates) and s.count(MATERIAL_NEW)==1:
            for i,(old,new) in enumerate(row_templates):replace('row-origin-material-'+str(i),old,new)
            replace('row-origin-material-writer',MATERIAL_NEW,row_consumer)
            info.update(materialRowOrigin=True,materialPointersPrivateVolatile=True,materialCellIndexInY=True)
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
    # GR28: inline stable-band samplers do not read the pixel cursor.
    # Publish the three completed sample steps once, before sample3.
    if info.get('sampler'):
        a=s.index('lp8_fast_m7_full_byte:\n');b=s.index('lpa_block_mode7_immediate_kernel_end:\n',a);body=s[a:b]
        if body.count(' inc gouraud_scan_x\n')==4:
            new=body.replace(' inc gouraud_scan_x\n','',2)
            new=new.replace(' inc gouraud_scan_x\n',' clc\n lda gouraud_scan_x\n adc #3\n sta gouraud_scan_x\n',1)
            if replace('stable-sampler-cursor-batch',body,new):info.update(stableSamplerCursorBatch=True,exactFinalCursor=True)
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
    # GR18: exact quotient/remainder DDA for the known consolidated wire walker.
    # Existing private dxabs/errhi hold remainder/quotient while the edge runs.
    # Both are restored before the final flush. No RAM tables or extra stack.
    wire_y=re.search(r'(?m)^PROJ_SCREEN_MAX_Y = \$([0-9a-fA-F]+)$',s)
    if 'WIRE_RENDER_ENABLE = $01' in s and 'ENGINE_WIRE_RASTER_CONSOLIDATION = $01' in s and wire_y and int(wire_y[1],16)<128:
        changed=[]
        if replace("wire-quotient-tec_lspan_pos",'tec_lspan_pos:\n lda xcur\n sta spanw\n sta spanh\n lda ycur\n cmp ey0\n beq tec_lspan_pos_done\n clc\n lda errlo\n adc dxabs\n sta errlo\n lda errhi\n adc #$00\n sta errhi\ntec_lspan_pos_check:\n lda errhi\n bne tec_lspan_pos_x\n lda errlo\n cmp dyval\n bcc tec_lspan_pos_y\ntec_lspan_pos_x:\n sec\n lda errlo\n sbc dyval\n sta errlo\n lda errhi\n sbc #$00\n sta errhi\n inc xcur\n lda xcur\n sta spanh\n jmp tec_lspan_pos_check\ntec_lspan_pos_y:\n jsr tec_flush_span\n inc ycur\n jmp tec_lspan_pos\ntec_lspan_pos_done:\n jsr tec_flush_span\n rts\n','tec_lspan_pos:\n lda dxabs\n ldx #0\ntec_lspan_pos_divide:\n cmp dyval\n bcc tec_lspan_pos_remainder\n sbc dyval\n inx\n bne tec_lspan_pos_divide\ntec_lspan_pos_remainder:\n sta dxabs\n stx errhi\ntec_lspan_pos_row:\n lda xcur\n sta spanw\n sta spanh\n lda ycur\n cmp ey0\n beq tec_lspan_pos_done\n clc\n lda errlo\n adc dxabs\n cmp dyval\n bcc tec_lspan_pos_no_correction\n sbc dyval\ntec_lspan_pos_no_correction:\n sta errlo\n lda xcur\n adc errhi\n sta xcur\n sta spanh\n clv\n jsr tec_flush_span\n inc ycur\n jmp tec_lspan_pos_row\ntec_lspan_pos_done:\n sec\n lda ex0\n sbc ex1\n sta dxabs\n lda #0\n sta errhi\n clv\n jsr tec_flush_span\n rts\n'):changed.append("tec_lspan_pos")
        if replace("wire-quotient-tec_lspan_neg",'tec_lspan_neg:\n lda xcur\n sta spanw\n sta spanh\n lda ycur\n cmp ey0\n beq tec_lspan_neg_done\n clc\n lda errlo\n adc dxabs\n sta errlo\n lda errhi\n adc #$00\n sta errhi\ntec_lspan_neg_check:\n lda errhi\n bne tec_lspan_neg_x\n lda errlo\n cmp dyval\n bcc tec_lspan_neg_y\ntec_lspan_neg_x:\n sec\n lda errlo\n sbc dyval\n sta errlo\n lda errhi\n sbc #$00\n sta errhi\n dec xcur\n lda xcur\n sta spanw\n jmp tec_lspan_neg_check\ntec_lspan_neg_y:\n jsr tec_flush_span\n inc ycur\n jmp tec_lspan_neg\ntec_lspan_neg_done:\n jsr tec_flush_span\n rts\n','tec_lspan_neg:\n lda dxabs\n ldx #0\ntec_lspan_neg_divide:\n cmp dyval\n bcc tec_lspan_neg_remainder\n sbc dyval\n inx\n bne tec_lspan_neg_divide\ntec_lspan_neg_remainder:\n sta dxabs\n stx errhi\ntec_lspan_neg_row:\n lda xcur\n sta spanw\n sta spanh\n lda ycur\n cmp ey0\n beq tec_lspan_neg_done\n clc\n lda errlo\n adc dxabs\n cmp dyval\n bcc tec_lspan_neg_no_correction\n sbc dyval\n sta errlo\n lda xcur\n clc\n sbc errhi\n jmp tec_lspan_neg_advanced\ntec_lspan_neg_no_correction:\n sta errlo\n lda xcur\n sec\n sbc errhi\ntec_lspan_neg_advanced:\n sta xcur\n sta spanw\n clv\n jsr tec_flush_span\n inc ycur\n jmp tec_lspan_neg_row\ntec_lspan_neg_done:\n sec\n lda ex1\n sbc ex0\n sta dxabs\n lda #0\n sta errhi\n clv\n jsr tec_flush_span\n rts\n'):changed.append("tec_lspan_neg")
        if replace("wire-quotient-tec_rspan_pos",'tec_rspan_pos:\n lda xcur\n sta spanw\n sta spanh\n lda ycur\n cmp ey1\n beq tec_rspan_pos_done\n clc\n lda errlo\n adc dxabs\n sta errlo\n lda errhi\n adc #$00\n sta errhi\ntec_rspan_pos_check:\n lda errhi\n bne tec_rspan_pos_x\n lda errlo\n cmp dyval\n bcc tec_rspan_pos_y\ntec_rspan_pos_x:\n sec\n lda errlo\n sbc dyval\n sta errlo\n lda errhi\n sbc #$00\n sta errhi\n inc xcur\n lda xcur\n sta spanh\n jmp tec_rspan_pos_check\ntec_rspan_pos_y:\n jsr tec_flush_span\n inc ycur\n jmp tec_rspan_pos\ntec_rspan_pos_done:\n jsr tec_flush_span\n rts\n','tec_rspan_pos:\n lda dxabs\n ldx #0\ntec_rspan_pos_divide:\n cmp dyval\n bcc tec_rspan_pos_remainder\n sbc dyval\n inx\n bne tec_rspan_pos_divide\ntec_rspan_pos_remainder:\n sta dxabs\n stx errhi\ntec_rspan_pos_row:\n lda xcur\n sta spanw\n sta spanh\n lda ycur\n cmp ey1\n beq tec_rspan_pos_done\n clc\n lda errlo\n adc dxabs\n cmp dyval\n bcc tec_rspan_pos_no_correction\n sbc dyval\ntec_rspan_pos_no_correction:\n sta errlo\n lda xcur\n adc errhi\n sta xcur\n sta spanh\n clv\n jsr tec_flush_span\n inc ycur\n jmp tec_rspan_pos_row\ntec_rspan_pos_done:\n sec\n lda ex1\n sbc ex0\n sta dxabs\n lda #0\n sta errhi\n clv\n jsr tec_flush_span\n rts\n'):changed.append("tec_rspan_pos")
        if replace("wire-quotient-tec_rspan_neg",'tec_rspan_neg:\n lda xcur\n sta spanw\n sta spanh\n lda ycur\n cmp ey1\n beq tec_rspan_neg_done\n clc\n lda errlo\n adc dxabs\n sta errlo\n lda errhi\n adc #$00\n sta errhi\ntec_rspan_neg_check:\n lda errhi\n bne tec_rspan_neg_x\n lda errlo\n cmp dyval\n bcc tec_rspan_neg_y\ntec_rspan_neg_x:\n sec\n lda errlo\n sbc dyval\n sta errlo\n lda errhi\n sbc #$00\n sta errhi\n dec xcur\n lda xcur\n sta spanw\n jmp tec_rspan_neg_check\ntec_rspan_neg_y:\n jsr tec_flush_span\n inc ycur\n jmp tec_rspan_neg\ntec_rspan_neg_done:\n jsr tec_flush_span\n rts\n','tec_rspan_neg:\n lda dxabs\n ldx #0\ntec_rspan_neg_divide:\n cmp dyval\n bcc tec_rspan_neg_remainder\n sbc dyval\n inx\n bne tec_rspan_neg_divide\ntec_rspan_neg_remainder:\n sta dxabs\n stx errhi\ntec_rspan_neg_row:\n lda xcur\n sta spanw\n sta spanh\n lda ycur\n cmp ey1\n beq tec_rspan_neg_done\n clc\n lda errlo\n adc dxabs\n cmp dyval\n bcc tec_rspan_neg_no_correction\n sbc dyval\n sta errlo\n lda xcur\n clc\n sbc errhi\n jmp tec_rspan_neg_advanced\ntec_rspan_neg_no_correction:\n sta errlo\n lda xcur\n sec\n sbc errhi\ntec_rspan_neg_advanced:\n sta xcur\n sta spanw\n clv\n jsr tec_flush_span\n inc ycur\n jmp tec_rspan_neg_row\ntec_rspan_neg_done:\n sec\n lda ex0\n sbc ex1\n sta dxabs\n lda #0\n sta errhi\n clv\n jsr tec_flush_span\n rts\n'):changed.append("tec_rspan_neg")
        if changed:info.update(wireQuotientSpans=changed,wireQuotientScratchRestored=True,wirePixelSequenceUnchanged=True)
    # GR18: exact unsigned clipping scale, including parent scratch/flags.
    # Optional circle builds retain the parent divider and its code layout.
    # The extra byte-path code crossed a PAL budget in the public Mode6 API.
    circle_api=bool(re.search(r"(?m)^ENGINE_CIRCLE_SPHERES\s*=\s*(?:1|\$0*1)\s*$",s))
    if not circle_api and replace("clipping-ratio-byte",'crts_fraction:\n lda clip_num16_lo\n sta prodlo\n lda clip_num16_hi\n sta prodhi\n lda #$00\n sta clip_rem_ext\n sta scalev\n ldx #$08\ncrts_loop:\n asl prodlo\n rol prodhi\n lda #$00\n rol clip_rem_ext\n lda clip_rem_ext\n bne crts_subtract\n lda prodhi\n cmp clip_den16_hi\n bcc crts_no_subtract\n bne crts_subtract\n lda prodlo\n cmp clip_den16_lo\n bcc crts_no_subtract\ncrts_subtract:\n sec\n lda prodlo\n sbc clip_den16_lo\n sta prodlo\n lda prodhi\n sbc clip_den16_hi\n sta prodhi\n lda clip_rem_ext\n sbc #$00\n sta clip_rem_ext\n sec\n jmp crts_shift_result\ncrts_no_subtract:\n clc\ncrts_shift_result:\n rol scalev\n dex\n bne crts_loop\n rts\n','crts_fraction:\n lda clip_num16_lo\n sta prodlo\n lda clip_num16_hi\n sta prodhi\n lda #$00\n sta clip_rem_ext\n sta scalev\n lda clip_den16_hi\n bne gr18_crts_wide\n ; num<den<=255, so a byte remainder in A is sufficient.\n lda prodlo\n ldx #$08\ngr18_crts_byte:\n asl a\n bcs gr18_crts_byte_sub\n cmp clip_den16_lo\n bcc gr18_crts_byte_shift\ngr18_crts_byte_sub:\n sbc clip_den16_lo\n clv\n sec\ngr18_crts_byte_shift:\n rol scalev\n dex\n bne gr18_crts_byte\n sta prodlo\n ; Match the parent accumulator and architectural flag poststate.\n lda scalev\n and #1\n beq gr18_crts_byte_a_remainder\n lda #0\n jmp gr18_crts_byte_return\ngr18_crts_byte_a_remainder:\n lda prodlo\ngr18_crts_byte_return:\n ldx #0\n clc\n rts\ngr18_crts_wide:\n ldx #$08\ncrts_loop:\n asl prodlo\n rol prodhi\n ; The shifted carry is the full seventeenth remainder bit.\n bcs crts_subtract\n lda prodhi\n cmp clip_den16_hi\n bcc crts_no_subtract\n bne crts_subtract\n lda prodlo\n cmp clip_den16_lo\n bcc crts_no_subtract\ncrts_subtract:\n sec\n lda prodlo\n sbc clip_den16_lo\n sta prodlo\n lda prodhi\n sbc clip_den16_hi\n sta prodhi\n ; With remainder<den, one subtraction clears the seventeenth bit.\n lda #0\n clv\n sec\n jmp crts_shift_result\ncrts_no_subtract:\n clc\ncrts_shift_result:\n rol scalev\n dex\n bne crts_loop\n rts\n'):
        info.update(clippingRatioByte=True,clippingRatioCarry17=True)
    # GR19: table-proven physical row1=row0+1 and even row0/x offsets.
    # Private row1lo/row1hi scratch is not published by the selected fillers.
    from legacy_wire_cursor import proven as adjacent_rows_proven,table as read_byte_table
    even_tables=[read_byte_table(s,'row0lo_'+b) for b in 'ab']+[read_byte_table(s,'xofflo')]
    if adjacent_rows_proven(s) and all(t and all(v%2==0 for v in t) for t in even_tables):
        changed=[]
        for bank in 'ab':
            for name,done in [('direct_fill_span_solid_','dfs_'),('fill_bounds_solid_','fbs_'),('fill_bounds_pattern_','fbp_')]:
                first=name+bank+':\n';last=done+bank+'_done:\n rts\n'
                if s.count(first)!=1 or s.count(last)!=1:continue
                a=s.index(first);b=s.index(last,a)+len(last);old=s[a:b]
                producer=' lda row1lo_'+bank+',x\n sta row1lo\n lda row1hi_'+bank+',x\n sta row1hi\n'
                consumer=' lda row1lo\n clc\n adc xofflo,x\n sta ptr1lo\n lda row1hi\n adc xoffhi,x\n sta ptr1hi\n'
                if old.count(producer)!=1 or old.count(consumer)!=1:continue
                base=' lda row0lo_'+bank+',x\n sta row0lo\n lda row0hi_'+bank+',x\n sta row0hi\n'
                first_pointer=' ldx leftval\n lda row0lo\n clc\n adc xofflo,x\n sta ptr0lo\n lda row0hi\n adc xoffhi,x\n sta ptr0hi\n'
                indexed_pointer=' ldy yrow\n ldx leftval\n lda row0lo_'+bank+',y\n clc\n adc xofflo,x\n sta ptr0lo\n lda row0hi_'+bank+',y\n adc xoffhi,x\n sta ptr0hi\n'
                if old.count(base)!=1 or old.count(first_pointer)!=1:continue
                new=old.replace(producer,'',1).replace(base,'',1).replace(first_pointer,indexed_pointer,1).replace(consumer,' lda ptr0lo\n ora #1\n sta ptr1lo\n lda ptr0hi\n sta ptr1hi\n',1)
                if re.search(r'\brow0(?:lo|hi)\b',new):continue
                if re.search(r'\brow1(?:lo|hi)\b',new):continue
                if replace('bitmap-adjacent-'+name+bank,old,new):changed.append(name+bank)
        if changed:info.update(bitmapAdjacentRows=changed,bitmapRowAdjacencyAndEvenOffsetsProven=True,bitmapRow1ScratchVolatile=True)
    # GR20: known clipped-only fan path; unknown callers/layouts retain parent.
    circle_api=bool(re.search(r"(?m)^ENGINE_CIRCLE_SPHERES\s*=\s*(?:1|\$0*1)\s*$",s))
    callers=re.findall(r'(?m)^\s*(?:jsr|jmp|bne|beq) draw_clip_poly_gouraud\s*$',s)
    if re.search(r'(?m)^GRAPHICS_MODE = \$0[67]$',s) and not circle_api and 'LAZY_CONVEX_BOUNDS = $00' in s and len(callers)==1 and callers[0].strip()=='bne draw_clip_poly_gouraud':
        if ' lda clip_poly_active\n bne draw_clip_poly_gouraud\n' in s and 'gr15_init:\n lda #255\n sta leftb,x\n lda #0\n sta rightb,x\n' in s:
            if replace("clipped-fan-bounds-once",'dcpg_loop:\n jsr load_clip_poly_fan_triangle\n jsr build_loaded_face_bounds_convex\n ; GR15_FUSED_EDGE_CALL\n jsr gr15_build_edges\n jsr gouraud_fill_bounds\n','dcpg_loop:\n jsr load_clip_poly_fan_triangle\n ; GR20: the known clipped/synthetic path is never eligible for raw XYQ2.\n ; gr15 reinitializes every consumed row and rebuilds all X/U/V/Q edges.\n.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0\n lda #1\n sta xyq2_face_valid\n.endif\n jsr setup_face_y_bounds\n ; GR15_FUSED_EDGE_CALL\n jsr gr15_build_edges\n jsr gouraud_fill_bounds\n'):info.update(clippedFanBoundsOnce=True,clippedFanOrderUnchanged=True,rawXYQ2PathUnchanged=True)
    # GR20: validity-only raw prefix when all original arithmetic is bounded.
    if info.get('clippedFanBoundsOnce') and 'SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y = $01' in s and 'FACE_SOLID_COLOR_ENABLE = $00' in s and 'WIRE_RENDER_ENABLE = $00' in s and 'HAS_TRI_FACES = $01' in s and 'PROJ_SCREEN_MAX_X = $9F' in s:
        raw_old=' jsr build_loaded_face_bounds\n.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0\n lda xyq2_face_valid\n beq dlfg_done\n.endif\n ; GR15_FUSED_EDGE_CALL\n jsr gr15_build_edges\n'
        raw_new=' jsr gr20_prepare_raw_validity\n.if SOLID_SUBPIXEL_XYQ2_LEGACY_DIRECT_Y != 0\n lda xyq2_face_valid\n beq dlfg_done\n.endif\n ; GR15_FUSED_EDGE_CALL\n jsr gr15_build_edges\n'
        raw_helper='YQ2_VIEWPORT_MAX_NATIVE = (YQ2_VIEWPORT_MAX_HI * 256 + YQ2_VIEWPORT_MAX_LO)\ngr20_prepare_raw_validity:\n jsr mobile_yq2_face_eligible\n bcs gr20_raw_eligible\n jmp build_loaded_face_bounds\ngr20_raw_eligible:\n lda vxq2_0hi\n cmp #2\n bcc gr20_raw_x_ok_0\n jmp build_loaded_face_bounds\ngr20_raw_x_ok_0:\n lda vyq2_0hi\n cmp #>YQ2_VIEWPORT_MAX_NATIVE\n bcc gr20_raw_y_ok_0\n beq gr20_raw_y_high_0\n jmp build_loaded_face_bounds\ngr20_raw_y_high_0:\n lda vyq2_0lo\n cmp #(<YQ2_VIEWPORT_MAX_NATIVE + 1)\n bcc gr20_raw_y_ok_0\n jmp build_loaded_face_bounds\ngr20_raw_y_ok_0:\n lda vxq2_1hi\n cmp #2\n bcc gr20_raw_x_ok_1\n jmp build_loaded_face_bounds\ngr20_raw_x_ok_1:\n lda vyq2_1hi\n cmp #>YQ2_VIEWPORT_MAX_NATIVE\n bcc gr20_raw_y_ok_1\n beq gr20_raw_y_high_1\n jmp build_loaded_face_bounds\ngr20_raw_y_high_1:\n lda vyq2_1lo\n cmp #(<YQ2_VIEWPORT_MAX_NATIVE + 1)\n bcc gr20_raw_y_ok_1\n jmp build_loaded_face_bounds\ngr20_raw_y_ok_1:\n lda vxq2_2hi\n cmp #2\n bcc gr20_raw_x_ok_2\n jmp build_loaded_face_bounds\ngr20_raw_x_ok_2:\n lda vyq2_2hi\n cmp #>YQ2_VIEWPORT_MAX_NATIVE\n bcc gr20_raw_y_ok_2\n beq gr20_raw_y_high_2\n jmp build_loaded_face_bounds\ngr20_raw_y_high_2:\n lda vyq2_2lo\n cmp #(<YQ2_VIEWPORT_MAX_NATIVE + 1)\n bcc gr20_raw_y_ok_2\n jmp build_loaded_face_bounds\ngr20_raw_y_ok_2:\n lda loaded_face_vertex_count\n cmp #4\n bne gr20_raw_valid_domain\n lda vxq2_3hi\n cmp #2\n bcc gr20_raw_x_ok_3\n jmp build_loaded_face_bounds\ngr20_raw_x_ok_3:\n lda vyq2_3hi\n cmp #>YQ2_VIEWPORT_MAX_NATIVE\n bcc gr20_raw_y_ok_3\n beq gr20_raw_y_high_3\n jmp build_loaded_face_bounds\ngr20_raw_y_high_3:\n lda vyq2_3lo\n cmp #(<YQ2_VIEWPORT_MAX_NATIVE + 1)\n bcc gr20_raw_y_ok_3\n jmp build_loaded_face_bounds\ngr20_raw_y_ok_3:\ngr20_raw_valid_domain:\n ; X in0..511 and Y in the native viewport: no original walker domain fault.\n ; A connected closed polygon crosses every sample Y between its extrema.\n ; The original builder accepts any one sampled edge point (left<=right).\n tsx\n stx xyq2_builder_sp\n lda #0\n sta xyq2_face_valid\n sta xyq2_faulted\n jsr setup_face_y_bounds_xyq2\n bcc gr20_raw_valid_done\n lda #1\n sta xyq2_face_valid\ngr20_raw_valid_done:\n rts\n'
        anchor='lpa_block_projection_exact_end:\n'
        if s.count(raw_old)==1 and s.count(anchor)==1:
            replace('raw-validity-prefix',raw_old,raw_new)
            replace('raw-validity-helper',anchor,raw_helper+anchor)
            info.update(rawQ2ValidityOnly=True,rawValidityMaximumNativeX=511,rawOutOfDomainFallback=True,rawXYQ2PathUnchanged=False)
    # GR21 exact integer convex bounds; raw native Q2 walker is untouched.
    if re.search(r'(?m)^GRAPHICS_MODE = \$06$',s) and not circle_api and all(n+' = $00' in s for n in ['WIRE_RENDER_ENABLE','MODE5_POLYGON_OUTLINE','LAZY_CONVEX_BOUNDS','ENGINE_MODE1_WIRE_POINT_DIRECT_ENTRY','ENGINE_WIRE_SCANLINE_RUN_RASTERIZER']):
        start=s.find('trace_edge_convex:\n');end=s.find('tec_horizontal:\n',start)
        if start>=0 and end>start:
            body=s[start:end]
            if hashlib.sha256(body.encode('ascii')).hexdigest()=='695c8342b5e3a1807cab12fd5790b1bd80450f96bfead898059c10270af24c52':
                replace('mode6-quotient-convex-bounds',body,"trace_edge_convex:\n ; GR21: integer coverage only. Preserve diagonal's single-point rows.\n lda ey0\n cmp ey1\n bcc gr21_forward\n bne gr21_reverse\n jmp tec_horizontal\ngr21_reverse:\n lda ex1\n sta xcur\n lda ey1\n sta ycur\n lda ey0\n sta spanw\n sec\n sbc ey1\n sta dyval\n sec\n lda ex0\n sbc ex1\n jmp gr21_delta\ngr21_forward:\n lda ex0\n sta xcur\n lda ey0\n sta ycur\n lda ey1\n sta spanw\n sec\n sbc ey0\n sta dyval\n sec\n lda ex1\n sbc ex0\ngr21_delta:\n ldx #1\n bcs gr21_abs_ready\n eor #255\n clc\n adc #1\n ldx #255\ngr21_abs_ready:\n stx sxstep\n sta dxabs\n beq gr21_point_rows\n cmp dyval\n beq gr21_diagonal\n ldx dyval\n cpx #1\n bne gr21_divide_init\n tax\n lda #0\n beq gr21_divided\ngr21_divide_init:\n ldx #0\ngr21_divide:\n cmp dyval\n bcc gr21_divided\n sbc dyval\n inx\n bne gr21_divide\ngr21_divided:\n sta dxabs\n txa\n ldx sxstep\n bpl gr21_quotient\n eor #255\n clc\n adc #1\ngr21_quotient:\n sta errhi\n lda #0\n sta errlo\n lda sxstep\n bmi gr21_rows_negative\ngr21_rows_positive:\n ldx ycur\n lda xcur\n cmp leftb,x\n bcs gr21_positive_left\n sta leftb,x\ngr21_positive_left:\n lda ycur\n cmp spanw\n beq gr21_positive_right\n clc\n lda errlo\n adc dxabs\n bcs gr21_positive_correct\n cmp dyval\n bcc gr21_positive_no_correct\ngr21_positive_correct:\n sbc dyval\n sta errlo\n clc\n lda xcur\n adc errhi\n adc #1\n sta xcur\n jmp gr21_positive_right\ngr21_positive_no_correct:\n sta errlo\n clc\n lda xcur\n adc errhi\n sta xcur\ngr21_positive_right:\n lda xcur\n cmp rightb,x\n bcc gr21_positive_next\n sta rightb,x\ngr21_positive_next:\n lda ycur\n cmp spanw\n beq gr21_done\n inc ycur\n jmp gr21_rows_positive\ngr21_rows_negative:\n ldx ycur\n lda xcur\n cmp rightb,x\n bcc gr21_negative_right\n sta rightb,x\ngr21_negative_right:\n lda ycur\n cmp spanw\n beq gr21_negative_left\n clc\n lda errlo\n adc dxabs\n bcs gr21_negative_correct\n cmp dyval\n bcc gr21_negative_no_correct\ngr21_negative_correct:\n sbc dyval\n sta errlo\n clc\n lda xcur\n adc errhi\n sec\n sbc #1\n sta xcur\n jmp gr21_negative_left\ngr21_negative_no_correct:\n sta errlo\n clc\n lda xcur\n adc errhi\n sta xcur\ngr21_negative_left:\n lda xcur\n cmp leftb,x\n bcs gr21_negative_next\n sta leftb,x\ngr21_negative_next:\n lda ycur\n cmp spanw\n beq gr21_done\n inc ycur\n jmp gr21_rows_negative\ngr21_diagonal:\n ldx ycur\n lda xcur\n cmp leftb,x\n bcs gr21_diagonal_left\n sta leftb,x\ngr21_diagonal_left:\n cmp rightb,x\n bcc gr21_diagonal_right\n sta rightb,x\ngr21_diagonal_right:\n lda ycur\n cmp spanw\n beq gr21_done\n inc ycur\n clc\n lda xcur\n adc sxstep\n sta xcur\n jmp gr21_diagonal\ngr21_point_rows:\n ldx ycur\n lda xcur\n cmp leftb,x\n bcs gr21_point_left\n sta leftb,x\ngr21_point_left:\n cmp rightb,x\n bcc gr21_point_right\n sta rightb,x\ngr21_point_right:\n lda ycur\n cmp spanw\n beq gr21_done\n inc ycur\n jmp gr21_point_rows\ngr21_done:\n rts\n")
                info.update(integerBoundsQuotientRemainder=True,rawQ2BoundsUnchanged=True,diagonalCoveragePreserved=True)
    if info.get('integerBoundsQuotientRemainder') and info.get('shadeEdges') and set(call_contexts(s,'gouraud_store_edge_sample'))=={'7a0c0279f0607f2120e852676f41beaeaf17ab3b10856618e4266a399cd65f9d', 'e2247f7d0eeb83b3007c0a029f4a6959756f54f8904f227416b1ccfe94f4d964', '75120b219428fa329771aa7c600237dbf1cf46579605149ea9dbfaa930a6b672'}:
        if s.count('gses_in_range:\n tax\n sec\n lda gouraud_edge_xcur\n sbc leftb,x\n')==1 and s.count(' cmp p1lo\n bcc gses_right\n lda gouraud_edge_scur\n sta leftshade,x\n')==1:
            replace('midpoint-shade-sample', 'gses_in_range:\n tax\n sec\n lda gouraud_edge_xcur\n sbc leftb,x\n', 'gses_in_range:\n tax\n lda leftb,x\n cmp rightb,x\n beq gr21_shade_left\n bcs gr21_shade_unordered\n ; Unsigned 9-bit average: ROR consumes the sum carry, avoiding overflow.\n clc\n adc rightb,x\n ror\n cmp gouraud_edge_xcur\n bcc gses_right\n jmp gr21_shade_left\ngr21_shade_unordered:\n sec\n lda gouraud_edge_xcur\n sbc leftb,x\n')
            replace('midpoint-shade-left', ' cmp p1lo\n bcc gses_right\n lda gouraud_edge_scur\n sta leftshade,x\n', ' cmp p1lo\n bcc gses_right\ngr21_shade_left:\n lda gouraud_edge_scur\n sta leftshade,x\n')
            info.update(shadeSampleMidpointExact=True,unorderedAndCoincidentBoundsPreserved=True)
    if info.get('shadeSampleMidpointExact'):
        if s.count('gbes_edges:\n lda vx0\n sta gouraud_edge_x0\n')==1 and s.count('gouraud_build_edge_shades:\n ldx face_ymin\ngbes_init:\n lda gouraud_vshade0\n sta leftshade,x\n')==1:
            replace('constant-shade-face', 'gbes_edges:\n lda vx0\n sta gouraud_edge_x0\n', 'gbes_edges:\n ; Initialization already wrote this exact constant to both shade arrays.\n lda gouraud_vshade0\n cmp gouraud_vshade1\n bne gr21_shade_varying\n cmp gouraud_vshade2\n bne gr21_shade_varying\n.if HAS_TRI_FACES != 0\n lda loaded_face_vertex_count\n cmp #4\n bne gr21_shade_constant_done\n lda gouraud_vshade0\n.endif\n cmp gouraud_vshade3\n bne gr21_shade_varying\ngr21_shade_constant_done:\n rts\ngr21_shade_varying:\n lda vx0\n sta gouraud_edge_x0\n')
            replace('shade-init-invariant', 'gouraud_build_edge_shades:\n ldx face_ymin\ngbes_init:\n lda gouraud_vshade0\n sta leftshade,x\n', 'gouraud_build_edge_shades:\n lda gouraud_vshade0\n ldx face_ymin\ngbes_init:\n sta leftshade,x\n')
            info.update(constantShadeFaceEarlyCompletion=True,shadeInitializerInvariantHoisted=True)
    # GR22: skip only a span contained by an actually written full span.
    # Row grouping is proven from emitted screen/color tables, never assumed.
    if re.search(r'(?m)^GRAPHICS_MODE = \$0[12]$',s) and info.get('materialRowOrigin') and not circle_api and 'MATERIAL_CELL_SPAN_CACHE = $00' in s and 'ENGINE_CAMERA_VIEWPORT_SMALL = $00' in s:
        from legacy_wire_cursor import table as material_table
        arrays=[material_table(s,n) for n in ['screenrowlo_a','screenrowhi_a','screenrowlo_b','screenrowhi_b','colorrowlo','colorrowhi']]
        grouped=all(a is not None and len(a)>0 and all(a[i]==a[i&252] for i in range(len(a))) for a in arrays)
        grouped=grouped and len({len(a) for a in arrays})==1
        if grouped:
            def cached_call(prefix,bank):
                n=prefix+'_'+bank
                return (' lda yrow\n and #$fc\n'+n+'_row:\n cmp #255\n beq '+n+'_same\n sta '+n+'_row+1\n jmp '+n+'_write\n'+n+'_same:\n lda startbyte\n'+n+'_min:\n cmp #0\n bcc '+n+'_left\n lda endbyte\n'+n+'_max:\n cmp #0\n bcc '+n+'_done\n beq '+n+'_done\n'
                # Right-only extension; disjoint intervals reset instead of coloring a gap.
                +' lda '+n+'_max+1\n clc\n adc #1\n cmp startbyte\n bcc '+n+'_write\n'
                +' lda startbyte\n sta '+n+'_restore_start+1\n lda '+n+'_max+1\n clc\n adc #1\n sta startbyte\n lda endbyte\n sta '+n+'_max+1\n jsr apply_material_span_'+bank+'\n'+n+'_restore_start:\n lda #0\n sta startbyte\n jmp '+n+'_done\n'
                +n+'_left:\n lda endbyte\n cmp '+n+'_max+1\n bcc '+n+'_left_only\n beq '+n+'_left_only\n jmp '+n+'_write\n'
                +n+'_left_only:\n clc\n adc #1\n cmp '+n+'_min+1\n bcc '+n+'_write\n'
                +' lda endbyte\n sta '+n+'_restore_end+1\n lda '+n+'_min+1\n sec\n sbc #1\n sta endbyte\n lda startbyte\n sta '+n+'_min+1\n jsr apply_material_span_'+bank+'\n'+n+'_restore_end:\n lda #0\n sta endbyte\n jmp '+n+'_done\n'
                +n+'_write:\n lda startbyte\n sta '+n+'_min+1\n lda endbyte\n sta '+n+'_max+1\n jsr apply_material_span_'+bank+'\n'+n+'_done:\n')
            if re.search(r'(?m)^GRAPHICS_MODE = \$01$',s):
                wire_start=s.find('pwh_span:\n');wire_end=s.find('plot_wire_vertical_run:\n',wire_start)
                if wire_start>=0 and wire_end>wire_start:
                    body=s[wire_start:wire_end]
                    if all(body.count(' jsr apply_material_span_'+b+'\n')==1 for b in 'ab') and hashlib.sha256(body.encode('ascii')).hexdigest() in {'53b771b7ac21584b95ef11e9dff1d8267f11cffaab9386465710cce69a89c0f4'}:
                        new=body
                        for bank in 'ab':new=new.replace(' jsr apply_material_span_'+bank+'\n',cached_call('gr22_wire',bank),1)
                        reset='.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0 || ENGINE_WIRE_MATERIAL_CELLS_RUNTIME_ACTIVE != 0\n lda #255\n sta gr22_wire_a_row+1\n sta gr22_wire_b_row+1\n.endif\n'
                        if s.count('trace_edge_convex:\n')==1:
                            replace('wire-material-last-span',body,new)
                            replace('wire-material-primitive-reset','trace_edge_convex:\n','trace_edge_convex:\n'+reset)
                            info.update(wireMaterialLastSpan=True,wireCachePrimitiveReset=True,materialRowGroupingProven=True,cacheMutableOperandBytes=10)
            if re.search(r'(?m)^GRAPHICS_MODE = \$02$',s):
                gate='.if FACE_MATERIAL_ACTIVE_ONLY != $01 || FACE_REFLECTIVITY_ACTIVE_ONLY != $01 || VIC_COLOR_POLICY_ENABLE != 0\n'
                shared='gr22_fill_shared:\n'+cached_call('gr22_fill','shared').replace('jsr apply_material_span_shared','jsr gr22_fill_dispatch')+' rts\ngr22_fill_dispatch:\n jmp apply_material_span_a\n'
                shared=shared.replace(' jsr gr22_fill_dispatch\ngr22_fill_shared_done:', ' jmp gr22_fill_dispatch\ngr22_fill_shared_done:')
                records=[]
                for bank in 'ab':
                    start=s.find('fill_bounds_solid_'+bank+':\n');end=s.find('fbs_'+bank+'_done:\n rts\n',start)
                    if start<0 or end<start:break
                    end+=len('fbs_'+bank+'_done:\n rts\n');body=s[start:end]
                    old=' jsr apply_material_span_'+bank+'\n'
                    if body.count(old)!=1 or hashlib.sha256(body.encode('ascii')).hexdigest() not in {'a938482caffbe09daa4dcacaaafae5d7b28310d2dcb22d0a0faf6a489e6965ce', '81216d8ffb435dca8da7755da644d45503ac21df74baa720a05864b710878710'}:break
                    setup=(gate+' lda #255\n sta gr22_fill_shared_row+1\n lda #<apply_material_span_'+bank+'\n sta gr22_fill_dispatch+1\n lda #>apply_material_span_'+bank+'\n sta gr22_fill_dispatch+2\n.endif\n')
                    new=body.replace('fill_bounds_solid_'+bank+':\n','fill_bounds_solid_'+bank+':\n'+setup,1).replace(old,' jsr gr22_fill_shared\n',1)
                    records.append((bank,body,new))
                if len(records)==2:
                    for bank,old,new in records:replace('shared-fill-material-'+bank,old,new)
                    replace('shared-fill-material-code','fill_bounds_solid_a:\n',gate+shared+'.endif\nfill_bounds_solid_a:\n')
                    info.update(fillMaterialSharedTrim=True,materialRowGroupingProven=True,cacheMutableOperandBytes=7,extraPeakDataStackBytes=max(2,info['extraPeakDataStackBytes']))
    # GR23: quotient/remainder integer bounds, with existing wire/outline fallback.
    if re.search(r'(?m)^GRAPHICS_MODE = \$0[2345]$',s) and not circle_api and 'LAZY_CONVEX_BOUNDS = $00' in s and 'ENGINE_MODE1_WIRE_POINT_DIRECT_ENTRY = $00' in s and 'PROJ_SCREEN_MAX_X = $9F' in s and 'PROJ_SCREEN_MAX_Y = $63' in s and ('WIRE_RENDER_ENABLE = $00' in s or all(n+' = $01' in s for n in ['ENGINE_WIRE_RASTER_CONSOLIDATION','ENGINE_WIRE_8BIT_BRESENHAM','ENGINE_WIRE_STEEP_LINE_FASTPATH'])):
        start=s.find('trace_edge_convex:\n');end=s.find('tec_horizontal:\n',start)
        if start>=0 and end>start:
            body=s[start:end]
            private=set(re.findall(r'(?m)^([A-Za-z_][A-Za-z0-9_]*):',body))-{'trace_edge_convex'}
            external=s[:start]+s[end:]
            external_targets=set(re.findall(r'(?m)^ (?:jsr|jmp|beq|bne|bcs|bcc|bmi|bpl|bvc|bvs) ([A-Za-z_][A-Za-z0-9_]*)\s*$',external))
            if hashlib.sha256(body.encode('ascii')).hexdigest() in {'695c8342b5e3a1807cab12fd5790b1bd80450f96bfead898059c10270af24c52', '2397ff16457bf78b1e1587224704745a8d278601c0601696d6a7c2f0ff22c57f'} and not (private & external_targets):
                dispatch='trace_edge_convex:\n.if MODE5_POLYGON_OUTLINE != 0\n lda mode5_outline_trace_active\n bne gr23_parent_entry\n.endif\n.if WIRE_RENDER_ENABLE != 0\n lda wire_trace_active\n bne gr23_parent_entry\n.endif\n jmp gr23_bounds_entry\ngr23_parent_entry:\n'
                kernel="gr23_bounds_entry:\n ; GR23: integer coverage only. Preserve diagonal's single-point rows.\n lda ey0\n cmp ey1\n bcc gr23_forward\n bne gr23_reverse\n jmp tec_horizontal\ngr23_reverse:\n lda ex1\n sta xcur\n lda ey1\n sta ycur\n lda ey0\n sta spanw\n sec\n sbc ey1\n sta dyval\n sec\n lda ex0\n sbc ex1\n jmp gr23_delta\ngr23_forward:\n lda ex0\n sta xcur\n lda ey0\n sta ycur\n lda ey1\n sta spanw\n sec\n sbc ey0\n sta dyval\n sec\n lda ex1\n sbc ex0\ngr23_delta:\n ldx #1\n bcs gr23_abs_ready\n eor #255\n clc\n adc #1\n ldx #255\ngr23_abs_ready:\n stx sxstep\n sta dxabs\n beq gr23_point_rows\n cmp dyval\n beq gr23_diagonal\n ldx dyval\n cpx #1\n bne gr23_divide_init\n tax\n lda #0\n beq gr23_divided\ngr23_divide_init:\n ldx #0\ngr23_divide:\n cmp dyval\n bcc gr23_divided\n sbc dyval\n inx\n bne gr23_divide\ngr23_divided:\n sta dxabs\n txa\n ldx sxstep\n bpl gr23_quotient\n eor #255\n clc\n adc #1\ngr23_quotient:\n sta errhi\n lda #0\n sta errlo\n lda sxstep\n bmi gr23_rows_negative\ngr23_rows_positive:\n ldx ycur\n lda xcur\n cmp leftb,x\n bcs gr23_positive_left\n sta leftb,x\ngr23_positive_left:\n lda ycur\n cmp spanw\n beq gr23_positive_right\n clc\n lda errlo\n adc dxabs\n bcs gr23_positive_correct\n cmp dyval\n bcc gr23_positive_no_correct\ngr23_positive_correct:\n sbc dyval\n sta errlo\n clc\n lda xcur\n adc errhi\n adc #1\n sta xcur\n jmp gr23_positive_right\ngr23_positive_no_correct:\n sta errlo\n clc\n lda xcur\n adc errhi\n sta xcur\ngr23_positive_right:\n lda xcur\n cmp rightb,x\n bcc gr23_positive_next\n sta rightb,x\ngr23_positive_next:\n lda ycur\n cmp spanw\n beq gr23_done\n inc ycur\n jmp gr23_rows_positive\ngr23_rows_negative:\n ldx ycur\n lda xcur\n cmp rightb,x\n bcc gr23_negative_right\n sta rightb,x\ngr23_negative_right:\n lda ycur\n cmp spanw\n beq gr23_negative_left\n clc\n lda errlo\n adc dxabs\n bcs gr23_negative_correct\n cmp dyval\n bcc gr23_negative_no_correct\ngr23_negative_correct:\n sbc dyval\n sta errlo\n clc\n lda xcur\n adc errhi\n sec\n sbc #1\n sta xcur\n jmp gr23_negative_left\ngr23_negative_no_correct:\n sta errlo\n clc\n lda xcur\n adc errhi\n sta xcur\ngr23_negative_left:\n lda xcur\n cmp leftb,x\n bcs gr23_negative_next\n sta leftb,x\ngr23_negative_next:\n lda ycur\n cmp spanw\n beq gr23_done\n inc ycur\n jmp gr23_rows_negative\ngr23_diagonal:\n ldx ycur\n lda xcur\n cmp leftb,x\n bcs gr23_diagonal_left\n sta leftb,x\ngr23_diagonal_left:\n cmp rightb,x\n bcc gr23_diagonal_right\n sta rightb,x\ngr23_diagonal_right:\n lda ycur\n cmp spanw\n beq gr23_done\n inc ycur\n clc\n lda xcur\n adc sxstep\n sta xcur\n jmp gr23_diagonal\ngr23_point_rows:\n ldx ycur\n lda xcur\n cmp leftb,x\n bcs gr23_point_left\n sta leftb,x\ngr23_point_left:\n cmp rightb,x\n bcc gr23_point_right\n sta rightb,x\ngr23_point_right:\n lda ycur\n cmp spanw\n beq gr23_done\n inc ycur\n jmp gr23_point_rows\ngr23_done:\n rts\n"
                if 'WIRE_RENDER_ENABLE = $00' in s and 'MODE5_POLYGON_OUTLINE = $00' in s:
                    new=kernel.replace('gr23_bounds_entry:\n','trace_edge_convex:\n',1)
                else:
                    retained=body.removeprefix('trace_edge_convex:\n')
                    if 'ENGINE_WIRE_RASTER_CONSOLIDATION = $01' in s and 'MODE5_POLYGON_OUTLINE = $00' in s and 'PROJ_SCREEN_MAX_Y = $63' in s:
                        # With wire active, the classifier handles every non-special slope.
                        # With wire inactive, the new entry handles all bounds first.
                        # The 16-bit point fallthrough is unreachable in either case.
                        for side in 'lr':
                            begin=retained.index(' lda sxstep\n bmi tec_'+side+'loop_neg\n')
                            end=retained.index('tec_'+side+'vertical:\n',begin)
                            retained=retained[:begin]+' jmp gr23_bounds_entry\n'+retained[end:]
                    new=dispatch+retained+kernel
                outline_selected=False
                if re.search(r'(?m)^GRAPHICS_MODE = \$05$',s) and 'WIRE_RENDER_ENABLE = $00' in s and 'PROJ_SCREEN_MAX_X = $9F' in s and 'PROJ_SCREEN_MAX_Y = $63' in s and adjacent_rows_proven(s):
                    point_start=s.find('mode5_plot_background_point:\n');point_end=s.find('update_convex_bounds:\n',point_start)
                    point_ok=point_start>=0 and point_end>point_start and hashlib.sha256(s[point_start:point_end].encode('ascii')).hexdigest()=='d7440ea35871648fda3842935de496f1f38816e23fb5c442d4e6d2f897626c8f'
                    mask_tables=[read_byte_table(s,n) for n in ['xbyte','startmask','endmask']]
                    if point_ok and mask_tables==[[x//4 for x in range(160)],[255>>(2*(x%4)) for x in range(160)],[(255<<(2*(3-x%4)))&255 for x in range(160)]]:
                        new='trace_edge_convex:\n lda mode5_outline_trace_active\n beq gr23_bounds_entry\n jmp gr23_outline_entry\n'+kernel+'; Exact connected integer outline, grouped by row. No material/dirty writes.\ngr23_outline_entry:\n lda ey0\n cmp ey1\n bcc gr23o_forward\n bne gr23o_reverse\n lda ex0\n cmp ex1\n bcc gr23o_horizontal_ordered\n lda ex1\n sta leftval\n lda ex0\n sta rightval\n jmp gr23o_horizontal_ready\ngr23o_horizontal_ordered:\n sta leftval\n lda ex1\n sta rightval\ngr23o_horizontal_ready:\n lda ey0\n sta ycur\n jmp gr23_outline_span\ngr23o_reverse:\n lda ex1\n sta xcur\n lda ey1\n sta ycur\n lda ey0\n sta spanw\n sec\n sbc ey1\n sta dyval\n sec\n lda ex0\n sbc ex1\n jmp gr23o_delta\ngr23o_forward:\n lda ex0\n sta xcur\n lda ey0\n sta ycur\n lda ey1\n sta spanw\n sec\n sbc ey0\n sta dyval\n sec\n lda ex1\n sbc ex0\ngr23o_delta:\n ldx #1\n bcs gr23o_abs\n eor #255\n clc\n adc #1\n ldx #255\ngr23o_abs:\n stx sxstep\n sta dxabs\n beq gr23o_vertical\n cmp dyval\n beq gr23o_point_rows\n ldx #0\ngr23o_divide:\n cmp dyval\n bcc gr23o_divided\n sbc dyval\n inx\n bne gr23o_divide\ngr23o_divided:\n sta dxabs\n txa\ngr23o_quotient:\n sta errhi\n lda #0\n sta errlo\n lda sxstep\n bmi gr23o_negative\ngr23o_positive:\n lda xcur\n sta leftval\n sta rightval\n lda ycur\n cmp spanw\n beq gr23o_positive_write\n clc\n lda errlo\n adc dxabs\n cmp dyval\n bcc gr23o_positive_no_correction\n sbc dyval\ngr23o_positive_no_correction:\n sta errlo\n lda xcur\n adc errhi\n sta xcur\n sta rightval\ngr23o_positive_write:\n jsr gr23_outline_span\n lda ycur\n cmp spanw\n beq gr23o_done\n inc ycur\n jmp gr23o_positive\ngr23o_negative:\n lda xcur\n sta leftval\n sta rightval\n lda ycur\n cmp spanw\n beq gr23o_negative_write\n clc\n lda errlo\n adc dxabs\n cmp dyval\n bcc gr23o_negative_no_correction\n sbc dyval\n sta errlo\n lda xcur\n clc\n sbc errhi\n jmp gr23o_negative_advanced\ngr23o_negative_no_correction:\n sta errlo\n lda xcur\n sec\n sbc errhi\ngr23o_negative_advanced:\n sta xcur\n sta leftval\ngr23o_negative_write:\n jsr gr23_outline_span\n lda ycur\n cmp spanw\n beq gr23o_done\n inc ycur\n jmp gr23o_negative\ngr23o_vertical:\n lda #0\n sta sxstep\ngr23o_point_rows:\n lda xcur\n sta leftval\n sta rightval\n jsr gr23_outline_span\n lda ycur\n cmp spanw\n beq gr23o_done\n inc ycur\n clc\n lda xcur\n adc sxstep\n sta xcur\n jmp gr23o_point_rows\ngr23o_done:\n rts\n\n; Inputs: leftval..rightval inclusive, ycur. Adjacent rows proven by tables.\ngr23_outline_span:\n ldx ycur\n lda drawbuf\n bne gr23os_buffer_b\n lda row0lo_a,x\n sta ptr0lo\n lda row0hi_a,x\n jmp gr23os_row\ngr23os_buffer_b:\n lda row0lo_b,x\n sta ptr0lo\n lda row0hi_b,x\ngr23os_row:\n sta ptr0hi\n ldx leftval\n lda ptr0lo\n clc\n adc xofflo,x\n sta ptr0lo\n lda ptr0hi\n adc xoffhi,x\n sta ptr0hi\n lda xbyte,x\n sta startbyte\n ldx rightval\n lda xbyte,x\n sta endbyte\n cmp startbyte\n bne gr23os_multi\n lda endmask,x\n ldx leftval\n and startmask,x\n eor #255\n sta maskv\n jmp gr23os_masked\ngr23os_multi:\n ldx leftval\n lda startmask,x\n eor #255\n sta maskv\n jsr gr23os_masked\ngr23os_next:\n clc\n lda ptr0lo\n adc #8\n sta ptr0lo\n bcc gr23os_pointer_ready\n inc ptr0hi\ngr23os_pointer_ready:\n inc startbyte\n lda startbyte\n cmp endbyte\n beq gr23os_last\n ldy #0\n lda #0\n sta (ptr0lo),y\n iny\n sta (ptr0lo),y\n jmp gr23os_next\ngr23os_last:\n ldx rightval\n lda endmask,x\n eor #255\n sta maskv\ngr23os_masked:\n ldy #0\n lda (ptr0lo),y\n and maskv\n sta (ptr0lo),y\n iny\n lda (ptr0lo),y\n and maskv\n sta (ptr0lo),y\n ; The parent point writer leaves Y=1. Trace callers treat it as scratch.\n rts\n'
                        outline_selected=True
                        info.update(outlineSpanGrouping=True,outlineCoverageExact=True,outlineWritesBitmapOnly=True,extraPeakDataStackBytes=max(2,info['extraPeakDataStackBytes']))
                if replace('quotient-integer-bounds-dispatch',body,new):info.update(integerBoundsExpanded=True,wireParentFallback=True,outlineParentFallback=not outline_selected,rawQ2BoundsUnchanged=True)
    if 'gr28_span_core:\n' in s and '; GR16_BIASED_UV ' in s and info.get('sampler'):
        scopes=[('raster','gr28_span_core:\n','; Texture is page aligned.'),
                ('advance','m7_sample:\n','m7_prepare_span:\n'),
                ('fast','lpa_block_mode7_immediate_kernel_begin:\n','lpa_block_mode7_immediate_kernel_end:\n'),
                ('composite','m3_composite:\n','m3_composite_end = *\n')]
        proposed=[];steps=0
        for name,first,last in scopes:
            a=s.index(first);b=s.index(last,a);old=s[a:b];new=old
            if name=='fast':new=re.sub(r'(?m)^lp8_fast_imm_\w+:\n','',new)
            pattern=re.compile(r'(?m)^(\w*m7_u_correct):\n sbc mul16mul\n sta prodlo\n lda mul16abs\n jmp (\w*lp8_u_apply)\n(\w*m7_u_store):\n sta prodlo\n lda crosslo\n\2:\n adc p1lo\n sta p1lo\n(\w*m7_v_advance):\n')
            def reg_step(m):
                return m[1]+':\n sbc mul16mul\n sta prodlo\n txa\n adc mul16abs\n tax\n jmp '+m[4]+'\n'+m[3]+':\n sta prodlo\n txa\n adc crosslo\n tax\n'+m[2]+':\n'+m[4]+':\n'
            new,n=pattern.subn(reg_step,new);steps+=n
            if name=='raster':
                assert new.count(' jsr gouraud_init_span_pointers\n')==1
                new=new.replace(' jsr gouraud_init_span_pointers\n',' jsr gouraud_init_span_pointers\n ldx p1lo\n')
                new=new.replace(' ldx shadeidx\n lda gouraud_pair_clear,x\n',' ldy shadeidx\n lda gouraud_pair_clear,y\n').replace(' cpx #3\n',' cpy #3\n')
                assert new.count(' lda p1lo\n sta m7_u\n')==1
                new=new.replace(' lda p1lo\n sta m7_u\n',' stx m7_u\n')
            if name in ('advance','fast'):
                new=new.replace(' lda p1lo\n lsr\n',' txa\n lsr\n')
            if name=='composite':
                new=new.replace(' ldx mul16reslo\n',' ldy mul16reslo\n').replace(' cpx #',' cpy #').replace(' txa\n',' tya\n')
            proposed.append((name,old,new))
        assert steps==9,('GR28_REGISTER_STEPS',steps)
        for name,old,new in proposed:assert replace('gr28-register-u-'+name,old,new)
        info.update(registerU=True,registerPreservedBySamplerAndQ=True)
    if info.get('registerU'):
        scopes=[('raster','gr28_span_core:\n','; Texture is page aligned.'),
                ('advance','m7_sample:\n','m7_prepare_span:\n'),
                ('fast','lpa_block_mode7_immediate_kernel_begin:\n','lpa_block_mode7_immediate_kernel_end:\n')]
        outside=s;parts=[]
        for name,first,last in scopes:
            a=s.index(first);b=s.index(last,a);body=s[a:b];parts.append((name,body));outside=outside.replace(body,'',1)
        # Only the data declarations may remain outside the closed raster.
        # A custom private scratch consumer retains the parent implementation.
        if len(re.findall(r'\bm7_packed\b',outside))==1 and len(re.findall(r'\bm7_index\b',outside))==1:
            old_address=' lda p1hi\n and #$f0\n sta m7_index\n txa\n lsr\n lsr\n lsr\n lsr\n ora m7_index\n tay\n'
            new_address=' txa\n lsr\n lsr\n lsr\n lsr\n eor p1hi\n and #$0f\n eor p1hi\n tay\n'
            count=sum(body.count(old_address) for name,body in parts)
            if count==5:
                for name,body in parts:
                    new=body.replace(old_address,new_address)
                    # U has moved from its saved private shadow into X before
                    # the first sample. The retired shadow can hold packed ink.
                    if name in ('raster','fast'):new=re.sub(r'\bm7_packed\b','p1lo',new)
                    assert replace('gr29-register-pack-'+name,body,new)
                info.update(exactNibbleMerge=True,packedInkInRetiredUShadow=True,newStackBytes=0)
    if info.get('registerU') and len(call_contexts(s,'m3_prepare_span'))==1:
        old='m3_prepare_span:\n jsr lp7_select_band\n sec\n lda rightval\n sbc leftval\n sta m7_den\n ldy yrow\n lda m3_leftq,y\n sta m3_qcur\n ldx m3_rightq,y\n jsr m7_dda_setup\n lda m7_q\n sta m3_qstep\n lda m7_r\n sta m3_qrem\n lda m7_dir\n sta m3_qdir\n lda #0\n sta m3_qerr\n rts\n'
        new='m3_prepare_span:\n jsr lp7_select_band\n sec\n lda rightval\n sbc leftval\n sta m7_den\n ldy yrow\n lda m3_leftq,y\n sta m3_qcur\n sec\n lda m3_rightq,y\n sbc m3_qcur\n ldx #1\n bcs gr29_q_absolute\n eor #255\n clc\n adc #1\n ldx #255\ngr29_q_absolute:\n cmp m7_den\n bcs gr29_q_setup_parent\n sta m3_qrem\n stx m3_qdir\n lda #0\n sta m3_qstep\n sta m3_qerr\n rts\ngr29_q_setup_parent:\n lda m3_qcur\n ldx m3_rightq,y\n jsr m7_dda_setup\n lda m7_q\n sta m3_qstep\n lda m7_r\n sta m3_qrem\n lda m7_dir\n sta m3_qdir\n lda #0\n sta m3_qerr\n rts\n'
        den_old='m7_prepare_span:\n jsr m3_prepare_span\n lda yrow\n and #3\n asl\n asl\n sta m2_bayer_row\n sec\n lda rightval\n sbc leftval\n sta m7_den\n'
        den_new='m7_prepare_span:\n jsr m3_prepare_span\n lda yrow\n and #3\n asl\n asl\n sta m2_bayer_row\n'
        if s.count(old)==s.count(den_old)==1:
            assert replace('gr29-q-zero-quotient',old,new)
            assert replace('gr29-untrimmed-span-denominator',den_old,den_new)
            info.update(exactQZeroQuotientSetup=True,originalUntrimmedDenominatorReused=True)
    from legacy_gouraud_zp import plan
    changes,block,details=plan(s)
    for name,old,new in changes:assert replace(name,old,new)
    s+=block;info.update(details)
    from legacy_mode7_edge_bias import plan as edge_bias_plan
    new_changes,new_block,new_info=edge_bias_plan(s)
    for name,old,new in new_changes:assert replace(name,old,new)
    s+=new_block;info.update(new_info)
    from legacy_mode7_table import plan as table_plan
    table_changes,table_block,table_info=table_plan(s)
    for name,old,new in table_changes:assert replace(name,old,new)
    s+=table_block;info.update(table_info)
    if replacements:
        raw=json.dumps(replacements,sort_keys=True,separators=(',',':')).encode('ascii');s+='; GR17_RENDER_TUNING '+hashlib.sha256(raw).hexdigest()+' '+base64.b64encode(zlib.compress(raw,9)).decode('ascii')+'\n';info['applied']=True
    return s,info
if __name__=='__main__':
    import argparse
    from pathlib import Path
    p=argparse.ArgumentParser();p.add_argument('asm',type=Path);a=p.parse_args();s=a.asm.read_text(encoding='utf-8-sig');s,info=patch(s);a.asm.write_bytes(s.encode('ascii'));a.asm.with_suffix('.render-tuning.json').write_text(json.dumps(info,indent=2)+'\n')
