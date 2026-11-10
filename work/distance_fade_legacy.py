"""Optional legacy distance-fade adapter with bounded free-gap allocation."""
import argparse,json,re,subprocess,tempfile,sys
from pathlib import Path
from distance_fade import config,adapt
sys.path.insert(0,str(Path(__file__).parent/'q8/src'))
from allocation import bounded_place

def attach(base,parts,placed=None):
    for n,body in parts.items():
        base+='\n'+(f'* = ${placed[n][0]:04x}\n' if placed else '.virtual $4000\n')
        base+=f'df_block_{n}_begin:\n'+body+f'df_block_{n}_end:\n'
        base+=(f'.cerror * > ${placed[n][1]:04x},"Distance fade allocation overflow"\n' if placed else '.endvirtual\n')
    return base

def wire_writers(base,parts):
    if not re.search(r'(?m)^GRAPHICS_MODE = \$01$',base):return base,parts
    # Move whole unchanged writers and the edge walker. Preserve conditional
    # scopes in the base; all calls/SMC references resolve to relocated labels.
    ranges=[('writers','plot_wire_point:\n','pvwr_done:\n'),
            ('clip','clip_poly_compact_screen_a:\n','wire_vertex_drawable:\n'),
            ('edges','trace_edge_convex:\n','.if MODE5_POLYGON_OUTLINE != 0 && MEMORY_LAYOUT_HIGH_BASIC_V2 = 0\nmode5_stable_code_end')]
    for name,first,last in ranges:
        start=base.index(first);end=base.index(last,start)
        if name=='writers':end=base.index(' rts\n',end)+len(' rts\n')
        body=base[start:end];retained=[];depth=minimum=0
        for line in body.splitlines(keepends=True):
            t=line.strip()
            if t.startswith('.if '):depth+=1
            elif t=='.endif':depth-=1;minimum=min(minimum,depth)
            if t.startswith(('.if ','.else','.elsif','.endif')):retained.append(line)
        parts['distance_wire_'+name]='.if 1\n'*(-minimum)+body+'.endif\n'*(depth-minimum)
        base=base[:start]+' jmp '+first.strip().rstrip(':')+'\n'+''.join(retained)+base[end:]
    return base,parts


def check_wire_ranges(source,ranges):
    # The old high-basic Mode1 ceiling was $6000, but $5c00..$5fff is
    # already the live screen. Never accept a base spilling into video/RAM.
    if re.search(r'(?m)^GRAPHICS_MODE = \$01$',source) and re.search(r'(?m)^MEMORY_LAYOUT_HIGH_BASIC_V2 = \$01$',source):
        for start,end in ranges:
            if start<0x9000 and end>0x5c00 or start<0x4000 and end>0x2000:
                raise ValueError('DISTANCE_FADE_LAYOUT: Mode1 base overlaps live video/runtime RAM; reduce scene size')

def main():
    p=argparse.ArgumentParser();p.add_argument('asm',type=Path);p.add_argument('--start',type=int,required=True);p.add_argument('--end',type=int,required=True);p.add_argument('--assembler',required=True);a=p.parse_args()
    c=config({},'dither',a.start,a.end);s=a.asm.read_text(encoding='utf-8-sig')
    # Reflow existing Plus allocations together with the new code. In-place
    # insertion can enlarge a low/middle segment into a previously free gap.
    # Keeping old absolute placements would silently overlap its old helpers.
    if '; Plus allocation block ' in s or '\nlc_helpers_begin:\n' in s or '\nlr_helpers_begin:\n' in s:
        from legacy_plus_memory import parts_of,attach as plus_attach,_allocate
        base,old_parts=parts_of(s)
        # Mode1's original aggregate ceiling describes its former fixed block.
        # The bounded allocator now guards each relocated part and live segment.
        for name in old_parts:
            old_parts[name]=old_parts[name].replace('.cerror * > $a000,"Mode1 plus helpers overlap high code"','; Original Mode1 aggregate bound replaced by per-part allocation guards.')
        base,parts=adapt(base,old_parts,c)
        base,parts=wire_writers(base,parts)
        with tempfile.TemporaryDirectory(prefix='3dvibe64-fade-plus-') as tmp:
            result=_allocate(plus_attach(base,parts),a.assembler,tmp)
            info=json.loads((Path(tmp)/'allocation.json').read_text())
            check_wire_ranges(base,info['baseRanges'])
            a.asm.write_bytes(result.encode('ascii'))
            a.asm.with_suffix('.distance-fade.json').write_text(json.dumps(dict(**c,plusReallocated=True,allocation=info),indent=2))
        return
    s,parts=adapt(s,{},c)
    s,parts=wire_writers(s,parts)
    with tempfile.TemporaryDirectory(prefix='3dvibe64-fade-') as d:
        d=Path(d);path=d/'sizing.asm';path.write_text(attach(s,parts),encoding='ascii')
        cmd=[a.assembler,'-a','-B','--vice-labels-numeric','--labels='+str(d/'labels'),'--map='+str(d/'map'),'-o',str(d/'image'),str(path)]
        r=subprocess.run(cmd,capture_output=True,text=True)
        if r.returncode:raise ValueError('DISTANCE_FADE_LAYOUT: '+r.stdout+r.stderr)
        lab={m[2]:int(m[1],16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$',(d/'labels').read_text(),re.M)}
        used=[(int(x,16),int(y,16)+1) for x,y in re.findall(r'^Data:.*?\$([0-9a-f]+)-\$([0-9a-f]+)',(d/'map').read_text(),re.M)]
        for m in re.finditer(r'lpa_block_(\w+)_begin:.*?lpa_block_\1_end:\n\.cerror \* > \$([0-9a-fA-F]+)',s,re.S):
            used.append((lab['lpa_block_'+m[1]+'_begin'],int(m[2],16)))
        check_wire_ranges(s,used)
        # Same polygon windows; protect screens, bitmap banks and all runtime buffers.
        windows=[(0x801,0x2000),(0x4000,0x5c00),(0x9000,0xa000)]
        if lab.get('BITMAP_B_BASE')==0x2000:windows.append((0xa000,0xd000))
        if not lab.get('MEMORY_LAYOUT_HIGH_BASIC_V2',0):windows=[(0x801,0x5c00)]
        gaps=[]
        for lo,hi in windows:
            for x,y in sorted(used):
                if y<=lo or x>=hi:continue
                if lo<x:gaps.append((lo,x))
                lo=max(lo,y)
            if lo<hi:gaps.append((lo,hi))
        sizes={n:lab['df_block_'+n+'_end']-lab['df_block_'+n+'_begin'] for n in parts}
        result,search=bounded_place(sizes,gaps,60000);placed,free=result
        a.asm.write_bytes(attach(s,parts,placed).encode('ascii'))
        a.asm.with_suffix('.distance-fade.json').write_text(json.dumps(dict(**c,allocation=placed,remaining=free,search=search),indent=2))
if __name__=='__main__':main()
