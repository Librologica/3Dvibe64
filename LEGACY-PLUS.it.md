> Edizione di sviluppo 1.15.0-dev2; contratti1.14.0 ereditati salvo estensioni esplicite nel [rendering esatto](EXACT-RENDER.it.md).

# Legacy-plus — 1.14.0

`-Precision legacy-plus` è il renderer intermedio esplicito per Mode1–7: matrici oggetto legacy Q6, geometria camera Q4, coefficienti camera Q10 e4096 fasi yaw/pitch. Legacy resta il default. Il selettore compatibile `-LegacyStability rotation` rimane solo Mode2. Mode8 e Normalized16 mantengono contratti separati. La distribuzione stabile è pubblicata su GitHub; i metadati sono in PACKAGE-MANIFEST.json.

## Build e configurazione

Copiare tutto l'SDK sorgente in una cartella di lavoro nuova. Fornire una scena esterna con graphicsMode coerente e camera walkLite. Python3, PowerShell7,64tass e Pillow opzionale sono dipendenze esterne; `TASS64_EXE` seleziona l'assembler.

```powershell
Copy-Item -LiteralPath ./repository -Destination ./my-build-sdk -Recurse
pwsh -NoProfile -File ./my-build-sdk/work/build-3Dvibe64.ps1 -SceneFile ../my-inputs/scene7.json -Precision legacy-plus -GraphicsMode 7 -TexturePrecision perspective -CameraMode walkLite -CameraViewport normal -MemoryLayout high-basic-v2 -Quality fast -Projection extended-table -VideoStandard pal -FramePresentation safe -NoFpsOverlay -ExplorerClipMode near -ExplorerNearCrossMode poly -SkipCmdUpdate
```

Dall'interno dell'SDK copiare `.` invece di `./repository`. Usare `-TexturePrecision affine` per Mode7 affine; omettere l'opzione in Mode1–6. Il builder scrive `work/3Dvibe64.asm`, `work/3Dvibe64.prg` e una copia PRG in `work/build/`; le build solide includono metadati di allocazione. Label/mappa diagnostiche complete richiedono64tass esplicito (`--vice-labels-numeric --labels=... --map=...`). Legacy/plus ordinari rifiutano `-OutputDirectory`; Q8/Normalized16/Mode8 hanno adapter di output esterno propri.

Profilo plus supportato: **walkLite, normal160×100, high-basic-v2, -NoFpsOverlay**; clipping poligonale near8 e schermo, `Mode4NearProfile default`. Plus seleziona i default near/poly e rifiuta profili di clipping incompatibili. Niente roll, viewport small, split testo/FPS o clipping Ground plane. Le prove non usano Ground; pavimenti come mesh esplicite seguono il clipping poligonale normale. Orizzonte/Ground non hanno nuova qualifica. Area/span0 sono impostazioni esplicite del benchmark, non nuovi default qualitativi: `-MinFaceAreaOverride 0 -ScreenMinSpanOverride 0` riproduce i confronti.

| Mode | Rendering plus |
|---|---|
|1|Spigoli wire originali, inclusi attraversamenti near/schermo dei segmenti|
|2|Hidden wire, conservando i flag degli spigoli sorgente|
|3|Solido statico|
|4|Flat dinamico, contratto Q2 nativo per Y schermo|
|5|Flat dinamico + contorni, contratto Q2 nativo per Y schermo|
|6|Gouraud, interpolazione della luce con lo stesso parametro near/schermo|
|7|Texture VIC-II16×16 affini o prospettiche; none/flat/Gouraud A/B/C|

## Camera, clipping e memoria

L'ABI pubblico usa posizioni signed24 con8 bit frazionari e assi engine-y-up; il JSON usa world-z-up. Il byte basso è la frazione, non un selettore di geometria Q8. La geometria interna plus è Q4. Yaw/pitch usano angolo byte più i4 bit frazionari alti,4096 fasi; impostare tutti i campi prima di `render_frame_begin`. Passi angolari byte della tastiera e rotazioni oggetto Q6 restano quelli ereditati. Vedere [ABI camera](CAMERA-ROTATION.it.md).

Le coordinate relative camera devono restare in **[-1024,1024)WU per asse**; controllare `legacy_camera_fault`. La cache separata Q4 occupa6 byte/vertice e conserva i buffer interi legacy. Near8WU corrisponde a128Q4. Attributi grezzi e geometria near condividono peso16 bit e arrotondamento signed al più vicino. Lo schermo resta Q4 fino alla conversione raster. Mode4–6 conservano Y schermo Q2; Mode7 prospettica usa le regole comuni di copertura Q2 sugli endpoint plus. Risoluzione visibile e colori non aumentano.

La proprietà degli spigoli wire originali sopravvive al clipping; i limiti schermo sono ripristinati per faccia. Offset almeno$3a00 conservano il fallback wide. Mode1/2 possono usare la LUT prodotti camera da3072 byte quando entra; Mode3–7 usano prodotti seriali esatti per evitare sovrapposizioni con codice solido attivo. Gli helper sono allocati in RAM realmente libera, con guardie assembly. Mode7 Gouraud può usare soltanto la coda verificata dopo `RUNTIME_BUFFER_COLOR_POLICY_END+32`, sotto$9000 e senza LUT rotazione/overlay FPS. La capacità dipende dalla mappa effettiva, non da un numero universale di vertici.

## Mode7 prospettica

Le UV sorgente restano Q4.4. Dopo il near sulle UV grezze, si calcolano carrier unsigned16: `W=floor(524288/Z_Q4)`, `UW=floor(U_Q4.4*W/128)` e analogamente VW. Lo schermo interpola UW/VW/W con il peso geometrico. Le DDA quoziente/resto di bordi e span campionano `floor(carrier*128/W)`. Gouraud Q mantiene la DDA di luce a schermo. Gli span interni half-open di larghezza zero non scrivono pixel; i cap chiusi del viewport conservano la copertura del bordo.

La profondità lungo la camera deve restare **8–256WU inclusi** dopo il near. `ps_fault` è persistente: profondità/denominatore invalidi fermano la pubblicazione con bordo rosso. Nessun ripiego affine. Restano arrotondamenti Q4/carrier e campionamento nearest. `TextureQuality standard`, LOD off; fast/LOD restano opzioni Q8. La prospettiva LP riusa allocazione host e DDA/campionatore texture generici con simboli privati; non collega trasformazione, proiezione o clipping geometrici Q8. I carrier texture non sono geometria Q8.

## Qualifica

[Confronto nativo e limiti](QUALIFICATION-1.14.0.it.md) · [dati strutturati](QUALIFICATION-1.14.0.json) · [verifiche](TESTING.md). Le build finali devono coincidere con gli hash PRG misurati per riusarne gli FPS. PAL Turbo6510×64, safe, silenzioso; percorsi completi dopo warm-up. Nessuna nuova qualifica NTSC o hardware fisico. Il rapporto Mode2 della1.13.0 resta [storico](QUALIFICATION-1.13.0.it.md), non misura scene diverse.
