# Qualifica della stabile — 1.20.0

Promozione stabile della agentic36, revisione documentale r1, pubblicata su GitHub. Il [registro JSON](QUALIFICATION-1.20.0.json) lega i sorgenti e le ricompilazioni ai risultati nativi originali. Evidenze grezze, comandi e programmi restano fuori dal pacchetto.

Copertura ereditata: 233 configurazioni tentate nelle modalità 1–8, pure e miste, a 1×/20×/64×. Sono compilabili 177 configurazioni, con 531 celle aggregate valide e 651 esecuzioni native originali. Restano 56 blocchi di compilazione preesistenti, cioè 168 celle indisponibili: 27 core, 13 fade (12 RAM e 1 layout), 16 interop; many 60/60. Non vengono contati come misure o risultati zero.

Per la promozione verificare sorgenti runtime identici, PRG identici e identità di tutti i simboli numerici delle ricompilazioni. Il registro riporta l’esito effettivo, i blocchi e i test eseguiti. L’eredità non equivale a una nuova campagna con tre ripetizioni per ogni cella: soltanto many a 64× conserva tre ripetizioni; le altre celle hanno una esecuzione.

Target originale VICE Turbo6510 PAL, SID originale attivo, nessuna REU, 1×/20×/64×. Core/fade/interop: 128 eventi IRQ di warm-up (circa 2,53–2,55 s effettivi), poi 1024 refresh (circa 20,429 s). Many: 129 eventi e almeno 128 periodi PAL completi di warm-up; a 1× 16384 refresh per scene fisiche/mappe o 32768 per scene angolari, a 20×/64× 2048 refresh. FPS da nuove viste complete e tempo macchina emulato; intervalli p95/peggiore conservati per cella. Nessun campionamento live durante le misure.

Indice storico, prima stabile 1.15.0=100: agentic36 137,505630 e stabile 137,505630, variazione 0%. Sono stime ricostruite ereditate, non indici canonici validati: il controllo storico è ancora bloccato dall’hash PowerShell. L’indice esteso indipendente conserva 100, ancorato alla prima consegna agentic36, ereditato per identità. Pesi, scene, ancoraggi e blocchi congelati restano invariati.

Nessuna nuova misura FPS, prova hardware o qualifica NTSC implicita. [Protocollo](TESTING.it.md) · [Limiti e scene fade](DISTANCE-FADE.it.md#quando-conviene-usare-distance-fade).
