"""Two-pass wire adapter; SDK emits legacy source, never alters frozen defaults."""
import json,math,re,shutil
from build import assemble,sha
from continuous import pieces,verify_retired_state_absent
from emit import attach
from wire import prepare_wire,wire_pieces

def finish_wire(out,sdk,spec,cmd,result,music,motion,camera_mobile=False,camera_auto=False,memory_recovery=True):
    source=(sdk/'work/3Dvibe64.asm').read_text(encoding='utf-8-sig')
    # Mode 1 legacy poly clipping overflows its middle segment for this profile.
    # Only this known error is allowed during source emission. Adapter removes
    # replaced integer clippers; ALL final assembler overlap guards stay active.
    if result.returncode:
        errors=re.findall(r'error: ([^\r\n]+)',result.stdout+result.stderr)
        if errors!=['High-basic-v2 middle segment overlaps video buffer A']:
            raise RuntimeError(result.stdout+result.stderr)
    lab={m[1]:int(m[2],16) for m in re.finditer(r'^(\w+) = \$([0-9a-fA-F]+)',source,re.M)}
    parts=wire_pieces(pieces(lab,music,motion),lab)
    source=prepare_wire(source,music,motion,lab['GRAPHICS_MODE'])
    if camera_mobile:
        from camera import adapt
        source,parts=adapt(source,parts,camera_auto)
    recovery=None
    if memory_recovery:
        from q8_memory import recover,compact_matrix
        source,recovery=recover(source,lab)
        parts=compact_matrix(parts)
    if lab['SCENE_OBJECT_COUNT']>1:
        from multiobject import adapt
        parts=adapt(parts)
    verify_retired_state_absent(source)
    sizing=assemble(attach(source,parts),out,'sizing')
    assert sizing['RUNTIME_BUFFER_COLOR_POLICY_END']<=0x9000,'wire adapter overlaps runtime state'
    assert sizing['VIC_COLOR_POLICY_ENABLE']==0
    # Occupied ranges from actual emitted data, excluding .virtual chunks.
    used=[(int(m[1],16),int(m[2],16)+1) for m in re.finditer(r'Data:.*?\$([0-9a-f]+)-\$([0-9a-f]+)',(out/'sizing.map').read_text(),re.I)]
    # Existing engine allocates live uninitialized scratch at $8000-$8fff.
    # Keep both bitmap banks, screens, charset/header and this scratch reserved.
    gaps=[]
    for start,end in ((0x0801,0x2000),(0x4000,0x5c00),(0x9000,0xa000),(0xa000,0xd000)):
        for a,b in sorted(used):
            if b<=start or a>=end:continue
            if start<a:gaps.append((start,a))
            start=max(start,b)
        if start<end:gaps.append((start,end))
    original=gaps[:];placed={}
    sizes={n:sizing[f'hp_block_{n}_end']-sizing[f'hp_block_{n}_begin'] for n in parts}
    for n,size in sorted(sizes.items(),key=lambda p:-p[1]):
        align=256 if n=='tables' else 2;need=size+(0 if n in ('tables','data') else 32)
        options=[]
        for i,(a,b) in enumerate(gaps):
            a=(a+align-1)//align*align
            if a+need<=b:options.append((b-a-need,i,a))
        if not options:raise ValueError(('wire memory budget',n,size,gaps))
        _,i,a=min(options);old,b=gaps.pop(i);placed[n]=(a,a+need)
        if old<a:gaps.append((old,a))
        if a+need<b:gaps.append((a+need,b))
    final=assemble(attach(source,parts,placed),out,'3Dvibe64')
    data=(out/'3Dvibe64.prg').read_bytes();load=int.from_bytes(data[:2],'little')
    def byte(n,i=0):return data[final[n]+i-load+2]
    def s8(v):return (v+128)%256-128
    vertices=[[s8(byte(a+'coord',byte('vert_'+a+'i',i))) for a in 'xyz'] for i in range(final['VERT_COUNT'])]
    from multiobject import metadata
    object_ranges=metadata(final,byte,vertices)
    radius=max(r['radiusWU'] for r in object_ranges)
    shutil.copy2(out/'3Dvibe64.labels',out/'labels.txt');shutil.copy2(out/'3Dvibe64.map',out/'memory.map')
    meta=dict(precision='q8',scene=spec,command=cmd,vertices=vertices,scaleQ6=byte('object_scale'),scaledRadiusWU=radius,
              blockSizes=sizes,allocation=placed,originalGaps=original,remainingGaps=gaps,music=music,demoLateralSweep=motion,
              prgSHA256=sha(out/'3Dvibe64.prg'),bytes=len(data),legacySourceAssemblyExit=result.returncode,
              recommendation='Q8 above 20 MHz; legacy at <=20 MHz. Recommendation, not measured FPS.')
    meta['objectRanges']=object_ranges
    if camera_mobile:meta.update(cameraMobile=True,cameraAutomatic=camera_auto)
    if recovery:meta['q8MemoryRecovery']=recovery
    (out/'build.json').write_text(json.dumps(meta,indent=2));print(out.name,meta['prgSHA256'],flush=True)
    return out
