# Agentic27 — 1.15.2-dev-agentic27

Unpublished development from delivered agentic26. [Italiano](AGENTIC27.it.md).
Current ledger: [QUALIFICATION-AGENTIC27.json](QUALIFICATION-AGENTIC27.json).
Earlier versioned notes/ledgers remain immutable history. No public API change.

Projected undirected wire edges now use a bounded two-endpoint screen clipper
instead of repeatedly clipping a closed polygon with duplicated intersections.
It keeps the right/left/top/bottom plane order and calls the existing inside,
intersection, ratio, multiply and rounding helpers. It skips an axis pair only
when both original endpoints are proven inside it: interpolation of those
bounded coordinates cannot leave the interval. Rejected and degenerate lines
retain their visible/rejected geometry. There is no approximate clipping.

Polygon closing duplicates can rotate private endpoint order; the new pair may
be reversed. The three recognized compiler consumers draw or bucket an
undirected edge, whose rasterizer normalizes Y and horizontal X. A complete
compiler-call-context guard retains the parent for unknown private consumers.
Gouraud/UV carriers retain the parent, as do noninteger lps_active contexts.
The inherited polygon/near clipper and its generated-cap rules remain intact.
CPU correctness compares clipped geometry and the actual bitmap, screen/color
RAM and dirty metadata, not just endpoint order. CPU replay never supplies FPS.

Solid mixed profiles use the original bounded plus allocator and its fallback.
Pure wire1/2 run a separate single-helper placement after existing wire/raster
tuning, within a subset of the same original low/middle windows,0801..2000 and
4000..5c00. Sizing uses the actual assembler map; complete physical bitmap banks,
screens, font, runtime buffers and wire product LUT are excluded. No room means
parent fallback. No allocator window, data table, private state or scratch alias
is added. Helper code occupies real RAM; see actual ranges/bytes in the ledger.
Mode2 may retain its parent when the projected Q4 helper contract is absent.
Mode8, AnimatedMesh, quality, workloads, defaults, music, colors, camera,
geometry, line coverage and complete-view publication remain inherited.

Native qualification uses VICE Turbo6510 PAL1x/20x/64x, original benchmark SID,
128 refresh warm-up and at least1024 measured refreshes (~20.429s),16-pose route,
new complete views only. Matched targeted repetitions and long64x windows
supplement the unchanged performance-v1 original12 stress/36-cell index.
Technical Debug reads only in pause with same-build PRG/labels; maincpu_clk is
PAL machine time, not internal accelerated CPU cycles. Holdouts are final
qualification only. Hardware/NTSC are not newly qualified.

Only source/docs are delivered. No demos, scenes, models, music, PRGs, captures,
reference SDKs or validation projects in this dev or ZIP. Those, including all
rejected trials, commands and raw timing, remain external in 3Dvibe64_Verifiche_1.15.2-dev-agentic27_2026-11-05.
At every dev/release verify suite alignment and compare parent and stable1.15.1.
No publication or stable promotion is authorized.

Final qualification:81 cold builds,54 buildable cases /162 native cells,648 parent-identical captures,27 inherited blocks and0 new.22 default public gates pass. Overall index 134.675573998 vs parent 131.672274975 (+2.281%), stable1.15.1 117.647645352. StressMode1 at64x 10.817894 → 12.531136 FPS (+15.837%), mean render -11.494%. Three matched81.716s64x windows confirm +15.968% FPS; three326.866s1x windows give 0.204977 → 0.235571 FPS (+14.925%). The original20.429s1x score remains quantized; long windows do not replace the fixed index.16512 clipping pairs match geometry/rejection, including512 noninteger fallbacks;4047 visible integer pairs match complete bitmap banks, screen/color RAM and dirty metadata under four patterns.951 internal endpoint order reversals preserve rendered output.695 helper-code bytes plus3 trampoline bytes, no new state/table; actual scene ranges are in the ledger. Technical Debug pose0:82039 →72675 machine cycles. Mode8/AnimatedMesh inherited.424 source/doc files, external evidence only.
