# Agentic24 â€” 1.15.2-dev-agentic24

Sviluppo non pubblicato basato sulla agentic23 consegnata. Release ufficiali,
SDK precedenti e demo congelate sono preservati. Non vengono creati tag,
release GitHub o promozioni a stabile. [English](AGENTIC24.en.md) Â·
[Contratto AnimatedMesh](ANIMATED-MESH.it.md).

## Modifiche riutilizzabili implementate

- `AnimatedMesh v1` nativa: geometria sorgente indicizzata condivisa e clip di
  pose compresse, fase/step indipendenti per istanza e interpolazione esatta.
- Stream a0/1/2/4/8 bit, deduplicazione tra clip/asset e percorsi per colonne
  costanti. Non ci sono conteggi o rami geometrici specifici degli zombi.
- Una cache del contenuto sorgente evita decodifiche ripetute: identifica la
  posa realmente presente, inclusi i passaggi tra istanze della stessa sorgente.
- Illuminazione di riferimento congelata facoltativa in Mode6: i valori vengono
  calcolati nella prima vista illuminata dell'istanza e riusati fino all'invalidazione.
- Riutilizzo di movimento ordinario, camera, clipping, ordinamento, raster Gouraud
  e proiezione. Cadenza dell'animazione e velocitÃ  nel mondo restano indipendenti.
- API nativa per scelta clip, reset animazione e invalidazione della luce. Il
  normale allocatore limitato posiziona codice/dati senza ampliare le finestre.
- Profilo esplicito `compact-gouraud`: Mode6 puro puÃ² omettere i filler non Gouraud
  irraggiungibili, con controlli di profilo/riferimenti applicativi e trap osservabili.

Il nuovo profilo Ã¨ esplicito e circoscritto: legacy-plus ordinario Mode4/5/6,
walkLite, viewport normale, high-basic-v2, NoFpsOverlay. Le scene esistenti usano
il percorso originale. Default, LOD delle texture, qualitÃ  e carichi pubblici
restano invariati. Il renderer privato di interfaccia/pavimento degli zombi non
viene copiato nel builder generico. Formato, aritmetica, reset, costi di memoria
e combinazioni rifiutate sono descritti nel manuale API abbinato.

## Ottimizzazioni discusse: cosa Ã¨ ereditato e cosa resta separato

Agentic23 contiene giÃ  interpolazione coerente dei byte Gouraud, varianti della
divisione per proiezione, posizionamento limitato, cache dei materiali e percorsi
qualificati per bordi interi/contorni. Sono conservati. I risultati storici sono
nelle [note agentic23](AGENTIC23.it.md) e nel registro immutabile: non vanno
presentati come nuovi guadagni di agentic24.

Aloni aggregati per byte, riuso temporaneo dello scratch pavimento/Gouraud,
tabelle ridotte del renderer privato degli
zombi dipendono dai tempi di vita e dal viewport dell'applicazione. Non vengono
attivati come default globali. L'omissione dei filler Ã¨ limitata al nuovo profilo
Gouraud puro con vincoli espliciti. Non ci sono riduzioni globali delle tabelle,
modalitÃ  disabilitate o percorsi specifici dei benchmark. Normali deformate
dinamiche, scheletri, root motion arbitrario e integrazione Mode7 con texture/UI
restano sviluppi futuri, non funzioni della v1.

## Verifiche ed evidenze

Il [registro corrente](QUALIFICATION-AGENTIC24.json) Ã¨ autorevole per stato
misurato, hash, FPS nativi e copertura. I registri storici mantengono l'identitÃ 
originale. I test documentali controllano coppie IT/EN, collegamenti, hash del
manifest, pacchetto di soli sorgenti e metadati non pubblicati. I controlli host
e6502 verificano correttezza e non misurano FPS.

Le misure native usano PAL Turbo6510 a1Ã—/20Ã—/64Ã—, SID originale del benchmark,
warm-up128 refresh e almeno1024 refresh misurati, contando solo nuove viste
complete. Comandi, tracce e build restano nelle evidenze esterne della dev; lo
ZIP sorgente non contiene scene, PRG, demo, musica o catture. Il confronto con
parent e stabile usa carichi invariati, conservando blocchi ereditati e pesi
fissi dell'indice. Non implica qualifica su hardware reale o nuova qualifica
NTSC. Vedere le [verifiche](TESTING.it.md).

## Final validation / Verifica finale

54 programmi ed etichette numeriche invariati;162 nuove osservazioni native del catalogo,648 catture identiche alla parent;27 blocchi ereditati,0 nuovi. Indice fisso 129.982745981, parent 129.982556846. La consegna sigillata richiede22 gate pubblici e audit IT/EN correnti. Le prove AnimatedMesh aggiuntive coprono Mode4/5/6 a1×/20×/64×. A64×, due modelli originali in piedi raggiungono16,740814 FPS e due striscianti20,607844 FPS, provati separatamente su fondo nero con SID originale del benchmark e movimento reale. Ogni finestra dura20,429s dopo128 refresh di warm-up. Generic/compact hanno12 confronti pixel nativi identici. Questi carichi sono fuori dall'indice fisso: non sono un confronto con la demo privata pavimento/UI. Dev e ZIP non contengono demo, modelli, musica, PRG o catture. Verifiche grezze esterne in 3Dvibe64_Verifiche_1.15.2-dev-agentic24_2026-11-04.
