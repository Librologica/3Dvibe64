# Release tests

## Official 1.10.0 / Ufficiale 1.10.0

The runner still offers 23 inherited public scripts. This RC qualification ran
12 selected scripts, plus 23 native PAL/NTSC builds, 16 same-pose comparisons
and independent projection checks. It does not claim a fresh run of all 23 scripts.
Official promotion changes no builder, backend, scene or measured PRG.
The official package contract and world-metrics checks are rerun on a clean copy.
Il runner offre ancora 23 script pubblici ereditati. La qualificazione RC ne ha
eseguiti 12, oltre a 23 build native PAL/NTSC, 16 confronti della stessa posa
e verifiche indipendenti di proiezione. Non dichiara una nuova esecuzione di tutti
i 23 script. La promozione ufficiale conserva builder, backend, scene e PRG misurati.
Contratto del pacchetto ufficiale e world metrics verificati su copia pulita.
[Scope, native FPS and hashes / Ambito, FPS nativi e hash](Q8-QUALIFICATION.md).
Raw commands, monitor traces, RAM captures and launchers are in the separate
qualification evidence package / Comandi grezzi, trace, catture RAM e launcher nel pacchetto prove separato.

## Inherited 1.9.0 / Ereditato dalla 1.9.0

23 scripts: the 22 inherited tests, plus `test_normalized16.py`. Use the same
clean-copy runner below. The new test rebuilds 21 PAL/NTSC programs, checks
seven deterministic PAL regenerations and executes actual 6502 multiply,
ratio, projection and five-plane clipping routines. Invalid profile/camera
combinations are refused. Historical PRG/framebuffer hashes are unchanged.

23 script: i 22 test ereditati più `test_normalized16.py`, sempre tramite il
runner su copie temporanee. Il nuovo test esegue 21 build PAL/NTSC, sette
rigenerazioni PAL deterministiche e routine 6502 reali di prodotto, rapporto,
proiezione e clipping sui cinque piani. Combinazioni non supportate rifiutate.
Gli hash storici PRG/framebuffer non vengono aggiornati.

Native FPS and identical-pose palette/bitmap replay are separate:
FPS nativi e replay palette/bitmap alla stessa posa sono verifiche separate:

```powershell
$env:VICE_TURBO6510 = 'C:\tools\turbo6510\x64sc_u.exe'
python -B scripts/benchmark_normalized16.py --out ../normalized-qualification --standard pal
python -B scripts/benchmark_normalized16.py --out ../normalized-qualification --standard ntsc
python -B scripts/benchmark_normalized16.py --out ../normalized-qualification --standard pal --capture --precision normalized16
```

The native benchmark uses unchanged public scenes, Turbo6510×64, no music or
overlay, 2s warm-up and at least 20s emulated measurement. Warp/host time is not
an FPS source. Color RAM is captured separately from the RAM underneath I/O,
and compared by its stored low nibble. py65 is required for the capture replay.
Il benchmark nativo usa scene pubbliche invariate, Turbo6510×64, senza
musica/overlay, warm-up2s e almeno20s emulati di misura. Warp/tempo host non
forniscono FPS. La Color RAM è catturata separatamente dalla RAM sotto I/O e
confrontata per nibble basso memorizzato. Il replay delle catture richiede py65.
See / Vedere [qualification / qualificazione](NORMALIZED16-QUALIFICATION.md).

## Release 1.8.0

22 scripts: the 19 inherited contracts plus `test_line_hybrid.py`,
`test_texture_lod.py`, `test_frame_presentation.py`. Run only through
`python -B scripts/run_release_tests.py`, which makes clean temporary SDK copies.
Old expected PRG hashes are checked with explicit legacy presentation; native
safe-default qualification is separate. The timing-model test is not a VIC-II
simulation. Real VICE traces, RAM/palette replay and measurements are recorded
in the external qualification report. New LOD and hybrid raster alter image sampling
intentionally, so their oracles are not the original Q8 pixel hashes.

22 script: 19 contratti ereditati più i tre test nuovi. Usare esclusivamente il
runner sopra, che crea copie SDK temporanee pulite. I vecchi hash PRG sono
verificati con presentazione legacy esplicita; la qualificazione nativa del
default sicuro è separata. Il modello temporale non simula il VIC-II. Trace VICE,
replay RAM/palette e misure sono nel report esterno di qualificazione. LOD e raster
ibrido cambiano intenzionalmente il campionamento; hanno oracoli propri.

## 1.7.0 fast Mode 7 / Mode 7 veloce

The runner includes `test_texture_fast.py`. It builds fresh PAL/NTSC Q8
fast PRGs and executes the actual 6502 routines: 16,416 step-eight predictions,
131,072 U/V endpoint tests, 25,758 span samples, 37,500 edge advances, both-buffer
duplication, scalar fallback and shader transitions. It also rejects invalid
lighting/profile combinations. Native qualification is separate from these
instruction-level tests; test output is not an FPS claim. Previous PRG/framebuffer
hashes remain unchanged. See [fast contract](MODE7-FAST.en.md).

Il runner include `test_texture_fast.py`: nuove build PAL/NTSC Q8 fast e routine
6502 reali, con 16.416 previsioni carrier, 131.072 test estremi U/V, 25.758
campioni span, 37.500 avanzamenti edge, duplicazione nei due buffer, fallback
scalare e transizioni shader. Rifiuta combinazioni luminose/profili non validi.
La qualificazione nativa è separata: questi test non misurano FPS. Hash PRG e
framebuffer precedenti invariati. [Contratto](MODE7-FAST.it.md).

## Inherited 1.6.1 tests / Test ereditati dalla 1.6.1

The 1.6.1 runner contained 18 scripts (1.7.0 adds the nineteenth).
`test_texture_uvzp.py` adds 12,814 assembled
paired-divider cases, a 1,048,576-input host subset and ownership/skip checks.
The full 16-bit triple space is not claimed exhausted: fast-domain equivalence
follows the restoring remainder invariant; other values retain the original
scalar fallback. No historical demo/ROM/benchmark directory is needed.
Existing 17 contracts/reference hashes retained; py65/PowerShell/64tass required.

Il runner 1.6.1 conteneva 18 script (1.7.0 aggiunge il diciannovesimo).
`test_texture_uvzp.py` aggiunge 12.814 casi del
divisore assemblato, 1.048.576 input host e controlli scratch/percorsi esclusi.
Non si dichiara esaustivo l'intero spazio di triple16bit: invariante restoring
nel dominio veloce, fallback originale negli altri casi. Nessuna demo/ROM o
directory benchmark storica. I17 contratti/hash restano; richiesti py65,
PowerShell e 64tass. [Note release / Release notes](RELEASE-NOTES-1.6.1.md).

Native DEV qualification: 2,610 real KERNAL/raster IRQ instruction-boundary
injections and 32 same-pose bitmap/color A/B comparisons PAL/NTSC across
x64sc/xscpu64/Turbo6510, zero differences. Separate from public arithmetic
tests; captures are not shipped, hardware and a new native FPS curve not claimed.
Qualificazione nativa DEV:2.610 iniezioni reali di IRQ KERNAL/raster ai
confini delle istruzioni e32 confronti A/B bitmap/colori alla stessa posa
PAL/NTSC su x64sc/xscpu64/Turbo6510, zero differenze. Sono separati dai test
aritmetici pubblici; catture non distribuite, hardware/nuova curva FPS non dichiarati.

## Historical 1.6.0 / Storico 1.6.0

The complete runner contains 17 scripts. The previous 16 preserve all old PRG
references. `test_texture_perspective.py` builds none/flat/Gouraud C and executes
the actual assembled 48/24 divider, clipping products, reciprocal encoder/cache,
signed span setup and projective samplers on py65 against independent integer
expectations. Requires py65, PowerShell and 64tass. No historical SDK or demo path.
Native qualification is reported separately; these arithmetic tests are not FPS
measurements or hardware tests. [Contract](TEXTURE-PRECISION.en.md).

Il runner completo contiene 17 script. I precedenti 16 conservano tutti gli hash
PRG. Il nuovo test compila none/flat/Gouraud C ed esegue l'assembly reale su py65
per divisione 48/24, prodotti clipping, encoding/cache, setup span e sampler,
confrontando attese intere indipendenti. Richiede py65, PowerShell e 64tass,
non copie storiche o demo. Qualificazione nativa separata: non misura FPS o
hardware. [Contratto](TEXTURE-PRECISION.it.md).

## Historical 1.5.5 / Storico 1.5.5

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

Italiano: eseguire da un SDK sorgente pulito con Python3, PowerShell,
64tass, Pillow e NumPy. VICE e Turbo6510 sono dipendenze esterne, non distribuite.
Configurare i percorsi eseguibili con il blocco PowerShell condiviso sopra.

Il runner crea un SDK temporaneo nuovo per ogni test, propaga gli errori e
rimuove i prodotti temporanei. Non modifica l'albero distribuito. I singoli
test possono scrivere file generati nel proprio SDK di lavoro: invocarli
tramite il runner per preservare il manifest. Il secondo comando condiviso
mostra come selezionare un sottoinsieme di test.

Il contratto release controlla manifest completo, pulizia del pacchetto, hash
builder immutabile, build Mode1–5 congelate e framebuffer Ground/materiali
condivisi. Test separati coprono normali/crease/duplicati Gouraud, clipping,
33 livelli, stabilizzazione temporale, LUT Bayer emessa esatta da528 elementi,
modelli esaustivi di byte-span/divisione, camere, domini depth e commutazione
A/B testo/FPS. La matrice emulatori compila PAL/NTSC × normal/small per
x64sc, xscpu64 e Turbo6510. Sono smoke test, non sostituti dei confronti pixel.

Nessun test richiede directory benchmark interna o copia di un builder storico.
Il modello byte-span verifica equivalenza scalare esatta, non FPS. Il builder
conserva Mode1–6 sull'output1.2.0 validato e aggiunge il backend Mode7 R1
qualificato. La qualificazione finale confronta Mode6 con Gate5 e Mode7 con
R1; snapshot grezzi, profiler e sorgenti storiche restano fuori dall'SDK.

Full tests require the listed emulators and may take several minutes. A missing
tool or divergent comparison is an error, not a skipped PASS.
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

Italiano: installare le dipendenze host con
`python -m pip install -r requirements-tests.txt`. `test_mode7.py` verifica
rifiuti parser, UV Q4.4, indirizzamento repeat, triangolazione quad,
multi-texture, default luce C, input PNG rigoroso, equivalenza PNG/inline,
1.610.631 incrementi edge R1 esatti e otto PRG congelati. Per questo sottoinsieme
eseguire `python -B scripts/run_release_tests.py test_mode7.py`.
Gli hash backend in PACKAGE-MANIFEST.json identificano tutti i moduli Python
e ASM sorgenti, non soltanto l'ingresso PowerShell. Kernel ASM sorgenti e PNG
di esempio sono input intenzionali; ASM generati/PRG/screenshot non sono distribuiti.

La qualificazione release riesegue anche oracoli assemblati edge/span/clipping
R1, test double-buffer e confronti dello stesso frame logico su x64sc, xscpu64
e Turbo6510. Le catture interne restano esterne all'SDK pubblico. L'inclusione
edge R1 riguarda Gouraud C; none/flat e A/B conservano l'output di riferimento.
Gli SHA-256 pubblici sono output R1 qualificati, non nuove baseline apprese
silenziosamente da un test fallito.
