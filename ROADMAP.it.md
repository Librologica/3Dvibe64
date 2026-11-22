# Roadmap — 1.20.1

> SDK sorgente stabile 1.20.1. [Qualifica](QUALIFICATION-1.20.1.it.md).


Implementati: AnimatedMesh v1 nativa, clip di pose compresse, fasi indipendenti, cache della posa sorgente e Gouraud di riferimento congelato facoltativo. [Contratto](ANIMATED-MESH.it.md).


Inclusi: opzioni renderer esatte, span compatti MAT-01, adapter pareti conservativo, helper retini/palette statici e primitive opzionali pool/camera/SID. Billboard, materiali, entità, visibilità, mesh condivise, animazioni controllate, WORLD-01 e LEVEL-01 mantengono contratti delimitati.

Restano futuri: integrazione in scene generali, intersezioni/trasparenze arbitrarie, occlusione generale, portali angolari, ombre dinamiche texturizzate, salvataggi disco persistenti, allocatore WORLD integrato e qualificazione di altri backend. Gli helper non realizzano automaticamente queste integrazioni. Nessuna nuova demo verrà allegata.

[Contratti](RENDER-OPTIMIZATIONS.it.md) · [Supporti](ADAPTER-SUPPORT.it.md) · [Qualificazione](https://github.com/Librologica/3Dvibe64/releases/tag/v1.14.0)


## Confine applicativo 1.15.0

Legacy-plus Mode1–7 e Mode7 affine/prospettica sono stabili nel [profilo plus pubblico](LEGACY-PLUS.it.md). Il port privato Underworld usa viewport, loader/layout RAM, culling e ottimizzazioni materiali/LOD/campionatore diversi: non sono nuovi default pubblici o una nuova ABI gameplay generica. Gli adapter gameplay riutilizzabili conservano i vincoli di precisione/profilo esistenti. Vedere [ambito della promozione stabile](https://github.com/Librologica/3Dvibe64/releases/tag/v1.14.0).
