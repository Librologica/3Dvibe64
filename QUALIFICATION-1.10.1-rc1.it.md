# Qualificazione — 1.10.1-rc1 locale

Base: commit `388595adcf49436a437f65b184d52149e8a2b80e`, stabile 1.10.0. Candidata: `1.10.1-rc1` locale, branch `maintenance/1.10.1-rc1`, prerelease esplicita. Pubblicazione GitHub esclusa da questa esecuzione. Conservati tag, asset e identità storiche. Lo ZIP dell'audit non era disponibile: ricostruiti i casi numerici dettagliati. La baseline effettiva contiene 88 file di testo CRLF, rispetto ai 78 dell'audit; normalizzazione in commit separato.

| Rilievo | Causa verificata e intervento | Prova di accettazione |
|---|---|---|
| Proiezione Mode7 Q8 | Segno perso nella riduzione signed24; codici unsigned48 completi, rigetto del solo semispazio esterno comune | Bitmap nativa 8000→0 byte non nulli; controllo vuoto; `hp_fault=0`; oracolo indipendente esatto per attraversamenti e UV |
| Luce flat Mode7 | +128 interpretato come −128; prodotto Q6 saturo solo luminoso | Vettore assemblato `[0,30,127]`, livelli facce opposte; 66.048 prodotti estremi |
| Override viewport / texture | Proprietà opzionale e rilettura JSON originale; lookup sicuro condiviso e impostazioni effettive nel preprocessore | Contract assente, alias, precedenza CLI, valore invalido e PNG relativo |
| Riuso catture | Identità acquisizione assente; nuovo manifest programma/input/file prima della qualificazione | Riuso autentico PAL/NTSC positivo, PRG modificato rifiutato; nove negativi sintetici di identità |
| Validazione / navigazione Mode8 | Assert obbligatorio e heading zero incoerente; eccezioni esplicite, heading 64 | Python normale/ottimizzato; 100 tick assemblati reali, zero pose divergenti |
| Copie test / etichette | Copia `.git` e separatore non nativo; elenco manifest corrente e percorso OS risolto | Suite su copie pulite da clone, compilatore Windows reale; esecuzione Linux aperta |
| Allocazione | Solo primo indirizzo allineato; fallback su tutti gli indirizzi con budget dopo la strategia originale | Controesempio 512/468 byte risolto; budget esaurito distinto da impossibilità dimostrata |
| Approssimazione adattiva Mode8 | Bordi gruppo uguali nascondono cambi interni; diagnostica inclusa, runtime invariato | 34 viste assembly/adattivo/fine, 36 byte / 138 pixel nel controesempio; costo prototipi misurato |
| Cache Q8 ritirate | Riserve presenti senza consumatori; nuovo layout runtime non incluso | Riserve misurate esattamente 15/18 byte; lavoro generale sul layout rinviato |

I riferimenti PRG correnti cambiano soltanto per Mode7 flat legacy e sei build Mode7 Q8, dopo prove numeriche/visive indipendenti. Gli otto vecchi riferimenti Mode7 e i 42 Q8 restano nei metadati separati. Gli altri sette riferimenti legacy Mode7 coincidono byte per byte. Invariati `mul_s6` geometrico, istruzioni Gouraud, runtime Mode8 e limiti pubblici dei profili.

## Gate pubblici e numerici

PASS: tutti i 25 script pubblici su copie pulite con i byte effettivi del pacchetto.

Prima esecuzione completa di 25 script: 24 PASS, un FAIL di impostazione del test host, che passava a Mode8 opzioni CLI solo poligonali. Corretto il helper del test; il suo rerun ufficiale mirato PASS completa i gate finali 25/25. Conservati log del primo fallimento e del rerun. Nessuna modifica engine/runtime necessaria. Controlli sul pacchetto finale estratto registrati separatamente.

PASS mirati: 14 profili numerici assemblati PAL/NTSC, 12.152 classificazioni del quoziente completo, 1.616 poligoni near/screen con UV affine esatte, 66.048 prodotti luce; test host/configurazione/provenienza/allocazione. Aritmetica/replay CPU costituiscono soltanto prove di correttezza.

## Mode7 nativo prima/dopo

32 build reali: otto profili × PAL/NTSC × baseline/candidata. VICE Turbo6510 ×64, viewport normal, presentazione safe, linee precise, filtro 0, senza SID/musica o overlay. PAL: warm-up 101 refresh (~2,015 s), misura 1024 (~20,429 s); NTSC: warm-up 120 (~2,006 s), misura 1230 (~20,560 s). Contati solo `fps_frame_done` dopo presentazioni complete; trace IRQ verificano i clock base emulati. Tempo host e warp non forniscono FPS. Comandi, script/log monitor, cicli grezzi, hash programma/scena e RAM sono nelle cartelle prove `mode7-native-matrix/*/native-fps`.

| Profile / Profilo | Video | FPS before / prima | FPS RC | p95 ms | worst / peggiore ms |
|---|---|---:|---:|---:|---:|
| q8-affine-none | PAL | 12.188487 | 12.188487 | 99.752 | 99.752 |
| q8-affine-none | NTSC | 12.646165 | 12.646165 | 100.291 | 100.291 |
| q8-affine-flat | PAL | 11.894789 | 11.894789 | 99.752 | 119.702 |
| q8-affine-flat | NTSC | 12.159774 | 12.159774 | 100.291 | 117.006 |
| q8-affine-gouraud | PAL | 9.985749 | 9.985749 | 119.702 | 139.652 |
| q8-affine-gouraud | NTSC | 10.506045 | 10.506045 | 117.006 | 133.721 |
| q8-perspective-none | PAL | 3.573332 | 3.573332 | 339.155 | 379.056 |
| q8-perspective-none | NTSC | 3.696571 | 3.696571 | 334.302 | 367.733 |
| q8-perspective-flat | PAL | 3.230683 | 3.230683 | 319.205 | 339.155 |
| q8-perspective-flat | NTSC | 3.356098 | 3.356098 | 317.587 | 317.587 |
| q8-perspective-gouraud | PAL | 3.083834 | 3.083834 | 339.155 | 339.155 |
| q8-perspective-gouraud | NTSC | 3.210180 | 3.210180 | 334.302 | 334.302 |
| q8-fast-gouraud | PAL | 6.950864 | 6.950864 | 159.602 | 159.602 |
| q8-fast-gouraud | NTSC | 7.247225 | 7.247225 | 150.436 | 150.436 |
| legacy-flat | PAL | 24.328025 | 24.328025 | 59.851 | 59.851 |
| legacy-flat | NTSC | 23.249488 | 23.249488 | 50.145 | 66.860 |

Profili affine: camera Q8 automatica e geometria pubblica rotante con due oggetti; misurata una fase in moto, non un percorso completo. Perspective/fast: camera stazionaria e cubi pubblici rotanti; le build Gouraud automatiche e interattive superano già la memoria della baseline invariata, quindi il perimetro è esplicito. Legacy: cubo flat pubblico rotante. Le 16 prime viste accoppiate coincidono nei due banchi bitmap/screen e nei nibble bassi Color RAM acquisiti separatamente. FPS uguali descrivono queste finestre alla risoluzione delle presentazioni quantizzata sui refresh, non assenza di lavoro CPU aggiuntivo.

## Memoria e opzioni rinviate

Incrementi misurati dei payload dei blocchi Q8: [119, 127] byte nella matrice; dettagli in `mode7-memory-impact.json`. Inclusi un byte codice per vertice runtime e due scalari. Helper solo flat: 25 byte codice; prodotto geometrico condiviso invariato. Verificati intervalli allineati e guardie; tutte le 32 build supportate della matrice entrano in memoria. Estensione PRG distinta dal payload allocato.

Mode8 stock x64sc, UI attiva, senza SID, warm-up 2 s, misura 20 s emulati: PAL 3,2 FPS, NTSC 3,3 FPS. La diagnostica fine indipendente mostra il limite conservato alla posa `[2546,7763,178,96,0]`: 36 byte bitmap / 138 pixel logici. Prototipo raggio centrale: PAL 2,8 FPS (−12,5%); tutto fine: 1,05 FPS (−67,1875%). Il prototipo centrale coincide su 34 viste selezionate e 1065 pose host vicine valide; nessuna prova universale. Il costo stock giustifica runtime invariato e diagnostica inclusa nella regressione host pubblica. Sorgenti/build prototipi nelle prove esterne, non default SDK. Nuovo layout cache Q8 rinviato dopo misura delle riserve di 15/18 byte.

| Mode8 stock | FPS | p95 ms | worst / peggiore ms |
|---|---:|---:|---:|
| PAL | 3.200 | 598.506 | 638.410 |
| NTSC | 3.300 | 568.312 | 601.748 |

## Gate aperto per la promozione e asset

Esecuzione Linux reale BLOCCATA: Linux/WSL e Docker assenti. Percorsi nativi risolti e build Windows reali passano; non dichiarata una prova eseguita su Linux. Prima della promozione stabile, eseguire il runner pubblico completo su toolchain Linux reale. Commit/tag congelati, integrità pacchetto estratto, rigenerazioni deterministiche, toolchain, percorsi asset e SHA256 sono nel rapporto finale separato accanto agli archivi sorgente/prove. Nessun upload GitHub.
