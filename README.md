# 3Dvibe64 1.11.0

Official source SDK / SDK sorgente ufficiale.
Existing 1.11.0 distribution corrected: no newly added demos, including sources/assets.
Corretta la distribuzione 1.11.0: esclusi i nuovi demo, anche sorgenti e asset.

- [English manual](README.en.md) · [Manuale italiano](README.it.md)
- [Documentation index / Indice documentazione](DOCS.md)
- [Release notes EN](RELEASE-NOTES-1.11.0.en.md) · [Note IT](RELEASE-NOTES-1.11.0.it.md)
- [Gameplay EN](GAMEPLAY.en.md) · [Gameplay IT](GAMEPLAY.it.md)
- [Quick start / Guida rapida](QUICKSTART.md) · [Testing / Test](TESTING.md)

GraphicsMode 1–8: wire/hidden wire, flat, GraphicsMode 5 solid/outline,
GraphicsMode 6 Gouraud, Mode 7 affine/projective textures and Mode 8 bitmap 2.5D.
Ordinary runtime/defaults are preserved from 1.10.2. Gameplay extensions include
configured billboards, entities/door, mixed materials, texture animation,
static lighting, sector visibility, source sharing, controlled clips/roll,
room groups and common level authoring, within documented profile boundaries.

Sorgenti senza PRG precompilati: **no precompiled PRG**, video, music or demo
archives. Only preexisting examples are retained; new project inputs are external.
Conservati soltanto gli esempi preesistenti; input dei nuovi progetti esterni.

The ordinary options `Mode4NearProfile`, `FaceCullProfile`, `meshSourceSharing`,
and the mode-specific limits are documented in both manuals. Q8-01 source
sharing is a separate adapter. `HeaderText` enables the `160×88` text split;
`TEXT_HEADER_SCREEN_BYTES` is its assembly ABI. See
[Gouraud Mode 6 report](GOURAUD-MODE6-REPORT.md), [assembly EN](ASSEMBLY-GUIDE.en.md)
and [assembly IT](ASSEMBLY-GUIDE.it.md).

Verified host / Host verificato: Windows, PowerShell 7, Python 3.13,
64tass 1.60.3243; Pillow for PNG/UI and py65 for routine tests.
Default / Default: legacy, TextureQuality standard, LineRaster precise,
TextureLOD off, FramePresentation safe. Mode 8 and the sealed 1.10.2
foundation retain their own contracts. [Qualification EN](QUALIFICATION-1.11.0.en.md)
· [Qualificazione IT](QUALIFICATION-1.11.0.it.md).

Copyright 2026 librologica.digital. Software: [PolyForm Noncommercial 1.0.0](LICENSE).
Documentation / Documentazione: [CC BY-NC 4.0](LICENSE-DOCUMENTATION.md).
