"""Private per-object dispatch to the native Mode4 flat bitmap fillers.
Required Notice:3Dvibe64. PolyForm Noncommercial1.0.0.
Geometry/clipping retain Q8 coverage; the statue has one Lambert level per face,
no interpolated vertex lighting, no texel sampling and no UV block traversal.
Static geometry and static light allow host evaluation of the face lighting.
"""
import json,math
from pathlib import Path
from optimizations import once
ROOT=Path(__file__).resolve().parents[1]

def apply(source,scene):
    mesh=scene['meshes'][-1];obj=scene['objects'][-1]
    assert obj['mesh']=='central-venus' and obj['rotation']==[0,0,0] and obj['scale']==1
    first=sum(len(m['faces']) for m in scene['meshes'][:-1]);assert first+len(mesh['faces'])<255
    codes=[];report=[]
    for face in mesh['faces']:
        p,q,r=[mesh['vertices'][i] for i in face]
        u=[q[i]-p[i] for i in range(3)];v=[r[i]-p[i] for i in range(3)]
        n=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
        center=[sum(mesh['vertices'][i][a] for i in face)/3 for a in range(3)]
        # One face-centroid light evaluation, constant over the entire triangle.
        assert any(n),('degenerate sculpture face',face)
        lamp=[-12,18,-16];delta=[lamp[a]-center[a] for a in range(3)]
        cosine=max(0,sum(n[a]*delta[a] for a in range(3))/(math.sqrt(sum(x*x for x in n))*math.sqrt(sum(x*x for x in delta))))
        # Native Mode4 solid codes0/2/4 correspond to dark/high/highlight.
        # No spatial dither is needed for this flat sculpture.
        code=0 if cosine<.15 else 2 if cosine<.60 else 4
        codes.append(code);report.append(dict(normal=n,cosine=cosine,mode4ShadeCode=code))
    (ROOT/'reports/flat-venus.json').write_text(json.dumps(dict(faceFirst=first,faces=report,
        renderer='native fill_bounds_solid_a/b (Mode4); pattern route retained',
        lighting='static per-plane Lambert, three native palette levels; no Gouraud'),indent=2))
    source=once(source,' jmp gouraud_fill_bounds\n',' jmp fc_finish_bounds\n')
    return source+f'''\n*=$4000
fc_begin:
fc_finish_bounds:
 ; The bucket drawer uses sortj; faceidx retains the collection cursor.
 lda sortj
 cmp #{first}
 bcs fc_cube
 jmp gouraud_fill_bounds
fc_cube:
 tay
 lda fc_shade_codes-{first},y
 sta fc_code
 ; Mode7 bounds have half-open right edges; Mode4 fills use inclusive ends.
 ; Convert coverage only, retaining screen-clipping caps and degenerate rows.
 ldx face_ymin
fc_inclusive:
 lda leftb,x
 cmp rightb,x
 bcc fc_nonempty
 bne fc_next
 lda tq_closed,x
 bne fc_next
 lda #255
 sta leftb,x
 lda #0
 sta rightb,x
 jmp fc_next
fc_nonempty:
 lda tq_closed,x
 bne fc_next
 dec rightb,x
fc_next:
 cpx face_ymax
 beq fc_draw
 inx
 jmp fc_inclusive
fc_draw:
 lda fc_code
 bmi fc_pattern
 tay
 lda shade_solid_bytes,y
 sta fillbyte
 lda drawbuf
 bne fc_solid_b
 jmp fill_bounds_solid_a
fc_solid_b:
 jmp fill_bounds_solid_b
fc_pattern:
 and #127
 sta shadeidx
 lda drawbuf
 bne fc_pattern_b
 jmp fill_bounds_pattern_a
fc_pattern_b:
 jmp fill_bounds_pattern_b
fc_code: .byte 0
fc_shade_codes: .byte '''+','.join(map(str,codes))+'''
fc_end:
'''
