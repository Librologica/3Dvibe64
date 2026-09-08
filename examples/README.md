# Public JSON reference scenes

## Gate 5 release references

`mode6-gouraud-cube-hard.json` and `mode6-gouraud-cube-smooth.json` have identical
geometry, pose, light and material. Only creaseAngle changes 0 to 180 (plus the
descriptive scene name). Compile either with `-GraphicsMode 6 -MemoryLayout
high-basic-v2 -Quality fast -Projection extended-table -NoFpsOverlay -SkipCmdUpdate`.

Reproduce the exact frozen Gate 5 torus/FPS build in a disposable SDK copy:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\work\build-3Dvibe64.ps1 `
  -SceneFile .\examples\mode6-gouraud-torus-fps.json -GraphicsMode 6 `
  -MemoryLayout high-basic-v2 -Quality fast -Projection extended-table `
  -CameraViewport normal -VideoStandard pal -MaterialFamily yellow -Reflectivity 2 `
  -ControlMaterial -ControlReflectivity -ReflectivityCycleLevels 3 -SkipCmdUpdate
```

Expected PRG SHA-256:
`F59587562E2CD78F7E28ACE58108274B88013A7DDC2A4F6949C393CD87844662`.
Keys 1–0 select material; R cycles reflectivity 0, 1, 2; F toggles the FPS/text header.
Do not also enable ControlRotation when R is reserved for reflectivity.

## Other references

These files are executable documentation for the public 3Dvibe64 1.2.0 builder. They
are generic technical references, not distributed productions. The package includes
no PRG; run commands in a disposable working copy if you want the source tree to
remain artifact-free.

All commands start from the package root:

```powershell
$build = '.\work\build-3Dvibe64.ps1'
```

## Wire and solid references

```powershell
& $build -SceneFile .\examples\wire-two-color-multimaterial.json -GraphicsMode 1 -CameraMode fixed -CameraViewport normal -Quality balanced -Projection table -MemoryLayout stable -NoFpsOverlay -SkipCmdUpdate
& $build -SceneFile .\examples\wire-two-color-multimaterial.json -GraphicsMode 2 -CameraMode fixed -CameraViewport normal -Quality balanced -Projection table -MemoryLayout stable -NoFpsOverlay -SkipCmdUpdate
& $build -SceneFile .\examples\basic-solid-reference.json -GraphicsMode 1 -CameraMode fixed -CameraViewport normal -Quality balanced -Projection table -MemoryLayout stable -SkipCmdUpdate
& $build -SceneFile .\examples\basic-solid-reference.json -GraphicsMode 2 -CameraMode fixed -CameraViewport normal -Quality balanced -Projection table -MemoryLayout stable -SkipCmdUpdate
& $build -SceneFile .\examples\basic-solid-reference.json -GraphicsMode 3 -CameraMode fixed -CameraViewport normal -Quality balanced -Projection table -MemoryLayout stable -SkipCmdUpdate
& $build -SceneFile .\examples\basic-solid-reference.json -GraphicsMode 4 -CameraMode fixed -CameraViewport normal -Quality balanced -Projection table -MemoryLayout stable -SkipCmdUpdate
& $build -SceneFile .\examples\basic-solid-reference.json -GraphicsMode 4 -CameraMode fixed -CameraViewport normal -Quality balanced -Projection table -MemoryLayout stable -HeaderText "SCRITTA DI ESEMPIO" -FpsOverlayOnStart -SkipCmdUpdate
```

The last command exercises the DEV7/DEV7.1 same-bank Generic Text and FPS header.
The 3D body is 160×88 while the split is compiled in; add `-NoFpsOverlay` for the
byte-compatible 1.1.0 bitmap-only path and legacy 160×100 normal viewport.

## Dynamic camera and materials

```powershell
& $build -SceneFile .\examples\mode4-walkfull-reference.json -GraphicsMode 4 -CameraMode walkLite -CameraViewport normal -Quality balanced -Projection table -MemoryLayout stable -SkipCmdUpdate
& $build -SceneFile .\examples\mode4-walkfull-reference.json -GraphicsMode 4 -CameraMode walkFull -CameraViewport normal -Quality balanced -Projection table -MemoryLayout stable -VideoStandard auto -SkipCmdUpdate
& $build -SceneFile .\examples\mode4-walkfull-reference.json -GraphicsMode 4 -CameraMode walkFull -CameraViewport normal -Quality balanced -Projection table -MemoryLayout stable -VideoStandard pal -SkipCmdUpdate
& $build -SceneFile .\examples\mode4-walkfull-reference.json -GraphicsMode 4 -CameraMode walkFull -CameraViewport normal -Quality balanced -Projection table -MemoryLayout stable -VideoStandard ntsc -SkipCmdUpdate
& $build -SceneFile .\examples\static-satin-material-reference.json -GraphicsMode 4 -CameraMode walkFull -CameraViewport normal -Quality balanced -Projection table -MemoryLayout stable -SkipCmdUpdate
& $build -SceneFile .\examples\dynamic-reflective-material-reference.json -GraphicsMode 4 -CameraMode walkFull -CameraViewport normal -Quality balanced -Projection table -MemoryLayout stable -SkipCmdUpdate
```

## Near profiles, stable culling, Ground, sharing, timeline, and outlines

```powershell
& $build -SceneFile .\examples\ground-plane-near-clip.json -GraphicsMode 4 -CameraMode fixed -CameraViewport normal -Quality balanced -Projection table -MemoryLayout high-basic-v2 -Mode4NearProfile clip -NoFpsOverlay -SkipCmdUpdate
& $build -SceneFile .\examples\ground-plane-near-clip.json -GraphicsMode 3 -CameraMode fixed -CameraViewport normal -Quality balanced -Projection table -MemoryLayout high-basic-v2 -Mode4NearProfile late -NoFpsOverlay -SkipCmdUpdate
& $build -SceneFile .\examples\shared-instances-timeline-static-light.json -GraphicsMode 4 -CameraMode fixed -CameraViewport normal -Quality balanced -Projection table -MemoryLayout stable -FaceCullProfile stable -NoFpsOverlay -SkipCmdUpdate
& $build -SceneFile .\examples\mode5-solid-color-outline.json -GraphicsMode 5 -CameraMode fixed -CameraViewport normal -Quality balanced -Projection table -MemoryLayout stable -FaceCullProfile stable -NoFpsOverlay -SkipCmdUpdate
```

`shared-instances-timeline-static-light.json` demonstrates source sharing,
using the documented `materialOverride`/`reflectivityOverride`/`colorOverride`
properties for per-instance appearance. Plain `material` is not a shared-instance
override. The scene also covers source-local face overrides, `light.type: "static"`,
a 50-Hz declarative timeline, and `resetKey: "SPACE"`. `mode5-solid-color-outline.json`
shows shared instances, solid face pigment, and the final clipped outline.
`ground-plane-near-clip.json` demonstrates the Mode 3–5 `clip` profile with a plane
Ground configuration.

## GraphicsMode 6 Gouraud references

Mode 6 requires `high-basic-v2` and accepts `gouraud.creaseAngle` from 0 through
180 degrees on each mesh (default 60):

```powershell
& $build -SceneFile .\examples\mode6-gouraud-torus.json -GraphicsMode 6 -CameraMode walkFull -CameraViewport normal -Quality balanced -Projection table -MemoryLayout high-basic-v2 -SkipCmdUpdate
& $build -SceneFile .\examples\mode6-gouraud-mixed-faces.json -GraphicsMode 6 -CameraMode fixed -CameraViewport normal -Quality balanced -Projection table -MemoryLayout high-basic-v2 -NoFpsOverlay -SkipCmdUpdate
& $build -SceneFile .\examples\mode6-gouraud-shared-materials.json -GraphicsMode 6 -CameraMode fixed -CameraViewport normal -Quality balanced -Projection table -MemoryLayout high-basic-v2 -FaceCullProfile stable -NoFpsOverlay -SkipCmdUpdate
```

The torus demonstrates smooth normals and an animated light; the mixed scene covers
native triangles and quadrilaterals with multiple material families; the shared
scene covers source sharing, per-instance materials/reflectivity, and a source face
whose explicit pigment bypasses dynamic shading. The complete algorithm, limits,
test matrix, and benchmark are in
[GOURAUD-MODE6-REPORT.md](../GOURAUD-MODE6-REPORT.md).
