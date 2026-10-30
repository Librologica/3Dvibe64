# Reusable rendering and data — 1.15.1

> Stable1.15.1 source SDK published on GitHub. [Status and support](RELEASE-STATUS.en.md).

Stable1.15.1 retains the optional API contracts; renderer source is promoted unchanged from agentic17. The current package is local; previous frozen releases and demos are preserved. [Base options](EXACT-RENDER.en.md). The default remains `-LegacyPlusOptimizations none`. New options retain the Mode4 legacy-plus, walkLite, normal160×100, high-basic-v2, NoFpsOverlay, Q4 near8/poly clipping profile. Geometry Q4, coefficients Q10, pixels and palette are not reduced. Every combination consumes real64KB RAM; a combination may fail even when its individual options fit.

## Option selection

`all` now expands to `arithmetic,edges,spans,outcodes,convex,integer-edges`. The new `integer-edges` extends integer polygon edge tracing: carry preserves the ninth addition bit. The original path remains for traces shared with wire rendering. Fractional Q4/Q2 edges keep their complete native paths. No precision reduction.

`wire` and `stream` are explicit caller APIs, excluded from `all`. Example: `-LegacyPlusOptimizations outcodes,wire,stream`. `all,wire` is not a valid combination; list individual option names. Frozen lighting remains a separate appearance option, also excluded from `all`.

## Native-material wire lines

`er_wire_line` takes `ex0,ey0,ex1,ey1`, already clipped to X0..159 and Y0..99. Set `drawbuf`, `fillbyte`, `material_screen_cur`, `material_color_cur` using the native renderer contract. Carry set means completion. Carry clear means invalid coordinates and no video writes; use native clipping first for lines crossing a screen boundary. This kernel does not perform3D clipping.

The original connected coverage, including row bridges, is retained. Horizontal runs use byte writes and steep runs use column grouping; carry preserves the8bit error sum. Masks, both physical rows, both buffers, material updates and dirty spans remain. No scene-wide fixed palette is assumed. The optional VIC cell-ownership policy is currently rejected: it needs a separately qualified adapter.

The API clobbers native global scratch, A/X/Y/flags and is not reentrant: call from the main drawing pass, without a concurrent IRQ caller. It does not change solid rasterization or automatically replace every engine line. `install(..., reference=True)` only generates the scalar qualification reference and is never selected by the public CLI.

## Runtime-generated vertices

`stream` requires `outcodes`, at most255 resident vertices and rejects shared-source instances. No buffer capacity is added: callers own an existing slot interval during their drawing pass and must exclude concurrent consumers.

1. Call `er_stream_begin` with X=first slot and Y=nonzero count. Carry set means the interval fits `VERT_COUNT`; its slots are invalidated (`projdone=0`, near outcode) before production. Failure deactivates the whole pass.
2. Set signed16 camera-space Q4 coordinates in `er_stream_x`, `er_stream_y`, `er_stream_z`; call `er_stream_project` with A=slot. Carry set means completion; `projdone=0` still requires native near clipping. Invalid ownership or an inactive pass returns carry clear without writing vertex arrays.
3. Results live in native clipping-Q4, projected-coordinate, depth, validity and outcode arrays. The caller supplies faces and native painter order. No connectivity, material or sorting policy is invented.
4. Call `er_stream_end_pass`. A subsequent owner must regenerate its slots before reading them. Begin/produce/end must be repeated for each new view; cross-view cache validity is not promised.

The generated API reuses the emitted native producer body, including rounding, projection and classification. Triangles can consume resident vertices without copying a full vertex record for every face. World-to-camera transformation remains the caller's responsibility. Native scratch and A/X/Y/flags are clobbered; main-pass calls only, no additional zero-page ownership.

## Lossless compact keyframes

`work/compact_keyframes.py` accepts a JSON list of1..256 signed16 integer samples. Coordinates, angles and animation channels retain every original sample exactly. The encoder factors out only already-zero low bits and packs offsets from the minimum using the necessary width.

```powershell
python -B work/compact_keyframes.py ../project/keys.json ../project/keys.asm --prefix camera_x
```

Adjacent JSON records count, width, shift, minimum and data bytes. Emitted `camera_x_read` accepts X=index and returns carry set, A=low/Y=high of the original signed16 value. Invalid index: carry clear, A=Y=0. Private scratch and self-modifying absolute loads require writable RAM and nonconcurrent calls outside IRQ. No zero page is claimed. Use a unique prefix per channel.

This optional data module does not promise higher FPS. Application interpolation stays unchanged; exact increments can be reconstructed at knots. Account for decoder, scratch, packed data and padding together: short or widely varying tracks may use more RAM than their original table. No automatic replacement of project tables is performed.

## Transfer boundaries

Model-specific component order, hidden shuttle faces, camera and dynamics, sparser grid, FOV, procedural course and alternate scanlines are not moved into the renderer core. These change content, behavior or graphics and remain in the demo project. Rigid model rotation requires separate qualification before becoming a new object-transform API.

[Current qualification](QUALIFICATION-1.15.1.en.md) separates native FPS, pixel identity and CPU callbacks. Wire benchmark results are not attributed to the shuttle or to the stream module alone.
