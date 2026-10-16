# Release notes — 1.12.0

Source-only release available in the GitHub repository. No demos or examples
are included, including preexisting ones. No PRG, music, artwork or captures.

## Changes

Promotes dev14's explicit camera-extremes (Mode7),zero-terms,degenerate-faces,
live-attributes,adapter-outcodes and MAT-01 flat-span-cache. Adds inside-planes,
bounded-divide,packed-samples and unlit unrolled-advance. Adds allocator-managed
conservative wall-occlusion adapter code, static pattern/palette helpers,
constant Gouraud span dispatch and optional original-DDA expansion. Host texel
page preparation uses only caller data. These retain exact arithmetic and
original clipping/shader fallbacks within their documented domains.

Optional adapter support supplies a bounded resident-pool callback manager,
parameterized camera offset tables and an audited PSID wrapper interface. They
are primitives, not complete procedural levels, autonomous camera tours or
bundled songs. Existing gameplay modules remain experimental within their
original bounded contracts. Mode8 runtime/normalized16 are not optimized here.

## Migration

Always provide -SceneFile/--scene. Gameplay additionally requires external
--project-source/-ProjectSource; preset engineVersion must be1.12.0. No
examples/validation assets are shipped; use your own scenes and test inputs.
No changes to ordinary quality/LOD defaults. All new flags are opt-in. Select
only options measured useful for the particular shader/project. Read the full
[optimization contract](RENDER-OPTIMIZATIONS.en.md), [support ABI](ADAPTER-SUPPORT.en.md),
[external input guide](EXTERNAL-INPUTS.en.md) and [qualification](QUALIFICATION-1.12.0.en.md).
English/Italian manuals, indices, CLI coverage and package exclusions are audited.

Migration: replace historical `all` experiment selections with an explicit compatible list; `all` now includes the new flags and may reject profiles that previously accepted the older set.
