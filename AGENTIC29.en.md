# Agentic29 — 1.15.2-dev-agentic29

Unpublished development from delivered agentic28. [Italiano](AGENTIC29.it.md).
Current ledger: [QUALIFICATION-AGENTIC29.json](QUALIFICATION-AGENTIC29.json).
Earlier versioned notes and ledgers remain immutable history. No public API change.

The guarded ordinary legacy-plus affine Mode7-C path keeps exact integer UV/Q
DDA, coverage/tie rules, closed caps, texture addressing, lighting/Bayer output,
material behavior and final published UV/Q state. Changes are general compiler
transformations, with no benchmark/scene branches or changed defaults:

* Packed ink uses the retired p1lo U shadow after U moves into X. The parent16
  saved private bytes still protect both the standalone span and whole-face fill.
  `(Uhi XOR V) AND15 XOR V` exactly composes `(V AND240) OR Uhi` without spilling
  a temporary sampler index. Carry from the last U shift is preserved.
* Stable-light full-byte selection starts at the first completely aligned byte
  instead of a24-pixel minimum. Partial coverage and deferred final Q are unchanged.
* Shade setup handles abs(deltaQ)<the original untrimmed denominator directly:
  quotient0, remainder abs(deltaQ), original sign/error. Other values and zero
  denominator retain the general DDA. The same denominator is reused for UV.
  This private setup scratch is overwritten by UV setup before any consumer.
* Known private edge/fill consumers allow sentinel-only bounds initialization.
  Each visited row initializes both endpoint UVQ values; attributes of empty,
  skipped rows become unspecified private scratch. Public/state/pixels are
  unchanged. A once-per-face proof checks every triangle/quad vertex against
  the active vertical range. Monotone edge stepping then skips redundant range
  comparisons; trimmed/out-of-range faces use the original per-point checks.

The transformations require known caller contexts/shapes; unknown/custom
consumers retain their parent behavior. No new zero-page aliases, persistent
variables or data tables are allocated. Existing private lifetimes are checked;
extra helper code occupies real RAM in the original bounded allocator. The
range helper adds one temporary JSR return address, no extra saved data bytes.
The inherited compiler short scratch paths and placement strategy/budget/windows
remain unchanged. Other modes and AnimatedMesh retain delivered agentic28 code.

Technical Debug uses same-build PRG/labels, paused reads and no live sampling.
maincpu_clk is PAL machine time, never accelerated CPU cycles. Native final
qualification uses PAL Turbo6510 at1x/20x/64x, original SID active,128-refresh
warm-up (~2.554s), at least1024 measured refreshes (~20.429s),16-pose routes.
Only new complete views count; raw commands, hashes, intervals/p95/worst and
stationary/moving phases stay external. Longer repeated windows supplement
sparse1x observations and presentation-quantized64x FPS. CPU callbacks only
prove correctness. Hardware and NTSC are not newly qualified.

The unchanged performance-v1 index uses12 stress cases/36 cells, equal mode
and speed weights and50/50 FPS/inverse rendering time, stable1.15.0=100.
Every dev/release must verify benchmark/adapter alignment and compare with the
parent and official stable1.15.1. Holdouts are final qualification only.

Only sources/docs are delivered; all trials and evidence remain in the external
3Dvibe64_Verifiche_1.15.2-dev-agentic29_2026-11-06 directory. No demos/scenes,
models/music, PRGs, captures or reference SDK are included. No stable promotion
or publication is authorized. Final measurements are recorded in the ledger.

Final qualification:81 cold builds,54 buildable cases/162 native cells,648 parent-identical captures,27 inherited blocks and0 new.22 default public gates pass. Overall index 136.266540957, parent 135.434561314 (+0.614%), stable1.15.1 117.647645352. StressMode7 at64x 8.370407 → 8.859904 FPS, mean render -5.322%. Three matched81.716s64x windows: 8.358169 → 8.872142 FPS (+6.149%), render -5.303%. Three326.866s1x windows: 0.146849 → 0.152968 FPS. Span oracle:12880 endpoint pairs,17424 shade-phase cases; full-fill oracle:256 faces/8218 rows, both banks, all16 borrowed values and balanced stack. These are correctness callbacks, never FPS.
