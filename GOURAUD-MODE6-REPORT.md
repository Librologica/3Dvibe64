# GraphicsMode 6 — Gouraud ordered-dithered for VIC-II

## Release identity

3Dvibe64 1.2.0 promotes the validated Gate 5 engine without engine edits.
Builder SHA-256:
`44B23B5DEF3A5B0D24E845AA355DF3F8DC65D00426B688253F811D97DB8B90A7`.
Only documentation, examples and test/package metadata are updated.
Mode 1–5 code generation remains frozen. No hybrid flat/Gouraud selector is included.

Mode 6 requires `-MemoryLayout high-basic-v2`; `stable` is explicitly rejected.
This is per-vertex lighting rendered through three VIC-II multicolor pigments,
not a continuous-color framebuffer. Geometry, depth sorting, clipping, materials,
Ground, cameras and double buffering retain the validated implementation.

## Smooth normals and shade vertices

Mesh property `"gouraud": { "creaseAngle": 60 }` accepts 0–180 degrees and defaults
to 60. Adjacent normals within the crease threshold are area-weighted and normalized
to Q6; hard creases use separate shade vertices. Smoothing changes lighting normals,
not geometry, face count, winding or silhouette.

- A cube at 0 or default 60 degrees keeps hard edges: 24 shade vertices.
- A cube at 180 degrees shares normals: 8 shade vertices, unchanged cube silhouette.
- The integer-quantized low-poly torus6x6 uses 180 in the smooth reference: 36 shade
  vertices. At default 60 some of its edges remain creases.

Exact-coordinate duplicate vertices are already canonicalized by the solid importer.
The duplicate-corner test checks 24 source corners resolving to 8 geometric and 8
shade vertices at 180 degrees. This release adds no geometry rewrite.

Runtime indices permit **at most 255 shade vertices**, counting expanded per-instance
state with `meshSourceSharing`. Overflow is a build error. Source geometry is shared;
transformed vertices and temporal shade state remain per instance.

## Lighting, materials and time

Q6 normals and object-space light vectors address eleven intensity tables producing
levels 0–32. After the first sample, temporal changes are limited to four levels per
rendered simulation tick. The existing 50 ST/s simulation contract is unchanged.

Compatible families: `gray`, `white`, `red`, `green`, `blue`, `yellow`, `cyan`,
`magenta`, `orange`, `brown` (0–9). They supply Dark/High/Highlight.
Reflectivity `satin`, `gloss`, `reflective`, `mirror` (0–3) adds 0, +2, +4, +6 to
the Mode 6 shade, saturated at 32.

`materialOverride`, `reflectivityOverride`, `colorOverride` and source-local
`faceOverrides` retain their semantics. With sharing, plain `material` is not an
instance override. Per-instance `faceOverrides` on reused sources remain unsupported.
`solidColor` with `shading:false` is an unlit pigment override, not dynamic flat shading.
Screen RAM/Color RAM retain VIC-II cell-level palette and ownership constraints.

## Clipping and rasterization

Convex triangles and native quads transport shade through near/camera-plane, screen
and Ground clipping using the same integer edge parameter as position. Internal
clipping fans retain interpolated shade. Geometry and shade edge walks remain separate;
rejected Edge Fusion work is not included.

Integer DDAs generate shade samples. The Bayer matrix stays screen-anchored:

```text
 0  8  2 10
12  4 14  6
 3 11  1  9
15  7 13  5
```

An exact 33 × 16 LUT selects position-shifted multicolor bits: Dark/High at levels
0–16 and High/Highlight at 17–32. Covered face pixels use 01, 10 or 11; 00 is background.
There is no temporal rotation of Bayer phases.

| Promoted component | Implementation |
|---|---|
| Gate 1 | Exact 528-byte Gouraud/Bayer LUT and compile-time specialized viewport clear |
| Gate 3 | Byte-oriented spans with exact scalar endpoint fallback |
| Gate 4 | Byte-seeded restoring division / accumulator remainder and exact fallback; no approximate reciprocal LUT |
| Gate 5 | Exact partial-byte aggregation preserving masked pixels and the DDA sequence |

Both physical rows, material composition and A/B buffers are preserved. No quality,
precision, polygon-count, resolution, sorting, clipping or timing reduction is used.
`wait_raster` is unchanged; accelerated CPU MHz do not change VIC-II PAL/NTSC timing.

## Memory and configurations

Shade data costs four corner indices per runtime face, seven bytes per runtime shade
vertex, range descriptors and scratch. Shade row arrays use 200 bytes; clipping adds
two 12-byte shade payload arrays where emitted. Intensity tables use 704 bytes plus
22 pointer bytes; the Gouraud/Bayer LUT uses 528 bytes. Code/data are specialized
by configuration and excluded from Modes 1–5 where unused.

The frozen torus/FPS build ends runtime at $8768; camera occupies $8800–$8B49,
raster $9000–$9BA7, and high code ends at $CC41. These are scene-specific observations,
not capacity guarantees. Ground configurations can approach $D000 closely: builder
segment-overlap checks remain authoritative.

Fixed/walkLite/walkFull, PAL/NTSC, normal/small, Ground, depth sorting, double buffering
and the FPS/text split remain supported. F toggles the complete header;
`-NoFpsOverlay` removes the split. The known isolated right-edge split-transition
pixel documented in the localized README remains unchanged. H remains Mode 4/5-only.

## Reproduction and tests

See `TESTING.md` for the clean-copy test runner. It retains frozen Mode 1–5 hash and
framebuffer contracts and provides self-contained LUT, span and division checks.
Host tests cover temporal levels, clipping, normals, duplicates and the 255 limit.
Emulator smoke tests cover PAL/NTSC × normal/small on x64sc, xscpu64 and Turbo6510.
Smoke tests are distinct from the paired framebuffer comparisons used in final
qualification. Raw qualification output and historical builders stay outside the SDK.

The exact Gate 5 torus/FPS scene is `examples/mode6-gouraud-torus-fps.json`;
its build command is in `examples/README.md`. Expected PRG SHA-256:
`F59587562E2CD78F7E28ACE58108274B88013A7DDC2A4F6949C393CD87844662`.
No PRG, generated ASM, screenshot or profiler output is distributed.
`MANIFEST.sha256` covers every permanent file except itself; its own hash accompanies
the ZIP in the release handoff.
