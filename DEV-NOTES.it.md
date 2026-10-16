# Provenienza dello sviluppo — 1.11.0

Questa è la release ufficiale locale derivata dalla dev13/cubes-restored,
non uno snapshot dev12 incompleto. La dev originale e le release precedenti
restano preservate. La pubblicazione online è rinviata.

Dev1: importazione sorgenti mascherati/contornati; dev2: shader per faccia;
dev3: entità configurabile/eventi/collisioni locali; dev4: porta/passabilità;
dev5: due billboard con asset condiviso; dev6: frame texture/scorrimento UV;
dev7: bake statico; dev8: PVS conservativo per connettività; dev9: mesh sorgente
condivisa; dev10: clip controllate/roll; dev11: gruppi esterni; dev12: formato
livello/budget; dev13: integrazione separata, corretta conservando tutti i cubi.

Le fasi mantengono l’ambito dei profili. Renderer ordinario e Mode 8 conservano
byte/default 1.10.2; foundation-1.10.2 resta sigillata. Lo span preciso della
1.10.3-dev1 è un input esplicito del solo adattatore Underworld, non un merge
universale. Il riuso UI attuale è 2904 byte, non i 1516 iniziali. WORLD-01 non
applica ancora il proprio recupero ipotetico 3759 byte né combina tutti i moduli.

La release completa manuali EN/IT, collegamenti, pacchetto solo sorgenti e
configurazione degli strumenti host. I preset indicano 1.11.0; la compatibilità
runtime si verifica con hash dei programmi, non con l’etichetta della versione.
Nessun eseguibile demo/video/musica è distribuito. Prove, limiti e politica di
evidenza: [qualificazione](QUALIFICATION-1.11.0.it.md). Uso corrente:
[GAMEPLAY](GAMEPLAY.it.md); lavoro rimanente: [roadmap](ROADMAP.it.md).
