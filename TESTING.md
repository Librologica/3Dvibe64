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
The packaged builder is exactly the promoted Gate 5 implementation. Final release
qualification also compares its framebuffers against that frozen implementation;
raw snapshots, profiler data and historical source copies remain outside the SDK.

Italiano: eseguire la suite tramite il runner per mantenere pulito il pacchetto.
I test completi richiedono gli emulatori indicati e possono durare diversi minuti.
Un tool mancante o un confronto divergente è un errore, non un PASS saltato.
