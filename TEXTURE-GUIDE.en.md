# Mode 7 Texture Format Guide

Every texture is **16×16**, row-major, unpacked: one byte per texel, 256 bytes. No other dimensions are supported. Integer JSON values **1, 2, 3** mean VIC-II pixel codes **01, 10, 11**. Do not write binary literals or RGB values as texels. **00** is reserved for the background; zero texels are rejected, not transparent.

At scene level, `texturePalette: [9,8,1]` assigns the VIC-II color indices (0–15) for Dark, High and Highlight in that order. These are the three texture pigments, not RGB colors. Multicolor cell palette sharing still applies. With lighting none they are sampled directly; flat changes lighting per face; Gouraud C modulates sampled pigments by shade vertex illumination. See [Mode 7](MODE7.en.md).

## Texture declaration

Choose exactly one of `texels` or `source`. A complete inline texture contains 256 integers. [mode7-cube-gouraud.json](examples/mode7-cube-gouraud.json) contains a complete inline brick pattern. [mode7-cube-png.json](examples/mode7-cube-png.json) has the equivalent PNG declaration:

```json
{
  "id": "diagnostic",
  "source": "textures/bricks.png",
  "sourceColors": ["#542C18", "#D06820", "#C8C8C8"],
  "repeat": [2, 2]
}
```

Inline form has `"width":16, "height":16, "texels":[...256 integers...]` instead of source/sourceColors. The ellipsis is explanatory only; use a complete supplied example as valid JSON. Declare 1–16 uniquely named textures; only referenced texture pages are emitted. Pages align to 256 bytes (initial padding 0–255); each additional used texture costs 256 bytes plus small selection metadata, without packing.

## UVs, repeat and seams

UVs are texel-space numbers, **not normalized 0–1**. Each component is 0–15.9375 inclusive, in exact steps of 0.0625 (Q4.4 encoded as 0–255). Choose either `uv` (one [U,V] per mesh vertex) or `faceUV` (one list of [U,V] corners per face), never both.

For a quad [0,1,2,3], a full-square corner list is:

```json
"faceUV": [[[0,0],[15.9375,0],[15.9375,15.9375],[0,15.9375]]]
```

For triangle [0,1,2], use three pairs, for example [[0,0],[15.9375,0],[0,15.9375]]. Each list must match its face's corner count. Corner UVs allow different coordinates on either side of a shared geometric vertex/edge; use them at seams. Quad triangulation 0→2 preserves these attributes.

A mesh's `texture: "diagnostic"` supplies its default. `faceTextures: [null,"second",null]` overrides individual faces, in face order; null inherits the mesh texture. The list must have exactly as many entries as source faces, before quad triangulation. See the complete [multi-texture scene](examples/mode7-multi-texture.json).

`repeat: [U,V]` defaults to [1,1]; each value must be 1,2,4,8 or16. It changes sampling frequency only, not the texture bytes. For encoded UV bytes u,v, addressing is:
`((floor(v*repeatV/16)&15)<<4) | (floor(u*repeatU/16)&15)`.
Nearest-neighbor and power-of-two wrap avoid expensive per-texel division.

## Authoring

Draw an opaque 16×16 image with exactly three RGB colors, no antialiasing. Use [PNG import](PNG-TEXTURES.en.md), or convert each pixel to integer1/2/3 according to an explicit RGB-to-pigment map, scan rows from top left, and paste all256 values into texels. Do not resize/quantize implicitly. Set texturePalette separately for the C64 colors you want.

Limits remain affine mapping, three pigments, Q4.4 and nearest-neighbor: no perspective correction, filtering, transparency or larger textures. Lighting adds shade/code memory and the applicable 255-shade-vertex limit; the builder's segment check is authoritative.
