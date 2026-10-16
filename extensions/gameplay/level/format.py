"""Common authoring format, resolved IDs and explicit WORLD-01 compatibility.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
This is host code: authoring records are not extra resident C64 tables.
"""
import copy
import hashlib
import importlib.util
import json
import math
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILTINS = {}  # Project artwork is deliberately not distributed.

FEATURES = ('multiple-billboards', 'shared-meshes', 'controlled-animation',
            'camera-roll', 'texture-animation', 'static-light', 'sector-visibility')


def read_json(path):
    def pairs(rows):
        result = {}
        for key, value in rows:
            if key in result:
                raise ValueError('Duplicate JSON key: '+key)
            result[key] = value
        return result
    def constant(value):
        raise ValueError('Non-finite JSON constant: '+value)
    return json.loads(Path(path).read_text(encoding='utf-8-sig'), object_pairs_hook=pairs, parse_constant=constant)


def module(name, relative):
    spec = importlib.util.spec_from_file_location(name, ROOT/'extensions/gameplay'/relative)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def fail(where, message):
    raise ValueError(f'{where}: {message}')


def record(value, fields, where):
    if not isinstance(value, dict) or set(value) != set(fields.split()):
        fail(where, 'expected fields '+fields)


def integer(value, lo, hi, where):
    if type(value) is not int or not lo <= value <= hi:
        fail(where, f'expected integer {lo}..{hi}')


def number(value, lo, hi, where, step=1/256):
    if type(value) not in (int, float) or not math.isfinite(value) or not lo <= value <= hi or value/step != round(value/step):
        fail(where, 'expected finite quantized value in range')


def vector(value, size, lo, hi, where):
    if not isinstance(value, list) or len(value) != size:
        fail(where, f'expected vector of {size} values')
    for item in value:
        number(item, lo, hi, where)


def flag(value, where):
    if type(value) is not bool:
        fail(where, 'expected boolean')


def items(value, lo, hi, where):
    if not isinstance(value, list) or not lo <= len(value) <= hi:
        fail(where, f'expected {lo}..{hi} entries')


def unique_strings(value, allowed, where):
    if not isinstance(value, list) or any(type(x) is not str or x not in allowed for x in value) or len(value) != len(set(value)):
        fail(where, 'invalid or repeated entry')


def asset_path(asset, directory):
    source = asset['source']
    if not isinstance(source, str):
        fail(asset['id'], 'asset source must be a string')
    if not source.startswith('file:'):
        fail(asset['id'], 'use file:relative/path.json; built-in demo assets are not distributed')
    relative = source[5:]
    if not relative or '\\' in relative or ':' in relative or relative.startswith('/'):
        fail(asset['id'], 'asset path must be relative to the level directory')
    directory = Path(directory).resolve()
    path = (directory/relative).resolve()
    if not path.is_relative_to(directory) or path.suffix.lower() != '.json' or not path.is_file():
        fail(asset['id'], 'asset must be an existing JSON file inside the level directory')
    return path


def validate(document, directory):
    """Validate graph/references and assets; never silently drop unsupported data."""
    d = copy.deepcopy(document)
    record(d, 'schema format id axisConvention target memory features assets groups rooms objects connections spawns events start', 'level')
    if type(d['schema']) is not int or d['schema'] != 1 or d['format'] != '3Dvibe64.level' or d['axisConvention'] != 'world-z-up':
        fail('level', 'requires common format1 and public world-z-up coordinates')
    if not isinstance(d['id'], str) or not re.fullmatch('[a-z][a-z0-9-]{0,47}', d['id']):
        fail('level', 'invalid level id')
    record(d['target'], 'standard multiplier quality textureLOD music autoTransitions', 'target')
    target = d['target']
    if target['standard'] != 'pal' or type(target['multiplier']) is not int or target['multiplier'] != 64 or target['quality'] != 'precise':
        fail('target', 'this checkpoint targets PAL x64 with precise rendering')
    if not isinstance(target['textureLOD'], list) or len(target['textureLOD']) != 2 or any(type(x) is not int for x in target['textureLOD']) or target['textureLOD'] != [14, 22]:
        fail('target', 'qualified texture LOD is [14,22]')
    flag(target['music'], 'target.music')
    if target['music']:
        fail('target', 'the qualified WORLD-01 runtime is silent')
    flag(target['autoTransitions'], 'target.autoTransitions')
    record(d['memory'], 'reserveBytes minimumContiguousBytes stagingBytes', 'memory')
    integer(d['memory']['reserveBytes'], 0, 65535, 'memory.reserveBytes')
    integer(d['memory']['minimumContiguousBytes'], 0, 65535, 'memory.minimumContiguousBytes')
    if type(d['memory']['stagingBytes']) is not int or d['memory']['stagingBytes'] != 1024:
        fail('memory', 'WORLD-01 staging is exactly1024 bytes')
    unique_strings(d['features'], FEATURES, 'features')
    limits = {'assets': (1, 64), 'groups': (2, 8), 'rooms': (2, 64), 'objects': (1, 255),
              'connections': (1, 128), 'spawns': (1, 64), 'events': (0, 255)}
    registry = {}
    tables = {}
    for name, (lo, hi) in limits.items():
        items(d[name], lo, hi, name)
        tables[name] = {}
        for item in d[name]:
            if not isinstance(item, dict) or not isinstance(item.get('id'), str) or not re.fullmatch('[a-z][a-z0-9-]{0,47}', item['id']):
                fail(name, 'invalid id')
            if item['id'] in registry:
                fail(name, 'ids must be globally unique: '+item['id'])
            registry[item['id']] = name
            tables[name][item['id']] = item

    def ref(name, identifier, where):
        if not isinstance(identifier, str) or identifier not in tables[name]:
            fail(where, 'unknown '+name+' reference '+str(identifier))
        return tables[name][identifier]

    loaded = {}
    for a in d['assets']:
        record(a, 'id kind source', a['id'])
        if a['kind'] not in ('billboard', 'materials', 'mesh'):
            fail(a['id'], 'unknown asset kind')
        path = asset_path(a, directory)
        data = read_json(path)
        if a['kind'] == 'materials':
            fake = {'meshes': [{'id': 'comparison-room', 'faces': [[0, 1, 2]]*16}]}
            module('level_surfaces', 'materials/surfaces.py').compile_surfaces(fake, data)
        elif a['kind'] == 'mesh':
            module('level_mesh', 'meshes/shared.py').configure_asset(data)
        else:
            minimal = dict(schema=1, billboards=[dict(id='asset-check', asset='unused.json',
                position=[0, 0, 0], size=[1, 1], animations={k: dict(frames=[0], ticksPerFrame=1) for k in ('idle', 'used')})],
                entity=dict(billboard='asset-check', enabled=True, useRange=1, collisionHalfSize=[.25, .25], demoUseKeys=[]))
            module('level_asset', 'billboards/scene.py').validate(minimal, data)
        loaded[a['id']] = dict(path=path, data=data, SHA256=hashlib.sha256(path.read_bytes()).hexdigest().upper())
    for g in d['groups']:
        record(g, 'id geometry materials entry', g['id'])
        record(g['geometry'], 'template halfWidth floorLevel doorIndex', g['id']+'.geometry')
        if g['geometry']['template'] != 'two-room-divider-v1':
            fail(g['id'], 'unknown geometry template')
        integer(g['geometry']['halfWidth'], 18, 24, g['id']+'.halfWidth')
        if g['geometry']['floorLevel'] is not None:
            integer(g['geometry']['floorLevel'], 0, 32, g['id']+'.floorLevel')
        integer(g['geometry']['doorIndex'], 1, 3, g['id']+'.doorIndex')
        if ref('assets', g['materials'], g['id'])['kind'] != 'materials':
            fail(g['id'], 'materials reference has wrong kind')
    for room in d['rooms']:
        record(room, 'id group bounds', room['id'])
        ref('groups', room['group'], room['id'])
        record(room['bounds'], 'min max', room['id']+'.bounds')
        for v in room['bounds'].values():
            vector(v, 3, -128, 127, room['id']+'.bounds')
        if any(a >= b for a, b in zip(room['bounds']['min'], room['bounds']['max'])):
            fail(room['id'], 'empty or reversed room bounds')
    for spawn in d['spawns']:
        record(spawn, 'id room position yawDegrees pitchDegrees', spawn['id'])
        room = ref('rooms', spawn['room'], spawn['id'])
        vector(spawn['position'], 3, -128, 127, spawn['id'])
        number(spawn['yawDegrees'], 0, 359+255/256, spawn['id'])
        number(spawn['pitchDegrees'], -90, 90, spawn['id'])
        if any(not a <= v <= b for a, v, b in zip(room['bounds']['min'], spawn['position'], room['bounds']['max'])):
            fail(spawn['id'], 'spawn outside its room')
    for g in d['groups']:
        spawn = ref('spawns', g['entry'], g['id'])
        if ref('rooms', spawn['room'], g['id'])['group'] != g['id']:
            fail(g['id'], 'entry belongs to another group')
    ref('spawns', d['start'], 'level.start')
    for o in d['objects']:
        common = 'id kind room position '
        kind = o.get('kind')
        fields = {'billboard': 'asset size animations interaction state',
                  'sliding-door': 'size state', 'mesh': 'asset yawDegrees scale visible level'}.get(kind)
        if fields is None:
            fail(o['id'], 'unknown object kind')
        record(o, common+fields, o['id'])
        room = ref('rooms', o['room'], o['id'])
        vector(o['position'], 3, -128, 127, o['id'])
        if any(not a <= v <= b for a, v, b in zip(room['bounds']['min'], o['position'], room['bounds']['max'])):
            fail(o['id'], 'object origin outside its room')
        if kind in ('billboard', 'mesh') and ref('assets', o['asset'], o['id'])['kind'] != kind:
            fail(o['id'], 'asset kind does not match object')
        if kind == 'billboard':
            record(o['state'], 'used', o['id']+'.state')
            flag(o['state']['used'], o['id'])
            record(o['interaction'], 'useRange collisionHalfSize', o['id']+'.interaction')
            config = gameplay_config(o)
            module('level_billboard', 'billboards/scene.py').validate(config, loaded[o['asset']]['data'])
        elif kind == 'sliding-door':
            vector(o['size'], 2, 1, 32, o['id'])
            record(o['state'], 'open', o['id']+'.state')
            flag(o['state']['open'], o['id'])
        else:
            number(o['yawDegrees'], 0, 359+255/256, o['id'])
            number(o['scale'], .5, 1, o['id'], step=1/64)
            integer(o['level'], 4, 28, o['id'])
            flag(o['visible'], o['id'])
    graph = {g['id']: set() for g in d['groups']}
    pairs = set()
    for c in d['connections']:
        kind = c.get('kind')
        record(c, 'id kind from to '+('door' if kind == 'doorway' else 'fromSpawn toSpawn'), c['id'])
        a = ref('rooms', c['from'], c['id']);b = ref('rooms', c['to'], c['id'])
        if a['id'] == b['id']:
            fail(c['id'], 'self connection')
        key = (kind, tuple(sorted([a['id'], b['id']])))
        if key in pairs:
            fail(c['id'], 'duplicate reciprocal connection')
        pairs.add(key)
        if kind == 'doorway':
            door = ref('objects', c['door'], c['id'])
            if a['group'] != b['group'] or door['kind'] != 'sliding-door' or door['room'] not in (a['id'], b['id']):
                fail(c['id'], 'doorway must bind its local sliding door')
        elif kind == 'group-transition':
            if a['group'] == b['group']:
                fail(c['id'], 'group transition must join different groups')
            for field, group in [('fromSpawn', a['group']), ('toSpawn', b['group'])]:
                sp = ref('spawns', c[field], c['id'])
                if tables['rooms'][sp['room']]['group'] != group:
                    fail(c['id'], 'return/arrival spawn belongs to the wrong group')
            graph[a['group']].add(b['group']);graph[b['group']].add(a['group'])
        else:
            fail(c['id'], 'unknown connection kind')
    reached = {d['groups'][0]['id']}
    while True:
        more = reached | {n for g in reached for n in graph[g]}
        if more == reached:
            break
        reached = more
    if len(reached) != len(graph):
        fail('connections', 'group graph is disconnected')
    for e in d['events']:
        record(e, 'id trigger actions', e['id'])
        record(e['trigger'], 'object signal', e['id']+'.trigger')
        owner = ref('objects', e['trigger']['object'], e['id'])
        if e['trigger']['signal'] != 'use' or owner['kind'] != 'billboard':
            fail(e['id'], 'use trigger requires an interactive billboard')
        items(e['actions'], 1, 8, e['id']+'.actions')
        for action in e['actions']:
            typ = action.get('type') if isinstance(action, dict) else None
            if typ == 'toggle':
                record(action, 'type object field', e['id'])
                if ref('objects', action['object'], e['id'])['kind'] != 'sliding-door' or action['field'] != 'open':
                    fail(e['id'], 'toggle currently addresses door.open')
                target = tables['objects'][action['object']]
            elif typ == 'animate-from':
                record(action, 'type object source field whenFalse whenTrue', e['id'])
                target = ref('objects', action['object'], e['id']);source = ref('objects', action['source'], e['id'])
                if target['kind'] != 'billboard' or source['kind'] != 'sliding-door' or action['field'] != 'open' or action['whenFalse'] != 'idle' or action['whenTrue'] != 'used':
                    fail(e['id'], 'invalid state-to-animation binding')
                if tables['rooms'][source['room']]['group'] != tables['rooms'][owner['room']]['group']:
                    fail(e['id'], 'event source must be in the active group')
            else:
                fail(e['id'], 'unknown action type')
            if tables['rooms'][target['room']]['group'] != tables['rooms'][owner['room']]['group']:
                fail(e['id'], 'events may only modify the active group')
    return d, tables, loaded, graph


def gameplay_config(o):
    return dict(schema=1, billboards=[dict(id='guardian', asset='guard-frames.json',
        position=o['position'], size=o['size'], animations=o['animations'])],
        entity=dict(billboard='guardian', enabled=True, useRange=o['interaction']['useRange'],
        collisionHalfSize=o['interaction']['collisionHalfSize'], demoUseKeys=[0, 6, 24, 30, 44]))


def compile_level(document, directory):
    d, t, loaded, graph = validate(document, directory)
    start_group = t['rooms'][t['spawns'][d['start']]['room']]['group']
    ordered = sorted(d['groups'], key=lambda g: g['id'] != start_group)
    ids = {name: {item['id']: i for i, item in enumerate(ordered if name == 'groups' else d[name])}
           for name in t}
    ir = dict(format='3Dvibe64.level-ir', schema=1, id=d['id'], axisConvention=d['axisConvention'],
              startSpawn=ids['spawns'][d['start']], ids=ids, source=d, assets={})
    for name, asset in loaded.items():
        ir['assets'][name] = dict(SHA256=asset['SHA256'], bytes=asset['path'].stat().st_size)
    ir['groups'] = [dict(id=g['id'], index=ids['groups'][g['id']],
        rooms=[ids['rooms'][r['id']] for r in d['rooms'] if r['group'] == g['id']],
        objects=[ids['objects'][o['id']] for o in d['objects'] if t['rooms'][o['room']]['group'] == g['id']],
        neighbors=sorted(ids['groups'][n] for n in graph[g['id']]), entrySpawn=ids['spawns'][g['entry']]) for g in ordered]
    ir['rooms'] = [dict(index=ids['rooms'][r['id']], group=ids['groups'][r['group']],
        boundsQ8={k: [round(v*256) for v in row] for k, row in r['bounds'].items()}) for r in d['rooms']]
    ir['objects'] = [dict(index=ids['objects'][o['id']], kind=o['kind'], room=ids['rooms'][o['room']],
        asset=ids['assets'][o['asset']] if 'asset' in o else None,
        positionQ8=[round(v*256) for v in o['position']]) for o in d['objects']]
    ir['spawns'] = [dict(index=ids['spawns'][s['id']], room=ids['rooms'][s['room']],
        positionQ8=[round(v*256) for v in s['position']], yawPhase=round(s['yawDegrees']*65536/360)&65535,
        pitchPhase=round(s['pitchDegrees']*65536/360)&65535) for s in d['spawns']]
    ir['connections'] = [dict(index=ids['connections'][c['id']], kind=c['kind'],
        fromRoom=ids['rooms'][c['from']], toRoom=ids['rooms'][c['to']],
        **({'door': ids['objects'][c['door']]} if c['kind'] == 'doorway' else
           {k: ids['spawns'][c[k]] for k in ('fromSpawn', 'toSpawn')})) for c in d['connections']]
    ir['events'] = [dict(index=ids['events'][e['id']], triggerObject=ids['objects'][e['trigger']['object']],
        signal=e['trigger']['signal'], actions=[{k: ids['objects'][v] if k in ('object', 'source') else v
                                               for k, v in a.items()} for a in e['actions']]) for e in d['events']]
    reasons = [f'{f}: module is qualified separately, not installed in WORLD-01' for f in d['features']]
    states = []
    pair_by_group = {}
    for g in ordered:
        name = g['id'];width = g['geometry']['halfWidth']
        rooms = sorted([r for r in d['rooms'] if r['group'] == name], key=lambda r: r['bounds']['min'][1])
        expected = [dict(min=[-width, -24, -10], max=[width, 8, 18]),
                    dict(min=[-width, 8, -10], max=[width, 24, 18])]
        if len(rooms) != 2 or [r['bounds'] for r in rooms] != expected:
            reasons.append(name+': WORLD-01 requires front/back rooms matching the divider template')
        objects = [o for o in d['objects'] if t['rooms'][o['room']]['group'] == name]
        guardians = [o for o in objects if o['kind'] == 'billboard']
        doors = [o for o in objects if o['kind'] == 'sliding-door']
        if len(objects) != 2 or len(guardians) != 1 or len(doors) != 1:
            reasons.append(name+': WORLD-01 requires one guardian and one door; additional objects need integration')
            continue
        guardian, door = guardians[0], doors[0]
        pair_by_group[name] = (guardian, door)
        reach = guardian['size'][0]/2+guardian['size'][1]/2*math.sin(math.radians(14))
        x, y, _ = guardian['position']
        if abs(x)+reach >= width or y-reach <= -24 or y+reach >= 8:
            reasons.append(name+': guardian camera-facing envelope must stay inside the front room for pitch14')
        if not rooms or guardian['room'] != rooms[0]['id'] or door['room'] != rooms[0]['id']:
            reasons.append(name+': guardian and door must be bound to the front room')
        if door['position'] != [0, 8, -10] or door['size'] != [10, 18]:
            reasons.append(name+': different door geometry needs integration')
        if guardian['state']['used'] != door['state']['open']:
            reasons.append(name+': initial guardian and door state must agree')
        spawn = t['spawns'][g['entry']]
        if spawn['position'] != [0, -20, 0] or spawn['yawDegrees'] != 0 or spawn['pitchDegrees'] != 0:
            reasons.append(name+': WORLD-01 enters at the qualified front spawn [0,-20,0],yaw/pitch0')
        if rooms and spawn['room'] != rooms[0]['id']:
            reasons.append(name+': entry must be in the front room')
        doorways = [c for c in d['connections'] if c['kind'] == 'doorway' and c['door'] == door['id']]
        if len(doorways) != 1 or {doorways[0]['from'], doorways[0]['to']} != {r['id'] for r in rooms}:
            reasons.append(name+': each group requires exactly its front/back doorway')
        events = [e for e in d['events'] if e['trigger']['object'] == guardian['id']]
        actions = [dict(type='toggle', object=door['id'], field='open'),
                   dict(type='animate-from', object=guardian['id'], source=door['id'], field='open', whenFalse='idle', whenTrue='used')]
        if len(events) != 1 or events[0]['actions'] != actions:
            reasons.append(name+': use event must toggle its door and synchronize its guardian animation')
        states.append(dict(group=name, bytes=17, guardian=guardian['id'], door=door['id'],
                           policy='freeze inactive group; restore native16byte slot plus visited flag'))
    if len(pair_by_group) == len(ordered):
        first = pair_by_group[ordered[0]['id']][0]
        first_config = gameplay_config(first)
        first_asset = loaded[first['asset']]['SHA256']
        for g in ordered:
            guardian, _ = pair_by_group[g['id']]
            if gameplay_config(guardian) != first_config or loaded[guardian['asset']]['SHA256'] != first_asset:
                reasons.append(g['id']+': guardian asset/configuration must be shared across groups in WORLD-01')
            if loaded[g['materials']]['SHA256'] != loaded[ordered[0]['materials']]['SHA256']:
                reasons.append(g['id']+': the resident material atlas must be shared')
    for c in d['connections']:
        if c['kind'] == 'group-transition':
            for field, endpoint in [('fromSpawn', 'from'), ('toSpawn', 'to')]:
                g = t['groups'][t['rooms'][c[endpoint]]['group']]
                if c[field] != g['entry']:
                    reasons.append(c['id']+': transition endpoints must use the group entry spawn')
    if d['start'] != t['groups'][start_group]['entry']:
        reasons.append('start: WORLD-01 starts at its group entry')
    if any(not 1 <= len(graph[g['id']]) <= 2 for g in ordered):
        reasons.append('WORLD-01 supports one or two neighbors per group')
    if d['target']['autoTransitions'] and len(ordered) != 2:
        reasons.append('the qualified automatic world tour requires two groups; use explicit N/P transitions for larger graphs')
    if not d['target']['autoTransitions'] and start_group in pair_by_group and pair_by_group[start_group][1]['state']['open']:
        reasons.append('the diagnostic single-group tour requires its initial door closed')
    if len(d['events']) != len(ordered):
        reasons.append('additional event handlers need an integrated dispatcher')
    ir['compatibility'] = dict(backend='WORLD-01', buildable=not reasons, reasons=reasons)
    ir['persistentState'] = states
    ir['nativeTranslation'] = None
    if not reasons:
        world = dict(schema=1, enabled=True, autoTransitions=d['target']['autoTransitions'], capacityBytes=1024,
            groups=[dict(id=g['id'], rooms=2, halfWidth=g['geometry']['halfWidth'], floorLevel=g['geometry']['floorLevel'],
                doorIndex=g['geometry']['doorIndex'], initialOpen=pair_by_group[g['id']][1]['state']['open'],
                neighbors=[x['id'] for x in ordered if x['id'] in graph[g['id']]]) for g in ordered])
        module('level_world', 'world/groups.py').validate(world)
        ir['nativeTranslation'] = dict(world=world, gameplay=gameplay_config(pair_by_group[ordered[0]['id']][0]),
            materials=loaded[ordered[0]['materials']]['data'], guardianAsset=pair_by_group[ordered[0]['id']][0]['asset'])
    return ir, loaded
