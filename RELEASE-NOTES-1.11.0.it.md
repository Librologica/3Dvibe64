# 3Dvibe64 1.11.0 — note di rilascio

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

## Ambito supportato

Exporter ordinario 1–8 e default invariati. I moduli gameplay restano
sperimentali e delimitati. L’SDK non include nuovi progetti demo, scene
sorgenti, personaggi, UI, percorsi camera o launcher; conserva soltanto gli
esempi preesistenti. Le build gameplay native richiedono input esterni.
Restano formato di livello e contabilità esatta della memoria assemblata;
`--validate-only` e `--plan-only` usano asset locali dell’utilizzatore.
Nessuna API generale di integrazione completa, geometria arbitraria,
salvataggio disco o ombra texturizzata dinamica. Recupero UI WORLD-01 non applicato.

## Verifiche

Controllati esclusione delle demo, manifest, parità documentale e link locali,
contratti unitari e conservazione dell’engine ordinario. Le prove native
storiche restano esterne; il riuso richiede esatte identità di sorgenti/PRG.
Questa correzione non introduce nuovi risultati di rendering/FPS. Vedere
[qualificazione](QUALIFICATION-1.11.0.it.md), [test](TESTING.md),
[documentazione completa](DOCS.md) e [GAMEPLAY](GAMEPLAY.it.md).

Software: PolyForm Noncommercial 1.0.0; documentazione: CC BY-NC 4.0.
Attribuzione: librologica.digital. VERSION resta 1.11.0.
