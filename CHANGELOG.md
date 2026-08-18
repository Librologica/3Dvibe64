# Changelog

## 1.1.2 — 2026-08-18

Fixes runtime `F` toggling for the DEV7 Generic Text/FPS split. Bitmap-only frames
now select the VIC bank, Screen RAM and bitmap pointer from the displayed buffer;
the compact charset is cleared and rebuilt using a length derived from the emitted
glyph count, eliminating raw glyph pixels without a fixed 96-byte assumption. `F`
remains backward-compatible and toggles the complete Generic Text/FPS header.

Shared Mode 4/5 instances now keep the draw-time material path whenever an
instance uses `materialOverride`, so different shared instances retain their
documented material families in the actual framebuffer. The equivalent
`reflectivityOverride` path is retained independently. Runtime framebuffer
coverage now checks red/green/blue shared cubes in both Mode 4 and Mode 5; no
projection, clipping, culling or raster-timing changes are included.

High-basic-v2 builds with mobile cameras now structurally relocate the contiguous
Camera Control & Navigation block to the relocated segment ($9B80), preventing
low-segment overflow in dense WalkFull configurations while preserving full runtime
margins and zero per-frame cycle overhead.

## 1.1.1 — 2026-08-15

Consolidates the validated DEV7 same-bank split-screen path into the canonical
builder. The optional text display reserves three character rows above the 3D
body, supports a compact Generic Text string on both Screen RAM buffers, and
keeps the FPS counter double-buffered. Material application preserves the first
120 screen bytes; the final raster switch uses `$4A`/`$4B` timing. The DEV7.1
mapping correction adds `$FF` termination and the correct compact indices for
the supported Generic Text glyphs. Builds made with `-NoFpsOverlay` retain the
1.1.0 binaries byte for byte. Non-engine development material is excluded.

## 1.1.0 — 2026-08-08

Prepares 3Dvibe64 for public source distribution on GitHub without changing the
engine builder, generated runtime, JSON API, reference PRGs, or framebuffer
signatures. The release adds complete Italian and English assembly-programmer
guides and complete Italian and English Codex-assisted vibe-coding manuals.

Software, builder code, scripts, JSON examples, validation material, and
generated engine code are now distributed for noncommercial purposes under the
PolyForm Noncommercial License 1.0.0. Documentation is distributed under
Creative Commons Attribution-NonCommercial 4.0 International. Copyright and
required attribution identify librologica.digital as author and licensor.

GitHub repository hygiene is defined by `.gitignore` and `.gitattributes`, while
`CONTRIBUTING.md` and `SECURITY.md` document contribution licensing, release
verification, and private vulnerability reporting. The package contract now
covers 44 permanent files. All text files use deterministic LF line endings,
the builder remains byte-identical to 1.0.1, and release hashes are refreshed.

## 1.0.1 — 2026-08-04

Synchronizes the public package version and release metadata, refreshes release
documentation, and records the final Ground validation status. Ground
projection, polygon-integrity, and roll-aware rendering fixes are retained
unchanged. Rendering pipelines, JSON 1.0 compatibility, and runtime behavior
are unchanged; the source package remains 34 permanent files.

## Ground plane roll-aware rendering

The visual Ground plane now derives its clipped viewport boundary from the same
roll-aware plane equation used by Ground clipping and occlusion. Modes 3–5 use
the shared masked-span path for positive, negative, and vertical horizons, with
the filled semiplane selected consistently on either side of the plane. Mode 2
remains line-only. The Ground projection and polygon-integrity fixes are
preserved, and a deterministic 32-frame multi-roll runtime regression covers
roll 0, 32, 64, and 224 in Modes 3–5.

## Ground polygon integrity

Ground-clipped polygons no longer overwrite the cached projected coordinates of
the source vertex used as temporary projection storage. The cache is preserved
while each generated vertex keeps its own camera-space depth, so subsequent
faces retain their original projected vertices. This preserves the clipped
polygon's vertex order and count for Mode 4/5 rasterization; Mode 5 continues
to outline the final post-clipping polygon. The runtime framebuffer regression
uses a deterministic multi-instance crossing pose in both affected modes.

## 1.0.0 — Public stable release

3Dvibe64 1.0 is the first stable public source SDK. It packages the frozen scene
builder, engine source generation, documentation, executable JSON examples, and
contract tests. No precompiled PRG is distributed: reference programs are generated
locally in temporary directories during validation.

The shared unsigned-divide helper is now emitted through a single ownership gate.
Ground `plane` and camera-plane `clip` can therefore be compiled together with fixed
or mobile cameras without a duplicate `div16u` label. Division mathematics, call
sites, clipping, projection, culling, rasterization, and visual output are unchanged.

Ground-clipped faces are now reprojected with each `clip_a` vertex's own camera-space
depth. The fixed depth 1 remains reserved for true camera-plane intersections. This
removes the stretched triangles and ribbons previously produced by Ground crossings
in GraphicsMode 4 and 5, without changing clipping mathematics, painter ordering,
culling, rasterization, or the Mode 5 outline. A deterministic 32-frame VICE runtime
contract now hashes the generated bitmap and screen RAM for both affected modes.

The public API includes GraphicsMode 1–5; fixed, walkLite, and walkFull cameras;
normal and small viewports; stable and high-basic-v2 layouts; simple and plane
Ground profiles; the `default`, `late`, and `clip` near profiles for Modes 3–5;
and `default` and `stable` face culling for Modes 4–5.

Mode 4 and Mode 5 support shared mesh sources, distinct runtime buffers for each
instance, global depth-bucket painter ordering, instance material/reflectivity/color
overrides, source-local solid face colors, true static lights, and deterministic
50-Hz declarative timelines. Mode 5 applies its one-pixel outline to the final
post-clipping polygon.

The package ships generic JSON reference scenes for wire rendering, static and
dynamic materials, shared instances with a static light and timeline, solid-color
outlines, and Ground camera-plane clipping. Their documented commands compile them
locally; they are technical examples and executable API documentation, not bundled
productions.

## Earlier development history

The pre-1.0 development series established the renderer, clipping, one-sided
culling, static and dynamic material paths, Ground profiles, source-mesh sharing,
and the validation contracts now consolidated in this release. Historical
production-specific names and packaged binaries are intentionally not part of the
public 1.0 source SDK.
