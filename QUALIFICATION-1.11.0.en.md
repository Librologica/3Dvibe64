# Qualification — 3Dvibe64 1.11.0

Official local source release derived from 1.11.0-dev13/cubes-restored;
publication online is deferred. This document separates the release audit
from historical native measurements. The machine-readable result is
[QUALIFICATION-1.11.0.json](QUALIFICATION-1.11.0.json); final delivery is accepted
only when its status is PASS and archive/manifest verification succeeds.

## What changes and what remains identical

Identity, current bilingual documentation, release assertions and tooling
are promoted to 1.11.0. Host packaging/capture tools honor configured external
assembler/emulator paths; these path changes do not alter 6502 renderer code.
The ordinary builder is SHA 256
`79510B085B6B786A87F2F2814B2BED0FE2C95313EDAF0A3C121B89EA02C9C14F`.
The 80 ordinary work files, Mode 8 backend and embedded foundation 1.10.2 are
preserved against the qualified development baseline. Compiled outputs are
verification material outside the source checkout and are not distributed.

## Release gate coverage

The full clean-copy suite in [TESTING](TESTING.md) covers public package,
legacy arithmetic/rendering references, Q8/Normalized 16, Mode 7 textures/fast/
LOD/lines/presentation, Mode 8 validation/native bitmap/provenance and mandatory
qualification checks. New gameplay gates cover all configuration compilers,
graphs, references, static bake and actual memory maps. Documentation audit
checks paired EN/IT references, every profile/configuration option, local
links and absence of compiled/demo assets. Every gate's actual outcome is
recorded in the result JSON; a missing executable is not a successful test.

All 13 gameplay presets are rebuilt separately, with hashes compared against
their retained checkpointPRGSHA 256. Common level program/group files are
compared to the WORLD-01 checkpoint; the separate integration is compared
to corrected dev13 hash
`249D99C34BA0A50C318A1577F07E632ACD3BEEE299E3AFEDCDDDD31966B6FA2E`.
This protects source profile/version promotion and host path changes without
learning new expected renderer hashes. Commands, tool identities, native
captures and rebuild evidence remain in the local external release reports.

## Native measurement reuse and limits

Existing native evidence is inherited only for byte-identical programs at
the same target, launcher/options, music and camera route. Rebuilding a source
package does not make those old measurements newly acquired. Ordinary 1.10.2
stock/Turbo PAL/NTSC matrices are described in its versioned release notes.
Gameplay values apply to their individual bounded scenes, not all engine use.

Corrected integration: VICE Turbo6510 PAL× 64,silent,filter 0,Colodore,
safe raster 252,101 refresh/2.014981 s warm-up,6400 refresh/127.681964 s measured,
full 96-key/6144 tick route.691 new complete views,5.411884 FPS,p 95=219.453 ms,
worst=299.255 ms. The culling-disabled matched scene also measured 5.411884 FPS.
Without the three cubes the earlier scene measured 5.748658 FPS; different
geometry prevents interpreting that difference as isolated optimization.
Original commands/hash/raw are preserved in the development delivery.

The source release ships no PRG or demo archive. Representative programs are
rebuilt for verification only. Any future renderer/scene change requires its
own native correctness/FPS evidence:≥20 emulated seconds after warm-up, full
route preferred, only newly presented complete views, raw/command/hash and
p 95/worst. Warp, host elapsed time and CPU routine replay are not FPS sources.

## Qualification boundaries

Windows/PowerShell 7/Python 3.13/64tass 1.60.3243, Pillow 12.3.0,py65 1.2.0.
Native tools include stock x64sc/xscpu64 and Turbo6510; exact identities are
recorded in external reports. No new Linux or physical C64/1541 qualification.
No arbitrary combined-feature topology/intersection or universal memory-fit
claim. Common WORLD-01 UI 3759 byte recovery is unapplied;2904 byte reuse exists
only in the separate integration. See [roadmap](ROADMAP.en.md).

Versioned historical reports retain their measured values/scope. Current
contracts: [README](README.en.md), [gameplay](GAMEPLAY.en.md), [index](DOCS.md).
[Italiano](QUALIFICATION-1.11.0.it.md).

## Final release result

All 41 required gates passed, including the corrected full package/native
rerun. All 15 checkpoint rebuilds are byte-identical; all six quick-start
checks passed. Initial failure and its resolution remain recorded in the
JSON/external logs. Final archive, extracted inputs and committed source are
checked independently during sealing; compiled verification outputs stay out
of the distribution.
