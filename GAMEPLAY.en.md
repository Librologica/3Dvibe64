# Gameplay source guide — 1.11.0

[Italiano](GAMEPLAY.it.md) · [Index](DOCS.md) · [Release notes](RELEASE-NOTES-1.11.0.en.md)

The official source release exposes bounded experimental profile builders,
not a universal combined scene API. Sources/JSON/assets are included so users
can rebuild and extend these modules. No precompiled PRG, music/video or demo
archives are distributed. Ordinary `work/build-3Dvibe64.ps1` retains its
1.10.2 contract; these profiles are explicit separate entry points.

## Choose a supported composition

|Profile|Parent composition|Added capability|
|---|---|---|
|`comparison-ui`|—|Skeleton and outlined billboard|
|`dungeon-masked`|—|Historical masked dungeon profile (fast)|
|`mixed-surfaces`|comparison-ui|Per-face material selection|
|`interactive-billboard`|mixed-surfaces|Configured guardian and local interaction|
|`door-entity`|interactive-billboard|Sliding door and safe local passage|
|`multiple-billboards`|door-entity|Two instances, shared asset/cache|
|`animated-textures`|multiple-billboards|Frame pages and UV scroll|
|`static-light`|animated-textures|Static host-side vertex lighting|
|`sector-visibility`|static-light|Conservative connectivity PVS|
|`shared-meshes`|mixed-surfaces|Shared convex source, separate instances|
|`controlled-animation`|shared-meshes|Application-controlled clips|
|`camera-roll`|controlled-animation|Controlled clips plus flight camera roll|
|`room-groups`|door-entity|External two-room groups and state|

The parent column describes the effective source/profile chain. camera-roll
inherits controlled-animation in its actual preset chain as well as Q8-01;
it adds flight roll, not door/billboard support. Defaults: PAL Turbo6510× 64,
no music, Colodore/filter 0. comparison-ui and later precise profiles use
96 × 60 logical/all 60 rows and texture LOD 14–22. dungeon-masked deliberately
keeps its historical 160 × 100 block 8/50 sampled-row reconstruction.

Q8-01/Q8-02 branch from mixed-surfaces and replace the comparison actors with
convex solids; they do not accumulate the door, texture animation, lighting
or sector modules. room-groups branches from door-entity rather than the
larger two-billboard chain. Profile names do not promise arbitrary geometry.

## Build API and output

```powershell
python -B work/build-gameplay.py --help
python -B work/build-gameplay.py --profile multiple-billboards --out ../billboards-build
pwsh -NoProfile -File work/build-gameplay.ps1 -Profile camera-roll -OutputDirectory ../roll-build
```

`--profile` selects one of 13 names and defaults to comparison-ui; `--out` is
required, new and outside the source tree. Existing/in-source outputs fail
before overwrite. The PowerShell wrapper exposes Profile/OutputDirectory and
PascalCase equivalents SurfaceConfig,GameplayScene,DoorConfig,TextureAnimation,
LightBake,Visibility,SharedMeshes,MotionControls,WorldGroups. Configurations
are copied into the generated project; unsupported option/profile pairs fail.

|Python option|Accepted profiles|Generated project input|
|---|---|---|
|`--surface-config`|mixed-surfaces, interactive-billboard, door-entity, multiple-billboards, animated-textures, static-light, sector-visibility, shared-meshes, controlled-animation, camera-roll, room-groups|`assets/surfaces.json`|
|`--gameplay-scene`|interactive-billboard, door-entity, multiple-billboards, animated-textures, static-light, sector-visibility, room-groups|`assets/gameplay-scene.json`|
|`--door-config`|door-entity, multiple-billboards, animated-textures, static-light, sector-visibility, room-groups|`assets/door.json`|
|`--texture-animation`|animated-textures, static-light, sector-visibility|`assets/texture-animation.json`|
|`--light-bake`|static-light, sector-visibility|`assets/light-bake.json`|
|`--visibility`|sector-visibility|`assets/visibility.json`|
|`--shared-meshes`|shared-meshes, controlled-animation, camera-roll|`assets/shared-meshes.json`|
|`--motion-controls`|controlled-animation, camera-roll|`assets/motion.json`|
|`--world-groups`|room-groups|`assets/world-groups.json`|

Default configs/assets live under `extensions/gameplay/profiles/<profile>/`;
inheritance supplies earlier inputs. Billboard/texture asset files resolve
relative to their config and must stay inside that directory. Unknown fields,
counts/types/ranges, invalid geometry and incompatible profiles are rejected
by the corresponding compiler. Read its contract before editing data.

Output `build.json` records engine/profile/foundation identities, scope,
configuration hashes, command, PRG hash and `checkpointPRGIdentical`.
The generated project is in `project`, final program at `<profile>.prg` and
generated launcher `launch-demo.cmd`. The source release contains none of
these compiled outputs. For room-groups keep external `project/media` with
the program/launcher; persistence is per-group RAM state, not disk saves.

## Shared level format

```powershell
python -B work/build-level.py --level examples/levels/integrated-foundation.json --validate-only
python -B work/build-level.py --level examples/levels/integrated-foundation.json --out ../level-build
python -B work/build-level.py --level examples/levels/integration-planning.json --plan-only --out ../level-plan
```

`--level` is required. `--validate-only` writes nothing; `--plan-only` writes
resolved portable input/IR and compatibility reasons without claiming a
native program or measured RAM. Normal compile requires a buildable WORLD-01
plan. `reserveBytes` and aligned `minimumContiguousBytes` are checked against
final assembled allocation. Native output is in `native`, portable level in
`level`, budget in `memory-budget.json`, accepted launcher `launch-level.cmd`.
The integration-planning example is intentionally unbuildable; it documents
the remaining combined-feature work instead of silently discarding requests.

WORLD-01 still reserves its 3759 bytes of startup UI storage. Recovery is a
plan, not measured free RAM in that backend; the separate integration below
actually reuses 2904 bytes under a different checked lifetime contract.

## Separate bounded integration

```powershell
python -B work/build-underworld.py --out ../integration-build
```

This distinct adapter combines three rooms/static cubes, skeleton and a
configured guardian with event-selected clips, conservative negative-Z room
rejection and 2904 byte post-UI storage reuse. It keeps precise sampling/all
60 rows; central cube static. It does not load WORLD-01 groups or provide
manual navigation/general collisions. `--scene-config` and `--no-room-culling`
are specific to this entry point; they are not build-gameplay switches.

## Controls, timing and qualification

Controls are profile-specific: SPACE uses guardian/door, WASD enters the local
manual visit and R resumes/restarts where documented. Q8-02 uses 1–4/SPACE/R/T/F
for clips and Q/E/HOME/C for flight roll. WORLD-01 adds N/P explicit neighbor
transitions. The Underworld camera remains automatic. Do not assume one
profile's controls, near threshold or occlusion solver apply to another.
State/animation updates use simulation ticks, not rendered-frame counts.

```powershell
python -B work/qualify-gameplay.py --out ../billboards-build --checks --benchmark --launcher
```

Configure `TASS64_EXE` and `VICE_TURBO6510` to installed tools. Host build and
qualification tools honor these overrides; historical local fallbacks are
not dependencies. Pillow and py65 are test/UI dependencies. Use `python -B`
without optimization. Saved native results are reusable only with matching
program/conditions; use new outputs for fresh acquisition. Complete-view FPS
requires native target timing, warm-up,≥20 emulated seconds/full route,
commands/hash/raw and p 95/worst. CPU correctness replay is not an FPS source.
See [testing](TESTING.md) and [release qualification](QUALIFICATION-1.11.0.en.md).

## Complete module contracts

- BB-01: [Imported masked/outlined billboard profiles](extensions/gameplay/CONTRACT.en.md).
- BB-02 / ENT-01: [Configured billboard, use events and local collision](extensions/gameplay/entities/DEV.en.md).
- ENT-01 door: [Sliding polygonal door and safe passage](extensions/gameplay/entities/DOOR-DEV.en.md).
- BB-03: [One/two shared-asset billboard instances](extensions/gameplay/billboards/MULTIPLE-DEV.en.md).
- MAT-01: [Per-face texture, flat and Gouraud selection](extensions/gameplay/materials/DEV.en.md).
- TEX-01: [Texture frames and signed integer UV scroll](extensions/gameplay/materials/ANIMATION-DEV.en.md).
- LIGHT-01: [Deterministic host-side static vertex lighting](extensions/gameplay/materials/LIGHT-DEV.en.md).
- VIS-01: [Conservative sector/portal connectivity](extensions/gameplay/visibility/VISIBILITY-DEV.en.md).
- Q8-01: [Shared source mesh, independent instance caches](extensions/gameplay/meshes/SHARED-DEV.en.md).
- Q8-02: [Controlled clips and Q8 camera roll](extensions/gameplay/motion/CONTROLLED-DEV.en.md).
- WORLD-01: [External room groups and per-group state](extensions/gameplay/world/WORLD-DEV.en.md).
- LEVEL-01: [Common level authoring and exact assembled budget](extensions/gameplay/level/LEVEL-DEV.en.md).
- Integration: [Bounded three-room actors/cubes and phased memory reuse](extensions/gameplay/experiments/underworld/README.en.md).

## Complete default configuration files

These are the actual complete source JSON shapes, including optional/application fields. Copy a configuration together with its relative assets; do not mix schemas or profile chains. The matching module contract explains numeric/geometry limits.

|Configuration|JSON|
|---|---|
|surfaces|[surfaces.json](extensions/gameplay/profiles/mixed-surfaces/assets/surfaces.json)|
|single billboard/entity|[gameplay-scene.json](extensions/gameplay/profiles/interactive-billboard/assets/gameplay-scene.json)|
|billboard asset|[guard-frames.json](extensions/gameplay/profiles/interactive-billboard/assets/guard-frames.json)|
|door|[door.json](extensions/gameplay/profiles/door-entity/assets/door.json)|
|two billboards|[gameplay-scene.json](extensions/gameplay/profiles/multiple-billboards/assets/gameplay-scene.json)|
|texture animation|[texture-animation.json](extensions/gameplay/profiles/animated-textures/assets/texture-animation.json)|
|texture frames|[texture-frames.json](extensions/gameplay/profiles/animated-textures/assets/texture-frames.json)|
|static lighting|[light-bake.json](extensions/gameplay/profiles/static-light/assets/light-bake.json)|
|visibility|[visibility.json](extensions/gameplay/profiles/sector-visibility/assets/visibility.json)|
|shared instances|[shared-meshes.json](extensions/gameplay/profiles/shared-meshes/assets/shared-meshes.json)|
|shared mesh asset|[crystal-mesh.json](extensions/gameplay/profiles/shared-meshes/assets/crystal-mesh.json)|
|controlled clips|[motion.json](extensions/gameplay/profiles/controlled-animation/assets/motion.json)|
|flight roll|[motion.json](extensions/gameplay/profiles/camera-roll/assets/motion.json)|
|world groups|[world-groups.json](extensions/gameplay/profiles/room-groups/assets/world-groups.json)|
