# Note di release — 1.15.1

Release stabile GitHub di soli sorgenti,30 ottobre2026. Promossa dalla dev
consegnata agentic17 e pubblicata come v1.15.1. Nessuna demo, esempio,
scena, media o PRG allegato. Renderer, template, matematica e API coincidono con
la dev; vengono aggiornati documentazione, versione e controlli della release.

Rispetto alla1.15.0 ufficiale include passaggi generali esatti di rotazione,
proiezione, span/materiali, wire, Gouraud e Mode7-C affine sviluppati fino a17,
cache per piano Mode8 multi e API opzionale cerchi/sfere4/6. Non amplia ogni
profilo/precisione né abilita automaticamente i flag Mode4 opzionali.
[Contratti dettagliati](AGENTIC-OPTIMIZATIONS.it.md).

Restano i default legacy, texture standard, linee precise, presentazione safe,
LOD off, LegacyPlusOptimizations none e SphereRenderer none. Nessuna modifica
al carico/qualità o selezione implicita di backend. Restano allocazione reale64KB
e fallback. Mode8 usa485 byte cache dati e85 byte helper prima del font,
entro guardie; auto/interactive pubblici restano compilabili.

Indice fisso117,647645 rispetto alla stabile1.15.0=100 (+17,647645% composito),
non un guadagno FPS universale. Ricompilazione stabile completa:54 PRG/etichette
numeriche identici,162 osservazioni native conservate a1/20/64×;27 blocchi
preesistenti. Immagini e segnalazioni restano conservate. Le misure appartengono
agli stessi programmi qualificati: non sono nuove misure né replay CPU.
Nessuna nuova qualifica NTSC stock, hardware fisico o Linux.
[Qualifica completa](QUALIFICATION-1.15.1.it.md).

Manuali consolidati in entrambe le lingue: niente pile di banner dev nei testi
correnti; verificati Unicode, stato locale/pubblicazione, percorsi source-only,
memoria, domini API e perimetro test. I rapporti storici conservano misure e
versioni originali, senza prevalere sui contratti correnti.
