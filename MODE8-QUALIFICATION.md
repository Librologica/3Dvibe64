# Mode 8 qualification / Qualificazione Mode 8

Measured with x64sc 3.10, stock 6510, PAL 985,248 clocks/s or NTSC 1,022,727 clocks/s;
UI and FPS enabled, complete images only, automatic runtime PAL/NTSC selection.
Two seconds warm-up, then both a 20-second window and a complete itinerary duration.
Each automatic run was repeated: measured interval sequences in both windows match
exactly. Absolute autostart clock origins can differ; they are not frame-time jitter.
Warp accelerates host execution only. No extrapolation to hardware or accelerated CPUs.

Misurato in x64sc 3.10, 6510 stock, PAL 985.248 clock/s o NTSC 1.022.727 clock/s;
UI/FPS attivi, solo immagini complete, selezione PAL/NTSC automatica.
Due secondi di warm-up, poi finestra da 20 secondi e durata del giro completo.
Ogni esecuzione automatica è ripetuta: sequenze degli intervalli identiche nelle
due finestre. L'origine assoluta dei clock di autostart può cambiare, non è jitter.
Warp accelera soltanto l'host. Nessuna estrapolazione a hardware o CPU accelerate.

## Native automatic / Automatico nativo

| Map / Mappa | Video | 20 s FPS | Tour s | Tour complete images | Tour FPS | Mean clocks | p95 ms | Worst ms |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| perimeter | PAL | 5.25 | 52.08 | 260 | 4.9923 | 197694.0 | 279.30 | 339.16 |
| perimeter | NTSC | 5.50 | 52.08 | 272 | 5.2227 | 196592.5 | 267.44 | 317.59 |
| apertures | PAL | 4.60 | 272.06 | 1172 | 4.3079 | 228861.6 | 359.11 | 438.91 |
| apertures | NTSC | 4.75 | 272.06 | 1214 | 4.4623 | 229332.1 | 351.02 | 401.17 |
| two-levels | PAL | 3.20 | 169.92 | 522 | 3.0720 | 320445.5 | 558.61 | 798.01 |
| two-levels | NTSC | 3.30 | 169.92 | 541 | 3.1839 | 321265.9 | 534.89 | 768.89 |

p95 uses sorted[floor(0.95*(N-1))]. Counts represent new completed images published,
not repeated refreshes. The full-tour window starts after warm-up and spans one
complete cyclic itinerary period. Static start FPS is not substituted for tour FPS.
The two-level worst interval is important: average FPS does not imply regular pacing.

p95 usa sorted[floor(0,95*(N-1))]. Si contano nuove immagini complete pubblicate,
non refresh ripetuti. La finestra del giro parte dopo il warm-up e dura un periodo
completo dell'itinerario ciclico. Gli FPS statici non sostituiscono quelli del giro.
Il peggior intervallo multilivello è rilevante: FPS medi non implicano cadenza regolare.

## Executed instruction/oracle corpus / Corpus istruzioni-oracolo

93 original poses (34 + 34 + 25), original order and persistent RAM.
The assembled 6502 code executes in py65. All 7,040 bitmap bytes, including
margins, match the independent fixed model. Renderer instruction cycles equal
the qualified backend-router references exactly. These counts omit VIC stalls,
IRQ, input, simulation and presentation: **not FPS**.

93 pose originali (34 + 34 + 25), ordine originale e RAM persistente.
Il codice 6502 assemblato viene eseguito in py65. Tutti i 7.040 byte bitmap,
inclusi i margini, coincidono con il modello fixed indipendente. I cicli delle
istruzioni del renderer sono identici ai riferimenti qualificati del router.
Esclusi stall VIC, IRQ, input, simulazione e presentazione: **non sono FPS**.

| Map / Mappa | Original mean cycles | Tutorial mean cycles | Change / Variazione | Compared views / Viste |
|---|---:|---:|---:|---:|
| perimeter | 169584.29 | 170759.15 | +0.693% | 34 |
| apertures | 200306.56 | 200456.15 | +0.075% | 34 |
| two-levels | 272074.72 | 271242.24 | -0.306% | 25 |

Tutorials also have zero bitmap differences to their matching geometry model.
Tutorial 3 narrows a three-cell aperture to two; the modest mean saving above
is specific to this corpus. Tutorials 1/2 are editing examples, not speed advice.
All six maps complete a 30,000-tick host route check with no blocked ticks.

Anche i tutorial hanno zero differenze bitmap rispetto al proprio modello
geometrico. Il terzo restringe un varco da tre a due celle: il modesto risparmio
medio riguarda questo corpus. I primi due sono esempi didattici, non consigli
prestazionali. Tutte le sei mappe completano 30.000 tick host senza collisioni bloccanti.

## Native correctness / Correttezza nativa

540 snapshots checked; 9384 presented poses traced across 18 runs.

Zero bitmap/margin differences at the sampled same-pose frames. Latched pose,
simulated tick pose, font copies, Screen RAM guard bytes, UI text/FPS digits,
Color RAM, VIC/CIA registers and alternating complete buffers checked.
Six interactive start screenshots (three maps × PAL/NTSC) have zero physical
pixel differences over the 320×176 body, including margins.
This is not a claim of exhaustive pixel comparison of every camera pose.

Zero differenze bitmap/margini nei frame campionati alla stessa posa. Verificati
posa acquisita, posa simulata al tick, copie font, guardie Screen RAM, testo UI/FPS,
Color RAM, registri VIC/CIA e alternanza dei buffer completi. Sei screenshot
interattivi iniziali (tre mappe × PAL/NTSC) hanno zero pixel fisici differenti
nel corpo 320×176, margini inclusi. Non è un confronto esaustivo di ogni posa.

Public runner: 13 legacy scripts plus one Mode 8 script containing 67 cases.
The final external release report records the clean-copy and extracted-package
run results, immutable baseline checks and archive hashes. Raw captures and
profiler traces are intentionally outside the SDK.

Runner pubblico: 13 script legacy più uno Mode 8 da 67 casi. Il report finale
esterno registra esiti in copie pulite e pacchetti estratti, integrità delle
baseline e hash degli archivi. Catture e profiler grezzi restano fuori dall'SDK.

Not executed / Non eseguiti: hardware real C64, accelerated Mode 8, xscpu64
Mode 8, exhaustive continuous-position coverage. Hardware qualification remains open.
