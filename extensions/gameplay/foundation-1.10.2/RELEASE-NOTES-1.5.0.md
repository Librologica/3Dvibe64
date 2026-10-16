# 3Dvibe64 1.5.0

## English

Optional precise Q8 geometry for the qualified Mode 1-7 profile. **Legacy remains
the unconditional default**, available and non-deprecated. Choose Q8 explicitly
with `-Precision q8`; recommend it above 20 MHz, legacy at <=20 MHz. No automatic
CPU detection/switch and no new FPS guarantee. Mode 8 and legacy reference PRGs
are unchanged. This release introduces no additional rendering optimization.

Read [the complete scope and build guide](PRECISION.en.md): normal/walkLite,
one or two disjoint objects, <=96 total vertices, <=40 WU scaled radius each,
scale <=1. No Ground, sharing, small viewport, timeline or camera roll. Camera
choices: stationary, inherited interactive input, or fractional automatic sweep.
Q8 output is isolated outside the source SDK. All public Q8 programs are silent.
Existing legacy camera, viewport, material, texture and Mode 8 contracts remain
available through the default path. Public source package contains no PRG or
generated ASM; source ASM templates are intentional inputs.

Tests cover immutable legacy PRG hashes, the public default/explicit dispatcher,
Q8 negative cases, silent frozen-source equivalence and PAL/NTSC runtime checks.
No real-hardware verification is claimed. See [TESTING.md](TESTING.md).

## Italiano

Geometria precisa Q8 opzionale per il profilo qualificato Mode 1-7. **Legacy resta
il default incondizionato**, disponibile e non deprecato. Q8 si sceglie solo con
`-Precision q8`; consigliato sopra 20 MHz, legacy fino a 20 MHz inclusi. Nessun
rilevamento/cambio automatico CPU né nuova garanzia FPS. Mode 8 e PRG legacy di
riferimento invariati. Nessuna ulteriore ottimizzazione di rendering in questa release.

Leggere [ambito e guida build](PRECISION.it.md): normal/walkLite, uno o due oggetti
disgiunti, <=96 vertici totali, raggio scalato <=40 WU ciascuno, scala <=1. Niente
Ground, sharing, small, timeline o roll camera. Camera ferma, input interattivo
ereditato o movimento automatico frazionario. Output Q8 isolato fuori dall'SDK.
Tutti i programmi Q8 pubblici sono silenziosi. I contratti legacy di camera,
viewport, materiali, texture e Mode 8 restano disponibili nel percorso default.
SDK senza PRG o ASM generati; i template ASM sorgenti sono input intenzionali.

I test coprono hash PRG legacy immutabili, dispatch default/esplicito, rifiuti Q8,
equivalenza silenziosa con sorgenti congelate e runtime PAL/NTSC. Nessuna verifica
su hardware reale dichiarata. Vedere [TESTING.md](TESTING.md).
