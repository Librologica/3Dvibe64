# Verifiche — 1.20.0

SDK stabile pubblicato su GitHub. I test di correttezza sono inclusi; demo, suite e driver di benchmark non sono distribuiti. Python 3, PowerShell 7 e 64tass vanno installati esternamente. Servono le dipendenze di `requirements-tests.txt`. Eseguire da un’estrazione pulita con le asserzioni Python attive:

```powershell
$env:TASS64_EXE='C:/tools/64tass.exe'
python -B scripts/run_release_tests.py
```

Ogni gate usa una copia SDK indipendente contenente esattamente i file del manifest. Il set predefinito stabile verifica distribuzione, hash, documentazione IT/EN e link locali, correttezza renderer, gameplay delimitato, AnimatedMesh, RuntimeScene, Distance Fade e layout. La qualifica JSON registra nomi ed esiti effettivi. Un gate di identità della vecchia release non viene dichiarato superato su questa versione.

## Prove opzionali con input esterni

I test registrati storici possono richiedere esempi e validation esterni della loro versione, mediante `--test-inputs`; non sono tutti gate della release corrente. Le prove aggiuntive dei kernel ricevono esplicitamente build e scene esterne:

```powershell
python -B scripts/test_animated_mesh.py --native-build C:/qa/animated --scene C:/qa/scene.json --out C:/qa/decoder.json
python -B scripts/test_reusable_render.py --control C:/qa/control --exact C:/qa/exact --api C:/qa/api --wire-reference C:/qa/wire --out C:/qa/reusable.json
python -B scripts/test_sphere_impostors.py --build C:/qa/sphere-work --out C:/qa/sphere.json
```

AnimatedMesh richiede `3Dvibe64.asm`, `raw.prg` (immagine 64tass non rilocata) e `labels.txt` numeriche della stessa compilazione; un launcher impacchettato non sostituisce l’immagine raw. I replay CPU verificano correttezza, mai FPS nativi.

## Prestazioni native e promozione

La suite prestazionale rimane esterna. Usare il target VICE Turbo6510 PAL, SID attivo, nessuna REU, a 1×/20×/64×. Contare nuove viste complete e conservare comandi, opzioni, percorso, hash PRG/simboli, clock emulati, FPS medi e p95/peggiore intervallo. Warp e tempo host non sono velocità della macchina emulata. Core/fade/interop usano 128 eventi IRQ di warm-up (circa 2,53–2,55 s effettivi) e 1024 refresh misurati; many usa 129 eventi e almeno 128 periodi PAL completi, poi 16384/32768 refresh a 1× o 2048 a 20×/64×, con tre ripetizioni many a 64×. Sono protocolli distinti e non vanno confusi.

Le misure originali possono essere ereditate per modifiche documentali/distributive solo dopo identità esatta di runtime, programma, tutti i simboli numerici e condizioni. La promozione registra zero nuove esecuzioni FPS e conserva i blocchi preesistenti. Una modifica renderer richiede nuove misure native. Scene, ancoraggi, pesi e qualità congelati non vanno adattati per migliorare l’indice. Nessuna nuova qualifica NTSC o hardware.

[Qualification / Qualifica](QUALIFICATION-1.20.0.json) · [Docs](DOCS.md)
