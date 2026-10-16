# Normalized16 — profilo geometrico sperimentale, 1.9.0

Alternativa intermedia esplicita, non una regolazione meno precisa di Q8.
Legacy resta il default; Q8 resta il percorso preciso supportato. Nessuna
selezione automatica dalla frequenza CPU. Non è raycasting, antialiasing o
aumento della risoluzione. Mode8 non cambia.

## Build

```powershell
$env:TASS64_EXE = 'C:\tools\64tass.exe'
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -Precision normalized16 -GraphicsMode 4 -SceneFile examples/q8/two-objects-mode4.json -Q8Camera interactive -VideoStandard pal -OutputDirectory ../normalized-mode4-pal
```

Output nuovo, esterno all'SDK. Genera ASM, PRG, label, mappa reale e build.json,
non patch binarie. Richiede Python3, PowerShell7 e64tass. Entry point Python:
work/normalized_build.py. PAL/NTSC espliciti, PAL se omesso. Camera walkLite
stationary o interactive; il movimento camera automatico frazionario è
rifiutato. La rotazione degli oggetti resta legata ai tick della simulazione.
Istruzioni6510 documentate; le prestazioni riportate usano CPU accelerata.

## Perimetro sperimentale

Mode1–7,160×100 logici/320×200 fisici, bitmap completa, uno/due oggetti senza
mesh condivise, **massimo16 vertici runtime**,0<scala<=1,raggio scalato<=40WU.
Niente Ground,timeline,roll,viewport ridotta. Rotazione iniziale camera nulla;
yaw/pitch runtime disponibili. Mode4 richiede quad; le altre conservano ABI
triangoli/quad. Mode7: texture **affini**, Gouraud compositorC ereditato;
non perspective/fast/LOD, che restano Q8. Nessuna selezione delle linee ibride,
overlay o musica. Combinazioni incompatibili rifiutate, mai ignorate.
I limiti non garantiscono il fit: restano le guardie di allocazione.

## Aritmetica e memoria

Conserva setup coefficienti e angoli oggetto frazionari Q8. Coordinate camera
signed16 in unità2^e/16WU,e0..4. Origine signed24 Q8 ridotta con shift
aritmetico4 e ulteriori riduzioni finché le componenti sono inferiori12288.
Yaw/pitch camera inglobati nella matrice oggetto prima dei termini vertice.
Somma signed24 e shift4+e. Near8WU Mode1–6,1WU Mode7 nella medesima scala.
Overflow segnala hp_fault: nessun fallback legacy nascosto. Non è identico
a Q8; coordinate lontane e corner possono mostrare maggiore quantizzazione.

Clipping con cinque piani omogenei camera, distanze signed32 e intersezione
canonica outside→inside. Proiezione mediante normalizzazione della profondità
positiva e tabella512 reciproci; output Q2 per raster/shader esistenti. Wire
taglia gli edge originali, senza bordi artificiali di chiusura. Palette,
doppio buffer, presentazione safe e banche bitmap restano controllate.
blockSizes,allocation,remainingGaps del build.json descrivono l'allocazione
effettiva: i buchi del PRG non equivalgono alla RAM libera runtime.
Gli IRQ non consumano lo scratch privato della geometria.

## Prove e adattamento privato

Misure **storiche**, PAL Turbo6510×64, due cubi rotanti senza musica,
2s riscaldamento+20s: Q8/Normalized16 FPS per Mode1–7:
49,10/50,10;22,55/24,55;30,75/36,05;26,30/34,75;25,05/27,30;
21,30/24,10;9,05/9,45 (Mode7 affine).
Non sono promesse per i nuovi PRG pubblici. Misure e verifiche delle build
pubbliche in NORMALIZED16-QUALIFICATION.md. Oracle continuo indipendente
storico: errore endpoint medio.3094,p95.6610,max1.2969 pixel logici;
Q8 medio.2755. Corner quasi tangente105 resta un limite di quantizzazione.
Nessuna qualifica implicita per mesh arbitrarie o tutte le silhouette.

L'esperimento privato della navetta usa invece origine Q8 completa,e0..8,
focale100 anziché170 e conferma del facing più precisa. Il proiettore corretto
tratta X128..159 screen-Q8 come **unsigned16**, con estensione di segno sopra
la word e gestione dello shift nullo. Il precedente test signed faceva
sparire facce ai bordi. Dopo la correzione:0 differenze/4167 proiezioni,
0 facce mancanti/3696 chiamate loader,PAL12,28469→12,94049FPS,+5,34%,
su239,4s con musica privata. **Non è l'exporter Normalized16 pubblico**,
né un guadagno universale; demo e asset privati non sono distribuiti.
Il proiettore pubblico Q2 non usa quel ramo difettoso screen-Q8 signed.
Q8 e texture perspective/fast/LOD non cambiano per questa correzione.

## Consiglio

Legacy per minor costo,Q8 per produzione precisa,Normalized16 per esperimenti
consapevoli nel perimetro indicato. Non convertire scene Mode7 prospettiche
cancellando i contratti. Build NTSC e FPS nativi sono verifiche distinte;
hardware reale non provato.
