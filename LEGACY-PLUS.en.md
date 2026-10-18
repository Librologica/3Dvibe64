# Legacy-plus — 1.13.0

`-Precision legacy-plus` selects the bounded intermediate Mode2 renderer.
Legacy stays the default; Q8, Normalized16, Mode8 and the compatibility
`-LegacyStability rotation` path retain their contracts. Legacy-plus is not an
alias of rotation: it inherits that transform and adds corrected wire clipping,
Q4 near/screen geometry and the dev7 camera cadence optimization. No Q8 backend
or additional visible resolution is introduced.

## Build and supported configuration

```powershell
Copy-Item -LiteralPath . -Destination ../my-build-sdk -Recurse
pwsh -NoProfile -File ../my-build-sdk/work/build-3Dvibe64.ps1 -SceneFile ../my-inputs/scene.json -Precision legacy-plus -GraphicsMode 2 -CameraMode walkLite -CameraViewport normal -MemoryLayout high-basic-v2 -Quality fast -Projection extended-table -VideoStandard pal -FramePresentation safe -NoFpsOverlay -ExplorerClipMode near -ExplorerNearCrossMode poly -MinFaceAreaOverride 0 -ScreenMinSpanOverride 0
```

The scene must be external and declare compatible Mode2/walkLite inputs.
First copy the complete SDK to a new sibling working directory. The ordinary
legacy/plus builder writes ASM/labels/map/PRG into that copy's `work/`, with a
PRG copy in `work/build/`. It rejects `-OutputDirectory`; that parameter belongs
to the Q8, Normalized16 and Mode8 branches, not ordinary legacy. This release includes no scene,
demo, route, launcher or compiled program. Python3, PowerShell7 and64tass are
external dependencies; `TASS64_EXE` can select the assembler.

The bounded selector requires Mode2, walkLite, normal160×100, high-basic-v2 and
`-NoFpsOverlay`; incompatible combinations are rejected. Do not combine it with
an explicit conflicting LegacyStability value. Area/span0 are explicit benchmark
settings, not new quality defaults. The new near pass requires ordinary
near-poly with camera-plane profile0 and world-ground-plane clipping0. The native
qualification has no Ground. Other clip selections preserve the inherited path;
they do not acquire the new near precision. Default screen-poly also enables
near-poly internally. Explicit `-ExplorerClipMode near -ExplorerNearCrossMode poly`
reproduces the documented qualification selection.

## Arithmetic and camera input

Object matrices remain Q6. Camera positions/temporary coordinates retain Q4;
camera rotation coefficients use Q10 and4096 angular phases. The final raster
is integer. Relative camera coordinates must stay in[-1024,1024)WU per axis;
inspect `legacy_camera_fault` and the actual assembled memory map.

The public fractional input ABI is documented in
[camera rotation](CAMERA-ROTATION.en.md): set all position/yaw/pitch inputs before
`render_frame_begin`. Keyboard controls still use their inherited byte-angle
steps; choosing plus does not automatically make a byte-only input fractional.
The automatic qualification driver supplies fractional public input and is
external to the SDK. Object rotation precision is not increased by this option.

Near classification/intersections read a separate Q4 camera cache,6bytes per
vertex, preserving original integer geometry buffers. Near8WU is128 Q4 units.
Original source-edge flags are retained: clipping does not invent wire closing
edges. Intersections use more accurate rational weights; projected coordinates
stay Q4 through screen clipping and convert to pixels afterwards. Temporary
screen bounds are restored after every face. Offsets at/above$3a00 activate the
inherited wide integer fallback, keeping signed interpolation spans below32768.
Helpers/cache have assembly guards against IO overlap. The transform may use a
3072byte product LUT when the runtime pool fits, otherwise its serial fallback.
Scene capacity follows the actual map, not a fixed promised vertex count.

The dev7 optimization expands the four Q4 signed rounding shifts. Addition,
numeric results and final register/flag state are unchanged;21 PRG bytes replace
loop-control overhead. Raster, safe presentation and input driver are unchanged.

## Native qualification and limits

VICE Turbo6510 MOS8565 PAL ×64, safe, Colodore/filter0, silent. After128 simulation
events of warm-up, each moving case measures one complete2048-tick route,
about41emulated seconds. Only new complete buffer swaps are counted; host time,
warp and CPU replay are not FPS. Final release rebuilds must match the measured
dev7 PRG hashes before reusing these data.

| Case | Legacy | Plus dev6 | Plus1.13.0/dev7 | Q8 |
|---|---:|---:|---:|---:|
| Camera FPS |25.06227|25.05004|25.06227|4.86338|
| Clipping FPS |41.09331|41.19121|41.19121|37.17733|

The camera worst interval is39.9006ms, previously59.8509ms; p95 is39.9006ms.
Clipping p95/worst are39.9006ms. A second native timing trace and a controlled
one-tick trajectory offset confirm the camera result. All658 native plus images
match dev6:158 camera,368 clipping,114 dense crossings,12 exact-near/±1/16/wide
cases and6 near-torus poses. Frozen poses test geometry/buffers, not their FPS.
No observed unexpected disappearance, source-edge-free residue, shared-vertex
mismatch or unstable buffer remains in these tests. Finite Q4, integer raster
and the wide fallback do not promise pixel-exact float/Q8 output or a universal
frame budget. Other scenes, modes, NTSC and physical hardware have no new
qualification from this release.

[Qualification](QUALIFICATION-1.13.0.en.md) ·
[Machine-readable aggregates](QUALIFICATION-1.13.0.json) ·
[Testing](TESTING.md) · [Precision](PRECISION.en.md)
