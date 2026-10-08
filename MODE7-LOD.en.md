# Mode 7 gradual texture LOD (1.8.0)

An explicit image-quality option, not raycasting, mipmapping or an exact-image optimization. Geometry, coverage, projective endpoints and lighting keep their existing contracts. `off` is the default. The standard and fast texture-quality profiles remain separately selectable.

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -Precision q8 -GraphicsMode 7 -SceneFile examples/mode7-perspective-cube.json -TextureQuality fast -TextureLOD gradual -TextureLODNear 28 -TextureLODFar 44 -OutputDirectory ../lod-build
```

The scene may instead contain `"textureLOD": "gradual"`, `"textureLODNear": 28`, `"textureLODFar": 44`. Explicit CLI values override scene values. Both distances are integer world units, with `1 < near < far < 256` and a **16 WU** transition interval. Unsupported combinations are rejected. Requires Q8 and perspective texturing, within the existing bounded Q8 object/camera/depth/memory profile. Standard supports none/flat/Gouraud C; fast still requires Gouraud C. LOD does not enable fast automatically.

The build counts the actual 256 runtime texels (PNG and inline are equivalent). The modal pigment is the most frequent of 1/2/3, ties choosing the lowest index. The accent is the most saturated present pigment in a fixed VIC-II RGB ranking, then the brightest, then the lowest index. This ranking does not change the emulator palette. Selection is palette-specific for each runtime face; there is no hardcoded texture ID or room list.

The minimum original face-corner camera depth selects detail conservatively. A corner behind the camera retains full detail. At or before `near`, the texture remains complete. Between near and far, an anchored Bayer 4×4 mask blends complete detail with the far pattern in sixteen steps. At/after far the fill is 75% modal pigment and 25% accent pigment. Gouraud/flat composition, when selected, is applied afterward. Already uniform texture pages are unchanged. This is a per-face depth classifier, not per-pixel LOD; long faces may retain detail because one corner is near. No lower-resolution texture pyramid is emitted.

Standard anchors the pattern to logical x/y. Fast anchors y to its sampled row index (`y/2`) and duplicates the result into the omitted row. No temporal dithering. At far LOD, existing uniform dispatch bypasses UV division and carrier advancement; the original bounded page read is retained and replaced by the selected pigment. Encoding and depth-domain checks remain live.

The renderer patches one JSR/BIT opcode outside the sample loop to bypass blending at full detail. Address-sampler and texture-page patch operands are unchanged. IRQ never enters or patches these routines. State and code use the existing guarded allocator; configurations outside the memory budget fail rather than silently reducing quality. Camera-mobile fast configurations can exhaust RAM even without LOD: support is determined by the real build, not by a blanket scene-size promise.

Assembled arithmetic/sampler tests, native captures and measured performance are recorded separately in the qualification report of the code-identical release candidate. A gain is scene- and distance-dependent; no universal FPS increase or hardware qualification is implied.
