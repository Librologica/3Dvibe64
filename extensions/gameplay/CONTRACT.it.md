> Edizione di sviluppo 1.15.0-dev2; contratti1.14.0 ereditati salvo estensioni esplicite nel [rendering esatto](../../EXACT-RENDER.it.md).

# Contratto sorgente billboard delimitato — 1.14.0

Release stabile 1.14.0: [ottimizzazioni correnti](../../RENDER-OPTIMIZATIONS.it.md), [input esterni](../../EXTERNAL-INPUTS.it.md). Tutte le demo, gli esempi e le prove native sono esterni alla distribuzione sorgente.


La distribuzione conserva `billboards/masked.py`, `outlined.py`, `scene.py`
e `multiple.py`, insieme ai moduli entità/porta, materiali, luce, visibilità,
mesh, movimento, mondo e livello. Nessun generatore scena, UI, disegno del
personaggio, percorso camera, launcher, progetto demo o SDK duplicato è
allegato. Gli input nativi sono esterni ed espliciti. [GAMEPLAY](../../GAMEPLAY.it.md).

## API e input del chiamante

`kernel()` emette codice e stato. `adapt(source, parts)` collega etichette e
ordinamento dichiarati del renderer delimitato. `post(source, frames)` aggiunge
sei frame indicizzati 16×32 forniti dal chiamante: valori 0–3 per masked,
0–4 per outlined. Zero è trasparente; 4 è nero opaco in outlined. Non disegna
personaggi né scrive asset. `scene.validate(config, asset)` valida la
configurazione; `scene.bind(code, config)` configura ancora/dimensioni e
`scene.animation(config)` emette stato e controlli. `multiple.validate/load/adapt`
gestisce una/due istanze con asset condiviso.

## Contratto nativo delimitato

Ancora nello spazio mondo e trasformazione/proiezione Q8. L’immagine resta
parallela al piano della vista e rispetta profondità e dimensioni prospettiche.
Near a 8 WU per istanza singola; BB-03 accetta profondità costante >=4 WU.
Maschera binaria, palette residente condivisa e cache decodificata da 512 byte.
Stato animazione per istanza. Il progetto deve rispettare etichette della
stanza convessa, nodo painter riservato 36 e hook delle bande di profondità.
Non è un’API generale di occlusione/intersezione o piani inclinati arbitrari.
Nessuna scena, texture o palette è installata implicitamente. Exporter ordinario invariato.

## Integrazione e qualificazione

Fornire renderer/progetto compatibile, frame e configurazione propri. Il
driver richiede `--project-source`; vedere [struttura degli input](../../GAMEPLAY.it.md#input-del-progetto).
Input mancanti sono rifiutati esplicitamente. I test usano array sintetici in
cartelle temporanee, senza distribuire demo. Verificata identità di emissione
codice/stato/frame rispetto all’emitter precedente. Le prove native storiche
restano esterne e valgono per hash PRG, target e opzioni registrati. Nessun
nuovo risultato FPS deriva dalla correzione. [Indice](../../DOCS.md), [English](CONTRACT.en.md).
