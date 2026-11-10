"""Opt-in, asset-free runtime-scene compiler for ordinary LegacyPlus.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
All native additions use the existing bounded plus allocator. No fixed RAM/ZP.
"""
import argparse
import copy
import json
import math
import re
from pathlib import Path

from animated_mesh import data, table, replace_once
from legacy_plus_exact import block, constant

OPTIONS = ('coordinateTerms', 'rigidMatrixCache', 'uniformGouraud',
           'gouraudSaturation', 'lighting', 'preserveBitmapTail',
           'fixedBackground', 'beforePresent', 'support', 'objectBounds',
           'dynamicLens', 'viewRoll', 'solidLamp')


def integer(value, lo, hi, name):
    if type(value) is not int or not lo <= value <= hi:
        raise ValueError(f'RUNTIME_SCENE: {name} requires integer {lo}..{hi}')
    return value


def symbol(value):
    if not isinstance(value, str) or not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*', value):
        raise ValueError('RUNTIME_SCENE: invalid assembly callback')
    return value


def prepare(document, source_dir):
    """Strip the explicit extension; preserve relative external input paths."""
    scene = copy.deepcopy(document)
    cfg = scene.pop('runtimeScene')
    if not isinstance(cfg, dict) or set(cfg) - set(OPTIONS):
        raise ValueError('RUNTIME_SCENE: unknown configuration fields')
    if scene.get('schema') != 1 or scene.get('axisConvention', 'engine-y-up') != 'engine-y-up':
        raise ValueError('RUNTIME_SCENE: Scene1 engine-y-up required')
    if scene.get('animatedMeshes'):
        raise ValueError('RUNTIME_SCENE: mutable AnimatedMesh coordinates need separate ownership; original AnimatedMesh API is unchanged')
    objects = scene.get('objects')
    if not isinstance(objects, list) or not 1 <= len(objects) <= 255:
        raise ValueError('RUNTIME_SCENE: 1..255 external objects required')
    for name in ('rigidMatrixCache', 'uniformGouraud', 'preserveBitmapTail', 'fixedBackground', 'objectBounds', 'dynamicLens', 'viewRoll'):
        if name in cfg and type(cfg[name]) is not bool:
            raise ValueError('RUNTIME_SCENE: '+name+' requires boolean')
    if cfg.get('coordinateTerms', 'full') not in ('full', 'active-mesh'):
        raise ValueError('RUNTIME_SCENE: coordinateTerms must be full or active-mesh')
    integer(cfg.get('gouraudSaturation', 32), 1, 32, 'gouraudSaturation')
    if (cfg.get('dynamicLens') or cfg.get('viewRoll')) and any(scene.get('world',{}).get(k) for k in ('ground','grounds')):
        raise ValueError('RUNTIME_SCENE: dynamic view requires mesh geometry; independent ground projection is outside this ABI')
    if 'beforePresent' in cfg:
        symbol(cfg['beforePresent'])
    ids = [o.get('id', f'object_{i}') for i, o in enumerate(objects)]
    if len(set(ids)) != len(ids):
        raise ValueError('RUNTIME_SCENE: unique object IDs required')
    lighting = cfg.get('lighting', {})
    if not isinstance(lighting, dict) or set(lighting) - set(ids):
        raise ValueError('RUNTIME_SCENE: lighting keys must name existing objects')
    frozen = [0] * len(objects)
    for name, mode in lighting.items():
        if mode not in ('dynamic', 'frozen', 'solid'):
            raise ValueError('RUNTIME_SCENE: lighting must be dynamic, frozen or solid')
        i = ids.index(name)
        frozen[i] = int(mode == 'frozen')
        if mode == 'solid' and 'colorOverride' not in objects[i]:
            raise ValueError('RUNTIME_SCENE: solid lighting requires explicit colorOverride')
    for mesh in scene.get('meshes', []):
        for field in ('file', 'meshFile', 'wireFile'):
            if field in mesh:
                mesh[field] = str((Path(source_dir) / mesh[field]).resolve())
    for obj in objects:
        for field in ('file', 'meshFile', 'wireFile'):
            if field in obj:
                obj[field] = str((Path(source_dir) / obj[field]).resolve())
    if scene.get('graphicEffect', {}).get('file'):
        scene['graphicEffect']['file'] = str((Path(source_dir) / scene['graphicEffect']['file']).resolve())
    support = cfg.get('support', {})
    if not isinstance(support, dict):
        raise ValueError('RUNTIME_SCENE: support requires an emitter configuration object')
    if 'lod' in support:
        from runtime_support_native import lod_code
        lod_code(support['lod'])
        if support['lod']['objects']!=len(objects):raise ValueError('RUNTIME_SCENE: LOD ownership differs from scene')
        for group in support['lod']['groups']:
            objects[group['near']]['visible']=False
            objects[group['far']]['visible']=True
    solid=[int(lighting.get(i)=='solid') for i in ids]
    if 'solidLamp' in cfg:
        import sys
        sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'extensions/gameplay'))
        from dynamics import solid_lamp_colors
        if not isinstance(cfg['solidLamp'],dict):
            raise ValueError('RUNTIME_SCENE: solidLamp requires mesh IDs')
        meshes={m['id']:m for m in scene.get('meshes',[])}
        for mid, spec in cfg['solidLamp'].items():
            if mid not in meshes or not isinstance(spec,dict) or set(spec)-{'position','dark','bright','threshold','emissive'}:
                raise ValueError('RUNTIME_SCENE: invalid solidLamp mesh/configuration')
            mesh=meshes[mid]
            if 'vertices' not in mesh or 'faces' not in mesh:
                raise ValueError('RUNTIME_SCENE: solidLamp requires external inline geometry')
            mesh['faceSolidColors']=solid_lamp_colors(mesh['vertices'],mesh['faces'],spec['position'],dark=spec['dark'],bright=spec['bright'],threshold=spec.get('threshold',.5),emissive={int(k):v for k,v in spec.get('emissive',{}).items()})
            mesh['useFaceSolidColors']=True
            for i,obj in enumerate(objects):
                if obj.get('mesh')==mid:
                    obj['faceSolidColors']=mesh['faceSolidColors']
                    obj['useFaceSolidColors']=True
                    solid[i]=1
    return scene, dict(schema=1, config=cfg, objects=len(objects), frozen=frozen,solid=solid)


def sparse_terms(source):
    """Use deduplicated per-mesh index lists, with mesh+matrix cache validity."""
    if 'am_prepare_object:' in source:
        raise ValueError('RUNTIME_SCENE: sparse dictionaries require immutable coordinates')
    first, end = table(source, 'mesh_vfirst'), table(source, 'mesh_vend')
    if len(first) != len(end) or not 1 <= len(first) <= 255:
        raise ValueError('RUNTIME_SCENE: invalid native mesh ranges')
    state = 'rs_terms_valid: .byte 0\nrs_terms_mesh: .byte 255\nrs_terms_matrix: .fill 9,0\n'
    code = '''rs_invalidate_terms:
 lda #0
 sta rs_terms_valid
 rts
rs_build_terms:
 lda rs_terms_valid
 beq rs_terms_rebuild
 lda meshidx
 cmp rs_terms_mesh
 bne rs_terms_rebuild
 ldx #8
rs_terms_compare:
 lda m00,x
 cmp rs_terms_matrix,x
 bne rs_terms_rebuild
 dex
 bpl rs_terms_compare
 rts
rs_terms_rebuild:
 lda meshidx
 sta rs_terms_mesh
 ldx #8
rs_terms_save:
 lda m00,x
 sta rs_terms_matrix,x
 dex
 bpl rs_terms_save
 lda #1
 sta rs_terms_valid
'''
    for axis, coefficients in [('x', ('00', '10', '20')), ('y', ('01', '11', '21')), ('z', ('02', '12', '22'))]:
        vi = table(source, 'vert_'+axis+'i')
        lists = [sorted(set(vi[a:b])) for a, b in zip(first, end)]
        if any(not seq or len(seq) > 255 for seq in lists):
            raise ValueError('RUNTIME_SCENE: empty or oversized coordinate domain')
        for mesh, seq in enumerate(lists):
            state += data(f'rs_{axis}_indices_{mesh}', seq)
        for operator, suffix in [('<', 'lo'), ('>', 'hi')]:
            state += f'rs_{axis}_index_{suffix}: .byte '+','.join(operator+f'rs_{axis}_indices_{i}' for i in range(len(lists)))+'\n'
        state += data(f'rs_{axis}_counts', [len(seq) for seq in lists])
        code += f''' ldx meshidx
 lda rs_{axis}_index_lo,x
 sta rs_{axis}_index_load+1
 lda rs_{axis}_index_hi,x
 sta rs_{axis}_index_load+2
 lda rs_{axis}_counts,x
 sta rs_{axis}_remaining
 lda #0
 sta rs_{axis}_cursor
rs_{axis}_loop:
 ldx rs_{axis}_cursor
rs_{axis}_index_load:
 ldy $ffff,x
'''
        for coeff in coefficients:
            code += f' lda {axis}coord,y\n ldx m{coeff}\n jsr mul_s6\n sta {axis}_m{coeff},y\n'
        code += f' inc rs_{axis}_cursor\n dec rs_{axis}_remaining\n bne rs_{axis}_loop\n'
        state += f'rs_{axis}_cursor: .byte 0\nrs_{axis}_remaining: .byte 0\n'
    code += ' rts\n'
    a = source.index('build_coord_terms:\n')
    b = source.index('; Convert signed geometric camera depth', a)
    source = source[:a]+'build_coord_terms:\n jmp rs_build_terms\n\n'+source[b:]
    return source+block('scene_terms', code)+block('scene_terms_data', state)


def rigid_cache(source):
    """Reuse full object rotation, not renderer scratch between components."""
    if constant(source, 'EXPLORER_MATRIX_FOLD'):
        raise ValueError('RUNTIME_SCENE: rigid cache requires separate object/camera matrices')
    # Cache the scaled matrix and the six trigonometric inputs. Dynamic lighting
    # may reconstruct an unscaled matrix in prepare_angles_after_terms.
    source = replace_once(source, 'prepare_angles:\n', '''prepare_angles:
 jsr rs_matrix_try
 bcc rs_matrix_build
 jsr build_coord_terms
 jmp prepare_angles_after_terms
rs_matrix_build:
''')
    source = replace_once(source, ' jsr build_coord_terms\nprepare_angles_after_terms:',
                          ' jsr rs_matrix_store\n jsr build_coord_terms\nprepare_angles_after_terms:')
    labels = ('angx_lo', 'angx', 'angy_lo', 'angy', 'angz_lo', 'angz', 'obj_scale_cur')
    trig = ('sinxv', 'cosxv', 'sinyv', 'cosyv', 'sinzv', 'coszv')
    code = '''rs_invalidate_matrix:
 lda #0
 sta rs_matrix_valid
 rts
rs_matrix_try:
 lda rs_matrix_valid
 beq rs_matrix_miss
'''
    for i, name in enumerate(labels):
        code += f' lda {name}\n cmp rs_matrix_key+{i}\n bne rs_matrix_miss\n'
    code += ' ldx #8\nrs_matrix_restore:\n lda rs_matrix_bytes,x\n sta m00,x\n dex\n bpl rs_matrix_restore\n'
    for i, name in enumerate(trig):
        code += f' lda rs_matrix_trig+{i}\n sta {name}\n'
    code += ' sec\n rts\nrs_matrix_miss:\n clc\n rts\nrs_matrix_store:\n'
    for i, name in enumerate(labels):
        code += f' lda {name}\n sta rs_matrix_key+{i}\n'
    code += ' ldx #8\nrs_matrix_save:\n lda m00,x\n sta rs_matrix_bytes,x\n dex\n bpl rs_matrix_save\n'
    for i, name in enumerate(trig):
        code += f' lda {name}\n sta rs_matrix_trig+{i}\n'
    code += ' lda #1\n sta rs_matrix_valid\n rts\nrs_matrix_valid: .byte 0\nrs_matrix_key: .fill 7,0\nrs_matrix_bytes: .fill 9,0\nrs_matrix_trig: .fill 6,0\n'
    return source+block('scene_matrix', code)


def uniform_gouraud(source):
    """Exact endpoint saturation only, after reflectivity and clipping."""
    if not constant(source, 'GOURAUD_MODE6') or ('MODE7_UV_CARRIER =' in source and constant(source, 'MODE7_UV_CARRIER')):
        raise ValueError('RUNTIME_SCENE: uniform Gouraud requires Mode6')
    # Prove endpoint pigment codes from the actual emitted Bayer LUTs.
    values = []
    for shade in (0, 32):
        rows = [table(source, 'gouraud_bayer_code_lut_y'+str(row)) for row in range(4)]
        masks = [[v[shade]] if len(v) == 33 else v[shade*4:shade*4+4] for v in rows]
        if len(set(tuple(v) for v in masks)) != 1 or any(len(v) not in (1, 4) for v in masks):
            raise ValueError('RUNTIME_SCENE: uniform pigment row proof failed')
        value = 0
        for mask in masks[0]:
            value |= mask
        if value not in (0,85,170,255):
            raise ValueError('RUNTIME_SCENE: endpoint pigment is not spatially uniform')
        values.append(value)
    source = replace_once(source, 'draw_loaded_face_gouraud:\n', '''draw_loaded_face_gouraud:
 jsr rs_uniform_face
 bcc rs_gouraud_original
 lda drawbuf
 bne rs_uniform_b
 jmp draw_loaded_face_solid_a
rs_uniform_b:
 jmp draw_loaded_face_solid_b
rs_gouraud_original:
''')
    code = '''rs_uniform_face:
 lda clip_poly_active
 beq rs_uniform_vertices
 lda clip_a_shade
 cmp #0
 beq rs_uniform_clip_check
 cmp #32
 bne rs_uniform_no
rs_uniform_clip_check:
 ldx #1
rs_uniform_clip_loop:
 cmp clip_a_shade,x
 bne rs_uniform_no
 inx
 cpx clip_a_count
 bcc rs_uniform_clip_loop
 jmp rs_uniform_yes
rs_uniform_vertices:
 lda gouraud_vshade0
 cmp #0
 beq rs_uniform_vertex_check
 cmp #32
 bne rs_uniform_no
rs_uniform_vertex_check:
 cmp gouraud_vshade1
 bne rs_uniform_no
 cmp gouraud_vshade2
 bne rs_uniform_no
 cmp gouraud_vshade3
 bne rs_uniform_no
rs_uniform_yes:
 cmp #0
 beq rs_uniform_dark
 lda #RS_UNIFORM_BRIGHT
 bne rs_uniform_store
rs_uniform_dark:
 lda #RS_UNIFORM_DARK
rs_uniform_store:
 sta fillbyte
 sec
 rts
rs_uniform_no:
 clc
 rts
'''.replace('RS_UNIFORM_DARK', str(values[0])).replace('RS_UNIFORM_BRIGHT', str(values[1]))
    return source+block('scene_uniform', code)


def lighting(source, plan):
    cfg = plan['config'];frozen = plan['frozen'];saturation = cfg.get('gouraudSaturation', 32)
    solid=plan.get('solid',[0]*plan['objects'])
    if not any(frozen) and not any(solid) and saturation == 32:
        return source
    if not constant(source, 'GOURAUD_MODE6'):
        if any(frozen) or saturation!=32:
            raise ValueError('RUNTIME_SCENE: frozen vertex lighting and saturation require Mode6')
        return source
    if 'am_light_original:' in source:
        raise ValueError('RUNTIME_SCENE: lighting has another owner')
    source = replace_once(source, 'gouraud_update_object_shades:\n',
                          'gouraud_update_object_shades:\n jmp rs_update_shades\nrs_update_shades_native:\n')
    code = '''; X=object. Invalidate between views after lamp/normal edits.
rs_invalidate_light:
 cpx #SCENE_OBJECT_COUNT
 bcs rs_light_bad
 lda #0
 sta rs_light_valid,x
 sec
 rts
rs_light_bad:
 clc
 rts
rs_update_shades:
 ldx objidx
 lda rs_solid,x
 beq +
 rts
+
 lda rs_frozen,x
 beq rs_shade_compute
 lda rs_light_valid,x
 beq rs_shade_first
 rts
rs_shade_first:
 lda object_runtime_shade_first,x
 tay
 lda object_runtime_shade_end,x
 sta rs_shade_end
 lda #255
rs_shade_first_loop:
 cpy rs_shade_end
 beq rs_shade_compute
 sta gouraud_shade_value,y
 iny
 jmp rs_shade_first_loop
rs_shade_compute:
 jsr rs_update_shades_native
 ldx objidx
 lda #1
 sta rs_light_valid,x
'''
    if saturation != 32:
        # Store canonical unsaturated lighting in the engine. Apply the curve
        # only to face-local values, so temporal smoothing never compounds it.
        source = replace_once(source, 'gouraud_boost_shade_a:\n', '''gouraud_boost_shade_a:
 stx rs_light_saved_x
 tax
 lda rs_light_curve,x
 ldx rs_light_saved_x
''')
        code += data('rs_light_curve', [min(32, (q*32+saturation//2)//saturation) for q in range(33)])
        # Jump around the LUT in executable flow.
        code = code[:code.index('rs_light_curve:')]+' rts\n'+code[code.index('rs_light_curve:'):]
    else:
        code += ' rts\n'
    code += data('rs_frozen', frozen)+data('rs_solid',solid)+data('rs_light_valid', [0]*len(frozen))+'rs_shade_end: .byte 0\nrs_light_saved_x: .byte 0\n'
    if any(frozen) or any(solid):
        a=source.index('resp_loop:\n');b=source.index('resp_next_object:',a)
        part=source[a:b]
        if ' jsr prepare_object_light_for_shade\n' not in part:
            raise ValueError('RUNTIME_SCENE: unknown object light preparation owner')
        part=part.replace(' jsr prepare_object_light_for_shade\n',' jsr rs_prepare_light\n')
        source=source[:a]+part+source[b:]
        code+='''rs_prepare_light:
 ldx objidx
 lda rs_solid,x
 bne rs_prepare_light_done
 lda rs_frozen,x
 beq rs_prepare_light_dynamic
 lda rs_light_valid,x
 bne rs_prepare_light_done
rs_prepare_light_dynamic:
 jmp prepare_object_light_for_shade
rs_prepare_light_done:
 rts
'''
    return source+block('scene_lighting', code)


def presentation(source, cfg):
    if cfg.get('preserveBitmapTail'):
        if constant(source, 'ENGINE_CAMERA_VIEWPORT_CLEAR_LIMITED'):
            raise ValueError('RUNTIME_SCENE: bitmap-tail preservation currently requires full normal viewport')
        a = source.index('clear_current_bitmap:\n');b = source.index('clear_camera_viewport_bitmap_row:', a)
        piece = source[a:b]
        for bank, last in [('a', '$7f00'), ('b', 'BITMAP_B_BASE+$1f00')]:
            piece = replace_once(piece, f' sta {last},x\n', '')
            hook = f' bne ccb_{bank}_loop\n'
            piece = replace_once(piece, hook, hook+f''' ldx #63
rs_clear_tail_{bank}:
 sta {last},x
 dex
 bpl rs_clear_tail_{bank}
 ldx #0
''')
        source = source[:a]+piece+source[b:]
    if cfg.get('fixedBackground'):
        old='set_bitmap_body_mode:\n lda #WORLD_BACKGROUND_COLOR\n sta $d020\n sta $d021\n'
        if source.count(old) != 2:
            raise ValueError('RUNTIME_SCENE: unknown VIC mode bodies')
        source = source.replace(old, 'set_bitmap_body_mode:\n')
        source = replace_once(source, '\nmain_loop:\n', '\n lda #WORLD_BACKGROUND_COLOR\n sta $d020\n sta $d021\n\nmain_loop:\n')
    if cfg.get('beforePresent') or cfg.get('fixedBackground'):
        source = replace_once(source, ' jsr show_buffer\n jsr fps_frame_done',
                              ' jsr rs_present\n jsr fps_frame_done')
        code = 'rs_present:\n php\n sei\n'
        if cfg.get('beforePresent'):
            code += ' jsr '+symbol(cfg['beforePresent'])+'\n'
        code += ' jsr show_buffer\n jsr set_bitmap_body_mode\n plp\n rts\n'
        source += block('scene_present', code)
    return source


def emit(source, plan):
    if plan.get('schema') != 1 or 'rs_build_terms:' in source:
        raise ValueError('RUNTIME_SCENE: invalid plan or duplicate installation')
    for key, value in [('CAMERA_WALK_LITE', 1), ('MEMORY_LAYOUT_HIGH_BASIC_V2', 1),
                       ('FPS_OVERLAY_ENABLE', 0), ('PROJ_SCREEN_MAX_X', 159), ('PROJ_SCREEN_MAX_Y', 99)]:
        if constant(source, key) != value:
            raise ValueError('RUNTIME_SCENE: incompatible '+key)
    if constant(source, 'GRAPHICS_MODE') not in (4, 5, 6) or 'LEGACY_PLUS_NEAR_SCREEN_Q4=1' not in source:
        raise ValueError('RUNTIME_SCENE: native LegacyPlus Mode4/5/6 required')
    if constant(source, 'SCENE_OBJECT_COUNT') != plan['objects']:
        raise ValueError('RUNTIME_SCENE: object ownership changed')
    cfg = plan['config'];applied = []
    if 'rigidPose' in cfg.get('support',{}):
        from legacy_plus_exact import flag
        for name in ('SCENE_OBJECT_X_ACTIVE','SCENE_OBJECT_Y_ACTIVE','SCENE_OBJECT_SCALE_ACTIVE'):
            source=flag(source,name,1)
    for key, fn in [('coordinateTerms', sparse_terms), ('rigidMatrixCache', rigid_cache), ('uniformGouraud', uniform_gouraud)]:
        if cfg.get(key) == ('active-mesh' if key == 'coordinateTerms' else True):
            source = fn(source);applied.append(key)
    source = lighting(source, plan)
    source = presentation(source, cfg)
    support=copy.deepcopy(cfg.get('support',{}))
    for key in ('rigidPose','lod'):
        if key in support and support[key].get('objects')!=plan['objects']:
            raise ValueError('RUNTIME_SCENE: '+key+' object ownership must equal scene count')
    if cfg.get('dynamicLens') or cfg.get('viewRoll') or cfg.get('objectBounds'):
        import runtime_scene_view as view
        if cfg.get('dynamicLens'):source=view.lens(source)
        if cfg.get('viewRoll'):source=view.roll(source)
        if cfg.get('objectBounds'):source=view.bounds(source,support)
    if support:
        from runtime_support_native import emit_support
        code=emit_support(support)
        if cfg.get('viewRoll') and 'camera' in support:
            code=replace_once(code,'rs_camera_apply:\n','rs_camera_apply:\n lda rs_camera_pose+10\n sta rs_view_bank\n lda rs_camera_pose+11\n sta rs_view_bank+1\n jsr rs_view_prepare\n')
        source += code
    report = dict(schema=1, config=cfg, applied=applied, objects=plan['objects'],
                  allocation='existing bounded LegacyPlus windows', fixedAddresses=False,
                  defaultBehaviorUnchanged=True, mutableCoordinateContract='call rs_invalidate_terms after edits')
    return source, report


def main():
    p = argparse.ArgumentParser(description=__doc__);subs = p.add_subparsers(dest='command', required=True)
    a = subs.add_parser('prepare');a.add_argument('--scene', type=Path, required=True);a.add_argument('--out', type=Path, required=True)
    a = subs.add_parser('emit');a.add_argument('--plan', type=Path, required=True);a.add_argument('--asm', type=Path, required=True)
    args = p.parse_args()
    if args.command == 'prepare':
        scene, plan = prepare(json.loads(args.scene.read_text('utf-8-sig')), args.scene.resolve().parent)
        args.out.mkdir(parents=True, exist_ok=True)
        (args.out/'scene.json').write_text(json.dumps(scene, indent=2)+'\n', encoding='utf-8')
        (args.out/'plan.json').write_text(json.dumps(plan, indent=2)+'\n', encoding='utf-8')
    else:
        source, report = emit(args.asm.read_text('utf-8-sig'), json.loads(args.plan.read_text('utf-8-sig')))
        args.asm.write_text(source, encoding='ascii')
        args.asm.with_suffix('.runtime-scene.json').write_text(json.dumps(report, indent=2)+'\n')


if __name__ == '__main__':
    main()
