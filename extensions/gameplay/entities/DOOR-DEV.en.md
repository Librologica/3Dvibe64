# ENT-01 — polygonal sliding door, 1.13.0

Release 1.13.0: [current optimizations](../../../RENDER-OPTIMIZATIONS.en.md), [external inputs](../../../EXTERNAL-INPUTS.en.md). All ../my-inputs/demos and native evidence are external to the source distribution.


Current 1.12.0 distribution ships the reusable module only. New demo projects/assets are excluded. Source captures, checkpoint numbers and native measurements below describe historical external proofs. Native project builds require explicit `--project-source`; see the [integration guide](../../../GAMEPLAY.en.md).


`door-entity` retains UI, configurable guardian and mixed surfaces. A divider
at public Y=8 spans the room with a 10 WU wide/18 WU high opening. A uniform
polygonal door retracts into its lintel. Skeleton storage is reused for the
door; the original comparison profile remains separate.

```powershell
python -B work/build-gameplay.py --profile door-entity --out ../door-build --project-source ../my-project
python -B work/qualify-gameplay.py --out ../door-build --checks --benchmark --launcher
```

SPACE uses the nearby guardian and toggles the open request. WASD starts the
frontal manual visit; R restarts the automatic route with closed door and
initial camera. The 3072 tick route opens, crosses, looks back, closes,
reopens, returns and closes. Uses at keys 6/24/30/44 and rejected key 0 are
application actions, not synthetic keyboard input; pitch stays within 14°.

## State and local collision

`dr_state`:0 closed,1 opening,2 open,3 closing. Travel 18 WU at 0.25 WU/tick
takes 72 ticks. Player radius 0.5 WU and height 12 WU; passability starts at
12.25 WU lift, including 0.25 WU clearance. Posts block movement outside the
opening; two-way passage, edge sliding and threshold behavior are qualified.
A closing request with the player in the opening is changed back to open
before reducing clearance. Guardian state/animation follows the corrected
request. Simulation advances by ticks and stays constant during a full draw.

`dr_seen_states` accumulates the four states, `dr_passages` counts side changes,
`dr_route_fault` saturates on an invalid programmed pose. The default full
route requires 15,2,0 respectively. `dr_safety_events` counts reopenings.

## Geometry, ordering and validation

21 vertices,32 triangles/nodes, one source object. Divider and door are double
sided. The lower visible edge changes in Q8 before camera transformation;
the upper edge is clipped by the lintel. Two mobile source vertices have a
distinct initial integer height to prevent importer welding; runtime always
sets their height to floor+lift, without moving the posts.

The common exact shader/near/screen clipper is retained, with LOD 14–22.
The divider separates the whole guardian envelope for supported views: from
the front it draws before the guardian, from behind after it, revealing only
pixels through the free aperture. Invalid guardian placement is rejected.
This ordering and collision contract is limited to one divider/room/billboard,
not arbitrary level intersections.

Qualification includes 20 native state/input/threshold/passage/closure/safety/
restart cases,14 UI/clipping views and five independent 16000 byte bitmap
comparisons at closed, partial, threshold and open states. Mobile quarter-WU
coordinates are checked in emulated RAM. `--door-config` with
`{"schema":1,"motion":false}` keeps an equal-route diagnostic control closed;
the programmed camera does not exercise collision in that control. Actual
door movement also changes drawn area/occlusion, so its FPS delta includes
that work. Raw commands and timing remain external source-release evidence.

[Italiano](DOOR-DEV.it.md) · [Release notes](../../../RELEASE-NOTES-1.12.0.en.md)
