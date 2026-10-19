# Release notes — 1.15.0

Stable source release prepared locally for GitHub, **not published**. Promoted from qualified1.15.0-dev2 with unchanged runtime. [Status/support](RELEASE-STATUS.en.md).

## Changes from1.14.0

- Exact Q4×Q10 products and divisions with proven fast paths and complete fallback.
- Byte-remainder edges with ninth-bit carry and a faster integer edge path; block bitmap writes, paired physical-row addressing and material-cache handling for disconnected intervals.
- Conservative vertex outcodes and compatible convex pair/fan adapters; mixed palettes, uncertain shapes and ineligible cases retain original triangles.
- Explicit native-material wire-line API and camera-Q4 vertex production directly into resident engine arrays.
- Optional lossless signed16 keyframe codec and explicit frozen-lighting with per-object invalidation.

New kernels/APIs are qualified only within the documented Mode4 legacy-plus profile. Ordinary Mode1–7 plus and other backends keep existing contracts. Defaults remain legacy,optimizations none,standard texture quality,precise lines,LOD off,safe presentation. `all` excludes wire,stream and frozen-lighting. No alternate scanlines or automatic precision/resolution/palette reduction. No demos or game content are distributed.

## Validation and performance

Qualified development measurements remain applicable because runtime,configuration,PRG bytes and target conditions are unchanged.127pixel-identical RGB poses;57identical legacy/plus/Q8 defaults; qualified arithmetic/API/codec callbacks. The wire fixture improves9.5988→12.2130FPS (+27.23%); dev2 ordinary renderer/clipping remain50.1245/47.6827FPS. These are named-fixture results, not shuttle FPS or universal speed promises. [Provenance/details](QUALIFICATION-1.15.0.en.md).

[Build](QUICKSTART.md) · [Exact options](EXACT-RENDER.en.md) · [API/memory](REUSABLE-RENDER.en.md) · [Public suite](TESTING.md). Source only; no online1.15.0 release page or download URL has been created.
