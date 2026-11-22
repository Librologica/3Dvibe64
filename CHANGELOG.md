# Changelog — 1.20.1

## 1.20.1

- Modes 1 and 2 reduce wire-span setup, dirty-row addressing and near-plane projection work. Polygon paths reuse cached material ranges.
- Gouraud shading, polygon outlines and affine texture mapping reuse intermediate results and reduce work inside raster loops.
- Mode 8 improves ray traversal, profile caching, fine raster fills and projection arithmetic in compatible monolayer and multilayer renderers.
- Existing renderer defaults, Distance Fade, texture LOD and API limits remain in effect.

- Le Mode 1 e 2 riducono il lavoro negli span wire, nell’indirizzamento delle righe da ripulire e nella proiezione vicino al piano di clipping. I percorsi poligonali riusano gli intervalli di materiale in cache.
- Lo shading Gouraud, i contorni poligonali e il texture mapping affine riusano risultati intermedi e riducono il lavoro nei cicli del raster.
- La Mode 8 accelera la percorrenza dei raggi, la cache dei profili, i riempimenti fini e l’aritmetica di proiezione nei renderer compatibili monolivello e multilivello.
- Restano validi i default del renderer, Distance Fade, il LOD texture e i limiti delle API.

[Previous official releases / Release ufficiali precedenti](https://github.com/Librologica/3Dvibe64/releases)
