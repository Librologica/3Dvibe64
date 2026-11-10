# Qualifica della stabile — 1.20.0

La release sorgente stabile 1.20.0 è pubblicata su GitHub. Il [registro JSON](QUALIFICATION-1.20.0.json) conserva identità dei sorgenti, provenienza dei programmi e risultati nativi originali. La revisione documentale corrente mantiene invariati runtime, API, misure e ancoraggi degli indici.

Copertura: 233 configurazioni tentate, nelle modalità 1–8 pure e miste, a 1×/20×/64×. Sono compilabili 177 configurazioni, con 531 celle aggregate valide e 651 esecuzioni native originali. Restano 56 blocchi preesistenti, equivalenti a 168 celle indisponibili: 27 core, 13 fade (12 RAM e 1 layout), 16 interop; many compila 60/60. I blocchi non sono misure né punteggi zero.

Le 177 ricompilazioni conservano PRG e mappe complete dei simboli numerici. L’eredità delle misure richiede anche identità delle condizioni. Solo many a 64× ha tre ripetizioni; le altre celle hanno una esecuzione. Non è una nuova campagna con tre ripetizioni per ogni cella.

Target originale VICE Turbo6510 PAL, SID originale attivo, nessuna REU, 1×/20×/64×. Core/fade/interop: 128 eventi IRQ di warm-up (circa 2,53–2,55 s effettivi), poi 1024 refresh (circa 20,429 s). Many: 129 eventi e almeno 128 periodi PAL completi di warm-up; a 1× 16384 refresh per scene fisiche/mappe o 32768 per scene angolari; a 20×/64× 2048 refresh. Gli FPS contano nuove viste complete sul tempo macchina emulato; intervalli p95/peggiore sono conservati per cella. Nessun campionamento live durante le misure.

Indice storico, prima stabile 1.15.0=100: la 1.20.0 conserva 137,505630. È una stima ricostruita ereditata, non un indice canonico validato: il controllo storico è ancora bloccato dall’hash PowerShell. L’indice esteso separato conserva 100 rispetto al proprio riferimento congelato, identificato dal registro; non viene riancorato alla numerazione pubblica della release. Pesi, scene, ancoraggi e gestione dei blocchi restano invariati.

Nessuna nuova misura FPS, prova hardware o qualifica NTSC è implicita. [Protocollo](TESTING.it.md) · [Casi d’uso del fade](DISTANCE-FADE.it.md#quando-conviene-usare-distance-fade).
