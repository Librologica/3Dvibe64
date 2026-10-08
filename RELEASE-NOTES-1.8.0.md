# 3Dvibe64 1.8.0 — release notes / note di rilascio

## English

This stable source SDK is promoted from the qualified 1.8.0-rc1, based on the frozen 1.7.0 SDK. Engine sources are byte-identical to that candidate; promotion changes documentation and package identities only. It includes maintained generators, source, examples and public tests. Generated PRGs, native evidence and the private room demo are kept outside the source distribution. No soundtrack is included.

### Changes and defaults

- Mode 7 retains `TextureQuality standard|fast`, perspective mapping, Q8 geometry and compositor C. Optional `TextureLOD gradual` adds a conservative per-face transition from the original texture to a screen-anchored pattern using its statistically dominant pigment and a vivid pigment already present in that texture. The transition spans 16 world units, with defaults 28–44 WU. This is a deliberate sampling approximation, not mipmapping. Uniform textures remain unchanged. All palette/shading conventions remain in force.
- Modes 1, 2 and 5 accept optional `LineRaster hybrid` with `Precision q8`: transformation, projection and clipping retain Q8; the final connected line walker uses additive integer Bresenham after endpoint rounding. This differs from the previous precise raster, which remains available and remains the default.
- Modes 1–7 default to `FramePresentation safe`. Previously, bitmap clearing could begin at raster 241 while the VIC-II still displayed its last rows; the actual bank switch occurs in the following raster IRQ. Waiting beyond raster 252 prevents the observed lower black strip/flicker. `legacy` is available only for historical diagnostics and reference-hash reproduction. Mode 8 has its own presentation protocol and is unchanged.

Geometry defaults to legacy, texture quality to standard and LOD to off. New line/LOD options require the documented Q8 profiles; the inherited object, vertex, camera and RAM limits are not relaxed. The existing fast camera-mobile profile may exhaust memory, even without LOD: a build that exceeds the layout is rejected, not silently reduced.

### Verification and measurements

The public runner works in disposable SDK copies. Frozen expected PRG hashes have not been replaced: historical builds select legacy presentation explicitly. The additional tests exercise assembled code: 3,214 line cases per mode; identical camera/projection arrays in six poses per mode; 25,920 LOD samples across standard none/flat/Gouraud C and fast Gouraud C; and eight presentation configurations with 48 modeled wait cases. Native VICE qualification compares four complete renderer replays in each of 13 configurations: bitmap, Screen RAM and the low four Color RAM bits have zero differences (52 replays). PAL/NTSC, stock timing and Turbo6510 timing are covered by separate presentation traces. Mode 6 also runs on x64sc, xscpu64 and Turbo6510 through the public suite.

Native speed tests use two seconds of warm-up and a 20-second emulated window, counting newly completed views; host elapsed time is not FPS. On the public PAL cube scenes at Turbo6510 64 MHz: Mode 2 precise/hybrid gives 23.70/25.05 FPS; Mode 5 gives 27.00/27.45 FPS. Mode 1 remains refresh-limited despite lower CPU work. A distant cube gives Mode 7 standard 3.10, fast 6.95, fast plus LOD 11.50 FPS. This is a favorable distant-texture test, NOT a general engine speedup or a measurement of the private three-room demo. Median, p95 and worst intervals are provided in the external qualification report.

Real Commodore hardware has not been tested. The native frame comparisons validate assembly execution against a replay of the same renderer; independent line and LOD tests cover their declared numeric contracts. They are not a proof for arbitrary scenes or third-party interrupt handlers. The private room-specific occlusion ordering is not imported into the general SDK.

See [Mode 7 LOD](MODE7-LOD.en.md), [line raster](LINE-RASTER.en.md), [presentation](PRESENTATION.en.md), [testing](TESTING.md), and `PACKAGE-MANIFEST.json` for exact interfaces, restrictions and identities.

## Italiano

Questo SDK sorgente stabile deriva dalla 1.8.0-rc1 qualificata, basata sull'SDK 1.7.0 congelato. I sorgenti dell'engine sono byte-identici alla candidate; la promozione aggiorna soltanto documentazione e identità del pacchetto. Include generatori mantenuti, sorgenti, esempi e test pubblici. PRG generati, evidenze native e demo privata delle stanze rimangono fuori dalla distribuzione sorgente. Non è inclusa alcuna colonna sonora.

### Modifiche e default

- Mode 7 conserva `TextureQuality standard|fast`, mapping prospettico, geometria Q8 e compositor C. L'opzione `TextureLOD gradual` aggiunge una transizione conservativa per faccia dalla texture originale a un retino ancorato allo schermo, usando il pigmento statisticamente dominante e un pigmento più vivo già presente nella texture. La transizione occupa 16 unità mondo, con default 28–44 WU. È un'approssimazione intenzionale del campionamento, non mipmapping. Le texture uniformi restano invariate. Restano valide tutte le convenzioni di palette e shading.
- Mode 1, 2 e 5 accettano `LineRaster hybrid` con `Precision q8`: trasformazione, proiezione e clipping conservano Q8; il tracciamento finale connesso usa Bresenham intero additivo dopo l'arrotondamento degli estremi. Il risultato differisce dal raster preciso precedente, che resta disponibile e predefinito.
- Mode 1–7 usano per default `FramePresentation safe`. Prima, il clear della bitmap poteva partire al raster 241 mentre il VIC-II ne visualizzava ancora le ultime righe; il cambio effettivo di banca avviene nell'IRQ raster successivo. Attendere oltre il raster 252 evita la fascia nera/flickering inferiore osservata. `legacy` rimane solo per diagnostica storica e riproduzione degli hash di riferimento. Mode 8 usa un proprio protocollo di presentazione e non cambia.

La geometria resta legacy per default, la qualità texture standard e il LOD off. Le nuove opzioni linee/LOD richiedono i profili Q8 documentati; non vengono ampliati i limiti ereditati su oggetti, vertici, camera e RAM. Il profilo fast con camera mobile può esaurire la memoria già senza LOD: la build fuori layout viene rifiutata, non ridotta silenziosamente.

### Verifiche e misure

Il runner pubblico lavora in copie SDK temporanee. Non sono stati sostituiti gli hash PRG attesi congelati: le build storiche selezionano esplicitamente la presentazione legacy. I test aggiuntivi eseguono il codice assemblato: 3.214 casi di linea per modalità; array camera/proiezione identici in sei pose per modalità; 25.920 campioni LOD fra standard none/flat/Gouraud C e fast Gouraud C; otto configurazioni di presentazione con 48 casi di attesa modellati. La qualificazione nativa VICE confronta quattro replay completi del renderer in ciascuna di 13 configurazioni: zero differenze in bitmap, Screen RAM e quattro bit bassi della Color RAM (52 replay). PAL/NTSC, timing stock e Turbo6510 sono coperti da trace separati della presentazione. Mode 6 viene inoltre eseguita su x64sc, xscpu64 e Turbo6510 dalla suite pubblica.

Le prove native usano due secondi di riscaldamento e una finestra di 20 secondi emulati, contando nuove viste completate; il tempo host non è FPS. Nelle scene pubbliche con cubi PAL a Turbo6510 64 MHz: Mode 2 precisa/ibrida misura 23,70/25,05 FPS; Mode 5 misura 27,00/27,45 FPS. Mode 1 resta limitata dal refresh pur riducendo il lavoro CPU. Un cubo distante misura Mode 7 standard 3,10, fast 6,95, fast più LOD 11,50 FPS. È una prova favorevole con texture lontane, NON un'accelerazione generale dell'engine né una misura della demo privata delle tre stanze. Mediana, p95 e intervallo peggiore sono nel report esterno di qualificazione.

Non è stato provato hardware Commodore reale. I confronti nativi dei frame verificano l'esecuzione assembly rispetto al replay dello stesso renderer; i test indipendenti delle linee e del LOD coprono i rispettivi contratti numerici. Non costituiscono una prova per scene arbitrarie o handler IRQ di terze parti. L'ordinamento di occlusione specifico delle stanze private non viene importato nell'SDK generale.

Consultare [LOD Mode 7](MODE7-LOD.it.md), [raster linee](LINE-RASTER.it.md), [presentazione](PRESENTATION.it.md), [test](TESTING.md) e `PACKAGE-MANIFEST.json` per interfacce, limiti e identità.
