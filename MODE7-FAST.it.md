# Profilo veloce Mode 7 — 1.7.0

## Selezione e default

`-TextureQuality fast`, oppure scena `"textureQuality":"fast"`, seleziona il
profilo veloce. Un'opzione CLI esplicita prevale sulla scena. `standard` è il
default e conserva l'output precedente. Geometria `legacy` e precisione texture
`affine` restano default finché non selezionate esplicitamente. Nessuna scelta
automatica in base alla CPU. Q8 è consigliato sopra 20 MHz; legacy fino a 20 MHz.

`TextureQuality` è distinto dal preset di build esistente `Quality fast`:
quel preset da solo non attiva sampling block8 o ricostruzione delle righe.

Fast richiede **Mode 7 + Q8 + perspective + Gouraud compositor C**. Combinazioni
non valide sono respinte, non declassate. È vero 3D poligonale, non raycasting.
Questa release promuove metodi riutilizzabili di campionamento/ricostruzione,
non la demo delle due stanze, le sue ipotesi di visibilità o la sua LUT.

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 7 -Precision q8 -TextureQuality fast -SceneFile examples/mode7-fast-cube.json -VideoStandard pal -OutputDirectory ../fast-cube-pal
```

Usare una directory nuova esterna all'SDK. La scena dichiara già texture
prospettiche, Gouraud C e qualità fast. Per una scena compatibile esistente
aggiungere `-TexturePrecision perspective`. Equivalente Python:
`python -B work/q8/build.py --scene examples/mode7-fast-cube.json --out ../fast-cube-python --mode 7 --texture-quality fast`.
PRG, ASM generato, label, mappa memoria e `build.json` restano fuori dal pacchetto.

## Contratto di rendering e compromessi visivi

La viewport Q8 normal resta **160×100 logici / 320×200 fisici**. Solo le righe
logiche pari vengono ombreggiate/campionate; il passaggio finale copia ciascuna
riga superiore nella successiva omessa, comprese entrambe le scanline fisiche.
Il campionamento verticale effettivo è **160×50**, non 160×100 campioni distinti.
Niente interlacciamento temporale, riuso fra frame o interpolazione del movimento.

Blocchi di otto pixel ricostruiscono le UV prospettiche esattamente agli estremi
nel precedente contratto fixed-point dei carrier. I campioni interni interpolano
affinemente gli estremi a otto bit. Gli ultimi uno–otto campioni usano il sampler
esatto; gli estremi non superano lo span. È prospettiva approssimata a blocchi,
non correzione prospettica esatta per ogni pixel. Nearest-neighbor, UV Q4.4,
repeat e texture 16×16 unpacked sono invariati. Repeat può amplificare gli errori
interni; prospettiva forte e wrapping possono produrre deformazioni visibili.

Geometria Q8, clipping near/screen, edge semiaperti, maschere byte e double
buffering restano. Bounds e richieste palette sono valutati su tutte le righe,
nell'ordine originale delle facce; UV/W/Q delle righe conservate mantengono la
DDA edge esatta. Le palette delle righe omesse servono perché il VIC-II condivide
i colori nella cella. La duplicazione resta nella stessa cella colore, quindi
non converte palette e non introduce colori RGB arbitrari.

Gli span neutri Q=10..22 del Gouraud C saltano il compositor a colore invariato.
Se entrambi gli estremi sono nell'intervallo, la DDA monotona vi rimane. Gli
altri span ripristinano lo shader originale. Ripetere la riga superiore ripete
anche ombreggiatura/retino: diagonali e silhouette risultano più grossolane.
Le texture uniformi sono riconosciute dal contenuto della pagina, non dall'ID.

## Memoria, limiti e interrupt

Restano tutti i [limiti Q8/prospettiva](TEXTURE-PRECISION.it.md): PAL/NTSC
esplicito, normal, walkLite, uno o due oggetti non condivisi, massimo 96 vertici,
raggio scalato fino a 40 WU/oggetto, niente Ground/timeline/roll. Profondità
lungo l'asse camera 1–256 WU dopo il clipping. `ps_fault` persistente impedisce
di pubblicare una vista non valida e ferma il rendering con bordo rosso.

Lo stato aggiuntivo dei blocchi occupa circa 35 byte. Gli array privati dei
carrier sono accoppiati a offset 0/1, indicizzati solo dalle righe pari:
gli otto array high/W passano **800→400 byte**, i low V usano gli slot dispari
liberi dei low U e Q condivide una coppia da 100 byte. Risparmio totale degli
attributi per riga: **700 byte** ad altezza 100. Bounds e palette restano completi.
Gli helper usano unità di allocazione già protette; restano le quattro
finestre originali e le guardie codice da 32 byte. L'allocatore può respingere
scene prima dei limiti geometrici, soprattutto con camera mobile o più texture.
Il cubo fast pubblico usa camera stationary; auto/interattiva richiede una scena
che rientri nello stesso budget. Nessuna riduzione silenziosa della precisione.

Solo nelle build fast si omette il divisore scalare stretto duplicato: il
divisore accoppiato gestisce già quel dominio; il fallback usa il divisore
scalare completo esatto. Quozienti/resti sono verificati, non approssimati.

La divisione UV accoppiata conserva lo scratch zero page `$E8..$EF`. La selezione
degli span neutri modifica solo gli ingressi dello shader scalare fra gli span.
Le routine non sono rientranti. Gli IRQ esistenti non chiamano il renderer e
non usano il suo scratch; eventuali estensioni IRQ devono rispettare entrambi.

## Verifica e prestazioni

`scripts/test_texture_fast.py` compila PAL/NTSC in directory temporanee ed esegue
l'aritmetica 6502 emessa: previsione carrier a passo otto con carry, tutte le
coppie di estremi UV, span corti/code, attributi edge conservati, duplicazione
nei due buffer e transizioni shader. Eseguire tramite
`python -B scripts/run_release_tests.py test_texture_fast.py`.

L'immagine fast è volutamente diversa da standard: non è un sostituto bit-exact
né una garanzia di 8 FPS. Oggetti piccoli possono guadagnare poco o perdere
tempo perché la ricostruzione copia sempre l'intera viewport. Le prestazioni
dipendono da copertura, clipping, shader e memoria. Gli FPS del video di sviluppo
delle due stanze includono ottimizzazioni specifiche **non** promosse qui.
Le [note release](RELEASE-NOTES-1.7.0.md) descrivono ambito ed evidenze.
Niente demo di produzione, PRG generato, musica o benchmark grezzo nel pacchetto.
