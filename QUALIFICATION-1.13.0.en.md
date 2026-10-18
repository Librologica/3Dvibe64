# Qualification — 1.13.0

Of93 work inputs,92 are byte-identical to dev7. The builder alone is normalized
from CRLF to the documented LF format; eight native-project rebuilds are
byte-identical. Stable preparation changes no renderer arithmetic. Native PRG identity is checked after building the final package.
Identical measured programs reuse their actual native evidence; no new FPS is
estimated or attributed to a different executable.

VICE Turbo6510 MOS8565 PAL ×64,985248Hz base clock,312×63cycles/refresh, safe,
Colodore, filter0, no music/audio. Mode2/walkLite/normal/high-basic-v2/no-overlay,
ordinary near-poly, no Ground; quality fast, extended-table, area/span0.
Camera: static126-vertex torus with moving XYZ/yaw/pitch. Clipping: adjacent
triangles with different origins cross near8/screen and return. No stationary
phase.128 simulation events warm up, then2048ticks complete the route. Only
new complete views after swap count at `fps_frame_done`; trace and counter agree.
Warp and host time do not enter FPS. All launch options, raw timestamps, RAM,
PNGs, inputs and actual commands are retained outside the source distribution.

| Case | Warm-up s | Emulated s | New views | Mean FPS | p95 ms | Worst ms |
|---|---:|---:|---:|---:|---:|---:|
| Plus camera |2.589751|40.858229|1024|25.062271|39.900614|39.900614|
| Plus clipping |2.589750|40.858229|1683|41.191213|39.900614|39.900614|

Measured PRG SHA256:
- Camera: `7755e1b1fdaf8dc9dbe0d362056953cb050cf358e4c1ee06b6721febd6d72223`.
- Clipping: `662ef5aa393285360c900b0ebb90df79360d9033e52b9530bef4dc043f92bf30`.

Before: plus dev6 camera25.050044FPS, worst59.850921ms; clipping41.191213FPS.
A second native begin/end/present trace and a verified one-tick input-phase
offset repeat the improved camera cadence. All658 frozen plus images match
dev6, both VIC buffers are stable, no new source-edge-free residue, unexpected
disappearance, behind-near leak or shared-original-vertex mismatch is observed.
The independent float oracle is an observational geometry check, not a
pixel-perfect raster proof. Q4 precision, wide fallback and integer raster remain.

Other modes/layouts, hardware, NTSC and arbitrary complexity get no new native
FPS or error guarantee. Historical corrected/camera/rotation reports retain
their own scope. Default legacy/Q8 references are reused only after exact PRG
identity. The current aggregate JSON contains hashes, counts, conditions,
metrics and limits, without scenes, routes or raw captures.

[Machine-readable qualification](QUALIFICATION-1.13.0.json) ·
[Legacy-plus](LEGACY-PLUS.en.md) · [Testing and reproduction](TESTING.md)
