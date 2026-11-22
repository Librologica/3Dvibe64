# RuntimeScene — 1.20.1

> Stable source SDK 1.20.1. [Qualification](QUALIFICATION-1.20.1.en.md).

Optional distance fade in Modes1–8: `-DistanceFade off/dither`, `-DistanceFadeStart`, `-DistanceFadeEnd`; default off. Mode7 texture LOD stays independent. See [complete contract](DISTANCE-FADE.en.md).

[Italiano](RUNTIME-SCENE.it.md).
Optional source compiler, not an application or a new graphics mode.
See [dynamics](DYNAMICS.en.md), [assembly/memory](ASSEMBLY-GUIDE.en.md) and [qualification](QUALIFICATION-1.20.1.json).

An external Scene1 may include `runtimeScene`. The ordinary builder validates
and strips this record before native compilation. Supported profile: `legacy-plus`,
Mode4/5/6, `walkLite`, normal160x100, `high-basic-v2`, `-NoFpsOverlay`, PAL,
near-poly/screen Q4 clipping. Other profiles are rejected. The original default
pipeline and AnimatedMesh API are retained. Combining mutable `animatedMeshes`
with this immutable-coordinate extension is rejected. Dynamic view does not
support the separate ground/grounds renderer; supply mesh geometry instead.

```json
{
  "coordinateTerms": "active-mesh",
  "rigidMatrixCache": true,
  "objectBounds": true
}
```

This is the value of `runtimeScene`, not a complete scene. No configuration is
enabled implicitly. Omit the entire field for parent behavior. Build using the
ordinary `work/build-3Dvibe64.ps1 -SceneFile <external-scene>` and the profile
above; `-SkipCmdUpdate` avoids updating the optional launcher. Generated assembly,
plan and `.runtime-scene.json` describe selected features; build in a working SDK
copy, keeping the distributed source tree clean.

| Field | Contract |
|---|---|
| `coordinateTerms` | `full` (default) or `active-mesh`. Deduplicated coordinate-index lists for the active source mesh. Cache key includes mesh and all9 effective scaled matrix bytes. |
| `rigidMatrixCache` | Boolean. Consecutive identical object pose/scale restores9 matrix and6 trig bytes before consumers; dynamic light can reconstruct its unscaled matrix. |
| `uniformGouraud` | Boolean, Mode6 only. All vertex/clip shades0 or32 use native solid fill only after the emitted Bayer rows prove the same uniform pigment. Other shades keep Gouraud. |
| `gouraudSaturation` | Integer1..32, default32, Mode6. Output curve `min(32,round(q*32/s))` before material boost. Canonical temporal shade state is unchanged. Lower values enlarge the bright area; this deliberately changes lighting. |
| `lighting` | Object-ID map: `dynamic`, `frozen`, `solid`. Frozen Mode6 computes once; solid requires explicit `colorOverride`. Unknown object IDs are rejected. |
| `solidLamp` | Mesh-ID map for external inline vertices/faces. `position` local point lamp, VIC-II `dark`/`bright`0..15, optional `threshold`-1..1 and `emissive` face-index/color map. Compiles `faceSolidColors` once; no per-frame lamp work. Symmetric geometry/lamp yield symmetric faces. |
| `objectBounds` | Conservative immutable-mesh sphere rejection before rotation, lighting and vertex projection. L1 radius plus quantization margin, current Q6 scale, actual camera transform and native focal/near planes. Uncertain/overflow cases remain visible. Render rejection never removes a collider. Owns the matching `support.frustum` parameters. |
| `preserveBitmapTail` | Boolean. Clears8000 bitmap bytes per bank, preserves the unused192-byte tail after startup. Does not allocate sprites or reserve their pointers. |
| `fixedBackground` | Boolean. Initializes border/background once and commits native bank/body mode with each presented view. Do not use when application/IRQ animates `$d020/$d021`. |
| `beforePresent` | Assembly symbol called under PHP/SEI immediately before native buffer commit. Foreground only, must RTS, be short/bounded, preserve renderer state and not re-enable IRQs. Use for app-owned sprite/pointer staging; it is not a generic color-RAM double buffer. |
| `dynamicLens` | Boolean. Shared focal for native Q4 projection, camera-plane clipping and installed circle/sphere API. `rs_lens_set`: A=even focal64..254, C=1 accepted/C=0 rejected. Updates focal/half/focal*4 together. Call between views only. Fixed-focal specialization is deliberately bypassed. |
| `viewRoll` | Boolean. Public signed16 Q8 phase `rs_view_bank` (256 high-byte units/turn). `rs_view_prepare` runs before each view. Independent signed Q10 products rotate camera X/Y for meshes and installed world spheres; Z is preserved. No camera coefficient/LUT is borrowed. Keep local coordinates in the documented native Q4 domain. |
| `support` | Optional independently allocated native helpers, detailed below. No feature-specific scene assets are included. |

`rs_invalidate_terms` invalidates coordinate-product state, not compiled index
lists. **Changing a coordinate index to a value outside its compiled mesh list
requires recompilation.** `rs_invalidate_matrix` discards rigid cache validity.
`rs_invalidate_light` takes X=object, C=1 valid/C=0 out of range, and forces a
fresh frozen computation after lamp/normal edits. Frozen light is frozen world
illumination, not automatically local-space illumination; use `solidLamp` for
the latter. Fully fixed-color objects skip vertex-light updates.

All rs_ routines/state are foreground-owned and nonreentrant, except the short
explicit PHP/SEI commits. IRQ code must not call them or overwrite their state.
Routines may clobber A/X/Y and arithmetic flags unless explicitly documented.
Existing low-level renderer scratch rules still apply. Object camera coordinates
use native Q4; scene positions/camera API use Q8. Do not mix scales.

Native helpers in `support`:

| Key | Configuration and native ABI |
|---|---|
| `random` | Optional nonzero16-bit `simulationSeed`/`cosmeticSeed`. `rs_sim_random` and `rs_fx_random` return A=byte; private independent LFSR states. Deterministic seed replay is supported. Seed from application entropy when randomness is desired. |
| `camera` | `shift`1..7(default3), unsigned Q8 `zoomEnter`<`zoomLeave`<=32767, `bankLimit`1..16383. `rs_camera_pose`/`rs_camera_target`: six signed16 values x,y,z,yaw,pitch,bank. `rs_camera_tick` filters positions, shortest circular angles and bounded bank; small residuals snap. `rs_camera_distance`+`rs_camera_zoom_tick` provide proximity hysteresis. `rs_camera_apply` copies position/yaw/pitch, and bank if `viewRoll` is installed. Call between views. `rs_camera_ease_lo/hi` are65 half-cosine samples0..256. Applications choose targets and cadence; no fixed route or automatic target selection. |
| `rigidPose` | `objects` must equal scene count. `rs_rigid_pose`: X=source,Y=destination, C=1 success. Atomically copies position, angles and scale; not mesh, materials, visibility or collider. Enables native X/Y/scale channels even when initial values coincide. Use before rendering compound/LOD components. |
| `lod` | `objects`=scene count,1..32 disjoint `groups` with numeric `near`,`far` object indices and unsigned Q8 `enter`<`leave`<=32767. `rs_lod_tick`: X=group,A=distance low,Y=high; C=1 valid, A=near0/1. Initializes far visible/near hidden, changes only render visibility with hysteresis. Call after synchronizing both poses; retain one independent collider owner. |
| `frustum` | `focal`1..255(default170), `nearQ4`1..32767(default128). `rs_bound_center`: signed16 Q4 x,y,z; `rs_bound_radius`:0..32767; `rs_bound_focal`:1..255. `rs_bounds_visible` C=0 only when proven outside; C=1 possibly visible/uncertain. Conservative containing-box support with one logical pixel margin, exact24-bit products. |
| `origin` | `channels`:1..32 `{low,high,extension?,count}` SoA symbol descriptors, count1..255. `rs_origin_shift`: A=Q8 signed delta low,Y=high. Subtracts the same delta from registered channels atomically; adds it to signed32 `rs_origin_world`. Register every matching-axis physics/render/shot/particle/camera channel. Alternatively `axes` with x/y/z channel configurations emits independent `rs_origin_x_shift`/`rs_origin_y_shift`/`rs_origin_z_shift` and world accumulators. Retire far bodies before local signed-range ambiguity. |
| `particles` | `slots`1..32(default16), `attempts`1..32(default8), `life`1..255(default32). `rs_particle_origin`: signed16 Q8 xyz. `rs_particles_emit` fills the pool using bounded random-volume samples in radius31, positions origin+sample*8 Q8 units, signed8 velocities=sample. `rs_particles_tick` integrates live slots and decrements life. SoA `rs_particle_life`, `{x,y,z}_{lo,hi}`, `v{x,y,z}` are private pool state exposed for drawing/rebase. Uses only cosmetic RNG; does not draw or depth-sort. Feed the existing point/circle API as appropriate. |
| `sat` | Empty record emits planar convex narrow phase. See [dynamics](DYNAMICS.en.md). |
| `contacts` | Bounded callback scheduler with snapshot/rollback. See [dynamics](DYNAMICS.en.md). |

All helpers use named state inside existing Plus allocation blocks: no hardcoded
RAM or borrowed zero page, no widened windows. Costs depend on selected modules,
objects, lists and pool sizes; final allocator/map guards are authoritative.
Selecting every module can exceed RAM, especially Mode6. Compose only needed
features; a rejected build is not a fallback to lower quality. PAL Turbo6510 is
qualified in the external ledger; hardware/NTSC and arbitrary module combinations
are not implied by individual tests.
