"""Exact shared-geometry UVQ edge traversal for the known Mode7-C kernel.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import base64,hashlib,re,zlib
EXPECTED = {'u': '52650121e4f10c71799dff6fa706c544daf8efec5801b3ebddf60c7d66ea4b8d', 'v': '2530b188544d03e655f0f6e7a3cb34083251e5287442e6ddfc693a91fa9f44e1', 'q': '3c4aa5443daf8acc064e894cbf429e8c759fd7a4060295ccfb7fa66f4d92fe4e'}
TRIPLE=' jsr gouraud_build_edge_shades\n jsr gouraud_build_edge_shades_v\n jsr gouraud_build_edge_shades_v_q\n'
CALL=' ; GR15_FUSED_EDGE_CALL\n jsr gr15_build_edges\n'
REGIONS=[('u','gouraud_build_edge_shades:\n','r1_span_closed_cap:\n'),
         ('v','gouraud_build_edge_shades_v:\n','; Mode 7 affine Q4.4.'),
         ('q','gouraud_build_edge_shades_v_q:\n','m3_code_end = *\n')]
SAVED=re.compile(r'; GR15_RESTORE_([uvq]) ([0-9a-f]{64}) ([A-Za-z0-9+/=]+)\n')
BLOCK=re.compile(r'\n; Plus allocation block mode7_fused_edges\n(?:\* = \$[0-9a-f]+|\.virtual \$4000)\nlpa_block_mode7_fused_edges_begin:\n.*?lpa_block_mode7_fused_edges_end:\n(?:\.cerror[^\n]+\n|\.endvirtual\n)',re.S)
def original_source(s):
 if not SAVED.search(s):return s
 def restore(m):
  raw=zlib.decompress(base64.b64decode(m[3]));assert hashlib.sha256(raw).hexdigest()==m[2]
  return raw.decode('ascii')
 assert len(list(SAVED.finditer(s)))==3 and len(list(BLOCK.finditer(s)))==1
 return SAVED.sub(restore,BLOCK.sub('',s)).replace(CALL,TRIPLE)
def setup_axis(current,end,step,rem,direction):
 return f' lda {current}\n ldx {end}\n jsr m7_dda_setup\n lda m7_q\n sta {step}\n lda m7_r\n sta {rem}\n lda m7_dir\n sta {direction}\n'
def advance(tag,current,error,step,rem,direction,immediate=False):
 code=f' clc\n lda {error}\n'
 code+=f'gr15_{tag}_rem:\n adc #0\n' if immediate else f' adc {rem}\n'
 code+=f' bcs gr15_{tag}_correct\n cmp m7_den\n bcc gr15_{tag}_no_correction\ngr15_{tag}_correct:\n sbc m7_den\n sta {error}\n'
 code+=f'gr15_{tag}_step_correct:\n lda #0\n' if immediate else f' lda {step}\n'
 code+=f' clc\n adc {direction}\n jmp gr15_{tag}_apply\ngr15_{tag}_no_correction:\n sta {error}\n'
 code+=f'gr15_{tag}_step:\n lda #0\n' if immediate else f' lda {step}\n'
 return code+f'gr15_{tag}_apply:\n clc\n adc {current}\n sta {current}\n'
def code():
 out='''gr15_build_edges:
 ldx face_ymin
gr15_init:
 lda #255
 sta leftb,x
 lda #0
 sta rightb,x
 lda gouraud_vshade0
 sta leftshade,x
 sta rightshade,x
 lda m7_v0
 sta m7_leftv,x
 sta m7_rightv,x
 lda m3_q0
 sta m3_leftq,x
 sta m3_rightq,x
 cpx face_ymax
 beq gr15_edges
 inx
 bne gr15_init
gr15_edges:
'''
 def load(i,j):
  pairs=[('gouraud_edge_x0','vx'+str(i)),('gouraud_edge_y0','vy'+str(i)),('gouraud_edge_s0','gouraud_vshade'+str(i)),('gouraud_edge_x1','vx'+str(j)),('gouraud_edge_y1','vy'+str(j)),('gouraud_edge_s1','gouraud_vshade'+str(j)),('m7_u','m7_v'+str(i)),('m7_v','m7_v'+str(j)),('m3_qcur','m3_q'+str(i)),('m3_qerr','m3_q'+str(j))]
  return ''.join(f' lda {src}\n sta {dst}\n' for dst,src in pairs)
 out+=load(0,1)+' jsr gr15_trace\n'+load(1,2)+' jsr gr15_trace\n'
 out+=''' .if HAS_TRI_FACES != 0
 lda loaded_face_vertex_count
 cmp #4
 beq gr15_quad
 .endif
'''+load(2,0)+' jmp gr15_trace\ngr15_quad:\n'+load(2,3)+' jsr gr15_trace\n'+load(3,0)+' jmp gr15_trace\n'
 # Quads-only profiles must take the quad path unconditionally.
 out=out.replace(' .if HAS_TRI_FACES != 0\n',' .if HAS_TRI_FACES != 0\n').replace(' beq gr15_quad\n .endif\n',' beq gr15_quad\n .else\n jmp gr15_quad\n .endif\n')
 out+='''gr15_trace:
 lda gouraud_edge_y0
 cmp gouraud_edge_y1
 bcc gr15_ordered
 bne gr15_swap
 rts
gr15_swap:
'''
 for a,b in [('gouraud_edge_x0','gouraud_edge_x1'),('gouraud_edge_y0','gouraud_edge_y1'),('gouraud_edge_s0','gouraud_edge_s1'),('m7_u','m7_v'),('m3_qcur','m3_qerr')]:
  out+=f' lda {a}\n ldx {b}\n stx {a}\n sta {b}\n'
 out+='''gr15_ordered:
 sec
 lda gouraud_edge_y1
 sbc gouraud_edge_y0
 sta gouraud_edge_dy
 sta m7_den
 lda gouraud_edge_x0
 ldx gouraud_edge_x1
 jsr m7_dda_setup
 lda m7_q
 sta gr15_x_step+1
 sta gr15_x_step_correct+1
 lda m7_r
 sta gr15_x_rem+1
 lda m7_dir
 sta gouraud_edge_xdir
'''
 out+=setup_axis('m3_qcur','m3_qerr','m3_qstep','m3_qrem','m3_qdir')
 out+=setup_axis('m7_u','m7_v','m7_vstep','m7_vrem','m7_vdir')
 out+=' lda m7_u\n sta m7_v\n'
 out+=setup_axis('gouraud_edge_s0','gouraud_edge_s1','m7_ustep','m7_urem','m7_udir')
 out+=''' lda gouraud_edge_s0
 sta m7_u
 lda #0
 sta m7_uerr
 sta m7_verr
 sta m3_qerr
 sta gouraud_edge_xerr_lo
 lda gouraud_edge_xdir
 bmi gr15_bias_ready
 lda gouraud_edge_dy
 sec
 sbc #1
 sta gouraud_edge_xerr_lo
gr15_bias_ready:
 lda gouraud_edge_y0
 sta gouraud_edge_row
 lda gouraud_edge_x0
 sta gouraud_edge_xcur
gr15_loop:
 lda gouraud_edge_row
 cmp gouraud_edge_y1
 bne gr15_sample
 lda clip_poly_active
 beq gr15_done
 lda gouraud_edge_row
 cmp #PROJ_SCREEN_MAX_Y
 bne gr15_done
 jsr gr15_store
gr15_done:
 rts
gr15_sample:
 jsr gr15_store
'''
 out+=advance('x','gouraud_edge_xcur','gouraud_edge_xerr_lo',None,None,'gouraud_edge_xdir',True)
 for axis,current,error,step,rem,direction in [('u','m7_u','m7_uerr','m7_ustep','m7_urem','m7_udir'),('v','m7_v','m7_verr','m7_vstep','m7_vrem','m7_vdir'),('q','m3_qcur','m3_qerr','m3_qstep','m3_qrem','m3_qdir')]:
  out+=advance(axis,current,error,step,rem,direction)
 out+=''' inc gouraud_edge_row
 jmp gr15_loop
gr15_store:
 lda gouraud_edge_row
 cmp face_ymin
 bcc gr15_store_done
 cmp face_ymax
 bcc gr15_store_range
 bne gr15_store_done
gr15_store_range:
 tax
 lda gouraud_edge_xcur
 cmp leftb,x
 bcc gr15_left
 bne gr15_right_check
gr15_left:
 sta leftb,x
 lda m7_u
 sta leftshade,x
 lda m7_v
 sta m7_leftv,x
 lda m3_qcur
 sta m3_leftq,x
gr15_right_check:
 lda gouraud_edge_xcur
 cmp rightb,x
 bcc gr15_store_done
 sta rightb,x
 lda m7_u
 sta rightshade,x
 lda m7_v
 sta m7_rightv,x
 lda m3_qcur
 sta m3_rightq,x
gr15_store_done:
 rts
'''
 return out
def patch(s):
 s=original_source(s)
 if not re.search(r'(?m)^GRAPHICS_MODE = \$07$',s) or 'm31_c_instructions_end = *' not in s:return s,dict(applied=False,reason='Known Mode7-C only')
 if TRIPLE not in s:return s,dict(applied=False,reason='No known combined caller')
 raw=s;removed=[]
 for name,first,last in REGIONS:
  if first not in s or last not in s:return raw,dict(applied=False,reason='Unknown edge shape')
  a=s.index(first);b=s.index(last,a);chunk=s[a:b];digest=hashlib.sha256(chunk.encode('ascii')).hexdigest()
  if digest!=EXPECTED[name]:return raw,dict(applied=False,reason='Different edge kernel retained')
  removed+=re.findall(r'(?m)^([A-Za-z_][A-Za-z_0-9]*):',chunk)
  payload=base64.b64encode(zlib.compress(chunk.encode('ascii'),9)).decode('ascii')
  s=s[:a]+f'; GR15_RESTORE_{name} {digest} {payload}\n'+s[b:]
 s=s.replace(TRIPLE,CALL)
 if any(re.search(r'\b'+re.escape(n)+r'\b',s) for n in removed):return raw,dict(applied=False,reason='External consumer of original edge helpers retained')
 s+='\n; Plus allocation block mode7_fused_edges\n.virtual $4000\nlpa_block_mode7_fused_edges_begin:\n'+code()+'lpa_block_mode7_fused_edges_end:\n.endvirtual\n'
 return s,dict(applied=True,sharedXYTraversal=True,channels='UVQ',newRAMVariables=0,newRAMTables=0,extraDataStackBytes=0,privateSpanScratchReused=True,qualityChanged=False,exactTopLeftAndTieRules=True)
