# Quick start — 1.15.1

Install Python3 (qualification used3.13.14), PowerShell7 and64tass1.60.3243.
Pillow supports PNG import; NumPy/py65 support optional correctness tests.
`TASS64_EXE` selects the external assembler. No tool binary, scene or demo is bundled.

## Ordinary polygon build

From the extracted SDK root, create a separate project and full working SDK copy:

```powershell
$project='C:/projects/my-engine'
New-Item -ItemType Directory -Force $project | Out-Null
New-Item -ItemType Directory -Force "$project/inputs" | Out-Null
Copy-Item -LiteralPath . -Destination "$project/sdk" -Recurse
$env:TASS64_EXE='C:/tools/64tass.exe'
```

Save this minimal authoring snippet as `C:/projects/my-engine/inputs/scene.json`.
It is documentation, not a bundled project or performance workload:

```json
{
  "schema": 1, "name": "minimal external input", "graphicsMode": 4,
  "axisConvention": "world-z-up",
  "world": {"backgroundColor": 0, "grounds": []},
  "camera": {"id": "camera", "position": [0,0,0], "rotation": [0,0,0], "mode": "walkLite"},
  "meshes": [{"id": "triangle", "type": "mesh", "geometry": "solid", "materialProfile": "single",
    "vertices": [[-8,0,-6],[8,0,-6],[0,0,8]], "faces": [[0,1,2]]}],
  "objects": [{"id": "object", "mesh": "triangle", "position": [0,40,0],
    "rotation": [0,0,0], "angularVelocity": [0,0,0], "scale": 1,
    "visible": true, "geometry": "solid", "materialProfile": "single",
    "material": "blue", "reflectivity": "satin"}],
  "contract": {"version": 1, "viewportProfile": "normal", "ground": false}
}
```

Then build Mode4 legacy-plus:

```powershell
pwsh -NoProfile -File C:/projects/my-engine/sdk/work/build-3Dvibe64.ps1 -SceneFile C:/projects/my-engine/inputs/scene.json -Precision legacy-plus -GraphicsMode 4 -DynamicLight -CameraMode walkLite -CameraViewport normal -MemoryLayout high-basic-v2 -Quality fast -Projection extended-table -VideoStandard pal -FramePresentation safe -NoFpsOverlay -NoCameraRuntimeControls -ExplorerClipMode near -ExplorerNearCrossMode poly -SkipCmdUpdate
```

Generated files are in the working copy: `sdk/work/3Dvibe64.asm`,
`sdk/work/3Dvibe64.prg` and `sdk/work/build/3Dvibe64.prg`. Ordinary legacy/plus
reject `-OutputDirectory`; they do not build into an arbitrary output folder.
Keep the release extraction pristine. Launch the generated PRG with your own
VICE installation/launcher; these instructions do not measure FPS.

The scene's graphicsMode/camera must match CLI selectors. To use Modes1–6,
change both declarations consistently; Mode6 requires high-basic-v2. Mode7
additionally needs caller-owned textures/materials/UV according to
[MODE7](MODE7.en.md), [texture guide](TEXTURE-GUIDE.en.md) and
[legacy-plus](LEGACY-PLUS.en.md). No default texture is silently supplied.
`legacy` stays the ordinary default; the command explicitly chooses plus.
Q8 and experimental Normalized16 have their own contracts and external outputs.

## Mode8 map

Supply your own valid map document, including32×32 solid/floor/ceiling arrays,
doors/ramps, supported template initial pose and navigation. Follow
[map authoring](MAPS-2.5D.en.md), [Mode8](MODE8.en.md), and the camera/navigation
contract values in `work/mode8/templates.json`; no map scene is bundled.

```powershell
python -B work/mode8_build.py --scene C:/projects/my-engine/inputs/map.json --out C:/projects/my-engine/map-check --run interactive --validate-only
python -B work/mode8_build.py --scene C:/projects/my-engine/inputs/map.json --out C:/projects/my-engine/map-build --run interactive
```

Use `--run auto` only with a valid complete route. Mode8/Q8/Normalized16 outputs
must be new directories outside the source SDK. Backend selection uses map
content, not file names; unsupported maps fail instead of silently degrading.

For Mode4/5 in this plus profile, keep `-DynamicLight` when the scene declares no light; otherwise the default shade-step path is incompatible. Mode6 enables its required dynamic-light path automatically.

## APIs, dependencies and tests

`-SphereRenderer circles` emits optional Mode4/6 plus APIs; application ASM must
call them in painter order. It creates no sphere JSON objects. Default `none`
adds no code/RAM. [Circle API](CIRCLE-SPHERES.en.md) documents all units and limits.
`scripts/sphere_api_example.py` is an optional source generator; invoking it
creates an external project. No generated demo/PRG is included in this release.

```powershell
python -m pip install -r requirements-tests.txt
python -B scripts/run_release_tests.py
```

Assertions must remain active: no `-O`, `-OO` or `PYTHONOPTIMIZE`. Self-contained
host/CPU tests do not measure FPS. [Testing](TESTING.en.md) separates their scope
from native timing and historical gates. [External inputs](EXTERNAL-INPUTS.en.md).
