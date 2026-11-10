# Agentic25 — 1.15.2-dev-agentic25

Sviluppo non pubblicato dalla dev agentic24 consegnata. [English](AGENTIC25.en.md).
Registro corrente: [QUALIFICATION-AGENTIC25.json](QUALIFICATION-AGENTIC25.json).
I registri precedenti restano storici immutabili. AnimatedMesh v1 e i sorgenti
runtime/API legacy-plus Mode1–7 mantengono i byte agentic24.

Il backend multi Mode8 sostituisce i profili proiettati in cache con un clock
second-chance limitato. Gli hit marcano lo slot come referenziato. In caso di
miss il clock azzera i flag incontrati ed espelle il primo slot non referenziato;
gli slot vuoti vengono accettati subito. L'espulsione invalida la vecchia chiave
prima di generare il nuovo profilo. Le voci complete/lazy mantengono l'identità
dello slot. Tutti i flag si azzerano per vista insieme alla cache esistente.

Restano32 profili /4096 byte. I32 byte nuovi di riferimento occupano soltanto
$ca00..$ca1f nella finestra layout_support $ca00..$caff preesistente, con guardie
assembler; nessun alias di buffer/scratch o finestra ampliata. Coefficienti/stato
totali480 byte, inclusi32 byte di sostituzione. Il codice resta sotto il limite
basso originale $3000. I template multi auto/interattivo applicano la politica;
mono-opaque e mono-portals mantengono la base. Proiezione, arrotondamenti,
campionamento lazy16 colonne, geometria, collisioni, camera, musica, font,
colori, pubblicazione, qualità e default conservano il comportamento originale.

Technical Debug legge solo in pausa, con PRG/label della stessa compilazione;
maincpu_clk è tempo macchina, non cicli interni CPU accelerata. Misure native
VICE Turbo6510 PAL1x/20x/64x, SID originale benchmark, warm128 e1024 refresh
(20,429s), solo viste nuove complete. Tre finestre uguali da81,716s a64x integrano
l'indice fisso. Casi e pesi performance-v1 restano invariati. Il replay CPU
verifica soltanto la correttezza. Holdout solo nella validazione finale.
Hardware e NTSC non sono nuovamente qualificati.

Build, riferimenti, trial rifiutati, catture, clock e comandi sono esterni alla
dev e allo ZIP di soli sorgenti, in
3Dvibe64_Verifiche_1.15.2-dev-agentic25_2026-11-04. Nessuna demo, scena, modello,
musica, PRG o progetto di validazione allegato. Nessuna promozione stabile o
pubblicazione GitHub richiesta. Il registro definisce il perimetro verificato.

Verifica finale:54 casi compilabili /162 celle native,648 catture identiche,27 blocchi ereditati e0 nuovi. Indice fisso 130.594894169; parent 129.982745981; stabile1.15.1 117.647645352. StressMode8 a64x: FPS 37.593407 → 46.991758 (+25.000%); tempo render medio +0.819%. Tre finestre uguali da81,716s per lato confermano il throughput.5120 richieste cache emesse coincidono con la base e conservano gli invarianti slot/chiavi. Superati22 test pubblici predefiniti. Margine codice basso multi auto canonico:6 byte; interattivo:1210 byte. Misure native auto a1/20/64x; interattivo assemblato/cache condivisa verificata, senza nuova misura nativa. Mono e Mode1–7 conservano i programmi della base. Pacchetto di417 sorgenti, verifiche esterne.
