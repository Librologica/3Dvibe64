# 3Dvibe64 1.10.2 — current stable scope

These development notes are historical. Current release, options, corrected evidence and qualification limits: [release notes](RELEASE-NOTES-1.10.2.en.md). Runtime unchanged from dev3.

---

# Historical development audit: 1.10.2-dev3 — local polygon audit

Development only, based on dev2 commit `26ba9ae13fd1b43bf0a09bf6aacf13b1f88e9f86`. No GitHub publication or stable promotion. Official releases and frozen demos remain unchanged. The immutable full dev2 snapshot, Git bundle and original experimental tests are kept outside this SDK.

Mode8 returns to its qualified post-maintenance bitmap backend. The three generators `mode8-regions`, `mode8-rays`, `mode8-chars`, their combinations and exclusively related caches/tables/character fallback have been removed from the active SDK. Omission and `none` are accepted; all explicit experimental requests, including `all`, fail with `ENGINE_MODE8_RETIRED`. The ordinary bitmap templates, map validation, navigation/duplicate-waypoint corrections, independent adaptive-approximation diagnostic, capture provenance, double buffers, UI, palette and memory guards remain intact. Mode8 is frozen after the rollback checkpoint.

The dev2 Q8 improvements below remain opt-in, default off. `all` strictly requests all four Q8 flags and retains all compatibility rejections. Explicit CLI selection overrides the scene selection. Tables consume 2048 bytes; visibility may lose time in fully visible scenes. No general occlusion or portal compiler is added.

| Flag | Implemented engine behavior / limits |
|---|---|
| `uv-texel` | Standard lit paired Mode7 Q8 perspective sampler: retain 3..7 fractional quotient bits according to repeat1..16, independently for U/V. Mixed textures use the maximum required bits per axis. Selected texels remain identical. Full division fallback handles out-of-domain pairs. Fast endpoints and unlit recurrence keep their complete quotient/remainder ABI and reject this flag. |
| `q8-arithmetic` | Exact focal product43520A =85A shifted9, retaining48-bit intermediate storage; numerator normalization and48/16 division with original48/24 fallback. No approximate reciprocal. |
| `camera-table` | Mobile Q8 camera only: four512-byte coefficient tables, rebuilt only when coefficients change. Signed24-bit products retain the original per-product rounding, ties away from zero. Foreground-only patched absolute operands. Select the original compact multiplier by omitting the flag. RAM failure remains explicit. |
| `visibility` | Polygon Modes3..7: reject inflated object volumes outside a conservative45-degree cone/behind camera before per-vertex work and face collection. Camera-center rotation shares exact product rounding. Near-crossing/uncertain objects are kept. Exact same-object opaque duplicate faces are removed in Modes3..6; Mode7 retains its richer face/UV ABI. This does not introduce a general depth buffer, PVS, portal compiler or inter-object occlusion solver. |

Fast block state is inherited unchanged from dev1: `bk_predict` retains future remainder; `bk_look0/bk_look1` share `ps_cur0/ps_cur1`; active `bk_count` skips scalar advancement of all three perspective carriers. `none` does not undo this optimization. UV specialization is for the standard lit paired sampler; fast endpoints retain full precision and reject `uv-texel`. The pre-dev1 fast baseline must be isolated separately from standard-vs-fast profile comparisons.

New and inherited results, commands, hashes, traces, memory and image checks are distinguished in the separate evidence archive `RESULTS.md` and `final-comparison.json`. Native FPS count newly completed views using emulated time; instruction replay tests establish correctness only. Windows/VICE is the test platform; Linux and real hardware are untested. Historical manuals and performance records below retain their original scope.

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 7 -Precision q8 -SceneFile examples/mode7-perspective-cube.json -EngineExperiments q8-arithmetic,uv-texel -VideoStandard pal -OutputDirectory ../dev3-uv
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 4 -Precision q8 -Q8Camera auto -SceneFile examples/q8/two-objects-mode4.json -EngineExperiments q8-arithmetic,camera-table,visibility -OutputDirectory ../dev3-camera
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile examples/mode8/two-levels.json -Mode8Run auto -EngineExperiments none -OutputDirectory ../dev3-mode8
python -B scripts/run_release_tests.py
```

## Dev3 qualification / Qualificazione dev3

Mode8 rollback checkpoint: `39dfdec`; host qualification guard: `c73c46f`. Twelve bitmap PRGs/ASM/build reports are identical to the dev2 none references. On the complete two-levels path, stock PAL3.113291FPS (p95558.610ms, worst798.013ms), NTSC3.218422FPS (p95534.886ms, worst768.893ms) exactly reproduce dev2. Warm-up101/120 refreshes; measured179.553/180.523 emulated seconds. The historic3.2FPS uses another qualification window.

The host guard rejects -O, -OO and PYTHONOPTIMIZE before native qualification, including direct native.run. A valid native capture passes; a coherently rehashed altered bitmap fails. The public runner has28 actual gates: ordinary Q8/fast/Mode8 coverage retained, exclusive retired backend tests archived, new retirement and optimized-Python refusal gates added. All28 pass.

New performance evidence:88 unprofiled Q8 native measurements (44 principal Turbo6510x64,16 stock PAL/NTSC,22 span/repeat/material probes,6 Modes3/5/6 regressions). The eight Mode4 arithmetic/table/visibility combinations compile on both public and sparse six-object mobile scenes in each standard. Public PAL:30.186 baseline,36.257 arithmetic,30.854 tables,29.518 visibility,39.738 arithmetic+tables,38.485 all three. NTSC baseline31.021/all three34.234. Standard Mode7 PAL3.091 baseline,3.119 arithmetic,3.676 UV,3.704 both. These are scene/profile results, not new defaults.

Renderer and presentation wait are recorded separately. Stock runs last120s fast/180s standard and Mode4 after ~2s warm-up; slow standard Mode7 yields few images, with raw counts and percentile sample sizes preserved. The fork's trace/stopwatch/profiler cycles are machine clocks (PAL985248Hz, NTSC1022727Hz); profiler Times counts executed instructions. A known16384-NOP loop validates the distinction. OPC/Branch%/Stolen heuristic fields are not used atx64. Warp and host elapsed time are excluded from FPS.

408 paired native image comparisons plus24 Modes3/5/6 comparisons have zero bitmap/screen/ColorRAM differences.22 dev2 Q8 PRGs regenerate identically; the four old/new fast PAL/NTSC PRGs match the verified dev1 references. The inherited fast gain is measured separately against pre-dev1 texture_fast.py: long-span probe6.321→7.463FPS, short spans28.125→28.125, clipping/mixed material6.293→7.379.477 assembled spans/38637 samples retain UV and boundary residues. Standard-versus-fast remains a visual profile comparison.

One external prototype reused the exact unlit rational recurrence with12 private bytes for the lit sampler. Images and51516 numeric samples pass, but the measured gain is1.152x against the isolated full-precision arithmetic baseline, below the investment goal and slower than existing arithmetic+UV on the public repeat2×2 scene. It is withdrawn and archived; no additional polygon runtime code or flag is included in dev3. Mode8 remains frozen. New and inherited results, complete commands, source/PRG hashes, timing traces, profiler records, memory maps, coverage estimates and image checks are in the separate proof archive. Coverage/overlap from inclusive span bounds is an upper estimate, not exact hidden-write savings. No visibility compiler is started.

Linux and physical hardware remain untested. Preliminary invalid diagnostic inputs and profiler commands are preserved separately and excluded from qualified results. See the evidence archive RESULTS.md and final-comparison.json for the complete matrix and actual gate contents. The source ZIP remains the normal SDK, without extraordinary test material, demos, video, emulator or compiled PRGs.

## Report documentation correction — 2026-10-13

Runtime unchanged at checkpoint 799be44544933aa759111748b9dc68accaab5da7.
This SDK copy changes only IT/EN notes and the manifest: no new runtime version,
flag, optimization or publication. The external generator keyed acquisitions
by name, allowing some stock records to replace Turbo6510 ×64 table entries.
Twelve Mode4/Mode7 cells are corrected from original traces, separating target,
video standard, animation and profile. Performance values in these notes were
already correct. The public Mode7 profile uses repeat2×2; the inaccurate old
repeat1 label is also corrected. Public PAL AC 39.737623 FPS beats ACV 38.484510
FPS; all denotes compatible options and does not guarantee the highest FPS.
The report and 17 tool regressions remain in the separate evidence archive,
distinct from 28 historical SDK gates.
