# Agentic29 — 1.15.2-dev-agentic29

Sviluppo non pubblicato dalla agentic28 consegnata. [English](AGENTIC29.en.md).
Registro corrente: [QUALIFICATION-AGENTIC29.json](QUALIFICATION-AGENTIC29.json).
Note e registri versionati precedenti restano storici immutabili. API invariata.

Il percorso controllato Mode7-C affine legacy-plus ordinario mantiene DDA intero
UV/Q esatto, copertura e pareggi, cap chiusi, indirizzamento texture, luce/Bayer,
materiali e stato UV/Q pubblicato. Le trasformazioni sono generali per l’engine,
senza rami per benchmark/scena, cambi di qualità o impostazioni predefinite:

* Ink usa p1lo dopo il trasferimento di U in X. I16 byte privati già salvati
  proteggono span autonomo e fill per faccia. `(Uhi XOR V) AND15 XOR V` compone
  esattamente `(V AND240) OR Uhi`, eliminando lo spill dell’indice temporaneo.
  Resta il carry dell’ultimo shift di U.
* La selezione a luce stabile parte dal primo byte interamente allineato,
  sostituendo la soglia di24 pixel. Copertura parziale e Q finale non cambiano.
* Il setup luce tratta direttamente abs(deltaQ)<denominatore originale non
  ritagliato: quoziente0, resto abs(deltaQ), segno/errore originali. Gli altri
  valori e denominatore zero mantengono il DDA generale. UV riusa lo stesso
  denominatore. Lo scratch privato del setup Q viene sovrascritto da UV prima
  di qualsiasi lettura successiva.
* I chiamanti privati riconosciuti consentono di inizializzare soltanto le
  sentinelle dei bound. La prima visita imposta entrambi gli estremi UVQ;
  gli attributi delle righe vuote, saltate dal fill, diventano scratch privato
  non specificato. Una prova per faccia controlla tutti i vertici del triangolo
  o quadrilatero rispetto al range verticale. Gli spigoli monotoni evitano
  quindi confronti ripetuti; range ridotti/vertici esterni conservano i controlli.

Sono richiesti contesti/forme dei chiamanti noti; gli usi personalizzati o
sconosciuti mantengono il comportamento della base. Nessun nuovo alias zero page,
variabile persistente o tabella dati. Durate dei prestiti privati controllate;
il codice aggiunto occupa RAM reale nell’allocatore delimitato originale.
L’helper del range aggiunge un indirizzo di ritorno JSR temporaneo, nessun nuovo
byte dati salvato. Restano percorsi temporanei brevi, ordine/budget/finestre
di allocazione. Altre modalità e AnimatedMesh conservano la agentic28 consegnata.

Technical Debug usa PRG/simboli della stessa build, letture in pausa e nessun
campionamento live. maincpu_clk è tempo macchina PAL, mai cicli CPU accelerati.
Qualifica nativa PAL Turbo6510 a1x/20x/64x, SID originale attivo, warm-up128 refresh
(~2,554s), almeno1024 refresh misurati (~20,429s), percorso16 pose. Contano solo
viste nuove complete. Comandi, hash, intervalli/p95/peggiore e fasi ferme/mobili
restano esterni. Finestre lunghe ripetute integrano i pochi frame a1x e gli FPS
quantizzati a64x. I callback CPU verificano solo correttezza. Hardware e NTSC
non sono nuovamente qualificati.

Performance-v1 invariato:12 stress/36 celle, uguali pesi modalità/velocità e50/50
FPS/inverso del render, stabile1.15.0=100. A ogni dev/release verificare
allineamento suite/adapter e confronto con base e stabile ufficiale1.15.1.
Holdout utilizzati soltanto per la qualifica finale.

Consegna di soli sorgenti/documentazione. Tutti i trial e le prove sono esterni
in3Dvibe64_Verifiche_1.15.2-dev-agentic29_2026-11-06. Nessuna demo/scena, modello,
musica, PRG, cattura o SDK di riferimento incluso. Nessuna promozione stabile
o pubblicazione autorizzata. Le misure finali sono nel registro corrente.

Qualifica finale:81 compilazioni a freddo,54 casi compilabili/162 celle native,648 catture identiche alla base,27 blocchi ereditati e0 nuovi.22 test pubblici predefiniti passati. Indice generale 136.266540957, base 135.434561314 (+0.614%), stabile1.15.1 117.647645352. StressMode7 a64x 8.370407 → 8.859904 FPS, render medio -5.322%. Tre finestre abbinate da81,716s a64x: 8.358169 → 8.872142 FPS (+6.149%), render -5.303%. Tre finestre da326,866s a1x: 0.146849 → 0.152968 FPS. Oracolo span:12880 coppie di estremi,17424 casi luce/fase; oracolo fill:256 facce/8218 righe, entrambi i banchi,16 byte ripristinati e stack bilanciato. Sono verifiche di correttezza, mai FPS.
