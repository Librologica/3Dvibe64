# Contratti dei sorgenti gameplay — 1.11.0

La release ufficiale include tredici profili sperimentali delimitati, il
formato comune di livello e un esperimento integrato separato. Dev1–dev13
identificano checkpoint storici; non sono attività future. La guida corrente
è [GAMEPLAY](../../GAMEPLAY.it.md); i contratti dei singoli moduli sono
indicizzati in [DOCS](../../DOCS.md). [English](CONTRACT.en.md).

Il builder ordinario `work/build-3Dvibe64.ps1` conserva l’API 1.10.2.
`work/build-gameplay.py` seleziona i profili; `work/build-level.py` compila
il formato comune tramite WORLD-01; `work/build-underworld.py` rimane
separato. Le combinazioni non disponibili sono rifiutate esplicitamente.
`common` contiene sorgenti/asset condivisi; `profiles` le specializzazioni;
le cartelle billboard, entità, materiali, mesh, motion, visibility, world
e level i moduli corrispondenti. Ogni dipendenza sorgente è inclusa.
La foundation-1.10.2 rimane un input immutabile, non una seconda release.

## Profili e composizione

`comparison-ui`: stanza chiusa, skeleton 38 vertici/52 segmenti con spada e
scudo, billboard contornato alto uguale,96 × 60 logici, prospettiva precisa
su tutte 60 righe, LOD 14–22 WU, orbita 3072 tick. `dungeon-masked`: un billboard
16 × 32/seiframe, cinque celle fisse,160 × 100, fast storico block 8/50 righe
ricostruite, LOD 14–22,7680 tick. Le qualità diverse impediscono un confronto
FPS diretto fra questi due profili.

La catena mixed-surfaces → interactive-billboard → door-entity →
multiple-billboards → animated-textures → static-light → sector-visibility
aggiunge progressivamente le funzioni descritte. Da mixed-surfaces si
dirama shared-meshes, poi controlled-animation/camera-roll: questo ramo
non include porta/billboard. room-groups deriva da door-entity; è il backend
del formato comune. L’integrazione a tre stanze è separata da WORLD-01.

## Geometria e palette dei billboard

Asset 16 × 32, maschera binaria:0 trasparente,1–3 pigmenti,4 nero opaco nei
profili contornati. Nessuna semitrasparenza. Il piano resta parallelo alla
vista, con profondità e dimensioni prospettiche. Gli adattatori storici a
istanza singola scartano il centro sotto 8 WU; BB-03 accetta 4 WU incluso e
scarta l’intero piano sotto tale valore. Le due istanze condividono asset
e cache 512 byte, mantenendo animazione indipendente. Appartenenza e
occlusione sono quelle del singolo profilo: intersezioni arbitrarie e piani
billboard inclinati non sono supportati.

## Ricostruzione e prove

```powershell
python -B work/build-gameplay.py --profile comparison-ui --out ../comparison-build
python -B work/build-gameplay.py --profile door-entity --out ../door-build
python -B work/build-level.py --level examples/levels/integrated-foundation.json --validate-only
```

Output nuovi e fuori dai sorgenti. I launcher generati usano VICE Turbo6510
PAL× 64, filtro 0, Colodore e nessuna musica. L’hash PRG decide il riuso delle
prove: cambiamenti richiedono controlli e misure native pertinenti, contando
soltanto nuove viste complete. La distribuzione sorgente non contiene
programmi precompilati o archivi demo. Restano futuri l’API generale di scena,
le topologie arbitrarie e la qualificazione congiunta di tutti i moduli.
