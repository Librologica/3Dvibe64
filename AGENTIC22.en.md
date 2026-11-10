# 3Dvibe64 1.15.2-dev-agentic22

Unpublished source development from delivered agentic21. Current qualification:
QUALIFICATION-AGENTIC22.json. Earlier AGENTIC21 notes/ledgers remain immutable
history. No release/tag, GitHub publication or stable promotion.

Technical Debug native profiles showed expensive repeated screen/color-cell
writes in Modes1/2. One physical C64 material row covers four logical scanlines.
The emitted screen/color tables must prove that grouping. The optimized code
tracks only a contiguous range of cells actually written with the same material
during one integer wire edge (Mode1), or one solid-face fill (Mode2).

Contained spans skip the duplicate writes. A connected one-sided extension writes
only previously unwritten columns, then restores the original start/end columns
before bitmap drawing. Two-sided extensions and disjoint intervals use full
writes and replace the cached range; no gap is ever claimed or colored. Cache row
state resets at every integer edge / solid-fill entry. Both buffers are isolated;
Mode2 patches its shared write target once per fill, not once per pixel/row.
Point/vertical material paths remain unchanged. The original bitmap raster,
dirty tracking, colors, draw order, geometry, clipping and precision are retained.

Selection requires exact known consumer bodies, the parent's proven private
material-pointer contexts, native table grouping, disabled VIC color policy and
disabled existing span-cache / small-viewport variants. Unknown shapes and
optional circle builds keep their parent path. Mode2 shares its trim code to fit
the original allocator windows; an oversized inline prototype was rejected.
No new standalone RAM variables or tables, no enlarged windows. Mutable code
operands store10 bytes of cache state in Mode1 and7 in Mode2. A Mode2 partial
extension can add one nested call (2 return-stack bytes); all paths balance it.

The design targets Turbo64x, where avoided physical color writes matter. Small
Mode1 CPU overhead at1x remains visible in native results and is not hidden.
All defaults, workloads, original music, LOD, frame presentation and quality are
unchanged. Modes3..8 retain agentic21. CPU replay validates correctness only;
FPS use actual PAL Turbo6510 at1/20/64x, original SID, warm128 then>=1024refreshes
(~20.429s). Long matched1x windows supplement the fixed historical index.
Technical Debug uses paused-only reads and matched PRG/labels; maincpu_clk is
MACHINE time, not accelerated CPU cycles. Never multiply it by64.

The20 public gates and separate development/docs audit apply. Three inherited
stable-publication-only tests are preserved and do not apply verbatim to this
unpublished development. Raw commands, programs, captures and diagnostics remain
external in ../evidence/, excluded from the source SDK archive. Hardware and NTSC
are not newly qualified. See the qualification ledger for exact validated scope.

Validation completed2026-11-02:54 buildable cases at1x/20x/64x,162 native cells,
648 matching captures,27 inherited build blocks and0 new blocks. Fixed index
126.591878108; agentic21 124.166609792; official
stable1.15.1 117.647645352; original stable1.15.0=100. Original
12 stress/36 cells, equal mode/speed weights and50/50 FPS/render remain unchanged.
Three ordinary repetitions per side cover6 Mode1/2 cases; three326.866s windows
per side cover4 heavy/stress cases at1x. Short1x count quantization is retained
in the historical index, not presented as sustained throughput. Original SID,
warm128 PAL refreshes then1024refreshes (~20.429s) per ordinary window.
36080 emitted cache span operations and3520 complete wire edges /1200 filled
primitives preserve bitmaps,screen/color arrays,dirty state,start/end and stack.
The20 public gates and source/docs audit pass. Independent cold rebuild reuses
126 parent observations and18 exact prototype observations, with18 new catalog
observations after complete identity checks. No altered program is synthetically
timed. Circle API4/6 retain4 identical programs/6 historical native observations
(no soundtrack asset in those API examples). Mode2 partial extensions can use2
extra return-stack bytes; no new standalone RAM/table or larger allocator window.
Modes3..8 remain agentic21. Native hardware and NTSC are not newly qualified.
This remains an unpublished development, not a stable release.
