# Gameplay source contracts — 1.11.0

The official 1.11.0 source release includes bounded experimental gameplay
modules. This is their current contract; dev1–dev13 identify historical
implementation checkpoints, not future tasks. Start with [gameplay](../../GAMEPLAY.en.md)
and the [documentation index](../../DOCS.md).

`work/build-3Dvibe64.ps1` retains the ordinary 1.10.2 interface. Use
`work/build-gameplay.py` for 13 named profiles, `work/build-level.py` for the
common level adapter, and `work/build-underworld.py` for the separate
integration. Unsupported combinations are rejected rather than silently dropped.

`common` supplies shared generator sources/assets; `profiles` supplies bounded
scene, UI and camera adapters; `billboards`, `entities`, `materials`, `meshes`,
`motion`, `visibility`, `world` and `level` supply their compiler/runtime modules.
All source dependencies are included. `foundation-1.10.2` is an immutable
generator input with its original version/manifest, not a second release.
The ordinary exporter and Mode 8 are not extended by importing a profile.

## Profiles and composition

`comparison-ui`: one closed room, original 38-vertex/52-edge skeleton with
sword/shield, outlined billboard of equal body height,96 × 60 logical viewport,
exact perspective/all 60 rows, texture LOD 14–22 WU,3072 tick orbit.
`dungeon-masked`: one six-frame 16 × 32 billboard in the front room of a fixed
five-cell chain;160 × 100 viewport, historical block 8/50-row reconstruction,
texture LOD 14–22,7680 ticks. These two contracts deliberately use different
sampling profiles and cannot be used as a matched speed comparison.

The mixed-surfaces → interactive-billboard → door-entity → multiple-billboards
→ animated-textures → static-light → sector-visibility chain adds the stated
features incrementally. shared-meshes branches from mixed-surfaces and leads
to controlled-animation/camera-roll; it does not include the door/billboards.
room-groups branches from door-entity. The common level backend uses room-groups.
The three-room integration is separate and does not load WORLD-01 groups.

## Billboard geometry and palette

Sources use 16 × 32 pixels, binary transparency 0, pigment slots 1–3 and optional
opaque black 4. No semitransparency. The plane stays parallel to the view plane;
size and depth are perspective derived. The historical single-instance
adapters reject centers below 8 WU. The two-instance BB-03 adapter accepts 4 WU
and above, rejecting the whole constant-depth plane below 4 WU. Its instances
share an asset and 512 byte decoded cache, with independent animation state.
Use each profile contract for its ownership/occlusion rules; arbitrary mesh
intersections or inclined billboard planes are not supported.

## Build and evidence

```powershell
python -B work/build-gameplay.py --profile comparison-ui --out ../comparison-build
python -B work/build-gameplay.py --profile door-entity --out ../door-build
python -B work/build-level.py --level examples/levels/integrated-foundation.json --validate-only
```

Output must be new and outside the source tree. Generated launchers use VICE
Turbo6510 PAL× 64, filter 0, Colodore and no music. PRG hashes identify exact
checkpoint reuse; changed hashes require new correctness/native timing checks.
Only new complete presented views count as FPS. Source archives contain no
precompiled programs or demo archives. General scene integration remains future
work; the detailed contracts below describe what is actually implemented.

[Italiano](CONTRACT.it.md) · [Release notes](../../RELEASE-NOTES-1.11.0.en.md)
