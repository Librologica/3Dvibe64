# Agentic renderer optimizations — 1.15.1

Stable1.15.1 promotes delivered agentic17 without changing renderer/public API
source bytes. These automatic passes are selected only for proven source shapes
and supported precision/profile; they are not `EngineExperiments` or the optional
Mode4 `LegacyPlusOptimizations` flag. Unknown callers/layouts retain original
fallbacks. No benchmark IDs, demo identity or scene-name recognition is used.

| Area | Preserved contract and optimization |
|---|---|
|Rotation/projection|Exact shared Q10 camera products, grouped/bounded division and constant-focal paths with original domain/fallback.|
|Solid/material spans|Exact partial masks, cell-row material reuse and indexed material stores; long interiors share a descending unrolled writer.|
|Wire|Adjacent physical-row cursor only after proving row1=row0+1 from both emitted tables; unknown layouts keep the original writer.|
|Mode5|Outline destination selected at contour entry/exit; connected edges and final clipping unchanged.|
|Mode6|Coherent Bayer byte handling, exact material reuse and quotient/remainder edge-X stepping; original shade samples retained.|
|Mode7-C affine|Exact Horner packing, coherent UV constants, binary quotient setup, fused/shared edges, carry-biased UV errors and stable-light-band inline sampling. Dither transitions and partial bytes retain full paths.|
|Mode8 multi|Per-pose plane unit-ratio cache; mono backends unchanged. Out-of-range planes use original division.|

Allocator windows, guard32, budget60000, camera priority and actual parent
fallbacks stay unchanged. Extra code can select a different valid placement or
unroll tier; there is no promise of uniform acceleration. Clipping, precision,
rounding, lighting, palette, viewport, textures, LOD and workload are unchanged.
Material pointers are private volatile scratch only for recognized engine
callers; unknown callers retain the old helper. They are not a new public ABI.

Long-span jump tables use62 allocated bytes; stable sampler palette uses4.
Mode5/6 can use2 additional transient data-stack bytes. Mode8 adds485 data bytes
at55c0..57a4 and85 helper-code bytes at57a5..57f9, before font5800; its new helper
uses2 return-stack bytes. [Current map memory](MODE8-MEMORY.en.md) documents guards.

## Optional circle/sphere API

`-SphereRenderer circles` is a separate opt-in, supported only for Mode4/6
legacy-plus, walkLite, normal, high-basic-v2, NoFpsOverlay. Default `none` emits
no extra code/RAM. It draws screen-aligned circular impostors, not volumetric
sphere/near intersections; callers own painter order, materials and lighting.
Projected radius max63 logical pixels. [Full API](CIRCLE-SPHERES.en.md).

## Reading performance results

Fixed index1.15.0=100:117.647645 overall,117.490903 at1×,117.407532 at20×,
118.045521 at64×. Equal weights for8 modes/3 speeds; geometric50/50 FPS and
inverse native render time;12 fixed cases/36 cells. This is not an FPS average.
Mode scores vs stable are +11.88%,+2.49%,+12.29%,+13.69%,+18.91%,+51.15%,+27.24%,
+9.62% for modes1..8 respectively. Small scene-dependent results are descriptive,
not statistical significance claims. Repetition is deterministic.

Use less overdraw and fewer clipped/visible spans, not only fewer objects.
Wire cost tracks line length/clipping; solid/flat cost tracks span/cell count;
outlined fill adds perimeter work; Gouraud adds edge/shade interpolation; texture
cost tracks covered pixels and UV/light transitions; multi-map cost tracks
surface profiles/events and plane reuse. These are authoring hypotheses from
the independent agentic16 study, not automatic guarantees for a new game.
Measure your delivered PRG with targeted benchmarks and preserve image checks.

[Qualification](QUALIFICATION-1.15.1.en.md) retains Mode7/1× policy, validation4/1×
short-window diagnosis and all raw basket values. No new Linux/NTSC/hardware claim.
