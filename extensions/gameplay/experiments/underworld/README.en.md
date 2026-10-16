# Underworld bounded integration — 1.11.0

This separate source experiment combines three connected rooms, original
LABIRINTO UI, three static flat cubes, the original 3D skeleton with sword/
shield and an outlined animated guardian billboard. Both character bodies
are 15 WU tall; full skeleton 38 vertices/52 segments, no geometric LOD.
Viewport 96 × 60 logical /192 × 120 physical at 48,8, focal 51: exact perspective per
pixel on all 60 rows, texture LOD 14–22. No precompiled program/demo archive is
part of the official source distribution.

```powershell
python -B work/build-underworld.py --out ../underworld-build
python -B work/build-underworld.py --out ../underworld-control --no-room-culling
```

Use a new directory outside sources; generated `launch-demo.cmd` starts the
output. SDK, scene, assets, memory maps and qualification tools are materialized
there. `--scene-config path.json` imports a validated billboard configuration
and its local asset. `--no-room-culling` changes only conservative whole-room
behind-camera rejection for a matched control; it does not select fast quality.

Route 96 keys/6144 ticks:24 keys of orbit/close/vertical inspection and 72 resampled
three-room exploration. It avoids all three cubes and both characters. Floor
cubes retain centers(-16,0,-7),side 6 and(16,48,-6),side 8 WU. The suspended
third cube center(0,160,4),side 8 is static in this variant. Original walls,
openings,corridors,floors,ceilings and textures are retained.

BB-02 supplies six 16 × 32 frames, opaque black outline 4 and transparent 0,
perspective depth/size. Default idle frames 0–3 every 12 logical ticks and alert
4–5 every 6. Entering configured inclusive XY use range sends an accepted use;
SPACE is edge-triggered, rejected outside range. Persistent entity state
switches guardian animation and skeleton walk/attack clip. Clips advance by
simulation tick, independent of complete-view FPS. SPACE does not stop camera.

Only rooms whose transformed vertices all have negative camera Z are omitted.
This is neither angular PVS nor a general portal/intersection solver. Painter
is bounded to five checked convex cells and disjoint first-room characters.
Cubes/actors share a bounded depth band, preserving ordering as camera side
changes. Billboard stays screen parallel; center below 8 WU is rejected.

After `game_ui_init` returns,2904 bytes of dead UI decoder/input storage hold
skeleton/actor/cache/ordering and Q8/screen coordinate buffers. Compact painter
tables 175 bytes replace five 120 byte tables. UI bitmap/screen/ColorRAM are not
scratch. Frames compress losslessly to 1098 bytes with one-byte RLE; immutable
poses/initializers live under I/O. Capacity/contiguity/lifetime guards apply.
This reuse is local; it does not change WORLD-01's format or budget. Doors,
general collision, manual navigation and functional inventory are not added.

Ordinary generator, foundation 1.10.2 and Mode 8 remain unchanged. The precise
`mode7_span_hot` optimization from 1.10.3-dev1 is an explicit local source input
`inherited_precise_span.py`, with fast=False, not silently merged into core.

In generated output, `tools/verify_adventure.py --project . --control <control>`
checks 32 pose decodes,sixframes,bank restoration/disjoint overlays,events,
3600 painter cases,16 uniform cube planes and 6144 navigation ticks. CPU checks
prove correctness, not FPS. Native captures compare UI/palette/bitmaps/faults
at matching poses. `tools/benchmark_comparison.py` needs its matched build
in `reference/previous`; prepare new outputs for fresh runs because saved
results are reused. Actual default launcher is also checked via `-Verify`.

Inherited corrected-dev13 native program SHA 256:
`249D99C34BA0A50C318A1577F07E632ACD3BEEE299E3AFEDCDDDD31966B6FA2E`.
PAL Turbo6510× 64,silent,101 refresh/2.014981 s warm-up,6400 refresh/127.681964 s
measurement, full route:691 new complete views,5.411884 FPS,p 95=219.453 ms,
worst=299.255 ms. Without the cubes the older variant measured 5.748658 FPS;
geometry changed, so that difference is not isolated renderer optimization.
Same new scene with culling disabled measured 5.411884 FPS. Original raw/native
commands remain external evidence. A promotion without changed PRG bytes or
launch conditions reuses those measurements; it does not invent a new one.

[Italiano](README.it.md).
