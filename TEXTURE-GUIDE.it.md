> Edizione di sviluppo 1.15.0-dev1; contratti1.14.0 ereditati salvo estensioni esplicite nel [rendering esatto](EXACT-RENDER.it.md).

# Mode 7 Texture Format Guide

## Legacy-plus nella 1.14.0

Mode1–7 plus e Mode7 affine/prospettica sono promosse dalla dev qualificata in questo SDK stabile. Near8, geometria Q4, luce A/B/C e vincoli RAM/camera sono in [LEGACY-PLUS](LEGACY-PLUS.it.md). Il requisito camera-plane `Mode4NearProfile clip` della Mode7 legacy ordinaria sotto non è il profilo plus: plus richiede default/near8/poly. Campionamento texture fast e LOD restano solo Q8. Risultati e regressioni sono nella [qualifica nativa](QUALIFICATION-1.14.0.it.md).

Release stabile 1.14.0: [ottimizzazioni correnti](RENDER-OPTIMIZATIONS.it.md), [input esterni](EXTERNAL-INPUTS.it.md). Tutte le demo, gli esempi e le prove native sono esterni alla distribuzione sorgente.


Contratto sorgente corrente 1.14.0. Il manuale descrive l’exporter ordinario
salvo indicazione esplicita; API delimitate gameplay/configurazione/roll/gruppi
in [GAMEPLAY](GAMEPLAY.it.md). [Indice documentazione](DOCS.md).

1.8.0: il [LOD graduale opzionale](MODE7-LOD.it.md) ricava
pigmento dominante e accento da questi stessi texel runtime e dalla palette
della faccia. Formato, dimensioni, repeat e contratto UV sotto restano invariati.

Ogni texture è **16 × 16**, per righe, unpacked: un byte per texel, 256 byte. Non sono supportate altre dimensioni. Gli interi JSON **1, 2, 3** indicano i codici pixel VIC-II **01, 10, 11**. Non scrivere valori binari letterali o RGB nei texel. **00** è riservato allo sfondo: i texel zero sono respinti, non trasparenti.

A livello scena, `texturePalette: [9,8,1]` assegna gli indici colore VIC-II (0–15) a Dark, High e Highlight, nell'ordine. Sono i tre pigmenti della texture, non colori RGB. Resta il vincolo di palette condivisa nelle celle multicolor. Con none vengono campionati direttamente; flat varia la luce per faccia; Gouraud C modula i pigmenti campionati con l'illuminazione degli shade vertex. Vedere [Mode 7](MODE7.it.md).

## Dichiarazione texture

Scegliere esattamente uno fra `texels` e `source`. Una texture inline completa contiene 256 interi. [mode 7-cube-gouraud.json](EXTERNAL-INPUTS.it.md) contiene il pattern completo dei mattoni. [mode 7-cube-png.json](EXTERNAL-INPUTS.it.md) contiene la dichiarazione PNG equivalente:

```json
{
  "id": "diagnostic",
  "source": "textures/bricks.png",
  "sourceColors": ["#542C18", "#D06820", "#C8C8C8"],
  "repeat": [2, 2]
}
```

Il formato inline usa `"width":16, "height":16, "texels":[...256 interi...]` al posto di source/sourceColors. I puntini sono solo esplicativi: usare un esempio completo fornito come JSON valido. Dichiarare 1–16 texture con nomi univoci; vengono emesse solo le pagine referenziate. Le pagine sono allineate a 256 byte (padding iniziale 0–255); ogni ulteriore texture usata costa 256 byte più piccoli metadati di selezione, senza packing.

## UV, repeat e seam

Le UV sono numeri nello spazio dei texel, **non normalizzate 0–1**. Ogni componente va da 0 a 15.9375 inclusi, con passi esatti di 0.0625 (Q4.4 codificato 0–255). Scegliere `uv` (una coppia [U,V] per vertice della mesh) oppure `faceUV` (una lista di corner [U,V] per faccia), mai entrambi.

Per un quad [0,1,2,3], la lista che copre il quadrato intero è:

```json
"faceUV": [[[0,0],[15.9375,0],[15.9375,15.9375],[0,15.9375]]]
```

Per un triangolo [0,1,2], usare tre coppie, ad esempio [[0,0],[15.9375,0],[0,15.9375]]. Ogni lista deve corrispondere al numero di corner della faccia. Le UV per corner permettono coordinate diverse sui due lati di un vertice/edge geometrico condiviso: usarle alle seam. La triangolazione quad 0→2 conserva questi attributi.

`texture: "diagnostic"` nella mesh fornisce il default. `faceTextures: [null,"second",null]` sovrascrive singole facce, nel loro ordine; null eredita la texture mesh. La lista deve avere tante voci quante sono le facce sorgenti, prima della triangolazione. Vedere la [scena multi-texture completa](EXTERNAL-INPUTS.it.md).

`repeat: [U,V]` ha default [1,1]; ogni valore deve essere 1,2,4,8 o 16. Cambia solo la frequenza di campionamento, non i byte della texture. Per UV codificate nei byte u,v, l'indirizzo è:
`((floor(v*repeatV/16)&15)<<4) | (floor(u*repeatU/16)&15)`.
Nearest-neighbor e wrap power-of-two evitano divisioni costose per texel.

## Preparazione pratica

Disegnare un'immagine opaca 16 × 16 con esattamente tre colori RGB, senza antialiasing. Usare [import PNG](PNG-TEXTURES.it.md), oppure convertire ogni pixel nell'intero 1/2/3 tramite una mappa RGB-pigmento esplicita, scorrere le righe dall'alto a sinistra e inserire tutti i 256 valori in texels. Nessun resizing/quantizzazione impliciti. Impostare separatamente texturePalette con i colori C64 desiderati.

Il default resta affine. Il sampling prospettico opzionale usa gli stessi tre pigmenti, Q4.4 e nearest-neighbor: vedere [precisione texture](TEXTURE-PRECISION.it.md). Niente filtering, trasparenza o texture più grandi. L'illuminazione aggiunge memoria shade/codice e il limite di 255 shade vertices dove applicabile; il controllo dei segmenti del builder è definitivo.
