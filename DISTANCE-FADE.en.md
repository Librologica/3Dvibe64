# Distance fade — 1.20.0

> Stable source SDK 1.20.0, promoted from agentic36. Published on GitHub. [Qualification](QUALIFICATION-1.20.0.en.md).

Optional screen-door visibility for GraphicsMode 1–8. Disabled by default. No demo or scene assets are distributed.

## Public configuration

| PowerShell option | Scene JSON member | Default | Contract |
|---|---|---|---|
| `-DistanceFade off/dither` | `distanceFade.mode` | `off` | Explicit opt-in; independent of texture LOD |
| `-DistanceFadeStart N` | `distanceFade.start` | `64` | Integer distance where full coverage ends |
| `-DistanceFadeEnd N` | `distanceFade.end` | `96` | Integer distance with zero coverage and exclusion |

Require `0 <= start < end <= 32767`. Booleans, fractional JSON distances, unknown members, null objects and unsupported modes are rejected. Omitted members use defaults. Distances without an enabled mode are rejected. Explicit CLI members override their scene members. Explicit `-DistanceFade off` disables a scene's enabled fade and ignores its stored thresholds; do not also pass CLI thresholds with `off`.

The following fragment belongs at the **top level**, beside `objects` in a polygon scene or beside `scene` and `navigation` in a Mode8 document:

```json
"distanceFade": {"mode": "dither", "start": 64, "end": 96}
```

Using an external polygon scene:

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -SceneFile ../inputs/world.json -GraphicsMode 4 -Precision q8 -VideoStandard pal -OutputDirectory ../outputs/world-fade -DistanceFade dither -DistanceFadeStart 64 -DistanceFadeEnd 96
```

For ordinary legacy/legacy-plus, first copy the complete SDK to an external working directory, as described in [External inputs](EXTERNAL-INPUTS.en.md). Those exporters still write to that working copy's `work/`; `OutputDirectory` remains a Q8/Normalized16/Mode8 option. All existing precision, camera, mesh and RAM restrictions still apply.

Direct Python Q8 and Normalized16 builders accept `--distance-fade off/dither`, `--fade-start N`, `--fade-end N`. The Mode8 builder accepts the same three options. Scene values and CLI precedence are identical. Validation-only Mode8 resolves/validates the fade before creating outputs. These are **build-time settings**, not keyboard controls or a runtime threshold setter. Changing generated constants alone does not regenerate the threshold tables.

## Modes 1–7: object distance and coverage

Distance is the Euclidean length of the camera-relative **object origin**, in engine world units. Each absolute coordinate difference is quantized down to whole WU before squaring; fractional Q8 translation is subtracted before this quantization. Components are sign-extended before subtraction, so opposite signed endpoints do not wrap. Rotation and object scale do not move the origin. The fade belongs to the whole object, including its faces, wire edges and outlines. Split very large geometry into smaller objects when an origin-based cutoff is unsuitable. It is not a per-polygon nearest-point metric or a visibility/occlusion proof.

There are 17 coverage states, 16 through 0. Host-generated squared thresholds avoid a runtime square root. For level k, the integer distance boundary is `ceil(end - (end-start)*k/16)`; classification picks the first descending boundary not greater than the quantized distance. This retains full coverage through the start threshold and zero coverage at or beyond the end threshold. Narrow intervals can have repeated boundaries and fewer distinct observable states.

A zero-coverage object is rejected before its vertex transform, projection and face collection in the ordinary scene loops. The classifier itself still costs CPU time. Sorted faces recover the coverage of their owner; prepared-face paths and wire passes use the same ownership contract. Primitive geometry, winding, normal generation, near/screen clipping, lighting, textures and precision remain the renderer's own implementation.

Intermediate coverage uses a deterministic, screen-anchored 4×4 Bayer pattern. Bitmap stores merge selected bits into the previous bitmap value, keeping both bits of a multicolor pixel together. Wire lines become stippled; this may reduce readability, so enabling the feature is a scene-level choice. It does not alternate whole frames and does not require temporal flicker. IRQ state is separate from foreground renderer scratch/SMC. The store helpers preserve A/X/Y and flags, including writes to non-bitmap pointer destinations.

UI, headers, sky and the analytic Ground background are not finite scene objects and are not faded by this object policy. Use finite mesh objects for distance-limited terrain. VIC-II per-cell palette constraints still apply: stipple does not create unrestricted alpha blending between incompatible material palettes. The effect preserves bitmap bits; it does not introduce a new color compositor or an occlusion buffer.

Legacy/legacy-plus helpers are reallocated together after instrumentation. Mode1 also relocates unchanged wire/clip kernels, preserving intentional fall-through entries. The same bounded free-gap search and per-part guards apply. `df_` and `df8_` symbols are private implementation names; application code must not write their scratch or call these helpers. Direct Python keyword arguments are `distance_fade`, `fade_start`, `fade_end` for Q8/Normalized16; use the public CLI/scene contract for Mode8.


## Mode 8: separate 2.5D backend

Mode8 has map cells and plane profiles rather than polygon objects. Distances are **map cells** (integer configured thresholds, Q8 fractional camera displacement retained), measured conservatively along the normal of a visible plane. Thus the numeric units/metric differ from Modes1–7: choose thresholds for the actual map. For example:

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile ../inputs/map.json -Mode8Run auto -OutputDirectory ../outputs/map-fade -DistanceFade dither -DistanceFadeStart 2 -DistanceFadeEnd 8
```

Both auto and interactive builds retain the existing map, collision, navigation and geometry contracts. On the multilayer backend, profile selection controls surface coverage; entirely distant profiles return a shared empty projection without generating the normal profile. Intermediate bands use the existing top/bottom samples and merge a Bayer mask while drawing. Fully opaque bands retain the original fast renderer.

Mono-opaque and mono-portals use the nearest coarse wall/overhead plane of the current column group to retain nearby layers conservatively. A group containing nearby geometry can therefore keep more distant layers visible longer. Refined bands use that same group coverage. A background reset removes stale stipple pixels; the existing black/brown background and UI remain. This is not per-pixel radial fog, a new ray tracer, or a DDA traversal cutoff. Geometry discovery can still run beyond the fade distance. The conservative group policy and the map renderer's pre-existing adaptive sampling limitations remain explicit.

The feature uses only the existing unused 2449-byte reserved payload window. All payload, low-code, cache, font, bitmap and screen bounds remain guarded; no existing memory boundary is widened. Omission/off emits the original templates byte-for-byte.

## Independent Mode7 texture LOD

`TextureLOD`, `TextureLODNear` and `TextureLODFar` retain their existing names, defaults and profile restrictions: Q8 perspective Mode7, `off/gradual`, default off, `1 < near < far < 256`, interval width16 WU. Their existing original-corner depth metric and material/pigment behavior are unchanged. The distance fade uses its own origin-distance thresholds.

The four combinations are: both off; texture LOD only; distance fade only; both enabled. For both:

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -SceneFile ../inputs/textured.json -GraphicsMode 7 -Precision q8 -TexturePrecision perspective -VideoStandard pal -OutputDirectory ../outputs/textured-fade-lod -DistanceFade dither -DistanceFadeStart 64 -DistanceFadeEnd 112 -TextureLOD gradual -TextureLODNear 28 -TextureLODFar 44
```

The fade never rewrites LOD thresholds, `ld_weight`, modal/accent pigments or its sampler/lighting policy. LOD changes texture detail on visible surfaces; fade changes coverage and eventually excludes the object. Existing affine, standard/fast and lighting restrictions still apply to the respective exporter. Additional code/data can exhaust RAM, particularly in perspective/Gouraud combinations. The bounded allocator reports an explicit memory error; there is no lower-precision fallback, weakened guard or silently disabled feature. A successful small scene does not qualify arbitrary geometry budgets.

## When Distance Fade helps

Choose Distance Fade according to the work that distant geometry can stop doing and the visibility that the scene can afford to lose. Its main performance benefit in Modes 1–7 comes from **fully excluding objects beyond `end`**. An object in the transition band still needs geometry processing and, where applicable, lighting and texture sampling; the final coverage mask adds work. Keeping every object visible at full opacity also retains the overhead of the enabled feature. Use the transition for its visual effect when the frame budget permits it, rather than assuming that fewer visible dots make rendering cheaper.

### Scene structure and distance ranges

The feature is a good candidate for an extended world made of many separate, spatially compact objects distributed over depth: the foreground stays opaque, a limited band transitions, and a meaningful amount of distant geometry is omitted entirely. Removing an expensive object can save substantial work even when it occupies few pixels, because its vertices and faces still have a cost. Objects that remain large on screen at a distance can also offer substantial fill and sampling savings when fully excluded.

It is less attractive when almost everything stays inside `start`, when most visible geometry remains in the partial band, or when a large part of the viewport is covered by partially faded surfaces. A very broad transition can keep many objects paying the masking cost without reaching exclusion. A narrower transition may reduce this overhead, but must still look acceptable with discrete coverage levels and camera motion. There is no universal distance, band width or minimum excluded-object percentage that makes the option profitable for every scene.

Keep object origins representative of their visible geometry. A single large terrain, building or road mesh with an origin near the camera can retain distant faces at full coverage. An origin beyond `end` can instead remove parts of the same mesh that extend close to the camera. Spatially compact objects or chunks give more useful control; their additional object-management and RAM costs also need to fit the scene. The analytic Ground, sky and UI remain outside the object fade policy, so their work is not removed by fading finite objects. Rendering exclusion does not automatically deactivate application logic or collision handling.

### Differences between rendering modes

| Mode | Scene types that can benefit | Scene types where fade can cost more |
|---|---|---|
| 1 — wireframe | Many separate distant objects whose transforms, clipping and edge drawing can be skipped entirely. | A detailed wire object that remains partially visible; many thin lines gain stipple work and may become harder to read. |
| 2 — hidden-wire | Distant objects that can be removed together with their geometry, face masking and edge work. | Dense overlapping wire geometry kept in the transition band: hidden-wire processing remains and masked writes add cost. |
| 3 — solid / static shading | Groups of independent objects spread over depth, with enough complete exclusions to avoid geometry and fill. | Large partially faded faces; the masking overhead can be large relative to a simple solid fill. |
| 4 — dynamic flat shading | Separate distant meshes whose own geometry, lighting and fill work can be avoided. | A mainly nearby scene or large surfaces that remain partial; flat shading and geometry still run before the mask. |
| 5 — dynamic flat with outlines | Objects that can be excluded with both their fill and outline passes. | Many visible contours in the transition band: the outline remains work and its stipple can reduce readability. |
| 6 — Gouraud | Distant objects that can be excluded before their geometry, lighting and interpolation work is needed. | Broad partial surfaces that still require Gouraud processing plus the coverage mask. Fade does not replace the shading calculation. |
| 7 — textures | Distant textured objects that would otherwise require substantial geometry or visible texture sampling, and can be excluded completely. | Visible surfaces that still require sampling and optional lighting before masking; already cheap distant objects leave less work to save. Affine/perspective and lighting profiles have different costs. |
| 8 — map renderer | Maps where the chosen cell thresholds exclude enough distant profiles to avoid projection and drawing. | Maps dominated by nearby planes or partial bands, or by geometry discovery and background work that the fade does not remove. |

For Mode7, keep texture LOD and fade as separate decisions. LOD controls detail on surfaces that remain visible; fade controls coverage and eventual exclusion. An existing lower-detail policy can reduce the work that fade could save. Choose both within their supported profiles and evaluate the combination, rather than adding their gains or treating their different distance metrics as interchangeable.

For Mode8, a long wall close to the camera can stay near according to its plane-normal distance even along visually distant sections. Narrow spaces with nearby sidewalls can therefore retain much of their work despite a short fade range. In mono backends, a nearby plane can also retain other layers in its conservative column group. The multilayer backend can skip fully distant profile projections, but the DDA traversal and background work are not eliminated by that decision. Use map-cell thresholds appropriate to the actual planes and layout, rather than copying world-unit thresholds from a polygon scene. Check that important boundaries and navigation cues remain visible.

### CPU speed and the frame budget

| CPU target | How to judge the choice |
|---|---|
| 1× | Additional masking is costly relative to the available frame budget. Full exclusions must save enough work; a large relative gain can still leave an overly complex scene too slow. |
| 20× | The transition can still push a view past a presentation deadline. Consider both the native render cost and complete-view FPS, including the application's other work. |
| 64× | The video presentation ceiling can keep FPS unchanged while fade either consumes or frees CPU headroom. Unchanged FPS does not establish that the effect is free or useless. |

Higher CPU speed does not by itself make fade beneficial. Compare the intended scene with fade OFF and with the chosen thresholds while retaining its geometry, lighting, texture policy, route and other active work. Follow both native render time and newly completed-view FPS during movement as well as stationary views. Select `end` so that omitted geometry is genuinely expendable for visibility and gameplay; making the whole scene disappear is not a useful performance target when that geometry needs to remain visible.

## Cost, validation and delivery

Partial visibility still needs geometry and often texture sampling. Masking adds foreground work; fewer visible dots do **not** imply proportionally fewer calculations or higher FPS. Full object exclusion can save substantial work. Mode8 partial band drawing and the mono background reset can also cost more than the original renderer. Measure the intended scene, target and distance distribution; the option remains off by default.

The current validation and native measurements are recorded in [AGENTIC36](AGENTIC36.en.md) and [qualification](QUALIFICATION-1.20.0.json). Native FPS count complete presented views in PAL Turbo6510 time after warm-up, never CPU replay or host/warp time. The compiled arithmetic/store test is correctness-only: `python -B scripts/test_distance_fade.py` (development dependencies: 64tass and py65). Source distributions contain no test scenes, demos, music, PRGs or captures; all native evidence stays external.

## Agentic35 implementation

Writer dispatch/mask selection moves to private level updates, with a compact Mode7 variant to preserve RAM. Mode8 clears the identical viewport in contiguous character-row slices and limits partial sampling to the conservative top/bottom union. No metric, sampling, visible pixel or public configuration changes. The [current notes](AGENTIC36.en.md) describe proof, native measurements and limits.

## Agentic36

The method/API/output is retained. Per-view multilevel plane-level reuse, cheaper wrapper and four-phase scalar fills remove repeated work; polygon range rejection/squares remain exact. Explicit wire ranges no longer overwrite polygon owners. Multi payload920/2449, mono766/2449, original guards unchanged. See [implementation and measurement scope](AGENTIC36.en.md).
