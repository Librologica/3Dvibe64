# Note di rilascio — 1.13.0

Release stabile dei sorgenti engine pubblicata su GitHub. Aggiunge la pipeline opzionale `-Precision legacy-plus`
dalla dev7 qualificata. Legacy/default resta byte-compatibile. Q8, Normalized16,
Mode8, vecchia rotazione e adapter gameplay mantengono i propri ambiti; le
funzionalità sperimentali restano sperimentali.

Legacy-plus unisce rotazioni camera Q4/Q10 più fini, clipping wire corretto
degli spigoli sorgente, intersezioni near frazionarie e clipping schermo Q4.
Buffer geometrici interi originali e raster rimangono. L'espansione finale
del ciclo di arrotondamento elimina l'intervallo camera osservato da59,85ms
senza cambiare i risultati; massimo/p95 qualificati39,90ms. Camera nativa
25,06227FPS, clipping41,19121FPS su PAL Turbo6510 ×64.658 immagini native ferme
sono identiche alla dev6. I dati nativi si riusano soltanto dopo ricompilazione
esatta dei PRG misurati a partire da questa release.

Il pacchetto contiene solo sorgenti: niente demo, esempi, scene, percorsi,
progetti, disegni, musica, PRG, catture, log, eseguibili degli strumenti o ambienti
test. Rimangono template/font riutilizzabili dell'engine e piccole fixture
matematiche dei test. Il catalogo corrente IT/EN include tutti i profili legacy,
ABI, limiti, input esterni, test pubblici e qualificazione; i rapporti versionati
precedenti restano storici. Release e progetti congelati non vengono toccati.

[Contratto legacy-plus](LEGACY-PLUS.it.md) · [Qualificazione](QUALIFICATION-1.13.0.it.md)
[Guida rapida](QUICKSTART.md) · [Documentazione](DOCS.md) · [Test](TESTING.md)
