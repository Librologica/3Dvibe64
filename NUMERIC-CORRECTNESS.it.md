# Manutenzione numerica — 1.15.0

> SDK sorgente stabile1.15.0 preparato in locale; non pubblicato online. [Stato e supporto](RELEASE-STATUS.it.md).

Release stabile 1.15.0: [ottimizzazioni correnti](RENDER-OPTIMIZATIONS.it.md), [input esterni](EXTERNAL-INPUTS.it.md). Tutte le demo, gli esempi e le prove native sono esterni alla distribuzione sorgente.


Contratto sorgente corrente 1.14.0. Il manuale descrive l’exporter ordinario
salvo indicazione esplicita; API delimitate gameplay/configurazione/roll/gruppi
in [GAMEPLAY](GAMEPLAY.it.md). [Indice documentazione](DOCS.md).

Mode 7 Q8 conserva clipping camera-near, clipping screen-Q8 e raster Q2. Prima che la cache di proiezione signed 24 possa perdere il segno di una coordinata lontana, il quoziente unsigned 48 completo fornisce i codici dei semispazi laterali. L'AND di tutti i vertici del poligono dopo il clipping near scarta solo un semispazio esterno comune. Un singolo vertice esterno non elimina una faccia attraversante; le coordinate non vengono saturate separatamente per interpolare UV.

Resta il limite pubblico del raggio scalato≤40 WU. Una faccia contribuente in questo profilo di trasformazione limitato rientra nel dominio signed 24 delle coordinate e intersezioni. Ampliare diametro/near-depth richiede una nuova verifica del limite. I vertici generati dal near hanno codici propri; i vertici sorgenti dietro la camera non vengono usati impropriamente come punti proiettati a profondità positiva. Normalized 16 conserva il proprio clipper omogeneo.

Limite conservativo del contratto: coordinate locali signed byte con norma inferiore a 222 WU; raggio scalato massimo 40 WU. Trigonometria Q8 arrotondata/interpolata distante da quella ideale meno di 1,1/256; prodotti di matrice annidati con errore inferiore a 0,03 per coefficiente prima della scala. Errore della matrice a tre assi inferiore a 3,6 WU, arrotondamento finale dei coefficienti inferiore a 1,4 WU. Due rotazioni camera e arrotondamenti lasciano ancora la mesh entro un raggio di 50 WU, quindi diametro inferiore a 100 WU. Il clipping near conserva questo limite convesso con ampio margine. Con near 1 WU, focale 170 e semiestensioni viewport 80/50, un poligono non scartato banalmente ha intervallo X proiettato entro `(170+80)*100 = 25000` pixel e Y entro `(170+50)*100 = 22000`. Attraversando lo zero vale il limite più stretto `170*100`; su un solo lato, un estremo entro quel semispazio ancora il limite. Coordinate contribuenti e differenze usate nelle intersezioni screen restano nel signed 24 Q8 (±32768 pixel). Poligoni interamente esterni possono superarlo: il quoziente completo li scarta prima che le cache avvolte entrino nel clipping screen. La prova dipende dai limiti correnti di raggio, coordinate, near e focale.

Il caso x 206, z 1/33 trasformava 35100 pixel in −30436 e riempiva 8000 byte bitmap. La RC produce zero byte bitmap e hp_fault=0. Il controllo x 192, z 1 resta vuoto. Test indipendenti sull'assembly coprono estremi speculari, soglie, attraversamenti near/screen e UV affine esatte. Gli altri profili condivisi sono verificati separatamente: none/flat/Gouraud, affine/perspective e Gouraud fast, PAL/NTSC.

La luce flat Mode 7 satura ogni prodotto Q6 luminoso prima dell'interpretazione signed byte. In particolare −128 × −64 / 64 diventa 127, non −128. Il mul_s 6 geometrico condiviso resta invariato. Gouraud usa lo stesso helper sorgente mantenendo le istruzioni emesse originali. Il caso nativo a 180 gradi produce [0,30,127] e livelli corretti sulle facce opposte; i prodotti luminosi assemblati coprono 256 × 129 input per standard.

Le impostazioni texture usate dal preprocessore seguono default<JSON<CLIesplicita. I PNG vengono ancora risolti accanto alla scena originale. Il lookup viewport di contract opzionale e objectModel usa lo stesso helper sicuro sulle proprietà. Il compilatore riceve percorsi etichette risolti secondo il sistema operativo. I vincoli pubblici Mode 8 restano attivi con python -O; heading coincidente 64 sia nel modello host sia nel runtime.

Il riuso nativo richiede un manifest dell'acquisizione che collega programma, scena, impostazioni build, etichette, font, standard video, modalità e hash dei file acquisiti. Prove mancanti/modificate vengono rifiutate. Le vecchie catture restano materiale storico e non qualificano un PRG diverso. Le fixture sintetiche di identità verificano solo la validazione e non forniscono FPS.

L'allocazione conserva prima le disposizioni già riuscite. Se la ricerca limitata fallisce, esplora tutti gli indirizzi allineati ammessi entro 60.000 stati Q8 / 100.000 Normalized 16. SEARCH_BUDGET_EXHAUSTED è distinto da NO_ALIGNED_PLACEMENT. Restano allineamenti pagina/word, guardie codice 32 byte e intervalli originali. Il controesempio 512/468 byte ora entra. Il nuovo layout delle cache coordinate ritirate è rinviato: le riserve misurate 15/18 byte non giustificano l'estensione dei cambiamenti runtime di questa RC.
