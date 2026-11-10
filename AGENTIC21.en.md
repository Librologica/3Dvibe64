# 3Dvibe64 1.15.2-dev-agentic21

Unpublished source development from delivered agentic20. Current qualification:
QUALIFICATION-AGENTIC21.json. Earlier AGENTIC20 notes, ledgers and qualifications
remain immutable history. No release/tag, GitHub publication or stable promotion.

The known Mode6 integer convex-bounds path now divides abs(dx) by dy once per
edge. Each scanline applies the signed quotient and at most one exact remainder
correction, updating only its minimum/maximum bounds. It preserves the original
inclusive horizontal runs and the original single-point diagonal/vertical rows,
both edge orders, endpoint bytes, Y and fullcount. The original native Q2 walker
and its faults remain unchanged. No geometric approximation or reduced coverage.

Shade samples select the nearer bound using an exact9-bit midpoint for ordered
bounds, with original tie behavior. Coincident bounds select left; reversed
bounds retain the original absolute-distance calculation. Range checks remain.
The old shade pass initializes both arrays to vertex0. If every active vertex
has that same shade, those arrays are already exact and edge interpolation ends
early. Varying faces retain the original interpolation. The invariant initial
shade load is hoisted from its row loop. Private edge scratch remains volatile.

Selection requires the exact known Mode6 source body and disabled wire, outline,
lazy-bound and wire-specialized consumers. Unknown shapes and optional circle
builds keep the parent path. Mode7 and all other modes retain agentic20. No new
RAM variables, tables, peak data stack or enlarged allocator windows. Defaults,
scene/route/music, precision, LOD, clipping, materials and draw order are unchanged.

Technical Debug profiled parent Mode6/7 and measured actual span distributions.
The constant-texel UV hypothesis was not promoted: the measured domains are too
small to establish a net benefit after setup/state reconstruction. CPU oracles
check emitted code only; they are not FPS. Final native validation uses PAL
Turbo6510 1/20/64x, original SID music, warm128 then>=1024 refreshes (~20.429s).
Heavy1x results need longer matched windows to reduce frame-count quantization.
maincpu_clk is MACHINE time; never multiply it by64 to infer CPU cycles.

The20 applicable public gates and separate development/docs audit apply. Three
stable-publication-only tests remain preserved and do not apply verbatim to an
unpublished development. Raw programs, commands, snapshots, captures and reports
are external in ../evidence/, not included in the source SDK archive. Hardware
and NTSC are not newly qualified. See the closed qualification ledger for its exact validated scope.

Validation completed on 2026-11-02:54 buildable cases at1x/20x/64x,162 native
cells,648 matching captures,27 inherited build blocks and0 new blocks. Fixed
performance-v1 index 124.166609792; agentic20 123.103329739;
official stable1.15.1 117.647645352; anchor1.15.0=100. Original
12 stress cases/36 cells, equal mode/speed weights and50/50 FPS/render definition
are unchanged. Heavy1x short-window gains are quantized; supplementary matched
three326.866s windows per side are reported separately, not substituted into
the fixed historical index. Three ordinary windows per side cover3 Mode6 cases.
Warm128 PAL refreshes, then1024 refreshes (~20.429s), original SID music active.
18072 integer edges,177289 shade samples,6536 polygons/9032 fan triangles,
including>1300 constant-shade polygons and6 original terminal fault cases passed
emitted-code correctness checks. The20 public gates and development/docs audit
passed. The cold full rebuild reuses144 parent observations and9 exact prototype
observations after PRG/all-numeric-symbol/workload/target/raw-file identity checks,
with9 new catalog observations. Circle API4/6 retain4 identical programs and6
byte-preserved historical observations (no soundtrack in those API samples).
The qualification ledger is now closed with these explicit existing limitations.
Mode7 and other modes retain agentic20. Unpublished development, not a stable.
