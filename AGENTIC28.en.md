# Agentic28 — 1.15.2-dev-agentic28

Unpublished development from delivered agentic27. [Italiano](AGENTIC28.it.md).
Current ledger: [QUALIFICATION-AGENTIC28.json](QUALIFICATION-AGENTIC28.json).
Earlier versioned notes and ledgers remain immutable history. No public API change.

Ordinary legacy-plus affine Mode7-C keeps the exact integer UV/Q DDA, half-open
coverage, closed caps, lighting/Bayer equation, texture addressing and final
public UV/Q state. It replaces repeated UV immediate-operand patching with
span-local values in saved existing private registers, precomputes corrected
steps, and represents private errors as E-D modulo256. Carry then decides the
same correction without a redundant comparison. Q uses the same exact scheme.
The closed raster core keeps U in X; the compositor uses Y for Q and the partial
writer uses Y for pixel phase. Four normal full-byte Q advances are inline;
stable-light spans retain deferred final-Q publication and the original bands.
The stable sampler still caches texture-page/palette operands; only the UV
constant patch stream is removed. No interpolation approximation is introduced.

All16 borrowed private bytes are saved and restored (parent4). The known fill
loop saves once per face and calls the shared span core; the standalone span
entry saves/restores independently. Mutable UV/Q state is published before the
original final-Q helper. No new zero-page address/global scratch alias, data
variable or data table is allocated. Existing values are borrowed within a
checked call lifetime, not assumed globally free. Extra stack bytes and wrapper
return addresses are a real cost: the16-byte save replaces the parent4-byte save,
and an inline-gate setup also temporarily pushes A. Stack balance, all borrowed
values and both complete physical bitmap banks are checked by emitted-code
oracles. Private fill A/flags are volatile to the recognized compiler consumers;
public frame/AnimatedMesh API and complete-view commits remain unchanged.

Ten exact compiler-source region contracts and the complete private call-site
contexts gate the pass. Changed/unknown consumers or callees, other compositors
and VIC color policy keep the delivered parent's complete Mode7 pass and biased
UV implementation. Existing bounded plus allocation and assembler limits remain
in force; no memory window is enlarged. Code occupies real RAM and every cold
build must pass its actual map checks. The wire clipper, Modes1..6/8 and
AnimatedMesh behavior are inherited from agentic27.

Qualification: VICE Turbo6510 PAL1x/20x/64x, original benchmark SID active,
128-refresh warm-up (~2.554s), >=1024 measured refreshes (~20.429s),16-pose route.
Only new complete views count. p95/worst intervals, raw clocks, commands, PRG and
numeric-label hashes stay external. Technical Debug uses same-build PRG/labels,
paused reads and no live sampling: maincpu_clk is PAL machine time, not internal
accelerated CPU cycles. Holdouts are final qualification only. The unchanged
performance-v1 uses12 stress/36 cells, equal mode/speed weights and50/50 FPS and
inverse render time, with stable1.15.0=100. Compare parent and stable1.15.1 at
every dev/release and recheck suite/adapter alignment. Hardware and NTSC are not
newly qualified. Improvement depends on span/shade distribution; presentation
quantization can keep FPS unchanged despite a shorter render.

Only sources/docs are delivered. No demos, scenes, models, music, programs,
captures, reference SDK or validation projects belong in this dev/ZIP. All trials
and evidence, including rejected prototypes, remain in 3Dvibe64_Verifiche_1.15.2-dev-agentic28_2026-11-05. No publication
or stable promotion is authorized. Final measurements are in the current ledger.

Compiler placement also uses short host scratch directory names (v0, v1, ...). Long Windows paths previously made64tass fail to write sizing labels, and the allocator misclassified the tool error as a layout failure, silently selecting a slower variant. Strategy order,60000-node budget, RAM windows, math and quality are unchanged; full strategy names remain in reports. This removes path-dependent optimization selection.

Final qualification:81 cold builds,54 buildable cases/162 native cells,648 parent-identical captures,27 inherited blocks and0 new.22 default public gates pass. Overall index 135.434561314, parent 134.675573998 (+0.564%), stable1.15.1 117.647645352. StressMode7 at64x 8.272507 → 8.370407 FPS, mean render -5.770%. Three matched81.716s64x windows: 8.272507 → 8.358169 FPS (+1.036%), render -5.795%. Three326.866s1x windows: 0.137671 → 0.146849 FPS. Span oracle:12880 endpoint pairs,17424 shade-phase cases; full-fill oracle:256 faces/8218 rows, both banks, all16 borrowed values and balanced stack. These are correctness callbacks, never FPS.
