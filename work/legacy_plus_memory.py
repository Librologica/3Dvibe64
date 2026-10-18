"""Place ordinary plus helpers in actual free RAM for the solid modes.

Only placement changes. No Q8 transform, clipping or projection is emitted.
The historical Mode2 layout is preserved. Native render code and live buffers
are excluded from every allocation; all final bounds remain assembler gates.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
"""
import argparse,hashlib,json,re,subprocess,tempfile
from pathlib import Path

PAT=re.compile(r'\n; Plus allocation block (\w+)\n(?:\* = \$[0-9a-f]+|\.virtual \$4000)\nlpa_block_\1_begin:\n(.*?)lpa_block_\1_end:\n(?:\.cerror[^\n]+\n|\.endvirtual\n)',re.S)

def parts_of(source):
    matches=list(PAT.finditer(source))
    existing={m[1]:m[2] for m in matches}
    if matches:source=PAT.sub('',source)
    if 'MODE7_UV_CARRIER = $01' in source and 'm3_q0:' in source:
        # The Gouraud emitter adds a complete lighting/metadata bundle to
        # the crowded middle segment. Relocate the unchanged bundle using
        # the same bounded allocator, rather than widening that segment.
        start='\nm3_code_begin = *\n'
        if start in source:
            a=source.index(start);b=source.index('mode3_high_basic_middle_end = *\n',a)
            existing['lighting']=source[a:b]
            source=source[:a]+source[b:]
        # The plus near/screen dispatch no longer references these integer
        # camera-side passes. Retain their live projection helpers.
        start='clip_poly_clip_camera_x_current:\n'
        if start in source:
            a=source.index(start);b=source.index('clip_poly_project_a_from_camera:\n',a)
            old=source[a:b];outside=source[:a]+source[b:]+'\n'+'\n'.join(existing.values())
            for name in re.findall(r'(?m)^(\w+):',old):
                assert not re.search(r'\b'+name+r'\b',outside),('Live camera-side clip consumer',name)
            assert old.count('.if ')==old.count('.endif')
            source=source[:a]+'; Plus M3: unreferenced camera-side clip removed.\n'+source[b:]
    marks=[('camera','\nlc_helpers_begin:\n'),('rotation','\nlr_helpers_begin:\n'),
      ('products','\n; Runtime-only allocation after every existing vertex/face/color buffer.'),
      ('terms','\nlr_terms_valid:'),('near','\nlpn_helpers_begin:\n'),('screen','\nlps_helpers_begin:\n')]
    for name,marker in [('attributes','\nlpa_attributes_begin:\n')]+[(n,'\nlpp_'+n+'_begin:\n') for n in ('bridge','edge','ratio','screen_attrs','sample','span','state')]:
        if marker in source:marks.append((name,marker))
    positions=[(name,source.index(marker)) for name,marker in marks if marker in source]
    if not positions:return source,existing
    assert positions==sorted(positions,key=lambda p:p[1])
    base=source[:positions[0][1]];parts=dict(existing)
    for i,(name,start) in enumerate(positions):
        end=positions[i+1][1] if i+1<len(positions) else len(source)
        parts[name]=source[start:end]
    # The old product LUT occupies $9000..$9fff on these scenes, where the
    # solid renderer already has live code. Keep its existing exact serial
    # fallback until a separately measured LUT placement is introduced.
    old='.if LR_PRODUCT_LUT_END <= RUNTIME_BUFFER_LIMIT\n'
    if old in parts['products']:
        assert parts['products'].count(old)==1
        parts['products']=parts['products'].replace(old,'.if 0 ; plus solid modes: existing exact serial fallback\n',1)
    return base,parts

def attach(base,parts,placed=None):
    s=base
    for n,code in parts.items():
        s+='\n; Plus allocation block '+n+'\n'
        s+=f'* = ${placed[n][0]:04x}\n' if placed else '.virtual $4000\n'
        s+='lpa_block_'+n+'_begin:\n'+code.rstrip()+'\nlpa_block_'+n+'_end:\n'
        s+=f'.cerror * > ${placed[n][1]:04x},"Plus allocation overflow: {n}"\n' if placed else '.endvirtual\n'
    return s

def allocate(source,assembler,directory):
    directory=Path(directory);directory.mkdir(parents=True,exist_ok=True)
    base,parts=parts_of(source)
    sizing=directory/'sizing.asm';sizing.write_text(attach(base,parts),encoding='ascii')
    cmd=[str(assembler),'-a','-B','--vice-labels-numeric','--labels='+str(directory/'sizing.labels'),'--map='+str(directory/'sizing.map'),'-o',str(directory/'sizing.prg'),str(sizing)]
    r=subprocess.run(cmd,capture_output=True,text=True);(directory/'sizing.log').write_text(r.stdout+r.stderr)
    if r.returncode:raise ValueError('PLUS_BASE_LAYOUT: '+r.stdout+r.stderr)
    lab={m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',(directory/'sizing.labels').read_text(),re.M)}
    assert lab['LR_PRODUCT_LUT_ACTIVE']==0
    assert lab['RUNTIME_BUFFER_COLOR_POLICY_END']<=0x9000
    used=[(int(a,16),int(b,16)+1) for a,b in re.findall(r'^Data:.*?\$([0-9a-f]+)-\$([0-9a-f]+)',(directory/'sizing.map').read_text(),re.M)]
    gaps=[]
    for start,end in ((0x0801,0x2000),(0x4000,0x5c00),(0x9000,0xa000),(0xa000,0xd000)):
        for a,b in sorted(used):
            if b<=start or a>=end:continue
            if start<a:gaps.append((start,a))
            start=max(start,b)
        if start<end:gaps.append((start,end))
    if 'm3_q0' in lab:
        # No FPS overlay and no rotation LUT are active in this qualified
        # profile. The actual live-buffer end, not $8000, determines which
        # tail of runtime RAM is free. Preserve32 bytes before any helper.
        assert lab['FPS_OVERLAY_ENABLE']==0 and lab['LR_PRODUCT_LUT_ACTIVE']==0
        tail=(lab['RUNTIME_BUFFER_COLOR_POLICY_END']+33)&~1
        if tail<0x9000:gaps.append((tail,0x9000))
    sizes={n:lab['lpa_block_'+n+'_end']-lab['lpa_block_'+n+'_begin'] for n in parts}
    # Shared host-only bounded RAM placer. It emits addresses, no target math.
    import sys
    sys.path.insert(0,str(Path(__file__).parent/'q8/src'))
    from allocation import bounded_place
    result,search=bounded_place(sizes,gaps,60000);placed=result[0]
    for n,(a,b) in placed.items():assert all(b<=x or a>=y for x,y in used)
    (directory/'allocation.json').write_text(json.dumps(dict(command=cmd,partsSHA256={n:hashlib.sha256(v.encode('ascii')).hexdigest() for n,v in parts.items()},sizes=sizes,baseRanges=used,gaps=gaps,placed=placed,search=search),indent=2))
    tail=[a for a,b in placed.values() if 0x8000<=a<0x9000]
    if tail:
        base+=f'\n.cerror RUNTIME_BUFFER_COLOR_POLICY_END+32 > ${min(tail):04x},"Plus helpers overlap live runtime buffers"\n.cerror LR_PRODUCT_LUT_ACTIVE != 0,"Plus tail allocation requires serial rotation products"\n'
    return attach(base,parts,placed)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('asm',type=Path);p.add_argument('--assembler',required=True);a=p.parse_args()
    with tempfile.TemporaryDirectory(prefix='plus-placement-',dir=a.asm.parent) as d:
        source=allocate(a.asm.read_text(encoding='utf-8-sig'),a.assembler,d)
        (a.asm.with_suffix('.plus-memory.json')).write_bytes((Path(d)/'allocation.json').read_bytes())
        a.asm.write_text(source,encoding='ascii')
