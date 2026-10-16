# 3Dvibe64 1.7.0 — Mode 7 fast profile

## English

This source SDK adds explicit `TextureQuality fast` / scene `textureQuality` to
Mode 7 Q8 perspective Gouraud C. It promotes reusable block8 projective endpoint
sampling, exact retained-row edge advancement, neutral shader bypass and upper
row reconstruction. Eight-pixel interiors remain affine; only 50 of the 100
logical rows are sampled. The full 320×200 physical viewport is preserved.
This is an explicitly approximate rendering profile, not a quality-identical
replacement for standard. [Complete contract](MODE7-FAST.en.md).

Legacy geometry, affine textures and `TextureQuality standard` remain defaults.
Q8 remains explicit and recommended above 20 MHz. Modes 1–6/8 and existing
standard Q8/Mode 7 PRG reference identities are retained. No changes to their
renderers. No development demo, soundtrack, contextual reconstruction LUT,
room-specific portals or baked light is included.

The package contains source, bilingual documentation, public examples and tests,
not generated PRGs/ASM, benchmark dumps or diagnostic screenshots. The new
`mode7-fast-cube.json` is a public diagnostic example, not the two-room demo.
Generation stays reproducible via the public PowerShell/Python entry points.
Mobile cameras are still available subject to actual memory allocation; the
fast public cube with mobile camera exceeds its budget, while smaller triangle
profiles compile and execute with automatic/interactive cameras.

### Measured native performance

Turbo6510 64 MHz, explicit PAL/NTSC, public rotating perspective cube, identical
scene/simulation, no music/overlay/instrumented renderer. Two seconds warm-up,
20 seconds emulated counting newly completed/published views at `fps_frame_done`.
Warp affects host execution only. Monitor frame clocks determine the window,
not elapsed host time or video frames.

| Cube configuration | PAL views / FPS | NTSC views / FPS |
| --- | ---: | ---: |
| Standard exact perspective | 62 / 3.10 | 64 / 3.20 |
| Fast block8 + upper duplication | 139 / 6.95 | 145 / 7.25 |

PAL gain **124.19%**, NTSC **126.56%** for this scene only. PAL median/p95/worst
view intervals: standard 319.20/339.16/339.16 ms; fast 139.65/159.60/159.60 ms.
NTSC: standard 317.59/334.30/334.30 ms; fast 133.72/150.44/150.44 ms.
These are not the development two-room video's figures and not universal gains.
No 8-FPS guarantee. Small coverage can lose time to the full reconstruction pass.

### Qualification scope

Assembled tests cover step-eight arithmetic including error carry, all byte UV
endpoint pairs, exact scalar fallback, short spans/tails, retained edge DDA,
disjoint packed row state, both bitmap buffers and neutral shader transitions.
PAL/NTSC PRGs are generated in clean temporary directories. Native captured
frames are replayed in the CPU model at the same pose: bitmap, Screen RAM and
stored Color RAM low nibbles must match exactly **within each configuration**.
Fast versus standard image equality is not required: their sampling differs.
Additional native cases exercise automatic/interactive camera on a triangle.
Previous public contracts keep their frozen PRG/framebuffer hashes; none is
replaced with an approximate fast output.

Actual hardware and other accelerated targets are not newly qualified. Existing
legacy emulator regressions do not prove Q8 fast hardware performance. Memory
maps/allocations remain checked, with the same four windows, video buffers and
32-byte guards. Fast row attribute storage saves 700 bytes at height 100, but
additional code can still exhaust the profile. Rejecting such a scene is correct.

## Italiano

Questo SDK sorgente aggiunge `TextureQuality fast` / campo scena `textureQuality`
esplicito alla Mode 7 Q8 perspective Gouraud C. Promuove sampling prospettico
agli estremi block8, avanzamento edge esatto delle righe conservate, bypass dello
shader neutro e ricostruzione superiore. L'interno dei blocchi otto pixel resta
affine; solo 50 delle 100 righe logiche sono campionate. Viewport fisica completa
320×200 invariata. È un profilo dichiaratamente approssimato, non un sostituto
di qualità identica a standard. [Contratto completo](MODE7-FAST.it.md).

Legacy, texture affini e `TextureQuality standard` restano default. Q8 resta
esplicito e consigliato sopra 20 MHz. Mode 1–6/8 e identità PRG precedenti Q8/
Mode 7 standard conservate, senza modifiche ai relativi renderer. Nessuna demo
privata, musica, LUT contestuale, portale specifico o luce precalcolata inclusa.

Il pacchetto contiene sorgenti, documentazione bilingue, esempi pubblici e test,
non PRG/ASM generati, dump benchmark o screenshot diagnostici. Il nuovo cubo
fast è diagnostico e pubblico, non la demo delle due stanze. Generazione
riproducibile tramite gli ingressi PowerShell/Python pubblici. Le camere mobili
restano disponibili nel budget reale: il cubo fast con camera mobile lo supera,
mentre i profili triangolo più piccoli compilano/eseguono camere auto/interattiva.

### Prestazioni native misurate

Turbo6510 64 MHz, PAL/NTSC esplicito, cubo prospettico pubblico in rotazione,
stessa scena/simulazione, niente musica/overlay/strumentazione renderer. Due
secondi di riscaldamento, 20 secondi emulati contando le nuove viste complete
pubblicate a `fps_frame_done`. Warp accelera solo l'host. La finestra deriva
dai clock del monitor, non dal tempo host o dai fotogrammi del video.

La tabella sopra vale per entrambe le lingue: PAL **3,10→6,95 FPS (+124,19%)**;
NTSC **3,20→7,25 FPS (+126,56%)**, esclusivamente su questa scena. Intervalli
PAL mediana/p95/peggiore: standard 319,20/339,16/339,16 ms; fast
139,65/159,60/159,60 ms. NTSC: standard 317,59/334,30/334,30 ms; fast
133,72/150,44/150,44 ms. Non sono i risultati del video delle due stanze né
guadagni universali. Nessuna garanzia di 8 FPS; coperture piccole possono perdere
tempo nel passaggio di ricostruzione completo.

### Ambito della qualificazione

Test assemblati: carrier a passo otto con carry dell'errore, tutte le coppie di
estremi UV byte, fallback scalare esatto, span corti/code, DDA edge conservata,
stato per riga compattato/disgiunto, entrambi i buffer e transizioni shader.
PRG PAL/NTSC generati in copie temporanee pulite. Frame nativi catturati e
ripetuti nel modello CPU alla stessa posa: bitmap, Screen RAM e nibble bassi
della Color RAM devono coincidere esattamente **nella stessa configurazione**.
Non si richiede uguaglianza fast/standard: i campionamenti differiscono.
Prove native aggiuntive verificano camera auto/interattiva su un triangolo.
I contratti precedenti mantengono gli hash PRG/framebuffer congelati; nessuno
viene sostituito con un'immagine fast approssimata.

Hardware reale e altri target accelerati non sono nuovamente qualificati. Le
regressioni emulatori legacy non dimostrano prestazioni hardware Q8 fast.
Mappe/allocazioni mantengono le quattro finestre, buffer video e guardie da
32 byte. Gli attributi per riga fast recuperano 700 byte ad altezza 100, ma il
codice aggiuntivo può comunque esaurire il profilo: respingere la scena è corretto.
