# 3Dvibe64 1.15.2-dev-agentic22

Sviluppo non pubblicato dalla dev agentic21 consegnata. Qualificazione corrente:
QUALIFICATION-AGENTIC22.json. Note e registri AGENTIC21 restano storici immutabili.
Nessuna release/tag GitHub o promozione stabile.

I profili nativi di Technical Debug hanno mostrato costi elevati nelle scritture
ripetute dei colori delle celle nelle modalità1/2. Una riga fisica di materiale
C64 copre quattro scanline logiche: il raggruppamento deve essere provato dalle
tabelle screen/color emesse. La cache conserva solo un intervallo contiguo di
celle realmente scritto con lo stesso materiale durante un bordo intero wire
(Mode1) oppure un singolo riempimento solido (Mode2).

Gli span contenuti saltano le scritture duplicate. Un'estensione connessa su un
solo lato scrive soltanto le colonne nuove e ripristina start/end prima del
bitmap. Le estensioni su entrambi i lati e gli intervalli separati usano una
scrittura completa e sostituiscono la cache: nessun buco viene marcato o colorato.
Lo stato della riga si azzera a ogni bordo / riempimento. I buffer sono separati;
Mode2 imposta il target di scrittura condiviso una volta per faccia. I percorsi
di materiale a punto e verticali restano invariati, come raster bitmap, dirty
tracking, colori, ordine di disegno, geometria, clipping e precisione.

La selezione richiede corpi consumer noti, i contesti privati dei puntatori già
provati dalla base, tabelle native compatibili, policy colore VIC e varianti
span-cache/small-viewport disabilitate. Forme sconosciute e API sfere opzionali
mantengono la base. Mode2 condivide il codice per rispettare le finestre originali;
il prototipo inline troppo grande è stato scartato. Nessuna nuova variabile RAM
separata, tabella o finestra ampliata. Gli operandi del codice conservano10 byte
di stato in Mode1 e7 in Mode2. Un'estensione parziale Mode2 può aggiungere una
chiamata annidata (2 byte di return stack), sempre bilanciata.

Il target principale è Turbo64x, dove si evitano scritture fisiche dei colori.
Il piccolo costo CPU Mode1 a1x resta visibile nei dati. Default, carichi, musica,
LOD, presentazione e qualità restano invariati. Le modalità3..8 mantengono
agentic21. Il replay CPU verifica la correttezza, non FPS: misure PAL Turbo6510
a1/20/64x, SID originale, warm128 e>=1024refresh (~20,429s). Finestre lunghe a1x
integrano l'indice storico senza sostituirlo. Technical Debug legge solo in pausa
con PRG/simboli della stessa build; maincpu_clk è tempo MACCHINA, non cicli CPU
accelerata. Non moltiplicarlo per64.

Si applicano20 test pubblici e l'audit separato di pacchetto/documenti. I tre test
riservati alla pubblicazione stabile restano conservati e non si applicano alla
lettera a questa dev. Comandi, PRG, catture e diagnosi sono esterni in ../evidence/,
esclusi dallo ZIP sorgente. Hardware e NTSC non sono nuovamente qualificati.
Il registro di qualificazione definisce l'ambito esatto validato.

Verifica completata2026-11-02:54 casi compilabili a1x/20x/64x,162 celle native,
648 catture identiche,27 blocchi ereditati e0 nuovi. Indice fisso
126.591878108; agentic21 124.166609792; stabile
ufficiale1.15.1 117.647645352; riferimento1.15.0=100. Restano i12
stress/36 celle originali, pesi uguali per modalitÃƒÂ /velocitÃƒÂ  e50/50 FPS/render.
Tre ripetizioni ordinarie per lato su6 casi Mode1/2; tre finestre da326,866s per
lato su4 casi pesanti/stress a1x. La quantizzazione delle finestre brevi resta
nell'indice storico senza diventare una stima del throughput sostenuto. SID
originale, warm128 refresh PAL e1024refresh (~20,429s) per finestra ordinaria.
36080 operazioni span emesse e3520 bordi wire completi /1200 riempimenti
conservano bitmap,screen/color,dirty state,start/end e stack. Superati20 test
pubblici e audit sorgente/documenti. La ricompilazione indipendente riutilizza
126 osservazioni della base e18 del prototipo identico, con18 nuove osservazioni
del catalogo e controlli completi di identitÃƒÂ . Nessuna misura sintetica. Le API
sfere4/6 mantengono4 programmi identici e6 osservazioni native storiche (gli esempi
API non hanno traccia musicale). Le estensioni parziali Mode2 possono usare2
byte aggiuntivi di return stack; nessuna nuova RAM separata/tabella o finestra
ampliata. Le modalitÃƒÂ 3..8 mantengono agentic21. Hardware e NTSC non sono nuovamente
qualificati. Sviluppo non pubblicato, non una release stabile.
