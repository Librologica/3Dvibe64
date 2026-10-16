# 3Dvibe64 1.11.0 — release notes

## Distribution correction within 1.11.0

New demo projects are excluded, including their source generators, UI,
character artwork, camera routes, launchers and captured/reference assets.
The duplicated 1.10.2 SDK is removed. The original examples from v1.10.2 are
retained. This corrects the existing release; VERSION stays 1.11.0.

Reusable gameplay compilers, validators and bounded assembly emitters remain.
Native gameplay builds require an external project supplied explicitly with
`--project-source`; no demo is reconstructed from bundled default inputs.
The ordinary engine and its existing examples remain directly buildable.
See [GAMEPLAY](GAMEPLAY.en.md), [quick start](QUICKSTART.md) and
[qualification](QUALIFICATION-1.11.0.en.md).

| ID | Module | Contract |
|---|---|---|
|BB-01|Masked/outlined billboard emitters|[reference](extensions/gameplay/CONTRACT.en.md)|
|BB-02 / ENT-01|Billboard configuration and local events|[reference](extensions/gameplay/entities/DEV.en.md)|
|ENT-01 door|Sliding polygonal door|[reference](extensions/gameplay/entities/DOOR-DEV.en.md)|
|BB-03|Multiple shared-asset billboards|[reference](extensions/gameplay/billboards/MULTIPLE-DEV.en.md)|
|MAT-01|Per-face texture/flat/Gouraud|[reference](extensions/gameplay/materials/DEV.en.md)|
|TEX-01|Texture frames and integer UV scroll|[reference](extensions/gameplay/materials/ANIMATION-DEV.en.md)|
|LIGHT-01|Host-side static lighting|[reference](extensions/gameplay/materials/LIGHT-DEV.en.md)|
|VIS-01|Conservative sector connectivity|[reference](extensions/gameplay/visibility/VISIBILITY-DEV.en.md)|
|Q8-01|Shared source mesh and instance caches|[reference](extensions/gameplay/meshes/SHARED-DEV.en.md)|
|Q8-02|Controlled animation and camera roll|[reference](extensions/gameplay/motion/CONTROLLED-DEV.en.md)|
|WORLD-01|Bounded group loading and state|[reference](extensions/gameplay/world/WORLD-DEV.en.md)|
|LEVEL-01|Common level format and memory accounting|[reference](extensions/gameplay/level/LEVEL-DEV.en.md)|

## Supported scope

The ordinary 1–8 exporter/defaults remain unchanged. Gameplay source modules
remain experimental and bounded. The SDK ships no new demonstration project,
source scene, character, UI, camera tour or launcher; only previous examples
are retained. External adapter inputs are required for native gameplay builds.
The level authoring format and exact assembled memory accounting remain;
`--validate-only` and `--plan-only` work with caller-supplied local assets.
No general combined-feature API, arbitrary geometry, disk saving or dynamic
textured shadows is claimed. WORLD-01 startup recovery is not applied.

## Verification

Distribution exclusions, manifest, documentation parity/local links, unit
contracts and preserved ordinary engine inputs are checked. Historic native
proofs remain external; exact source/program identities govern their reuse.
This packaging correction introduces no new rendering/FPS result. See
[qualification](QUALIFICATION-1.11.0.en.md), [testing](TESTING.md),
[complete documentation](DOCS.md) and [GAMEPLAY](GAMEPLAY.en.md).

Software: PolyForm Noncommercial 1.0.0; documentation: CC BY-NC 4.0.
Attribution: librologica.digital. VERSION remains 1.11.0.
