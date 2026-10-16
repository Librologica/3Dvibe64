# Roadmap — 1.11.0

## Correzione della distribuzione nella 1.11.0

Esclusi i nuovi progetti demo, compresi generatori sorgente, UI, disegni dei
personaggi, percorsi camera, launcher e asset di riferimento. Rimossa la copia
duplicata dell’SDK 1.10.2. Conservati gli esempi già presenti nella v1.10.2.
Si corregge la release esistente; VERSION resta 1.11.0.

Restano compilatori, validatori ed emitter assembly gameplay riutilizzabili.
Le build gameplay native richiedono un progetto esterno esplicito tramite
`--project-source`; nessuna demo è ricostruita da input predefiniti allegati.
Engine ordinario ed esempi preesistenti restano direttamente compilabili.
Vedere [GAMEPLAY](GAMEPLAY.it.md), [guida rapida](QUICKSTART.md) e
[qualificazione](QUALIFICATION-1.11.0.it.md).

| ID | Modulo | Contratto |
|---|---|---|
|BB-01|Emitter billboard mascherati/contornati|[reference](extensions/gameplay/CONTRACT.it.md)|
|BB-02 / ENT-01|Configurazione billboard ed eventi locali|[reference](extensions/gameplay/entities/DEV.it.md)|
|ENT-01 door|Porta poligonale scorrevole|[reference](extensions/gameplay/entities/DOOR-DEV.it.md)|
|BB-03|Billboard multipli con asset condiviso|[reference](extensions/gameplay/billboards/MULTIPLE-DEV.it.md)|
|MAT-01|Texture/flat/Gouraud per faccia|[reference](extensions/gameplay/materials/DEV.it.md)|
|TEX-01|Frame texture e scorrimento UV intero|[reference](extensions/gameplay/materials/ANIMATION-DEV.it.md)|
|LIGHT-01|Luce statica calcolata sul PC|[reference](extensions/gameplay/materials/LIGHT-DEV.it.md)|
|VIS-01|Connettività conservativa dei settori|[reference](extensions/gameplay/visibility/VISIBILITY-DEV.it.md)|
|Q8-01|Mesh sorgente condivisa e cache per istanza|[reference](extensions/gameplay/meshes/SHARED-DEV.it.md)|
|Q8-02|Animazione controllabile e roll camera|[reference](extensions/gameplay/motion/CONTROLLED-DEV.it.md)|
|WORLD-01|Caricamento e stato di gruppi delimitati|[reference](extensions/gameplay/world/WORLD-DEV.it.md)|
|LEVEL-01|Formato comune di livello e contabilità memoria|[reference](extensions/gameplay/level/LEVEL-DEV.it.md)|

## Lavoro rimanente

Integrare i moduli delimitati in una API generale di scena, rimuovere le dipendenze dalle etichette dei template, ampliare la topologia del mondo e provare la proprietà della memoria nelle combinazioni di funzioni. Recupero UI WORLD-01 non ancora applicato. Ogni composizione nativa richiede verifiche e misure proprie; prove storiche separate non dimostrano compatibilità generale. I nuovi progetti dimostrativi restano fuori dall’SDK pubblico.
