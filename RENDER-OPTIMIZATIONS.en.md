# Exact renderer optimizations — 1.14.0

## Legacy-plus in 1.14.0

Mode1–7 plus and Mode7 affine/perspective are promoted from the qualified development into this stable SDK. The near8, Q4 geometry, lighting A/B/C, RAM and camera constraints are in [LEGACY-PLUS](LEGACY-PLUS.en.md). The ordinary legacy Mode7 camera-plane `Mode4NearProfile clip` requirement below is not the plus profile: plus requires default/near8/poly. Fast texture sampling and LOD remain Q8-only. Results and regressions are in [native qualification](QUALIFICATION-1.14.0.en.md).

All new options are explicit. Legacy precision, standard texture quality,
precise lines, safe presentation and texture LOD off remain ordinary defaults.
No option silently enables Fast, skips rows, reduces resolution or changes LOD.
The allocator retains code guards and refuses combinations that do not fit.
There is no universal fastest preset: additional tests can cost more than they
save on a given scene. Historical Mode4 shading differences with camera-extremes
and q8-arithmetic are not promoted as qualified speedups.

## Builder options

Pass comma-separated names to `--engine-experiments` in work/q8/build.py or
`-EngineExperiments` in work/build-3Dvibe64.ps1. They are recorded in build.json.
Use `none` to disable them. `all` is a parser convenience, not a compatible preset.

| Option | Domain and exact behavior |
|---|---|
| camera-extremes | Mode7 mobile Q8: exact coefficient0/+1/-1 shortcut; other products keep the original path. Rejected outside Mode7. |
| zero-terms | Q8 polygon transform: skip exactly-zero terms, preserving fractional products, signs and signed24 carries. |
| degenerate-faces | Repeated-index source triangles only. Quads are retained because one half may remain visible. |
| live-attributes | Mode7 perspective standard: process only shader-declared X/S/V/W/Q channels; preserve Q lighting. Uniform/far texture paths retain their existing LOD output. |
| adapter-outcodes | Mode7 perspective: explicitly request public conservative outcodes even with geometry_adapter; missing hooks fail. |
| inside-planes | Q8 polygons: skip a screen-plane copy only when every vertex is inside that exact plane. Intersections retain full Q8 clipping. |
| bounded-divide | Mode7 perspective standard: prove numerator>>8<denominator before an8-step divide. Otherwise use original24/16, including zero-denominator fault. |
| packed-samples | Mode7 perspective standard: compose four original two-bit samples with six shifts. Sampling and interpolator calls are unchanged. |
| unrolled-advance | Unlit Mode7 perspective standard with rational carrier ABI: exact three-channel advancement, same errors/carries and X/Y preservation. Lit shaders are rejected. |

Existing q8-arithmetic, uv-texel, camera-table and visibility remain separately
experimental; Mode8 and normalized16 do not accept these Q8 additions.

```powershell
python -B work/q8/build.py --scene ../my-inputs/scene.json --out ../exact-build --mode 7 --camera auto --texture-precision perspective --texture-quality standard --engine-experiments inside-planes,bounded-divide,packed-samples
python -B work/build-gameplay.py --profile mixed-surfaces --project-source ../my-project --out ../mixed-build --flat-span-cache
```

`-FlatSpanCache` is the PowerShell gameplay equivalent. It requires a MAT-01
adapter with the standard `return surfaces.hooks(source, TABLE)` binding;
incompatible inputs fail explicitly. Direct adapters may call
`surfaces.hooks(source, table, optimize_flat=True)`. Flat spans write packed
palette-slot bytes and preserve partial edges/two physical rows. Texture and
Gouraud keep their shaders. It does not turn fixed pigments into lit materials.

## Live attributes

`build(...,face_attribute_masks=[...])` requires live-attributes and one byte
per runtime face. Bits X=1,S=2,V=4,W=8,Q=16; X is mandatory and S/V require W.
Q exists only in the lit shader. `surfaces.attribute_masks(table,
gouraud_channel='q')` maps texture/flat/Gouraud to31/1/17; `'s-w'` maps to15/1/11
for an adapter that already implements that scalar perspective shader. The
mask is a contract, not a shader implementation. Dynamic face changes must
update it, and shaders must never read a declared-dead channel.

## Adapter raster helpers

`work/q8/src/exact_raster.py` exposes:

- `bounded_divide(parts)`: add the exact divider block to standard perspective parts, no fixed address.
- `pack_four(samples)`: host two-bit composition, four integer codes0..3.
- `unrolled_advance(source,parts)`: unlit rational carrier emitter, allocator-managed code.
- `texture_page(texels)`: validate256 caller-supplied two-bit texels; returns unchanged bytes. Caller allocates/alines the page and binds its sampler. It is not a texture asset or an automatic lookup replacement.
- `inline_gouraud(source,sites=1)`: expand selected original DDA calls with unique local labels; same integer operations, more code/RAM. Incompatible DDA labels fail.
- `uniform_gouraud(patterns,bulk_entry='sp_solid',row_cache='sp_current_row',prefix='er_uniform')`: emit a span dispatcher over1..64 shade levels, four row bytes per level. Build verifies that matching endpoint bytes prove all intermediate bytes match. Caller validates runtime shade range and routes only compatible spans. Variable spans use the original Gouraud shader; the bulk target must satisfy the same edge ABI.

`extensions/gameplay/materials/static_patterns.py` provides `pattern(level,
low=0,high=1)` (four Bayer bytes, level0..16), `constant_interval(patterns,
start,end)`, host `FlatCache.assign(key,revision,level,low,high)` and
`invalidate(key)`. These prepare explicit native cache data; they do not install
runtime lighting hooks. Regenerate affected native cache entries whenever
geometry/material/light revisions change. `bulk_span(closed_edges=False)` emits
a packed Q8 Mode6 raster routine plus scratch/masks. Caller supplies a nonempty
0..159 span, `ptr0lo/hi`, `ptr1lo/hi`, `gouraud_init_span_pointers`, leftval,
rightval,yrow,gouraud_scan_x/end and tq_closed unless all edges are closed.
Set sp_current_row[0..3] before use. Both physical bitmap rows are written.

`shared_palette(source,immutable=True)` verifies homogeneous material_screen_bytes
and material_color_bytes, then removes only span claims; full-screen palette
initialization stays. Caller guarantees every runtime update keeps that palette.
If a material can change hardware colors, do not use it. Host helpers return
source/data; they do not auto-detect or silently rewrite arbitrary shaders.

## Conservative walls

`extensions/gameplay/visibility/wall_occlusion.py` provides an opt-in native
adapter emitter. `validate_quads(vertices,triangles,first_faces)` checks each
local-space variant: [a,b,c]/[a,c,d], four distinct vertices, axis-aligned vertical
rectangle, exactly two Y planes straddling zero. Then call
`attach(source,parts,face_count=...,first_faces=[...],draw_part=None,
opaque_vertical_contract=True,palette_indices=None)`. Runtime faces2..128, disjoint consecutive
triangle pairs1..64. With draw_part=None the standard draw label is in source;
otherwise pass its parts key. All emitted cache/code use the normal allocator.
No room counts, palette, fixed RAM, SID addresses or scene paths are embedded.

The adapter must guarantee opacity, convex full-height vertical walls, correct
source/runtime face mapping, upper positive/lower negative Y classification,
a camera between the two planes, preserved painter semantics and projection
ABI sx/sy/projdone. Do not use with transparent, moving nonconforming, split
height or arbitrary sloped walls. Validate every generated layout variant.
The kernel requires both triangles collected, every vertex in front of near,
strict actual bucket order and whole target bounds inside a5-logical-pixel
inset rectangle of one later-painted occluder. Partial, tied, uncertain and
near-clipped cases are kept. Transform/collection costs remain; this is not a
z-buffer or a general occlusion solver. Counters oc_frames/oc_culled_total are
16-bit; repeated exclusions are occurrences, not unique source walls.

## Qualification and migration

See [native qualification](QUALIFICATION-1.14.0.en.md), [testing](TESTING.md),
[external inputs](EXTERNAL-INPUTS.en.md) and [optional support](ADAPTER-SUPPORT.en.md).
Compare equal camera ticks and native complete-view FPS before selecting options
for another project. Existing build calls with no options keep renderer behavior;
SceneFile and gameplay project inputs are now always external and explicit.


Wall cache data cost: `2*face_count + 12*quad_count + 17` bytes, plus three emitted code blocks and their allocator guards. No hypothetical freed memory is counted. Historical referenceBuilds entries in PACKAGE-MANIFEST.json identify external regression inputs, not files distributed with the SDK.


## Adapter entry point

The following is glue for caller-owned geometry, not a shipped scene. `sdk`, `my_vertices`, `my_triangles`, `first_faces`, `my_scene_path` and `my_output` are explicit project inputs. Validate every generated layout, not only the initial one.

```python
import sys
sys.path.insert(0, str(sdk / 'extensions/gameplay/visibility'))
from wall_occlusion import validate_quads, attach

validate_quads(my_vertices, my_triangles, first_faces)
def adapt(source, parts, labels):
    return attach(source, parts,
                  face_count=labels['FACE_COUNT'],
                  first_faces=first_faces,
                  opaque_vertical_contract=True,
                  palette_indices=my_reachable_palette_entries)

builder.build(my_output, my_scene_path, mode=6,
              camera_auto=True, geometry_adapter=adapt,
              engine_experiments='inside-planes')
```
The geometry check alone does not prove opacity, camera limits, object/world transforms or shader compatibility. Assert the contract only after those adapter obligations are satisfied. Existing custom draw parts use the `draw_part` keyword.

FlatCache keys and revisions must be immutable/hashable; invalid types never reuse an existing entry.

Wall occlusion additionally requires a shared immutable VIC hardware palette. Both material palette tables are checked homogeneous at build time; the adapter must keep them unchanged at runtime. Mixed palette ownership is not qualified and is rejected.

`palette_indices=None` checks the entire material catalog. If the catalog contains unused palettes, pass a nonempty explicit list of every reachable palette entry, including material+reflectivity offsets, initialization and instance/color overrides. The adapter guarantees no other entry/color can become active. Only those entries are checked homogeneous; undeclared dynamic palette transitions are unsupported.

`static_patterns.native_cache(face_count,low=0,high=1,prefix='sf',row_cache='sp_current_row')` emits native generation-time cache code/data. Supports1..255 faces; data6*face_count+68bytes plus code/guards. `sf_assign`: A=level0..16,X=face, call only when generated/changed. `sf_load`: X=face, copies four cached bytes to the active span row cache; an unassigned face returns carry clear without changing it. `sf_invalidate`: X=face. Carry set means success; A/Y clobbered,X preserved. Initial entries are unassigned. Invalid face/level is rejected. Update only between completed views; the adapter handles fallback and geometry/material/light invalidation. No per-frame light calculation is installed.


## 1.14.0 application boundary

Legacy-plus Mode1–7 and Mode7 affine/perspective are stable within the [public plus profile](LEGACY-PLUS.en.md). The private Underworld port uses a different viewport, loader/RAM layout, culling and material/LOD/sampler optimizations; these are not public defaults or a new generic gameplay ABI. The reusable gameplay adapters retain their existing precision/profile restrictions. See [stable promotion scope](RELEASE-NOTES-1.14.0.en.md#distribution-and-private-application-boundary).
