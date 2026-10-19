# 3Dvibe64 world metrics / Metrica del mondo 3Dvibe64 — 1.15.0

> Published stable1.15.0 source SDK. [Status and support](RELEASE-STATUS.en.md).

3Dvibe64 1.12.0: [EN optimization contract](RENDER-OPTIMIZATIONS.en.md) · [Contratto IT](RENDER-OPTIMIZATIONS.it.md).
All examples require external inputs / Tutti gli esempi richiedono input esterni.


Current 1.12.0 ordinary metric/geometry contract; inherited sections retain their stated profile/version.
Contratto metrico/geometrico ordinario 1.12.0; sezioni ereditate con profilo/versione dichiarati.
Current contracts / Contratti correnti: [EN](README.en.md), [IT](README.it.md);
[gameplay EN](GAMEPLAY.en.md), [gameplay IT](GAMEPLAY.it.md);
[qualification EN](QUALIFICATION-1.13.0.en.md), [qualificazione IT](QUALIFICATION-1.13.0.it.md).

## Precision profiles / Profili di precisione — 1.10.0

Q8: byte-index ceilings of 255 disjoint objects/runtime vertices, subject to real RAM guards.
Normalized 16: experimental, at most two objects/16 runtime vertices.
Q8: tetti di codifica di 255 oggetti disgiunti/vertici runtime, con controlli RAM reali.
Normalized 16: sperimentale, massimo due oggetti/16 vertici runtime.
See / Vedere [Official contract / Contratto ufficiale](Q8-SCALABILITY.md) and [qualification](Q8-QUALIFICATION.md).

Legacy remains the default; the metric/renderer contracts below describe legacy
unless explicitly stated otherwise. Optional Q8 has a narrower qualified scope,
not a global replacement. See [Q8 EN](PRECISION.en.md).
Legacy resta il default; i contratti metrici/renderer seguenti descrivono legacy
salvo indicazione diversa. Q8 opzionale ha un ambito qualificato più ristretto,
non sostituisce globalmente legacy. Vedere [Q8 IT](PRECISION.it.md).

## Scope / Ambito in 1.4.0

The WU/TU and mesh-camera conventions below apply to **Modes 1–7**.
Mode 8 is a separate cell-map contract: 32 × 32 cells, position already encoded
as Q8.8 integers (256 units/cell), vertical values in 1/32 cell, yaw 0–511
(512 units/turn). Yaw 0 looks +Y, 128 looks +X. It does not automatically convert
polygonal units. See [complete EN guide](MAPS-2.5D.en.md).

Le convenzioni WU/TU e della camera mesh sotto valgono per **Mode 1–7**.
La Mode 8 ha un contratto separato: 32 × 32 celle, posizione già codificata come
interi Q8.8 (256 unità/cella), quote in 1/32 di cella, yaw 0–511
(512 unità/giro). Yaw 0 guarda +Y, 128 guarda +X. Non converte automaticamente
le unità poligonali. Vedere la [guida IT completa](MAPS-2.5D.it.md).

This document defines the metric contract promoted in `0.1.0-pre-1.0`, including the mobile-camera initialization correction validated in pre-1.0 development, the object-depth signed 16.8 validation added in pre-1.0 development, the historical movement audit in pre-1.0 development, and the updated walk-camera control defaults validated in pre-1.0 development. It describes an abstract engine convention, not a physical-unit convention: a world unit is not automatically a metre, centimetre, inch, or any other real-world measure. Physical scale belongs to a scene or to authoring tools. The pre-1.0 `walkLite` zero-pitch framebuffer fix changes only CPU depth-test flags and does not alter WU, TU, or ST semantics.

Questo documento definisce il contratto metrico promosso in `0.1.0-pre-1.0`, includendo la correzione dell'inizializzazione camera pre-1.0 development, la validazione signed 16.8 della profondita oggetto pre-1.0 development, l'audit storico del movimento pre-1.0 development e i nuovi default dei controlli walk validati nella pre-1.0 development. Descrive una convenzione astratta dell'engine e non introduce una scala fisica: una world unit non equivale automaticamente a un metro, centimetro, pollice o altra misura reale. La correzione pre-1.0 del framebuffer `walkLite` pitch-zero modifica soltanto i flag CPU del test di profondita e non altera la semantica WU, TU o ST.

## Normative vocabulary / Vocabolario normativo

- **WU — world unit.** The abstract linear unit used by scene positions and local mesh coordinates after scale. Where a fixed-point accumulator is present, one WU contains 256 positional sub-units.
- **TU — turn unit.** The angular unit. One turn is 256 TU, so 1 TU is 360/256 = 1.40625 degrees.
- **ST — simulation tick.** The step at which object motion, object rotation, camera controls, light phases, depth ping-pong, and the other automatic state machines advance.
- **WU — world unit.** Unita lineare astratta usata dalle posizioni di scena e dalle coordinate locali delle mesh dopo la scala. Dove esiste un accumulatore fixed-point, una WU contiene 256 sotto-unita posizionali.
- **TU — turn unit.** Unita angolare. Un giro contiene 256 TU, quindi 1 TU equivale a 360/256 = 1,40625 gradi.
- **ST — simulation tick.** Passo con cui avanzano movimento e rotazione degli oggetti, controlli camera, fasi luce, depth ping-pong e gli altri automatismi.

The fixed-point statement is deliberately qualified. pre-1.0 does not expose one uniform 8.8 storage format for every scene entity; the exact formats are listed below.

La definizione fixed-point e intenzionalmente qualificata. pre-1.0 non espone un unico formato 8.8 per tutte le entita; i formati effettivi sono elencati sotto.

## Axes and conversion / Assi e conversione

The public scene convention is `world-z-up`:

- +X is right, -X is left;
- +Y is forward/deeper into the world, -Y is backward;
- +Z is up, -Z is down.

La convenzione pubblica e `world-z-up`:

- +X e destra, -X e sinistra;
- +Y e avanti/verso il fondo del mondo, -Y e indietro;
- +Z e alto, -Z e basso.

The internal engine convention is Y-up and Z-depth. Scene vectors are converted exactly as follows:

La convenzione interna dell'engine è Y-up con profondità Z. I vettori di
scena sono convertiti esattamente come nella formula condivisa seguente:

```text
engineX = worldX
engineY = worldZ
engineZ = worldY
```

The same component permutation is used for object position, velocity, rotation, angular velocity, camera position/rotation, and static light position. Generated assembly from the audit scene confirmed, for example, camera `[3,5,7] -> [3,7,5]`, object `[11,69,13] -> [11,13,69]`, and static light `[17,19,23] -> [17,23,19]`.

La stessa permutazione delle componenti vale per posizione, velocità,
rotazione e velocità angolare oggetto, posizione/rotazione camera e posizione
della luce statica. L'assembly generato dalla scena di audit conferma, per
esempio, camera `[3,5,7] -> [3,7,5]`, oggetto `[11,69,13] -> [11,13,69]` e
luce statica `[17,19,23] -> [17,23,19]`.

## Ground plane / Piano Ground

In pre-1.0, `ground.z` is a whole WU coordinate on the public Z-up axis. `WorldGroundMode=plane` therefore defines the geometric plane `world Z = ground.z`; it is available in GraphicsMode 2-5. A face wholly on the side opposite the camera is rejected, while a crossing face is clipped before the normal near-plane and screen clipping stages. Crossing the plane changes the retained side; changing camera height without crossing it does not.

In pre-1.0, `ground.z` è una coordinata WU intera sull'asse Z-up pubblico.
`WorldGroundMode=plane` definisce quindi il piano geometrico
`world Z = ground.z`, disponibile nelle GraphicsMode 2–5. Una faccia interamente
sul lato opposto alla camera viene rifiutata; una faccia che attraversa il piano
è clippata prima del normale clipping near e screen. Attraversare il piano
cambia il lato conservato; cambiare quota camera senza attraversarlo no.

Mode 2 keeps a line-only presentation in both Ground profiles. `simple` is decorative and performs no geometric clipping. `plane` performs geometric classification and clipping, but still draws no half-plane; hidden-wire face masks and final edges use the post-clipping polygon. Modes 3-5 retain the traditional screen-space behavior for `simple`, while `plane` fills the projected half-plane and clips geometry. Mode 1 supports only the decorative roll-aware horizon.

Mode 2 mantiene una presentazione a sole linee in entrambi i profili Ground.
`simple` è decorativo e non esegue clipping geometrico. `plane` classifica e
clippa geometricamente, ma non disegna un semipiano; maschere hidden-wire e
bordi finali usano il poligono risultante dal clipping. Mode 3–5 conservano il
comportamento tradizionale screen-space con `simple`; `plane` riempie il
semipiano proiettato e clippa la geometria. Mode 1 supporta soltanto l'orizzonte
decorativo che tiene conto del roll.

The roll convention observed by the renderer is: `+32 TU` slopes down to the right, `-32 TU` slopes up to the right, and `+64 TU` is vertical. A horizon line wholly above, below, or laterally outside the viewport is rejected; the Mode 1/2 non-intersection sentinel is `$FF`, so no line is clamped to a border. Mode 2 `plane` adds `VERT_COUNT` bytes for `ground_vside`; the Ground-plus-near clipping pipeline is provisioned for polygons through 12 vertices. The `plane` path has a greater byte/cycle cost than `simple` and may require `high-basic-v2`.

Convenzione roll osservata dal renderer: `+32 TU` scende verso destra,
`-32 TU` sale verso destra, `+64 TU` è verticale. Un orizzonte interamente sopra,
sotto o lateralmente fuori viewport è rifiutato; la sentinella di mancata
intersezione Mode 1/2 è `$FF`, quindi nessuna linea viene clampata al bordo.
Mode 2 `plane` aggiunge `VERT_COUNT` byte per `ground_vside`; la pipeline
Ground-plus-near supporta poligoni fino a 12 vertici. `plane` costa più byte/cicli
di `simple` e può richiedere `high-basic-v2`.

For camera `rotation`, the public array is best read as rotations about public X/Y/Z. After conversion, the runtime variables receive `pitch=rotX`, `yaw=rotZ`, and `roll=rotY`, matching a Z-up world whose forward axis is Y. The alternative named camera fields are ambiguous in pre-1.0: the builder assembles `[pitch,yaw,roll]` and then applies the same component permutation, so the named `yaw` and `roll` do not land in the variables their names suggest. Use the three-component `rotation` array until that authoring API is audited separately.

Per `rotation` della camera, leggere l'array pubblico come rotazioni attorno
agli assi pubblici X/Y/Z. Dopo la conversione, le variabili runtime ricevono
`pitch=rotX`, `yaw=rotZ`, `roll=rotY`, coerentemente con mondo Z-up e asse forward Y.
I campi camera nominati alternativi sono ambigui in pre-1.0: il builder assembla
`[pitch,yaw,roll]` e applica la stessa permutazione, quindi `yaw` e `roll` nominati
non arrivano nelle variabili suggerite dai nomi. Usare l'array `rotation` a tre
componenti finché quell'API di authoring non sarà verificata separatamente.

Raw local mesh vertices are not axis-converted by the builder. They are copied in component order after integer coercion. Therefore `axisConvention: world-z-up` governs scene vectors, but mesh importers/exporters must currently deliver local vertex axes in the orientation expected by the engine. This is an authoring-contract gap, not a change made by this audit.

I vertici locali raw della mesh non sono convertiti per asse dal builder:
sono copiati nell'ordine delle componenti dopo conversione a intero.
`axisConvention: world-z-up` governa quindi i vettori di scena, ma gli
importer/exporter delle mesh devono fornire assi locali nell'orientamento
atteso dall'engine. È una lacuna del contratto di authoring, non una modifica
introdotta da questo audit.

## Numeric formats and ranges / Formati numerici e intervalli

Host-side fixed conversion uses `round(value * 256)` with .NET midpoint-to-even rounding. Out-of-range values cause a build error; they are not clamped.

La conversione fixed host-side usa `round(value * 256)` con arrotondamento .NET midpoint-to-even. I valori fuori intervallo causano un errore di build e non vengono clampati.

### Objects / Oggetti

With `world-z-up`, object position and velocity map to these internal containers:

Con `world-z-up`, posizione e velocità oggetto usano i contenitori interni
indicati nella tabella condivisa. X pubblico corrisponde a X interno, Z a Y,
Y forward a Z depth; gli intervalli accettati sono riportati per ogni formato.

| Public component / Componente pubblica | Internal component / Componente interna | Position format/range / Formato e intervallo posizione | Velocity format/range / Formato e intervallo velocità |
|---|---|---|---|
| X | X | signed 8.8, -128 to 127.99609375 WU | signed 8.8, -128 to 127.99609375 WU/ST |
| Z | Y | signed 8.8, -128 to 127.99609375 WU | signed 8.8, -128 to 127.99609375 WU/ST |
| Y (forward) | Z (depth) | signed 16.8 `[fraction, integer-low, signed-extension]`, raw center domain -32768 to 32767.99609375 WU; mesh-safe interval validated per object | signed 16.8, -32768 to 32767.99609375 WU/ST |

The depth position container is emitted as three bytes, but its extension byte is sign extension rather than an extra unsigned magnitude byte. The runtime therefore represents raw values -8388608..8388607, or -32768..32767.99609375 WU. Before pre-1.0 development the host accepted -8388608..16777215 (-32768..65535.99609375 WU); values above 32767.99609375 encoded extension `$80..$FF` and were consumed as negative geometry. pre-1.0 development rejects this before assembly.

Il contenitore della posizione depth è emesso in tre byte, ma il byte di
estensione estende il segno, non aggiunge magnitudine unsigned. Il runtime
rappresenta quindi raw -8388608..8388607, ossia -32768..32767,99609375 WU.
Prima dello sviluppo pre-1.0, l'host accettava -8388608..16777215, cioè
-32768..65535,99609375 WU: sopra 32767,99609375 l'estensione `$80..$FF` veniva
interpretata come geometria negativa. Lo sviluppo pre-1.0 rifiuta questi
valori prima dell'assemblaggio.

The safe center interval is also reduced by the mesh's possible local-depth extension. For each vertex and the object's quantized `scaleQ6`, the builder computes the all-rotation Q6 envelope:

L'intervallo sicuro del centro si restringe inoltre in funzione della
possibile estensione depth locale della mesh. Per ogni vertice e per la scala
quantizzata `scaleQ6`, il builder calcola l'envelope Q6 per tutte le rotazioni
con la formula condivisa seguente:

```text
Evertex = floor(abs(x)*scaleQ6/64)
        + floor(abs(y)*scaleQ6/64)
        + floor(abs(z)*scaleQ6/64)
E = max(Evertex)
```

This mirrors the three separately truncated `mul_s6` terms. When `E < 128`, local depth is conservatively bounded by `[-E,+E]`; when `E >= 128`, byte addition may wrap and the complete signed local-byte domain `[-128,+127]` is used. If those local bounds are `[Dmin,Dmax]`, a safe runtime center integer is `[-32768-Dmin, 32767-Dmax]`. The accepted authored interval additionally follows fractional consumption: `fixed` rounds values whose fraction has bit 7 set upward into integer depth, while `walkLite` and `walkFull` ignore the stored object-center fraction during geometry. The final interval is intersected with the raw signed 16.8 domain.

La formula rispecchia i tre termini `mul_s6` troncati separatamente. Con
`E < 128`, la profondità locale è limitata conservativamente a `[-E,+E]`;
con `E >= 128`, la somma a byte può andare in wrap e si usa tutto il dominio
signed del byte locale `[-128,+127]`. Per limiti locali `[Dmin,Dmax]`, il
centro intero runtime sicuro è `[-32768-Dmin,32767-Dmax]`. L'intervallo di
authoring tiene conto anche della frazione: `fixed` arrotonda verso l'alto
la depth intera quando il bit 7 della frazione è attivo; `walkLite` e `walkFull`
ignorano nella geometria la frazione del centro oggetto memorizzata. Il risultato
è intersecato con il dominio raw signed 16.8.

Examples: a point mesh has raw intervals `[-32768,32767.49609375]` in `fixed` and `[-32768,32767.99609375]` in mobile modes; the standard cube at scale 64/64 has Q6 extension `[-84,+84]`, giving `[-32684.5,32683.49609375]` in `fixed` and `[-32684,32683.99609375]` in mobile modes. At scale 127/64 its envelope reaches the byte boundary, so `[-128,+127]` is used. complex reference mesh at scale 61/64 yields `[-89,+89]`. These are safety envelopes for every rotation, not claims that every bound is geometrically attainable.

Esempi: una mesh punto ammette raw `[-32768,32767.49609375]` in `fixed` e
`[-32768,32767.99609375]` nelle camere mobili. Il cubo standard a scala 64/64
ha estensione Q6 `[-84,+84]`, quindi `[-32684.5,32683.49609375]` in `fixed`
e `[-32684,32683.99609375]` nelle camere mobili. A scala 127/64 l'envelope
raggiunge il limite del byte: si usa `[-128,+127]`. La mesh complex di
riferimento a scala 61/64 dà `[-89,+89]`. Sono envelope di sicurezza per
qualsiasi rotazione, non una garanzia che ogni estremo sia geometricamente
raggiungibile.

The depth-validation diagnostic reports the object, requested world Y,
safe interval, mesh extension, Q6 scale and resulting minimum/maximum depth.
Il messaggio diagnostico di validazione depth riporta oggetto, world Y richiesto,
intervallo sicuro, estensione mesh, scala Q6 e profondità minima/massima risultante.

This contract protects object-world composition (`center + transformed/scaled local vertex`) at build time. Camera-relative arithmetic is a later signed operation: initial diagnostic poses at the origin are covered by the fixed/walk matrix, but no static object-position check can guarantee an indefinitely moving camera because mobile camera accumulators have no world-boundary clamp. That existing runtime-motion policy is not changed by pre-1.0 development.

Il contratto protegge la composizione oggetto-mondo
(`center + transformed/scaled local vertex`) in compilazione. L'aritmetica
relativa alla camera è un'operazione signed successiva: la matrice fixed/walk
copre pose diagnostiche iniziali all'origine, ma un controllo statico della
posizione oggetto non garantisce una camera in moto indefinito, perché gli
accumulatori mobili non hanno clamp ai confini del mondo. Questa politica
runtime esistente resta invariata nello sviluppo pre-1.0.

Runtime additions wrap at their container width unless a specific subsystem implements a clamp. Object X/Z-public accumulators wrap at 16 bits; forward depth uses 24 bits. Rendering consumes integer WU from these accumulators, so sub-units accumulate motion smoothly but visible geometry changes at integer-coordinate boundaries.

Le somme runtime vanno in wrap alla larghezza del contenitore, salvo clamp
esplicito di un sottosistema. Gli accumulatori X/Z pubblici degli oggetti sono
a 16 bit; la profondità forward a 24 bit. Il rendering consuma WU intere:
le sotto-unità accumulano il moto in modo regolare, ma la geometria visibile
cambia ai confini delle coordinate intere.

### Camera / Camera

Scene and camera-file starting coordinates are coerced to whole integers and must be in -63..63 WU. They are not authored as fractional 8.8 values. A mobile camera then uses three-byte signed accumulators with one fractional byte, so controls advance in 1/256-WU sub-units.

Le coordinate iniziali di scena e file camera sono convertite a interi
e devono stare in -63..63 WU. Non vengono definite come valori 8.8 frazionari.
La camera mobile usa poi accumulatori signed a tre byte con un byte frazionario,
quindi i controlli avanzano a passi di 1/256 WU.

`0.1.0-pre-1.0-pre-1.0 development-camera-initial-sign-extension` corrects the initial encoding for all three internal axes. Each whole-WU coordinate is emitted as `[lowFraction, highInteger, signedExtension]`. Public world X maps to internal X, public world Z maps to internal Y, and public world Y maps to internal Z. Negative integer starts use extension `$FF`; zero and positive starts use `$00`. Examples are `$00:$C1:$FF` for -63 WU, `$00:$FF:$FF` for -1 WU, and `$00:$3F:$00` for +63 WU. This is a one-time host-side encoding decision, not a per-frame conversion.

`0.1.0-pre-1.0-pre-1.0 development-camera-initial-sign-extension` corregge
la codifica iniziale di tutti e tre gli assi interni. Ogni coordinata WU intera
è emessa come `[lowFraction,highInteger,signedExtension]`. X mondo pubblico
va in X interno, Z in Y, Y in Z. Le partenze negative usano estensione `$FF`,
zero/positive `$00`: `$00:$C1:$FF` per -63 WU, `$00:$FF:$FF` per -1 WU,
`$00:$3F:$00` per +63 WU. È una codifica host eseguita una volta, non una
conversione per frame.

An explicit mobile camera at `[0,0,0]` remains at the real origin. The historical internal-depth fallback to -64 WU applies only when `CameraSource=default`, that is, when no camera was explicitly supplied by a scene or camera file. Translation-invariance tests confirm identical camera-space coordinates and framebuffer screenshots for translated-equivalent scenes in both `walkLite` and `walkFull`.

Una camera mobile esplicita a `[0,0,0]` resta all'origine reale. Il fallback
storico della profondità interna a -64 WU vale solo con `CameraSource=default`,
cioè senza camera esplicita nella scena o in un file camera. I test di
invarianza per traslazione confermano coordinate camera-space e screenshot
framebuffer identici per scene equivalenti traslate, sia walkLite sia walkFull.

Camera motion has no world-boundary clamp; sufficiently long motion wraps at the accumulator width.

Il moto camera non ha clamp ai confini del mondo; su durate sufficientemente
lunghe va in wrap alla larghezza dell'accumulatore.

### Lights / Luci

Static and generated orbit-light coordinates are signed whole bytes in -127..127 WU. They do not have fractional 8.8 authoring or runtime storage. Orbit samples are precomputed as integer coordinates.

Le coordinate delle luci statiche e orbitali generate sono byte signed
interi in -127..127 WU. Non hanno authoring o storage runtime 8.8 frazionario.
I campioni dell'orbita sono precalcolati come coordinate intere.

### Meshes and Q6 scale / Mesh e scala Q6

Mesh vertex components are coerced to integers using PowerShell/.NET midpoint-to-even conversion and must end in -63..63. Fractions are rounded rather than rejected.

Le componenti dei vertici mesh sono convertite a interi con PowerShell/.NET
midpoint-to-even e devono risultare in -63..63. Le frazioni sono arrotondate,
non rifiutate.

`scale` is converted with `round(scale * 64)` and stored as `scaleQ6`; valid stored values are 1..127:

`scale` diventa `round(scale * 64)` ed è memorizzata come `scaleQ6`,
con valori validi 1..127. La formula condivisa mostra scala 1.0=64/64,
0.5=32/64 e massimo 127/64=1,984375.

```text
scale 1.0 = 64/64
scale 0.5 = 32/64
maximum   = 127/64 = 1.984375
```

The intended geometric relation is:

La relazione geometrica prevista è quella della formula condivisa seguente:

```text
effective world coordinate = local integer vertex * scaleQ6 / 64
```

The runtime combines scale with Q6 rotation matrices and `mul_s6`, whose division by 64 truncates the magnitude toward zero. Rotation and scale are therefore integer-quantized, not exact real arithmetic.

Il runtime combina scala, matrici di rotazione Q6 e `mul_s6`, la cui
divisione per 64 tronca la magnitudine verso zero. Rotazione e scala sono
quindi quantizzate intere, non aritmetica reale esatta.

The built-in standard cube uses local coordinates -28 and +28 on every axis. At scale 1.0 its side is 56 WU and its half-side is 28 WU. This cube is an artistic reference only; it does not define the WU.

Il cubo standard incorporato usa coordinate locali -28 e +28 su ogni asse.
A scala 1.0 il lato è 56 WU e il semilato 28 WU. È un riferimento artistico,
non la definizione della WU.

## Geometric depth and near plane / Profondita geometrica e near-plane

All camera profiles use the same abstract WU. The `default` profile in GraphicsMode 3, 4, and 5 uses:

Tutti i profili camera usano la stessa WU astratta. Il profilo `default`
nelle GraphicsMode 3/4/5 usa la soglia geometrica 8 WU della formula condivisa.

```text
CAMERA_FACE_MIN_DEPTH = 8 WU
```

pre-1.0 exposes `-Mode4NearProfile default|late|clip` for GraphicsMode 3, 4, and 5. The option name is retained for compatibility. `late` uses:

pre-1.0 espone `-Mode4NearProfile default|late|clip` nelle GraphicsMode 3/4/5.
Il nome dell'opzione è mantenuto per compatibilità. `late` usa le regole
condivise seguenti: rifiuto depth<=0, profondità minima accettata 1 WU,
divisore di proiezione minimo 2.

```text
reject depth <= 0 WU
minimum accepted depth = 1 WU
projection_divisor = max(2, camera_depth_geometric)
```

`late` separates the reject distance from the minimum projection divisor: depth 1 WU is projected with divisor 2, producing a limited plateau between 1 and 2 WU, and geometric depth is used at and beyond 2 WU. Near-polygon clipping remains disabled, backface culling is unchanged, and no two-sided behavior is introduced. Faces crossing the camera plane are rejected as complete faces.

`late` separa distanza di rifiuto e divisore minimo: depth 1 WU viene proiettata
con divisore 2, creando un plateau limitato fra 1 e 2 WU; da 2 WU si usa la depth
geometrica. Il clipping poligonale near rimane disabilitato, il backface culling
invariato e non si introducono facce a due lati. Le facce che attraversano il
piano camera sono rifiutate interamente.

`clip` keeps the same 1 WU intersection depth and minimum projection divisor of 2, but clips a crossing face against the camera plane with Sutherland-Hodgman instead of rejecting the complete face. Ground plane clipping runs first. Backface culling remains one-sided and uses the original camera-space polygon; rasterization in Modes 3-5 and the Mode 5 outline use the final post-clipping polygon and its final edges. A diagnostic wall remains visible at +0.5 WU and on the plane at 0 WU, where the diagnostic face has five post-clipping vertices, then is rejected at -0.25 WU after the camera has genuinely crossed it. The legacy near-polygon path remains disabled.

`clip` mantiene intersezione a 1 WU e divisore minimo 2, ma clippa la faccia
che attraversa il piano camera con Sutherland-Hodgman invece di rifiutarla
interamente. Il clipping Ground viene prima. Il backface culling rimane
monofacciale e usa il poligono camera-space originale; raster Mode 3–5 e
outline Mode 5 usano poligono ed edge finali dopo clipping. Una parete
diagnostica resta visibile a+0,5 WU e sul piano a 0 WU, dove ha cinque vertici
finali, poi è rifiutata a-0,25 WU dopo il reale attraversamento. Il percorso
legacy di clipping poligonale near rimane disabilitato.

pre-1.0 keeps `camera_depth_geometric` separate from the physical table address. Under the default profile:

pre-1.0 mantiene `camera_depth_geometric` separata dall'indirizzo fisico
della tabella. Nel profilo default valgono indice e divisore della formula
condivisa seguente.

```text
projection_table_index = max(1, camera_depth_geometric + 190)
projection_divisor     = max(8, camera_depth_geometric)
```

The value 190 is not geometric distance. Fixed, walkLite, and walkFull compare geometric depth against 8 WU. Their precision and overflow envelopes are not identical: `fixed` is the compact Q6/byte-oriented path and can saturate or wrap intermediate transverse/local terms, while the mobile paths preserve 16-bit camera-space depth and Mobile Y-Q2 screen coordinates. Equality is guaranteed only while inputs remain inside the safe range of the compact path.

190 non è distanza geometrica. Fixed, walkLite e walkFull confrontano la
depth geometrica con 8 WU. Gli envelope di precisione/overflow differiscono:
`fixed` è il percorso compatto Q6/byte e può saturare o far andare in wrap
termini intermedi trasversali/locali; i percorsi mobili conservano depth
camera-space 16 bit e coordinate screen Mobile Y-Q2. L'uguaglianza è garantita
soltanto entro il dominio sicuro del percorso compatto.

Near comparison is performed on integer camera-space WU after fixed-point accumulation/quantization. Fractional motion therefore changes the result when it crosses an integer boundary.

Il confronto near opera su WU intere camera-space dopo accumulo/quantizzazione
fixed-point. Il moto frazionario cambia quindi il risultato attraversando
un confine intero.

## Camera translation / Traslazione camera

The movement contract is:

Il contratto di movimento è riportato nella formula condivisa seguente:
127 sotto-unità posizionali per sottopasso e un sottopasso per tick.

```text
EXPLORER_MOVE_STEP = 127 positional sub-units per substep
EXPLORER_MOVE_SUBSTEPS_PER_TICK = 1
```

pre-1.0 development retains the signed-byte multiplier audited in pre-1.0 development but invokes each selected W/S/A/D/Q/E direction once per ST:

Lo sviluppo pre-1.0 conserva il moltiplicatore signed-byte verificato nello
sviluppo pre-1.0, ma invoca ogni direzione W/S/A/D/Q/E selezionata una volta
per ST. Un passo vale 127/256=0,49609375 WU.

```text
127/256 = 0.49609375 WU
```

The effective axis-aligned displacement is:

Lo spostamento effettivo allineato a un asse è 127/256=0,49609375 WU/ST.

```text
127/256 = 0.49609375 WU/ST
```

At the nominal 50 ST/s this is 24.8046875 WU/s, or approximately 0.4429408482 standard-cube sides per second.

Ai 50 ST/s nominali sono 24,8046875 WU/s, ossia circa 0,4429408482 lati del
cubo standard al secondo.

Each substep computes `trunc(axisQ6*127/64)`, sign-extends the result, and adds it to the three-byte positional accumulator with normal carry propagation. pre-1.0 development removes the second identical call; it does not replace the pair with a fused 254 multiplier. Consequently the one-substep path after 2 N ST equals the historical two-substep path after N ST at constant orientation, including Q6 truncation and carry behaviour. A 256-ST axis-aligned trajectory is 32512 raw positional units.

Ogni sottopasso calcola `trunc(axisQ6*127/64)`, estende il segno e somma il
risultato all'accumulatore posizionale a tre byte con normale propagazione
del carry. Lo sviluppo pre-1.0 rimuove la seconda chiamata identica, senza
fondere le due in un moltiplicatore 254. A orientamento costante, 2 N ST nel
percorso a un sottopasso equivalgono a N ST nel percorso storico a due
sottopassi, inclusi troncamento Q6 e carry. Una traiettoria
allineata all'asse di 256 ST misura 32512 unità posizionali raw.

The same one-substep behaviour is shared by walkLite and walkFull. Fixed cameras, object velocity, object angular velocity, light animation, and depth ping-pong are unchanged.

Lo stesso comportamento a un sottopasso vale per walkLite e walkFull.
Camere fixed, velocità/velocità angolare oggetto, animazione luce e depth
ping-pong restano invariati.

Movement directions are additive and the combined vector is not normalized. At an axis-aligned pose, two orthogonal directions produce `sqrt(2) * 0.49609375 = 0.7015825095 WU/ST`; three produce `sqrt(3) * 0.49609375 = 0.8592595801 WU/ST`. Q6 sine/cosine quantization causes small orientation-dependent deviations. W+S, A+D, and Q+E are explicitly neutral.

Le direzioni si sommano e il vettore combinato non è normalizzato. A posa
allineata agli assi, due direzioni ortogonali danno
`sqrt(2)*0.49609375=0.7015825095 WU/ST`; tre danno
`sqrt(3)*0.49609375=0.8592595801 WU/ST`. La quantizzazione Q6 seno/coseno causa
piccole variazioni dipendenti dall'orientamento. W+S, A+D e Q+E sono neutri.

W/S and A/D use yaw in the public X/Y horizontal plane. Pitch changes the view but is deliberately absent from translation: W/S does not climb or descend when looking up/down. With no roll, Q/E changes public Z. In walkFull, roll rotates the strafe and up axes and can mix X/Y/Z; pitch still does not enter the translation basis. Fixed cameras have no runtime translation controls.

W/S e A/D usano yaw nel piano orizzontale pubblico X/Y. Pitch cambia la vista
ma è deliberatamente escluso dalla traslazione: W/S non sale/scende guardando
in alto/basso. Senza roll, Q/E cambia Z pubblico. In walkFull il roll ruota
gli assi strafe/up e può mescolare X/Y/Z; pitch resta escluso dalla base di
traslazione. Le camere fixed non hanno controlli runtime di traslazione.

## Camera angles / Angoli camera

Camera yaw, pitch, and roll are byte phases modulo 256 TU and retain `EXPLORER_LOOK_STEP = 1`. Yaw and pitch respond immediately to a new cursor press, then repeat after four ST and every four ST thereafter. Their continuous rate is 0.25 TU/ST = 0.3515625 degrees/ST = 17.578125 degrees/s. Roll responds immediately to N/M, then repeats after two ST and every two ST thereafter: 0.5 TU/ST = 0.703125 degrees/ST = 35.15625 degrees/s.

Yaw, pitch e roll camera sono fasi byte modulo 256 TU e conservano
`EXPLORER_LOOK_STEP=1`. Yaw/pitch rispondono subito alla pressione dei cursori,
poi dopo quattro ST e ogni quattro ST:0,25 TU/ST=0,3515625 gradi/ST=
17,578125 gradi/s. Roll risponde subito a N/M, poi dopo due ST e ogni due ST:
0,5 TU/ST=0,703125 gradi/ST=35,15625 gradi/s.

Yaw, pitch, and roll have independent repeat-phase bytes. Release resets the corresponding phase, so the next press always applies its first 1-TU update immediately. N+M is neutral and resets the roll phase. The C64 keyboard matrix represents each cursor axis with one physical cursor key plus Shift, so simultaneous logical left+right or up+down cannot be encoded by the stock keyboard; the host-side logical-opposite model treats such a state as neutral and phase-resetting. Camera reset clears all three phases. walkLite allocates two bytes (yaw and pitch); walkFull allocates those two plus one roll byte.

Yaw, pitch e roll hanno byte indipendenti della fase di repeat. Il rilascio
azzera la rispettiva fase; una nuova pressione applica subito il primo
aggiornamento di 1 TU. N+M è neutro e azzera la fase roll. La matrice tastiera
C64 rappresenta ogni asse cursore con un tasto fisico più Shift: sinistra+
destra o alto+basso logici simultanei non sono codificabili dalla tastiera
stock; il modello host degli opposti logici li tratta come neutri con reset
della fase. Il reset camera azzera tutte e tre le fasi. WalkLite alloca due
byte, yaw/pitch; walkFull ne aggiunge uno per roll.

walkLite supports yaw and pitch and locks roll. walkFull supports yaw, pitch, and roll. With roll active, an accepted cursor repeat is decomposed through the roll angle into yaw/pitch accumulators; Q6 quantization and fractional accumulation are otherwise unchanged.

walkLite supporta yaw/pitch e blocca roll. walkFull supporta tutti e tre.
Con roll attivo, un repeat cursore accettato viene scomposto attraverso
l'angolo roll negli accumulatori yaw/pitch; quantizzazione Q6 e accumulo
frazionario restano invariati.

The ordinary cursor pitch clamp is -64..+64 TU, or -90..+90 degrees. Initial scene rotation is merely validated as 0..255 and is not clamped to that interval. In the rolled walkFull routine, pitch changes coupled from simultaneous yaw can bypass the ordinary clamp; the pitch variable therefore has no unconditional global -90..+90 guarantee in every combined-input state.

Il clamp ordinario del pitch cursore è-64..+64 TU, cioè-90..+90 gradi.
La rotazione iniziale di scena è soltanto validata in 0..255, senza quel clamp.
Nel walkFull con roll, variazioni pitch accoppiate a yaw simultaneo possono
aggirare il clamp ordinario: la variabile pitch non garantisce globalmente
-90..+90 in ogni stato di input combinato.

## Simulation time / Tempo di simulazione

The raster IRQ queues one video event per VBlank. The main loop drains the queue and advances simulation as follows:

L'IRQ raster accoda un evento video per VBlank. Il main loop svuota la coda
e avanza la simulazione così:

- PAL: un ST per VBlank, nominalmente 50 ST/s;
- NTSC: ST nei primi cinque VBlank di ogni gruppo di sei, poi uno saltato,
  nominalmente `60*5/6=50 ST/s`.

- PAL: one ST for every VBlank, nominally 50 ST/s;
- NTSC: ST on the first five VBlanks of each six-VBlank group, then one skipped ST, nominally `60 * 5/6 = 50 ST/s`.

`NTSC_SIM_TICKS_PER_6_VBLANKS = 5` documents the policy; the runtime scheduler implements it with a six-phase counter. Auto-detection selects PAL or NTSC before the IRQ loop. If rendering falls behind, multiple queued STs are consumed before the next render. The input matrix is sampled once before that drain, so the sampled state applies to all queued ticks. The pending-VBlank counter is one byte and can wrap after an extreme unserviced backlog.

`NTSC_SIM_TICKS_PER_6_VBLANKS=5` documenta la politica; lo scheduler runtime
usa un contatore a sei fasi. L'autodetection seleziona PAL/NTSC prima del loop
IRQ. Se il rendering ritarda, più ST accodati sono consumati prima del render
successivo. L'input è campionato una volta prima dello svuotamento: lo stesso
stato vale per tutti i tick accodati. Il contatore VBlank pendenti è un byte
e può andare in wrap con arretrati estremi non serviti.

The nominal rates are equal on PAL and NTSC:

Le velocità nominali sono uguali in PAL/NTSC, come nella tabella condivisa:
50 ST/s, moto assiale 24,8046875 WU/s,0,4429408482 lati cubo/s,
yaw/pitch continui 17,578125 gradi/s e roll continuo 35,15625 gradi/s.

| Quantity / Grandezza | PAL | NTSC |
|---|---:|---:|
| Simulation rate | 50 ST/s | 60 * 5/6 = 50 ST/s |
| Axis camera motion | 24.8046875 WU/s | 24.8046875 WU/s |
| Camera motion in 56-WU cube sides | 0.4429408482/s | 0.4429408482/s |
| Continuous yaw/pitch | 17.578125 degrees/s | 17.578125 degrees/s |
| Continuous roll | 35.15625 degrees/s | 35.15625 degrees/s |

These are nominal engine rates. Real PAL/NTSC hardware refresh frequencies differ slightly from exact 50/60 Hz.

Sono velocità nominali dell'engine. Le frequenze di refresh PAL/NTSC
dell'hardware reale differiscono leggermente dai 50/60 Hz esatti.

## Automatic animation conversions / Conversione animazioni automatiche

### Object velocity / Velocità oggetto

`velocity` is converted component-wise with `q = round(value * 256)`. The stored value is added once per ST, so the effective component is `q/256 WU/ST`. Axes use the same world-to-engine permutation described above.

`velocity` viene convertita per componente con `q=round(value*256)`.
Il valore memorizzato è sommato una volta per ST: la componente effettiva
è `q/256 WU/ST`. Gli assi usano la permutazione mondo-engine già descritta.

### object.angularVelocity

JSON values are expressed in TU/ST and quantized to signed 8.8:

I valori JSON di `object.angularVelocity` sono TU/ST, quantizzati signed 8.8
secondo le formule condivise seguenti.

```text
q                  = round(jsonAngularVelocity * 256)
runtime TU/ST      = q / 256
runtime degrees/ST = q * 360 / (256 * 256)
```

The signed accepted JSON range is -128 through 127.99609375 TU/ST. The 16-bit fixed angular accumulator adds `q` once per ST; its high byte indexes the 256-entry sine table and its low byte interpolates between entries. It wraps naturally after one turn. With `world-z-up`, `[wx,wy,wz]` is stored internally as `[wx,wz,wy]`. For example `[0.125,0.25,0.375]` becomes fixed steps `$0020,$0060,$0040` on internal X/Y/Z.

L'intervallo JSON signed accettato è-128..127,99609375 TU/ST.
L'accumulatore angolare fixed 16 bit aggiunge `q` una volta per ST; il byte
alto indicizza il seno a 256 elementi e il basso interpola fra elementi.
Il wrap dopo un giro è naturale. Con `world-z-up`, `[wx,wy,wz]` diventa
internamente `[wx,wz,wy]`: `[0.125,0.25,0.375]` genera passi fixed
`$0020,$0060,$0040` sugli assi interni X/Y/Z.

### Light orbit and pulse / Orbita e pulse della luce

Orbit geometry is a host-generated table of `phaseCount` integer samples (`phaseCount` is 8, 16, or 32). Runtime advances one phase every `tickDiv` ST, so a complete orbit/pulse cycle lasts:

La geometria orbitale è una tabella host di `phaseCount` campioni interi;
`phaseCount` vale 8,16 o 32. Il runtime avanza una fase ogni `tickDiv` ST:
il ciclo orbita/pulse completo dura `phaseCount*tickDiv ST`.

```text
phaseCount * tickDiv ST
```

`flat` uses a radius-88 sampled circle and an internal Y offset of -42. `tumble3d` starts from a radius-88 local circle, applies phase-derived pitch/yaw/roll, subtracts 12 from internal Y, rounds, and clamps each component to -127..127. Pulse intensity uses the same phase and a host-generated cosine curve.

`flat` usa un cerchio campionato di raggio 88 e offset Y interno-42.
`tumble3d` parte da un cerchio locale di raggio 88, applica pitch/yaw/roll
derivati dalla fase, sottrae 12 a Y interno, arrotonda e limita ogni componente
a-127..127. L'intensità pulse usa la stessa fase e una curva coseno host.

### depthPingPong

`min` and `max` are converted to fixed values with 256 sub-units per WU. The builder precomputes 256 sinusoidal samples:

`min` e `max` diventano valori fixed con 256 sotto-unità per WU. Il builder
precalcola 256 campioni sinusoidali con le formule condivise seguenti.

```text
u(phase) = (1 + sin(2*pi*phase/256)) / 2
position = round(minFixed + (maxFixed-minFixed) * u)
```

Every ST, phase becomes `(phase + phaseStep) mod 256` and the corresponding position replaces camera internal Z/public world Y. The full table-cycle period is `256 / gcd(256, phaseStep)` ST. This feature is accepted only for walkLite/walkFull.

Ogni ST, la fase diventa `(phase+phaseStep) mod256` e la posizione
corrispondente sostituisce Z interno camera/Y mondo pubblico. Il periodo
completo della tabella è `256/gcd(256,phaseStep) ST`. La funzione è accettata
solo per walkLite/walkFull.

### Other tick-driven controls / Altri controlli a tick

- `AutoCycleFrames` is historical naming: it is incremented by `advance_sim_tick`, so its unit is ST, not rendered frames.
- `RandomMaterialCycleSeconds` becomes `seconds * 50` ST.
- Legacy `MotionZStep256` is already an unsigned fixed positional step in 1/256-WU units per ST.
- Legacy non-scene rotation steps are fixed angular sub-units added once per ST, following the same 256 sub-units per TU accumulator.

- `AutoCycleFrames` è un nome storico: viene incrementato da
  `advance_sim_tick`, quindi l'unità è ST, non frame renderizzati.
- `RandomMaterialCycleSeconds` diventa `seconds*50 ST`.
- Il legacy `MotionZStep256` è già un passo posizionale fixed unsigned in
  unità 1/256 WU per ST.
- I passi legacy di rotazione non da scena sono sotto-unità angolari fixed
  sommate una volta per ST, con lo stesso accumulatore 256 sotto-unità per TU.

## Audit conclusion / Conclusione dell'audit

The abstract core is valid: WU is the linear scene unit, TU is 1/256 turn, and PAL/NTSC both target approximately 50 ST/s. The historical pre-1.0 default used one geometric near threshold of 8 WU and kept the projection-index bias out of geometric depth. The current Mode 3-5 contract instead has three explicit profiles: `default` keeps the 8-WU reject threshold and divisor minimum; `late` keeps whole-face rejection but accepts 1 WU with divisor minimum 2; `clip` performs camera-plane polygon clipping and retains the visible portion until the real crossing, with generated intersections at 1 WU and divisor minimum 2. All profiles remain one-sided.

The stronger proposed claim that camera, objects, and lights all share one public 8.8 format is **not** valid in pre-1.0. The audit also found raw (unconverted) mesh-local axes, the formerly unsafe upper object-depth interval, and ambiguous named camera yaw/roll fields. pre-1.0 development resolves negative mobile-camera X/Z initialization; pre-1.0 development resolves object-depth authoring safety; pre-1.0 development records the historical two-substep movement contract; pre-1.0 development deliberately changes the global walk defaults to one movement substep and deterministic angular repeats. pre-1.0 development does not change scene coordinates, fixed cameras, renderer, projection, clipping, materials, object animation, or tables. The remaining findings are separate tasks.

Il nucleo astratto è valido: WU è l'unità lineare della scena, TU è 1/256 di giro e PAL/NTSC mirano entrambi a circa 50 ST/s. Il default storico pre-1.0 usava un unico near geometrico di 8 WU e manteneva il bias dell'indice fuori dalla profondità geometrica. Il contratto corrente delle Mode 3-5 offre invece tre profili espliciti: `default` conserva reject e divisore minimo a 8 WU; `late` conserva il reject whole-face ma accetta 1 WU con divisore minimo 2; `clip` esegue il clipping poligonale contro il piano camera e conserva la porzione visibile fino al reale attraversamento, con intersezioni generate a 1 WU e divisore minimo 2. Tutti i profili restano monofacciali.

Non e invece valida l'affermazione piu forte secondo cui camera, oggetti e luci condividono tutti un formato pubblico 8.8. L'audit ha inoltre rilevato gli assi locali mesh non convertiti, il precedente intervallo alto non sicuro per la profondita oggetto e l'ambiguita dei campi camera nominati yaw/roll. La pre-1.0 development risolve l'inizializzazione X/Z negativa della camera mobile; la pre-1.0 development risolve la sicurezza della profondita oggetto; la pre-1.0 development registra il contratto storico a due sotto-step; la pre-1.0 development aggiorna deliberatamente i default walk a un sotto-step lineare e ripetizioni angolari deterministiche. La pre-1.0 development non modifica coordinate scena, camera fixed, renderer, proiezione, clipping, materiali, animazioni oggetto o tabelle. Gli altri rilievi restano incarichi separati.


## Current optional budgets / Budget opzionali correnti — 1.12.0

Actual assembled allocation remains authoritative. New native flat-cache data
costs6*N+68bytes; conservative wall data2*F+12*Q+17bytes, plus emitted code and
guards. Attribute masks use one byte per face. Pool/SID/camera tables have their
own explicit budgets. None of these bytes is free unless the allocator proves
placement in that exact combination. Historical profile margins exclude new
optional helpers. [EN](RENDER-OPTIMIZATIONS.en.md) · [IT](RENDER-OPTIMIZATIONS.it.md).

Conta l'allocazione assemblata reale. Dati cache flat6*N+68byte; occlusione
pareti2*F+12*Q+17byte, oltre a codice e guardie. Maschere:un byte per faccia.
Pool/SID/tabelle camera hanno budget espliciti separati. Nessuno spazio è libero
senza verifica dell'allocatore sulla combinazione reale. I margini dei profili
storici non includono nuovi helper opzionali.
