# GraphicsMode 7 — Texture Mapping

The default is the qualified R1 software **affine** texture mapper for the VIC-II
multicolor bitmap. Version1.6.0 adds optional fixed-point projective interpolation
in the bounded Q8 profile; it is not enabled by Q8 alone. See the complete
[texture precision contract](TEXTURE-PRECISION.en.md) before selecting it.

1.6.1 optimizes only projective flat/Gouraud C nonuniform UV division, exactly.
Eight zero-page bytes `$E8..$EF` are reserved; external IRQs must not use them.
The default affine renderer and lighting/output contracts remain unchanged.
See [maintenance notes](RELEASE-NOTES-1.6.1.md) for code cost and measured scope.

## Modes and lighting

| Mode | Surface rendering |
| --- | --- |
| 4 | Dynamic flat shading, one lighting value per face. |
| 6 | Ordered-dithered Gouraud shading, interpolated shade vertices, 33 levels. |
| 7 | Affine textures, optionally with dynamic flat or Gouraud lighting. |

Scene `textureLighting` omitted or `"none"` means unlit textures. `"flat"` enables dynamic face lighting. `"gouraud"` enables shade-vertex lighting and interpolation of U/V/Q, with Q in 0–32.

For textured Gouraud the official compositor is `textureCompositor: "C"`, also the 1.3.0 default when lighting is Gouraud. Specify C explicitly in portable scenes. A/B remain accepted for compatibility/diagnostics; they are not the recommended public path and do not inherit the C-only R1 edge fix.

Compositor C is texel-first: sample the pigment, then apply illumination. The central light band preserves all three texture pigments; darker/brighter bands shift pigments, with screen-anchored Bayer 4×4 transitions. It preserves pattern contrast, but does not promise unchanged pigments at every light intensity. LightFix corrects signed light-vector arithmetic and saturation; no new lighting model is introduced. Materials and reflectivity use the established lighting pipeline. With `none`, lights, normals and reflectivity do not dynamically shade the texture.

## Build

Use Python 3, PowerShell and 64tass; set `TASS64_EXE` to the assembler. Install Pillow only when using PNG sources. Work in a writable SDK copy, not a frozen distribution.

```powershell
python -m pip install -r requirements-mode7.txt
$env:TASS64_EXE = "C:\tools\64tass.exe"
.\work\build-3Dvibe64.ps1 -SceneFile .\examples\mode7-cube-gouraud.json -GraphicsMode 7 -MemoryLayout high-basic-v2 -Quality fast -Projection extended-table -Mode4NearProfile clip -VideoStandard pal -CameraViewport normal -CameraMode fixed -FpsCounterOnly -SkipCmdUpdate
```

The scene must contain `graphicsMode: 7`. Mode 7 requires `high-basic-v2`, `fast`, `extended-table` and near profile `clip`; the adapter supplies these defaults when omitted. Do not substitute the older Mode 4 balanced/table build settings.

## Geometry and raster pipeline

Explicit mesh vertices and triangle/quad faces are accepted. Quads split deterministically along **0→2**, into (0,1,2) and (0,2,3), preserving winding and corner UVs. All runtime faces are triangles. Face texture selection follows both child triangles; flat lighting retains the source face relationship.

Transformation, projection, culling, depth buckets, camera, near-plane and screen clipping feed the texture rasterizer. Generated clipping vertices interpolate U/V, and Q for Gouraud, with the geometric clipping parameter. Integer/fixed-point edge and scanline DDAs preserve the validated X/U/V relationship. Texture seams are represented by per-corner UVs, independently of smooth-normal seams.

The kernel assembles four 2-bit logical pixels into each full bitmap byte. Short spans and partial bytes use masks preserving neighboring pixels. Double buffering, PAL/NTSC, normal/small viewports and fixed/walkLite/walkFull cameras remain supported.

R1 corrects edge inclusion in the Gouraud C path: integer-ceiling half-open edges, coherent ownership of shared edges, and explicit closed viewport boundary caps, including single-pixel cap spans. It removes the qualified outside-surface pixels and gaps without changing geometry, UV precision or lighting. None/flat and legacy A/B paths retain their previous raster behavior.

## Smooth shading

`gouraud.creaseAngle` defaults to 60°, range 0–180°. Smaller angles preserve hard edges; 180° smooths adjacent curved surfaces as far as the topology permits. This changes normals/shade vertices, not polygon count or silhouette. A cube at 60° keeps hard edges; the sphere/torus examples use smooth normals. UV seams do not require a visible lighting seam.

The runtime shade-vertex limit is 255 where applicable, including normal splits and instances. The scene also has an at-most-255 runtime triangle limit. Actual memory fit is checked by the builder and can fail earlier.

## Memory and scope

Textures are unpacked, page-aligned, 256 bytes per used 16×16 texture, plus alignment and face/pointer metadata. Unused texture pages and unused Gouraud lighting metadata are omitted when possible. Low/middle/relocated/high segments use the recovered layout; high code/data must remain below $D000. Geometry, UVs, clipping buffers, shade state and generated code compete for this space. There is no universal mesh-size budget independent of lighting and scene configuration.

Mode 7 currently requires explicit geometry: no builtin/file mesh loader, `meshSourceSharing`, face shading overrides or per-object material/color/reflectivity override fields. Ordinary supported material/reflectivity properties are distinct from those Mode 6 override features.

Common limits: nearest-neighbor;16×16 textures;three VIC-II pigments;UV Q4.4;
runtime triangles and triangulated quads. No bilinear filtering, mipmapping,
transparency, packed runtime textures or native quad mapper. The default affine
path has no perspective correction. Projective sampling is optional and has
narrower camera/viewport/depth limits, extra memory and CPU cost. Nearest-neighbor
aliasing and fixed-point quantization remain in both paths.

See [texture format](TEXTURE-GUIDE.en.md), [PNG import](PNG-TEXTURES.en.md),
[texture precision](TEXTURE-PRECISION.en.md), [examples](examples/README.md),
and [tests](TESTING.md). Modes1–6/8 and old affine output retain their references.
