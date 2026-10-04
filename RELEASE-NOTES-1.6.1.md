# 3Dvibe64 1.6.1 — exact projective UV maintenance

## English

Promotes exact paired zero-page/unrolled U/V division into optional Mode 7 Q8
perspective flat/Gouraud C for nonuniform textures. No new rendering feature or
approximation. `floor(128*A/D) mod256` unchanged. Fast domain: D>0, both unsigned
carriers A<2D. Integer bit plus seven restoring steps preserve the remainder
invariant. Other inputs, including zero denominator/faults, use original scalar
fallback. Unlit recurrence and all-uniform textures retain their old paths.

Legacy and affine remain defaults. Q8 recommended above20 MHz; legacy at20 MHz
or below, not deprecated. No automatic CPU selection. Mode1–6/8, Q8 affine and
previous PRG hashes unchanged. Same normal/walkLite, one/two-object, depth1..256
WU Q8 perspective contract, no Ground/sharing; validation/fault behavior retained.

Public cube pose measured: flat20,602,770 ->17,026,043 instruction cycles
(-17.36%); Gouraud21,089,986 ->17,653,207 (-16.30%); unlit unchanged14,923,612.
Assembled CPU replay excludes VIC stalls, IRQ, waiting/presentation: NOT FPS
or a universal speedup. New block682 bytes, net code growth673 on that cube,
zero-page scratch8, extra absolute scratch0. PRG length can hide gap allocation.
Budgets stay enforced; additional code reduces scene headroom. Torus/sphere
perspective fixtures exceeded the original baseline budget already: not qualified.

Reserve `$E8..$EF` while rendering. Nonreentrant: external IRQ/KERNAL/RS232
extensions must not use these bytes or enter the sampler. Existing renderer
IRQ/KERNAL entry/exit passed2,610 instruction-boundary injections. No denominator
self-modifying code or approximate sampling introduced.

DEV evidence:12,814 assembled boundary/random/fallback cases;1,048,576 host
subset inputs; analytic fast-domain invariant (not exhaustive16-bit triples);
32 same-pose native bitmap/color A/B comparisons PAL/NTSC on x64sc/xscpu64/
Turbo6510, zero differences. Clean-copy public suite now18 scripts, including
`test_texture_uvzp.py`, requiring no historical workspace. Native evidence is
separate from public arithmetic tests. Hardware and a new native FPS curve not
claimed. SDK only source/tests/generic examples/docs: no private demo, music,
generated PRG/ASM, captures or profiler artifacts.

## Italiano

Promossa la divisione U/V esatta accoppiata unrolled in zero page nel percorso
opzionale Mode7 Q8 perspective flat/Gouraud C per texture non uniformi. Nessuna
nuova funzione o approssimazione. `floor(128*A/D) mod256` invariato. Dominio
veloce: D>0, entrambi i carrier unsigned A<2D; bit intero e sette passi restoring
conservano l'invariante del resto. Altri input, divisore nullo/errori inclusi,
usano il fallback originale. Unlit e tutto uniforme mantengono i vecchi percorsi.

Legacy e affine default. Q8 consigliato sopra20 MHz, legacy a20 MHz o meno,
non deprecato; nessuna scelta automatica CPU. Mode1–6/8, Q8 affine e hash PRG
precedenti intatti. Stesso contratto Q8 perspective normal/walkLite, uno/due
oggetti, profondità1..256 WU, senza Ground/sharing; controlli/errori conservati.

Posa cubo pubblico: flat20.602.770 ->17.026.043 cicli (-17,36%), Gouraud21.089.986
->17.653.207 (-16,30%), unlit invariato14.923.612. Replay CPU assemblato senza
stall VIC, IRQ, attesa/presentazione: NON FPS o guadagni universali. Blocco682
byte, crescita netta codice673 sul cubo, scratch zero page8, assoluto extra0.
La lunghezza PRG nasconde l'allocazione nei gap. Budget rispettati; più codice
riduce il margine della scena. Toro/sfera prospettici superavano già il budget
originale: non qualificati.

Riservare `$E8..$EF` nel rendering. Routine non rientrante: estensioni IRQ/KERNAL/
RS232 non devono usare questi byte o chiamare il sampler. IRQ/ingresso/uscita
KERNAL esistenti superano2.610 interruzioni ai confini delle istruzioni. Nessun
denominatore automodificante o campionamento approssimato introdotto.

Prove DEV:12.814 casi assembly boundary/random/fallback;1.048.576 input host;
invariante analitico dominio veloce (non esaustività triple16bit);32 confronti
nativi bitmap/colori alla stessa posa PAL/NTSC nei tre emulatori, zero differenze.
Suite pubblica pulita18 script con `test_texture_uvzp.py`, senza workspace
storico. Prove native separate dai test CPU; hardware/nuova curva FPS non
dichiarati. SDK solo sorgenti/test/esempi generici/documenti: niente demo privata,
musica, PRG/ASM generati, catture o profiler.

Software: PolyForm Noncommercial1.0.0; documentation:CC-BY-NC4.0.
Copyright2026 librologica.digital. Existing attribution/license terms unchanged.
