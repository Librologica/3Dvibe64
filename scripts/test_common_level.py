"""Common level graph, lowering, portable assets and exact memory contracts."""
import copy
import importlib.util
import json
import tempfile
from pathlib import Path
from gameplay_test_inputs import FIXTURES

ROOT = Path(__file__).resolve().parents[1]


def load(name, relative):
    spec = importlib.util.spec_from_file_location(name, ROOT/relative)
    module = importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    return module


def main():
    f = load('level_format_test', 'extensions/gameplay/level/format.py')
    b = load('level_budget_test', 'extensions/gameplay/level/budget.py')
    entry = load('level_entry_test', 'work/build-level.py')
    path = FIXTURES/'examples/levels/integrated-foundation.json'
    d = f.read_json(path);original = copy.deepcopy(d)
    schema = f.read_json(ROOT/'extensions/gameplay/level/level.schema.json')
    assert set(schema['properties']) == set(schema['required']) == set(d)
    assert schema['additionalProperties'] is False
    def schema_refs(value):
        if isinstance(value, dict):
            if '$ref' in value:
                assert value['$ref'].startswith('#/$defs/') and value['$ref'][8:] in schema['$defs']
            for item in value.values():schema_refs(item)
        elif isinstance(value, list):
            for item in value:schema_refs(item)
    schema_refs(schema)
    ir, assets = f.compile_level(d, path.parent)
    assert d == original and ir['compatibility']['buildable']
    assert ir['nativeTranslation']['world'] == f.read_json(FIXTURES/'extensions/gameplay/profiles/room-groups/assets/world-groups.json')
    assert ir['nativeTranslation']['gameplay'] == f.read_json(FIXTURES/'extensions/gameplay/profiles/door-entity/assets/gameplay-scene.json')
    assert len(ir['groups']) == 2 and len(ir['rooms']) == 4 and len(ir['objects']) == 4 and len(ir['events']) == 2
    assert ir['objects'][0]['positionQ8'] == [1792, 0, -640]
    assert ir['groups'][1]['neighbors'] == [0] and ir['persistentState'][1]['bytes'] == 17
    # Referenced IDs, not object/room/asset presentation order, define bindings.
    for key in ('assets', 'rooms', 'objects', 'connections', 'events', 'spawns'):
        changed = copy.deepcopy(d);changed[key].reverse()
        assert f.compile_level(changed, path.parent)[0]['nativeTranslation'] == ir['nativeTranslation'], key
    changed = copy.deepcopy(d);changed['groups'].reverse()
    assert f.compile_level(changed, path.parent)[0]['nativeTranslation'] == ir['nativeTranslation']
    changed['start'] = 'crypt-entry'
    assert f.compile_level(changed, path.parent)[0]['nativeTranslation']['world']['groups'][0]['id'] == 'crypt'
    changed = copy.deepcopy(d);changed['target']['autoTransitions'] = False
    assert not f.compile_level(changed, path.parent)[0]['nativeTranslation']['world']['autoTransitions']
    for count in range(2,9):
        expanded=eight_style_level(d,count)
        compiled=f.compile_level(expanded,path.parent)[0]
        assert compiled['compatibility']['buildable'] and len(compiled['groups'])==count
        assert len(compiled['persistentState'])*17==17*count
    unsupported = []
    for feature in f.FEATURES:
        changed = copy.deepcopy(d);changed['features'] = [feature];unsupported.append(changed)
    changed = copy.deepcopy(d);extra = copy.deepcopy(changed['objects'][0]);extra['id'] = 'second-guardian';changed['objects'].append(extra);unsupported.append(changed)
    changed = copy.deepcopy(d);changed['assets'].append(dict(id='crystal-art', kind='mesh', source='file:assets/test-mesh.json'))
    changed['objects'].append(dict(id='crystal-object', kind='mesh', room='hall-front', position=[-8, -8, -5], asset='crystal-art', yawDegrees=0, scale=1, visible=True, level=20));unsupported.append(changed)
    changed = copy.deepcopy(d);changed['spawns'][0]['position'] = [1, -20, 0];unsupported.append(changed)
    changed = copy.deepcopy(d);changed['objects'][1]['size'] = [8, 18];unsupported.append(changed)
    changed = copy.deepcopy(d);changed['objects'][2]['interaction']['useRange'] = 17;unsupported.append(changed)
    changed = copy.deepcopy(d);changed['objects'][0]['position'][0]=19;changed['objects'][2]['position'][0]=19;unsupported.append(changed)
    changed = copy.deepcopy(d);changed['objects'][0]['state']['used'] = True;unsupported.append(changed)
    changed = copy.deepcopy(d);changed['events'][0]['actions'].reverse();unsupported.append(changed)
    for changed in unsupported:
        result = f.compile_level(changed, path.parent)[0]
        assert not result['compatibility']['buildable'] and result['compatibility']['reasons'] and result['nativeTranslation'] is None
    bad = []
    def reject(fn):
        changed = copy.deepcopy(d);fn(changed);bad.append(changed)
    for key, value in [('schema', True), ('schema', 2), ('format', 'unknown'), ('id', '../bad'), ('axisConvention', 'y-up'), ('extra', 0), ('start', 'missing')]:
        reject(lambda x, k=key, v=value: x.update({k:v}))
    for key, value in [('multiplier', True), ('multiplier', 32), ('quality', 'fast'), ('textureLOD', [True, 22]), ('textureLOD', [14, 23]), ('music', True), ('autoTransitions', 0)]:
        reject(lambda x, k=key, v=value: x['target'].update({k:v}))
    for key, value in [('reserveBytes', True), ('reserveBytes', -1), ('minimumContiguousBytes', 65536), ('stagingBytes', 2048)]:
        reject(lambda x, k=key, v=value: x['memory'].update({k:v}))
    for features in (['unknown'], ['shared-meshes']*2, 'shared-meshes', [1]):
        reject(lambda x, v=features: x.update(features=v))
    reject(lambda x:x['rooms'][0].update(id=x['assets'][0]['id']))
    reject(lambda x:x['assets'][0].update(source='https://example.invalid/asset.json'))
    reject(lambda x:x['assets'][0].update(source='file:../escape.json'))
    reject(lambda x:x['assets'][0].update(source='file:C:/outside.json'))
    reject(lambda x:x['assets'][0].update(source='file:sub\\asset.json'))
    reject(lambda x:x['assets'][0].update(source='builtin:missing'))
    reject(lambda x:x['assets'][0].update(kind='materials'))
    reject(lambda x:x['assets'][0].update(kind='unknown'))
    for key, value in [('halfWidth', True), ('halfWidth', 17), ('halfWidth', 20.5), ('floorLevel', 33), ('floorLevel', False), ('doorIndex', 0), ('template', 'arbitrary')]:
        reject(lambda x,k=key,v=value:x['groups'][0]['geometry'].update({k:v}))
    reject(lambda x:x['groups'][0].update(materials='guardian-art'))
    reject(lambda x:x['groups'][0].update(entry='crypt-entry'))
    reject(lambda x:x['rooms'][0].update(group='missing'))
    reject(lambda x:x['rooms'][0]['bounds'].update(min=[24,-24,-10]))
    reject(lambda x:x['rooms'][0]['bounds'].update(min=[float('nan'),-24,-10]))
    reject(lambda x:x['spawns'][0].update(position=[50,-20,0]))
    reject(lambda x:x['spawns'][0].update(position=[0,-20+1/512,0]))
    reject(lambda x:x['spawns'][0].update(room='missing'))
    reject(lambda x:x['objects'][0].update(asset='room-materials'))
    reject(lambda x:x['objects'][0].update(kind='unknown'))
    reject(lambda x:x['objects'][0].update(room='missing'))
    reject(lambda x:x['objects'][0].update(position=[float('inf'),0,0]))
    reject(lambda x:x['objects'][0]['state'].update(used=1))
    reject(lambda x:x['objects'][0]['animations']['idle'].update(frames=[6]))
    reject(lambda x:x['objects'][0]['interaction'].update(useRange=True))
    reject(lambda x:x['connections'][0].update(to='hall-front'))
    reject(lambda x:x['connections'][0].update(door='hall-guardian'))
    reject(lambda x:x['connections'][0].update(to='crypt-front'))
    reject(lambda x:x['connections'][2].update(toSpawn='hall-entry'))
    reject(lambda x:x['connections'][2].update(kind='teleport'))
    reject(lambda x:x.update(connections=x['connections'][:2]))
    reject(lambda x:x['events'][0]['trigger'].update(object='hall-door'))
    reject(lambda x:x['events'][0]['trigger'].update(signal='enter'))
    reject(lambda x:x['events'][0]['actions'][0].update(object='crypt-door'))
    reject(lambda x:x['events'][0]['actions'][0].update(field='unknown'))
    reject(lambda x:x['events'][0]['actions'][1].update(source='hall-guardian'))
    reject(lambda x:x['events'][0]['actions'][1].update(whenTrue='missing'))
    reject(lambda x:x['events'][0].update(actions=[]))
    for changed in bad:
        try:f.compile_level(changed, path.parent)
        except ValueError:pass
        else:raise AssertionError('Invalid common level accepted')
    with tempfile.TemporaryDirectory() as temp:
        temp = Path(temp)
        for name, text in [('duplicate.json','{"schema":1,"schema":2}'),('nan.json','{"x":NaN}')]:
            p=temp/name;p.write_text(text,encoding='utf-8')
            try:entry.read_level(p)
            except ValueError:pass
            else:raise AssertionError('Ambiguous/non-finite JSON accepted')
        # The planning artifact carries asset bytes and is relocatable.
        result = entry.build(path, temp/'plan', plan_only=True)
        assert result['result'] == 'PLAN' and not result['nativeProgramBuilt']
        portable = temp/'plan/level/level.json'
        assert f.compile_level(f.read_json(portable),portable.parent)[0]['nativeTranslation'] == ir['nativeTranslation']
        changed = copy.deepcopy(unsupported[0]);p=temp/'unsupported.json';p.write_text(json.dumps(changed),encoding='utf-8')
        try:entry.build(p,temp/'must-not-exist')
        except ValueError:pass
        else:raise AssertionError('Unsupported level reached native builder')
        assert not (temp/'must-not-exist').exists()
        for out in (ROOT/'must-not-exist-level', temp):
            try:entry.build(path,out,plan_only=True)
            except ValueError:pass
            else:raise AssertionError('Unsafe output directory accepted')
    meta=dict(originalGaps=[[100,200],[300,400]],allocation=dict(code=[100,128],data=[300,310]),
              blockSizes=dict(code=20,data=10),remainingGaps=[[128,200],[310,400]])
    symbols=dict(hp_block_code_begin=100,hp_block_code_end=123,hp_block_data_begin=300,hp_block_data_end=310)
    account=b.placement(meta,symbols)
    assert (account['freeBytes'],account['largestFreeBlockBytes'],account['fragmentedFreeBytes']) == (162,90,72)
    assert account['finalPayloadBytes']==33 and account['growthGuardBytes']==5 and account['allocatedBytes']==38
    assert b.check_policy(account,dict(reserveBytes=162,minimumContiguousBytes=90))['passed']
    assert not b.check_policy(account,dict(reserveBytes=163,minimumContiguousBytes=90))['passed']
    assert not b.check_policy(account,dict(reserveBytes=160,minimumContiguousBytes=100))['passed']
    odd = b.placement(dict(originalGaps=[[101,200]],allocation={},blockSizes={},remainingGaps=[[101,200]]),{})
    assert odd['largestFreeBlockBytes']==99 and odd['largestAligned2FreeBlockBytes']==98
    assert not b.check_policy(odd,dict(reserveBytes=0,minimumContiguousBytes=99))['passed']
    bad_maps=[]
    def bad_map(fn):
        m=copy.deepcopy(meta);s=copy.deepcopy(symbols);fn(m,s);bad_maps.append((m,s))
    bad_map(lambda m,s:m.update(remainingGaps=[[129,200],[310,400]]))
    bad_map(lambda m,s:m.update(remainingGaps=[[127,200],[310,400]]))
    bad_map(lambda m,s:m['allocation'].update(data=[110,120]))
    bad_map(lambda m,s:m['allocation'].update(code=[200,228]))
    bad_map(lambda m,s:m['blockSizes'].update(code=21))
    bad_map(lambda m,s:s.update(hp_block_code_end=129))
    bad_map(lambda m,s:m.update(originalGaps=[[100,200],[150,400]]))
    bad_map(lambda m,s:m.update(remainingGaps=[[True,200],[310,400]]))
    for m,s in bad_maps:
        try:b.placement(m,s)
        except ValueError:pass
        else:raise AssertionError('Invalid allocator evidence accepted')
    candidate=copy.deepcopy(account);candidate['blocks'][0]['name']='ui_code'
    plan=b.startup_plan(candidate,' jsr game_ui_init\n')
    assert plan['status']=='proposed-not-applied' and plan['candidateAllocatedBytes']==28
    assert plan['availableNowBytes']==162 and plan['hypotheticalFreeBytes']==190
    assert not b.check_policy(account,dict(reserveBytes=170,minimumContiguousBytes=0))['passed']
    print(f'COMMON LEVEL PASS;{len(bad)} invalid graphs/configurations and{len(bad_maps)} invalid memory maps refused;{len(unsupported)} unsupported plans stay explicit; portable assets, ID lowering, exact partitions and fragmentation checked')


def eight_style_level(base,count=8):
    """Authored version of the already qualified WORLD-01 eight-group fixture."""
    d=copy.deepcopy(base);d['id']='memory-limit-eight';d['target']['autoTransitions']=False
    first={name:[x for x in d[name] if (x.get('id','').startswith('hall'))] for name in ('groups','rooms','objects','connections','spawns','events')}
    first['connections']=[x for x in first['connections'] if x['kind']=='doorway']
    for name in first:d[name]=[]
    def rename(value,prefix):
        if isinstance(value,dict):return {k:rename(v,prefix) for k,v in value.items()}
        if isinstance(value,list):return [rename(v,prefix) for v in value]
        if isinstance(value,str) and value.startswith('hall'):return prefix+value[4:]
        return value
    for i in range(count):
        prefix=f'group{i}'
        for name,rows in first.items():d[name].extend(rename(rows,prefix))
        width=18+i%7;d['groups'][-1]['geometry'].update(halfWidth=width,floorLevel=i*4,doorIndex=1+i%3)
        for r in d['rooms'][-2:]:r['bounds']['min'][0]=-width;r['bounds']['max'][0]=width
        d['objects'][-2]['state']['used']=bool(i%2);d['objects'][-1]['state']['open']=bool(i%2)
        if i:
            d['connections'].append(dict(id=f'edge{i-1}-{i}',kind='group-transition',**{'from':f'group{i-1}-back','to':prefix+'-front','fromSpawn':f'group{i-1}-entry','toSpawn':prefix+'-entry'}))
    d['start']='group0-entry'
    return d


if __name__ == '__main__':
    main()
