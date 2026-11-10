# 3Dvibe64 1.15.2-dev-agentic21

Sviluppo non pubblicato dalla dev agentic20 consegnata. Qualificazione corrente:
QUALIFICATION-AGENTIC21.json. Note AGENTIC20, registri e qualificazioni precedenti
restano storici immutabili. Nessuna release/tag GitHub o promozione stabile.

Il percorso noto Mode6 per i bordi convessi interi divide abs(dx) per dy una sola
volta per bordo. Ogni scanline applica il quoziente con segno e al massimo una
correzione esatta del resto, aggiornando soltanto minimo e massimo. Conserva le
sequenze orizzontali inclusive e le righe a punto singolo di diagonali/verticali,
entrambi gli ordini, i byte degli estremi, Y e fullcount. Il walker nativo Q2 e
i suoi fault restano invariati. Nessuna approssimazione o riduzione di copertura.

I campioni shade selezionano il bordo più vicino con un punto medio esatto a9bit
per estremi ordinati, mantenendo la scelta a sinistra nei pareggi. Se coincidono
si sceglie sinistra; se sono invertiti resta il calcolo originale delle distanze
assolute. Restano i controlli di intervallo. Il passaggio originale inizializza
entrambi gli array allo shade del vertice0: se tutti i vertici attivi hanno quel
valore, gli array sono già corretti e l'interpolazione dei bordi termina subito.
Le facce variabili mantengono l'interpolazione originale; il caricamento costante
di inizializzazione esce dal ciclo sulle righe. Lo scratch privato resta volatile.

La selezione richiede il corpo sorgente Mode6 noto e consumer wire, outline,
lazy-bound e wire specializzati disabilitati. Forme sconosciute e build con API
sfere opzionali mantengono il percorso della base. Mode7 e le altre modalità
restano agentic20. Nessuna nuova variabile RAM, tabella, allocazione massima di
stack o ampliamento delle finestre. Default, scena, percorso, musica, precisione,
LOD, clipping, materiali e ordine di disegno sono invariati.

Technical Debug ha profilato Mode6/7 e misurato le distribuzioni reali degli span.
L'ipotesi UV a texel costante non viene promossa: i domini misurati sono troppo
piccoli per dimostrare un beneficio netto dopo setup e ricostruzione dello stato.
Gli oracoli CPU verificano codice emesso, non FPS. La verifica nativa usa PAL
Turbo6510 a1/20/64x, SID originale attivo, warm128 e>=1024 refresh (~20,429s).
I casi pesanti a1x richiedono anche finestre più lunghe e confrontabili.
maincpu_clk misura tempo MACCHINA; non moltiplicarlo per64 per dedurre cicli CPU.

Si applicano20 test pubblici e l'audit separato di pacchetto/documenti. I tre test
riservati alla pubblicazione stabile restano conservati e non si applicano alla
lettera a questa dev. PRG, comandi, RAM, catture e report sono esterni in
../evidence/, esclusi dallo ZIP sorgente. Hardware e NTSC non sono nuovamente
qualificati. Il registro corrente definisce l’ambito esatto della qualificazione.

Verifica completata il 2026-11-02:54 casi compilabili a1x/20x/64x,162 celle
native,648 catture identiche,27 blocchi ereditati e0 nuovi. Indice fisso
performance-v1 124.166609792; agentic20 123.103329739;
stabile ufficiale1.15.1 117.647645352; riferimento1.15.0=100. Restano
invariati i12 stress/36 celle originali, i pesi uguali per modalitÃ /velocitÃ  e
la combinazione50/50 FPS/render. I guadagni delle finestre brevi a1x sono
quantizzati: anche tre finestre da326,866s per caso/lato, riportate separatamente
senza sostituire l'indice storico. Tre finestre ordinarie per lato su3 casi Mode6.
Warm128 refresh PAL, poi1024 refresh (~20,429s), musica SID originale attiva.
Superati18072 bordi,177289 campioni shade,6536 poligoni/9032 triangoli fan,
inclusi oltre1300 poligoni a luminositÃ  costante e6 fault terminali originali.
Superati20 test pubblici e audit di pacchetto/documenti. La ricompilazione
completa riutilizza144 osservazioni della base e9 del prototipo identico, dopo
controllo di PRG, tutti i simboli numerici, carichi, target e dati grezzi;9 nuove
osservazioni del catalogo. Le API sfere4/6 mantengono4 programmi identici e6
osservazioni storiche byte per byte (gli esempi API non hanno traccia musicale).
Il registro di qualificazione ora Ã¨ chiuso con questi limiti espliciti. Mode7 e
le altre modalitÃ  mantengono agentic20. Dev non pubblicata, non una stabile.
