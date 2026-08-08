# 3Dvibe64 1.1.0

Questo pacchetto pubblico 1.1.0 è un SDK sorgente: contiene builder congelato,
documentazione, scene JSON di riferimento e contratti, ma nessun PRG precompilato o
artefatto diagnostico. Gli esempi si compilano localmente, preferibilmente in una
copia di lavoro eliminabile; sono documentazione eseguibile dell'API, non produzioni
incluse.

Il contratto delle metriche spaziali, angolari e temporali è documentato in [WORLD-METRICS.md](WORLD-METRICS.md).

La struttura del generatore, il sorgente 6510/6502 emesso, il layout di memoria e il
workflow professionale di modifica e debug sono descritti in
[ASSEMBLY-GUIDE.it.md](ASSEMBLY-GUIDE.it.md).

Il flusso pratico assistito da Codex — preparazione dell’ambiente, creazione della
scena, compilazione, test in VICE e conservazione delle versioni approvate — è
documentato in [VIBE-CODING-GUIDE.it.md](VIBE-CODING-GUIDE.it.md).

## Culling stabile e istanze condivise Mode 4/5

L'opzione compile-time `-FaceCullProfile default|stable` è disponibile per le
GraphicsMode 4 e 5. `default` conserva byte per byte il percorso screen-space
validato. `stable` usa il test screen-space fuori dalla banda signed `[-64,+64]` e il
facing camera-space nella banda quasi edge-on, riutilizzando normali e matrice già
disponibili. Le facce esattamente edge-on vengono conservate, senza hysteresis o stato
fra frame; il rendering resta monofacciale. La cache luce `sh_nx`, `sh_ny`, `sh_nz`
viene salvata sullo stack e ripristinata su entrambi gli esiti del culling, con zero
scratch persistente e shading dinamico invariato. Mode 3 resta esclusa.

Con `"meshSourceSharing": true`, una geometria sorgente riutilizzata viene emessa una sola volta. Descriptor mesh e descriptor istanza restano distinti; ciascuna istanza mantiene buffer trasformati e proiettati propri. Le bucket entry identificano istanza e faccia locale, e tutte le istanze visibili entrano in un unico painter order globale. Il percorso shared è disponibile solo in Mode 4/5. L'opt-in in Mode 1, 2 o 3 interrompe la build con `meshSourceSharing is supported only in GraphicsMode 4 and 5`; anche l'opt-in senza una mesh sorgente referenziata da più istanze interrompe la build. Non esiste fallback silenzioso all'espansione. Le scene senza opt-in conservano il percorso diretto byte-identico.

Gli override `materialOverride`, `reflectivityOverride` e `colorOverride` si applicano senza riscrivere le tabelle sorgente. La precedenza è: override locale della faccia, override dell'istanza, materiale sorgente. Nel percorso shared, `faceOverrides` appartiene alla mesh sorgente e le chiavi sono indici faccia locali alla sorgente; `faceOverrides` per istanza viene rifiutato. Per un pigmento esplicito non soggetto a shading si usa una mappa sparsa nella sorgente, per esempio `"faceOverrides": { "0": { "solidColor": 7, "shading": false } }`. Mode 4 esegue il fill solido nel painter normale; Mode 5 applica anche l'outline al poligono finale post-clipping, senza contorni residui sulle facce eliminate.

Una luce reale statica usa `"type": "static"` e `"position": [x,y,z]`: viene emesso un solo campione, senza fase orbitale, tick divisor o tabella duplicata; lo shading continua a reagire alla rotazione degli oggetti. Il valore legacy `"mode": "static"` non seleziona questo percorso compile-time 1.0 e può conservare infrastruttura di fase, tick e tabelle. La timeline dichiarativa richiede `tickRate: 50`; `resetKey: "SPACE"` ripristina stato, pose, visibilità e contatori. PAL e NTSC producono 50 tick logici al secondo. L'easing sinusoidale generico resta fuori da pre-1.0.

## Profili near per Mode 3, 4 e 5

L'API pubblica documenta l'opzione compile-time `-Mode4NearProfile default|late|clip` per le GraphicsMode 3, 4 e 5; il nome resta invariato per compatibilita. `default` conserva il reject sotto 8 WU e il divisore prospettico minimo 8 WU, con comportamento byte-identico alla baseline validata. `late` rigetta la profondita `<= 0`, accetta 1 WU usando un divisore minimo di 2 WU e da 2 WU usa il divisore geometrico. Fra 1 e 2 WU esiste quindi un breve plateau prospettico a divisore 2.

Il profilo `late` non abilita il clipping poligonale near-plane, non modifica il backface culling e non introduce rendering two-sided: le facce che attraversano il piano camera vengono rigettate integralmente. `clip` esegue invece clipping Sutherland-Hodgman contro il piano camera dopo l'eventuale Ground clipping. Conserva la porzione davanti alla camera fino a 0 WU incluso, genera intersezioni proiettabili a 1 WU con divisore minimo 2 e rigetta la faccia soltanto dopo il reale attraversamento. Il culling camera-space usa il poligono originale; raster e outline Mode 5 usano il poligono finale. Il vecchio near-poly resta escluso e il comportamento monofacciale non cambia. `default` e `late` restano byte-identici; il fix `clip` aggiunge zero scratch.

`clip` è disponibile con `fixed`, `walkLite` e `walkFull`. `-ExplorerClipMode` e `-ExplorerNearCrossMode` sono controlli diagnostici legacy: non vanno combinati con il percorso near legacy quando si usa `-Mode4NearProfile late|clip`, che richiede `ExplorerClipMode=none` e rifiuta un crossing mode legacy non predefinito.

## Reference JSON compatta

La struttura esatta della timeline è:

```json
{
  "timeline": {
    "tickRate": 50,
    "resetKey": "SPACE",
    "initialState": "id-stato",
    "states": [{
      "id": "id-stato",
      "duration": 50,
      "next": "id-stato-successivo",
      "loop": false,
      "instances": {
        "id-oggetto": {
          "visible": true,
          "position": [0, 100, 8],
          "rotation": [0, 0, 0],
          "scale": 1,
          "positionVelocity": [0, 0, 0],
          "rotationVelocity": [0, 0, 0],
          "materialOverride": "blue",
          "reflectivityOverride": "mirror",
          "colorOverride": 6
        }
      }
    }]
  }
}
```

`tickRate` deve essere 50. La timeline contiene 1-255 stati, il prodotto stati × oggetti della scena non può superare 255 e `duration` vale 1-65535 tick. Il campo corretto è esattamente `visible`, non `visibility`; quest'ultimo produce un warning del builder e viene ignorato. `position` è in WU secondo la convenzione assi della scena; `rotation` in TU, `positionVelocity` in WU/ST e `rotationVelocity` in TU/ST. Le transizioni sono deterministiche e pre-1.0 non offre easing sinusoidale generico.

Un'istanza seleziona la sorgente tramite `mesh` e può usare `materialOverride`, `reflectivityOverride` e `colorOverride`. Il materiale accetta il nome di famiglia (`gray`, `white`, `red`, `green`, `blue`, `yellow`, `cyan`, `magenta`, `orange`, `brown`) oppure l'indice 0-9. La riflettività accetta `satin`, `gloss`, `reflective`, `mirror` oppure l'indice 0-3. `colorOverride` e `solidColor` sono indici palette VIC-II 0-15. `active`, `global`, `variable` o `default` mantengono materiale/riflettività attivi. La precedenza effettiva è override locale della faccia sorgente, override dell'istanza, materiale della mesh sorgente.

Con sharing attivo, `faceOverrides` deve trovarsi nell'elemento sorgente di `meshes`, mai nell'istanza oggetto. Le chiavi sono indici locali delle facce. `solidColor` con `shading:false` esclude lo shading dinamico per quella faccia. Una mappa per istanza su sorgente riutilizzata fallisce con `per-instance object faceOverrides are not supported by the shared-source path`.

Lo sharing è esplicito e limitato alle Mode 4/5. La geometria sorgente viene emessa una volta, ma ogni istanza richiede buffer runtime trasformati/proiettati distinti. Gli indici a un byte limitano a 255 ciascuno vertici sorgente, facce sorgente, vertici runtime, facce runtime, descriptor mesh e oggetti/istanze di scena. La memoria disponibile impone normalmente limiti pratici inferiori; le scene complesse possono richiedere esplicitamente `-MemoryLayout high-basic-v2`.

Questa release ufficiale limita `H` (Temporal Scanline Mode) alle sole GraphicsMode 4 e 5. Le Mode 1-3 non compilano alcun handler, stato, copia temporale o gate di rasterizzazione esclusivo della funzione.

## Ground `simple` e `plane`

pre-1.0 promuove due profili Ground compile-time. `ground.z` e espresso in WU nella convenzione pubblica `world-z-up`; il piano geometrico e quindi `world Z = ground.z`. La quota della camera cambia il lato geometricamente visibile soltanto quando la camera attraversa il piano. Il profilo `plane` costa piu cicli di `simple` e le scene che non entrano nel layout `stable` devono selezionare esplicitamente `high-basic-v2`.

- Mode 1: linea d'orizzonte roll-aware decorativa, senza occlusione e senza fill.
- Mode 2 `simple`: la stessa linea decorativa e nessun clipping geometrico; tutte le mesh vengono conservate. La linea e disegnata prima delle facce, quindi le face mask hidden-wire la nascondono dietro le superfici.
- Mode 2 `plane`: linea d'orizzonte di sfondo, classificazione rispetto al piano, eliminazione delle facce dal lato opposto alla camera e clipping delle facce attraversanti. Hidden-wire ed edge usano il poligono post-clipping. Non viene mai riempito un semipiano. Il profilo aggiunge `VERT_COUNT` byte di `ground_vside`, usa buffer poligonali fino a 12 vertici e puo richiedere `high-basic-v2`.
- Mode 3-5 `simple`: Ground screen-space tradizionale.
- Mode 3-5 `plane`: semipiano roll-aware riempito, classificazione e clipping geometrici, con camera sopra o sotto il piano. La Mode 3 fixed usa la rilocazione Ground corretta nel layout `high-basic-v2`.

Con la convenzione storica, roll `+32 TU` produce un orizzonte discendente verso destra, `-32 TU` ascendente verso destra e `+64 TU` verticale. Se la retta e interamente fuori viewport non viene disegnata e non resta alcuna linea sui bordi.

## Wire multimateriale a due colori

L'API pubblica include alle GraphicsMode 1 e 2 un profilo compile-time attivato da `materialProfile: multimaterial`. La scena deve usare esattamente due famiglie colore differenti e deve mappare esplicitamente ogni faccia; una terza famiglia o un mapping incompleto interrompono la build senza fallback al materiale globale. La prima famiglia nell'ordine sorgente usa lo slot bitmap `01` e il pattern `$55`, la seconda lo slot `10` e `$AA`. I due pigmenti condividono lo stesso `screenByte`; Color RAM resta fisso e non li distingue. Per la two-color multimaterial wire reference il mapping e rosso VIC-II 2 / bianco VIC-II 1, quindi `screenByte=$21` e Color RAM fisso `$01`.

In Mode 1 gli edge sono unici: `wire_edge_slot` assegna ogni spigolo alla prima faccia adiacente nell'ordine sorgente, regola stabile anche per gli edge condivisi fra materiali differenti. In Mode 2 `wire_face_slot` seleziona il pattern prima dei bordi di ogni faccia; restano invariati fill di mascheramento hidden-wire, clipping, culling, painter order e depth bucket. Nello stesso bucket la catena esistente disegna gli indici faccia in ordine decrescente, quindi la faccia sorgente con indice minore vince deterministicamente. Non sono introdotti buffer runtime per edge o proprietari. La regressione e [examples/wire-two-color-multimaterial.json](examples/wire-two-color-multimaterial.json), con 84 facce inalterate (42 rosse e 42 bianche).

Il limite a due pigmenti non dipende dal fatto che le facce siano triangoli o quadrilateri: la topologia della mesh non determina i colori disponibili. In ogni cella bitmap multicolore VIC-II, `00` usa il colore globale di sfondo `$D021`, `01` il nibble alto della Screen RAM, `10` il nibble basso della Screen RAM e `11` la Color RAM. pre-1.0 assegna i due pigmenti wire a `01` e `10` e mantiene stabile `11`; edge di facce e oggetti differenti possono cosi attraversare la stessa cella senza richiedere una nuova palette per cella. Un terzo pigmento e tecnicamente possibile tramite `11`, ma writer concorrenti richiederebbero arbitraggio esplicito dei conflitti, proprieta per cella, prepass o stato runtime aggiuntivo. I due pigmenti sono quindi una scelta architetturale generale sicura, compatta e deterministica della pre-1.0, non un limite assoluto del VIC-II.

## Profili grafici

**Mode 5: solid dynamic outlined.**

Le modalità grafiche 1 e 2 offrono i percorsi wire e hidden-wire. La modalità 3 usa facce riempite con shading statico. GraphicsMode 4 offre facce riempite e luce dinamica e attiva automaticamente il profilo XY-Q2 validato: non servono flag subpixel sperimentali.

GraphicsMode 5 eredita l’intera pipeline Mode 4 e aggiunge un contorno di un pixel lowres dopo il riempimento di ogni faccia. Il contorno segue il poligono finale dopo il clipping, compresi gli spigoli generati dal near-plane e dai limiti schermo, e usa `world.backgroundColor`. Viene applicato faccia per faccia nel painter order far-to-near esistente, quindi il riempimento più vicino copre naturalmente i contorni della geometria retrostante.

Il costo dell’outline è misurabile. L’audit prestazionale pre-1.0 non ha promosso ottimizzazioni rischiose o con impatto insufficiente: Mode 5 conserva il renderer dinamico, lo shading e i materiali della Mode 4, aggiungendo esclusivamente il contorno post-fill sul poligono post-clipping.

Le build dense nel layout stable restano soggette al limite esistente del video buffer a `$5C00`. Il toro ufficiale Mode 5 entra con overlay FPS attivo; la scena di stress completa del near-plane usa il layout esistente `high-basic-v2`.

Mode 4 usa X LegacyDirect, builder XY-Q2, trace Y integrale e frazionario, divisore 11×8, fast pixel convert, inline bounds, Mode4ShadeStepLimit e somma signed saturata del vettore luce. La viewport `normal` è predefinita e misura 160×100 pixel; `small` resta selezionabile esplicitamente e misura 128×80 pixel.

### Temporal Scanline Mode sperimentale (`H`)

Disponibile esclusivamente in GraphicsMode 4 e 5, cicla una volta per pressione fra `0 -> 1 -> 2 -> 0`: lo stato 0 aggiorna tutte le 100 righe, lo stato 1 ne aggiorna 50 a parità alternata e lo stato 2 ne aggiorna 25 secondo la classe modulo 4. Le righe escluse conservano temporaneamente il contenuto precedente, creando un effetto interlacciato e una moderata scia nel movimento; il ritorno a 0 esegue il ripristino completo già previsto dal renderer.

Non è una modalità prestazionale o una semplice bassa risoluzione. Trasformazione, proiezione, clipping, culling, depth ordering, shading e preparazione delle facce continuano integralmente; l'effetto può aumentare il costo del frame. Materiali, fill, painter order e outline Mode 5 restano invariati.

## Profili camera

La camera `fixed` è il percorso specializzato leggero. Consuma meno codice, memoria e cicli, è più frequentemente compatibile con `MemoryLayout stable` e usa la proiezione tabellare Q6 più quantizzata. Offre qualità geometrica inferiore alle camere walk nelle scene complesse o molto vicine. Con `Mode4NearProfile=default|late` una faccia può essere rigettata integralmente dal relativo gate near/camera; selezionando esplicitamente `-Mode4NearProfile clip` si abilita il clipping poligonale contro il piano camera anche per `fixed`, oltre che per le camere walk.

`walkLite` è una camera mobile con yaw e pitch. Usa la trasformazione Mobile Y-Q2 e una proiezione geometricamente più precisa. Per il clipping poligonale contro il piano camera si seleziona `-Mode4NearProfile clip`.

`walkFull` aggiunge il roll alla stessa pipeline precisa di `walkLite`. Richiede più codice e dati runtime e, con mesh complesse come complex reference mesh, può richiedere `MemoryLayout high-basic-v2`.

Le camere walk partono nella posa definita dalla scena e restano ferme finché l’utente non invia un comando camera. Rotazione degli oggetti e animazione della luce continuano anche quando la camera è ferma. I tre profili condividono culling, depth bucket a 16 bit, painter order far-to-near, builder facce XY-Q2, fill, pattern e shading.

I default pre-1.0 development di `walkLite` e `walkFull` applicano un solo sotto-step lineare da `127/256 = 0,49609375 WU/ST`, pari nominalmente a `24,8046875 WU/s` o circa `0,44294` lati del cubo standard al secondo. Il movimento diagonale resta additivo e non normalizzato. Yaw e pitch rispondono subito con 1 TU, poi ripetono ogni 4 ST (`0,25 TU/ST`, `17,578125°/s` continui); il roll risponde subito e ripete ogni 2 ST (`0,5 TU/ST`, `35,15625°/s`). Il rilascio e il reset camera azzerano separatamente le tre fasi. La camera `fixed` e le animazioni degli oggetti restano invariate.

La profondità pre-1.0 è geometrica: `camera_depth_geometric` resta la distanza reale, `projection_table_index = max(1, camera_depth_geometric + 190)` è soltanto l’indirizzo fisico e `projection_divisor = max(8, camera_depth_geometric)` determina la scala. Le scene distribuite sono migrate lungo il loro asse forward world Y; non esiste un fallback runtime per il vecchio bias geometrico.

La geometria clippata conserva il fallback legacy compatibile. I profili `normal` e `small` mantengono nere l’area esterna e la cornice VIC-II.

## Layout di memoria

`MemoryLayout stable` è il layout preferenziale e compatto, adatto alle configurazioni leggere o medie. Il builder interrompe la compilazione se codice o runtime invadono bitmap, screen buffer o altre aree video e suggerisce esplicitamente `-MemoryLayout high-basic-v2`; il passaggio non avviene mai automaticamente.

`MemoryLayout high-basic-v2` è il layout segmentato per build pesanti. Usa anche la RAM sotto la BASIC ROM ed è indicato per complex reference mesh, camera `walkFull` e pipeline solide complesse. Deve essere selezionato esplicitamente e può produrre PRG fisicamente più grandi a causa dei gap tra segmenti.

## Materiali

Satin e gloss conservano il percorso storico. Nelle scene composte interamente da facce reflective o mirror, il selettore raw alimenta direttamente Mode4ShadeStepLimit. Le scene con profili misti conservano il comportamento storico. Reflective può raggiungere il massimo previsto dalla propria tabella; mirror raggiunge il bianco per ogni famiglia la cui tabella definisce il bianco come massimo.

Il VIC-II accetta legalmente tutti gli indici colore 0-15, incluso il nero, e anche valori duplicati fra Dark, High e Highlight. 3Dvibe64 esclude deliberatamente il nero dalle rampe delle facce come soglia minima di illuminazione ambientale del modello di illuminazione dell'engine: è una policy dell'engine, non un limite hardware. Le rampe D/H/L arrivano inalterate al runtime; il packing necessario è `screenByte = (Dark << 4) | High` e `colorRam = Highlight`. `VicColorPolicy` gestisce eventuali conflitti di palette nella stessa cella bitmap e normalmente non filtra né rimappa le rampe materiali. Orange satin resta `9,8,10` con `$98/$0A`; Brown satin resta `2,9,8` con `$29/$08`.

## Controlli camera e runtime

- `W` / `S`: avanti / indietro
- `A` / `D`: movimento laterale sinistra / destra
- `Q` / `E`: movimento verticale giù / su
- cursori: yaw e pitch
- `N` / `M`: roll
- `R`: con `-ControlRotation` sospende o riprende la rotazione della mesh; nelle build di riflettività interattiva va riservato a `-ControlReflectivity`
- `L`: controllo luce, dove supportato dalla scena
- `F`: overlay FPS
- `H`: Temporal Scanline Mode, soltanto in GraphicsMode 4 e 5

Se `-ControlRotation` e `-ControlReflectivity` vengono forzati insieme, entrambi gli handler leggono `R`: quello della rotazione viene eseguito per primo e quello della riflettività subito dopo. Non è una configurazione a proprietario unico; per assegnare `R` alla riflettività si deve omettere `-ControlRotation`.

## Principali opzioni pubbliche da riga di comando

| Opzione | Valori | Default / effetto |
|---|---|---|
| `-GraphicsMode` | `1`-`5` | `4` |
| `-CameraMode` | `fixed`, `walkLite`, `walkFull` | modo della camera nella scena, altrimenti `fixed`; il valore CLI esplicito prevale |
| `-VideoStandard` | `auto`, `pal`, `ntsc` | `auto`; PAL/NTSC forzato mantiene la simulazione logica a 50 ST/s |
| ViewportProfile / `-CameraViewport` | `normal`, `small` | `normal`; `contract.viewportProfile` vale quando la CLI è omessa |
| `-MemoryLayout` | `stable`, `high-basic-v2` | `stable`; non cambia mai automaticamente |
| `-Mode4NearProfile` | `default`, `late`, `clip` | `default`; valido per Mode 3-5 |
| `-FaceCullProfile` | `default`, `stable` | `default`; `stable` solo per Mode 4/5 |
| `-ControlRotation` | switch | off; assegna `R` a pausa/ripresa della rotazione |
| `-ControlLight` | switch | off; abilita il tasto luce supportato dalla scena |
| `-ControlReflectivity` | switch | off; assegna `R` al ciclo riflettività quando `ControlRotation` non è attivo |
| `-FpsOverlay` | switch | il sistema overlay è incluso per default e commutato con `F`; selettore esplicito di compatibilità |
| `-FpsOverlayOnStart` | switch | off; mostra dall'avvio l'overlay incluso |
| `-NoFpsOverlay` | switch | off; rimuove overlay e tasto FPS, in conflitto con i due switch overlay |
| `-NoCameraRuntimeControls` | switch | off; compila una camera mobile senza input camera runtime |
| `-StaticPose` | switch | off; impedisce gli aggiornamenti automatici degli angoli mesh |
| `-LightOrbit` | `flat`, `tumble3d` | `flat` per il percorso orbit legacy |
| `-LightPhaseCount` | `8`, `16`, `32` | `32` |
| `-LightTickDiv` | intero | `2`; divisore aggiornamento orbit legacy |
| `-LightStaticPhase` | `-1` o indice fase | `-1`; congela il campione luce legacy selezionato se non negativo |

`-ExplorerClipMode` e `-ExplorerNearCrossMode` sono opzioni diagnostiche legacy, non l'API pubblica 1.0 dei profili near. Gli switch `Experimental*`, `Diagnostic*`, `*Trace` e i probe interni non fanno parte dell'API pubblica stabile.

## Licenze

Copyright © 2026 **librologica.digital**, autore e licenziante di 3Dvibe64.

Il software, il builder, gli script, gli esempi JSON, i materiali di validazione
e il codice engine generato possono essere usati esclusivamente per scopi non
commerciali secondo la [PolyForm Noncommercial License 1.0.0](LICENSE). Qualsiasi
uso commerciale richiede una licenza separata rilasciata per iscritto da
librologica.digital.

Tutta la documentazione Markdown, i manuali e le guide per programmatori possono
essere usati esclusivamente per scopi non commerciali secondo la
[Creative Commons Attribuzione–NonCommerciale 4.0 Internazionale](LICENSE-DOCUMENTATION.md).
È obbligatoria l'attribuzione a `librologica.digital`. Queste restrizioni rendono
il progetto *source-available*, non open source approvato OSI. In un repository
GitHub pubblico restano comunque consentite la visualizzazione e la creazione di
fork attraverso le funzioni offerte da GitHub.

64tass e VICE sono dipendenze esterne, non incluse nella distribuzione, e restano
soggetti alle licenze dei rispettivi autori.

## Requisiti di compilazione

Servono Windows PowerShell e 64tass 1.60 o successivo. Inserire `64tass.exe` nel `PATH`, impostare `TASS64_EXE`/`TASS64_PATH` oppure collocarlo sotto `work/tools/64tass`. I comandi sono riportati in [examples/README.md](examples/README.md). Il contratto completo richiede anche VICE x64sc: inserirlo nel `PATH` oppure impostare `VICE_X64SC`/`VICE_EXE` prima di eseguire `python scripts/test_release_contract.py`.
