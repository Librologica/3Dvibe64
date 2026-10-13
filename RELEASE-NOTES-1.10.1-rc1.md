# 1.10.1-rc1 — maintenance candidate / candidata di manutenzione

Local prerelease; GitHub publication excluded. Public inputs remain compatible.
Historical release tags, assets and reference identities are preserved.

Corrected: Mode7 Q8 remote projection sign loss; flat light product overflow;
optional viewport contract/alias; effective CLI texture override with relative
PNG paths; native capture provenance; optimized Mode8 input checks; coincident
heading; package-exact test copies and native assembler-label paths; bounded
aligned placement fallback. Shared geometric multiplication and Gouraud emitted
instructions remain unchanged. Source LF normalization has a separate commit.

Qualification: 32 matched native Mode7 builds, 16 identical ordinary first views,
PAL/NTSC measurements after a two-second warm-up over at least 20 emulated
seconds, plus independent assembled numeric regressions. Q8 allocated payload
increases by 119–127 bytes in measured examples; all supported matrix builds fit.
New current references are justified only for legacy Mode7 flat and Q8 Mode7.
Full public gate results and exact FPS/p95/worst intervals are in the paired
[English qualification](QUALIFICATION-1.10.1-rc1.en.md) and
[numeric notes](NUMERIC-CORRECTNESS.en.md).

Deferred: the Mode8 adaptive visual approximation has an independent public
diagnostic. Stock PAL central-ray prototype costs 3.2→2.8 FPS (−12.5%); all-fine
costs 1.05 FPS. Runtime sampling remains unchanged; prototypes are external
evidence. Q8 retired-cache reservations measure 15/18 bytes and a broad layout
change is deferred. Actual Linux execution remains an open promotion gate.

## Italiano

Prerelease locale; pubblicazione GitHub esclusa. Input pubblici compatibili.
Conservati tag, asset e identità dei riferimenti storici.

Corretti: perdita del segno nella proiezione lontana Mode7 Q8; overflow luce
flat; contract viewport opzionale/alias; override CLI texture effettivo con PNG
relativi; provenienza catture native; vincoli input Mode8 con Python ottimizzato;
heading coincidente; copie test identiche al pacchetto e percorsi etichette nativi;
fallback di allocazione allineata con budget. Invariati prodotto geometrico
condiviso e istruzioni emesse Gouraud. Normalizzazione LF in commit separato.

Qualificazione: 32 build native Mode7 accoppiate, 16 prime viste ordinarie
identiche, misure PAL/NTSC dopo warm-up di due secondi per almeno 20 secondi
emulati, oltre a regressioni numeriche assemblate indipendenti. Payload Q8
allocato maggiore di 119–127 byte negli esempi misurati; tutte le build
supportate della matrice entrano in memoria. Nuovi riferimenti correnti
giustificati soltanto per Mode7 flat legacy e Mode7 Q8. Esiti pubblici completi
e FPS/p95/intervalli peggiori nei documenti di
[qualificazione](QUALIFICATION-1.10.1-rc1.it.md) e
[correttezza numerica](NUMERIC-CORRECTNESS.it.md).

Rinviati: approssimazione visiva adattiva Mode8 con diagnostica pubblica
indipendente. Prototipo raggio centrale stock PAL: 3,2→2,8 FPS (−12,5%);
tutto fine: 1,05 FPS. Campionamento runtime invariato; prototipi nelle prove
esterne. Riserve cache Q8 ritirate di 15/18 byte: nuovo layout generale
rinviato. Esecuzione Linux reale resta un gate aperto per la promozione.
