# 3Dvibe64 1.6.0

English: Mode7 gains optional projective UV in a strictly bounded Q8 profile.
Legacy geometry and affine texture interpolation remain defaults and are not
deprecated. Existing reference PRG hashes are unchanged. Read
[texture precision](TEXTURE-PRECISION.en.md) and [testing](TESTING.md): fixed-point
equivalence is not a claim of infinite numerical precision or hardware testing.
Only reusable source and public diagnostic examples are shipped. The developed
demo, production assets, music, raw benchmarks and scene-specific adapters are
not distributed. Modes1–6/8 do not inherit the new projective routines.

Italiano: UV prospettiche opzionali nella Mode7 con profilo Q8 rigorosamente
limitato. Geometria legacy e texture affini restano default e non sono deprecate.
Hash PRG precedenti invariati. Leggere [precisione texture](TEXTURE-PRECISION.it.md)
e [test](TESTING.md): equivalenza fixed-point non significa precisione infinita o
test hardware. Inclusi soltanto sorgenti riutilizzabili ed esempi diagnostici
pubblici. Demo sviluppata, asset di produzione, musica, benchmark grezzi e
adapter specifici della scena sono esclusi. Mode1–6/8 non includono queste routine.

## Qualification / Qualificazione

17/17 public test scripts passed, including the unchanged historical PRG
references and 42 Q8 builds. The new assembled CPU test checked 88,149 arithmetic,
sampler and mixed-repeat/uniform cases against independent integer expectations.
Native comparisons: 20 PAL/NTSC cases on Turbo6510 at 64 MHz, plus 8 on x64sc
and 8 on xscpu64. Both complete bitmap buffers, screen/color data and the
displayed configuration matched the unoptimized exact projective reference.
These are bounded-profile checks, not hardware qualification or a universal
FPS claim. Full logs and captures are retained outside the source package.

17/17 script pubblici superati, inclusi i riferimenti PRG storici invariati e
42 build Q8. Il nuovo test CPU assemblato ha verificato 88.149 casi aritmetici,
sampler e repeat misti/texture uniformi contro attese intere indipendenti.
Confronti nativi: 20 casi PAL/NTSC su Turbo6510 a 64 MHz, più 8 su x64sc e 8 su
xscpu64. Entrambe le bitmap complete, Screen/Color RAM e configurazione visibile
coincidono con il riferimento prospettico esatto non ottimizzato. Si qualificano
il profilo limitato, non l'hardware o FPS universali. Log e catture restano fuori
dal pacchetto sorgente.

Single-pose assembled instruction replay / Replay CPU assemblato a posa fissa:

| Lighting / Luce | Exact scalar cycles / Cicli esatti scalari | Optimized / Ottimizzati | Reduction / Riduzione |
| --- | ---: | ---: | ---: |
| none | 21,240,571 | 15,073,981 | 29.03% |
| flat | 21,700,969 | 20,612,352 | 5.02% |
| Gouraud C | 22,883,419 | 21,100,489 | 7.79% |
| uniform texture + Gouraud C | 22,885,685 | 4,953,214 | 78.36% |

Diagnostic cube, same pose and framebuffer, scalar projective baseline—not the
faster affine path. Includes CPU rendering work but excludes VIC stalls, IRQ,
simulation, presentation and raster wait. **These are not measured FPS.**
Fallback-heavy scenes may benefit less or run slower. The uniform case is an
intentionally favorable specialization, not the speed of arbitrary textures.

Cubo diagnostico, stessa posa e framebuffer, baseline prospettica scalare—non il
percorso affine più veloce. Include il rendering CPU, esclude stall VIC, IRQ,
simulazione, presentazione e attesa raster. **Non sono FPS misurati.** Scene ricche
di fallback possono migliorare meno o peggiorare. La texture uniforme è un caso
deliberatamente favorevole, non la velocità delle texture generiche.
