# Q8-02 — controlled animation and camera roll, 1.13.0

Stable release 1.14.0: [current optimizations](../../../RENDER-OPTIMIZATIONS.en.md), [external inputs](../../../EXTERNAL-INPUTS.en.md). All demonstration projects and raw native evidence remain external to the source distribution.


Current 1.12.0 distribution ships the reusable module only. New demo projects/assets are excluded. Source captures, checkpoint numbers and native measurements below describe historical external proofs. Native project builds require explicit `--project-source`; see the [integration guide](../../../GAMEPLAY.en.md).


`controlled-animation` and `camera-roll` extend Q8-01. The first keeps the
dungeon camera without roll; the second banks the camera in the same bounded
room. Four solids have independent position/yaw/scale/visibility clips.
Precise textured walls, all 60 rows, LOD 14–22 and UI 96 × 60 remain.

```powershell
python -B work/build-gameplay.py --profile controlled-animation --out ../motion-build --project-source ../my-project
python -B work/build-gameplay.py --profile camera-roll --out ../roll-build --project-source ../my-project
python -B work/qualify-gameplay.py --out ../roll-build --checks --benchmark --launcher
```

`--motion-controls path.json` replaces configuration. `enabled:false` omits
Q8-02 entirely and reproduces shared-meshes. The standalone Q8-01 profile
retains its own checkpoint.

## Clip format and time

Schema 1, Boolean enabled, camera, clips. One clip per instance in the same ID
order as shared-meshes: `instance`, `ticksPerKey:64`, `playing`, `speed`1/2/4,
`loop`,1–8`keys`. Keys contain public `position`, `yawDegrees`[0,360),
`scale`0.5–1 step 1/64, Boolean `visible`. First key equals the descriptor;
positions step 1/256 WU. The validator checks all 64 quantized samples of every
segment including closure, room containment and disjoint instance envelopes.

PAL simulation ticks drive clips independently of draws; speed 2/4 consumes
2/4 steps per tick. Position/yaw increments round to nearest Q8/phase and exact
end keys prevent cyclic drift. Yaw follows the shortest arc, negative at 180°.
Scale keeps a Q14 accumulator and publishes Q6; visibility changes at key entry.

## Native application API

Call `an_control` in the main thread before constructing a view: A=opcode,
X=instance 0..N−1, Y=argument. Carry 1 succeeds; carry 0 rejects without altering
pose/clip cursors. Other registers/flags are scratch. Sources remain immutable.

| A | Operation | Y |
|---:|---|---|
|0|Pause, preserving fractional time|ignored|
|1|Resume|ignored|
|2|Stop at first key and pause|ignored|
|3|Seek exact key, retain play/pause|key index|
|4|Set speed|1,2,4|
|5|Set loop|0,1|
|6|Next key and pause|ignored|
|7|First key and play|ignored|

Without looping the final key stops and sets `an_completed`. Disabling loop
on the closing segment lands exactly on the last key. A one-key nonlooping
clip completes at its initial pose. Keyboard 1–4 select instance, SPACE pauses/
resumes, R restarts, T steps to next key paused, F cycles 1/2/4. Single actions
are edge-triggered and do not change other clips.

## Camera API and controls

`camera.mode`: dungeon/flight. `bankDegrees`0–45 controls automatic bank
amplitude over 3072 ticks. Yaw/pitch/roll are full 16 bit phases. Inverse roll
acts after yaw/pitch on 24 bit camera coordinates, before projection/near/screen
clipping, using canonical sine/Q8 products. UI pixels remain unchanged.

`cr_set_roll`: A=phase low byte,Y=high, carry 1 success; enters manual roll.
Dungeon accepts only zero and rejects nonzero without changing state. Flight
accepts full turns/wrap. `cr_resume` resumes automatic bank at current route
phase without advancing/restarting the camera. In flight Q/E change roll by
128 phase units/tick, HOME zeros it, C resumes automatic bank. Camera still tours.

Default four 4-key clips:344 source bytes,80 state,192 bank table,9 camera state;
player 650, keyboard 285, roll 361 code bytes. Including call sites/guards/layout,
increment 1979 allocated bytes over Q8-01; free 3302. Geometry/caches unchanged.

Native evidence separately covers dungeon/flight control acceptance/rejection,
fractional pause/resume, speed, loop/end, held keys and manual/automatic roll.
Independent geometry/pixel checks cover 33 vertices at 24 bits, roll 90/180/270,
fractional angles, combined yaw/pitch and clipping. Zero roll matches Q8-01
bitmap/palette; UI stays intact. Native 1/3/4/8-key clips are also tested.
This is not skeletal animation, flight physics, billboard roll or a new
ordinary-builder API. WORLD-01 is a separate included profile.

[Italiano](CONTROLLED-DEV.it.md).
