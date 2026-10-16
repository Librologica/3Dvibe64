# Formato comune e budget del livello — — 1.12.0

Release 1.12.0: [ottimizzazioni correnti](../../../RENDER-OPTIMIZATIONS.it.md), [input esterni](../../../EXTERNAL-INPUTS.it.md). Tutte le demo, gli esempi e le prove native sono esterni alla distribuzione sorgente.


La distribuzione 1.12.0 include soltanto il modulo riutilizzabile. I nuovi progetti/asset demo sono esclusi. Catture, checkpoint e misure native sotto descrivono prove storiche esterne. Le build di progetto richiedono `--project-source`; vedere la [guida di integrazione](../../../GAMEPLAY.it.md).


Contratto corrente della release 1.12.0; i numeri dei checkpoint indicano
la provenienza delle prove. [English](LEVEL-DEV.en.md).

La dev12 aggiunge un punto di ingresso per descrivere insieme gruppi,
stanze, oggetti, collegamenti, ingressi ed eventi. Il computer risolve gli
ID e traduce il livello nelle configurazioni native già qualificate.
Il file di esempio costruibile riproduce WORLD-01 byte per byte: non
aggiunge tabelle generiche al C64 e non consuma altra RAM a runtime.

L'adattatore attuale è WORLD-01: due stanze nello schema del divisorio per
gruppo, un guardiano e una porta per gruppo, asset condivisi. Il formato
può rappresentare anche richieste d'integrazione: il tool le segnala e
impedisce di costruirle come se fossero già supportate. Il builder ordinario,
la fondazione e Mode 8 mantengono i rispettivi contratti.

## Uso

```powershell
python -B work/build-level.py --level ../my-level/level.json --validate-only
python -B work/build-level.py --level ../my-level/level.json --out ../builds/common-level --project-source ../my-project
python -B work/qualify-gameplay.py --out ../builds/common-level/native --benchmark --launcher
```

L'output deve essere nuovo e fuori dal repository. `launch-level.cmd`
avvia la demo nativa. `build.json` riporta risultato e hash; il progetto
nativo completo resta in `native`. `memory-budget.json` contiene intervalli
e contabilità assemblata. In `level` si trovano originale, IR con riferimenti
numerici, asset copiati e un `level.json` ricompilabile anche dopo lo
spostamento della cartella. Tutte le dipendenze del livello sono esplicite.
Il tool usa soltanto la libreria standard di Python.

Per progettare l'integrazione:

```powershell
python -B work/build-level.py --level ../my-level/level.json --plan-only --out ../plans/integration
```

Questo secondo esempio richiede un altro guardiano, una mesh e moduli
qualificati nei profili separati. Il risultato è un piano con
`buildable:false` e i motivi; nessun PRG viene generato. La validità dei
dati e la disponibilità dell'adattatore sono due controlli distinti.
Un build normale di quel piano viene rifiutato prima di creare l'output.
`--plan-only` non dichiara un budget misurato: servono un assemblato e i
suoi indirizzi effettivi.

## Formato 1

Schema sintattico: `level.schema.json`, identificatore
`urn:3dvibe64:level:1`. Il validatore Python aggiunge controlli su riferimenti,
asset, geometria, eventi e compatibilità che lo schema sintattico non esprime.
Non accetta campi sconosciuti, chiavi JSON duplicate, NaN, infinito o
booleani al posto di numeri. ID: lettere minuscole, cifre e trattino,
massimo 48 caratteri, con lettera iniziale; unici fra tutte le risorse.

| Campo | Contenuto |
| --- | --- |
| schema / format / id | 1, `3Dvibe64.level`, nome del livello |
| axisConvention | `world-z-up`: X destra, Y avanti, Z alto |
| target | PAL, moltiplicatore 64, precise, LOD[14,22], musica falsa, autoTransitions booleano |
| memory | reserveBytes, minimumContiguousBytes, stagingBytes 1024 |
| features | richieste esplicite di moduli da integrare; vuoto nel livello costruibile |
| assets | ID, tipo billboard/materials/mesh e origine |
| groups | ID, template geometrico, materiali ed ingresso |
| rooms | ID, gruppo ed estremi XYZ del volume |
| objects | ID, tipo, stanza, posizione e dati specifici |
| connections | porte locali o passaggi reciproci fra gruppi |
| spawns | ingressi: stanza, XYZ, yaw e pitch |
| events | oggetto utilizzato e azioni collegate |
| start | ID dell'ingresso iniziale |

Posizioni e volumi sono numeri finiti a passi di 1/256 WU. La scala delle
mesh usa passi di 1/64. L'IR converte XYZ in Q8 e gli angoli degli ingressi
in fasi di 16 bit. Gli ID dei riferimenti diventano indici densi per categoria;
il gruppo dell'ingresso iniziale è indice 0. Gli ID restano nel rapporto
per la diagnosi. Non sono indirizzi di memoria o nomi di routine 6502.

Gli asset demo builtin sono esclusi e i relativi identificatori sono rifiutati. Si usa
`file:assets/nome.json`, relativo al file del livello. Il file deve restare
entro quella cartella anche dopo la risoluzione dei symlink. Percorsi
assoluti, uscite dalla cartella e URL remoti vengono rifiutati. I rapporti
conservano hash e dimensione di ogni asset; risorse equivalenti vengono
condivise per il contenuto, non duplicate nel C64 per il solo diverso ID.

### Stanze e collegamenti

Il template `two-room-divider-v1` usa halfWidth 18–24, floorLevel nullo
oppure 0–32 e doorIndex 1–3. Ogni gruppo dell'adattatore contiene:

- stanza frontale: min[-width,-24,-10], max[width,8,18];
- stanza posteriore: min[-width,8,-10], max[width,24,18];
- un ingresso frontale [0,-20,0], yaw/pitch 0;
- una porta in [0,8,-10], dimensione[10,18].

Una connessione `doorway` riferisce le due stanze e la porta. Una
`group-transition` collega due stanze di gruppi diversi e specifica i due
ingressi di arrivo/ritorno: basta un record per il collegamento reciproco.
Il grafo deve essere connesso. WORLD-01 accetta 1–2 vicini per gruppo;
gli ingressi di transizione devono essere quelli del gruppo. N/P sono
passaggi espliciti, non attraversamenti continui della frontiera descritta.
Il giro automatico qualificato richiede due gruppi. Con 2–8 gruppi si può
usare autoTransitions:false e i comandi espliciti; la camera diagnostica
iniziale conserva il giro a 48 chiavi e richiede la prima porta chiusa.

### Oggetti ed eventi

Un `billboard` descrive asset, XYZ, size[larghezza,altezza], animazioni
idle/used, useRange, collisionHalfSize e stato used. Il formato dell'asset
rimane 16 × 32,1–6 frame, trasparente 0 e nero opaco 4. Tempi e fotogrammi sono
validati col compilatore billboard esistente. Una `sliding-door` contiene
XYZ, size e stato open. Una `mesh` riferisce l'asset, XYZ, yawDegrees,
scale, visible e level: è descrivibile e validata, ma l'adattatore WORLD-01
ne segnala l'integrazione mancante e non la elimina silenziosamente.

L'evento di esempio usa il guardiano e contiene due azioni ordinate:
`toggle` sul campo open della propria porta, poi `animate-from` sul
guardiano, legato alla porta: false→idle, true→used. I riferimenti devono
appartenere al gruppo attivo. Il backend attuale riconosce questa coppia
ed usa il codice nativo già esistente; non aggiunge un dispatcher generico.
Il flag iniziale del guardiano deve concordare con quello della porta.

Ogni gruppo conserva i 17 byte nativi:16 di slot più il flag di visita.
L'IR associa gli ID logici a questi slot, includendo cursori dell'animazione,
altezza/stato porta e contatori. La porta e il guardiano condividono il
flag d'uso del backend, da cui la necessità di sincronizzazione. Il gruppo
inattivo resta congelato; la persistenza vale per la sessione in RAM.

## Budget effettivo del livello costruibile

Il rapporto legge `build.json`, allocazione, simboli finali e hash del PRG.
Verifica finestre legali, intervalli senza sovrapposizioni, partizione
completa fra blocchi e gap, dimensioni finali e guardie di crescita,
indirizzi del caricatore con ROM visibile, staging e slot persistenti.
Un totale di byte liberi non dimostra da solo che un buffer contiguo entri.

| Voce | Byte |
| --- | ---: |
| Finestre legali per blocchi ricollocabili | 26018 |
| Blocchi allocati, guardie incluse | 25012 |
| Payload effettivo nei blocchi | 24567 |
| Guardie di crescita residue | 445 |
| Liberi effettivi | 1006 |
| Gap singolo più grande | 965 |
| Capacità massima con allineamento a 2 byte | 964 |
| Margine minimo scelto per questo livello | 512 |
| Liberi oltre il margine | 494 |

I 39518 byte fuori da queste finestre sono codice/buffer fissi, video,
hardware o aree riservate: non vengono contati come ulteriore spazio
allocabile. Il rapporto riporta le sottoaree residenti già comprese nella
mappa: staging 1024, dati attivi 748, stato 17 per gruppo, frame sorgenti,
cache billboard 512 e buffer di rendering. Queste voci non si sommano una
seconda volta ai blocchi. I file esterni sono 762 byte ciascuno:1524 su disco
per il livello predefinito, con un solo file in staging alla volta.

`reserveBytes` è una soglia di accettazione, non una nuova allocazione.
`minimumContiguousBytes` usa l'allineamento a 2 byte del backend. Il build
viene rifiutato se una delle due condizioni fallisce, anche quando un
ipotetico recupero futuro renderebbe il totale sufficiente. Il rapporto
e l'assemblato restano consultabili; il launcher del livello viene creato
soltanto per i build accettati. La configurazione a 8 gruppi/48 chiavi lascia
460 byte: con il margine 512 viene quindi rifiutata, pur essendo assemblabile.

## Piano di integrazione per fasi, ancora da implementare

Il decoder della UI, i suoi 12 blocchi compressi, directory e dizionario
occupano 3759 byte allocati:3639 di payload più 120 di guardie. Sono usati
per l'inizializzazione; il rapporto individua i blocchi e l'unica chiamata
diretta a game_ui_init. Oggi restano occupati. Prima di riusarli occorre
provare che siano irraggiungibili da gioco, caricamento, IRQ e ogni percorso
di reinizializzazione, e introdurre allocatore/emitter per fasi e un loader
dedicato. Il singolo riferimento testuale è evidenza iniziale, non la prova
completa di quella proprietà.

Dopo un recupero verificato, i byte liberi diventerebbero 4765, con un
intervallo massimo 2905 byte grezzi /2904 allineati. Il piano host colloca:

| Accantonamento proposto | Byte | Intervallo esemplificativo, fine esclusa |
| --- | ---: | --- |
| Estensioni residenti caricate dopo la UI | 2048 | $BBCC–$C 3 CC |
| Stato aggiuntivo entità/eventi | 512 | $CC 3 C–$CE 3 C |
| Margine di sicurezza complessivo | 512 | soglia sui gap residui |
| Residuo oltre questi accantonamenti | 1693 | da assegnare e verificare |

Le estensioni del piano si caricano una volta dopo la UI e rimangono
residenti durante gioco e cambio gruppo. Il piano non presuppone di
evincere il codice mentre porte, animazioni o IRQ lo usano. Il file WG01
continua a usare lo staging 1024: una futura estensione d'avvio da 2048 byte
richiede un protocollo di lettura/validazione proprio e non può essere
presentata come supportata dal caricatore attuale. Un errore in quella
fase deve impedire l'avvio del codice incompleto.

Durante il cambio gruppo servono contemporaneamente vecchia vista
completa, geometria attiva precedente, staging, stato e backup KERNAL:
queste aree non vengono sovrapposte nel piano. I costi delle demo separate
non vengono sommati come prova che tutti i moduli entrino insieme. Nuovo
loader, dispatcher, cache e moduli selezionati richiedono un assemblato
integrato e relative prove. Il riuso è realizzato separatamente nell’esperimento Underworld:2904 byte.
Nel backend WORLD-01 descritto qui il recupero resta da implementare.

## Verifiche e prestazioni

I test controllano riferimenti, eventi, asset sicuri e portabili,
compilazione 2–8 gruppi, indipendenza dall'ordine di presentazione degli ID,
rifiuto esplicito delle integrazioni non supportate, mappe sovrapposte o
incomplete, guardie, frammentazione e allineamento. Il livello predefinito
genera il PRG WORLD-01 già qualificato e i medesimi file gruppo. Il nuovo
entry point non modifica shader, runtime, UI o launcher nativo.

La consegna conserva una misura nativa del livello ricostruito dal suo
formato e i comandi/raw fuori dal sorgente: VICE Turbo6510 PAL× 64,
preciso/LOD, silent, warm-up 101 refresh e misura 3072 refresh del giro A→B→A.
Il budget ipotetico non introduce un nuovo valore FPS. Documentazione corrente inclusa nella release 1.12.0.
