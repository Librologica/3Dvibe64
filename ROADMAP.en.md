# Roadmap — 1.11.0

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

## Remaining work

Integrate bounded modules into a general scene API, remove template-label dependencies, broaden world topology, and prove shared memory ownership for combined features. WORLD-01 UI startup recovery is still not applied. Validate every native composition and measure its own complete-view FPS; isolated historical proofs do not establish general compatibility. New demonstration projects remain outside the public SDK.
