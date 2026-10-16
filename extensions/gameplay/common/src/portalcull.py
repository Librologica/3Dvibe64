"""Conservative horizontal aperture bounds for this two-convex-room demo only.
Required Notice:3Dvibe64. PolyForm Noncommercial1.0.0.
No clipping/rasterizer modification; reject whole fully front triangles only.
"""
import json,re
from pathlib import Path
from block4 import once
ROOT=Path(__file__).resolve().parents[1]

def recover(source):
    a=source.index('camera_plane_add_dot:\n');b=source.index('\n.if MEMORY_LAYOUT_HIGH_BASIC_V2 = 0',a)
    body=source[a:b];names=re.findall(r'(?m)^(\w+):',body)
    rest=source[:a]+source[b:]
    code='\n'.join(line.split(';',1)[0] for line in rest.splitlines())
    for n in names:assert not re.search(r'\b'+n+r'\b',code),('live helper',n)
    source=source[:a]+''.join(n+' = hp_unreachable\n' for n in names)+source[b:]
    removed=[]
    for n,decl in [('m3_clip_b_q','m3_clip_b_q: .fill 12,0\n'),
                   ('m3_texel','m3_texel: .byte 0\n')]:
        rest=once(source,decl,'')
        code='\n'.join(line.split(';',1)[0] for line in rest.splitlines())
        assert not re.search(r'\b'+n+r'\b',code),n
        source=rest;removed.append(n)
    for n in ('object_runtime_shade_first','object_runtime_shade_end'):
        m=re.search(r'(?m)^'+n+r':\n(?: \.byte[^\n]*\n)+',source);assert m,n
        rest=source[:m.start()]+source[m.end():]
        assert not re.search(r'\b'+n+r'\b','\n'.join(x.split(';',1)[0] for x in rest.splitlines()))
        source=rest;removed.append(n)
    (ROOT/'reports/portal-memory-proof.json').write_text(json.dumps(dict(labels=names,
        scalarDeclarations=removed,externalConsumers=0),indent=2))
    return source

def code(ids):
    # The automatic trajectory is build-validated inside these convex rooms.
    # Do not deploy this specialization with interactive/unbounded cameras.
    return f'''pc_prepare:
 lda #255
 sta pc_remote
 ldx #0
 lda explorer_cam_z_hi
 bmi pc_set_plane
 cmp #22
 bcc pc_set_plane
 cmp #26
 bcc pc_prepare_done
 ldx #4
pc_set_plane:
 lda #111
 sta pc_left
 lda #0
 sta pc_right
pc_portal_loop:
 ldy pc_vertices,x
 lda projdone,y
 beq pc_prepare_done
 lda sx,y
 cmp pc_left
 bcs pc_not_left
 sta pc_left
pc_not_left:
 cmp pc_right
 bcc pc_not_right
 sta pc_right
pc_not_right:
 inx
 txa
 and #3
 bne pc_portal_loop
 ; Clamped monotonic coordinates plus two-pixel conservative expansion.
 lda pc_left
 sec
 sbc #2
 bcs pc_left_ready
 lda #0
pc_left_ready:
 sta pc_left
 lda pc_right
 clc
 adc #2
 cmp #112
 bcc pc_right_ready
 lda #111
pc_right_ready:
 sta pc_right
 txa
 lsr
 lsr
 and #1
 sta pc_remote
pc_prepare_done:
 rts
pc_visible:
 lda objidx
 cmp pc_remote
 bne pc_accept
 lda faceidx
 cmp #18
 bcc pc_regular
 cmp #26
 bcc pc_accept
pc_regular:
 ldx faceidx
 lda #3
 sta pc_mask
 sta pc_count
pc_face_loop:
 ; Builder proves face0/1/2 are consecutive 64-byte topology tables.
 ldy face0,x
 lda projdone,y
 beq pc_accept
 lda sx,y
 cmp pc_left
 bcc pc_left_outside
 lda pc_mask
 and #2
 sta pc_mask
pc_left_outside:
 lda sx,y
 cmp pc_right
 beq pc_right_inside
 bcs pc_right_outside
pc_right_inside:
 lda pc_mask
 and #1
 sta pc_mask
pc_right_outside:
 txa
 clc
 adc #64
 tax
 dec pc_count
 bne pc_face_loop
 lda pc_mask
 bne pc_reject
pc_accept:
 sec
 rts
pc_reject:
 clc
 rts
pc_vertices: .byte {','.join(map(str,ids))}
pc_remote: .byte 255
pc_left: .byte 0
pc_right: .byte 0
pc_mask: .byte 0
pc_count: .byte 0
.if face1-face0 != 64 || face2-face1 != 64
 .error "Portal selector topology stride changed"
.endif
'''

def adapt(source,parts,placed,enabled):
    if not enabled:return source,parts
    scene=json.loads((ROOT/'room/scenes/large-room.json').read_text())
    assert [len(m['faces']) for m in scene['meshes']]==[36,28]
    mesh=scene['meshes'][0]
    poses=json.loads((ROOT/'room/scenes/camera-keyframes.json').read_text())['posesQ8']
    assert len(poses)==32
    assert all(-23*256<p[0]<23*256 and -23*256<p[2]<71*256 and p[1]==0 for p in poses)
    # Piecewise-linear Q8 route stays in its endpoint envelope; inherited
    # camera bob is much smaller than the floor/ceiling safety margin.
    ids=[mesh['vertices'].index([x,y,z]) for z in (23,25) for x in (-7,7) for y in (-10,18)]
    if placed is None:
        parts['core']+=code(ids)
        # Physical placement only: split at a proven RTS routine boundary.
        # Instructions, labels, buffers and four legal RAM windows unchanged.
        body=parts['projection'];a=body.index('hc_screen_pass:\n')
        assert body[:a].rstrip().endswith('rts')
        parts['projection']=body[:a]
        parts['portal_screen_placement']=body[a:]
    refs=[line.strip() for line in (source+'\n'+'\n'.join(parts.values())).splitlines()
          if re.search(r'\bhp_sin_(?:lo|hi)\b',line.split(';',1)[0]) and not re.match(r'^hp_sin_(?:lo|hi):',line)]
    assert len(refs)==4 and all(re.fullmatch(r'lda hp_sin_(?:lo|hi),x',x) for x in refs),refs
    source=once(source,'collect_active_mesh_faces:\n','''collect_active_mesh_faces:
 lda objidx
 bne pc_collect_ready
 jsr pc_prepare
pc_collect_ready:
''')
    source=once(source,' jsr load_face_visible\ndm_skip:\n',' jsr pc_visible\n bcc dm_skip\n jsr load_face_visible\ndm_skip:\n')
    return source,parts
