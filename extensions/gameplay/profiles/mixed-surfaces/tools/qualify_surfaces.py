"""Native per-pixel oracle for untextured spans; complete-frame UI/clip checks."""
import json
from pathlib import Path
from native_compare import ROOT, paths, run, capture, sha
from verify_ui import check_frame, lod_trace


def span_oracle(build):
    b, prg, l = paths(build)
    cases = [('flat-dark',1,1,1,14,0,32,False), ('flat-mid',1,2,4,12,32,0,False),
             ('flat-light',1,3,3,4,0,32,False), ('flat-closed',1,2,7,7,16,16,True),
             ('gouraud-up',2,2,1,29,0,32,False), ('gouraud-down',2,2,3,30,32,0,False),
             ('gouraud-closed',2,2,7,7,32,0,True), ('gouraud-one',2,2,15,16,8,24,False)]
    results = []
    for tag, mode, index, left, right, q0, q1, closed in cases:
        stem = ROOT/'reports/surfaces'/tag
        cmds = [f'load_labels "{b/"3Dvibe64.labels"}"', 'break exec .mx_untextured','x','disable 1',
                f'> ${l["mx_mode"]:04x} {mode:02x}', f'> ${l["mx_flat"]:04x} {index:02x}',
                f'> ${l["leftval"]:04x} {left:02x}', f'> ${l["rightval"]:04x} {right:02x}',
                'bank ram',f'save "{stem}.initial.ram" 0 $0000 $ffff','bank cpu','quit']
        # First learn the actual row selected by the renderer, without
        # guessing its projection or modifying delivery-program bytes.
        run(prg, Path(str(stem)+'-row'), cmds)
        initial = Path(str(stem)+'.initial.ram').read_bytes()[2:]
        row = initial[l['yrow']]
        cmds = cmds[:-4] + [f'> ${l["m3_leftq"]+row:04x} {q0:02x}',
            f'> ${l["m3_rightq"]+row:04x} {q1:02x}', f'> ${l["tq_closed"]+row:04x} {int(closed):02x}',
            'bank ram',f'save "{stem}.before.ram" 0 $0000 $ffff','bank cpu',
            'break exec .gfb_next_restore','x','disable 2','bank ram',
            f'save "{stem}.after.ram" 0 $0000 $ffff','bank cpu','quit']
        info = run(prg, stem, cmds)
        before = Path(str(stem)+'.before.ram').read_bytes()[2:]
        after = Path(str(stem)+'.after.ram').read_bytes()[2:]
        assert row == before[l['yrow']] and 0 <= row < 60
        expected = bytearray(before)
        rows = [before[l[n+'lo']] + 256*before[l[n+'hi']] for n in ('row0','row1')]
        bayer = before[l['m2_bayer']:l['m2_bayer']+16]
        samples = []
        for x in range(left, right+int(closed)):
            den = right-left
            q = q0 if den == 0 else q0+(1 if q1 >= q0 else -1)*(abs(q1-q0)*(x-left)//den)
            value = index if mode == 1 else 1+q//16+int(bayer[(row&3)*4+(x&3)] < q%16)
            if q == 32 and mode == 2: value = 3
            for base in rows:
                addr = base + (x//4)*8
                shift = 6-2*(x&3)
                expected[addr] = (expected[addr] & ~(3<<shift)) | value<<shift
            samples.append(dict(x=x,Q=q,index=value))
        for base in (0x2000,0x6000):
            assert after[base:base+8000] == expected[base:base+8000], ('Native span differs from oracle',tag)
        info.update(result='PASS',mode=mode,row=row,left=left,right=right,closed=closed,
            pixels=len(samples),samples=samples,bitmapBytesCompared=16000,
            monitorOverrides='span inputs only; shader/PRG bytes unchanged',PRGInstrumentationAdded=False)
        stem.with_suffix('.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf-8')
        results.append(dict(case=tag,pixels=len(samples),row=row,result='PASS'))
    return results


def checks(build):
    b,prg,l=paths(build)
    asm=(b/'3Dvibe64.asm').read_text(encoding='utf-8-sig')
    assert 'ps_sample:\n jmp bk_exact_sample\n' in asm
    assert 'ps_advance:\n jmp bk_exact_advance\n' in asm
    assert all(t not in asm for t in ('sp_filter_row:','sp_render_and_fill:','lg_lod_select_disabled:'))
    spans=span_oracle(build)
    views=[]
    for key in range(0,48,6):
        tag=f'view{key:02}'
        capture(build,key,0,tag=tag)
        stem=ROOT/f'reports/views/{build}-{tag}'
        views.append(check_frame(stem.with_suffix('.ram').read_bytes()[2:],
            Path(str(stem)+'.color.ram').read_bytes()[2:],l,tag))
    for tag,camera in [('near-floor',[0,0,-1,0,60]),('clip-ceiling',[0,0,-21.5,0,-60])]:
        capture(build,0,0,enabled=False,camera=camera,tag=tag,skeleton_enabled=False)
        stem=ROOT/f'reports/views/{build}-{tag}'
        views.append(check_frame(stem.with_suffix('.ram').read_bytes()[2:],
            Path(str(stem)+'.color.ram').read_bytes()[2:],l,tag))
    result=dict(result='PASS',PRGSHA256=sha(prg),nativeSpanOracles=spans,
        views=views,LODWeights=lod_trace(build),sharedTransformAndClip=True)
    (ROOT/'reports/native-surfaces.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    return result
