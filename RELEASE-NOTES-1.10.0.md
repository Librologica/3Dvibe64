# 3Dvibe64 1.10.0 — Q8 scalability / scalabilità Q8

Official source SDK, promoted from the qualified 1.10.0-rc1. Engine sources,
examples and measured PRGs are byte-identical to the qualified candidate;
promotion changes documentation and package identity only. Legacy remains default.

Q8 removes the former two-object/96-runtime-vertex qualification gates and
accepts disjoint object ranges up to 255 objects/255 runtime vertices, subject
to real source/runtime face, edge, shade-buffer and RAM guards. These are
encoding ceilings, not guaranteed scene capacities. Single meshes above 128
vertices use range-based invalidation. Q8 arithmetic, projection, clipping and
Q2 raster remain unchanged. Normalized16 remains experimental: two objects and
16 runtime vertices. Q8 shared source meshes, Ground, timeline and camera roll
remain outside the supported scope.

Qualification: 23 native PAL/NTSC builds, 16 native/6502 same-pose comparisons
with zero recorded differences, 8,224 independently checked projected vertices
(maximum observed error 0.46923 logical pixels), 42 historical Q8 binaries
unchanged and 12 selected public scripts passed. This is not a new execution
of all 23 inherited scripts. Official package contract and world-metrics checks
are rerun on a clean copy. Native FPS remains tied to the exact measured PRG
hashes: the two-object Mode 5 PAL baseline and expanded backend both measured
27.02026 FPS, p95/worst interval 39.901 ms, VICE Turbo6510 ×64, no SID/overlay,
2.014981 s warm-up and 20.429114 s measurement. Full matrix and protocol:
[Q8 qualification](Q8-QUALIFICATION.md).

SDK sorgente ufficiale, promosso dalla 1.10.0-rc1 qualificata. Engine, esempi
e PRG misurati restano byte-identici; cambiano documentazione e identità del
pacchetto. Legacy resta il default. Q8 supera due oggetti/96 vertici fino ai
tetti di codifica 255 oggetti/vertici runtime, subordinati ai controlli reali
di buffer e RAM. Non è una promessa di capacità per ogni modalità. Nessuna
riduzione di precisione. Normalized16 conserva due oggetti/16 vertici.
Le release precedenti e le demo congelate sono preservate.

[Q8 contract / Contratto Q8](Q8-SCALABILITY.md) ·
[Examples and expected refusals / Esempi e rifiuti attesi](examples/README.md) ·
[Tests / Test](TESTING.md).
