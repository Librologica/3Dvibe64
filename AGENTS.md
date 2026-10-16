# 3Dvibe64 1.11.0 — release source / sorgenti della release

This is the separate local release checkout. Preserve the development checkout,
older releases, frozen external projects and foundation-1.10.2. Do not change
Mode8 or turn bounded gameplay adapters into claims of general scene support.
Build/test outputs belong outside this source tree. Release assets contain
source only: no precompiled PRG, video, music or demo archives. Keep current
documentation complete in English and Italian; see DOCUMENTATION.json.

Questa è la copia separata della release locale. Preservare dev, versioni
precedenti, progetti esterni congelati e foundation-1.10.2. Non modificare
Mode8 né presentare gli adattatori delimitati come API generali. Output di
build/test fuori dai sorgenti; soltanto sorgenti negli asset della release.
Documentazione corrente completa in italiano e inglese: DOCUMENTATION.json.

After demo/rendering changes, measure actual native complete-view FPS on the
real target/launcher, at least20 emulated seconds after warm-up; preserve raw
data, command, hash, p95/worst and matched conditions. Host/warp/replay speed
is not native FPS. Documentation/tooling-only changes need no repeated FPS
when delivered PRG hashes and launch conditions are identical.

Dopo modifiche a demo/rendering misurare FPS nativi di sole nuove viste
complete sul target/launcher reale, almeno20secondi emulati dopo il warm-up.
Conservare raw, comando, hash, p95/peggiore e condizioni comparabili. Tempo
host, warp e replay CPU non sono FPS nativi. Modifiche solo documentali o
agli strumenti non richiedono nuove misure se hash PRG e condizioni coincidono.
