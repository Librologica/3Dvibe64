# Native qualification â€” 1.15.0-dev1

Unpublished development, based on stable1.14.0. Future GitHub stable promotion remains pending. Source SDK only; previous releases and frozen demos preserved. New options are bounded to Mode4 legacy-plus. No automatic precision, resolution, palette or scanline reduction.

[Options / Opzioni](EXACT-RENDER.en.md) Â· [JSON](QUALIFICATION-1.15.0-dev1.json)

VICE Turbo6510 PALx64, safe, Colodore/filter0, silent fixtures. Warm-up128simulation events; complete2048tick route, about40.8emulated seconds. Identical scene/motion hashes and target before/after. Fresh complete views only, native counter/trace agreement; warp and host/CPU replay are not FPS. Individual warm-up/duration, p95/worst, hashes and eight route windows are in JSON; complete commands, timestamps, logs and RAM remain external.

|Case|Before FPS|After FPS|Change|After p95 ms|After worst ms|
|---|---:|---:|---:|---:|---:|
|m4-camera|25.3315|50.1245|+97.87%|19.950|19.950|
|m4-clipping|47.5359|47.6827|+0.31%|39.901|39.901|
|m4-material-camera|47.2855|50.1245|+6.00%|19.950|19.950|
|m4-shared-camera|46.3065|50.1245|+8.25%|19.950|19.950|

146 equal-input native poses: full RGB images identical. Both visible-view buffers settle for3complete views, then the main PC is temporarily parked in the existing self-JMP while native IRQ/VIC runs for3PAL raster0events. No code/framebuffer edits, no extra complete views counted. Resume only after IRQ exit. This removes transient palette scanout differences; unparked screenshots remain diagnostic, excluded from promoted pixel claims. This capture procedure never measures FPS.

Native6502 correctness callbacks: {'unsigned8Products': 65536, 'signedQ10Products': 4160, 'divisionsWithRemainder': 4060, 'exactRationalEdges': 5000, 'solidSpanEndpointPairs': 12880, 'vertexOutcodes': 3000, 'convexShapesIncludingSelfIntersections': 2005}. No FPS derived from them. Panel checks: 400 accepted triangle pairs versus the original two triangles; 400 fan inputs, 0 actual merges under the ordinary conservative palette guard, fallback checks included. A separate compiled uniform-palette contract harness (FACE_MATERIAL_ACTIVE_ONLY=FACE_REFLECTIVITY_ACTIVE_ONLY=1) exercises the identical eligible branch: 300 merges among400fan inputs,400accepted pairs. This harness supplies callback correctness only, no FPS or ordinary-profile performance claim. Material cache: 4024 screen/color-RAM comparisons after individual rows, including disconnected intervals in both buffers.

Frozen-lighting explicit option: 50.1245native FPS, 40.858229emulated seconds, p95 19.950ms, worst 19.950ms. The update_face_shade trace records no recalculation after warm-up, and all 33 native pose captures retain exactly the primed shade/fill arrays. This is a separate appearance option, not an exact comparison with changing illumination.

57 default programs freshly rebuilt byte-identically against stable1.14.0:25plus,16legacy,16Q8. The inherited native evidence remains applicable to those unchanged bytes/conditions. New option results come from new native runs. Stable/publication source and baseline inventories are unchanged. Historical qualification documents are retained as history, not relabeled as new measurements.

New generic kernels: exact arithmetic, byte remainder edges, unrolled spans/paired rows, vertex outcodes, conservative convex uniform fan fill and explicit opaque pair-bounds API; per-view vertex projection was already shared. No route, mesh, camera-follow model, SID or game assets are integrated into the SDK. Automatic fan merging requires a uniform active material/reflectivity palette without fixed per-face pigments or VIC cell ownership; mixed palettes retain the full fan. Frozen lighting requires nonshared dynamic-light objects. Source builds retain all allocator/assembler bounds in ordinary64KB RAM.

Before stable publication: review this bounded contract and source diff, preserve the exact qualification hashes, and run the final source-package gates from a clean extraction. Their results belong to the external delivery receipt. No GitHub push/tag/release is performed by this development. Software PolyForm Noncommercial1.0.0; documentation CC BY-NC4.0; attribution librologica.digital.
