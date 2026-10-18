# Normalized16 — experimental geometry profile, 1.13.0

Release 1.13.0: [current optimizations](RENDER-OPTIMIZATIONS.en.md), [external inputs](EXTERNAL-INPUTS.en.md). All ../my-inputs/demos and native evidence are external to the source distribution.


Current 1.12.0 source contract. This manual describes the ordinary exporter unless
explicitly stated otherwise; bounded gameplay/configuration/roll/group APIs
are documented in [GAMEPLAY](GAMEPLAY.en.md). [Documentation index](DOCS.md).

An explicit intermediate alternative, not a cheaper setting inside Q8.
Legacy remains the default; Q8 remains the precise general supported path.
No automatic selection based on CPU clock. This is not raycasting, antialiasing
or a higher-resolution display. Mode 8 is not affected.

## Build

```powershell
$env:TASS64_EXE = 'C:\tools\64tass.exe'
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -Precision normalized16 -GraphicsMode 4 -SceneFile ../my-inputs/q8/two-objects-mode4.json -Q8Camera interactive -VideoStandard pal -OutputDirectory ../normalized-mode4-pal
```

Output must be new and outside the SDK. ASM, PRG, labels, actual memory map and
build.json are generated, not patched binary assets. Python 3, PowerShell 7 and
64tass are required. `work/normalized_build.py` exposes the same Python build.
Use PAL or NTSC explicitly; omitted standard is PAL. Camera is stationary or
interactive walkLite; automatic fractional camera is deliberately refused.
Objects keep their original tick-based rotation. The renderer is compatible
with documented 6510 instructions; the measurements below use acceleration.

## Supported experimental envelope

Modes 1–7, 160 × 100 logical / 320 × 200 physical, full bitmap, one/two nonshared
objects, **at most 16 runtime vertices**, scale 0..1 excluding 0, scaled radius
at most 40 WU, no Ground, timeline, roll or small viewport. Initial camera
rotation 0; runtime yaw/pitch permitted. Mode 4 requires quad faces. The other
modes retain their triangle/quad ABI. Mode 7 supports **affine texture mapping**
and inherited Gouraud compositorC, not perspective/fast/LOD. Those features
continue to require Q8. No hybrid line selection, overlay or soundtrack here.
Unsupported combinations fail rather than silently ignoring options.
Limits are not a guarantee of RAM fit: final placement retains overlap guards.

## Arithmetic and memory

Q8 fractional object-angle coefficient setup is retained. Per-object camera
coordinates use signed 16 in units 2^e/16 WU, e 0..4. A signed 24 Q8 origin is
arithmetically shifted by 4, then reduced until magnitudes are below 12288.
Camera yaw/pitch folds into the object matrix before vertex terms. Vertices
sum signed 24 terms and round through arithmetic shift 4+e. Near 8 WU (Mode 1–6)
or 1 WU (Mode 7) is expressed in the same scale. Overflow sets hp_fault, not a
hidden legacy fallback. A small far-coordinate/corner quantization error is
possible; this is not bit-identical Q8 geometry.

Five homogeneous planes clip in camera space using signed 32 distances and a
canonical outside→inside ratio. Projection normalizes positive depth to a
512-entry reciprocal table, then delivers Q2 screen coordinates to the
existing raster/shaders. Wire modes clip original edges without artificial
cap edges. Geometry allocation, bitmap banks, palette policy, double buffer
and safe presentation remain independently checked. Per-build blockSizes,
allocation and remainingGaps describe actual memory use; do not equate PRG
file gaps to free runtime RAM. IRQ does not use the private geometry scratch.

## Evidence and private adaptation

Historical PAL Turbo6510× 64, silent, two rotating cubes,2 s warm-up+20 s window:

| Mode | Q8 FPS | Normalized 16 FPS |
|---|---:|---:|
|1|49.10|50.10|
|2|22.55|24.55|
|3|30.75|36.05|
|4|26.30|34.75|
|5|25.05|27.30|
|6|21.30|24.10|
|7, affine|9.05|9.45|

These are **historical test-harness builds**, not FPS promises for this SDK.
See NORMALIZED 16-QUALIFICATION.md for public-build measurements and tests.
Independent continuous endpoint oracle: mean.3094, p 95.6610, max 1.2969 logical
pixels in the historical corpus versus Q8 mean.2755. Near-tangent case 105
remains a quantization limitation; full arbitrary-mesh coverage is not claimed.

A separate private ship experiment uses adaptive e 0..8 from the full Q8 origin,
focal 100 rather than 170 and precise-facing confirmation. Its corrected
projector treats screen-Q8 X 128..159 as **unsigned 16**, with sign extension
above the screen word and explicit zero-shift handling. The earlier signed
test caused disappearing border faces. After correction:0/4167 projector
differences,0 missing faces in 3696 loader calls, PAL 12.28469→12.94049 FPS,
+5.34%, over 239.4 s with the private soundtrack. This is **not the public
Normalized 16 exporter**, not a universal engine speed claim and not included
as a private production/demo asset. The public Q2 projector does not use that
faulty signed screen-Q8 branch. Q8/perspective/fast/LOD is not changed by it.

## Recommendation

Use legacy for low-cost rendering, Q8 for the precise production path,
Normalized 16 only for deliberate experiments inside its documented envelope.
Do not convert existing Mode 7 perspective scenes by deleting their contracts.
NTSC assembly is tested separately from native FPS; hardware remains untested.
