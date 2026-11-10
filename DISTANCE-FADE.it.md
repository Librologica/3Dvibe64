# Dissolvenza a distanza — 1.20.0

> SDK sorgente stabile 1.20.0. Pubblicato su GitHub. [Qualifica](QUALIFICATION-1.20.0.it.md).

Visibilità opzionale a retino per GraphicsMode 1–8. Disattivata per impostazione predefinita. Nessuna demo o scena distribuita.

## Configurazione pubblica

| Opzione PowerShell | Campo JSON della scena | Default | Contratto |
|---|---|---|---|
| `-DistanceFade off/dither` | `distanceFade.mode` | `off` | Attivazione esplicita; indipendente dal LOD texture |
| `-DistanceFadeStart N` | `distanceFade.start` | `64` | Distanza intera alla quale termina la copertura piena |
| `-DistanceFadeEnd N` | `distanceFade.end` | `96` | Distanza intera di copertura zero ed esclusione |

Deve valere `0 <= start < end <= 32767`. Booleani, distanze JSON frazionarie, campi sconosciuti, oggetti null e modalità non supportate vengono rifiutati. I campi omessi usano i default. Le distanze senza modalità attiva vengono rifiutate. Ogni valore CLI esplicito prevale sul corrispondente valore della scena. `-DistanceFade off` esplicito disattiva la dissolvenza della scena e ne ignora le soglie memorizzate; non aggiungere soglie CLI insieme a `off`.

Il frammento seguente va al **livello principale**, accanto a `objects` nelle scene poligonali oppure accanto a `scene` e `navigation` nei documenti Mode8:

```json
"distanceFade": {"mode": "dither", "start": 64, "end": 96}
```

Con una scena poligonale esterna:

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -SceneFile ../inputs/world.json -GraphicsMode 4 -Precision q8 -VideoStandard pal -OutputDirectory ../outputs/world-fade -DistanceFade dither -DistanceFadeStart 64 -DistanceFadeEnd 96
```

Per legacy e legacy-plus ordinari copiare prima l'intera SDK in una directory di lavoro esterna, come descritto in [Input esterni](EXTERNAL-INPUTS.it.md). Questi esportatori continuano a scrivere in `work/` della copia; `OutputDirectory` resta un'opzione Q8/Normalized16/Mode8. Restano tutti i vincoli esistenti su precisione, camera, mesh e RAM.

I builder Python diretti Q8 e Normalized16 accettano `--distance-fade off/dither`, `--fade-start N`, `--fade-end N`. Il builder Mode8 accetta le stesse tre opzioni, con identica precedenza CLI/JSON. La validazione Mode8 senza compilazione risolve e verifica la dissolvenza prima di creare output. Sono **impostazioni di build**, non controlli da tastiera o un setter delle soglie a runtime. Cambiare soltanto le costanti nell'ASM generato non rigenera le tabelle delle soglie.

## Modalità 1–7: distanza e copertura dell'oggetto

La distanza è la lunghezza euclidea dell'**origine dell'oggetto** rispetto alla camera, in unità mondo dell'engine. Ogni differenza assoluta delle coordinate viene troncata a WU interi prima del quadrato; la traslazione Q8 frazionaria viene sottratta prima di questa quantizzazione. Gli operandi vengono estesi col segno prima della sottrazione: estremi con segni opposti non causano ritorni modulari. Rotazione e scala non spostano l'origine. La dissolvenza appartiene all'intero oggetto, comprese facce, spigoli wire e contorni. Suddividere geometrie molto grandi in oggetti più piccoli quando il limite basato sull'origine non è adatto. Non è una distanza dal punto più vicino del singolo poligono né una prova di visibilità/occlusione.

Esistono 17 stati di copertura, da16 a0. Le soglie al quadrato generate sul computer evitano una radice quadrata a runtime. Per il livello k, il confine intero è `ceil(end - (end-start)*k/16)`; la classificazione sceglie il primo confine decrescente non maggiore della distanza quantizzata. La copertura resta piena fino alla soglia iniziale e diventa zero dalla soglia finale. Intervalli stretti possono produrre confini ripetuti e meno stati effettivamente osservabili.

Un oggetto a copertura zero viene escluso prima di trasformazione dei vertici, proiezione e raccolta delle facce nei normali cicli della scena. Il classificatore continua ad avere un costo CPU. Le facce ordinate recuperano la copertura del proprietario; i percorsi con facce preparate e le passate wire usano la stessa proprietà. Geometria, winding, normali, clipping near/screen, illuminazione, texture e precisione restano quelli del renderer.

La copertura intermedia usa un Bayer4×4 deterministico, ancorato allo schermo. Le scritture bitmap fondono i bit selezionati con il valore precedente, mantenendo insieme entrambi i bit del pixel multicolor. Le linee wire diventano tratteggiate: può diminuire la leggibilità, quindi l'attivazione è una scelta della scena. Non alterna fotogrammi interi e non richiede lampeggio temporale. Lo stato IRQ è separato da scratch/SMC del renderer in primo piano. Gli helper di scrittura preservano A/X/Y e flag, anche per destinazioni indirette esterne alla bitmap.

UI, intestazioni, cielo e sfondo Ground analitico non sono oggetti finiti della scena e non vengono dissolti da questa politica. Per un terreno limitato dalla distanza usare mesh finite. Restano i vincoli VIC-II di palette per cella: il retino non crea alpha blending libero tra palette incompatibili. L'effetto conserva i bit bitmap; non introduce un nuovo compositore di colori o un buffer di occlusione.

Gli helper legacy/legacy-plus vengono riallocati insieme dopo la strumentazione. Mode1 rialloca anche i kernel wire/clip invariati, conservando gli ingressi per caduta intenzionali. Restano ricerca limitata negli spazi liberi e controlli per blocco. I simboli `df_` e `df8_` sono privati: il codice applicativo non deve modificarne lo scratch o chiamarne gli helper. Gli argomenti keyword Python sono `distance_fade`, `fade_start`, `fade_end` per Q8/Normalized16; per Mode8 usare il contratto pubblico CLI/scena.


## Modalità 8: backend 2.5D separato

Mode8 usa celle della mappa e profili di piani, non oggetti poligonali. Le distanze sono **celle della mappa** (soglie configurate intere, spostamento frazionario Q8 della camera conservato), misurate conservativamente lungo la normale di un piano visibile. Unità e metrica numeriche differiscono quindi dalle modalità1–7: scegliere soglie adatte alla mappa. Per esempio:

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile ../inputs/map.json -Mode8Run auto -OutputDirectory ../outputs/map-fade -DistanceFade dither -DistanceFadeStart 2 -DistanceFadeEnd 8
```

Le build auto e interactive mantengono i contratti esistenti di mappa, collisioni, navigazione e geometria. Nel backend multilivello la selezione dei profili controlla la copertura delle superfici; un profilo completamente distante restituisce una proiezione vuota condivisa senza generare il profilo normale. Le fasce intermedie usano i campioni top/bottom esistenti e fondono la maschera Bayer durante il disegno. Le fasce completamente opache conservano il renderer veloce originale.

Mono-opaque e mono-portals usano il piano wall/overhead coarse più vicino nel gruppo di colonne corrente, conservando le superfici vicine. Un gruppo con geometria vicina può quindi mantenere visibili più a lungo anche gli strati lontani. Le fasce raffinate usano la stessa copertura del gruppo. Un ripristino dello sfondo elimina i pixel a retino residui; restano lo sfondo nero/marrone e la UI esistenti. Non è nebbia radiale per pixel, un nuovo ray tracer o un limite al percorso DDA. La ricerca della geometria può continuare oltre la distanza di dissolvenza. Restano espliciti la politica conservativa per gruppi e i limiti preesistenti del campionamento adattivo.

L'opzione usa soltanto la finestra payload riservata inutilizzata di2449 byte. Restano attive tutte le guardie di payload, codice basso, cache, font, bitmap e schermi: nessun confine di memoria esistente viene allargato. Omissione/off emettono i template originali byte per byte.

## LOD delle texture Mode7 indipendente

`TextureLOD`, `TextureLODNear` e `TextureLODFar` mantengono nomi, default e vincoli esistenti: Mode7 Q8 perspective, `off/gradual`, default off, `1 < near < far < 256`, intervallo16 WU. Non cambiano la metrica basata sulla profondità dei vertici originali né il comportamento di materiali/pigmenti. La dissolvenza usa soglie proprie basate sulla distanza dell'origine.

Le quattro combinazioni sono: entrambi spenti; solo LOD texture; solo dissolvenza; entrambi attivi. Per entrambi:

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -SceneFile ../inputs/textured.json -GraphicsMode 7 -Precision q8 -TexturePrecision perspective -VideoStandard pal -OutputDirectory ../outputs/textured-fade-lod -DistanceFade dither -DistanceFadeStart 64 -DistanceFadeEnd 112 -TextureLOD gradual -TextureLODNear 28 -TextureLODFar 44
```

La dissolvenza non riscrive soglie LOD, `ld_weight`, pigmenti modal/accent o politica del campionatore/illuminazione. Il LOD cambia il dettaglio delle texture sulle superfici visibili; la dissolvenza cambia copertura e infine esclude l'oggetto. Restano i vincoli affine, standard/fast e di illuminazione dei rispettivi esportatori. Il codice/dati aggiuntivi possono esaurire la RAM, soprattutto combinando perspective/Gouraud. L'allocatore limitato restituisce un errore esplicito di memoria; non esistono fallback a precisione inferiore, guardie indebolite o opzioni disattivate silenziosamente. Una piccola scena compilata non qualifica budget geometrici arbitrari.

## Quando conviene usare Distance Fade

Scegliere Distance Fade in base al lavoro che la geometria lontana può evitare e alla visibilità che la scena può permettersi di perdere. Il principale beneficio prestazionale nelle modalità 1–7 deriva dall'**esclusione completa degli oggetti oltre `end`**. Un oggetto nella fascia di transizione richiede ancora elaborazione geometrica e, dove previsti, illuminazione e campionamento texture; la maschera finale aggiunge lavoro. Anche mantenere tutti gli oggetti visibili e completamente opachi conserva il costo aggiuntivo dell'opzione attiva. Usare la transizione per il suo effetto visivo quando il budget del fotogramma lo consente, senza assumere che meno puntini visibili rendano il disegno meno costoso.

### Struttura della scena e distanze

La funzione è una buona candidata per un mondo esteso composto da molti oggetti separati, spazialmente compatti e distribuiti in profondità: il primo piano resta opaco, una fascia limitata attraversa la transizione e una quantità significativa di geometria lontana viene omessa completamente. Eliminare un oggetto costoso può risparmiare molto lavoro anche quando occupa pochi pixel, perché vertici e facce hanno comunque un costo. Anche oggetti che restano grandi sullo schermo a distanza possono offrire un risparmio importante di riempimento e campionamento quando vengono esclusi interamente.

La funzione è meno conveniente quando quasi tutto resta entro `start`, quando gran parte della geometria visibile rimane nella fascia parziale o quando ampie superfici retinate coprono il viewport. Una transizione molto larga può lasciare molti oggetti a pagare la mascheratura senza arrivare all'esclusione. Una fascia più stretta può ridurre questo costo, ma deve restare visivamente accettabile con livelli discreti di copertura e camera in movimento. Non esistono una distanza, una larghezza della fascia o una percentuale minima di oggetti esclusi che rendano l'opzione conveniente per ogni scena.

Le origini degli oggetti devono essere rappresentative della loro geometria visibile. Un unico grande terreno, edificio o tratto di strada con origine vicina alla camera può mantenere pienamente visibili anche le facce lontane. Un'origine oltre `end` può invece far sparire parti della stessa mesh che si estendono vicino alla camera. Oggetti o blocchi spazialmente compatti danno un controllo più utile; anche il loro costo aggiuntivo di gestione e RAM deve rientrare nel budget della scena. Ground analitico, cielo e UI restano fuori dalla politica di dissolvenza degli oggetti: dissolvere mesh finite non elimina il loro lavoro. L'esclusione dal rendering non disattiva automaticamente la logica applicativa o le collisioni.

### Differenze fra modalità grafiche

| Modalità | Tipi di scena che possono beneficiare | Tipi di scena in cui il fade può costare di più |
|---|---|---|
| 1 — wireframe | Molti oggetti lontani separati, dei quali evitare completamente trasformazione, clipping e disegno degli spigoli. | Un oggetto wire dettagliato che resta parzialmente visibile; molte linee sottili acquistano il costo del retino e possono diventare meno leggibili. |
| 2 — hidden-wire | Oggetti lontani eliminabili insieme alla loro geometria, alle maschere delle facce e al lavoro sugli spigoli. | Geometria wire densa e sovrapposta mantenuta nella fascia di transizione: il lavoro hidden-wire resta e le scritture mascherate aggiungono costo. |
| 3 — solido / shading statico | Gruppi di oggetti indipendenti distribuiti in profondità, con abbastanza esclusioni complete da evitare geometria e riempimento. | Grandi facce parzialmente dissolte; la mascheratura può pesare molto rispetto a un riempimento solido semplice. |
| 4 — flat dinamico | Mesh lontane separate delle quali evitare il lavoro specifico di geometria, illuminazione e riempimento. | Una scena prevalentemente vicina o grandi superfici che restano parziali; flat shading e geometria vengono ancora elaborati prima della maschera. |
| 5 — flat dinamico con contorni | Oggetti eliminabili insieme alle passate di riempimento e contorno. | Numerosi contorni visibili nella transizione: il loro disegno resta un costo e il tratteggio può ridurne la leggibilità. |
| 6 — Gouraud | Oggetti lontani eliminabili prima di richiederne geometria, illuminazione e interpolazione. | Ampie superfici parziali che richiedono ancora il Gouraud e la maschera di copertura. Il fade non sostituisce il calcolo dello shading. |
| 7 — texture | Oggetti texturizzati lontani che richiederebbero molta geometria o campionamento visibile e possono essere esclusi completamente. | Superfici visibili che richiedono ancora campionamento ed eventuale illuminazione prima della maschera; oggetti lontani già poco costosi lasciano meno lavoro da risparmiare. I profili affine/perspective e di illuminazione hanno costi diversi. |
| 8 — mappa 2.5D | Mappe nelle quali le soglie in celle escludono abbastanza profili lontani da evitarne proiezione e disegno. | Mappe dominate da piani vicini, fasce parziali o lavoro di ricerca geometrica e sfondo che la dissolvenza non elimina. |

Per Mode7, mantenere LOD texture e fade come decisioni separate. Il LOD controlla il dettaglio delle superfici che restano visibili; il fade controlla copertura ed eventuale esclusione. Una politica di dettaglio ridotto già attiva può diminuire il lavoro che il fade potrebbe risparmiare. Scegliere entrambi nei profili supportati e valutare la combinazione, senza sommarne i guadagni né considerare intercambiabili le diverse metriche di distanza.

Per Mode8, una parete lunga vicina alla camera può restare vicina secondo la distanza dalla normale del piano anche nei tratti visivamente lontani. Ambienti stretti con pareti laterali vicine possono quindi conservare gran parte del lavoro nonostante una distanza di dissolvenza breve. Nei backend mono, un piano vicino può inoltre mantenere altri strati nel proprio gruppo conservativo di colonne. Il multilivello può evitare le proiezioni dei profili completamente lontani, ma questa decisione non elimina attraversamento DDA e lavoro sullo sfondo. Usare soglie in celle adatte ai piani e alla disposizione effettivi, invece di copiare soglie in unità mondo da una scena poligonale. Controllare che confini importanti e riferimenti per la navigazione restino visibili.

### Velocità CPU e budget del fotogramma

| Target CPU | Come valutare la scelta |
|---|---|
| 1× | La mascheratura aggiuntiva pesa sul budget disponibile. Le esclusioni complete devono evitare abbastanza lavoro; un grande guadagno relativo può comunque lasciare troppo lenta una scena eccessivamente complessa. |
| 20× | La transizione può ancora far superare una scadenza di presentazione. Considerare sia il costo del render nativo sia gli FPS di nuove viste complete, includendo il resto del lavoro applicativo. |
| 64× | Il limite di presentazione video può mantenere invariati gli FPS mentre il fade consuma o libera margine CPU. FPS invariati non dimostrano che l'effetto sia gratuito o inutile. |

Una CPU più veloce non rende di per sé conveniente il fade. Confrontare la scena prevista con fade OFF e con le soglie scelte, mantenendo geometria, illuminazione, politica texture, percorso e altro lavoro attivo. Seguire sia il tempo di render nativo sia gli FPS di nuove viste complete durante il movimento e nelle viste ferme. Scegliere `end` in modo che la geometria omessa sia effettivamente sacrificabile per visibilità e gioco; far sparire l'intera scena non è un obiettivo prestazionale utile quando quella geometria deve restare visibile.

## Costo, verifiche e consegna

La visibilità parziale richiede ancora geometria e spesso campionamento texture. La mascheratura aggiunge lavoro: meno puntini visibili **non** significano proporzionalmente meno calcoli o più FPS. L'esclusione completa degli oggetti può risparmiare molto lavoro. Anche le fasce parziali Mode8 e il ripristino dello sfondo mono possono costare più del renderer originale. Misurare scena, target e distribuzione delle distanze effettivi; l'opzione resta spenta per default.

Verifiche e misure native correnti sono in [Note di release](RELEASE-NOTES-1.20.0.it.md) e nella [qualifica](QUALIFICATION-1.20.0.json). Gli FPS nativi contano viste complete presentate nel tempo PAL Turbo6510 dopo warm-up, mai replay CPU o tempo host/warp. Il test compilato di aritmetica/scritture verifica solo la correttezza: `python -B scripts/test_distance_fade.py` (dipendenze di sviluppo:64tass e py65). Le distribuzioni sorgenti non contengono scene di prova, demo, musica, PRG o catture; tutte le evidenze native restano esterne.

## Dispatch delle scritture e delle maschere

Dispatch del writer e selezione maschera passano agli aggiornamenti del livello privato, con variante Mode7 compatta per conservare RAM. Mode8 pulisce il viewport identico per porzioni contigue di righe carattere e limita i campioni parziali all'unione conservativa top/bottom. Nessun cambiamento di metrica, campionamento, pixel visibile o configurazione pubblica. Le [note correnti](QUALIFICATION-1.20.0.it.md) descrivono prove, misure native e limiti.

## Riutilizzo del lavoro per vista

Metodo/API/output conservati. Riutilizzo per vista dei livelli dei piani nel multi, wrapper più leggero e riempimenti scalari in quattro fasi eliminano lavoro ripetuto; esclusione per intervallo e quadrati poligonali restano esatti. Gli intervalli wire non sovrascrivono più i proprietari poligonali. Payload multi920/2449, mono766/2449, guardie originali. Vedere [implementazione e perimetro delle misure](QUALIFICATION-1.20.0.it.md).
