# 3Dvibe64 1.1.1

This public 1.1.1 package is a source SDK: it contains the frozen builder,
documentation, JSON reference scenes, and contracts, but no precompiled PRG or
diagnostic artifact. Build examples locally, preferably in a disposable working copy.
The examples are executable API documentation, not bundled productions.

The spatial, angular, and temporal contract is documented in [WORLD-METRICS.md](WORLD-METRICS.md).

The generator architecture, emitted 6510/6502 source, memory layout, and professional
modification/debugging workflow are documented in
[ASSEMBLY-GUIDE.en.md](ASSEMBLY-GUIDE.en.md).

The practical Codex-assisted workflow—environment preparation, scene creation,
building, VICE testing, and preservation of approved versions—is documented in
[VIBE-CODING-GUIDE.en.md](VIBE-CODING-GUIDE.en.md).

## Stable culling and shared Mode 4/5 instances

`-FaceCullProfile default|stable` is available for GraphicsMode 4 and 5. `default`
preserves the validated screen-space culling path byte-for-byte. `stable` uses screen
space outside signed band `[-64,+64]` and camera-space facing for nearly edge-on
faces, reusing the normals and matrix already available. Exactly edge-on faces are
kept without hysteresis or cross-frame state, and rendering remains one-sided. The
`sh_nx`, `sh_ny`, and `sh_nz` light cache is saved on the stack and restored after
either culling outcome, with zero persistent scratch and unchanged dynamic shading.
Mode 3 is excluded.

With `"meshSourceSharing": true`, reused source geometry is emitted once. Mesh and instance descriptors remain separate, and each instance keeps its own transformed and projected buffers. Bucket entries identify instance plus local face, and every visible instance participates in one global painter order. The shared path is available only in Mode 4/5. Opting in from Mode 1, 2, or 3 stops the build with `meshSourceSharing is supported only in GraphicsMode 4 and 5`; opting in without a source mesh referenced by multiple instances also stops the build. There is no silent expansion fallback. Scenes without the opt-in retain the byte-identical direct path.

`materialOverride`, `reflectivityOverride`, and `colorOverride` apply without rewriting shared source tables. Precedence is local face override, instance override, then source material. In the shared path, `faceOverrides` belongs to the source mesh and its keys are source-local face indices; per-instance `faceOverrides` is rejected. An explicit non-shaded pigment uses a sparse source map such as `"faceOverrides": { "0": { "solidColor": 7, "shading": false } }`. Mode 4 fills it in normal painter order; Mode 5 also outlines the final post-clipping polygon and leaves no residual outline for rejected faces.

A real static light uses `"type": "static"` and `"position": [x,y,z]`: it emits one sample and no orbit phase, tick divisor, or duplicated table, while shading still reacts to object rotation. The legacy `"mode": "static"` value does not select this current compile-time path and can retain phase, tick, and table infrastructure. The declarative timeline requires `tickRate: 50`; `resetKey: "SPACE"` restores state, poses, visibility, and counters. PAL and NTSC both produce 50 logical ticks per second. Generic sinusoidal easing is intentionally outside 1.0.

## Near profiles for Mode 3, 4, and 5

The public API documents compile-time `-Mode4NearProfile default|late|clip` for GraphicsMode 3, 4, and 5; the option name is retained for compatibility. `default` preserves rejection below 8 WU and the 8-WU minimum projection divisor, with validated-baseline byte-identical behavior. `late` rejects depth `<= 0`, accepts 1 WU with a minimum divisor of 2 WU, and uses geometric depth from 2 WU onward. This creates a short divisor-2 projection plateau from 1 to 2 WU.

The `late` profile does not enable near-plane polygon clipping, change backface culling, or add two-sided rendering: faces crossing the camera plane are rejected whole. `clip` instead performs Sutherland-Hodgman clipping against the camera plane after optional Ground clipping. It preserves the portion in front of the camera through 0 WU, creates projectable intersections at depth 1 WU with divisor minimum 2, and rejects a face only after a real crossing. Camera-space culling uses the original polygon; rasterization and the Mode 5 outline use the final polygon. The legacy near-poly path stays disabled and one-sided behavior is unchanged. `default` and `late` remain byte-identical; the `clip` fix adds zero scratch.

`clip` is available with `fixed`, `walkLite`, and `walkFull`. `-ExplorerClipMode` and `-ExplorerNearCrossMode` are legacy diagnostic controls; do not combine their legacy near-crossing path with `-Mode4NearProfile late|clip`, which requires `ExplorerClipMode=none` and rejects a non-default legacy crossing mode.

## Compact JSON reference

The exact timeline structure is:

```json
{
  "timeline": {
    "tickRate": 50,
    "resetKey": "SPACE",
    "initialState": "state-id",
    "states": [{
      "id": "state-id",
      "duration": 50,
      "next": "next-state-id",
      "loop": false,
      "instances": {
        "object-id": {
          "visible": true,
          "position": [0, 100, 8],
          "rotation": [0, 0, 0],
          "scale": 1,
          "positionVelocity": [0, 0, 0],
          "rotationVelocity": [0, 0, 0],
          "materialOverride": "blue",
          "reflectivityOverride": "mirror",
          "colorOverride": 6
        }
      }
    }]
  }
}
```

`tickRate` must be 50. A timeline has 1-255 states, the state count multiplied by the scene-object count must not exceed 255, and `duration` is 1-65535 ticks. The field is exactly `visible`, not `visibility`; the latter produces a builder warning and is ignored. `position` is in WU under the scene axis convention; `rotation` is in TU, `positionVelocity` in WU/ST, and `rotationVelocity` in TU/ST. State transitions are deterministic and do not provide generic sinusoidal easing in pre-1.0.

An instance selects its source with `mesh` and can use `materialOverride`, `reflectivityOverride`, and `colorOverride`. Material accepts a family name (`gray`, `white`, `red`, `green`, `blue`, `yellow`, `cyan`, `magenta`, `orange`, `brown`) or index 0-9. Reflectivity accepts `satin`, `gloss`, `reflective`, `mirror` or index 0-3. `colorOverride` and `solidColor` are VIC-II palette indices 0-15. `active`, `global`, `variable`, or `default` retain the active material/reflectivity. Effective precedence is local source-face override, instance override, then source-mesh material.

With sharing enabled, `faceOverrides` must be stored on the source entry in `meshes`, never on an object instance. Keys are local face indices. `solidColor` with `shading:false` bypasses dynamic shading for that face. A per-instance map on a reused source fails with `per-instance object faceOverrides are not supported by the shared-source path`.

Sharing is explicit and limited to Mode 4/5. Source geometry is emitted once, but each instance requires separate transformed/projected runtime buffers. Byte-sized indices cap source vertices, source faces, runtime vertices, runtime faces, mesh descriptors, and scene objects/instances at 255 each. Available memory normally imposes lower practical limits; complex scenes can require explicit `-MemoryLayout high-basic-v2`.

This public release restricts `H` (Temporal Scanline Mode) to GraphicsMode 4 and 5. Modes 1-3 compile none of its handler, state, temporal copy, or feature-only raster gates.

## Ground `simple` and `plane`

pre-1.0 promotes two compile-time Ground profiles. `ground.z` is expressed in WU under the public `world-z-up` convention, so the geometric plane is `world Z = ground.z`. Camera height changes the geometrically visible side only when the camera crosses that plane. The `plane` profile costs more cycles than `simple`; scenes that no longer fit `stable` must explicitly select `high-basic-v2`.

- Mode 1: a decorative roll-aware horizon line, with neither occlusion nor fill.
- Mode 2 `simple`: the same decorative line and no geometric clipping; every mesh is retained. The line is drawn before faces, so hidden-wire face masks cover it behind surfaces.
- Mode 2 `plane`: a background horizon line, plane-side classification, rejection of faces opposite the camera, and clipping of crossing faces. Hidden-wire and edges consume the post-clipping polygon. No half-plane is ever filled. This profile adds `VERT_COUNT` bytes of `ground_vside`, uses polygon buffers through 12 vertices, and can require `high-basic-v2`.
- Modes 3-5 `simple`: the traditional screen-space Ground.
- Modes 3-5 `plane`: a filled roll-aware half-plane plus geometric classification and clipping, for cameras above or below the plane. Mode 3 fixed uses the corrected Ground relocation under `high-basic-v2`.

Under the pre-1.0 convention, roll `+32 TU` makes the horizon slope down to the right, `-32 TU` makes it slope up to the right, and `+64 TU` makes it vertical. A line wholly outside the viewport is not drawn and leaves no residue on its borders.

## Two-color wire multimaterial

The public API includes a compile-time profile to GraphicsMode 1 and 2, enabled by `materialProfile: multimaterial`. A scene must use exactly two different color families and explicitly map every face; a third family or an incomplete map stops the build without falling back to the global object material. The first family in source order uses bitmap slot `01` and pattern `$55`; the second uses slot `10` and `$AA`. Both pigments share one `screenByte`; fixed Color RAM never distinguishes them. For the two-color multimaterial wire reference the mapping is VIC-II red 2 / white 1, hence `screenByte=$21` and fixed Color RAM `$01`.

Mode 1 keeps unique edges: `wire_edge_slot` assigns each edge to its first adjacent source face, a rotation-independent rule for cross-material shared edges. Mode 2 uses `wire_face_slot` before drawing each face border and preserves hidden-wire mask fill, clipping, culling, painter order, and depth buckets. Within one bucket, the existing chain draws descending face indices, so the lower source face deterministically wins. No runtime edge or owner buffers are added. The regression scene is [examples/wire-two-color-multimaterial.json](examples/wire-two-color-multimaterial.json), with its original 84 faces (42 red and 42 white).

The two-pigment limit is independent of whether faces are triangles or quadrilaterals: mesh topology does not determine the available pigments. In each VIC-II multicolor bitmap cell, `00` selects global background `$D021`, `01` the high Screen RAM nibble, `10` the low Screen RAM nibble, and `11` Color RAM. pre-1.0 assigns its two wire pigments to `01` and `10` while keeping `11` stable, allowing edges from different faces and objects to cross the same cell without requesting another per-cell palette. A third pigment is technically possible through `11`, but competing writers would require explicit conflict arbitration, per-cell ownership, a prepass, or additional runtime state. Two pigments are therefore pre-1.0's safe, compact, deterministic general profile, not an absolute VIC-II limit.

## Graphics profiles

**Mode 5: solid dynamic outlined.**

Graphics modes 1 and 2 provide the wire and hidden-wire paths. Mode 3 uses filled faces with static shading. GraphicsMode 4 provides filled faces with dynamic lighting and automatically enables the validated XY-Q2 profile; experimental subpixel flags are not required.

GraphicsMode 5 inherits the complete Mode 4 pipeline and adds a one-lowres-pixel polygon outline after each face fill. The outline follows the final post-clipping polygon, including generated near-plane and screen edges, and uses `world.backgroundColor`. It is applied face-by-face in the existing far-to-near painter order, so a nearer fill naturally covers outlines belonging to farther geometry.

The outline has a measurable cost. The pre-1.0 performance audit did not promote risky changes or changes with insufficient impact: Mode 5 preserves Mode 4 dynamic rendering, shading, and materials and adds only the post-fill outline to the post-clipping polygon.

Dense stable-layout builds remain subject to the existing `$5C00` video-buffer boundary. The reference Mode 5 scene fits with the FPS overlay enabled; the full near-plane stress scene uses the existing `high-basic-v2` layout.

Mode 4 uses X LegacyDirect and the XY-Q2 builder, integral and fractional Y traces, the 11×8 divisor, fast pixel conversion, inline bounds, Mode4ShadeStepLimit and signed saturated light-vector addition. With the default DEV7 text split, `normal` renders a 160×88 body at low-resolution Y=12 and `small` renders 128×80 at Y=12. `-NoFpsOverlay` removes the split and restores the legacy 160×100 normal body; small remains 128×80 and is centered.

### Generic Text and FPS header

The same-bank DEV7 split reserves three character rows (`TEXT_HEADER_SCREEN_BYTES=120`) above the 3D body. `-HeaderText "..."` writes up to 40 characters to the middle row of both Screen A and Screen B. The compact charset supports space, digits, dot, and `S C R I T A D E M P O`; unsupported characters are rendered as spaces. The DEV7.1 `$FF` terminator allows spaces inside the string and fixes the compact alphabet mapping.

The FPS counter uses cells 0–3 of that middle row and takes precedence there. `F` toggles the complete header, including Generic Text; `-FpsOverlayOnStart` starts it visible. `-FpsCounterOnly` retains the sampler without the visual split, while `-NoFpsOverlay` removes both split and FPS key. Both video banks keep their own Screen RAM and charset, and material changes preserve the reserved 120-byte header. Adding Generic Text emits the complete 184-byte compact font and can make a dense `stable` build require `high-basic-v2`.

Known limitation: on stock timing, an isolated physical pixel can remain at the far-right edge on the header/body raster transition. The 1.1.1 regression observed one stable pixel with no scene corruption, crash, propagation, or A/B mismatch. The validated `$4A`/`$4B` timing is intentionally retained; use `-NoFpsOverlay` when a completely split-free frame is required.

### Experimental Temporal Scanline Mode (`H`)

Available only in GraphicsMode 4 and 5, it advances once per key press through `0 -> 1 -> 2 -> 0`: state 0 updates all 100 rows, state 1 updates 50 rows with alternating parity, and state 2 updates 25 rows using the existing modulo-4 class. Excluded rows temporarily retain their previous contents, creating an interlaced effect and a moderate motion trail; returning to 0 uses the renderer's existing full restore.

This is a visual effect, not a performance mode or simple low resolution. Transform, projection, clipping, culling, depth ordering, shading, and face preparation continue to run in full, so the effect can increase frame cost. Materials, fill, painter order, and the Mode 5 outline remain unchanged.

## Camera profiles

The `fixed` camera is the specialized lightweight path. It consumes less code, memory, and cycles, is more often compatible with `MemoryLayout stable`, and uses the more quantized Q6 table projection. Its geometric quality is lower than the walk cameras in complex or very close scenes. Under `Mode4NearProfile=default|late`, a complete face can be rejected at the corresponding near/camera gate; explicitly selecting `-Mode4NearProfile clip` enables camera-plane polygon clipping for `fixed` as well as the walk cameras.

`walkLite` is a mobile camera with yaw and pitch. It uses the Mobile Y-Q2 transform and more precise geometry. Select `-Mode4NearProfile clip` for camera-plane polygon clipping.

`walkFull` adds roll to the same precise pipeline used by `walkLite`. It requires more code and runtime data and can require `MemoryLayout high-basic-v2` with complex meshes such as complex reference mesh.

Walk cameras start at the pose stored in the scene and stay still until the user supplies a camera command. Object rotation and light animation continue while the camera is idle. All three profiles share culling, 16-bit depth buckets, far-to-near painter order, the XY-Q2 face builder, fill, surface patterns, and shading.

The pre-1.0 development defaults for `walkLite` and `walkFull` apply one linear substep of `127/256 = 0.49609375 WU/ST`, nominally `24.8046875 WU/s` or approximately `0.44294` standard-cube sides per second. Diagonal movement remains additive and unnormalized. Yaw and pitch respond immediately with 1 TU and then repeat every 4 ST (continuous `0.25 TU/ST`, `17.578125°/s`); roll responds immediately and repeats every 2 ST (continuous `0.5 TU/ST`, `35.15625°/s`). Release and camera reset independently clear all three phases. The `fixed` camera and object animations remain unchanged.

pre-1.0 depth is geometric: `camera_depth_geometric` remains the real distance, `projection_table_index = max(1, camera_depth_geometric + 190)` is only the physical address, and `projection_divisor = max(8, camera_depth_geometric)` determines scale. Reference scenes were migrated along their actual world-Y forward axis; there is no runtime fallback for the former geometric bias.

Clipped geometry retains the compatible legacy fallback. The `normal` and `small` profiles share black outer-area and VIC-II border initialization.

## Memory layouts

`MemoryLayout stable` is the preferred compact layout for light and medium configurations. The builder stops when code or runtime invades bitmap, screen, or other video regions and explicitly suggests `-MemoryLayout high-basic-v2`; it never switches layout automatically.

`MemoryLayout high-basic-v2` is the segmented layout for heavy builds. It also uses RAM beneath the BASIC ROM and is suitable for complex reference mesh, `walkFull`, and complex solid pipelines. It must be selected explicitly and can produce physically larger PRG files because gaps between segments are retained.

## Materials

Satin and gloss retain the historical shading path. In scenes whose faces are entirely reflective or mirror, the raw material selector feeds Mode4ShadeStepLimit directly. Mixed-profile scenes retain the historical behavior. Reflective materials can reach the maximum defined by their material table; mirror reaches white for every family whose table defines the white maximum.

The VIC-II legally accepts every color index from 0-15, including black, and duplicate Dark, High, and Highlight values. 3Dvibe64 deliberately excludes black from face ramps as the engine lighting model's minimum ambient-illumination floor: this is engine policy, not a hardware limit. D/H/L ramps reach runtime unchanged; the required packing is `screenByte = (Dark << 4) | High` and `colorRam = Highlight`. `VicColorPolicy` handles palette conflicts within the same bitmap cell and does not normally filter or remap material ramps. Orange satin remains `9,8,10` with `$98/$0A`; Brown satin remains `2,9,8` with `$29/$08`.

## Camera and runtime controls

- `W` / `S`: forward / backward
- `A` / `D`: strafe left / right
- `Q` / `E`: move down / up
- cursor keys: yaw and pitch
- `N` / `M`: roll
- `R`: with `-ControlRotation`, pause/resume mesh rotation; interactive-reflectivity builds should reserve it for `-ControlReflectivity`
- `L`: light control where supported by the scene
- `F`: complete Generic Text/FPS header
- `H`: Temporal Scanline Mode, GraphicsMode 4 and 5 only

If `-ControlRotation` and `-ControlReflectivity` are forced together, both handlers read `R`: rotation runs first and reflectivity immediately afterward. This is not a single-owner configuration; omit `-ControlRotation` when `R` must cycle reflectivity.

## Main public command-line options

| Option | Values | Default / effect |
|---|---|---|
| `-GraphicsMode` | `1`-`5` | `4` |
| `-CameraMode` | `fixed`, `walkLite`, `walkFull` | scene camera mode, otherwise `fixed`; an explicit CLI value wins |
| `-VideoStandard` | `auto`, `pal`, `ntsc` | `auto`; forced PAL/NTSC keeps logical simulation at 50 ST/s |
| ViewportProfile / `-CameraViewport` | `normal`, `small` | `normal`; `contract.viewportProfile` is used when CLI is omitted |
| `-MemoryLayout` | `stable`, `high-basic-v2` | `stable`; never changes automatically |
| `-Mode4NearProfile` | `default`, `late`, `clip` | `default`; valid for Mode 3-5 |
| `-FaceCullProfile` | `default`, `stable` | `default`; `stable` only for Mode 4/5 |
| `-ControlRotation` | switch | off; assigns `R` to pause/resume rotation |
| `-ControlLight` | switch | off; enables the scene-supported light key |
| `-ControlReflectivity` | switch | off; assigns `R` to reflectivity when `ControlRotation` is not enabled |
| `-FpsOverlay` | switch | overlay system is included by default and toggled with `F`; explicit compatibility selector |
| `-FpsOverlayOnStart` | switch | off; starts the included overlay visible |
| `-HeaderText` | string | empty; up to 40 compact-charset characters in the middle header row |
| `-FpsCounterOnly` | switch | off; keeps FPS sampling without the visual split or `F` key |
| `-NoFpsOverlay` | switch | off; removes overlay and FPS key, and conflicts with the two overlay switches |
| `-NoCameraRuntimeControls` | switch | off; compiles a mobile camera without runtime camera input |
| `-StaticPose` | switch | off; prevents automatic mesh-angle updates |
| `-LightOrbit` | `flat`, `tumble3d` | `flat` for the legacy orbit path |
| `-LightPhaseCount` | `8`, `16`, `32` | `32` |
| `-LightTickDiv` | integer | `2`; legacy orbit update divider |
| `-LightStaticPhase` | `-1` or phase index | `-1`; freezes the selected legacy light sample when non-negative |

`-ExplorerClipMode` and `-ExplorerNearCrossMode` are legacy diagnostic options, not
the public 1.0 near-profile API. `Experimental*`, `Diagnostic*`, `*Trace`, and
internal probe switches are not part of the stable public API.

## Licensing

Copyright © 2026 **librologica.digital**, author and licensor of 3Dvibe64.

The software, builder, scripts, JSON examples, validation assets, and generated
engine code are available exclusively for noncommercial purposes under the
[PolyForm Noncommercial License 1.0.0](LICENSE). Commercial use requires a
separate written license from librologica.digital.

All Markdown documentation, manuals, and programmer guides are available
exclusively for noncommercial purposes under
[Creative Commons Attribution-NonCommercial 4.0 International](LICENSE-DOCUMENTATION.md).
Attribution to `librologica.digital` is required. These restrictions make the
project source-available rather than OSI-approved open source. A public GitHub
repository still permits viewing and forking through GitHub's own functionality.

64tass and VICE are external dependencies, are not included in the distribution,
and remain subject to their respective authors' licenses.

## Build requirements

Use Windows PowerShell and 64tass 1.60 or newer. Put `64tass.exe` on `PATH`, set `TASS64_EXE`/`TASS64_PATH`, or place it below `work/tools/64tass`. Build commands are listed in [examples/README.md](examples/README.md). The full release contract also requires VICE x64sc; put it on `PATH` or set `VICE_X64SC`/`VICE_EXE` before running `python scripts/test_release_contract.py`.
