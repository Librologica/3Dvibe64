# 3Dvibe64 1.15.2-dev-agentic19

Sviluppo non pubblicato dalla dev agentic18 consegnata. Qualificazioni precedenti
e documenti AGENTIC18 restano storici immutabili. Qualificazione corrente:
QUALIFICATION-AGENTIC19.json. Nessuna release, tag o promozione GitHub.

Technical Debug, tramite vice_link.py, individua costi nella gestione delle celle
materiale e nella preparazione del raster. La diagnosi usa breakpoint persistenti,
profiler nativo e stopwatch letto solo in pausa. maincpu_clk misura il tempo
macchina PAL, non i cicli interni della CPU accelerata. Questi tempi non sono FPS.

Le scritture materiale note usano direttamente la colonna in Y e puntatori alla
base della riga screen/colore. I filler ricavano la seconda riga fisica dalla
prima solo se le tabelle emesse provano row1=row0+1 e basi/offset pari. I filler
solidi, a pattern e diretti selezionati leggono inoltre le tabelle di riga dopo
la gestione del materiale, evitando copie temporanee. Forme sconosciute
mantengono il codice della base. row0lo/hi,row1lo/hi e i puntatori materiale sono
scratch privati volatili in tali filler; API pubblica e pixel restano uguali.
Nessuna nuova variabile RAM, tabella, allocazione di stack o finestra di memoria.

Opzioni predefinite, qualità, scene, percorsi, musica e pesi dell'indice restano
invariati. Benchmark e dati diagnostici restano esterni all'SDK, in ../evidence/.
I tre test riservati alla pubblicazione stabile restano conservati; per questa
dev sono richiesti20 controlli renderer/API e la verifica separata dei metadati
e documenti. Il test di distribuzione richiede questa precisa versione dev;
gli hash legacy-plus sono controllati sul registro corrente scelto da RELEASE.

Native validation complete / Verifica nativa completata:54 cases at1/20/64x,
648 matching captures,27 existing build blocks,0 new blocks. Fixed index
121.110691904; agentic18=120.207624484; stable1.15.1=117.647645352;
anchor1.15.0=100. Three runs per side on3 targeted cases,6 supplementary public
API runs. Warm128 PAL refreshes then1024refreshes (~20.429s), original SID active.
Original timing flags retained; unresolved0. See external REPORT.html/evidence.
Unpublished development / Sviluppo non pubblicato.
