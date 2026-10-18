# Q8-02 — animazioni controllabili e roll — 1.14.0-dev1

Dev locale 1.14.0-dev1: [ottimizzazioni correnti](../../../RENDER-OPTIMIZATIONS.it.md), [input esterni](../../../EXTERNAL-INPUTS.it.md). Tutte le demo, gli esempi e le prove native sono esterni alla distribuzione sorgente.


La distribuzione 1.12.0 include soltanto il modulo riutilizzabile. I nuovi progetti/asset demo sono esclusi. Catture, checkpoint e misure native sotto descrivono prove storiche esterne. Le build di progetto richiedono `--project-source`; vedere la [guida di integrazione](../../../GAMEPLAY.it.md).


Contratto corrente della release 1.12.0; i numeri dei checkpoint indicano
la provenienza delle prove. [English](CONTROLLED-DEV.en.md).

I profili `controlled-animation` e `camera-roll` estendono la prova delle
mesh condivise. Il primo mantiene la camera dungeon senza roll; il secondo
aggiunge il roll della camera nella medesima stanza di verifica. I quattro
solidi hanno clip indipendenti di posizione, yaw, scala e visibilità. Le
pareti mantengono texture precise per pixel, 60 righe, LOD 14–22 e UI 96 × 60.

```powershell
python -B work/build-gameplay.py --profile controlled-animation --out ../builds/motion-dev10 --project-source ../my-project
python -B work/build-gameplay.py --profile camera-roll --out ../builds/roll-dev10 --project-source ../my-project
python -B work/qualify-gameplay.py --out ../builds/motion-dev10 --checks --benchmark --launcher
python -B work/qualify-gameplay.py --out ../builds/roll-dev10 --checks --benchmark --launcher
```

`--motion-controls percorso.json` sostituisce la configurazione. `enabled:false`
elimina interamente Q8-02 e ricostruisce il PRG shared-meshes della dev9.
Il profilo ordinario `shared-meshes` conserva il suo programma originale.

## Clip e tempo

Il JSON contiene schema 1, enabled booleano, camera e clips. Una clip per
istanza, nel medesimo ordine degli id di shared-meshes, contiene instance,
ticksPerKey 64, playing, speed 1/2/4, loop e da 1 a 8 keys. Ogni chiave contiene
position pubblica X/destra,Y/avanti,Z/alto, yawDegrees 0–360 escluso,
scale 0.5–1 con passo 1/64 e visible booleano. La prima chiave coincide con
il descrittore dell'istanza. Le posizioni hanno passo 1/256 WU.

Il player gira sul tick PAL di simulazione, indipendentemente dalle viste
completate. Ogni chiave dura 64 tick; le velocità 2/4 consumano 2/4 passi per tick.
Posizioni e yaw usano incrementi arrotondati al Q8/fase più vicino e caricano
esattamente la chiave all'estremo, evitando deriva tra cicli. Il percorso
angolare usa l'arco più corto; a 180° sceglie il segno negativo. La scala
conserva un accumulatore Q14, pubblicando nel trasformatore il valore Q6.
La visibilità cambia all'ingresso della chiave. Il validatore controlla
tutti i 64 campioni quantizzati di ogni segmento, compreso quello di chiusura,
la permanenza nella stanza e gli inviluppi XY disgiunti delle istanze.

## Comandi applicativi nativi

Chiamare dal thread principale, prima della costruzione della vista:
`an_control`, A=opcode, X=indice istanza 0..N−1, Y=argomento. Carry 1 segnala
successo; carry 0 rifiuta il comando senza cambiare pose o cursori delle clip.
Registri e flag ulteriori sono scratch. I comandi non modificano i sorgenti.

| A | Comando | Y |
| ---: | --- | --- |
| 0 | Pausa sulla posa corrente, conservando il tempo frazionario | ignorato |
| 1 | Riprendi | ignorato |
| 2 | Stop, prima chiave e pausa | ignorato |
| 3 | Seek esatto a una chiave; conserva play/pausa | indice chiave |
| 4 | Velocità | 1,2,4 |
| 5 | Ripetizione | 0,1 |
| 6 | Chiave successiva e pausa | ignorato |
| 7 | Prima chiave e riproduzione | ignorato |

Senza loop, l'ultima chiave ferma la clip e imposta an_completed. Disattivare
il loop durante il segmento di ritorno porta esattamente all'ultima chiave.
Con una sola chiave la modalità non ripetuta termina sulla posa iniziale.
La selezione da tastiera non cambia lo stato delle altre clip:
**1–4** scelgono l'istanza, **SPAZIO** pausa/riprende, **R** riavvia,
**T** passa alla chiave seguente in pausa, **F** cicla velocità 1/2/4.
I comandi singoli sono attivati sul fronte del tasto, senza ripetizione involontaria.

## Camera dungeon e volo

camera.mode sceglie dungeon o flight; bankDegrees 0..45 controlla
l'ampiezza del roll automatico nel giro di 3072 tick. Yaw, pitch e roll
sono fasi complete di 16 bit. Il roll inverso viene applicato dopo yaw/pitch
alle coordinate camera a 24 bit, prima di proiezione, near plane e clipping
allo schermo. Si usano seno interpolato e prodotto Q8 canonici. La UI 2 D
mantiene i pixel originali; l'immagine 3D viene ricostruita nella viewport.

`cr_set_roll`: A=byte basso della fase, Y=byte alto; carry 1 successo.
Il comando entra in roll manuale. Dungeon accetta solo zero; una richiesta
non nulla restituisce carry 0 e conserva lo stato. Flight accetta l'intero
giro e il wrap. `cr_resume` riprende il bank automatico dalla fase corrente
del percorso, senza far avanzare o riavviare la camera. Nel profilo volo,
**Q/E** variano il roll di 128 unità di fase per tick, **HOME** lo azzera,
**C** riprende il bank automatico. La camera continua il giro automatico.

## Memoria, prove e ambito

Quattro clip da quattro chiavi: 344 byte di sorgenti clip, 80 byte di stato,
192 byte di tabella bank e 9 byte di stato camera. Player 650 byte, tastiera 285,
roll 361. Con call site, guardie e allocazione, Q8-02 occupa **1979 byte**
aggiuntivi rispetto alla stessa prova Q8-01: restano **3302 byte** nei gap.
Geometria condivisa e cache per istanza conservano quantità e intervalli.

Le verifiche native sono separate per dungeon e volo: comandi validi e
rifiutati, pausa, ripresa frazionaria, cambio velocità, loop e fine clip,
tasti premuti/mantenuti, roll manuale e automatico. Il controllo geometrico
indipendente confronta tutti i 33 vertici a 24 bit e i pixel interni dei solidi,
inclusi roll 90/180/270°, frazioni angolari, yaw/pitch combinati e clipping.
A roll zero la bitmap e la palette coincidono con la dev9; la UI rimane
invariata. Sono provate anche clip native con 1/3/4/8 chiavi e visibilità.
FPS, p 95, peggiore intervallo, comandi, hash e dati grezzi del giro completo
sono nel checkpoint esterno reports/dev10/CHECKPOINT.it.md della consegna.

Resta una prova sperimentale per 2–4 istanze di solidi convessi delimitati.
Non è una nuova API generale del builder ordinario, né animazione scheletrica,
fisica di volo o roll dei billboard. Le dieci demo precedenti restano nei
loro profili, con PRG identici. La prova di volo usa la stanza: navetta,
release congelate, fondazione e Mode 8 sono preservate. WORLD-01 è disponibile nel profilo separato room-groups.
Documentazione corrente inclusa nella release 1.12.0.
