"""Bind explicit per-face rendering to the bounded one-room UI profile."""
import json
from pathlib import Path
import surfaces
ROOT = Path(__file__).resolve().parents[1]
TABLE = None


def configure(path):
    global TABLE
    scene = json.loads(path.read_text(encoding='utf-8-sig'))
    config = json.loads((ROOT/'assets/surfaces.json').read_text(encoding='utf-8-sig'))
    TABLE = surfaces.compile_surfaces(scene, config)
    if any(e['mode'] != 'texture' for e in TABLE[14:16]):
        raise ValueError('Faces14/15 are actor sort nodes, not renderable surfaces')
    (ROOT/'reports/surface-rendering.json').write_text(json.dumps(report(), indent=2)+'\n', encoding='utf-8')


def bake(source): return surfaces.bake(source, TABLE)
def hooks(source): return surfaces.hooks(source, TABLE)
def report():
    visible=TABLE[:14]+TABLE[16:]
    return dict(experimental=True, faces=TABLE, counts={m:sum(e['mode']==m for e in visible) for m in surfaces.MODES},
        actorSortNodesExcluded=[14,15], lighting='explicit static per-corner levels; no automatic light bake',
        shared='Q8 transform, near/screen clipping, coverage, palette policy and depth buckets',
        texture='exact perspective per pixel/all60 rows, LOD14..22',
        untextured='flat palette slot or Gouraud33-level ordered dither; no UV sampling',
        visibility='same bounded convex room/actor painter as comparison-ui')
