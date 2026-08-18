# 3Dvibe64 — Assembly Programmer's Guide

This guide is for programmers who already understand the Commodore 64, the 6510/6502, the VIC-II, and a conventional assembler workflow, and who want to use or modify 3Dvibe64 through ordinary software engineering. It is not a vibe-coding guide and does not assume the use of generative tools. The practical Codex-assisted workflow is documented separately in [VIBE-CODING-GUIDE.en.md](VIBE-CODING-GUIDE.en.md).

The general scene API and renderer profiles remain documented in [README.en.md](README.en.md). Spatial, angular, and time units are defined in [WORLD-METRICS.md](WORLD-METRICS.md). This document explains how the engine is built, how to obtain the actual assembly source, how to navigate the generated routines, and how to make reproducible changes.

## 1. The correct mental model

3Dvibe64 is not distributed as a conventional assembly project made of `main.asm`, `renderer.asm`, `camera.asm`, and `.inc` files. It is a **generator of specialized C64 programs**.

The actual chain is:

```text
JSON scene + CLI options
          |
          v
work/build-3Dvibe64.ps1
  - validates the scene
  - computes tables and memory layout
  - selects compile-time features
  - emits 6510/6502 source
          |
          v
work/3Dvibe64.asm
          |
          v
64tass
          |
          v
work/3Dvibe64.prg
work/build/3Dvibe64.prg
```

`work/3Dvibe64.asm` is therefore a build product, not the authoritative repository source. A different scene or option set may generate a program with different routines, tables, addresses, and sizes.

This has three practical consequences:

- to **use** the engine, normally edit JSON and builder options;
- to **study and debug** the engine, generate and read `3Dvibe64.asm`;
- to make a **permanent engine change**, edit `build-3Dvibe64.ps1`, regenerate the ASM, and run the tests.

A change made only to `work/3Dvibe64.asm` is useful for a local experiment but will be overwritten by the next build.

## 2. Distribution map

The files most relevant to an assembly programmer are:

| Path | Role |
|---|---|
| `work/build-3Dvibe64.ps1` | Authoritative builder and engine generator. It contains PowerShell host logic, assembly templates, substitutions, and memory checks. |
| `examples/*.json` | Public minimal or demonstrative scenes. They also serve as readable API tests. |
| `validation/**/*.json` | Scenes aimed at clipping, memory, depth, and outline regressions. |
| `work/tools/c64_material_scales.generated.json` | VIC-II ramps for material families and reflectivity levels. |
| `scripts/test_*.py` | Host-side and release/runtime contracts. |
| `PACKAGE-MANIFEST.json` | Public capabilities, reference-build hashes, and expected runtime signatures. |
| `MANIFEST.sha256` | Integrity list for the permanent release files. |

The distribution deliberately contains no permanent PRG or ASM. Build in a disposable working copy when you want the SDK tree to remain clean.

## 3. Toolchain

### 3.1 Required components

An ordinary build requires:

- Windows PowerShell;
- 64tass 1.60 or newer;
- a valid JSON scene.

VICE x64sc is recommended for debugging and runtime contracts. Python 3 is required for the host-side tests.

The builder searches for 64tass in this order:

1. full executable path in `TASS64_EXE`;
2. file or directory named by `TASS64_PATH`;
3. `work/tools/64tass/64tass.exe`;
4. `work/tools/64tass/64tass-1.60.3243/64tass.exe`;
5. `64tass.exe` or `64tass` on `PATH`.

VICE used by the tests may be selected through `VICE_X64SC` or `VICE_EXE`, or be available on `PATH`.

### 3.2 Quick check

```powershell
64tass.exe --version
x64sc.exe -version
python --version
```

If PowerShell blocks script execution, invoke the builder with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ...`; no permanent system policy change is required.

## 4. First readable build

From a copy of the package root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\work\build-3Dvibe64.ps1 `
  -SceneFile .\examples\basic-solid-reference.json `
  -GraphicsMode 4 `
  -CameraMode fixed `
  -CameraViewport normal `
  -Quality balanced `
  -Projection table `
  -MemoryLayout stable `
  -NoFpsOverlay `
  -SkipCmdUpdate
```

The main artifacts are:

| File | Contents |
|---|---|
| `work/3Dvibe64.asm` | Generated source specialized for the selected scene and options. |
| `work/3Dvibe64.prg` | Assembled C64 program. |
| `work/build/3Dvibe64.prg` | Build-flow copy of the PRG. |

Without `-SkipCmdUpdate`, the builder may also update assembly/run `.cmd` helpers. Keep the switch enabled for comparison builds and automation.

The PRG contains a small BASIC stub at `$0801` with `SYS 2061`; machine code starts at `$080D`, and the main label is `start`.

## 5. Making the ASM navigable

Generated source can be several hundred kilobytes long. Before reading it linearly, generate labels, a listing, and a map with 64tass:

```powershell
Set-Location .\work

64tass.exe -a -B `
  --vice-labels `
  --labels=build\3Dvibe64.vice.labels `
  --map=build\3Dvibe64.map `
  --list=build\3Dvibe64.lst `
  -o build\3Dvibe64-debug.prg `
  .\3Dvibe64.asm
```

The important options are:

- `-a`: addressing mode used by the builder;
- `-B`: automatic expansion of long branches;
- `--vice-labels`: symbols in VICE monitor format;
- `--labels`: symbol table;
- `--map`: output sections and ranges;
- `--list`: source listing with addresses and bytes;
- `-o`: output PRG.

Use a distinct output name to avoid replacing the PRG validated by the builder.

Useful searches include:

```powershell
rg -n "^start:|^main_loop:|^render_frame_begin:|^render_frame_end:" .\work\3Dvibe64.asm
rg -n "^project_vertex:|^face_visible:|^draw_depth_buckets:" .\work\3Dvibe64.asm
rg -n "^clip_|^explorer_|^fill_|^plot_wire" .\work\3Dvibe64.asm
rg -n "^\* =|^; ===" .\work\3Dvibe64.asm
```

Not every label listed in this guide exists in every build. The generator removes or disables paths that are incompatible with the selected configuration.

## 6. Generated-source anatomy

The ASM is organized approximately as follows:

1. BASIC stub and initial code origin;
2. zero-page assignments and scratch aliases;
3. scene-derived constants and compile-time contracts;
4. C64 and VIC-II initialization;
5. main loop, simulation, and input;
6. transformation, camera, and projection;
7. face/edge collection and depth buckets;
8. clipping, culling, and Ground;
9. solid, pattern, and wire rasterizers;
10. tables, scene data, and runtime buffers.

The `; === ... Contract ===` sections are particularly valuable. They describe what was actually compiled, including:

- viewport size and origin;
- effective graphics mode;
- camera and near profile;
- clipping and culling features;
- Ground paths;
- emitted optimizations and fallbacks;
- mesh, object, vertex, and face counts.

Treat these constants as a compilation report. Before diagnosing a routine, confirm that its corresponding flag is actually `$01`.

## 7. Program and frame flow

### 7.1 Startup

Execution starts at `start`. Depending on the build, it initializes:

- CPU/CIA/VIC-II state;
- bitmap, Screen RAM, and Color RAM;
- tables and dirty buffers;
- materials and light;
- the fixed camera or mobile-camera `explorer_*` state;
- optional Generic Text/FPS split and its IRQ.

Control then enters `main_loop`.

### 7.2 Main loop

The most useful labels for tracing one frame are:

```text
main_loop
  -> wait/schedule video tick
  -> read input and update camera
  -> advance simulation, objects, light, and timeline
  -> render_frame_begin
  -> render_world_background
  -> render_scene_renderer
  -> render_frame_end
  -> present/swap buffers
```

Logical simulation runs at 50 ST per second on both PAL and NTSC. Video presentation and logical advancement are separate concerns; NTSC builds emit the required compensation.

### 7.3 Frame boundaries

`render_frame_begin` prepares the back buffer, dirty state, and caches. `render_world_background` handles the background and Ground when enabled. `render_scene_renderer` enters the pipeline selected by GraphicsMode. `render_frame_end` completes the frame and makes the buffer presentable.

For stable profiling or breakpoints, `render_frame_begin` and `render_frame_end` are better anchors than a highly specialized internal routine.

### 7.4 DEV7 same-bank text split

With the visual overlay compiled in, each VIC-II bank owns its Screen RAM and compact charset. The IRQ shows three character rows, switches to the bitmap fast path at `TEXT_BITMAP_IRQ_RASTER=$4A`, and starts the body at `TEXT_BODY_FIRST_RASTER=$4B`. `TEXT_HEADER_CELL_ROWS=3` and `TEXT_HEADER_SCREEN_BYTES=120` are a public memory contract: `apply_active_material` must begin after byte 119 in both screen buffers.

The normal 3D body is therefore 160×88 at Y=12; small is 128×80 at Y=12. `-NoFpsOverlay` compiles the unchanged 1.1.0 bitmap-only path. Generic Text uses a `$FF`-terminated compact string; zero is a valid space glyph. The FPS digits and Generic Text are written to both Screen RAM buffers, not copied from one displayed bank to the other.

At runtime, `F` toggles this complete split, not only the numeric FPS cells. The OFF path still selects VIC bank, Screen RAM and bitmap from `drawbuf`. `TEXT_CHARSET_BYTES` is derived from `TEXT_CHARSET_GLYPH_COUNT`: it is 96 for the FPS-only charset and 184 when Generic Text is emitted. The safe toggle path clears exactly that bitmap prefix while hidden and restores it before re-enabling the text IRQ; `$4A`/`$4B` timing is unchanged.

## 8. The 3D pipeline

The conceptual pipeline is:

```text
mesh/object data
  -> object transform
  -> camera transform
  -> geometric depth
  -> projection
  -> near/Ground classification
  -> backface culling
  -> clipping
  -> depth-bucket insertion
  -> far-to-near painter order
  -> shading/material
  -> fill, pattern, wire, or outline
```

The concrete order may vary by mode and fast path. Some builds prepare or project data early; others retain complete fallbacks for boundary-crossing faces.

### 8.1 Transformation and camera

`fixed`, `walkLite`, and `walkFull` share scene semantics but do not necessarily share the same generated code.

- `fixed` is specialized and compact;
- `walkLite` provides yaw and pitch;
- `walkFull` adds roll.

Mobile-camera routines generally use the `explorer_` prefix. Useful entry points include:

- `explorer_init_camera`;
- `explorer_scan_keys`;
- `explorer_advance_camera_tick`;
- `explorer_prepare_motion_axes`;
- `explorer_prepare_view`;
- `explorer_transform_project_vertices`;
- `explorer_project_x16` and `explorer_project_y16`.

Public coordinates normally use `world-z-up`; the builder converts them to internal `engine-y-up`. Do not repair axes directly in ASM without checking [WORLD-METRICS.md](WORLD-METRICS.md) and the PowerShell functions `Convert-SceneVectorToEngine` / `Convert-EngineVectorToScene`.

### 8.2 Depth and projection

Geometric depth and the projection-table index are distinct concepts. Generated source documents them through these semantic aliases:

```text
camera_depth_geometric_lo/hi
projection_table_index_lo/hi
```

The table bias is an addressing device; it must not affect the near plane, culling, sorting, or depth buckets.

Relevant labels include:

- `project_vertex`;
- `project_vertex_extended_table`;
- `project_vertex_reference`;
- `projection_depth_index_from_p1`;
- `explorer_project_axis_offset` for mobile cameras.

`table` is the ordinary profile. `reference` favors mathematical clarity and comparison. `extended-table` uses an extended table where supported. Do not assume identical scratch registers or cycle cost across the three paths.

### 8.3 Near plane and clipping

The public profiles are `default`, `late`, and `clip`:

- `default`: historical rejection and minimum divisor;
- `late`: accepts closer depth but rejects a face that crosses the camera plane;
- `clip`: polygon clipping against the camera plane.

Screen and near clipping may use A/B buffers of up to 12 vertices. Important label families are:

- `camera_plane_*`;
- `clip_loaded_face_near_poly`;
- `clip_loaded_face_poly_x`;
- `clip_poly_*`;
- `clip_project_*`;
- `ground_plane_*` for Ground clipping.

The pipeline remains one-sided. Enabling clipping does not make the renderer two-sided.

### 8.4 Culling

`face_visible` is a useful anchor for the screen-space backface test. With `-FaceCullProfile stable`, Mode 4/5 builds may also use `stable_face_cull_*` and `camera_plane_original_facing` near edge-on.

Before changing a sign test or vertex order, verify:

- axis convention;
- source-face winding;
- camera transform;
- clipped-face behavior;
- preservation of lighting caches used by dynamic shading.

A local culling change can produce apparently unrelated material regressions.

### 8.5 Depth buckets and painter order

Visible faces are collected in 16-bit depth buckets and drawn far-to-near. Typical labels are:

- `clear_depth_buckets`;
- `load_face_visible`;
- `face_far_depth`;
- `draw_depth_buckets`;
- `draw_bucket_wire_object` for selected wire paths.

Important runtime arrays include `bucket_head`, `bucket_used_list`, `face_next`, and an object/face owner where required. With `meshSourceSharing`, a bucket entry must retain instance identity in addition to the local face.

Do not replace painter order with source order. Cross-instance occlusion, Mode 5 outlines, and deterministic precedence depend on the global order.

### 8.6 Rasterization

The principal paths are:

- wire and hidden-wire: `draw_wire_*`, `plot_wire_point`, `plot_wire_horizontal`, `plot_wire_vertical_run`, `trace_edge_convex`;
- faces: `draw_loaded_face_*`, `draw_direct_face_*`, `build_loaded_face_bounds`;
- spans: `direct_fill_span_*`, `fill_bounds_solid_*`, `fill_bounds_pattern_*`;
- Mode 5 outline: `mode5_draw_loaded_polygon_outline` and related `mode5_*` routines.

The renderer contains both fast paths and fallbacks. A fast path is valid only when viewport, near-plane, and polygon-integrity conditions are already guaranteed. Boundary-crossing cases must retain the validated fallback.

## 9. GraphicsMode from the engine's point of view

| Mode | Main pipeline |
|---|---|
| 1 | Wireframe; may use precomputed edges and direct paths. |
| 2 | Hidden-wire; retains face classification, depth/masks, and draws visible edges. |
| 3 | Solid rendering with static shading and specialized fill/Ground optimizations. |
| 4 | Solid rendering with dynamic shading, XY-Q2 pipeline, and runtime materials. |
| 5 | Mode 4 pipeline plus an outline around the final post-clipping polygon. |

The mode number is not merely a runtime flag: it affects emitted code and buffer layout. To compare modes, generate separate build directories and diff ASM, maps, and labels.

## 10. VIC-II, bitmap, and materials

The ordinary renderer uses double-buffered multicolor bitmap mode, with a logical 160×100 image expanded to 320×200 physical pixels.

A typical `stable` build exposes:

- Screen RAM A near `$5C00`;
- bitmap A at `$6000-$7FFF`;
- runtime buffers starting at `$8000`, ending before Screen RAM B;
- Screen RAM B at `$8C00-$8FFF`;
- bitmap B at `$A000-$BFFF`;
- VIC-II Color RAM at `$D800-$DBE7`.

Actual addresses and use of these regions vary with layout, overlay, and feature set. The `* =` origins, `BITMAP_*`, `SCREEN_*`, and `RUNTIME_*` constants, and the map file for the specific build are authoritative.

Each multicolor bitmap cell uses:

| Pixel code | Color source |
|---|---|
| `00` | global background `$D021` |
| `01` | high nibble of Screen RAM |
| `10` | low nibble of Screen RAM |
| `11` | Color RAM |

Material ramps are represented as Dark/High/Highlight:

```text
screenByte = (Dark << 4) | High
colorRam   = Highlight
```

Reference data lives in `work/tools/c64_material_scales.generated.json`. When multiple faces request incompatible palettes in the same cell, the selected VIC-II policy applies; this is not a conventional color z-buffer.

## 11. Memory and zero page

### 11.1 Zero page

A full build may use `$02-$A5` intensively. Many symbols are overlapping aliases: one location may serve transformation, clipping, or rasterization at different times.

Common examples include:

- angles and trig values: `angx`, `angy`, `angz`, `sinxv`, `cosxv`, ...;
- pointers: `ptr0lo/hi`, `ptr1lo/hi`, `row0lo/hi`, `row1lo/hi`;
- raster state: `xcur`, `ycur`, `errlo/hi`, `leftval`, `rightval`;
- face state: `faceidx`, `loaded_face_vertex_count`, `face_ymin/max`;
- clipping: `clip_*`;
- shading: `shadeidx`, `sh_nx`, `sh_ny`, `sh_nz`.

Do not add a zero-page variable at an address that appears free in one build. Availability depends on configuration, and aliases may be valid only because lifetimes do not overlap. Add an explicit generator allocation, 64tass assertions, and tests across multiple profiles.

### 11.2 Runtime buffers

The runtime block is built from contiguous expressions beginning at `RUNTIME_BUFFER_BASE`. Depending on the build, it contains:

- `sx`, `sy`, and Q2 projections;
- `sz/szhi` depth;
- transformed coordinates;
- `projdone` flags;
- per-row `leftb/rightb` bounds;
- dirty ranges for both buffers;
- depth buckets and face lists;
- clipping buffers;
- sharing, Ground, and color-policy state.

`RUNTIME_AFTER_*` labels and `RUNTIME_BUFFER_END` form an allocation chain. A new feature must join this chain and remain below `RUNTIME_BUFFER_LIMIT`; it should not use an arbitrary fixed address.

### 11.3 `stable` and `high-basic-v2`

`stable` is preferred for light and medium builds. `high-basic-v2` segments code and data and may use RAM beneath the BASIC ROM for larger builds. The builder never switches automatically.

When code changes:

- assemble both layouts with representative scenes;
- read overlap diagnostics from the builder and 64tass;
- check the map and margins, not only total PRG size;
- remember that a segmented PRG can be physically large because it retains gaps.

## 12. Essential numeric formats

Normative definitions are in [WORLD-METRICS.md](WORLD-METRICS.md). Operationally:

- WU means world unit;
- TU means turn unit, with 256 TU per revolution;
- ST means simulation tick, with 50 ST/s;
- many positions and velocities use signed 16.8 fixed point or split components;
- scale and trigonometry often use Q6;
- XY-Q2 profiles preserve quarter-pixel fractions where enabled;
- mobile-camera routines may use 24-bit accumulators and differences.

The builder performs rounding, clamping, and domain checks before emitting bytes. Reimplementing a conversion directly in ASM without the same rules can make the scene, host tests, and runtime disagree.

## 13. Scene data in generated ASM

Near the end of generated source, expect tables such as:

- `object_mesh`;
- `object_pos_*`;
- `object_ang_*` and `object_angvel_*`;
- `object_scale`;
- face, vertex, material, and normal tables;
- `sintab` and projection/shading tables;
- optional timeline and sharing structures.

The builder can remove whole fields when values are constant or a feature is unused. There is no guaranteed stable binary ABI between builds. An external program that modifies runtime data must be assembled against the specific build or consume labels/maps generated for that build.

## 14. Three levels of change

### 14.1 Changing a scene without changing the engine

This is the preferred path for content, geometry, poses, materials, lights, and timelines:

1. copy the closest example;
2. edit the JSON;
3. build with explicit options;
4. verify the PRG in VICE;
5. keep the command and JSON together.

### 14.2 Temporary patch to generated ASM

Useful for testing an instruction or measuring a routine:

1. generate `3Dvibe64.asm`;
2. save its hash or a copy;
3. apply the patch;
4. reassemble manually with the same `-a -B` options;
5. compare behavior and cycles;
6. port the change into the builder if it must survive.

Do not run `build-3Dvibe64.ps1` again before porting the patch; it regenerates the ASM.

### 14.3 Permanent generator change

A permanent change normally requires:

1. identify the label in generated ASM;
2. search for the label in `work/build-3Dvibe64.ps1`;
3. identify the template, conditional block, or placeholder that emits it;
4. change the generator;
5. regenerate several configurations;
6. compare ASM and PRG;
7. run contracts and regressions;
8. update documentation, manifest, and hashes only during release preparation.

The builder mixes two languages. In PowerShell here-strings, distinguish:

- literal `@' ... '@` blocks, with no PowerShell expansion;
- expandable `@" ... "@` blocks, where `$` and interpolation are PowerShell syntax;
- 64tass `.if`, `.else`, `.endif`, and `.error`, evaluated by the assembler;
- PowerShell substitutions performed before 64tass runs.

A `$` in the wrong context can be consumed by the host language instead of the assembler.

## 15. Adding an assembly feature

To keep a feature consistent with the SDK architecture, verify every level:

1. **Public surface**: JSON field or CLI option when intended for users.
2. **Host validation**: types, ranges, incompatible combinations, and explicit errors.
3. **Renderer plan**: compile-time flag selecting when code is emitted.
4. **Data**: tables and buffers sized from scene content.
5. **Assembly**: routines, call sites, and entry/exit contracts.
6. **Memory**: zero page, runtime chain, code segments, and VIC-II areas.
7. **Timing**: PAL/NTSC, logical tick, and frame cost.
8. **Fallbacks**: scenes and clipping cases that cannot use the fast path.
9. **Tests**: positive case, rejected case, and unchanged-build regression.
10. **Documentation/release**: READMEs, guide, manifest, and checksums.

The project treats a public feature as promoted only when it exists at the builder surface, in generated ASM, and in linked runtime code.

## 16. Debugging with VICE

### 16.1 Preparation

Generate VICE-format labels and a map as described in section 5. Start the PRG in x64sc and open the integrated monitor. Exact commands can vary slightly by VICE version; use monitor `help` for local syntax.

Useful initial breakpoints include:

- `start` for initialization;
- `main_loop` for top-level control;
- `render_frame_begin` / `render_frame_end` for frame boundaries;
- `render_scene_renderer` for the rendering pipeline;
- `load_face_visible`, `face_visible`, or `draw_depth_buckets` for geometry and sorting;
- `project_vertex` or `explorer_transform_project_vertices` for projection;
- `mode5_draw_loaded_polygon_outline` for Mode 5.

### 16.2 Diagnostic method

For a geometry problem:

1. stop after transformation;
2. inspect camera-space coordinates and geometric depth;
3. inspect `projdone`, `sx/sy`, and Q2 coordinates;
4. verify near/Ground classification;
5. verify culling and bucket insertion;
6. only then enter the rasterizer.

For a graphics problem:

1. identify `drawbuf`;
2. inspect VIC-II bank and bitmap registers;
3. inspect Screen RAM and Color RAM for the cell;
4. check `fillbyte`, `shadeidx`, and active material;
5. verify dirty ranges and buffer swapping.

For a crash or memory corruption:

1. inspect the `.map`;
2. set watchpoints on adjacent ranges;
3. check face/vertex indices and counts;
4. verify that X/Y counters do not exceed byte-sized capacity;
5. reproduce with a minimal scene.

## 17. Profiling

For reliable comparisons:

- use the same 64tass version;
- fix `-VideoStandard pal` or `ntsc`;
- disable the FPS overlay unless it is under test;
- use the same scene, pose, and input sequence;
- measure the same `render_frame_begin`/`render_frame_end` interval;
- separate simulation cost from renderer cost;
- record builder hash, full command, and PRG hash.

Reducing instruction count in one routine can still make a frame slower if code crosses a page, long branches are introduced, or a fallback becomes more common.

## 18. Tests and regression contract

Run from the package root:

```powershell
python .\scripts\test_camera_angular_repeat.py
python .\scripts\test_camera_move_step.py
python .\scripts\test_mobile_yq2.py
python .\scripts\test_object_depth_domain.py
python .\scripts\test_world_metrics.py
python .\scripts\test_dev7_text_split.py
python .\scripts\test_release_contract.py
```

`test_release_contract.py` is the broadest check: it verifies package structure, builder identity, reference builds, and, when VICE is available, framebuffer regressions. It may create PRGs in temporary directories and remove them automatically.

During development, do not update expected hashes merely to make a test pass. First determine whether the visual change is intentional, reproducible, and documented. Manifest and reference-build hashes are updated during release preparation after the builder is frozen.

## 19. Recommended comparison strategy

Use separate `baseline` and `candidate` copies:

```text
baseline/
  work/3Dvibe64.asm
  work/3Dvibe64.prg
  work/build/*.map, *.labels, *.lst

candidate/
  work/3Dvibe64.asm
  work/3Dvibe64.prg
  work/build/*.map, *.labels, *.lst
```

Compare in this order:

1. builder messages and emitted contracts;
2. `..._ACTIVE` constants in the ASM preamble;
3. memory map;
4. the affected routine in the listing;
5. PRG size and hash;
6. framebuffer or behavior in VICE.

A whole-file ASM diff can be noisy because a scene change moves data and addresses. Keep the scene and all options identical.

## 20. Common mistakes

### Editing the wrong file

`work/3Dvibe64.asm` is generated. Permanent changes belong in `work/build-3Dvibe64.ps1`.

### Assuming a stable ABI

Labels, addresses, and even routine presence are build-dependent. Generate labels and maps together with each PRG.

### Using apparently free zero page

Aliases change by feature and lifetime. Add a controlled allocation, not a magic address.

### Confusing depth with projection index

The table bias is not geometric distance and must not enter culling or sorting.

### Removing a fallback

A fully internal face and a clipped face have different contracts. Test near crossings, viewport borders, camera-inside-mesh, and Ground crossings.

### Testing only one profile

A change can work in Mode 4/fixed/stable and break Mode 2, walkFull, or high-basic-v2. Use a minimum build matrix.

### Updating manifests and checksums immediately

During development, hash failures correctly indicate that the package changed. Regenerate release metadata only when the release is ready.

## 21. Minimum build matrix for renderer changes

| Changed area | Suggested minimum builds |
|---|---|
| Projection/camera | Mode 4 fixed + Mode 4 walkFull; normal and small viewports |
| Culling/clipping | `default`, `late`, `clip`; one near-crossing scene |
| Wire | Mode 1 and Mode 2 with `wire-two-color-multimaterial.json` |
| Fill/materials | Mode 3 static, Mode 4 dynamic, Mode 5 outline |
| Ground | Mode 2 plane and Mode 3-5 plane; roll 0/32/64/224 |
| Memory | `stable` and at least one complex `high-basic-v2` build |
| Sharing | Mode 4 or 5 with `shared-instances-timeline-static-light.json` |

Extend the matrix when a feature touches IRQs, overlay, timing, or VIC-II color policy.

## 22. Possible future modularization

The assembly can be extracted gradually into conventional source files, but copying all generated ASM is not a good starting point. A safe process is:

1. choose a routine with limited scene dependencies;
2. define inputs, outputs, clobbered registers, and scratch state;
3. move it into a 64tass `.inc` parameterized by symbols;
4. include it from generated source;
5. verify PRG equivalence or an intentional regression;
6. repeat for coherent subsystems.

Arithmetic utilities or stable VIC-II routines are good initial candidates. Transformation, clipping, and fill are more dependent on compile-time flags and require greater care.

Until the project officially adopts external modules, the PowerShell builder remains authoritative and local include files are outside the public contract.

## 23. Pre-delivery checklist

- The complete build command is recorded.
- The reproduction scene is committed or described as a temporary fixture.
- ASM was regenerated from the modified builder.
- Labels, listing, and map match the tested PRG.
- No unintended permanent build artifacts were added to the distribution.
- Zero page and runtime buffers do not overlap.
- Relevant `stable` and `high-basic-v2` builds assemble correctly.
- Clipping fallbacks remain reachable and valid.
- Relevant host-side tests pass.
- Relevant VICE regressions pass, or a new signature is justified.
- Italian and English documentation describe the same API.
- Version, package manifest, and checksums will be updated together during release preparation.

## 24. Recommended reading path

For a professional first approach to the engine:

1. read [QUICKSTART.md](QUICKSTART.md) and [README.en.md](README.en.md);
2. read the numeric sections of [WORLD-METRICS.md](WORLD-METRICS.md);
3. build `basic-solid-reference.json` in Mode 4/fixed;
4. generate `.labels`, `.map`, and `.lst`;
5. trace `start -> main_loop -> render_frame_*`;
6. follow one vertex into `project_vertex`;
7. follow one face from `load_face_visible` through `draw_depth_buckets` and fill;
8. repeat with `mode4-walkfull-reference.json`;
9. repeat with a `clip` scene and a Mode 5 build;
10. only then begin a permanent builder change.

With this workflow, 3Dvibe64 becomes readable as a specialized assembly engine: PowerShell is the configuration compiler, JSON is the program description, and `3Dvibe64.asm` is the concrete assembly unit to analyze for that build.
