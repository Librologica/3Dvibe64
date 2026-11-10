# Agentic25 — 1.15.2-dev-agentic25

Unpublished development from delivered agentic24. [Italiano](AGENTIC25.it.md).
Current ledger: [QUALIFICATION-AGENTIC25.json](QUALIFICATION-AGENTIC25.json).
Earlier versioned ledgers are immutable history. Inherited AnimatedMesh v1 and
all legacy-plus Mode1–7 runtime/API sources retain their agentic24 bytes.

The Mode8 multi backend now replaces cached projected profiles with a bounded
second-chance clock. Hits mark a slot referenced. On a miss the clock clears
referenced flags while scanning and evicts the first unreferenced slot; empty
slots are accepted immediately. Eviction still invalidates the old key before
the new profile is generated. Full/lazy entries share the same slot identity.
All reference flags reset per complete view, together with the existing cache.

The cache remains32 profiles /4096 bytes.32 added reference bytes live only at
$ca00..$ca1f in the existing $ca00..$caff layout_support window, with assembler
bounds; no buffer/scratch alias or enlarged window. Coefficient/state accounting
is480 bytes, of which32 are replacement state. Code remains inside the original
low-code limit $3000. Both auto and interactive multi templates implement the
policy; mono-opaque and mono-portals templates are unchanged. Projection,
rounding, lazy16-column sampling, geometry, collision, camera, music, font,
colors, image publication and quality/defaults retain their original behavior.

Technical Debug uses paused reads with same-build PRG/labels; maincpu_clk is
machine time, not internal accelerated CPU cycles. Native performance uses
VICE Turbo6510 PAL1x/20x/64x, original benchmark SID, warm128 then1024 refreshes
(20.429s), complete new views only. Three matched81.716s windows at64x supplement
the fixed score. Existing performance-v1 cases and weights remain unchanged.
CPU callback oracles verify correctness only. Holdouts are final validation,
never tuning. Hardware and NTSC are not newly qualified.

All builds, reference copies, rejected trials, captures, native clocks and
commands stay outside this source-only dev and its ZIP, in
3Dvibe64_Verifiche_1.15.2-dev-agentic25_2026-11-04. No demos, scenes, models,
music, PRGs or validation projects are included. No stable promotion or GitHub
publication is requested. Read the qualification ledger for exact verified scope.

Final validation:54 buildable cases /162 native cells,648 matching captures,27 inherited build blocks and0 new. Fixed index 130.594894169; parent 129.982745981; stable1.15.1 117.647645352. Mode8 stress64x FPS 37.593407 → 46.991758 (+25.000%); mean render time +0.819%. Three matched81.716s windows per side confirm the throughput result.5120 emitted cache requests match parent samples and preserve slot/key invariants.22 default public gates pass. Canonical multi auto low-code margin:6 bytes; interactive:1210 bytes. Auto native-qualified at1/20/64x; interactive assembled/shared-cache correctness checked, not newly native-timed. Mono and all Mode1–7 programs remain unchanged. The source-only package includes417 files; verification is external.
