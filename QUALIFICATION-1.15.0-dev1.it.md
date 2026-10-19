# Qualifica nativa — 1.15.0-dev1

Dev non pubblicata, basata sulla stabile1.14.0. La promozione GitHub stabile resta un passaggio futuro. Nuove opzioni limitate al Mode4 legacy-plus; default legacy/plus/Q8 conservati. Solo SDK sorgente, senza demo o media. [Opzioni](EXACT-RENDER.it.md) · [Dati strutturati](QUALIFICATION-1.15.0-dev1.json).

Target VICE Turbo6510 PALx64, presentazione safe, Colodore/filter0, fixture silenziose con audio disattivato. Warm-up128eventi simulati; intero percorso automatico2048tick, circa40,8secondi emulati. Hash di scena/movimento e target identici prima/dopo. Solo nuove viste complete, contatore e trace concordi; warp, tempo host e replay CPU non misurano gli FPS. Warm-up/durata individuali, p95/peggiore, hash e otto finestre del percorso sono nel JSON; comandi completi, timestamp, log e RAM restano esterni.

|Caso|FPS prima|FPS dopo|Variazione|p95 dopo ms|Peggiore dopo ms|
|---|---:|---:|---:|---:|---:|
|m4-camera|25.3315|50.1245|+97.87%|19.950|19.950|
|m4-clipping|47.5359|47.6827|+0.31%|39.901|39.901|
|m4-material-camera|47.2855|50.1245|+6.00%|19.950|19.950|
|m4-shared-camera|46.3065|50.1245|+8.25%|19.950|19.950|

146 pose native a input identici: immagini RGB complete identiche pixel per pixel. Si lasciano completare3viste e si parcheggia temporaneamente il PC principale in un salto a se stesso gia presente, mentre IRQ/VIC avanzano per3eventi raster0PAL. Ripresa solo dopo l'uscita dall'IRQ. Nessuna modifica a codice o framebuffer e nessuna nuova vista contata durante il parcheggio. Il metodo completa la scansione della palette; le precedenti catture senza parcheggio restano diagnostiche, escluse dalle prove promosse. Questa acquisizione non misura FPS.

Callback6502 di correttezza: {'unsigned8Products': 65536, 'signedQ10Products': 4160, 'divisionsWithRemainder': 4060, 'exactRationalEdges': 5000, 'solidSpanEndpointPairs': 12880, 'vertexOutcodes': 3000, 'convexShapesIncludingSelfIntersections': 2005}. Nessun FPS ricavato dai callback. Verificati400pannelli come coppie di triangoli e400fan con il ripiego imposto dal controllo conservativo della palette ordinaria. Un harness compilato separato, con contratto esplicito di palette uniforme e FACE_MATERIAL_ACTIVE_ONLY=FACE_REFLECTIVITY_ACTIVE_ONLY=1, verifica il medesimo ramo eleggibile: 300fusioni su400fan e400coppie accettate. E una prova di correttezza dei callback, senza misura FPS o pretesa di accelerazione del profilo ordinario. La cache materiali supera 4024confronti dopo singole righe su screen/color RAM, inclusi intervalli disconnessi e i due buffer.

Illuminazione fissa esplicita: 50.1245FPS nativi su 40.858229secondi emulati; p95 19.950ms, peggiore 19.950ms. Il trace update_face_shade conferma zero ricalcoli dopo warm-up; le 33pose native conservano gli stessi array shade/fill inizializzati. E un'opzione estetica separata, senza equivalenza dichiarata con illuminazione mobile.

57programmi con opzioni nuove disattivate sono stati ricompilati identici alla stabile1.14.0:25plus,16legacy,16Q8. Le misure native ereditate restano valide per quei byte e condizioni invariati; i nuovi risultati derivano da nuove acquisizioni native. Inventari della stabile pubblicata e della baseline invariati. I rapporti storici sono conservati come tali, senza rinominarli in nuove misure.

Inclusi aritmetica esatta, ricorrenza dei bordi a resto byte, span srotolati/righe adiacenti, outcode condivisi e supporto conservativo per fan/pannelli convessi. La proiezione dei vertici era gia condivisa. Nessun percorso, modello navetta, camera di inseguimento, SID o asset di gioco inserito nell'SDK. La fusione automatica dei fan richiede il contratto compilato di materiale/riflettivita attivo uniforme, senza pigmenti fissi per faccia o proprieta celle VIC; gli altri casi conservano il fan completo. La luce congelata richiede oggetti non condivisi. Rimangono tutti i controlli di allocazione/assembler nei64KB ordinari.

Prima della pubblicazione stabile: revisione del contratto limitato e del diff, conservazione degli hash qualificati e controlli del pacchetto sorgente da estrazione pulita. I risultati dei gate pubblici del pacchetto esatto sono nella ricevuta di consegna esterna. Questa dev non esegue push, tag o release GitHub. Software PolyForm Noncommercial1.0.0; documentazione CC BY-NC4.0; attribuzione librologica.digital.
