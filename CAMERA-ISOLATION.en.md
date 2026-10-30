# CAMERA ISOLATION — 1.15.1

Stable1.15.1, source-only GitHub release. [Release status](RELEASE-STATUS.en.md) · [Current qualification](QUALIFICATION-1.15.1.en.md). Input scenes/assets are external; no demo projects are bundled.

> Stable1.15.1 source SDK published on GitHub. [Status and support](RELEASE-STATUS.en.md).

The compatibility selector `-Precision legacy -LegacyStability camera` requires
Mode2, walkLite, normal and high-basic-v2. It preserves four fractional position
bits through camera subtraction, yaw/pitch and original-vertex projection. It
retains Q6 coefficients and byte camera angles; no Q8/Normalized16 backend is used.

Projection uses the native arithmetic ratio with Q4 numerator/denominator instead
of integer-depth lookup. Raw geometry for culling/near intersections remains
integer: this profile does not contain legacy-plus near/screen fixes. Relative
coordinates must remain in[-1024,1024)WU per axis. Out-of-domain input sets
`legacy_camera_fault`; inspect it and the assembly high-segment guards.

The optimized `mul_s16_s6` quotient path uses native quarter-square products when
both positive operands fit signed8. Remainder, rounding and general fallback are
preserved; it does not add per-object/vertex caches. The byte-angle1.40625-degree
step and integer raster remain. This compatibility experiment is retained so
existing projects can reproduce its behavior. New native camera/near/FPS
qualification belongs to [legacy-plus](LEGACY-PLUS.en.md), not this path.

```powershell
python -B scripts/test_camera_profile.py --build ../camera-build --out ../camera-numeric.json
```

This is an arithmetic check on an external build, never an FPS benchmark.
[Precision](PRECISION.en.md) · [Testing](TESTING.md)
