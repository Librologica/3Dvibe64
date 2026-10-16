# Contributing / Contribuire — 1.12.0

## English

Read [LICENSE](LICENSE) and [documentation license](LICENSE-DOCUMENTATION.md).
3Dvibe64 is noncommercial source-available software. Report ordinary problems
with version, minimal external JSON/input, full command, GraphicsMode, precision,
quality, LOD, camera, viewport, memory layout, tool versions and observed output.
Keep secrets and unrelated third-party assets out. Follow [security policy](SECURITY.md)
for vulnerabilities rather than posting them in a public issue.

Use focused branches. Preserve public contracts or document a versioned change.
Keep work/build-3Dvibe64.ps1 UTF-8 with LF only: changing line endings can alter
literal assembly substitutions. .gitattributes enforces LF. Update English and
Italian manuals, indices, options and memory limits together. No demos/examples,
scene assets, PRGs, media, generated logs or test environments in source releases.
Engine assembly templates are maintained sources, not generated artifacts.

Run `python -B scripts/run_release_tests.py`; historical scene gates additionally
require external `--test-inputs`. Test current manifest bytes in fresh copies.
After renderer changes compare native images and complete-view FPS on the actual
project target/options, at least20emulated seconds after warm-up, preserving raw
commands, hashes, p95/worst and equal conditions. Never infer FPS from host time,
warp or CPU replay. [Testing](TESTING.md) · [External inputs](EXTERNAL-INPUTS.en.md).

## Italiano

Leggere [LICENSE](LICENSE) e [licenza documentazione](LICENSE-DOCUMENTATION.md).
3Dvibe64 è software source-available non commerciale. Segnalare i problemi con
versione, input/JSON esterno minimo, comando completo, GraphicsMode, precisione,
qualità, LOD, camera, viewport, layout memoria, versioni strumenti e risultato.
Escludere segreti e asset terzi non necessari. Per vulnerabilità seguire la
[politica di sicurezza](SECURITY.md), evitando dettagli pubblici.

Usare branch mirati; conservare contratti pubblici o documentare il cambio di
versione. Mantenere work/build-3Dvibe64.ps1 UTF-8 con soli LF: CRLF può alterare
sostituzioni assembly letterali. .gitattributes impone LF. Aggiornare insieme
manuali, indici, opzioni e limiti memoria in italiano e inglese. Niente demo,
esempi, asset scena, PRG, media, log generati o ambienti test nelle release
sorgenti. I template assembly dell'engine sono sorgenti, non output generati.

Eseguire `python -B scripts/run_release_tests.py`; le regressioni storiche delle
scene richiedono anche `--test-inputs` esterno. Verificare i byte del manifest
corrente in copie nuove. Dopo modifiche al renderer confrontare immagini e FPS
nativi di nuove viste complete sul target/opzioni reali, almeno20secondi emulati
dopo warm-up; conservare comandi, hash, p95/peggiore e condizioni uguali. Mai
stimare FPS da tempo host, warp o replay CPU. [Test](TESTING.md) · [Input](EXTERNAL-INPUTS.it.md).
