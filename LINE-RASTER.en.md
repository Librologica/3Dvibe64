# Hybrid lines: Q8 geometry, additive integer raster

`-Precision q8 -LineRaster hybrid` is supported in GraphicsMode 1, 2 and 5. It retains the Q8 camera, mesh transforms, endpoint projection and near/screen clipping. Only the final clipped line raster changes. `precise` remains the Q8 line default; geometry `legacy` remains the engine default. Hybrid is not a simplified projection or a change to solid-fill shading.

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -Precision q8 -GraphicsMode 2 -SceneFile examples/q8/two-objects-mode2.json -Q8Camera auto -LineRaster hybrid -OutputDirectory ../hybrid-build
```

The bounded clipped Q2 endpoints are rounded to integer pixels, nearest with positive half ties. The canonical ascending major axis produces one connected Bresenham sample per major position. The unsigned 8-bit error uses carry for its ninth bit; maximum major extent is 159. No multiply, division or self-modifying code in the walker. Reversing endpoints produces the same pixel sequence. IRQ does not own its scratch.

Mode 1 applies it to visible edges; Mode 2 uses the same walker for edge display and face masks. Mode 5 keeps its Q8 polygon fill and applies the hybrid only to the actual clipped polygon perimeter, including screen/near caps. Existing bitmap writers, materials and palettes are unchanged.

Pixel-phase differences from the previous subpixel-aware raster are intentional; bitmap identity is not claimed. Geometry/clipping identity and the integer line contract must be tested separately. The independent closed-form oracle in `test_line_hybrid.py` checks both endpoint orders, degenerates, all octants and fractional endpoints on the emitted 6510 code. Native performance is scene-specific, not a universal speedup promise. Existing Q8 profile and memory limits remain; Q8 is recommended above 20 MHz, not selected automatically.
