# Building Mode 8 maps

This guide describes the **implemented, deliberately restricted** 1.4.0 map contract. Use [MODE8.en.md](MODE8.en.md) for runtime architecture and [QUICKSTART.md](QUICKSTART.md) for SDK setup. Mode 8 is a separate 2.5D bitmap renderer, not a polygon importer.

## 1. Choose the right complete template

| Environment | Complete scene | What may change | What stays fixed |
|---|---|---|---|
| One floor, opaque walls and pillars | [perimeter.json](examples/mode8/perimeter.json) | Solid/free cells away from the border and route | Floor 0, ceiling 128, no apertures/ramps; initial camera and all waypoints |
| One floor with thick static apertures | [apertures.json](examples/mode8/apertures.json) | Solid/free geometry around the qualified separator | Floor 0; room ceiling 96; aperture ceiling 64; separator y=14 and its two openings; initial camera and all waypoints |
| Two floor plans joined by continuous ramps | [two-levels.json](examples/mode8/two-levels.json) | Geometry, declared apertures and waypoints within the heightfield contract | Initial camera, allowed floor values, two ramp formulas and footprints; numeric/path/memory budgets |

These are not three freely configurable general-purpose level editors. In particular, moving a monolevel aperture, changing its thickness, adding arbitrary ramps or moving a template's initial camera is rejected. Multi-level means a single floor/ceiling pair at each XY position: **no room-over-room**. No animated doors or opening/closing command exist.

All scenes are complete 32×32 maps. Generated [coordinate plans](examples/mode8/PLANS.md) show the exact source cells and tutorial changes. A successful build checks syntax, geometry, selected backend, capacities and the automatic route; it does not prove every possible interactive view has been exhaustively sampled.

## 2. Public coordinates and units

Origin is the upper-left map corner. X increases right; Y increases down the printed plan. Cell `(x,y)` is at array index `32*y+x`, with both indices 0–31. Arrays contain rows in increasing Y, each row in increasing X. The outermost row/column must be solid.

```text
             X →
        0  1  2  3 … 31
 Y  0   #  #  #  # … #
 ↓  1   #  .  .  . … #     # solid=1; . free=0
    2   #  .  #  . … #     P initial camera; D static aperture
   31   #  #  #  # … #     R ramp marker; actual plans are linked above
```

Horizontal camera and waypoint coordinates are **already Q8.8 integers in the JSON**. The builder does not multiply them by 256. Cell `(x,y)` has center `(256*x+128,256*y+128)`; divide a position by 256 to obtain cells. One integer unit is 1/256 cell. This is not `position`, `xWU` or another polygon-scene field.

Vertical ordinary values are integer units of **1/32 cell**: floor 32 is one cell above floor 0; ceiling 128 is four cells above zero. Runtime ramp heights carry another eight fractional bits. `initial` is `[xQ8,yQ8,yaw,eyeInteger,eyeFraction]`; the last two values represent `eyeInteger + eyeFraction/256` vertical units. The eye is always 32 units above the local floor.

Yaw has 512 discrete values, 0–511. Zero looks along +Y, 128 along +X, 256 along −Y, 384 along −X; increasing yaw turns right from the forward direction. Runtime wrap is modulo 512. Public input is range-checked, not silently wrapped. One yaw unit is 360/512 degrees. FOV is fixed at 60 degrees; there is no public FOV override. The initial camera must match the chosen template exactly.

Mode 8 conventions are separate from [WORLD-METRICS.md](WORLD-METRICS.md). Do not apply polygon world-unit scaling or the Mode 1–7 camera schema to these arrays.

## 3. Exact JSON fields

Root object has **exactly** `scene` and `navigation`, both objects. Duplicate JSON keys, unknown fields, null in place of an array/object, booleans in integer arrays, and missing required fields are errors. No schema or geometry is inferred from a filename.

| Field | Type / required / default | Domain and dependency |
|---|---|---|
| `scene.schema` | string, required | Exactly `3dvibe64-mode8-map-v1` |
| `scene.size` | two integers, required | Exactly `[32,32]` |
| `scene.solid` | 1024 integers, required | 0 free, 1 opaque; border all 1 |
| `scene.floor` | 1024 integers, required | Monolevel: all 0. Multi: 0,32,64 or ramp marker 254/255 |
| `scene.ceiling` | 1024 integers, required | Mono opaque all 128; mono apertures 96 except specified cells 64. Multi: 1–192 plus headroom/join restrictions below |
| `scene.initial` | five integers, required | Template-fixed initial camera, in the units above; valid collision footprint and eye height |
| `scene.eyeHeight` | integer, required | Exactly 32 |
| `scene.playerHeight` | integer, optional; 48 | Exactly 48. Null/0 are invalid, not defaults |
| `scene.heightUnit` | string, optional; `1/32 cell` | Only that string accepted; does not convert data |
| `scene.doors` | array, required | `[]` for opaque; two fixed rectangles for mono; dictionaries for multi |
| `scene.ramps` | array, required | `[]` for mono; exact two ramp descriptors for multi |
| `scene.notes` | string, optional; unused | Human description only; no runtime effect |
| `navigation.camera` | three integers, required | Exactly `scene.initial[0:3]` |
| `navigation.nodes` | array of integer pairs, required | Cyclic Q8.8 waypoints; each coordinate >0 and <8192. 2–193 mono, 2–160 multi; mono list must equal its template |

`solid`, `floor` and `ceiling` are always complete, including solid cells. Solid-cell heights still obey the backend's domain. Zero is meaningful in `solid` and `floor`; it is not an omitted field. `doors: []` and `ramps: []` are valid absence declarations; `null` and omitted fields are not.

The author writes cell arrays and aperture/ramp metadata. Owner IDs, directional event maps, plane/profile IDs, lookup arrays, bitmap addresses and all assembly are **generated or supplied by the SDK**. Never edit these internal tables to make a map pass.

### Opaque monolevel

Any supported solid/free arrangement must retain the closed border and free route. Each contiguous, collinear exposed wall boundary becomes an owner; at most **96 owners plus sentinel 0** fit the qualified layout. More obstacles can exceed this budget even on a 32×32 map. There is no overhead volume in this family.

### Monolevel static apertures

`doors` must be exactly `[[10,14,11,14],[22,14,23,14]]`, inclusive cell rectangles. Row y=14 is solid except x=10,11,22,23. These four cells are free with ceiling 64; every other cell has ceiling 96. All floors are 0.

```text
Plan, separator row 14 (X increasing):
  … # # [10 D][11 D] # … # [22 D][23 D] # …
  thickness: y=14 to y=15, exactly one horizontal cell

Vertical section through an aperture:
  z=96  ───────── room ceiling ─────────
        █████████ solid header █████████
  z=64  ───────── underside ────────────
        │  open passage, height 64     │
  z=32  │  eye                        │
  z=0   ───────── floor ────────────────
```

The retained separator and two isolated slots ensure a ray does not require two separate overhead volumes before its opaque wall. Merely having a uniform floor is not sufficient to use this backend. Side faces and header depth remain part of the rendering.

### Multi-level heightfield

Ordinary floor levels: 0,32,64. Markers 255 and 254 are **formula selectors**, not heights 255/254. They are present in the complete template; preserve their footprint and metadata. No arbitrary stairs, riser jumps, ramp orientation or gradient are exposed.

| Marker | Allowed free-cell footprint | Formula in vertical units, Y in cells | Endpoints |
|---|---|---|---|
| 255 | x=8..10, y=11..14 | `8*(Y-11)` | y=11:0; y=15:32 |
| 254 | x=14..16, y=18..21 | `8*(Y-14)` | y=18:32; y=22:64 |

The exact descriptor objects are in [two-levels.json](examples/mode8/two-levels.json): `marker`, `axis:"y"`, `origin`, `start`, `end`, `bottom`, `top`. All other fields are integers. There are no optional fields in an object and the two-object array must match the template. Formula origins 11 and 14 are deliberately different from the second ramp's start 18.

```text
floor 64                           ───────── upper
                                  / marker254 (18 ≤ Y < 22)
floor 32            ──────────────    landing
                   / marker255 (11 ≤ Y < 15)
floor  0  ────────                         lower
```

Every traversable shared boundary must have equal floor heights on its two sides, evaluating ramp formulas at that boundary. Abrupt free-cell steps are rejected. Solid screening cells may separate otherwise incompatible levels. Each free cell requires at least 48 units of headroom. The conservative ramp check uses 64 as the floor bound for both markers; with ordinary cells it uses their actual floor. The eye follows the ramp continuously, including its fractional component.

A multi-level aperture is `{ "axis":"y", "plane":6, "start":16, "end":18, "floor":0 }` in the original scene. For axis y, plane is the row and start/end are inclusive X; for axis x, plane is the column and start/end are inclusive Y. Every index is 1–30, start≤end. Each declared cell must be free, with the declared ordinary floor and ceiling exactly `floor+80`. Conversely every free cell with ceiling−floor=80 must be declared. No extra dictionary keys are accepted.

Global budgets: **≤255 profile keys and ≤255 event records** (including any reserved entry), with 8-bit IDs. This is separate from the per-ray path buffer: the builder proves a conservative monotone-grid bound **strictly below 15 encountered events** before an opaque wall. The original map's bound is 11. A scene can fit global IDs but exceed the path limit, or vice versa. 32 cache slots do not limit the total keys to 32; eviction is allowed and affects cost.

## 4. Camera, collision and navigation

W/S move forward/backward, A/D turn. The interactive runtime uses a radius of 48/256 cell, tests the footprint, and slides along walls. It does not impose a “70% screen occupancy” rule. The automatic route uses the original continuous pursuit, not cardinal rotations. Automatic collision radius is 224/256 cell in the aperture template and 48/256 in the other two.

Initial camera is fixed for all families. Both mono routes are fixed verbatim, including waypoint order. Multi waypoints may change within the 160-entry limit but must preserve the template start, remain navigable, and complete a full cyclic lap without a blocked tick in the 30,000-tick host validation. Small headroom, unreachable stops or obstacles on the itinerary are errors, not triggers for automatic replanning. There is no waypoint pathfinding during public build.

The same validation runs for an interactive build: it qualifies the scene/template pair, including its automatic example. All supplied tutorials preserve the original camera and route. Not every possible manual path has been exhaustively verified.

Palette is fixed in this contract: VIC-II indices 0/9/8/7, orientation-based wall pigments and screen-anchored ceiling stipple. No scene palette, per-wall RGB, texture, light or FOV fields are exposed. Changing those requires source development, outside map authoring.

## 5. Three executable geometry tutorials

Use the supplied full final scenes; no missing array elements or assembly edits are required. To make the change yourself, copy the corresponding original JSON outside the SDK and perform the cell edits below, retaining all other fields.

| Tutorial | Exact edits | Full final file | What the earlier map study actually found |
|---|---|---|---|
| Move one pillar | `solid[15*32+21]=0`; `solid[16*32+21]=1` | [perimeter-tutorial.json](examples/mode8/perimeter-tutorial.json) | No practically significant tour improvement; not a recommended performance optimization |
| Move a 2×2 pillar | Clear x=15..16 at y=18; set x=15..16 at y=20; y=19 stays solid | [apertures-tutorial.json](examples/mode8/apertures-tutorial.json) | Local CPU reduction, no material improvement of tour p95; not a general speed recommendation |
| Narrow a lower aperture | Set `solid[6*32+16]=1`; in the y=6 aperture whose start is 16, change start to 17 | [two-levels-tutorial.json](examples/mode8/two-levels-tutorial.json) | Opening width 3→2 cells; partial improvement of long pauses, upper-level worst remains |

From the extracted SDK root, with Python, PowerShell and 64tass available:

```powershell
Copy-Item examples/mode8/perimeter-tutorial.json ../my-perimeter.json
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile ../my-perimeter.json -ValidateOnly
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile ../my-perimeter.json -Mode8Run interactive -OutputDirectory ../my-perimeter-build
x64sc -default -pal -autostartprgmode 1 ../my-perimeter-build/3Dvibe64.prg
```

Corresponding complete builds for the other tutorials:

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile examples/mode8/apertures-tutorial.json -Mode8Run interactive -OutputDirectory ../my-apertures-build
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile examples/mode8/two-levels-tutorial.json -Mode8Run auto -OutputDirectory ../my-two-levels-build
```

Use a new empty output directory for each build. Output inside the SDK is rejected. `-Mode8Run` defaults to `interactive`; `auto` uses the validated itinerary. The PRG auto-detects PAL/NTSC; test NTSC by changing the emulator option to `-ntsc`. Public commands are checked by the Mode 8 tests and release extraction qualification. Normal build requires only the Python standard library, PowerShell and 64tass; no emulator or profiler is imported by the builder.

## 6. Common errors

| Code | Cause | Fix |
|---|---|---|
| `SCHEMA`, `FORMAT`, `ARRAY`, `INTEGER`, `UNKNOWN_FIELD` | Wrong JSON shape/type, incomplete array, unrelated polygon property | Start from a complete Mode 8 template; use integer arrays, not null/booleans |
| `BORDER` | Free cell on outside edge | Restore solid border at reported cell |
| `INITIAL_POSE`, `CAMERA`, `TEMPLATE_CAMERA` | Blocked footprint, wrong eye, camera mismatch or changed template start | Restore exact template camera and free its collision footprint |
| `MONO_CEILING`, `MONO_QUOTE`, `MONO_FLOOR` | Unsupported constant-room heights | Restore family values |
| `MONO_APERTURES`, `MONO_SEPARATOR` | Moved/resized slot or breached separator | Restore the two one-cell-thick qualified apertures and row14 |
| `RAMP_FORMULA`, `MULTI_GEOMETRY` | Wrong marker, footprint or discontinuous join | Restore supported ramps and continuous adjacent floor heights |
| `HEADROOM`, `DOOR_CELL`, `DOOR_METADATA` | Insufficient vertical clearance or metadata/array disagreement | Correct the identified cell and associated descriptor |
| `OWNER_CAPACITY`, `EVENT_CAPACITY`, `PATH_CAPACITY` | Distinct numeric budgets exceeded | Simplify geometry appropriate to the reported budget; no silent precision reduction |
| `MONO_NAV`, `MULTI_NAV_CAPACITY`, `AUTO_COLLISION`, `AUTO_TOUR` | Unsupported route or blocked/uncompleted lap | Restore mono route; check multi nodes, clearance and cycle completion |
| `LOW_BUDGET`, `ASSEMBLER` | Source/data layout budget violated | Inspect assembler.log; reduce permitted variable data, never hand-edit addresses |
| `OUTPUT_DIRECTORY`, `OUTPUT_EXISTS` | Output inside SDK or existing nonempty folder | Choose a new external directory |

## 7. Optional cost atlas

Long empty rays, owner discontinuities, successive overhead apertures and distinct profile keys can cost more than a visually crowded room. The multi cache contains 32 profiles: a view requesting more distinct profiles can churn it. Cell-access frequency is not itself the whole cost of that cell; shared profile costs must not be added twice.

Install optional dependencies separately: `python -m pip install py65==1.2.0 Pillow`. Build the map first, then run:

```powershell
python -B scripts/analyze_mode8.py --scene examples/mode8/perimeter.json --build ../perimeter-reference-build --sampling examples/mode8/sampling/perimeter.json --out ../perimeter-cost
```

Use a build of that **same** scene (for example the public command in [MODE8.en.md](MODE8.en.md)). The sampling document contains `poses`, each `[xQ8,yQ8,yaw,eyeInteger,eyeFraction]`, evaluated in order with persistent RAM. For another map check every sampling pose; invalid footprint/eye/range samples are explicitly recorded and skipped, not converted.

Outputs: `poses.json`, `poses.csv`, `REPORT.md`, `atlas-host.png`. Mean and worst observed cell costs are separate; the arrow marks the costliest sampled yaw. Grey is unsampled, blue unreachable, pink invalid, black solid. This is a **host-generated map atlas**, not a VICE screenshot. Every valid render compares all 7,040 bitmap bytes (viewport plus margins) with the independent fixed oracle.

Cycles come from executing the assembled 6502 instructions in py65, excluding VIC stalls, IRQ, input, simulation and presentation. They are not native FPS. Native timings require `scripts/qualify_mode8.py` with stock x64sc. Neither tool inserts instrumentation into the distributed PRG. Worst sampled pose is not a global worst-case bound; no automatic scene optimizer or guaranteed speedup is provided.
