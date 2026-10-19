> Development edition 1.15.0-dev1; inherited1.14.0 contracts remain unless explicitly extended in [exact rendering](../../../EXACT-RENDER.en.md).

# WORLD-01 — external resident room groups, 1.13.0

Stable release 1.14.0: [current optimizations](../../../RENDER-OPTIMIZATIONS.en.md), [external inputs](../../../EXTERNAL-INPUTS.en.md). All demonstration projects and raw native evidence remain external to the source distribution.


Current 1.12.0 distribution ships the reusable module only. New demo projects/assets are excluded. Source captures, checkpoint numbers and native measurements below describe historical external proofs. Native project builds require explicit `--project-source`; see the [integration guide](../../../GAMEPLAY.en.md).


`room-groups` loads real external data through C64 KERNAL. The default route
visits hall→crypt→hall: two groups of two rooms with different widths, floor
and door. One group occupies active geometry/material arrays; textures,
palette and guardian frames remain resident/shared.

```powershell
python -B work/build-gameplay.py --profile room-groups --out ../world-build --project-source ../my-project
python -B work/qualify-gameplay.py --out ../world-build --checks --benchmark --launcher
```

Keep generated `project/media` alongside `launch-demo.cmd`; the PRG alone
cannot supply other groups. Target: VICE Turbo6510 PAL× 64, device 8 filesystem,
KERNAL traps enabled, true-drive/IEC bus emulation disabled. Read timings apply
to that backend, not a physical 1541. No music; precise all 60 rows and LOD 14–22.
N/P requests next/previous neighbor and enters manual mode. WASD moves, SPACE
uses guardian/door, R resumes the current group's tour. Transitions are explicit,
not uninterrupted walk-through portals. Default 24 keys per group; larger graphs
need suitable application controls/routes.

## Configuration and geometry

`--world-groups path.json` replaces `assets/world-groups.json`: schema 1,
Boolean `enabled`,`autoTransitions`, `capacityBytes:1024`,2–8 groups. Each has
unique ID, `rooms:2`, integer `halfWidth`18–24, nullable/integer `floorLevel`
0–32, `doorIndex`1–3, Boolean `initialOpen`,1–2 neighbors. Graph connected,
reciprocal, without duplicate/self edges.

Only the 21 vertex/32 face door layout is supported: rectangular room volume,
divider Y 8, central aperture/mobile door. Width, floor Gouraud level, flat
door color and initial state vary; lateral collision follows width. This is
not arbitrary topology, nor automatic combination of all other profiles.

## File and transaction contract

`wg00`…`wg07`:762 bytes each,12 byte header,748 payload,2 CRC 16-CCITT. Header
magic WG01, group index,2 rooms,21 vertices,32 faces, little-endian payload
length, half width and initial door state. Payload has 27 whitelisted coordinate,
index, UV, material, Gouraud and ordering channels. Compiled destinations/
lengths are resident; files supply data only, no addresses or executable code.

Staging 1024 bytes. OPEN/CHKIN/CHRIN checks capacity, EOF/I/O, exact length,
magic/counts/index/CRC before installation. CRC must match trailer and the
resident expected value computed by the builder; changed files require a
matching rebuild. `wg_request`: A=index, carry 1 accepted/no-op, carry 0 rejected.
Only one pending target, a current neighbor; initial load accepts only 0.
`wg_service` runs at view start. Simulation freezes pending transition; I/O
keeps the previous complete view. CPU port,CIA 2,254 zero-page bytes and 32 RAM
vector bytes are saved/restored. A dedicated IRQ retains refresh accounting
with KERNAL mapped. I/O code, IRQ wrapper/counters must allocate below$D 000.

`wg_error`:0 success,1 index,2 busy,3 no link,4 I/O/capacity,5 format/integrity.
Failure preserves active geometry/state/camera, modifying only staging and
diagnostic counters. Pending request is cleared on error as well.

## Persistent state and budget

17 bytes/group:16 slots+first-visit flag. Fourteen active fields include guardian
state, success/rejection counts, Q8 door lift/state, safety/visited/passages,
animation cursors/hold/frame. Inactive groups freeze. Returning restores state
and starts at frontal entry; camera position is not stored. Persistence is
RAM-session only, without disk saves. Decoded frame is invalidated on switch.

Default: staging 1024, I/O 620, manager 1237(including slots), free 1006 bytes
versus 3502 in door-entity. Net 2496 includes 408 camera bytes saved by 24 keys.
Equal 48-key/no-transition control leaves 598, net 2904. Renderer/UI/guardian
buffers are not shrunk. `enabled:false` reproduces door-entity exactly.

Native evidence covers actual device 8 reads/all 27 channels, exact state return,
commands/held keys, moving-door restore, missing/empty/truncated/oversize/
corrupt files and forced IRQ during input. Independent static builds control
28 views (UI, bitmap/screen/ColorRAM, clipping, door/guardian/LOD). An 8-group
variant visits all 16 rooms and returns. Matched FPS uses the original 48-key
route with autoTransitions:false; active A→B→A is separately measured. Only
new full views, base PAL cycles and at least 20 emulated seconds after warm-up
count; warp/host timing is excluded. General integration remains separate.

[Italiano](WORLD-DEV.it.md).
