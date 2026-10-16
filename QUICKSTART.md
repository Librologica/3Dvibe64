# Quick start / Guida rapida — 1.12.0

1. Install Python, PowerShell7 and64tass; install Pillow for PNG and py65 for tests.
2. Extract source ZIP. No demos/examples are included: supply an external scene.
3. Set TASS64_EXE; use a new output directory outside the SDK.

1. Installare Python,PowerShell7 e64tass; Pillow per PNG,py65 per test.
2. Estrarre lo ZIP sorgenti. Nessuna demo/esempio incluso: fornire una scena esterna.
3. Configurare TASS64_EXE e usare un output nuovo fuori dall'SDK.

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -SceneFile ../my-inputs/scene.json -GraphicsMode 6 -MemoryLayout high-basic-v2 -OutputDirectory ../my-build
python -B scripts/run_release_tests.py
```

Legacy/default quality unchanged; Q8 is explicit. / Default legacy/qualità invariati; Q8 esplicito.

[English manual](README.en.md) · [Manuale italiano](README.it.md) ·
[External inputs EN](EXTERNAL-INPUTS.en.md) · [Input esterni IT](EXTERNAL-INPUTS.it.md) ·
[Optimizations EN](RENDER-OPTIMIZATIONS.en.md) · [Ottimizzazioni IT](RENDER-OPTIMIZATIONS.it.md)
