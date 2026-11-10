# Agentic36 — 1.15.2-dev-agentic36

Unpublished, source-only Distance Fade development from delivered agentic35. [Italiano](AGENTIC36.it.md). [Current qualification](QUALIFICATION-AGENTIC36.json). Earlier versioned notes/ledgers are historical; no official publication or stable promotion.

## Behavior and compatibility

The manual includes [scene design guidance](DISTANCE-FADE.en.md#when-distance-fade-helps) for choosing fade according to geometry distribution, rendering mode and CPU budget.

Distance Fade remains optional and OFF by default in all Modes 1–8. The public JSON object is `distanceFade: {mode,start,end}`; `mode` is `off` or `dither`, integer distances satisfy `0 <= start < end <= 32767`, and explicit distances require dither. PowerShell retains `-DistanceFade`, `-DistanceFadeStart`, `-DistanceFadeEnd`; Python builders retain `--distance-fade`, `--fade-start`, `--fade-end`. The [complete contract](DISTANCE-FADE.en.md) gives validated CLI/JSON examples, defaults and backend restrictions. No new application entry points or configuration keys are introduced, and existing input files need no migration.

Modes 1–7 retain the original object-origin Euclidean metric: sign-extend before subtraction, take the absolute Q8 difference, truncate each axis to integer world units, square/sum with the original 40-bit range, and select the same 17 coverage states. Level 16 is opaque, levels 1–15 use the unchanged Bayer multicolor pixel pairs, level0 excludes the object. Partial objects still incur transformation/raster costs; only complete exclusion avoids their native geometry build. Mesh radius and individual vertex depth do not replace the configured origin metric.

Mode7 texture LOD remains independent and retains its existing supported Q8 perspective profiles. Fade OFF/ON and texture LOD OFF/gradual work separately or together. `TextureLODNear`, `TextureLODFar`, original-corner depth, pigment policy, lighting, sampler and precision are unchanged. The many-object Mode7 benchmark intentionally uses affine/unlit-A with LOD OFF; the separate perspective LOD factorial uses both 40..56 and 28..44 profiles. These are separate workloads, not interchangeable shaders.

## Mode8 decision: retain the existing method

Mode8 fade is retained for the mono perimeter/aperture and multilevel backends, in automatic and interactive templates. Its API, cell units, conservative plane-normal distance, exact17 states, fractional camera handling, top/bottom samples, DDA traversal and visible Bayer output are unchanged. It still does not terminate DDA at the fade distance. A nearby sidewall plane can remain nearby along distant sections; object-distance exclusions from Modes 1–7 do not predict map exclusions. No request silently falls back to OFF.

Technical Debug identified repeated classification of the same plane as a major multilevel cost. A private 128-byte table now holds levels only for the current composed view. The existing pose/unit-cache initialization call is replaced by a same-size wrapper that invalidates all 128 entries before composition, after the pose is latched. The normal preprocessor emits plane encodings within the existing X/Y coordinate domain. Multiple height/profile keys can reuse the same plane level; no profile projection, vertex, frame or previous-view geometry is cached by this change. Camera motion cannot reuse an old view's level.

The profile wrapper avoids unnecessary Y/stack saves because the distance helpers never modify Y; the original key and required X state use private foreground storage. The existing get_profile ABI and all callers are retained; its status flags remain clobbered. Partial scalar fills process the four repeating Bayer row phases with a stride of four, selecting the lane mask/ink once per phase. Each destination byte receives exactly the old masked merge. Empty/reversed intervals, zero/full paths, other lanes, borders, colors and clipping remain covered by compiled tests and native comparisons. Mono behavior and emitted programs remain unchanged by this multilevel optimization.

The multilevel helper occupies 920 bytes versus 723 on SDK35, inside the same 2449-byte reserved payload; mono remains 766. No reservation, allocator window/order/search budget, low-code hook size, bitmap range or guard is expanded. The existing tightly packed public multilevel-auto low-code budget remains intact. Insufficient memory remains an explicit error, never a quality/precision fallback. The per-view128-byte reset has a fixed cost; gains depend on map/profile demand and do not imply every possible scene becomes faster.

## Polygon arithmetic and wire ownership

An absolute integer axis at least `end` already implies total squared distance at least `end²`; it can return level0 before unused squares. Accepted factors use a compile-time exact bit width derived from `end`, while retaining nonwrapping signed subtraction, Q8 truncation and the full accumulator. No approximate distance or reduced precision is introduced. Threshold transitions, far endpoints and register/flag-preserving STA writer/setter contracts remain exact.

Explicit wire meshes use edge ranges in active_face_first/end. These are no longer written into the polygon face-owner table. Polygon owners are populated only for actual polygon meshes; wire instances keep their own classified level and normal writer. This corrects the SDK35 wire-overwrite defect and protects mixed polygon/wire ownership. Historical corrupt/black results are invalid baselines, not measured speedups.

## Measurement scope and interpretation

Qualification uses the integrated core, original fade extension, two 60-object families, a new corridor, mixed fade interop and final holdouts. Actual SDK snapshots, PRG/label/tool hashes, exact argv, clocks, RAM, images, work counts, native render spans, p95/worst intervals and stationary/moving/actual-pose data remain external and are indexed by the current ledger. Mode8 screenshots preserve output; the method was not replaced or removed. The report distinguishes newly measured, program-equivalent inherited and invalid/blocked records.

Native performance targets are VICE Turbo6510 PAL1×/20×/64×, original suite SID active, no REU. Warm-up timing is specified by the component protocol and by the clock-verified correction below. Core/fade/interop measure 1024 refreshes (20.429114 s). Many uses1× physical/map 16384 refreshes (326.865829 s),1× angular 32768 (653.731657 s),20×/64× 2048 (40.858229 s), with three 64× repeats and one at the other speeds. Only complete new-view commits count; display refresh duplicates, host/warp speed and CPU replay do not. Render headroom can improve while FPS stays on a PAL presentation plateau. Deterministic repeats are not independent statistical confidence samples. Slow1× runs may display only part of the authored camera keys.

Technical Debug sessions are separate, with matching PRGs/labels and no live polling. Stopwatch/profiler values refer to maincpu_clk machine time, never invented internal CPU cycles obtained by multiplying by64. Compiled arithmetic/cache/store tests prove correctness only, not FPS. Extra public-template/Gouraud/normalized builds are capacity/API checks, not SID performance comparisons. Earlier silent SDK35 measurements remain a separate protocol. No new real-hardware or NTSC qualification is claimed.

## Two score series and reproducibility

Historical `3dvibe64-performance-v1` keeps first stable 1.15.0=100, its fixed 12-case basket, formula, weights and old series. SDK35's 137.50563008162632 is an inherited reconstructed default-OFF estimate; the canonical calculation remains blocked by the historical/current PowerShell hash mismatch. Added fade cases never enter that series. The current ledger records base/candidate/delta and exact program-equivalence provenance; an estimate is not relabeled validated.

Separate `3dvibe64-extended-performance-v1`, specification 1.0.1, starts at the first delivered agentic36 = 100 with immutable source/runtime/program/baseline identities. Before evaluation its basket was frozen to 12 core + 56 previously valid fade + 60 many cases, balanced by mode, family, speed and native FPS/render time. Additional interop is final correctness validation, outside that score. Missing/invalid data or removed capabilities block the total rather than causing zero FPS, OFF substitution or silent renormalization. Debug Suite/holdouts add no artificial score. The SDK qualification points to the frozen external suite definition, baseline and full reports.

The integration is `3Dvibe64_BenchmarkSuite_Extended_1.2.1_2026-11-10`, with candidate-SDK parameterization and ITA/ENG/AI instructions. Recheck alignment and compare the previous SDK at every new dev/release. Preserve stables, frozen demos, original suites and SDK35. The SDK contains no demo scenes, models, music, compiled PRGs or captures; tests create temporary correctness kernels. External benchmark evidence is not bundled as an engine demo.
## Observer correction1.0.1

Many requires at least128 complete PAL periods after first render-begin: the corrected runner observes129 IRQ hits and checks actual native elapsed clocks. Both35 and36 are newly measured with the same correction. Legacy128-edge timing stays separate. Core/fade/interop retain their own128-IRQ-hit protocols (~2.53–2.55s), with actual durations audited. Formula, cases, weights and measured windows remain unchanged. Original basket/formula1.0.0 preceded tuning; instrumentation-only1.0.1 preceded the final paired qualification.

The existing Mode8 build-receipt field `distanceFade.levels:16` denotes the maximum level, not a count of coverage states:0..16 is17 states. No scene or option migration is required.
