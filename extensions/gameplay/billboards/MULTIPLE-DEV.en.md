> Development edition 1.15.0-dev1; inherited1.14.0 contracts remain unless explicitly extended in [exact rendering](../../../EXACT-RENDER.en.md).

# BB-03 — two billboard instances, 1.13.0

Stable release 1.14.0: [current optimizations](../../../RENDER-OPTIMIZATIONS.en.md), [external inputs](../../../EXTERNAL-INPUTS.en.md). All demonstration projects and raw native evidence remain external to the source distribution.


Current 1.12.0 distribution ships the reusable module only. New demo projects/assets are excluded. Source captures, checkpoint numbers and native measurements below describe historical external proofs. Native project builds require explicit `--project-source`; see the [integration guide](../../../GAMEPLAY.en.md).


`multiple-billboards` extends door-entity with two independently positioned,
sized and animated characters. UI 96 × 60, exact perspective on all 60 rows and
LOD 14–22 remain. Build/qualify with the corresponding `--profile` and a new
external output; see [gameplay](../../../GAMEPLAY.en.md).

Schema 2 in `assets/gameplay-scene.json` accepts one/two `billboards` with
unique IDs. The first guardian owns the existing interaction/door binding;
the second is visual, with no second collider/interaction system. Idle/used
frames and cadence are independent: the second uses `sc_state`, the first
`bc_state`. Default idle cadences are 5/8 simulation ticks, independent of draws.

Both use one shared 16 × 32 asset with at most six frames and the resident
palette. Source storage is 3072 bytes for the default asset under I/O; one
512 byte cache is decoded when each instance draws. Distinct assets are
rejected by this adapter. Optional `visibleBillboards` lists visible IDs;
omission shows all. One/two-visible controls retain both descriptions,
geometry, route, code, allocation and state/projection updates; only the
initial visibility mask differs.

Reserved actor nodes 14/15 hold instance rectangles, frame and depth before
bucket construction. Full Q8 depth including fraction decides mutual order,
then distinct buckets preserve it. Equal-depth ties favor the first configured
ID. Screen-parallel planes have constant depth across each rectangle; inclined
intersections are outside this contract.

The near threshold is 4 WU inclusive; the whole plane is rejected below it.
Supported sizes keep the projected DDA within 8 bit range. All four viewport
edges preserve nearest-neighbor correspondence to the original rectangle:
clipping does not stretch the visible part or write outside the 3D window.

Instances stay inside the convex room and wholly in front of Y=8 for the
supported camera envelope, up to 14° pitch. The compiler conservatively rejects
wall/divider crossings. The rear divider/door correctly masks both instances
except through the aperture. Arbitrary geometry, more than two instances,
different assets/palettes and inclined planes are not supported. No general
level solver is added; ordinary exporter, Mode 8 and other profiles are separate.

Inherited evidence:64 native UI/clipping views,14 composition cases with three
16000 byte comparisons each, reversed order,0.25 WU separation, exact ties,
near 4 and 4−1/256, hidden/backward characters, transparency/opaque black and
door states. Seven tick samples verify cadence;20 door cases are repeated.
Default free gaps 3004 bytes,498 less than the door profile. Historical counts
refer to their recorded profile/hash; raw data and native FPS are external.

[Italiano](MULTIPLE-DEV.it.md) · [Release notes](../../../RELEASE-NOTES-1.12.0.en.md)
