# Mode 7 — PNG Texture Import

Release 1.13.0: [current optimizations](RENDER-OPTIMIZATIONS.en.md), [external inputs](EXTERNAL-INPUTS.en.md). All ../my-inputs/demos and native evidence are external to the source distribution.


Current 1.12.0 source contract. This manual describes the ordinary exporter unless
explicitly stated otherwise; bounded gameplay/configuration/roll/group APIs
are documented in [GAMEPLAY](GAMEPLAY.en.md). [Documentation index](DOCS.md).

PNG conversion is host-side only; the C64 does not decode PNG. Install Pillow with `python -m pip install -r requirements-mode7.txt`. Inline texels do not require Pillow.

A texture may use `source: "textures/file.png"`, resolved relative to the scene JSON directory, and the mandatory ordered list `sourceColors: ["#RRGGBB","#RRGGBB","#RRGGBB"]`: Dark, High, Highlight. These three distinct RGB colors map exactly to texel codes 1,2,3. `texturePalette` is separate: three VIC-II indices 0–15 controlling displayed colors, not the source image's RGB values.

## Strict requirements

- Actual PNG file, exactly 16 × 16 pixels, one static frame.
- Exactly three distinct RGB colors actually used, matching sourceColors.
- All pixels fully opaque (alpha 255); no transparency.
- At most 8-bit channels; no 16-bit PNG or animated PNG.
- No automatic quantization, resizing, filtering or color matching.
- source and texels are mutually exclusive. If width/height are supplied with source, both must be 16.
- Paths are scene-relative; keep assets with the scene when moving it.

A normal graphics-editor image must therefore first be manually resized to 16 × 16 and reduced to precisely three solid RGB colors. Disable antialiasing and export an opaque PNG, without changing the chosen RGB values. These preparation steps are outside the importer. A BMP/JPEG is not an accepted source.

## Complete working pair

[mode 7-cube-png.json](EXTERNAL-INPUTS.en.md) references [textures/bricks.png](EXTERNAL-INPUTS.en.md), with sourceColors `["#542C18","#D06820","#C8C8C8"]`. [mode 7-cube-gouraud.json](EXTERNAL-INPUTS.en.md) contains the equivalent 256 inline texels. Both use repeat[2,2], Gouraud C, and the same geometry/UVs/palette; with the same build options they produce byte-identical PRGs. Scene names may differ without affecting runtime data.

After conversion, a texture remains an unpacked 256-byte, page-aligned runtime table. PNG does not save runtime RAM and does not add a decoder. More used textures add pages; unused pages can be omitted. See [texture format](TEXTURE-GUIDE.en.md) and [Mode 7 build settings](MODE7.en.md).
