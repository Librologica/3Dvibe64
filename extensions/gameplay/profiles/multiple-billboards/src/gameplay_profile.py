"""Bind the experimental scene/entity API to the qualified comparison room."""
import json
from pathlib import Path
import billboard_room as bb
import billboard_scene as scene
import billboard_multiple as multiple
import entity_runtime
ROOT=Path(__file__).resolve().parents[1]
CONFIG=None
ASSET=None


def configure(path):
    global CONFIG,ASSET
    CONFIG,ASSET=multiple.load(ROOT/'assets/gameplay-scene.json')
    def artwork():
        (ROOT/'assets/billboard-frames.json').write_text(json.dumps(ASSET,indent=2)+'\n',encoding='utf-8')
        return ASSET['frames']
    bb.artwork=artwork
    (ROOT/'reports/gameplay-scene.json').write_text(json.dumps(report(),indent=2)+'\n',encoding='utf-8')


def adapt(source,parts):
    parts['billboard']=scene.bind(parts['billboard'],CONFIG)
    parts['billboard_animation']=scene.animation(CONFIG)
    parts['entity_runtime']=entity_runtime.kernel(CONFIG)
    source=source.replace('qc_demo_tick:\n','qc_demo_tick:\n lda en_manual\n beq +\n rts\n+\n',1)
    old='advance_sim_tick:\n jsr wr_tick\n jsr bb_tick\n jsr qc_demo_tick\n'
    if source.count(old)!=1:raise ValueError('Simulation tick ABI changed')
    source=source.replace(old,'advance_sim_tick:\n jsr wr_tick\n jsr qc_demo_tick\n jsr en_tick\n jsr bb_tick\n')
    return source,parts


def report():
    return dict(configuration=CONFIG,sourceSize=[16,32],singleBillboard=False,
        controls='WASD enters front-facing manual visit; R restarts automatic cycle; SPACE uses guardian within XY range',
        entity='persistent binary state, edge-triggered use, accepted/rejected event, optional XY box collision',
        playerRadiusWU=.5,manualStepWU=.25,manualRoomBoundsWU=[-23,23],
        automatedUse='attempt once on entering configured orbit keys; no synthetic keyboard input',
        limits='one/two billboards sharing source and palette; bounded divider; pitch within14degrees; view-aligned plane below4WU rejected; second billboard has no entity collider')


def billboard_metadata():
    b=CONFIG['billboards'][0]
    rows=[i//16 for frame in ASSET['frames'] for i,v in enumerate(frame) if v in (1,2,3)]
    top=b['position'][2]+b['size'][1]/2
    return dict(enabled=True,position=b['position'],worldSize=b['size'],sourceSize=[16,32],
        frames=len(ASSET['frames']),transparentIndex=0,opaqueBlackIndex=4,
        sourceAsset=b['asset'],cameraFacing='screen-aligned',
        bodyHeight=(max(rows)-min(rows)+1)*b['size'][1]/32 if rows else 0,
        feetWorldZ=top-(max(rows)+1)*b['size'][1]/32 if rows else None,
        headWorldZ=top-min(rows)*b['size'][1]/32 if rows else None,
        outline='opaque source index4; supplied by the configured asset')
