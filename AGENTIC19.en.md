# 3Dvibe64 1.15.2-dev-agentic19

Unpublished development from delivered agentic18. Earlier qualifications and
AGENTIC18 documents are immutable history. Current qualification:
QUALIFICATION-AGENTIC19.json. No GitHub release, tag or promotion is included.

Technical Debug's vice_link.py identifies material-cell handling and raster
setup as costs worth reducing. Diagnostics use persistent symbol breakpoints,
the native profiler and paused-only stopwatch reads. maincpu_clk is elapsed PAL
machine time, not internal accelerated CPU cycles. Diagnostic timings are not FPS.

Known volatile-pointer material writers now use the column directly in Y and
row-origin screen/color pointers. Pixel fillers derive the adjacent physical
row pointer from the first; actual emitted tables must prove row1=row0+1 and
even row origins and offsets. Selected solid/pattern/direct fillers also read
row tables directly after material handling, avoiding temporary row copies.
Unknown shapes keep parent code. row0lo/hi,row1lo/hi and material pointers are
private volatile scratch in those fillers; public API and pixel coverage do
not change. No new RAM variables, tables, data stack or allocator windows.

Defaults, image quality, scenes, routes, music and index weights are unchanged.
Benchmarks and raw diagnostic data stay outside the SDK in ../evidence/.
The inherited three stable-publication-only gates do not apply verbatim to an
unpublished development.20 renderer/API gates plus the separate development
metadata/documentation audit are required. The distribution gate expects this
exact dev version; legacy-plus source hashes use the current RELEASE ledger.

Native validation complete / Verifica nativa completata:54 cases at1/20/64x,
648 matching captures,27 existing build blocks,0 new blocks. Fixed index
121.110691904; agentic18=120.207624484; stable1.15.1=117.647645352;
anchor1.15.0=100. Three runs per side on3 targeted cases,6 supplementary public
API runs. Warm128 PAL refreshes then1024refreshes (~20.429s), original SID active.
Original timing flags retained; unresolved0. See external REPORT.html/evidence.
Unpublished development / Sviluppo non pubblicato.
