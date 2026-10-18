# Qualification — local 1.10.1-rc1

Base: commit `388595adcf49436a437f65b184d52149e8a2b80e`, stable 1.10.0. Candidate: local `1.10.1-rc1`, branch `maintenance/1.10.1-rc1`, explicit prerelease. GitHub publication is not part of this run. Historical tags, assets and reference identities are preserved. The supplied audit ZIP was unavailable; its detailed numeric cases were reconstructed. Actual baseline inventory contains 88 CRLF text files, rather than the audit's 78; normalization is a separate commit.

| Finding | Verified cause and delivery | Acceptance evidence |
|---|---|---|
| Mode7 Q8 projection | Sign lost at signed24 reduction; full unsigned48 outcodes reject only a common outside plane | Native 8000→0 nonzero bitmap bytes; control empty; `hp_fault=0`; exact independent crossing/UV oracle |
| Mode7 flat light | +128 reinterpreted as −128; light-only saturated Q6 product | Assembled vector `[0,30,127]`, opposite face levels; 66,048 extreme products |
| Viewport / texture overrides | Optional property access and original JSON reread; shared safe lookup and effective prepare settings | Missing contract, alias, CLI precedence, invalid value and relative PNG regressions |
| Capture reuse | No acquisition identity; new program/input/file manifest verified before qualification | Authentic PAL/NTSC positive reuse, changed PRG refused; nine synthetic negative identity cases |
| Mode8 validation / navigation | Required assert and inconsistent zero heading; explicit input exceptions, heading 64 | Normal and optimized Python; 100 actual assembled ticks, zero divergent poses |
| Test copies / labels | `.git` copied and non-native separator; current manifest file list and resolved OS path | Clone clean-copy suite, Windows actual assembler; Linux execution remains open |
| Allocation | Restricted first aligned address; bounded all-address fallback after original strategy | 512/468-byte counterexample fits; budget exhaustion distinct from proven impossibility |
| Mode8 adaptive approximation | Equal group boundaries miss interior changes; diagnostic retained, runtime unchanged | 34 assembly/adaptive/fine views, 36 bytes / 138 pixels at counterexample; evaluated prototype cost |
| Retired Q8 caches | Reservations remain despite no consumers; no runtime relayout delivered | Exact measured 15/18-byte reservations; broader layout work deferred |

New current PRG references change only legacy Mode7 flat and six Q8 Mode7 builds, after independent numeric/image checks. The eight old Mode7 and 42 old Q8 identities are retained separately in metadata. Other seven legacy Mode7 references remain byte-identical. Shared geometric `mul_s6`, Gouraud instructions, Mode8 runtime and public profile limits remain intact.

## Public and numeric gates

PASS: all 25 public scripts, independent package-exact clean copies.

First complete 25-script run: 24 PASS, one host-test setup FAIL because polygon-only CLI flags were incorrectly supplied to Mode8. The test helper was corrected; its official targeted rerun PASS completes 25/25 final gates. Raw first-run failure and rerun logs are both preserved. No engine/runtime change was required. Final frozen extracted-package checks are recorded separately.

Targeted PASS: 14 assembled numeric profiles (PAL/NTSC), 12,152 full-quotient classifications, 1,616 near/screen polygons including exact affine UVs, 66,048 light products; host/configuration/provenance/allocator tests. CPU arithmetic/replay is correctness evidence only.

## Native Mode7 before/after

32 real builds: eight profiles × PAL/NTSC × baseline/candidate. VICE Turbo6510 ×64, normal viewport, safe presentation, precise line raster, filter 0, no SID/music or overlay. PAL warm-up 101 refreshes (~2.015 s), measurement 1024 (~20.429 s); NTSC warm-up 120 (~2.006 s), measurement 1230 (~20.560 s). Only `fps_frame_done` after complete presentation counts; IRQ trace verifies emulated base clocks. Host time and warp do not supply FPS. Commands, monitor scripts/logs, raw frame cycles, program/scene hashes and RAM are in each `mode7-native-matrix/*/native-fps` evidence folder.

| Profile / Profilo | Video | FPS before / prima | FPS RC | p95 ms | worst / peggiore ms |
|---|---|---:|---:|---:|---:|
| q8-affine-none | PAL | 12.188487 | 12.188487 | 99.752 | 99.752 |
| q8-affine-none | NTSC | 12.646165 | 12.646165 | 100.291 | 100.291 |
| q8-affine-flat | PAL | 11.894789 | 11.894789 | 99.752 | 119.702 |
| q8-affine-flat | NTSC | 12.159774 | 12.159774 | 100.291 | 117.006 |
| q8-affine-gouraud | PAL | 9.985749 | 9.985749 | 119.702 | 139.652 |
| q8-affine-gouraud | NTSC | 10.506045 | 10.506045 | 117.006 | 133.721 |
| q8-perspective-none | PAL | 3.573332 | 3.573332 | 339.155 | 379.056 |
| q8-perspective-none | NTSC | 3.696571 | 3.696571 | 334.302 | 367.733 |
| q8-perspective-flat | PAL | 3.230683 | 3.230683 | 319.205 | 339.155 |
| q8-perspective-flat | NTSC | 3.356098 | 3.356098 | 317.587 | 317.587 |
| q8-perspective-gouraud | PAL | 3.083834 | 3.083834 | 339.155 | 339.155 |
| q8-perspective-gouraud | NTSC | 3.210180 | 3.210180 | 334.302 | 334.302 |
| q8-fast-gouraud | PAL | 6.950864 | 6.950864 | 159.602 | 159.602 |
| q8-fast-gouraud | NTSC | 7.247225 | 7.247225 | 150.436 | 150.436 |
| legacy-flat | PAL | 24.328025 | 24.328025 | 59.851 | 59.851 |
| legacy-flat | NTSC | 23.249488 | 23.249488 | 50.145 | 66.860 |

Affine profiles use the automatic Q8 camera and rotating public two-object geometry; measurements sample its moving phase, not a complete route. Perspective/fast use a stationary camera with rotating public cubes: automatic and interactive Gouraud builds already exceed the unchanged baseline memory-fit, so no supported configuration was silently substituted. Legacy uses the rotating public flat cube. All 16 paired first views match both bitmap/screen banks and separately captured Color RAM low nibbles. Equal measured FPS describes these windows at refresh-quantized presentation resolution, not a claim of zero extra CPU work.

## Memory and deferred options

Q8 measured allocated block payload increments: [119, 127] bytes across the matrix; detailed deltas are in `mode7-memory-impact.json`. This includes one outcode byte per runtime vertex and two scalar bytes. Flat-only helper costs 25 code bytes; shared geometric multiplication is unchanged. Existing aligned gaps and guards remain validated; all 32 supported matrix builds fit. PRG span is reported separately from allocated payload.

Mode8 stock x64sc, UI on, no SID, warm-up 2 s, 20 emulated seconds: PAL 3.2 FPS, NTSC 3.3 FPS. The independent full-render diagnostic exposes the retained approximation at `[2546,7763,178,96,0]`: 36 bitmap bytes / 138 logical pixels. Central-ray prototype: PAL 2.8 FPS (−12.5%); all-fine: 1.05 FPS (−67.1875%). The central prototype matches the 34 selected views and 1065 nearby valid host poses; this is not a universal proof. Stock cost justifies keeping the runtime unchanged and retaining the diagnostic in the public host regression. Prototype source/builds are external evidence, not SDK defaults. Retired Q8 cache relayout is deferred after measuring 15/18-byte reservations.

| Mode8 stock | FPS | p95 ms | worst / peggiore ms |
|---|---:|---:|---:|
| PAL | 3.200 | 598.506 | 638.410 |
| NTSC | 3.300 | 568.312 | 601.748 |

## Open promotion gate and artifacts

Actual Linux execution is BLOCKED: Linux/WSL and Docker are absent. Native resolved paths and real Windows builds pass; Linux portability is not claimed as executed. Before stable promotion, run the full public runner on a real Linux toolchain. Frozen commit/tag, extracted-package integrity, deterministic rebuild results, toolchain, asset paths and SHA256 are recorded in the separate final delivery report beside the source and evidence archives. No GitHub upload is performed.
