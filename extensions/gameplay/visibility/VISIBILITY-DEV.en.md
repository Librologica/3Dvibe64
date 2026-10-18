# VIS-01 — conservative sector/portal visibility, 1.13.0

Local development 1.14.0-dev1: [current optimizations](../../../RENDER-OPTIMIZATIONS.en.md), [external inputs](../../../EXTERNAL-INPUTS.en.md). All ../my-inputs/demos and native evidence are external to the source distribution.


Current 1.12.0 distribution ships the reusable module only. New demo projects/assets are excluded. Source captures, checkpoint numbers and native measurements below describe historical external proofs. Native project builds require explicit `--project-source`; see the [integration guide](../../../GAMEPLAY.en.md).


`sector-visibility` extends static-light. The host builds potentially visible
sector masks per start sector and open-door combination. It unions every
graph path; closing a door does not hide sectors reachable through another
opening. This is connectivity visibility, a conservative superset without
angular/frustum portal clipping.

Compiler contract: sealed axis-aligned rectangular cells partition the world
completely, all openings declared.2–8 sectors,0–4 doors,1–16 portals; public Q8
coordinates within±127 WU. Portals are rectangles on shared faces. Geometry
belongs to every sector intersecting its AABB, including boundary crossings/
touches; centroid ownership is not used. Host `PV01` stores counts, per-face
membership masks and PVS rows.

The native adapter accepts only the qualified two-sector sealed room, divider
Y=8, aperture X[-5,5], Z[-10,8] and one opaque retracting door. It verifies
geometry identity and both billboard envelopes. Actor nodes belong to the
front sector; divider/door belong to both. Arbitrary levels need a separately
qualified adapter relating real openings and geometry.

A door is visibility-closed only when both Q8 bytes of `dr_lift` are zero.
Even 1/256 WU opening enables the connected sectors before player passage.
Invisible sectors are skipped before face collection, preserving projection,
clipping, materials, palette and painter behavior.

Camera culling is used only for exact yaw 0°/180°, pitch 0, within the interior
envelope and more than 8 WU from the divider. Oblique, near-boundary and outside
views retain every face/sector, including historical background pixels at
occluder edges. The reserve contains the complete near-view volume for the
96 × 60 viewport, focal 41 and near 4 WU at supported orientations.

```powershell
python -B work/build-gameplay.py --profile sector-visibility --out ../visibility-build --project-source ../my-project
python -B work/qualify-gameplay.py --out ../visibility-build --checks --benchmark --launcher
```

`--visibility path.json` stays within this adapter contract. `culling:false`
retains code/data/allocation and changes only initial `vs_enabled` for matched
native timing. `enabled:false` omits the module and reproduces static-light,
including its camera. `visibility.json`/`.bin` record the bake. The active
route keeps earlier positions/yaw, with horizontal gaze at keys 0–4,24–28,44–47;
other portions retain pitch. Both timing controls use that same route.
Native FPS is measured, never inferred from eliminated-face counts. General
level integration and angular portal reduction remain future work.

[Italiano](VISIBILITY-DEV.it.md) · [Release notes](../../../RELEASE-NOTES-1.12.0.en.md)
