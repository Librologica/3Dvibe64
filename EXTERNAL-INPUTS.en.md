# External inputs — 1.13.0

## Working copy and output paths in1.13.0

Ordinary legacy and legacy-plus write generated ASM/labels/map/PRG in their
SDK working copy's `work/`, plus `work/build/3Dvibe64.prg`. Copy the complete
source SDK to a new external working directory first and run ordinary commands
there. They reject `-OutputDirectory`. Q8, Normalized16 and Mode8 instead accept
`-OutputDirectory` for a new external output directory. The outputs described
below are generated files, never precompiled files included in this SDK.


No demos, examples, source scenes, artwork, music, camera tours, standalone demo
launchers, precompiled programs or native captures are shipped. The source ZIP
contains no `examples/` or `validation/` directory. Unit tests may construct tiny
mathematical fixtures in temporary directories; they are not demo projects.
Renderer assembly templates and primitive geometry generators are engine code.
Mode8's bounded backend templates retain their implementation contracts; they
are compiled only with an explicit caller-supplied map and are not new demos.

## Ordinary scenes

Supply an existing schema1 polygon scene to `-SceneFile`; supply a Mode8 map to
Mode8. All commands below use **your external files**, not bundled templates.
Run from the SDK root; choose a fresh output directory outside it.

```powershell
Copy-Item -LiteralPath . -Destination ../my-build-sdk -Recurse
pwsh -NoProfile -File ../my-build-sdk/work/build-3Dvibe64.ps1 -SceneFile ../my-inputs/scene.json -GraphicsMode 6 -MemoryLayout high-basic-v2
python -B work/q8/build.py --scene ../my-inputs/textured-scene.json --out ../my-q8-build --mode 7 --camera auto --texture-precision perspective --texture-quality standard --engine-experiments inside-planes,bounded-divide,packed-samples
```

Omitting SceneFile fails explicitly instead of generating a default scene.
External texture paths are resolved relative to the scene. Install PowerShell7,
Python, Pillow where needed and64tass separately; `TASS64_EXE` selects the latter.

## Gameplay adapters

`--project-source` / `-ProjectSource` is mandatory. The adapter directory must
supply `examples/gameplay/<profile>.json`, `extensions/gameplay/common`,
`extensions/gameplay/billboards` and `extensions/gameplay/profiles/<profile>`
for every profile in its inheritance chain. It supplies scene/UI/assets,
material bindings, build script, camera and application logic. The SDK does not
invent any of these. Update the preset `engineVersion` to1.13.0 and qualify its
checkpoint hash again. Use [GAMEPLAY](GAMEPLAY.en.md) for the full13-profile ABI.

## Regression inputs

The default `python -B scripts/run_release_tests.py` runs self-contained package,
math and gameplay configuration tests without example files. Historical scene
regression tests additionally require an external, trusted input directory with
`examples/` and `validation/` compatible with the1.11.0 archive:

```powershell
python -B scripts/run_release_tests.py --test-inputs ../my-regression-inputs test_mode7.py test_precision_q8.py
```

Inputs are copied only into temporary QA copies, never into the source package.
Do not pass `-O`, `-OO` or PYTHONOPTIMIZE. Native evidence and builds are delivered
separately under the local release's `reports/` and `qualification/`, outside
`repository/` and outside the source ZIP. No external-input bundle is distributed.
