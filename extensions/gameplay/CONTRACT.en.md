# Bounded billboard source contract — 1.11.0

The distribution retains `billboards/masked.py`, `outlined.py`, `scene.py`
and `multiple.py`, with entity/door, material, light, visibility, mesh, motion,
world and level modules. No scene builder, UI, character artwork, camera route,
launcher, demo project or duplicate foundation SDK is bundled. Native project
inputs are external and explicit. See [GAMEPLAY](../../GAMEPLAY.en.md).

## API and caller inputs

`kernel()` emits code and state. `adapt(source, parts)` binds the declared
bounded renderer labels/face ordering. `post(source, frames)` appends caller
data: exactly six 16×32 indexed frames, pigment values 0–3 for masked or 0–4
for outlined. Zero is transparent; index 4 is opaque black in outlined.
It never paints a character or writes an asset. `scene.validate(config, asset)`
checks the billboard/entity configuration and `scene.bind(code, config)`
binds anchor/size; `scene.animation(config)` emits playback state/controls.
`multiple.validate/load/adapt` handles one/two instances sharing the asset.

## Bounded native contract

World-space anchors transform/project with Q8 geometry. The image stays
parallel to the view plane and respects perspective size and painter depth.
Single-instance near threshold is 8 WU; BB-03 accepts constant depth >=4 WU.
Binary transparency, shared resident palette and one 512-byte decoded cache
remain. Animation state is per instance. Caller code must match the declared
convex-room labels, reserved painter node 36 and bounded depth-band hooks.
These emitters do not provide a universal occlusion/intersection API or
arbitrarily inclined planes. No geometry scene, texture or palette asset is
implicitly installed. The ordinary exporter remains unchanged.

## Integration and qualification

Supply your own compatible renderer/project and complete frames/scene inputs.
The compatibility driver requires `--project-source`; see [project input
layout](../../GAMEPLAY.en.md#project-inputs). Missing inputs fail explicitly.
Unit tests use synthetic arrays in temporary directories, with no distributed
demonstration. Exact code/state/frame emission is checked against the prior
emitter. Historical native captures remain external and apply only to their
recorded program hash and target/options. No new FPS claim follows from this
distribution correction. [Module index](../../DOCS.md), [Italiano](CONTRACT.it.md).
