# Note di rilascio — 1.15.0

Release stabile sorgente pubblicata su GitHub. Promossa dalla dev qualificata1.15.0-dev2, con runtime invariato. [Stato e supporto](RELEASE-STATUS.it.md).

## Novità rispetto alla1.14.0

- Prodotti Q4×Q10 e divisioni esatte con percorsi rapidi dimostrati e ripiego completo.
- Bordi con resto a8bit, riporto del nono bit e percorso rapido per bordi interi; scritture bitmap per blocchi, righe fisiche adiacenti e cache materiali corretta per intervalli disconnessi.
- Outcode conservativi dei vertici e adapter per coppie/fan convessi compatibili; palette miste, geometrie dubbie e casi non idonei conservano i triangoli originali.
- API esplicite per linee wire con materiali nativi e per vertici camera Q4 generati direttamente negli array dell'engine.
- Codec facoltativo di chiavi signed16 senza perdita e illuminazione congelata esplicita con invalidazione per oggetto.

I nuovi kernel/API sono qualificati solo nel profilo Mode4 legacy-plus documentato. Legacy-plus ordinario Mode1–7 e gli altri backend mantengono i contratti esistenti. Default `legacy`, ottimizzazioni `none`, texture standard, linee precise, LOD off e presentazione safe invariati. `all` non include wire,stream o frozen-lighting. Nessuna riga alternata o riduzione automatica di precisione/risoluzione/palette. Nessuna demo o contenuto del gioco viene distribuito.

## Verifiche e prestazioni

Le prove native della dev qualificata restano valide perché runtime, configurazioni, PRG e target sono invariati.127pose RGB identiche;57default legacy/plus/Q8 identici; callback numerici e codec qualificati. La fixture wire passa da9,5988 a12,2130FPS (+27,23%); renderer e clipping della dev2 mantengono50,1245 e47,6827FPS. Questi sono risultati delle fixture nominate, non FPS della navetta o promesse universali. [Provenienza e dettagli](QUALIFICATION-1.15.0.it.md).

[Build](QUICKSTART.md) · [Opzioni esatte](EXACT-RENDER.it.md) · [API e memoria](REUSABLE-RENDER.it.md) · [Suite pubblica](TESTING.md). Solo sorgenti. [Release e download](https://github.com/Librologica/3Dvibe64/releases/tag/v1.15.0).
