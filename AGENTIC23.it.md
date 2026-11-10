# 3Dvibe64 1.15.2-dev-agentic23

Sviluppo non pubblicato dalla dev agentic22 consegnata. Registro corrente:
[QUALIFICATION-AGENTIC23.json](QUALIFICATION-AGENTIC23.json). Registri e note
AGENTIC precedenti restano storici immutabili. Nessuna promozione stabile o
pubblicazione GitHub.

I profili Technical Debug hanno individuato costi elevati nel tracciamento dei
contorni interi e nell'outline di sfondo Mode5. Un percorso a quoziente/resto
calcola i medesimi limiti inclusivi sinistro/destro dei percorsi interi noti
Mode2/3/4/5. Normalizza l'ordine degli estremi, conserva le righe diagonali con
un solo punto e unisce ai bounds soltanto i medesimi pixel. Il percorso nativo
XYQ2, shading, clipping, geometria e ordine di disegno mantengono la base.
Mode2 conserva il raster wire connesso: il fallthrough a16 bit irraggiungibile
viene rimosso solo con il classificatore completo delle pendenze wire e il
viewport nativo limitato. Mode3/4 sostituiscono il vecchio kernel intero.

Mode5 raggruppa l'outline di sfondo in span di riga esatti. I byte bitmap
interni vengono azzerati insieme; gli estremi parziali usano le maschere
start/end originali. Scrive entrambe le scanline fisiche con adiacenza provata
dalle tabelle. Resta selezionato il registro VIC-II di sfondo con il colore
configurato. L'outline non scrive screen, color RAM, dirty state o materiali,
come nella base. Restano identici ordine degli estremi, copertura orizzontale,
verticale, diagonale e connessioni dei bordi poco inclinati. Qualità e LOD invariati.

La selezione automatica richiede corpi sorgente noti esatti, tabelle native
160x100, maschere invariate e righe bitmap adiacenti, niente lazy bounds né API
cerchi. Corpi sconosciuti, label private referenziate esternamente, viewport
diversi e classificatori wire non supportati mantengono la base. Nessuna nuova
variabile RAM separata, tabella o finestra ampliata. Riutilizza scratch esistenti;
la chiamata annidata del writer parziale Mode5 può aggiungere2 byte al return
stack. API, precisione, texture, default, carichi e musica originale invariati.
Le modalità1/6/7/8 conservano il rendering agentic22.

Misure reali VICE Turbo6510 PAL a1x/20x/64x, SID originale, warm128 refresh e
almeno1024 refresh (~20,429s). Contare solo viste nuove complete; conservare
comandi, hash PRG/label, FPS, render medio, intervalli p95/peggiore e catture.
Il paniere e i pesi performance-v1 e il riferimento Stable1.15.0=100 restano
invariati. Finestre lunghe uguali a1x integrano i conteggi brevi quantizzati.
Il replay CPU verifica la correttezza, non gli FPS. Technical Debug usa simboli
della stessa build e letture in pausa; maincpu_clk è tempo macchina, non cicli
interni CPU accelerata. Hardware e NTSC non sono nuovamente qualificati.

Verifica completata: 54 casi compilabili, 162 celle native, 648 catture identiche; 27 blocchi ereditati e0 nuovi. Indice fisso 129.982556846; agentic22 126.591878108; stabile ufficiale1.15.1 117.647645352. Tre ripetizioni per lato su8 casi Mode2/3/4/5; tre finestre da326,866s per lato su4 casi pesanti/stress Mode2/5 a1x. Superati20 test pubblici e audit dei sorgenti/documenti. Quattro programmi API cerchi conservano PRG/label identici e6 osservazioni native precedenti (esempi senza asset musicale, fuori indice). Resta una dev non pubblicata.
