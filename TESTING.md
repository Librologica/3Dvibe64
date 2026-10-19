# Testing / Verifiche — 1.15.0

Stable source SDK prepared locally, not published. / SDK sorgente stabile preparato in locale, non pubblicato. [Status EN](RELEASE-STATUS.en.md) · [Stato IT](RELEASE-STATUS.it.md).

Use Python3.13,PowerShell7,64tass1.60.3243,Pillow and py65; install tools separately. Set TASS64_EXE to the assembler. Never disable assertions with Python -O/-OO/PYTHONOPTIMIZE. / Installare separatamente gli strumenti e mantenere attive le asserzioni.

```powershell
python -B scripts/run_release_tests.py
python -B scripts/test_reusable_render.py --control ../control --exact ../optimized --api ../api-build --wire-reference ../wire-reference --out ../checks/reusable.json
python -B scripts/test_legacy_plus_exact.py --control ../control --exact ../optimized --out ../checks/kernels.json
python -B scripts/test_exact_panels.py --control ../control --exact ../optimized --out ../checks/panels.json
python -B scripts/test_exact_material_cache.py --control ../mixed-control --exact ../mixed-optimized --out ../checks/materials.json
```

Run the public suite from a clean source ZIP extraction; it makes independent temporary SDK copies. No bundled demo inputs are required by the default suite. Additional historical scene tests require explicit external --test-inputs. Callback builds retain native ASM,PRG,labels and maps. They check exact arithmetic,clipping,materials,wire/stream and codec behavior; **CPU callbacks do not measure FPS**. / Eseguire la suite dallo ZIP estratto; copie temporanee indipendenti. Le prove storiche aggiuntive richiedono input esterni. I callback verificano correttezza e non misurano FPS.

Uniform convex-fan merging requires the documented compiled material/palette contract. Mixed palettes keep the complete fallback. Frozen lighting intentionally fixes appearance and requires a separate no-recalculation trace; it is not equivalence to moving illumination. / La fusione dei fan è condizionata al contratto di palette; illuminazione congelata e grafica equivalente sono prove distinte.

Stable promotion changes docs,version,metadata and host checks only. All runtime sources match qualified1.15.0-dev2. Existing FPS evidence is retained only for identical PRGs and target conditions; fresh stable rebuild identities and final clean-ZIP gates are recorded in the external release receipt. / Promozione senza modifiche runtime: misure conservate solo per PRG/target identici; identità delle ricompilazioni e gate dello ZIP nella ricevuta esterna.

Native protocol: actual launcher VICE Turbo6510 PAL312×63,multiplier64,safe,Colodore/filter0;128simulation-event warm-up and at least20emulated seconds, preferably a complete automatic route. Count only new complete views after swaps, never duplicate refreshes. Preserve commands,PRG hashes,native timestamps,RAM,mean FPS,p95/worst and music state. No warp/host time/CPU replay FPS. Original fixtures are silent; do not relabel them as music-active. Native parked-palette poses are separate correctness captures, never timing runs. / Conservare target,stato musica,percorso,warm-up,durata e dati grezzi; nessuna stima o misura host.

[Qualification EN](QUALIFICATION-1.15.0.en.md) · [Qualifica IT](QUALIFICATION-1.15.0.it.md) · [Historical dev2 EN](QUALIFICATION-1.15.0-dev2.en.md) · [Storico dev2 IT](QUALIFICATION-1.15.0-dev2.it.md).
