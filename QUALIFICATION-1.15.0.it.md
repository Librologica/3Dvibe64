# Qualifica della release stabile — 1.15.0

Release sorgente preparata in locale e non pubblicata. [Stato](RELEASE-STATUS.it.md) · [Dati strutturati](QUALIFICATION-1.15.0.json) · [Misure originali dev2](QUALIFICATION-1.15.0-dev2.it.md) · [Prima integrazione](QUALIFICATION-1.15.0-dev1.it.md).

## Provenienza e identità

La promozione dalla dev1.15.0-dev2, commit `ccc7d62a03d250a606f3aab6e246ba11af6bc94f`, modifica documentazione, versione, metadati e controlli host del pacchetto. Tutti i 127file runtime/configurazioni non documentali in work/ ed extensions/ mantengono gli hash della dev qualificata. I rapporti storici restano identici. Non è una nuova misura nativa: le acquisizioni sottostanti restano quelle della dev2. Identità dei PRG ricompilati dallo ZIP stabile e gate dell'estrazione esatta sono registrati nella ricevuta esterna di consegna.

## FPS conservati, non nuove acquisizioni

VICE Turbo6510 PAL×64, presentazione safe, Colodore/filter0, launcher reale delle fixture silenziose, nessun SID, audio disattivato. Warm-up128eventi simulati (2,55–2,63s); intero percorso automatico2048tick (40,838–40,874s emulati), senza fase stazionaria. Si contano solo nuove viste complete dopo lo scambio; contatore e trace concordi, refresh duplicati esclusi. Warp, tempo host e replay CPU non misurano FPS. Comandi, timestamp, RAM, hash e condizioni originali sono conservati nei report esterni della dev2.

|Prova originaria|FPS prima|FPS dopo|Variazione|p95 dopo ms|Peggiore dopo ms|
|---|---:|---:|---:|---:|---:|
|m4-camera|50.1245|50.1245|+0.00%|19.950|19.950|
|m4-clipping|47.6827|47.6827|+0.00%|39.901|39.901|
|m4-clipping-wire-API|9.5988|12.2130|+27.23%|99.752|99.752|

Le prime due coppie confrontavano `all` dev1/dev2: gli FPS restano invariati. La terza confrontava64linee wire mobili, più3vertici stream in entrambe le versioni, contro il tracciatore scalare connesso completo: +27,23% nella sola fixture nominata, non nella navetta e non come guadagno isolato dello stream. La prima integrazione aveva ulteriori confronti con la stabile1.14.0: rimangono nella qualifica dev1 con i propri hash e condizioni, senza mescolare i confronti.

## Grafica, numeri e limiti

127pose native a input uguali erano RGB identiche;3viste complete e3raster0PAL con main CPU parcheggiata nel salto già presente completavano la scansione palette. Nessuna modifica a codice/framebuffer; queste pose non misuravano FPS.57programmi default legacy/plus/Q8 ricompilati erano identici alla1.14.0. Callback6502:8.036bordi,1.225linee contro oracolo/scalare,1.500vertici contro produttore nativo; codec4.867campioni e5.632decodifiche native. Callback e conteggi di correttezza non sono FPS.

Nuove opzioni/API qualificate solo in Mode4 legacy-plus/walkLite/normal160×100/high-basic-v2/NoFpsOverlay,near8/poly,no Ground. Altri backend non sono implicitamente estesi. `all` esclude wire,stream,frozen-lighting. Fusioni di fan condizionate al contratto di palette, ripiego completo nelle fixture ordinarie; luce congelata è un'opzione estetica distinta. Moduli sperimentali conservano il proprio stato. Nessuna nuova qualifica NTSC,C64 stock o hardware fisico; RAM64KB non è una promessa di velocità su CPU standard. [ABI e limiti](REUSABLE-RENDER.it.md) · [Test](TESTING.md).
