# Guida ai sorgenti gameplay — 1.11.0

[English](GAMEPLAY.en.md) · [Indice](DOCS.md) · [Note di rilascio](RELEASE-NOTES-1.11.0.it.md)

La release ufficiale espone builder di profili sperimentali delimitati, non
un’API universale di scena integrata. Sorgenti/JSON/asset permettono di
ricostruire ed estendere i moduli. Non sono distribuiti PRG precompilati,
musica/video o archivi demo. Il builder ordinario conserva il contratto 1.10.2;
i profili seguenti hanno entry point espliciti e separati.

## Scegliere una composizione supportata

|Profilo|Composizione di base|Funzione aggiunta|
|---|---|---|
|`comparison-ui`|—|Skeleton e billboard contornato|
|`dungeon-masked`|—|Profilo dungeon mascherato storico (fast)|
|`mixed-surfaces`|comparison-ui|Materiali per faccia|
|`interactive-billboard`|mixed-surfaces|Guardiano configurabile e interazione locale|
|`door-entity`|interactive-billboard|Porta scorrevole e passaggio locale sicuro|
|`multiple-billboards`|door-entity|Due istanze, asset/cache condivisi|
|`animated-textures`|multiple-billboards|Pagine dei frame e scorrimento UV|
|`static-light`|animated-textures|Luce statica per vertici calcolata sul PC|
|`sector-visibility`|static-light|PVS conservativo per connettività|
|`shared-meshes`|mixed-surfaces|Sorgente convessa condivisa, istanze separate|
|`controlled-animation`|shared-meshes|Clip controllate dall’applicazione|
|`camera-roll`|controlled-animation|Clip controllabili e roll della camera volo|
|`room-groups`|door-entity|Gruppi esterni di due stanze e stato|

La colonna base descrive la catena effettiva dei sorgenti. camera-roll
eredita anche controlled-animation nella catena del preset e aggiunge il
roll di volo a Q8-01, non porta/billboard. Default: VICE Turbo6510 PAL× 64,
senza musica, Colodore/filtro 0. comparison-ui e i successivi profili precisi
usano 96 × 60 logici, tutte 60 righe e LOD 14–22. dungeon-masked conserva
deliberatamente il fast storico 160 × 100, block 8/50 righe con ricostruzione.

Q8-01/Q8-02 si diramano da mixed-surfaces e sostituiscono gli attori con
solidi convessi: non accumulano porta, texture animate, luce e settori.
room-groups deriva da door-entity, non dalla catena con due billboard.
Il nome del profilo non promette supporto a geometrie arbitrarie.

## API di compilazione e output

```powershell
python -B work/build-gameplay.py --help
python -B work/build-gameplay.py --profile multiple-billboards --out ../billboards-build
pwsh -NoProfile -File work/build-gameplay.ps1 -Profile camera-roll -OutputDirectory ../roll-build
```

`--profile` sceglie uno dei 13 nomi, default comparison-ui; `--out` è obbligatorio,
nuovo e fuori dai sorgenti. Output esistenti/interni sono rifiutati prima di
sovrascrivere. Il wrapper PowerShell espone Profile/OutputDirectory e i nomi
SurfaceConfig,GameplayScene,DoorConfig,TextureAnimation,LightBake,Visibility,
SharedMeshes,MotionControls,WorldGroups. Le configurazioni vengono copiate
nel progetto generato; le combinazioni opzione/profilo non ammesse falliscono.

|Opzione Python|Profili accettati|Input nel progetto generato|
|---|---|---|
|`--surface-config`|mixed-surfaces, interactive-billboard, door-entity, multiple-billboards, animated-textures, static-light, sector-visibility, shared-meshes, controlled-animation, camera-roll, room-groups|`assets/surfaces.json`|
|`--gameplay-scene`|interactive-billboard, door-entity, multiple-billboards, animated-textures, static-light, sector-visibility, room-groups|`assets/gameplay-scene.json`|
|`--door-config`|door-entity, multiple-billboards, animated-textures, static-light, sector-visibility, room-groups|`assets/door.json`|
|`--texture-animation`|animated-textures, static-light, sector-visibility|`assets/texture-animation.json`|
|`--light-bake`|static-light, sector-visibility|`assets/light-bake.json`|
|`--visibility`|sector-visibility|`assets/visibility.json`|
|`--shared-meshes`|shared-meshes, controlled-animation, camera-roll|`assets/shared-meshes.json`|
|`--motion-controls`|controlled-animation, camera-roll|`assets/motion.json`|
|`--world-groups`|room-groups|`assets/world-groups.json`|

Default e asset sono in `extensions/gameplay/profiles/<profilo>/`; l’ereditarietà
fornisce gli input precedenti. Gli asset billboard/texture sono relativi al
JSON e devono restare nella sua cartella. Campi, conteggi, tipi, intervalli,
geometrie e profili incompatibili sono rifiutati dal compilatore corrispondente.
Leggere il suo contratto prima di cambiare i dati.

`build.json` conserva identità engine/profilo/fondazione, ambito, hash delle
configurazioni, comando, hash PRG e `checkpointPRGIdentical`. Il progetto è
in `project`, il programma finale in `<profilo>.prg`, il launcher generato
in `launch-demo.cmd`. Nessuno di questi output compilati è nella release
sorgente. Con room-groups conservare `project/media` insieme a programma e
launcher; lo stato dei gruppi persiste in RAM, senza salvataggi su disco.

## Formato comune di livello

```powershell
python -B work/build-level.py --level examples/levels/integrated-foundation.json --validate-only
python -B work/build-level.py --level examples/levels/integrated-foundation.json --out ../level-build
python -B work/build-level.py --level examples/levels/integration-planning.json --plan-only --out ../level-plan
```

`--level` è obbligatorio. `--validate-only` non scrive; `--plan-only` produce
input portabile/IR e motivi di compatibilità senza dichiarare un programma
nativo o RAM misurata. La compilazione richiede un piano WORLD-01 costruibile.
`reserveBytes` e `minimumContiguousBytes` allineato vengono verificati sulla
mappa assemblata. Output nativo in `native`, livello portabile in `level`,
budget in `memory-budget.json`, launcher accettato `launch-level.cmd`.
integration-planning è volutamente non costruibile: descrive il lavoro di
integrazione mancante, senza eliminare richieste silenziosamente.

WORLD-01 conserva ancora i 3759 byte della UI iniziale: recuperarli è un
piano, non RAM libera misurata in quel backend. L’integrazione seguente
riusa realmente 2904 byte con un diverso contratto di durata verificato.

## Integrazione delimitata separata

```powershell
python -B work/build-underworld.py --out ../integration-build
```

Questo adattatore combina tre stanze/cubi statici, skeleton e guardiano
configurabile, clip selezionate da eventi, esclusione delle stanze con Z
negativo e riuso di 2904 byte dopo l’avvio UI. Mantiene prospettiva precisa e
tutte 60 righe; cubo centrale statico. Non carica gruppi WORLD-01 né aggiunge
visita manuale/collisioni generali. `--scene-config` e `--no-room-culling`
appartengono a questo entry point, non a build-gameplay.

## Comandi, tempo e qualifica

I comandi dipendono dal profilo: SPACE usa guardiano/porta, WASD avvia la
visita locale, R riprende/riavvia dove documentato. Q8-02 usa 1–4/SPACE/R/T/F
per le clip e Q/E/HOME/C per il roll volo. WORLD-01 aggiunge N/P per i vicini.
La camera Underworld resta automatica. Comandi, near e solver di occlusione
di un profilo non si estendono agli altri. Stato e animazioni avanzano nei
tick di simulazione, non in base ai frame disegnati.

```powershell
python -B work/qualify-gameplay.py --out ../billboards-build --checks --benchmark --launcher
```

Configurare `TASS64_EXE` e `VICE_TURBO6510`. Gli strumenti host di build e
qualifica rispettano queste variabili; i fallback locali storici non sono
dipendenze. Pillow e py65 servono a UI/test. Python senza ottimizzazioni,
con `-B`. I risultati salvati si riusano solo con programma e condizioni
coincidenti; per una nuova acquisizione scegliere output nuovi. Gli FPS
richiedono target nativo, warm-up,≥20 secondi emulati/giro completo,
comandi/hash/raw e p 95/peggiore. Il replay CPU prova correttezza, non FPS.
Vedere [test](TESTING.md) e [qualificazione](QUALIFICATION-1.11.0.it.md).

## Contratti completi dei moduli

- BB-01: [Profili billboard mascherati e contornati](extensions/gameplay/CONTRACT.it.md).
- BB-02 / ENT-01: [Billboard configurabile, eventi d’uso e collisioni locali](extensions/gameplay/entities/DEV.it.md).
- ENT-01 door: [Porta poligonale scorrevole e passaggio sicuro](extensions/gameplay/entities/DOOR-DEV.it.md).
- BB-03: [Una/due istanze billboard con asset condiviso](extensions/gameplay/billboards/MULTIPLE-DEV.it.md).
- MAT-01: [Selezione per faccia texture, flat e Gouraud](extensions/gameplay/materials/DEV.it.md).
- TEX-01: [Frame delle texture e scorrimento UV intero](extensions/gameplay/materials/ANIMATION-DEV.it.md).
- LIGHT-01: [Illuminazione statica deterministica calcolata sul PC](extensions/gameplay/materials/LIGHT-DEV.it.md).
- VIS-01: [Connettività conservativa di settori e portali](extensions/gameplay/visibility/VISIBILITY-DEV.it.md).
- Q8-01: [Mesh sorgente condivisa, cache indipendenti](extensions/gameplay/meshes/SHARED-DEV.it.md).
- Q8-02: [Clip controllabili e roll Q8 della camera](extensions/gameplay/motion/CONTROLLED-DEV.it.md).
- WORLD-01: [Gruppi di stanze esterni e stato per gruppo](extensions/gameplay/world/WORLD-DEV.it.md).
- LEVEL-01: [Formato comune di livello e budget assemblato esatto](extensions/gameplay/level/LEVEL-DEV.it.md).
- Integration: [Integrazione delimitata a tre stanze e riuso memoria per fasi](extensions/gameplay/experiments/underworld/README.it.md).

## File completi delle configurazioni predefinite

Questi JSON sorgente mostrano la forma completa dei dati, compresi i campi applicativi. Copiare configurazione e asset relativi insieme, senza mescolare schemi o catene di profili. I contratti dei moduli spiegano limiti numerici e geometrici.

|Configurazione|JSON|
|---|---|
|superfici|[surfaces.json](extensions/gameplay/profiles/mixed-surfaces/assets/surfaces.json)|
|billboard/entità singola|[gameplay-scene.json](extensions/gameplay/profiles/interactive-billboard/assets/gameplay-scene.json)|
|asset billboard|[guard-frames.json](extensions/gameplay/profiles/interactive-billboard/assets/guard-frames.json)|
|porta|[door.json](extensions/gameplay/profiles/door-entity/assets/door.json)|
|due billboard|[gameplay-scene.json](extensions/gameplay/profiles/multiple-billboards/assets/gameplay-scene.json)|
|animazione texture|[texture-animation.json](extensions/gameplay/profiles/animated-textures/assets/texture-animation.json)|
|frame texture|[texture-frames.json](extensions/gameplay/profiles/animated-textures/assets/texture-frames.json)|
|illuminazione statica|[light-bake.json](extensions/gameplay/profiles/static-light/assets/light-bake.json)|
|visibilità|[visibility.json](extensions/gameplay/profiles/sector-visibility/assets/visibility.json)|
|istanze condivise|[shared-meshes.json](extensions/gameplay/profiles/shared-meshes/assets/shared-meshes.json)|
|asset mesh condivisa|[crystal-mesh.json](extensions/gameplay/profiles/shared-meshes/assets/crystal-mesh.json)|
|clip controllate|[motion.json](extensions/gameplay/profiles/controlled-animation/assets/motion.json)|
|roll volo|[motion.json](extensions/gameplay/profiles/camera-roll/assets/motion.json)|
|gruppi di stanze|[world-groups.json](extensions/gameplay/profiles/room-groups/assets/world-groups.json)|
