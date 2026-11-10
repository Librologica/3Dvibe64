# Agentic36 — 1.15.2-dev-agentic36

Sviluppo Distance Fade non pubblicato, solo sorgenti, dalla agentic35 consegnata. [English](AGENTIC36.en.md). [Qualifica corrente](QUALIFICATION-AGENTIC36.json). Note e registri versionati precedenti restano storici; nessuna pubblicazione ufficiale o promozione stabile.

## Comportamento e compatibilità

Il manuale include [indicazioni per progettare le scene](DISTANCE-FADE.it.md#quando-conviene-usare-distance-fade), scegliendo il fade secondo distribuzione della geometria, modalità grafica e budget CPU.

Distance Fade resta opzionale e spento per default in tutte le Modes 1–8. Il JSON pubblico è `distanceFade: {mode,start,end}`; `mode` è `off` o `dither`, le distanze intere rispettano `0 <= start < end <= 32767` e le distanze esplicite richiedono dither. PowerShell conserva `-DistanceFade`, `-DistanceFadeStart`, `-DistanceFadeEnd`; i builder Python conservano `--distance-fade`, `--fade-start`, `--fade-end`. Il [contratto completo](DISTANCE-FADE.it.md) contiene esempi CLI/JSON verificati, default e vincoli dei backend. Nessun nuovo ingresso applicativo o campo di configurazione; gli input esistenti non richiedono migrazione.

Modes 1–7 conservano la metrica euclidea dell'origine dell'oggetto: estensione del segno prima della sottrazione, valore assoluto della differenza Q8, troncamento di ciascun asse alle unità mondo intere, quadrato/somma con l'intervallo originale a 40 bit, stessi 17 stati di copertura. Livello 16 opaco,1–15 Bayer multicolor invariato,0 esclusione. Un oggetto parziale conserva costi di trasformazione/raster; soltanto l'esclusione completa evita la costruzione nativa della geometria. Raggio mesh e profondità dei singoli vertici non sostituiscono questa metrica.

Il LOD texture Mode7 resta indipendente, sui profili Q8 perspective già supportati. Fade OFF/ON e LOD texture OFF/gradual funzionano da soli o insieme. Restano TextureLODNear/TextureLODFar, profondità dei vertici originali, pigmenti, illuminazione, sampler e precisione. Il bench many Mode7 usa intenzionalmente affine/unlit-A con LOD OFF; la matrice perspective separata conserva entrambi i profili 40..56 e 28..44. Sono carichi distinti, non shader intercambiabili.

## Decisione Mode8: mantenere il metodo esistente

Il fade Mode8 è mantenuto nei backend mono perimeter/apertures e multilivello, nei template automatici e interattivi. Restano API, unità in celle, distanza conservativa dalla normale del piano,17 stati, frazioni della camera, campioni top/bottom, attraversamento DDA e pixel Bayer. Il fade non termina il DDA alla distanza configurata. Una parete laterale vicina può restare vicina nei tratti lontani: le esclusioni per origine delle Modes 1–7 non predicono quelle della mappa. Nessuna richiesta viene trasformata silenziosamente in OFF.

Technical Debug ha identificato la classificazione ripetuta dello stesso piano come costo importante nel multilivello. Una tabella privata da 128 byte conserva i livelli solo durante la vista composta corrente. Una chiamata esistente di inizializzazione della cache posa/unità viene sostituita con un wrapper della stessa dimensione che invalida tutte le 128 celle prima della composizione, dopo il latch della posa. Il preprocessore normale emette piani nel dominio X/Y esistente. Più chiavi di altezza/profilo possono riusare il livello del piano; non si memorizzano nuove proiezioni, vertici, fotogrammi o geometria della vista precedente. Il movimento della camera non riusa livelli vecchi.

Il wrapper dei profili evita salvataggi superflui di Y/stack perché gli helper di distanza non modificano Y; conserva chiave e stato X necessario in memoria privata foreground. Restano ABI e chiamanti di get_profile; i flag di stato restano clobbered. I riempimenti scalari parziali elaborano le quattro fasi ripetute del Bayer a passo quattro, scegliendo maschera/colore una volta per fase. Ogni byte riceve la stessa fusione mascherata precedente. Intervalli vuoti/invertiti, rami zero/pieno, altre lane, bordi, colori e clipping sono verificati con test compilati e confronti nativi. Il mono e i programmi emessi restano invariati da questa ottimizzazione multilivello.

L'helper multi occupa 920 byte contro 723 della35, nel medesimo payload riservato di 2449 byte; il mono resta 766. Non si ampliano riserve, finestre/ordine/budget dell'allocatore, hook del codice basso, bitmap o guardie. Il budget stretto del template multi-auto pubblico è conservato. La RAM insufficiente resta un errore esplicito, senza fallback di precisione/qualità. Il reset per vista di128 byte ha un costo fisso: il guadagno dipende dalla richiesta di piani/profili, senza promessa universale.

## Aritmetica poligonale e proprietari wire

Un asse intero assoluto almeno pari a `end` implica già distanza quadrata totale almeno `end²`: può restituire livello0 prima di quadrati inutili. I fattori accettati usano una larghezza esatta derivata da `end` in compilazione, conservando sottrazione firmata senza wrap, troncamento Q8 e accumulatore completo. Non si introduce una distanza approssimata o precisione ridotta. Restano esatti transizioni, estremi lontani e contratto registri/flag dei writer/setter che sostituiscono STA.

Le mesh wire esplicite usano intervalli di spigoli in active_face_first/end. Questi non vengono più scritti nella tabella dei proprietari delle facce poligonali. La tabella viene popolata solo per mesh poligonali; le istanze wire conservano il loro livello e writer normale. Si corregge la sovrascrittura della35 e si protegge l'associazione nei misti. I vecchi risultati corrotti/neri sono baseline invalide, non guadagni prestazionali.

## Perimetro delle misure

La qualifica usa core integrato, estensione fade originale, due famiglie da 60 oggetti, nuovo corridoio, interop misti e holdout finali. Snapshot SDK, hash PRG/simboli/strumenti, argv, clock, RAM, immagini, conteggi di lavoro, tempi render, p95/peggiori e fasi/pose effettive restano esterni e indicizzati nel registro corrente. Le catture Mode8 conservano l'output; il metodo non è stato sostituito o rimosso. Il rapporto distingue misure nuove, ereditate per equivalenza dei programmi e casi invalidi/bloccati.

Target nativo: VICE Turbo6510 PAL1×/20×/64×, SID originale attivo, nessuna REU. Warm-up secondo il protocollo del componente e la correzione verificata sui clock riportata sotto. Core/fade/interop: 1024 refresh misurati (20,429114 s). Many:1× physical/map 16384 (326,865829 s),1× angular 32768 (653,731657 s),20×/64× 2048 (40,858229 s); tre ripetizioni64×, una alle altre velocità. Contano solo nuove viste complete; duplicati VIC, host/warp e replay CPU non diventano FPS. Il tempo render può migliorare con FPS fermi sul gradino PAL. Le ripetizioni deterministiche non sono campioni statistici indipendenti. Le prove lente1× possono mostrare solo parte delle pose scritte.

Le sessioni Technical Debug sono separate, con PRG/simboli abbinati e senza polling live. Stopwatch/profiler usano maincpu_clk, non cicli interni inventati moltiplicando per64. I test compilati di aritmetica/cache/scritture verificano correttezza, mai FPS. Le build supplementari dei template pubblici/Gouraud/normalized verificano capacità/API, senza confronti prestazionali SID. La vecchia qualifica silent35 resta un protocollo separato. Nessuna nuova qualifica hardware reale o NTSC.

## Due serie di indici e riproducibilità

Lo storico `3dvibe64-performance-v1` conserva prima stabile 1.15.0=100, paniere fisso da 12 casi, formula, pesi e serie passata. Il 137,50563008162632 della35 è una stima ricostruita ereditata per default-OFF; il canonico resta bloccato dal diverso hash PowerShell. I nuovi fade non entrano nella serie. Il registro corrente riporta base/nuova dev/delta ed equivalenza effettiva dei programmi; nessuna stima viene rinominata validata.

L'esteso separato `3dvibe64-extended-performance-v1`, specifica 1.0.1, parte dalla prima agentic36 consegnata=100 con identità immutabili di sorgenti/runtime/programmi/baseline. Prima della valutazione è stato congelato il paniere 12 core + 56 fade già validi + 60 many, bilanciato per modalità, famiglia, velocità e FPS/tempo render nativi. L'interop aggiuntivo è validazione finale, fuori dal punteggio. Mancanze, dati invalidi o capacità eliminate bloccano il totale, senza FPS zero, sostituzione con OFF o rinormalizzazione. Debug Suite e holdout non aggiungono punti. Il registro SDK indica definizione, baseline e rapporti esterni congelati.

L'integrazione è `3Dvibe64_BenchmarkSuite_Extended_1.2.1_2026-11-10`, con SDK parametro e istruzioni ITA/ENG/AI. A ogni nuova dev/release verificare allineamento e confronto con la precedente. Preservare stabili, demo congelate, suite originali e SDK35. L'SDK non contiene scene demo, modelli, musica, PRG compilati o catture; i test creano kernel temporanei. Le evidenze dei benchmark restano esterne alla consegna engine.
## Correzione osservatore1.0.1

Many richiede almeno128 periodi PAL completi dal primo render-begin: il runner corretto osserva129 ingressi IRQ e verifica il clock nativo effettivo.35 e36 vengono rimisurate con la stessa correzione; i tempi legacy128-edge restano separati. Core/fade/interop conservano128 ingressi IRQ (~2,53–2,55s), con durate effettive verificate. Formula, casi, pesi e finestre misurate invariati. Formula/paniere1.0.0 precedono la selezione; la correzione strumentale1.0.1 precede la qualifica finale abbinata.

Il campo esistente nelle ricevute build Mode8 `distanceFade.levels:16` indica il livello massimo, non il numero di stati di copertura:0..16 sono17 stati. Non serve migrare scene o opzioni.
