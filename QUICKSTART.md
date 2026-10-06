# Quick start / Guida rapida

## Optional fast Mode 7 / Profilo veloce opzionale — 1.7.0

Read the sampling/memory tradeoffs first / Leggere prima i compromessi:
[EN](MODE7-FAST.en.md) · [IT](MODE7-FAST.it.md).
Standard, legacy and affine remain defaults / Default invariati.

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 7 -Precision q8 -TextureQuality fast -SceneFile examples/mode7-fast-cube.json -VideoStandard pal -OutputDirectory ../fast-cube-pal
```

Fast requires perspective + Gouraud C. Use a fresh directory outside the SDK.
Fast richiede perspective + Gouraud C e una directory nuova esterna all'SDK.
Full viewport 160×100 logical, 160×50 sampled; upper-row duplication, block8 UV.
Viewport piena 160×100 logici, 160×50 campionati; duplicazione superiore, UV block8.

## Optional projective textures / Texture prospettiche opzionali — 1.6.1

1.6.1 preserves the 1.6.0 command/profile. Lit projective samplers reserve
`$E8..$EF` zero-page scratch; respect this in custom IRQs. Legacy and affine
remain defaults. [Notes EN/IT](RELEASE-NOTES-1.6.1.md).
La 1.6.1 conserva comandi/profilo 1.6.0. I sampler prospettici illuminati
riservano `$E8..$EF`: rispettarli negli IRQ personalizzati. Default invariati.

Legacy/affine remain defaults / Legacy/affine restano default.
The bounded profile requires explicit Q8; leggere i limiti prima della build:
[EN](TEXTURE-PRECISION.en.md) · [IT](TEXTURE-PRECISION.it.md).

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -Precision q8 -GraphicsMode 7 -TexturePrecision perspective -SceneFile examples/mode7-perspective-cube.json -VideoStandard pal -OutputDirectory ../perspective-cube-pal
```

## Precision / Precisione — 1.5.0

Legacy is always the default; Q8 is explicit, not CPU-selected. Recommend Q8
above 20 MHz and legacy at <=20 MHz. No deprecation. See [EN](PRECISION.en.md).
Legacy è sempre il default; Q8 è esplicito, non selezionato dalla CPU. Consigliato
sopra 20 MHz; legacy fino a 20 MHz, non deprecato. Vedere [IT](PRECISION.it.md).

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -Precision q8 -GraphicsMode 4 -SceneFile examples/q8/two-objects-mode4.json -Q8Camera auto -VideoStandard pal -OutputDirectory ../q8-first
```

New external output directory required / Serve una nuova directory esterna.
Restricted normal/walkLite profile / Profilo limitato normal/walkLite.

## Mode 8 — 2.5D / 1.4.0

Build dependencies: Python 3, PowerShell, 64tass on PATH (or
`TASS64_EXE`). No optional analysis packages are needed for this command.
Dipendenze: Python 3, PowerShell, 64tass nel PATH (o `TASS64_EXE`).
Gli strumenti di analisi opzionali non servono per compilare.

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile examples/mode8/perimeter.json -ValidateOnly
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -GraphicsMode 8 -SceneFile examples/mode8/perimeter.json -Mode8Run interactive -OutputDirectory ../mode8-start
x64sc -default -pal -autostartprgmode 1 ../mode8-start/3Dvibe64.prg
```

W/S move, A/D turn; use `-Mode8Run auto` with a different empty output directory
for the automatic itinerary. PAL/NTSC detection is automatic.
W/S per muoversi, A/D per ruotare; `-Mode8Run auto` con altra directory vuota
produce il percorso automatico. PAL/NTSC viene rilevato automaticamente.

[Map authoring EN](MAPS-2.5D.en.md) · [Creazione mappe IT](MAPS-2.5D.it.md).
These templates have explicit geometry/camera restrictions. Do not add the
polygonal options in the remaining Mode 1–7 examples to a Mode 8 command.
I template hanno vincoli espliciti su geometria e camera. Non aggiungere
alle build Mode 8 le opzioni degli esempi poligonali Mode 1–7 seguenti.

3Dvibe64 1.6.1 is a source SDK. It intentionally contains no precompiled PRG:
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

Il pacchetto 3Dvibe64 1.6.1 contiene solo sorgenti: compilare localmente una scena JSON
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

GraphicsMode 1–8 are available. GraphicsMode 1–6 retain their 1.2.0 reference output; the older API sections below still apply to those modes.

Mode 4 is dynamic flat shading. Mode 6 is ordered-dithered Gouraud shading.
Mode 7 is **affine texture mapping**, optionally with flat or Gouraud lighting:
`textureLighting` absent/`"none"`, `"flat"`, or `"gouraud"`.
The official Gouraud compositor is `textureCompositor: "C"` (texel-first + LightFix; now the Gouraud default). R1 corrects edge inclusion in this C path. A/B remain compatibility options, not the recommended renderer.

Mode 7 requires `high-basic-v2`, Python 3, `fast` quality and `extended-table` projection.
Textures are 16×16, nearest-neighbor, three pigment codes 1/2/3, with UV Q4.4 and optional repeat 1/2/4/8/16. It supports per-vertex or corner UVs, seams, per-face textures, triangulated quads (0→2), near/screen clipping, byte-oriented fill, partial bytes, double buffering, PAL/NTSC, normal/small and fixed/walkLite/walkFull.

PNG import is host-side, through Pillow: `source` and mandatory ordered `sourceColors` map exactly three opaque RGB colors to Dark/High/Highlight texels. `texturePalette` separately selects three VIC-II colors. No resizing, quantization or transparency. Inline texels remain supported and runtime-equivalent.

Textured Gouraud uses `gouraud.creaseAngle` (default60°, range0–180°) for hard edges or smooth normals, with the applicable255-shade-vertex limit. Mode 7 has its own memory/geometry constraints and does not inherit every Mode 6 override/source-sharing API.

The default affine path has no perspective correction. Optional projective interpolation requires the bounded Q8 profile; see [texture precision](TEXTURE-PRECISION.en.md). No bilinear filtering, mipmapping, packed runtime textures or native quad mapper. Sampling aliasing remains.

Read the [complete Mode7 contract](MODE7.en.md), [texture guide](TEXTURE-GUIDE.en.md), [PNG guide](PNG-TEXTURES.en.md), and [eight public examples](examples/README.md). The paired Italian guides cover the same contract.

## Mode 7 ufficiale nella 1.3.0

Sono disponibili GraphicsMode 1–8. Le GraphicsMode 1–6 conservano l'output di riferimento della 1.2.0; le sezioni API precedenti continuano a descrivere quelle modalità.

Mode 4 è flat shading dinamico. Mode 6 è Gouraud ordered-dithered.
Mode 7 è **texture mapping affine**, con luce flat o Gouraud opzionale:
`textureLighting` assente/`"none"`, `"flat"` oppure `"gouraud"`.
Il compositor Gouraud ufficiale è `textureCompositor: "C"` (texel-first + LightFix; ora default Gouraud). R1 corregge l'inclusione degli edge in questo percorso C. A/B restano opzioni di compatibilità, non il renderer consigliato.

Mode 7 richiede `high-basic-v2`, Python 3, qualità `fast` e proiezione `extended-table`.
Le texture sono 16×16, nearest-neighbor, con tre codici pigmento1/2/3, UV Q4.4 e repeat opzionale1/2/4/8/16. Supporta UV per vertice o corner, seam, texture per faccia, quad triangolati(0→2), clipping near/screen, fill byte-oriented, byte parziali, double buffering, PAL/NTSC, normal/small e fixed/walkLite/walkFull.

L'import PNG è host-side tramite Pillow: `source` e `sourceColors` obbligatorio ordinato convertono esattamente tre RGB opachi nei texel Dark/High/Highlight. `texturePalette` sceglie separatamente tre colori VIC-II. Niente resizing, quantizzazione o trasparenza. I texel inline restano supportati ed equivalenti a runtime.

Il Gouraud textured usa `gouraud.creaseAngle` (default60°, intervallo0–180°) per spigoli duri o normali smussate, con il limite di255 shade vertices dove applicabile. Mode 7 ha vincoli propri di memoria/geometria e non eredita tutte le API override/source-sharing della Mode 6.

Il default affine non corregge la prospettiva. L’interpolazione prospettica opzionale richiede il profilo Q8 limitato: vedere [precisione texture](TEXTURE-PRECISION.it.md). Niente bilinear, mipmapping, texture runtime packed o quad mapper nativo. Resta l’aliasing di campionamento.

Leggere il [contratto Mode7 completo](MODE7.it.md), la [guida texture](TEXTURE-GUIDE.it.md), la [guida PNG](PNG-TEXTURES.it.md) e gli [otto esempi pubblici](examples/README.md). Le guide inglesi equivalenti coprono lo stesso contratto.
