# Note di sviluppo e manutenzione — 1.15.1

Questa stabile GitHub promuove la dev consegnata agentic17, non il lavoro
deprecato1.15.3/1.16/1.17 di un'altra chat storica. Renderer/API restano identici;
release ufficiali precedenti e demo congelate sono preservate. La pubblicazione
è registrata in RELEASE.json, non dedotta dal nome previsto del tag v1.15.1.

Passaggi automatici e cerchi opzionali sono in
[AGENTIC-OPTIMIZATIONS](AGENTIC-OPTIMIZATIONS.it.md). Flag Mode4 opzionali, altre
precisioni e adattatori sperimentali mantengono domini distinti. Le qualifiche
delle API1.15.0 sono prove storiche, non promesse sugli hash sorgente correnti.
Gli hash correnti sono in QUALIFICATION-1.15.1.json.

Non ampliare finestre RAM o indebolire clipping/matematica per accettare build.
Conservare fallback e normalizzazione degli helper privati; chiamanti/layout
sconosciuti mantengono il comportamento originale. Restano i default legacy,
standard,safe e LOD off. -SphereRenderer circles è none di default, solo4/6 plus.

Le misure native si conservano solo dopo ricompilazione con identità di PRG e
etichette numeriche e condizioni uguali. I callback CPU non sono FPS. Conservare
flag, indice fisso e compromesso Mode7/1x; diagnosticare l'effetto delle finestre
senza sostituire i punteggi. [Test](TESTING.it.md),
[qualifica](QUALIFICATION-1.15.1.it.md), [stato](RELEASE-STATUS.it.md).
