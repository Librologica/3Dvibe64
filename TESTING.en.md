# Testing — 1.20.0

Stable SDK published on GitHub. Correctness tests are included; demos, benchmark suites and drivers are not distributed. Install Python 3, PowerShell 7, 64tass and `requirements-tests.txt` dependencies externally. Run from a clean extraction with Python assertions enabled:

```powershell
$env:TASS64_EXE='C:/tools/64tass.exe'
python -B scripts/run_release_tests.py
```

Each gate uses an independent SDK copy containing exactly the manifest-listed files. The stable default set checks distribution, hashes, IT/EN docs and local links, renderer correctness, bounded gameplay, AnimatedMesh, RuntimeScene, Distance Fade and layout. The qualification JSON records actual names and outcomes. An old release-identity check is not reported as passing on this version.

## Optional external-input checks

Historical registered tests may require their version's external examples/validation through `--test-inputs`; they are not all current-release gates. Additional emitted-kernel checks accept explicit external builds and scenes:

```powershell
python -B scripts/test_animated_mesh.py --native-build C:/qa/animated --scene C:/qa/scene.json --out C:/qa/decoder.json
python -B scripts/test_reusable_render.py --control C:/qa/control --exact C:/qa/exact --api C:/qa/api --wire-reference C:/qa/wire --out C:/qa/reusable.json
python -B scripts/test_sphere_impostors.py --build C:/qa/sphere-work --out C:/qa/sphere.json
```

AnimatedMesh requires `3Dvibe64.asm`, `raw.prg` (unrelocated 64tass memory image) and numeric `labels.txt` from the same compilation; a packed launcher cannot replace the raw image. CPU replays verify correctness, never native FPS.

## Native performance and promotion

The performance suite remains external. Use VICE Turbo6510 PAL, active SID, no REU, at 1×/20×/64×. Count new complete views and retain commands, options, route, PRG/symbol hashes, emulated clocks, mean FPS and p95/worst intervals. Warp and host time are not emulated-machine speed. Core/fade/interop use 128 warm-up IRQ events (about 2.53–2.55 s actual) and 1024 measured refreshes; many uses 129 events and at least 128 complete PAL periods, then 16384/32768 measured refreshes at 1× or 2048 at 20×/64×, with three many repeats at 64×. These are distinct protocols.

Original measurements can be inherited for documentation/distribution changes only after exact runtime, program, complete numeric-symbol and condition identity. Promotion records zero new FPS runs and preserves existing blocks. Renderer changes require fresh native timing. Do not adjust frozen scenes, anchors, weights or quality to improve the index. No new NTSC or hardware qualification.

[Qualification / Qualifica](QUALIFICATION-1.20.0.json) · [Docs](DOCS.md)
