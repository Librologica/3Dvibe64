# Roadmap — 1.15.1

Stabile1.15.1, release GitHub di soli sorgenti. [Stato release](RELEASE-STATUS.it.md) · [Qualifica corrente](QUALIFICATION-1.15.1.it.md). Scene e asset sono esterni; nessun progetto demo incluso.

> SDK sorgente stabile1.15.1 pubblicato su GitHub. [Stato e supporto](RELEASE-STATUS.it.md).

Inclusi: opzioni renderer esatte, span compatti MAT-01, adapter pareti conservativo, helper retini/palette statici e primitive opzionali pool/camera/SID. Billboard, materiali, entità, visibilità, mesh condivise, animazioni controllate, WORLD-01 e LEVEL-01 mantengono contratti delimitati.

Restano futuri: integrazione in scene generali, intersezioni/trasparenze arbitrarie, occlusione generale, portali angolari, ombre dinamiche texturizzate, salvataggi disco persistenti, allocatore WORLD integrato e qualificazione di altri backend. Gli helper non realizzano automaticamente queste integrazioni. Nessuna nuova demo verrà allegata.

[Contratti](RENDER-OPTIMIZATIONS.it.md) · [Supporti](ADAPTER-SUPPORT.it.md) · [Qualificazione](QUALIFICATION-1.14.0.it.md)


## Confine applicativo 1.15.0

Legacy-plus Mode1–7 e Mode7 affine/prospettica sono stabili nel [profilo plus pubblico](LEGACY-PLUS.it.md). Il port privato Underworld usa viewport, loader/layout RAM, culling e ottimizzazioni materiali/LOD/campionatore diversi: non sono nuovi default pubblici o una nuova ABI gameplay generica. Gli adapter gameplay riutilizzabili conservano i vincoli di precisione/profilo esistenti. Vedere [ambito della promozione stabile](RELEASE-NOTES-1.14.0.it.md#distribuzione-e-confine-del-port-privato).
