# 3Dvibe64 1.15.0

**Stable source SDK published on GitHub.** / **SDK sorgente stabile pubblicato su GitHub.** Release and downloads: [v1.15.0](https://github.com/Librologica/3Dvibe64/releases/tag/v1.15.0). / Release e download: [v1.15.0](https://github.com/Librologica/3Dvibe64/releases/tag/v1.15.0).

[English manual](README.en.md) · [Manuale italiano](README.it.md) · [Release status EN](RELEASE-STATUS.en.md) · [Stato release IT](RELEASE-STATUS.it.md)
[Release notes EN](RELEASE-NOTES-1.15.0.en.md) · [Note release IT](RELEASE-NOTES-1.15.0.it.md) · [Docs](DOCS.md) · [Quick start](QUICKSTART.md) · [Tests](TESTING.md)

No demos/examples, no precompiled PRG, source scenes, models, audio/video or captures. Maintained renderer templates,tables and fonts are engine source inputs. Supply external scene/assets and install tools separately. / Nessuna demo,esempio,PRG,scena,modello,media o cattura. Template,tabelle e font mantenuti sono sorgenti del renderer; input esterni e strumenti installati separatamente.

|Feature / Funzione|Contract / Contratto|
|---|---|
|`legacy`|Unchanged default / Default invariato|
|Ordinary `legacy-plus`|Mode1–7, camera Q4/Q10, near8 polygon/screen; Mode7 affine/perspective within documented profile|
|`-LegacyPlusOptimizations all`|Mode4 plus only: arithmetic,edges,spans,outcodes,convex,integer-edges; default none|
|`wire`,`stream`|Explicit main-pass APIs, excluded from all; stream requires outcodes and caller-owned slots|
|`frozen-lighting`|Separate appearance option, excluded from all; first-active-pose colors with explicit invalidation|
|Compact keyframes|Optional lossless signed16 codec; total code+data RAM must be evaluated|
|`q8`|Existing explicit renderer / Renderer esplicito esistente|
|Normalized16 / gameplay|Separate bounded experimental modules; not automatically promoted / Moduli sperimentali separati|

GraphicsMode 1–8 remain available in their documented profiles. New1.15.0 kernels/APIs require **Mode4 legacy-plus,walkLite,normal160×100,high-basic-v2,NoFpsOverlay,near8/poly,no Ground**. This does not extend them to Q8 or every graphics mode. Real64KB allocation remains mandatory; oversized combinations fail. / I nuovi kernel/API richiedono il profilo indicato; nessuna estensione implicita a Q8 o ad altri modi. Allocazione reale64KB, combinazioni troppo grandi rifiutate.

`all` contains six automatic exact options and excludes wire,stream,frozen-lighting. Default legacy/Q8 behavior,resolution,palette,safe presentation and sampling remain unchanged. No alternate scanlines. / Default,precisione,risoluzione,palette e presentazione conservati; nessuna riga alternata.

[Exact options EN](EXACT-RENDER.en.md) · [Opzioni IT](EXACT-RENDER.it.md) · [Reusable API EN](REUSABLE-RENDER.en.md) · [API IT](REUSABLE-RENDER.it.md)
[Qualification EN](QUALIFICATION-1.15.0.en.md) · [Qualifica IT](QUALIFICATION-1.15.0.it.md) · [RELEASE.json](RELEASE.json)

Promotion retains qualified1.15.0-dev2 runtime bytes. Measurements are inherited from the exact same PRGs: VICE Turbo6510 PAL×64,safe,silent fixtures. They are not stock-C64,NTSC,physical-hardware or new timing claims. The wire fixture's +27.23% is not a shuttle-demo FPS claim. / Misure conservate della dev qualificata sugli stessi PRG; nessuna nuova misura o promessa universale.

Ordinary legacy/plus writes into a fresh complete SDK working copy's work/ and rejects -OutputDirectory; Q8/Normalized16/Mode8 support external output directories. Existing APIs include meshSourceSharing,FaceCullProfile,Mode4NearProfile and HeaderText. HeaderText uses the160×88 split with TEXT_HEADER_SCREEN_BYTES. Historical raster details: [GOURAUD-MODE6-REPORT.md](GOURAUD-MODE6-REPORT.md).

[Software license](LICENSE) · [Documentation license](LICENSE-DOCUMENTATION.md) · [Contributing](CONTRIBUTING.md) · [Security](SECURITY.md)
