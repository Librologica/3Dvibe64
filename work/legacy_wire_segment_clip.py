"""Exact segment clipping for recognized undirected wire consumers.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
# Exact two-endpoint screen clipping using the existing intersections.
import base64,hashlib,json,re,zlib
BLOCK=re.compile(r'\n; Plus allocation block wire_segment_clip\n(?:\* = \$[0-9a-f]+|\.virtual \$4000)\nlpa_block_wire_segment_clip_begin:\n.*?lpa_block_wire_segment_clip_end:\n(?:\.cerror[^\n]+\n|\.endvirtual\n)',re.S)
MARKER=re.compile(r'; GR27_WIRE_CLIP ([0-9a-f]{64}) ([A-Za-z0-9+/=]+)\n')
CALLER_CONTEXTS=frozenset(['32f144a8b8825ba8b28e49b73d79cb10d92e26167606fda131289ac837f1f94a', '367c4ede50b756d139edac4197cd5329be60bc91929161d5123e719e10c9103a', 'b159f43480cf771ee1e82722052580379161bbbabcd4989a7711cc87322d800a'])
def original_source(s):
 m=MARKER.search(s)
 if not m:return s
 raw=zlib.decompress(base64.b64decode(m[2]));assert hashlib.sha256(raw).hexdigest()==m[1]
 old,new=json.loads(raw);assert s.count(new)==1 and len(list(BLOCK.finditer(s)))==1
 return MARKER.sub('',BLOCK.sub('',s.replace(new,old,1)))
def code(load):
 s='''gr27_wire_screen:
 lda lps_active
 beq gr27_wire_integer
 jmp gr27_wire_parent
gr27_wire_integer:
'''+load+''' jsr gr27_wire_pair_x_inside
 bcs gr27_wire_x_inside
 jsr gr27_wire_pair_y_inside
 bcs gr27_wire_y_inside
 jmp gr27_wire_full_clip
gr27_wire_x_inside:
 jsr gr27_wire_pair_y_inside
 bcs gr27_wire_finish
 jsr gr27_wire_top
 bcc gr27_wire_axis_no
 jsr gr27_wire_bottom
 bcc gr27_wire_axis_no
 jmp gr27_wire_finish
gr27_wire_y_inside:
 jsr gr27_wire_right
 bcc gr27_wire_axis_no
 jsr gr27_wire_left
 bcc gr27_wire_axis_no
 jmp gr27_wire_finish
gr27_wire_axis_no:
 jmp gr27_wire_no
gr27_wire_full_clip:
'''
 for plane in ['right','left','top','bottom']:
  s+=f' jsr gr27_wire_{plane}\n bcs gr27_wire_{plane}_accepted\n jmp gr27_wire_no\ngr27_wire_{plane}_accepted:\n'
 s+='''gr27_wire_finish:
 lda clip_a_x
 cmp clip_a_x+1
 bne gr27_wire_yes
 lda clip_a_y
 cmp clip_a_y+1
 beq gr27_wire_no
gr27_wire_yes:
 lda #2
 sta clip_a_count
 lda clip_a_x
 sta ex0
 lda clip_a_y
 sta ey0
 lda clip_a_x+1
 sta ex1
 lda clip_a_y+1
 sta ey1
 lda #1
 rts
gr27_wire_no:
 lda #0
 sta clip_a_count
 rts
'''
 for plane,src,dst,inside in [('right','a','b','clip_a_right_inside'),('left','b','a','clip_b_left_inside'),('top','a','b','clip_a_top_inside'),('bottom','b','a','clip_b_bottom_inside')]:
  tag='gr27_wire_'+plane
  s+=f'''{tag}:
 lda #0
 sta clip_{dst}_count
 ldx #0
 jsr {inside}
 beq {tag}_first_out
 ldx #1
 jsr {inside}
 bne {tag}_both_in
 ; Parent polygon order compacts to [intersection, inside endpoint0].
 lda #0
 sta clip_prev_idx
 sta clip_cur_inside
 lda #1
 sta clip_cur_idx
 jsr clip_append_{plane}_intersection_{src}_to_{dst}
 ldx #0
 jsr gr27_wire_copy_{src}_to_{dst}
 sec
 rts
{tag}_first_out:
 ldx #1
 jsr {inside}
 bne {tag}_second_in
 clc
 rts
{tag}_second_in:
 lda #0
 sta clip_prev_idx
 lda #1
 sta clip_cur_idx
 sta clip_cur_inside
 jsr clip_append_{plane}_intersection_{src}_to_{dst}
 ldx #1
 jsr gr27_wire_copy_{src}_to_{dst}
 sec
 rts
{tag}_both_in:
 ldx #0
 jsr gr27_wire_copy_{src}_to_{dst}
 ldx #1
 jsr gr27_wire_copy_{src}_to_{dst}
 sec
 rts
'''
 for axis in 'xy':
  s+=f'''gr27_wire_pair_{axis}_inside:
 lda clip_a_{axis}hi
 ora clip_a_{axis}hi+1
 bne gr27_wire_pair_{axis}_out
 lda clip_a_{axis}lo
 cmp lps_bound_{axis}
 bcc gr27_wire_pair_{axis}_second
 bne gr27_wire_pair_{axis}_out
 gr27_wire_pair_{axis}_second:
 lda clip_a_{axis}lo+1
 cmp lps_bound_{axis}
 bcc gr27_wire_pair_{axis}_yes
 bne gr27_wire_pair_{axis}_out
 gr27_wire_pair_{axis}_yes:
 sec
 rts
 gr27_wire_pair_{axis}_out:
 clc
 rts
'''
 for src,dst in [('a','b'),('b','a')]:
  s+=f'gr27_wire_copy_{src}_to_{dst}:\n ldy clip_{dst}_count\n'
  for field in ['xlo','xhi','ylo','yhi','x','y','flag']:s+=f' lda clip_{src}_{field},x\n sta clip_{dst}_{field},y\n'
  s+=f' inc clip_{dst}_count\n rts\n'
 return s
def patch(s):
 s=original_source(s)
 if 'WIRE_RENDER_ENABLE = $01' not in s or 'GOURAUD_MODE6 = $00' not in s or 'MODE7_UV_CARRIER = $01' in s or 'lps_active:' not in s:return s,dict(applied=False)
 # Only the known undirected wire-render consumers may use the faster clipper.
 # Polygon closing duplicates can rotate endpoint order; the wire rasterizer
 # normalizes endpoints. Unknown private consumers retain the complete parent.
 lines=s.splitlines();calls=[i for i,line in enumerate(lines) if re.fullmatch(r'\s*(?:jsr|jmp) clip_wire_edge_screen',line)]
 if not calls or any(hashlib.sha256('\n'.join(lines[max(0,i-3):i+7]).encode('ascii')).hexdigest() not in CALLER_CONTEXTS for i in calls):return s,dict(applied=False,reason='Unknown endpoint-order consumer')
 start='clip_wire_edge_screen:\n';stop='cwes_no:\n lda #$00\n rts\n'
 if start not in s or stop not in s:return s,dict(applied=False)
 a=s.index(start);b=s.index(stop,a)+len(stop);old=s[a:b]
 cut=' lda #$02\n sta clip_a_count\n'
 if old.count(cut)!=1 or old.count(' jsr clip_poly_clip_screen_current\n')!=1:return s,dict(applied=False)
 load=old[len(start):old.index(cut)]
 new=start+' jmp gr27_wire_screen\ngr27_wire_parent:\n'+old[len(start):]
 s=s.replace(old,new,1)
 s+='\n; Plus allocation block wire_segment_clip\n.virtual $4000\nlpa_block_wire_segment_clip_begin:\n'+code(load)+'lpa_block_wire_segment_clip_end:\n.endvirtual\n'
 raw=json.dumps([old,new],separators=(',',':')).encode('ascii');s+='; GR27_WIRE_CLIP '+hashlib.sha256(raw).hexdigest()+' '+base64.b64encode(zlib.compress(raw,9)).decode('ascii')+'\n'
 return s,dict(applied=True,halfSpaceOrder=['right','left','top','bottom'],originalIntersectionArithmetic=True,endpointOrderMayReverse=True,knownUndirectedConsumersProven=True,maximumEndpoints=2,provenInsideAxisPairsSkipped=True,newPrivateBytes=0,newRAMTables=0,nonintegerParentFallback=True,qualityChanged=False)


def place_wire_only(source,assembler,directory):
    from pathlib import Path
    import subprocess
    directory=Path(directory);directory.mkdir(parents=True,exist_ok=True)
    original=original_source(source);candidate,info=patch(original)
    if not info['applied']:return original,info
    sizing=directory/'sizing.asm';sizing.write_text(candidate,encoding='ascii')
    command=[str(assembler),'-a','-B','--vice-labels-numeric','--labels='+str(directory/'sizing.labels'),'--map='+str(directory/'sizing.map'),'-o',str(directory/'sizing.prg'),str(sizing)]
    r=subprocess.run(command,capture_output=True,text=True);(directory/'sizing.log').write_text(r.stdout+r.stderr,encoding='utf-8')
    if r.returncode:raise ValueError('WIRE_SEGMENT_SIZING: '+r.stdout+r.stderr)
    lab={m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',(directory/'sizing.labels').read_text(),re.M)}
    used=[(int(a,16),int(b,16)+1) for a,b in re.findall(r'^Data:.*?\$([0-9a-f]+)-\$([0-9a-f]+)',(directory/'sizing.map').read_text(),re.M)]
    for first,last in [('RUNTIME_BUFFER_BASE','RUNTIME_BUFFER_COLOR_POLICY_END'),('LR_PRODUCT_LUT_BASE','LR_PRODUCT_LUT_END')]:
        if first in lab and last in lab:used.append((lab[first],lab[last]))
    image=(directory/'sizing.prg').read_bytes();origin=int.from_bytes(image[:2],'little');memory=bytes(origin)+image[2:]
    def byte(addr):return memory[addr] if addr<len(memory) else 0
    # Protect complete physical VIC screens/bitmap banks, including runtime-only RAM.
    for bank in 'ab':
        for table,mask,length in [('row0',0xe000,0x2000),('screenrow',0xfc00,0x400)]:
            lo,hi=table+'lo_'+bank,table+'hi_'+bank
            if lo in lab and hi in lab:
                base=(byte(lab[lo])+256*byte(lab[hi]))&mask;used.append((base,base+length))
    for m in re.finditer(r'(?m)^FPS_CHARSET_BASE = \$([0-9a-fA-F]+)$',original):
        base=int(m[1],16);used.append((base,base+0x800))
    size=lab['lpa_block_wire_segment_clip_end']-lab['lpa_block_wire_segment_clip_begin'];gaps=[]
    # Subset of the pre-existing plus allocator windows. Never use the live wire LUT band.
    for start,end in [(0x0801,0x2000),(0x4000,0x5c00)]:
        for a,b in sorted(used):
            if b<=start or a>=end:continue
            if start<a:gaps.append((start,a))
            start=max(start,b)
        if start<end:gaps.append((start,end))
    eligible=[(a,b) for a,b in gaps if b-a>=size]
    if not eligible:return original,dict(applied=False,reason='No room inside original low/middle windows',size=size,gaps=gaps)
    start,end=eligible[0];assert all(start+size<=a or start>=b for a,b in used)
    m=BLOCK.search(candidate);assert m
    actual=m[0].replace('.virtual $4000',f'* = ${start:04x}',1).replace('.endvirtual',f'.cerror * > ${end:04x},"Wire segment helper overlaps existing allocation"',1)
    candidate=candidate[:m.start()]+actual+candidate[m.end():]
    return candidate,dict(info,placement=[start,start+size],existingGap=[start,end],size=size,usedRanges=used,windows=[[0x0801,0x2000],[0x4000,0x5c00]],originalWindowsUnchanged=True,command=command)

if __name__=='__main__':
    import argparse,tempfile
    from pathlib import Path
    p=argparse.ArgumentParser();p.add_argument('asm',type=Path);p.add_argument('--assembler',required=True);a=p.parse_args()
    with tempfile.TemporaryDirectory(prefix='wire-segment-placement-',dir=a.asm.parent) as directory:
        source,info=place_wire_only(a.asm.read_text('utf-8-sig'),a.assembler,directory)
        a.asm.write_text(source,encoding='ascii');a.asm.with_suffix('.wire-segment.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
