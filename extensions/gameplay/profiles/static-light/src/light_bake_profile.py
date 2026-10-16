"""Bind host-only static illumination to the existing Gouraud receiver tables."""
import json
from pathlib import Path
import light_baker
import material_profile
import door_profile
ROOT=Path(__file__).resolve().parents[1]
REPORT=None


def configure(path):
    global REPORT
    scene=json.loads(path.read_text(encoding='utf-8-sig'))
    config=json.loads((ROOT/'assets/light-bake.json').read_text(encoding='utf-8-sig'))
    forbidden={14,15}|set(range(door_profile.LEAF_FIRST,door_profile.GEOMETRY['faces']))
    table,payload,REPORT=light_baker.compile_bake(scene,config,material_profile.TABLE,forbidden)
    assert light_baker.decode(payload)==REPORT['records']
    material_profile.TABLE=table
    (ROOT/'reports/static-light.bin').write_bytes(payload)
    (ROOT/'reports/static-light.json').write_text(json.dumps(REPORT,indent=2)+'\n',encoding='utf-8')
    (ROOT/'reports/static-light-surfaces.json').write_text(json.dumps(table,indent=2)+'\n',encoding='utf-8')
    (ROOT/'reports/surface-rendering.json').write_text(json.dumps(report()['surfaceRendering'],indent=2)+'\n',encoding='utf-8')


def report():
    surfaces=material_profile.report()
    enabled=REPORT['configuration']['enabled']
    surfaces['lighting']='host-baked static vertex light on selected Gouraud receivers; textured/flat surfaces retain their existing treatment' if enabled else surfaces['lighting']
    return dict(staticLightBake=REPORT,surfaceRendering=surfaces,
        lighting=surfaces['lighting'])
