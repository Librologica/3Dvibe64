# Precision profiles — 1.5.0

1.9.0: explicit experimental `-Precision normalized16`, not Q8 with fewer bits.
Legacy stays default; Q8 perspective/fast/LOD remain unchanged.
See [scope and arithmetic](NORMALIZED16.en.md) and [qualification](NORMALIZED16-QUALIFICATION.md).

1.8.0: optional [hybrid line raster](LINE-RASTER.en.md) in Q8 Modes 1/2/5.
It preserves geometric precision, changing only endpoint raster quantization.
Legacy geometry and precise Q8 lines remain defaults. Safe presentation is now
default; historical PRG comparisons explicitly select legacy presentation.

Version 1.6.0 adds an independent optional texture setting: Q8 alone still uses
affine UV. `-TexturePrecision perspective` requires Mode 7 Q8 and its additional
bounded-depth contract. See [texture precision](TEXTURE-PRECISION.en.md).

## Default and recommendation

**Legacy is always the default.** Omitting `-Precision` and specifying
`-Precision legacy` use the same renderer and reference output as 1.4.0.
Q8 requires the explicit command-line option `-Precision q8`. Neither CPU speed
nor a field in scene JSON selects it automatically. Legacy is not deprecated.
Recommend legacy at **20 MHz and below**, and Q8 **above 20 MHz**; this is a
quality/cost recommendation, not a minimum hardware requirement or FPS guarantee.
Mode 8 is unchanged and does not accept Q8.

## What Q8 changes

Q8 retains fractional object angles and transformed coordinates, uses wider
projection and near/screen clipping, and passes screen fractions to Q2 raster
edges. It reduces snapping and fixes the qualified clipping discontinuities,
including near-tangent/offscreen edges and faces. Screen clipping retains Q8
precision until conversion to the existing quarter-pixel raster contract.
The visible resolution is not increased; there is no antialiasing or new color.
Lighting, normals, materials, reflectivity, fills and Mode 7 affine texture
sampling are not upgraded to a new precision model by this option.

Modes 1/2 retain wire/hidden wire, Mode 3 static solids, Mode 4 dynamic flat,
Mode 5 dynamic flat with outlines, Mode 6 Gouraud and Mode 7 affine textures
with their existing lighting. Mode 7 Gouraud requires compositor C.
Objects share the existing face-bucket painter; Q8 does not add a Z-buffer or
guarantee correct occlusion for intersecting solids.

## Qualified profile and strict refusals

- Mode 1-7; normal viewport, 160×100 logical pixels without text/FPS split.
- `walkLite`, `high-basic-v2`, `fast`, `extended-table`. These are selected inside
  the Q8 adapter; explicitly conflicting CLI options are rejected.
- One or two objects with disjoint mesh vertex/face ranges; up to 96 total
  runtime vertices, compiled scaled radius <=40 WU per object, 0 < scale <=1.
  These limits do not guarantee a fit: allocation still checks all RAM guards.
- No Ground, meshSourceSharing, scene timeline, small viewport or camera roll.
- Camera initial rotation must be `[0,0,0]`. Runtime yaw/pitch is supported.
  Scene camera must be walkLite; fixed/walkFull are rejected, not approximated.
- Coordinates must be finite and within the bounded camera/object domain
  +/-4095 WU. This outer check does not enlarge the SDK's narrower signed Q8
  object X/Y translation range or its original depth-validation rules.
- PAL or NTSC explicitly selected at build time; if omitted for Q8, PAL.
  Explicit `-VideoStandard auto` is rejected for Q8. Legacy defaults are unchanged.
- No public Q8 header/FPS overlay, soundtrack, runtime mode switch or extra
  diagnostic flags. Unsupported combinations fail rather than silently fall back.

`fixed` is a distinct legacy projection path, not merely a stationary walkLite.
Its far-depth tables can visibly quantize a cube. For a stationary precise view,
use Q8 with `-Q8Camera stationary`, not `-CameraMode fixed`.

## Build and camera

Dependencies: Python 3, PowerShell 7 and 64tass (`TASS64_EXE` or PATH); Pillow
also required when using PNG textures. py65 is only needed for optional tests.
Build from the SDK root, with a new output directory **outside** the SDK:

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -Precision q8 -GraphicsMode 4 -SceneFile examples/q8/two-objects-mode4.json -Q8Camera auto -VideoStandard pal -OutputDirectory ../q8-mode4-pal
```

`3Dvibe64.prg`, ASM, labels, memory map, build metadata and an isolated SDK work
copy are written there. Existing output directories are refused; nothing is
written into the distributed SDK. Use another folder with `-VideoStandard ntsc`.
Matching examples `two-objects-mode1.json` through `mode7.json` are included.
Keep `-GraphicsMode` consistent with the scene's `graphicsMode`.

| Q8Camera | Behavior |
|---|---|
| `stationary` (default) | walkLite projection with camera input disabled; objects still rotate |
| `interactive` | inherited walkLite controls: W/S forward/back, A/D strafe, Q/E down/up, cursors yaw/pitch; no roll |
| `auto` | smooth fractional yaw/pitch demonstration, controls disabled; 1,024 logical tick period |

Automatic motion advances on simulation ticks, not render frames. It preserves
the PAL/NTSC 50-logical-tick contract; acceleration raises possible frame rate,
not the intended movement speed. Interactive input retains legacy angular key
repeat; fractional automatic motion does not imply a new input implementation.

## Architecture and evidence

The public PowerShell entry dispatches before legacy scene generation. Q8 works
in its own output copy, prepares the qualified geometry data and uses
`work/q8/src/` for exact generation/placement. Existing legacy kernel generation
is untouched unless the opt-in is chosen. The preparation probe files are
internal dependencies, not a separate public precision profile.

The family checkpoint covered 280 numeric poses, 4,480 vertex checks, 3,840
clipped faces, 112 primary CPU-rendered views and 22 native paired frames.
Release tests additionally compare silent public builds against silent rebuilds
of that frozen source, test defaults/refusals and rerun release runtime checks.
See [testing](TESTING.md) and [release notes](RELEASE-NOTES-1.5.0.md).
No hardware test or new FPS guarantee is claimed. Legacy reference hashes are
retained; only version/source-package identities change with this release.
