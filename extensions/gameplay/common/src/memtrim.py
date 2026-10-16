"""Demo-specific removal of proved unreferenced legacy culling bodies.
Required Notice:3Dvibe64. Copyright2026 librologica.digital.
PolyForm Noncommercial1.0.0. Frozen SDKs remain unchanged.
"""
import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def trim(source,parts):
    assert re.search(r'(?m)^STABLE_FACE_CULL_PROFILE\s*=\s*(?:0|\$00)\s*$',source)
    assert re.search(r'(?m)^STANDARD_PROJECT_VERTEX\s*=\s*(?:0|\$00)\s*$',source)
    blocks=[('face_visible:','project_vertex:'),
            ('camera_plane_original_facing:','camera_plane_add_dot:')]
    names=[];proof=[];cuts=[]
    for start,end in blocks:
        starts=list(re.finditer(r'(?m)^'+re.escape(start)+r'\s*$',source))
        ends=list(re.finditer(r'(?m)^'+re.escape(end)+r'\s*$',source))
        assert len(starts)==len(ends)==1,(start,end,len(starts),len(ends))
        a=starts[0].start();b=ends[0].start();assert a<b
        body=source[a:b];local=re.findall(r'(?m)^(\w+):',body)
        names+=local;cuts.append((a,b,body,local))
    # Check against program with ALL selected bodies removed. References
    # internal to a removed body are harmless; any external symbol consumer
    # including pointers/SMC/aliases causes an error, even in false .if code.
    rest=source
    for a,b,body,local in sorted(cuts,reverse=True):rest=rest[:a]+rest[b:]
    whole='\n'.join(line.split(';',1)[0] for line in
        (rest+'\n'+'\n'.join(parts.values())).splitlines())
    for name in names:
        assert not re.search(r'\b'+re.escape(name)+r'\b',whole),('live dead-code consumer',name)
    for a,b,body,local in sorted(cuts,reverse=True):
        new='; Demo-only: no symbolic entry/pointer/SMC consumers remain.\n'
        # Preserve macro/conditional balance and make accidental future
        # references explicit traps rather than permitting arbitrary RAM.
        for line in body.splitlines():
            m=re.match(r'^(\w+):',line)
            if m:new+=m[1]+' = hp_unreachable\n'
            elif line.strip().startswith(('.if ','.else','.elsif ','.endif')):new+=line+'\n'
        source=source[:a]+new+source[b:]
        proof.append(dict(start=body.splitlines()[0],labels=local,externalConsumers=0))
    assert 'camera_plane_add_dot:' in source and 'camera_plane_mul_s16_s6:' in source
    (ROOT/'reports/memtrim-symbolic-proof.json').write_text(json.dumps(proof,indent=2))
    return source,parts
