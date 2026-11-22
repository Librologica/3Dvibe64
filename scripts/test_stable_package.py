"""Stable source distribution and inherited VICE qualification contract."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load(name):
    return json.loads((ROOT / name).read_text('utf-8-sig'))


def main():
    version = (ROOT / 'VERSION').read_text().strip()
    release = load('RELEASE.json')
    package = load('PACKAGE-MANIFEST.json')
    qualification = load(release['qualification'])
    assert version == release['version'] == qualification['version'] == package['package']['version']
    assert release['classification'] == 'stable' and release['qualifiedAsStable']
    assert release['plannedTag'] == 'v' + version and release['sourceOnly']
    assert not release['demosIncluded'] and not release['benchmarksIncluded']
    assert not package['package']['prerelease'] and not package['package']['precompiledPrograms']
    assert package['stablePromotion']['status'] == 'complete'
    assert not qualification['runtimeChangedDuringPromotion'] and qualification['newNativeTimingRuns'] == 0
    assert qualification['measurementsReusedByExactIdentity']
    for name, digest in qualification['runtimeSourceSHA256'].items():
        assert hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == digest, name
    identity = {r['caseId']: r for r in qualification['coldBuildIdentities']}
    assert len(identity) == 20 and all(r['allNumericLabelsIdentical'] for r in identity.values())
    rows = qualification['nativeFPS']
    assert len(rows) == 44 and len({(r['caseId'], r['multiplier']) for r in rows}) == 44
    historical = [r for r in rows if r['scope'] == 'historical']
    assert len(historical) == 36 and {r['primaryMode'] for r in historical} == set(range(1, 9))
    assert {r['multiplier'] for r in historical} == {1, 20, 64}
    for row in rows:
        assert row['emulatedSeconds'] >= 20 and row['PRGSHA256'] == identity[row['caseId']]['PRGSHA256']
        assert row['averageFPS'] > 0 and row['completeViews'] > 0
        assert row['worstIntervalMs'] >= row['p95IntervalMs'] > 0
    index = qualification['generalIndex']
    assert index['anchor'] == '1.15.0=100' and index['new'] == index['base'] and index['deltaPercent'] == 0
    assert index['status'] == 'inherited reconstructed estimate'
    assert package['distanceFade']['default'] == 'off' and package['distanceFade']['modes'] == list(range(1, 9))
    assert package['mode7LOD']['default'] == 'off' and package['mode7LOD']['fadeWidthWU'] == 16
    forbidden = {'.prg','.d64','.d71','.d81','.tap','.t64','.sid','.wav','.zip','.vsf','.pyc'}
    assert all(p.suffix.lower() not in forbidden for p in ROOT.rglob('*') if p.is_file())
    assert not any((ROOT / name).exists() for name in ('demos','examples','validation','benchmarks','artifacts','media'))
    print('STABLE PACKAGE PASS; 20 exact program identities, 44 inherited native measurements')


if __name__ == '__main__':
    main()
