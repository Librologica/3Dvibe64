"""Exact adjacent-row bitmap cursors for wire points and horizontal/vertical runs.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import base64,hashlib,json,re,zlib
REGIONS=[('point','plot_wire_point:\n','pwp_done:\n'),('horizontal','plot_wire_horizontal:\n','plot_wire_vertical_run:\n'),('vertical','plot_wire_vertical_run:\n','pvwr_done:\n')]
MARKER=re.compile(r'; GR16_WIRE_RUNS ([0-9a-f]{64}) ([A-Za-z0-9+/=]+)\n')
def region(s,first,last):
 a=s.index(first);b=s.index(last,a);return a,b,s[a:b]
def original_source(s):
 matches=list(MARKER.finditer(s))
 if not matches:return s
 assert len(matches)==1;m=matches[0];raw=zlib.decompress(base64.b64decode(m[2]));assert hashlib.sha256(raw).hexdigest()==m[1]
 saved=json.loads(raw);s=MARKER.sub('',s)
 for name,first,last in REGIONS:
  a,b,_=region(s,first,last);s=s[:a]+saved[name]+s[b:]
 return s
def table(s,name):
 m=re.search(r'(?m)^'+name+r':\n((?: \.byte[^\n]*\n)+)',s)
 if not m:return None
 out=[]
 for line in m[1].splitlines():
  for part in line.removeprefix(' .byte ').split(','):
   part=part.strip()
   if not re.fullmatch(r'(?:\$[0-9a-fA-F]+|\d+)',part):return None
   v=int(part[1:],16) if part.startswith('$') else int(part)
   if not 0<=v<=255:return None
   out.append(v)
 return out
def proven(s):
 for bank in 'ab':
  arrays=[table(s,'row'+str(row)+part+'_'+bank) for row in [0,1] for part in ['lo','hi']]
  if any(a is None for a in arrays) or not arrays[0] or len({len(a) for a in arrays})!=1:return False
  lo,hi,lo1,hi1=arrays
  if any(c+256*d!=a+256*b+1 for a,b,c,d in zip(lo,hi,lo1,hi1)):return False
 return True
def patch(s):
 s=original_source(s)
 if not re.search(r'(?m)^WIRE_RENDER_ENABLE = \$01$',s):return s,dict(applied=False,reason='Enabled wire renderer only')
 if any(first not in s or last not in s for name,first,last in REGIONS) or not proven(s):return s,dict(applied=False,reason='Known adjacent-row writers only')
 saved={n:region(s,a,b)[2] for n,a,b in REGIONS};patched={}
 pointer=' lda row1lo\n clc\n adc xofflo,x\n sta ptr1lo\n lda row1hi\n adc xoffhi,x\n sta ptr1hi\n'
 scalar=' lda (ptr1lo),y\n and maskv\n ora p1lo\n sta (ptr1lo),y\n'
 single=' iny\n lda (ptr0lo),y\n and maskv\n ora p1lo\n sta (ptr0lo),y\n dey\n'
 for name,first,last in REGIONS:
  body=saved[name]
  for bank in 'ab':
   old=f' lda row1lo_{bank},x\n sta row1lo\n lda row1hi_{bank},x\n sta row1hi\n'
   if body.count(old)!=1:return s,dict(applied=False,reason='Other row setup retained')
   body=body.replace(old,'',1)
  if body.count(pointer)!=1:return s,dict(applied=False,reason='Other second-row cursor retained')
  body=body.replace(pointer,'',1)
  expected=3 if name=='horizontal' else 1
  if body.count(scalar)!=expected:return s,dict(applied=False,reason='Other masked row stores retained')
  body=body.replace(scalar,single)
  if name=='horizontal':
   old='pwh_next0_ok:\n clc\n lda ptr1lo\n adc #$08\n sta ptr1lo\n bcc pwh_next1_ok\n inc ptr1hi\npwh_next1_ok:\n'
   if body.count(old)!=1:return s,dict(applied=False,reason='Other horizontal cursor increment retained')
   body=body.replace(old,'pwh_next0_ok:\npwh_next1_ok:\n',1)
   old=' sta (ptr0lo),y\n sta (ptr1lo),y\n'
   if body.count(old)!=1:return s,dict(applied=False,reason='Other full-byte writer retained')
   body=body.replace(old,' sta (ptr0lo),y\n iny\n sta (ptr0lo),y\n dey\n',1)
  patched[name]=body
 for name,first,last in REGIONS:
  a,b,_=region(s,first,last);s=s[:a]+patched[name]+s[b:]
 payload=json.dumps(saved,sort_keys=True,separators=(',',':')).encode('ascii');encoded=base64.b64encode(zlib.compress(payload,9)).decode('ascii')
 s+='; GR16_WIRE_RUNS '+hashlib.sha256(payload).hexdigest()+' '+encoded+'\n'
 return s,dict(applied=True,physicalRowAdjacencyProven=True,writers=['point','horizontal','vertical'],oneBitmapCursor=True,YRestored=True,dirtyAndMaterialCodeUnchanged=True,newRAMVariables=0,newRAMTables=0,extraDataStackBytes=0,qualityChanged=False,exact=True)

if __name__=='__main__':
 import argparse
 from pathlib import Path
 p=argparse.ArgumentParser();p.add_argument('asm',type=Path);a=p.parse_args()
 source=a.asm.read_text(encoding='utf-8-sig');result,info=patch(source)
 a.asm.write_bytes(result.encode('ascii'))
 a.asm.with_suffix('.wire-cursor.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
