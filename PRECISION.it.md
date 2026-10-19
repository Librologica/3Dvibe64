# Precision / Precisione — 1.15.0

> SDK sorgente stabile1.15.0 pubblicato su GitHub. [Stato e supporto](RELEASE-STATUS.it.md).

| Geometria | Mode | Camera/clipping | Texture Mode7 |
|---|---|---|---|
|legacy (default)|1–7|Contratto storico intero/angoli byte|Affini|
|legacy-plus (esplicito)|1–7|Q4, camera fine, near8; profilo delimitato walkLite/normal|Affini o prospettiche, none/flat/Gouraud A/B/C|
|q8 (esplicito)|1–7|Geometria Q8, near1; profilo delimitato proprio|Affini o prospettiche; Gouraud solo C|
|normalized16|1–7|Profilo sperimentale separato|Affini|
|Mode8|8|Renderer dedicato|Contratto proprio|

Profilo stabile SDK pubblico; build di riferimento legacy/Q8 identiche nei byte. Attivare texture prospettiche non trasforma plus in Q8. Vincoli e ABI camera sono in [LEGACY-PLUS](LEGACY-PLUS.it.md), FPS/stabilità nella [qualifica](QUALIFICATION-1.14.0.it.md). Le sezioni seguenti conservano il contratto Q8 e non estendono plus a fixed/walkFull, viewport small, Ground o roll.

## Default e raccomandazione

**Legacy è sempre il default.** Omettere `-Precision` e specificare
`-Precision legacy` usa lo stesso renderer e output di riferimento della 1.4.0.
Q8 richiede l'opzione esplicita da riga di comando `-Precision q8`. Né la velocità
della CPU né un campo nel JSON scena lo selezionano automaticamente.
Legacy non è deprecato. Consigliamo legacy a **20 MHz e meno**, Q8 **sopra
20 MHz**: è una raccomandazione qualità/costo, non un requisito hardware minimo
o una garanzia di FPS. La Mode 8 è invariata e non accetta Q8.

## Cosa cambia con Q8

Q8 conserva le frazioni degli angoli oggetto e delle coordinate trasformate,
usa proiezione e clipping near/screen più ampi e passa le frazioni schermo agli
edge Q2. Riduce gli scatti di quantizzazione e corregge le discontinuità di clipping
qualificate, inclusi bordi e facce quasi tangenti/fuori schermo. Il clipping screen
conserva Q8 fino alla conversione nel contratto raster a quarti di pixel esistente.
La risoluzione visibile non aumenta: nessun antialiasing o nuovo colore.
Illuminazione, normali, materiali, reflectivity, fill e sampling affine Mode 7
non vengono trasformati in un nuovo modello di precisione da questa opzione.

Mode 1/2 mantengono wire/hidden wire, Mode 3 solidi statici, Mode 4 flat dinamico,
Mode 5 flat dinamico con contorni, Mode 6 Gouraud e Mode 7 texture affini con
l'illuminazione esistente. Gouraud Mode 7 richiede il compositor C.
Gli oggetti condividono il painter a bucket delle facce: Q8 non aggiunge uno
Z-buffer né garantisce occlusione esatta fra solidi che si intersecano.

## Profilo qualificato e rifiuti espliciti

- Mode 1-7; viewport normal, 160 × 100 pixel logici senza split testo/FPS.
- `walkLite`, `high-basic-v2`, `fast`, `extended-table`, selezionati internamente
  dall'adattatore Q8. Opzioni CLI esplicite incompatibili vengono rifiutate.
- Oggetti con intervalli vertici/facce disgiunti; fino a 255 vertici
  runtime totali, raggio compilato scalato <=40 WU per oggetto, 0 < scala <=1.
  Non è una garanzia di capienza: l'allocatore controlla tutti i limiti RAM.
- Niente Ground, meshSourceSharing, timeline scena, viewport small o roll camera.
- Rotazione iniziale camera `[0,0,0]`. Yaw/pitch runtime supportati.
  La camera scena deve essere walkLite: fixed/walkFull sono rifiutati, non approssimati.
- Coordinate finite entro il dominio limitato camera/oggetto +/-4095 WU.
  Questo controllo esterno non amplia il più ristretto dominio signed Q8 delle
  traslazioni X/Y oggetto dell'SDK né le sue regole originali sulla profondità.
- PAL o NTSC selezionati alla build; omettendo lo standard per Q8 si usa PAL.
  `-VideoStandard auto` esplicito viene rifiutato. I default legacy non cambiano.
- Nessun header/overlay FPS, colonna sonora, cambio modalità runtime o ulteriori
  flag diagnostici nel profilo Q8 pubblico. Le combinazioni non supportate
  falliscono, senza ripiegare silenziosamente su legacy.

`fixed` è un diverso percorso di proiezione legacy, non un semplice walkLite fermo.
Le sue tabelle di profondità lontana possono quantizzare visibilmente un cubo.
Per una vista precisa ferma usare Q8 con `-Q8Camera stationary`, non fixed.

## Build e camera

Dipendenze: Python 3, PowerShell 7 e 64tass (`TASS64_EXE` o PATH); serve anche
Pillow usando texture PNG. py65 serve solo per i test opzionali.
Dalla radice SDK compilare in una nuova directory **esterna** all'SDK:

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -Precision q8 -GraphicsMode 4 -SceneFile ../my-inputs/q8/two-objects-mode4.json -Q8Camera auto -VideoStandard pal -OutputDirectory ../q8-mode4-pal
```

Qui vengono scritti `3Dvibe64.prg`, ASM, label, mappa memoria, metadati e copia
di lavoro isolata dell'SDK. Directory output già esistenti vengono rifiutate;
nessuna scrittura nel pacchetto distribuito. Per NTSC usare un'altra directory
e `-VideoStandard ntsc`. Quei nomi identificano input storici esterni: nessun esempio è incluso in questo SDK sorgente. Mantenere `-GraphicsMode` coerente con `graphicsMode` della scena.

| Q8Camera | Comportamento |
|---|---|
| `stationary` (default) | proiezione walkLite con input camera disabilitato; gli oggetti ruotano |
| `interactive` | controlli walkLite ereditati: W/S avanti/indietro, A/D laterale, Q/E giù/su, cursori yaw/pitch; niente roll |
| `auto` | dimostrazione yaw/pitch frazionaria fluida, input disabilitato; periodo di 1.024 tick logici |

Il moto automatico avanza sui tick di simulazione, non sui frame. Conserva il
contratto PAL/NTSC da 50 tick logici; l'accelerazione aumenta il frame rate possibile,
non la velocità di moto prevista. L'input interattivo conserva la ripetizione
angolare legacy: il moto automatico frazionario non implica un nuovo input.

## Architettura e verifiche

Il builder PowerShell pubblico instrada prima della generazione scena legacy.
Q8 lavora nella propria copia output, prepara i dati geometrici qualificati e usa
`work/q8/src/` per generazione/allocazione esatta. La generazione dei kernel
legacy resta invariata salvo scelta esplicita. I file probe di preparazione sono
dipendenze interne, non un ulteriore profilo pubblico di precisione.

Il checkpoint delle famiglie copre 280 pose numeriche, 4.480 vertici, 3.840 facce
clippate, 112 viste CPU primarie e 22 coppie di frame nativi. I test release
aggiungono il confronto fra build pubbliche silenziose e ricompilazioni silenziose
di quella sorgente congelata, default/rifiuti e nuove verifiche runtime.
Vedere [test](TESTING.md) e [note di release](RELEASE-NOTES-1.5.0.md).
Il paragrafo sopra descrive la qualificazione Q8 storica. La release 1.10.0 aggiunge la
[qualificazione di scalabilità](Q8-QUALIFICATION.md) e le [note di versione](RELEASE-NOTES-1.10.0.md).
Gli hash PRG legacy restano invariati. Nessun test hardware o garanzia FPS universale dichiarata.

## Ottimizzazioni e API della1.15.0

Il selettore `-LegacyPlusOptimizations` è distinto da EngineExperiments,dal raster Q8 ibrido e dagli altri backend. Richiede Mode4 legacy-plus nel profilo qualificato; default none. `all` comprende arithmetic,edges,spans,outcodes,convex,integer-edges. Wire e stream sono API ASM esplicite escluse da all,non sostituzioni automatiche; stream richiede outcodes e possesso degli slot nativi. Frozen-lighting è separata e cambia intenzionalmente la risposta alle luci mobili. Il codec di chiavi è un modulo dati facoltativo. L'errore Bresenham a8bit non riduce la precisione geometrica Q4/Q10. La matrice oggetto ordinaria resta Q6; nessuna nuova API di rotazione rigida degli oggetti è implicita.

[Opzioni e profilo](EXACT-RENDER.it.md) · [ABI,materiali,memoria e ripieghi](REUSABLE-RENDER.it.md) · [Stato e supporto](RELEASE-STATUS.it.md). Alcune combinazioni non entrano nei64KB e vengono rifiutate.
