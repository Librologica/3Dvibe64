# Agentic28 — 1.15.2-dev-agentic28

Sviluppo non pubblicato dalla agentic27 consegnata. [English](AGENTIC28.en.md).
Registro corrente: [QUALIFICATION-AGENTIC28.json](QUALIFICATION-AGENTIC28.json).
Note e registri versionati precedenti restano storici immutabili. API invariata.

La Mode7-C affine legacy-plus ordinaria conserva DDA intero UV/Q esatto,
copertura semiaperta e cap chiusi, formula luce/Bayer, indirizzamento texture e
stato UV/Q finale. Agli aggiornamenti ripetuti degli operandi immediati UV
sostituisce valori locali allo span in registri privati esistenti salvati,
precalcola i passi corretti e usa errori privati E-D modulo256. Il carry decide
la stessa correzione eliminando un confronto ridondante; Q usa lo stesso metodo.
Il core chiuso tiene U in X; il compositore usa Y per Q e lo scrittore parziale
usa Y per la fase del pixel. I quattro avanzamenti Q dei byte completi normali
sono inline; gli span a luce stabile conservano bande e pubblicazione Q differita.
Restano le cache del sampler per pagina texture/palette: viene eliminata la sola
sequenza di patch delle costanti UV. Nessuna approssimazione di interpolazione.

Tutti i16 byte privati presi in prestito sono salvati e ripristinati (base4).
Il fill riconosciuto salva una volta per faccia e chiama il core condiviso;
l’ingresso span autonomo resta protetto separatamente. Lo stato UV/Q mutabile
viene pubblicato prima dell’helper finale Q originale. Non sono allocati nuovi
indirizzi/alias globali zero page, variabili o tabelle persistenti. Il prestito
ha durata controllata; i byte non sono considerati globalmente liberi. Lo stack
ha un costo reale:16 byte salvati invece di4, nuovi indirizzi di ritorno dei
wrapper e un push temporaneo di A nel setup dei gate inline. Gli oracoli sul
codice emesso verificano bilanciamento, ripristino e interi bitmap di entrambi i
banchi. A/flag del fill privato sono volatili per i chiamanti riconosciuti;
API pubblica frame/AnimatedMesh e commit delle viste complete restano invariati.

Dieci contratti esatti delle regioni sorgente e l’insieme completo dei contesti
di chiamata privati abilitano il passaggio. Chiamanti/helper diversi o sconosciuti,
altri compositori e policy colore VIC conservano il passaggio Mode7 completo e
l’implementazione UV biased della base. Restano allocazione plus delimitata e
controlli assembler: nessuna finestra ampliata. Il codice occupa RAM reale e ogni
build a freddo deve superare i limiti della propria mappa. Clipper wire, Mode1..6/8
e AnimatedMesh conservano il comportamento della agentic27.

Qualifica: VICE Turbo6510 PAL1x/20x/64x, SID originale benchmark attivo,
warm-up128 refresh (~2,554s), almeno1024 misurati (~20,429s), percorso16 pose,
sole viste nuove complete. p95/intervalli peggiori, clock, comandi e hash di PRG
e label numeriche restano esterni. Technical Debug usa PRG/simboli della stessa
build, letture in pausa e nessun campionamento live: maincpu_clk è tempo macchina
PAL, non cicli interni CPU accelerati. Holdout solo nella qualifica finale.
Performance-v1 conserva12 stress/36 celle, pesi uguali per modalità/velocità e
50/50 FPS/inverso del render, stabile1.15.0=100. A ogni dev/release verificare
allineamento suite/adapter e confronto con parent e stabile1.15.1. Hardware e
NTSC non sono nuovamente qualificati. Il vantaggio dipende dalla distribuzione
di span e luce; la presentazione può quantizzare gli FPS anche con render minore.

Dev/ZIP contengono solo sorgenti/documentazione: nessuna demo, scena, modello,
musica, programma, cattura, SDK di riferimento o progetto di validazione. Tutti
i trial e le prove, inclusi quelli scartati, restano in 3Dvibe64_Verifiche_1.15.2-dev-agentic28_2026-11-05. Nessuna
pubblicazione o promozione stabile autorizzata. Misure finali nel registro corrente.

Il posizionamento usa anche directory temporanee host brevi (v0, v1, ...). Percorsi Windows lunghi impedivano a64tass di scrivere le label di misura; l’allocatore interpretava l’errore dello strumento come un layout non valido, selezionando silenziosamente una variante più lenta. Restano ordine delle strategie, budget60000 nodi, finestre RAM, matematica e qualità; i nomi completi restano nei report. La selezione ottimizzata non dipende più dalla lunghezza del percorso.

Qualifica finale:81 compilazioni a freddo,54 casi compilabili/162 celle native,648 catture identiche alla base,27 blocchi ereditati e0 nuovi.22 test pubblici predefiniti passati. Indice generale 135.434561314, base 134.675573998 (+0.564%), stabile1.15.1 117.647645352. StressMode7 a64x 8.272507 → 8.370407 FPS, render medio -5.770%. Tre finestre abbinate da81,716s a64x: 8.272507 → 8.358169 FPS (+1.036%), render -5.795%. Tre finestre da326,866s a1x: 0.137671 → 0.146849 FPS. Oracolo span:12880 coppie di estremi,17424 casi luce/fase; oracolo fill:256 facce/8218 righe, entrambi i banchi,16 byte ripristinati e stack bilanciato. Sono verifiche di correttezza, mai FPS.
