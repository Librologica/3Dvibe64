# Release notes — 1.15.1

Stable GitHub source release,30 October2026. Promoted from delivered agentic17;
published as v1.15.1. No demos, examples, scenes, media or PRGs
attached. Renderer, templates, math and public API bytes are unchanged from
that development; documentation/version/release checks are maintained.

Compared with official1.15.0, this includes the generic exact rotation/projection,
solid/material, wire, Gouraud and affine Mode7-C passes developed through17,
the per-plane Mode8 multi cache and optional circle/sphere API4/6. They do not
broaden every precision/profile or automatically enable the optional Mode4 flags.
[Detailed contracts](AGENTIC-OPTIMIZATIONS.en.md).

Defaults remain legacy, standard texture quality, precise lines, safe
presentation, LOD off, LegacyPlusOptimizations none and SphereRenderer none.
No workload/image-quality change or default backend switch. Real64KB allocation
and parent fallbacks remain. Mode8 uses485 cache-data bytes plus85 helper-code
bytes in bounded font-adjacent space; public auto/interactive remain buildable.

Fixed benchmark index:117.647645 vs stable1.15.0=100 (+17.647645% composite).
This is not universal FPS gain. Full stable cold rebuild:54 matching PRGs/all
numeric labels,162 retained native observations at1/20/64×;27 existing blocks.
All images/flags are preserved. Native observations originate from the identical
qualified programs, not a new timing run or CPU replay. No fresh stock NTSC,
physical hardware or Linux qualification. [Full qualification](QUALIFICATION-1.15.1.en.md).

Documentation is consolidated in both languages: current guides no longer stack
development banners; Unicode, release/publication state, source-only paths,
memory, API domains and test scopes are checked. Historical reports keep their
original measurements and do not override current contracts.
