# GraphicsMode 7 — Texture mapping affine

3Dvibe64 1.3.0 promuove il renderer R1 qualificato. È texture mapping software **affine**, non perspective-correct, per la bitmap multicolor VIC-II.

## Modalità e illuminazione

| Mode | Rendering della superficie |
| --- | --- |
| 4 | Flat shading dinamico, un valore luminoso per faccia. |
| 6 | Gouraud ordered-dithered, shade vertex interpolati, 33 livelli. |
| 7 | Texture affini, con illuminazione dinamica flat o Gouraud opzionale. |

Nella scena, `textureLighting` assente oppure `"none"` significa texture senza illuminazione. `"flat"` attiva la luce dinamica per faccia. `"gouraud"` attiva l'illuminazione per shade vertex e l'interpolazione U/V/Q, con Q in 0–32.

Il compositor ufficiale per Gouraud textured è `textureCompositor: "C"`, anche default della 1.3.0 quando l'illuminazione è Gouraud. Specificare C esplicitamente nelle scene portabili. A/B restano accettati per compatibilità/diagnostica; non sono il percorso pubblico consigliato e non ereditano il fix R1, specifico di C.

Il compositor C è texel-first: campiona il pigmento, poi applica l'illuminazione. La fascia luminosa centrale conserva i tre pigmenti della texture; le fasce scure/chiare li spostano, con transizioni Bayer 4×4 ancorate allo schermo. Conserva il contrasto del pattern, ma non garantisce pigmenti immutati a ogni intensità. LightFix corregge aritmetica e saturazione del vettore luce con segno; non introduce un modello luminoso nuovo. Materiali e reflectivity usano la pipeline già presente. Con `none`, luci, normali e reflectivity non illuminano dinamicamente la texture.

## Build

Servono Python 3, PowerShell e 64tass; impostare `TASS64_EXE` con il percorso dell'assembler. Installare Pillow solo per sorgenti PNG. Lavorare in una copia SDK modificabile, non nella distribuzione congelata.

```powershell
python -m pip install -r requirements-mode7.txt
$env:TASS64_EXE = "C:\tools\64tass.exe"
.\work\build-3Dvibe64.ps1 -SceneFile .\examples\mode7-cube-gouraud.json -GraphicsMode 7 -MemoryLayout high-basic-v2 -Quality fast -Projection extended-table -Mode4NearProfile clip -VideoStandard pal -CameraViewport normal -CameraMode fixed -FpsCounterOnly -SkipCmdUpdate
```

La scena deve contenere `graphicsMode: 7`. Mode 7 richiede `high-basic-v2`, `fast`, `extended-table` e profilo near `clip`; l'adapter applica questi default se omessi. Non sostituirli con i precedenti parametri balanced/table della Mode 4.

## Geometria e pipeline raster

Sono accettati vertici espliciti e facce triangolari/quad. I quad sono divisi deterministicamente sulla diagonale **0→2**, in (0,1,2) e (0,2,3), conservando winding e UV dei corner. Tutte le facce runtime sono triangoli. Entrambi i triangoli ereditano la texture; il flat conserva il rapporto con la faccia sorgente.

Trasformazione, proiezione, culling, depth bucket, camera e clipping near-plane/screen alimentano il rasterizer. I vertici generati dal clipping interpolano U/V, e Q per Gouraud, con il parametro geometrico del clipping. DDA intere/fixed-point sugli edge e sulle scanline conservano la relazione X/U/V validata. Le seam della texture usano UV per corner, indipendentemente dalle discontinuità delle normali.

Il kernel compone quattro pixel logici a 2 bit in ogni byte bitmap completo. Span corti e byte parziali usano maschere che preservano i pixel vicini. Restano supportati double buffering, PAL/NTSC, viewport normal/small e camere fixed/walkLite/walkFull.

R1 corregge l'inclusione degli edge nel percorso Gouraud C: arrotondamento superiore intero ed edge semiaperti, proprietà coerente degli edge condivisi, chiusura esplicita dei bordi del viewport, inclusi span di un pixel. Elimina i pixel esterni e i buchi dei casi qualificati senza cambiare geometria, precisione UV o luce. None/flat e i precedenti A/B mantengono il comportamento raster precedente.

## Smooth shading

`gouraud.creaseAngle` ha default 60°, intervallo 0–180°. Angoli minori conservano gli spigoli duri; 180° smussa le superfici curve adiacenti quanto consentito dalla topologia. Cambiano normali/shade vertex, non numero di poligoni o silhouette. Un cubo a 60° conserva gli spigoli; sfera e toro degli esempi usano normali smussate. Una seam UV non richiede una cucitura luminosa visibile.

Il limite runtime è 255 shade vertices dove applicabile, inclusi split delle normali e istanze. La scena ha anche un limite di 255 triangoli runtime. Il builder verifica la memoria effettiva, che può esaurirsi prima.

## Memoria e ambito

Le texture sono unpacked, allineate a pagina, 256 byte per texture 16×16 utilizzata, più allineamento e metadati faccia/puntatori. Pagine texture inutilizzate e metadati luminosi Gouraud inutili vengono omessi dove possibile. I segmenti low/middle/relocated/high usano il layout recuperato; codice/dati high devono restare sotto $D000. Geometria, UV, buffer clipping, stato luminoso e codice generato condividono questo spazio. Non esiste un budget di mesh universale indipendente da luce e configurazione.

Mode 7 richiede geometria esplicita: non supporta loader mesh builtin/file, `meshSourceSharing`, override shading per faccia o campi override material/color/reflectivity per oggetto. Le normali proprietà supportate material/reflectivity sono distinte dagli override della Mode 6.

Limiti intenzionali: mapping affine; nearest-neighbor; texture 16×16; tre pigmenti VIC-II; UV Q4.4; triangoli runtime e quad triangolati. Nessuna perspective correction, bilinear filtering, mipmapping, trasparenza, texture packed runtime o quad mapper nativo. Distorsione affine e aliasing nearest-neighbor in movimento sono limiti previsti, non rendering perspective-correct.

Vedere [formato texture](TEXTURE-GUIDE.it.md), [import PNG](PNG-TEXTURES.it.md), [esempi](examples/README.md) e [test](TESTING.md). Questo packaging non introduce nuove ottimizzazioni.
