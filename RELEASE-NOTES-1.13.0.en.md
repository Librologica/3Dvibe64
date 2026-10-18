# Release notes — 1.13.0

Stable engine source release published on GitHub.
Adds the opt-in `-Precision legacy-plus` pipeline from the qualified dev7.
Legacy/default remains byte-compatible. Q8, Normalized16, Mode8, old rotation
and gameplay adapters keep their existing scopes; experimental features remain
experimental.

Legacy-plus combines finer Q4/Q10 camera rotation with corrected source-edge
wire clipping, fractional near intersections and Q4 screen clipping. Original
integer geometry buffers/raster remain. The last rounding-loop expansion
removes the observed59.85ms camera interval without changing numeric results;
the qualified maximum/p95 are39.90ms. Native camera25.06227FPS, clipping41.19121FPS
on PAL Turbo6510 ×64.658 frozen native images are identical to dev6. Native data
are reused only after exact rebuild of the measured PRGs from this release.

This is a source-only package: no demos, examples, scenes, routes, projects,
artwork, music, PRGs, captures, logs, tools executables or test environments.
Reusable engine templates/fonts and small mathematical unit fixtures remain.
The new current IT/EN catalog includes all legacy profiles, ABI, limits,
external inputs, public tests and qualification; earlier versioned reports
remain historical. Existing releases and frozen projects are untouched.

[Legacy-plus contract](LEGACY-PLUS.en.md) · [Qualification](QUALIFICATION-1.13.0.en.md)
[Quick start](QUICKSTART.md) · [Documentation](DOCS.md) · [Testing](TESTING.md)
