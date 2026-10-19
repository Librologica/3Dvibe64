# LIGHT-01 — static vertex lighting bake, 1.15.0

> Stable1.15.0 source SDK prepared locally; not published online. [Status and support](../../../RELEASE-STATUS.en.md).

Stable release 1.15.0: [current optimizations](../../../RENDER-OPTIMIZATIONS.en.md), [external inputs](../../../EXTERNAL-INPUTS.en.md). All demonstration projects and raw native evidence remain external to the source distribution.


Current 1.12.0 distribution ships the reusable module only. New demo projects/assets are excluded. Source captures, checkpoint numbers and native measurements below describe historical external proofs. Native project builds require explicit `--project-source`; see the [integration guide](../../../GAMEPLAY.en.md).


`static-light` extends animated-textures. The host bakes point lights and
static divider shadows into existing floor Gouraud tables. Door, two
billboards, animated textures, precise 96 × 60/all 60 rows and LOD 14–22 remain.

`--light-bake` replaces `assets/light-bake.json`: schema 1, `enabled`,
`ambient`, `biasWU`, `receivers`, `occluders`, `lights`. Lights have ID,
public XYZ position, `radiusWU`, `strength`:1–8 lights, ambient 0–32,
strength 0–64, radius 1–128 WU, Q8-representable parameters.

Each sample sums ambient and normalized Lambert contributions with linear
radius attenuation. A segment to each light is tested against selected static
triangles; a hit removes that contribution. Round/clamp final values 0–32.
Normal bias avoids self-shadowing. Edge intersections are opaque; segment
endpoints and parallel/coplanar grazing rays are excluded. A light coincident
with the sample contributes ambient only because direction is undefined.

After Q8 conversion, the bake uses integers, integer roots and determinant
ratios, without randomness/time/path dependencies. Private mesh X/up/forward
is converted to public coordinates with source winding handled. One visible
identity-transformed mesh/object is supported; incompatible transforms and
degenerate geometry are rejected.

Outputs: `reports/static-light.bin`, `static-light.json`,
`static-light-surfaces.json`. `LB01` payload: magic, one-byte count and
four-byte records (face index and three corner levels); four records=21 bytes.
Reports record scene/config/input/output hashes, individual contributions and
blocking triangles. The binary is a host artifact, not extra resident memory.
Twelve levels replace existing shader-table bytes; code, block sizes,
allocation and free 1428 bytes remain identical to animated-textures.
`enabled:false` retains manual levels and reproduces that checkpoint.

Receivers must already be untextured Gouraud surfaces. Textured walls/flat
faces are unchanged. Actor nodes 14/15 and mobile door faces 28–31 are forbidden
as receivers/occluders. Mobile shadows need another system. Vertex density
limits shadow detail; runtime only interpolates the baked samples.

Analytical fixtures cover Lambert, falloff, two-sided shadows, endpoint rules,
axes, determinism, binary round-trip and invalid inputs. An independent
floating-point plane/rectangle reference checks all twelve samples and
rebuilds an identical PRG through explicit levels. Six native camera views
confine changes to the floor with UI/palette/sampler intact; earlier texture,
billboard and door cases are repeated. Matched FPS differs only in light data.

[Italiano](LIGHT-DEV.it.md) · [Release notes](../../../RELEASE-NOTES-1.12.0.en.md)
