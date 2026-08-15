# 3Dvibe64 1.1.1

3Dvibe64 1.1.1 is a source SDK for creating specialized Commodore 64 3D programs
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
- `scripts/` — release and world-metrics contracts. Regression PRGs are generated in
  external temporary directories and removed automatically.
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

GraphicsMode 1–5 are available. Cameras support `fixed`, `walkLite`, and `walkFull`;
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
without the visual split.

Modes 3–5 support `-Mode4NearProfile default|late|clip`. `default` keeps the 8-WU
reject and projection divisor; `late` accepts depth 1 with a divisor minimum of 2 and
rejects camera-plane crossings as whole faces; `clip` uses camera-plane clipping.
All profiles remain one-sided. Modes 4–5 also support
`-FaceCullProfile default|stable`; `stable` combines the normal screen-space path
with a camera-space decision near edge-on, avoiding quantization flicker.

Ground profiles are `simple` and `plane`. Mode 2 remains line-only with plane Ground;
Modes 3–5 can fill the projected half-plane. Mode 4/5 shared scenes can opt into
`meshSourceSharing: true`: source geometry is emitted once while each visible
instance retains its own transformed/projected runtime buffers. All instance faces
share one global depth-bucket painter order.

Instances can override material, reflectivity, and color; source-local `faceOverrides`
can request a VIC-II `solidColor` and disable dynamic shading for an individual face.
`light.type: "static"` emits a true static-light path. The declarative timeline is
deterministic at 50 Hz, supports states, visibility, transforms, linear velocities,
instance overrides, and `resetKey: "SPACE"`; it intentionally has no generic
sinusoidal-easing language.

## Public release contract

The 1.1.1 contract requires version `1.1.1`, the immutable builder hash, 45 permanent
source files, no permanent `.prg`, a valid manifest, generic examples, and reference
build hashes generated outside the package. Invalid point-only or collinear faces are
rejected by the builder as malformed geometry. It also runs frozen Ground-crossing
poses for Modes 4 and 5 through at least 32 `render_frame_end` events and verifies
symbol-derived bitmap/screen-RAM signatures. Run `python scripts/test_release_contract.py`;
set `VICE_X64SC` (or `VICE_EXE`) when x64sc is not on `PATH`.
