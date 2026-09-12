# Mode 7 — PNG Texture Import

PNG conversion is host-side only; the C64 does not decode PNG. Install Pillow with `python -m pip install -r requirements-mode7.txt`. Inline texels do not require Pillow.

A texture may use `source: "textures/file.png"`, resolved relative to the scene JSON directory, and the mandatory ordered list `sourceColors: ["#RRGGBB","#RRGGBB","#RRGGBB"]`: Dark, High, Highlight. These three distinct RGB colors map exactly to texel codes1,2,3. `texturePalette` is separate: three VIC-II indices0–15 controlling displayed colors, not the source image's RGB values.

## Strict requirements

- Actual PNG file, exactly16×16 pixels, one static frame.
- Exactly three distinct RGB colors actually used, matching sourceColors.
- All pixels fully opaque (alpha255); no transparency.
- At most8-bit channels; no16-bit PNG or animated PNG.
- No automatic quantization, resizing, filtering or color matching.
- source and texels are mutually exclusive. If width/height are supplied with source, both must be16.
- Paths are scene-relative; keep assets with the scene when moving it.

A normal graphics-editor image must therefore first be manually resized to16×16 and reduced to precisely three solid RGB colors. Disable antialiasing and export an opaque PNG, without changing the chosen RGB values. These preparation steps are outside the importer. A BMP/JPEG is not an accepted source.

## Complete working pair

[mode7-cube-png.json](examples/mode7-cube-png.json) references [textures/bricks.png](examples/textures/bricks.png), with sourceColors `["#542C18","#D06820","#C8C8C8"]`. [mode7-cube-gouraud.json](examples/mode7-cube-gouraud.json) contains the equivalent256 inline texels. Both use repeat[2,2], Gouraud C, and the same geometry/UVs/palette; with the same build options they produce byte-identical PRGs. Scene names may differ without affecting runtime data.

After conversion, a texture remains an unpacked256-byte, page-aligned runtime table. PNG does not save runtime RAM and does not add a decoder. More used textures add pages; unused pages can be omitted. See [texture format](TEXTURE-GUIDE.en.md) and [Mode7 build settings](MODE7.en.md).
