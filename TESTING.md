[Rendering e dati riutilizzabili IT](REUSABLE-RENDER.it.md) · [Reusable rendering and data EN](REUSABLE-RENDER.en.md). Nuove API esplicite wire/stream e chiavi compatte; `all` aggiunge `integer-edges`.

# Development tests / Test dev — 1.15.0-dev2

Run the public suite from a clean source extraction. / Eseguire la suite pubblica da un'estrazione sorgente pulita.

```powershell
python -B scripts/run_release_tests.py
python -B scripts/test_legacy_plus_exact.py --control ../control --exact ../qualified --out ../checks/kernels.json
python -B scripts/test_exact_panels.py --control ../triangle-control --exact ../qualified --out ../checks/panels.json
python -B scripts/test_exact_material_cache.py --control ../mixed-control --exact ../mixed-qualified --out ../checks/materials.json
```

The external build inputs for callbacks must retain their raw ASM/PRG/labels. Uniform-fan eligibility requires its documented compiled palette contract; an ordinary conservative profile tests its exact fallback. Native moving FPS and parked palette/pose captures are separate external runs, as recorded in QUALIFICATION-1.15.0-dev2.json. Callback counts never measure FPS. Full exact ZIP test results live in the external delivery receipt.

Gli input esterni dei callback conservano ASM/PRG/label originali. La fusione dei fan richiede il contratto compilato di palette uniforme documentato; il profilo conservativo ordinario verifica il suo ripiego esatto. FPS nativi in movimento e catture ferme con scansione palette completata sono prove esterne separate, descritte in QUALIFICATION-1.15.0-dev2.json. I callback non misurano FPS. I risultati dei gate dello ZIP esatto sono nella ricevuta di consegna esterna.

## Inherited1.14.0 testing contract / Contratto di test1.14.0 ereditato

# Testing / Verifiche — 1.14.0

[Qualification EN](QUALIFICATION-1.14.0.en.md) · [Qualificazione IT](QUALIFICATION-1.14.0.it.md)

## English

Use Python3.13, PowerShell7,64tass1.60.3243, Pillow and py65. Set TASS64_EXE to
64tass; VICE_TURBO6510 selects the real native target for new FPS tests.
Historical tests can also require VICE_X64SC / VICE_XSCPU64. Install tools
separately; no executables or environments are bundled. Never use Python -O,
-OO or PYTHONOPTIMIZE: checks must stay enabled. Run from SDK root.

```powershell
python -B scripts/run_release_tests.py
python -B scripts/test_exact_release.py
python -B scripts/run_release_tests.py --test-inputs ../my-regression-inputs test_mode7.py test_precision_q8.py
```

The default suite uses self-contained package/math/configuration contracts.
Historical scene regressions require explicit external ../my-inputs/validation,
installed only into temporary SDK copies. Full archived inputs and native
projects are not distributed. Public renderer checks accept external builds:

```powershell
python -B scripts/test_exact_release.py --control ../control --exact ../optimized --out ../exact-checks
python -B scripts/test_render_optimizations.py --control ../control --exact ../dev14-optimized --mode4-scene ../my-inputs/mode4.json --out ../render-checks
python -B scripts/benchmark_native_render.py --prg ../optimized/3Dvibe64.prg --labels ../optimized/3Dvibe64.labels --out ../native-result --sound-off --warmup 101 --refreshes 2048 --route "two automatic camera periods, no stationary phase"
```

Benchmark target: VICE Turbo6510 PAL312x63 multiplier64. New complete views are
counted at fps_frame_done, not duplicate refreshes; cycles are985248Hz baseclock.
Keep real project music/launcher options: --sound-off is only for a silent
project. This generic probe's FPS path is qualified for silent projects; for
music-active projects use an external SID-aware probe preserving native audio
and per-refresh calls. Never relabel a silent measure as music-active.
At least20emulated seconds after warm-up; prefer full routes. Preserve PRG/hash,
command, raw timestamps, RAM, p95/worst and conditions. Warp/host time/CPU replay
are not native FPS. --poses freezes simulation solely for image comparison;
those runs never measure FPS. The generic probe expects the standard Q8 IRQ/
simulation labels; an incompatible adapter requires a separate validated probe.

## Italiano

Usare Python3.13, PowerShell7,64tass1.60.3243, Pillow e py65. TASS64_EXE indica
64tass; VICE_TURBO6510 seleziona il target delle nuove misure. Le prove storiche
possono richiedere VICE_X64SC / VICE_XSCPU64. Dipendenze installate separatamente,
nessun eseguibile o ambiente incluso. Non usare -O,-OO,PYTHONOPTIMIZE.

I comandi sopra eseguono test autonomi di pacchetto, matematica e configurazioni.
Le regressioni storiche richiedono ../my-inputs/validation esterni, copiati solo in
SDK temporanei. I test renderer accettano build esterne. Target delle misure:
VICE Turbo6510 PAL312x63 moltiplicatore64; solo viste nuove complete su
fps_frame_done, cicli base985248Hz. --sound-off vale soltanto per progetti
silenziosi: il probe generico FPS è qualificato per questi. Un progetto con SID
richiede un probe esterno verificato con audio nativo e chiamate per refresh.
Mai presentare una misura silenziosa come musicale. Conservare opzioni reali di
launcher/progetto; almeno20secondi emulati dopo warm-up, preferibilmente percorsi
completi. Conservare PRG/hash, comando, timestamp grezzi, RAM,p95/peggiore e
condizioni. Warp,tempo host e replay CPU non misurano FPS. --poses ferma la
simulazione solo per confrontare immagini; non misura prestazioni. Il probe
richiede le etichette IRQ/simulazione Q8 standard; altri adapter richiedono un
probe specifico qualificato.

## Legacy-plus development contract / Contratto dev legacy-plus

The default suite verifies current source hashes,57 exact native rebuild identities,
32 full-orbit sets and native provenance. Four positive compiler selections and
six incompatible-option rejections use temporary synthetic inputs. No fixture or
compiled program is shipped. The external development tools capture the actual
native complete-view counter, native intervals and frozen poses. The generic Q8
probe is not automatically compatible with the ordinary plus ABI.

La suite verifica hash sorgenti correnti,57 identità di ricompilazione nativa,
32 serie in orbita e provenienza nativa. Quattro selezioni del compilatore e sei
rifiuti usano input sintetici temporanei, non demo distribuite. Gli strumenti
esterni della dev misurano contatore viste complete/intervalli nativi e pose ferme;
il probe Q8 generico non è automaticamente compatibile con l'ABI plus ordinaria.
Le prove callback py65 controllano aritmetica e non producono FPS.

```powershell
python -B scripts/run_release_tests.py test_legacy_plus.py
```
