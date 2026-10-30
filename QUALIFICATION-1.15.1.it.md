# Qualifica nativa — 1.15.1

La promozione locale ricompila il catalogo fisso dal renderer/API della dev
consegnata agentic17, con VERSION stabile1.15.1. Tutti i54 PRG compilabili e
tutte le etichette numeriche coincidono;162 osservazioni native a1×/20×/64×
sono conservate per identità esatta. Restano27 blocchi preesistenti; nessuna
combinazione aggiuntiva è eliminata silenziosamente. Non è una nuova misura.

Lo snapshot di compilazione congela renderer/API/VERSION mentre documenti e
gate host erano in revisione; la consegna finale prova separatamente che tali
input coincidono. La [qualifica JSON](QUALIFICATION-1.15.1.json) contiene metriche,
hash dei programmi/comandi, perimetro supportato e segnalazioni.

## Condizioni native

VICE Turbo6510 PAL, musica SID originale a tre voci attiva. Warm-up128 refresh
(~2,553639s),1024 refresh misurati (~20,429114s), percorso originale16 pose.
Si contano soltanto nuove viste complete. FPS/p95/peggiore/latency provengono dai
cicli nativi conservati, non da warp, tempo host o replay CPU. Gli oracoli CPU
verificano maschere, materiali, wire, DDA shade, UV/luce e profili dei piani.

La qualifica sorgente comprende312 osservazioni principali e6 diagnostiche
lunghe; durante la ricerca furono acquisite486 run native, comprese varianti
scartate/superate. Non sono nuove acquisizioni della stabile.648 catture del
catalogo coincidono col parent; ripetizioni/API hanno identità proprie. Programmi
QA, scene, catture e tracce restano fuori dallo ZIP, con hash/versioni conservati.

## Limiti e segnalazioni temporali

27 combinazioni fallivano già su agentic17: la promozione non le corregge né le
dichiara supportate. Mode7/1× conserva il compromesso storico esplicitamente
accettato, senza cambiare pesi/dati. validation4/1× completa11 viste contro12
in20,43s; il flag grezzo−8,33% resta. Tre finestre di8 periodi per parte
(~163,43s ciascuna) producono93 viste/run senza regressione persistente oltre
soglia. Nessuna diagnosi sostituisce il dato originale. Le ripetizioni sono
deterministiche, non campioni casuali indipendenti o prove di significatività.

Nessuna nuova qualifica di C64 fisico, NTSC stock o Linux. I rapporti versionati
precedenti valgono per i PRG originari. La matrice corrente non copre qualsiasi
precisione, adattatore opzionale, timing hardware o forma di mappa. I campioni
API cerchi sono carichi separati silenziosi con SID emulato attivo: warm128,
2048 refresh misurati a1× e1024 a20×/64×; le osservazioni si conservano solo con
identità dei programmi API ricompilati sulla stabile.

## Indice fisso

La stabile1.15.0=100 resta l'ancora storica di performance-v1: una nuova stabile
non la reimposta. Il punteggio1.15.1 è117,647645 (+17,647645% composito), non un
aumento FPS universale.12 casi fissi/36 celle, pesi uguali per modi/velocità,
media geometrica50/50 FPS e inverso del tempo render.

| Modo | Indice composito | Guadagno vs1.15.0 |
|---|---:|---:|
| 1 | 111.882175 | +11.882% |
| 2 | 102.492792 | +2.493% |
| 3 | 112.287028 | +12.287% |
| 4 | 113.691539 | +13.692% |
| 5 | 118.911330 | +18.911% |
| 6 | 151.149649 | +51.150% |
| 7 | 127.243316 | +27.243% |
| 8 | 109.619698 | +9.620% |

## FPS nativi stress64×

| Modo | FPS medi | p95 intervallo ms | Peggiore ms |
|---|---:|---:|---:|
| 1 | 10.034698 | 99.752 | 99.752 |
| 2 | 10.034698 | 99.752 | 99.752 |
| 3 | 16.740814 | 59.851 | 59.851 |
| 4 | 16.740814 | 59.851 | 59.851 |
| 5 | 12.531136 | 79.801 | 79.801 |
| 6 | 16.447115 | 59.851 | 79.801 |
| 7 | 7.440362 | 139.652 | 139.652 |
| 8 | 37.593407 | 39.901 | 39.901 |

Tutti i valori1×/20×/64× e gli hash: [qualifica JSON](QUALIFICATION-1.15.1.json). [Test](TESTING.it.md) · [Stato](RELEASE-STATUS.it.md).
