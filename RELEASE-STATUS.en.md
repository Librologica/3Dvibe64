# Release status and support — 1.15.1

**Stable1.15.1 source release, promoted from delivered agentic17 and published on GitHub.**
Release/downloads: [v1.15.1](https://github.com/Librologica/3Dvibe64/releases/tag/v1.15.1). [RELEASE.json](RELEASE.json) is
canonical. Previous official releases and frozen demos are preserved.

The source ZIP contains renderer, reusable modules, host tools and documentation;
no demo projects, scenes, artwork, music, native PRGs, captures or dependencies.
API generators may create projects only when the caller explicitly invokes them;
no generated project is bundled.

Renderer and public API source bytes match agentic17. The stable qualification
cold-rebuilds the full catalog:54 programs at1/20/64×,27 existing blocked cases.
Only observations of identical PRGs and all numeric labels are reused. All original
FPS/p95/worst values and flags are preserved. [Qualification](QUALIFICATION-1.15.1.en.md).

This qualifies the measured PAL Turbo6510 benchmark profiles and public API4/6,
not every possible renderer/option combination. Stock NTSC, physical C64 hardware
and other hosts have no new qualification. Historical versioned reports apply to
their original programs. Normalized16 and optional gameplay adapters remain
separate experimental modules; stable packaging does not broaden their contracts.

Real64KB guards remain; oversized or unsupported combinations fail explicitly.
Mode7 at1× retains the documented prior timing tradeoff, without removing index
cells. The validation4/1× short-window flag is retained with long-window diagnosis.

[External inputs](EXTERNAL-INPUTS.en.md) · [Tests](TESTING.en.md) · [Docs](DOCS.md)
