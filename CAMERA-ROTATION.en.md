# CAMERA ROTATION — 1.13.0

`-Precision legacy -LegacyStability rotation` preserves the original finer
camera-rotation profile. It requires Mode2, walkLite, normal, high-basic-v2 and
`-NoFpsOverlay`. Legacy-plus inherits its transform but adds a distinct clipping
pipeline; selecting rotation alone does not apply the plus near fixes.

## Public fractional camera ABI

Yaw/pitch support4096 phases per turn,0.087890625degrees. Historical
`explorer_cam_yaw` / `explorer_cam_pitch` remain the high bytes. The top four
bits of `explorer_cam_yaw_frac` / `explorer_cam_pitch_frac` carry the low phase;
the bottom four bits are ignored. Alternatively call
`legacy_camera_set_yaw_phase` or `legacy_camera_set_pitch_phase` with A=low byte,
Y=high byte of a wrapping16-bit phase. Supply all inputs before
`render_frame_begin`; coefficients are prepared once per new view.

Byte-only keyboard input does not acquire fractional steps automatically.
The native qualification uses an external driver supplying these public
fractions. Camera sine has256 signed Q10 samples with4-bit linear interpolation.
Only camera coefficients are Q10; object matrices remain Q6 and temporary
camera coordinates Q4. Signed products round nearest, halfway away from zero.
The relative camera domain is[-1024,1024)WU per axis; check `legacy_camera_fault`.

## Exact product and repeated-transform caches

When the assembled pool fits, four three-plane product LUTs consume3072bytes,
page-aligned after existing buffers. They rebuild only when a coefficient's
absolute value changes. Sign and rounding match the serial product. If the
tables do not fit, compilation selects the serial fallback. The no-overlay
requirement avoids the old high-font overlap; the actual map is authoritative.

Consecutive objects with the same effective nine-byte scaled matrix reuse
local-coordinate terms. Cache validity resets every view. This changes neither
matrix nor numeric values and does not depend on scene/object identities.
Original raw geometry, near intersections and raster in rotation remain integer.
Use [legacy-plus](LEGACY-PLUS.en.md) for Q4 near/screen clipping and current
native cadence qualification. No arbitrary-scene, NTSC or hardware guarantee
is inferred from the older compatibility profile.

```powershell
python -B scripts/test_camera_rotation.py --build ../rotation-build --out ../rotation-numeric.json
```

The external-build arithmetic check is not FPS.
[Precision](PRECISION.en.md) · [Testing](TESTING.md)
