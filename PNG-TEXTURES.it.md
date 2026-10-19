# Mode 7 — Importazione texture PNG — 1.15.0

> SDK sorgente stabile1.15.0 pubblicato su GitHub. [Stato e supporto](RELEASE-STATUS.it.md).

Release stabile 1.15.0: [ottimizzazioni correnti](RENDER-OPTIMIZATIONS.it.md), [input esterni](EXTERNAL-INPUTS.it.md). Tutte le demo, gli esempi e le prove native sono esterni alla distribuzione sorgente.


Contratto sorgente corrente 1.14.0. Il manuale descrive l’exporter ordinario
salvo indicazione esplicita; API delimitate gameplay/configurazione/roll/gruppi
in [GAMEPLAY](GAMEPLAY.it.md). [Indice documentazione](DOCS.md).

La conversione PNG avviene solo sull'host; il C64 non decodifica PNG. Installare Pillow con `python -m pip install -r requirements-mode7.txt`. I texel inline non richiedono Pillow.

Una texture può usare `source: "textures/file.png"`, relativo alla directory del JSON della scena, e la lista ordinata obbligatoria `sourceColors: ["#RRGGBB","#RRGGBB","#RRGGBB"]`: Dark, High, Highlight. Questi tre colori RGB distinti sono convertiti esattamente nei codici texel 1,2,3. `texturePalette` è separata: tre indici VIC-II 0–15 che controllano i colori visualizzati, non i valori RGB dell'immagine sorgente.

## Requisiti rigorosi

- File realmente PNG, esattamente 16 × 16 pixel, un solo frame statico.
- Esattamente tre colori RGB distinti realmente utilizzati, corrispondenti a sourceColors.
- Tutti i pixel completamente opachi (alpha 255); nessuna trasparenza.
- Canali al massimo a 8 bit; niente PNG 16 bit o animati.
- Nessuna quantizzazione, ridimensionamento, filtraggio o approssimazione dei colori automatici.
- source e texels si escludono. Se width/height sono presenti con source, devono essere 16.
- I percorsi sono relativi alla scena; spostare gli asset insieme al JSON.

Un'immagine normale di un editor deve quindi essere ridimensionata manualmente a 16 × 16 e ridotta a esattamente tre colori RGB uniformi. Disattivare l'antialiasing ed esportare un PNG opaco senza cambiare gli RGB scelti. Questa preparazione è esterna all'importer. BMP/JPEG non sono sorgenti accettate.

## Coppia completa funzionante

[mode 7-cube-png.json](EXTERNAL-INPUTS.it.md) usa [textures/bricks.png](EXTERNAL-INPUTS.it.md), con sourceColors `["#542C18","#D06820","#C8C8C8"]`. [mode 7-cube-gouraud.json](EXTERNAL-INPUTS.it.md) contiene i 256 texel inline equivalenti. Entrambi usano repeat[2,2], Gouraud C e la stessa geometria/UV/palette; con gli stessi parametri di build producono PRG byte-identici. I nomi delle scene possono differire senza influire sui dati runtime.

Dopo la conversione, la texture resta una tabella runtime unpacked di 256 byte, allineata a pagina. Il PNG non risparmia RAM runtime e non aggiunge decoder. Più texture usate aggiungono pagine; le pagine inutilizzate possono essere omesse. Vedere [formato texture](TEXTURE-GUIDE.it.md) e [parametri build Mode 7](MODE7.it.md).
