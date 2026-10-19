# Exact rendering optimizations — 1.15.0

> Stable1.15.0 source SDK prepared locally; not published online. [Status and support](RELEASE-STATUS.en.md).

Stable1.15.0 features promoted from qualified1.15.0-dev2 with unchanged runtime. Prepared locally for GitHub, not published. Legacy/Q8 and ordinary plus builds without this selector retain their previous contracts. No demos, scenes, programs, media or native captures are packaged.

## Selection and scope

`-LegacyPlusOptimizations none` is the default. The new kernels currently require `-Precision legacy-plus -GraphicsMode 4`, walkLite, normal160×100, high-basic-v2, NoFpsOverlay and the existing Q4 near8/poly clipping profile. Other modes and Q8 are not silently substituted. Options are unique comma-separated names; `all` expands to the six exact options, including the extension below and **does not include frozen lighting**. Unsupported combinations, malformed names and insufficient RAM fail the build. Every build needs a fresh complete SDK copy.

| Option | Native behavior |
|---|---|
| arithmetic | Exact quarter-square unsigned partial products replace serial Q10 products; exact0/+1/−1 shortcuts. The existing sign restoration and symmetric rounding remain. A proven8bit quotient uses8 division iterations; larger quotients and zero divisors retain the original16bit loop and remainder. Projection focal products remain exact. |
| edges | Byte divisor/remainder row recurrence when the divisor fits8bits; the carry is the ninth sum bit. Full16bit coordinate/step and original wide-divisor fallback remain. |
| spans | Existing material-cell span cache plus unrolled interior byte writes and paired physical-row addressing. The generator proves row adjacency/evenness and8byte X offsets. First/last masks, both buffers and the long-span fallback remain. No row is omitted. |
| outcodes | Classify each freshly projected original vertex once using the original four clipper predicates; reuse those bits for source-face rejection/inside tests. Near/synthetic intersections still use the complete Q4 clipper. Never retain these codes across views. |
| convex | Merge uniform solid clipped fans only after strict all-points/edge convexity, a Y-extreme fan anchor and fill-kernel checks. Keep every original triangle edge, including both diagonal directions. Patterns, uncertain geometry, degeneracy and unsupported cases retain the original fan. Also exports the explicit pair-bounds adapter below. |
| integer-edges | Integer polygon edge tracing retains the ninth sum bit in carry; native coordinates and original shared-wire fallback remain. |
| frozen-lighting | **Appearance option**, separate from exact optimizations. Prime all non-fixed-color faces of each nonshared object once at its first active pose, then retain those shades. Invisible objects initialize when first active. Dynamic lighting no longer follows object/light motion until invalidated. Fixed pigments remain unchanged. Requires scene objects and dynamic-light infrastructure. |

Coordinates remain signed16 Q4, rotation coefficients remain Q10; no Q8 backend, resolution/LOD reduction, alternating scanlines or changed palette is installed. Vertex transformation/projection is already shared per view by the ordinary renderer and is reused, not duplicated as a new cache. Scene-specific motion, route generation, mesh simplification and camera tracking are outside this SDK change.

```powershell
pwsh -NoProfile -File ./work/build-3Dvibe64.ps1 -SceneFile ../my-project/scene.json -Precision legacy-plus -GraphicsMode 4 -CameraMode walkLite -CameraViewport normal -MemoryLayout high-basic-v2 -NoFpsOverlay -NoCameraRuntimeControls -LegacyPlusOptimizations arithmetic,edges,spans,outcodes,convex
```

Use the ordinary argument spelling `-GraphicsMode 4` when composing scripts. Option names and every native kernel are recorded in the generated ASM and the adjacent `.exact-render.json` before allocation. Additional code/data consumes real64KB RAM: the existing bounded allocator/assembler checks remain authoritative. `all` is a testable selection, not a promise that every extra test helps every scene.

## Explicit opaque triangle-pair adapter

`er_try_pair_bounds` consumes a quad already prepared by the native loader: `loaded_face_vertex_count=4`, native `vx0..vx3`, `vxq2_*`, `vyq2_*`, near/screen flags. Caller guarantees opaque triangles `(0,1,2)` and `(0,2,3)` with identical material/fill, contiguous actual painter order and no intervening surface. The kernel verifies native eligibility, viewport bounds and strict convexity, then combines the four outer edges and both diagonal directions. It writes bounds only, no pixels and no face tables. Carry set means valid bounds ready for the caller's single uniform fill; carry clear requires rebuilding/drawing both original triangles. A failed call can change scratch/bounds, so they must be rebuilt. An ordinary source quad keeps its original coverage; this adapter is never automatically applied to it. Caller-owned streamed vertices can use the existing native projection arrays and outcode producer after each update.

## Frozen-lighting invalidation

`er_light_invalidate`: X=object index, call between complete views after a geometry/material/light change. Carry set means its cache was invalidated; an invalid index returns carry clear. The next active pass recaptures that object's shades. First-active-pose initialization and initial shade hysteresis follow the native engine; this is a fixed-color style option rather than an equivalence claim for moving lights. Shared-source instances are rejected for this option.

## Verification and promotion

[Qualification](QUALIFICATION-1.15.0.en.md) separates retained native FPS from mathematical/callback checks and inherited defaults. Use identical inputs, target, warm-up and route for before/after comparisons. Test complete images and material cells, clipping/near, shared vertices, degenerate/self-crossing panels, signed rounding, wide divisors, byte carries and page crossings. Prefer arithmetic first on CPU-bound scenes; PAL can cap complete visible views near50.125/s. Stable promotion is complete locally; nothing has been uploaded or published online.

Automatic clipped-fan merging additionally requires a single active material/reflectivity palette, no fixed face-color table and no VIC cell-ownership policy. Mixed-palette faces keep the original fan; the explicit pair-bounds API remains available under its caller contract. The material interval cache forgets disconnected cell intervals instead of filling or caching their gaps.

## Reusable extensions

`all` also includes `integer-edges`. The `wire` and `stream` APIs are excluded from `all` and require explicit caller integration; `stream` requires `outcodes`. Compact motion data is a separate module. See [reusable rendering and data](REUSABLE-RENDER.en.md) for ABI, limits and usage.
