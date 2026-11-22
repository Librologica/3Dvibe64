# Release notes — 1.20.1

Stable source SDK with optimizations for compatible rendering paths.

- Modes 1 and 2 reduce wire-span setup, dirty-row addressing and near-plane projection work. Polygon paths reuse cached material ranges.
- Gouraud shading, polygon outlines and affine texture mapping reuse intermediate results and reduce work inside raster loops.
- Mode 8 improves ray traversal, profile caching, fine raster fills and projection arithmetic in compatible monolayer and multilayer renderers.
- Existing renderer defaults, Distance Fade, texture LOD and API limits remain in effect.

[Qualification](QUALIFICATION-1.20.1.en.md)

The source archive contains the engine, bilingual documentation and correctness tests. Demo assets, benchmark drivers, generated programs and raw local verification files are excluded.
