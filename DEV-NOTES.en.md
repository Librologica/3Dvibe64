# Development provenance — 1.11.0

## Distribution correction within 1.11.0

New demo projects are excluded, including their source generators, UI,
character artwork, camera routes, launchers and captured/reference assets.
The duplicated 1.10.2 SDK is removed. The original examples from v1.10.2 are
retained. This corrects the existing release; VERSION stays 1.11.0.

Reusable gameplay compilers, validators and bounded assembly emitters remain.
Native gameplay builds require an external project supplied explicitly with
`--project-source`; no demo is reconstructed from bundled default inputs.
The ordinary engine and its existing examples remain directly buildable.
See [GAMEPLAY](GAMEPLAY.en.md), [quick start](QUICKSTART.md) and
[qualification](QUALIFICATION-1.11.0.en.md).

Ordinary engine files and previous examples retain the v1.10.2 bytes. Generic gameplay functions remain under `extensions/gameplay`; project-specific sources stay in the private development checkout. No new release/version is created by the distribution correction. See [qualification](QUALIFICATION-1.11.0.en.md).
