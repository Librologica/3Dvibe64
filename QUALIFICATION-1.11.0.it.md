# Qualificazione — 3Dvibe64 1.11.0

Release ufficiale locale derivata dalla 1.11.0-dev13/cubes-restored;
pubblicazione online rinviata. Il documento distingue l’audit di release
dalle misure native storiche. Risultato verificabile in
[QUALIFICATION-1.11.0.json](QUALIFICATION-1.11.0.json); la consegna finale
è accettata solo con stato PASS e verifica di archivio/manifest superata.

## Cambiamenti e identità preservate

Identità, manuali bilingui, asserzioni di release e strumenti passano alla
1.11.0. Packaging/catture host rispettano i percorsi esterni configurati di
assembler/emulatore, senza cambiare il codice 6502 del renderer. Builder
ordinario SHA 256
`79510B085B6B786A87F2F2814B2BED0FE2C95313EDAF0A3C121B89EA02C9C14F`.
Gli 80 file work ordinari, Mode 8 e fondazione 1.10.2 rimangono identici alla
base qualificata. Gli output compilati sono materiali di verifica esterni
al checkout sorgente e non vengono distribuiti.

## Gate della release

La suite su copie pulite in [TESTING](TESTING.md) copre pacchetto pubblico,
riferimenti legacy, aritmetica/rendering, Q8/Normalized 16, Mode 7 texture/fast/
LOD/linee/presentazione, Mode 8 validazione/bitmap/provenienza nativa e guardie
di qualificazione. I gate gameplay controllano tutti i compilatori di dati,
grafi, riferimenti, bake statico e mappe RAM reali. L’audit documentazione
verifica coppie EN/IT, ogni profilo/opzione, link locali e assenza di asset
compilati/demo. Gli esiti effettivi sono nel JSON: uno strumento mancante
non viene considerato un test riuscito.

Tutti 13 i preset sono ricostruiti separatamente e confrontati con gli hash
checkpointPRGSHA 256 conservati. Programma/dati del livello comune sono
confrontati col checkpoint WORLD-01; l’integrazione separata con la dev13
corretta, hash
`249D99C34BA0A50C318A1577F07E632ACD3BEEE299E3AFEDCDDDD31966B6FA2E`.
Si verificano promozione dei preset e percorsi host senza apprendere nuovi
hash attesi da un renderer diverso. Comandi, identità strumenti, catture
native e prove di rebuild sono nei rapporti locali esterni della release.

## Riuso delle misure native e limiti

Le prove si ereditano soltanto per programmi identici, con stesso target,
launcher/opzioni, musica e percorso. Ricostruire i sorgenti non trasforma
quelle misure in nuove acquisizioni. Le matrici stock/Turbo PAL/NTSC 1.10.2
sono nelle note storiche; i valori gameplay valgono per le singole scene
delimitate, non per ogni utilizzo dell’engine.

Integrazione corretta: VICE Turbo6510 PAL× 64,silent,filtro 0,Colodore,
safe raster 252,warm-up 101 refresh/2.014981 s,misura 6400 refresh/127.681964 s,
giro completo 96 chiavi/6144 tick.691 nuove viste complete,5.411884 FPS,
p 95=219.453 ms,peggiore=299.255 ms. La stessa scena senza scarto delle stanze
misurava 5.411884 FPS. La variante precedente senza cubi misurava 5.748658 FPS:
geometrie diverse impediscono di attribuire il delta a una sola ottimizzazione.
Comandi/hash/raw originali preservati nella consegna dello sviluppo.

La release sorgente non distribuisce PRG o archivi demo: i programmi sono
ricostruiti soltanto per verifica. Ogni futuro cambiamento di rendering/scena
richiede prove proprie:≥20 secondi emulati dopo warm-up, preferibilmente giro
completo, nuove viste presentate, raw/comando/hash/p 95/peggiore. Warp, tempo
host e replay di routine CPU non sono misure FPS.

## Confini della qualifica

Windows/PowerShell 7/Python 3.13/64tass 1.60.3243, Pillow 12.3.0,py65 1.2.0.
Tool nativi stock x64sc/xscpu64 e Turbo6510, con identità esatte nei rapporti
esterni. Nessuna nuova qualifica Linux, hardware C64/1541 o promessa di fit
per topologie/intersezioni/moduli arbitrari. Recupero UI 3759 byte non applicato
in WORLD-01;2904 byte riusati solo nell’integrazione separata. [Roadmap](ROADMAP.it.md).

I rapporti storici conservano misure e ambito. Contratti correnti:
[README](README.it.md), [gameplay](GAMEPLAY.it.md), [indice](DOCS.md).
[English](QUALIFICATION-1.11.0.en.md).

## Esito finale della release

Superati tutti i 41 gate, incluso il rerun completo del contratto/nativo
del pacchetto dopo la correzione documentale. Identità binaria di tutte le 15
ricostruzioni e sei controlli della guida rapida superati. Primo errore e
risoluzione restano nel JSON/log esterni. Archivio, estrazione e sorgenti Git
sono verificati separatamente nel sigillo; gli output compilati non sono
distribuiti.
