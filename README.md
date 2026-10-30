# 3Dvibe64 1.15.1

**Stable source SDK published on GitHub. / SDK sorgente stabile pubblicato su GitHub.**
Derived from delivered `1.15.1-dev-agentic17`; renderer/public API sources and
generated programs retain their qualified bytes. Release/downloads: [v1.15.1](https://github.com/Librologica/3Dvibe64/releases/tag/v1.15.1). / Deriva dalla dev consegnata agentic17; sorgenti del renderer,
API e programmi qualificati restano identici. Release e download: [v1.15.1](https://github.com/Librologica/3Dvibe64/releases/tag/v1.15.1).

[English manual](README.en.md) · [Manuale italiano](README.it.md) ·
[Quick start / Guida rapida](QUICKSTART.md) · [Documentation / Documenti](DOCS.md) ·
[Testing / Verifiche](TESTING.md)

[Release notes EN](RELEASE-NOTES-1.15.1.en.md) · [Note IT](RELEASE-NOTES-1.15.1.it.md) ·
[Qualification EN](QUALIFICATION-1.15.1.en.md) · [Qualifica IT](QUALIFICATION-1.15.1.it.md) ·
[Status EN](RELEASE-STATUS.en.md) · [Stato IT](RELEASE-STATUS.it.md)

## Distribution / Distribuzione

Source SDK only: **no demos, no precompiled PRG**, scenes, artwork, music,
camera tours or captured images. No `examples/` or `validation/` directories.
Engine templates, tables, font and primitive generators remain source inputs.
Install tools separately; supply your own external scene/assets. / Solo
sorgenti: nessuna demo, PRG, scena, modello, media o cattura allegata. Gli input
del progetto restano esterni; template, tabelle e font del renderer sono codice
dell'engine. [External inputs EN](EXTERNAL-INPUTS.en.md) · [Input IT](EXTERNAL-INPUTS.it.md).

## Rendering contracts / Contratti grafici

GraphicsMode 1–8 retain their documented profiles. Default precision is `legacy`;
`legacy-plus`, `q8` and experimental Normalized16 are explicit. Standard texture
quality, precise lines, safe presentation and texture LOD off retain their defaults.
`legacy-plus` Mode1–7 requires walkLite, normal160×100, high-basic-v2 and
NoFpsOverlay. Mode8 is a separate128×144 map renderer. / Restano disponibili le
modalità1–8 nei rispettivi profili; non ogni combinazione è supportata.

Automatic exact source-shape optimizations inherited from agentic17 are separate
from the optional Mode4 `-LegacyPlusOptimizations` selector. Its default remains
`none`; `all` excludes wire, stream and frozen-lighting. Optional circle/sphere
APIs use `-SphereRenderer circles`, Mode4/6 plus only; default `none` emits no
additional code/RAM. No sphere JSON entities are introduced.

[Agentic optimizations EN](AGENTIC-OPTIMIZATIONS.en.md) · [Ottimizzazioni IT](AGENTIC-OPTIMIZATIONS.it.md) ·
[Exact options EN](EXACT-RENDER.en.md) · [Opzioni IT](EXACT-RENDER.it.md) ·
[Circle API EN](CIRCLE-SPHERES.en.md) · [API cerchi IT](CIRCLE-SPHERES.it.md)

`meshSourceSharing`, `FaceCullProfile`, `Mode4NearProfile`, materials, camera ABI,
near/screen clipping and the64KB budget retain their supported domains. Optional
gameplay adapters and Normalized16 retain their separate experimental status.
Historical raster details: [GOURAUD-MODE6-REPORT.md](GOURAUD-MODE6-REPORT.md).

`HeaderText` and `TEXT_HEADER_SCREEN_BYTES` retain the documented text-header
ABI: where supported, the normal body is160×88 with a three-row header. This
is separate from the legacy-plus normal160×100 profile. / L'header testuale
mantiene la propria ABI e riduce il corpo normale a160×88 nei profili supportati;
non va combinato implicitamente con il profilo plus160×100.

## Native performance / Prestazioni native

The fixed `3dvibe64-performance-v1` index is117.647645 (stable1.15.0=100), not a
universal FPS percentage. Basket, weights, scenes and target remain unchanged.
Stable rebuild:54 buildable cases/162 observations at VICE Turbo6510 PAL1×/20×/64×;
27 existing blocked combinations, no new ones; all PRG/numeric-label bytes match
agentic17. Native observations are retained by exact identity, with original
commands/cycles/images outside this source ZIP. A short-window validation4/1×
flag remains documented; three163.43s runs per side do not confirm a persistent
regression. The prior Mode7/1× timing policy and all fixed weights are retained.

L'indice non è un moltiplicatore universale di FPS. I limiti e le segnalazioni
restano nella qualifica; nessuna nuova affermazione su NTSC, Linux o hardware
fisico. Nessuna demo viene usata come sostituto della suite generale.

[Software license](LICENSE) · [Documentation license](LICENSE-DOCUMENTATION.md) ·
[Contributing](CONTRIBUTING.md) · [Security](SECURITY.md) · [RELEASE.json](RELEASE.json)
