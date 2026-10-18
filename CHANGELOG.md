# 1.14.0-dev1 — separate local development / dev locale separata

Extends opt-in legacy-plus to Mode1–7, affine and perspective Mode7, without Q8 geometry. Q4 near/screen and shade/UV carriers remain coherent; half-open projective spans and guarded solid/Gouraud RAM allocation are corrected. Native PAL Turbo6510×64 comparisons include camera routes, near/screen crossings, frozen buffers and full orbit/pitch. Mode4 camera FPS regresses vs legacy; finite quantization and memory/profile bounds remain. Default legacy/Q8 reference bytes are preserved. Unpublished, no demos or official/frozen changes. [Evidence](QUALIFICATION-1.14.0-dev1.en.md).

Legacy-plus estesa a Mode1–7 e texture Mode7 affini/prospettiche senza geometria Q8. Clipping Q4, attributi coerenti, span half-open e RAM Gouraud verificati. Confronti nativi di stabilità/FPS per camera e clipping; regressione FPS camera Mode4 dichiarata. Dev non pubblicata, nessuna modifica a release ufficiali o demo congelate. [Prove](QUALIFICATION-1.14.0-dev1.it.md).

# 1.13.0 — stable engine source release / release stabile

Promotes the byte-preserved dev7 engine and opt-in legacy-plus. Default legacy,
old rotation, Q8, Normalized16 and Mode8 retain their contracts. Q4 near/screen
clipping and finer camera rotation; camera cadence39.9006ms on the qualified
PAL Turbo6510 ×64 route. Complete current IT/EN contracts, source-only tests,
no demos/examples/PRGs/media. Published on GitHub.

Promozione dell'engine dev7 senza variazioni dei byte. Legacy-plus opzionale;
default legacy e altri backend preservati. Contratti, limiti e prove IT/EN
aggiornati; nessuna demo, esempio, PRG o media; pubblicata su GitHub.

## Development history / Storia dello sviluppo

# Local 1.12.1-dev7 — legacy-plus camera cadence

One isolated plus-only Q4 rounding-loop expansion. Native PAL Turbo6510 ×64 camera worst59.85→39.90ms; mean25.05004→25.06227 FPS. Clipping41.19121 FPS unchanged. All658 native pose images unchanged from dev6. No Q8 introduction or publication; all earlier developments/releases/frozen demos preserved.

**Local dev6 / dev locale 1.12.1-dev6:** Q4 near/screen clipping for legacy-plus; default legacy, old rotation and Q8 preserved. See [LEGACY-PLUS.it.md](LEGACY-PLUS.it.md) / [LEGACY-PLUS.en.md](LEGACY-PLUS.en.md). Earlier documentation follows.

**Local1.12.1-dev3:** finer legacy camera rotations and exact optimizations; [CAMERA-ROTATION.en.md](CAMERA-ROTATION.en.md), evidence in DEV-QUALIFICATION.json. Inherited documents/references follow.

**Dev locale1.12.1-dev3:** rotazioni camera legacy più fini e ottimizzazioni esatte; [CAMERA-ROTATION.it.md](CAMERA-ROTATION.it.md), dati in DEV-QUALIFICATION.json. Seguono documenti e riferimenti ereditati.

**Local 1.12.1-dev2:** legacy camera lab, optional Q4 profile and limits in [CAMERA-ISOLATION.en.md](CAMERA-ISOLATION.en.md). The following retains dev1/official baseline references.

**Dev locale 1.12.1-dev2:** laboratorio camera legacy, profilo Q4 opzionale e limiti in [CAMERA-ISOLATION.it.md](CAMERA-ISOLATION.it.md). La documentazione seguente include i riferimenti ereditati dalla dev1/base ufficiale.

**Local1.12.1-dev1:** optional legacy corrections, Mode2/4 qualification and limits in [LEGACY-STABILITY.en.md](LEGACY-STABILITY.en.md). The following documents the inherited1.12.0 APIs.

**Dev locale1.12.1-dev1:** correzioni legacy opzionali, qualifica Mode2/4 e limiti in [LEGACY-STABILITY.it.md](LEGACY-STABILITY.it.md). Il seguito documenta le API ereditate dalla base1.12.0.

# Changelog

## 1.12.0 — local source release / release locale

Exact opt-in renderer work elimination; reusable conservative wall adapter,
static pattern/palette and raster emitters, optional pool/camera/SID support.
No demo/example projects or assets, including preexisting examples. Explicit
external scene/project/test inputs. No GitHub publication. Full bilingual
contracts, native before/after measurements and source-only package audit.

Ottimizzazioni esatte esplicite, adapter conservativo pareti, emitter raster,
retini/palette e supporti opzionali pool/camera/SID. Nessuna demo o esempio,
neppure preesistente. Input scena/progetto/test esterni espliciti. GitHub non
aggiornato. Contratti EN/IT, misure native e controllo del pacchetto sorgente.

[EN](RELEASE-NOTES-1.12.0.en.md) · [IT](RELEASE-NOTES-1.12.0.it.md)

## 1.11.0 distribution correction / correzione distribuzione

Remove all newly bundled demo projects, including their sources, character/UI
assets, camera tours, launchers and duplicate old SDK. Retain reusable engine
modules and only the preexisting examples; native gameplay requires explicit
external project inputs. Version/release stays 1.11.0. / Rimossi i nuovi demo,
anche sorgenti e asset; conservati moduli generici ed esempi preesistenti.
Nessuna nuova versione/release.


## 1.11.0 — 2026-10-16 — official local source release / release sorgente ufficiale locale

- Promote the qualified dev13/cubes-restored line with all bounded gameplay modules, common level authoring and exact assembled memory checks. Promote tutti i moduli delimitati e il formato/budget di livello qualificati.
- Keep ordinary1.10.2 renderer/defaults, Mode8 and sealed foundation unchanged. Conservati renderer/default ordinari, Mode8 e fondazione.
- Complete current English/Italian manuals, module contracts, feature/CLI matrix, roadmap, quick start, test inventory and link/coverage audit. Documentazione corrente completa nelle due lingue.
- Honor configured assembler/emulator paths in host packaging/capture helpers; qualify binary identity separately. Percorsi host configurabili, identità dei programmi verificata.
- Source distribution only; no precompiled PRG, demo archive, video or music. Local delivery; online publication deferred. Solo sorgenti, pubblicazione online rinviata.

[Release EN](RELEASE-NOTES-1.11.0.en.md) · [Release IT](RELEASE-NOTES-1.11.0.it.md) · [Qualification EN](QUALIFICATION-1.11.0.en.md) · [Qualificazione IT](QUALIFICATION-1.11.0.it.md).

## Historical development and releases / Sviluppo e release precedenti


Deterministic host-only static vertex lighting with Lambert/radius falloff,
static triangle occlusion and a compact LB01 bake artifact. Selected existing
Gouraud receivers reuse resident shade tables: twelve data bytes change,
no runtime code or extra RAM. Independent analytical/manual-reference and
native image/regression proofs; official release documentation deferred.
See extensions/gameplay/materials/LIGHT-DEV.it.md.

# Development checkpoint 1.11.0-dev6

Optional resident texture frame pages and signed integer UV scrolling per
material group, exact perspective sampling and unchanged LOD14..22.
Native timing/page-integrity, independent pre-baked pixel oracles and
active/frozen route benchmarks; dev5 capabilities preserved. Empty animation
configuration reconstructs the dev5 PRG. See materials/ANIMATION-DEV.it.md
under the gameplay extension. Official release documentation deferred.

# Development checkpoint 1.11.0-dev5

Two shared-asset billboard instances with independent animation, exact Q8
mutual depth ordering, screen clipping and explicit near-plane4WU behavior.
Native pixel/animation/door regression checks and equal-condition one/two
instance benchmarks. See extensions/gameplay/billboards/MULTIPLE-DEV.it.md.

# Development checkpoint 1.11.0-dev4

Guardian-operated polygonal door with progressive four-state motion,
height clearance, bidirectional passage, safe closure reversal and bounded
half-space occlusion. Existing profiles preserved. See
extensions/gameplay/entities/DOOR-DEV.it.md. General levels remain planned.

# Development checkpoint 1.11.0-dev3

Experimental single-billboard scene configuration, native animation timing,
a usable entity with persistent state/events and local XY box collision.
ENT-01 remains partial: moving doors and general level entities are planned.
See extensions/gameplay/entities/DEV.it.md and ROADMAP.md.

# Development checkpoint 1.11.0-dev2

Experimental per-face texture, flat and Gouraud rendering in the Q8 comparison
room, with native pixel oracles and equal-condition route benchmarks.
See ROADMAP.md and extensions/gameplay/materials/DEV.it.md. Official release
documentation remains deferred to release preparation.

# Development checkpoint 1.11.0-dev1

- Import and consolidate two bounded billboard prototypes, with common sources.
- Add the experimental gameplay builder, presets, native checker and roadmap.
- Preserve stable1.10.2, the ordinary renderer, Mode8 and frozen demos.
- General public billboard API and the remaining gameplay roadmap are pending.

# Changelog

## 1.10.2 — 2026-10-14

Stable local promotion of qualified dev3 and the corrected performance report. Runtime/defaults/options unchanged; inherited dev1 fast block-state optimization and optional dev2 Q8 UV/arithmetic/camera/visibility retained. Mode8 remains restored bitmap, retired options rejected. Host qualification guard preserved. Stock and Turbo6510 ×64 results separated; 17 reporting regressions and full measurement identities. No new runtime experiment or GitHub publication.

Promozione stabile locale della dev3 qualificata e del rapporto corretto. Runtime/default/opzioni invariati; conservati fast dev1 e migliorie Q8 UV/aritmetica/camera/visibilità opzionali. Mode8 bitmap ripristinato, opzioni ritirate rifiutate, guardia host conservata. Prove stock e Turbo6510 ×64 separate, 17 regressioni reportistiche e identità complete. Nessun nuovo esperimento runtime o pubblicazione GitHub.

[EN](RELEASE-NOTES-1.10.2.en.md) · [IT](RELEASE-NOTES-1.10.2.it.md). Windows/VICE qualified; Linux and physical hardware untested / Linux e hardware reale non testati.

## 1.10.1 — 2026-10-13

Official maintenance source SDK, promoted from qualified 1.10.1-rc1. Engine, examples and measured PRGs unchanged by promotion. Corrected Mode7 Q8 projection sign loss, flat-light overflow, configuration/viewport, Mode8 validation/navigation and native evidence provenance, package-exact runner/native labels paths and bounded aligned allocation. Standard release contents retained; generated programs and raw qualification data remain external. Windows qualification inherited; Linux execution remains unverified. No GitHub publication in this local preparation.

Italiano: SDK sorgente ufficiale di manutenzione, promosso dalla 1.10.1-rc1 qualificata. Engine, esempi e PRG misurati invariati dalla promozione. Corretti segno proiezione Q8 e overflow luce flat Mode7, configurazione/viewport, validazione/navigazione Mode8 e provenienza catture native, runner identico al pacchetto/percorsi etichette nativi e allocazione allineata con budget. Conservato il materiale standard; programmi generati e dati grezzi restano esterni. Qualificazione Windows ereditata; esecuzione Linux non verificata. Nessuna pubblicazione GitHub nella preparazione locale.

[Official notes / Note ufficiali](RELEASE-NOTES-1.10.1.md).


<!-- maintenance-1.10.1 -->
## 1.10.1-rc1 — 2026-10-13

Local maintenance prerelease: correct Mode7 Q8 projection sign loss and flat lighting overflow; configuration precedence and optional viewport; verified capture provenance; optimized Mode8 validation and coincident heading; package-exact public runner, native labels paths, bounded allocator fallback. Preserve historical references and stock Mode8 runtime. Separate LF normalization. Native qualification and known adaptive limit are documented. No GitHub publication.

Italiano: prerelease locale di manutenzione per overflow proiezione Q8/luce flat Mode7, configurazione e viewport opzionale, provenienza catture, validazione Mode8 ottimizzata e heading coincidente, runner identico al pacchetto, percorsi etichette nativi e fallback allocatore con budget. Conservati riferimenti storici e runtime Mode8 stock. Normalizzazione LF separata. Documentate prove native e limite adattivo noto. Nessuna pubblicazione GitHub.

See / Vedere [release notes / note](RELEASE-NOTES-1.10.1-rc1.md).


## 1.10.0 — 2026-10-11

Official promotion of qualified 1.10.0-rc1. Q8 scene scalability is now released:
encoding ceilings 255 objects/255 runtime vertices with real buffer/RAM guards.
Engine and measured PRGs are unchanged; package identity and current guides
now identify the stable release. Legacy remains default, Normalized16 experimental.
See [official release notes](RELEASE-NOTES-1.10.0.md).

Italiano: promozione ufficiale della1.10.0-rc1 qualificata. Scalabilità
scene Q8 rilasciata: tetti di codifica255 oggetti/255 vertici runtime, con
controlli effettivi buffer/RAM. Engine e PRG misurati invariati; identità
pacchetto e guide correnti indicano la release stabile. Legacy default,
Normalized16 sperimentale. Vedere le [note ufficiali](RELEASE-NOTES-1.10.0.md).

Repository documentation maintenance: complete EN/IT coverage of shared reports,
contracts, examples and policies; regenerate the documentation manifest.
Version remains1.10.0; the published tag and release archive remain frozen.
No engine, scene, test implementation or measured-program changes.
Manutenzione documentazione repository: copertura EN/IT completa dei rapporti
condivisi, contratti, esempi e policy; manifest documentale rigenerato.
Versione ancora1.10.0; tag pubblicato e archivio release restano congelati.
Nessuna modifica a engine, scene, implementazione dei test o programmi misurati.

## 1.10.0-rc1 — 2026-10-11

Candidate: remove Q8 two-object/96-vertex gates, retaining byte-index ceilings
and guarded memory allocation. Range invalidation supports large single meshes.
Normalized16 keeps its own two-object/16-vertex experimental contract.
See [RC notes and qualification](RELEASE-NOTES-1.10.0-rc1.md).
EN/IT guides, CLI, quickstart and test instructions aligned to the candidate.

Italiano: candidata separata dalla release ufficiale; Q8 supera i limiti di
due oggetti/96 vertici, mantenendo tetti di codifica e controlli RAM reali.
L'invalidazione per intervallo copre anche mesh singole oltre 128 vertici.
Normalized16 conserva il contratto sperimentale di due oggetti/16 vertici.
Guide EN/IT, CLI, quickstart e istruzioni dei test allineati alla candidata.

## 1.9.0 — 2026-10-10

English: explicit experimental Normalized16 homogeneous geometry for bounded
Modes 1–7 meshes; Q8 coefficient setup, signed16 camera-space clipping and
reciprocal projection into the existing Q2 raster. Mode 7 affine only.
Legacy remains default; Q8, perspective, fast, LOD and Mode 8 retained.
Maintained generator, assembled arithmetic, native qualification and EN/IT
contract. No private demos, soundtrack or adaptive ship specialization.

Italiano: geometria omogenea Normalized16 sperimentale esplicita per mesh
limitate Mode 1–7; setup Q8, clipping camera-space signed16, proiezione reciproca
verso raster Q2. Mode 7 solo affine. Legacy default; Q8, perspective, fast, LOD
e Mode 8 conservati. Generatore mantenuto, test assembly, qualificazione nativa
e contratto EN/IT. Nessuna demo privata, musica o adattamento della navetta.

## 1.8.0 — 2026-10-08

English: safe post-visible presentation for Modes 1–7; opt-in Q8 additive hybrid line raster in Modes 1/2/5; property-derived gradual Mode 7 projective texture LOD with modal/accent far fill. Existing fast profile retained. Legacy geometry stays default; new image tradeoffs are explicit. Frozen PRG references retained with explicit historical presentation, Mode 8 untouched. No private room demo, soundtrack or scene-specific ordering promoted. New assembled tests and equivalent EN/IT contracts.

Italiano: presentazione sicura dopo l'area visibile per Mode 1–7; raster linee ibrido additivo Q8 opzionale in Mode 1/2/5; LOD graduale delle texture prospettiche Mode 7 derivato dai dati, con dominante/accento lontano. Profilo fast esistente conservato. Geometria legacy default; compromessi d'immagine espliciti. Riferimenti PRG congelati conservati con presentazione storica esplicita, Mode 8 invariata. Nessuna demo privata, colonna sonora o ordinamento specifico delle stanze promosso. Nuovi test assemblati e contratti EN/IT equivalenti.

## 1.7.0 — 2026-10-06

English: opt-in `TextureQuality fast` for Mode 7 Q8 perspective Gouraud C.
Exact block endpoints at eight pixels, affine interior, exact short tails;
even logical rows sampled and missing rows upper-duplicated within the same
VIC-II color cell. Exact retained-row edge carrier DDA, full palette-claim
order, neutral shader specialization and packed even-row carrier state.
New general generator, public cube example, assembled regression and bilingual
contract. Standard/legacy/affine and Modes 1–6/8 keep their previous references.
Scene-specific development LUT, portals, baked lighting and private demo excluded.

Italiano: `TextureQuality fast` opzionale per Mode 7 Q8 perspective Gouraud C.
Estremi esatti ogni otto pixel, interno affine, code corte esatte; righe logiche
pari campionate e righe mancanti duplicate dall'alto nella stessa cella VIC-II.
DDA carrier esatta sulle righe conservate, ordine completo delle palette,
specializzazione shader neutro e stato carrier compattato per righe pari.
Generatore generale, cubo pubblico, regressione assemblata e contratto bilingue.
Standard/legacy/affine e Mode 1–6/8 conservano i riferimenti precedenti.
LUT, portali, luce precalcolata e demo privata di sviluppo non inclusi.

## 1.6.1 — 2026-10-04

English: exact paired zero-page/unrolled UV division for nonuniform Mode 7
Q8 perspective flat/Gouraud C. Original scalar fallback, zero-denominator
behavior and pixel output preserved. Legacy/affine/unlit/all-uniform paths,
Modes 1–6/8 and previous reference hashes unchanged. Eight reserved zero-page
bytes, +673 code bytes on the measured cube. CPU cycle savings are scene-specific,
not FPS promises. New self-contained assembled UV divider regression and
bilingual scratch/memory documentation. No private demo or generated artifacts.

Italiano: divisione UV accoppiata esatta in zero page/unrolled per Mode 7 Q8
perspective flat/Gouraud C con texture non uniformi. Fallback scalare, divisore
nullo e pixel invariati. Legacy/affine/unlit/tutto uniforme, Mode 1–6/8 e hash
precedenti intatti. Otto byte zero page riservati, +673 byte codice sul cubo
misurato. Risparmi CPU specifici della scena, non promesse FPS. Nuovo test UV
assemblato autonomo e guide bilingui scratch/memoria. Nessuna demo privata o
artefatto generato incluso.

## 1.6.0 — 2026-10-03

English: optional `texturePrecision: perspective` / `-TexturePrecision perspective`
for Mode7 Q8; affine and legacy remain defaults. Exact Euclidean span setup,
leading-zero division trim, guarded narrow clipping products, full-depth
reciprocal cache, unlit rational recurrence with exact fallback, and automatic
uniform-page UV fast path. Mixed-repeat sampler dispatch targets the correct
address jump. The bounded depth1..256 WU profile stops before publishing an
invalid frame. No approximate blocks, room-specific portals, baked light,
development demo or music. Existing Mode1–8/Q8-affine output references retained.

Italiano: `texturePrecision: perspective` / `-TexturePrecision perspective`
opzionale per Mode7 Q8; affine e legacy restano default. Setup span euclideo,
divisione senza bit iniziali nulli, prodotti clipping stretti protetti, cache
reciproco per profondità completa, ricorrenza razionale unlit con fallback esatto
e fast path UV automatico per pagine uniformi. Dispatch repeat diversi corretto.
Il profilo profondità1..256 WU ferma un frame non valido prima di pubblicarlo.
Niente blocchi approssimati, portali specifici, luce precalcolata, demo di sviluppo
o musica. Riferimenti precedenti Mode1–8/Q8-affine conservati.

## 1.5.5 — 2026-09-28

- Mode 8 mono-portals: reset inside state on exit and recognize front-plane
  boundaries in adaptive refinement; matching independent host-oracle update.
- Public map contract unchanged; mono-opaque/multi PRGs, Modes 1–7 and Q8 intact.
- New executed lintel regression test and promoted portal reference identities.
- Bilingual documentation and source-package contracts updated. Legacy remains
  default; Q8 recommended above 20 MHz. No new optimization or world generator.

Italiano: Mode 8 mono-portals azzera lo stato interno all'uscita e riconosce i
confini frontali nel raffinamento; oracolo aggiornato. Contratto mappe invariato,
PRG mono-opaque/multi e Mode 1–7/Q8 intatti. Nuovo test eseguito delle architravi,
identità porte promosse, guide bilingui e contratti aggiornati. Legacy default,
Q8 consigliato sopra 20 MHz. Nessuna nuova ottimizzazione o generatore del mondo.

## 1.5.0 — 2026-09-27

- Explicit `-Precision q8` for qualified Mode 1-7 fractional geometry/clipping.
- Legacy remains the unconditional default, non-deprecated; reference PRGs and
  Mode 8 unchanged. Q8 recommended above 20 MHz; legacy at <=20 MHz.
- Bounded normal/walkLite, one/two-object profile; strict validation, isolated
  output, stationary/interactive/automatic cameras, bilingual guide and tests.
- No new optimization, public soundtrack or generated files in the source SDK.

Italiano: Q8 esplicito per geometria/clipping Mode 1-7; legacy sempre default e
non deprecato, riferimenti e Mode 8 invariati. Q8 consigliato sopra 20 MHz,
legacy fino a 20 MHz. Profilo limitato normal/walkLite, uno/due oggetti,
validazione rigorosa, output isolato, camera ferma/interattiva/automatica,
guide e test. Nessuna nuova ottimizzazione, colonna sonora pubblica o
file generato incluso nell'SDK sorgente.

## 1.4.0 — 2026-09-19

- Promote GraphicsMode 8: 2.5D, separate property-selected single-level and
  heightfield bitmap backends, 128×144 logical viewport, adaptive discontinuity
  refinement, static apertures/thickness and qualified continuous ramps.
- Public `-GraphicsMode 8 -SceneFile` dispatch, strict map contract,
  standalone assembly templates, portable build dependencies and external output.
- Three original complete maps, three editing tutorials, equivalent IT/EN
  architecture and map guides, optional scene-cost analysis.
- Preserve Mode 1–7 reference PRGs and public commands; no new rendering
  optimization. Source SDK and six-program demo archive are separate.

Italiano: promozione GraphicsMode8,2.5D con backend bitmap distinti per
monolivello e heightfield selezionati dalle proprietà, viewport logica128×144,
raffinamento adattivo delle discontinuità, aperture statiche/spessori e rampe
continue qualificate. Dispatch pubblico `-GraphicsMode 8 -SceneFile`, contratto
mappe rigoroso, template assembly autosufficienti, dipendenze build portabili
e output esterno. Tre mappe originali complete, tre tutorial completi,
guide architettura/mappe IT/EN equivalenti e analisi costi scena opzionale.
PRG di riferimento, opzioni e default Mode1–7 preservati; nessuna nuova
ottimizzazione. SDK sorgente e archivio delle sei demo separati.

## 1.3.0 — 2026-09-12

English: GraphicsMode 7 becomes official: generic affine texture mapping, unused
Gouraud-state cleanup, flat and shade-vertex lighting, compositor C texel-first
with LightFix, recovered memory layout, strict host-side PNG import, and the R1
edge-inclusion correction. Textured Gouraud now defaults to C; explicit A/B remain
available for compatibility. Modes 1–6 retain the official 1.2.0 reference output.
Eight public examples and equivalent English/Italian Mode 7, texture and PNG
guides are included. No new rendering optimization or perspective correction.

Italiano: GraphicsMode 7 diventa ufficiale: texture mapping affine generico,
rimozione dello stato Gouraud inutile, illuminazione flat e per shade vertex,
compositor C texel-first con LightFix, layout di memoria recuperato, import PNG
host-side rigoroso e correzione R1 dell'inclusione degli edge. Gouraud textured
usa ora C di default; A/B espliciti restano per compatibilità. Mode 1–6 conservano
l'output di riferimento ufficiale 1.2.0. Inclusi otto esempi pubblici e guide
Mode 7, texture e PNG equivalenti in italiano/inglese. Nessuna nuova
ottimizzazione del rendering o perspective correction.

## 1.2.0 — 2026-09-05

First official Gouraud release, promoted from the validated Gate 5 builder without
engine changes. Includes the exact Gouraud/Bayer LUT and specialized viewport clear
(Gate 1), byte-oriented span kernel (Gate 3), exact byte-seeded division (Gate 4,
no reciprocal approximation), and exact partial-byte span aggregation (Gate 5).
No Edge Fusion or hybrid flat/Gouraud implementation is included. Release metadata
and contracts identify the Gate 5 builder; historical benchmark products are not
distributed. See TESTING.md for clean-copy qualification.

Adds GraphicsMode 6, a real per-vertex Gouraud lighting path rendered through an
opaque, screen-anchored 4x4 Bayer ordered dither. The builder generates
area-weighted smoothing normals with a configurable `gouraud.creaseAngle`, keeps
hard creases through shade-vertex splits, computes 33 lighting levels, applies
reflectivity bias, and rate-limits temporal changes to four levels per simulation
tick after the first sample.

Triangles and native quadrilaterals interpolate shade across their final clipped
polygons. Camera-plane, screen, frustum, and Ground intersections carry the same
affine shade attribute. Every covered pixel uses VIC-II bitmap code `01`, `10`, or
`11`; code `00` remains background-only. Source sharing, instance material and
reflectivity overrides, source-face `solidColor`/`shading:false`, both bitmap
buffers, fixed/walkLite/walkFull cameras, and the three near profiles are supported.

Mode 6 deliberately requires `high-basic-v2` and caps runtime shade vertices at
255. Temporal Scanline Mode (`H`) remains compiled only for GraphicsMode 4 and 5.
The legacy Mode 1–5 reference programs retain their frozen SHA-256 values. New
host and x64sc/xscpu64/Turbo6510 tests, executable Mode 6 JSON references, and
`GOURAUD-MODE6-REPORT.md` document the implementation and its limits.

Italiano: prima release Gouraud ufficiale, promossa dal builder Gate5 validato
senza modifiche engine. Include LUT Gouraud/Bayer esatta e clear viewport
specializzato (Gate1), kernel span byte-oriented (Gate3), divisione esatta
inizializzata per byte (Gate4, senza reciproco approssimato) e aggregazione
esatta span a byte parziali (Gate5). Nessuna Edge Fusion o implementazione
ibrida flat/Gouraud. Metadata e contratti identificano il builder Gate5;
prodotti benchmark storici non distribuiti. Vedere TESTING.md per copie pulite.

Aggiunge GraphicsMode6: illuminazione Gouraud reale per vertice attraverso
dither Bayer4×4 opaco, ancorato allo schermo. Il builder genera normali smooth
pesate per area con `gouraud.creaseAngle` configurabile, separa gli shade
vertices sugli spigoli duri, calcola33 livelli, applica bias reflectivity e
limita le variazioni temporali a quattro livelli per tick dopo il primo campione.

Triangoli e quad nativi interpolano shade sui poligoni finali clippati.
Intersezioni piano camera, screen, frustum e Ground portano lo stesso attributo
shade affine. Ogni pixel coperto usa codici bitmap VIC-II `01`,`10`,`11`;
`00` è solo sfondo. Supportati source sharing, override materiali/reflectivity
per istanza, `solidColor`/`shading:false` sulle facce sorgenti, entrambi i buffer,
camere fixed/walkLite/walkFull e tre profili near.

Mode6 richiede `high-basic-v2` e limita a255 gli shade vertices runtime.
Temporal Scanline Mode (`H`) resta compilata soltanto nelle GraphicsMode4/5.
I programmi legacy Mode1–5 mantengono gli SHA-256 congelati. Nuovi test host e
x64sc/xscpu64/Turbo6510, riferimenti JSON Mode6 eseguibili e
`GOURAUD-MODE6-REPORT.md` documentano implementazione e limiti.

## 1.1.2 — 2026-08-18

Fixes runtime `F` toggling for the DEV7 Generic Text/FPS split. Bitmap-only frames
now select the VIC bank, Screen RAM and bitmap pointer from the displayed buffer;
the compact charset is cleared and rebuilt using a length derived from the emitted
glyph count, eliminating raw glyph pixels without a fixed 96-byte assumption. `F`
remains backward-compatible and toggles the complete Generic Text/FPS header.

Shared Mode 4/5 instances now keep the draw-time material path whenever an
instance uses `materialOverride`, so different shared instances retain their
documented material families in the actual framebuffer. The equivalent
`reflectivityOverride` path is retained independently. Runtime framebuffer
coverage now checks red/green/blue shared cubes in both Mode 4 and Mode 5; no
projection, clipping, culling or raster-timing changes are included.

High-basic-v2 builds with mobile cameras now structurally relocate the contiguous
Camera Control & Navigation block to the relocated segment ($9B80), preventing
low-segment overflow in dense WalkFull configurations while preserving full runtime
margins and zero per-frame cycle overhead.

Italiano: corregge la commutazione runtime `F` dello split Generic Text/FPS
DEV7. I frame bitmap-only selezionano banca VIC, Screen RAM e puntatore bitmap
dal buffer visualizzato; il charset compatto è azzerato e ricostruito con
lunghezza derivata dai glifi emessi, eliminando pixel raw senza ipotesi fissa
di96 byte. `F` resta compatibile e commuta l'intero header Generic Text/FPS.

Le istanze condivise Mode4/5 mantengono il percorso materiali al draw quando
usano `materialOverride`: ogni istanza conserva la famiglia documentata nel
framebuffer. Il percorso equivalente `reflectivityOverride` resta indipendente.
La copertura runtime verifica cubi condivisi rossi/verdi/blu in Mode4 e Mode5;
nessuna modifica a proiezione, clipping, culling o timing raster.

Le build high-basic-v2 con camera mobile ricollocano strutturalmente il blocco
contiguo Camera Control & Navigation nel segmento$9B80, evitando overflow del
segmento basso nelle configurazioni WalkFull dense, con margini runtime completi
e senza costo aggiuntivo di cicli per frame.

## 1.1.1 — 2026-08-15

Consolidates the validated DEV7 same-bank split-screen path into the canonical
builder. The optional text display reserves three character rows above the 3D
body, supports a compact Generic Text string on both Screen RAM buffers, and
keeps the FPS counter double-buffered. Material application preserves the first
120 screen bytes; the final raster switch uses `$4A`/`$4B` timing. The DEV7.1
mapping correction adds `$FF` termination and the correct compact indices for
the supported Generic Text glyphs. Builds made with `-NoFpsOverlay` retain the
1.1.0 binaries byte for byte. Non-engine development material is excluded.

Italiano: consolida nel builder canonico lo split-screen DEV7 nella stessa
banca, validato. Il testo opzionale riserva tre righe carattere sopra il body3D,
supporta una stringa Generic Text compatta su entrambi gli screen e mantiene
FPS in double buffer. I materiali preservano i primi120 byte screen;
lo switch raster finale usa timing `$4A`/`$4B`. La correzione mapping DEV7.1
aggiunge terminazione `$FF` e indici compatti corretti per i glifi supportati.
Le build `-NoFpsOverlay` conservano i binari1.1.0 byte per byte. Materiale di
sviluppo estraneo all'engine escluso.

## 1.1.0 — 2026-08-08

Prepares 3Dvibe64 for public source distribution on GitHub without changing the
engine builder, generated runtime, JSON API, reference PRGs, or framebuffer
signatures. The release adds complete Italian and English assembly-programmer
guides and complete Italian and English Codex-assisted vibe-coding manuals.

Software, builder code, scripts, JSON examples, validation material, and
generated engine code are now distributed for noncommercial purposes under the
PolyForm Noncommercial License 1.0.0. Documentation is distributed under
Creative Commons Attribution-NonCommercial 4.0 International. Copyright and
required attribution identify librologica.digital as author and licensor.

GitHub repository hygiene is defined by `.gitignore` and `.gitattributes`, while
`CONTRIBUTING.md` and `SECURITY.md` document contribution licensing, release
verification, and private vulnerability reporting. The package contract now
covers 44 permanent files. All text files use deterministic LF line endings,
the builder remains byte-identical to 1.0.1, and release hashes are refreshed.

Italiano: prepara la distribuzione pubblica dei sorgenti su GitHub senza
modificare builder, runtime generato, API JSON, PRG di riferimento o firme
framebuffer. Aggiunge guide complete assembly in italiano/inglese e manuali
completi di vibe coding assistito da Codex in entrambe le lingue.

Software, builder, script, esempi JSON, materiale di validazione e codice engine
generato sono distribuiti per uso non commerciale con PolyForm Noncommercial
License1.0.0. La documentazione usa Creative Commons Attribution-NonCommercial
4.0 International. Copyright e attribuzione obbligatoria identificano
librologica.digital come autore e licenziante.

`.gitignore` e `.gitattributes` definiscono l'igiene del repository;
`CONTRIBUTING.md` e `SECURITY.md` descrivono licenze dei contributi, verifiche
release e segnalazione privata di vulnerabilità. Il contratto copre44 file
permanenti. I testi usano terminatori LF deterministici, il builder è
byte-identico alla1.0.1 e gli hash release sono aggiornati.

## 1.0.1 — 2026-08-04

Synchronizes the public package version and release metadata, refreshes release
documentation, and records the final Ground validation status. Ground
projection, polygon-integrity, and roll-aware rendering fixes are retained
unchanged. Rendering pipelines, JSON 1.0 compatibility, and runtime behavior
are unchanged; the source package remains 34 permanent files.

Italiano: sincronizza versione pubblica e metadata del pacchetto, aggiorna
la documentazione release e registra lo stato finale della validazione Ground.
Conserva senza modifiche le correzioni di proiezione Ground, integrità del
poligono e rendering che tiene conto del roll. Pipeline, compatibilità JSON1.0
e runtime invariati; il pacchetto sorgente resta di34 file permanenti.

## Ground plane roll-aware rendering

The visual Ground plane now derives its clipped viewport boundary from the same
roll-aware plane equation used by Ground clipping and occlusion. Modes 3–5 use
the shared masked-span path for positive, negative, and vertical horizons, with
the filled semiplane selected consistently on either side of the plane. Mode 2
remains line-only. The Ground projection and polygon-integrity fixes are
preserved, and a deterministic 32-frame multi-roll runtime regression covers
roll 0, 32, 64, and 224 in Modes 3–5.

Italiano: il piano Ground visivo deriva il confine viewport clippato dalla
stessa equazione del piano con roll usata da clipping e occlusione Ground.
Mode3–5 usano il percorso masked-span condiviso per orizzonti positivi,
negativi e verticali, selezionando il semipiano coerente sui due lati.
Mode2 resta a sole linee. Correzioni proiezione/integrità poligono preservate;
una regressione runtime deterministica di32 frame copre roll0,32,64,224
nelle Mode3–5.

## Ground polygon integrity

Ground-clipped polygons no longer overwrite the cached projected coordinates of
the source vertex used as temporary projection storage. The cache is preserved
while each generated vertex keeps its own camera-space depth, so subsequent
faces retain their original projected vertices. This preserves the clipped
polygon's vertex order and count for Mode 4/5 rasterization; Mode 5 continues
to outline the final post-clipping polygon. The runtime framebuffer regression
uses a deterministic multi-instance crossing pose in both affected modes.

Italiano: i poligoni clippati da Ground non sovrascrivono più le coordinate
proiettate in cache del vertice sorgente usato come storage temporaneo.
La cache è preservata e ogni vertice generato mantiene la propria depth
camera-space; le facce successive conservano i vertici proiettati originali.
Sono preservati ordine e conteggio del poligono clippato nella rasterizzazione
Mode4/5; Mode5 continua a bordare il poligono finale dopo clipping.
La regressione framebuffer usa una posa deterministica con più istanze che
attraversano Ground in entrambe le modalità interessate.

## 1.0.0 — Public stable release

3Dvibe64 1.0 is the first stable public source SDK. It packages the frozen scene
builder, engine source generation, documentation, executable JSON examples, and
contract tests. No precompiled PRG is distributed: reference programs are generated
locally in temporary directories during validation.

The shared unsigned-divide helper is now emitted through a single ownership gate.
Ground `plane` and camera-plane `clip` can therefore be compiled together with fixed
or mobile cameras without a duplicate `div16u` label. Division mathematics, call
sites, clipping, projection, culling, rasterization, and visual output are unchanged.

Ground-clipped faces are now reprojected with each `clip_a` vertex's own camera-space
depth. The fixed depth 1 remains reserved for true camera-plane intersections. This
removes the stretched triangles and ribbons previously produced by Ground crossings
in GraphicsMode 4 and 5, without changing clipping mathematics, painter ordering,
culling, rasterization, or the Mode 5 outline. A deterministic 32-frame VICE runtime
contract now hashes the generated bitmap and screen RAM for both affected modes.

The public API includes GraphicsMode 1–5; fixed, walkLite, and walkFull cameras;
normal and small viewports; stable and high-basic-v2 layouts; simple and plane
Ground profiles; the `default`, `late`, and `clip` near profiles for Modes 3–5;
and `default` and `stable` face culling for Modes 4–5.

Mode 4 and Mode 5 support shared mesh sources, distinct runtime buffers for each
instance, global depth-bucket painter ordering, instance material/reflectivity/color
overrides, source-local solid face colors, true static lights, and deterministic
50-Hz declarative timelines. Mode 5 applies its one-pixel outline to the final
post-clipping polygon.

The package ships generic JSON reference scenes for wire rendering, static and
dynamic materials, shared instances with a static light and timeline, solid-color
outlines, and Ground camera-plane clipping. Their documented commands compile them
locally; they are technical examples and executable API documentation, not bundled
productions.

Italiano: 3Dvibe64 1.0 è il primo SDK sorgente pubblico stabile. Raccoglie
builder congelato, generazione sorgenti engine, documentazione, esempi JSON
eseguibili e test contrattuali. Nessun PRG precompilato distribuito: i riferimenti
sono generati localmente in directory temporanee durante la validazione.

L'helper unsigned-divide condiviso è emesso da un unico punto di gestione.
Ground `plane` e piano camera `clip` compilano insieme con camere fixed o
mobili senza duplicare `div16u`. Matematica della divisione, chiamate,
clipping, proiezione, culling, rasterizzazione e output visivo invariati.

Le facce clippate Ground sono riproiettate usando la depth propria di ogni
vertice `clip_a`. La depth fissa1 resta riservata alle vere intersezioni col
piano camera. Elimina triangoli allungati e nastri negli attraversamenti Ground
Mode4/5, senza cambiare matematica clipping, painter ordering, culling,
rasterizzazione o outline Mode5. Un contratto VICE deterministico32 frame
calcola hash bitmap/screen generate in entrambe le modalità.

L'API pubblica comprende GraphicsMode1–5, camere fixed/walkLite/walkFull,
viewport normal/small, layout stable/high-basic-v2, Ground simple/plane,
profili near `default`,`late`,`clip` Mode3–5 e face culling `default`,`stable`
Mode4/5.

Mode4/5 supportano sorgenti mesh condivise, buffer runtime distinti per istanza,
ordinamento painter globale per bucket depth, override materiali/reflectivity/
colori per istanza, colori faccia solidi locali alla sorgente, luci realmente
statiche e timeline dichiarative deterministiche a50 Hz. Mode5 applica un
outline di un pixel al poligono finale dopo clipping.

Il pacchetto include scene JSON generiche di riferimento per wire, materiali
statici/dinamici, istanze condivise con luce statica e timeline, outline solidi
e clipping Ground/piano camera. I comandi documentati le compilano localmente:
sono esempi tecnici/documentazione API eseguibile, non produzioni incluse.

## Earlier development history

The pre-1.0 development series established the renderer, clipping, one-sided
culling, static and dynamic material paths, Ground profiles, source-mesh sharing,
and the validation contracts now consolidated in this release. Historical
production-specific names and packaged binaries are intentionally not part of the
public 1.0 source SDK.

Italiano: la serie di sviluppo pre-1.0 ha definito renderer, clipping, culling
monofacciale, materiali statici/dinamici, profili Ground, condivisione delle
mesh sorgenti e contratti di validazione consolidati nella release.
Nomi storici specifici di produzioni e binari confezionati sono intenzionalmente
esclusi dall'SDK sorgente pubblico1.0.

## 1.11.0-dev8 — VIS-01 sperimentale

- Compilatore PVS conservativo per settori rettangolari, portali e stati delle porte, incluse aperture alternative.
- Profilo sector-visibility con selezione nativa prima della raccolta delle facce; apertura anche minima e casi vicini/esterni/obliqui mantengono i settori necessari.
- Confronti pixel nativi attivo/disattivo, regressioni delle capacità precedenti e FPS del percorso completo a condizioni uguali, con dati grezzi conservati.
- Nessun taglio angolare generale; scena, renderer ordinario, Mode8 e checkpoint precedenti conservano i rispettivi contratti.

## 1.11.0-dev9 — Q8-01 sperimentale

- Profilo shared-meshes: asset geometrico unico e 2–4 istanze native con posizione Q8, scala Q6, yaw a 16 bit, visibilità e ombreggiatura distinti.
- Topologia e coordinate locali condivise, cache e metadati delle facce individuali. Quattro solidi: 50 contro 200 byte sorgenti; 150 byte di RAM liberati nel confronto equivalente.
- Equivalenza pixel con controllo duplicato e stanza indipendente, trasformazioni e isolamento dei buffer verificati su VICE; FPS misurati sul giro completo a condizioni uguali.
- Renderer ordinario, Mode8 e programmi dei nove profili precedenti preservati. API generale, animazioni applicative e roll restano fuori da questa prova.

## 1.11.0-dev10 — Q8-02 sperimentale

- Clip indipendenti con comandi nativi di pausa, ripresa, stop, seek, velocità, loop, passo e riavvio; tick di simulazione indipendenti dalle viste completate.
- Roll camera di16bit sulle coordinate camera a24bit, dopo yaw/pitch e prima di proiezione/clipping; profili distinti dungeon e volo con controlli da tastiera.
- Regressioni native separate, oracoli geometrici/pixel, sorgenti immutabili, UI originale, confronto FPS a parità di percorso/qualità e budget RAM:1979byte aggiuntivi,3302liberi.
- Opzione disabled ricostruisce la dev9; i dieci profili precedenti, fondazione, engine ordinario e Mode8 restano invariati. API generale e fisica di volo restano fuori dalla prova.

## 1.11.0-dev11 — WORLD-01 sperimentale

- Caricamento reale di gruppi da file esterni tramite KERNAL e device8 filesystem di VICE; un solo gruppo attivo, staging1024byte e formato762byte con canali residenti fissi e CRC atteso.
- Transazioni esplicite e controllo errori prima dell'installazione; porte, animazioni ed eventi conservati separatamente in RAM. Due gruppi di due stanze, ritorno e variante a8gruppi qualificati nativamente.
- Preciso/LOD e UI originale; riferimenti statici indipendenti, rifiuto file errati, ripristino IRQ/zero page, confronto FPS nativo.1006byte liberi nella demo predefinita.
- I dodici profili precedenti e l'engine ordinario mantengono identità. Topologie arbitrarie, persistenza su disco, tempi1541 e integrazione pubblica restano da qualificare.

## 1.11.0-dev12 — formato comune e budget

- Formato3Dvibe64.level/1 per risorse, gruppi, stanze, oggetti, collegamenti, ingressi ed eventi; ID verificati, IR numerico, schema e asset portabili.
- Nuovo build-level.py traduce il sottoinsieme supportato su WORLD-01. Richieste future producono un piano esplicito e vengono rifiutate dal build nativo.
- Budget ricavato dall'assemblato, guardie e partizione della memoria, soglie su totale e blocchi allineati; rifiuto reale del livello8gruppi con460byte liberi e margine richiesto512.
- Stesso PRG/RAM della dev11,1006byte liberi. Individuati3759byte della UI di avvio come recupero futuro; nessun overlay attivato in questa dev. Engine ordinario, fondazione,13profili e Mode8 preservati.

## 1.11.0-dev13 — integrazione Underworld

- Tre stanze nella UI LABIRINTO, rendering preciso per pixel e60 righe, LOD14–22.
- Skeleton originale38vertici/52segmenti senza LOD geometrico e billboard contornato16x32, stessa altezza corporea15WU.
- Configurazione BB-02, animazioni a tick, eventi persistenti di prossimità/SPACE e clip cammino/attacco controllate dall'entità.
- Riuso a fasi di1516byte UI dopo init; RLE senza perdita per i frame; pose sotto I/O.
- Scarto conservativo delle stanze interamente dietro la camera, confronto nativo con lo stesso profilo senza lo scarto.
- Engine ordinario, fondazione, Mode8 e profili precedenti conservati; nessuna nuova API generale o integrazione WORLD-01 implicita.

### Correzione dev13 — cubi nella nuova Underworld

- Ripristinati i tre cubi insieme a skeleton e billboard. Dimensioni e posizioni originali; il cubo sospeso di questa variante è statico.
- Riutilizzati2904byte dopo l’avvio della UI, con coordinate Q8/schermo in aree disgiunte. Ordine compatto175byte e banda di profondità condivisa dai solidi.
- Il percorso e la qualità prospettica restano identici al precedente esperimento; misure native ed evidenze specifiche nella nuova consegna.
