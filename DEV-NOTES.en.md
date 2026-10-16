# Development provenance — 1.11.0

This is the official local source release derived from dev13/cubes-restored,
not an unfinished dev12 snapshot. The original development checkout and
previous releases remain preserved. Online publication is deferred.

Dev1 imported the masked/outlined source profiles; dev2 mixed face shaders;
dev3 configured entity/events/local collision; dev4 sliding door/passability;
dev5 two shared-asset billboards; dev6 texture pages/UV scroll; dev7 host light
bake; dev8 conservative connectivity PVS; dev9 shared source mesh; dev10 clip
controls/camera roll; dev11 external room groups; dev12 common level/budget;
dev13 separate bounded integration, corrected to retain all three cubes.

These stages remain scoped to their profiles. The ordinary renderer and
Mode 8 keep 1.10.2 bytes/defaults; foundation-1.10.2 stays sealed. The precise
1.10.3-dev1 span optimization is only an explicit input of the separate
Underworld adapter, not a universal merge. It now reuses 2904 post-init UI
bytes, not the original 1516. WORLD-01 still does not apply its proposed 3759 byte
recovery or automatically combine every module.

The release adds complete EN/IT manuals, cross-links, source-only packaging
and host-tool path overrides. Source configuration version fields become
1.11.0; runtime compatibility is checked by exact program hashes, not version
labels alone. No demo binaries/video/music are distributed. Qualification,
known limits and evidence policy: [release qualification](QUALIFICATION-1.11.0.en.md).
Current usage: [GAMEPLAY](GAMEPLAY.en.md); remaining work: [roadmap](ROADMAP.en.md).
