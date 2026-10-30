# WORLD-01 — gruppi residenti — 1.15.1

Stabile1.15.1, release GitHub di soli sorgenti. [Stato release](../../../RELEASE-STATUS.it.md) · [Qualifica corrente](../../../QUALIFICATION-1.15.1.it.md). Scene e asset sono esterni; nessun progetto demo incluso.

> SDK sorgente stabile1.15.1 pubblicato su GitHub. [Stato e supporto](../../../RELEASE-STATUS.it.md).

Release stabile GitHub 1.15.1: [ottimizzazioni correnti](../../../RENDER-OPTIMIZATIONS.it.md), [input esterni](../../../EXTERNAL-INPUTS.it.md). Tutte le demo, gli esempi e le prove native sono esterni alla distribuzione sorgente.


La distribuzione 1.12.0 include soltanto il modulo riutilizzabile. I nuovi progetti/asset demo sono esclusi. Catture, checkpoint e misure native sotto descrivono prove storiche esterne. Le build di progetto richiedono `--project-source`; vedere la [guida di integrazione](../../../GAMEPLAY.it.md).


Contratto corrente della release 1.12.0; i numeri dei checkpoint indicano
la provenienza delle prove. [English](WORLD-DEV.en.md).

Il profilo sperimentale `room-groups` carica file esterni attraverso il
KERNAL del C64. La demo visita hall → crypt → hall nella UI LABIRINTO:
due gruppi di due stanze, con larghezze, pavimento e porta differenti.
Un solo gruppo occupa gli array attivi di geometria e materiali; texture,
palette e fotogrammi del guardiano restano condivisi e residenti.

```powershell
python -B work/build-gameplay.py --profile room-groups --out ../builds/world --project-source ../my-project
python -B work/qualify-gameplay.py --out ../builds/world --checks --benchmark --launcher
```

L'output deve essere nuovo e fuori dal repository. Avviare `launch-demo.cmd`
insieme alla sua cartella `project/media`: il solo PRG non comprende gli
altri gruppi. Il launcher imposta VICE Turbo6510 PAL × 64, dispositivo 8 con
backend filesystem, trap KERNAL attive, emulazione del drive e bus disattivate.
I tempi di lettura misurati descrivono questo backend, non un 1541 fisico.
Demo silenziosa, texture precise per pixel su tutte 60 righe, LOD 14–22 WU.

N richiede il vicino successivo; P il precedente. Il primo comando passa
alla visita manuale. WASD muove, SPAZIO usa il guardiano/porta, R riprende
il giro nel gruppo corrente. N/P sono comandi espliciti: non sono portali
attraversabili senza interruzione. L'itinerario automatico predefinito usa
24 chiavi per gruppo; le configurazioni estese devono scegliere collegamenti
e controlli applicativi adatti al loro percorso.

## Configurazione e limiti

`assets/world-groups.json` richiede schema 1, flag booleani enabled e
autoTransitions, capacityBytes 1024 e 2–8 gruppi. Ogni gruppo dichiara un id
unico, rooms 2, halfWidth intero 18–24, floorLevel nullo oppure intero 0–32,
doorIndex 1–3, initialOpen booleano e 1–2 vicini. Il grafo deve essere connesso,
con collegamenti reciproci, senza duplicati o auto-collegamenti. Il builder
accetta `--world-groups percorso.json`.

È un formato limitato allo schema di 21 vertici e 32 facce della prova porta:
due stanze entro un rettangolo convesso, divisorio Y 8 e apertura centrale
con porta mobile. Variazioni ammesse: larghezza, livello Gouraud del
pavimento, colore flat della porta e stato iniziale. Collisione laterale
adeguata alla larghezza caricata. Non è un importatore di topologie
arbitrarie. Non combina implicitamente tutti gli altri profili sperimentali.

## File e transazione

Ogni file raw `wg00`…`wg07` occupa 762 byte: header 12, payload 748, CRC 16-CCITT 2.
Header: magic WG01, indice gruppo,2 stanze,21 vertici,32 facce, lunghezza payload
little endian, mezza larghezza e stato iniziale della porta. Il payload
contiene 27 canali di coordinate, indici, UV, materiali, Gouraud e metadati
di ordinamento; destinazioni e lunghezze sono compilate nel programma.
Il file contiene esclusivamente dati, senza indirizzi o codice eseguibile.

Il buffer di staging è 1024 byte. OPEN/CHKIN/CHRIN leggono al massimo tale
capacità; EOF, errori I/O, lunghezza esatta, magic, conteggi, indice e CRC
vengono controllati prima dell'installazione. Il CRC deve corrispondere
sia al trailer sia al CRC atteso residente, determinato dal builder.
Un file modificato richiede la ricompilazione del programma associato.

`wg_request`: A=indice, carry 1=accettato/no-op, carry 0=rifiutato. Un solo
target può essere pendente e deve essere un vicino del gruppo corrente;
all'avvio è consentito esclusivamente il gruppo 0. `wg_service`, chiamata
all'inizio di una vista, esegue la transazione. Durante la richiesta pendente
il passo di simulazione resta fermo; durante l'I/O rimane l'ultima vista
completa. La porta del processore, CIA 2,254 byte di zero page e 32 byte di vettori
RAM vengono salvati e ripristinati. Un IRQ dedicato mantiene i contatori
di refresh anche con il KERNAL visibile. Codice I/O, wrapper IRQ e contatori
devono essere allocati sotto $D 000; il builder controlla questa condizione.

`wg_error`:0 successo,1 indice,2 richiesta già pendente,3 collegamento
assente,4 I/O/capacità,5 formato/integrità. Il fallimento lascia geometria,
stato e camera attivi invariati; può sovrascrivere soltanto lo staging e
i contatori diagnostici. La coda viene liberata anche in caso di errore.

## Stato e memoria

Ogni gruppo conserva 17 byte:16 di slot e 1 di prima visita. Quattordici campi
sono attivi: stato del guardiano, contatori eventi/rifiuti, altezza Q8 e
stato della porta, sicurezza, stati visitati, attraversamenti e cursori,
hold/fotogramma dell'animazione. I gruppi inattivi restano congelati.
Al ritorno si ripristinano questi campi e si riparte dall'ingresso frontale;
la posizione della camera non viene conservata. La persistenza dura per
la sessione in RAM, senza salvataggio su disco. Il frame decodificato viene
invalidato per ricostruirlo correttamente dopo il cambio.

Build predefinita: staging 1024 byte, blocco I/O 620, manager 1237, slot compresi
nel manager. Restano 1006 byte nei gap legali, contro 3502 nella prova porta.
Il delta netto 2496 include il risparmio 408 della camera ridotta a 24 chiavi.
Il controllo con 48 chiavi e transizioni disattivate lascia 598 byte: delta 2904.
Non sono ridotti i buffer del renderer, della UI o del guardiano.
`enabled:false` esclude l'estensione e ricostruisce il PRG `door-entity`
qualificato byte per byte. I profili precedenti restano separati.

## Qualificazione

Le prove native verificano file realmente letti da device 8, tutti 27 canali,
ritorno con stato esatto, comandi/rifiuti/tasti mantenuti, porta che riprende
il movimento, file mancanti/vuoti/troncati/oversize/corrotti o errati.
Un IRQ forzato durante la lettura verifica il ripristino di zero page e
vettori. Due build statiche senza loader costituiscono il riferimento per
28 viste native: bitmap, screen e ColorRAM confrontati, UI originale,
near plane, viste oblique, stati porta, occlusione del guardiano e LOD.
Una variante a 8 gruppi percorre tutti 16 ambienti e torna al primo gruppo.

I benchmark della consegna sono fuori dal pacchetto sorgente, insieme ai
raw, comandi e hash. Prima/dopo usa la medesima rotta originale di 48 chiavi
con autoTransitions:false; la demo attiva misura invece il percorso A→B→A.
Solo nuove viste complete, contatore nativo e cicli PAL base; almeno 20 secondi
emulati dopo il warm-up. Warp e tempo host sono esclusi dal calcolo FPS.
Documentazione corrente inclusa nella release 1.12.0.
