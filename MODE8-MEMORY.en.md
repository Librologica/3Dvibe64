# Mode8 memory — 1.20.0

> Stable source SDK 1.20.0. Published on GitHub. [Qualification](QUALIFICATION-1.20.0.en.md).


Current native mono and multi map contracts retain separate auto/interactive
templates. Source-only package; supply external maps. No RAM banks, REU or
resolution/precision reductions are added by the agentic optimization.

| Region/resource | Current contract |
|---|---|
|Low code|From080d, at most3000 exclusive for multi; code_end assertion.|
|Bitmaps|6000/e000; active origins6660/e660,4608 active bytes per buffer.|
|Screens/font|4000/cc00 screen RAM; font5800/d800; existing banking/UI split.|
|Existing multi profile cache|4096 bytes; original32-slot/lazy16-column rules.|
|Current multi coefficient/state data|608 bytes; fine buffer144 active bytes,256 reserved.|
|Shared-zero support|ca20..cab7:24 code bytes,128 immutable data bytes; inside ca00..caff.|
|Fixed height helper|5500..55bf,192 bytes; fixed_height_end must not exceed55c0.|
|New per-plane cache|55c0..57a4,485 data bytes:97 valid flags and4×97 value bytes.|
|New cache helpers|57a5..57f9,85 code bytes; gr17_unit_code_end=57fa must not exceed5800.|
|Font guard|Six bytes remain before5800; assembler rejects overlap.|

Plane ratios are reset for every latched pose/composition. Physical plane IDs
0..96 are bounded; out-of-range IDs retain original division. Full profile
cache and new unit cache are distinct. Do not place custom data into apparent
gaps without checking all runtime tables/screens and the actual build map.

The standard public auto layouts retain157/120/3 low-code bytes for perimeter,
apertures/two-levels respectively; multi interactive retains1207. These are
code margins for the qualified templates, not general free-RAM promises.
Map capacities, buffers and extra navigation data retain their own guards.
The new helper adds2 return-stack bytes and no new zero-page reservation.
PRG file size includes gaps; it is not total RAM usage.

`work/mode8/build.py` reports codeLowBytes,lowFree,profileCacheBytes,
profileStateBytes,planeUnitCacheBytes and the half-open planeUnitCacheRange.
Assembler labels/maps are authoritative for the compiled document.
[Mode8](MODE8.en.md) · [Map format](MAPS-2.5D.en.md) ·
[Current qualification](QUALIFICATION-1.20.0.json). Old MODE8-MEMORY.md is historical.

The multi profile cache retains 32 slots and 4096 bytes with second-chance replacement. Its 32 extra state bytes occupy $ca00..$ca1f in the existing layout_support window; the 485-byte plane-unit cache is separate. The shared zero profile uses 128 bytes and a 24-byte helper at $ca20..$cab7; total coefficient/state data is 608 bytes, without new aliases. Automatic and interactive templates share this algorithm. Guards, geometry, lazy sampling, input and presentation retain their respective contracts.

The [current ledger](QUALIFICATION-1.20.0.json) retains build identities and the conditions required to reuse native measurements.
