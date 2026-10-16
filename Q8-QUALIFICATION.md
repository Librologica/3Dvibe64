# Q8 scalability qualification / qualificazione — 1.10.0

Historical/versioned evidence. Measurements, hashes and implementation stages below
retain their original scope; they are not a new1.11.0 acquisition or feature promise.
Evidenza storica/versionata: misure, hash e fasi seguenti mantengono l’ambito
originale; non sono nuove acquisizioni o promesse di funzioni1.11.0.
Current contracts / Contratti correnti: [EN](README.en.md), [IT](README.it.md);
[gameplay EN](GAMEPLAY.en.md), [gameplay IT](GAMEPLAY.it.md);
[qualification EN](QUALIFICATION-1.11.0.en.md), [qualificazione IT](QUALIFICATION-1.11.0.it.md).

<!-- maintenance-1.10.1 -->
Current 1.10.1-rc1 matched native matrix and memory changes: [English](QUALIFICATION-1.10.1-rc1.en.md), [Italiano](QUALIFICATION-1.10.1-rc1.it.md). Matrice nativa e costi memoria correnti nei documenti bilingui; il rapporto seguente resta storico.

Official promotion preserves the qualified RC engine, scenes and all 23 measured
PRG hashes. No new native benchmark is needed for documentation/package identity
changes. Raw case names retain their original RC provenance.
La promozione conserva engine, scene e hash dei 23 PRG misurati della RC.

23 delivered builds measured in native VICE Turbo6510 ×64, explicit PAL/NTSC,
normal viewport, no SID or overlay (public Q8 launcher). These figures are not
the private shuttle demo with music. Count only fps_frame_done after show_buffer,
therefore new complete views; warp and host time are not speed measurements.
PAL: 101 refresh warm-up, 2.014981 s; 1024 measured refresh, 20.429114 s.
NTSC: 120 refresh warm-up, 2.005814 s; 1197 measured refresh, 20.007993 s.
Automatic yaw/pitch and rotating objects; no stationary phase. The PAL window
nominally spans the 1024-tick camera cycle; NTSC covers part of that cycle.
Le 23 build consegnate sono misurate in VICE Turbo6510 nativo ×64, PAL/NTSC
esplicito, viewport normal, senza SID o overlay, con il launcher Q8 pubblico.
Questi numeri non riguardano la demo privata della navetta con musica.
Si conta solo fps_frame_done dopo show_buffer, quindi nuove viste complete;
warp e tempo host non misurano la velocità della macchina emulata.
PAL: 101 refresh di warm-up, 2,014981 s; 1024 refresh misurati, 20,429114 s.
NTSC: 120 refresh di warm-up, 2,005814 s; 1197 refresh misurati, 20,007993 s.
Yaw/pitch automatici e oggetti in rotazione, senza fase stazionaria. La finestra
PAL copre nominalmente il ciclo camera di 1024 tick; NTSC ne copre una parte.

## Native FPS / FPS nativi

|Case|Objects|Vertices|Mean FPS|p95 ms|Worst ms|PRG SHA-256|
|---|---:|---:|---:|---:|---:|---|
|13-objects-m1-pal|13|104|9.78995|119.702|119.702|`D6F1C6D6116452D9A75451E79D5524F15A355B401793176D6D7C05EFB67391F3`|
|13-objects-m2-pal|13|104|5.87397|179.553|179.553|`1F579658234FD2C9F95AA00951D37E1CB14CA28F0EA867265447176EFDC34134`|
|13-objects-m3-pal|13|104|9.05570|119.702|119.702|`C064816B6A342DC2732A63BBF6D264D568EE7B85696D960EF49566EFBFD601CB`|
|13-objects-m4-pal|13|104|8.37041|119.702|119.702|`4D5760B0BF267615558E2E86636AC7FF1C3C8E82E1BDBAAF9DD8C7745D075A5D`|
|13-objects-m5-pal|13|104|8.07671|139.652|139.652|`7AA6239644448B9B910A61E0370EC1515A968154E8ABF99B90964AD1F62E73E0`|
|3-objects-m1-ntsc|3|24|31.23752|33.430|33.430|`DE005B83D462F0939415B4C651665EF4E90B00327D388762170017190D9A0C8C`|
|3-objects-m1-pal|3|24|31.18099|39.901|39.901|`F6EF6EE158B18AE52588AFE908FCC085FB1E68E8AB073BF862781271DC4244FA`|
|3-objects-m2-ntsc|3|24|21.79129|50.145|66.860|`8D82E41193F9868004021CD7F0FE9300956FCF6740CEDFD41D638D0D94A51805`|
|3-objects-m2-pal|3|24|20.21625|59.851|59.851|`243B3F3B99B15747091AA3357DE2BEC406FC55F8A7AD923FBE05A21A1DDE041D`|
|3-objects-m3-ntsc|3|24|29.73811|33.430|50.145|`79B83112EC2F1069679C723ADA78FDF589C8CE820A952529F62FEEF85D5FAE47`|
|3-objects-m3-pal|3|24|25.11122|39.901|39.901|`B9667CAAB9FFEEAECA740F7C20A676AAA6E862D22CBE94D97C17600D0F8AAFFC`|
|3-objects-m4-ntsc|3|24|29.28829|33.430|50.145|`8312E359CCAC5B09173B483F163D269D4BBDB5B9C2089B97EE7C668183AA6F78`|
|3-objects-m4-pal|3|24|25.06227|39.901|39.901|`E1BFE3582415FD69FF914C592B2408FC8735852FE2F6D84F21D09E979ECF065D`|
|3-objects-m5-ntsc|3|24|28.98841|50.145|50.145|`80DEE0E68AD5FB6AFECAEA0A77A749F847E90E13BAA31F64D6ED6283A50FF9A3`|
|3-objects-m5-pal|3|24|25.06227|39.901|39.901|`B84FC47E7990E65700F4AC7D079D8C1325B6EE6E59BA8B78F5B614CD22CF66E0`|
|3-objects-m6-ntsc|3|24|24.99001|50.145|50.145|`E519262F4343FD469A35405C522362B123406474815BDB85FED6395A2E5AB785`|
|3-objects-m6-pal|3|24|24.03433|59.851|59.851|`92A8DA0793310C37B5F90074091EA1E765073A6D5888FC7638D82C25D44DAF1E`|
|3-objects-m7-ntsc|3|24|10.19593|133.721|133.721|`F77335AA431236B039DDDF9262D608F91312527809C3356D99BBA598300F491C`|
|3-objects-m7-pal|3|24|9.83890|139.652|139.652|`2EDC69953B45505E037E27F5CD8207DA7BF39B405A93852A97F390D202F25F85`|
|8-objects-m6-pal|8|64|10.27945|99.752|99.752|`B364A52DF0CFEDF794E7152C7B3537C944EA9EE0636C8E4D0F34A3B421DA0108`|
|baseline-2-objects-m5-pal|2|16|27.02026|39.901|39.901|`412AAEC82AD928166C033E08B493397A9BDAB51B0EE3D1C8B3985C4A7B2110B9`|
|candidate-2-objects-m5-pal|2|16|27.02026|39.901|39.901|`412AAEC82AD928166C033E08B493397A9BDAB51B0EE3D1C8B3985C4A7B2110B9`|
|single-129-m3-pal|1|129|16.74081|59.851|59.851|`A97EA68B269678CCB2C9F574484ED722EE0DD22DC54F436D73A22A59B4ECCEF8`|

Before/after two-object Mode5: 27.02026 FPS, identical program hash and frame
intervals. Different scene workloads are not before/after comparisons.
Prima/dopo due oggetti Mode5: 27,02026 FPS, hash del programma e intervalli
identici. Carichi di scene differenti non sono confronti prima/dopo.

## Correctness and scope / Correttezza e ambito

16 native/6502 same-pose comparisons: zero bitmap, screen, Color RAM or vertex
cache differences. Independent double projection oracle: 32 poses in each of
three scenes, 8224 projected vertices, maximum observed error 0.46923 logical
pixel; not a theoretical bound or raster/clipping proof. Fractional camera XYZ
and object Z rotation included. Invalid camera-domain tests cover every vertex,
including indices above 127. Single-129 has one face: its FPS is a transform
stress measurement, not a complex 129-vertex solid benchmark.
16 confronti nativi/6502 alla stessa posa: zero differenze in bitmap, Screen RAM,
Color RAM o cache dei vertici. Oracolo indipendente di proiezione in double:
32 pose in ciascuna di tre scene, 8224 vertici proiettati, errore massimo
osservato 0,46923 pixel logici. Non è un limite teorico né una prova del raster
o del clipping. Incluse coordinate frazionarie XYZ della camera e rotazione Z
dell'oggetto. I test di dominio camera non valido coprono ogni vertice,
compresi gli indici oltre 127. Single-129 ha una sola faccia: i suoi FPS
misurano uno stress di trasformazione, non un solido complesso di 129 vertici.

42 historical Q8 PRGs unchanged; seven implicit/explicit legacy modes identical;
11 frozen legacy references; 21 Normalized16 builds. Twelve public scripts ran:
`test_release_contract.py`, `test_world_metrics.py`, `test_gouraud_mode6.py`, `test_gouraud_mode6_emulators.py`, `test_precision_q8.py`, `test_normalized16.py`, `test_texture_perspective.py`, `test_texture_uvzp.py`, `test_texture_fast.py`, `test_texture_lod.py`, `test_line_hybrid.py`, `test_frame_presentation.py`.
The runner offers 23 inherited scripts; all 23 are not claimed freshly rerun.
Enlarged object-count qualification covers affine Modes1–7. Perspective/fast/LOD
retain original-scene regression coverage; enlarged combinations are not newly
qualified. Rejection cases preserve actual allocation/encoding guards.
42 PRG Q8 storici invariati; sette modalità legacy implicite/esplicite identiche;
11 riferimenti legacy congelati; 21 build Normalized16. Sono stati eseguiti
dodici script pubblici: `test_release_contract.py`, `test_world_metrics.py`,
`test_gouraud_mode6.py`, `test_gouraud_mode6_emulators.py`, `test_precision_q8.py`,
`test_normalized16.py`, `test_texture_perspective.py`, `test_texture_uvzp.py`,
`test_texture_fast.py`, `test_texture_lod.py`, `test_line_hybrid.py`,
`test_frame_presentation.py`. Il runner offre 23 script ereditati: non si
dichiara una nuova esecuzione di tutti e 23. La qualificazione del numero
ampliato di oggetti copre Mode1–7 affini. Perspective/fast/LOD conservano le
regressioni sulle scene originali; le combinazioni ampliate non sono
nuovamente qualificate. I casi di rifiuto preservano i controlli effettivi
di allocazione e codifica.

## Reproduction / Riproduzione

The separate RC evidence package retains QUALIFICATION.md, QUALIFICATION-DATA.json,
FPS.csv, raw/<case>/command.json and commands.mon, monitor logs and RAM;
capture/ holds same-pose data, precision/ the per-vertex projection results,
reports/ build commands, artifacts/<case>/AVVIA-64MHZ.cmd exact launchers.
Use Python3, PowerShell7, 64tass, VICE Turbo6510, py65==1.2.0 and Pillow.
Set VICE_TURBO6510 to your emulator. Existing results are preserved: rerun in
a disposable evidence copy with new output directories. Tools are outside the SDK.
Il pacchetto separato delle prove RC conserva QUALIFICATION.md,
QUALIFICATION-DATA.json, FPS.csv, raw/<case>/command.json e commands.mon,
log del monitor e RAM. capture/ contiene i dati alla stessa posa; precision/
i risultati di proiezione per vertice; reports/ i comandi di build;
artifacts/<case>/AVVIA-64MHZ.cmd i launcher esatti.
Usare Python3, PowerShell7, 64tass, VICE Turbo6510, py65==1.2.0 e Pillow.
Impostare VICE_TURBO6510 sul proprio emulatore. Preservare i risultati esistenti:
rieseguire in una copia di lavoro delle prove con nuove directory output.
Gli strumenti sono esterni all'SDK.

Documentation-only revisions preserve all 23 measured PRGs and their measurement
conditions; they do not require a new benchmark of those same programs.
Le revisioni esclusivamente documentali conservano i 23 PRG e le condizioni
misurate: non richiedono un nuovo benchmark degli stessi programmi.

```powershell
python -B scripts/run_release_tests.py test_release_contract.py test_world_metrics.py
```

From the separate evidence root / Dalla radice del pacchetto prove:

```powershell
python -B native_qualify.py 13-objects-m5-pal
python -B native_qualify.py --capture 13-objects-m5-pal
python -B precision_scalability.py 13-objects-m3-pal single-129-m3-pal
```
