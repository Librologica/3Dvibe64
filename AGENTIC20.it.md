# 3Dvibe64 1.15.2-dev-agentic20

Sviluppo non pubblicato dalla dev agentic19 consegnata. Qualificazioni, report e
documenti AGENTIC19 restano storici immutabili. Qualificazione corrente:
QUALIFICATION-AGENTIC20.json. Nessuna release/tag GitHub o promozione stabile.

Technical Debug ha misurato gli span reali ordinati dal painter nelle modalità
6/7 su quattro pose e carichi ordinari pesanti. L'overdraw riguarda soprattutto
porzioni di poligoni; la piccola cache di rettangoli conservativi non elimina
poligoni completi. Il culling di occlusione NON viene promosso. L'indagine ha
invece individuato lavoro sui bordi scartato prima del raster fuso Mode7 X/U/V/Q.

Il percorso noto dei fan tagliati prepara ora lo stesso intervallo Y intero e il
flag di validità, evitando bordi che gr15 azzera e ricostruisce subito dopo.
Per le facce native, un prefisso controllato conserva il setup Y Q2 e verifica
la presenza di righe campionate senza tracciare bordi destinati a essere scartati.
Il dominio veloce richiede XQ2=0..511 e YQ2 nel viewport: un poligono chiuso
connesso interseca ogni riga campionata fra i suoi estremi Y. Il builder originale
accetta un punto di bordo campionato; NS=4*dx resta nel dominio originale a11 bit.
Coordinate esterne, mancata idoneità e forme sconosciute mantengono il builder
originale e i suoi controlli di errore. Copertura, UV, shade, Q, ordine e materiali
restano invariati; il raster fuso calcola ancora tutti i dati effettivamente usati.

La selezione riguarda solo il percorso fuso Mode7. Mode6 mantiene i suoi bordi
geometrici, necessari al successivo passaggio degli attributi. Le API opzionali
delle sfere mantengono il percorso della base. Nessuna nuova variabile RAM,
tabella, allocazione massima di stack o ampliamento delle finestre di memoria.
Nessuna approssimazione o modifica a qualità e carichi.

Le verifiche CPU confrontano bordi e attributi attivi, validità/fault e stack su
poligoni sottili, frazionari, degeneri e fan tagliati. Non misurano FPS. I bench
nativi usano PAL Turbo6510 1/20/64x, SID originale attivo, warm128 e >=1024 refresh
misurati. Comandi e dati sono esterni in ../evidence/. maincpu_clk è tempo
macchina; non moltiplicarlo per64 per dedurre cicli CPU o equivalenza hardware.

Si applicano20 test pubblici renderer/API e l'audit separato di documenti e
metadati. I tre test riservati alla pubblicazione stabile restano conservati.

Verifica completata il 2026-11-02:54 casi compilabili a1x/20x/64x,162 celle
native,648 catture identiche,27 blocchi ereditati e0 nuovi. Indice fisso
performance-v1 123.103329739; agentic19 121.110691904;
stabile ufficiale1.15.1 117.647645352; riferimento1.15.0=100. Restano
invariati i12 stress/36 celle originali, i pesi uguali per modalità/velocità e
la combinazione50/50 FPS/render. A1x le finestre brevi dei casi pesanti contano
solo2–5 viste: i guadagni+25%/+50% sono quantizzati, non stime del throughput
sostenuto. Tre finestre da326,866s per lato confermano+7,69% FPS su pure-7-heavy
e+4,65% su stress-7 a1x. Tre finestre ordinarie per lato confermano rispettivamente
+18,27% e+9,74% a64x. Le repliche sono deterministiche, non campioni casuali
indipendenti. p95/peggiore e comandi grezzi sono nel report/evidence esterno.
Warm-up128 refresh PAL, poi1024 refresh (~20,429s), musica SID originale attiva.
Superati6536 casi di poligoni/9032 triangoli fan e6 fault terminali originali,
20 test pubblici e l'audit di pacchetto/documentazione. La ricompilazione completa
riutilizza144 osservazioni della base e9 del prototipo identico, dopo controllo
di PRG, tutti i simboli numerici, carichi, target e file grezzi;9 osservazioni del
catalogo sono nuove. Le API sfere4/6 mantengono4 programmi identici e6 osservazioni
storiche conservate byte per byte (gli esempi API non hanno una traccia musicale).
Mode6 e le altre modalità mantengono il renderer della base. Dev non pubblicata.
