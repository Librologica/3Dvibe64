# Sfere rese mediante cerchi — 1.15.1

Stabile1.15.1, release GitHub di soli sorgenti. [Stato release](RELEASE-STATUS.it.md) · [Qualifica corrente](QUALIFICATION-1.15.1.it.md). Scene e asset sono esterni; nessun progetto demo incluso.

API opzionale di sviluppo, indipendente dalla scena e dall'identità degli
oggetti. La sfera è rappresentata da un cerchio orientato verso lo schermo,
con geometria della camera legacy-plus e riempimento nativo. Nessuna mesh
sferica, limite di sprite, raggio, numero di oggetti, palette, luce o piano
di appoggio prestabiliti.

Attivazione: `-SphereRenderer circles`. Il default `none` non emette codice
o RAM aggiuntivi. L'opzione è separata da `-LegacyPlusOptimizations all`.
Primo profilo supportato: Mode4/Mode6, `legacy-plus`, `walkLite`, `normal`,
`high-basic-v2`, `-NoFpsOverlay`. Gli altri profili sono rifiutati esplicitamente.
Codice e dati usano l'allocatore esistente: nessuna finestra di memoria o
allocazione zero-page ampliata. Una combinazione può non entrare nei64 KB.

## Coordinate e materiali

Chiamare dal passaggio principale di disegno, selezionando prima `drawbuf`,
prima della presentazione del buffer. Le API modificano A/X/Y/flag e lo scratch
nativo di proiezione, clipping e span. Non sono rientranti e non vanno chiamate
contemporaneamente da IRQ. Stato in RAM ordinaria allocata; nessun vertice
residente o triangolo di controllo fittizio richiesto.

Il materiale usa `fillbyte`, `material_screen_cur`, `material_color_cur`, come
gli span solidi nativi. Rimangono attivi entrambe le righe fisiche, i due
buffer, le maschere, gli aggiornamenti dei materiali per cella e gli span dirty.
Bianco e nero non hanno percorsi speciali; il pattern0 scrive opacamente lo
slot00. I limiti di colore per cella del VIC-II restano quelli dell'hardware:
la politica della palette appartiene al chiamante.

| Entrata | Input | Risultato |
|---|---|---|
| `er_sphere_begin_view` | Angoli attuali della camera nativa | Prepara i coefficienti Q10; chiamare dopo aver cambiato gli angoli |
| `er_sphere_world_to_camera` | `er_sphere_world_x/y/z`, signed24 Q8 | Scrive `er_sphere_camera_x/y/z`, signed16 Q4; carry indica successo |
| `er_sphere_draw_world` | Centro mondo, raggio mondo, materiale | Trasformazione, proiezione e disegno; richiede coefficienti aggiornati |
| `er_sphere_project` | Centro camera e raggio mondo | Produce centro/raggio a schermo senza disegnare |
| `er_sphere_draw_camera` | Centro camera, raggio mondo, materiale | Proietta e disegna senza trasformare un oggetto/mesh |
| `er_circle_draw` | `er_circle_xq2/yq2`, signed16 Q2; `er_circle_radius_q2`, byte | Disegna il cerchio già proiettato, ritagliato a160×100 |

Assi mondo nativi: **X, Y verticale, Z in avanti**. Le coordinate pubbliche
world-z-up `[x,avanti,altezza]` diventano native `[x,altezza,avanti]`.
I centri sono signed24 Q8 assoluti, come la camera. La distanza relativa
deve stare in `[-1024,1024)` WU per asse, dominio nativo legacy-plus.
Valori esterni e overflow della sottrazione signed24 restituiscono errore,
senza avvolgere le coordinate né cambiare il flag di errore della camera.

`er_sphere_radius`: raggio **nel mondo**, unsigned16 Q4, valori grezzi1..16383
(1/16..1023 15/16 WU). Applicare prima l'eventuale scala dell'oggetto.
Una sfera non ha orientamento: non viene trasformata una mesh.

Formula: `PROJ_FOCAL * radiusQ4 *4 / cameraDepthQ4`, arrotondata al quarto di
pixel logico più vicino, con i mezzi arrotondati in alto. Prodotto24 bit,
profondità Q4 completa, senza costanti del biliardo. I centri conservano la
normalizzazione del divisore nativo e l'arrotondamento del resto al quarto
di pixel. `er_sphere_depth_q4` è un alias della profondità camera per
l'ordinamento painter gestito dall'applicazione.

La proiezione scrive `er_circle_xq2/yq2`, raggio ed `er_sphere_valid`
(proiezione prodotta). `er_sphere_screen_xq2/yq2` sono alias dei centri a
schermo. La sola proiezione non modifica il framebuffer. Le entrate di
disegno restituiscono carry impostato solo se disegnano almeno uno span visibile.

## Limiti, cerchi minuscoli e stato

Raggio a schermo1..252 quarti di pixel (0,25..63 pixel logici). Una proiezione
più grande restituisce stato3, senza ridurne silenziosamente la scala.
Centri dietro la camera o più vicini del piano near nativo di8 WU sono
rifiutati come piani rivolti allo schermo; non si calcola l'intersezione
volumetrica fra sfera e piano near.

`er_sphere_min_radius_q2` vale0: un raggio arrotondato a0 viene escluso.
Impostare4 per scegliere esplicitamente il raggio minimo di un pixel.
Non viene applicata una tabella LOD per profondità.

`er_circle_trim_tips` vale1: elimina righe/colonne cardinali isolate dalla
sagoma completa, prima del clipping. Con0 mantiene la copertura stretta
del cerchio. Sotto1,5 pixel di raggio, una sagoma campionata vuota usa un
pixel vicino; il centro fuori schermo non viene forzato sul bordo del viewport.
Nessun retino temporale né righe alternate.

`er_sphere_status`:0 successo,1 near/dietro,2 raggio mondo non valido,
3 proiezione troppo grande,4 sotto risoluzione/raggio schermo nullo,
5 fuori viewport/nessuna copertura,6 coordinate mondo fuori dominio.
Controllare il carry della funzione chiamata: una proiezione valida può
essere interamente fuori schermo. Input di proprietà del chiamante, validi
per tutta la chiamata sincrona.

## Integrazione e significato visivo

Nessun nuovo livello automatico di disegno. Il chiamante ordina cerchi e
poligoni, emettendo prima quelli lontani e poi quelli vicini, oppure li
integra nel proprio ordinamento. La profondità del centro ordina un piano
rivolto allo schermo: non equivale a uno z-buffer sferico o a un'intersezione
geometrica sfera/mesh.

Il profilo circolare mantiene il costo ridotto dell'impostor. Fuori asse la
sagoma prospettica esatta di una sfera sarebbe un'ellisse spostata: il limite
è esplicito. Illuminazione, riflessi, ombre, animazione del materiale,
collisioni e movimento rimangono scelte dell'applicazione. L'engine non
contiene posizioni, colori, buche, lampada, riflesso o ombre del biliardo.

## Compilazione e chiamata ASM minima

I comandi partono dalla radice SDK. Copiare tutto l'SDK in una nuova cartella:
legacy-plus ordinario scrive nella copia e rifiuta `-OutputDirectory`.
La scena esterna deve dichiarare camera/modalità compatibili. Il selettore
emette soltanto API richiamabili: non aggiunge uno schema sfere al JSON della
scena né inserisce oggetti nel passaggio di disegno. Usare ASM applicativo
oppure lo strumento di esempio esterno.

```powershell
Copy-Item -LiteralPath . -Destination ../sphere-build-sdk -Recurse
pwsh -NoProfile -File ../sphere-build-sdk/work/build-3Dvibe64.ps1 -SceneFile ../my-inputs/scene.json -Precision legacy-plus -GraphicsMode 4 -CameraMode walkLite -CameraViewport normal -MemoryLayout high-basic-v2 -Quality fast -Projection extended-table -VideoStandard pal -DynamicLight -NoFpsOverlay -SphereRenderer circles
```

Per Mode 6 usare `-GraphicsMode 6` e una scena compatibile.
L'esempio in coordinate camera disegna una sfera di raggio 4 WU a profondità
100 WU. Presuppone un frame inizializzato e una palette condivisa con le altre
primitive: i numeri dei materiali sono scelte dell'esempio, non slot riservati.
`er_sphere_begin_view` serve per il percorso di trasformazione dal mondo.

```asm
; In the main draw pass, after selecting drawbuf, before presentation.
; Example palette: global background 0, shared slots 01=1, 10=3, 11=6.
 lda #$55
 sta fillbyte
 lda #$13
 sta material_screen_cur
 lda #6
 sta material_color_cur
 lda #0
 sta er_sphere_camera_x
 sta er_sphere_camera_x+1
 sta er_sphere_camera_y
 sta er_sphere_camera_y+1
 lda #<(100*16)
 sta er_sphere_camera_z
 lda #>(100*16)
 sta er_sphere_camera_z+1
 lda #<(4*16)
 sta er_sphere_radius
 lda #>(4*16)
 sta er_sphere_radius+1
 jsr er_sphere_draw_camera
; C=1: visible spans drawn. C=0: inspect er_sphere_status.
```
Per le chiamate mondo, scrivere `er_sphere_world_x/y/z` nel formato nativo
signed24 Q8, chiamare `er_sphere_begin_view` dopo aver aggiornato gli angoli
della camera e usare `er_sphere_draw_world`. Le chiamate di disegno ripetono
proiezione e raster per ogni vista richiesta; l'engine non memorizza
illuminazione o geometria già calcolate.

## Esempio esterno e verifiche

```powershell
$env:TASS64_EXE='C:/percorso/64tass.exe'
python -B scripts/sphere_api_example.py --out C:/progetti/sfere-cerchi --mode 4
```

Lo strumento sorgente genera e compila un progetto esterno con un cubo,
livelli gestiti dal chiamante e sfere sospese di raggi diversi. `--mode 6`
usa un chiamante compatto a due oggetti per rispettare la memoria disponibile.
Palette comune a quattro colori e movimento sono scelte dell'esempio.
Ogni progetto ha `launch-demo.cmd`, `launch.ps1`, PRG e controllo che
differisce solo per un byte di attivazione. Nessun esempio precompilato o
media è distribuito nell'SDK sorgente.

`scripts/test_sphere_impostors.py --build <work-assemblato> --out <rapporto>`
confronta il6502 emesso con copertura indipendente, maschere del framebuffer,
divisione prospettica e prodotti signed Q10. Servono `3Dvibe64.prg` e le
etichette VICE numeriche `3Dvibe64.labels` nella cartella work.
Misure FPS e immagini VICE sono distinte dai controlli CPU di correttezza.

[Indice documentazione](DOCS.md) · [Guida rapida](QUICKSTART.md) · [Comandi dei test ed evidenze](TESTING.md).
