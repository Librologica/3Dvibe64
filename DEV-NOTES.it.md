# Note di sviluppo e manutenzione — 1.20.0

> SDK sorgente stabile 1.20.0, derivato dalla agentic36. Pubblicato su GitHub. [Qualifica](QUALIFICATION-1.20.0.it.md).


Lo sviluppo attivo aggiunge AnimatedMesh v1 alla agentic23 consegnata. Leggere [AGENTIC24](AGENTIC36.it.md) e [il contratto completo](ANIMATED-MESH.it.md). Hash correnti e risultati nativi appartengono a QUALIFICATION-1.20.0.json. Le qualifiche precedenti restano storico immutabile. Non viene usato o promosso lavoro deprecato1.15.3/1.16/1.17.

Non ampliare finestre RAM o indebolire clipping/matematica per accettare build.
Conservare fallback e normalizzazione degli helper privati; chiamanti/layout
sconosciuti mantengono il comportamento originale. Restano i default legacy,
standard,safe e LOD off. -SphereRenderer circles è none di default, solo4/6 plus.

Le misure native si conservano solo dopo ricompilazione con identità di PRG e
etichette numeriche e condizioni uguali. I callback CPU non sono FPS. Conservare
flag, indice fisso e compromesso Mode7/1x; diagnosticare l'effetto delle finestre
senza sostituire i punteggi. [Test](TESTING.it.md),
[qualifica](QUALIFICATION-1.20.0.json), [stato](RELEASE-STATUS.it.md).
