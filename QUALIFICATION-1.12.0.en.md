# Native qualification â€” 1.12.0

Source release, no demos/examples or media included. [Machine-readable results](QUALIFICATION-1.12.0.json).

| Case | FPS before | FPS after | Change | p95 before/after ms | Worst before/after ms |
|---|---:|---:|---:|---:|---:|
| Mode7 texture | 6.4858 | 7.0977 | +9.43% | 219.45/199.50 | 239.40/219.45 |
| Mode7 uniform | 20.1918 | 23.0064 | +13.94% | 59.85/59.85 | 59.85/59.85 |
| MAT-01 flat spans | 8.8599 | 8.9252 | +0.74% | 119.70/119.70 | 139.65/139.65 |
| Mode6 room | 8.4683 | 8.4683 | +0.00% | 119.70/119.70 | 139.65/139.65 |
| Mode6 overlapping walls | 13.7794 | 15.0276 | +9.06% | 79.80/79.80 | 79.80/79.80 |

Target VICE Turbo6510 PAL312Ã—63 multiplier64, explicitly silent, filter0, default VICE palette, safe presentation, no warp. Warm-up101 refresh=2.014981emulated seconds. Texture/uniform/Mode6:2048refresh=40.858229seconds; position fixed with yaw/pitch oscillation, two1024tick periods, no paused phase. MAT-01:3072refresh=61.287343seconds, full48-key moving orbit. Standard precise Q8, full rows. Mode7 controls/variants retain gradual texture LOD28/44WU; Mode6 has no textures or geometry LOD. MAT-01 keeps its precise profile, viewport and14/22WU LOD. Only complete new views after buffer presentation are counted; repeated refreshes, host time, warp speed and CPU replay are excluded. Raw commands, timestamps, RAM, source records and images are external in the separate qualification folder.

Positive overlapping-wall case skipped 420 quad occurrences in 645 passes (cumulative counters, including warm-up). The room case has no hidden quads and no measured gain. Both combine inside-planes and occlusion, so this does not isolate either optimization. Mode6 evidence is reused only where final recompilation yields the same PRG bytes and launch conditions. Every optimized case matches its control at five native frozen simulation poses:25 comparisons, zero different pixels in the 3D area. Image runs never measure FPS.

16 self-contained public gates pass. All42 frozen Q8 PAL/NTSC references and8 Mode7 references match original hashes; the ordinary LF generator is preserved. Assembled contracts cover3006divisions,260clip cases,5000carrier advances,5643camera products,1600vertices,2907MATflat spans,2336bulk spans,1006occlusion decisions,1156constant-Gouraud intervals,51native cache assignments,1024synthetic SID calls and1000pool transitions. Perspective rectangle tests include large pitch/roll and viewport clamping. These routine tests prove correctness, never estimate FPS. Optional support is bounded caller glue, not a complete procedural game or universal SID loader.

The first CRLF-converted preparation was rejected and replaced; its results are not final release evidence. Earlier official releases, private development and frozen demos are preserved. Known Mode4 and lit-shader limitations remain explicit. [Contracts](RENDER-OPTIMIZATIONS.en.md) Â· [Support](ADAPTER-SUPPORT.en.md) Â· [Tests](TESTING.md).
