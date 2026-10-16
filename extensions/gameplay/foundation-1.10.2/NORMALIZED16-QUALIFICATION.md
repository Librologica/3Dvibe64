# Normalized16 — qualification / qualificazione 1.9.0

## Scope / Ambito

New maintained public exporter, not the private adaptive ship adapter. All
measurements below use SDK `examples/q8/two-objects-modeN.json`, unchanged.
Mode 7 here is **affine**, not perspective/fast/LOD. Legacy remains default.
Normalized16 is an **opt-in experiment**, not an exact replacement for Q8.
Nuovo exporter pubblico mantenuto, non l'adattamento privato della navetta.
Tutte le misure usano gli esempi SDK `examples/q8/two-objects-modeN.json`
invariati; Mode7 **affine**, non perspective/fast/LOD. Legacy default.
Normalized16 è sperimentale esplicito, non un sostituto esatto di Q8.

## Native FPS / FPS nativi

VICE Turbo6510 3.10, multiplier64, uninstrumented delivered builds, silent,
no visual overlay, safe double-buffer presentation. Interactive camera with
no injected input; the original objects rotate on unchanged logical ticks.
PAL warm-up101 refreshes (2.014981s), measurement1003 (20.010158s);
NTSC warm-up120 (2.005814s), measurement1197 (20.007993s).
Count `fps_frame_done` only after a complete new image is published. The native
stopwatch is emulated base-clock time, not host time or CPU replay cycles.
Warp speeds up the test on the host only. Results are scene-specific. Several
examples are limited by refresh cadence: equality there is not a CPU cost claim.

VICE Turbo6510 3.10, moltiplicatore64, build consegnate senza strumentazione,
silenziose, senza overlay visivo, presentazione sicura con double buffer.
Camera interattiva senza input iniettato; gli oggetti originali ruotano ai
tick logici invariati. PAL: warm-up101 refresh (2,014981s), misura1003
(20,010158s); NTSC: warm-up120 (2,005814s), misura1197 (20,007993s).
Si conta `fps_frame_done` soltanto dopo la pubblicazione di una nuova immagine
completa. Lo stopwatch nativo usa tempo dei clock base emulati, non tempo
host o cicli di replay CPU. Warp accelera solo il test sull'host. Risultati
specifici della scena; diversi esempi sono limitati dal refresh: l'uguaglianza
in quei casi non è una dichiarazione sul costo CPU.

| Mode | PAL Q8 FPS | PAL NF FPS | PAL gain | NTSC Q8 FPS | NTSC NF FPS |
|---|---:|---:|---:|---:|---:|
|1|50.12454|50.12454|+0.00%|59.82609|59.82609|
|2|25.28716|31.98376|+26.48%|29.88805|31.68734|
|3|50.07457|50.12454|+0.10%|59.82609|59.82609|
|4|50.12454|50.12454|+0.00%|47.53100|59.82609|
|5|40.42947|50.12454|+23.98%|35.63576|59.82609|
|6|25.08726|31.63393|+26.10%|29.88805|30.68774|
|7, affine|11.89396|13.49315|+13.45%|12.69493|13.84447|

PAL Modes2/5/6/7 Q8 and NF were repeated: identical PRG hashes and view counts
in both runs. NTSC and refresh-capped PAL modes were measured once.
Ripetute due volte Mode2/5/6/7 PAL Q8 e NF: stessi hash e conteggi. NTSC e le
Mode PAL limitate dal refresh misurate una volta.

| Standard | Mode | Profile | Complete views | Median ms | p95 ms | Worst ms |
|---|---:|---|---:|---:|---:|---:|
|PAL|1|q8|1003|19.95031|19.95031|19.95031|
|PAL|1|normalized16|1003|19.95031|19.95031|19.95031|
|PAL|2|q8|506|39.90061|39.90061|39.90061|
|PAL|2|normalized16|640|39.90061|39.90061|39.90061|
|PAL|3|q8|1002|19.95031|19.95031|39.90061|
|PAL|3|normalized16|1003|19.95031|19.95031|19.95031|
|PAL|4|q8|1003|19.95031|19.95031|19.95031|
|PAL|4|normalized16|1003|19.95031|19.95031|19.95031|
|PAL|5|q8|809|19.95031|39.90061|39.90061|
|PAL|5|normalized16|1003|19.95031|19.95031|19.95031|
|PAL|6|q8|502|39.90061|39.90061|39.90061|
|PAL|6|normalized16|633|39.90061|39.90061|39.90061|
|PAL|7|q8|238|79.80123|99.75153|99.75153|
|PAL|7|normalized16|270|79.80123|79.80123|99.75153|
|NTSC|1|q8|1197|16.71512|16.71512|16.71512|
|NTSC|1|normalized16|1197|16.71512|16.71512|16.71512|
|NTSC|2|q8|598|33.43023|33.43023|33.43023|
|NTSC|2|normalized16|634|33.43023|33.43023|33.43023|
|NTSC|3|q8|1197|16.71512|16.71512|16.71512|
|NTSC|3|normalized16|1197|16.71512|16.71512|16.71512|
|NTSC|4|q8|951|16.71512|33.43023|33.43023|
|NTSC|4|normalized16|1197|16.71512|16.71512|16.71512|
|NTSC|5|q8|713|33.43023|33.43023|33.43023|
|NTSC|5|normalized16|1197|16.71512|16.71512|16.71512|
|NTSC|6|q8|598|33.43023|33.43023|33.43023|
|NTSC|6|normalized16|614|33.43023|33.43023|33.43023|
|NTSC|7|q8|254|83.57558|100.29069|100.29069|
|NTSC|7|normalized16|277|66.86046|83.57558|83.57558|

## Correctness / Correttezza

PASS23/23 public scripts through disposable-copy runner. Inherited golden
PRG and framebuffer hashes are **unchanged**. The Q8 test rebuilds42 historical
PAL/NTSC configurations. New Normalized16 test:21 builds,7 byte-identical PAL
regenerations,512 assembled unsigned products,512 ratios,504 projections,
10 clipping passes (all five homogeneous planes, both standards),0 fixed-model
differences. Invalid camera/profile combinations are rejected.

PASS14/14 native-vs-py65 full-render comparisons at identical yaw8/pitch4:
all Modes1–7, PAL/NTSC; both8000-byte bitmaps, both1000-byte screens, actual
Color RAM low nibbles and live vertex buffers,0 differences and0 fault flags.
This verifies the public assembled build/replay ABI, not equality to Q8 pixels.
The first DRAM-only color capture was rejected: RAM underneath I/O is not the
Color RAM chip. The tool now captures that chip separately; the rejected raw
diagnostic remains local, never recategorized as a passing engine test.

PASS23/23 script pubblici tramite runner su copie temporanee; hash golden
PRG/framebuffer ereditati **invariati**. Il test Q8 rigenera42 configurazioni
PAL/NTSC storiche. Nuovo test Normalized16:21 build,7 rigenerazioni PAL
byte-identiche,512 prodotti unsigned assemblati,512 rapporti,504 proiezioni,
10 passate clipping su tutti i cinque piani omogenei e nei due standard,
0 differenze dal modello fixed. Combinazioni camera/profilo non valide rifiutate.

PASS14/14 confronti completi nativo/py65 alla posa identica yaw8/pitch4:
tutte le Mode1–7, PAL/NTSC, entrambe le bitmap da8000 byte, entrambi gli screen
da1000 byte, nibble bassi reali Color RAM e buffer vertici live;0 differenze
e0 flag fault. Verifica l'ABI pubblico della build assemblata/replay, non
l'uguaglianza ai pixel Q8. La prima cattura colori solo DRAM è stata rifiutata:
la RAM sotto I/O non è il chip Color RAM. Lo strumento cattura ora il chip
separatamente; la diagnostica raw rifiutata resta locale e non viene mai
riclassificata come test engine superato.

## Actual memory / Memoria reale

The assembler map and protected allocation are emitted with every build.
`PRG bytes` includes file gaps and is **not** live RAM. `NF/Q8 blocks` sums
actual adapter code/data/LUT sizes, without their guards. All protected regions
retain final assembler overlap checks; combined NF face helpers use one region
with one32-byte outer guard, not unsafe spills into graphics. NTSC Mode6 first
failed gap placement; grouping those unchanged instructions fixed the build.
Both bitmaps occupy separate8192-byte allocations (8000 active each), Screen
RAM1000 active bytes per buffer, no added REU/ROM/hardware expansion. RAM under
BASIC/KERNAL remains banked as before. Private scratch is not shared with IRQ.

Ogni build emette mappa assemblatore e allocazione protetta. `PRG bytes`
include i gap del file e **non** è RAM viva. `NF/Q8 blocks` somma le dimensioni
effettive codice/dati/LUT dell'adapter, senza guardie. Tutte le regioni
protette conservano i controlli overlap finali dell'assemblatore. Gli helper
facce NF combinati usano una regione con una guardia esterna da32 byte,
senza spill non sicuri nella grafica. Mode6 NTSC inizialmente falliva la
collocazione nei gap: raggruppare quelle istruzioni invariate ha risolto la build.
Bitmap in allocazioni separate da8192 byte,8000 attivi ciascuna; Screen RAM
1000 byte attivi per buffer. Nessuna REU/ROM/espansione hardware aggiunta.
La RAM sotto BASIC/KERNAL resta banked come prima. Lo scratch privato non è
condiviso con gli IRQ.

| Mode, PAL | Profile | PRG bytes | Adapter blocks bytes | Remaining placement gaps | Runtime array range |
|---|---|---:|---:|---:|---|
|1|q8|43344|9656|7996|$8000..$84BC|
|1|normalized16|46242|12458|5066|$8000..$84BC|
|2|q8|51091|9841|6129|$8000..$85ED|
|2|normalized16|51154|12643|3199|$8000..$85ED|
|3|q8|51169|8337|5382|$8000..$8621|
|3|normalized16|51162|10882|2741|$8000..$8621|
|4|q8|51150|8337|4173|$8000..$8621|
|4|normalized16|51164|10868|1546|$8000..$8621|
|5|q8|51150|8337|4061|$8000..$8621|
|5|normalized16|51147|10882|1420|$8000..$8621|
|6|q8|51130|8464|2633|$8000..$86E9|
|6|normalized16|51165|11125|100|$8000..$86E9|
|7|q8|51167|9996|2424|$8000..$86ED|
|7|normalized16|51144|12105|443|$8000..$86ED|

## Reproduce / Riprodurre

Python3.13.14, PowerShell7.6.5,64tass1.60.3243,py65 1.2.0,Pillow12.3.0;
stock VICE3.10 used by inherited emulator regressions, Turbo6510 VICE3.10 for
these new native measurements. Configure external tool paths as in TESTING.md.
Python3.13.14, PowerShell7.6.5,64tass1.60.3243,py65 1.2.0,Pillow12.3.0;
VICE stock3.10 nelle regressioni emulatori ereditate, VICE Turbo6510 3.10
nelle nuove misure native. Configurare i tool esterni come in TESTING.md.

```powershell
python -B scripts/run_release_tests.py
python -B scripts/benchmark_normalized16.py --out ../nf-qualification --standard pal
python -B scripts/benchmark_normalized16.py --out ../nf-qualification --standard ntsc
python -B scripts/benchmark_normalized16.py --out ../nf-qualification --standard pal --modes 2,5,6,7 --run 2
python -B scripts/benchmark_normalized16.py --out ../nf-qualification --standard pal --capture --precision normalized16
python -B scripts/benchmark_normalized16.py --out ../nf-qualification --standard ntsc --capture --precision normalized16
```

Raw native monitor commands, native stopwatch/frame events, full RAM/color
dumps, host diagnostic time and PRG hashes are saved outside the SDK in the
chosen output folder. Source-only package: no private scenes, binary demo or
soundtrack. The builder selects Normalized16 only explicitly. Unselected
Q8/legacy/Mode8 outputs retain inherited references.
Comandi monitor grezzi, stopwatch/eventi frame nativi, dump completi RAM/colori,
tempo host diagnostico e hash PRG sono salvati fuori dall'SDK nella cartella
output scelta. Pacchetto solo sorgenti: nessuna scena privata, demo binaria o
musica. Il builder seleziona Normalized16 solo esplicitamente. Gli output
Q8/legacy/Mode8 non selezionati conservano i riferimenti ereditati.

## Historical evidence and limits / Evidenze storiche e limiti

The earlier shifted-camera experiment's FPS and continuous geometric oracle
are historical, not this release's measurements: mean endpoint error0.3094,
p950.6610,max1.2969 logical pixels, compared with Q8 mean0.2755. Quantization
case105 near a tangent remains open. This narrow opt-in experiment is not an
arbitrary-mesh or fully tangent-qualified production precision profile.
The separate adaptive ship path's corrected unsigned screen-Q8 projector and
5.34% measured gain are **not included in this public exporter**. See the
two language guides; do not infer ship-demo or perspective-texture gains from
the new public affine benchmarks.

FPS/oracolo del vecchio corpus con camera diversa sono dati storici: errore
medio0.3094,p950.6610,max1.2969 pixel logici (Q8 medio0.2755). Caso tangente105
ancora aperto. Nessuna qualificazione generale di tutte le mesh/tangenti.
Il percorso adattivo navetta con fix screen-Q8 unsigned e guadagno5.34% resta
separato, **non incluso nell'exporter pubblico**. Nessun guadagno prospettico
o della navetta si deduce dal benchmark affine.

NOT EXECUTED: new Normalized16 FPS on stock1MHz/real hardware; exhaustive
arbitrary meshes; perspective/fast/LOD NF (explicitly refused), automatic
fractional camera NF (refused). No missing emulator blocks this qualification.
NON ESEGUITI: FPS NF stock1MHz/hardware reale, mesh arbitrarie esaustive;
NF perspective/fast/LOD e camera automatica frazionaria sono esplicitamente
rifiutati, non qualificati. Nessun emulatore mancante blocca questa qualificazione.

Recommendation: legacy stays default, Q8 remains the precise supported path,
Normalized16 for bounded experiments where its measured benefit outweighs
the stated quantization limits. No API contract is silently relaxed.
Raccomandazione: legacy default, Q8 preciso; NF per esperimenti limitati che
accettano la quantizzazione dichiarata. Nessun contratto rilassato implicitamente.
