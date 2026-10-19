# Rendering e dati riutilizzabili — 1.15.0

> SDK sorgente stabile1.15.0 pubblicato su GitHub. [Stato e supporto](RELEASE-STATUS.it.md).

La stabile1.15.0 include i moduli qualificati nelle dev precedenti, con runtime invariato. Il pacchetto è pubblicato su GitHub; release e demo congelate precedenti sono preservate. [Opzioni di base](EXACT-RENDER.it.md). Il default resta `-LegacyPlusOptimizations none`. Le nuove opzioni conservano il profilo Mode4 legacy-plus, walkLite, viewport normale 160×100, high-basic-v2, NoFpsOverlay e clipping Q4 near8/poly. Coordinate Q4, coefficienti Q10, pixel e palette non vengono ridotti. Ogni combinazione occupa RAM reale nei 64 KB: una combinazione può essere rifiutata anche se ciascuna opzione entra da sola.

## Scelta delle opzioni

`all` ora comprende `arithmetic,edges,spans,outcodes,convex,integer-edges`. `integer-edges` estende il tracciatore dei bordi interi dei poligoni: il riporto conserva il nono bit della somma, mentre il percorso originale resta disponibile per le tracce condivise con il wire. Il percorso frazionario Q4/Q2 conserva le sue routine complete. Nessuna nuova perdita di precisione.

`wire` e `stream` sono API opzionali, escluse da `all`: devono essere chiamate dall'applicazione. Esempio di selezione: `-LegacyPlusOptimizations outcodes,wire,stream`. Non si può usare `all,wire`: i nomi vanno elencati esplicitamente. La luce congelata resta un'opzione estetica separata, anch'essa esclusa da `all`.

## Linee wire con materiali nativi

`er_wire_line` riceve `ex0,ey0,ex1,ey1` già ritagliati nello schermo, con X=0..159 e Y=0..99. Il chiamante imposta `drawbuf`, `fillbyte`, `material_screen_cur` e `material_color_cur` secondo il normale contratto del renderer. Carry impostato: linea completata. Carry azzerato: coordinate non valide, nessuna scrittura video; usare prima il clipper nativo per linee che attraversano il bordo. Il kernel non esegue clipping 3D.

Mantiene il tracciamento connesso originale, inclusi i raccordi tra righe. Raggruppa le sequenze orizzontali per byte e quelle ripide per colonna, gestendo il riporto dell'errore a 8 bit. Conserva maschere, entrambe le righe fisiche, entrambi i buffer, aggiornamenti dei materiali e regioni sporche. Non presume che tutta la scena abbia una palette fissa. La politica opzionale di proprietà delle celle VIC viene attualmente rifiutata: richiede un adattatore qualificato separato.

L'API usa lo scratch globale nativo, altera A/X/Y/flag e non è rientrante: chiamarla nel passaggio di disegno principale, non da un IRQ concorrente. Non modifica il raster dei poligoni e non viene collegata automaticamente a tutte le linee dell'engine. `install(..., reference=True)` è esclusivamente il generatore del riferimento scalare per le verifiche; il selettore pubblico non lo usa.

## Vertici generati durante il gioco

`stream` richiede `outcodes`, al massimo255vertici residenti e rifiuta le istanze con sorgente condivisa. Non aggiunge slot ai buffer: il chiamante deve possedere un intervallo di slot esistenti durante il proprio passaggio di disegno, senza consumatori concorrenti.

1. Chiamare `er_stream_begin` con X=primo slot e Y=numero di slot, non nullo. Carry impostato indica un intervallo valido entro `VERT_COUNT`; gli slot sono invalidati (`projdone=0`, outcode near) prima della produzione. Un errore disattiva l'intero passaggio.
2. Scrivere coordinate camera signed16 Q4 in `er_stream_x`, `er_stream_y`, `er_stream_z`, quindi chiamare `er_stream_project` con A=slot. Carry impostato indica completamento; `projdone=0` indica comunque la necessità del normale clipping vicino. Fuori dall'intervallo o senza un passaggio attivo, carry azzerato e nessuna scrittura agli array dei vertici.
3. Il risultato è negli array nativi: coordinate Q4 per clipping, coordinate proiettate, profondità, validità e outcode. Preparare facce e ordine painter secondo il contratto esistente; l'API non inventa collegamenti, materiali o ordinamento.
4. Chiamare `er_stream_end_pass`. Il proprietario successivo deve rigenerare i propri slot prima di leggerli. Ripetere begin/produzione/end per ogni nuova vista: nessuna cache valida tra viste viene promessa.

La generazione riusa il corpo del produttore nativo emesso, compresi arrotondamenti, proiezione, classificazione e clipping. Evita che ogni triangolo debba ricopiare un intero record di vertice. La trasformazione mondo-camera resta al chiamante. Scratch nativo condiviso, A/X/Y/flag alterati, chiamate esclusivamente nel passaggio principale. Nessuna prenotazione in zero page aggiunta.

## Chiavi di movimento compatte senza perdita

`work/compact_keyframes.py` accetta una lista JSON di 1..256 campioni interi signed16. Può rappresentare coordinate, angoli o canali di animazione già quantizzati dal progetto: non modifica i campioni e non ne elimina nessuno. Fattorizza soltanto bit bassi già nulli e memorizza gli scarti dal minimo con il numero di bit necessario.

```powershell
python -B work/compact_keyframes.py ../progetto/chiavi.json ../progetto/chiavi.asm --prefix camera_x
```

Il file JSON adiacente riporta campioni, bit, fattore, minimo e byte dei dati. Il decoder ASM `camera_x_read` riceve X=indice; restituisce carry impostato, A=byte basso e Y=byte alto del valore signed16 originale. Indice fuori intervallo: carry azzerato e A=Y=0. Il decoder usa scratch privato e caricamenti automodificanti: codice e dati devono essere in RAM scrivibile, senza chiamate concorrenti o IRQ. Non occupa zero page. Il prefisso deve essere unico per ciascun canale.

È un modulo facoltativo per i dati, non un aumento degli FPS garantito. L'interpolazione resta quella dell'applicazione: può ricostruire gli stessi incrementi ai punti di raccordo. Considerare insieme decoder, scratch, dati e padding: su canali brevi o molto variabili la forma compatta può occupare più RAM della tabella originale. Il generatore non la impone e non sostituisce automaticamente le tabelle del progetto.

## Confini del recupero dalla demo

L'ordine dei componenti della navetta, le facce nascoste rimosse dal suo modello, camera e dinamica specifiche, griglia più rada, FOV, generatore del percorso e linee alternate non sono trasferiti al nucleo. La riduzione di copie e i kernel sono riutilizzabili; questi altri interventi cambiano contenuto, comportamento o grafica e restano nel progetto della demo. Le rotazioni rigide del modello richiedono una qualifica distinta prima di diventare una nuova API di trasformazione degli oggetti.

La [qualifica corrente](QUALIFICATION-1.15.0.it.md) distingue FPS nativi, equivalenza delle immagini e callback CPU. Nessun risultato del benchmark wire viene attribuito alla navetta o al solo modulo stream.
