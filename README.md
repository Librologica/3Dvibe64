# 3Dvibe64 1.3.0

**New in 1.3.0: official GraphicsMode 7 affine textures**, with optional flat or
Gouraud C lighting and PNG import. [English guide](MODE7.en.md) · [Guida italiana](MODE7.it.md).
Modes 1–6 preserve their official 1.2.0 reference output.

3Dvibe64 1.3.0 is a source SDK for creating specialized Commodore 64 3D programs
from JSON scenes. It includes the frozen PowerShell builder, engine code generation,
technical documentation, generic executable JSON references, and reproducibility
contracts. It deliberately ships with no precompiled PRG and no diagnostic artifacts.

## Package contents

- `work/build-3Dvibe64.ps1` — the public scene builder and generated engine source.
- `examples/*.json` — generic technical reference scenes; compile them locally.
- `README.it.md` and `README.en.md` — complete API, JSON, CLI, controls, limits, and
  memory documentation.
- `ASSEMBLY-GUIDE.it.md` and `ASSEMBLY-GUIDE.en.md` — professional assembly
  programmer guides to the generated 6510/6502 engine, memory, debugging, and
  permanent builder changes.
- `VIBE-CODING-GUIDE.it.md` and `VIBE-CODING-GUIDE.en.md` — complete practical
  manuals for creating, building, testing, and preserving 3Dvibe64 demos with
  Codex while keeping JSON and the recorded build command authoritative.
- `scripts/` — release, renderer and world-metrics contracts. Use the disposable-copy
  runner documented in `TESTING.md` to keep generated outputs outside the package.
- `LICENSE` and `LICENSE-DOCUMENTATION.md` — noncommercial software and
  documentation terms, with attribution to librologica.digital.
- `.gitignore`, `.gitattributes`, `CONTRIBUTING.md`, and `SECURITY.md` — repository
  hygiene, contribution, and private vulnerability-reporting guidance for GitHub.

Use a disposable copy for builds if you want the SDK checkout to remain free of
generated PRG and ASM artifacts. See [QUICKSTART.md](QUICKSTART.md) and
[examples/README.md](examples/README.md). Assembly programmers should start with
[ASSEMBLY-GUIDE.en.md](ASSEMBLY-GUIDE.en.md) or
[ASSEMBLY-GUIDE.it.md](ASSEMBLY-GUIDE.it.md). Codex-assisted workflows are covered
by [VIBE-CODING-GUIDE.en.md](VIBE-CODING-GUIDE.en.md) and
[VIBE-CODING-GUIDE.it.md](VIBE-CODING-GUIDE.it.md).

## Licensing

Copyright © 2026 **librologica.digital**, author and licensor of 3Dvibe64.

The software, builder, scripts, JSON examples, validation assets, and generated
engine code are available for noncommercial purposes under the
[PolyForm Noncommercial License 1.0.0](LICENSE). Commercial use requires a
separate written license from librologica.digital.

All Markdown documentation, manuals, and programmer guides are available for
noncommercial purposes under
[Creative Commons Attribution-NonCommercial 4.0 International](LICENSE-DOCUMENTATION.md).
Attribution to `librologica.digital` is required. These restrictions make the
project source-available rather than OSI-approved open source. A public GitHub
repository still permits viewing and forking through GitHub's own functionality.

64tass and VICE are external dependencies and remain subject to their respective
authors' licenses; they are not included in this distribution.

## Renderer overview

GraphicsMode 1–6 are available. Mode 6 adds per-vertex Gouraud lighting using a
33-level, screen-anchored 4x4 Bayer ordered dither. It requires
`-MemoryLayout high-basic-v2`; `gouraud.creaseAngle` controls smoothing across
adjacent faces and defaults to 60 degrees. Runtime shade vertices are limited to
255. See [GOURAUD-MODE6-REPORT.md](GOURAUD-MODE6-REPORT.md) and the
`examples/mode6-gouraud-*.json` scenes.

Cameras support `fixed`, `walkLite`, and `walkFull`;
viewports are `normal` and `small`. With the DEV7 text split compiled in (the default),
three character rows are reserved above the 3D body: `normal` renders a 160×88 body
at Y=12, while `small` renders 128×80 at Y=12. `-NoFpsOverlay` removes the split and
restores the legacy 160×100 normal viewport (the 128×80 small viewport is centered).
`stable` is the compact layout; `high-basic-v2` supports larger or more complex scenes.

`-HeaderText "..."` embeds up to 40 characters in the shared text header. Supported
glyphs are space, digits, dot, and `S C R I T A D E M P O`; unsupported characters
become spaces. The FPS display occupies the first four cells of the middle header
row and takes precedence there. `F` toggles the complete text header; use
`-FpsOverlayOnStart` to show it at startup. Screen A and Screen B keep independent
same-bank header/charset copies, and material application preserves the first 120
Screen RAM bytes (`TEXT_HEADER_SCREEN_BYTES=120`). `-FpsCounterOnly` retains sampling
without the visual split. Hiding the header with `F` keeps the 3D body double-buffered,
selects the displayed buffer's VIC bank and bitmap pointer, and clears the exact
generated compact-charset length; showing it reconstructs that charset before the
next text frame. `F` therefore hides Generic Text and FPS together, not FPS alone.

Modes 3–6 support `-Mode4NearProfile default|late|clip`. `default` keeps the 8-WU
reject and projection divisor; `late` accepts depth 1 with a divisor minimum of 2 and
rejects camera-plane crossings as whole faces; `clip` uses camera-plane clipping.
All profiles remain one-sided. Modes 4–6 also support
`-FaceCullProfile default|stable`; `stable` combines the normal screen-space path
with a camera-space decision near edge-on, avoiding quantization flicker.

Ground profiles are `simple` and `plane`. Mode 2 remains line-only with plane Ground;
Modes 3–6 can fill the projected half-plane. Mode 4/5/6 shared scenes can opt into
`meshSourceSharing: true`: source geometry is emitted once while each visible
instance retains its own transformed/projected runtime buffers. All instance faces
share one global depth-bucket painter order.

Instances can override material, reflectivity, and color; source-local `faceOverrides`
can request a VIC-II `solidColor` and disable dynamic shading for an individual face.
With `meshSourceSharing`, per-instance selection must use `materialOverride`,
`reflectivityOverride`, or `colorOverride`; plain `material`/`materialFamily` describes
the non-shared/source-default path and is not an instance override.
`light.type: "static"` emits a true static-light path. The declarative timeline is
deterministic at 50 Hz, supports states, visibility, transforms, linear velocities,
instance overrides, and `resetKey: "SPACE"`; it intentionally has no generic
sinusoidal-easing language.

## Public release contract

The 1.3.0 contract requires version `1.3.0`, immutable builder/backend hashes, 88 permanent
source files, no permanent `.prg`, a valid manifest, generic examples, and reference
build hashes generated outside the package. Invalid point-only or collinear faces are
rejected by the builder as malformed geometry. It also runs frozen Ground-crossing
poses for Modes 4 and 5 through at least 32 `render_frame_end` events and verifies
symbol-derived bitmap/screen-RAM signatures. Dedicated Mode 6 host and emulator
contracts live in `scripts/test_gouraud_mode6.py` and
`scripts/test_gouraud_mode6_emulators.py`. Run `python -B scripts/run_release_tests.py`;
set `VICE_X64SC` (or `VICE_EXE`) when x64sc is not on `PATH`.

Mode 6 retains the validated Gate 5 runtime: exact 528-entry
Gouraud/Bayer LUT, specialized viewport clear, byte-oriented spans, exact division,
and exact partial-byte aggregation (Gates 1, 3, 4, 5). No hybrid flat/Gouraud
selector is supported. See [TESTING.md](TESTING.md) for the complete clean-copy suite.

## Official Mode 7 in 1.3.0

GraphicsMode 1–7 are available. GraphicsMode 1–6 retain their 1.2.0 reference output; the older API sections below still apply to those modes.

Mode 4 is dynamic flat shading. Mode 6 is ordered-dithered Gouraud shading.
Mode 7 is **affine texture mapping**, optionally with flat or Gouraud lighting:
`textureLighting` absent/`"none"`, `"flat"`, or `"gouraud"`.
The official Gouraud compositor is `textureCompositor: "C"` (texel-first + LightFix; now the Gouraud default). R1 corrects edge inclusion in this C path. A/B remain compatibility options, not the recommended renderer.

Mode 7 requires `high-basic-v2`, Python 3, `fast` quality and `extended-table` projection.
Textures are 16×16, nearest-neighbor, three pigment codes 1/2/3, with UV Q4.4 and optional repeat 1/2/4/8/16. It supports per-vertex or corner UVs, seams, per-face textures, triangulated quads (0→2), near/screen clipping, byte-oriented fill, partial bytes, double buffering, PAL/NTSC, normal/small and fixed/walkLite/walkFull.

PNG import is host-side, through Pillow: `source` and mandatory ordered `sourceColors` map exactly three opaque RGB colors to Dark/High/Highlight texels. `texturePalette` separately selects three VIC-II colors. No resizing, quantization or transparency. Inline texels remain supported and runtime-equivalent.

Textured Gouraud uses `gouraud.creaseAngle` (default60°, range0–180°) for hard edges or smooth normals, with the applicable255-shade-vertex limit. Mode 7 has its own memory/geometry constraints and does not inherit every Mode 6 override/source-sharing API.

No perspective correction, bilinear filtering, mipmapping, packed runtime textures or native quad mapper. Affine distortion and sampling aliasing remain intentional limitations.

Read the [complete Mode7 contract](MODE7.en.md), [texture guide](TEXTURE-GUIDE.en.md), [PNG guide](PNG-TEXTURES.en.md), and [eight public examples](examples/README.md). The paired Italian guides cover the same contract.
