# Release testing / Test della release — 1.11.0

## English

The current runner executes **41 gates**. It copies exactly the
manifest-listed current candidate bytes into an independent temporary SDK
per gate, excluding .git. Build outputs never write into this source checkout.
Tests do not silently export a different historical HEAD. Read
[qualification](QUALIFICATION-1.11.0.en.md) for actual release results.

### Environment and commands

Windows/PowerShell 7/Python 3.13/64tass 1.60.3243; Pillow 12.3.0,py65 1.2.0.
Native gates require installed stock x64sc, xscpu64 and Turbo6510. Set
TASS 64_EXE, VICE_X64SC (or VICE_EXE), VICE_XSCPU64, VICE_TURBO6510 to actual
executables. The [quick start](QUICKSTART.md) gives isolated installation and
path examples. No dependency binaries are distributed. Linux is unverified.

```powershell
python -B scripts/run_release_tests.py
python -B scripts/run_release_tests.py test_documentation.py test_dev_gameplay.py test_common_level.py
python -B work/qualify-gameplay.py --out ../your-profile-build --checks --benchmark --launcher
```

Omit filenames for the full suite. Optional filenames must be in the list
below. Qualification rejects -O/-OO/PYTHONOPTIMIZE, including direct native.run.
A blocked tool is reported as blocked, never converted into a pass. Host
contract tests for new schemas/graphs are distinct from executed 6502/native
pixel checks. Synthetic integrity fixtures are never performance evidence.

### Coverage and evidence

Core gates retain historical reference PRG hashes, arithmetic/clipping/
coverage/lighting/texture/LOD/line/presentation tests, Mode 8 validation,
bitmap-oracle/provenance checks and retired-path refusals. Identity assertions
use 1.11.0; ordinary builder/backend hashes retain 1.10.2. Profile gates cover
mixed surfaces, configured billboard/entity, door, multiple instances,
texture animation, light bake, connectivity visibility, shared meshes,
controlled motion/roll, room graphs and common-level memory/compatibility.
Documentation tests check both languages, feature/CLI coverage, links,
manifest integrity and absence of shipped programs/demo archives.

The release also rebuilds all 13 profile checkpoints, the common level and
the separate integration from source into external verification directories.
Only exact PRG/group-data/label identity permits reuse of prior native proof;
version strings alone do not. Preserve commands, tool versions/hashes and
source ZIP/extraction identities. Final archive is checked for CRC and every
manifest hash; no PRG is packaged.

FPS: use the actual native target/launcher, music/options/route,≥20 emulated
seconds after warm-up, preferably a complete automatic route. Count only
new complete presentations and independently cross-check native counters.
Report average,p 95,worst,raw,hash and exact command. Warp/host/CPU replay
speed is not emulated-machine FPS. Matched controls keep target, geometry,
camera and visual quality; explicitly identify intended scene changes.
Source/docs/host-tool promotion does not require a new FPS run when delivered
program hashes and launch conditions remain identical. Raw development
captures stay outside the source distribution; qualified summaries identify
their original programs rather than pretending they were reacquired.

## Italiano

Il runner corrente esegue **41 gate**. Copia i byte del candidato
elencati nel manifest in un SDK temporaneo indipendente per ogni test,
escludendo .git. Non scrive build nei sorgenti e non esporta silenziosamente
un vecchio HEAD. Risultati effettivi in [qualificazione](QUALIFICATION-1.11.0.it.md).

### Ambiente e comandi

Windows/PowerShell 7/Python 3.13/64tass 1.60.3243; Pillow 12.3.0 e py65 1.2.0.
I gate nativi richiedono x64sc stock, xscpu64 e Turbo6510 installati.
Configurare TASS 64_EXE, VICE_X64SC(o VICE_EXE), VICE_XSCPU64 e VICE_TURBO6510.
La [guida rapida](QUICKSTART.md) descrive ambiente isolato e percorsi.
Dipendenze non distribuite; Linux non verificato.

```powershell
python -B scripts/run_release_tests.py
python -B scripts/run_release_tests.py test_documentation.py test_dev_gameplay.py test_common_level.py
python -B work/qualify-gameplay.py --out ../your-profile-build --checks --benchmark --launcher
```

Senza nomi si esegue la suite intera; i nomi opzionali devono essere nella
lista seguente. Qualifica senza -O/-OO/PYTHONOPTIMIZE, anche per native.run
diretta. Strumenti mancanti sono segnalati come blocco, mai come PASS.
Test host di schemi/grafi sono distinti da routine 6502 eseguite/pixel nativi.
Fixture sintetiche d’integrità non sono prove di prestazioni.

### Copertura e prove

I gate core conservano hash PRG storici, test di aritmetica/clipping/copertura/
luce/texture/LOD/linee/presentazione, validazione Mode 8, oracoli bitmap,
provenienza e rifiuto dei percorsi ritirati. Identità 1.11.0, hash di builder/
backend ordinari 1.10.2. I gate dei profili coprono materiali misti, entità,
porta, istanze billboard, texture animate, bake, visibilità, mesh condivise,
clip/roll, gruppi, formato comune e budget. Il controllo documentazione
verifica entrambe le lingue, funzioni/opzioni CLI, collegamenti, manifest e
assenza di programmi/archivi demo nella consegna.

La release ricostruisce anche tutti 13 i checkpoint, il livello comune e
l’integrazione separata in cartelle esterne. Soltanto l’identità esatta di
PRG/dati gruppo/label permette di riusare prove precedenti, non il numero
versione. Conservare comandi, identità strumenti, ZIP/estrazione. Verifica
CRC e ogni hash del manifest nell’archivio finale; nessun PRG incluso.

FPS sul target/launcher nativo reale con musica/opzioni/percorso dichiarati,
almeno 20 secondi emulati dopo warm-up, preferibilmente giro completo. Contare
nuove presentazioni complete e riscontrare contatori nativi. Comunicare media,
p 95,peggiore,raw,hash e comando. Warp/tempo host/replay CPU non sono FPS della
macchina. Controlli con target/geometria/camera/qualità uguali, dichiarando
le modifiche intenzionali della scena. Non serve una nuova misura per sole
modifiche sorgenti documentali/strumenti host quando byte e condizioni PRG
restano identici. Catture originali fuori dalla distribuzione; i riepiloghi
indicano l’acquisizione originale senza dichiarare misure mai rieseguite.

## Gate inventory / Elenco gate

- `test_documentation.py`
- `test_mixed_surfaces.py`
- `test_billboard_scene.py`
- `test_door_entity.py`
- `test_multiple_billboards.py`
- `test_texture_animation.py`
- `test_light_bake.py`
- `test_sector_visibility.py`
- `test_shared_meshes.py`
- `test_controlled_motion.py`
- `test_world_groups.py`
- `test_common_level.py`
- `test_dev_gameplay.py`
- `test_release_contract.py`
- `test_world_metrics.py`
- `test_gouraud_mode6.py`
- `test_optimization_gate1_lut.py`
- `test_optimization_gate3_span.py`
- `test_optimization_gate4_division.py`
- `test_mobile_yq2.py`
- `test_camera_move_step.py`
- `test_camera_angular_repeat.py`
- `test_object_depth_domain.py`
- `test_gouraud_mode6_emulators.py`
- `test_dev7_text_split.py`
- `test_mode7.py`
- `test_mode8.py`
- `test_precision_q8.py`
- `test_mode8_lintels.py`
- `test_texture_perspective.py`
- `test_texture_uvzp.py`
- `test_texture_fast.py`
- `test_line_hybrid.py`
- `test_texture_lod.py`
- `test_frame_presentation.py`
- `test_normalized16.py`
- `test_maintenance_host.py`
- `test_maintenance_numeric.py`
- `test_engine_experiments.py`
- `test_mode8_retirement.py`
- `test_qualification_guard.py`

Historical reports retain their versioned scope; current results are in
QUALIFICATION-1.11.0.json. I rapporti storici mantengono la versione originaria;
risultati correnti in QUALIFICATION-1.11.0.json.
