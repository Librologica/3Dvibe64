# Stable release qualification — 1.15.0

Source release published on GitHub. [Status](RELEASE-STATUS.en.md) · [Structured evidence](QUALIFICATION-1.15.0.json) · [Original dev2 measurements](QUALIFICATION-1.15.0-dev2.en.md) · [First integration](QUALIFICATION-1.15.0-dev1.en.md).

## Provenance and identity

Promotion from qualified1.15.0-dev2 commit `ccc7d62a03d250a606f3aab6e246ba11af6bc94f` changes documentation,version,metadata and host package checks. All 127non-document runtime/configuration files under work/ and extensions/ retain qualified development hashes. Historical evidence stays byte-identical. These are not new native timing runs: original dev2 acquisitions are retained. Exact stable-ZIP PRG rebuild identities and clean-extraction gates are recorded in the external delivery receipt.

## Retained FPS, not new acquisitions

Actual fixture launcher VICE Turbo6510 PAL×64,safe,Colodore/filter0,silent,no SID,sound off.128simulation-event warm-up (2.55–2.63s); complete2048tick automatic route (40.838–40.874emulated seconds),no stationary phase. Only newly completed rendered swaps count; counter/trace agree,duplicate refreshes excluded. No host time,warp or CPU replay FPS. Original commands,timestamps,RAM,hashes and conditions remain in external dev2 reports.

|Original case|Before FPS|After FPS|Change|After p95 ms|After worst ms|
|---|---:|---:|---:|---:|---:|
|m4-camera|50.1245|50.1245|+0.00%|19.950|19.950|
|m4-clipping|47.6827|47.6827|+0.00%|39.901|39.901|
|m4-clipping-wire-API|9.5988|12.2130|+27.23%|99.752|99.752|

The first two originally compared dev1/dev2 `all` and kept the same FPS. The third compared64moving connected wire lines plus3stream vertices in both versions against the complete scalar connected walker: +27.23% only for that named fixture,not the shuttle or an isolated stream gain. Earlier stable1.14.0 comparisons remain in dev1 qualification with their own hashes/conditions and are not mixed with these pairs.

## Graphics,numerics and limits

127equal-input native poses were full-RGB identical;3completed views and3PAL raster0events with main CPU parked in its existing self-JMP settled palette scanout. No code/framebuffer edits; correctness captures were never FPS.57default legacy/plus/Q8 programs rebuilt identically to1.14.0. Separate6502 callbacks:8,036integer edges,1,225wire lines versus point/scalar references,1,500stream vertices versus native producer;4,867codec samples and5,632native decoder calls. Callback counts are not FPS.

New options/APIs qualified only for Mode4 legacy-plus/walkLite/normal160×100/high-basic-v2/NoFpsOverlay,near8/poly,no Ground. No implicit extension to other backends. `all` excludes wire,stream,frozen-lighting. Fan merging requires its palette contract; ordinary fixtures keep the full fallback. Frozen lighting is a separate appearance choice. Experimental modules retain their status. No new NTSC,stock-C64 or physical-hardware qualification;64KB RAM is not a stock-CPU speed promise. [ABI/limits](REUSABLE-RENDER.en.md) · [Tests](TESTING.md).
