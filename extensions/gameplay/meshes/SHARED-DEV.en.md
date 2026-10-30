# Q8-01 — shared source meshes, 1.15.1

Stable1.15.1, source-only GitHub release. [Release status](../../../RELEASE-STATUS.en.md) · [Current qualification](../../../QUALIFICATION-1.15.1.en.md). Input scenes/assets are external; no demo projects are bundled.

> Stable1.15.1 source SDK published on GitHub. [Status and support](../../../RELEASE-STATUS.en.md).

Stable GitHub release 1.15.1: [current optimizations](../../../RENDER-OPTIMIZATIONS.en.md), [external inputs](../../../EXTERNAL-INPUTS.en.md). All demonstration projects and raw native evidence remain external to the source distribution.


Current 1.12.0 distribution ships the reusable module only. New demo projects/assets are excluded. Source captures, checkpoint numbers and native measurements below describe historical external proofs. Native project builds require explicit `--project-source`; see the [integration guide](../../../GAMEPLAY.en.md).


`shared-meshes` places four polygonal solids in the LABIRINTO room. One
editable geometry asset supplies instances with independent position, scale,
yaw, visibility and shading. Camera 48 keys, exact perspective on all 60 rows,
viewport 96 × 60 and texture LOD 14–22 are retained.

```powershell
python -B work/build-gameplay.py --profile shared-meshes --out ../shared-build --project-source ../my-project
python -B work/qualify-gameplay.py --out ../shared-build --checks --benchmark --launcher
```

`--shared-meshes path.json` replaces instance descriptors. Editable mesh:
`<project-source>/extensions/gameplay/profiles/shared-meshes/assets/crystal-mesh.json`, schema,
ID, six integer public X/right,Y/forward,Z/up vertices and eight triangles.
The validator requires a closed convex solid, public clockwise winding,
maximum XY radius 3 and local height−5..5. Native layout is deliberately six
vertices/eight faces; coordinates/topology are not hard-coded to one asset.

Configuration: schema 1, Boolean `sharing`,2–4`instances`. Each has unique ID,
`position`, `yawDegrees`, `scale`, `visible`, `level`. Position step 1/256 WU;
scale 0.5–1 step 1/64; yaw[0,360) quantized to 16 bit phase; integer level 4–28.
Faces derive individual Gouraud levels. XY envelopes must be disjoint and
inside the room; floor/ceiling crossings are rejected. Native transform
uses canonical interpolated sine/Q8 products. Hidden instances omit faces
but still update their vertex caches.

## Native memory

One asset uses 18 XYZ bytes plus 32 local-topology bytes (four 8-byte columns,
fourth reserved). Four instances share 50 bytes instead of 200, saving 150 real
helper-pool bytes. Default free 5281 versus 5131 with `sharing:false`, with
the same room/code/instances/route/quality. Other profiles are not matched
sharing controls. Room: nine vertices/16 face slots including two inert nodes;
total runtime 33 vertices/48 faces.

Caches remain per instance:36 bytes per vertex across 24 bit camera coordinates,
projection/texture/coverage/legacy caches and flags,216 bytes per solid.
The two global bucket tables each add eight bytes per solid. Descriptors/
indices add 16 bytes/instance; UV/material/shade/count tables remain individual.
Fixed 35 byte scratch is sequentially reused; the clipper has common per-face
scratch. Transform code 729 bytes, topology resolution 112, state/index/scratch 99
for four instances excluding pre-existing buffers/metadata. Build maps expose
all allocation and free gaps; sharing does not remove per-instance caches.

## Evidence and supported scope

Ten native shared/duplicated poses include each instance alone, all visible
and all hidden. An independently compiled empty room is also compared.
An independent Q8 oracle checks 1/256 WU translation, scale, yaw, visibility and
other caches; a ray/triangle oracle checks 700 interior pixels from front/back.
UI, palette, immutable sources and three LOD distances are verified.

This bounded mixed-surfaces branch uses untextured Gouraud solids and textured
walls. Arbitrary assets, intersecting objects and geometric LOD remain
unsupported. [Q8-02](../motion/CONTROLLED-DEV.en.md) separately adds application
animation/roll. Door, billboards, light bake and portals are not combined here.
The ordinary builder/foundation still reject ordinary Q8 `meshSourceSharing`;
this adapter does not change that general API. Historical raw/FPS checkpoints
remain external and apply only to their recorded program/conditions.

[Italiano](SHARED-DEV.it.md).
