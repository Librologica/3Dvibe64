# Ottimizzazioni del renderer e prestazioni — 1.20.1

SDK sorgente stabile. [Note di release](RELEASE-NOTES-1.20.1.it.md) · [Qualifica](QUALIFICATION-1.20.1.it.md).

## Percorsi ottimizzati

Le ottimizzazioni automatiche selezionano soltanto forme di codice e profili per cui sono verificate le condizioni richieste. I chiamanti non riconosciuti conservano i percorsi generali. Non sono selezionate in base al nome di una scena, demo o benchmark.

| Area | Contratto e ottimizzazione |
|---|---|
|Rotazione e proiezione|Prodotti Q10 condivisi esatti, divisioni raggruppate/limitate e specializzazione della focale costante con i domini e fallback documentati.|
|Span solidi e materiali|Maschere parziali esatte, riuso per righe di celle, store indicizzati e scritture a blocchi degli interni lunghi.|
|Wire e contorni|Cursori di righe adiacenti solo dopo prova del layout; destinazione del contorno selezionata mantenendo clipping e collegamento degli spigoli.|
|Gouraud|Interpolazione coerente dei byte Bayer, riuso dei materiali e stepping esatto per quoziente/resto degli spigoli.|
|Texture affini|Packing Horner, UV coerenti, stepping condiviso e campionamento per bande di luce stabili; transizioni e byte parziali conservano il percorso completo.|
|Mode8 multilivello|Cache profili second-chance, profilo nullo condiviso, rapporti per piano e riuso dei livelli del fade per vista.|
|Distance Fade|Dispatch privato delle maschere, scritture Bayer a passo quattro ed esclusione poligonale esatta; LOD texture indipendente.|

Non si riducono precisione, clipping, palette, risoluzione o qualità per ottenere un risultato migliore. Le finestre RAM e le guardie continuano a delimitare i profili supportati. Le API opzionali [rendering esatto](EXACT-RENDER.it.md), [rendering riutilizzabile](REUSABLE-RENDER.it.md) e [sfere](CIRCLE-SPHERES.it.md) hanno contratti distinti e non vengono abilitate implicitamente.

## Lettura delle prestazioni

Il punteggio generale non è una media degli FPS. La serie storica conserva il riferimento 1.15.0=100; la 1.20.0 conserva 137,505630 come stima ricostruita ereditata, con calcolo canonico storico ancora bloccato. La serie estesa resta separata, con riferimento congelato identificato nel [registro](QUALIFICATION-1.20.1.json). Non si modificano ancoraggi, pesi o scene.

Il costo dipende dalla scena: lunghezza e clipping degli spigoli per il wire; span, celle e overdraw per solid/flat; perimetri per i contorni; interpolazione di spigoli e shade per Gouraud; pixel coperti e transizioni UV/luce per le texture; profili ed eventi delle superfici per le mappe multilivello. Queste indicazioni orientano lo sviluppo; ogni progetto va misurato con il proprio PRG e percorso. Per il fade vedere [tipi di scena e budget CPU](DISTANCE-FADE.it.md#quando-conviene-usare-distance-fade).

Nessuna accelerazione uniforme è garantita. Ripetizioni deterministiche non sono una prova di significatività statistica. [Protocollo nativo e copertura](TESTING.it.md).
