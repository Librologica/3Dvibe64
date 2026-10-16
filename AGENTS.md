# 3Dvibe64 1.11.0 distribution / distribuzione

Preserve the ordinary engine and all preexisting v1.10.2 examples. New demo
projects, their source scenes, UI/artwork/camera paths, launchers and asset
bundles must stay outside the public repository and release ZIP. Keep generic
gameplay modules, tests, complete English/Italian docs and user-input tools.
Native gameplay adapters require explicit external --project-source input.
The user's correction updates the existing 1.11.0; create no new release or
version. Older release tags and the private development checkout stay intact.

Conservare engine ordinario ed esempi della v1.10.2. I nuovi progetti demo,
anche sorgenti/scene/UI/disegni/percorsi/launcher/asset, restano esterni al
repository pubblico e allo ZIP. Conservare moduli gameplay generici, test e
documentazione completa EN/IT. Correggere la 1.11.0 esistente senza nuova
release/versione; preservare tag precedenti e dev privata.

After renderer/demo changes, measure real complete-view native FPS over at
least 20 emulated seconds after warm-up; preserve target, command, hashes,
raw data and p95/worst. Packaging/docs/input-selection changes with identical
runtime bytes need no new FPS. Dopo modifiche di rendering/demo misurare FPS
nativi reali; cambi di packaging/documentazione con runtime identico non
richiedono nuove misure. Warp/host time/CPU replay are not native FPS.
