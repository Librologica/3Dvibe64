# Quick start / Guida rapida — 1.13.0

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
and required Mode2 options are in [LEGACY-PLUS.en.md](LEGACY-PLUS.en.md).
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
legacy-plus e opzioni Mode2 obbligatorie sono in [LEGACY-PLUS.it.md](LEGACY-PLUS.it.md).
Legacy resta default; plus, Q8 e Normalized16 sperimentale sono espliciti.
Non usare -O/-OO/PYTHONOPTIMIZE per la qualifica.

[Manual EN](README.en.md) · [Manuale IT](README.it.md) · [All docs / Indice](DOCS.md)
[External inputs EN](EXTERNAL-INPUTS.en.md) · [Input esterni IT](EXTERNAL-INPUTS.it.md)
[Tests / Test](TESTING.md)
