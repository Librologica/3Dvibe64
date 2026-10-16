# 3Dvibe64 1.11.0 — release ufficiale locale dei sorgenti

2026-10-16. Promossa dalla 1.11.0-dev13/cubes-restored. Preparazione locale;
pubblicazione online rinviata. Distribuzione del source SDK dell’engine,
con input JSON/asset e sorgenti dei compilatori/profili. **Nessun PRG
precompilato, archivio demo, video o musica** è incluso. Gli strumenti
esterni non sono distribuiti.

## Novità rispetto alla1.10.2

|ID|Funzione|Contratto completo|
|---|---|---|
|BB-01|Profili billboard mascherati e contornati|[reference](extensions/gameplay/CONTRACT.it.md)|
|BB-02 / ENT-01|Billboard configurabile, eventi d’uso e collisioni locali|[reference](extensions/gameplay/entities/DEV.it.md)|
|ENT-01 door|Porta poligonale scorrevole e passaggio sicuro|[reference](extensions/gameplay/entities/DOOR-DEV.it.md)|
|BB-03|Una/due istanze billboard con asset condiviso|[reference](extensions/gameplay/billboards/MULTIPLE-DEV.it.md)|
|MAT-01|Selezione per faccia texture, flat e Gouraud|[reference](extensions/gameplay/materials/DEV.it.md)|
|TEX-01|Frame delle texture e scorrimento UV intero|[reference](extensions/gameplay/materials/ANIMATION-DEV.it.md)|
|LIGHT-01|Illuminazione statica deterministica calcolata sul PC|[reference](extensions/gameplay/materials/LIGHT-DEV.it.md)|
|VIS-01|Connettività conservativa di settori e portali|[reference](extensions/gameplay/visibility/VISIBILITY-DEV.it.md)|
|Q8-01|Mesh sorgente condivisa, cache indipendenti|[reference](extensions/gameplay/meshes/SHARED-DEV.it.md)|
|Q8-02|Clip controllabili e roll Q8 della camera|[reference](extensions/gameplay/motion/CONTROLLED-DEV.it.md)|
|WORLD-01|Gruppi di stanze esterni e stato per gruppo|[reference](extensions/gameplay/world/WORLD-DEV.it.md)|
|LEVEL-01|Formato comune di livello e budget assemblato esatto|[reference](extensions/gameplay/level/LEVEL-DEV.it.md)|
|Integration|Integrazione delimitata a tre stanze e riuso memoria per fasi|[reference](extensions/gameplay/experiments/underworld/README.it.md)|

Tutti i moduli gameplay conservano contratti sperimentali/delimitati. Exporter
ordinario, default, aritmetica Q8 e backend Mode 8 sono preservati. Nessuna
nuova ABI generale di scena integrata. I profili sorgente sono configurazioni
ricostruibili, non prodotti eseguibili allegati alla release.

## Compatibilità ed entry point

- `work/build-3Dvibe64.ps1`: exporter GraphicsMode 1–8 ereditato. Default:
  legacy, texture standard, linee precise, LOD off, presentazione safe.
- `work/build-gameplay.py` / `.ps1`:13 profili con opzioni di configurazione
  controllate. Condivisione/roll sono adattatori Q8-01/Q8-02; non diventano
  campi `meshSourceSharing`/roll accettati nell’API Q8 ordinaria.
- `work/build-level.py`: `3Dvibe64.level/1`, asset portabili, ID densi,
  traduzione WORLD-01, margine RAM/contiguità assemblati. `--validate-only`
  non scrive; `--plan-only` non dichiara un programma nativo.
- `work/build-underworld.py`: integrazione sorgente separata a tre stanze,
  tre cubi statici, skeleton/guardiano, clip da eventi e 2904 byte realmente
  riutilizzati dopo l’avvio UI. Non incorpora il caricamento WORLD-01.

L’helper preciso 1.10.3-dev1 rimane locale a tale adattatore. Mode 8 solo bitmap
e rifiuto degli esperimenti ritirati, limiti Normalized 16 e hash della
fondazione 1.10.2 restano conservati. Note/evidenze storiche mantengono la
propria versione. Manuali EN/IT, indice, matrice funzioni, comandi, schemi,
memoria e limiti sono allineati. Gli strumenti host di packaging/cattura
rispettano anche `TASS64_EXE`/`VICE_TURBO6510`; questa selezione dei percorsi
non cambia le istruzioni del renderer.

## Limiti da rispettare

Billboard con maschera binaria e palette residente condivisa. Near 8 WU negli
adattatori singoli,4 WU in BB-03 con una/due istanze dello stesso asset.
Occlusione/collisioni limitate agli inviluppi verificati di stanza/divisorio.
Luce statica sul PC sui ricevitori Gouraud, senza ombre texturizzate dinamiche.
VIS-01 usa connettività conservativa, non clipping angolare dei portali.
Q8-01:2–4 solidi convessi da sei vertici/otto facce, cache sempre per istanza.
Q8-02 anima trasformazioni, senza animazione scheletrica/fisica di volo.

WORLD-01:2–8 gruppi del template a due stanze, staging 1024 byte, file 762 byte
con CRC, stato 17 byte/gruppo in RAM e transizioni esplicite. Nessun salvataggio
su disco/topologia generale. Il formato comune descrive ulteriori richieste,
ma rifiuta integrazioni non costruibili dal backend. Recupero UI 3759 byte
ancora ipotetico in WORLD-01: i 2904 byte dell’Underworld separata non diventano
liberi in quel backend. Integrazione generale nella [roadmap](ROADMAP.it.md).

## Build, test e prestazioni

Toolchain Windows verificata: PowerShell 7,Python 3.13,64tass 1.60.3243; Pillow
per PNG/UI,py65 per test routine. Configurare le versioni VICE installate per
i test nativi. Nessuna nuova qualifica Linux/hardware fisico.

```powershell
python -B scripts/run_release_tests.py
python -B work/build-gameplay.py --profile shared-meshes --out ../shared-build
python -B work/build-level.py --level examples/levels/integrated-foundation.json --validate-only
```

La [qualificazione](QUALIFICATION-1.11.0.it.md) registra gate di release,
integrità dei sorgenti e ricostruzioni dei checkpoint. Le prove native si
riusano solo con byte PRG e condizioni coincidenti. Ogni FPS vale per la sua
scena/target/opzioni: promuovere i sorgenti non produce un FPS universale
dell’engine. Warp/tempo host/replay CPU non sono FPS di viste complete native.
Le catture grezze dello sviluppo restano fuori dall’archivio sorgente.

Integrità del pacchetto: `MANIFEST.sha256`; digest dello ZIP nella consegna.
Release precedenti, progetti congelati e dev originale preservati. Software:
PolyForm Noncommercial 1.0.0; documentazione CC BY-NC 4.0, attribuzione
librologica.digital. [README](README.it.md), [guida rapida](QUICKSTART.md),
[tutta la documentazione](DOCS.md), [test](TESTING.md).
