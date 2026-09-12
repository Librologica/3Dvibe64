# Mode 7 Texture Format Guide

Ogni texture è **16×16**, per righe, unpacked: un byte per texel, 256 byte. Non sono supportate altre dimensioni. Gli interi JSON **1, 2, 3** indicano i codici pixel VIC-II **01, 10, 11**. Non scrivere valori binari letterali o RGB nei texel. **00** è riservato allo sfondo: i texel zero sono respinti, non trasparenti.

A livello scena, `texturePalette: [9,8,1]` assegna gli indici colore VIC-II (0–15) a Dark, High e Highlight, nell'ordine. Sono i tre pigmenti della texture, non colori RGB. Resta il vincolo di palette condivisa nelle celle multicolor. Con none vengono campionati direttamente; flat varia la luce per faccia; Gouraud C modula i pigmenti campionati con l'illuminazione degli shade vertex. Vedere [Mode 7](MODE7.it.md).

## Dichiarazione texture

Scegliere esattamente uno fra `texels` e `source`. Una texture inline completa contiene 256 interi. [mode7-cube-gouraud.json](examples/mode7-cube-gouraud.json) contiene il pattern completo dei mattoni. [mode7-cube-png.json](examples/mode7-cube-png.json) contiene la dichiarazione PNG equivalente:

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

`texture: "diagnostic"` nella mesh fornisce il default. `faceTextures: [null,"second",null]` sovrascrive singole facce, nel loro ordine; null eredita la texture mesh. La lista deve avere tante voci quante sono le facce sorgenti, prima della triangolazione. Vedere la [scena multi-texture completa](examples/mode7-multi-texture.json).

`repeat: [U,V]` ha default [1,1]; ogni valore deve essere 1,2,4,8 o16. Cambia solo la frequenza di campionamento, non i byte della texture. Per UV codificate nei byte u,v, l'indirizzo è:
`((floor(v*repeatV/16)&15)<<4) | (floor(u*repeatU/16)&15)`.
Nearest-neighbor e wrap power-of-two evitano divisioni costose per texel.

## Preparazione pratica

Disegnare un'immagine opaca 16×16 con esattamente tre colori RGB, senza antialiasing. Usare [import PNG](PNG-TEXTURES.it.md), oppure convertire ogni pixel nell'intero1/2/3 tramite una mappa RGB-pigmento esplicita, scorrere le righe dall'alto a sinistra e inserire tutti i256 valori in texels. Nessun resizing/quantizzazione impliciti. Impostare separatamente texturePalette con i colori C64 desiderati.

Restano i limiti affine, tre pigmenti, Q4.4 e nearest-neighbor: niente perspective correction, filtering, trasparenza o texture più grandi. L'illuminazione aggiunge memoria shade/codice e il limite di255 shade vertices dove applicabile; il controllo dei segmenti del builder è definitivo.
