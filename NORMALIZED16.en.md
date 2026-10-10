# Normalized16 — experimental geometry profile, 1.9.0

An explicit intermediate alternative, not a cheaper setting inside Q8.
Legacy remains the default; Q8 remains the precise general supported path.
No automatic selection based on CPU clock. This is not raycasting, antialiasing
or a higher-resolution display. Mode8 is not affected.

## Build

```powershell
$env:TASS64_EXE = 'C:\tools\64tass.exe'
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -Precision normalized16 -GraphicsMode 4 -SceneFile examples/q8/two-objects-mode4.json -Q8Camera interactive -VideoStandard pal -OutputDirectory ../normalized-mode4-pal
```

Output must be new and outside the SDK. ASM, PRG, labels, actual memory map and
build.json are generated, not patched binary assets. Python3, PowerShell7 and
64tass are required. `work/normalized_build.py` exposes the same Python build.
Use PAL or NTSC explicitly; omitted standard is PAL. Camera is stationary or
interactive walkLite; automatic fractional camera is deliberately refused.
Objects keep their original tick-based rotation. The renderer is compatible
with documented 6510 instructions; the measurements below use acceleration.

## Supported experimental envelope

Modes1–7, 160×100 logical / 320×200 physical, full bitmap, one/two nonshared
objects, **at most 16 runtime vertices**, scale0..1 excluding0, scaled radius
at most40WU, no Ground, timeline, roll or small viewport. Initial camera
rotation0; runtime yaw/pitch permitted. Mode4 requires quad faces. The other
modes retain their triangle/quad ABI. Mode7 supports **affine texture mapping**
and inherited Gouraud compositorC, not perspective/fast/LOD. Those features
continue to require Q8. No hybrid line selection, overlay or soundtrack here.
Unsupported combinations fail rather than silently ignoring options.
Limits are not a guarantee of RAM fit: final placement retains overlap guards.

## Arithmetic and memory

Q8 fractional object-angle coefficient setup is retained. Per-object camera
coordinates use signed16 in units2^e/16WU, e0..4. A signed24 Q8 origin is
arithmetically shifted by4, then reduced until magnitudes are below12288.
Camera yaw/pitch folds into the object matrix before vertex terms. Vertices
sum signed24 terms and round through arithmetic shift4+e. Near8WU (Mode1–6)
or1WU (Mode7) is expressed in the same scale. Overflow sets hp_fault, not a
hidden legacy fallback. A small far-coordinate/corner quantization error is
possible; this is not bit-identical Q8 geometry.

Five homogeneous planes clip in camera space using signed32 distances and a
canonical outside→inside ratio. Projection normalizes positive depth to a
512-entry reciprocal table, then delivers Q2 screen coordinates to the
existing raster/shaders. Wire modes clip original edges without artificial
cap edges. Geometry allocation, bitmap banks, palette policy, double buffer
and safe presentation remain independently checked. Per-build blockSizes,
allocation and remainingGaps describe actual memory use; do not equate PRG
file gaps to free runtime RAM. IRQ does not use the private geometry scratch.

## Evidence and private adaptation

Historical PAL Turbo6510×64, silent, two rotating cubes,2s warm-up+20s window:

| Mode | Q8 FPS | Normalized16 FPS |
|---|---:|---:|
|1|49.10|50.10|
|2|22.55|24.55|
|3|30.75|36.05|
|4|26.30|34.75|
|5|25.05|27.30|
|6|21.30|24.10|
|7, affine|9.05|9.45|

These are **historical test-harness builds**, not FPS promises for this SDK.
See NORMALIZED16-QUALIFICATION.md for public-build measurements and tests.
Independent continuous endpoint oracle: mean.3094, p95.6610, max1.2969 logical
pixels in the historical corpus versus Q8 mean.2755. Near-tangent case105
remains a quantization limitation; full arbitrary-mesh coverage is not claimed.

A separate private ship experiment uses adaptive e0..8 from the full Q8 origin,
focal100 rather than170 and precise-facing confirmation. Its corrected
projector treats screen-Q8 X128..159 as **unsigned16**, with sign extension
above the screen word and explicit zero-shift handling. The earlier signed
test caused disappearing border faces. After correction:0/4167 projector
differences,0 missing faces in3696 loader calls, PAL12.28469→12.94049FPS,
+5.34%, over239.4s with the private soundtrack. This is **not the public
Normalized16 exporter**, not a universal engine speed claim and not included
as a private production/demo asset. The public Q2 projector does not use that
faulty signed screen-Q8 branch. Q8/perspective/fast/LOD is not changed by it.

## Recommendation

Use legacy for low-cost rendering, Q8 for the precise production path,
Normalized16 only for deliberate experiments inside its documented envelope.
Do not convert existing Mode7 perspective scenes by deleting their contracts.
NTSC assembly is tested separately from native FPS; hardware remains untested.
