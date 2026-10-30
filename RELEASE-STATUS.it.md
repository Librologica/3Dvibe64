# Stato release e supporto — 1.15.1

**Release stabile1.15.1 di soli sorgenti, promossa dalla dev consegnata agentic17 e pubblicata su GitHub.**
Release/download: [v1.15.1](https://github.com/Librologica/3Dvibe64/releases/tag/v1.15.1). [RELEASE.json](RELEASE.json)
è lo stato canonico. Release ufficiali precedenti e demo congelate sono preservate.

Lo ZIP contiene renderer, moduli riutilizzabili, strumenti host e documentazione;
nessun progetto demo, scena, asset, musica, PRG, cattura o dipendenza. I generatori
API possono creare progetti solo su invocazione esplicita dell'utente; nessun
progetto generato è allegato.

Renderer e API coincidono byte per byte con agentic17. La qualifica stabile
ricompila il catalogo completo:54 programmi a1/20/64× e27 casi già bloccati.
Si riusano soltanto osservazioni di PRG ed etichette numeriche identici; valori
FPS/p95/peggiore e segnalazioni originali restano conservati.
[Qualifica](QUALIFICATION-1.15.1.it.md).

Sono qualificati i profili benchmark PAL Turbo6510 misurati e le API4/6, non
qualsiasi combinazione di renderer e opzioni. Nessuna nuova qualifica su NTSC
stock, hardware C64 fisico o altri host. I rapporti versionati valgono per i
programmi originari. Normalized16 e gli adattatori gameplay opzionali restano
moduli sperimentali separati; il pacchetto stabile non ne amplia i contratti.

Le guardie64KB restano attive: combinazioni sovradimensionate o non supportate
sono rifiutate. Mode7 a1× conserva il compromesso temporale già documentato,
senza eliminare celle dall'indice. Il caso validation4/1× conserva la segnalazione
della finestra breve e la diagnosi su finestre lunghe.

[Input esterni](EXTERNAL-INPUTS.it.md) · [Test](TESTING.it.md) · [Documenti](DOCS.md)
