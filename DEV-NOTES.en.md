# Development notes — 1.13.0

This stable release promotes the unchanged dev7 engine, not a new
arithmetic experiment. Default legacy stays historical; legacy-plus is explicit
and bounded. Prior developments isolated winding/origin errors, camera position
rounding, angular steps, source-edge clipping, near fractional loss, signed screen
span limits and the missed camera presentation slot. Their final integration is
documented in the current legacy-plus contract and qualification. Compatibility
profiles remain separate. Existing releases/frozen demos are preserved. Sources are published on GitHub
without bundled examples. Normalized16/gameplay limitations remain.

[Release notes](RELEASE-NOTES-1.13.0.en.md) · [Legacy-plus](LEGACY-PLUS.en.md)
[Qualification](QUALIFICATION-1.13.0.en.md) · [Tests](TESTING.md)
