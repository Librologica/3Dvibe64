# Moduli sorgente gameplay — 1.11.0

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

## Input del progetto

L’SDK contiene algoritmi e adattatori delimitati, non un nuovo gioco o demo
completo. Scena, texture, frame billboard, mesh/animazioni, UI, percorso camera
e collegamenti del progetto sono forniti dall’utilizzatore. Nessun personaggio
o scena a tre stanze è allegato. L’exporter ordinario resta separato: sharing
Q8-01 e roll Q8-02 non diventano campi accettati nelle scene Q8 ordinarie.

Il driver di compatibilità `work/build-gameplay.py` riceve una radice esterna:
`examples/gameplay/<profile>.json` per il preset e
`extensions/gameplay/common`, `extensions/gameplay/profiles/<profile>` e
`extensions/gameplay/billboards/<implementation>.py` per i collegamenti
dell’utilizzatore. Questi percorsi appartengono al progetto esterno, non
all’SDK. Il preset contiene `profile`, `engineVersion` (1.11.0), `extends`
opzionale, `buildName`, `billboardImplementation`, `distributionPRG`,
`textureQuality`, `textureLOD`, `viewportLogical`,
`expectedCheckpointPRGSHA256` e `scope` opzionale. Il driver sovrappone i
profili del progetto, copia l’SDK corrente come dipendenza dell’engine,
applica la configurazione e avvia il `build_demo.py` del progetto.
Verifiche, oracoli e launcher devono essere forniti dal progetto stesso.

```powershell
python -B work/build-gameplay.py --project-source ../my-project --profile shared-meshes --shared-meshes ../my-project/assets/instances.json --out ../my-build
pwsh -NoProfile -File work/build-gameplay.ps1 -ProjectSource ../my-project -Profile shared-meshes -OutputDirectory ../my-build-ps
```

`--out` deve essere nuovo ed esterno a SDK e input del progetto. Input mancanti
sono rifiutati prima di creare output. Nessuna ricerca implicita di demo
private locali. Restano questi identificatori compatibili con i progetti
esterni; nessun relativo preset dimostrativo è distribuito:

`animated-textures`, `camera-roll`, `comparison-ui`, `controlled-animation`, `door-entity`, `dungeon-masked`, `interactive-billboard`, `mixed-surfaces`, `multiple-billboards`, `room-groups`, `sector-visibility`, `shared-meshes`, `static-light`.

## Opzioni di configurazione

- `--surface-config`: JSON materiali per faccia.
- `--gameplay-scene`: JSON billboard/entità e asset relativo.
- `--door-config`: configurazione movimento porta.
- `--texture-animation`: tempi frame/UV e asset relativo.
- `--light-bake`: configurazione luce statica sul PC.
- `--visibility`: grafo settori/portali.
- `--shared-meshes`: istanze condivise e input mesh.
- `--motion-controls`: clip trasformazioni, riproduzione e roll.
- `--world-groups`: topologia gruppi e transizioni.

Billboard/porta/multipli/texture/luce/visibilità seguono la catena delimitata
delle stanze. Mesh condivise derivano dai materiali misti; animazioni e roll
derivano da tale ramo. I gruppi derivano dal ramo porta. Le opzioni incompatibili
sono rifiutate. Schemi, campi, intervalli e proprietà della memoria rimangono
quelli dei contratti completi collegati sopra.

## Integrazione delle librerie

`billboards/masked.py` e `outlined.py` espongono `kernel()`, `adapt(source,
parts)` e `post(source, frames)`. Il chiamante fornisce sei frame indicizzati
16×32 (0 trasparente, slot 1–3, nero opaco 4 opzionale per outlined).
Non esistono `artwork()`, generatori scena/percorso o scritture implicite
degli asset. Etichette delle facce e bande di profondità devono corrispondere
al progetto delimitato; `billboards/scene.py` configura ancora, dimensioni e
animazione. `multiple.py` condivide un asset e mantiene stato per istanza.

Materiali, luce, visibilità, mesh, movimento e gruppi conservano le funzioni
emit/validate e le ABI native documentate (`an_control`, `cr_set_roll`,
`cr_resume`, `wg_request`, `wg_service`). Sono richieste le etichette sorgente
e le regole di memoria dichiarate; non viene promessa una ABI generale stabile.

## Livello comune e memoria

`work/build-level.py --level ../my-level/level.json --validate-only` controlla
grafo e asset dell’utilizzatore senza scrivere. `--plan-only --out ../plan`
produce dati portabili, non un PRG o un budget nativo misurato. Tutti gli asset
usano `file:assets/name.json` dentro la cartella del livello; esclusi gli asset
demo builtin. La build nativa richiede anche `--project-source` e un template
WORLD-01 realmente supportato. `reserveBytes` e `minimumContiguousBytes` sono
verificati sulle mappe assemblate. Recupero UI WORLD-01 di 3759 byte non applicato.

## Prove e limiti

Le vecchie catture native delle demo restano prove di sviluppo esterne al
pacchetto e valgono per gli esatti programmi/opzioni storici. La pulizia non
introduce ottimizzazioni del rendering. Engine ordinario ed esempi preesistenti
sono conservati. Nuovi FPS nativi richiedono almeno 20 secondi emulati dopo
warm-up, sole viste complete, comando/hash/raw e p95/peggiore intervallo.
Restano maschere binarie, palette condivisa, geometria disgiunta e contratti
delimitati di stanze/gruppi. Non si aggiungono topologie arbitrarie, salvataggi
disco, ombre texturizzate dinamiche o API generali di integrazione completa.

[Indice documentazione](DOCS.md).
