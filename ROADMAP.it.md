# Roadmap e stato delle funzioni — 1.11.0

Le funzioni seguenti sono incluse e qualificate entro i limiti dei profili.
La confezione ufficiale non amplia questi contratti.

|ID|Implementato entro i limiti|Riferimento|
|---|---|---|
|BB-01|Profili billboard mascherati e contornati|[contract](extensions/gameplay/CONTRACT.it.md)|
|BB-02 / ENT-01|Billboard configurabile, eventi d’uso e collisioni locali|[contract](extensions/gameplay/entities/DEV.it.md)|
|ENT-01 door|Porta poligonale scorrevole e passaggio sicuro|[contract](extensions/gameplay/entities/DOOR-DEV.it.md)|
|BB-03|Una/due istanze billboard con asset condiviso|[contract](extensions/gameplay/billboards/MULTIPLE-DEV.it.md)|
|MAT-01|Selezione per faccia texture, flat e Gouraud|[contract](extensions/gameplay/materials/DEV.it.md)|
|TEX-01|Frame delle texture e scorrimento UV intero|[contract](extensions/gameplay/materials/ANIMATION-DEV.it.md)|
|LIGHT-01|Illuminazione statica deterministica calcolata sul PC|[contract](extensions/gameplay/materials/LIGHT-DEV.it.md)|
|VIS-01|Connettività conservativa di settori e portali|[contract](extensions/gameplay/visibility/VISIBILITY-DEV.it.md)|
|Q8-01|Mesh sorgente condivisa, cache indipendenti|[contract](extensions/gameplay/meshes/SHARED-DEV.it.md)|
|Q8-02|Clip controllabili e roll Q8 della camera|[contract](extensions/gameplay/motion/CONTROLLED-DEV.it.md)|
|WORLD-01|Gruppi di stanze esterni e stato per gruppo|[contract](extensions/gameplay/world/WORLD-DEV.it.md)|
|LEVEL-01|Formato comune di livello e budget assemblato esatto|[contract](extensions/gameplay/level/LEVEL-DEV.it.md)|
|Integration|Integrazione delimitata a tre stanze e riuso memoria per fasi|[contract](extensions/gameplay/experiments/underworld/README.it.md)|

## Lavoro rimanente

1. Adattatore generale di livello con moduli combinati, assemblato e qualifica.
2. Allocatore UI per fasi e loader d’avvio validato WORLD-01:3759 byte sono
   candidati, non RAM libera. Il riuso 2904 byte esiste solo nell’Underworld
   separata, non nel backend WORLD-01.
3. Contratti per geometrie/condivisione/intersezioni arbitrarie, più di due
   asset/palette billboard indipendenti, collisioni/eventi generali.
4. Clipping angolare oltre la connettività conservativa; ombre dinamiche,
   luce sulle texture e trasformazioni più generali per ricevitori/occludenti.
5. Topologia dei gruppi generale, passaggi continui, qualifica del drive fisico
   e salvataggi persistenti su disco.
6. Qualifica di piattaforme/hardware e futura stabilizzazione delle API,
   basate su memoria/correttezza/prestazioni native riproducibili.

L’elenco non implica scadenze o memoria sufficiente. Ogni modifica futura
al rendering richiede FPS nativi di viste complete e controlli comparabili.
Mode 8, fondazione e versioni congelate mantengono il proprio ambito.
