# Development and maintenance notes — 1.20.0

> Stable source SDK 1.20.0, promoted from agentic36. Published on GitHub. [Qualification](QUALIFICATION-1.20.0.en.md).


The active development adds AnimatedMesh v1 to delivered agentic23. Read [AGENTIC24](AGENTIC36.en.md) and [the full API contract](ANIMATED-MESH.en.md). Current hashes and native results belong to QUALIFICATION-1.20.0.json. Earlier versioned qualification files remain immutable history. No deprecated 1.15.3/1.16/1.17 work is used or promoted.

Do not enlarge RAM windows or weaken clipping/math to force a build. Keep
fallbacks and private helper normalization; unknown callers/layouts must retain
their original behavior. Preserve default legacy/standard/safe/LOD-off options.
The optional -SphereRenderer circles remains none by default, Mode4/6 plus only.

Native timing is inherited only after fresh PRG+all-numeric-label identity and
matching target/conditions. Correctness CPU callbacks are not FPS. Keep raw
flags, the fixed index and prior Mode7/1x policy; diagnose finite-window effects
without replacing original scores. [Tests](TESTING.en.md),
[qualification](QUALIFICATION-1.20.0.json), [status](RELEASE-STATUS.en.md).
