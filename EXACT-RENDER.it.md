# Sviluppo rendering esatto — 1.15.0-dev1

Dev non pubblicata basata sulla stabile1.14.0, destinata a fornire i sorgenti di una futura release stabile GitHub. Nessun tag stabile, branch remoto o release viene modificato. I default legacy/Q8 e le build plus ordinarie senza selettore mantengono i contratti precedenti. L'SDK sorgente non contiene scene, programmi, audio/video o catture native grezze.

## Selezione e ambito

`-LegacyPlusOptimizations none` e il default. I nuovi kernel richiedono attualmente `-Precision legacy-plus -GraphicsMode 4`, walkLite, normal160×100, high-basic-v2, NoFpsOverlay e il profilo Q4 near8/poly esistente. Nessuna sostituzione implicita con altri modi o Q8. Le opzioni sono nomi unici separati da virgole; `all` comprende le cinque opzioni esatte seguenti e **non include l'illuminazione congelata**. Combinazioni incompatibili, nomi errati e RAM insufficiente bloccano la build. Ogni build richiede una copia SDK completa nuova.

| Opzione | Comportamento nativo |
|---|---|
| arithmetic | Prodotti parziali esatti con tabelle dei quadrati sostituiscono i prodotti Q10 seriali; scorciatoie esatte0/+1/−1. Segno e arrotondamento simmetrico restano quelli originali. Un quoziente dimostrato entro8bit usa8 iterazioni; quozienti maggiori e divisore zero mantengono il ciclo16bit originale e il resto. I prodotti della focale restano esatti. |
| edges | Ricorrenza dei bordi con divisore/resto a8bit quando possibile; il riporto e il nono bit della somma. Coordinate/passi16bit e ripiego originale per divisori maggiori conservati. |
| spans | Cache esistente dei materiali nelle celle, scritture srotolate dei byte interni e indirizzo della seconda riga fisica ricavato dalla prima. Il generatore dimostra adiacenza/parita delle righe e offset X multipli di8. Maschere iniziali/finali, entrambi i buffer e ripiego per span lunghi conservati. Nessuna riga omessa. |
| outcodes | Classifica una sola volta ogni vertice originale appena proiettato con i quattro predicati originali del clipper; riusa i bit per esclusione/inclusione delle facce sorgenti. Intersezioni near/sintetiche mantengono il clipper Q4 completo. Nessun riuso tra viste diverse. |
| convex | Unisce il riempimento dei fan ritagliati uniformi solo dopo verifica rigorosa di tutti i punti rispetto ai lati, ancora del fan estrema in Y e controllo del kernel di fill. Conserva tutti i bordi dei triangoli, incluse entrambe le direzioni delle diagonali. Pattern, geometrie dubbie, degeneri o incompatibili mantengono il fan originale. Esporta anche l'adapter esplicito per coppie di triangoli descritto sotto. |
| frozen-lighting | **Opzione estetica**, separata dalle ottimizzazioni esatte. Calcola una volta le facce senza pigmento fisso di ogni oggetto non condiviso alla prima posa attiva e conserva i colori. Gli oggetti invisibili inizializzano quando diventano attivi. La luce non segue piu oggetti/luci mobili fino all'invalidazione. Pigmenti fissi conservati. Richiede oggetti e infrastruttura di luce dinamica. |

Coordinate signed16 Q4 e coefficienti Q10 restano invariati: nessun backend Q8, riduzione di risoluzione/LOD, riga alternata o cambio palette. Trasformazione e proiezione dei vertici sono gia condivise per vista dal renderer ordinario: vengono riutilizzate, senza una seconda cache. Movimento, generazione del percorso, semplificazione mesh e inseguimento camera specifici della demo restano esterni all'SDK.

```powershell
pwsh -NoProfile -File ./work/build-3Dvibe64.ps1 -SceneFile ../mio-progetto/scena.json -Precision legacy-plus -GraphicsMode 4 -CameraMode walkLite -CameraViewport normal -MemoryLayout high-basic-v2 -NoFpsOverlay -NoCameraRuntimeControls -LegacyPlusOptimizations arithmetic,edges,spans,outcodes,convex
```

Usare la normale sintassi `-GraphicsMode 4` negli script. Opzioni e kernel nativi sono registrati nell'ASM generato e nel file `.exact-render.json` adiacente prima dell'allocazione. Codice/dati aggiuntivi occupano RAM reale nei64KB: restano vincolanti allocator e controlli assembler. `all` e una selezione verificabile, non una promessa di vantaggio per ogni scena.

## Adapter esplicito per coppie opache

`er_try_pair_bounds` riceve un quad gia preparato dal loader nativo: `loaded_face_vertex_count=4`, `vx0..vx3`, `vxq2_*`, `vyq2_*`, flag near/schermo. Il chiamante garantisce triangoli opachi `(0,1,2)` e `(0,2,3)` con materiale/fill identici, ordine painter effettivo contiguo e nessuna superficie interposta. Il kernel verifica eleggibilita nativa, limiti viewport e convessita rigorosa, quindi combina i quattro lati e le due direzioni della diagonale. Scrive solo bounds, nessun pixel o tabella facce. Carry impostato: bounds validi per un unico fill uniforme del chiamante; carry azzerato: ricostruire e disegnare entrambi i triangoli originali. Una chiamata fallita puo modificare scratch/bounds, che vanno ricostruiti. Un quad sorgente ordinario conserva la copertura originale: questo adapter non gli viene applicato automaticamente. Vertici streamed del chiamante possono usare gli array di proiezione nativi e il produttore di outcode dopo ogni aggiornamento.

## Invalidazione illuminazione fissa

`er_light_invalidate`: X=indice oggetto, chiamare tra viste complete dopo modifiche a geometria/materiale/luce. Carry impostato indica invalidazione; indice invalido restituisce carry azzerato. Il passaggio attivo successivo ricattura i colori dell'oggetto. Inizializzazione alla prima posa attiva e isteresi iniziale seguono l'engine: e un'opzione a colori fissi, senza equivalenza con luci mobili. Le istanze con sorgente condivisa vengono rifiutate per questa opzione.

## Verifica e promozione

La [qualifica](QUALIFICATION-1.15.0-dev1.it.md) separa nuovi FPS nativi, verifiche matematiche/callback e default ereditati. Confrontare input, target, warm-up e percorso identici prima/dopo. Verificare immagini e celle materiali, clipping/near, vertici condivisi, pannelli degeneri/autointersecanti, arrotondamento signed, divisori larghi, riporti e passaggi di pagina. Sulle scene limitate dalla CPU partire dall'aritmetica; PAL puo limitare le nuove viste visibili a circa50,125/s. La promozione stabile resta un'azione successiva alla revisione: questa dev non pubblica nulla.

La fusione automatica dei fan richiede inoltre un unico materiale/riflettivita attivo, nessuna tabella di pigmenti fissi per faccia e nessuna politica di proprieta delle celle VIC. Le facce con palette miste mantengono il fan originale; l'API esplicita per bounds di coppie resta disponibile nel contratto del chiamante. La cache degli intervalli materiali dimentica gli intervalli disconnessi senza riempire o memorizzare le celle nel mezzo.
