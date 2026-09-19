# Costruire mappe Mode 8

Questa guida descrive il contratto delle mappe **implementato e deliberatamente limitato** della 1.4.0. [MODE8.it.md](MODE8.it.md) spiega l'architettura; [QUICKSTART.md](QUICKSTART.md) prepara l'SDK. Mode 8 è un renderer bitmap 2.5D distinto, non un importatore di poligoni.

## 1. Scegliere un template completo

| Ambiente | Scena completa | Modificabile | Fisso |
|---|---|---|---|
| Un piano, pareti opache e pilastri | [perimeter.json](examples/mode8/perimeter.json) | Celle solide/libere lontano dal bordo e dal percorso | Pavimento 0, soffitto 128, nessuna apertura/rampa; camera iniziale e tutti i waypoint |
| Un piano con aperture statiche dotate di spessore | [apertures.json](examples/mode8/apertures.json) | Geometria solida/libera intorno alla separazione qualificata | Pavimento 0; soffitto stanza 96, apertura 64; separatore y=14 e due varchi; camera e waypoint |
| Due piante raccordate da rampe continue | [two-levels.json](examples/mode8/two-levels.json) | Geometria, aperture dichiarate e waypoint entro il contratto heightfield | Camera iniziale, quote ammesse, due formule/footprint delle rampe; budget numerici, percorsi e memoria |

Non sono tre editor di livelli completamente generici. Spostare un'apertura monolivello, cambiarne lo spessore, aggiungere rampe arbitrarie o spostare la camera iniziale di un template viene rifiutato. Multilivello significa una sola coppia pavimento/soffitto per posizione XY: **room-over-room escluso**. Non esistono porte animate o comandi di apertura/chiusura.

Tutte le scene contengono mappe complete 32×32. Le [piante con coordinate generate dai dati](examples/mode8/PLANS.md) mostrano celle e cambiamenti dei tutorial. Una build valida sintassi, geometria, backend, capacità e percorso automatico: non dimostra di aver campionato esaustivamente ogni possibile vista interattiva.

## 2. Coordinate e unità pubbliche

L'origine è l'angolo superiore sinistro della pianta. X cresce a destra; Y verso il basso nella pianta stampata. La cella `(x,y)` corrisponde all'indice `32*y+x`; entrambi gli indici vanno da 0 a 31. Gli array contengono righe in ordine Y crescente, ciascuna con colonne X crescenti. Righe e colonne esterne devono essere solide.

```text
             X →
        0  1  2  3 … 31
 Y  0   #  #  #  # … #
 ↓  1   #  .  .  . … #     # solid=1; . libero=0
    2   #  .  #  . … #     P camera iniziale; D apertura statica
   31   #  #  #  # … #     R marker rampa; piante reali nel link sopra
```

Le coordinate orizzontali di camera e waypoint sono **già interi Q8.8 nel JSON**: il builder non le moltiplica per 256. Il centro della cella `(x,y)` è `(256*x+128,256*y+128)`; dividere una posizione per 256 restituisce celle. Un'unità intera vale 1/256 di cella. Non sono i campi `position`, `xWU` o altri campi delle scene poligonali.

Le quote verticali ordinarie sono interi in unità di **1/32 di cella**: pavimento 32 è una cella sopra pavimento 0; soffitto 128 è quattro celle sopra zero. Le quote runtime delle rampe conservano ulteriori otto bit frazionari. `initial` contiene `[xQ8,yQ8,yaw,eyeInteger,eyeFraction]`; gli ultimi due valori rappresentano `eyeInteger + eyeFraction/256` unità verticali. L'occhio è sempre 32 unità sopra il pavimento locale.

Yaw ha 512 valori, 0–511: zero guarda +Y, 128 guarda +X, 256 guarda −Y, 384 guarda −X. L'incremento di yaw corrisponde alla rotazione a destra del comando runtime. Il wrap runtime è modulo 512; gli input pubblici sono controllati, non ricondotti silenziosamente nell'intervallo. Un'unità angolare è 360/512 gradi. FOV fisso a 60 gradi, senza override pubblico. La camera iniziale deve coincidere esattamente con quella del template.

Queste convenzioni sono distinte da [WORLD-METRICS.md](WORLD-METRICS.md): non applicare agli array Mode 8 la scala delle unità mondo o lo schema camera delle Mode 1–7.

## 3. Campi JSON effettivi

L'oggetto radice contiene **esattamente** `scene` e `navigation`, entrambi oggetti. Chiavi duplicate, campi ignoti, null al posto di array/oggetti, booleani negli array interi e campi obbligatori mancanti sono errori. Nome del file e nome della scena non determinano geometria o backend.

| Campo | Tipo / obbligatorietà / default | Dominio e dipendenze |
|---|---|---|
| `scene.schema` | stringa obbligatoria | Esattamente `3dvibe64-mode8-map-v1` |
| `scene.size` | due interi obbligatori | Esattamente `[32,32]` |
| `scene.solid` | 1024 interi obbligatori | 0 libero, 1 opaco; bordo tutto 1 |
| `scene.floor` | 1024 interi obbligatori | Mono: tutti 0. Multi: 0,32,64 oppure marker 254/255 |
| `scene.ceiling` | 1024 interi obbligatori | Mono opaco: tutti 128; mono aperture: 96 tranne celle previste a 64. Multi: 1–192 e vincoli sotto |
| `scene.initial` | cinque interi obbligatori | Camera iniziale fissa del template; unità indicate sopra; impronta libera e quota occhio corretta |
| `scene.eyeHeight` | intero obbligatorio | Esattamente 32 |
| `scene.playerHeight` | intero facoltativo; 48 | Esattamente 48; null/0 non significano default |
| `scene.heightUnit` | stringa facoltativa; `1/32 cell` | Solo questa stringa, non converte i dati |
| `scene.doors` | array obbligatorio | `[]` opaco; due rettangoli fissi mono; oggetti multi |
| `scene.ramps` | array obbligatorio | `[]` mono; due descrittori esatti multi |
| `scene.notes` | stringa facoltativa; ignorata | Descrizione umana, nessun effetto runtime |
| `navigation.camera` | tre interi obbligatori | Esattamente `scene.initial[0:3]` |
| `navigation.nodes` | array obbligatorio di coppie intere | Waypoint ciclici Q8.8; coordinate >0 e <8192. 2–193 mono, 2–160 multi; lista mono identica al template |

`solid`, `floor` e `ceiling` sono sempre completi, anche nelle celle solide; anche le quote di queste celle rispettano il dominio del backend. Zero è significativo in `solid` e `floor`, non equivale a un campo assente. `doors: []` e `ramps: []` dichiarano legittimamente l'assenza; null e omissione non sono validi.

L'autore scrive array e metadati delle aperture/rampe. Owner, mappe direzionali di eventi, ID di piani/profili, lookup, indirizzi bitmap e assembly vengono **generati o forniti dall'SDK**. Non modificare queste tabelle interne per far accettare una mappa.

### Monolivello opaco

La disposizione solido/libero deve conservare bordo chiuso e percorso libero. Ogni tratto esposto contiguo e collineare diventa un owner: il layout ammette **96 owner più sentinella 0**. Anche una mappa 32×32 può eccedere questo budget aggiungendo ostacoli. Non esiste volume superiore in questa famiglia.

### Aperture statiche monolivello

`doors` deve essere esattamente `[[10,14,11,14],[22,14,23,14]]`: rettangoli di celle con estremi inclusi. La riga y=14 è solida tranne x=10,11,22,23. Queste quattro celle sono libere con soffitto 64; tutte le altre hanno soffitto 96. Pavimenti tutti 0.

```text
Pianta del separatore y=14 (X crescente):
  … # # [10 D][11 D] # … # [22 D][23 D] # …
  spessore: da y=14 a y=15, esattamente una cella orizzontale

Sezione verticale di un'apertura:
  z=96  ───────── soffitto stanza ─────────
        █████████ architrave solido ██████
  z=64  ───────── intradosso ──────────────
        │  vano attraversabile, altezza64 │
  z=32  │  occhio                         │
  z=0   ───────── pavimento ───────────────
```

Separatore continuo e due varchi isolati garantiscono che un raggio non richieda due volumi superiori distinti prima della parete opaca. Il solo pavimento uniforme non basta a selezionare questo backend. Fiancate e profondità dell'architrave restano renderizzate.

### Heightfield multilivello

Quote ordinarie: 0,32,64. I marker 255/254 sono **selettori di formule**, non altezze 255/254. Sono già nel template completo: conservarne impronta e metadati. Non sono esposti gradini arbitrari, salti di quota, altre direzioni o pendenze delle rampe.

| Marker | Impronta di celle libere ammessa | Formula in unità verticali, Y in celle | Estremi |
|---|---|---|---|
| 255 | x=8..10, y=11..14 | `8*(Y-11)` | y=11:0; y=15:32 |
| 254 | x=14..16, y=18..21 | `8*(Y-14)` | y=18:32; y=22:64 |

Gli oggetti esatti sono in [two-levels.json](examples/mode8/two-levels.json): `marker`, `axis:"y"`, `origin`, `start`, `end`, `bottom`, `top`. Tutti gli altri campi sono interi; nessuno è facoltativo; l'array di due oggetti deve coincidere col template. L'origine 14 della seconda formula è deliberatamente diversa dal suo inizio 18.

```text
pavimento64                           ───────── superiore
                                     / marker254 (18 ≤ Y < 22)
pavimento32            ──────────────    pianerottolo
                      / marker255 (11 ≤ Y < 15)
pavimento 0  ────────                         inferiore
```

Ogni confine attraversabile deve avere quote pavimento uguali sui due lati, valutando la formula delle rampe su quel confine. Salti improvvisi fra celle libere sono rifiutati. Celle solide possono separare quote incompatibili. Ogni cella libera richiede almeno 48 unità di spazio verticale. Il controllo conservativo delle rampe usa 64 come limite del pavimento per entrambi i marker; per le celle ordinarie usa la quota effettiva. L'occhio segue la rampa continuativamente, frazione compresa.

Un'apertura multi della scena originale è `{ "axis":"y", "plane":6, "start":16, "end":18, "floor":0 }`. Con axis y, plane è la riga e start/end sono X inclusi; con axis x, plane è la colonna e start/end sono Y inclusi. Indici 1–30 e start≤end. Tutte le celle dichiarate devono essere libere, con quel pavimento ordinario e soffitto esattamente `floor+80`. Viceversa, ogni cella libera con ceiling−floor=80 deve essere dichiarata. Nessun campo aggiuntivo ammesso nell'oggetto.

Budget globali: **≤255 chiavi di profilo e ≤255 record evento**, incluse le eventuali sentinelle, con ID a 8 bit. Distinto è il buffer di un singolo raggio: il builder dimostra un limite conservativo su percorsi monotoni della griglia **strettamente inferiore a 15 eventi incontrati** prima di un muro opaco. L'originale ha limite 11. Una scena può rispettare gli ID globali ma eccedere il percorso, o viceversa. I 32 slot della cache non limitano a 32 le chiavi globali: l'espulsione è prevista e incide sui costi.

## 4. Camera, collisioni e navigazione

W/S avanti/indietro, A/D rotazione. Il runtime interattivo usa un raggio di 48/256 di cella, verifica l'impronta e permette scorrimento lungo le pareti. Non impone un limite del 70% di occupazione dello schermo. L'automatico conserva l'inseguimento continuo dei waypoint, non svolte cardinali. Il raggio di collisione automatico è 224/256 nella scena aperture e 48/256 nelle altre due.

Camera iniziale fissa per tutte le famiglie. Le due liste mono sono fisse anche nell'ordine. Nel multi i waypoint possono cambiare entro 160 elementi, conservando lo start del template, percorribilità e un giro ciclico completo senza tick bloccati nella simulazione host di 30.000 tick. Clearance insufficiente, destinazioni irraggiungibili o ostacoli sull'itinerario producono errori, non pianificazione automatica. Il builder pubblico non esegue pathfinding.

La stessa validazione si applica alle build interattive: qualifica la coppia scena/template, compreso il relativo esempio automatico. I tutorial conservano camera e itinerario originali. Non è stata verificata esaustivamente ogni possibile traiettoria manuale.

Palette fissa del contratto: indici VIC-II 0/9/8/7, pigmenti delle pareti per orientamento e retino del soffitto ancorato allo schermo. Nessun campo scena espone palette, RGB per parete, texture, luce o FOV. Modificarli richiede sviluppo dei sorgenti, non normale definizione della mappa.

## 5. Tre tutorial geometrici eseguibili

Usare i file finali completi: nessun elemento mancante o modifica assembly. Per rifare manualmente l'intervento, copiare l'originale fuori dall'SDK e applicare le sole variazioni indicate.

| Tutorial | Modifiche esatte | File finale completo | Risultato effettivo del precedente studio |
|---|---|---|---|
| Spostare un pilastro | `solid[15*32+21]=0`; `solid[16*32+21]=1` | [perimeter-tutorial.json](examples/mode8/perimeter-tutorial.json) | Nessun beneficio pratico significativo sul giro; non un'ottimizzazione prestazionale consigliata |
| Spostare pilastro 2×2 | Liberare x=15..16 a y=18; rendere solidi x=15..16 a y=20; y=19 resta solida | [apertures-tutorial.json](examples/mode8/apertures-tutorial.json) | Calo CPU locale ma nessun miglioramento sostanziale del p95 del giro; non una raccomandazione generale |
| Restringere apertura inferiore | Impostare `solid[6*32+16]=1`; nell'apertura y=6 con start16 cambiare start a17 | [two-levels-tutorial.json](examples/mode8/two-levels-tutorial.json) | Larghezza3→2celle; beneficio parziale sulle pause, worst del piano superiore invariato |

Dalla radice dell'SDK estratto, con Python, PowerShell e 64tass disponibili:

```powershell
Copy-Item examples/mode8/perimeter-tutorial.json ../my-perimeter.json
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile ../my-perimeter.json -ValidateOnly
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile ../my-perimeter.json -Mode8Run interactive -OutputDirectory ../my-perimeter-build
x64sc -default -pal -autostartprgmode 1 ../my-perimeter-build/3Dvibe64.prg
```

Build complete degli altri tutorial:

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile examples/mode8/apertures-tutorial.json -Mode8Run interactive -OutputDirectory ../my-apertures-build
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile examples/mode8/two-levels-tutorial.json -Mode8Run auto -OutputDirectory ../my-two-levels-build
```

Scegliere una cartella esterna nuova e vuota per ciascuna build: output interno all'SDK rifiutato. `-Mode8Run` ha default `interactive`; `auto` percorre l'itinerario validato. Il PRG rileva PAL/NTSC; provare NTSC sostituendo l'opzione dell'emulatore con `-ntsc`. I test Mode 8 e la qualificazione dello ZIP estratto controllano i comandi pubblici. La build minima richiede solo libreria standard Python, PowerShell e 64tass: non importa emulatori o profiler.

## 6. Errori comuni

| Codice | Causa | Correzione |
|---|---|---|
| `SCHEMA`, `FORMAT`, `ARRAY`, `INTEGER`, `UNKNOWN_FIELD` | Struttura/tipo errato, array incompleto, proprietà poligonale | Ripartire dal template completo, usare interi e non null/booleani |
| `BORDER` | Cella libera sul bordo esterno | Ripristinare la cella solida indicata |
| `INITIAL_POSE`, `CAMERA`, `TEMPLATE_CAMERA` | Impronta occupata, occhio errato, camera discordante o start modificato | Ripristinare la camera del template e liberarne l'impronta |
| `MONO_CEILING`, `MONO_QUOTE`, `MONO_FLOOR` | Quote stanza fuori contratto | Ripristinare i valori della famiglia |
| `MONO_APERTURES`, `MONO_SEPARATOR` | Varco spostato/ridimensionato, separatore bucato | Ripristinare due aperture di spessore1 e riga14 |
| `RAMP_FORMULA`, `MULTI_GEOMETRY` | Marker, impronta o raccordo errato | Ripristinare rampe ammesse e continuità dei pavimenti adiacenti |
| `HEADROOM`, `DOOR_CELL`, `DOOR_METADATA` | Spazio verticale insufficiente o metadati incoerenti | Correggere cella e descrittore indicati |
| `OWNER_CAPACITY`, `EVENT_CAPACITY`, `PATH_CAPACITY` | Superati budget numerici distinti | Semplificare rispetto al budget indicato, senza ridurre precisione silenziosamente |
| `MONO_NAV`, `MULTI_NAV_CAPACITY`, `AUTO_COLLISION`, `AUTO_TOUR` | Percorso non ammesso/bloccato o giro incompleto | Ripristinare lista mono; controllare nodi, clearance e ciclo multi |
| `LOW_BUDGET`, `ASSEMBLER` | Superato budget sorgenti/dati | Leggere assembler.log e ridurre dati variabili ammessi, non modificare indirizzi |
| `OUTPUT_DIRECTORY`, `OUTPUT_EXISTS` | Output nell'SDK o cartella non vuota | Usare una nuova cartella esterna |

## 7. Atlante opzionale dei costi

Raggi lunghi nello spazio vuoto, discontinuità degli owner, aperture successive e profili distinti possono costare più di una stanza apparentemente affollata. La cache multi ha 32 profili: una vista con più profili distinti può causare espulsioni ripetute. Frequenza di lettura di una cella non significa costo totale di quella cella; i costi condivisi dei profili non vanno sommati due volte.

Dipendenze opzionali: `python -m pip install py65==1.2.0 Pillow`. Compilare prima la scena, poi eseguire:

```powershell
python -B scripts/analyze_mode8.py --scene examples/mode8/perimeter.json --build ../perimeter-reference-build --sampling examples/mode8/sampling/perimeter.json --out ../perimeter-cost
```

Usare una build della **stessa** scena, per esempio quella del comando in [MODE8.it.md](MODE8.it.md). Il campionamento contiene `poses`, ciascuna `[xQ8,yQ8,yaw,eyeInteger,eyeFraction]`, valutate in ordine con RAM persistente. Su una mappa diversa ricontrollare le pose: campioni con impronta/quota/intervallo errati vengono registrati e saltati, non convertiti.

Output: `poses.json`, `poses.csv`, `REPORT.md`, `atlas-host.png`. Media e massimo osservato per cella sono separati; la freccia indica lo yaw più costoso campionato. Grigio=non campionato, blu=irraggiungibile, rosa=invalido, nero=solido. È un **atlante host**, non uno screenshot VICE. Ogni render valido confronta tutti i 7.040 byte bitmap, viewport e margini, contro l'oracolo fixed indipendente.

I cicli derivano dalle istruzioni 6502 assemblate eseguite in py65, senza stall VIC, IRQ, input, simulazione e presentazione: non sono FPS nativi. Per questi usare `scripts/qualify_mode8.py` con x64sc stock. Nessuno strumento inserisce diagnostica nel PRG distribuito. Il worst campionato non è un limite globale; non viene fornito un ottimizzatore automatico delle mappe né un guadagno garantito.
