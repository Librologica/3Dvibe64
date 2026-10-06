# Mode 7 texture precision — 1.7.0

The exact sampling contract below describes `textureQuality: standard` (default).
For approximate block8 sampling with upper-row reconstruction explicitly select
`textureQuality: fast` and read [Mode 7 fast](MODE7-FAST.en.md).

## Defaults and opt-in

**Geometry remains `legacy` and texture interpolation remains `affine` by
default.** Neither selects itself from CPU frequency. Old scenes/commands keep
their reference output. `-Precision q8` improves geometry, not texture perspective
by itself. Recommend Q8 above 20 MHz, legacy at 20 MHz and below; this is not an
FPS guarantee. Projective textures add substantial cost even on accelerated CPUs.

Select projective interpolation with scene `"texturePrecision":"perspective"`
or `-TexturePrecision perspective`, together with `-Precision q8 -GraphicsMode 7`.
An explicit CLI texture setting overrides the scene setting. Affine/perspective
do not change the source texture format, PNG importer, repeat, palette or lighting.

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -Precision q8 -GraphicsMode 7 -TexturePrecision perspective -SceneFile examples/mode7-perspective-cube.json -Q8Camera stationary -VideoStandard pal -OutputDirectory ../perspective-cube-pal
```

Use a new output directory outside the SDK. `3Dvibe64.prg`, labels, ASM, memory
map and build metadata are written there. No PRG, production demo or soundtrack
is distributed. The example is the existing public diagnostic cube specialized
for this profile, not the development scene.

## Supported profile

All existing Q8 restrictions apply: normal 160×100 logical viewport without
header/FPS split; walkLite stationary/interactive/auto; explicit PAL/NTSC; one or
two disjoint nonshared objects; at most 96 vertices; scaled radius <=40 WU per
object; scale >0 and <=1; no Ground, timeline, small viewport or camera roll.
The allocator may reject a scene before these geometric limits are reached.
See [geometric Q8 restrictions](PRECISION.en.md).

Additional projective carrier domain: camera-forward depth **1–256 WU inclusive**
after near clipping. This is not a Euclidean camera distance or a scene-size
guarantee. Interactive/automatic camera movement must stay within that domain.
`ps_fault` is sticky; an invalid depth or denominator prevents publication of
the completed frame and stops rendering with a red border. Reposition/rebuild,
do not treat a fault as a perspective-to-affine fallback. Build-time validation
cannot prove all future interactive poses. Unsupported CLI combinations are
rejected, never silently changed.

Lighting `none`, `flat`, and `gouraud` remain dynamic engine paths. Textured
Gouraud requires compositor C; normals, creaseAngle, reflectivity and 33 shade
levels retain their existing meaning. No baked or camera-attached light is added.

## Numerical architecture

Near clipping transports raw UV (Q4.4 with 8 additional clipping fraction bits).
For camera depth Q16.8, W=floor(8388608/depthQ8). Each attribute carrier is
floor(rawUV16*W/32768), unsigned 16; W is unsigned 16. Screen clipping then
interpolates UW/VW/W with the geometric parameter. Exact Euclidean quotient/
remainder edge and span DDAs advance these carriers. Each sampled coordinate
is floor(carrier*128/W), using the low byte for the established repeat sampler.
Gouraud Q keeps its existing screen-space DDA.

This is perspective-correct interpolation of **quantized carriers**, not infinite
precision or bit-exact continuous real geometry. Finite reciprocal/carrier/Q2
rounding and nearest-neighbor aliasing remain. It eliminates the deliberate
affine interior interpolation; it does not guarantee zero texel error versus a
floating-point oracle, nor increase resolution or UV source precision.

## Exact optimizations

- Signed span setup uses restoring 16/8 division with Euclidean rounding.
- Projection/clipping 48/24 division skips leading zero bits without changing
  quotient/remainder. A guarded 16×16 clipping product keeps the full 24×24 path.
- Near-plane reciprocal encoding is an exact identity at 1 WU. An 8-entry FIFO
  caches the full fractional depth and its exact reciprocal, not rounded bins.
  The cache costs 34 state bytes; it is per PRG and main-thread only.
- Unlit spans use a guarded exact rational recurrence (W 256..8191 and integer
  carrier steps±32, width>=8), with exact division for every unsupported case.
  No approximate blocks or error-tolerance relaxation.
- The builder detects uniform emitted texture pages (including PNG input).
  Uniform surfaces skip UV sampling/advance/setup while preserving the existing
  lighting DDA, texture fetch, byte masks and framebuffer.

All specializations are compile-time confined to projective Mode 7. The four-pixel
packer and partial-byte handling remain. There is no universal speedup guarantee:
fallback-heavy scenes can be slower. The reciprocal, UW/VW/W scanline arrays,
clipping channels and generated routines consume additional RAM; `build.json`
lists actual block sizes and placement. No bank, screen buffer or guard is stolen
to force a scene to fit.

## What is deliberately not promoted

No approximate four-pixel correction, hardcoded two-room portal culling, custom
painter ordering, baked lighting or demo-specific geometry/viewport. No Z-buffer,
general portals/PVS, bilinear filtering, mipmapping, transparency, packed runtime
texture or native quad mapper. Quad split remains 0→2. Affine retains its broader
legacy camera/viewport support. [Testing](TESTING.md) distinguishes CPU arithmetic,
native checks and hardware tests; synthetic cycle costs are not measured FPS.
## 1.6.1: exact paired UV division

Version 1.6.1 adds a paired restoring divider for
nonuniform projective textures with flat/Gouraud C lighting. U/V sampling and
all numerical results remain exact under the existing integer carrier contract.
Seven fractional steps are unrolled; no denominator patching or approximation.
The original scalar divider handles out-of-fast-domain inputs and zero W.
Eight zero-page bytes $E8-$EF are reserved while the renderer owns the machine;
external IRQ/KERNAL extensions must not use this scratch or call the sampler.
The routine is not reentrant. Existing renderer IRQs do not access this state.
It adds code, not texture RAM; ordinary memory-budget checks remain active.
Unlit rational recurrence and all-uniform textures retain their old paths.
Affine, legacy, other modes, viewport/camera limits and precision defaults are
unchanged. The paired block occupies 682 bytes; net code growth on the public
cube is 673 bytes, with no extra absolute scratch. A measured cube pose saves
16.30% Gouraud / 17.36% flat instruction cycles, excluding VIC stalls, IRQ,
wait and presentation. This is not a native FPS measurement or universal gain.
Additional code reduces scene-specific memory headroom; unsafe layouts are
still rejected, not silently simplified. See [release notes](RELEASE-NOTES-1.6.1.md).

