# Verifiche — 1.15.1

## Gate dello ZIP sorgente pulito

Installare separatamente `requirements-tests.txt`, Python3, PowerShell7 e64tass.
Eseguire da un'estrazione pulita dello ZIP, con asserzioni attive:

```powershell
$env:TASS64_EXE='C:/tools/64tass.exe'
python -B scripts/run_release_tests.py
```

La suite predefinita crea copie SDK temporanee indipendenti da MANIFEST.sha256.
Verifica metadati stabili/locali, assenza di demo, link e contratti IT/EN,
API host legacy-plus, rendering esatto riutilizzabile, guardie API cerchi,
aritmetica/pannelli/materiali assemblati e configurazione dei moduli gameplay.
Non richiede scene allegate. I callback host/CPU non misurano FPS.

## Controlli API emesse opzionali

Compilare progetti del chiamante fuori dallo SDK e conservare ASM/PRG ed
etichette VICE numeriche. I comandi mirati accettano build esterne esplicite:

```powershell
python -B scripts/test_reusable_render.py --control C:/qa/control --exact C:/qa/exact --api C:/qa/api --wire-reference C:/qa/wire --out C:/qa/reusable.json
python -B scripts/test_legacy_plus_exact.py --control C:/qa/control --exact C:/qa/exact --out C:/qa/kernels.json
python -B scripts/test_sphere_impostors.py --build C:/qa/sphere-work --out C:/qa/sphere.json
```

Servono build reali corrispondenti, non cartelle vuote. Per i cerchi fornire
`3Dvibe64.prg` e `3Dvibe64.labels` numerico. [API cerchi](CIRCLE-SPHERES.it.md)
descrive il generatore; [guida rapida](QUICKSTART.it.md) i profili di build.

## Gate storici e regressioni con input esterni

Altri script registrati richiedono input esterni fidati `examples/` e
`validation/`, intenzionalmente assenti dal pacchetto. Script e rapporti legati
agli hash PRG storici sono diagnostica storica: non qualificano automaticamente
ogni vecchia scena/hash sulla release corrente. Selezionare un test e input
compatibili; `--test-inputs` li copia solo nelle copie QA. Gli adattatori
opzionali richiedono `--project-source` esplicito e un preset con
`engineVersion` uguale a1.15.1. Il perimetro sperimentale resta invariato.

## Tempi nativi e identità stabile

La promozione stabile ricompila tutti gli81 casi:54 programmi ed etichette
numeriche coincidono con agentic17;162 osservazioni PAL Turbo6510 1×/20×/64×
sono conservate per identità esatta. I27 casi già bloccati restano invariati.
La [qualifica corrente](QUALIFICATION-1.15.1.it.md) include FPS,p95/peggiore,
tempo render, hash PRG, target/percorso e segnalazioni conservate.

Condizioni benchmark: musica SID originale a tre voci; warm-up128 refresh PAL
(~2,553639s), poi1024 refresh misurati (~20,429114s), percorso originale16 pose.
Contare solo nuove viste complete. Conservare comando VICE, opzioni, cicli
grezzi, immagini e hash. Warp, tempo host e replay CPU non sono FPS. I campioni
API cerchi sono carichi separati silenziosi con SID emulato attivo:2048 refresh
a1×,1024 a20×/64×, dopo warm-up128.

Resta il flag validation4/1× del catalogo (11 contro12 viste); tre finestre
native di8 periodi per parte (~163,43s,93 viste ciascuna) non confermano una
regressione persistente oltre soglia. Restano espliciti il compromesso Mode7/1×
e i pesi dell'indice. Non sostituire i dati originali con diagnosi favorevoli.

Modifiche al renderer richiedono nuove misure native. Documentazione e controlli
host conservano le osservazioni solo dopo verifica esatta di PRG/etichette e
condizioni. La promozione non qualifica nuovamente NTSC, hardware fisico o Linux.
Tracce grezze e build QA private restano fuori dallo ZIP sorgente.
