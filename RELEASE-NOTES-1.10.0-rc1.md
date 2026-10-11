# 3Dvibe64 1.10.0-rc1 — Q8 scalability / scalabilità Q8

Historical RC notes: this candidate was promoted to [official 1.10.0](RELEASE-NOTES-1.10.0.md).
Note storiche RC: candidata promossa alla 1.10.0 ufficiale.

At candidate publication: release candidate; official 1.9.0 remains stable. Legacy remains the default.
Q8 accepts disjoint object ranges beyond the former two-object/96-vertex gates,
up to the existing 255 object/runtime-vertex encoding ceilings. Every scene
must pass real source/runtime face, edge, shade-buffer and RAM guards.
Single meshes above 128 vertices use range-based invalidation.
Q8 arithmetic, projection, clipping and the Q2 raster contract are retained.
Normalized16 remains experimental: at most two objects/16 runtime vertices.
Shared source meshes, Ground, timeline and camera roll are not added to Q8.

Candidata; la 1.9.0 ufficiale resta stabile e legacy resta il default.
Q8 supera i limiti di due oggetti/96 vertici, fino ai tetti di codifica 255
oggetti/vertici runtime, con controlli reali su buffer e RAM per ogni scena.
Le mesh singole oltre 128 vertici usano invalidazione per intervallo.
Aritmetica Q8, proiezione, clipping e raster Q2 conservati. Normalized16 resta
sperimentale: due oggetti/16 vertici. Nessuna estensione Q8 a mesh sorgenti
condivise, Ground, timeline o roll camera.

[Contract / Contratto](Q8-SCALABILITY.md) · [Measured qualification / Qualificazione misurata](Q8-QUALIFICATION.md).
Build examples and expected refusals are documented in [examples](examples/README.md).
The documentation revision corrects package/version labels, all three Precision
CLI choices and test scope; it changes no measured engine program.
La revisione documentale corregge versioni, tre scelte CLI Precision e ambito
dei test; nessun programma engine misurato viene modificato.
