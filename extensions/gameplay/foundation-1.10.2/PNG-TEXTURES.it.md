# Mode 7 — Importazione texture PNG

La conversione PNG avviene solo sull'host; il C64 non decodifica PNG. Installare Pillow con `python -m pip install -r requirements-mode7.txt`. I texel inline non richiedono Pillow.

Una texture può usare `source: "textures/file.png"`, relativo alla directory del JSON della scena, e la lista ordinata obbligatoria `sourceColors: ["#RRGGBB","#RRGGBB","#RRGGBB"]`: Dark, High, Highlight. Questi tre colori RGB distinti sono convertiti esattamente nei codici texel1,2,3. `texturePalette` è separata: tre indici VIC-II0–15 che controllano i colori visualizzati, non i valori RGB dell'immagine sorgente.

## Requisiti rigorosi

- File realmente PNG, esattamente16×16 pixel, un solo frame statico.
- Esattamente tre colori RGB distinti realmente utilizzati, corrispondenti a sourceColors.
- Tutti i pixel completamente opachi (alpha255); nessuna trasparenza.
- Canali al massimo a8 bit; niente PNG16 bit o animati.
- Nessuna quantizzazione, ridimensionamento, filtraggio o approssimazione dei colori automatici.
- source e texels si escludono. Se width/height sono presenti con source, devono essere16.
- I percorsi sono relativi alla scena; spostare gli asset insieme al JSON.

Un'immagine normale di un editor deve quindi essere ridimensionata manualmente a16×16 e ridotta a esattamente tre colori RGB uniformi. Disattivare l'antialiasing ed esportare un PNG opaco senza cambiare gli RGB scelti. Questa preparazione è esterna all'importer. BMP/JPEG non sono sorgenti accettate.

## Coppia completa funzionante

[mode7-cube-png.json](examples/mode7-cube-png.json) usa [textures/bricks.png](examples/textures/bricks.png), con sourceColors `["#542C18","#D06820","#C8C8C8"]`. [mode7-cube-gouraud.json](examples/mode7-cube-gouraud.json) contiene i256 texel inline equivalenti. Entrambi usano repeat[2,2], Gouraud C e la stessa geometria/UV/palette; con gli stessi parametri di build producono PRG byte-identici. I nomi delle scene possono differire senza influire sui dati runtime.

Dopo la conversione, la texture resta una tabella runtime unpacked di256 byte, allineata a pagina. Il PNG non risparmia RAM runtime e non aggiunge decoder. Più texture usate aggiungono pagine; le pagine inutilizzate possono essere omesse. Vedere [formato texture](TEXTURE-GUIDE.it.md) e [parametri build Mode7](MODE7.it.md).
