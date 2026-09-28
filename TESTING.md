# Release tests

## Current 1.5.5 / Attuale 1.5.5

The complete runner contains **16 scripts**: the previous 15 plus
`test_mode8_lintels.py`. It assembles both portal templates, executes the
exit-state and front-only boundary cases on py65, and compares 36 same-pose
complete bitmaps against the host model. This test requires py65 and 64tass,
not VICE. The existing `test_mode8.py` retains all 67 cases with the two
separately qualified portal hashes promoted in this new package only.
All other Mode 8 references, Modes 1–7 and Q8 identities remain unchanged.
The 1.5.0/1.4.0 sections below describe their historical introductions.

Il runner completo contiene **16 script**: i precedenti 15 più
`test_mode8_lintels.py`. Assembla entrambi i template porte, esegue su py65 i
casi di uscita e discontinuità solo frontale e confronta 36 bitmap complete
alla stessa posa con il modello host. Richiede py65 e 64tass, non VICE.
`test_mode8.py` conserva tutti i 67 casi: solo i due hash porte, qualificati
separatamente, vengono promossi nel nuovo pacchetto. Gli altri riferimenti
Mode 8, Mode 1–7 e Q8 restano invariati. Le sezioni 1.5.0/1.4.0 sotto descrivono
le rispettive introduzioni storiche.

```powershell
python -B scripts/run_release_tests.py
```

## 1.5.0 / Q8 precision

The complete runner now contains **15 scripts**. The previous fourteen remain,
with only version/source-package identities updated in metadata contracts.
Legacy PRG/framebuffer reference hashes and all Mode 8 algorithms are unchanged.
`test_precision_q8.py` checks omitted/explicit legacy for Modes 1-7, 42 Q8 builds
against silent rebuilds of the qualified source, and invalid profile/output cases.
Run through the temporary-copy runner below; no historical workspace is required.
The extra Q8 test requires no emulator. Source ASM under work/q8/src and the
subpixel preparation templates are intentional inputs, not generated artifacts.

Il runner completo contiene ora **15 script**. I quattordici precedenti restano,
con aggiornamento delle sole identità versione/sorgente nei contratti del pacchetto.
Hash PRG/framebuffer legacy e algoritmi Mode 8 invariati. `test_precision_q8.py`
verifica legacy omesso/esplicito Mode 1-7, 42 build Q8 contro ricompilazioni
silenziose della sorgente qualificata e rifiuti di profili/output non validi.
Usare il runner su copie temporanee; nessuna dipendenza dal workspace storico.
Il test Q8 aggiuntivo non richiede emulatori. Gli ASM in work/q8/src e i template
di preparazione subpixel sono input intenzionali, non artefatti generati.

```powershell
python -B scripts/run_release_tests.py test_precision_q8.py
```

Native release checks are separate from build-hash tests and use same-pose RAM
captures/replay. Q8 does not imply unrestricted Ground/sharing/small/roll support
or a new stock FPS qualification. See [EN](PRECISION.en.md) / [IT](PRECISION.it.md).
I controlli nativi release sono separati dagli hash build e usano catture RAM e
replay della stessa posa. Q8 non implica supporto illimitato Ground/sharing/small/
roll né una nuova qualificazione FPS stock. Guide [EN](PRECISION.en.md) / [IT](PRECISION.it.md).

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
