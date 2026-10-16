"""Compile common level data and verify the actual assembled memory budget.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
--validate-only writes nothing; --plan-only resolves data without a native build.
"""
import argparse
import hashlib
import importlib.util
import json
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


FORMAT = load_module('common_level', ROOT/'extensions/gameplay/level/format.py')
BUDGET = load_module('level_budget', ROOT/'extensions/gameplay/level/budget.py')


def read_level(path):
    return FORMAT.read_json(path)


def write(path, data):
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False)+'\n', encoding='utf-8', newline='\n')


def build(level, out=None, validate_only=False, plan_only=False):
    level = Path(level).resolve(strict=True)
    document = read_level(level)
    ir, assets = FORMAT.compile_level(document, level.parent)
    if validate_only:
        return dict(result='VALID', level=ir['id'], compatibility=ir['compatibility'],
                    groups=len(ir['groups']), rooms=len(document['rooms']), objects=len(document['objects']))
    if out is None:
        raise ValueError('--out is required unless --validate-only is selected')
    out = Path(out).resolve()
    if out.is_relative_to(ROOT) or out.exists() or out == level or level.is_relative_to(out):
        raise ValueError('Choose a new output directory outside the source tree and level inputs')
    if not plan_only and not ir['compatibility']['buildable']:
        raise ValueError('LEVEL_BACKEND_UNSUPPORTED:\n'+'\n'.join(ir['compatibility']['reasons']))
    out.mkdir(parents=True)
    data = out/'level';data.mkdir()
    write(data/'source-level.json', document)
    portable = json.loads(json.dumps(document))
    (data/'assets').mkdir()
    for asset in portable['assets']:
        name = asset['id']+'.json'
        shutil.copy2(assets[asset['id']]['path'], data/'assets'/name)
        asset['source'] = 'file:assets/'+name
    write(data/'level.json', portable)
    write(data/'level-ir.json', ir)
    if plan_only:
        result = dict(result='PLAN', level=ir['id'], compatibility=ir['compatibility'],
            nativeProgramBuilt=False, memoryStatus='not measured; assemble a supported level for an exact budget')
        write(out/'plan.json', result)
        return result
    translation = ir['nativeTranslation']
    for name, key in [('world-groups.json', 'world'), ('gameplay-scene.json', 'gameplay'), ('surfaces.json', 'materials')]:
        write(data/name, translation[key])
    shutil.copy2(assets[translation['guardianAsset']]['path'], data/'guard-frames.json')
    builder = load_module('gameplay_builder', ROOT/'work/build-gameplay.py')
    native = out/'native'
    built = builder.build('room-groups', native, surface_config=data/'surfaces.json',
                          gameplay_scene=data/'gameplay-scene.json', world_groups=data/'world-groups.json')
    budget = BUDGET.report(native, document['memory'])
    write(out/'memory-budget.json', budget)
    if not budget['policy']['passed']:
        result = dict(result='REJECTED_MEMORY', level=ir['id'], PRGSHA256=built['PRGSHA256'],
            errors=budget['policy']['errors'], nativeProgramBuiltForInspection=True,
            launchableDelivery=False)
        write(out/'build.json', result)
        raise ValueError('LEVEL_MEMORY_BUDGET: '+'; '.join(budget['policy']['errors'])+'; inspect '+str(out/'memory-budget.json'))
    (out/'launch-level.cmd').write_bytes(b'@echo off\r\ncall "%~dp0native\\launch-demo.cmd" %*\r\n')
    result = dict(result='PASS', engineVersion=(ROOT/'VERSION').read_text(encoding='utf-8').strip(),
        level=ir['id'], format='3Dvibe64.level/1', backend='WORLD-01',
        program='native/'+built['program'], PRGSHA256=built['PRGSHA256'],
        sourceLevelSHA256=hashlib.sha256(level.read_bytes()).hexdigest().upper(),
        groups=len(document['groups']), rooms=len(document['rooms']), objects=len(document['objects']),
        events=len(document['events']), residentGroups=1,
        memory=dict(freeBytes=budget['accounting']['freeBytes'],
                    largestFreeBlockBytes=budget['accounting']['largestFreeBlockBytes'],
                    largestAligned2FreeBlockBytes=budget['accounting']['largestAligned2FreeBlockBytes'],
                    marginBytes=document['memory']['reserveBytes'],
                    bytesBeyondReserve=budget['policy']['bytesBeyondReserve']),
        sourceRecordStorage='host only; existing native channels/slots; no duplicate C64 tables',
        proposedOverlayApplied=False)
    write(out/'build.json', result)
    return result


def main():
    from mode8.common import require_qualification_checks
    require_qualification_checks()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--level', required=True, type=Path)
    parser.add_argument('--out', type=Path)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--validate-only', action='store_true')
    mode.add_argument('--plan-only', action='store_true')
    args = parser.parse_args()
    try:
        result = build(args.level, args.out, args.validate_only, args.plan_only)
    except (ValueError, OSError) as error:
        parser.exit(2, str(error)+'\n')
    print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == '__main__':
    main()
