# Release tests

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
