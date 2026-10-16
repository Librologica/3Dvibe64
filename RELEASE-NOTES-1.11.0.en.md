# 3Dvibe64 1.11.0 — official local source release

2026-10-16. Promoted from 1.11.0-dev13/cubes-restored. Local preparation only;
online publication is deferred. Distribution is the engine source SDK with
JSON/asset inputs and compiler/profile sources. **No precompiled PRG, demo
archive, video or music** is included. External tools are not bundled.

## Included changes since1.10.2

|ID|Capability|Full contract|
|---|---|---|
|BB-01|Imported masked/outlined billboard profiles|[reference](extensions/gameplay/CONTRACT.en.md)|
|BB-02 / ENT-01|Configured billboard, use events and local collision|[reference](extensions/gameplay/entities/DEV.en.md)|
|ENT-01 door|Sliding polygonal door and safe passage|[reference](extensions/gameplay/entities/DOOR-DEV.en.md)|
|BB-03|One/two shared-asset billboard instances|[reference](extensions/gameplay/billboards/MULTIPLE-DEV.en.md)|
|MAT-01|Per-face texture, flat and Gouraud selection|[reference](extensions/gameplay/materials/DEV.en.md)|
|TEX-01|Texture frames and signed integer UV scroll|[reference](extensions/gameplay/materials/ANIMATION-DEV.en.md)|
|LIGHT-01|Deterministic host-side static vertex lighting|[reference](extensions/gameplay/materials/LIGHT-DEV.en.md)|
|VIS-01|Conservative sector/portal connectivity|[reference](extensions/gameplay/visibility/VISIBILITY-DEV.en.md)|
|Q8-01|Shared source mesh, independent instance caches|[reference](extensions/gameplay/meshes/SHARED-DEV.en.md)|
|Q8-02|Controlled clips and Q8 camera roll|[reference](extensions/gameplay/motion/CONTROLLED-DEV.en.md)|
|WORLD-01|External room groups and per-group state|[reference](extensions/gameplay/world/WORLD-DEV.en.md)|
|LEVEL-01|Common level authoring and exact assembled budget|[reference](extensions/gameplay/level/LEVEL-DEV.en.md)|
|Integration|Bounded three-room actors/cubes and phased memory reuse|[reference](extensions/gameplay/experiments/underworld/README.en.md)|

All gameplay modules remain explicitly bounded/experimental. The ordinary
scene exporter, default options, Q8 arithmetic and Mode 8 backend are preserved.
There is no new general-purpose combined scene ABI. Source profiles are
reproducible configurations, not shipped executable products.

## Compatibility and entry points

- `work/build-3Dvibe64.ps1`: inherited GraphicsMode 1–8 exporter. Defaults:
  legacy geometry, standard textures, precise lines, LOD off, safe presentation.
- `work/build-gameplay.py` / `.ps1`:13 named profiles with strict per-profile
  config switches. Source sharing/roll are Q8-01/Q8-02 adapters, not newly
  accepted ordinary Q8 `meshSourceSharing`/roll fields.
- `work/build-level.py`: `3Dvibe64.level/1`, portable assets, dense IDs,
  WORLD-01 lowering and exact assembled memory reserve/contiguity checks.
  `--validate-only` writes nothing; `--plan-only` does not claim a native build.
- `work/build-underworld.py`: separate bounded three-room source integration,
  three static cubes, skeleton/guardian, event-controlled clips and 2904 bytes
  of proven post-UI storage reuse. It does not combine WORLD-01 loading.

The exact 1.10.3-dev1 span helper remains local to that adapter. Mode 8 bitmap
only/retired-experiment refusals, Normalized 16 limits and original 1.10.2
foundation hashes remain. Historical release notes/evidence keep their own
versions. EN/IT manuals, index, feature matrix, controls, schemas, memory and
limitations are synchronized. Packaging/native helper tools now also honor
`TASS64_EXE`/`VICE_TURBO6510`; renderer instructions are not changed by that
host path resolution.

## Important limits

Billboards use binary masks/shared resident palette. One-instance adapters
have near 8 WU; BB-03 has one/two shared-asset instances and near 4 WU. Occlusion/
collision remain constrained to their checked room/divider envelopes. Lighting
is static host-side on Gouraud receivers, not dynamic textured shadows.
VIS-01 is conservative connectivity, not angular portal clipping. Q8-01
has 2–4 six-vertex/eight-face convex instances; caches remain per instance.
Q8-02 is transform animation, not skeletal animation/flight physics.

WORLD-01 has 2–8 groups of the fixed two-room template,1024 byte staging,
CRC-checked 762 byte files,17 bytes RAM state/group and explicit transitions.
No disk save/general topology. Common level authoring can express additional
requests but rejects integrations its backend cannot build. Its 3759 byte UI
recovery is hypothetical; the separate 2904 byte Underworld reuse does not
make that space available in WORLD-01. General combined-feature integration
remains on the [roadmap](ROADMAP.en.md).

## Build, tests and performance

Verified Windows toolchain: PowerShell 7,Python 3.13,64tass 1.60.3243; Pillow for
PNG/UI,py65 for routine tests. Configure installed VICE variants for native
tests. Linux/physical hardware execution is not newly qualified.

```powershell
python -B scripts/run_release_tests.py
python -B work/build-gameplay.py --profile shared-meshes --out ../shared-build
python -B work/build-level.py --level examples/levels/integrated-foundation.json --validate-only
```

See [qualification](QUALIFICATION-1.11.0.en.md) for exact release gate results,
source integrity and representative checkpoint rebuilds. Native evidence is
reused only when rebuilt program bytes and launch conditions match. Existing
FPS apply to their own scene/target/options; there is no universal engine FPS
or speedup claim from source-only promotion. Warp/host/CPU replay is not native
complete-view FPS. Raw development captures stay outside the source archive.

Source package integrity: `MANIFEST.sha256`; external ZIP digest accompanies
delivery. Existing official releases, frozen projects and development checkout
remain preserved. Software: PolyForm Noncommercial 1.0.0; documentation:
CC BY-NC 4.0, attribution librologica.digital. See [README](README.en.md),
[quick start](QUICKSTART.md), [all documentation](DOCS.md) and [testing](TESTING.md).
