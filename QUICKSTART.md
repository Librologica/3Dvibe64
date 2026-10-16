# Quick start / Guida rapida — 1.11.0

[English](#english) · [Italiano](#italiano) · [Documentation / Documentazione](DOCS.md)

## English

This is the official local source release. Online publication is deferred.
No precompiled programs, demo archives, video or music are supplied. Keep an
untouched source copy and use new build directories outside the checkout.

### 1. Prepare the tools

Verified host: Windows, PowerShell 7 (`pwsh`), Python 3.13,64tass 1.60.3243.
Pillow 12.3.0 and py65 1.2.0 are the evaluated image/test libraries. External
tools are installed separately. Use a virtual environment for Python tools:

```powershell
python -m venv ../3dvibe64-tools
& ../3dvibe64-tools/Scripts/Activate.ps1
python -m pip install Pillow==12.3.0 py65==1.2.0
$env:TASS64_EXE='C:\Tools\64tass\64tass.exe'
$env:VICE_X64SC='C:\Tools\VICE\bin\x64sc.exe'
$env:VICE_XSCPU64='C:\Tools\VICE\bin\xscpu64.exe'
$env:VICE_TURBO6510='C:\Tools\Turbo6510\bin\x64sc_u.exe'
```

Replace these illustrative paths with installed tools. TASS 64_PATH/PATH also
work for the ordinary exporter; set TASS 64_EXE for gameplay packaging.
VICE is needed for native execution/tests, not data-only level validation.
Do not enable Python optimization for qualification. Compare the source ZIP
SHA 256 with the delivery checksum; every extracted input is in MANIFEST.sha 256.

### 2. Pick the pipeline

Ordinary polygonal scene, inherited API. For legacy, first extract a separate
source working copy and run the first command there. Its result is
`work/3Dvibe64.prg`. Legacy does not accept `-OutputDirectory`; that option
belongs to Q8, Normalized 16 and Mode 8. The second command uses Q8 and an
external output directory. The stationary camera keeps this first precise
textured example within its checked RAM budget; do not assume every automatic
camera/scene combination fits.

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -SceneFile examples/basic-solid-reference.json -GraphicsMode 4
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -SceneFile examples/mode7-perspective-cube.json -GraphicsMode 7 -Precision q8 -TexturePrecision perspective -TextureQuality standard -Q8Camera stationary -OutputDirectory ../first-texture
```

Standard is exact textured sampling; `TextureQuality fast` is a different
declared block/row reconstruction profile, not a synonym for precise.
TextureLOD defaults off in the ordinary exporter. Never assume gameplay
profile defaults change that ordinary API. For Mode 8 use its own map contract:

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile examples/mode8/perimeter.json -Mode8Run interactive -OutputDirectory ../first-map
```

Experimental source modules and common level:

```powershell
python -B work/build-gameplay.py --profile controlled-animation --out ../first-motion
python -B work/build-level.py --level examples/levels/integrated-foundation.json --validate-only
python -B work/build-level.py --level examples/levels/integrated-foundation.json --out ../first-level
```

Read [GAMEPLAY](GAMEPLAY.en.md) before editing profile-specific configurations.
The common level backend is WORLD-01's bounded template. Planning data can
be valid but unsupported; `--plan-only` is not a native program/memory result.
For generated group outputs retain all media files with their launcher.

### 3. Verify the result

Inspect build.json, command, hashes and memory report. Launch generated output
through its actual launcher/PRG, preserving target/options. Gameplay checks:

```powershell
python -B work/qualify-gameplay.py --out ../first-motion --checks --benchmark --launcher
python -B scripts/run_release_tests.py test_documentation.py test_dev_gameplay.py test_common_level.py
```

Full regression/native requirements: [TESTING](TESTING.md). FPS counts only new
complete native views, after warm-up over at least 20 emulated seconds/full
route; preserve raw commands, hashes and p 95/worst. Host time, warp and CPU
routine replay are not machine FPS. Historical proof is reusable only when
program bytes and launch conditions match. All compiled/check outputs remain
outside the source release. Keep older releases/foundation immutable.

## Italiano

Release ufficiale locale dei sorgenti, con pubblicazione online rinviata.
Nessun programma precompilato, archivio demo, video o musica. Conservare una
copia intatta e compilare in cartelle nuove fuori dal checkout.

### 1. Preparare gli strumenti

Host verificato: Windows, PowerShell 7 (`pwsh`), Python 3.13,64tass 1.60.3243.
Librerie valutate: Pillow 12.3.0 e py65 1.2.0. Installazione esterna separata,
preferibilmente in un ambiente virtuale:

```powershell
python -m venv ../3dvibe64-tools
& ../3dvibe64-tools/Scripts/Activate.ps1
python -m pip install Pillow==12.3.0 py65==1.2.0
$env:TASS64_EXE='C:\Tools\64tass\64tass.exe'
$env:VICE_X64SC='C:\Tools\VICE\bin\x64sc.exe'
$env:VICE_XSCPU64='C:\Tools\VICE\bin\xscpu64.exe'
$env:VICE_TURBO6510='C:\Tools\Turbo6510\bin\x64sc_u.exe'
```

Sostituire i percorsi illustrativi con quelli installati. TASS 64_PATH/PATH
valgono anche per l’exporter ordinario; TASS 64_EXE per il packaging gameplay.
VICE serve ai test/esecuzione nativi, non alla sola validazione del livello.
Qualifica senza ottimizzazioni Python. Confrontare SHA 256 dello ZIP con la
consegna; ogni sorgente estratto è elencato in MANIFEST.sha 256.

### 2. Scegliere la pipeline

Scena poligonale ordinaria, API ereditata. Per legacy estrarre prima una
copia di lavoro separata dei sorgenti ed eseguire lì il primo comando:
il risultato è `work/3Dvibe64.prg`. Legacy non accetta `-OutputDirectory`,
riservato a Q8, Normalized 16 e Mode 8. Il secondo comando usa Q8 con output
esterno. La camera stationary mantiene questo primo esempio texturizzato
preciso nel suo budget RAM verificato: non ogni scena/camera automatica
ha necessariamente memoria sufficiente.

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -SceneFile examples/basic-solid-reference.json -GraphicsMode 4
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -SceneFile examples/mode7-perspective-cube.json -GraphicsMode 7 -Precision q8 -TexturePrecision perspective -TextureQuality standard -Q8Camera stationary -OutputDirectory ../first-texture
```

Standard conserva il campionamento preciso; `TextureQuality fast` è un altro
profilo con blocchi/ricostruzione righe dichiarati. TextureLOD resta off nel
builder ordinario: i default dei profili gameplay non cambiano quell’API.
Mode 8 usa un contratto di mappa separato:

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile examples/mode8/perimeter.json -Mode8Run interactive -OutputDirectory ../first-map
```

Moduli sperimentali e formato comune:

```powershell
python -B work/build-gameplay.py --profile controlled-animation --out ../first-motion
python -B work/build-level.py --level examples/levels/integrated-foundation.json --validate-only
python -B work/build-level.py --level examples/levels/integrated-foundation.json --out ../first-level
```

Leggere [GAMEPLAY](GAMEPLAY.it.md) prima di modificare le configurazioni.
Il backend del formato comune è il template WORLD-01 delimitato. Dati di
pianificazione validi possono non essere supportati; `--plan-only` non misura
RAM né genera programmi. Conservare tutti i file media dei gruppi col launcher.

### 3. Verificare

Controllare build.json, comando, hash e mappa RAM. Avviare l’output reale con
launcher/PRG e target/opzioni corretti. Per i profili gameplay:

```powershell
python -B work/qualify-gameplay.py --out ../first-motion --checks --benchmark --launcher
python -B scripts/run_release_tests.py test_documentation.py test_dev_gameplay.py test_common_level.py
```

Requisiti completi in [TESTING](TESTING.md). Gli FPS contano nuove viste
complete native, dopo warm-up e almeno 20 secondi emulati/giro completo,
con raw/comandi/hash/p 95/peggiore. Tempo host, warp e replay di routine CPU
non sono FPS della macchina. Il riuso delle prove richiede hash e condizioni
coincidenti. Output compilati/test restano fuori dal pacchetto. Preservare
release precedenti e fondazione.
