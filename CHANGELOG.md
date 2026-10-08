# Changelog

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
guide e test. Nessuna nuova ottimizzazione o colonna sonora pubblica.

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

Italiano: Mode 8 ufficiale con backend distinti selezionati dalle proprietà,
viewport bitmap 128×144, aperture/spessori e rampe qualificate.
Builder pubblico, contratto rigoroso, sorgenti autosufficienti, tre mappe
originali e tre tutorial, guide IT/EN equivalenti e analisi costi opzionale.
PRG di riferimento e comandi Mode 1–7 invariati; nessuna nuova ottimizzazione.
SDK sorgente e archivio delle sei demo rimangono separati.

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

## 1.1.1 — 2026-08-15

Consolidates the validated DEV7 same-bank split-screen path into the canonical
builder. The optional text display reserves three character rows above the 3D
body, supports a compact Generic Text string on both Screen RAM buffers, and
keeps the FPS counter double-buffered. Material application preserves the first
120 screen bytes; the final raster switch uses `$4A`/`$4B` timing. The DEV7.1
mapping correction adds `$FF` termination and the correct compact indices for
the supported Generic Text glyphs. Builds made with `-NoFpsOverlay` retain the
1.1.0 binaries byte for byte. Non-engine development material is excluded.

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

## 1.0.1 — 2026-08-04

Synchronizes the public package version and release metadata, refreshes release
documentation, and records the final Ground validation status. Ground
projection, polygon-integrity, and roll-aware rendering fixes are retained
unchanged. Rendering pipelines, JSON 1.0 compatibility, and runtime behavior
are unchanged; the source package remains 34 permanent files.

## Ground plane roll-aware rendering

The visual Ground plane now derives its clipped viewport boundary from the same
roll-aware plane equation used by Ground clipping and occlusion. Modes 3–5 use
the shared masked-span path for positive, negative, and vertical horizons, with
the filled semiplane selected consistently on either side of the plane. Mode 2
remains line-only. The Ground projection and polygon-integrity fixes are
preserved, and a deterministic 32-frame multi-roll runtime regression covers
roll 0, 32, 64, and 224 in Modes 3–5.

## Ground polygon integrity

Ground-clipped polygons no longer overwrite the cached projected coordinates of
the source vertex used as temporary projection storage. The cache is preserved
while each generated vertex keeps its own camera-space depth, so subsequent
faces retain their original projected vertices. This preserves the clipped
polygon's vertex order and count for Mode 4/5 rasterization; Mode 5 continues
to outline the final post-clipping polygon. The runtime framebuffer regression
uses a deterministic multi-instance crossing pose in both affected modes.

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

## Earlier development history

The pre-1.0 development series established the renderer, clipping, one-sided
culling, static and dynamic material paths, Ground profiles, source-mesh sharing,
and the validation contracts now consolidated in this release. Historical
production-specific names and packaged binaries are intentionally not part of the
public 1.0 source SDK.
