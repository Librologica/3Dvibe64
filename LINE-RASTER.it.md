# Linee ibride: geometria Q8, raster intero additivo — 1.15.0

> SDK sorgente stabile1.15.0 preparato in locale; non pubblicato online. [Stato e supporto](RELEASE-STATUS.it.md).

Release stabile 1.15.0: [ottimizzazioni correnti](RENDER-OPTIMIZATIONS.it.md), [input esterni](EXTERNAL-INPUTS.it.md). Tutte le demo, gli esempi e le prove native sono esterni alla distribuzione sorgente.


Contratto sorgente corrente 1.14.0. Il manuale descrive l’exporter ordinario
salvo indicazione esplicita; API delimitate gameplay/configurazione/roll/gruppi
in [GAMEPLAY](GAMEPLAY.it.md). [Indice documentazione](DOCS.md).

`-Precision q8 -LineRaster hybrid` è supportato nelle GraphicsMode 1, 2 e 5. Conserva camera Q8, trasformazioni mesh, proiezione degli estremi e clipping near/schermo. Cambia soltanto il raster finale della linea clippata. `precise` resta il default delle linee Q8; la geometria `legacy` resta il default dell'engine. Hybrid non semplifica la proiezione né modifica lo shading del fill solido.

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -Precision q8 -GraphicsMode 2 -SceneFile ../my-inputs/q8/two-objects-mode2.json -Q8Camera auto -LineRaster hybrid -OutputDirectory ../hybrid-build
```

Gli estremi Q2 clippati e limitati vengono arrotondati al pixel intero più vicino, con parità verso la coordinata positiva. L'asse maggiore canonico crescente produce un campione Bresenham connesso per posizione. L'errore unsigned a 8 bit usa il carry per il nono bit; estensione massima 159. Nessun prodotto, divisione o codice automodificante nel walker. Invertire gli estremi produce la stessa sequenza. L'IRQ non usa il suo scratch.

Mode 1 lo applica agli edge visibili; Mode 2 usa lo stesso walker per disegno e maschere delle facce. Mode 5 mantiene il fill poligonale Q8 e applica l'ibrido soltanto al perimetro del poligono realmente clippato, inclusi i cap near/schermo. Writer bitmap, materiali e palette restano invariati.

Le differenze di fase dei pixel dal raster subpixel precedente sono intenzionali: non si dichiara identità bitmap. Identità di geometria/clipping e contratto della linea intera vanno testati separatamente. L'oracolo indipendente a formula chiusa in `test_line_hybrid.py` verifica entrambi gli ordini, degeneri, ottanti ed estremi frazionari nel codice 6510 emesso. Le prestazioni native dipendono dalla scena, senza promesse universali. Restano i limiti Q8 di profilo e memoria; Q8 è consigliato oltre 20 MHz, mai scelto automaticamente.

## Ottimizzazioni e API della1.15.0

Il selettore `-LegacyPlusOptimizations` è distinto da EngineExperiments,dal raster Q8 ibrido e dagli altri backend. Richiede Mode4 legacy-plus nel profilo qualificato; default none. `all` comprende arithmetic,edges,spans,outcodes,convex,integer-edges. Wire e stream sono API ASM esplicite escluse da all,non sostituzioni automatiche; stream richiede outcodes e possesso degli slot nativi. Frozen-lighting è separata e cambia intenzionalmente la risposta alle luci mobili. Il codec di chiavi è un modulo dati facoltativo. L'errore Bresenham a8bit non riduce la precisione geometrica Q4/Q10. La matrice oggetto ordinaria resta Q6; nessuna nuova API di rotazione rigida degli oggetti è implicita.

[Opzioni e profilo](EXACT-RENDER.it.md) · [ABI,materiali,memoria e ripieghi](REUSABLE-RENDER.it.md) · [Stato e supporto](RELEASE-STATUS.it.md). Alcune combinazioni non entrano nei64KB e vengono rifiutate.
