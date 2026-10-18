# Note di sviluppo — 1.14.0-dev1

Dev engine locale separata dalla1.13.0, non pubblicata. Aggiunge legacy-plus Mode1–7 e Mode7 affine/prospettica senza geometria Q8. Selezione sempre esplicita; controlli legacy/Q8 e riferimento Mode2 plus originario invariati nei byte. Nessuna modifica a cartelle ufficiali/congelate o demo.

Gli adapter conservano le convenzioni raster native; il near/schermo Q4 trasporta UV/luce coerenti. UW/VW/W prospettici usano carrier16 bit delimitati e DDA texture comuni. Span half-open vuoti esclusi; helper solidi/Gouraud nella RAM realmente libera con guardie. Rifiuti di profilo/profondità/RAM espliciti.

[Build, ABI e vincoli](LEGACY-PLUS.it.md) · [FPS/stabilità nativi e regressioni](QUALIFICATION-1.14.0-dev1.it.md) · [test](TESTING.md). Le prestazioni camera Mode4 regrediscono rispetto a legacy; il costo prospettico dipende dalla scena. È un profilo dev qualificato, non l'estensione di ogni opzione legacy a plus.
