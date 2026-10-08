# Linee ibride: geometria Q8, raster intero additivo

`-Precision q8 -LineRaster hybrid` è supportato nelle GraphicsMode 1, 2 e 5. Conserva camera Q8, trasformazioni mesh, proiezione degli estremi e clipping near/schermo. Cambia soltanto il raster finale della linea clippata. `precise` resta il default delle linee Q8; la geometria `legacy` resta il default dell'engine. Hybrid non semplifica la proiezione né modifica lo shading del fill solido.

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -Precision q8 -GraphicsMode 2 -SceneFile examples/q8/two-objects-mode2.json -Q8Camera auto -LineRaster hybrid -OutputDirectory ../hybrid-build
```

Gli estremi Q2 clippati e limitati vengono arrotondati al pixel intero più vicino, con parità verso la coordinata positiva. L'asse maggiore canonico crescente produce un campione Bresenham connesso per posizione. L'errore unsigned a 8 bit usa il carry per il nono bit; estensione massima 159. Nessun prodotto, divisione o codice automodificante nel walker. Invertire gli estremi produce la stessa sequenza. L'IRQ non usa il suo scratch.

Mode 1 lo applica agli edge visibili; Mode 2 usa lo stesso walker per disegno e maschere delle facce. Mode 5 mantiene il fill poligonale Q8 e applica l'ibrido soltanto al perimetro del poligono realmente clippato, inclusi i cap near/schermo. Writer bitmap, materiali e palette restano invariati.

Le differenze di fase dei pixel dal raster subpixel precedente sono intenzionali: non si dichiara identità bitmap. Identità di geometria/clipping e contratto della linea intera vanno testati separatamente. L'oracolo indipendente a formula chiusa in `test_line_hybrid.py` verifica entrambi gli ordini, degeneri, ottanti ed estremi frazionari nel codice 6510 emesso. Le prestazioni native dipendono dalla scena, senza promesse universali. Restano i limiti Q8 di profilo e memoria; Q8 è consigliato oltre 20 MHz, mai scelto automaticamente.
