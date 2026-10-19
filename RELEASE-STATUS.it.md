# Stato della release e supporto — 1.15.0

**La1.15.0 è la release stabile pubblicata su GitHub.** [Pagina release e download](https://github.com/Librologica/3Dvibe64/releases/tag/v1.15.0). Il repository e i metadati identificano la stessa versione. Stato canonico: [RELEASE.json](RELEASE.json). Il tag pubblico è `v1.15.0`.

Stabile descrive la versione dell'SDK e i contratti qualificati, non rende universali i profili limitati o maturi i moduli ancora sperimentali. Le qualifiche storiche sono archiviate con la loro versione e non documentano una pubblicazione di questa release.

|Funzione|Stato nella1.15.0|
|---|---|
|Renderer predefinito|`legacy`, invariato; nessuna selezione automatica di plus o Q8|
|Legacy-plus ordinario|Mode1–7, incluse texture Mode7 affini/prospettiche, nei profili documentati|
|Nuove ottimizzazioni esatte|Opt-in, solo Mode4 legacy-plus/walkLite/normal160×100/high-basic-v2/NoFpsOverlay, near8/poly, senza Ground|
|`all`|`arithmetic,edges,spans,outcodes,convex,integer-edges`|
|API `wire` e `stream`|Escluse da `all`; chiamate esplicite nel passaggio principale; `stream` richiede `outcodes` e slot posseduti dal chiamante|
|`frozen-lighting`|Esclusa da `all`; opzione estetica esplicita, non equivalenza con luci in movimento; oggetti non condivisi|
|Chiavi compatte|Codec opzionale signed16 senza perdita; valutare decoder+scratch+dati, nessun aumento FPS garantito|
|Q8, Mode8 e gameplay|Contratti separati; nessun trasferimento implicito delle nuove API agli altri backend|
|Normalized16 e gameplay sperimentale|Restano sperimentali nei rispettivi limiti; non promossi automaticamente dalla versione stabile|

Non sono inclusi demo, esempi, scene, modelli, musica, video, catture o programmi compilati. Le tabelle/font/template mantenute dell'engine sono sorgenti del renderer. Fornire input esterni; gli strumenti di compilazione vanno installati separatamente. Le nuove opzioni consumano RAM reale nei64KB: il compilatore può rifiutare combinazioni troppo grandi. Memoria64KB non equivale a una qualifica FPS su C64 stock.

Il runtime è identico alla dev qualificata1.15.0-dev2 (`ccc7d62a03d250a606f3aab6e246ba11af6bc94f`). La promozione cambia solo documentazione, versione, metadati e controlli host della distribuzione. Le misure conservate provengono da VICE Turbo6510 PAL×64, safe, fixture silenziose; non sono nuove acquisizioni, prove NTSC, misure sul C64 stock o sull'hardware fisico. Gli hash dei PRG ricompilati e i controlli dello ZIP esatto sono nella ricevuta di rilascio esterna.

[Note release](RELEASE-NOTES-1.15.0.it.md) · [Qualifica](QUALIFICATION-1.15.0.it.md) · [Opzioni](EXACT-RENDER.it.md) · [ABI e limiti](REUSABLE-RENDER.it.md) · [Test](TESTING.md).
