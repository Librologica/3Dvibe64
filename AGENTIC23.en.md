# 3Dvibe64 1.15.2-dev-agentic23

Unpublished development from delivered agentic22. Current ledger:
[QUALIFICATION-AGENTIC23.json](QUALIFICATION-AGENTIC23.json). Earlier ledgers and
AGENTIC notes are immutable history. No stable promotion or GitHub publication.

Technical Debug profiles identified integer contour tracing and the Mode5
background outline as expensive work. A quotient/remainder walker now builds
the exact inclusive left/right bounds for known Mode2/3/4/5 integer paths.
It normalizes endpoint order, preserves the original single-point diagonal
rows, and merges only the same covered pixels into the existing bounds.
The raw native XYQ2 walker, shading, clipping, geometry and draw order retain
their parent implementations. Mode2 keeps its connected wire raster; its
unreachable 16-bit fallthrough is removed only with the complete existing
wire slope classifier and bounded native viewport. Modes3/4 replace the old
integer kernel rather than add a duplicate.

Mode5 groups its background outline into exact row spans. Interior bitmap bytes
are cleared together; partial endpoints use the original start/end masks. Both
physical bitmap scanlines are written, using table-proven row adjacency. This
selects the existing VIC-II background register, preserving its configured
color. Screen, color RAM, dirty tracking and material state are not written by
the outline, exactly as before. Endpoint order, horizontal, vertical, diagonal
and connected shallow-edge coverage remain exact. No reduced quality or LOD.

Automatic selection requires exact known source bodies, 160x100 native tables,
unchanged masks and adjacent bitmap rows, no lazy bounds and no circle API.
Unknown bodies, externally referenced private labels, other viewports and
unsupported wire classifiers retain the parent path. No standalone RAM/table
allocation or enlarged allocator windows. Existing scratch bytes are reused;
the nested Mode5 partial-span writer can add at most2 return-stack bytes.
API, arithmetic precision, textures, defaults, workloads and original music
remain unchanged. Modes1/6/7/8 keep agentic22 rendering.

Performance qualification uses actual VICE Turbo6510 PAL at1x/20x/64x, original
SID, warm128 refreshes then at least1024 refreshes (~20.429s). Count only new
complete views; preserve raw commands, PRG/labels hashes, FPS, mean render time,
p95/worst intervals and captures. The fixed performance-v1 basket/weights and
Stable1.15.0=100 anchor are unchanged. Longer matched1x runs supplement coarse
short-window counts. CPU replay checks correctness only. Technical Debug uses
same-build symbols and paused reads; maincpu_clk is machine time, not internal
accelerated CPU cycles. Hardware and NTSC are not newly qualified.

Validation completed: 54 buildable cases, 162 native cells, 648 matching captures; 27 inherited build blocks and0 new blocks. Fixed index 129.982556846; agentic22 126.591878108; official Stable1.15.1 117.647645352. Three repetitions per side on8 Mode2/3/4/5 cases; three326.866s windows per side on4 heavy/stress Mode2/5 cases at1x.20 public gates and development/docs audit pass. Four circle API programs retain exact PRG/label identities and6 prior native observations (API examples have no soundtrack asset; outside fixed index). This is an unpublished development.
