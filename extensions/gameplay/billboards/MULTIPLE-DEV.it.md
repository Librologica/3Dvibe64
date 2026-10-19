> Edizione di sviluppo 1.15.0-dev2; contratti1.14.0 ereditati salvo estensioni esplicite nel [rendering esatto](../../../EXACT-RENDER.it.md).

# BB-03 — due istanze billboard — 1.14.0

Release stabile 1.14.0: [ottimizzazioni correnti](../../../RENDER-OPTIMIZATIONS.it.md), [input esterni](../../../EXTERNAL-INPUTS.it.md). Tutte le demo, gli esempi e le prove native sono esterni alla distribuzione sorgente.


La distribuzione 1.12.0 include soltanto il modulo riutilizzabile. I nuovi progetti/asset demo sono esclusi. Catture, checkpoint e misure native sotto descrivono prove storiche esterne. Le build di progetto richiedono `--project-source`; vedere la [guida di integrazione](../../../GAMEPLAY.it.md).


Contratto corrente incluso nella release 1.12.0. I riferimenti dev descrivono
la provenienza delle prove. [English](MULTIPLE-DEV.en.md).

Il profilo `multiple-billboards` estende la stanza con porta della dev4.
Il guardiano e un secondo personaggio hanno posizione, dimensioni, sequenze,
tempi e stato di animazione indipendenti. Mantiene UI LABIRINTO, viewport
96 × 60, Q8 preciso su tutti i pixel e le righe e LOD texture 14–22.

```powershell
python -B work/build-gameplay.py --profile multiple-billboards --out ../builds/multiple-dev5 --project-source ../my-project
python -B work/qualify-gameplay.py --out ../builds/multiple-dev5 --checks --benchmark --launcher
```

## Contratto della scena

Lo schema 2 di `assets/gameplay-scene.json` accetta una o due voci in
`billboards`, con id distinti. Il primo è il guardiano collegato alla porta;
il secondo è una presenza visiva, senza un secondo sistema di interazione
o collider. Le animazioni `idle` e `used` conservano fotogrammi e tempi
configurabili; lo stato del secondo è `sc_state`, separato da `bc_state`.
La sequenza idle del secondo procede ogni cinque tick, quella del primo
ogni otto. Sono tick di simulazione PAL, indipendenti dal numero di disegni.

Entrambi usano lo stesso asset 16 × 32 con fino a sei fotogrammi e la stessa
palette residente. Le immagini sorgente restano condivise sotto I/O
(3072 byte per l'asset della demo); un solo buffer decodificato da 512 byte
è caricato al momento di disegnare ciascuna istanza. Non si duplicano due
renderer o sei immagini per ogni personaggio. Le configurazioni con asset
diversi vengono rifiutate per il budget di questa scena.

`visibleBillboards`, opzionale, elenca gli id visibili. Senza il campo sono
visibili tutte le istanze configurate. Per confrontare una/due istanze,
conservare entrambe le descrizioni e impostare `['guardian']` oppure
`['guardian','watcher']`: geometria, camera, codice e allocazione restano
uguali, cambia solo la maschera iniziale di visibilità. Anche l'istanza
nascosta conserva il suo aggiornamento di stato e proiezione: il confronto
isola il costo della sua presenza nel disegno rispetto a quel controllo.

I due nodi attore 14/15 già riservati vengono riusati. I rettangoli proiettati,
fotogrammi e profondità sono conservati per istanza prima di costruire i
bucket. L'ordine reciproco usa l'intera profondità Q8, compresa la frazione,
poi assegna due bucket distinti. Anche due personaggi nello stesso vecchio
intervallo di quattro WU vengono ordinati correttamente. A profondità
esattamente uguale prevale il primo id configurato. I piani billboard sono
paralleli al piano di vista, quindi questa regola ordina tutto il rettangolo;
non esistono incroci fra piani inclinati in questo contratto.

## Clipping e limiti geometrici

Il piano vicino per questi billboard è 4 WU. A 4 WU viene disegnato; appena
sotto viene escluso interamente, perché tutto il piano ha la stessa profondità
di vista. La dimensione massima ammessa e questo piano vicino mantengono
larghezza/altezza proiettate entro il DDA a otto bit. Ai quattro bordi del
viewport si conserva la corrispondenza nearest-neighbor con il rettangolo
originale, senza stirare la parte visibile; non si scrive fuori dall'area 3D.

Entrambe le istanze devono rimanere all'interno della stanza convessa e
interamente davanti al divisorio Y=8 per tutte le direzioni di camera
supportate, entro 14 gradi di pitch. Il compilatore verifica un margine
conservativo e rifiuta posizioni che attraversano il divisorio o le pareti.
Dal retro, parete e pannello nascondono entrambe le istanze, lasciando
visibili soltanto i pixel esposti dal varco. Geometrie arbitrarie, altri
asset/palette, più di due istanze e piani billboard inclinati restano fuori
da questo checkpoint. Mode 8 e i PRG dei cinque profili precedenti restano
preservati. Non viene introdotto un solver generale di livelli/intersezioni.

## Qualifica

La prova nativa comprende 64 viste con UI invariata e clipping, 14 casi
di composizione con tre confronti di 16.000 byte bitmap ciascuno, ordine
inverso davanti/dietro, profondità distanti solo 0,25 WU e parità esatta.
Controlla i quattro bordi, il piano vicino a 4 e 4−1/256 WU, personaggi
dietro la camera, maschera trasparente, nero opaco, porta chiusa/parziale
e fotogrammi diversi. Sette campioni nativi di tick verificano le due
cadenze indipendenti. I 20 casi di stato/collisione/sicurezza della porta
sono eseguiti nuovamente nel programma con due istanze.

Il programma lascia 3004 byte nei gap allocabili, 498 in meno della dev4;
il solo passaggio fra una e due istanze visibili usa la stessa allocazione.
Comandi, PRG, dati grezzi, percorso e FPS nativi sono nell'evidence esterna.
Documentazione corrente nella release 1.12.0.
