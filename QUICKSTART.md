# Quick start / Guida rapida

3Dvibe64 1.2.0 is a source SDK. It intentionally contains no precompiled PRG:
compile a JSON scene locally with the PowerShell builder.

## Build / Compilazione

From a disposable working copy of the package root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\work\build-3Dvibe64.ps1 `
  -SceneFile .\examples\mode4-walkfull-reference.json `
  -GraphicsMode 4 -CameraMode walkFull -CameraViewport normal `
  -Quality balanced -Projection table -MemoryLayout stable -SkipCmdUpdate
```

The local build product is `work/3Dvibe64.prg`. With the default Generic Text/FPS
split, `normal` has a 160×88 3D body below three character rows and `small` has a
128×80 body. Add `-HeaderText "SCRITTA DI ESEMPIO" -FpsOverlayOnStart` to show a
header at startup. Pass `-NoFpsOverlay` for the legacy 160×100 normal viewport.
At runtime, `F` hides or restores the complete Generic Text/FPS header; it does not
toggle the FPS digits independently.
Use a separate copy when you want the source SDK itself to remain free of generated
artifacts.

For Gouraud rendering, build a Mode 6 reference with the required segmented layout:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\work\build-3Dvibe64.ps1 `
  -SceneFile .\examples\mode6-gouraud-torus.json `
  -GraphicsMode 6 -CameraMode walkFull -CameraViewport normal `
  -Quality balanced -Projection table -MemoryLayout high-basic-v2 -SkipCmdUpdate
```

Il pacchetto 3Dvibe64 1.2.0 contiene solo sorgenti: compilare localmente una scena JSON
con il builder PowerShell. Il comando precedente genera `work/3Dvibe64.prg`.
Con lo split Generic Text/FPS predefinito, `normal` offre un body 3D 160×88 sotto
tre righe di testo e `small` un body 128×80. Usare
`-HeaderText "SCRITTA DI ESEMPIO" -FpsOverlayOnStart` per mostrare l’header
dall’avvio; `-NoFpsOverlay` ripristina la viewport normal storica 160×100.
Durante l’esecuzione, `F` nasconde o ripristina l’intero header Generic Text/FPS,
non le sole cifre FPS. Per mantenere pulito l'SDK, eseguire le build in una copia
di lavoro separata.

See [examples/README.md](examples/README.md) for all public reference scenes and
their complete commands.  The localized README files document the renderer, JSON
schema, camera controls, limits, and public command-line options.

Mode 6 is ordered-dithered Gouraud for VIC-II and uses the validated Gate 5 engine.
`gouraud.creaseAngle` defaults to 60 degrees; use 180 on the coarse torus to smooth
curved boundaries, or compare the hard/smooth cube examples. The silhouette does
not change. The runtime limit is 255 shade vertices. Materials provide
Dark/High/Highlight; reflectivity is satin/gloss/reflective/mirror.
See [TESTING.md](TESTING.md) to verify a clean SDK without generating files inside it.
