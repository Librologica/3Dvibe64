# Note di release — 1.20.1

SDK sorgente stabile con ottimizzazioni per i percorsi di rendering compatibili.

- Le Mode 1 e 2 riducono il lavoro negli span wire, nell’indirizzamento delle righe da ripulire e nella proiezione vicino al piano di clipping. I percorsi poligonali riusano gli intervalli di materiale in cache.
- Lo shading Gouraud, i contorni poligonali e il texture mapping affine riusano risultati intermedi e riducono il lavoro nei cicli del raster.
- La Mode 8 accelera la percorrenza dei raggi, la cache dei profili, i riempimenti fini e l’aritmetica di proiezione nei renderer compatibili monolivello e multilivello.
- Restano validi i default del renderer, Distance Fade, il LOD texture e i limiti delle API.

[Qualifica](QUALIFICATION-1.20.1.it.md)

Lo ZIP sorgente contiene motore, documentazione bilingue e test di correttezza. Demo, driver dei benchmark, programmi generati e dati grezzi di verifica restano esterni.
