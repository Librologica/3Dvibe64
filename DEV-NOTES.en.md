# Development and maintenance notes — 1.15.1

This stable GitHub source release promotes delivered agentic17; it does not
promote the deprecated1.15.3/1.16/1.17 work from a different historical chat.
Renderer/public API source bytes remain unchanged; prior official releases and
frozen demos are preserved. Publication is recorded in RELEASE.json, not inferred
from the intended v1.15.1 tag name.

Current automatic optimizations and optional circles are documented in
[AGENTIC-OPTIMIZATIONS](AGENTIC-OPTIMIZATIONS.en.md). Existing optional Mode4 flags,
other precisions and experimental adapters retain separate domains. The old
1.15.0 optional API qualifications are historical evidence, not current-source
hash promises. All current source hashes are in QUALIFICATION-1.15.1.json.

Do not enlarge RAM windows or weaken clipping/math to force a build. Keep
fallbacks and private helper normalization; unknown callers/layouts must retain
their original behavior. Preserve default legacy/standard/safe/LOD-off options.
The optional -SphereRenderer circles remains none by default, Mode4/6 plus only.

Native timing is inherited only after fresh PRG+all-numeric-label identity and
matching target/conditions. Correctness CPU callbacks are not FPS. Keep raw
flags, the fixed index and prior Mode7/1x policy; diagnose finite-window effects
without replacing original scores. [Tests](TESTING.en.md),
[qualification](QUALIFICATION-1.15.1.en.md), [status](RELEASE-STATUS.en.md).
