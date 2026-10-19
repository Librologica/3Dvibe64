> Development edition 1.15.0-dev2; inherited1.14.0 contracts remain unless explicitly extended in [exact rendering](EXACT-RENDER.en.md).

# Native qualification — 1.14.0

This stable source SDK promotes the qualified development that extends legacy-plus to Mode1–7 and Mode7 affine/perspective, including none/flat/Gouraud A/B/C. No Q8 geometry backend is linked. Official releases and frozen demos are preserved; the stable distribution is published on GitHub. [Profile and build](LEGACY-PLUS.en.md) · [structured results](QUALIFICATION-1.14.0.json).

## Stable promotion and application scope

Promoted from `1.14.0-dev1`, source commit `3d7a30b`. All runtime implementation/configuration files under `work/` and `extensions/` retain the exact qualified bytes; their paired manuals are updated. This promotion changes documentation, version/package metadata and host distribution checks only. Native FPS below are inherited acquisitions of the exact same PRGs, not new timing runs. The separate release QA retains fresh rebuild identities and package-test logs; raw development acquisitions stay at their original paths.

The private Underworld port is excluded, including its three rooms, actors, UI, camera route, assets and programs. Its 96×60 viewport, banked loader/RAM layout, face-culling fix, material/LOD specialization and sampler/divider optimizations are not installed by this public SDK. Its measured 5.247413 FPS and 22.5% gain describe that application only. Existing gameplay adapters retain their bounded Q8-oriented contracts; ordinary legacy-plus does not automatically port them. Mode7 plus remains standard textures, LOD off, depth8–256WU and normal160×100. See [release notes](RELEASE-NOTES-1.14.0.en.md).


## Method and provenance

VICE Turbo6510 MOS8565 **PAL, multiplier64**, safe presentation, normal160×100, Colodore/filter0, **silent**. This engine qualification is not the music-active shuttle demo. The actual external `launch.ps1` supplies `-default +confirmonexit -pal -turbo6510 64 +sound -autostartprgmode 1 -VICIIfilter 0 -VICIIextpal -VICIIpalette ...`. Acquisition uses `-console -warp -initbreak ready -moncommands ...`; warp only accelerates the host acquisition. The JSON preserves complete commands, absolute paths, emulator/PRG/scene/motion hashes and raw report references.

Warm-up128 simulation events (about2.56–2.70 emulated seconds), then one complete2048-tick route, about40.8 emulated seconds. Count only new completed renderer views at `fps_frame_done`; trace and24-bit native counter agree. PAL baseclock985248Hz,312×63 cycles/refresh. All128 route bins are observed; no host time, duplicate refresh count or CPU-replay FPS. IRQ validity and SID writes are checked; all promoted faults and SID writes are zero. Individual warm-up, duration, completed-view count and p95/worst are in JSON. The eight route windows distinguish visible, crossing and fully clipped phases.

External evidence root: `C:/Users/rapso/Desktop/TEST 3Dvibe64/3Dvibe64_Dev_1.14.0-dev1-legacy-plus-modes1-7`. `build/` contains inputs/ASM/labels/maps/logs, `artifacts/` exact PRGs, `reports/fps-*` raw timestamps/commands/monitor logs and per-window data, `raw/poses-*` VICE PNG/RAM captures, `tools/` acquisition/oracle scripts. These are development evidence outside the source-only SDK.57 final rebuilds are byte-identical to their measured references; source/documentation edits do not substitute a different executable. Legacy/Q8 controls are rebuilt from1.13.0; their final reference bytes are identical.

## Modes1–7: native average and intervals

Camera:48-vertex8×6 torus, small fractional camera XYZ/yaw/pitch route. Clipping: two adjacent independently positioned double-sided triangles, crossing near and all screen borders, including fully behind phases. Mode7 is affine in this table. Identical geometry, motion, target and raster options are used where the historical adapters support them.

| Mode | Legacy camera / clip FPS | Plus camera / clip FPS | Q8 camera / clip FPS | Plus camera p95 / worst ms | Plus clip p95 / worst ms |
|---|---:|---:|---:|---:|---:|
| 1 | 50.125 / 50.125 | 50.125 / 50.125 | 16.708 / 50.125 | 19.950 / 19.950 | 19.950 / 19.950 |
| 2 | 50.125 / 41.093 | 49.072 / 41.191 | 12.531 / 37.177 | 19.950 / 39.901 | 39.901 / 39.901 |
| 3 | 50.125 / 46.802 | 50.125 / 47.609 | 21.401 / 47.016 | 19.950 / 19.950 | 39.901 / 39.901 |
| 4 | 50.125 / 46.802 | 25.331 / 47.536 | 16.708 / 46.894 | 39.901 / 39.901 | 39.901 / 39.901 |
| 5 | 25.062 / 46.092 | 25.062 / 47.047 | 16.708 / 41.314 | 39.901 / 39.901 | 39.901 / 39.901 |
| 6 | 25.062 / 34.877 | 25.062 / 35.440 | 16.708 / 34.845 | 39.901 / 39.901 | 59.851 / 99.752 |
| 7 | 12.531 / 30.310 | 12.531 / 31.891 | 7.196 / 29.904 | 79.801 / 79.801 | 79.801 / 179.553 |


**Near volumes differ:** plus8WU in every mode; Q8=1WU. Legacy1–6 uses8WU, but the supported original Mode1 reference skips crossing segments and has screen clip disabled. Legacy Mode7 clips at camera plane0, creates intersections/min face depth1 and uses projection divisor minimum2. Its old generic build-report `nearPlaneWU:8` was incorrect for Mode7; this report's `nearClipPlaneWU` is authoritative. Clipping averages include empty/fully clipped route phases; they are not uniform visible-scene FPS. No equality of clipped images or workloads at different near planes is claimed.

Mode4 plus camera falls from50.125 legacy to25.331FPS: the native Q2 screen-Y contract and exact serial camera fallback cost time. Modes3–7 cannot safely retain the old3KB product LUT over live solid code. Plus is not universally faster than Q8 either; the flat projective lighting fixture below is slower. These are measured tradeoffs, not performance promises.

## Mode7 perspective: matched before/after

The matched camera fixture is a tilted24-vertex6×4 torus,48 triangles; legacy remains affine because it has no projective option. Plus affine-before and perspective-after use the same geometry, route and near8. They differ only in texture interpolation and its required carriers.

| Profile | Camera FPS | Camera p95 / worst ms | Clip FPS | Clip p95 / worst ms |
|---|---:|---:|---:|---:|
|Legacy affine|16.708|59.851 / 59.851|30.310|79.801 / 159.602|
|Plus affine before|16.480|59.851 / 79.801|31.891|79.801 / 179.553|
|Plus perspective|5.834|179.553 / 199.503|26.417|219.453 / 758.112|
|Q8 perspective|3.948|279.304 / 279.304|25.307|199.503 / 997.515|


Continuous-UV clipping plane:212,505 robust native interior samples for final plus perspective, **zero wrong texels and zero missing pixels** versus an independent inverse-ray/UV oracle. On the same scene plus affine-before differs on31.6943% of robust samples, the expected affine distortion. Q8 perspective also has zero wrong/missing robust samples on207,623 samples; actual camera angular quantization changes its sample set. The oracle excludes edges, depth below10WU and quarter-texel checker boundaries. It does not prove infinite precision or eliminate nearest-neighbor aliasing. Final plus plane maximum outside-surface distance0.37131 logical pixel.

## Lighting

Same12-vertex20-face icosahedron and moving camera. Legacy perspective-labelled controls explicitly use affine; their bytes match the corresponding affine controls and reuse those exact measurements. They are not projective measurements. Gouraud A/B are outside Q8's public contract; Q8 perspective Gouraud C rejects this same scene's RAM fit, so no FPS is invented. Its rejection logs are retained. All eight plus lighting variants passed33 route poses and36 full-orbit poses.

| Mode7 lighting / texture | Legacy affine FPS | Plus FPS | Q8 FPS | Plus p95 / worst ms |
|---|---:|---:|---:|---:|
|flat|22.590|21.587|16.708|59.851 / 59.851|
|gouraud-b|16.708|16.708|C only|59.851 / 59.851|
|gouraud-c|16.716|16.782|15.314|59.851 / 59.851|
|gouraud|16.708|16.708|C only|59.851 / 59.851|
|perspective-flat|22.590|6.780|8.273|159.602 / 159.602|
|perspective-gouraud-b|16.708|6.336|C only|179.553 / 179.553|
|perspective-gouraud-c|16.716|6.489|RAM limit|159.602 / 179.553|
|perspective-gouraud|16.708|6.287|C only|179.553 / 179.553|


## Stability and arithmetic

The table measures per-coordinate RMS logical-pixel error against independent floating camera transforms on common visible original vertices. It includes each public camera's angular input quantization: this driver writes fine fractions only where that ABI exists, whereas the inherited legacy/Q8 interactive path uses byte camera angles. It is a comparison of these exact input paths, not a proof that Q8 geometry is intrinsically less precise. JSON separately reports projection error at actual angles and adjacent motion steps. A finer phase can increase an individual pixel step while reducing positional error.

| Camera case | Legacy RMS px | Plus RMS px | Q8 RMS px | Plus frozen/shared/disappearance/leak failures |
|---|---:|---:|---:|---|
| 1 | 2.3154 | 0.5620 | 1.8741 | 0 / 0 / 0 / 0 |
| 2 | 3.5259 | 0.6119 | 2.7365 | 0 / 0 / 0 / 0 |
| 3 | 2.3154 | 0.5620 | 1.8741 | 0 / 0 / 0 / 0 |
| 4 | 2.3154 | 0.5620 | 1.8741 | 0 / 0 / 0 / 0 |
| 5 | 2.3154 | 0.5620 | 1.8741 | 0 / 0 / 0 / 0 |
| 6 | 2.3154 | 0.5620 | 1.8741 | 0 / 0 / 0 / 0 |
| 7 | 2.3154 | 0.5620 | 1.8741 | 0 / 0 / 0 / 0 |


Mode2 has158 camera and368 clipping poses per profile; other main cases33/47. All promoted plus main cases have no frozen-buffer mismatch, shared original-vertex mismatch, unexpected disappearance, source-edge-free residue or behind leak in these tests.32 sets of36 full-orbit poses cover yaw360°, pitch−45°/0°/+45°, fractional angles and near/offscreen cases across the three renderers and eight plus lighting variants. These are three completed native views per pose; they never supply FPS. They are observational tests, not a proof for arbitrary intersecting meshes or all possible poses.

Actual assembled6510 callbacks pass independent integer arithmetic checks:800 near U/V/Q cases; projective450 encode +450 sample +450 screen +450 span +450 edge, two zero-width span no-write checks and five invalid-depth faults. No Q8 geometry runtime symbols occur. py65 is used only for callback correctness, never speed.

## One change per gate

1. Separate byte-preserved1.13.0 baseline and native controls. Mode1 allocation/edge traversal enabled; first port kept50.125FPS but lost an edge at the near crossing. Corrected segment clipping preserved50.125FPS and removed the disappearance.
2. Mode2 output remains byte-identical to the baseline plus on the new fixture (49.072/41.191FPS). The different scene is not the historical1.13.0 camera benchmark.
3. Separate Mode3 placement, Mode4 native screen-Y, Mode5 outline and Mode6 adapters, each with own camera/clipping native logs. The prior plus selector rejected these modes, so no fictional pre-extension plus FPS is assigned; legacy/Q8 controls supply the baseline comparison above.
4. Mode6 attribute transport: before25.062/33.890FPS and32.909px maximum outside-surface error; first correction25.062/36.125FPS exposed one frozen failure from the Y index. The isolated Y restoration yields25.062/35.440FPS, no failure and1.4511px maximum outside-surface distance. Failed intermediates remain in the evidence ledger.
5. Mode7 affine attributes and common near8:12.531/31.891FPS. Then the projective carrier change was measured separately against affine-before above. Initial projective spans showed gray corruption and1.33929 camera FPS; clipping did not complete warm-up, so no usable clipping FPS. The isolated half-open empty-span correction yields the final5.834/26.417FPS and clean native images/UV oracle.
6. Mode7 Gouraud helper placement uses the guarded actual free RAM tail; initial lighting builds failed assembly RAM checks, hence no before FPS. Final lighting FPS are measured above. Unlit/flat and all other final PRGs remain byte-identical to the earlier qualified programs.

The external Git log, intermediate build/FPS/pose logs and final identity files retain this order. RAM/profile rejections are not emulated performance results. An early Q8 acquisition probe overlapped relocated code; it was corrected by sizing/repacking the unchanged Q8 blocks after instrumentation. Only the corrected controls/reference acquisitions are promoted.

## Limits and reproducibility

Plus:walkLite, normal160×100, high-basic-v2, NoFpsOverlay, no Ground plane; projective depth8–256WU, standard textures, LOD off. No new NTSC, audio-active or physical-hardware qualification. Preserve the complete SDK and install the toolchain externally. Source-only tests are in [TESTING](TESTING.md); external development commands:

```powershell
python -B tools/campaign.py --cases m7-perspective-camera m7-perspective-clipping --profiles legacy-plus --source repository --tag my-rebuild
python -B tools/run_checks.py --names m7-perspective-camera-legacy-plus-my-rebuild m7-perspective-clipping-legacy-plus-my-rebuild --tag my-native --poses
```

Use fresh names/directories; each native command and raw result is saved. Do not overwrite the qualified artifacts. The historical1.13.0 release/report remains unchanged and independently versioned.

The eight public default-clipping builds (Modes1–7 plus Mode7 perspective) also match the explicit near8/poly builds byte-for-byte. Official SDK and immutable baseline inventories both verify309/309 unchanged files.

## Stable delivery verification

All57 measured programs were freshly rebuilt from the stable SDK:16 legacy,25 legacy-plus and16 Q8. Every PRG is byte-identical to its native measured reference. All runtime implementation/configuration source bytes are unchanged. The separate release evidence directory is `3Dvibe64_Qualification_1.14.0`; its `reports/stable-identity-*.json`, build/assembly logs and programs are private QA, not ZIP assets. Therefore the native before/after FPS and stability evidence remains applicable without a new timing run for this documentation/package-only promotion. The clean-extraction public suite and final manifest/link checks are recorded in the retained delivery receipt; publication-only metadata checks passed separately.
