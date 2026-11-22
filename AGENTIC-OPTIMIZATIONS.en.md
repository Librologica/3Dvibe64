# Renderer optimizations and performance — 1.20.1

Unpublished development SDK. [Release notes](RELEASE-NOTES-1.20.1.en.md) · [Qualification](QUALIFICATION-1.20.1.en.md).

## Optimized paths

Automatic optimizations select only code shapes and profiles whose required conditions are verified. Unrecognized callers retain general paths. Selection never depends on a scene, demo or benchmark name.

| Area | Contract and optimization |
|---|---|
|Rotation and projection|Exact shared Q10 products, grouped/bounded division and constant-focal specialization with documented domains and fallbacks.|
|Solid and material spans|Exact partial masks, cell-row reuse, indexed stores and block writes for long interiors.|
|Wire and outlines|Adjacent-row cursors only after layout proof; outline destination selection retains clipping and connected edges.|
|Gouraud|Coherent Bayer byte interpolation, material reuse and exact quotient/remainder edge stepping.|
|Affine textures|Horner packing, coherent UVs, shared stepping and stable-light-band sampling; transitions and partial bytes retain complete paths.|
|Multilevel Mode8|Second-chance profile cache, shared zero profile, plane ratios and per-view fade-level reuse.|
|Distance Fade|Private mask dispatch, strided Bayer writes and exact polygon rejection; texture LOD remains independent.|

Precision, clipping, palette, resolution and quality are not reduced to improve a result. RAM windows and guards continue to bound supported profiles. Optional [exact rendering](EXACT-RENDER.en.md), [reusable rendering](REUSABLE-RENDER.en.md) and [sphere](CIRCLE-SPHERES.en.md) APIs retain separate contracts and are not enabled implicitly.

## Reading performance results

The general score is not an FPS average. The historical series retains 1.15.0=100; 1.20.0 retains 137.505630 as an inherited reconstructed estimate, with canonical historical calculation still blocked. The extended series remains separate, with its frozen reference identified in the [ledger](QUALIFICATION-1.20.1.json). Anchors, weights and workloads are unchanged.

Cost depends on the scene: line length/clipping for wire; spans, cells and overdraw for solid/flat; perimeter work for outlines; edge/shade interpolation for Gouraud; covered pixels and UV/light transitions for textures; surface profiles/events for multilevel maps. These guide authoring choices; measure each project with its own PRG and route. For fade, see [scene types and CPU budgets](DISTANCE-FADE.en.md#when-distance-fade-helps).

Uniform acceleration is not guaranteed. Deterministic repetition is not statistical significance. [Native protocol and coverage](TESTING.en.md).
