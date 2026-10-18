"""Exact assembled memory accounting and a separate, unapplied lifetime plan.
Required Notice: 3Dvibe64. PolyForm Noncommercial 1.0.0.
Free helper-pool bytes are not the same as a contiguous arena or all unused RAM.
"""
import hashlib
import json
import re
from pathlib import Path


def require(condition, message):
    if not condition:
        raise ValueError('MEMORY_CONTRACT: '+message)


def intervals(rows, where):
    result = []
    for row in rows:
        require(isinstance(row, (list, tuple)) and len(row) == 2 and all(type(x) is int for x in row), where+' invalid range')
        a, b = row
        require(0 <= a < b <= 65536, where+' range outside address space')
        result.append((a, b))
    result.sort()
    require(all(b <= c for (_, b), (c, _) in zip(result, result[1:])), where+' overlapping ranges')
    return result


def merge(rows):
    result = []
    for a, b in intervals(rows, 'merge'):
        if result and result[-1][1] == a:
            result[-1] = (result[-1][0], b)
        else:
            result.append((a, b))
    return result


def placement(metadata, symbols):
    windows = intervals(metadata['originalGaps'], 'legal windows')
    allocated = metadata['allocation']
    require(set(allocated) == set(metadata['blockSizes']), 'allocation/size names differ')
    intervals(list(allocated.values()), 'allocated blocks')
    free = intervals(metadata['remainingGaps'], 'remaining gaps')
    blocks = []
    for name, (a, b) in allocated.items():
        require(any(x <= a < b <= y for x, y in windows), name+' outside legal windows')
        begin = symbols['hp_block_'+name+'_begin'];end = symbols['hp_block_'+name+'_end']
        require(begin == a and a <= end <= b, name+' final labels exceed allocation')
        initial = metadata['blockSizes'][name]
        require(type(initial) is int and initial >= 0, name+' invalid sizing result')
        require(b-a == initial+(0 if name in ('data', 'tables') else 8), name+' growth reserve inconsistent')
        blocks.append(dict(name=name, start=a, end=b, allocatedBytes=b-a,
                           finalPayloadBytes=end-a, remainingGrowthGuardBytes=b-end))
    for a, b in free:
        require(any(x <= a < b <= y for x, y in windows), 'free gap outside legal windows')
    # Exact partition detects holes, double counting, collisions and forged totals.
    require(merge(list(allocated.values())+list(free)) == merge(windows), 'allocated/free ranges do not exactly partition legal windows')
    total = sum(b-a for a, b in windows)
    remaining = sum(b-a for a, b in free)
    largest = max((b-a for a, b in free), default=0)
    aligned = max((b-((a+1)&~1) for a, b in free), default=0)
    return dict(legalWindowBytes=total, allocatedBytes=total-remaining,
        finalPayloadBytes=sum(b['finalPayloadBytes'] for b in blocks),
        growthGuardBytes=sum(b['remainingGrowthGuardBytes'] for b in blocks),
        freeBytes=remaining, largestFreeBlockBytes=largest, largestAligned2FreeBlockBytes=aligned,
        fragmentedFreeBytes=remaining-largest,
        windows=windows, freeRanges=free, blocks=blocks,
        outsideHelperPoolBytes=65536-total,
        outsideHelperPoolMeaning='fixed engine, display, runtime buffers, vectors, hardware or reserved ranges; not extra allocatable memory')


def check_policy(account, policy):
    errors = []
    for field in ('reserveBytes', 'minimumContiguousBytes'):
        require(type(policy.get(field)) is int and 0 <= policy[field] <= 65535, 'invalid memory policy')
    if account['freeBytes'] < policy['reserveBytes']:
        errors.append(f"free {account['freeBytes']} < reserved margin {policy['reserveBytes']}")
    if account['largestAligned2FreeBlockBytes'] < policy['minimumContiguousBytes']:
        errors.append(f"largest aligned block {account['largestAligned2FreeBlockBytes']} < requested contiguous {policy['minimumContiguousBytes']}")
    return dict(passed=not errors, errors=errors, reserveBytes=policy['reserveBytes'],
        minimumContiguousBytes=policy['minimumContiguousBytes'],
        bytesBeyondReserve=account['freeBytes']-policy['reserveBytes'],
        alignmentBytes=2, note='The margin is a build acceptance threshold; no runtime memory is allocated by this host check.')


def startup_plan(account, assembly):
    ui = [b for b in account['blocks'] if b['name'].startswith('ui_')]
    candidate = sum(b['allocatedBytes'] for b in ui)
    hypothetical = merge(account['freeRanges']+[(b['start'], b['end']) for b in ui])
    calls = len(re.findall(r'(?m)^\s*jsr game_ui_init\s*$', assembly))
    assignments = []
    planned_free = list(hypothetical)
    for name, size in [('post-boot-resident-extensions', 2048), ('additional-entity-event-state', 512)]:
        options = [(b-((a+1)&~1), a, b) for a, b in planned_free if b-((a+1)&~1) >= size]
        if not options:
            assignments = []
            break
        _, a, b = max(options)
        start = (a+1)&~1
        planned_free.remove((a, b))
        if a < start:
            planned_free.append((a, start))
        if start+size < b:
            planned_free.append((start+size, b))
        assignments.append(dict(name=name, start=start, end=start+size, bytes=size))
    targets = dict(status='proposed-only' if assignments else 'insufficient-hypothetical-capacity',
        assignments=assignments, safetyMarginBytes=512,
        unassignedBeyondSafetyBytes=sum(b-a for a, b in planned_free)-512 if assignments else None,
        moduleFit='not established; new loader/dispatcher and selected modules must be assembled and measured',
        lifetime='extensions are loaded once after UI initialization and remain resident through play/load; no per-group code eviction',
        loadFailure='validate boot extension before first use; do not resume gameplay on a partial boot load',
        transferLimit='WG01 geometry files retain1024byte staging; a2048byte boot extension needs its own bounded validated boot-load protocol')
    return dict(status='proposed-not-applied', availableNowBytes=account['freeBytes'],
        candidate='startup UI decoder, compressed stream, page directory and dictionary',
        candidateAllocatedBytes=candidate,
        candidatePayloadBytes=sum(b['finalPayloadBytes'] for b in ui),
        candidateGrowthGuardBytes=sum(b['remainingGrowthGuardBytes'] for b in ui),
        candidateBlocks=[dict(name=b['name'], start=b['start'], end=b['end']) for b in ui],
        directInitCallsObserved=calls,
        hypotheticalFreeBytes=account['freeBytes']+candidate,
        hypotheticalLargestFreeBlockBytes=max((b-a for a, b in hypothetical), default=0),
        hypotheticalLargestAligned2FreeBlockBytes=max((b-((a+1)&~1) for a, b in hypothetical), default=0),
        hypotheticalRanges=hypothetical,
        allocationTargets=targets,
        conditions=['After UI decode, prove every candidate block unreachable from play/load/interrupt paths.',
                    'Add a phase-aware allocator/emitter and a validated fixed-address boot extension loader before reusing any byte.',
                    'Keep displayed bitmaps/screens, renderer buffers, group staging and IRQ backup live.',
                    'Reassemble and qualify integrated modules; isolated profile byte costs are not additive proofs.',
                    'Measure native FPS and check UI/state/interrupts on the resulting actual PRG.'],
        phases=[dict(phase='boot', live='UI compressed inputs/decoder and display initialization'),
                dict(phase='play', live='display, renderer, active group data, per-group state, resident controller; candidates still physically occupied today'),
                dict(phase='load', live='previous complete front view, old active group, staging, state slots, KERNAL ZP/vector backup, loader and IRQ')],
        exclusions='No bytes reclaimed in this checkpoint; this hypothetical total does not pass the current build policy.')


def report(build_directory, policy):
    build_directory = Path(build_directory).resolve()
    read = lambda p: json.loads(p.read_text(encoding='utf-8-sig'))
    outer = read(build_directory/'build.json')
    require(outer['profile'] == 'room-groups', 'this budget adapter requires WORLD-01')
    program = build_directory/outer['program']
    require(program.resolve().is_relative_to(build_directory), 'program path outside build')
    digest = hashlib.sha256(program.read_bytes()).hexdigest().upper()
    require(digest == outer['PRGSHA256'], 'program hash mismatch')
    project = build_directory/'project'
    directory = project/'room/build/room-groups'
    metadata = read(directory/'build.json')
    symbol_path = directory/'3Dvibe64.labels'
    symbols = {m[2]: int(m[1], 16) for m in re.finditer(r'^al ([0-9a-fA-F]+) \.(\S+)$', symbol_path.read_text(encoding='utf-8'), re.M)}
    account = placement(metadata, symbols)
    groups = read(project/'reports/world-groups.json')
    count = len(groups['groups'])
    stage = symbols['wg_arena_end']-symbols['wg_arena']
    require(stage == 1024 and stage == policy['stagingBytes'], 'staging size mismatch')
    require(symbols['wg_visited']+count <= symbols['wg_saved'], 'persistent fields overlap')
    manager = metadata['allocation']['world_manager']
    require(manager[0] <= symbols['wg_visited'] and symbols['wg_saved']+count*16 <= manager[1], 'persistent slots outside manager')
    require(symbols['hp_block_world_io_end'] <= 0xd000, 'KERNAL-visible I/O above legal memory')
    for label in ('tr_irq_exit', 'demo_count_refresh', 'demo_refreshes', 'sim_vblank_count', 'fps_vblank_count', 'fps_second_flag'):
        require(symbols[label] < 0xd000, label+' inaccessible with KERNAL mapped')
    require(symbols['RUNTIME_BUFFER_END']+32 <= min(a for a, b in metadata['originalGaps'] if a >= symbols['RUNTIME_BUFFER_END']), 'runtime/helper separation missing')
    active_channels = []
    for name, values in groups['groups'][0]['channels'].items():
        active_channels.append(dict(name=name, start=symbols[name], end=symbols[name]+len(values), bytes=len(values)))
    intervals([(c['start'], c['end']) for c in active_channels], 'active geometry/material channels')
    require(sum(c['bytes'] for c in active_channels) == 748, 'group channel layout changed')
    file_data = []
    for g in groups['groups']:
        path = project/'media'/g['filename']
        require(path.resolve().is_relative_to(project/'media'), 'media path outside group directory')
        data = path.read_bytes();require(len(data) == g['bytes'] <= stage, 'group file exceeds staging')
        file_data.append(dict(group=g['id'], file=g['filename'], bytes=len(data),
                              SHA256=hashlib.sha256(data).hexdigest().upper()))
    overlays = startup_plan(account, (directory/'3Dvibe64.asm').read_text(encoding='utf-8'))
    accepted = check_policy(account, policy)
    return dict(schema=1, result='PASS' if accepted['passed'] else 'REJECTED_POLICY', PRGSHA256=digest,
        evidence=dict(buildMetadataSHA256=hashlib.sha256((directory/'build.json').read_bytes()).hexdigest().upper(),
                      labelsSHA256=hashlib.sha256(symbol_path.read_bytes()).hexdigest().upper()),
        accounting=account, policy=accepted,
        resident=dict(groups=1, stagingBytes=stage, stateBytes=17*count,
            stateSlots=dict(visited=symbols['wg_visited'], saved=symbols['wg_saved'], slotBytes=16),
            activeChannelsBytes=748, activeChannels=active_channels,
            decodedBillboardBytes=metadata['blockSizes']['bb_pixels'],
            billboardFramesBytes=symbols['bb_frames_end']-symbols['bb_frames'],
            runtimeBuffer=dict(start=symbols['RUNTIME_BUFFER_BASE'], end=symbols['RUNTIME_BUFFER_END']),
            doubleCountingRule='Resident subranges already belong to allocated blocks or fixed ranges; do not add them to allocatedBytes.'),
        external=dict(files=file_data, totalStorageBytes=sum(f['bytes'] for f in file_data),
            peakStagedFileBytes=max(f['bytes'] for f in file_data),
            note='Only one file is staged at once; total disk bytes are not simultaneous RAM.'),
        proposedIntegration=overlays,
        method='Exact final assembled labels plus allocator partition; no pixel/FPS estimate and no sum of independent demo budgets.')
