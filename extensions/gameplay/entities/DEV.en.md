# BB-02 / ENT-01 — configured entity, 1.11.0

`interactive-billboard` inherits mixed-surfaces. `assets/gameplay-scene.json`
configures a 16 × 32 JSON asset with 1–6 frames, public XYZ position, world size,
idle/used sequences and frame duration in simulation ticks. Asset, position,
size and animation can change through data rather than renderer edits.

```powershell
python -B work/build-gameplay.py --profile interactive-billboard --out ../entity-build
python -B work/qualify-gameplay.py --out ../entity-build --checks --benchmark --launcher
```

Override with `--gameplay-scene path/gameplay-scene.json` (`-GameplayScene`
in PowerShell). Asset paths resolve inside the configuration directory and
are copied to the new external output. This is a bounded experimental schema,
not a new field of arbitrary ordinary Q8 scenes.

## Controls and state

Automatic orbit is the initial mode. Scheduled use at keys 0/36 demonstrates
out-of-range rejection and accepted use. WASD enters a frontal manual visit:
W/S forward/back, A/D strafe. SPACE uses the guardian; R resumes the orbit.
Use is edge triggered: holding SPACE does not repeat it.

The entity has state 0/1, separate success/rejection counters and an XY volume.
Use range is an inclusive square, not spherical distance. Local collision
expands its rectangle by player radius 0.5 WU and bounds the room at±23 WU.
Manual speed is 0.25 WU/tick, resolved per axis for sliding. The default volume
keeps the camera in front of the billboard near threshold.

Logic runs on simulation ticks independently of draws. `en_state`,
`en_event_count`, `en_rejected` persist; `en_event` pulses for one tick:
0 none,1 accepted,2 rejected. The binding consumes it to choose animation.
Counters are 8 bit and wrap after 255; there is no general event queue.
`entity.enabled:false` disables interaction and the manual visit.

## Geometry and limits

One instance, one convex room and an already shared VIC palette. Index 0 is
transparent,1–3 pigments,4 opaque black; no alpha blending. The billboard is
screen parallel and perspective sized. Centers below 8 WU are wholly rejected.
The separate [BB-03 adapter](../billboards/MULTIPLE-DEV.en.md) handles two
instances and a 4 WU near threshold. The [door adapter](DOOR-DEV.en.md) adds
mobile passage geometry; neither supplies general level collision/intersection.
Mode 8 and the sealed foundation remain unchanged.

Native evidence covers 17 state/input/collision/sliding/animation cases, every
frame against pixel oracles, an alternate asset with three frames every five
ticks, UI integrity and full-route FPS. No compiled programs ship in the release.

[Italiano](DEV.it.md) · [Release notes](../../../RELEASE-NOTES-1.11.0.en.md)

## Complete single-instance data shape

Schema 1 has exactly `schema`, `billboards`, `entity`; one billboard has
`id`, `asset`, `position`, `size`, `animations`. Public XYZ is finite Q8 in
[-20,20]. Width/height are 1–20 WU and their half sizes must be exact Q8
(multiples 1/128 WU); width≤10, lower Z≥−10.5, upper Z≤18. These are numeric
compiler limits, not a general wall/intersection solver: keep the complete
character envelope inside the supported convex room and camera contract.

`idle`/`used` each contain 1–16 valid frame references and `ticksPerFrame`1–255.
`entity` has `billboard` matching the ID, Boolean `enabled`, Q8 `useRange`1–24,
two Q8 `collisionHalfSize` values 0.25–10, and integer `demoUseKeys`0–47.
These keys schedule use attempts in the automatic 48-key route; they are not
keyboard events. The default lists 0/36. Source asset fields are `width:16`,
`height:32`, `transparentIndex:0`, `opaqueBlackIndex:4`, and 1–6`frames`,
each 512 integer pixel indices 0–4. Unknown configuration fields and invalid pixel/timing types/counts fail validation.
The full default JSON and asset are linked in [GAMEPLAY](../../../GAMEPLAY.en.md).
