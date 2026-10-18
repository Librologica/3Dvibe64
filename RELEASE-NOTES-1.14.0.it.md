# Note di rilascio — 1.14.0

SDK sorgente stabile dell'engine promosso dalla dev qualificata `1.14.0-dev1`. Legacy-plus supporta ora **Mode1–7**, comprese texture Mode7 affini e prospettiche con luce none, flat e Gouraud A/B/C. Legacy resta il default; `-Precision legacy-plus` richiede una scelta esplicita. Pubblicata come distribuzione sorgente GitHub stabile1.14.0.

## Novità rispetto alla 1.13.0

- Esteso il precedente profilo plus solo Mode2 agli spigoli sorgente Mode1, solidi statici/dinamici Mode3–5, Gouraud Mode6 e texture Mode7.
- Conservate geometria camera Q4, coefficienti camera Q10 e4096 fasi yaw/pitch; nessun backend geometrico Q8 di trasformazione, proiezione o clipping collegato in plus.
- Geometria, UV e luce attraversano near/schermo con interpolazione e arrotondamento coerenti. Conservate proprietà degli spigoli originali e convenzioni Y di ciascun raster.
- Aggiunti carrier prospettici UW/VW/W delimitati, DDA/campionamento esatti e gestione degli span half-open vuoti. Helper Gouraud Mode7 nella RAM realmente libera, con guardie assembly.
- Aggiornati catalogo completo IT/EN, matrici precisione/supporto, istruzioni build, qualifica e metadati. I rapporti delle versioni precedenti restano storici.

La promozione non modifica alcun file implementativo/configurativo runtime in `work/` o `extensions/`: runtime, opzioni e default coincidono con la dev qualificata. I programmi di controllo legacy/Q8 e il precedente riferimento plus Mode2 conservano i byte qualificati. Controlli sorgenti e manifest descrivono il pacchetto consegnato, correggendo i metadati ereditati dalla pubblicazione1.13.

## Profilo plus supportato e compilazione

**walkLite, normal160×100, high-basic-v2, -NoFpsOverlay, clipping poligonale near8/schermo**. L'ABI pubblico delle posizioni ha8 bit frazionari, ma la geometria interna plus è Q4. Le fasi fini yaw/pitch vanno impostate con i campi/helper documentati. Le matrici oggetto restano legacy Q6. Coordinate relative camera in `[-1024,1024)`WU per asse; controllare `legacy_camera_fault`.

Mode7 prospettica richiede profondità camera **8–256WU incluse**, `TextureQuality standard`, LOD off. `ps_fault` è persistente; profondità/denominatore invalidi fermano la presentazione con bordo rosso, senza fallback affine. Fixed/walkFull, viewport small, roll, split testo/FPS e Ground plane sono fuori contratto plus. La capacità dipende dalla mappa assembly effettiva, senza garanzia universale sulle dimensioni delle scene. Mode8 e Normalized16 mantengono contratti separati.

Installare esternamente Python3, PowerShell7 e64tass; impostare `TASS64_EXE` se necessario. Pillow serve per importare PNG. Copiare **tutto l'SDK** in una cartella sorella nuova e fornire scena/asset esterni propri:

```powershell
Copy-Item -LiteralPath . -Destination ../my-build-sdk -Recurse
pwsh -NoProfile -File ../my-build-sdk/work/build-3Dvibe64.ps1 -SceneFile ../my-inputs/scene7.json -Precision legacy-plus -GraphicsMode 7 -TexturePrecision perspective -CameraMode walkLite -CameraViewport normal -MemoryLayout high-basic-v2 -Quality fast -Projection extended-table -VideoStandard pal -FramePresentation safe -NoFpsOverlay -SkipCmdUpdate
```

La scena deve dichiarare `graphicsMode:7` e camera walkLite compatibili. Plus seleziona i default near/poly. Usare `-TexturePrecision affine` per Mode7 affine; omettere la precisione texture in Mode1–6. Legacy/plus ordinari scrivono ASM/PRG nel `work/` della copia e rifiutano `-OutputDirectory`. Q8/Normalized16/Mode8 hanno adapter di output esterno separati. Label/mappe diagnostiche richiedono una chiamata assembler esplicita. Vedere [contratto plus](LEGACY-PLUS.it.md), [ABI camera](CAMERA-ROTATION.it.md), [input esterni](EXTERNAL-INPUTS.it.md) e [limiti adapter](ADAPTER-SUPPORT.it.md).

## FPS nativi e stabilità

Risultati riutilizzati soltanto per programmi ricompilati identici nei byte dai sorgenti runtime stabili. **VICE Turbo6510 MOS8565, PAL×64, safe, Colodore/filter0, silenzioso**, normal160×100. Warm-up128 eventi di simulazione, circa2,56–2,70 secondi emulati; poi percorso completo camera/clipping di2048 tick, circa40,8 secondi emulati. Contate soltanto nuove viste complete: trace di presentazione e contatore nativo concordano. Warp e tempo host esclusi. Nessuna fase stazionaria; il clipping include fasi vuote/interamente tagliate. Il JSON conserva hash, comandi esatti, durata, contatori, p95/peggiore e finestre individuali.

| Fixture / modalità | Legacy FPS camera / clip | Plus FPS camera / clip | Q8 FPS camera / clip |
|---|---:|---:|---:|
|Toroide48 vertici / Mode1|50,125 / 50,125|50,125 / 50,125|16,708 / 50,125|
|Toroide48 vertici / Mode2|50,125 / 41,093|49,072 / 41,191|12,531 / 37,177|
|Toroide48 vertici / Mode3|50,125 / 46,802|50,125 / 47,609|21,401 / 47,016|
|Toroide48 vertici / Mode4|50,125 / 46,802|25,331 / 47,536|16,708 / 46,894|
|Toroide48 vertici / Mode5|25,062 / 46,092|25,062 / 47,047|16,708 / 41,314|
|Toroide48 vertici / Mode6|25,062 / 34,877|25,062 / 35,440|16,708 / 34,845|
|Toroide48 vertici / Mode7 affine|12,531 / 30,310|12,531 / 31,891|7,196 / 29,904|
|Toroide inclinato24 vertici / Mode7 prospettica|16,708 / 30,310 (affine)|5,834 / 26,417|3,948 / 25,307|

Il toroide è la fixture camera; il clipping usa triangoli adiacenti a doppia faccia. I volumi near differiscono: plus8WU, Q8 1WU, legacy secondo modalità. Gli FPS clipping sono quindi controlli contestuali, non tempi backend a volume identico. Plus affine sulla fixture24 vertici misura16,480/31,891FPS. p95/peggiore plus prospettica: camera179,553/199,503ms, clipping219,453/758,112ms. La camera Mode4 regredisce rispetto a legacy. La fixture prospettica con luce flat è più lenta di Q8:6,780 contro8,273FPS. Tutte le otto varianti illuminate plus e gli intervalli di ogni modalità sono nella [qualifica](QUALIFICATION-1.14.0.it.md).

Nelle pose native promosse non risultano discordanza dei buffer congelati, disaccordo dei vertici condivisi, scomparse inattese o residui dietro il near. Trentadue serie da36 pose comprendono yaw completo e pitch−45°/0°/+45°. Sul piano UV prospettico212.505 campioni interni robusti hanno zero texel errati/mancanti rispetto all'oracolo indipendente. Restano quantizzazione Q4/Q2, nearest e limiti del painter; i test non provano la correttezza di scene arbitrarie. Nessuna nuova qualifica NTSC, Linux, musica attiva o hardware fisico.

## Distribuzione e confine del port privato

Lo ZIP sorgenti contiene engine/build, moduli gameplay riutilizzabili delimitati, controlli sintetici, documentazione, licenze e manifest. **Nessuna demo o esempio**, progetto scena/camera, personaggio, UI, artwork, SID/audio/video, PRG/disco compilato, emulatore, ambiente dipendenze o cattura grezza. I template assembly e il font implementativo dell'engine restano input sorgenti riutilizzabili. Input di test e prove grezze restano nelle cartelle di qualifica private separate.

L'ultimo lavoro Underworld resta un port applicativo. Viewport96×60, loader/layout RAM bancato, correzione del culling, specializzazioni materiali/LOD e ottimizzazioni UV accoppiate/divisore **non sono promossi nell'SDK generico**. I5,247413FPS privati e il recupero del22,5% non descrivono l'engine pubblico. Gli adapter gameplay restano delimitati e orientati Q8; supportare plus ordinaria non li rende direttamente compatibili. Generalizzarli richiede qualifica specifica di tutte le modalità, shader e RAM. Nessun generatore o asset Underworld incluso.

Eseguire `python -B scripts/run_release_tests.py` da un'estrazione pulita, con dipendenze installate. I controlli usano copie temporanee e verificano link IT/EN, versioni e contratti del pacchetto corrente. Vedere [test](TESTING.md) e [qualifica strutturata](QUALIFICATION-1.14.0.json). Cartelle release/dev precedenti, tag/asset e demo congelate restano intatti; questa pubblicazione crea soltanto il nuovo tag/release v1.14.0.

Software: PolyForm Noncommercial1.0.0. Documentazione: CC BY-NC4.0. Attribuzione: librologica.digital.
