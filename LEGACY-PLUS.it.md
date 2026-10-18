# Legacy-plus — 1.13.0

`-Precision legacy-plus` seleziona il renderer intermedio delimitato Mode2.
Legacy resta il default; Q8, Normalized16, Mode8 e il percorso di compatibilità
`-LegacyStability rotation` mantengono i propri contratti. Legacy-plus non è un
alias di rotation: ne eredita le trasformazioni e aggiunge clipping wire corretto,
geometria near/schermo Q4 e ottimizzazione della cadenza camera dev7. Non introduce
il backend Q8 né aumenta la risoluzione visibile.

## Build e configurazione supportata

```powershell
Copy-Item -LiteralPath . -Destination ../my-build-sdk -Recurse
pwsh -NoProfile -File ../my-build-sdk/work/build-3Dvibe64.ps1 -SceneFile ../my-inputs/scene.json -Precision legacy-plus -GraphicsMode 2 -CameraMode walkLite -CameraViewport normal -MemoryLayout high-basic-v2 -Quality fast -Projection extended-table -VideoStandard pal -FramePresentation safe -NoFpsOverlay -ExplorerClipMode near -ExplorerNearCrossMode poly -MinFaceAreaOverride 0 -ScreenMinSpanOverride 0
```

La scena deve essere esterna e dichiarare input Mode2/walkLite compatibili.
Copiare prima l'intero SDK in una cartella di lavoro sorella nuova. Il builder
legacy/plus ordinario scrive ASM/label/mappa/PRG nel suo `work/`, con copia PRG
in `work/build/`. Rifiuta `-OutputDirectory`: il parametro appartiene ai rami
Q8, Normalized16 e Mode8, non al legacy ordinario. Nessuna scena, demo, percorso,
launcher o programma compilato è distribuito. Python3, PowerShell7 e64tass sono
dipendenze esterne; `TASS64_EXE` può selezionare l'assembler.

Il selettore richiede Mode2, walkLite, normal160×100, high-basic-v2 e
`-NoFpsOverlay`; le combinazioni incompatibili vengono rifiutate. Non combinarlo
con un LegacyStability esplicito in conflitto. Area/span0 sono impostazioni
esplicite del benchmark, non nuovi default di qualità. Il nuovo near richiede
near-poly ordinario, camera-plane profile0 e world-ground-plane clipping0. La
qualifica nativa non usa Ground. Le altre selezioni clipping mantengono il
percorso ereditato e non acquisiscono la nuova precisione near. Anche screen-poly
predefinito attiva internamente near-poly. Le opzioni esplicite
`-ExplorerClipMode near -ExplorerNearCrossMode poly` riproducono la selezione
della qualifica documentata.

## Aritmetica e input camera

Le matrici oggetto restano Q6. Posizioni e coordinate temporanee camera conservano
Q4; i coefficienti di rotazione camera sono Q10 con4096 fasi angolari. Il raster
finale è intero. Le coordinate relative camera devono restare in[-1024,1024)WU
per asse: controllare `legacy_camera_fault` e la mappa memoria assemblata reale.

L'ABI frazionaria è descritta nelle [rotazioni camera](CAMERA-ROTATION.it.md):
preparare posizioni/yaw/pitch prima di `render_frame_begin`. La tastiera mantiene
i gradini angolari a byte ereditati; selezionare plus non rende frazionario un
input che fornisce solo byte. Il driver automatico di qualifica usa gli input
pubblici frazionari ed è esterno all'SDK. Non aumenta la precisione delle rotazioni
oggetto.

Classificazione e intersezioni near leggono una cache Q4 separata,6byte per
vertice, conservando i buffer geometrici interi originali. Near8WU corrisponde
a128 unità Q4. I flag degli spigoli sorgente sono conservati: non vengono
inventate chiusure wire. Le intersezioni usano pesi razionali più precisi;
le coordinate proiettate restano Q4 fino al clipping schermo, poi diventano
pixel. I limiti temporanei vengono ripristinati dopo ogni faccia. Offset
pari/superiori a$3a00 attivano il fallback intero ampio ereditato, mantenendo
le differenze signed sotto32768. Guardie assembly impediscono sovrapposizioni
helper/cache con l'IO. Le trasformazioni possono usare una LUT prodotti da3072byte
se entra nel pool runtime, altrimenti il prodotto seriale. La capienza dipende
dalla mappa effettiva, non da un numero di vertici promesso.

L'ottimizzazione dev7 espande i quattro shift signed dell'arrotondamento Q4.
Somma, risultati e stato finale registri/flag restano identici;21 byte PRG
sostituiscono il controllo del ciclo. Raster, presentazione safe e driver input
restano invariati.

## Qualifica nativa e limiti

VICE Turbo6510 MOS8565 PAL ×64, safe, Colodore/filtro0, silenzioso. Dopo128 eventi
di simulazione di warm-up, ogni caso in movimento misura un giro completo2048tick,
circa41secondi emulati. Si contano solo nuovi buffer completi; tempo host, warp
e replay CPU non sono FPS. Le build della release finale devono coincidere con
gli hash PRG dev7 misurati prima di riutilizzare questi dati.

| Caso | Legacy | Plus dev6 | Plus1.13.0/dev7 | Q8 |
|---|---:|---:|---:|---:|
| Camera FPS |25.06227|25.05004|25.06227|4.86338|
| Clipping FPS |41.09331|41.19121|41.19121|37.17733|

Il massimo intervallo camera è39,9006ms, prima59,8509ms; p95 è39,9006ms.
Clipping p95/peggiore sono39,9006ms. Una seconda traccia nativa e un offset
controllato di un tick nella traiettoria confermano il risultato camera.
Tutte le658 immagini native plus coincidono con dev6:158 camera,368 clipping,
114 attraversamenti densi,12 casi near esatto/±1/16/proiezione ampia e6 pose del
toroide vicino al near. Le pose ferme verificano geometria/buffer, non i loro
FPS. Nessuna scomparsa inattesa, residuo senza spigoli sorgente, divergenza di
vertici condivisi o instabilità buffer osservata rimane nei test. Q4 finito,
raster intero e fallback ampio non promettono equivalenza pixel-esatta float/Q8
o un budget universale per frame. Altre scene, modalità, NTSC e hardware fisico
non ricevono una nuova qualifica da questa release.

[Qualificazione](QUALIFICATION-1.13.0.it.md) ·
[Aggregati leggibili dagli strumenti](QUALIFICATION-1.13.0.json) ·
[Test](TESTING.md) · [Precisione](PRECISION.it.md)
