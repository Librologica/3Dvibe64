# Qualificazione — correzione distribuzione 1.11.0

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

## Ambito delle verifiche

Risultati correnti in [QUALIFICATION-1.11.0.json](QUALIFICATION-1.11.0.json).
Controlli su input esterni espliciti/rifiuto anticipato, schemi e grafi
sintetici, identità emissione assembly billboard, manifest/esclusioni,
link e CLI EN/IT e contratto ordinario del pacchetto con prove native.
Gli 80 file runtime/generatori ordinari conservano i byte della 1.10.2.
Conservati gli esempi preesistenti; il loro README è ripristinato dalla v1.10.2.
Demo private di sviluppo e release ufficiali precedenti preservate.

La pubblicazione iniziale 1.11.0 aveva qualificato 41 gate e 15 ricostruzioni
private: è una registrazione storica, non indica demo ancora distribuite o
ricostruibili senza input esterni. La correzione riesegue i contratti host e
di distribuzione modificati e build native rappresentative con input esterni
espliciti. I gate renderer invariati riusano le identità già verificate di
sorgenti/runtime. Nessun nuovo renderer, FPS o PRG demo consegnato. Le misure
native valgono soltanto per gli esatti PRG e condizioni originarie.
Linux e hardware fisico non nuovamente qualificati.
