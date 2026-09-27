"""Q8-only removal of superseded Q6 view folding; SDK emission untouched."""
import re
from continuous import retire
from emit import product


def compact_matrix(parts):
    old=''.join(product(f'hp_m{i}{j}','hp_scale',f'hp_m{i}{j}') for i in range(3) for j in range(3))+' rts\n'
    assert parts['matrix'].endswith(old),'Q8 matrix tail changed'
    # Same nine products, same order and round-to-nearest. Replace repeated
    # load/store instructions, NOT the arithmetic. Matrix fields are contiguous.
    new=''' lda #0
 sta hp_idx
qm_scale_loop:
 ldx hp_idx
 lda hp_m00,x
 sta hp_a
 lda hp_m00+1,x
 sta hp_a+1
 lda hp_scale
 sta hp_b
 lda hp_scale+1
 sta hp_b+1
 jsr hp_q8
 ldx hp_idx
 lda hp_r
 sta hp_m00,x
 lda hp_r+1
 sta hp_m00+1,x
 inc hp_idx
 inc hp_idx
 lda hp_idx
 cmp #18
 bne qm_scale_loop
 rts
.cerror hp_m22-hp_m00 != 16, "Q8 matrix no longer contiguous"
'''
    parts['matrix']=parts['matrix'][:-len(old)]+new
    return parts


def recover(source,lab):
    if lab.get('SCENE_OBJECT_COUNT') not in (1,2):raise ValueError('Q8_OBJECT_BUDGET: 1..2')
    for key,value in {'EXPLORER_MATRIX_FOLD':1,
                      'STABLE_FACE_CULL_PROFILE':0,'WORLD_GROUND_OCCLUDE':0,
                      'CAMERA_ROLL_ACTIVE':0,'CAMERA_WALK_LITE':1,'CAMERA_MOVABLE':1,
                      'CAMERA_MODE_CYCLE':0,'WORLD_GROUND_ENABLE':0,'MESH_SOURCE_SHARING_RUNTIME':0}.items():
        if lab.get(key)!=value:raise ValueError(f'Q8_MEMORY_PROFILE: {key}={lab.get(key)}')
    start=source.index('explorer_view_origin_x_lo:')
    # Find the enclosing EXPLORER_MATRIX_FOLD terminator, independent of the
    # next family-specific routine (wire has no Mode 4 face latch after it).
    depth=0;end=start
    for line in source[start:].splitlines(keepends=True):
        stripped=line.strip()
        if stripped.startswith('.if '):depth+=1
        elif stripped=='.endif':
            if depth==0:break
            depth-=1
        end+=len(line)
    else:raise ValueError('Q8_FOLD_BLOCK_UNTERMINATED')
    old=source[start:end]
    names=re.findall(r'(?m)^(\w+):',old)
    outside='\n'.join(line.split(';',1)[0] for line in (source[:start]+source[end:]).splitlines())
    for name in names:
        if name=='prepare_explorer_matrix_fold':continue
        if re.search(r'\b'+re.escape(name)+r'\b',outside):
            raise ValueError('Q8_OLD_FOLD_LIVE_CONSUMER: '+name)
    # Lighting still needs the unrotated object matrix. That was the previous
    # routine's final action too. Do NOT substitute the Q8 matrix into lighting.
    new='''; Q8 has private 24-bit origins, matrix/terms and camera rotation.
; Preserve the Q6 object matrix used by the existing lighting pipeline.
prepare_explorer_matrix_fold:
 jmp prepare_object_matrix
'''
    source=source[:start]+new+source[end:]
    # All calls to the stationary projector are in CAMERA_MOVABLE=0 arms.
    # Keep trap aliases (not a lower-precision fallback) and conditional ABI.
    source=retire(source,'rotate_project_vertices:', '\n.if POLY_FILL_ENABLE != 0\ndraw_mesh:')
    a=source.index('build_coord_terms:');b=source.index('; Convert signed geometric camera depth',a)
    source=source[:a]+'build_coord_terms:\n rts ; Q8 term caches are built separately\n\n'+source[b:]
    executable='\n'.join(line.split(';',1)[0] for line in source.splitlines()
                         if not re.match(r'^\w+\s*=',line))
    for n in ('x_m00','x_m10','x_m20','y_m01','y_m11','y_m21','z_m02','z_m12','z_m22'):
        if re.search(r'\b'+n+r'\b',executable):raise ValueError('Q8_OLD_TERMS_LIVE_CONSUMER: '+n)
    return source,dict(
        removedLabels=[n for n in names if n!='prepare_explorer_matrix_fold'],
        reason='No consumers outside retired fold block; Q8 transform uses private state',
        retained='prepare_object_matrix for exact existing illumination',
        stationaryProjector='unreachable with CAMERA_MOVABLE=1; trap aliases retained',
        coordinateTerms='no-op; only consumers belonged to replaced legacy projectors')
