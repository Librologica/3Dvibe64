# Agentic26 â€” 1.15.2-dev-agentic26

Sviluppo non pubblicato dalla dev agentic25 consegnata. [English](AGENTIC26.en.md).
Registro corrente: [QUALIFICATION-AGENTIC26.json](QUALIFICATION-AGENTIC26.json).
I registri versionati precedenti restano immutabili. Mode1â€“7 e AnimatedMesh v1
mantengono i sorgenti runtime/API della base. API pubblica, qualitÃ  e default invariati.

Mode8 multi condivide il profilo proiettato interamente nullo. Quando proiezione
e clipping originali dimostrano che un profilo in cache Ã¨ tutto zero, la chiave
riceve il marcatore $fe e lo slot ordinario viene liberato. Le richieste successive
leggono un unico profilo immutabile da128 byte. I32 slot ordinari /4096 byte
mantengono la politica second-chance per gli altri profili. Le chiamate complete
con lazy_mode=0 riempiono ancora la destinazione originale. Resta il reset della
mappa a ogni vista. Il getter tratta Y come scratch volatile: tutti i chiamanti
riconosciuti inizializzano Y prima di leggere. Le chiavi nulle non sono espulse.

Tabella nulla da128 byte e helper da24 byte occupano $ca20..$cab7, dopo i32 flag
ereditati, nella finestra layout_support $ca00..$caff originale. Coefficienti/stato
totali608 byte, inclusi128 campioni condivisi; slot4096 byte e cache per piano da485
byte restano distinti. Nessuna finestra ampliata o alias scratch. Codice basso
entro $3000. Template multi auto/interattivo condividono lâ€™implementazione.
Mono, aritmetica di proiezione, geometria, campioni, font, colori, camera,
collisioni, musica e pubblicazione mantengono la base. Nessuna approssimazione.

Technical Debug legge soltanto in pausa con PRG/simboli della stessa build;
maincpu_clk Ã¨ tempo macchina PAL, non cicli CPU interni accelerati. Misure native
con lo stesso VICE Turbo6510, PAL1x/20x/64x, SID originale benchmark,128 refresh
warm-up e almeno1024 misurati (20,429s); contano solo nuove viste complete.
Tre repliche mirate e finestre lunghe integrano performance-v1, che conserva12
stress/36 celle, riferimento e pesi originali. Callback CPU solo per correttezza,
holdout solo nella verifica finale. Hardware e NTSC non nuovamente qualificati.
Il registro riporta il perimetro realmente misurato.

Build, scene, modelli, musica, PRG, catture, SDK di riferimento, trial e comandi
restano soltanto in 3Dvibe64_Verifiche_1.15.2-dev-agentic26_2026-11-05. Dev e ZIP contengono sorgenti/documentazione,
senza demo. Nessuna pubblicazione o promozione stabile. A ogni nuova dev/release
verificare allineamento della suite e confronto con dev precedente e stabile1.15.1.

Verifica finale:54 casi compilabili /162 celle native;648 catture identiche alla base,27 blocchi ereditati e0 nuovi.22 test pubblici predefiniti superati. Indice 131.672274975, base 130.594894169, stabile1.15.1 117.647645352. StressMode8 a64x 46.991758 → 50.124542 FPS (+6.667%), render -4.970%. Tre ripetizioni ordinarie a ogni velocità e tre finestre da81,716s a64x per lato confermano il risultato.5120 richieste cache su5 pose e1120 profili completi da128 campioni coincidono con la base; stack e invarianti slot/chiavi corretti. Technical Debug posa0:94 →86 miss,19623 →18243 cicli macchina. Margine codice basso canonico3 byte auto /1207 interattivo; layout support termina a $cab8. Auto misurato nativamente, interattivo assemblato/kernel condiviso verificato senza nuove misure native. Gli altri53 programmi benchmark e i sorgenti Mode1–7 sono identici alla base.420 file di sorgenti/documentazione, verifiche esterne.
