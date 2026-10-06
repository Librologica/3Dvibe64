# Mode 7 fast profile — 1.7.0

## Selection and defaults

`-TextureQuality fast`, or scene `"textureQuality":"fast"`, selects the fast
profile. An explicit CLI option overrides the scene. `standard` is the default;
it preserves the preceding output. Geometry remains `legacy` and texture
precision remains `affine` unless explicitly selected. No CPU-based selection.
Q8 is recommended above 20 MHz; legacy remains recommended at or below 20 MHz.

`TextureQuality` is independent of the existing `Quality fast` build preset:
that preset alone does not enable block8 sampling or row reconstruction.

Fast requires **Mode 7 + Q8 + perspective + Gouraud compositor C**. Invalid
combinations are rejected, not silently downgraded. It is true polygonal 3D,
not raycasting. This release promotes reusable sampling/reconstruction methods,
not the two-room development demo, its visibility assumptions or its LUT.

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 7 -Precision q8 -TextureQuality fast -SceneFile examples/mode7-fast-cube.json -VideoStandard pal -OutputDirectory ../fast-cube-pal
```

Use a fresh directory outside the SDK. The scene already specifies perspective
textures, Gouraud C and fast quality. For an existing compatible scene also use
`-TexturePrecision perspective`. Python's equivalent is
`python -B work/q8/build.py --scene examples/mode7-fast-cube.json --out ../fast-cube-python --mode 7 --texture-quality fast`.
PRG, generated ASM, labels, memory map and `build.json` go outside the package.

## Rendering contract and quality tradeoffs

The normal Q8 viewport stays **160×100 logical / 320×200 physical**. Only even
logical rows are shaded/sampled; the final pass copies each upper logical row
into the following omitted row, including both physical scanlines. Effective
vertical sampling is **160×50**, not 160×100 independent samples. There is no
temporal interlace, alternate-frame reuse or motion interpolation.

Eight-pixel blocks reconstruct perspective UV exactly at the endpoints using
the preceding fixed-point carrier contract. Interior samples interpolate the
eight-bit endpoints affinely. The final one–eight samples use the exact sampler;
endpoints never extend beyond the span. This is approximate block-perspective
mapping, not exact perspective correction at every pixel. Nearest-neighbor,
UV Q4.4, repeat and texture 16×16 unpacked are unchanged. Repeat can amplify
interior errors. Strong perspective and wrapping can produce visible distortion.

Geometry Q8, near/screen clipping, half-open edge ownership, byte masks and
double buffering remain. Bounds and palette claims are evaluated on all rows,
in the original face order; UV/W/Q attributes on retained rows keep the exact
edge DDA. Palette claims on omitted rows are necessary because VIC-II colors
are shared across a cell. Upper duplication stays within the same color cell,
so it does not convert palettes or introduce arbitrary RGB colors.

Gouraud C's neutral Q=10..22 spans bypass its unchanged-color compositor.
When both endpoints lie in that interval the monotonic DDA stays inside it.
Other spans restore the original shader. Repeating the upper row also repeats
its shading/dither pattern: diagonals and silhouettes are visibly coarser.
Uniform textures are recognized by actual page contents, not texture IDs.

## Memory, limits and interrupts

All [Q8/perspective limits](TEXTURE-PRECISION.en.md) still apply: explicit
PAL/NTSC, normal viewport, walkLite, one or two nonshared objects, at most 96
vertices, scaled radius up to 40 WU/object, no Ground/timeline/roll. Depth along
the camera axis is 1–256 WU after clipping. A sticky `ps_fault` prevents an
invalid view from being published and stops with a red border.

Additional block state is about 35 bytes. Private carrier-row arrays are
paired at offsets 0/1, indexed only by even rows: eight high/W arrays use
**800→400 bytes**, V lows use the spare odd U-low slots, and Q arrays share a
100-byte pair. Total row-attribute saving is **700 bytes** at height 100.
Bounds and palette work remain full-height. Helper code
uses existing guarded packing units; all four original memory windows and
32-byte code guards remain. The actual allocator can reject a scene before its
geometric limits, especially with mobile camera code or several textures. The
public fast cube is a stationary-camera example; automatic/interactive camera
requires a scene that fits the same budget. No silent precision reduction.

The duplicate narrow scalar UV divider is omitted only in fast builds: the
paired fast divider already handles that domain; fallback uses the complete
exact scalar divider. Its quotients/remainders are verified, not approximated.

Paired UV division keeps the reserved `$E8..$EF` zero-page scratch. Neutral
span selection patches the scalar shader entry instructions only between
spans. These routines are not reentrant. Existing IRQs do not call the renderer
or use its scratch; custom IRQ extensions must respect both conditions.

## Verification and performance

`scripts/test_texture_fast.py` builds PAL/NTSC in temporary directories and
executes the emitted 6502 arithmetic: step-eight carrier prediction including
carry, all UV endpoint pairs, short spans/tails, retained edge attributes,
both-buffer duplication and shader transitions. Run through
`python -B scripts/run_release_tests.py test_texture_fast.py`.

The fast image is deliberately different from standard; it is not a bit-exact
replacement or an 8-FPS guarantee. Small objects may gain little or lose time
because reconstruction always copies a complete viewport. Performance depends
on coverage, clipping, shader and memory. The development two-room video's FPS
include additional scene-specific optimizations that are **not** promoted here.
See [release notes](RELEASE-NOTES-1.7.0.md) for qualification scope and evidence.
No production demo, generated PRG, music or raw benchmark is packaged.
