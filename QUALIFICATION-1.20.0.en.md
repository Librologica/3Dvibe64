# Stable qualification — 1.20.0

Stable source release 1.20.0 is published on GitHub. The [JSON ledger](QUALIFICATION-1.20.0.json) retains source identities, program provenance and original native results. The current documentation revision leaves runtime, APIs, measurements and index anchors unchanged.

Coverage: 233 attempted configurations across pure and mixed modes 1–8 at 1×/20×/64×. There are 177 buildable configurations, 531 valid aggregate cells and 651 original native runs. The 56 existing build blocks leave 168 unavailable cells: 27 core, 13 fade (12 RAM and 1 layout), 16 interop; many builds 60/60. Blocks are not measurements or zero scores.

All 177 cold builds retain identical PRGs and complete numeric symbol maps. Measurement inheritance also requires identical conditions. Only many at 64× has three repeats; other cells have one run. This is not a new three-repeat-per-cell campaign.

Original target: VICE Turbo6510 PAL, original SID active, no REU, 1×/20×/64×. Core/fade/interop: 128 warm-up IRQ events (about 2.53–2.55 s actual), then 1024 refreshes (about 20.429 s). Many: 129 events and at least 128 complete PAL warm-up periods; 1× uses 16384 measured refreshes for physical/map scenes or 32768 for angular scenes, while 20×/64× uses 2048. FPS counts new complete views over emulated machine time; per-cell p95/worst intervals are retained. No live sampling during timing runs.

Historical index, first stable 1.15.0=100: 1.20.0 retains 137.505630. This is an inherited reconstructed estimate, not a validated canonical index: historical calculation remains blocked by the PowerShell hash check. The separate extended index retains 100 against its original frozen reference identified in the ledger; it is not reanchored to the public release number. Weights, workloads, anchors and blocked-case policies remain unchanged.

No new FPS runs, hardware test or NTSC qualification is implied. [Protocol](TESTING.en.md) · [Fade scene guidance](DISTANCE-FADE.en.md#when-distance-fade-helps).
