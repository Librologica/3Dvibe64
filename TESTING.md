# Release tests

## 1.4.0 / Mode 8

The runner contains **14 scripts**: the 13 legacy Mode 1–7 contracts and
`test_mode8.py`, which reports **67 separate cases** covering six maps/tours,
parser refusals, owner/global-table/per-ray budgets, blocked routes, font
generation, twelve twice-built programs and public dispatch. It needs no emulator.
Il runner contiene **14 script**: 13 legacy e `test_mode8.py`, con **67 casi**
separati su sei mappe/percorsi, parser, budget distinti, percorsi bloccati,
font, dodici programmi ricompilati due volte e dispatch. Non serve un emulatore.

```powershell
python -B scripts/run_release_tests.py test_mode8.py
```

Optional instruction/oracle analysis requires `py65==1.2.0` and Pillow;
native qualification requires x64sc and Pillow. After the interactive build
in [MODE8.en.md](MODE8.en.md), run:
L'analisi istruzioni/oracolo opzionale richiede `py65==1.2.0` e Pillow;
quella nativa richiede x64sc e Pillow. Dopo la build interattiva in
[MODE8.it.md](MODE8.it.md), eseguire:

```powershell
python -m pip install py65==1.2.0 Pillow
python -B scripts/analyze_mode8.py --scene examples/mode8/perimeter.json --build ../perimeter-reference-build --sampling examples/mode8/sampling/perimeter.json --out ../perimeter-analysis
python -B scripts/qualify_mode8.py --scene examples/mode8/perimeter.json --build ../perimeter-reference-build --out ../perimeter-native-pal --standard pal --interactive
```

For a full automatic tour, build with `-Mode8Run auto` and omit `--interactive`.
Use `--standard ntsc` with a new output folder for NTSC. Scene/build/run mode
must match. Native clocks include UI, IRQ and presentation. Warp only speeds up
the host, never defines FPS. py65 excludes VIC stalls, IRQ and presentation.
Per il giro automatico compilare con `-Mode8Run auto` e omettere `--interactive`.
Per NTSC usare `--standard ntsc` e una nuova directory. Scena/build/modalità
devono corrispondere. I clock nativi includono UI, IRQ e presentazione. Warp
accelera solo l'host; py65 esclude stall VIC, IRQ e presentazione e non misura FPS.

Release evidence includes 93 ordered historical CPU views, full bitmap/margins,
PAL/NTSC tours and repeats, Screen RAM/UI/FPS, Color RAM, font, VIC and buffer
checks, plus screenshot pixel comparisons at six interactive starting views.
See [measured results](MODE8-QUALIFICATION.md). Mode 8 hardware, xscpu64 and
accelerated qualification were **not performed**. Mode 6 emulator smoke tests
retain their own matrix; their PASS does not qualify Mode 8.
Le prove includono 93 viste CPU storiche ordinate, bitmap/margini, giri PAL/NTSC
ripetuti, Screen RAM/UI/FPS, Color RAM, font, VIC, buffer e confronto pixel
di screenshot nei sei avvii interattivi. Vedere i [risultati](MODE8-QUALIFICATION.md).
Mode 8 su hardware, xscpu64 o accelerata **non verificata**. Il PASS della
matrice emulatori Mode 6 non qualifica la Mode 8.

## Legacy Mode 1–7 suite

Run from a clean source SDK using Python 3, PowerShell, 64tass, Pillow and NumPy.
VICE and Turbo6510 are external dependencies, not distributed with this SDK.
Configure executable paths before running:

```powershell
$env:TASS64_EXE = 'C:\tools\64tass.exe'
$env:VICE_X64SC = 'C:\tools\vice\x64sc.exe'
$env:VICE_XSCPU64 = 'C:\tools\vice\xscpu64.exe'
$env:VICE_TURBO6510 = 'C:\tools\turbo6510\x64sc_u.exe'
python -B scripts/run_release_tests.py
```

The runner makes a fresh temporary SDK for every test, propagates failures and
removes temporary build products. It does not modify the distributed tree.
Individual tests may write generated files into their working SDK; invoke them
through this runner to preserve the release manifest. A subset can be selected:

```powershell
python -B scripts/run_release_tests.py test_gouraud_mode6.py test_optimization_gate1_lut.py
```

The release contract checks the complete manifest, package cleanliness, immutable
builder hash, frozen Mode 1–5 reference builds, Ground and shared-material
framebuffers. Separate tests cover Gouraud normals/creases/duplicates, clipping,
33 levels, temporal stabilization, the exact 528-entry emitted Bayer LUT, exhaustive
byte-span and division models, cameras, depth domains and text/FPS A/B toggling.
The emulator matrix builds PAL/NTSC × normal/small for x64sc, xscpu64 and Turbo6510.
These emulator checks are smoke tests, not a substitute for pixel comparisons.

No test requires an internal benchmark directory or historical builder copy.
The byte-span model checks exact scalar equivalence; it does not measure FPS.
The packaged builder keeps Modes 1–6 on their validated 1.2.0 output and adds the
qualified Mode 7 R1 backend. Final release qualification compares Mode 6 with
Gate 5 and Mode 7 with R1;
raw snapshots, profiler data and historical source copies remain outside the SDK.

Italiano: eseguire la suite tramite il runner per mantenere pulito il pacchetto.
I test completi richiedono gli emulatori indicati e possono durare diversi minuti.
Un tool mancante o un confronto divergente è un errore, non un PASS saltato.

## Mode 7 / 1.3.0

Install host test dependencies with `python -m pip install -r requirements-tests.txt`.
`test_mode7.py` checks parser rejection cases, UV Q4.4, repeat addressing,
quad triangulation, multi-texture data, the C lighting default, strict PNG input,
PNG/inline equivalence, 1,610,631 exact R1 edge increments and eight frozen PRGs.
Run `python -B scripts/run_release_tests.py test_mode7.py` for that subset.
The backend hashes in PACKAGE-MANIFEST.json identify all Python and source ASM
modules, not only the PowerShell entry point. Source ASM kernels and the example
PNG are intentional SDK inputs; generated ASM/PRG/screenshots are not distributed.

Release qualification additionally reruns the R1 assembled edge/span and clipping
oracles, double-buffer tests and same-logical-frame comparisons on x64sc, xscpu64
and Turbo6510. These internal raw captures remain outside the public SDK.
R1 edge inclusion applies to Gouraud C; none/flat and A/B retain their reference
output. Public reference SHA-256 values are qualified R1 outputs, not new baselines
silently learned from a failing test.

Italiano: installare le dipendenze host con requirements-tests.txt. test_mode7.py
verifica parser, UV Q4.4, repeat, triangolazione quad, multi-texture, default C,
PNG rigoroso ed equivalente ai texel inline, 1.610.631 incrementi edge esatti e
otto PRG congelati. Il manifest identifica tutti i moduli Python/ASM sorgenti.
La qualificazione release aggiunge gli oracoli edge/span/clipping assemblati,
double buffering e confronti dello stesso frame logico nei tre emulatori.
I dump interni non sono distribuiti. R1 riguarda Gouraud C; none/flat e A/B
mantengono l'output precedente. Gli hash non vengono aggiornati per mascherare test falliti.
