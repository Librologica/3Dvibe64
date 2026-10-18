# Testing / Verifiche — 1.13.0

[Qualification EN](QUALIFICATION-1.13.0.en.md) · [Qualificazione IT](QUALIFICATION-1.13.0.it.md)

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

## Legacy-plus release contract / Contratto release legacy-plus

The default suite includes `test_legacy_plus.py`: it verifies93 promoted engine
inputs, the native aggregate provenance, four positive compiler selections and
six incompatible-option rejections. Its temporary synthetic triangle is a
compiler unit fixture, not a packaged scene or demo. The test never infers FPS
from CPU replay. Legacy-plus native FPS require a validated external project
driver/counter; the generic Q8 probe does not automatically provide those labels.
The1.13.0 QA rebuilds the exact dev7 native PRGs before reusing their measurements.

La suite predefinita include `test_legacy_plus.py`: controlla93 input engine,
provenienza degli aggregati nativi, quattro selezioni positive del compilatore
e sei rifiuti per opzioni incompatibili. Il triangolo sintetico temporaneo è una
fixture unitaria, non una scena/demo distribuita. Nessun FPS è dedotto da replay
CPU. Gli FPS nativi plus richiedono driver/contatore esterni verificati: il probe
Q8 generico non fornisce automaticamente tali label. La qualifica1.13.0 ricompila
i PRG nativi dev7 esatti prima di riutilizzarne le misure.

```powershell
python -B scripts/run_release_tests.py test_legacy_plus.py
```
