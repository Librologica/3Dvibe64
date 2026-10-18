# Qualificazione nativa — 1.12.0

Release sorgente locale, nessuna demo/esempio o media incluso. [Risultati strutturati](QUALIFICATION-1.12.0.json).

| Caso | FPS prima | FPS dopo | Variazione | p95 prima/dopo ms | Peggiore prima/dopo ms |
|---|---:|---:|---:|---:|---:|
| Mode7 texture | 6.4858 | 7.0977 | +9.43% | 219.45/199.50 | 239.40/219.45 |
| Mode7 uniform | 20.1918 | 23.0064 | +13.94% | 59.85/59.85 | 59.85/59.85 |
| MAT-01 flat spans | 8.8599 | 8.9252 | +0.74% | 119.70/119.70 | 139.65/139.65 |
| Mode6 room | 8.4683 | 8.4683 | +0.00% | 119.70/119.70 | 139.65/139.65 |
| Mode6 overlapping walls | 13.7794 | 15.0276 | +9.06% | 79.80/79.80 | 79.80/79.80 |

Target VICE Turbo6510 PAL312×63 moltiplicatore64, esplicitamente silenzioso, filtro0, palette VICE predefinita, presentazione safe, senza warp. Warm-up101refresh=2,014981secondi emulati. Texture/uniforme/Mode6:2048refresh=40,858229secondi; posizione fissa con oscillazione yaw/pitch, due periodi1024tick, nessuna pausa. MAT-01:3072refresh=61,287343secondi, giro mobile completo48chiavi. Q8 standard preciso, tutte le righe. Mode7 conserva LOD texture graduale28/44WU; Mode6 non usa texture o LOD geometrico. MAT-01 mantiene profilo preciso, viewport e LOD14/22WU. Contate solo nuove viste complete dopo presentazione del buffer; refresh duplicati, tempo host, velocità warp e replay CPU esclusi. Comandi, timestamp, RAM, record sorgenti e immagini sono esterni nella cartella di qualificazione separata.

Il caso positivo di pareti sovrapposte esclude 420 occorrenze di quad in 645 passaggi (contatori cumulativi, warm-up incluso). Il caso stanza non ha quad nascosti e non mostra guadagno. Entrambi combinano inside-planes e occlusione: non isolano l'effetto delle singole opzioni. Prove Mode6 riusate solo quando la ricompilazione finale produce gli stessi byte PRG e condizioni. Ogni variante coincide con il controllo in cinque pose native a simulazione congelata:25confronti, zero pixel diversi nell'area3D. Le prove immagini non misurano FPS.

Superati16gate pubblici autonomi. Tutti i42riferimenti Q8 PAL/NTSC congelati e8riferimenti Mode7 coincidono con gli hash originali; formato LF del generatore conservato. I contratti6502 coprono3006divisioni,260clipping,5000avanzamenti,5643prodotti camera,1600vertici,2907span flat MAT,2336span bulk,1006decisioni occlusione,1156intervalli Gouraud costanti,51assegnazioni cache native,1024chiamate SID sintetiche e1000transizioni pool. Le prove dei rettangoli includono pitch/roll ampi e clamp ai bordi. Questi test dimostrano correttezza, non stimano FPS. I supporti sono collegamenti delimitati, non un gioco procedurale completo o loader SID universale.

La prima preparazione convertita CRLF è stata rifiutata e sostituita; i suoi risultati non qualificano la release finale. Release ufficiali precedenti, dev privata e demo congelate conservate. Restano espliciti i limiti Mode4 e degli shader illuminati. [Contratti](RENDER-OPTIMIZATIONS.it.md) · [Supporti](ADAPTER-SUPPORT.it.md) · [Test](TESTING.md).
