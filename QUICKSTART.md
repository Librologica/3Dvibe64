# Quick start / Guida rapida

3Dvibe64 1.3.0 is a source SDK. It intentionally contains no precompiled PRG:
compile a JSON scene locally with the PowerShell builder.

## Build / Compilazione

From a disposable working copy of the package root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\work\build-3Dvibe64.ps1 `
  -SceneFile .\examples\mode4-walkfull-reference.json `
  -GraphicsMode 4 -CameraMode walkFull -CameraViewport normal `
  -Quality balanced -Projection table -MemoryLayout stable -SkipCmdUpdate
```

The local build product is `work/3Dvibe64.prg`. With the default Generic Text/FPS
split, `normal` has a 160×88 3D body below three character rows and `small` has a
128×80 body. Add `-HeaderText "SCRITTA DI ESEMPIO" -FpsOverlayOnStart` to show a
header at startup. Pass `-NoFpsOverlay` for the legacy 160×100 normal viewport.
At runtime, `F` hides or restores the complete Generic Text/FPS header; it does not
toggle the FPS digits independently.
Use a separate copy when you want the source SDK itself to remain free of generated
artifacts.

For Gouraud rendering, build a Mode 6 reference with the required segmented layout:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\work\build-3Dvibe64.ps1 `
  -SceneFile .\examples\mode6-gouraud-torus.json `
  -GraphicsMode 6 -CameraMode walkFull -CameraViewport normal `
  -Quality balanced -Projection table -MemoryLayout high-basic-v2 -SkipCmdUpdate
```

Il pacchetto 3Dvibe64 1.3.0 contiene solo sorgenti: compilare localmente una scena JSON
con il builder PowerShell. Il comando precedente genera `work/3Dvibe64.prg`.
Con lo split Generic Text/FPS predefinito, `normal` offre un body 3D 160×88 sotto
tre righe di testo e `small` un body 128×80. Usare
`-HeaderText "SCRITTA DI ESEMPIO" -FpsOverlayOnStart` per mostrare l’header
dall’avvio; `-NoFpsOverlay` ripristina la viewport normal storica 160×100.
Durante l’esecuzione, `F` nasconde o ripristina l’intero header Generic Text/FPS,
non le sole cifre FPS. Per mantenere pulito l'SDK, eseguire le build in una copia
di lavoro separata.

See [examples/README.md](examples/README.md) for all public reference scenes and
their complete commands.  The localized README files document the renderer, JSON
schema, camera controls, limits, and public command-line options.

Mode 6 is ordered-dithered Gouraud for VIC-II and uses the validated Gate 5 engine.
`gouraud.creaseAngle` defaults to 60 degrees; use 180 on the coarse torus to smooth
curved boundaries, or compare the hard/smooth cube examples. The silhouette does
not change. The runtime limit is 255 shade vertices. Materials provide
Dark/High/Highlight; reflectivity is satin/gloss/reflective/mirror.
See [TESTING.md](TESTING.md) to verify a clean SDK without generating files inside it.

## Official Mode 7 in 1.3.0

GraphicsMode 1–7 are available. GraphicsMode 1–6 retain their 1.2.0 reference output; the older API sections below still apply to those modes.

Mode 4 is dynamic flat shading. Mode 6 is ordered-dithered Gouraud shading.
Mode 7 is **affine texture mapping**, optionally with flat or Gouraud lighting:
`textureLighting` absent/`"none"`, `"flat"`, or `"gouraud"`.
The official Gouraud compositor is `textureCompositor: "C"` (texel-first + LightFix; now the Gouraud default). R1 corrects edge inclusion in this C path. A/B remain compatibility options, not the recommended renderer.

Mode 7 requires `high-basic-v2`, Python 3, `fast` quality and `extended-table` projection.
Textures are 16×16, nearest-neighbor, three pigment codes 1/2/3, with UV Q4.4 and optional repeat 1/2/4/8/16. It supports per-vertex or corner UVs, seams, per-face textures, triangulated quads (0→2), near/screen clipping, byte-oriented fill, partial bytes, double buffering, PAL/NTSC, normal/small and fixed/walkLite/walkFull.

PNG import is host-side, through Pillow: `source` and mandatory ordered `sourceColors` map exactly three opaque RGB colors to Dark/High/Highlight texels. `texturePalette` separately selects three VIC-II colors. No resizing, quantization or transparency. Inline texels remain supported and runtime-equivalent.

Textured Gouraud uses `gouraud.creaseAngle` (default60°, range0–180°) for hard edges or smooth normals, with the applicable255-shade-vertex limit. Mode 7 has its own memory/geometry constraints and does not inherit every Mode 6 override/source-sharing API.

No perspective correction, bilinear filtering, mipmapping, packed runtime textures or native quad mapper. Affine distortion and sampling aliasing remain intentional limitations.

Read the [complete Mode7 contract](MODE7.en.md), [texture guide](TEXTURE-GUIDE.en.md), [PNG guide](PNG-TEXTURES.en.md), and [eight public examples](examples/README.md). The paired Italian guides cover the same contract.

## Mode 7 ufficiale nella 1.3.0

Sono disponibili GraphicsMode 1–7. Le GraphicsMode 1–6 conservano l'output di riferimento della 1.2.0; le sezioni API precedenti continuano a descrivere quelle modalità.

Mode 4 è flat shading dinamico. Mode 6 è Gouraud ordered-dithered.
Mode 7 è **texture mapping affine**, con luce flat o Gouraud opzionale:
`textureLighting` assente/`"none"`, `"flat"` oppure `"gouraud"`.
Il compositor Gouraud ufficiale è `textureCompositor: "C"` (texel-first + LightFix; ora default Gouraud). R1 corregge l'inclusione degli edge in questo percorso C. A/B restano opzioni di compatibilità, non il renderer consigliato.

Mode 7 richiede `high-basic-v2`, Python 3, qualità `fast` e proiezione `extended-table`.
Le texture sono 16×16, nearest-neighbor, con tre codici pigmento1/2/3, UV Q4.4 e repeat opzionale1/2/4/8/16. Supporta UV per vertice o corner, seam, texture per faccia, quad triangolati(0→2), clipping near/screen, fill byte-oriented, byte parziali, double buffering, PAL/NTSC, normal/small e fixed/walkLite/walkFull.

L'import PNG è host-side tramite Pillow: `source` e `sourceColors` obbligatorio ordinato convertono esattamente tre RGB opachi nei texel Dark/High/Highlight. `texturePalette` sceglie separatamente tre colori VIC-II. Niente resizing, quantizzazione o trasparenza. I texel inline restano supportati ed equivalenti a runtime.

Il Gouraud textured usa `gouraud.creaseAngle` (default60°, intervallo0–180°) per spigoli duri o normali smussate, con il limite di255 shade vertices dove applicabile. Mode 7 ha vincoli propri di memoria/geometria e non eredita tutte le API override/source-sharing della Mode 6.

Niente perspective correction, bilinear filtering, mipmapping, texture packed runtime o quad mapper nativo. Distorsione affine e aliasing di campionamento restano limiti intenzionali.

Leggere il [contratto Mode7 completo](MODE7.it.md), la [guida texture](TEXTURE-GUIDE.it.md), la [guida PNG](PNG-TEXTURES.it.md) e gli [otto esempi pubblici](examples/README.md). Le guide inglesi equivalenti coprono lo stesso contratto.
