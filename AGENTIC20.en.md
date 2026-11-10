# 3Dvibe64 1.15.2-dev-agentic20

Unpublished source development from delivered agentic19. Earlier qualifications,
reports and AGENTIC19 documents are immutable history. Current qualification:
QUALIFICATION-AGENTIC20.json. No GitHub release/tag or stable promotion.

Technical Debug measured exact painter-ordered raster spans for Mode6/7 at four
poses plus heavy ordinary cases. Overdraw exists mostly on parts of polygons;
the proposed small conservative rectangle cache rejected no complete polygon.
Occlusion culling is NOT promoted. The investigation instead found discarded
edge work before the existing fused Mode7 X/U/V/Q raster pass.

The known clipped-fan path now prepares the same integer Y interval and native
valid flag without tracing bounds that gr15 immediately clears and rebuilds.
For raw faces, a guarded prefix retains the exact native Q2 Y setup and tests
sample-row validity without discarded geometric edge walks. Its fast domain
is XQ2=0..511 and YQ2 inside the viewport; a connected closed polygon intersects
every sample row between its Y extrema. The original builder accepts any one
such edge point. NS=4*dx stays within its original11-bit magnitude domain.
Eligibility failures, other coordinates and unknown source shapes keep the
original builder, including its fault behavior. Raw/direct-Y checks, integer
pixel coverage, UV/shade/Q interpolation, draw order and materials are retained.
The original fused raster still computes all consumed bounds and attributes.

Only the known fused Mode7 path is selected; Mode6 keeps its original bounds
because its shade-edge pass does not replace geometric coverage. Optional circle
builds keep their parent path. No new RAM variables, lookup tables, peak data
stack or enlarged allocator windows. No approximation or quality/workload change.

Independent CPU checks compare active X/U/V/Q/shade arrays, validity/fault bytes
and balanced stacks on raw fractional/thin/degenerate polygons and clipped fans.
CPU oracles and Technical Debug diagnostics are NOT FPS. Native benchmarks use
PAL Turbo6510 1/20/64x, original SID music, warm128 and >=1024 measured refreshes.
Raw commands/results stay outside the SDK in ../evidence/. maincpu_clk is machine
time; never multiply it by64 to infer internal CPU cycles or hardware equivalence.

The20 public renderer/API gates plus development package/docs audit apply. The
three preserved stable-publication-only tests do not apply verbatim to this dev.

Validation completed on 2026-11-02:54 buildable cases at1x/20x/64x,162 native
cells,648 matching captures,27 inherited build blocks and0 new blocks. Fixed
performance-v1 index 123.103329739; agentic19 121.110691904;
official stable1.15.1 117.647645352; anchor1.15.0=100. The original
12 stress cases/36 cells, equal mode/speed weights and50/50 FPS/render definition
are unchanged. The short1x window counts only2–5 views on the heavy cases and
quantizes FPS gains: do not interpret its+25%/+50% as sustained throughput.
Three326.866s windows per side confirm+7.69% FPS for pure-7-heavy and+4.65%
for stress-7 at1x. Three ordinary windows per side confirm+18.27% and+9.74%
at64x respectively. These are deterministic replications, not independent random
samples. p95/worst and exact raw commands are in the external report/evidence.
Warm-up128 PAL refreshes, then1024 refreshes (~20.429s), original SID music.
6536 polygon cases/9032 fan triangles plus6 original terminal fault cases passed
the emitted-code oracle;20 public gates and the package/docs audit passed.
The full rebuild reuses144 parent observations and9 exact prototype observations
after PRG/all-numeric-symbol/workload/target/raw-file identity checks, with9 new
catalog observations. Public circle API4/6 retain4 identical programs and6
byte-preserved historical observations (no soundtrack asset in those API samples).
Mode6 and all other modes retain the parent renderer. Unpublished development.
