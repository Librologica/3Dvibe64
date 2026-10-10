# Normalized16 — qualification / qualificazione 1.9.0

## Scope / Ambito

New maintained public exporter, not the private adaptive ship adapter. All
measurements below use SDK `examples/q8/two-objects-modeN.json`, unchanged.
Mode 7 here is **affine**, not perspective/fast/LOD. Legacy remains default.
Normalized16 is an **opt-in experiment**, not an exact replacement for Q8.
Nuovo exporter pubblico mantenuto, non l'adattamento privato della navetta.
Esempi SDK invariati; Mode 7 **affine**, non perspective/fast/LOD. Legacy default.
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

VICE Turbo6510×64, PRG senza strumentazione aggiunta, senza musica/overlay,
presentazione sicura. Camera interattiva senza input iniettato, rotazioni
originali ai tick logici. Warm-up almeno2s, misura almeno20s emulati.
Solo nuove viste complete pubblicate; niente FPS dal tempo host o dal replay.
Risultati specifici degli esempi: alcune configurazioni sono limitate dal refresh.

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

PASS23/23 script pubblici su copie pulite; hash PRG/framebuffer storici invariati.
42 configurazioni Q8 storiche rigenerate. Nuovo test NF:21 build,7 rigenerazioni
identiche,512 prodotti,512 rapporti,504 proiezioni,10 passate clipping eseguite
dal6502;0 differenze dal modello fixed. PASS14/14 confronti frame VICE/py65 alla
stessa posa su PAL/NTSC, incluse entrambe le bitmap, Screen RAM, Color RAM reale
a4bit e vertici. Non significa pixel identici a Q8.

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

Mappe/layout emessi per build. I byte PRG includono buchi, non equivalgono alla
RAM viva. Blocchi=summa di codice/dati/LUT dell'adapter, senza guardie. Tutte le
guardie overlap restano attive; helper NF raggruppati sotto una guardia esterna.
Bitmap2×8192 allocati,2×8000 attivi; Screen RAM2×1000 attivi. Nessuna REU/ROM nuova.

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
Dati grezzi e comandi nel percorso output esterno. Pacchetto solo sorgenti,
senza scene private, demo binarie o musica. Nessuna selezione automatica.

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
NF perspective/fast/LOD e camera automatica sono rifiutati, non qualificati.

Recommendation: legacy stays default, Q8 remains the precise supported path,
Normalized16 for bounded experiments where its measured benefit outweighs
the stated quantization limits. No API contract is silently relaxed.
Raccomandazione: legacy default, Q8 preciso; NF per esperimenti limitati che
accettano la quantizzazione dichiarata. Nessun contratto rilassato implicitamente.
