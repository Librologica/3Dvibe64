# MAT-01 — 1.14.0-dev1

Dev locale 1.14.0-dev1: [ottimizzazioni correnti](../../../RENDER-OPTIMIZATIONS.it.md), [input esterni](../../../EXTERNAL-INPUTS.it.md). Tutte le demo, gli esempi e le prove native sono esterni alla distribuzione sorgente.


La distribuzione 1.12.0 include soltanto il modulo riutilizzabile. I nuovi progetti/asset demo sono esclusi. Catture, checkpoint e misure native sotto descrivono prove storiche esterne. Le build di progetto richiedono `--project-source`; vedere la [guida di integrazione](../../../GAMEPLAY.it.md).


Contratto corrente incluso nella release 1.12.0. I riferimenti dev descrivono
la provenienza delle prove. [English](DEV.en.md).

`mixed-surfaces` estende la stanza UI del confronto: stesse geometrie,
camera orbitale di 3072 tick, attori, viewport 96 × 60 e texture precise,
LOD 14–22. Pareti: texture; pavimento: Gouraud; soffitto: flat.

`surfaces.py` compila descrittori espliciti per faccia. Il dispatcher
seleziona lo shader dopo il clipping, usando trasformazioni Q8, clipping
vicino/schermo, copertura top-left, palette e bucket di profondità comuni.
Flat e Gouraud saltano campionamento UV e LOD. Il flat sceglie uno slot
VIC 1..3 costante; Gouraud interpola livelli 0..32 tra gli angoli, con dither
ordinato 4 × 4 tra gli stessi tre slot. Interpolazione della luce lineare
sullo schermo, texture prospettica precisa. Nessun nuovo solver di occlusione.

Build dalla radice SDK, con output nuovo fuori dai sorgenti:

```powershell
python -B work/build-gameplay.py --profile mixed-surfaces --out ../builds/mixed-surfaces-dev2 --project-source ../my-project
python -B work/qualify-gameplay.py --out ../builds/mixed-surfaces-dev2 --checks --benchmark --launcher
```

Per cambiare le superfici usare `--surface-config percorso.json` sul
builder. Il file ha `schema:1` e `meshes`, mappa dagli ID delle mesh a un
array con un descrittore per triangolo, nello stesso ordine della scena.
Descrittori ammessi: `{"mode":"texture"}`, `{"mode":"flat","index":2}`,
`{"mode":"gouraud","levels":[0,16,32]}`. Esempio completo nel profilo,
`assets/surfaces.json`. Valori, campi e conteggi errati sono rifiutati.
I nodi attore 14/15 restano riservati e non rappresentano superfici.

Il binding attuale è limitato alla stanza importata, statica e convessa,
con palette VIC condivisa e il suo ordinamento degli attori. I valori di
luce sono espliciti qui; LIGHT-01 è disponibile separatamente in static-light. Il modulo e il
file di configurazione sono sperimentali, separati dallo schema stabile;
non dichiarano supporto pubblico per istanze o geometrie arbitrarie.

Verifiche: shader sul PRG nativo confrontato con un oracolo pixel per
span flat/Gouraud, bordi parziali, estremi crescenti/decrescenti e singolo
pixel; viste complete e clipping con controllo UI; controllo solo-texture
contro dev1 e benchmark dei percorsi completi con condizioni uguali.
Dati e comandi restano nella cartella esterna reports/builds/verification.
Documentazione corrente nella release 1.12.0.
