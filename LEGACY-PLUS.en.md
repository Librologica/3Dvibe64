# Legacy-plus — 1.15.0

> Published stable1.15.0 source SDK. [Status and support](RELEASE-STATUS.en.md).

`-Precision legacy-plus` is the explicit intermediate renderer for Mode1–7. It combines the legacy Q6 object matrix with Q4 camera geometry, Q10 camera coefficients and 4096 yaw/pitch phases. Legacy stays default. The compatibility `-LegacyStability rotation` remains Mode2 only. Mode8 and Normalized16 keep separate contracts. This stable1.15.0 distribution is published on GitHub; RELEASE.json records its publication state.

## Build and configuration

Copy the entire source SDK to a fresh working directory before building ordinary legacy/plus. Supply an external scene declaring the same graphicsMode and walkLite camera. Python3, PowerShell7,64tass and optional Pillow are external dependencies; `TASS64_EXE` selects the assembler.

```powershell
Copy-Item -LiteralPath ./repository -Destination ./my-build-sdk -Recurse
pwsh -NoProfile -File ./my-build-sdk/work/build-3Dvibe64.ps1 -SceneFile ../my-inputs/scene7.json -Precision legacy-plus -GraphicsMode 7 -TexturePrecision perspective -CameraMode walkLite -CameraViewport normal -MemoryLayout high-basic-v2 -Quality fast -Projection extended-table -VideoStandard pal -FramePresentation safe -NoFpsOverlay -ExplorerClipMode near -ExplorerNearCrossMode poly -SkipCmdUpdate
```

If running inside the SDK, copy `.` instead of `./repository`. Use `-TexturePrecision affine` for affine Mode7; omit this option in Modes1–6. The builder writes `work/3Dvibe64.asm`, `work/3Dvibe64.prg` and a PRG copy in `work/build/`; placement metadata accompanies solid builds. Full diagnostic labels/map require an explicit64tass invocation (`--vice-labels-numeric --labels=... --map=...`). Ordinary legacy/plus reject `-OutputDirectory`; Q8/Normalized16/Mode8 have their own external-output adapters.

Supported plus configuration: **walkLite, normal160×100, high-basic-v2, -NoFpsOverlay**; near8 polygon and screen clipping, `Mode4NearProfile default`. Near/poly defaults are selected by plus; conflicting clip profiles are rejected. No roll, small viewport, text/FPS split or Ground plane clipping. Qualification uses no Ground; explicit floor meshes use ordinary polygon clipping. Horizon/Ground combinations have no new qualification. Area/span0 are explicit benchmark settings, not changed quality defaults. Match them with `-MinFaceAreaOverride 0 -ScreenMinSpanOverride 0` when reproducing the comparisons.

| Mode | Plus rendering |
|---|---|
|1|Source wire edges, including segment near/screen crossings|
|2|Hidden wire, original source-edge flags retained|
|3|Static solid|
|4|Dynamic flat, inherited Q2 screen-Y contract|
|5|Dynamic flat + outlines, inherited Q2 screen-Y contract|
|6|Gouraud, shade interpolation follows the same near/screen parameter|
|7|16×16 VIC-II texture, affine or perspective; none/flat/Gouraud A/B/C|

## Camera, clipping and memory

The public input ABI uses signed24 positions with8 fraction bits, engine-y-up axes; JSON uses world-z-up. The low byte is the fraction, not a Q8 geometry selector. Internal plus geometry is Q4. Yaw/pitch use byte angle plus the upper4 fraction bits (4096 phases); write all fields before `render_frame_begin`. Existing keyboard byte-angle steps and Q6 object rotations remain. See [camera ABI](CAMERA-ROTATION.en.md).

Relative camera coordinates must remain in **[-1024,1024)WU per axis**; check `legacy_camera_fault`. A separate6-byte/vertex Q4 cache preserves legacy integer buffers. Near8WU is128Q4. Raw near attributes and geometry share the same16-bit interpolation weight and signed nearest rounding. Screen clipping retains Q4 until raster conversion. Modes4–6 keep native Q2 screen-Y; projective Mode7 uses the shared Q2 coverage rules over plus endpoints. No extra visible resolution or colors are introduced.

Original wire-edge ownership survives clipping; screen bounds reset per face. Offsets at/above$3a00 retain the wide fallback. Mode1/2 can use the3072-byte camera product LUT when it fits. Modes3–7 use exact serial camera products because that LUT would overlap live solid code. Helpers are placed in measured free RAM with assembly guards; Mode7 Gouraud can use only the verified tail after `RUNTIME_BUFFER_COLOR_POLICY_END+32`, below$9000, when the rotation LUT/FPS overlay are disabled. Scene capacity follows the actual map, not a universal vertex count.

## Mode7 perspective

Source UV remains Q4.4. After raw-UV near clipping, compute unsigned16 `W=floor(524288/Z_Q4)`, `UW=floor(U_Q4.4*W/128)`, and VW likewise. Screen clipping transports UW/VW/W with the geometry weight. Quotient/remainder edge and span DDAs sample `floor(carrier*128/W)`. Gouraud Q retains its screen-space shading DDA. Half-open zero-width internal spans write no pixels; closed viewport caps retain their boundary coverage.

Camera-forward depth must stay **8–256WU inclusive** after near clipping. `ps_fault` is sticky: invalid depth/denominator stops publication with a red border. There is no affine fallback. Finite Q4/carrier rounding and nearest sampling remain. `TextureQuality standard`, LOD off; fast/LOD options remain Q8-only. LP perspective reuses generic host allocation and texture DDA/sampler code, with private symbols; it links no Q8 geometry transform, projection or clipping backend. Texture carriers are not Q8 geometry.

## Qualification

[Native comparison and limitations](QUALIFICATION-1.14.0.en.md) · [machine-readable evidence](QUALIFICATION-1.14.0.json) · [testing](TESTING.md). The final delivered builds must match the measured PRG hashes before reusing their FPS. PAL Turbo6510×64, safe, silent; complete routes after warm-up. No new NTSC or physical-hardware claim. The original1.13.0 Mode2 report remains [historical](QUALIFICATION-1.13.0.en.md), not a measurement of other scenes.
