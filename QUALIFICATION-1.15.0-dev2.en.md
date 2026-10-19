# Native qualification — 1.15.0-dev2

Unpublished local development. [New API contracts](REUSABLE-RENDER.en.md) · [Complete data](QUALIFICATION-1.15.0-dev2.json) · [Previous qualification](QUALIFICATION-1.15.0-dev1.en.md).

Actual launcher: VICE Turbo6510 PALx64, safe presentation, Colodore/filter0, silent fixtures with no SID and sound off. Warm-up128simulation events; complete2048tick automatic route, over40emulated seconds. Only newly completed rendered swaps count, excluding duplicate refreshes. No host time, warp or CPU replay FPS. Each pair has identical scene,motion and target inputs; individual warm-up/durations, commands, timestamps, logs and RAM remain external.

|Case|Before FPS|After FPS|Change|After p95 ms|After worst ms|
|---|---:|---:|---:|---:|---:|
|m4-camera|50.1245|50.1245|+0.00%|19.950|19.950|
|m4-clipping|47.6827|47.6827|+0.00%|39.901|39.901|
|m4-clipping-wire-API|9.5988|12.2130|+27.23%|99.752|99.752|

The first two compare dev1/dev2 `all`, showing no FPS regression and no additional measured FPS gain for these scenes. The third draws64moving connected wire lines per view with native materials; both versions update3vertices using the stream API. It compares the complete16bit scalar connected walker against the optimized wire kernel. It is not shuttle FPS and does not isolate a stream-only gain. Measurement durations may differ by less than one refresh due to render-boundary alignment.

127equal-input native poses: full RGB images are pixel-identical. After3completed views, main CPU is parked in its existing self-JMP while IRQ/VIC complete3PAL raster0events, then resumed. No code/framebuffer edits; correctness captures never measure FPS.

Separate6502 correctness checks, no FPS:8,036integer edges versus original fallback;1,225wire lines versus both a point oracle and the native scalar walker, checking both bitmap/material buffers;1,500stream vertices versus the original native producer including near and invalid slots. Codec:4,867original samples reconstructed exactly and5,632native decoder calls, covering every alignment, full signed16 range, offsets beyond256bytes and invalid indices.

57default legacy/plus/Q8 programs rebuilt byte-identically to stable1.14.0 retain inherited evidence only for those unchanged bytes/conditions. APIs remain opt-in. No old release,demo or video changed; no GitHub push/tag/release. Failed experiments and incomplete-coverage wire2 reference remain diagnostic and are excluded. The ZIP contains source/documents only; exact-extraction public gates are recorded in the external receipt.
