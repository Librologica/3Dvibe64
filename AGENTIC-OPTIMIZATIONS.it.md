# Ottimizzazioni agentiche del renderer — 1.20.0

> SDK sorgente stabile 1.20.0, derivato dalla agentic36. Pubblicato su GitHub. [Qualifica](QUALIFICATION-1.20.0.it.md).


Current agentic36 contracts and score provenance: [notes](AGENTIC36.en.md), [ledger](QUALIFICATION-1.20.0.json). Historical tables below retain their original scope/scales; the required historical series is first stable1.15.0=100, and the extended series starts at delivered36=100. / Contratti e provenienza correnti: [note IT](AGENTIC36.it.md). Le tabelle precedenti conservano perimetro/scala originali; storico1.15.0=100 ed esteso36=100 restano distinti.


## Promozione corrente
+
+La stabile 1.20.0 conserva la agentic36: ottimizzazioni esatte Mode6/7/8 ereditate, cache del livello per piano e riempimenti Bayer a passo quattro per il fade Mode8 multi, aritmetica della distanza poligonale esatta e scritture wire corrette. Default e contratti restano invariati. [Note correnti](RELEASE-NOTES-1.20.0.it.md).
+
+Indice generale storico, 1.15.0=100: agentic36 e stabile 137,505630, variazione 0%. Stime ricostruite ereditate; il calcolo canonico è ancora bloccato dall’hash PowerShell storico. L’indice esteso separato resta 100, ancorato alla prima agentic36, ereditato per identità. I numeri della vecchia stabile riportati sotto appartengono alla loro qualifica originale.
+
+## Storico della promozione 1.15.1
+
+La stabile1.15.1 promuove agentic17 senza cambiare sorgenti di renderer/API.
I passaggi automatici vengono scelti solo per forme sorgente provate e profili
supportati: non sono `EngineExperiments` né il flag opzionale Mode4
`LegacyPlusOptimizations`. Chiamanti/layout sconosciuti mantengono i fallback.
Nessun riconoscimento di ID benchmark, demo o nomi di scena.

| Area | Contratto preservato e ottimizzazione |
|---|---|
|Rotazione/proiezione|Prodotti camera Q10 condivisi esatti, divisioni raggruppate/limitate e focale costante, con dominio e fallback originali.|
|Span solidi/materiali|Maschere parziali esatte, riuso per riga di celle e scritture indicizzate; gli interni lunghi condividono un writer srotolato discendente.|
|Wire|Cursore per righe fisiche adiacenti solo se entrambe le tabelle provano row1=row0+1; altri layout mantengono il writer originale.|
|Mode5|Destinazione selezionata a ingresso/uscita del contorno; edge connessi e clipping finale invariati.|
|Mode6|Byte Bayer coerenti, riuso materiali esatto e avanzamento X degli edge con quoziente/resto; campioni shade originali conservati.|
|Mode7-C affine|Packing Horner esatto, costanti UV coerenti, setup quozienti binario, edge fusi/condivisi, errori UV con carry e sampling inline nelle bande di luce stabili. Transizioni dithering e byte parziali mantengono i percorsi completi.|
|Mode8 multi|Cache dei rapporti unitari per piano e posa; backend mono invariati. Piani fuori intervallo usano la divisione originale.|

Finestre dell'allocatore, guard32, budget60000, priorità camera e fallback reali
restano invariati. Il codice aggiuntivo può cambiare placement o fattore di
srotolamento valido; non garantisce accelerazione uniforme. Clipping, precisione,
arrotondamenti, luce, palette, viewport, texture, LOD e carico restano invariati.
I puntatori materiali sono scratch privato volatile solo per chiamanti interni
riconosciuti; altri chiamanti conservano l'helper originale. Non è una nuova ABI.

Le jump table degli span usano62 byte allocati; la palette sampler4. Mode5/6
possono usare2 byte dati temporanei aggiuntivi sullo stack. Mode8 aggiunge485
byte dati a55c0..57a4 e85 byte codice a57a5..57f9, prima del font5800; l'helper
usa2 byte di ritorno. [Memoria mappe](MODE8-MEMORY.it.md) descrive le guardie.

## API opzionale cerchi/sfere

`-SphereRenderer circles` è un opt-in separato, solo Mode4/6 legacy-plus,
walkLite, normal, high-basic-v2, NoFpsOverlay. Il default `none` non aggiunge
codice/RAM. Disegna impostor circolari allineati allo schermo, non intersezioni
volumetriche sfera/near; painter order, materiali e luce appartengono al chiamante.
Raggio proiettato massimo63 pixel logici. [API completa](CIRCLE-SPHERES.it.md).

## Interpretazione dei risultati

Indice fisso1.15.0=100:117,647645 complessivo;117,490903 a1×,117,407532 a20×,
118,045521 a64×. Pesi uguali per8 modi/3 velocità; media geometrica50/50 FPS e
inverso del tempo render nativo;12 casi fissi/36 celle. Non è una media degli FPS.
Indici per modo rispetto alla stabile: +11,88%,+2,49%,+12,29%,+13,69%,+18,91%,
+51,15%,+27,24%,+9,62% per1..8. I piccoli risultati dipendenti dalla scena sono
descrittivi; non sono prove di significatività statistica. Le ripetizioni sono
deterministiche.

Ridurre overdraw e span visibili/tagliati, non solo il numero di oggetti. Il wire
costa in funzione di lunghezza/clipping delle linee; solid/flat di span e celle;
gli outline aggiungono perimetro; Gouraud interpolazione edge/shade; le texture
pixel coperti e transizioni UV/luce; il multi-map profili/eventi e riuso piani.
Sono ipotesi d'autore dallo studio separato su agentic16, non garanzie per un
gioco nuovo. Misurare il PRG consegnato con benchmark mirati e confrontare immagini.

La [qualifica](QUALIFICATION-1.15.1.it.md) conserva compromesso Mode7/1×,
diagnosi validation4/1× e dati originali. Nessuna nuova qualifica Linux/NTSC/hardware.
