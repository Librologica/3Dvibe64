# GraphicsMode 8 — 2.5D

3Dvibe64 1.4.0 adds an independent map renderer to the source SDK. For making environments, start with [Building Mode 8 maps](MAPS-2.5D.en.md). The supported subset is intentionally conservative: three complete templates, property validation, fixed camera starts and restricted ramps/apertures. No mesh conversion or simultaneous polygon/2.5D composition is provided.

## Public build

Minimum dependencies: PowerShell, Python 3.10+ standard library, and 64tass. Qualified toolchain: Python 3.13.14, PowerShell 7.6.5 and 64tass 1.60.3243. Put tools on PATH or set `PYTHON_EXE` and `TASS64_EXE`; `TASS64_PATH` also accepts an assembler directory. VICE, Pillow and py65 are **not** build dependencies.

From the SDK root:

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile examples/mode8/perimeter.json -Mode8Run interactive -OutputDirectory ../perimeter-reference-build
```

The builder prints the selected backend and reason. It dispatches before any polygon parser. Outputs include `3Dvibe64.prg`, readable `3Dvibe64.asm`, labels, listing, assembler log, input scene and a build/memory summary. Use `-ValidateOnly` to validate without assembling or creating an output directory.

| Option | Mode 8 contract |
|---|---|
| `-GraphicsMode 8` | Required integer-valued mode selection; never 2.5 |
| `-SceneFile` | Required explicit Mode 8 JSON |
| `-Mode8Run interactive/auto` | Defaults interactive; auto follows the cyclic route |
| `-OutputDirectory` | New empty external directory; default `3Dvibe64-output/mode8` beside the SDK |
| `-ValidateOnly` | Full map/route validation; no output or assembler needed |
| `-VideoStandard auto` | Runtime PAL/NTSC detection; explicit pal/ntsc rejected |
| All other polygon options | Rejected when explicitly requested; their legacy defaults do not affect Mode 8 |

This includes `CameraMode`, `CameraViewport`, `Quality`, `MemoryLayout`, `HeaderText`, lighting/material switches and `SkipCmdUpdate`: they are not Mode 8 controls. The three new options are rejected on Modes 1–7. Existing legacy commands/defaults and reference PRG hashes remain unchanged.

## Renderer and source organization

`work/mode8/build.py` validates explicit geometry and instantiates qualified source templates in `work/mode8/asm`. These ASM files are **intentional sources**, not a dependency on an old output directory. Automatic and interactive layouts remain separate to avoid relocating qualified runtime instructions. Original-map byte comparison isolates only the requested removal and UI changes; geometry/raster code and addresses remain unchanged.

Selection is by content, not name: ramps or multiple free-cell floor values choose the multi-level heightfield; otherwise the full monolevel contract is validated, including its upper-volume restrictions. There is no silent fallback. The two different runtime implementations are not unified.

Common pipeline:

1. IRQ accumulates logical ticks and updates the textual interface.
2. Foreground consumes pending ticks: input, simulation, collisions and automatic pursuit.
3. Latch one camera pose for the entire new image.
4. DDA determines surfaces; adaptive refinement resolves discontinuities.
5. Project profiles, clip visible intervals and fill multicolor bitmap bands.
6. Mark the inactive buffer complete; IRQ publishes it at a safe boundary.

PAL uses the video tick; NTSC applies the existing 5/6 cadence, approximately 50 logical ticks/s. This is **not a continuously rendered 50 FPS view**. The foreground does not change the latched camera halfway through a frame. Long rendering delays remain visible latency even though average motion speed is tick-based. No artificial FPS cap or partial/alternating-column frame counting is used.

Monolevel: 32 main rays, owner/plane-aware endpoints and additional fine samples where needed. The aperture path continues through the qualified upper volume in the same traversal. Multi-level: 33 boundary rays for 32 bitmap groups; differing event paths trigger four fine rays. Ordered events clip the remaining visible vertical interval front-to-back. Up to 32 cached profiles, lazy 16-column blocks and exact arithmetic specializations remain active.

There are no triangle fills, mesh transforms, vertex normals, Gouraud, active wall UV sampling or dynamic light in this renderer. Wall pigments depend on orientation; the ceiling is a screen-anchored stipple. Historical internal names `TEXTURED`, `strip` and `depth` are retained where renaming would obscure comparison: they do not advertise current UV textures or a complete compositing z-buffer. `select_strips` now prepares geometric bounds/projections. Old comments about the character renderer are not the current display specification.

## Video and memory

- Bitmap multicolor VIC-II, **128×144 logical pixels**, each 2×1 physical pixels.
- 256×144 physical viewport; 32×18 bitmap cells; **4,608 active bytes per buffer**.
- Bitmap bases `$6000/$E000`; active origins `$6660/$E660`.
- Screen RAM `$4000/$CC00`; separate text font `$5800/$D800`; three-row UI.
- CPU/VIC banking uses `$01`, `$DD00`, `$D018` and the qualified PAL/NTSC split handlers.
- Clear/initialization and comparisons include the appropriate margins; full body comparison is 7,040 bytes, not the per-frame active clear size.
- Source templates retain layout guards, sprite-pointer guards and private foreground SMC. IRQ must not reuse foreground scratch. The runtime is not reentrant.
- Multi profile cache: 4,096 bytes; coefficient/state: 448 bytes; fine buffer: 144 active bytes, 256 reserved.
- Original automatic low-code free space: 157/140/76 bytes for perimeter/apertures/two-levels. Multi helper code is 192 bytes at `$5500`. PRG file size includes reserved gaps; it is not a RAM-used metric.

See [memory map](MODE8-MEMORY.md) and each build's `build.json`. Additional scene data must fit existing capacities. There is no relocation, automatic resolution reduction or precision downgrade to force acceptance. Stock 64 KB C64, documented 6510 instructions, no REU or acceleration required.

## Controls, limits and qualification

Interactive: W/S movement, A/D rotation. Automatic: the complete validated cyclic itinerary. Both start at the same template pose. UI and FPS count complete images. No public palette, FOV, viewport or arbitrary initial-camera override in this first contract.

Static apertures only; fixed supported ramp formulas; no room-over-room, arbitrary steps, PVS, advanced portal traversal, wall UV texture mapping, floor textures, dynamic lighting or 3D sprites. Modes 1–7 remain distinct polygon-renderer builds.

[TESTING.md](TESTING.md) separates 13 legacy test scripts, the new public map tests, instruction/oracle comparisons and native runs. [Release notes](RELEASE-NOTES-1.4.0.md) contain final measured FPS, p95 and worst intervals. CPU-only sampling is not converted to FPS. Hardware execution is **not tested**; qualification is stock x64sc PAL/NTSC. Accelerated or other machine results are not substitutes.

For a hardware check: transfer the appropriate interactive PRG to a stock PAL/NTSC C64, load/run it, traverse the scene including both ramp joins, inspect split stability and buffer presentation, then run its automatic counterpart for a full loop. Record machine model, video standard, loader and observed faults. Do not claim a hardware PASS without performing and recording this test.

## Optional analysis

`scripts/analyze_mode8.py` uses py65 and Pillow to produce an external instruction-cost atlas; `scripts/qualify_mode8.py` uses `VICE_X64SC` or x64sc on PATH for native captures. Both write outside the SDK. Neither instruments the distributed runtime. Instructions and coverage limits are in [the map guide](MAPS-2.5D.en.md#7-optional-cost-atlas).

Historical note: the research began with a low-resolution character-based compositor and tested other geometric/rendering approaches. Those archives are not part of this SDK. The promoted path is bitmap with separate monolevel and multi-level implementations; no old performance target is reintroduced as a release gate.
