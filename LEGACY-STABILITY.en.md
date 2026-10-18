# LEGACY STABILITY — 1.14.0-dev1

The compatibility selector is `-Precision legacy -LegacyStability corrected`.
Omitting LegacyStability, or choosing `historical`, preserves ordinary legacy.
The option is rejected for Q8, Normalized16 and Mode8; no automatic CPU-based
selection occurs. Use an external scene and a new external output directory.

Corrected adds exact signed24 Mode2 winding over full screen X, separate camera
transformation after composing world position, signed16 local/origin X/Y carry,
nearest signed Q6 products with signed8 saturation, and nearest integer camera
rounding (half toward positive infinity). Original geometry buffers and raster
remain. Original shared integer world points no longer depend on chunk origin
in the qualified identity-translation cases. This does not guarantee seams for
independently transformed arbitrary meshes.

This is a compatibility numeric profile, not legacy-plus. Camera angles remain
byte-based (1.40625 degrees); coefficients remain Q6, near geometry integer.
Mode2/Mode4 dev1 native evidence is historical, not a new1.13.0 FPS promise.
Use [legacy-plus](LEGACY-PLUS.en.md) for the current bounded Mode1–7 near/camera
qualification. No new qualification for Ground, other modes, NTSC or hardware
is inferred from this compatibility path.

Independent arithmetic checks accept caller-supplied external before/after
builds; no demo or compiled fixture is shipped:

```powershell
python -B scripts/test_legacy_stability.py --before ../control-build --after ../corrected-build --out ../numeric-check.json
```

[Precision](PRECISION.en.md) · [Testing](TESTING.md)
