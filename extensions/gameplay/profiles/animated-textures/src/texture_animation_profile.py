"""Opt-in resident texture animation bound to the dev5 precise room."""
import json
from pathlib import Path
import texture_animation as animation
import material_profile
ROOT=Path(__file__).resolve().parents[1]
CONFIG=None
ASSET=None


def configure(path):
    global CONFIG,ASSET
    scene=json.loads(path.read_text(encoding='utf-8-sig'))
    CONFIG,ASSET=animation.load(ROOT/'assets/texture-animation.json',scene,material_profile.TABLE)
    CONFIG['_textureIndex']=[t['id'] for t in scene['textures']].index(CONFIG['sourceTexture'])
    (ROOT/'reports/texture-animation.json').write_text(json.dumps(report(),indent=2)+'\n',encoding='utf-8')


def adapt(source,parts):return animation.adapt(source,parts,CONFIG,ASSET,len(material_profile.TABLE))


def report():
    cfg={k:v for k,v in CONFIG.items() if not k.startswith('_')}
    return dict(textureAnimation=dict(experimental=True,configuration=cfg,groups=len(CONFIG['materials']),
        sourceFrameCount=len(ASSET['frames']),extraTexelBytes=(len(ASSET['frames'])-1)*256 if CONFIG['materials'] else 0,
        pageAlignmentReservation=255 if len(ASSET['frames'])>1 and CONFIG['materials'] else 0,
        source='resident pages selected by address; source pixels never copied per tick/frame',
        UV='signed integer texel steps; exact perspective quotient then translation modulo16',
        clock='PAL simulation ticks, independent of draw calls; current state stable during each complete view',
        LOD='unchanged14..22; identical pigment histograms preserve modal/accent fallback',
        limits='up to two material groups, one shared16x16 atlas of1..4 frames; existing bounded scene/palette contract'))
