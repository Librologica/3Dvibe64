# AnimatedMesh v1 — 1.20.0

> Stable source SDK 1.20.0. Published on GitHub. [Qualification](QUALIFICATION-1.20.0.en.md).

[Italiano](ANIMATED-MESH.it.md) ·
[Release notes](RELEASE-NOTES-1.20.0.en.md) · [Testing](TESTING.en.md).

## Supported profile

`AnimatedMesh` is an indexed solid mesh with vertex-pose clips, not a skeleton.
The ordinary builder accepts `animatedMeshes` in a caller-owned Scene1 file.
Select `-Precision legacy-plus -GraphicsMode 4`, `5` or `6`, `-CameraMode walkLite
-CameraViewport normal -MemoryLayout high-basic-v2 -NoFpsOverlay`. Modes4/5 use
the existing flat/outlined renderer; Mode6 uses the existing Gouraud renderer.
The normal viewport is160×100 logical /320×200 bitmap pixels. Other precision
backends, Mode1/2/3/7/8, small viewports, explicit object-model contracts and
declarative timelines are rejected. The private zombie application's textured
floor/UI and fullscreen switching are not part of this v1 API.

Ordinary Mode4/5 shading still requires an eligible scene light or `-DynamicLight`;
animation does not bypass the existing shade-profile checks.

Existing scenes without `animatedMeshes` keep the original generation path.
Geometry, clips and music are supplied externally; no application assets are
bundled in the source SDK. Build into a disposable SDK copy as usual.

## Scene contract

The root retains ordinary `schema:1`, `axisConvention:"engine-y-up"`, camera,
world, meshes and objects. Coordinates use engine Y-up. Each `animatedMeshes`
entry contains these fields; unknown fields are errors.

Optional root `animatedMeshRenderer` is `generic` by default. Explicit
`compact-gouraud` is a pure Mode6 profile with no world grounds or wire meshes.
It retains ordinary Gouraud/clipping but omits the four unreachable generic
solid/pattern fill bodies, keeping instrumented entry traps. Application includes
that reference those removed labels are rejected. It does not enable mode
switching or private calls to non-Gouraud helpers. Other modes and ordinary
scenes keep all their fillers. This profile frees code space for larger animated
assets without expanding memory windows or aliasing buffers. `am_cold_calls`
must remain0; a nonzero value traps and invalidates qualification. Native capture
comparison must verify the profile before relying on its memory saving.
The four filler bodies must match exact qualified source hashes; modified or
unknown templates are rejected with an instruction to select `generic`.

| Field | Contract |
|---|---|
| `id` | Unique among static and animated mesh IDs; ASCII letter followed by up to47 letters, digits, `_` or `-`. |
| `faces` | 1..255 triangles/quads, ordered as ordinary engine faces; distinct vertex indices in each face. Topology and vertex order stay constant. |
| `clips` | 1..16 clips per asset; total1..255 clips. Each has unique local `id` and `frames`. |
| `frames` | 2/4/8/16/32/64 poses, each containing the same3..85 `[x,y,z]` vertices; signed integer coordinates−63..63. |
| `material`, `reflectivity` | Optional ordinary source material properties. Instance properties retain their normal engine precedence. |
| `lighting` | `reference` (default) or `frozen`; `frozen` requires Mode6. |
| `creaseAngle` | Integer0..180 degrees, default180 for animated assets. Selects ordinary reference-pose normal sharing; lower angles split hard edges and cost additional shade vertices/RAM. |

There are1..32 animated assets and1..255 animated instances. Ordinary engine
limits still apply: source/runtime vertices, faces, shade vertices, memory and
scene objects must fit their existing byte-indexed buffers. These are format
bounds, not a promise that the largest combination fits64KB. No allocator window
is enlarged. A failed placement stops compilation; it does not drop geometry.

An object references the asset through ordinary `mesh`. Its optional `animation`
contains `clip` (first clip by default), `phase` (default0), `step` (default8) and
`interpolation` (`linear` by default, or `step`). `phase` is an integer in
0..(poseCount×16−1); `step` is0..255 sixteenths of a pose per50Hz logical tick.
`step:0` pauses the clip. `step:8` traverses25 poses/s. `step` interpolation selects
the current pose; it uses the same phase clock and does not blend endpoints.
Booleans are not accepted in integer fields. Unknown clips/fields are errors.

The two manuals contain the same minimal complete source scene:

```json
{
  "schema": 1,
  "axisConvention": "engine-y-up",
  "world": {"backgroundColor": 0, "grounds": []},
  "camera": {"mode": "walkLite", "position": [0,0,0], "rotation": [0,0,0]},
  "animatedMeshes": [{
    "id": "body",
    "faces": [[0,2,1],[0,1,3],[1,2,3],[2,0,3]],
    "lighting": "frozen",
    "clips": [{"id": "bend", "frames": [
      [[-5,-5,0],[5,-5,0],[0,5,0],[0,0,7]],
      [[-5,-5,0],[5,-5,0],[2,5,0],[1,0,7]]
    ]}]
  }],
  "objects": [
    {"id":"left","mesh":"body","position":[-10,0,65],"material":"gray","animation":{"phase":0,"step":4}},
    {"id":"right","mesh":"body","position":[10,0,70],"material":"gray","animation":{"phase":16,"step":7}}
  ]
}
```

Build with PowerShell7 and64tass available, supplying your external scene path:

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -SceneFile C:/project/scene.json -Precision legacy-plus -GraphicsMode 6 -CameraMode walkLite -CameraViewport normal -MemoryLayout high-basic-v2 -Quality fast -Projection extended-table -VideoStandard pal -FramePresentation safe -NoFpsOverlay -SkipCmdUpdate
```

`work/build/animated-mesh/scene.json` and `plan.json` are generated intermediates;
the caller's scene is not rewritten. `3Dvibe64.animated-mesh.json` reports exact
pose payload, descriptor sizes and compression counts. The normal allocator
report records placement. Existing relative mesh/include files are resolved
against the original scene directory. Build products stay outside the source ZIP.

## Native animation and movement

Clips use column minima and shared packed0/1/2/4/8-bit delta streams, deduplicated
across clips/assets. Topology and source coordinates are shared when multiple
objects reference a source, through existing `meshSourceSharing`; transformed
vertices, face sorting and Gouraud shade values remain per instance. Descriptor
cost is12 bytes per source vertex per clip, plus packed payload, runtime code,
per-instance state and the engine's projection/shading buffers. Contribution
tables cover the full integer animation domain, including intermediate values;
they can cost more RAM than the static first pose. Compressed poses alone do not
describe the total memory cost.

The decoder runs before transformation. Exact interpolation is
`a + sign(b-a) * floor(abs(b-a)*fraction/16)`, with fraction0..15; the last pose
blends into the first. Constant columns bypass unpacking/multiplication. A cache
per source mesh keys its actual current clip/phase; switching between instances
with different phases cannot reuse the wrong instance's pose. Stepped clips
reuse the decoded pose until its pose index changes. No private zero-page range
or renderer scratch alias is introduced.

Animation advances with the engine's50Hz logical simulation clock (also under
NTSC conversion), independently of render FPS and camera movement. `animation`
changes local vertices only. Set ordinary object `velocity`, `position`, rotation
and scale for real world movement. There is no implicit root motion, foot locking,
floor movement, texture scrolling, teleportation or floating-origin reset. The
application must match clip cadence, stride and world velocity itself.

## Gouraud and lighting

Both policies use normals/centres built from the first pose of the asset's first
declared clip. Selecting another clip does not rebuild them. `reference` retains
the ordinary per-frame engine lighting calculation using that reference geometry;
normals are not recomputed from deformed vertices. `frozen` computes each visible
instance's shade values on its first shaded view, then reuses them. Gouraud still
interpolates vertex shade values across the rendered/clipped triangles. This is
cached reference lighting, not physically updated deforming-mesh illumination.
Rotation, movement and moving lights do not update frozen values until explicitly
invalidated. First-visible lighting is not necessarily the application's first
video frame. Normal seams and painter-order limitations remain those of Mode6.

## Native API

Call from foreground code with the engine's normal RAM mapping. Decoder code
self-modifies its operands; it is not reentrant and must not run in an IRQ.
No new interrupt is installed. Registers and flags are volatile except the
documented carry result. Existing application `graphicEffect` hooks still work.

| Entry/state | Contract |
|---|---|
| `am_set_clip` | X=scene object index, A=global clip index in asset/clip declaration order. C=0 resets valid animation phase to0; C=1 rejects out-of-range/static-object/wrong-asset requests without changing state. Does not invalidate frozen light. |
| `am_invalidate_light` | X=scene object index. C=0 clears its light-valid flag; C=1 for an out-of-range index. The next shaded view refreshes reference lighting. |
| `am_reset_all` | Restores declared initial clips/phases and clears all pose/light caches. Does not reset ordinary object positions, camera or application state. |
| `am_step`, `am_linear` | Indexed by scene object. Writable step0..255; `am_linear` must be0 (`step`) or1 (`linear`). |
| `am_clip`, `am_phase_lo`, `am_phase_hi`, `am_light_valid` | Per-object internal state, available for paused diagnostics. Use the API to change clips and reset/invalidate state. |

The builder initializes animation automatically and calls `am_tick` once per
simulation tick. Applications must not call it a second time. Animation-only
reset is explicit; declarative timeline reset is rejected rather than partially
resetting animation. See [verification](TESTING.en.md) for native decoder checks
and the separate real-machine-cycle FPS protocol.
