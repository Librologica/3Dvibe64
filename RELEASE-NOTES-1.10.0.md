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

## Italiano

SDK sorgente ufficiale, promosso dalla 1.10.0-rc1 qualificata. Sorgenti engine,
esempi e PRG misurati sono byte-identici alla candidata qualificata; la
promozione modifica soltanto documentazione e identità del pacchetto.
Legacy resta il default.

Q8 elimina i precedenti limiti di qualificazione di due oggetti/96 vertici
runtime e accetta intervalli disgiunti fino a 255 oggetti/255 vertici runtime,
subordinati ai controlli reali su facce sorgenti/runtime, edge, shade buffer
e RAM. Sono tetti di codifica, non capacità garantite per una scena. Le mesh
singole oltre 128 vertici usano invalidazione per intervallo. Aritmetica Q8,
proiezione, clipping e raster Q2 restano invariati. Normalized16 rimane
sperimentale: due oggetti e 16 vertici runtime. Mesh sorgenti condivise,
Ground, timeline e roll camera restano fuori dall'ambito Q8 supportato.

Qualificazione: 23 build native PAL/NTSC, 16 confronti nativi/6502 alla stessa
posa con zero differenze registrate, 8224 vertici proiettati verificati
indipendentemente (errore massimo osservato 0,46923 pixel logici), 42 binari
Q8 storici invariati e 12 script pubblici selezionati superati. Non è una nuova
esecuzione di tutti i 23 script ereditati. Contratto del pacchetto ufficiale e
metriche del mondo sono ricontrollati su una copia pulita. Gli FPS nativi
restano legati agli hash esatti dei PRG misurati: baseline PAL Mode5 a due
oggetti e backend ampliato hanno entrambi misurato 27,02026 FPS, intervallo
p95/peggiore 39,901 ms, VICE Turbo6510 ×64, senza SID/overlay, warm-up 2,014981 s
e misura 20,429114 s. Matrice completa e protocollo:
[qualificazione Q8](Q8-QUALIFICATION.md).

Historical releases and frozen demos are preserved.
Le release precedenti e le demo congelate sono preservate.

[Q8 contract / Contratto Q8](Q8-SCALABILITY.md) ·
[Examples and expected refusals / Esempi e rifiuti attesi](examples/README.md) ·
[Tests / Test](TESTING.md).
