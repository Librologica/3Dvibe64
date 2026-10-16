# Input esterni — 1.12.0

Non sono distribuiti demo, esempi, scene sorgenti, disegni, musica, percorsi
camera, launcher di demo, programmi compilati o catture native. Lo ZIP non
contiene `examples/` né `validation/`. I test possono creare piccole fixture
matematiche in cartelle temporanee: non sono progetti dimostrativi. Template
assembly dei renderer e generatori di primitive sono codice dell'engine.
I template del backend Mode8 mantengono i loro contratti delimitati e vengono
compilati solo con una mappa esplicita dell'utilizzatore; non sono nuove demo.

## Scene ordinarie

Fornire una scena poligonale schema1 a `-SceneFile`, oppure una mappa a Mode8.
I comandi usano **file esterni dell'utilizzatore**, non modelli allegati.
Eseguirli dalla radice SDK, scegliendo un output nuovo e fuori dai sorgenti.

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -SceneFile ../my-inputs/scene.json -GraphicsMode 6 -MemoryLayout high-basic-v2 -OutputDirectory ../my-build
python -B work/q8/build.py --scene ../my-inputs/textured-scene.json --out ../my-q8-build --mode 7 --camera auto --texture-precision perspective --texture-quality standard --engine-experiments inside-planes,bounded-divide,packed-samples
```

SceneFile omesso produce un errore esplicito, senza generare scene predefinite.
Le texture esterne si risolvono rispetto alla scena. Installare separatamente
PowerShell7, Python, Pillow quando richiesto e64tass; `TASS64_EXE` seleziona64tass.

## Adapter gameplay

`--project-source` / `-ProjectSource` è obbligatorio. La cartella esterna deve
fornire `examples/gameplay/<profile>.json`, `extensions/gameplay/common`,
`extensions/gameplay/billboards` ed `extensions/gameplay/profiles/<profile>`
per tutti i profili nella catena di ereditarietà. Fornisce scena/UI/asset,
binding dei materiali, script di build, camera e logica applicativa. L'SDK
non genera questi input. Aggiornare `engineVersion` del preset a1.12.0 e
riqualificare l'hash. [GAMEPLAY](GAMEPLAY.it.md) descrive l'ABI dei13 profili.

## Input di regressione

`python -B scripts/run_release_tests.py` esegue i test autonomi di pacchetto,
matematica e configurazioni gameplay senza file di esempio. Le regressioni
storiche delle scene richiedono anche una cartella esterna attendibile con
`examples/` e `validation/` compatibili con l'archivio1.11.0:

```powershell
python -B scripts/run_release_tests.py --test-inputs ../my-regression-inputs test_mode7.py test_precision_q8.py
```

Gli input entrano solo nelle copie QA temporanee, mai nel pacchetto sorgente.
Non usare `-O`, `-OO` o PYTHONOPTIMIZE. Build e prove native sono separate in
`reports/` e `qualification/` della cartella privata di qualificazione, fuori dal repository pubblico
e dallo ZIP sorgenti. Non viene distribuito un archivio degli input esterni.
