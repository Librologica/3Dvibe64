# Gameplay source modules — 1.12.0

Release 1.12.0: [current optimizations](RENDER-OPTIMIZATIONS.en.md), [external inputs](EXTERNAL-INPUTS.en.md). All examples/demos and native evidence are external to the source distribution.


## Source-only release

This is the source release available in the GitHub repository. No demos or examples are shipped, including
preexisting ones. Supply your own scenes/assets and explicit external project
inputs. The renderer and reusable gameplay modules remain included. See
[external inputs](EXTERNAL-INPUTS.en.md), [optimizations](RENDER-OPTIMIZATIONS.en.md)
and [qualification](QUALIFICATION-1.12.0.en.md).

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

## Project inputs

The SDK contains algorithms and bounded adapters, not a complete new game or
demo. Supply your own scene, textures, billboard frames, mesh/animation data,
UI, camera path and project glue. No character or three-room scene is bundled.
The ordinary exporter API remains separate: Q8-01 sharing and Q8-02 roll do
not become accepted ordinary `meshSourceSharing` or camera-roll scene fields.

The compatibility driver `work/build-gameplay.py` accepts an external adapter
root. Its layout is `examples/gameplay/<profile>.json` for the preset and
`extensions/gameplay/common`, `extensions/gameplay/profiles/<profile>` and
`extensions/gameplay/billboards/<implementation>.py` for caller-owned glue.
These paths belong to the external project, not this SDK. Presets contain
`profile`, `engineVersion` (1.12.0), optional `extends`, `buildName`,
`billboardImplementation`, `distributionPRG`, `textureQuality`, `textureLOD`,
`viewportLogical`, `expectedCheckpointPRGSHA256` and optional `scope`.
The driver overlays the inherited project profiles, copies the current SDK
as the engine dependency, applies supplied configuration and invokes the
project’s `build_demo.py`. This is an explicit project build, not an installed
demo. Qualification also needs the project's own checks/oracles/launcher.

```powershell
python -B work/build-gameplay.py --project-source ../my-project --profile shared-meshes --shared-meshes ../my-project/assets/instances.json --out ../my-build
pwsh -NoProfile -File work/build-gameplay.ps1 -ProjectSource ../my-project -Profile shared-meshes -OutputDirectory ../my-build-ps
```

`--out` must be new and outside both SDK and project inputs. Missing project
inputs fail before output creation. There is no implicit search for a local
private demo. The following adapter identifiers are retained for compatibility
with external projects; no corresponding project preset is distributed:

`animated-textures`, `camera-roll`, `comparison-ui`, `controlled-animation`, `door-entity`, `dungeon-masked`, `interactive-billboard`, `mixed-surfaces`, `multiple-billboards`, `room-groups`, `sector-visibility`, `shared-meshes`, `static-light`.

## Configuration switches

- `--surface-config`: per-face materials JSON.
- `--gameplay-scene`: billboard/entity JSON and relative asset.
- `--door-config`: door motion configuration.
- `--texture-animation`: frame/UV timing and relative asset.
- `--light-bake`: host static lighting configuration.
- `--visibility`: sector/portal graph.
- `--shared-meshes`: shared instances and mesh input.
- `--motion-controls`: transform clips, playback and roll.
- `--world-groups`: group topology and transition settings.

Billboard/door/multiple/texture/light/visibility adapters form the inherited
room chain. Shared meshes branch from mixed surfaces; controlled-animation
and camera-roll build on that branch. Room groups branch from door-entity.
The driver rejects incompatible options. Inputs remain schema-checked; see
the complete module contracts for every field, range and ownership rule.

## Library integration

`billboards/masked.py` and `outlined.py` provide `kernel()`, `adapt(source,
parts)` and `post(source, frames)`. The caller supplies six 16×32 indexed
frames (0 transparent, slots 1–3, optional opaque black 4 for outlined).
There is no `artwork()`, scene/tour generator or implicit asset write.
The existing bounded face labels/depth bands must match the project;
`billboards/scene.py` binds validated anchors, size and animation.
`multiple.py` uses one shared asset with independent instance state.

Materials, lighting, visibility, mesh, motion and world modules retain their
documented emit/validate functions and native ABIs (`an_control`,
`cr_set_roll`, `cr_resume`, `wg_request`, `wg_service`). Emitters depend on
the declared source labels and memory ownership, not a general stable ABI.

## Common level and memory

`work/build-level.py --level ../my-level/level.json --validate-only` checks
the caller's graph/assets without writing. `--plan-only --out ../plan` emits
portable data, not a PRG or measured native budget. All assets use
`file:assets/name.json` inside the level directory; built-in demo assets
are excluded. Native builds additionally require `--project-source` and
an actually supported WORLD-01 template. `reserveBytes` and
`minimumContiguousBytes` are checked against assembled maps, never an estimate.
WORLD-01’s proposed 3759-byte startup UI recovery is not applied.

## Evidence and limitations

Previous native demo captures are development evidence outside this package.
They qualify their exact historical program/options only. Source cleanup adds
no rendering optimization. Ordinary runtime files and old example inputs
are preserved. New native FPS must count complete views for at least 20
emulated seconds after warm-up; preserve command/hash/raw data and p95/worst.
Binary masks, shared palette, disjoint geometry and bounded room/group
contracts remain. No arbitrary topology, disk save, dynamic textured shadows
or universal combined-feature scene API is introduced.

[Documentation index](DOCS.md).


## Packed flat spans

Optional --flat-span-cache / -FlatSpanCache selects exact MAT-01 flat spans. Requires a compatible external material binding; no quality or LOD change. [Contract / Contratto](RENDER-OPTIMIZATIONS.en.md).
