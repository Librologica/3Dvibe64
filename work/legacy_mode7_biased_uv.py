"""Exact carry-only UV stepping with biased private errors during a Mode7 span.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import base64,hashlib,json,re,zlib
REGIONS=[('raster','gouraud_draw_scan_span_bytes:\n','; Texture is page aligned.'),('advance','m7_advance:\n','m7_prepare_span:\n'),('fast','lpa_block_mode7_immediate_kernel_begin:\n','lpa_block_mode7_immediate_kernel_end:\n'),('setup','lp8_patch_uv_constants:\n','lpa_block_mode7_immediate_setup_end:\n')]
MARKER=re.compile(r'; GR16_BIASED_UV ([0-9a-f]{64}) ([A-Za-z0-9+/=]+)\n')
PATTERN=re.compile(r'(?m)^( adc (?:m7_[uv]rem|#(?:\$00|0))\n) bcs (\w+)\n(?:(\w+):\n)? cmp (?:m7_den|#(?:\$00|0))\n bcc (\w+)\n\2:\n(?: sec\n)?')
def region(s,first,last):
 a=s.index(first);b=s.index(last,a);return a,b,s[a:b]
def original_source(s):
 matches=list(MARKER.finditer(s))
 if not matches:return s
 assert len(matches)==1;m=matches[0];payload=zlib.decompress(base64.b64decode(m[2]));assert hashlib.sha256(payload).hexdigest()==m[1]
 saved=json.loads(payload);s=MARKER.sub('',s)
 for name,first,last in REGIONS:
  a,b,_=region(s,first,last);s=s[:a]+saved[name]+s[b:]
 return s
def patch(s):
 s=original_source(s)
 if not re.search(r'(?m)^GRAPHICS_MODE = \$07$',s) or 'm31_c_instructions_end = *' not in s:return s,dict(applied=False,reason='Known Mode7-C only')
 if any(first not in s or last not in s for name,first,last in REGIONS):return s,dict(applied=False,reason='Other raster retained')
 saved={name:region(s,first,last)[2] for name,first,last in REGIONS};rest=s
 for name,first,last in REGIONS:
  a,b,_=region(rest,first,last);rest=rest[:a]+rest[b:]
 if re.search(r'\b(?:jsr|jmp) m7_advance\b',rest):return s,dict(applied=False,reason='External private advance caller retained')
 total=0;removed=[];patched={}
 for name,first,last in REGIONS:
  body=saved[name]
  if name!='setup':
   def replace(m):
    nonlocal total
    total+=1
    if m[3]:removed.append(m[3])
    return m[1]+' bcc '+m[4]+'\n'+m[2]+':\n'
   body=PATTERN.sub(replace,body)
  if name=='raster':
   for axis,scratch in [('u','prodlo'),('v','prodhi')]:
    old=f' lda m7_{axis}err\n sta {scratch}\n';new=f' sec\n lda m7_{axis}err\n sbc m7_den\n sta {scratch}\n'
    if body.count(old)!=1:return s,dict(applied=False,reason='Other shadow entry retained')
    body=body.replace(old,new,1)
    old=f' lda {scratch}\n sta m7_{axis}err\n';new=f' clc\n lda {scratch}\n adc m7_den\n sta m7_{axis}err\n'
    if body.count(old)!=1:return s,dict(applied=False,reason='Other shadow exit retained')
    body=body.replace(old,new,1)
  patched[name]=body
 if total!=18 or len(removed)!=8:return s,dict(applied=False,reason='Other UV step count retained')
 setup=patched['setup']
 for label in removed:
  line=' sta '+label+'+1\n'
  if setup.count(line)!=1:return s,dict(applied=False,reason='Other immediate cache retained')
  setup=setup.replace(line,'',1)
 old=' cmp lp8_fast_imm_m7_den_0+1\n';new=' cmp lp8_fast_imm_m7_den_1+1\n'
 if setup.count(old)!=1:return s,dict(applied=False,reason='Other denominator cache retained')
 patched['setup']=setup.replace(old,new,1)
 for name,first,last in REGIONS:
  a,b,_=region(s,first,last);s=s[:a]+patched[name]+s[b:]
 payload=json.dumps(saved,sort_keys=True,separators=(',',':')).encode('ascii');encoded=base64.b64encode(zlib.compress(payload,9)).decode('ascii')
 s+='; GR16_BIASED_UV '+hashlib.sha256(payload).hexdigest()+' '+encoded+'\n'
 return s,dict(applied=True,stepSites=total,removedImmediateComparisons=len(removed),errorRepresentation='E-D modulo256 within private span shadows only',entryAndExitConvert=True,newRAMVariables=0,newRAMTables=0,extraDataStackBytes=0,originalPublicErrorStateRestored=True,qualityChanged=False,exact=True)
