# Mode8 memory — 1.15.1

Current native mono and multi map contracts retain separate auto/interactive
templates. Source-only package; supply external maps. No RAM banks, REU or
resolution/precision reductions are added by the agentic optimization.

| Region/resource | Current contract |
|---|---|
|Low code|From080d, at most3000 exclusive for multi; code_end assertion.|
|Bitmaps|6000/e000; active origins6660/e660,4608 active bytes per buffer.|
|Screens/font|4000/cc00 screen RAM; font5800/d800; existing banking/UI split.|
|Existing multi profile cache|4096 bytes; original32-slot/lazy16-column rules.|
|Existing multi state|448 bytes; fine buffer144 active bytes,256 reserved.|
|Fixed height helper|5500..55bf,192 bytes; fixed_height_end must not exceed55c0.|
|New per-plane cache|55c0..57a4,485 data bytes:97 valid flags and4×97 value bytes.|
|New cache helpers|57a5..57f9,85 code bytes; gr17_unit_code_end=57fa must not exceed5800.|
|Font guard|Six bytes remain before5800; assembler rejects overlap.|

Plane ratios are reset for every latched pose/composition. Physical plane IDs
0..96 are bounded; out-of-range IDs retain original division. Full profile
cache and new unit cache are distinct. Do not place custom data into apparent
gaps without checking all runtime tables/screens and the actual build map.

The standard public auto layouts retain157/120/62 low-code bytes for perimeter,
apertures/two-levels respectively; multi interactive retains1266. These are
code margins for the qualified templates, not general free-RAM promises.
Map capacities, buffers and extra navigation data retain their own guards.
The new helper adds2 return-stack bytes and no new zero-page reservation.
PRG file size includes gaps; it is not total RAM usage.

`work/mode8/build.py` reports codeLowBytes,lowFree,profileCacheBytes,
profileStateBytes,planeUnitCacheBytes and the half-open planeUnitCacheRange.
Assembler labels/maps are authoritative for the compiled document.
[Mode8](MODE8.en.md) · [Map format](MAPS-2.5D.en.md) ·
[Qualification](QUALIFICATION-1.15.1.en.md). Old MODE8-MEMORY.md is historical.
