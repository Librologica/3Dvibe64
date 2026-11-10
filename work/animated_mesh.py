"""AnimatedMesh v1 compiler, exact reference sampler and native emitter.

Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
No application geometry, animation or music is embedded in this module.
"""
import argparse
import copy
import hashlib
import json
import re
from pathlib import Path

# Exact agentic23 generator bodies, before ordinary bounded placement/tuning.
# Unknown integrations must select generic or obtain a separate qualification.
COMPACT_BODIES = {
    ('solid','a'):'c5f7f1ee4068d13894f256a3aeca09fd4f882e3589751e5183d9461ec7665cc1',
    ('solid','b'):'a0f67604f9cb94ba9af4133cffdd1bb7a1ba51ca24d45a9ba5251e3bc1390754',
    ('pattern','a'):'a4e922ad14b1aee3033ce392cb660acd639b400c54fd80ab49d2bcbb28563b0a',
    ('pattern','b'):'3b7e8d1b9593ac2aa1075610f3c29d747c4d351d241d93a07da6313cc966b29f',
}


def integer(value, lo, hi, where):
    if type(value) is not int or not lo <= value <= hi:
        raise ValueError(f'ANIMATED_MESH: {where} must be an integer {lo}..{hi}')
    return value


def keys(value, allowed, required, where):
    if not isinstance(value, dict) or set(value) - set(allowed) or set(required) - set(value):
        raise ValueError(f'ANIMATED_MESH: invalid fields in {where}')


def identifier(value, where):
    if not isinstance(value, str) or not re.fullmatch(r'[A-Za-z][A-Za-z0-9_-]{0,47}', value):
        raise ValueError(f'ANIMATED_MESH: invalid {where}')
    return value


def pack_clip(frames):
    """Column minima + deduplicated little-bit-order 0/1/2/4/8-bit streams."""
    columns = []
    streams = []
    lookup = {}
    for axis in range(3):
        for vertex in range(len(frames[0])):
            values = [frame[vertex][axis] for frame in frames]
            base = min(values)
            delta = tuple(v - base for v in values)
            bits = next(n for n in (0, 1, 2, 4, 8) if max(delta) < (1 << n))
            key = bits, delta
            if key not in lookup:
                packed = [] if not bits else [sum(delta[f+j] << (j*bits) for j in range(min(8//bits,len(frames)-f)))
                                              for f in range(0, len(frames), 8//bits)]
                lookup[key] = len(streams)
                streams.append(dict(bits=bits, bytes=packed))
            columns.append(dict(base=base, stream=lookup[key]))
    return dict(frames=len(frames), vertices=len(frames[0]), columns=columns, streams=streams)


def unpack_sample(packed, column, frame):
    c = packed['columns'][column]
    s = packed['streams'][c['stream']]
    bits = s['bits']
    return c['base'] + (0 if not bits else
        (s['bytes'][frame//(8//bits)] >> ((frame % (8//bits))*bits)) & ((1 << bits)-1))


def sample(packed, phase, interpolation='linear'):
    phase %= packed['frames'] * 16
    frame, fraction = divmod(phase, 16)
    if interpolation == 'step':
        fraction = 0
    result = [[0, 0, 0] for _ in range(packed['vertices'])]
    for column in range(3 * packed['vertices']):
        a = unpack_sample(packed, column, frame)
        b = unpack_sample(packed, column, (frame + 1) % packed['frames'])
        difference = b - a
        value = a + (1 if difference >= 0 else -1) * (abs(difference)*fraction//16)
        result[column % packed['vertices']][column//packed['vertices']] = value
    return result


def prepare(document, source_dir):
    """Return ordinary Scene1 plus a native plan; never mutate caller inputs."""
    scene = copy.deepcopy(document)
    assets = scene.pop('animatedMeshes', None)
    renderer = scene.pop('animatedMeshRenderer','generic')
    if renderer not in ('generic','compact-gouraud'):
        raise ValueError('ANIMATED_MESH: animatedMeshRenderer must be generic or compact-gouraud')
    if renderer=='compact-gouraud' and scene.get('world',{}).get('grounds'):
        raise ValueError('ANIMATED_MESH: compact-gouraud requires no world grounds')
    if not isinstance(assets, list) or not 1 <= len(assets) <= 32:
        raise ValueError('ANIMATED_MESH: animatedMeshes must contain 1..32 assets')
    if type(scene.get('schema')) is not int or scene.get('schema') != 1 or scene.get('axisConvention', 'engine-y-up') != 'engine-y-up':
        raise ValueError('ANIMATED_MESH: requires Scene1 engine-y-up')
    if scene.get('timeline'):
        raise ValueError('ANIMATED_MESH: declarative timeline reset integration is not supported in v1')
    if scene.get('contract') or scene.get('objectModel'):
        raise ValueError('ANIMATED_MESH: explicit object-model contracts are not supported in v1')
    meshes = scene.setdefault('meshes', [])
    if not isinstance(meshes, list) or not isinstance(scene.get('objects'), list):
        raise ValueError('ANIMATED_MESH: meshes and objects must be arrays')
    names = {m.get('id') for m in meshes}
    by_id = {}
    clips = []
    bounds = [[63, -63] for _ in range(3)]
    for index, asset in enumerate(assets):
        keys(asset, ['id', 'faces', 'clips', 'material', 'reflectivity', 'lighting', 'creaseAngle'],
             ['id', 'faces', 'clips'], f'asset {index}')
        name = identifier(asset['id'], 'asset id')
        if name in names:
            raise ValueError('ANIMATED_MESH: duplicate mesh/asset id '+name)
        names.add(name)
        ac = asset['clips']
        faces = asset['faces']
        if not isinstance(ac, list) or not 1 <= len(ac) <= 16:
            raise ValueError('ANIMATED_MESH: each asset requires 1..16 clips')
        if not isinstance(faces, list) or not 1 <= len(faces) <= 255:
            raise ValueError('ANIMATED_MESH: faces must contain 1..255 triangles/quads')
        lighting = asset.get('lighting', 'reference')
        crease = integer(asset.get('creaseAngle',180),0,180,'creaseAngle')
        if lighting not in ('reference', 'frozen'):
            raise ValueError('ANIMATED_MESH: lighting must be reference or frozen')
        vertex_count = None
        clip_names = {}
        for clip in ac:
            keys(clip, ['id', 'frames'], ['id', 'frames'], 'clip')
            cid = identifier(clip['id'], 'clip id')
            if cid in clip_names:
                raise ValueError('ANIMATED_MESH: duplicate clip id '+cid)
            frames = clip['frames']
            if not isinstance(frames, list) or len(frames) not in (2, 4, 8, 16, 32, 64):
                raise ValueError('ANIMATED_MESH: frame count must be 2/4/8/16/32/64')
            for frame in frames:
                if not isinstance(frame, list) or not 3 <= len(frame) <= 85:
                    raise ValueError('ANIMATED_MESH: frame requires 3..85 vertices')
                if vertex_count is None:
                    vertex_count = len(frame)
                if len(frame) != vertex_count:
                    raise ValueError('ANIMATED_MESH: vertex count/order must stay constant')
                for vertex in frame:
                    if not isinstance(vertex, list) or len(vertex) != 3:
                        raise ValueError('ANIMATED_MESH: vertex must be [x,y,z]')
                    for axis, value in enumerate(vertex):
                        integer(value, -63, 63, 'coordinate')
                        bounds[axis][0] = min(bounds[axis][0], value)
                        bounds[axis][1] = max(bounds[axis][1], value)
            clip_names[cid] = len(clips)
            clips.append(dict(asset=index, id=cid, packed=pack_clip(frames)))
        for face in faces:
            if not isinstance(face, list) or len(face) not in (3, 4):
                raise ValueError('ANIMATED_MESH: faces must be triangles or quads')
            for v in face:
                integer(v, 0, vertex_count-1, 'face index')
            if len(set(face)) != len(face):
                raise ValueError('ANIMATED_MESH: repeated face vertex')
        by_id[name] = dict(index=index, clips=clip_names, lighting=lighting)
        mesh = dict(id=name, type='mesh', geometry='solid', vertices=ac[0]['frames'][0], faces=faces,
                    gouraud=dict(creaseAngle=crease))
        for key in ('material', 'reflectivity'):
            if key in asset:
                mesh[key] = asset[key]
        meshes.append(mesh)
    if len(clips) > 255:
        raise ValueError('ANIMATED_MESH: total clips must fit 255 entries')
    instances = []
    object_ids = set()
    for i, obj in enumerate(scene['objects']):
        oid = obj.get('id')
        identifier(oid, 'object id')
        if oid in object_ids:
            raise ValueError('ANIMATED_MESH: duplicate object id')
        object_ids.add(oid)
        if obj.get('mesh') not in by_id:
            if 'animation' in obj:
                raise ValueError('ANIMATED_MESH: animation requires an animated mesh')
            continue
        asset = by_id[obj['mesh']]
        anim = obj.pop('animation', {})
        keys(anim, ['clip', 'phase', 'step', 'interpolation'], [], 'instance animation')
        cid = anim.get('clip', next(iter(asset['clips'])))
        if not isinstance(cid, str) or cid not in asset['clips']:
            raise ValueError('ANIMATED_MESH: unknown animation clip')
        clip_index = asset['clips'][cid]
        phase = integer(anim.get('phase', 0), 0, clips[clip_index]['packed']['frames']*16-1, 'phase')
        step = integer(anim.get('step', 8), 0, 255, 'step')
        interpolation = anim.get('interpolation', 'linear')
        if interpolation not in ('linear', 'step'):
            raise ValueError('ANIMATED_MESH: interpolation must be linear or step')
        instances.append(dict(object=i, asset=asset['index'], clip=clip_index, phase=phase,
                              step=step, interpolation=interpolation, frozen=asset['lighting']=='frozen'))
    if not instances or len(instances) > 255:
        raise ValueError('ANIMATED_MESH: requires 1..255 animated instances')
    # Absolute external file paths retain their meaning in the generated scene.
    def paths(value):
        if isinstance(value, dict):
            for key, v in value.items():
                if key in ('file', 'meshFile', 'wireFile') and isinstance(v, str):
                    value[key] = str((Path(source_dir)/v).resolve())
                else:
                    paths(v)
        elif isinstance(value, list):
            for v in value:
                paths(v)
    paths(scene)
    # Source and topology sharing uses the engine's existing bounded buffers.
    references = [o['mesh'] for o in scene['objects'] if isinstance(o.get('mesh'), str)]
    if len(references) != len(set(references)):
        scene['meshSourceSharing'] = True
    return scene, dict(schema=1, renderer=renderer, assets=list(by_id), clips=clips, instances=instances,
                      axisBounds=bounds, objects=len(scene['objects']))


def data(name, values):
    return name+':\n'+''.join(' .byte '+','.join(str(v & 255) for v in values[i:i+24])+'\n'
                              for i in range(0, len(values), 24))


def table(source, name):
    match = re.search(r'^'+re.escape(name)+r':\n((?:\s+\.byte [^\n]+\n)+)', source, re.M)
    if not match:
        raise ValueError('ANIMATED_MESH: missing native table '+name)
    values = []
    for value in re.findall(r'\$[0-9a-fA-F]+|-?\d+', match[1]):
        values.append(int(value[1:], 16) if value.startswith('$') else int(value))
    return values


def replace_once(source, old, new):
    if source.count(old) != 1:
        raise ValueError('ANIMATED_MESH: unknown native hook '+old[:65])
    return source.replace(old, new, 1)


def emit(source, plan):
    """Attach before legacy_plus_memory allocation; no fixed scratch addresses."""
    if 'am_reset_all:\n' in source:
        raise ValueError('ANIMATED_MESH: native extension already installed')
    count = plan['objects']
    compact_removed = 0
    if plan['renderer']=='compact-gouraud':
        required={'GRAPHICS_MODE':6,'GOURAUD_MODE6':1,'RUNTIME_GRAPHICS_MODE_SWITCH':0,
                  'HIDDEN_WIRE_ENABLE':0,'WIRE_MESH_COUNT':0,'FLAT_DYNAMIC_SHADE':0,
                  'FACE_SOLID_COLOR_ENABLE':0,'WORLD_GROUND_ENABLE':0}
        for key,value in required.items():
            match=re.search(r'^'+key+r' = \$([0-9a-fA-F]+)$',source,re.M)
            if not match or int(match[1],16)!=value:
                raise ValueError('ANIMATED_MESH: compact-gouraud incompatible '+key)
        include=re.search(r'; Scene graphic include: [^\n]*\n(.*?)\n; End scene graphic include',source,re.S)
        application=include[1] if include else ''
        for kind,short in [('solid','fbs'),('pattern','fbp')]:
            for buffer in 'ab':
                start=f'fill_bounds_{kind}_{buffer}:\n';end=f'{short}_{buffer}_done:\n rts\n'
                if source.count(start)!=1 or source.count(end)!=1:
                    raise ValueError('ANIMATED_MESH: unknown compact filler body')
                a=source.index(start);b=source.index(end,a)+len(end);body=source[a:b]
                if hashlib.sha256(body.encode('ascii')).hexdigest()!=COMPACT_BODIES[kind,buffer]:
                    raise ValueError('ANIMATED_MESH: unknown compact filler body hash; select generic')
                if body.count('.if ')!=body.count('.endif'):
                    raise ValueError('ANIMATED_MESH: unbalanced compact filler body')
                removed=re.findall(r'^(\w+):',body,re.M)
                if any(re.search(r'\b'+label+r'\b',application) for label in removed):
                    raise ValueError('ANIMATED_MESH: application references compacted filler')
                replacement=start+' jmp am_compact_violation\n'
                compact_removed+=len(body)-len(replacement)
                source=source[:a]+replacement+source[b:]
    mapping = [255]*count
    frozen = [0]*count
    initial_clip = [0]*count
    initial_phase = [0]*count
    steps = [0]*count
    interpolate = [0]*count
    owner = [255]*count
    for instance in plan['instances']:
        i = instance['object']
        mapping[i] = instance['asset']
        owner[i] = instance['asset']
        frozen[i] = int(instance['frozen'])
        initial_clip[i] = instance['clip']
        initial_phase[i] = instance['phase']
        steps[i] = instance['step']
        interpolate[i] = int(instance['interpolation']=='linear')
    source = replace_once(source, '\nmain_loop:\n', '\n jsr am_reset_all\n\nmain_loop:\n')
    source = replace_once(source, 'advance_sim_tick:\n', 'advance_sim_tick:\n jsr am_tick\n')
    # Runs after object/mesh ranges have been selected, before any transformation.
    start = source.index('set_active_object:\n')
    end = source.index('\n rts\n', start)
    source = source[:end]+'\n jsr am_prepare_object'+source[end:]
    if any(frozen):
        source = replace_once(source, 'gouraud_update_object_shades:\n', '''gouraud_update_object_shades:
 ldx objidx
 lda am_frozen,x
 beq am_light_original
 lda am_light_valid,x
 beq am_light_first
 rts
am_light_first:
 inc am_light_valid,x
 lda object_runtime_shade_end,x
 sta am_light_end
 lda object_runtime_shade_first,x
 tay
 lda #255
am_light_reset_values:
 cpy am_light_end
 beq am_light_original
 sta gouraud_shade_value,y
 iny
 jmp am_light_reset_values
am_light_original:
''')
    info = ''
    for n, values in [('map',mapping),('frozen',frozen),('initial_clip',initial_clip),
                      ('initial_lo',[p & 255 for p in initial_phase]),('initial_hi',[p >> 8 for p in initial_phase]),
                      ('step',steps),('linear',interpolate),('owner',owner)]:
        info += data('am_'+n, values)
    for n in ('clip','phase_lo','phase_hi','light_valid'):
        info += data('am_'+n, [0]*count)
    meshes = len(table(source, 'mesh_vfirst'))
    for n in ('cache_lo','cache_hi'):
        info += data('am_'+n, [0]*meshes)
    info += data('am_cache_clip', [255]*meshes)
    info += data('am_clip_owner', [c['asset'] for c in plan['clips']])
    info += data('am_frame_mask', [c['packed']['frames']-1 for c in plan['clips']])
    info += data('am_phase_mask', [(c['packed']['frames']*16-1) >> 8 for c in plan['clips']])
    info += data('am_vertices', [c['packed']['vertices'] for c in plan['clips']])
    for op, suffix in [('<','lo'),('>','hi')]:
        for field in ('base','ptrlo','ptrhi','bits'):
            info += f'am_{field}_{suffix}: .byte '+','.join(op+f'am_c{i}_{field}' for i in range(len(plan['clips'])))+'\n'
    unique = {}
    descriptors = []
    for i, clip in enumerate(plan['clips']):
        p = clip['packed']
        labels = []
        bits = []
        for c in p['columns']:
            s = p['streams'][c['stream']]
            key = tuple(s['bytes'])
            if key not in unique:
                unique[key] = f'am_stream_{len(unique)}'
            labels.append(unique[key])
            bits.append(s['bits'])
        descriptors.append(data(f'am_c{i}_base', [c['base'] for c in p['columns']])+
            f'am_c{i}_ptrlo: .byte '+','.join('<'+label for label in labels)+'\n'+
            f'am_c{i}_ptrhi: .byte '+','.join('>'+label for label in labels)+'\n'+data(f'am_c{i}_bits',bits))
    coordinates = []
    for axis in 'xyz':
        values = table(source, axis+'coord')
        values = [v-256 if v > 127 else v for v in values]
        if values != list(range(min(values), max(values)+1)):
            raise ValueError('ANIMATED_MESH: coordinate domain is not contiguous')
        coordinates.append(min(values))
    code = (Path(__file__).with_suffix('.asm')).read_text(encoding='ascii')
    code = code.replace('AM_OBJECTS',str(count)).replace('AM_CLIPS',str(len(plan['clips'])))
    code = code.replace('AM_MESHES',str(meshes))
    for axis, minimum in zip('xyz',coordinates):
        code = code.replace('AM_OFFSET_'+axis.upper(),str((-minimum) & 255))
    # Every block is placed by the existing allocator in its existing windows.
    blocks = {'animated_runtime': code, 'animated_instances': info,
              **{f'animated_clip_{i}': d for i,d in enumerate(descriptors)}}
    blocks['animated_streams'] = ''.join(data(label, list(b) or [0]) for b,label in unique.items())
    for name, body in blocks.items():
        source += f'\n; Plus allocation block {name}\n.virtual $4000\nlpa_block_{name}_begin:\n{body.rstrip()}\nlpa_block_{name}_end:\n.endvirtual\n'
    report = dict(schema=1, instances=len(plan['instances']), assets=len(plan['assets']),
                  clips=len(plan['clips']), uniqueStreams=len(unique),
                  posePayloadBytes=sum(len(b) or 1 for b in unique),
                  columnDescriptorBytes=sum(12*c['packed']['vertices'] for c in plan['clips']),
                  uncompressedPoseBytes=sum(3*c['packed']['vertices']*c['packed']['frames'] for c in plan['clips']),
                  interpolation='a + sign(b-a) * floor(abs(b-a)*fraction/16)',
                  coordinateMinimum=coordinates, nativeBlocks=list(blocks),renderer=plan['renderer'],
                  compactRemovedSourceCharacters=compact_removed)
    return source, report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    p = sub.add_parser('prepare');p.add_argument('--scene',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p = sub.add_parser('emit');p.add_argument('--plan',type=Path,required=True);p.add_argument('--asm',type=Path,required=True)
    args = parser.parse_args()
    if args.command == 'prepare':
        scene, plan = prepare(json.loads(args.scene.read_text('utf-8-sig')),args.scene.resolve().parent)
        args.out.mkdir(parents=True,exist_ok=True)
        (args.out/'scene.json').write_text(json.dumps(scene,indent=2)+'\n',encoding='utf-8')
        (args.out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n',encoding='utf-8')
    else:
        source, report = emit(args.asm.read_text('utf-8-sig'),json.loads(args.plan.read_text('utf-8-sig')))
        args.asm.write_text(source,encoding='ascii')
        args.asm.with_suffix('.animated-mesh.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')


if __name__ == '__main__':
    main()
