# 3Dvibe64 1.10.2 — release stabile locale

2026-10-14. Promozione del runtime dev3 qualificato `799be44544933aa759111748b9dc68accaab5da7` e della correzione
definitiva del rapporto. Preparazione locale, senza pubblicazione GitHub. Il
commit della release è registrato nei manifest separati di consegna/prove.
Release stabili e demo congelate precedenti restano intatte.

## Cambiamenti rispetto alla stabile 1.10.1

- Mode7 fast riusa lo stato prospettico per blocco ed evita l’avanzamento
  scalare ridondante dei carrier. L’ottimizzazione proviene dalla dev1 ed è
  attiva nel fast anche con `EngineExperiments none`, mantenendo il suo profilo.
- Quattro migliorie opzionali Q8 del generatore, conservando il nome pubblico
  `EngineExperiments`: `q8-arithmetic` esatta; `uv-texel` per sampler standard
  illuminato paired secondo il repeat; `camera-table` mobile da 2048 byte;
  `visibility` conservativa fuori campo e rimozione dei duplicati opachi esatti
  nella stessa mesh nei modi supportati. Nessun nuovo flag o backend.
- Mode8 usa il backend bitmap qualificato dopo la manutenzione. Regions/rays/
  chars e combinazioni sono ritirati e rifiutati, compreso `all` Mode8. Sono
  accettati selezione ordinaria e `none`. Conservati validazione, navigazione,
  waypoint coincidenti, provenienza, UI, palette, doppi buffer e protezioni
  RAM; conservata anche la diagnostica indipendente del limite adattivo noto.
- Qualificazione nativa host e runner pubblico rifiutano Python ottimizzato
  (-O/-OO/PYTHONOPTIMIZE), anche chiamando native.run direttamente. Il
  generatore esterno del rapporto separa stock/Turbo, standard, profili e
  animazioni e blocca selezioni assenti o ambigue.

Runtime/generatore, esempi, default e contratti delle opzioni sono identici alla
dev3 qualificata. Geometria legacy default, Q8 esplicito, texture standard,
linee precise, LOD off e presentazione safe. Normalized16 mantiene il proprio
contratto sperimentale separato: la promozione non estende la qualificazione.

## Prove native — Turbo6510 ×64

| Scenario / options | PAL FPS | NTSC FPS |
|---|---:|---:|
| Mode4 public / none | 30.186113 | 31.020935 |
| Mode4 public / q8-arithmetic | 36.256752 | 33.873753 |
| Mode4 public / q8-arithmetic,camera-table | 39.737623 | 35.009341 |
| Mode4 public / q8-arithmetic,camera-table,visibility | 38.484510 | 34.233818 |
| Mode4 sparse mobile / none | 20.523215 | 20.135911 |
| Mode4 sparse mobile / q8-arithmetic,camera-table,visibility | 25.090118 | 29.885347 |
| Mode7 standard / none | 3.091013 | 3.212883 |
| Mode7 standard / q8-arithmetic,uv-texel | 3.703647 | 3.822222 |
| Mode7 fast / 1.10.1 pre-dev1 baseline | 6.906048 | 7.228986 |
| Mode7 fast / inherited block state | 8.047774 | 8.364574 |

## Prove native — stock 6510 ×1

| Scenario / options | PAL FPS | NTSC FPS |
|---|---:|---:|
| Mode4 public / none | 0.649958 | 0.672203 |
| Mode4 public / q8-arithmetic,camera-table,visibility | 0.749952 | 0.766645 |
| Mode4 sparse mobile / none | 0.366643 | 0.377767 |
| Mode4 sparse mobile / q8-arithmetic,camera-table,visibility | 0.483302 | 0.494430 |
| Mode7 standard / none | 0.044442 | 0.049999 |
| Mode7 standard / q8-arithmetic,uv-texel | 0.061107 | 0.061109 |
| Mode7 fast / 1.10.1 pre-dev1 baseline | 0.116666 | 0.116653 |
| Mode7 fast / inherited block state | 0.133332 | 0.141650 |

Nessuna misura stock AC o aritmetica isolata è dedotta da ×64. Mode7 standard
stock presenta poche viste (PAL none 8, A+UV 11); campioni, p95 e massimo sono
nel JSON/CSV delle prove. FPS stock e accelerati restano distinti. La sparse
storica dev2 aveva camera ferma e rimane separata dalla matrice sparse mobile.
Il profilo pubblico Mode7 usa repeat texture2×2.

AC pubblico PAL supera ACV: 39,737623 contro 38,484510 FPS. `all` richiede i
quattro flag Q8 compatibili, conserva gli errori di contratto e non garantisce
la build più veloce; non è valido per ogni profilo. Le tabelle camera costano
2048 byte e vengono ricostruite al cambio dei coefficienti. La visibilità può
costare tempo quando tutti gli oggetti sono visibili. Restano i controlli
effettivi di capienza RAM e dominio numerico. Pubblica PAL none→AC: rendering
**22.359 → 18.732 ms**, attesa di presentazione **10.750 → 6.412 ms**. Gli FPS comprendono anche
altro lavoro e cadenza video: misure distinte da replay istruzioni o tempo host.

Il guadagno fast usa il modulo isolato precedente alla dev1, dal commit
ufficiale 1.10.1 `7b27fd8a2f38a4dee13ee5eecf950a27b4f84a03`. `none` attuale
conserva già l’ottimizzazione e non è la baseline. Standard/fast è un confronto
di profilo visivo: il fast mantiene i compromessi dichiarati di ricostruzione
per blocchi/righe. Richiede Q8 prospettico e Gouraud C; uv-texel richiede il
sampler standard illuminato paired supportato ed è rifiutato con fast/unlit.
Nessuna riduzione di qualità è dichiarata nuova ottimizzazione della 1.10.2.

## Comandi e limiti conservati

```powershell
# Mode4, public moving camera: arithmetic + camera tables
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 4 -Precision q8 -Q8Camera auto -SceneFile examples/q8/two-objects-mode4.json -EngineExperiments q8-arithmetic,camera-table -VideoStandard pal -OutputDirectory ../mode4-ac
# Mode7 standard perspective, repeat2x2, Gouraud C
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 7 -Precision q8 -SceneFile examples/mode7-perspective-cube.json -EngineExperiments q8-arithmetic,uv-texel -VideoStandard pal -OutputDirectory ../mode7-uv
# Fast is a separately selected visual profile; uv-texel is incompatible
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 7 -Precision q8 -TexturePrecision perspective -TextureQuality fast -SceneFile examples/mode7-fast-cube.json -EngineExperiments none -VideoStandard pal -OutputDirectory ../mode7-fast
# Mode8 remains ordinary bitmap
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile examples/mode8/two-levels.json -Mode8Run auto -EngineExperiments none -OutputDirectory ../mode8
```


Le prestazioni riusano PRG nativi verificati senza strumentazione. PAL/NTSC
separati: warm-up101/120 refresh (~2 secondi), ×64 circa35,911/36,105 secondi
emulati; stock Mode4/standard180 secondi e fast120, usando l’intervallo reale
stopwatch dopo il warm-up. Programmi misurati senza musica, viewport normal,
presentazione safe, linee precise, filtro0 e nessun overlay. I contatori fork
misurano clock macchina maincpu, non istruzioni o cicli CPU Turbo; PAL985248/
NTSC1022727Hz. Contate soltanto nuove viste complete presentate; refresh
duplicati, warp e tempo host non definiscono gli FPS. Rendering, attesa e altro
lavoro hanno campioni e bordi della finestra espliciti.

Mode8 bitmap two-levels completo stock conserva PAL3,113291/NTSC3,218422 FPS,
p95558,610/534,886 ms e massimo798,013/768,893 ms; warm-up101/120 refresh,
misura179,553/180,523 secondi emulati. Il precedente valore3,2 FPS appartiene
a una finestra di qualificazione diversa.

La suite dev3 completa documenta28 gate. Controlli finali sul pacchetto
versionato/estratto e identità dei PRG rigenerati sono nell’archivio release;
gate invariati sono riusabili solo verificando l’identità dei sorgenti. Le17
regressioni del rapporto restano separate. Timing nativo, profili diagnostici,
correttezza per posa e dati storici hanno identità distinte. La correzione del
rapporto ha ricontrollato96 acquisizioni. Negli archivi storici dev1/dev2 manca
l’hash contemporaneo dell’emulatore: lacuna esplicita, con PRG, opzioni e tracce
verificati. La nuova coppia fast isolata dev3 ha identità eseguibile registrata.
Nessun risultato mancante è interpolato o attribuito ad altre configurazioni.

Windows/VICE qualificato sui profili dichiarati; Linux e hardware reale non
testati. Conservato il limite noto dell’approssimazione adattiva Mode8. Nessun
solver generale di occlusione, compilatore portali o nuovo esperimento. Il
prototipo esterno ritirato e gli esperimenti Mode8 ritirati restano nell’archivio
storico separato. ZIP sorgente con SDK normale, guide, esempi e test; tracce,
PRG generati, demo, video ed emulatori restano separati.
