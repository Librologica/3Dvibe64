# 3Dvibe64 — Guida per il programmatore assembly

Questa guida è rivolta a chi conosce il Commodore 64, il 6510/6502, il VIC-II e un assembler tradizionale e vuole usare o modificare 3Dvibe64 con un normale processo di sviluppo software. Non è una guida al vibe coding e non presuppone l'impiego di strumenti generativi. Il percorso pratico assistito da Codex è documentato separatamente in [VIBE-CODING-GUIDE.it.md](VIBE-CODING-GUIDE.it.md).

La documentazione generale dell'API, delle scene e dei profili di rendering resta in [README.it.md](README.it.md). Le unità geometriche e temporali sono definite in [WORLD-METRICS.md](WORLD-METRICS.md). Questo documento spiega invece come è costruito l'engine, come ottenere il sorgente assembly effettivo, come orientarsi nelle routine generate e come apportare modifiche riproducibili.

## 1. Il modello mentale corretto

3Dvibe64 non è distribuito come un progetto assembly convenzionale composto da `main.asm`, `renderer.asm`, `camera.asm` e file `.inc`. È un **generatore di programmi C64 specializzati**.

La catena reale è:

```text
scena JSON + opzioni CLI
          |
          v
work/build-3Dvibe64.ps1
  - valida la scena
  - calcola tabelle e layout
  - seleziona le feature compile-time
  - emette il sorgente 6510/6502
          |
          v
work/3Dvibe64.asm
          |
          v
64tass
          |
          v
work/3Dvibe64.prg
work/build/3Dvibe64.prg
```

Il file `work/3Dvibe64.asm` è quindi un prodotto di build, non la sorgente autorevole del repository. Una scena o una combinazione di opzioni diversa può generare un programma con routine, tabelle, indirizzi e dimensioni differenti.

Questa scelta ha tre conseguenze pratiche:

- per **usare** l'engine si modificano normalmente JSON e opzioni del builder;
- per **studiare e debuggare** l'engine si genera e si legge `3Dvibe64.asm`;
- per una **modifica permanente** dell'engine si cambia `build-3Dvibe64.ps1`, poi si rigenera l'ASM e si eseguono i test.

Una modifica fatta soltanto a `work/3Dvibe64.asm` è valida per un esperimento locale, ma viene sovrascritta alla build successiva.

## 2. Cosa contiene la distribuzione

I file più importanti per il programmatore assembly sono:

| Percorso | Ruolo |
|---|---|
| `work/build-3Dvibe64.ps1` | Sorgente autorevole del builder e del generatore dell'engine. Contiene logica host PowerShell, template assembly, sostituzioni e controlli di memoria. |
| `examples/*.json` | Scene pubbliche minimali o dimostrative da compilare. Sono anche test leggibili dell'API. |
| `validation/**/*.json` | Scene mirate a regressioni di clipping, memoria, profondità e outline. |
| `work/tools/c64_material_scales.generated.json` | Rampe VIC-II usate da famiglie di materiali e livelli di riflettività. |
| `scripts/test_*.py` | Contratti host-side e test di release/runtime. |
| `PACKAGE-MANIFEST.json` | Capacità pubbliche, hash delle build di riferimento e firme runtime attese. |
| `MANIFEST.sha256` | Integrità dei file permanenti della release. |

La distribuzione non contiene volutamente PRG o ASM permanenti. Per mantenere pulito il checkout, conviene compilare in una copia di lavoro eliminabile.

## 3. Toolchain

### 3.1 Componenti necessari

Per una build ordinaria servono:

- Windows PowerShell;
- 64tass 1.60 o successivo;
- una scena JSON valida.

Per debug e contratto runtime è consigliato VICE x64sc. Per i test host-side serve Python 3.

Il builder cerca 64tass in questo ordine:

1. percorso completo in `TASS64_EXE`;
2. file o directory indicata da `TASS64_PATH`;
3. `work/tools/64tass/64tass.exe`;
4. `work/tools/64tass/64tass-1.60.3243/64tass.exe`;
5. `64tass.exe` o `64tass` nel `PATH`.

VICE usato dai test può essere indicato con `VICE_X64SC` o `VICE_EXE`, oppure essere disponibile nel `PATH`.

### 3.2 Controllo rapido

```powershell
64tass.exe --version
x64sc.exe -version
python --version
```

Se PowerShell impedisce l'esecuzione degli script, avviare il builder con `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ...`; non è necessario modificare permanentemente la policy del sistema.

## 4. Prima build leggibile

In una copia della radice del pacchetto:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\work\build-3Dvibe64.ps1 `
  -SceneFile .\examples\basic-solid-reference.json `
  -GraphicsMode 4 `
  -CameraMode fixed `
  -CameraViewport normal `
  -Quality balanced `
  -Projection table `
  -MemoryLayout stable `
  -NoFpsOverlay `
  -SkipCmdUpdate
```

Gli artefatti principali sono:

| File | Contenuto |
|---|---|
| `work/3Dvibe64.asm` | Sorgente generato, già specializzato per scena e opzioni. |
| `work/3Dvibe64.prg` | Programma C64 assemblato. |
| `work/build/3Dvibe64.prg` | Copia del PRG usata dal flusso di build. |

Senza `-SkipCmdUpdate` il builder può anche aggiornare script `.cmd` di assemblaggio/esecuzione. Per build di confronto e automazione è preferibile mantenerlo.

Il PRG contiene un piccolo stub BASIC a `$0801` con `SYS 2061`; il codice macchina inizia a `$080D` e la label principale è `start`.

## 5. Rendere l'ASM navigabile

Il sorgente generato può superare ampiamente le centinaia di kilobyte. Prima di leggerlo linearmente, creare label, listing e mappa con 64tass:

```powershell
Set-Location .\work

64tass.exe -a -B `
  --vice-labels `
  --labels=build\3Dvibe64.vice.labels `
  --map=build\3Dvibe64.map `
  --list=build\3Dvibe64.lst `
  -o build\3Dvibe64-debug.prg `
  .\3Dvibe64.asm
```

Significato delle opzioni principali:

- `-a`: indirizzamento compatibile con il builder;
- `-B`: espansione automatica dei branch lunghi;
- `--vice-labels`: formato label importabile dal monitor VICE;
- `--labels`: tabella simboli;
- `--map`: intervalli e sezioni prodotti;
- `--list`: listing con indirizzi e byte;
- `-o`: PRG di output.

Usare un nome di output diverso evita di sostituire accidentalmente il PRG validato dal builder.

Per cercare rapidamente nel file:

```powershell
rg -n "^start:|^main_loop:|^render_frame_begin:|^render_frame_end:" .\work\3Dvibe64.asm
rg -n "^project_vertex:|^face_visible:|^draw_depth_buckets:" .\work\3Dvibe64.asm
rg -n "^clip_|^explorer_|^fill_|^plot_wire" .\work\3Dvibe64.asm
rg -n "^\* =|^; ===" .\work\3Dvibe64.asm
```

Non tutte le label elencate in questa guida sono presenti in ogni build: il generatore elimina o disattiva percorsi incompatibili con la configurazione scelta.

## 6. Anatomia del sorgente generato

L'ASM è organizzato approssimativamente in questo ordine:

1. stub BASIC e origine del codice;
2. assegnazioni zero-page e alias scratch;
3. costanti derivate dalla scena e contratti compile-time;
4. inizializzazione del C64 e del VIC-II;
5. loop principale, simulazione e input;
6. trasformazione, camera e proiezione;
7. raccolta facce/edge e depth buckets;
8. clipping, culling e Ground;
9. rasterizzatori solidi, pattern e wire;
10. tabelle, dati della scena e buffer runtime.

Le sezioni `; === ... Contract ===` sono particolarmente utili. Riassumono la configurazione realmente compilata, per esempio:

- dimensione e origine della viewport;
- modalità grafica effettiva;
- camera e profilo near;
- feature di clipping/culling;
- percorsi Ground;
- ottimizzazioni e fallback emessi;
- numero di mesh, oggetti, vertici e facce.

Trattare queste costanti come un report di compilazione: prima di diagnosticare una routine, controllare che il relativo flag sia effettivamente a `$01`.

## 7. Flusso del programma e del frame

### 7.1 Avvio

La sequenza parte da `start`. A seconda della build inizializza:

- stato CPU/CIA/VIC-II;
- bitmap, Screen RAM e Color RAM;
- tabelle e buffer dirty;
- materiali e luce;
- camera fissa o stato `explorer_*` delle camere mobili;
- eventuale split Generic Text/FPS e IRQ associato.

Il controllo passa quindi a `main_loop`.

### 7.2 Loop principale

Le label più utili per seguire un frame sono:

```text
main_loop
  -> attesa/schedulazione del tick video
  -> lettura input e aggiornamento camera
  -> avanzamento simulazione/oggetti/luce/timeline
  -> render_frame_begin
  -> render_world_background
  -> render_scene_renderer
  -> render_frame_end
  -> presentazione/scambio buffer
```

Il ritmo logico della simulazione è 50 ST al secondo sia su PAL sia su NTSC. La presentazione video e l'avanzamento logico non vanno confusi: su NTSC il builder emette la compensazione necessaria.

### 7.3 Inizio e fine frame

`render_frame_begin` prepara il back buffer, lo stato dirty e le cache per il nuovo frame. `render_world_background` gestisce fondo e Ground quando presenti. `render_scene_renderer` entra nella pipeline scelta dal GraphicsMode. `render_frame_end` completa il frame e rende presentabile il buffer.

Per misurazioni o breakpoint stabili, `render_frame_begin` e `render_frame_end` sono punti migliori di una routine interna molto specializzata.

### 7.4 Split testuale same-bank DEV7

Quando l’overlay visivo è compilato, ogni bank VIC-II possiede la propria Screen RAM e il proprio charset compatto. L’IRQ mostra tre righe di caratteri, passa al fast path bitmap a `TEXT_BITMAP_IRQ_RASTER=$4A` e avvia il body a `TEXT_BODY_FIRST_RASTER=$4B`. `TEXT_HEADER_CELL_ROWS=3` e `TEXT_HEADER_SCREEN_BYTES=120` sono un contratto pubblico di memoria: `apply_active_material` deve iniziare dopo il byte 119 in entrambi gli screen buffer.

Il body 3D normal misura quindi 160×88 a Y=12; small misura 128×80 a Y=12. `-NoFpsOverlay` compila il percorso solo bitmap 1.1.0 invariato. Generic Text usa una stringa compatta terminata da `$FF`; zero è un glifo spazio valido. Le cifre FPS e Generic Text vengono scritti in entrambe le Screen RAM, senza copiare dalla bank visualizzata all’altra.

A runtime, `F` commuta l’intero split, non le sole celle numeriche FPS. Il percorso OFF continua a scegliere bank VIC, Screen RAM e bitmap da `drawbuf`. `TEXT_CHARSET_BYTES` deriva da `TEXT_CHARSET_GLYPH_COUNT`: vale 96 per il charset dei soli FPS e 184 quando è emesso Generic Text. Il toggle sicuro pulisce esattamente quel prefisso bitmap quando lo split è nascosto e lo ripristina prima di riattivare l’IRQ testuale; il timing `$4A`/`$4B` resta invariato.

## 8. Pipeline 3D

La pipeline concettuale è:

```text
mesh/object data
  -> trasformazione oggetto
  -> trasformazione camera
  -> profondità geometrica
  -> proiezione
  -> classificazione near/Ground
  -> backface culling
  -> clipping
  -> inserimento nei depth bucket
  -> painter order far-to-near
  -> shading/materiale
  -> fill, pattern, wire o outline
```

L'ordine concreto può variare per modalità e fast path. Alcune build preparano o proiettano dati in anticipo; altre mantengono fallback completi per facce attraversanti il bordo.

### 8.1 Trasformazione e camera

Le camere `fixed`, `walkLite` e `walkFull` condividono la semantica della scena, ma non necessariamente lo stesso codice generato.

- `fixed` è specializzata e più compatta;
- `walkLite` usa yaw e pitch;
- `walkFull` aggiunge roll.

Le routine mobili hanno generalmente prefisso `explorer_`. Punti di ingresso utili includono:

- `explorer_init_camera`;
- `explorer_scan_keys`;
- `explorer_advance_camera_tick`;
- `explorer_prepare_motion_axes`;
- `explorer_prepare_view`;
- `explorer_transform_project_vertices`;
- `explorer_project_x16` e `explorer_project_y16`.

Le coordinate pubbliche usano normalmente `world-z-up`; il builder le converte nella convenzione interna `engine-y-up`. Non correggere gli assi direttamente nell'ASM senza verificare [WORLD-METRICS.md](WORLD-METRICS.md) e le funzioni PowerShell `Convert-SceneVectorToEngine` / `Convert-EngineVectorToScene`.

### 8.2 Profondità e proiezione

La profondità geometrica e l'indice della tabella prospettica sono concetti distinti. Nel sorgente generato sono documentati anche dagli alias:

```text
camera_depth_geometric_lo/hi
projection_table_index_lo/hi
```

Il bias della tabella serve all'indirizzamento e non deve contaminare near plane, culling, sorting o depth buckets.

Le label da controllare sono:

- `project_vertex`;
- `project_vertex_extended_table`;
- `project_vertex_reference`;
- `projection_depth_index_from_p1`;
- `explorer_project_axis_offset` nelle camere mobili.

Il profilo `table` è quello normale. `reference` privilegia chiarezza matematica e confronto; `extended-table` usa una tabella estesa dove prevista. Non assumere che i tre percorsi abbiano gli stessi registri temporanei o gli stessi costi.

### 8.3 Near plane e clipping

I profili pubblici sono `default`, `late` e `clip`:

- `default`: reject e divisore minimo storici;
- `late`: accetta profondità più vicine ma rigetta una faccia che attraversa il piano camera;
- `clip`: clipping poligonale contro il piano camera.

Il clipping a schermo e il clipping near usano buffer A/B fino a 12 vertici in alcune configurazioni. Le famiglie di label più rilevanti sono:

- `camera_plane_*`;
- `clip_loaded_face_near_poly`;
- `clip_loaded_face_poly_x`;
- `clip_poly_*`;
- `clip_project_*`;
- `ground_plane_*` per il piano Ground.

La pipeline è monofacciale: abilitare il clipping non rende automaticamente il renderer two-sided.

### 8.4 Culling

`face_visible` è un punto di riferimento del backface test screen-space. Con `-FaceCullProfile stable` le build Mode 4/5 possono usare anche le routine `stable_face_cull_*` e `camera_plane_original_facing` nelle condizioni quasi edge-on.

Prima di cambiare il segno di un test o l'ordine dei vertici, verificare:

- convenzione degli assi;
- winding delle facce sorgente;
- trasformazione camera;
- comportamento delle facce clippate;
- salvataggio delle cache luce usate dallo shading.

Una correzione locale al culling può produrre regressioni apparentemente scollegate nei materiali dinamici.

### 8.5 Depth buckets e painter order

Le facce visibili vengono raccolte in bucket di profondità a 16 bit e disegnate far-to-near. Le label tipiche sono:

- `clear_depth_buckets`;
- `load_face_visible`;
- `face_far_depth`;
- `draw_depth_buckets`;
- `draw_bucket_wire_object` per alcuni percorsi wire.

I principali array runtime includono `bucket_head`, `bucket_used_list`, `face_next` e, quando necessario, il proprietario oggetto/faccia. Con `meshSourceSharing` una bucket entry deve conservare l'identità dell'istanza oltre alla faccia locale.

Non sostituire il painter order con un semplice ordine sorgente: occlusione fra istanze, outline Mode 5 e precedenza deterministica dipendono dall'ordine globale.

### 8.6 Rasterizzazione

I percorsi principali sono:

- wire e hidden-wire: `draw_wire_*`, `plot_wire_point`, `plot_wire_horizontal`, `plot_wire_vertical_run`, `trace_edge_convex`;
- facce: `draw_loaded_face_*`, `draw_direct_face_*`, `build_loaded_face_bounds`;
- span: `direct_fill_span_*`, `fill_bounds_solid_*`, `fill_bounds_pattern_*`;
- outline Mode 5: `mode5_draw_loaded_polygon_outline` e routine `mode5_*` correlate.

Il renderer contiene fast path e fallback. Un percorso veloce deve essere usato soltanto quando sono già garantiti viewport, near plane e integrità del poligono; i casi attraversanti i bordi devono restare sul percorso validato.

## 9. GraphicsMode dal punto di vista dell'engine

| Mode | Pipeline principale |
|---|---|
| 1 | Wireframe. Può usare edge precomputati e percorsi diretti. |
| 2 | Hidden-wire. Conserva classificazione facce, depth/maschere e disegna i bordi visibili. |
| 3 | Solido con shading statico e ottimizzazioni specifiche di fill/Ground. |
| 4 | Solido con shading dinamico, pipeline XY-Q2 e materiali runtime. |
| 5 | Pipeline Mode 4 più outline del poligono finale post-clipping. |

Il numero del mode non è un semplice flag runtime: determina quanto codice e quali buffer vengono emessi. Per confrontare due mode, generare due directory di build separate e diffare ASM, mappe e label.

## 10. VIC-II, bitmap e materiali

Il renderer normale usa bitmap multicolore a doppio buffer, con risoluzione logica 160×100 espansa a 320×200 pixel fisici.

In una build `stable` tipica sono visibili questi elementi:

- Screen RAM A intorno a `$5C00`;
- bitmap A a `$6000-$7FFF`;
- buffer runtime a partire da `$8000`, con limite prima della Screen RAM B;
- Screen RAM B a `$8C00-$8FFF`;
- bitmap B a `$A000-$BFFF`;
- Color RAM VIC-II a `$D800-$DBE7`.

Gli indirizzi effettivi e l'uso delle aree cambiano con layout, overlay e feature. Le origini `* =`, le costanti `BITMAP_*`, `SCREEN_*`, `RUNTIME_*` e il file `.map` della specifica build sono l'autorità finale.

Ogni cella bitmap multicolore usa:

| Codice pixel | Colore |
|---|---|
| `00` | background globale `$D021` |
| `01` | nibble alto della Screen RAM |
| `10` | nibble basso della Screen RAM |
| `11` | Color RAM |

Le rampe di materiale sono espresse come Dark/High/Highlight:

```text
screenByte = (Dark << 4) | High
colorRam   = Highlight
```

I dati di riferimento si trovano in `work/tools/c64_material_scales.generated.json`. Quando più facce pretendono palette incompatibili nella stessa cella, entra in gioco la policy VIC-II selezionata; non è un normale z-buffer colore.

## 11. Memoria e zero page

### 11.1 Zero page

Una build completa può usare in modo intensivo l'intervallo `$02-$A5`. Molti simboli sono alias sovrapposti: la stessa locazione può essere usata da trasformazione, clipping o rasterizzazione in fasi diverse.

Esempi frequenti:

- angoli e seni/coseni: `angx`, `angy`, `angz`, `sinxv`, `cosxv`, ...;
- puntatori: `ptr0lo/hi`, `ptr1lo/hi`, `row0lo/hi`, `row1lo/hi`;
- raster: `xcur`, `ycur`, `errlo/hi`, `leftval`, `rightval`;
- facce: `faceidx`, `loaded_face_vertex_count`, `face_ymin/max`;
- clipping: `clip_*`;
- shading: `shadeidx`, `sh_nx`, `sh_ny`, `sh_nz`.

Non introdurre una nuova variabile zero-page scegliendo un indirizzo apparentemente libero in una singola build. La disponibilità dipende dalla configurazione e gli alias possono essere validi soltanto grazie a lifetime non sovrapposti. Preferire un'allocazione esplicita nel generatore con assert 64tass e test su più profili.

### 11.2 Buffer runtime

Il blocco runtime viene costruito per espressioni contigue a partire da `RUNTIME_BUFFER_BASE`. Può contenere:

- proiezioni `sx`, `sy` e componenti Q2;
- profondità `sz/szhi`;
- coordinate trasformate;
- flag `projdone`;
- limiti per riga `leftb/rightb`;
- dirty ranges per entrambi i buffer;
- depth buckets e liste facce;
- buffer clipping;
- stato sharing, Ground e policy colore.

Le label `RUNTIME_AFTER_*` e `RUNTIME_BUFFER_END` formano una catena di allocazione. Una feature nuova deve inserirsi in questa catena e rispettare `RUNTIME_BUFFER_LIMIT`; non va collocata a un indirizzo assoluto scelto a mano.

### 11.3 Layout `stable` e `high-basic-v2`

`stable` è il layout preferito per build leggere e medie. `high-basic-v2` segmenta codice e dati e può usare RAM sotto la BASIC ROM per build più grandi. Il builder non effettua il passaggio automaticamente.

Quando si modifica il codice:

- assemblare entrambi i layout almeno con una scena rappresentativa;
- leggere gli errori di overlap prodotti dal builder/64tass;
- controllare mappa e margini, non soltanto la dimensione totale del PRG;
- ricordare che un PRG segmentato può essere fisicamente grande a causa dei gap.

## 12. Formati numerici essenziali

Le definizioni normative sono in [WORLD-METRICS.md](WORLD-METRICS.md); questi sono i punti operativi da ricordare:

- WU: world unit;
- TU: turn unit, con 256 TU per giro;
- ST: simulation tick, 50 ST/s;
- molte posizioni/velocità usano fixed point 16.8 o componenti separate;
- scale e trigonometria usano frequentemente Q6;
- i profili XY-Q2 mantengono frazioni di quarto di pixel dove previsto;
- la camera mobile usa accumuli e differenze a 24 bit in alcune routine.

Il builder esegue arrotondamenti, clamp e controlli di dominio prima di emettere i byte. Replicare una conversione direttamente nell'ASM senza usare le stesse regole può creare divergenze fra scena, test host e runtime.

## 13. Dati della scena nell'ASM

Verso la fine del file generato si trovano tabelle come:

- `object_mesh`;
- `object_pos_*`;
- `object_ang_*` e `object_angvel_*`;
- `object_scale`;
- tabelle facce, vertici, materiali e normali;
- `sintab` e tabelle di proiezione/shading;
- eventuali strutture timeline e sharing.

Il builder può eliminare interi campi quando tutti i valori sono costanti o la feature non è usata. Non esiste quindi una ABI binaria stabile garantita fra due build. Se un programma esterno deve modificare dati a runtime, deve essere assemblato insieme alla specifica build o usare label/map prodotti da quella build.

## 14. Tre livelli di modifica

### 14.1 Modificare una scena senza cambiare l'engine

È il percorso preferito per contenuti, geometria, pose, materiali, luci e timeline:

1. copiare un esempio vicino al caso desiderato;
2. cambiare il JSON;
3. compilare con opzioni esplicite;
4. verificare il PRG in VICE;
5. conservare comando e JSON insieme.

### 14.2 Patch temporanea all'ASM generato

Utile per provare un'istruzione o misurare una routine:

1. generare `3Dvibe64.asm`;
2. salvarne hash o copia;
3. applicare la patch;
4. riassemblare manualmente con gli stessi `-a -B`;
5. confrontare comportamento e cicli;
6. riportare la modifica nel builder se deve sopravvivere.

Non eseguire nuovamente `build-3Dvibe64.ps1` prima di trasferire la patch: l'ASM viene rigenerato.

### 14.3 Modifica permanente del generatore

Una modifica permanente richiede normalmente:

1. individuare la label nel file ASM generato;
2. cercare la stessa label in `work/build-3Dvibe64.ps1`;
3. identificare il template, blocco condizionale o placeholder che la emette;
4. cambiare il generatore;
5. rigenerare più configurazioni;
6. confrontare ASM e PRG;
7. eseguire contratti e regressioni;
8. aggiornare documentazione, manifest e hash soltanto nella fase di release.

Il builder mescola due linguaggi. Nei blocchi PowerShell here-string occorre distinguere:

- here-string letterali `@' ... '@`, senza espansione PowerShell;
- here-string espandibili `@" ... "@`, dove `$` e interpolazione hanno significato PowerShell;
- direttive 64tass `.if`, `.else`, `.endif`, `.error` valutate in fase assembler;
- sostituzioni PowerShell eseguite prima di 64tass.

Un simbolo `$` scritto nel contesto sbagliato può essere interpretato dal linguaggio host invece che dall'assembler.

## 15. Come introdurre una feature assembly

Per mantenere una feature coerente con l'architettura dell'SDK, verificare tutti questi livelli:

1. **Superficie pubblica**: campo JSON o parametro CLI, se la feature è destinata agli utenti.
2. **Validazione host**: tipi, intervalli, combinazioni incompatibili ed errori espliciti.
3. **Piano renderer**: flag compile-time che decide quando emettere il codice.
4. **Dati**: tabelle e buffer dimensionati dal contenuto della scena.
5. **Assembly**: routine, call site e contratti di ingresso/uscita.
6. **Memoria**: zero page, runtime chain, code segment e aree VIC-II.
7. **Timing**: PAL/NTSC, tick logico e costo nel frame.
8. **Fallback**: scene/clipping non compatibili con il fast path.
9. **Test**: caso positivo, caso rifiutato e regressione delle build non interessate.
10. **Documentazione e release**: README, guida, manifest e checksum.

Il contratto pubblico del progetto considera una feature realmente promossa solo quando esiste nella superficie del builder, nell'ASM generato e nel runtime collegato.

## 16. Debug con VICE

### 16.1 Preparazione

Generare label in formato VICE e una mappa come mostrato nella sezione 5. Avviare il PRG con x64sc e aprire il monitor integrato. I comandi esatti possono variare leggermente fra versioni di VICE; usare `help` nel monitor per la sintassi locale.

Breakpoint iniziali consigliati:

- `start` per inizializzazione;
- `main_loop` per il controllo principale;
- `render_frame_begin` / `render_frame_end` per delimitare il rendering;
- `render_scene_renderer` per la pipeline;
- `load_face_visible`, `face_visible` o `draw_depth_buckets` per geometria e sorting;
- `project_vertex` o `explorer_transform_project_vertices` per la proiezione;
- `mode5_draw_loaded_polygon_outline` per Mode 5.

### 16.2 Metodo di diagnosi

Per un problema geometrico:

1. fermarsi dopo la trasformazione;
2. controllare coordinate camera-space e profondità geometrica;
3. controllare `projdone`, `sx/sy` e coordinate Q2;
4. verificare near/Ground classification;
5. verificare culling e bucket;
6. solo infine entrare nel rasterizzatore.

Per un problema grafico:

1. identificare `drawbuf`;
2. controllare i registri VIC-II di bank e bitmap;
3. verificare Screen RAM e Color RAM della cella;
4. controllare `fillbyte`, `shadeidx` e materiale attivo;
5. verificare dirty ranges e scambio buffer.

Per un crash o corruzione memoria:

1. consultare il `.map`;
2. mettere watchpoint sugli intervalli confinanti;
3. controllare indici faccia/vertice e conteggi;
4. verificare che X/Y non superino la capacità a un byte;
5. ripetere con una scena minima.

## 17. Profilazione

Per confronti attendibili:

- usare la stessa versione di 64tass;
- fissare `-VideoStandard pal` o `ntsc`;
- disabilitare overlay FPS se non è l'oggetto del test;
- usare la stessa scena, posa e sequenza input;
- confrontare gli stessi punti `render_frame_begin`/`render_frame_end`;
- separare costo della simulazione da quello del renderer;
- registrare hash del builder, comando completo e hash del PRG.

Una modifica che riduce il numero di istruzioni in una routine può peggiorare il frame se sposta codice oltre una pagina, introduce branch lunghi o fa usare più spesso un fallback.

## 18. Test e contratto di regressione

Eseguire dalla radice del pacchetto:

```powershell
python .\scripts\test_camera_angular_repeat.py
python .\scripts\test_camera_move_step.py
python .\scripts\test_mobile_yq2.py
python .\scripts\test_object_depth_domain.py
python .\scripts\test_world_metrics.py
python .\scripts\test_dev7_text_split.py
python .\scripts\test_release_contract.py
```

`test_release_contract.py` è il controllo più ampio: verifica struttura del pacchetto, builder, build di riferimento e, con VICE disponibile, regressioni framebuffer. Può creare PRG in directory temporanee e rimuoverli automaticamente.

Durante lo sviluppo non aggiornare gli hash attesi solo per rendere verde un test. Prima determinare se il cambiamento grafico è intenzionale, riproducibile e documentato. Gli hash di manifest e reference build si aggiornano nella preparazione della nuova release, dopo il congelamento del builder.

## 19. Strategia di confronto consigliata

Per isolare l'effetto di una modifica usare due copie, `baseline` e `candidate`:

```text
baseline/
  work/3Dvibe64.asm
  work/3Dvibe64.prg
  work/build/*.map, *.labels, *.lst

candidate/
  work/3Dvibe64.asm
  work/3Dvibe64.prg
  work/build/*.map, *.labels, *.lst
```

Confrontare nell'ordine:

1. messaggi e contratti stampati dal builder;
2. costanti `..._ACTIVE` nel preambolo ASM;
3. mappa memoria;
4. routine interessata nel listing;
5. dimensione e hash PRG;
6. framebuffer o comportamento in VICE.

Un diff dell'intero ASM può essere rumoroso perché una variazione di scena sposta dati e indirizzi. Limitare il confronto alla stessa scena e alle stesse opzioni.

## 20. Errori comuni

### Modificare il file sbagliato

`work/3Dvibe64.asm` è generato. La modifica permanente appartiene a `work/build-3Dvibe64.ps1`.

### Assumere una ABI stabile

Label, indirizzi e persino presenza delle routine dipendono dalla build. Generare sempre label e mappe insieme al PRG.

### Usare zero page “libera”

Gli alias cambiano per feature e lifetime. Aggiungere un'allocazione controllata, non un indirizzo magico.

### Confondere profondità e indice di proiezione

Il bias della tabella non è distanza geometrica e non deve entrare in culling o sorting.

### Rimuovere un fallback

Una faccia completamente interna e una faccia clippata non hanno lo stesso contratto. Provare near crossing, bordi viewport, camera dentro la mesh e Ground crossing.

### Valutare un solo profilo

Una modifica può funzionare in Mode 4/fixed/stable e rompere Mode 2, walkFull o high-basic-v2. Scegliere una matrice minima di build.

### Aggiornare subito manifest e checksum

Durante lo sviluppo gli hash devono segnalare che il pacchetto è cambiato. Si rigenerano soltanto quando la release è pronta.

## 21. Matrice minima per una modifica al renderer

Una verifica ragionevole comprende almeno:

| Area modificata | Build minime suggerite |
|---|---|
| Proiezione/camera | Mode 4 fixed + Mode 4 walkFull; viewport normal e small |
| Culling/clipping | `default`, `late`, `clip`; una scena near crossing |
| Wire | Mode 1 e Mode 2 con `wire-two-color-multimaterial.json` |
| Fill/materiali | Mode 3 statico, Mode 4 dinamico, Mode 5 outline |
| Ground | Mode 2 plane e Mode 3-5 plane; roll 0/32/64/224 |
| Memoria | `stable` e almeno una build `high-basic-v2` complessa |
| Sharing | Mode 4 o 5 con `shared-instances-timeline-static-light.json` |

La matrice va estesa quando la feature tocca IRQ, overlay, timing o policy VIC-II.

## 22. Possibile modularizzazione futura

È possibile estrarre gradualmente l'assembly in file tradizionali, ma non conviene iniziare copiando l'intero ASM generato. Un percorso sicuro è:

1. scegliere una routine poco dipendente dalla scena;
2. stabilire input, output, registri distrutti e scratch;
3. spostarla in un `.inc` 64tass parametrizzato da simboli;
4. farla includere dal sorgente generato;
5. verificare equivalenza PRG o regressione intenzionale;
6. ripetere per sottosistemi coerenti.

I candidati iniziali migliori sono utility aritmetiche o routine VIC-II con contratti stabili. Trasformazione, clipping e fill dipendono maggiormente dai flag compile-time e richiedono più cautela.

Finché il progetto non adotta ufficialmente moduli esterni, il builder PowerShell resta la sorgente autorevole e gli include locali non fanno parte del contratto pubblico.

## 23. Checklist prima di consegnare una modifica

- Il comando di build è registrato integralmente.
- La scena di riproduzione è nel repository o in una fixture temporanea documentata.
- L'ASM è stato rigenerato dal builder modificato.
- Label, listing e mappa corrispondono al PRG provato.
- Non sono stati aggiunti artefatti permanenti non previsti nella distribuzione.
- Zero page e runtime buffer non si sovrappongono.
- I layout `stable` e `high-basic-v2` rilevanti assemblano correttamente.
- I fallback di clipping sono ancora raggiungibili e validi.
- I test host-side interessati passano.
- Le regressioni VICE interessate passano o la nuova firma è motivata.
- Documentazione italiana e inglese descrivono la stessa API.
- Versione, package manifest e checksum saranno aggiornati insieme nella fase di release.

## 24. Percorso di lettura consigliato

Per un primo approccio professionale all'engine:

1. leggere [QUICKSTART.md](QUICKSTART.md) e [README.it.md](README.it.md);
2. leggere le sezioni numeriche di [WORLD-METRICS.md](WORLD-METRICS.md);
3. compilare `basic-solid-reference.json` in Mode 4/fixed;
4. generare `.labels`, `.map` e `.lst`;
5. seguire `start -> main_loop -> render_frame_*`;
6. seguire un vertice fino a `project_vertex`;
7. seguire una faccia da `load_face_visible` a `draw_depth_buckets` e al fill;
8. ripetere con `mode4-walkfull-reference.json`;
9. ripetere con una scena `clip` e una Mode 5;
10. soltanto dopo iniziare una modifica permanente al builder.

Con questo metodo 3Dvibe64 diventa leggibile come un engine assembly specializzato: il PowerShell è il compilatore di configurazione, il JSON è la descrizione del programma e `3Dvibe64.asm` è l'unità assembly concreta da analizzare per quella build.
