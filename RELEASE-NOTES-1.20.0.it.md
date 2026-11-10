# Note di release — 1.20.0

3Dvibe64 1.20.0 è una release sorgente stabile per le modalità grafiche 1–8, con documentazione italiana e inglese aggiornata. Pubblicata su GitHub.

## Novità

- Distance Fade opzionale nelle modalità 1–8, con 17 livelli Bayer, distanze configurabili e aritmetica Q8. È disattivato per default; il LOD texture della modalità 7 resta indipendente.
- Ottimizzazioni esatte del rendering: riutilizzo del lavoro su shading e materiali, campionamento affine delle texture, cache dei profili e dei livelli per piano nel backend multilivello della modalità 8. Riempimenti Bayer a passo quattro e calcolo della distanza poligonale riducono lavoro ripetuto; corrette le scritture dei proprietari wire.
- AnimatedMesh per clip di pose indicizzate e RuntimeScene per configurare funzioni opzionali di camera, visibilità e supporto alla simulazione, entro i profili e i limiti documentati.
- Guide complete per API, compilazione con input esterni, memoria e tipi di scena in cui il fade offre vantaggi o introduce un costo aggiuntivo.

Restano i default e i limiti dei singoli contratti. Non tutte le combinazioni di geometria e funzioni entrano nella memoria C64. Il pacchetto include sorgenti, documentazione e test di correttezza; nessuna demo, suite/driver di benchmark, musica o programma compilato.

[Guida rapida](QUICKSTART.it.md) · [Indice completo](DOCS.md) · [Distance Fade](DISTANCE-FADE.it.md) · [Qualifica e limiti](QUALIFICATION-1.20.0.it.md).

## Verifiche

I controlli sorgente e di correttezza della release sono superati. Le misure native VICE PAL Turbo6510 a 1×, 20× e 64× sono conservate per identità esatta del runtime e dei programmi; copertura, ripetizioni e configurazioni bloccate sono esplicite nel registro di qualifica. Questa revisione documentale non modifica il rendering né introduce nuove misure FPS. Nessuna nuova qualifica hardware o NTSC è implicita.
