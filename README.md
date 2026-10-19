# 3Dvibe64 1.15.0-dev1

Dev locale non pubblicata per la futura release stabile. / Unpublished local development for a future stable release.

[Italiano](EXACT-RENDER.it.md) · [English](EXACT-RENDER.en.md) · [Qualifica](QUALIFICATION-1.15.0-dev1.it.md)

# 3Dvibe64 1.14.0

Stable **source SDK**, no demos/examples, no precompiled PRG, music, scene
projects or captures. / **SDK sorgente** stabile, senza demo/esempi,
PRG, musica, progetti scena o catture. Source repository / Repository sorgente: [GitHub](https://github.com/Librologica/3Dvibe64). Stable release / Release stabile: [v1.14.0](https://github.com/Librologica/3Dvibe64/releases/tag/v1.14.0). Upstream: [GitHub](https://github.com/Librologica/3Dvibe64). Previous releases and frozen projects remain untouched.

| Precision | Contract / Contratto |
|---|---|
| `legacy` | Default historical renderer, preserved / Renderer storico predefinito, preservato |
| `legacy-plus` | Explicit intermediate Mode1–7, Q4 near/screen, Mode7 affine/perspective / Mode1–7 intermedie, near/schermo Q4, Mode7 affine/prospettica |
| `q8` | Existing explicit Q8 renderer / Renderer Q8 esplicito esistente |
| `normalized16` | Existing experimental profile / Profilo sperimentale esistente |

[English manual](README.en.md) · [Manuale italiano](README.it.md)
[Quick start / Guida rapida](QUICKSTART.md) · [All contracts / Tutti i contratti](DOCS.md)
[Release notes EN](RELEASE-NOTES-1.14.0.en.md) · [Note release IT](RELEASE-NOTES-1.14.0.it.md)
[Qualification EN](QUALIFICATION-1.14.0.en.md) · [Qualificazione IT](QUALIFICATION-1.14.0.it.md)
[Testing / Test](TESTING.md) · [External inputs EN](EXTERNAL-INPUTS.en.md) · [Input esterni IT](EXTERNAL-INPUTS.it.md)

GraphicsMode 1–8 remain available within their documented profiles. Legacy-plus
requires Mode1–7/walkLite/normal/high-basic-v2/-NoFpsOverlay; its native
qualification is PAL Turbo6510 ×64, safe, silent, no Ground. It is not a rotation
alias or a Q8 backend. Full ABI, memory, clipping and input limitations are in
[LEGACY-PLUS.en.md](LEGACY-PLUS.en.md) / [LEGACY-PLUS.it.md](LEGACY-PLUS.it.md).

Inherited APIs include meshSourceSharing, FaceCullProfile, Mode4NearProfile and
HeaderText; the text split is160×88 with TEXT_HEADER_SCREEN_BYTES. Gameplay,
Normalized16 and Mode8 keep their separate scopes. The historical raster contract
is in [GOURAUD-MODE6-REPORT.md](GOURAUD-MODE6-REPORT.md). Use external scenes/assets and a fresh complete SDK working copy for ordinary
legacy/plus; Q8/Normalized16/Mode8 accept an external output directory; engine assembly templates/fonts are
maintained source inputs, not demos. Build tools are installed separately.

Le GraphicsMode 1–8 restano disponibili nei rispettivi profili. Legacy-plus
richiede Mode1–7/walkLite/normal/high-basic-v2/-NoFpsOverlay; qualifica nativa
PAL Turbo6510 ×64, safe, silenziosa, senza Ground. Non è un alias rotation né
un backend Q8. Usare input esterni e una copia SDK nuova per legacy/plus; template/font
dell'engine sono sorgenti mantenuti. Strumenti di build installati separatamente.

[Software license](LICENSE) · [Documentation license](LICENSE-DOCUMENTATION.md)
[Contributing / Contribuire](CONTRIBUTING.md) · [Security / Sicurezza](SECURITY.md)

Private Underworld optimizations remain application-specific and excluded. / Le ottimizzazioni private Underworld restano specifiche dell’applicazione ed escluse. See / Vedere [release notes](RELEASE-NOTES-1.14.0.md).
