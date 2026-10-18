# Release notes — 1.14.0

Stable engine source SDK promoted from the qualified `1.14.0-dev1` development. Legacy-plus now supports **Mode1–7**, including affine and perspective Mode7 textures with none, flat and Gouraud A/B/C lighting. Legacy remains the default; selecting `-Precision legacy-plus` is explicit. Published as the stable1.14.0 GitHub source distribution.

## Changes from 1.13.0

- Extend the former Mode2-only plus profile to source wire edges in Mode1, static/dynamic solids in Modes3–5, Gouraud in Mode6 and textures in Mode7.
- Preserve Q4 camera geometry, Q10 camera coefficients and 4096 yaw/pitch phases; no Q8 geometry transform, projection or clipping is linked into plus.
- Carry geometry, UV and shade attributes through near/screen clipping with coherent interpolation and rounding. Preserve original wire-edge ownership and each raster mode's screen-Y convention.
- Add bounded projective UW/VW/W carriers, exact texture DDAs/sampling and half-open empty-span handling. Mode7 Gouraud helpers use actual free RAM with assembly guards.
- Update the complete IT/EN manual catalogue, precision/support matrices, build instructions, qualification and package metadata. Older versioned reports remain historical.

The promotion itself changes no runtime implementation/configuration file in `work/` or `extensions/`: runtime, options and defaults match the qualified dev exactly. Existing legacy/Q8 control programs and the former Mode2 plus reference retain their qualified bytes. The new stable source checks and manifests describe the delivered package rather than the older 1.13 publication.

## Supported plus profile and build

**walkLite, normal160×100, high-basic-v2, -NoFpsOverlay, near8 polygon/screen clipping**. The public input position ABI has8 fraction bits, but internal plus geometry is Q4. Fine yaw/pitch phases must be written through the documented camera fields/helpers. Object matrices retain legacy Q6. Relative camera coordinates must stay in `[-1024,1024)`WU per axis; check `legacy_camera_fault`.

Mode7 perspective requires camera-forward depth **8–256WU inclusive**, `TextureQuality standard`, LOD off. `ps_fault` is sticky; invalid depth/denominator stops publication with a red border rather than falling back to affine. Fixed/walkFull, small viewport, roll, header/FPS split and Ground plane are outside the plus contract. Available capacity follows the actual assembly map; there is no universal scene-size guarantee. Mode8 and Normalized16 keep their separate contracts.

Install Python3, PowerShell7 and64tass externally; set `TASS64_EXE` if needed. Pillow is optional for PNG import. Copy the **entire SDK** to a fresh sibling work directory, and provide your own external scene/assets:

```powershell
Copy-Item -LiteralPath . -Destination ../my-build-sdk -Recurse
pwsh -NoProfile -File ../my-build-sdk/work/build-3Dvibe64.ps1 -SceneFile ../my-inputs/scene7.json -Precision legacy-plus -GraphicsMode 7 -TexturePrecision perspective -CameraMode walkLite -CameraViewport normal -MemoryLayout high-basic-v2 -Quality fast -Projection extended-table -VideoStandard pal -FramePresentation safe -NoFpsOverlay -SkipCmdUpdate
```

The scene must declare compatible `graphicsMode:7` and walkLite camera. Near/poly defaults are selected by plus. Use `-TexturePrecision affine` for affine Mode7; omit texture precision in Modes1–6. Ordinary legacy/plus writes ASM/PRG into the working copy's `work/` and rejects `-OutputDirectory`. Q8/Normalized16/Mode8 have separate external-output adapters. Diagnostic labels/maps require an explicit assembler call. See [full plus contract](LEGACY-PLUS.en.md), [camera ABI](CAMERA-ROTATION.en.md), [external inputs](EXTERNAL-INPUTS.en.md) and [support boundaries](ADAPTER-SUPPORT.en.md).

## Native FPS and stability

Results are reused only for programs freshly rebuilt byte-identically from the stable runtime sources. **VICE Turbo6510 MOS8565, PAL×64, safe, Colodore/filter0, silent**, normal160×100. Warm-up128 simulation events, approximately2.56–2.70 emulated seconds, followed by a complete2048-tick camera/clipping route of approximately40.8 emulated seconds. Count only new complete views; the presentation trace agrees with the native counter. Warp and host time are excluded. No stationary phase; clipping includes empty/fully clipped phases. JSON retains individual hashes, exact commands, durations, counters, p95/worst intervals and per-window results.

| Fixture / mode | Legacy FPS camera / clip | Plus FPS camera / clip | Q8 FPS camera / clip |
|---|---:|---:|---:|
|48-vertex torus / Mode1|50.125 / 50.125|50.125 / 50.125|16.708 / 50.125|
|48-vertex torus / Mode2|50.125 / 41.093|49.072 / 41.191|12.531 / 37.177|
|48-vertex torus / Mode3|50.125 / 46.802|50.125 / 47.609|21.401 / 47.016|
|48-vertex torus / Mode4|50.125 / 46.802|25.331 / 47.536|16.708 / 46.894|
|48-vertex torus / Mode5|25.062 / 46.092|25.062 / 47.047|16.708 / 41.314|
|48-vertex torus / Mode6|25.062 / 34.877|25.062 / 35.440|16.708 / 34.845|
|48-vertex torus / Mode7 affine|12.531 / 30.310|12.531 / 31.891|7.196 / 29.904|
|24-vertex tilted torus / Mode7 perspective|16.708 / 30.310 (affine)|5.834 / 26.417|3.948 / 25.307|

The torus is the camera fixture; clipping uses adjacent double-sided triangles. Near volumes differ: plus8WU, Q8 1WU; legacy depends on mode. Thus clipping FPS are contextual controls, not equal-volume backend timing. Plus affine on the matched24-vertex fixture measures16.480/31.891FPS. Plus perspective p95/worst: camera179.553/199.503ms; clipping219.453/758.112ms. Mode4 camera regresses versus legacy. The projective flat-light fixture is slower than Q8,6.780 versus8.273FPS. All eight plus lighting variants and full mode interval tables are in the [qualification](QUALIFICATION-1.14.0.en.md).

Promoted native poses show no frozen-buffer mismatch, shared-vertex disagreement, unexpected disappearance or behind-near residue. Thirty-two36-pose orbit sets include full yaw and pitch−45°/0°/+45°. On the projective UV plane,212,505 robust interior samples have zero wrong/missing texels against an independent oracle. Finite Q4/Q2 quantization, nearest sampling and painter-order limits remain; these tests do not prove arbitrary-scene correctness. No new NTSC, Linux, music-active or physical-hardware qualification is claimed.

## Distribution and private application boundary

The source ZIP contains engine/build sources, reusable bounded gameplay modules, synthetic contract checks, documentation, licenses and manifests. It contains **no demos or examples**, scene/camera projects, characters, UI, artwork, SID/audio/video, compiled PRG/disk images, emulators, dependency environments or raw captures. Engine assembly templates and the implementation font remain reusable source inputs. Raw evidence and test inputs stay in separate private qualification directories.

The latest Underworld work remains an application port. Its96×60 viewport, banked loader/RAM layout, culling correction, material/LOD specialization and paired-UV/divider optimizations are **not promoted into this generic SDK**. The private5.247413FPS result and22.5% recovery do not describe the public engine. Existing gameplay adapters remain bounded Q8-oriented adapters; ordinary plus support does not make them directly compatible. A public generalization needs its own all-mode/shader/RAM qualification. No Underworld generator or asset is packaged.

Run `python -B scripts/run_release_tests.py` from a clean extraction, with dependencies installed. Checks run in temporary copies and verify all current IT/EN links and version/package contracts. See [testing](TESTING.md) and [structured qualification](QUALIFICATION-1.14.0.json). Previous release/dev directories, tags/assets and frozen demos remain intact; this publication creates only the new v1.14.0 tag/release.

Software: PolyForm Noncommercial1.0.0. Documentation: CC BY-NC4.0. Attribution: librologica.digital.
