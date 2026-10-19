> Development edition 1.15.0-dev1; inherited1.14.0 contracts remain unless explicitly extended in [exact rendering](EXACT-RENDER.en.md).

# Numeric maintenance — 1.14.0

Stable release 1.14.0: [current optimizations](RENDER-OPTIMIZATIONS.en.md), [external inputs](EXTERNAL-INPUTS.en.md). All demonstration projects and raw native evidence remain external to the source distribution.


Current 1.14.0 source contract. This manual describes the ordinary exporter unless
explicitly stated otherwise; bounded gameplay/configuration/roll/group APIs
are documented in [GAMEPLAY](GAMEPLAY.en.md). [Documentation index](DOCS.md).

Mode 7 Q8 keeps camera-near clipping followed by screen-Q8 clipping and Q2 rasterization. Before the signed 24 projection cache can lose a remote coordinate's sign, the complete unsigned 48 quotient supplies true side-plane outcodes. The AND of every near-clipped polygon corner rejects only a common exterior side plane. A single exterior corner never rejects a crossing face; coordinates are not independently saturated for UV interpolation.

The existing public scaled mesh radius≤40 WU is retained. A contributing face in this bounded transform profile fits the signed 24 screen/intersection domain. Do not broaden the diameter/near-depth contract without rechecking that bound. Near-generated corners receive their own outcodes; behind-camera source corners are not incorrectly used as positive-depth projected points. Normalized 16 retains its separate homogeneous clipper.

Conservative bound for this contract: signed-byte local coordinates have norm below 222 WU; scaled radius is at most 40 WU. Rounded/interpolated Q8 trig differs from ideal trig by less than 1.1/256; nested matrix products contribute less than 0.03 per coefficient before scaling. The three-axis matrix error contributes less than 3.6 WU, final coefficient rounding less than 1.4 WU. Two camera rotations and coordinate rounding still leave each transformed mesh inside a 50 WU radius, hence diameter below 100 WU. Near clipping retains this convex bound with ample rounding margin. At near depth 1 WU, focal length 170, centered viewport extents 80/50, any nontrivially accepted polygon has projected X span bounded by `(170+80)*100 = 25000` pixels and Y span by `(170+50)*100 = 22000`. If an axis straddles zero the tighter bound is `170*100`; if it stays on one side, an endpoint within that side plane anchors the bound. Individual contributing projected coordinates therefore remain below the signed 24 Q8 range (±32768 pixels), as do screen-intersection deltas. Entirely exterior polygons can exceed it and are rejected using the full quotient before those wrapped caches enter screen clipping. This proof depends on the existing radius, coordinate, near and focal constants.

The supplied x 206, z 1/33 case previously wrapped 35100 px to −30436 px and painted 8000 bitmap bytes. The RC produces zero bitmap bytes and hp_fault=0. The x 192, z 1 control remains empty. Independent assembled tests cover mirrored extremes, thresholds, near/screen crossings and exact affine UVs. Other shared profiles are tested separately: none/flat/Gouraud, affine/perspective and Gouraud fast, PAL/NTSC.

Mode 7 flat lighting now saturates each light-only Q6 product before signed-byte interpretation. In particular −128 × −64 / 64 becomes 127, not −128. The shared geometric mul_s 6 is unchanged. Gouraud uses the same source helper with its original emitted instructions. The native 180-degree case yields [0,30,127] and the expected opposite face levels; exhaustive assembled light products cover 256 × 129 inputs per standard.

Configuration follows default<JSON<explicitCLI for texture settings used by preparation. PNG paths still resolve beside the original scene. Optional contract and objectModel viewport lookup use the same property-safe helper. Assembler label paths use the OS-native resolved path. Mode 8 public input checks remain active under python -O; coincident heading is 64 in both host and runtime.

Native reuse requires an acquisition manifest binding program, scene, build settings, labels, font, video standard, run mode and captured file hashes. Changed/missing evidence is rejected. Old captures remain historical material, not qualification of a different PRG. Synthetic identity fixtures exercise validation only and never provide FPS.

Allocation first preserves previous successful placements. If that restricted search fails, all legal aligned addresses are explored within 60,000 Q8 / 100,000 Normalized 16 states. SEARCH_BUDGET_EXHAUSTED differs from NO_ALIGNED_PLACEMENT. Page/word alignment, 32-byte code guards and original memory ranges remain enforced. The 512/468-byte counterexample now fits. Retired coordinate-cache relayout is deferred: measured 15/18-byte reservations do not justify expanding this RC's runtime layout scope.
