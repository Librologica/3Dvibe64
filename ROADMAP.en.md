# Roadmap and implementation status — 1.11.0

The following source capabilities are included and qualified within the
limits of their profiles. Official packaging does not enlarge these contracts.

|ID|Implemented within bounds|Reference|
|---|---|---|
|BB-01|Imported masked/outlined billboard profiles|[contract](extensions/gameplay/CONTRACT.en.md)|
|BB-02 / ENT-01|Configured billboard, use events and local collision|[contract](extensions/gameplay/entities/DEV.en.md)|
|ENT-01 door|Sliding polygonal door and safe passage|[contract](extensions/gameplay/entities/DOOR-DEV.en.md)|
|BB-03|One/two shared-asset billboard instances|[contract](extensions/gameplay/billboards/MULTIPLE-DEV.en.md)|
|MAT-01|Per-face texture, flat and Gouraud selection|[contract](extensions/gameplay/materials/DEV.en.md)|
|TEX-01|Texture frames and signed integer UV scroll|[contract](extensions/gameplay/materials/ANIMATION-DEV.en.md)|
|LIGHT-01|Deterministic host-side static vertex lighting|[contract](extensions/gameplay/materials/LIGHT-DEV.en.md)|
|VIS-01|Conservative sector/portal connectivity|[contract](extensions/gameplay/visibility/VISIBILITY-DEV.en.md)|
|Q8-01|Shared source mesh, independent instance caches|[contract](extensions/gameplay/meshes/SHARED-DEV.en.md)|
|Q8-02|Controlled clips and Q8 camera roll|[contract](extensions/gameplay/motion/CONTROLLED-DEV.en.md)|
|WORLD-01|External room groups and per-group state|[contract](extensions/gameplay/world/WORLD-DEV.en.md)|
|LEVEL-01|Common level authoring and exact assembled budget|[contract](extensions/gameplay/level/LEVEL-DEV.en.md)|
|Integration|Bounded three-room actors/cubes and phased memory reuse|[contract](extensions/gameplay/experiments/underworld/README.en.md)|

## Remaining work

1. General combined-feature level adapter and native assembly/qualification.
2. WORLD-01 phased UI allocator/validated startup extension loader.3759 bytes
   are candidates, not free RAM.2904 byte reuse exists only in the separate
   Underworld adapter; it is not the WORLD-01 implementation.
3. Arbitrary geometry/source-sharing/intersection contracts, more than two
   independent billboard assets/palettes and general entity collision/events.
4. Angular portal clipping beyond conservative connectivity; dynamic shadows
   or lighting of textured surfaces; broader receiver/occluder transforms.
5. General group topology, seamless transitions, physical drive qualification
   and persistent disk saves.
6. New platforms/hardware qualification and future API stabilization based
   on repeatable memory/correctness/native performance evidence.

No deadline or memory fit is inferred from this list. Future renderer changes
require native complete-view measurements and matched controls. Mode 8,
foundation and frozen releases retain their existing scope.
