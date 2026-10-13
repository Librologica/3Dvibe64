# 3Dvibe64 1.10.2 — ambito stabile corrente

Le note di sviluppo seguenti sono storiche. Release, opzioni, prove corrette e limiti correnti: [note di rilascio](RELEASE-NOTES-1.10.2.it.md). Runtime invariato dalla dev3.

---

# Historical development audit: 1.10.2-dev3 — verifica poligonale locale

Solo sviluppo, basato sul commit dev2 `26ba9ae13fd1b43bf0a09bf6aacf13b1f88e9f86`. Nessuna pubblicazione GitHub o promozione stabile. Release ufficiali e demo congelate restano invariate. Il riferimento completo e immutabile alla dev2, il bundle Git e i test sperimentali originari sono conservati fuori dall’SDK.

Mode8 torna al backend bitmap qualificato dopo le correzioni di manutenzione. I generatori `mode8-regions`, `mode8-rays`, `mode8-chars`, le loro combinazioni e le relative cache/tabelle/fallback a caratteri sono rimossi dall’SDK attivo. Omissione e `none` sono accettati; ogni richiesta sperimentale esplicita, incluso `all`, fallisce con `ENGINE_MODE8_RETIRED`. Restano intatti i template bitmap ordinari, validazione mappe, correzioni di navigazione/waypoint coincidenti, diagnostica indipendente dell’approssimazione adattiva, provenienza delle catture, doppio buffer, UI, palette e protezioni di memoria. Mode8 viene congelato dopo il checkpoint del ripristino.

Le migliorie Q8 della dev2 elencate sotto restano opzionali, disattivate per default. `all` richiede rigorosamente tutti i quattro flag Q8 e conserva i rifiuti di compatibilità. La selezione CLI esplicita prevale sulla scena. Le tabelle occupano 2048 byte; la visibilità può rallentare scene interamente visibili. Non viene aggiunto un sistema generale di occlusione o compilazione di portali.

| Flag | Comportamento implementato nell’engine / limiti |
|---|---|
| `uv-texel` | Sampler standard illuminato paired di Mode7 Q8 prospettico: conserva3..7 bit frazionari secondo repeat1..16, separatamente per U/V. Texture diverse usano il massimo necessario per asse. I texel scelti sono identici. Il fallback completo tratta le coppie fuori dominio. Gli endpoint fast e la ricorrenza unlit mantengono quoziente/resto completi e rifiutano il flag. |
| `q8-arithmetic` | Prodotto focale esatto43520A =85A traslato9, intermedi48 bit; normalizzazione del numeratore e divisione48/16 con fallback originale48/24. Nessun reciproco approssimato. |
| `camera-table` | Solo camera mobile Q8: quattro tabelle da512 byte, ricostruite solo al cambio dei coefficienti. Prodotti signed24 bit con lo stesso arrotondamento per prodotto, metà lontano da zero. Operandi assoluti modificati solo nel foreground. Senza il flag resta il moltiplicatore compatto; l’insufficienza di RAM produce un errore esplicito. |
| `visibility` | Poligoni Modes3..7: scarta volumi maggiorati fuori da un cono conservativo di45 gradi/dietro la camera prima dei vertici e della raccolta facce. La rotazione del centro condivide l’arrotondamento esatto. Mantiene oggetti incerti o a cavallo del piano vicino. Elimina facce opache esattamente duplicate nello stesso oggetto in Modes3..6; Mode7 conserva l’ABI più ricca facce/UV. Non introduce un depth buffer generale, PVS, compilatore di portali o occlusione fra oggetti. |

Lo stato fast a blocchi proviene invariato dalla dev1: `bk_predict` conserva il resto futuro; `bk_look0/bk_look1` condividono `ps_cur0/ps_cur1`; `bk_count` attivo evita l’avanzamento scalare dei tre canali prospettici. `none` non annulla questa ottimizzazione. La specializzazione UV riguarda il sampler standard illuminato paired; gli endpoint fast mantengono precisione completa e rifiutano `uv-texel`. La baseline fast precedente alla dev1 va isolata dal confronto di profilo standard/fast.

Risultati nuovi ed ereditati, comandi, hash, tracce, memoria e immagini sono distinti nell’archivio separato delle prove, in `RESULTS.md` e `final-comparison.json`. Gli FPS nativi contano nuove viste complete nel tempo emulato; il replay delle istruzioni verifica soltanto la correttezza. Piattaforma di prova Windows/VICE; Linux e hardware reale non testati. Manuali e misure storici conservano il proprio ambito originario.

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 7 -Precision q8 -SceneFile examples/mode7-perspective-cube.json -EngineExperiments q8-arithmetic,uv-texel -VideoStandard pal -OutputDirectory ../dev3-uv
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 4 -Precision q8 -Q8Camera auto -SceneFile examples/q8/two-objects-mode4.json -EngineExperiments q8-arithmetic,camera-table,visibility -OutputDirectory ../dev3-camera
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile examples/mode8/two-levels.json -Mode8Run auto -EngineExperiments none -OutputDirectory ../dev3-mode8
python -B scripts/run_release_tests.py
```

## Dev3 qualification / Qualificazione dev3

Checkpoint ripristino Mode8: `39dfdec`; guardia host: `c73c46f`. Dodici PRG bitmap/ASM/rapporti di build sono identici ai riferimenti dev2 none. Sul percorso two-levels completo, stock PAL3,113291FPS (p95558,610ms, massimo798,013ms), NTSC3,218422FPS (p95534,886ms, massimo768,893ms) riproducono esattamente la dev2. Warm-up101/120 refresh; misura179,553/180,523 secondi emulati. I3,2FPS storici usano un’altra finestra di qualifica.

La guardia host rifiuta -O, -OO e PYTHONOPTIMIZE prima della qualifica nativa, anche chiamando direttamente native.run. Una cattura valida passa; un bitmap alterato con hash del manifest coerente fallisce. Il runner pubblico comprende28 gate effettivi: mantenute le regressioni ordinarie Q8/fast/Mode8, archiviati i test esclusivi dei backend ritirati, aggiunti i gate sul ritiro e su Python ottimizzato. Tutti28 passano.

Nuove prove prestazionali:88 misure Q8 native non profilate (44 principali Turbo6510x64,16 stock PAL/NTSC,22 prove span/repeat/materiali,6 regressioni Modes3/5/6). Le otto combinazioni Mode4 aritmetica/tabelle/visibilità compilano sia sulla scena pubblica sia sulla sparse mobile con sei oggetti, in entrambi gli standard. Pubblica PAL:30,186 baseline,36,257 aritmetica,30,854 tabelle,29,518 visibilità,39,738 aritmetica+tabelle,38,485 tutti e tre. NTSC baseline31,021/tutti e tre34,234. Mode7 standard PAL3,091 baseline,3,119 aritmetica,3,676 UV,3,704 entrambi. Sono risultati della scena/profilo, non nuovi default.

Renderer e attesa della presentazione sono misurati separatamente. Le prove stock durano120s fast/180s standard e Mode4 dopo ~2s di warm-up; Mode7 standard lento produce poche immagini, con conteggi e dimensione del campione dei percentili conservati. Trace/stopwatch/profiler del fork contano cicli macchina (PAL985248Hz, NTSC1022727Hz); Times del profiler conta istruzioni eseguite. Un ciclo noto di16384NOP verifica la distinzione. I campi euristici OPC/Branch%/Stolen non sono usati ax64. Warp e tempo host sono esclusi dagli FPS.

408 confronti nativi su pose accoppiate più24 nei Modes3/5/6 hanno zero differenze bitmap/screen/ColorRAM.22 PRG Q8 dev2 si rigenerano identici; i quattro PRG fast vecchi/nuovi PAL/NTSC coincidono con i riferimenti dev1 verificati. Il beneficio fast ereditato è misurato separatamente contro texture_fast.py pre-dev1: span lunghi6,321→7,463FPS, code brevi28,125→28,125, clipping/materiali misti6,293→7,379.477 span assemblati/38637 campioni conservano UV e residui ai confini. Standard contro fast resta un confronto fra profili visivi.

Un solo prototipo esterno ha riusato la ricorrenza razionale esatta non illuminata con12 byte privati nel sampler illuminato. Immagini e51516 campioni numerici passano, ma il guadagno misurato è1,152x contro la baseline isolata completa con aritmetica, sotto l’obiettivo di investimento e più lento dell’attuale aritmetica+UV sulla scena pubblica repeat2×2. È ritirato e archiviato; la dev3 non include ulteriore codice o flag runtime poligonali. Mode8 resta congelato. Risultati nuovi ed ereditati, comandi completi, hash sorgenti/PRG, tracce, profili, mappe di memoria, stime di copertura e immagini sono nell’archivio separato delle prove. Copertura/sovrapposizione da bounds inclusivi è un limite superiore, non il risparmio esatto di scritture occultate. Non viene avviato un compilatore di visibilità.

Linux e hardware fisico restano non testati. Input diagnostici e comandi profiler preliminari invalidi sono conservati separatamente ed esclusi dai risultati qualificati. Per matrice completa e contenuto effettivo dei gate vedere RESULTS.md e final-comparison.json nell’archivio delle prove. Lo ZIP sorgente resta l’SDK normale, senza materiale straordinario, demo, video, emulatore o PRG compilati.

## Correzione documentale del rapporto — 2026-10-13

Runtime invariato al checkpoint 799be44544933aa759111748b9dc68accaab5da7.
Questa copia dell’SDK cambia soltanto le note IT/EN e il manifest: nessuna
nuova versione runtime, flag, ottimizzazione o pubblicazione. Il generatore
esterno indicizzava le acquisizioni per nome e alcune misure stock sostituivano
quelle Turbo6510 ×64 nelle tabelle. Dodici celle Mode4/Mode7 sono corrette dalle
tracce originali, separando target, standard, animazione e profilo. I valori
prestazionali di queste note erano già corretti. Il profilo pubblico Mode7 usa
repeat2×2: è corretta anche la precedente etichetta imprecisa repeat1.
AC PAL pubblico 39,737623 FPS supera ACV 38,484510 FPS; all esprime le opzioni
compatibili e non garantisce il massimo FPS. Report e 17 regressioni dello
strumento restano nell’archivio separato, distinti dai 28 gate SDK storici.
