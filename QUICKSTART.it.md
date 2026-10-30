# Guida rapida — 1.15.1

Installare Python3 (qualifica con3.13.14), PowerShell7 e64tass1.60.3243.
Pillow serve all'importazione PNG; NumPy/py65 ai test di correttezza opzionali.
`TASS64_EXE` seleziona l'assembler esterno. Nessun eseguibile, scena o demo è allegato.

## Build poligonale ordinaria

Dalla radice dello SDK estratto creare un progetto separato e una copia SDK completa:

```powershell
$project='C:/projects/my-engine'
New-Item -ItemType Directory -Force $project | Out-Null
New-Item -ItemType Directory -Force "$project/inputs" | Out-Null
Copy-Item -LiteralPath . -Destination "$project/sdk" -Recurse
$env:TASS64_EXE='C:/tools/64tass.exe'
```

Salvare questo frammento minimo in `C:/projects/my-engine/inputs/scene.json`.
È documentazione, non un progetto allegato o un carico prestazionale:

```json
{
  "schema": 1, "name": "minimal external input", "graphicsMode": 4,
  "axisConvention": "world-z-up",
  "world": {"backgroundColor": 0, "grounds": []},
  "camera": {"id": "camera", "position": [0,0,0], "rotation": [0,0,0], "mode": "walkLite"},
  "meshes": [{"id": "triangle", "type": "mesh", "geometry": "solid", "materialProfile": "single",
    "vertices": [[-8,0,-6],[8,0,-6],[0,0,8]], "faces": [[0,1,2]]}],
  "objects": [{"id": "object", "mesh": "triangle", "position": [0,40,0],
    "rotation": [0,0,0], "angularVelocity": [0,0,0], "scale": 1,
    "visible": true, "geometry": "solid", "materialProfile": "single",
    "material": "blue", "reflectivity": "satin"}],
  "contract": {"version": 1, "viewportProfile": "normal", "ground": false}
}
```

Compilare quindi in Mode4 legacy-plus:

```powershell
pwsh -NoProfile -File C:/projects/my-engine/sdk/work/build-3Dvibe64.ps1 -SceneFile C:/projects/my-engine/inputs/scene.json -Precision legacy-plus -GraphicsMode 4 -DynamicLight -CameraMode walkLite -CameraViewport normal -MemoryLayout high-basic-v2 -Quality fast -Projection extended-table -VideoStandard pal -FramePresentation safe -NoFpsOverlay -NoCameraRuntimeControls -ExplorerClipMode near -ExplorerNearCrossMode poly -SkipCmdUpdate
```

Gli output sono nella copia di lavoro: `sdk/work/3Dvibe64.asm`,
`sdk/work/3Dvibe64.prg` e `sdk/work/build/3Dvibe64.prg`. Legacy/plus ordinari
rifiutano `-OutputDirectory`: non generano in una cartella arbitraria. Conservare
intatta l'estrazione della release. Avviare il PRG con il proprio VICE/launcher;
queste istruzioni non misurano FPS.

graphicsMode/camera nella scena devono corrispondere ai selettori CLI. Per le
Mode1–6 cambiare entrambe le dichiarazioni; Mode6 richiede high-basic-v2. Mode7
richiede inoltre texture/materiali/UV esterni secondo [MODE7](MODE7.it.md),
[guida texture](TEXTURE-GUIDE.it.md) e [legacy-plus](LEGACY-PLUS.it.md): non viene
fornita una texture predefinita. `legacy` resta il default ordinario; il comando
seleziona plus esplicitamente. Q8 e Normalized16 sperimentale hanno contratti e
output esterni propri.

## Mappa Mode8

Fornire un documento mappa valido, con matrici solid/floor/ceiling32×32,
porte/rampe, posa iniziale del template supportato e navigazione. Seguire
[creazione mappe](MAPS-2.5D.it.md), [Mode8](MODE8.it.md) e i valori contrattuali
camera/navigazione in `work/mode8/templates.json`; nessuna scena mappa è allegata.

```powershell
python -B work/mode8_build.py --scene C:/projects/my-engine/inputs/map.json --out C:/projects/my-engine/map-check --run interactive --validate-only
python -B work/mode8_build.py --scene C:/projects/my-engine/inputs/map.json --out C:/projects/my-engine/map-build --run interactive
```

Usare `--run auto` soltanto con un itinerario completo valido. Gli output
Mode8/Q8/Normalized16 devono essere cartelle nuove esterne allo SDK sorgente.
Il backend dipende dal contenuto della mappa, non dal nome del file; mappe non
supportate vengono rifiutate senza degradazioni silenziose.

Per Mode4/5 in questo profilo plus mantenere `-DynamicLight` se la scena non dichiara luci: altrimenti il percorso shade-step predefinito è incompatibile. Mode6 attiva automaticamente il percorso luce richiesto.

## API, dipendenze e test

`-SphereRenderer circles` emette API opzionali Mode4/6 plus da chiamare in ASM
nell'ordine painter. Non crea entità sfera JSON; il default `none` non aggiunge
codice/RAM. [API cerchi](CIRCLE-SPHERES.it.md) documenta unità e limiti.
`scripts/sphere_api_example.py` è un generatore sorgente opzionale: invocarlo
crea un progetto esterno. Nessuna demo o PRG generato è incluso nella release.

```powershell
python -m pip install -r requirements-tests.txt
python -B scripts/run_release_tests.py
```

Lasciare attive le asserzioni: niente `-O`, `-OO` o `PYTHONOPTIMIZE`. I test
host/CPU autosufficienti non misurano FPS. [Verifiche](TESTING.it.md) distingue
il loro perimetro dalle misure native e dai gate storici. [Input esterni](EXTERNAL-INPUTS.it.md).
