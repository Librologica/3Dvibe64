# Circle-rendered spheres — 1.15.1

Stable1.15.1, source-only GitHub release. [Release status](RELEASE-STATUS.en.md) · [Current qualification](QUALIFICATION-1.15.1.en.md). Input scenes/assets are external; no demo projects are bundled.

Optional stable API, independent of scene geometry and object identities.
It represents a sphere by a screen-aligned circular impostor, with native
legacy-plus camera geometry and native solid spans. No polygon sphere, sprite
limit, fixed radius, object count, palette, light or ground is assumed.

Enable `-SphereRenderer circles`. The default `none` emits no added code or RAM.
This is separate from `-LegacyPlusOptimizations all` and is never implied by it.
The first supported profile is Mode4/Mode6, `legacy-plus`, `walkLite`,
`normal`, `high-basic-v2`, `-NoFpsOverlay`. Unsupported profiles fail explicitly.
All helper code/data use the unchanged bounded allocator. Combinations can fail
for lack of RAM; no memory window or zero-page allocation is enlarged.

## Coordinate and material contracts

Call from the main drawing pass, after selecting `drawbuf`, before buffer
presentation. APIs clobber A/X/Y/flags and native projection/clipping/span
scratch. They are not reentrant and must not run concurrently from an IRQ.
Input/output state is ordinary allocated RAM; no extra resident mesh vertices
or fake control triangles are required.

Materials use the same `fillbyte`, `material_screen_cur`, `material_color_cur`
inputs as native solid spans. Both physical rows, both buffers, masks,
material-cell updates and dirty spans retain their native contracts. There is
no special treatment for white, black, transparent colors or a fixed palette.
An opaque fill pattern0 writes slot00; it does not mean transparency.
VIC-II per-cell color limits still apply. Palette policy belongs to the caller.

| Entry | Inputs | Result |
|---|---|---|
| `er_sphere_begin_view` | Current native camera angles | Prepares the native Q10 view coefficients; call once after changing angles |
| `er_sphere_world_to_camera` | `er_sphere_world_x/y/z`, signed24 Q8 | Writes `er_sphere_camera_x/y/z`, signed16 Q4; carry means success |
| `er_sphere_draw_world` | World center, world radius and material | World transform, projection and draw; requires current view coefficients |
| `er_sphere_project` | Camera center and world radius | Produces screen center/radius without drawing |
| `er_sphere_draw_camera` | Camera center, world radius and material | Projects and draws without an object/world transform |
| `er_circle_draw` | `er_circle_xq2/yq2`, signed16 Q2; `er_circle_radius_q2`, byte | Draws an already projected circle, clipped to160×100 |

World inputs use the native axis order **X, Y-up, Z-forward**. For public
world-z-up authoring coordinates `[x,forward,height]`, map these to native
`[x,height,forward]`. They are absolute signed24 Q8 values, like the native
camera. The relative position must stay within `[-1024,1024)` WU on every axis,
the original legacy-plus transform domain. Out-of-domain values, including
signed24 subtraction overflow, return failure instead of wrapping or changing
the engine's camera-fault flag.

`er_sphere_radius` is an unsigned16 Q4 **world-space** radius: raw1..16383
(1/16..1023 15/16 WU). Apply any object scale before passing the radius.
Spheres have no orientation; the API does not transform an object mesh.

Projection uses `PROJ_FOCAL * radiusQ4 *4 / cameraDepthQ4`, rounded to nearest
quarter logical pixel, ties upward. The product is24-bit; it does not overflow
when the world radius exceeds the billiard-demo radius. The complete positive
native Q4 depth is used. Centers retain the native divider's coordinate
normalization and quarter-pixel remainder rounding. `er_sphere_depth_q4`
aliases the camera-space Z input for caller-owned painter sorting.

`er_sphere_project` writes `er_circle_xq2/yq2`, radius and
`er_sphere_valid` (projection produced). `er_sphere_screen_xq2/yq2` are aliases
for those screen-center words. No framebuffer is changed by projection alone.
The public draw entries set carry only when at least one visible span was drawn.

## Bounds, tiny circles and status

Screen radius is1..252 quarter pixels (0.25..63 logical pixels). Larger
projections fail with status3 instead of silently changing scale. Centers
behind the camera or nearer than the native near plane (8 WU) are rejected as
screen-aligned planes; this is not a volumetric sphere/near-plane intersection.

`er_sphere_min_radius_q2` defaults to0. A radius rounding to0 is culled;
set this byte to4 for an explicit minimum one-pixel radius. It is a caller
appearance choice, not an automatic depth LOD table.

`er_circle_trim_tips` defaults to1: isolated cardinal rows/columns are removed
from the complete circle before viewport clipping. Set0 for the strict circle
coverage. A circle below1.5 pixels radius with empty sampled coverage uses one
nearest pixel; an offscreen center is not clamped onto the viewport edge.
No temporal dithering or alternating scanlines are introduced.

`er_sphere_status`:0 success,1 near/behind,2 invalid world radius,
3 projected radius too large,4 below resolution/zero screen radius,
5 outside viewport/no visible coverage,6 world-coordinate domain failure.
Inspect carry on the called entry; a valid projected center can still have no
visible raster coverage. Input storage is caller-owned and must remain valid
through each synchronous call.

## Integration and visual meaning

The API does not add an automatic draw layer. The caller supplies painter
order relative to other circles and polygons. Sorting a circle by its center
depth has the same screen-aligned-plane approximation as a billboard, not a
sphere z-buffer or geometric sphere/mesh intersection. Emit farther primitives
first, then nearer ones, or integrate them into the application's ordering.

The circular silhouette preserves the cheap sphere-impostor technique. A true
perspective sphere becomes an offset ellipse off-axis; that distinction is not
hidden. Lighting, highlight placement, shadows, material animation, collision
and motion remain application choices. The engine contains none of the pool
demo's positions, colors, pockets, lamp, white spot or contact-shadow rules.

## Build and minimal ASM call

Commands are relative to the SDK root. Copy the complete SDK to a new working
directory; ordinary legacy-plus writes into that copy, not `-OutputDirectory`.
The external scene must declare a compatible camera/mode. Enabling the selector
emits callable APIs only: it does not add a sphere scene JSON schema or insert
objects into the render pass. Use application ASM or the external example tool.

```powershell
Copy-Item -LiteralPath . -Destination ../sphere-build-sdk -Recurse
pwsh -NoProfile -File ../sphere-build-sdk/work/build-3Dvibe64.ps1 -SceneFile ../my-inputs/scene.json -Precision legacy-plus -GraphicsMode 4 -CameraMode walkLite -CameraViewport normal -MemoryLayout high-basic-v2 -Quality fast -Projection extended-table -VideoStandard pal -DynamicLight -NoFpsOverlay -SphereRenderer circles
```

Use `-GraphicsMode 6` with a compatible Mode 6 scene for that backend.
This camera-space example draws a radius-4 WU sphere at depth 100 WU.
It assumes an initialized frame and a palette shared with the other primitives;
the material numbers below are example choices, not reserved engine slots.
`er_sphere_begin_view` is needed only for the world-space transform path.

```asm
; In the main draw pass, after selecting drawbuf, before presentation.
; Example palette: global background 0, shared slots 01=1, 10=3, 11=6.
 lda #$55
 sta fillbyte
 lda #$13
 sta material_screen_cur
 lda #6
 sta material_color_cur
 lda #0
 sta er_sphere_camera_x
 sta er_sphere_camera_x+1
 sta er_sphere_camera_y
 sta er_sphere_camera_y+1
 lda #<(100*16)
 sta er_sphere_camera_z
 lda #>(100*16)
 sta er_sphere_camera_z+1
 lda #<(4*16)
 sta er_sphere_radius
 lda #>(4*16)
 sta er_sphere_radius+1
 jsr er_sphere_draw_camera
; C=1: visible spans drawn. C=0: inspect er_sphere_status.
```
For world-space calls, set `er_sphere_world_x/y/z` in native signed24 Q8,
call `er_sphere_begin_view` after updating camera angles, and use
`er_sphere_draw_world`. World/camera draw calls repeat projection and raster
for each requested view; the engine does not cache lighting or geometry.

## External example and verification

```powershell
$env:TASS64_EXE='C:/path/to/64tass.exe'
python -B scripts/sphere_api_example.py --out C:/projects/circle-spheres --mode 4
```

The source tool creates/builds an external project with a cube, caller-defined
layers and floating orbs of different world radii. `--mode 6` uses a compact
two-object caller to fit its tighter RAM budget. Its common four-color palette
and its motion are example policy, not engine assumptions. Each project has
`launch-demo.cmd`, `launch.ps1`, a PRG and a one-byte-disabled control PRG.
No precompiled example or media is distributed inside this source SDK.

`scripts/test_sphere_impostors.py --build <assembled-work> --out <report>`
checks the emitted6502 against independent circle coverage, framebuffer masks,
perspective division and signed Q10 transform arithmetic. Provide
`3Dvibe64.prg` and numeric VICE labels `3Dvibe64.labels` in that work directory.
Native VICE timing and images are separate from CPU correctness tests.

[Documentation index](DOCS.md) · [Quick start](QUICKSTART.md) · [Test commands and evidence](TESTING.md).
