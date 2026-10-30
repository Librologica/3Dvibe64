# Testing — 1.15.1

## Clean source-ZIP gates

Install `requirements-tests.txt`, Python3, PowerShell7 and64tass separately.
Run from a clean source ZIP extraction, with assertions enabled:

```powershell
$env:TASS64_EXE='C:/tools/64tass.exe'
python -B scripts/run_release_tests.py
```

The default suite constructs independent temporary SDK copies from MANIFEST.sha256.
It covers stable/local metadata, no-demo distribution, current IT/EN links and
contracts, legacy-plus host API, reusable exact rendering, circle API guards,
assembled arithmetic/panels/materials and optional gameplay configuration modules.
It needs no bundled scenes. Host/CPU correctness callbacks never measure FPS.

## Optional emitted API checks

Build caller-owned projects outside the SDK, retaining ASM/PRG and numeric
VICE labels. The targeted commands accept explicit external builds:

```powershell
python -B scripts/test_reusable_render.py --control C:/qa/control --exact C:/qa/exact --api C:/qa/api --wire-reference C:/qa/wire --out C:/qa/reusable.json
python -B scripts/test_legacy_plus_exact.py --control C:/qa/control --exact C:/qa/exact --out C:/qa/kernels.json
python -B scripts/test_sphere_impostors.py --build C:/qa/sphere-work --out C:/qa/sphere.json
```

Supply actual matching builds, not empty directories. Circle checks require
`3Dvibe64.prg` and numeric `3Dvibe64.labels`. See [circle API](CIRCLE-SPHERES.en.md)
for its source generator and [quick start](QUICKSTART.en.md) for build profiles.

## Historical/external regression gates

Additional registered scripts consume explicit trusted external `examples/` and
`validation/` inputs. The package intentionally omits those directories. Scripts
and versioned reports tied to historical PRG hashes are historical diagnostics,
not claims that every old scene/hash qualifies this release. Choose a named test
and compatible input set deliberately; `--test-inputs` copies inputs into QA
copies only. Optional adapters require explicit `--project-source` and a preset
whose `engineVersion` equals1.15.1. Their experimental scope is unchanged.

## Native timing and stable identity

The stable promotion cold-rebuilds all81 catalog cases.54 programs and all numeric
labels match agentic17;162 native observations at PAL Turbo6510 1×/20×/64× are
retained by exact identity.27 pre-existing blocked cases are unchanged. Current
[qualification](QUALIFICATION-1.15.1.en.md) includes observed FPS,p95/worst,
render time, PRG hashes, target/route settings and retained timing flags.

Native benchmark conditions: original three-voice SID music; warm128 PAL refreshes
(~2.553639s), then1024 measured refreshes (~20.429114s), original16-pose route.
Count complete new views, not duplicate refreshes. Preserve real VICE command,
launch options, raw cycles, capture bytes and program hash. Warp/host time or
CPU replay are never FPS. Public circle samples are separate, silent workloads
with SID emulation enabled:2048 refreshes at1×,1024 at20×/64×, after warm128.

The validation4/1× catalog flag (11 vs12 views) remains; three8-period native
windows per side (~163.43s,93 views each) do not confirm a persistent threshold
regression. Prior Mode7/1× acceptance and fixed index weights remain explicit.
Do not replace original basket values with favorable diagnostics.

New renderer changes require new native timing; documentation/host-check changes
retain observations only after exact program/label and condition verification.
No new NTSC/stock-hardware/Linux qualification is implied by this promotion.
Raw traces and private QA builds remain outside the source ZIP.
