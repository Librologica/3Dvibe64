# 3Dvibe64 1.10.2 — stable local release

2026-10-14. Promoted from qualified dev3 runtime `799be44544933aa759111748b9dc68accaab5da7` and the definitive
report correction. Local preparation only; no GitHub publication. The release
commit is recorded in the separate delivery/evidence manifest. Earlier stable
releases and frozen demos remain intact.

## Changes from stable 1.10.1

- Mode7 fast reuses perspective block state and skips redundant scalar carrier
  advancement. This optimization originated in dev1; it is retained in fast
  even with `EngineExperiments none`. It preserves the existing fast profile.
- Four optional Q8 generator improvements, kept under the existing
  `EngineExperiments` name: exact `q8-arithmetic`; lit standard paired sampler
  `uv-texel` specialization by texture repeat; 2048-byte mobile `camera-table`;
  conservative offscreen-volume `visibility` and exact same-object opaque
  duplicate-face removal in supported modes. No new flag or backend is added.
- Mode8 uses the qualified post-maintenance bitmap backend. Regions/rays/chars
  and combinations are retired and rejected, including Mode8 `all`. Ordinary
  selection and `none` remain accepted. Validation, navigation, coincident
  waypoints, provenance, UI, palette, double buffers and memory guards remain.
  The known adaptive approximation diagnostic remains independent.
- Host native qualification and the public runner explicitly reject optimized
  Python (-O/-OO/PYTHONOPTIMIZE), including direct native.run. The corrected
  external report generator separates stock/Turbo, standards, profiles and
  animations and rejects missing/ambiguous acquisitions.

All runtime/generator bytes, examples, defaults and supported option contracts
are identical to qualified dev3. Legacy geometry remains default; Q8 requires
explicit selection, standard textures and precise lines remain default, LOD is
off and presentation is safe. Normalized16 retains its separate experimental
contract; stable SDK promotion does not extend its qualification.

## Native evidence — Turbo6510 ×64

| Scenario / options | PAL FPS | NTSC FPS |
|---|---:|---:|
| Mode4 public / none | 30.186113 | 31.020935 |
| Mode4 public / q8-arithmetic | 36.256752 | 33.873753 |
| Mode4 public / q8-arithmetic,camera-table | 39.737623 | 35.009341 |
| Mode4 public / q8-arithmetic,camera-table,visibility | 38.484510 | 34.233818 |
| Mode4 sparse mobile / none | 20.523215 | 20.135911 |
| Mode4 sparse mobile / q8-arithmetic,camera-table,visibility | 25.090118 | 29.885347 |
| Mode7 standard / none | 3.091013 | 3.212883 |
| Mode7 standard / q8-arithmetic,uv-texel | 3.703647 | 3.822222 |
| Mode7 fast / 1.10.1 pre-dev1 baseline | 6.906048 | 7.228986 |
| Mode7 fast / inherited block state | 8.047774 | 8.364574 |

## Native evidence — stock 6510 ×1

| Scenario / options | PAL FPS | NTSC FPS |
|---|---:|---:|
| Mode4 public / none | 0.649958 | 0.672203 |
| Mode4 public / q8-arithmetic,camera-table,visibility | 0.749952 | 0.766645 |
| Mode4 sparse mobile / none | 0.366643 | 0.377767 |
| Mode4 sparse mobile / q8-arithmetic,camera-table,visibility | 0.483302 | 0.494430 |
| Mode7 standard / none | 0.044442 | 0.049999 |
| Mode7 standard / q8-arithmetic,uv-texel | 0.061107 | 0.061109 |
| Mode7 fast / 1.10.1 pre-dev1 baseline | 0.116666 | 0.116653 |
| Mode7 fast / inherited block state | 0.133332 | 0.141650 |

No stock AC or isolated arithmetic measurement is inferred from ×64. Standard
Mode7 stock has very few views (PAL none 8, A+UV 11); sample sizes and p95/worst
intervals remain in the proof JSON/CSV. Stock and accelerated FPS are never
combined. The historical dev2 sparse camera was stationary; it is separate
from this mobile sparse matrix. Public Mode7 uses texture repeat2×2.

Public PAL AC beats ACV: 39.737623 versus 38.484510 FPS. `all` requests the four
compatible Q8 flags and retains compatibility errors; it does not guarantee
the fastest build and is not valid for every profile. Camera tables cost 2048
bytes, rebuilding when coefficients change. Visibility can cost time when all
objects are visible. Actual memory-capacity and numeric-domain guards remain.
Public PAL none→AC rendering is **22.359 → 18.732 ms**, presentation wait
**10.750 → 6.412 ms**; FPS also includes other work and video presentation. These are
distinct measures, not instruction replay or host-time speed estimates.

Fast gains use the isolated pre-dev1 module from official 1.10.1 commit
`7b27fd8a2f38a4dee13ee5eecf950a27b4f84a03`, not current `none`, which already
contains the optimization. Standard-versus-fast changes the visual profile:
fast retains its declared block/row reconstruction tradeoffs. Fast requires
Q8 perspective and Gouraud C; uv-texel requires the supported standard lit
paired sampler and is rejected with fast/unlit. No image-quality reduction is
presented as a new 1.10.2 performance optimization.

## Commands and preserved limits

```powershell
# Mode4, public moving camera: arithmetic + camera tables
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 4 -Precision q8 -Q8Camera auto -SceneFile examples/q8/two-objects-mode4.json -EngineExperiments q8-arithmetic,camera-table -VideoStandard pal -OutputDirectory ../mode4-ac
# Mode7 standard perspective, repeat2x2, Gouraud C
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 7 -Precision q8 -SceneFile examples/mode7-perspective-cube.json -EngineExperiments q8-arithmetic,uv-texel -VideoStandard pal -OutputDirectory ../mode7-uv
# Fast is a separately selected visual profile; uv-texel is incompatible
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 7 -Precision q8 -TexturePrecision perspective -TextureQuality fast -SceneFile examples/mode7-fast-cube.json -EngineExperiments none -VideoStandard pal -OutputDirectory ../mode7-fast
# Mode8 remains ordinary bitmap
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile examples/mode8/two-levels.json -Mode8Run auto -EngineExperiments none -OutputDirectory ../mode8
```


Performance figures reuse verified unprofiled native PRGs. PAL/NTSC are
separate: warm-up 101/120 refreshes (~2 seconds), ×64 measured approximately
35.911/36.105 emulated seconds; stock Mode4/standard 180 seconds, fast 120
seconds, using the actual stopwatch interval after warm-up. The measured
programs are silent, normal viewport, safe presentation, precise lines,
filter0 and no overlay. The fork counter is maincpu machine clocks, not CPU
instructions or Turbo CPU cycles; PAL985248/NTSC1022727Hz. Only newly complete
presented views count; duplicate refreshes, warp and host elapsed time do not.
Render, wait and remaining work have explicit sample/window accounting.

Mode8 full two-levels bitmap stock retains PAL3.113291/NTSC3.218422 FPS,
p95558.610/534.886 ms, worst798.013/768.893 ms, after 101/120 warm-up refreshes
and 179.553/180.523 measured emulated seconds. The historical 3.2 FPS figure
belongs to another qualification window.

The full dev3 suite has 28 documented gates. Final versioned/extracted package
checks and regenerated PRG identities are recorded in the release evidence;
unchanged gates may be inherited only with verified source identity. The 17
report regressions remain separate. Native timing, diagnostic profiles,
paired-pose image correctness and historical data have separate identities.
96 retained acquisitions were rechecked in the report correction. Historical
dev1/dev2 captures lack a contemporaneous emulator executable hash: the gap
remains explicit, while PRG, options and traces are verified. Fresh dev3
isolated-fast data have recorded executable identity. No missing result is
interpolated or attributed to another configuration.

Windows/VICE is qualified for the named profiles; Linux and physical hardware
are untested. The known Mode8 adaptive approximation limit remains. No general
occlusion solver, portal compiler or new performance experiment is included.
The withdrawn external prototype and retired Mode8 experiments remain in the
separate history archive. The source ZIP contains the normal SDK, guides,
examples and tests; raw traces, generated PRGs, demos, videos and emulators are
kept in the separate evidence archive or previous frozen folders.
