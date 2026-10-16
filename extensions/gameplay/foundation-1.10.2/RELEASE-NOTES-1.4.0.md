# 3Dvibe64 1.4.0 — release notes / note di release

GraphicsMode 8 officially exposes the qualified 2.5D bitmap pipeline through
the normal builder. Three original maps and three complete editing tutorials
are included. Monolevel opaque, monolevel apertures and heightfield inputs select
separate qualified paths; no new renderer optimization is introduced.

GraphicsMode 8 rende ufficiale la pipeline bitmap 2.5D attraverso il builder
normale. Include tre mappe originali e tre tutorial completi. Mappe monolivello
opache, con aperture e heightfield selezionano percorsi qualificati distinti;
non vengono introdotte nuove ottimizzazioni del renderer.

## Start / Iniziare

- [Architecture EN](MODE8.en.md) / [architettura IT](MODE8.it.md).
- [Complete map guide EN](MAPS-2.5D.en.md) / [guida completa mappe IT](MAPS-2.5D.it.md).
- [Generated plans / piante generate](examples/mode8/PLANS.md).
- [Memory / memoria](MODE8-MEMORY.md), [qualification / qualificazione](MODE8-QUALIFICATION.md), [test commands / comandi test](TESTING.md).

## Contract and compatibility / Contratto e compatibilità

Modes 1–7 preserve their reference PRGs, options and defaults. Mode 8 is a
separate map schema and runtime, not a new mesh shader or a compositing layer.
It requires explicit `-GraphicsMode 8 -SceneFile ...`, with its own option table.
The three original maps support the documented edits, not arbitrary ramps,
room-over-room, new camera starts or unrestricted monolevel tours.

Mode 1–7 conservano PRG di riferimento, opzioni e default. La Mode 8 usa schema
mappe e runtime separati: non è uno shader mesh né un livello di compositing.
Richiede `-GraphicsMode 8 -SceneFile ...`, con tabella opzioni propria.
Le tre mappe originali ammettono le modifiche documentate, non rampe arbitrarie,
room-over-room, nuovi punti di partenza o percorsi monolivello liberi.

128×144 logical-pixel bitmap, double buffering, complete-frame UI/FPS and the
qualified adaptive edge/thickness treatment are retained. Pigments are fixed
by orientation and the ceiling uses a stipple; wall UV textures are not active.
The source SDK has no compiled programs or diagnostic captures. Six programs
(three maps × interactive/automatic) are supplied in the separate demo archive.

Restano bitmap da 128×144 pixel logici, doppio buffer, UI/FPS per immagini complete
e trattamento adattivo qualificato di bordi/spessori. Pigmenti fissi per
orientamento e retino del soffitto: le texture UV sulle pareti non sono attive.
L'SDK non contiene programmi compilati o catture diagnostiche. Sei programmi
(tre mappe × interattivo/automatico) sono nell'archivio demo separato.

## Evidence and limits / Evidenze e limiti

The old 13-script suite is distinct from the new map tests and native comparisons.
See the qualification table for actual counts, measured full tours and tail
latency. CPU-only sampling is not FPS. The two-level scene can pause for much
longer than its mean interval; current performance is accepted, not advertised
as a newly achieved high-FPS target. Only x64sc stock PAL/NTSC is qualified for
Mode 8. **No hardware test has been performed.**

La vecchia suite di 13 script è distinta dai nuovi test mappe e confronti nativi.
La tabella di qualificazione riporta conteggi effettivi, giri completi e latenze.
I cicli CPU del campionamento non sono FPS. La scena a due livelli può avere
pause molto superiori alla media; le prestazioni attuali sono accettate, non
presentate come un nuovo target di elevato framerate. Mode 8 qualificata soltanto
su x64sc stock PAL/NTSC. **Nessun test hardware è stato eseguito.**

## Provenance and distribution / Provenienza e distribuzione

The base is the frozen 1.3.0 SDK. Mode 8 derives from the qualified bitmap
backend-router; property validation and the optional instruction-cost analyzer
derive from the Scene Cost Lab. Its numerical renderer and template layout are
preserved. Portable host imports, stricter input diagnostics, UI text and public
packaging are release integration work. Source templates and the original
project-authored text font are covered by the project software license.
External tools remain external and keep their own licenses.

La base è l'SDK 1.3.0 congelato. Mode 8 deriva dal backend-router bitmap
qualificato; validazione per proprietà e analizzatore costi opzionale derivano
dal Scene Cost Lab. Renderer numerico e layout dei template sono preservati.
Import host portabili, diagnostica rigorosa, testo UI e packaging sono lavoro
di integrazione. Template e font testuale originale del progetto ricadono nella
licenza software del progetto. I tool esterni mantengono le proprie licenze.

Software: PolyForm Noncommercial 1.0.0. Documentation: CC BY-NC 4.0.
The complete `MANIFEST.sha256` covers every distributed file except itself;
`PACKAGE-MANIFEST.json` pins the builder and runtime source identities.
Legacy expected PRG hashes are not changed to accommodate this release.
Remote publication is separate from this local package.

Software: PolyForm Noncommercial 1.0.0. Documentazione: CC BY-NC 4.0.
`MANIFEST.sha256` copre tutti i file distribuiti tranne sé stesso;
`PACKAGE-MANIFEST.json` identifica builder e sorgenti runtime.
Gli hash PRG legacy attesi non sono modificati per adattarli alla release.
La pubblicazione remota è separata da questo pacchetto locale.
