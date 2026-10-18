# 3Dvibe64 1.10.1 — official numeric maintenance / manutenzione numerica ufficiale

Official source SDK, promoted from qualified `1.10.1-rc1`. Promotion changes package identity and documentation only: engine, examples, texture assets and measured PRGs remain byte-identical. Legacy remains default; Q8 and experimental Normalized16 retain their public profile contracts.

The standard source distribution contains builder/backend sources, assembly templates, scene examples and texture PNGs, public tests and measurement tools, complete EN/IT guides and qualification summaries, release notes/changelog, licenses, package metadata and source checksums. It excludes generated PRGs, native captures, raw logs, videos, toolchain binaries and the extraordinary evidence bundle. Historical release documents remain part of the SDK.

## Corrections and qualification

Mode7 Q8 now classifies the complete unsigned48 projection quotient before signed24 reduction and rejects only a common exterior side plane. The reproduced remote plane changes from 8000 nonzero bitmap bytes to zero, without deleting visible border-crossing geometry or distorting affine UVs. Flat-light products saturate before signed-byte interpretation: the 180-degree light vector is `[0,30,127]`. Shared geometric multiplication and original Gouraud emitted instructions remain unchanged.

Also corrected: optional viewport contract/alias handling; effective default/JSON/CLI texture settings while preserving relative PNG paths; native acquisition provenance before capture reuse; mandatory Mode8 input checks under optimized Python; coincident heading 64; package-exact clean test copies excluding `.git`; OS-native assembler label paths; bounded aligned allocator fallback with distinct exhaustion/impossibility results.

Qualified RC evidence: 25/25 final public gates (24 initial passes plus a corrected host-test helper official rerun), four gates from the frozen extracted package, 14 assembled numeric profiles, 12,152 quotient cases, 1,616 exact geometry/UV polygons and 66,048 light products. Mode8 authentic PAL/NTSC capture reuse passes and modified PRGs are refused; 100 assembled coincident-waypoint ticks have zero divergent poses. Ten representative PAL/NTSC rebuilds match the measured PRGs. All source/metadata integrity checks are repeated for the official package. The measured runtime is inherited; no new FPS is inferred from CPU replay.

Native Mode7: 32 before/after builds, 16 identical ordinary first views (both bitmap/screen banks and separately captured Color RAM), eight supplementary moving-camera fit/first-view pairs. Average FPS **3.083834–24.328025**, unchanged in paired measured windows: VICE Turbo6510 ×64 PAL/NTSC, normal viewport, safe presentation, precise lines, filter 0, no SID/music or overlay, warm-up about 2 s, at least 20 emulated seconds. Affine uses an automatic camera; perspective/fast use stationary cameras with rotating objects. Supplementary moving-camera checks do not provide extra FPS. p95/worst, exact paths/options and measured PRG hashes: [original qualification](QUALIFICATION-1.10.1-rc1.en.md). Allocated Q8 payload +119–127 bytes, plus 25 code bytes only for flat light; all qualified supported builds fit with original guards.

## Known limitations and platform scope

Windows is the evaluated build/test host. The Linux label-path fix is present, but actual Linux execution was unavailable and remains unverified. Official status does not imply completed Linux qualification. Run the public suite on a real Linux toolchain before claiming that platform qualified. Raw Windows evidence remains archived separately and is not bundled in the standard SDK.

Mode8 adaptive sampling retains its known visual approximation: the independent fine diagnostic finds 36 bitmap bytes / 138 logical pixels at the supplied pose. Refinement is deferred after measured stock PAL cost: central probe 3.2→2.8 FPS (−12.5%), all-fine 1.05 FPS (−67.1875%). The diagnostic is in the public host regression; the runtime remains unchanged. Retired Q8 coordinate-cache relayout is deferred after measuring 15/18-byte reservations. These limits are distinct from the corrected numeric overflows.

## Italiano

SDK sorgente ufficiale, promosso dalla `1.10.1-rc1` qualificata. La promozione cambia soltanto identità pacchetto e documentazione: engine, esempi, texture e PRG misurati coincidono byte per byte. Legacy resta il default; Q8 e Normalized16 sperimentale mantengono i contratti pubblici.

La distribuzione standard comprende sorgenti builder/backend, template assembly, esempi e PNG texture, test pubblici e strumenti di misura, guide complete EN/IT e sintesi di qualificazione, note/changelog, licenze, metadati e checksum sorgenti. Esclude PRG generati, catture native, log grezzi, video, binari toolchain e pacchetto straordinario di prove. Conserva i documenti delle release storiche.

### Correzioni e qualificazione

Mode7 Q8 classifica il quoziente unsigned48 completo prima della riduzione signed24 e scarta soltanto un semispazio esterno comune. Il piano lontano riprodotto passa da 8000 byte bitmap non nulli a zero, conservando geometria attraversante e UV affine. I prodotti luce flat saturano prima dell’interpretazione signed byte: vettore a 180 gradi `[0,30,127]`. Invariati prodotto geometrico condiviso e istruzioni Gouraud originali.

Corretti anche contract viewport opzionale/alias; impostazioni texture effettive default/JSON/CLI con PNG relativi; provenienza acquisizione prima del riuso nativo; controlli obbligatori Mode8 con Python ottimizzato; heading coincidente 64; copie test identiche al pacchetto senza `.git`; percorsi etichette nativi; fallback allocatore allineato con budget e distinzione esaurimento/impossibilità.

Prove RC: 25/25 gate pubblici finali (24 PASS iniziali più rerun ufficiale del helper host corretto), quattro gate sul pacchetto congelato estratto, 14 profili numerici assemblati, 12.152 casi quoziente, 1.616 poligoni geometry/UV esatti e 66.048 prodotti luce. Riuso autentico Mode8 PAL/NTSC valido e PRG modificati rifiutati; 100 tick assemblati con waypoint coincidente senza divergenze. Dieci rigenerazioni PAL/NTSC rappresentative identiche ai PRG misurati. Controlli integrità sorgente/metadati ripetuti per il pacchetto ufficiale. Runtime misurato ereditato; nessun FPS dedotto da replay CPU.

Mode7 nativo: 32 build prima/dopo, 16 prime viste ordinarie identiche (due banchi bitmap/screen e Color RAM separata), otto coppie supplementari camera mobile per fit/prima vista. FPS medi **3,083834–24,328025**, invariati nelle finestre accoppiate: VICE Turbo6510 ×64 PAL/NTSC, viewport normal, presentazione safe, linee precise, filtro 0, senza SID/musica o overlay, warm-up circa 2 s, misura almeno 20 s emulati. Affine con camera automatica; perspective/fast con camera stazionaria e oggetti rotanti. Le verifiche supplementari non misurano ulteriori FPS. p95/peggiore, percorsi/opzioni e hash PRG: [qualificazione originale](QUALIFICATION-1.10.1-rc1.it.md). Payload Q8 +119–127 byte, più 25 byte codice soltanto per luce flat; tutte le build qualificate supportate entrano con le guardie originali.

### Limiti noti e piattaforme

Windows è l’host valutato per build/test. Correzione percorsi etichette Linux presente, ma esecuzione Linux reale indisponibile e non verificata. Stato ufficiale non implica qualificazione Linux completata: eseguire la suite su toolchain Linux reale prima di dichiararla qualificata. Le prove Windows restano archiviate separatamente e non incluse nel SDK standard.

Mode8 conserva l’approssimazione adattiva nota: diagnostica fine indipendente con 36 byte bitmap / 138 pixel logici alla posa segnalata. Raffinamento rinviato per costo stock PAL: raggio centrale 3,2→2,8 FPS (−12,5%), tutto fine 1,05 FPS (−67,1875%). Diagnostica inclusa nel test host pubblico, runtime invariato. Layout cache coordinate Q8 ritirate rinviato dopo misura di 15/18 byte. Limiti distinti dagli overflow corretti.

Historical releases, the RC tag/archive and frozen demos remain preserved. This preparation creates an official local package/tag; no GitHub upload is performed.
Conservati release storiche, tag/archivio RC e demo congelate. Preparazione del pacchetto/tag ufficiale locale; nessun upload GitHub.
