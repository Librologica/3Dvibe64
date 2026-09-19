# Mode 8 memory / Memoria Mode 8

The source ASM and emitted `labels.txt`, `listing.txt`, `assembler.log` are the
authoritative per-build layout. The two backends do not share a single allocation
map. Load-image gaps are **not automatically free runtime RAM**: initialization
copies tables, creates the second font, clears bitmap memory and installs vectors.

ASM sorgente, `labels.txt`, `listing.txt` e `assembler.log` sono il riferimento
per ogni build. I due backend non condividono un'unica allocazione. I buchi
dell'immagine di caricamento **non sono automaticamente RAM libera**: l'init
copia tabelle, crea il secondo font, pulisce la bitmap e installa i vettori.

| Area | Use / Uso |
|---|---|
| `$0000–$00FF` | CPU port and explicitly named backend scratch/state / porta CPU e stato nominato nei sorgenti |
| `$0100–$01FF` | 6510 stack / stack 6510 |
| `$0200–$07FF` | Private tables; not KERNAL workspace / tabelle private, non workspace KERNAL |
| `$0801` | BASIC load header; entry `$080D` / header BASIC; ingresso `$080D` |
| Low code limit / limite | Mono `$2F00`, multi `$3000`; assembler/build guards / controlli assembler e builder |
| `$4000–$43FF`, `$CC00–$CFFF` | Screen RAM A/B; runtime overwrites initialization data / Screen RAM A/B; l'init sostituisce dati di caricamento |
| `$5800–$5FFF`, `$D800–$DFFF` RAM | 2,048-byte text fonts; second under I/O / font da 2.048 byte, secondo sotto I/O |
| `$6000–$7FFF`, `$E000–$FFFF` RAM | Bitmap banks and protected end regions / bitmap e regioni finali protette |
| `$6660`, `$E660` | Active viewport origins / origini viewport attiva |
| 4,608 bytes × 2 | 32×18 active bitmap cells / celle bitmap attive |
| 7,040 bytes × 2 | Full 40×22 body checked including margins / corpo completo controllato con margini |
| Color RAM `$D800` I/O | Set during initialization; separate from underlying font RAM / impostata all'init, distinta dal font sottostante |
| `$FFFA–$FFFF` | NMI/IRQ vectors: protected, not bitmap pixels / vettori protetti |

Multi-only: 4,096-byte profile cache, 448-byte coefficient/state allocation,
144 bytes of active fine-ray data in a 256-byte reservation. Its helper at
`$5500–$55BF` occupies 192 bytes. Key/event tables have byte identifiers and at
most 255 entries each; the per-ray path limit is a **different** capacity.
See [map limits EN](MAPS-2.5D.en.md) / [limiti mappe IT](MAPS-2.5D.it.md).

Solo multi: cache profili da 4.096 byte, coefficienti/stato da 448 byte,
144 byte di dati fine-ray attivi in una riserva da 256. Helper di 192 byte a
`$5500–$55BF`. Tabelle key/event con identificativi byte e massimo 255 entry
ciascuna; la capacità del percorso del singolo raggio è **distinta**.

The fixed layout retains a zero-filled reserved block at `$B000–$B990`; it is not
repurposed in 1.4.0. Foreground SMC is non-reentrant and disjoint from IRQ scratch.
Screen bytes 1000–1023, including sprite pointers, retain guard values. `$01`,
`$DD00` and `$D018` banking changes belong to the qualified split protocol.

Il layout mantiene una riserva azzerata a `$B000–$B990`, non riutilizzata nella
1.4.0. Lo SMC foreground non è rientrante e usa scratch distinto dagli IRQ.
I byte Screen RAM 1000–1023, inclusi i puntatori sprite, conservano guardie.
I cambi di banking `$01`, `$DD00` e `$D018` appartengono al protocollo split qualificato.

## Original automatic builds / Build automatiche originali

| Scene | PRG bytes | Low code bytes | Low margin bytes |
|---|---:|---:|---:|
| perimeter | 50,689 | 9,814 | 157 |
| apertures | 50,689 | 9,831 | 140 |
| two-levels | 49,665 | 10,151 | 76 |

PRG size includes zero-fill and load gaps: it is not total live RAM usage.
Interactive variants have their own source and build report. The normal map
workflow cannot change this layout or silently reduce precision to fit it.

La dimensione PRG comprende riserve e buchi di caricamento: non è la RAM viva
totale. Le varianti interattive hanno sorgenti/report propri. Il workflow mappe
non cambia il layout né riduce silenziosamente la precisione per farlo rientrare.
