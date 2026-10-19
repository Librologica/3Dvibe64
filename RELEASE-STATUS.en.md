# Release status and support — 1.15.0

**1.15.0 is the stable release published on GitHub.** [Release page and downloads](https://github.com/Librologica/3Dvibe64/releases/tag/v1.15.0). Repository and metadata identify the same version. Canonical state: [RELEASE.json](RELEASE.json). Public tag: `v1.15.0`.

Stable identifies the SDK version and its qualified contracts. It does not make bounded profiles universal or experimental modules mature. Archived qualifications retain their own version and do not establish publication of this release.

|Feature|Status in1.15.0|
|---|---|
|Default renderer|`legacy`, unchanged; no automatic plus/Q8 selection|
|Ordinary legacy-plus|Mode1–7, including affine/perspective Mode7, within documented profiles|
|New exact optimizations|Opt-in, only Mode4 legacy-plus/walkLite/normal160×100/high-basic-v2/NoFpsOverlay, near8/poly, no Ground|
|`all`|`arithmetic,edges,spans,outcodes,convex,integer-edges`|
|`wire` and `stream` APIs|Excluded from `all`; explicit main-pass calls; `stream` requires `outcodes` and caller-owned resident slots|
|`frozen-lighting`|Excluded from `all`; explicit appearance option, not equivalence with moving lights; nonshared objects|
|Compact keyframes|Optional lossless signed16 codec; count decoder+scratch+data together; no guaranteed FPS gain|
|Q8, Mode8 and gameplay|Separate contracts; no implicit transfer of these APIs to other backends|
|Normalized16 and experimental gameplay|Remain experimental within their limits; a stable SDK version does not promote them automatically|

No demos, examples, scenes, models, music, video, captures or compiled programs are included. Maintained renderer tables/fonts/templates are engine source inputs. Supply external inputs and install build tools separately. New options consume real64KB RAM; oversized combinations may be refused. A64KB memory layout does not establish stock-C64 FPS qualification.

Runtime is identical to qualified1.15.0-dev2 (`ccc7d62a03d250a606f3aab6e246ba11af6bc94f`). Promotion changes documentation, version, metadata and host distribution checks only. Retained measurements are VICE Turbo6510 PAL×64,safe,silent fixtures: they are not new timing runs,NTSC,stock-C64 or physical-hardware qualification. Exact release PRG rebuild identities and clean-ZIP gates are recorded in the external release receipt.

[Release notes](RELEASE-NOTES-1.15.0.en.md) · [Qualification](QUALIFICATION-1.15.0.en.md) · [Options](EXACT-RENDER.en.md) · [ABI/limits](REUSABLE-RENDER.en.md) · [Tests](TESTING.md).
