# Quick start / Guida rapida

3Dvibe64 1.0 is a source SDK. It intentionally contains no precompiled PRG:
compile a JSON scene locally with the PowerShell builder.

## Build / Compilazione

From a disposable working copy of the package root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\work\build-3Dvibe64.ps1 `
  -SceneFile .\examples\mode4-walkfull-reference.json `
  -GraphicsMode 4 -CameraMode walkFull -CameraViewport normal `
  -Quality balanced -Projection table -MemoryLayout stable -SkipCmdUpdate
```

The local build product is `work/3Dvibe64.prg`. `normal` is 160×100; pass
`-CameraViewport small` for 128×80.  Use a separate copy when you want the source
SDK itself to remain free of generated artifacts.

Il pacchetto 3Dvibe64 1.0 contiene solo sorgenti: compilare localmente una scena JSON
con il builder PowerShell. Il comando precedente genera `work/3Dvibe64.prg`.
`normal` misura 160×100; `small` misura 128×80. Per mantenere pulito l'SDK, eseguire
le build in una copia di lavoro separata.

See [examples/README.md](examples/README.md) for all public reference scenes and
their complete commands.  The localized README files document the renderer, JSON
schema, camera controls, limits, and public command-line options.
