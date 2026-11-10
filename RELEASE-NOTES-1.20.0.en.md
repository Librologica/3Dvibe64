# Release notes — 1.20.0

3Dvibe64 1.20.0 is a stable source release for graphics modes 1–8, with updated English and Italian documentation. Published on GitHub.

## Highlights

- Optional Distance Fade in modes 1–8, with 17 Bayer levels, configurable distance ranges and Q8 arithmetic. It defaults to off; mode 7 texture LOD remains independent.
- Exact rendering optimizations: shading/material work reuse, affine texture sampling, profile caching and per-plane fade-level reuse in the multilevel mode 8 backend. Strided Bayer fills and exact polygon distance arithmetic avoid repeated work; wire face-owner writes are corrected.
- AnimatedMesh for indexed pose clips and RuntimeScene for optional camera, visibility and simulation support, within the documented profiles and bounds.
- Complete guidance for APIs, external-input builds, memory and scene types where fade saves work or adds overhead.

Defaults and individual contract limits are retained. Not every geometry/feature combination fits C64 memory. The package contains sources, documentation and correctness tests; no demos, benchmark suite/drivers, music or compiled applications.

[Quick start](QUICKSTART.en.md) · [Complete index](DOCS.md) · [Distance Fade](DISTANCE-FADE.en.md) · [Qualification and limits](QUALIFICATION-1.20.0.en.md).

## Verification

Release source and correctness gates passed. Native VICE PAL Turbo6510 measurements at 1×, 20× and 64× are retained through exact runtime/program identity; coverage, repeats and blocked configurations remain explicit in the qualification ledger. This documentation revision does not change rendering or introduce new FPS runs. No new hardware or NTSC qualification is implied.
