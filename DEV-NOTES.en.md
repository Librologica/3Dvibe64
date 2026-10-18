# Development notes — 1.14.0

Stable source SDK promoted from the qualified1.14.0-dev1 development based on1.13.0. Adds legacy-plus Mode1–7 and Mode7 affine/perspective without Q8 geometry. The public selector remains opt-in; old legacy/Q8 controls and original Mode2 plus reference bytes remain unchanged. No official/frozen trees or demos are modified.

Mode adapters retain native raster conventions; Q4 near/screen transport carries UV/shade attributes coherently. Projective UW/VW/W use bounded16-bit carriers and shared texture DDAs. Empty half-open spans are suppressed; solid/Gouraud helpers are allocated in actual free guarded RAM. Profile/depth/RAM refusals remain explicit.

[Build, ABI and constraints](LEGACY-PLUS.en.md) · [native FPS/stability and regressions](QUALIFICATION-1.14.0.en.md) · [testing](TESTING.md). Mode4 camera performance regresses versus legacy; perspective cost is scene-dependent. This is a qualified stable profile, not a claim that all legacy options now support plus.
