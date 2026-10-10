# 3Dvibe64 1.9.0 — experimental precision addition / precisione sperimentale

New explicit `-Precision normalized16` for bounded mesh experiments in Modes1–7.
Signed16 homogeneous transform/clipping and reciprocal projection, existing
Q8 coefficient setup and Q2 raster/shaders. Mode7 affine only; perspective,
fast, LOD stay Q8. Legacy default retained; all prior reference hashes retained.
Source generator, strict refusals, assembled tests, bilingual numerical/memory
contract and separate native qualification. No private demos or music included.

The adaptive ship path and its unsigned-screen-Q8 border correction are recorded
as separate evidence, not silently promoted to a generic exporter. This release
does not claim that Normalized16 is universally interchangeable with Q8.

Nuova selezione `-Precision normalized16` per esperimenti mesh limitati Mode1–7.
Trasformazione/clipping omogenei signed16 e proiezione reciproca; setup Q8,
raster/shader Q2 ereditati. Mode7 affine; perspective/fast/LOD restano Q8.
Legacy default, vecchi hash di riferimento invariati. Generatore mantenuto,
validazione rigorosa,test assembly,contratto bilingue e misure native separate.
Nessuna demo privata o musica. Adattamento navetta e fix screen-Q8 unsigned
documentati separatamente, non promossi implicitamente a exporter generale.

See NORMALIZED16.en.md / NORMALIZED16.it.md and NORMALIZED16-QUALIFICATION.md.
