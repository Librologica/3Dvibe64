# Q8-01 — mesh sorgenti condivise — 1.14.0

Release stabile 1.14.0: [ottimizzazioni correnti](../../../RENDER-OPTIMIZATIONS.it.md), [input esterni](../../../EXTERNAL-INPUTS.it.md). Tutte le demo, gli esempi e le prove native sono esterni alla distribuzione sorgente.


La distribuzione 1.12.0 include soltanto il modulo riutilizzabile. I nuovi progetti/asset demo sono esclusi. Catture, checkpoint e misure native sotto descrivono prove storiche esterne. Le build di progetto richiedono `--project-source`; vedere la [guida di integrazione](../../../GAMEPLAY.it.md).


Contratto corrente della release 1.12.0; i numeri dei checkpoint indicano
la provenienza delle prove. [English](SHARED-DEV.en.md).

Il profilo sperimentale `shared-meshes` mostra quattro solidi poligonali
nella stanza con interfaccia LABIRINTO. Un solo asset geometrico alimenta
istanze con posizione, scala, yaw, visibilità e livelli di ombreggiatura
distinti. La camera automatica percorre 48 chiavi, gira attorno agli oggetti
e varia lo sguardo verticale. Pareti precise per pixel, tutte le 60 righe,
viewport 96 × 60 e LOD delle texture 14–22 restano attivi.

```powershell
python -B work/build-gameplay.py --profile shared-meshes --out ../builds/shared-dev9 --project-source ../my-project
python -B work/qualify-gameplay.py --out ../builds/shared-dev9 --checks --benchmark --launcher
```

`--shared-meshes percorso.json` sostituisce i descrittori delle istanze.
L'asset modificabile è `<project-source>/extensions/gameplay/profiles/shared-meshes/assets/crystal-mesh.json`:
schema, id, sei vertici interi X/destra,Y/avanti,Z/alto e otto triangoli.
Il validatore richiede solido convesso chiuso, avvolgimento pubblico orario,
raggio XY massimo 3 e altezza locale compresa fra −5 e 5. Il layout nativo
è deliberatamente limitato a sei vertici e otto facce, ma non dipende da
una sola sequenza di coordinate o da triangoli incorporati nel codice.

La configurazione contiene `schema:1`, `sharing` booleano e da 2 a 4
`instances`. Ogni istanza contiene id univoco, `position`, `yawDegrees`,
`scale`, `visible`, `level`. Le posizioni usano passi di 1/256 WU, la scala
0.5–1 passi di 1/64; yaw 0–360 escluso viene quantizzato a fase di 16 bit.
`level` è intero 4–28; le otto facce derivano livelli Gouraud individuali.
Gli inviluppi XY devono essere disgiunti e contenuti nella stanza; i solidi
non devono attraversare pavimento o soffitto. Le trasformazioni native
riusano seno interpolato e prodotti Q8 del renderer. Il flag di visibilità
esclude le facce; la cache dei vertici viene comunque aggiornata.

## Memoria nativa

Un asset occupa 18 byte XYZ più 32 byte di topologia locale (quattro colonne
da otto byte, quarta colonna riservata). Con quattro istanze, **50 byte
condivisi contro 200 duplicati: 150 byte risparmiati realmente nei gap**.
Restano **5281 byte**, contro **5131** nel controllo `sharing:false` a
parità di stanza, codice, istanze, percorso e qualità. Il confronto con
profili che contengono altri attori o estensioni non misura questo risparmio.
La stanza conserva i suoi nove vertici e sedici slot di faccia, inclusi due
nodi inerti; il totale runtime è 33 vertici e 48 facce.

Le cache restano separate per istanza: 36 byte per vertice per coordinate
camera a 24 bit, cache di proiezione/texture, coordinate di copertura,
coordinate legacy e flag. Sono 216 byte per solido di sei vertici. Le due
tabelle globali dei bucket crescono di otto byte ciascuna per solido
(lista bucket usati e collegamenti delle otto facce); non sono geometria
sorgente. Descrittori e indici richiedono altri 16 byte per istanza.
Le tabelle statiche per faccia (UV, materiale, shade, conteggio) restano
individuali. I 35 byte fissi di scratch del nuovo modulo sono riutilizzati
in sequenza; non sostituiscono le cache per istanza. Il clipper conserva
il suo scratch comune per la faccia attualmente elaborata.

Il nuovo codice occupa 729 byte di trasformazione e 112 di risoluzione
della topologia. Stato/indici/scratch occupano 99 byte per quattro istanze,
esclusi i buffer e metadati preesistenti. I rapporti di build conservano
allocazione completa e gap; il controllo duplicato differisce nei dati
sorgente e nei relativi offset, senza cambiare il numero di cache.

## Qualifica e limiti

Le verifiche native della configurazione predefinita confrontano copie
condivise/duplicate in dieci pose, con ogni oggetto isolato, tutti visibili
e tutti nascosti. La stanza vuota è confrontata anche con una compilazione
indipendente del profilo precedente senza attori. Traslazione di 1/256 WU,
scala, yaw e visibilità di un'istanza vengono confrontati con un oracolo Q8
indipendente e con i buffer delle altre. Un oracolo ray/triangolo controlla
700 pixel interni nelle viste anteriore e posteriore; UI, palette, sorgenti
immutabili e LOD a tre distanze sono verificati nel programma nativo.
I dati grezzi, comandi e FPS del giro completo sono nel checkpoint esterno
`reports/dev9/CHECKPOINT.it.md` della consegna, con hash del programma.

Questa è un'estensione delimitata del profilo `mixed-surfaces`. I solidi
sono Gouraud senza texture; le pareti mantengono le texture. LOD geometrico,
intersezioni tra oggetti, asset arbitrari, animazioni applicative e roll
non fanno parte di questo checkpoint. Animazioni applicative e roll sono disponibili nei profili Q8-02 separati.
Gli altri nove profili restano disponibili con programmi identici ai propri
checkpoint. La nuova demo non riunisce porta, billboard, luce e portali.
Il builder ordinario e la fondazione Q8 restano invariati e mantengono il
rifiuto dell'opzione pubblica `meshSourceSharing`: questa prova non cambia
quel contratto generale. Documentazione corrente inclusa nella release 1.12.0.
