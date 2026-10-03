# Precisione texture Mode 7 — 1.6.0

## Default e selezione esplicita

**La geometria resta `legacy` e le texture restano `affine` per default.** Nessuna
selezione automatica dipende dalla frequenza CPU. Scene/comandi precedenti
conservano l'output di riferimento. `-Precision q8` migliora la geometria, non la
prospettiva delle texture da solo. Consigliamo Q8 sopra 20 MHz e legacy fino a 20
MHz inclusi: non è una garanzia FPS. Le texture prospettiche costano molto anche
su CPU accelerate.

Selezionare `"texturePrecision":"perspective"` nella scena oppure
`-TexturePrecision perspective`, insieme a `-Precision q8 -GraphicsMode 7`.
Un'opzione CLI esplicita prevale sul campo scena. Affine/perspective non cambiano
formato texture, import PNG, repeat, palette o modello di illuminazione.

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -Precision q8 -GraphicsMode 7 -TexturePrecision perspective -SceneFile examples/mode7-perspective-cube.json -Q8Camera stationary -VideoStandard pal -OutputDirectory ../perspective-cube-pal
```

Scegliere una nuova directory esterna all'SDK. PRG, label, ASM, mappa memoria e
metadati build vengono scritti lì. Non distribuiamo PRG, demo di produzione o
musica. L'esempio deriva dal cubo diagnostico pubblico, non dalla scena di sviluppo.

## Profilo supportato

Restano tutti i vincoli Q8: viewport normal 160×100 logici senza split header/FPS;
walkLite stationary/interactive/auto; PAL/NTSC esplicito; uno o due oggetti con
geometria non condivisa; massimo 96 vertici; raggio scalato <=40 WU per oggetto;
scala>0 e<=1; niente Ground, timeline, small o roll della camera. L'allocatore
può respingere la scena prima dei limiti geometrici. Vedere [Q8](PRECISION.it.md).

Dominio aggiuntivo dei carrier prospettici: profondità lungo l'asse della camera
**1–256 WU inclusi**, dopo il near clipping. Non è distanza euclidea né garanzia
di dimensione della scena. Il movimento interattivo/automatico deve restare nel
dominio. `ps_fault` è persistente: profondità o denominatore non validi impediscono
la pubblicazione del frame e fermano il rendering con bordo rosso. Riposizionare/
ricompilare; non è un fallback prospettico→affine. La validazione host non può
dimostrare tutte le future pose interattive. Combinazioni CLI non supportate sono
respinte, mai sostituite silenziosamente.

`none`, `flat` e `gouraud` mantengono i percorsi luminosi dinamici dell'engine.
Gouraud textured richiede C; normali, creaseAngle, reflectivity e 33 livelli restano
invariati. Non viene aggiunta illuminazione precalcolata o legata alla camera.

## Architettura numerica

Il near clipping trasporta UV grezze Q4.4 con 8 bit frazionari aggiuntivi. Per
profondità camera Q16.8, W=floor(8388608/depthQ8). Ogni carrier attributo vale
floor(rawUV16*W/32768), unsigned 16; anche W è unsigned 16. Lo screen clipping
interpola UW/VW/W con il parametro geometrico. DDA edge/span con quoziente e
resto euclidei esatti avanzano i carrier. La coordinata campionata è
floor(carrier*128/W); il byte basso alimenta il sampler repeat esistente.
Q Gouraud conserva la DDA screen-space precedente.

È interpolazione prospettica di **carrier quantizzati**, non precisione infinita
o equivalenza bit-exact alla geometria reale continua. Restano arrotondamenti
reciproco/carrier/Q2 e aliasing nearest-neighbor. Si elimina l'interpolazione
interna deliberatamente affine; non si garantisce errore texel nullo contro un
oracolo floating-point, né si aumenta risoluzione o precisione UV sorgente.

## Ottimizzazioni esatte

- Setup span signed con divisione restoring 16/8 e arrotondamento euclideo.
- Divisione 48/24 di proiezione/clipping senza bit iniziali nulli, quoziente/resto
  invariati. Prodotto clipping 16×16 protetto, con percorso 24×24 completo.
- Encoding al near plane 1 WU ridotto all'identità esatta. FIFO di 8 elementi per
  profondità frazionaria completa e reciproco esatto, non fasce arrotondate.
  Costa 34 byte di stato per PRG e opera solo nel thread principale.
- Span senza luce con ricorrenza razionale esatta protetta: W 256..8191, step
  interi carrier±32, larghezza>=8. Divisione esatta per ogni caso non supportato.
  Niente blocchi approssimati o tolleranze numeriche allargate.
- Il builder riconosce pagine texture uniformi emesse, anche da PNG: salta
  sampling/advance/setup UV, conservando DDA luminosità, fetch, maschere e immagine.

Tutte le specializzazioni sono isolate compile-time nella Mode 7 prospettica.
Restano packer a quattro pixel e byte parziali. Nessun guadagno universale:
scene con molti fallback possono essere più lente. Reciproco, array scanline
UW/VW/W, clipping e routine richiedono RAM aggiuntiva; `build.json` riporta
dimensioni e posizioni reali. Nessuna banca, buffer video o guardia viene sottratta
per far entrare una scena.

## Esclusioni deliberate

Niente correzione approssimata a quattro pixel, portal culling delle due stanze,
painter specifico, luce precalcolata o geometria/viewport della demo. Niente
Z-buffer, portali/PVS generali, bilinear, mipmapping, trasparenza, texture runtime
packed o quad mapper nativo. Diagonale quad 0→2 invariata. Affine conserva le
camere/viewport legacy più ampie. [Test](TESTING.md) separa aritmetica CPU,
verifiche native e hardware: i cicli sintetici non sono FPS misurati.
