# GraphicsMode 8 — 2.5D

3Dvibe64 1.4.0 aggiunge all'SDK un renderer indipendente per mappe. Per costruire ambienti partire da [Costruire mappe Mode 8](MAPS-2.5D.it.md). Il sottoinsieme è deliberatamente conservativo: tre template completi, validazione per proprietà, partenze fisse e rampe/aperture limitate. Non sono disponibili conversione di mesh o composizione simultanea poligonale/2.5D.

## Build pubblica

Dipendenze minime: PowerShell, libreria standard Python 3.10+ e 64tass. Toolchain qualificata: Python 3.13.14, PowerShell 7.6.5, 64tass 1.60.3243. Usare PATH oppure `PYTHON_EXE` e `TASS64_EXE`; `TASS64_PATH` accetta anche una directory dell'assembler. VICE, Pillow e py65 **non** servono alla normale build.

Dalla radice dell'SDK:

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile examples/mode8/perimeter.json -Mode8Run interactive -OutputDirectory ../perimeter-reference-build
```

Il builder indica backend scelto e motivo, prima di applicare parser poligonali. Produce `3Dvibe64.prg`, `3Dvibe64.asm` leggibile, label, listing, log assembler, scena e riepilogo build/memoria. `-ValidateOnly` valida senza assemblare o creare output.

| Opzione | Contratto Mode 8 |
|---|---|
| `-GraphicsMode 8` | Selezione intera, mai 2.5 |
| `-SceneFile` | JSON Mode 8 esplicito obbligatorio |
| `-Mode8Run interactive/auto` | Default interactive; auto segue il percorso ciclico |
| `-OutputDirectory` | Cartella esterna nuova e vuota; default `3Dvibe64-output/mode8` accanto all'SDK |
| `-ValidateOnly` | Validazione completa mappa/percorso; niente output o assembler |
| `-VideoStandard auto` | Rilevamento runtime PAL/NTSC; pal/ntsc espliciti rifiutati |
| Altre opzioni poligonali | Rifiutate se richieste esplicitamente; i loro default storici non influiscono |

Sono comprese `CameraMode`, `CameraViewport`, `Quality`, `MemoryLayout`, `HeaderText`, opzioni luce/materiali e `SkipCmdUpdate`: non sono controlli Mode 8. Le tre nuove opzioni sono rifiutate nelle Mode 1–7. Comandi/default legacy e hash PRG di riferimento restano invariati.

## Renderer e organizzazione dei sorgenti

`work/mode8/build.py` valida la geometria esplicita e istanzia i template qualificati in `work/mode8/asm`. Sono **sorgenti intenzionali**, non dipendenze da vecchie directory di output. Layout automatico e interattivo restano separati per non rilocare istruzioni runtime qualificate. Sulle mappe originali il confronto dei byte circoscrive la rimozione richiesta e la UI; codice geometrico/raster e indirizzi restano invariati.

La scelta dipende dai dati: rampe o più quote pavimento nelle celle libere selezionano l'heightfield multi; altrimenti si verifica l'intero contratto mono, comprese le restrizioni sui volumi superiori. Nessun fallback silenzioso. Le due implementazioni non vengono unificate.

Pipeline comune:

1. IRQ accumula tick logici e aggiorna l'interfaccia testuale.
2. Il foreground consuma i tick: input, simulazione, collisioni e inseguimento automatico.
3. Acquisisce una sola posa camera per tutta la nuova immagine.
4. Il DDA individua le superfici; il raffinamento adattivo risolve le discontinuità.
5. Proietta i profili, ritaglia gli intervalli visibili e riempie bande bitmap multicolor.
6. Segnala il buffer inattivo completo; l'IRQ lo pubblica al confine sicuro.

PAL usa il tick video; NTSC mantiene la cadenza 5/6, circa 50 tick logici/s. **Non significa rendering continuo a 50 FPS**. La camera acquisita non cambia a metà disegno. Un frame lungo produce latenza visibile anche se la velocità media del movimento resta basata sui tick. Nessun cap FPS artificiale o conteggio di viste parziali/colonne alternate.

Mono: 32 raggi principali, endpoint basati su owner/piano e campioni fini aggiuntivi dove necessari. Le aperture continuano nello stesso DDA attraverso il volume superiore ammesso. Multi: 33 raggi di confine per 32 gruppi bitmap; percorsi evento differenti richiedono quattro raggi fini. Gli eventi ordinati ritagliano da vicino a lontano l'intervallo verticale ancora visibile. Restano attivi 32 profili in cache, blocchi lazy da16colonne e specializzazioni aritmetiche esatte.

Non vengono eseguiti fill di triangoli, trasformazioni di mesh, normali, Gouraud, sampling UV attivo delle pareti o luce dinamica. I pigmenti dipendono dall'orientamento; il soffitto usa un retino ancorato allo schermo. I nomi storici `TEXTURED`, `strip`, `depth` restano dove utili al confronto: non indicano texture UV correnti o uno z-buffer completo per composizione. `select_strips` prepara oggi proiezioni e limiti geometrici. I vecchi commenti sul renderer a caratteri non sono la specifica video corrente.

## Video e memoria

- Bitmap multicolor VIC-II, **128×144 pixel logici**, ciascuno 2×1 pixel fisici.
- Viewport fisica256×144; 32×18celle bitmap; **4.608byte attivi per buffer**.
- Bitmap `$6000/$E000`, origini attive `$6660/$E660`.
- Screen RAM `$4000/$CC00`, font separato `$5800/$D800`, UI di tre righe.
- Banking CPU/VIC tramite `$01`, `$DD00`, `$D018` e handler split PAL/NTSC qualificati.
- Inizializzazione e confronti includono i margini pertinenti; il confronto del corpo completo comprende7.040byte, non la dimensione del clear attivo per frame.
- I template conservano guardie layout/puntatori sprite e SMC privato del foreground. L'IRQ non deve riutilizzarne lo scratch; runtime non rientrante.
- Cache multi4.096byte, coefficienti/stato448byte, buffer fine144byte attivi/256riservati.
- Margine low delle mappe originali automatiche157/140/76byte: perimetro/aperture/due-livelli. Helper multi192byte a `$5500`. La dimensione PRG comprende intervalli riservati, non coincide con RAM utilizzata.

Vedere [mappa memoria](MODE8-MEMORY.md) e `build.json`. Dati aggiuntivi devono rispettare le capacità esistenti. Non si riloca, riduce la risoluzione o abbassa la precisione per accettare una scena. C64 stock64KB, istruzioni6510 documentate, senza REU o accelerazione.

## Controlli, limiti e qualificazione

Interattiva: W/S movimento, A/D rotazione. Automatica: itinerario ciclico completo validato. Stessa partenza del template. UI/FPS contano immagini complete. Questo primo contratto non espone override per palette, FOV, viewport o camera iniziale arbitraria.

Solo aperture statiche e formule di rampa previste; niente room-over-room, gradini arbitrari, PVS, traversal avanzato a portali, texture UV delle pareti, texture pavimento, luce dinamica o sprite3D. Le Mode1–7 conservano build poligonali distinte.

[TESTING.md](TESTING.md) distingue13script legacy, nuovi test pubblici delle mappe, confronti istruzioni/oracolo e prove native. Le [note release](RELEASE-NOTES-1.4.0.md) contengono FPS finali, p95 e worst misurati. Il campionamento CPU non viene convertito in FPS. Hardware reale **non testato**: qualificazione stock x64sc PAL/NTSC, non sostituibile con risultati accelerati o di altre macchine.

Per la prova hardware: trasferire il PRG interattivo su C64 stockPAL/NTSC, caricarlo/avviarlo, attraversare la scena e i raccordi delle due rampe, verificare split e presentazione, poi eseguire un giro automatico completo. Registrare modello, standard video, loader ed eventuali difetti. Non dichiarare PASS hardware senza esecuzione e registrazione effettive.

## Analisi opzionale

`scripts/analyze_mode8.py` usa py65 e Pillow per un atlante dei cicli istruzione; `scripts/qualify_mode8.py` usa `VICE_X64SC` o x64sc nel PATH per catture native. Entrambi scrivono fuori dall'SDK e non strumentano il runtime distribuito. Istruzioni e limiti nella [guida mappe](MAPS-2.5D.it.md#7-atlante-opzionale-dei-costi).

Nota storica: la ricerca è iniziata con un compositore a caratteri a risoluzione ridotta e ha sperimentato altre architetture geometriche/grafiche. Gli archivi non fanno parte dell'SDK. Si promuove il bitmap con backend mono/multi distinti; nessun precedente target prestazionale torna come gate di rilascio.
