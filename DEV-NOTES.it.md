# Provenienza dello sviluppo — 1.11.0

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

Engine ordinario ed esempi preesistenti conservano i byte della v1.10.2. Le funzioni gameplay generiche restano in `extensions/gameplay`; i progetti specifici restano nella dev privata. La correzione non crea una nuova release/versione. Vedere [qualificazione](QUALIFICATION-1.11.0.it.md).
