# Normalized16 — profilo geometrico sperimentale, 1.9.0

Release 1.12.0: [ottimizzazioni correnti](RENDER-OPTIMIZATIONS.it.md), [input esterni](EXTERNAL-INPUTS.it.md). Tutte le demo, gli esempi e le prove native sono esterni alla distribuzione sorgente.


Contratto sorgente corrente 1.12.0. Il manuale descrive l’exporter ordinario
salvo indicazione esplicita; API delimitate gameplay/configurazione/roll/gruppi
in [GAMEPLAY](GAMEPLAY.it.md). [Indice documentazione](DOCS.md).

Alternativa intermedia esplicita, non una regolazione meno precisa di Q8.
Legacy resta il default; Q8 resta il percorso preciso supportato. Nessuna
selezione automatica dalla frequenza CPU. Non è raycasting, antialiasing o
aumento della risoluzione. Mode 8 non cambia.

## Build

```powershell
$env:TASS64_EXE = 'C:\tools\64tass.exe'
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -Precision normalized16 -GraphicsMode 4 -SceneFile examples/q8/two-objects-mode4.json -Q8Camera interactive -VideoStandard pal -OutputDirectory ../normalized-mode4-pal
```

Output nuovo, esterno all'SDK. Genera ASM, PRG, label, mappa reale e build.json,
non patch binarie. Richiede Python 3, PowerShell 7 e64tass. Entry point Python:
work/normalized_build.py. PAL/NTSC espliciti, PAL se omesso. Camera walkLite
stationary o interactive; il movimento camera automatico frazionario è
rifiutato. La rotazione degli oggetti resta legata ai tick della simulazione.
Istruzioni 6510 documentate; le prestazioni riportate usano CPU accelerata.

## Perimetro sperimentale

Mode 1–7,160 × 100 logici/320 × 200 fisici, bitmap completa, uno/due oggetti senza
mesh condivise, **massimo 16 vertici runtime**,0<scala<=1,raggio scalato<=40 WU.
Niente Ground,timeline,roll,viewport ridotta. Rotazione iniziale camera nulla;
yaw/pitch runtime disponibili. Mode 4 richiede quad; le altre conservano ABI
triangoli/quad. Mode 7: texture **affini**, Gouraud compositorC ereditato;
non perspective/fast/LOD, che restano Q8. Nessuna selezione delle linee ibride,
overlay o musica. Combinazioni incompatibili rifiutate, mai ignorate.
I limiti non garantiscono il fit: restano le guardie di allocazione.

## Aritmetica e memoria

Conserva setup coefficienti e angoli oggetto frazionari Q8. Coordinate camera
signed 16 in unità 2^e/16 WU,e 0..4. Origine signed 24 Q8 ridotta con shift
aritmetico 4 e ulteriori riduzioni finché le componenti sono inferiori 12288.
Yaw/pitch camera inglobati nella matrice oggetto prima dei termini vertice.
Somma signed 24 e shift 4+e. Near 8 WU Mode 1–6,1 WU Mode 7 nella medesima scala.
Overflow segnala hp_fault: nessun fallback legacy nascosto. Non è identico
a Q8; coordinate lontane e corner possono mostrare maggiore quantizzazione.

Clipping con cinque piani omogenei camera, distanze signed 32 e intersezione
canonica outside→inside. Proiezione mediante normalizzazione della profondità
positiva e tabella 512 reciproci; output Q2 per raster/shader esistenti. Wire
taglia gli edge originali, senza bordi artificiali di chiusura. Palette,
doppio buffer, presentazione safe e banche bitmap restano controllate.
blockSizes,allocation,remainingGaps del build.json descrivono l'allocazione
effettiva: i buchi del PRG non equivalgono alla RAM libera runtime.
Gli IRQ non consumano lo scratch privato della geometria.

## Prove e adattamento privato

Misure **storiche**, PAL Turbo6510× 64, due cubi rotanti senza musica,
2 s riscaldamento+20 s: Q8/Normalized 16 FPS per Mode 1–7:
49,10/50,10;22,55/24,55;30,75/36,05;26,30/34,75;25,05/27,30;
21,30/24,10;9,05/9,45 (Mode 7 affine).
Non sono promesse per i nuovi PRG pubblici. Misure e verifiche delle build
pubbliche in NORMALIZED 16-QUALIFICATION.md. Oracle continuo indipendente
storico: errore endpoint medio.3094,p 95.6610,max 1.2969 pixel logici;
Q8 medio.2755. Corner quasi tangente 105 resta un limite di quantizzazione.
Nessuna qualifica implicita per mesh arbitrarie o tutte le silhouette.

L'esperimento privato della navetta usa invece origine Q8 completa,e 0..8,
focale 100 anziché 170 e conferma del facing più precisa. Il proiettore corretto
tratta X 128..159 screen-Q8 come **unsigned 16**, con estensione di segno sopra
la word e gestione dello shift nullo. Il precedente test signed faceva
sparire facce ai bordi. Dopo la correzione:0 differenze/4167 proiezioni,
0 facce mancanti/3696 chiamate loader,PAL 12,28469→12,94049 FPS,+5,34%,
su 239,4 s con musica privata. **Non è l'exporter Normalized 16 pubblico**,
né un guadagno universale; demo e asset privati non sono distribuiti.
Il proiettore pubblico Q2 non usa quel ramo difettoso screen-Q8 signed.
Q8 e texture perspective/fast/LOD non cambiano per questa correzione.

## Consiglio

Legacy per minor costo,Q8 per produzione precisa,Normalized 16 per esperimenti
consapevoli nel perimetro indicato. Non convertire scene Mode 7 prospettiche
cancellando i contratti. Build NTSC e FPS nativi sono verifiche distinte;
hardware reale non provato.
