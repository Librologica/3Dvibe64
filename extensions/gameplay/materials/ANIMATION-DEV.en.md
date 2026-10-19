# TEX-01 — texture frames and UV scrolling, 1.15.0

> Stable1.15.0 source SDK prepared locally; not published online. [Status and support](../../../RELEASE-STATUS.en.md).

Stable release 1.15.0: [current optimizations](../../../RENDER-OPTIMIZATIONS.en.md), [external inputs](../../../EXTERNAL-INPUTS.en.md). All demonstration projects and raw native evidence remain external to the source distribution.


Current 1.12.0 distribution ships the reusable module only. New demo projects/assets are excluded. Source captures, checkpoint numbers and native measurements below describe historical external proofs. Native project builds require explicit `--project-source`; see the [integration guide](../../../GAMEPLAY.en.md).


`animated-textures` extends multiple-billboards, retaining door, mixed
materials, UI 96 × 60, exact sampling on all 60 rows and LOD 14–22. One wall uses
four frames, another signed integer U/V scrolling. Build/qualify with this
profile through the [gameplay entry point](../../../GAMEPLAY.en.md).

`--texture-animation` replaces `assets/texture-animation.json`. Schema 1 has
`running`, `sourceTexture`, `asset`, `materials`. Each material group declares
ID, source face IDs, `frames`, `ticksPerFrame` and `scroll:{step:[u,v],ticks}`.
Counters/cursors are separate. A face belongs to one group and must already
use the texture shader and named source. Flat, Gouraud and actor nodes 14/15
are rejected as animation receivers.

Zero/two groups, one common 16 × 16 atlas of 1–4 frames, up to 16 sequence entries,
durations 1–255 ticks and integer UV steps−15..15 texels/axis. Offsets wrap
modulo 16. No alpha blending or temporal interpolation. Pigments are resident
indices 1–3. Frame 0 must match the original texture; every frame must keep its
pigment histogram so existing modal/accent LOD colors remain correct.
Changing palettes/histograms needs a different adapter.

`materials:[]` omits all new code/tables/pages and reproduces the multiple-
billboards checkpoint. `running:false` retains code/allocation but freezes
cursors/offsets for matched native timing. Tick only updates state; binding
selects a source page rather than copying texels each frame. The first page
is reused; three extra pages cost 768 bytes plus 255 alignment reservation.

UV translation occurs after exact projective division and before texture
index construction. Full-byte and partial-pixel paths agree; fraction and
wrap preserve sampler rules. Unconfigured materials retain their original
path. Binding/tick preserve caller registers/flags; state is constant during
a complete draw and IRQ does not reenter selection/shading.

Default free gaps 1428 bytes,1576 less than multiple-billboards: runtime 305,
helper 146, state/tables 64, pages 1023 plus call-site/allocation changes.
Inherited native evidence:11 samples across 0–128 ticks,24 frozen ticks,
12 independent 16000 byte texture/frame/UV/clipping/LOD oracles,24 UI views and
three LOD traces at 14/18/22 WU (weights 16/8/0). Billboard/door cases are repeated.
FPS uses intact automatic programs and counts only newly presented full views.

[Italiano](ANIMATION-DEV.it.md) · [Release notes](../../../RELEASE-NOTES-1.12.0.en.md)
