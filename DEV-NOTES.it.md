# Note di sviluppo e manutenzione — 1.20.1

> SDK sorgente stabile 1.20.1. [Qualifica](QUALIFICATION-1.20.1.it.md).


La release include AnimatedMesh v1. Leggere le [note di release](RELEASE-NOTES-1.20.1.it.md) e [il contratto completo](ANIMATED-MESH.it.md). Hash e risultati nativi sono nel registro QUALIFICATION-1.20.1.json. I registri di qualifica precedenti conservano la provenienza originale.

Non ampliare finestre RAM o indebolire clipping/matematica per accettare build.
Conservare fallback e normalizzazione degli helper privati; chiamanti/layout
sconosciuti mantengono il comportamento originale. Restano i default legacy,
standard,safe e LOD off. -SphereRenderer circles è none di default, solo4/6 plus.

Le misure native si conservano solo dopo ricompilazione con identità di PRG e
etichette numeriche e condizioni uguali. I callback CPU non sono FPS. Conservare
flag, indice fisso e compromesso Mode7/1x; diagnosticare l'effetto delle finestre
senza sostituire i punteggi. [Test](TESTING.it.md),
[qualifica](QUALIFICATION-1.20.1.json), [stato](RELEASE-STATUS.it.md).
