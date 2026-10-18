# MAT-01 — mixed surfaces, 1.13.0

Local development 1.14.0-dev1: [current optimizations](../../../RENDER-OPTIMIZATIONS.en.md), [external inputs](../../../EXTERNAL-INPUTS.en.md). All ../my-inputs/demos and native evidence are external to the source distribution.


Current 1.12.0 distribution ships the reusable module only. New demo projects/assets are excluded. Source captures, checkpoint numbers and native measurements below describe historical external proofs. Native project builds require explicit `--project-source`; see the [integration guide](../../../GAMEPLAY.en.md).


The bounded `mixed-surfaces` profile retains the comparison room, actors,
3072 tick camera,96 × 60 viewport, exact perspective/all 60 rows and LOD 14–22.
Walls use textures, the floor uses Gouraud, the ceiling uses flat color.

```powershell
python -B work/build-gameplay.py --profile mixed-surfaces --out ../mixed-build --project-source ../my-project
python -B work/qualify-gameplay.py --out ../mixed-build --checks --benchmark --launcher
```

`--surface-config path.json` replaces `assets/surfaces.json`. Schema 1 contains
`meshes`, a map of mesh IDs to one descriptor per source triangle, in order:
`{"mode":"texture"}`, `{"mode":"flat","index":2}` or
`{"mode":"gouraud","levels":[0,16,32]}`. Fields, counts and ranges are strict;
actor nodes 14/15 are reserved and cannot be configured as surfaces.

The post-clipping dispatcher shares Q8 transforms, near/screen clipping,
top-left coverage, palette and depth buckets. Flat/Gouraud bypass UV sampling
and LOD. Flat selects one VIC pigment slot 1–3; Gouraud linearly interpolates
corner levels 0–32 on screen, with screen-anchored 4 × 4 ordered dither between
the same slots. Textured surfaces retain exact projective sampling.

Binding is limited to the imported static convex room and shared palette.
This schema is separate from the ordinary scene API; arbitrary instances and
geometry are not qualified. Levels are explicit here. The separate
[LIGHT-01 profile](LIGHT-DEV.en.md) implements host-side static lighting.
No general occlusion solver is added.

Qualification executes flat/Gouraud spans against independent pixel oracles,
including partial edges, rising/falling levels and one-pixel spans; native
views check UI/clipping and the texture-only control reproduces the imported
checkpoint. Matched full-route native FPS/evidence is retained externally.

[Italiano](DEV.it.md) · [Release notes](../../../RELEASE-NOTES-1.12.0.en.md)
