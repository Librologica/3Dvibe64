# Qualifica nativa — 1.15.0-dev2

Dev locale non pubblicata. [Contratti delle nuove API](REUSABLE-RENDER.it.md) · [Dati completi](QUALIFICATION-1.15.0-dev2.json) · [Qualifica precedente](QUALIFICATION-1.15.0-dev1.it.md).

VICE Turbo6510 PAL, moltiplicatore64, launcher reale, presentazione safe, Colodore/filter0. Fixture silenziose, nessun SID, audio disattivato. Warm-up128eventi simulati; percorso automatico2048tick, oltre40secondi emulati. Si contano solo nuove viste complete dopo lo scambio, senza refresh duplicati. Nessun tempo host, warp o replay CPU usato come FPS. Scene, moto e condizioni uguali per ogni coppia; hash, warm-up/durate individuali, comandi, timestamp, log e RAM nei rapporti esterni.

|Prova|FPS prima|FPS dopo|Variazione|p95 dopo ms|Peggiore dopo ms|
|---|---:|---:|---:|---:|---:|
|m4-camera|50.1245|50.1245|+0.00%|19.950|19.950|
|m4-clipping|47.6827|47.6827|+0.00%|39.901|39.901|
|m4-clipping-wire-API|9.5988|12.2130|+27.23%|99.752|99.752|

Le prime due coppie confrontano gli `all` delle dev1/dev2. Confermano l'assenza di regressioni: non mostrano un guadagno FPS aggiuntivo su queste scene. La terza esercita64linee wire in movimento per vista, con materiali nativi e3vertici aggiornati tramite API stream in entrambe le versioni. Confronta il tracciatore connesso scalare completo a16bit con il kernel wire ottimizzato: non è una misura della navetta né un guadagno attribuibile al solo stream. La durata di misura può differire di meno di un refresh per l'allineamento ai confini delle viste.

127pose native a input identici: immagini RGB complete identiche pixel per pixel. Dopo3viste complete il PC principale viene parcheggiato nel salto a se stesso già presente mentre IRQ/VIC completano3raster0PAL; poi riprende. Nessun codice o framebuffer modificato; questa acquisizione non misura gli FPS.

Verifiche6502 separate, senza FPS:8.036bordi interi contro il percorso originale;1.225linee contro sia un oracolo per punti sia il codice scalare nativo, su bitmap e materiali dei due buffer;1.500vertici contro il produttore nativo originale, inclusi near e indici invalidi. Codec:4.867campioni originali ricostruiti esattamente e5.632chiamate al decoder nativo, con tutti gli allineamenti, range signed16 completo, dati oltre256byte e indici invalidi.

57programmi legacy/plus/Q8 ricompilati con nuove opzioni disattivate restano identici alla stabile1.14.0. Le relative misure storiche valgono per byte e condizioni invariati. Le API restano opt-in; nessuna modifica a release, demo o video precedenti, nessun push/tag/release GitHub. Gli esperimenti falliti e il riferimento wire2 con copertura incompleta restano diagnostici, esclusi dalle prove promosse. Lo ZIP contiene soltanto sorgenti e documentazione; i gate dell'estrazione esatta sono registrati nella ricevuta esterna.
