# Quick start / Guida rapida — 1.15.0

> Stable1.15.0 source SDK prepared locally; not published online. [Status and support](RELEASE-STATUS.en.md).

## English

Install Python3, PowerShell7 and64tass; set `TASS64_EXE` when it is not on PATH.
Pillow is needed for PNG import; py65 is used by optional arithmetic tests.
Extract the source ZIP, provide your own external scene/assets, and choose a
new sibling SDK working copy for ordinary legacy. Ordinary legacy/plus writes
into its own `work/` and rejects `-OutputDirectory`; Q8/Normalized16/Mode8
accept that option for their new external output directories. No examples, demos or tools are bundled.

```powershell
Copy-Item -LiteralPath . -Destination ../my-build-sdk -Recurse
pwsh -NoProfile -File ../my-build-sdk/work/build-3Dvibe64.ps1 -SceneFile ../my-inputs/scene.json -GraphicsMode 6 -MemoryLayout high-basic-v2
python -B scripts/run_release_tests.py
```

The scene must declare a compatible graphicsMode/camera. The legacy-plus command
and required Mode1–7 profile options are in [LEGACY-PLUS.en.md](LEGACY-PLUS.en.md).
Legacy stays default; plus, Q8 and experimental Normalized16 are explicit.
Do not use Python -O/-OO or PYTHONOPTIMIZE for qualification.

## Italiano

Installare Python3, PowerShell7 e64tass; impostare `TASS64_EXE` se non è nel PATH.
Pillow serve per importare PNG; py65 per i test aritmetici opzionali. Estrarre
lo ZIP sorgenti, fornire scena/asset esterni e scegliere un output nuovo fuori
dall'SDK. Per legacy/plus ordinario copiare prima tutto l'SDK: gli output
sono nel `work/` della copia e `-OutputDirectory` è rifiutato. Q8, Normalized16
e Mode8 accettano quel parametro. Nessun esempio, demo o strumento eseguibile è incluso.

I comandi sopra richiedono graphicsMode/camera compatibili nella scena. Comando
legacy-plus e opzioni obbligatorie del profilo Mode1–7 sono in [LEGACY-PLUS.it.md](LEGACY-PLUS.it.md).
Legacy resta default; plus, Q8 e Normalized16 sperimentale sono espliciti.
Non usare -O/-OO/PYTHONOPTIMIZE per la qualifica.

[Manual EN](README.en.md) · [Manuale IT](README.it.md) · [All docs / Indice](DOCS.md)
[External inputs EN](EXTERNAL-INPUTS.en.md) · [Input esterni IT](EXTERNAL-INPUTS.it.md)
[Tests / Test](TESTING.md)

## Exact Mode4 options / Opzioni Mode4 esatte — 1.15.0

Use a fresh complete SDK working copy and a compatible external Mode4 scene. / Usare una copia SDK completa nuova e una scena Mode4 esterna compatibile.

```powershell
pwsh -NoProfile -File ../my-build-sdk/work/build-3Dvibe64.ps1 -SceneFile ../my-inputs/scene.json -Precision legacy-plus -GraphicsMode 4 -CameraMode walkLite -CameraViewport normal -MemoryLayout high-basic-v2 -NoFpsOverlay -NoCameraRuntimeControls -Quality fast -Projection extended-table -VideoStandard pal -ExplorerNearCrossMode poly -ExplorerClipMode near -LegacyPlusOptimizations all
```

Default is none. `all` excludes wire,stream,frozen-lighting. For explicit APIs use individual names,for example outcodes,wire,stream; application ASM calls are required. Compact keyframes are a separate generator. / Default none; le API richiedono chiamate ASM esplicite e il codec è separato.

[Exact options EN](EXACT-RENDER.en.md) · [Opzioni IT](EXACT-RENDER.it.md) · [API EN](REUSABLE-RENDER.en.md) · [API IT](REUSABLE-RENDER.it.md).
