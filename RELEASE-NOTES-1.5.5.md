# 3Dvibe64 1.5.5

## English

Maintenance release promoting the qualified Mode 8 lintel fixes:

- Clear `portal_inside` when leaving an overhead volume, before reading the
  following cell.
- Include front-plane identity (`fx_near_plane`) in adaptive edge refinement,
  alongside owner and exit plane; update the independent host oracle.

These are defensive correctness changes within the existing **mono-portals**
contract. They do not introduce arbitrary serial lintels, procedural generation,
world streaming or distance shading. The map validator and accepted map subset
are unchanged. Only the two mono-portals reference PRG identities change.
Mono-opaque and multi reference programs remain byte-identical.

Modes 1–7, materials, cameras, clipping and Q8 output are unchanged.
**Legacy remains the default and is not deprecated.** Q8 requires explicit
`-Precision q8`: recommended above 20 MHz; legacy at 20 MHz or below.
The existing [Q8 limits](PRECISION.en.md) still apply.

Each portal template adds 20 code bytes and no state RAM. PRG size is unchanged;
automatic/interactive low-code margins are 120/634 bytes. Paired instruction
measurements on 130 portal poses show +0.265% renderer cost, not a speedup.
All 189 qualified views across the three backends match both the original
bitmap and the host oracle. Stock x64sc PAL/NTSC checks include 118 snapshots
and six same-pose screenshot comparisons with zero pixel differences.
These are sampled tests, not exhaustive geometric or real-hardware verification.

The new package promotes only the qualified portal hashes; it does not rewrite
older releases. The public suite adds executed lintel invariant/bitmap checks.
See [tests](TESTING.md), [qualification](MODE8-QUALIFICATION.md) and
[memory](MODE8-MEMORY.md). Source SDK only: compile examples outside this tree.
No new features or rendering optimizations are introduced.

## Italiano

Release di manutenzione che promuove le correzioni qualificate alle architravi
della Mode 8:

- Azzera `portal_inside` all'uscita dal volume superiore, prima di leggere la
  cella successiva.
- Include l'identità del piano frontale (`fx_near_plane`) nel raffinamento
  adattivo dei bordi, insieme a proprietario e piano di uscita; aggiorna
  l'oracolo host indipendente.

Sono correzioni difensive entro il contratto **mono-portals** esistente.
Non introducono architravi seriali arbitrarie, generazione procedurale, streaming
del mondo o ombreggiatura a distanza. Validatore e mappe ammesse restano invariati.
Cambiano soltanto le identità dei due PRG mono-portals di riferimento.
I programmi mono-opaque e multi restano byte-identici.

Mode 1–7, materiali, camere, clipping e output Q8 sono invariati.
**Legacy resta il default e non è deprecato.** Q8 richiede `-Precision q8`
esplicito: consigliato sopra 20 MHz; legacy fino a 20 MHz inclusi.
Restano validi i [limiti Q8](PRECISION.it.md).

Ogni template con porte aggiunge 20 byte di codice, senza nuovo stato RAM.
Dimensione PRG invariata; margine low automatico/interattivo 120/634 byte.
Le misure delle istruzioni su 130 pose con porte mostrano +0,265% di costo del
renderer, non un'accelerazione. Tutte le 189 viste qualificate dei tre backend
coincidono con bitmap originale e oracolo host. I test x64sc stock PAL/NTSC
comprendono 118 snapshot e sei confronti screenshot alla stessa posa con zero
pixel differenti. Sono prove campionate, non esaustive né su hardware reale.

Il nuovo pacchetto promuove solo gli hash qualificati delle porte; le release
precedenti non vengono riscritte. La suite pubblica aggiunge test eseguiti delle
invarianti e bitmap delle architravi. Vedere [test](TESTING.md),
[qualificazione](MODE8-QUALIFICATION.md) e [memoria](MODE8-MEMORY.md).
Solo SDK sorgente: compilare gli esempi fuori dall'albero.
Nessuna nuova funzionalità o ottimizzazione di rendering.
