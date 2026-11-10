# Agentic34 — 1.15.2-dev-agentic34

Unpublished development from agentic33. New optional distance fade for Modes1–8, default off. [Full contract](DISTANCE-FADE.en.md). Mode7 texture LOD remains independent.

The disabled polygon outputs and three Mode8 auto outputs were compared byte-for-byte with agentic33. Seven native fully opaque images match the disabled path exactly; seven fully distant images contain no object pixels. The two controls in Mode7 were checked separately and together, including compiled LOD classifier/sample tests. Mode8 retains fractional camera distance and existing guarded memory boundaries; all three backends build in auto and interactive.

This is an optional visibility/quality feature, not a universal optimization: partial dithering adds work. Representative PAL64× results: Mode4 static cube50.12→25.06 FPS during partial fade; Mode7 Gouraud-C3.13→2.89 FPS; unlit Mode7 LOD9.45→7.93 FPS with partial fade. Fully excluded Mode7 reaches50.12 FPS. These workloads/lighting profiles differ and must not be combined into a general score.

A full Mode8 multi tour was measured for179.552762 emulated seconds after128 refreshes of warm-up:50.124542→37.877446 FPS, all142 nodes completed (150 visits), zero faults/tick overflow. Mono fade also has a background-reset cost. Other short measurements use1024 refreshes (20.429114 emulated seconds) after128 warm-up, complete presented views only. Music is absent in these supported public Q8/Mode8 profiles. CPU correctness tests never supply FPS. NTSC and active-effect multipliers1/20 are not newly timed; interactive Mode8 is assembled/shared-kernel and capture checked, without a separate FPS claim.

Legacy/legacy-plus allocations are rebuilt after instrumentation to prevent overlap with existing helpers. Mode1 wire/clip kernels retain fall-through entries when relocated. Native Mode1 legacy and legacy-plus both measure50.124542 FPS; corrected legacy-plus Mode4 measures33.432678 FPS against50.124542 with the effect off. Regression tests compile and execute these fall-through entries and an adjacent-helper allocation case.

General SDK index, fixed stable1.15.0=100: base137.50563008162632; new137.50563008162632; delta0%. This is an inherited reconstructed estimate for unchanged defaults. The historical canonical index remains blocked by the PowerShell hash mismatch. Optional fade workloads do not replace the frozen basket.

[Qualification ledger](QUALIFICATION-AGENTIC34.json) records the exact local evidence location, PRG hashes, commands and measurements. No scene assets, demos, music, PRGs or captures are included in this source SDK. No publication or stable promotion. Original agentic33, official releases and frozen demos are preserved.
