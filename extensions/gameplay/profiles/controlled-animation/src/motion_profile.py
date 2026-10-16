"""Bind Q8-02 to Q8-01; original shared-mesh program remains reproducible."""
import json
from pathlib import Path
import controlled_motion as motion
import shared_mesh_profile as meshes
ROOT=Path(__file__).resolve().parents[1]
CONFIG=None


def configure():
    global CONFIG
    CONFIG=motion.validate(json.loads((ROOT/'assets/motion.json').read_text(encoding='utf-8-sig')),meshes.CONFIG)
    (ROOT/'reports/motion.json').write_text(json.dumps(report(),indent=2)+'\n',encoding='utf-8')


def adapt(source,parts):return motion.adapt(source,parts,CONFIG)


def report():
    first,rows=motion.samples(CONFIG)
    result=dict(controlledMotion=dict(configuration=CONFIG,experimental=True,enabled=CONFIG['enabled'],
        nativeClips=len(CONFIG['clips']),sourceKeys=len(rows),keySourceBytes=21*len(rows)+2*len(first),
        ticksPerKey=64,tickSource='PAL simulation tick; independent of rendered views',
        position='signed Q8; per-tick rounded step and exact endpoint reload',scale='Q6 with Q14 interpolation accumulator',
        yaw='full16-bit phase; shortest keyframe arc; exact endpoint reload',
        commandABI='an_control: A0pause/1play/2stop/3seek/4speed/5loop/6step/7restart, X instance, Y argument; C success',
        cameraABI='cr_set_roll: A low,Y high full16-bit phase; C success. cr_resume resumes automatic bank',
        cameraMode=CONFIG['camera']['mode'],roll='inverse roll after inverse yaw/pitch in signed24 camera coordinates, before projection and clipping',
        keyboard='1..4 select; SPACE pause/play; R restart; T paused key step; F speed1/2/4; flight Q/E bank, HOME level, C automatic bank',
        scope='bounded Q8 shared solid instances; separate dungeon/flight profiles; no ordinary engine API change'))
    if CONFIG['enabled']:result['sharedMeshes']={**meshes.REPORT,'animation':'independent application-controlled Q8-02 clips; immutable shared geometry'}
    return result
