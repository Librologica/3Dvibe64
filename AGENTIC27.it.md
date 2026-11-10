# Agentic27 — 1.15.2-dev-agentic27

Sviluppo non pubblicato dalla dev agentic26 consegnata. [English](AGENTIC27.en.md).
Registro corrente: [QUALIFICATION-AGENTIC27.json](QUALIFICATION-AGENTIC27.json).
Note e registri versionati precedenti restano storici immutabili. API invariata.

Gli spigoli wire proiettati non orientati usano un clipper a due estremi,
evitando i passaggi del poligono chiuso e le intersezioni duplicate. Restano
ordine destra/sinistra/alto/basso e helper originali per classificazione,
intersezioni, rapporti, prodotti e arrotondamenti. Una coppia di bordi si salta
solo se entrambi gli estremi originali sono sicuramente interni: interpolare
coordinate già comprese nell’intervallo non può portarle fuori. Geometria
visibile, rifiuto e degenerazione delle linee sono conservati, senza approssimare.

Le copie di chiusura del poligono possono ruotare l’ordine privato degli estremi;
la nuova coppia può risultare invertita. I tre chiamanti riconosciuti disegnano
o accodano uno spigolo non orientato; il rasterizer normalizza Y e X orizzontale.
Un controllo dell’intero contesto dei chiamanti conserva la base per consumatori
privati sconosciuti. Carrier Gouraud/UV e contesti lps_active non interi mantengono
la base. Clipper dei poligoni/near e regole sui cap generati restano intatti.
L’oracolo CPU confronta geometria e bitmap reali, screen/color RAM e dati dirty,
non il solo ordine degli estremi. Il replay CPU non produce FPS.

I profili misti solidi usano l’allocatore plus delimitato originale e il suo
fallback. Wire1/2 collocano il solo nuovo helper dopo il tuning wire/raster,
in un sottoinsieme delle finestre originali,0801..2000 e4000..5c00. La misura
usa la mappa assembler effettiva; esclude interi bitmap, screen, font, buffer
runtime e LUT dei prodotti wire. Se manca spazio resta la base. Nessuna finestra,
tabella dati, variabile privata o alias scratch nuovi. Il codice helper occupa
RAM reale: intervalli e byte effettivi sono nel registro. Mode2 può mantenere
la base se manca il contratto degli helper proiettati Q4. Mode8, AnimatedMesh,
qualità, carichi, default, musica, colori, camera, geometria, copertura delle
linee e pubblicazione delle viste complete mantengono il comportamento ereditato.

Qualifica nativa VICE Turbo6510 PAL1x/20x/64x, SID originale benchmark,128 refresh
warm-up e almeno1024 misurati (~20,429s), percorso16 pose, sole viste nuove
complete. Repliche mirate e finestre lunghe a64x integrano performance-v1 con
gli stessi12 stress/36 celle, riferimento e pesi. Technical Debug legge solo
in pausa con PRG/simboli della stessa build: maincpu_clk è tempo macchina PAL,
non cicli CPU interni accelerati. Holdout solo nella verifica finale.
Hardware e NTSC non sono nuovamente qualificati.

Dev e ZIP contengono solo sorgenti/documentazione: nessuna demo, scena, modello,
musica, PRG, cattura, SDK di riferimento o progetto di validazione. Tutto questo,
inclusi trial rifiutati, comandi e tempi grezzi, resta in 3Dvibe64_Verifiche_1.15.2-dev-agentic27_2026-11-05.
A ogni dev/release verificare allineamento suite e confronto con parent e stabile1.15.1.
Nessuna pubblicazione o promozione stabile autorizzata.

Qualifica finale:81 ricompilazioni,54 casi compilabili /162 celle native,648 catture identiche alla base,27 blocchi ereditati e0 nuovi.22 test pubblici predefiniti passati. Indice 134.675573998, parent 131.672274975 (+2.281%), stabile1.15.1 117.647645352. StressMode1 a64x 10.817894 → 12.531136 FPS (+15.837%), render medio -11.494%. Tre finestre uguali da81,716s a64x confermano +15.968% FPS; tre da326,866s a1x danno 0.204977 → 0.235571 FPS (+14.925%). L’indice originale usa ancora20,429s a1x e resta quantizzato: le finestre lunghe lo integrano, senza sostituirlo.16512 coppie di clipping conservano geometria/rifiuto, incluse512 chiamate di fallback non intere;4047 coppie intere visibili mantengono bitmap completi, screen/color RAM e dati dirty con quattro pattern.951 inversioni interne degli estremi conservano il rendering.695 byte di codice helper più3 di trampolino, nessun nuovo stato/tabella; intervalli effettivi nel registro. Technical Debug posa0:82039 →72675 cicli macchina. Mode8/AnimatedMesh ereditati.424 file di sorgenti/documentazione, prove soltanto esterne.
