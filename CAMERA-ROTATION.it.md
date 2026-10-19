# CAMERA ROTATION — 1.15.0

> SDK sorgente stabile1.15.0 pubblicato su GitHub. [Stato e supporto](RELEASE-STATUS.it.md).

`-Precision legacy -LegacyStability rotation` conserva il profilo originale
di rotazione camera più fine. Richiede Mode2, walkLite, normal, high-basic-v2 e
`-NoFpsOverlay`. Legacy-plus ne eredita le trasformazioni ma aggiunge una pipeline
di clipping distinta: rotation da solo non applica le correzioni near plus.

## ABI pubblica della camera frazionaria

Yaw/pitch supportano4096 fasi per giro,0,087890625gradi. Gli storici
`explorer_cam_yaw` / `explorer_cam_pitch` restano i byte alti. I quattro bit alti
di `explorer_cam_yaw_frac` / `explorer_cam_pitch_frac` portano la parte bassa
della fase; gli ultimi quattro bit sono ignorati. In alternativa chiamare
`legacy_camera_set_yaw_phase` o `legacy_camera_set_pitch_phase` con A=byte basso,
Y=byte alto di una fase16bit ciclica. Fornire tutti gli input prima di
`render_frame_begin`; i coefficienti sono preparati una volta per nuova vista.

La tastiera a byte non acquisisce automaticamente passi frazionari. La qualifica
nativa usa un driver esterno che fornisce queste frazioni pubbliche. Il seno
camera ha256 campioni signed Q10 con interpolazione lineare a4bit. Solo i
coefficienti camera sono Q10; matrici oggetto Q6 e coordinate temporanee Q4
rimangono. I prodotti signed arrotondano al più vicino, a metà lontano da zero.
Il dominio relativo è[-1024,1024)WU per asse: controllare `legacy_camera_fault`.

## Cache esatte dei prodotti e dei termini locali

Quando entrano nel pool assemblato, quattro LUT prodotti a tre piani occupano
3072byte, allineate a pagina dopo i buffer esistenti. Sono ricostruite solo se
cambia il valore assoluto del coefficiente. Segno e arrotondamento coincidono
con il prodotto seriale; se non entrano viene compilato il fallback seriale.
Il requisito senza overlay evita il vecchio conflitto col font alto; prevale
la mappa effettiva.

Oggetti consecutivi con la stessa matrice scalata effettiva a nove byte riusano
i termini delle coordinate locali. La validità si azzera a ogni vista. Matrice
e risultati non cambiano e non dipendono dall'identità della scena/oggetto.
Raw geometrico, intersezioni near e raster di rotation restano interi.
Usare [legacy-plus](LEGACY-PLUS.it.md) per il near/schermo Q4 e la qualifica
nativa corrente della cadenza. Dal vecchio profilo di compatibilità non si
deducono garanzie su scene arbitrarie, NTSC o hardware fisico.

```powershell
python -B scripts/test_camera_rotation.py --build ../rotation-build --out ../rotation-numeric.json
```

Il controllo aritmetico sulla build esterna non misura FPS.
[Precisione](PRECISION.it.md) · [Test](TESTING.md)

## Ottimizzazioni e API della1.15.0

Il selettore `-LegacyPlusOptimizations` è distinto da EngineExperiments,dal raster Q8 ibrido e dagli altri backend. Richiede Mode4 legacy-plus nel profilo qualificato; default none. `all` comprende arithmetic,edges,spans,outcodes,convex,integer-edges. Wire e stream sono API ASM esplicite escluse da all,non sostituzioni automatiche; stream richiede outcodes e possesso degli slot nativi. Frozen-lighting è separata e cambia intenzionalmente la risposta alle luci mobili. Il codec di chiavi è un modulo dati facoltativo. L'errore Bresenham a8bit non riduce la precisione geometrica Q4/Q10. La matrice oggetto ordinaria resta Q6; nessuna nuova API di rotazione rigida degli oggetti è implicita.

[Opzioni e profilo](EXACT-RENDER.it.md) · [ABI,materiali,memoria e ripieghi](REUSABLE-RENDER.it.md) · [Stato e supporto](RELEASE-STATUS.it.md). Alcune combinazioni non entrano nei64KB e vengono rifiutate.
