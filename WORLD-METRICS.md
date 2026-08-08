# 3Dvibe64 world metrics / Metrica del mondo 3Dvibe64

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

```text
engineX = worldX
engineY = worldZ
engineZ = worldY
```

The same component permutation is used for object position, velocity, rotation, angular velocity, camera position/rotation, and static light position. Generated assembly from the audit scene confirmed, for example, camera `[3,5,7] -> [3,7,5]`, object `[11,69,13] -> [11,13,69]`, and static light `[17,19,23] -> [17,23,19]`.

## Ground plane / Piano Ground

In pre-1.0, `ground.z` is a whole WU coordinate on the public Z-up axis. `WorldGroundMode=plane` therefore defines the geometric plane `world Z = ground.z`; it is available in GraphicsMode 2-5. A face wholly on the side opposite the camera is rejected, while a crossing face is clipped before the normal near-plane and screen clipping stages. Crossing the plane changes the retained side; changing camera height without crossing it does not.

Mode 2 keeps a line-only presentation in both Ground profiles. `simple` is decorative and performs no geometric clipping. `plane` performs geometric classification and clipping, but still draws no half-plane; hidden-wire face masks and final edges use the post-clipping polygon. Modes 3-5 retain the traditional screen-space behavior for `simple`, while `plane` fills the projected half-plane and clips geometry. Mode 1 supports only the decorative roll-aware horizon.

The roll convention observed by the renderer is: `+32 TU` slopes down to the right, `-32 TU` slopes up to the right, and `+64 TU` is vertical. A horizon line wholly above, below, or laterally outside the viewport is rejected; the Mode 1/2 non-intersection sentinel is `$FF`, so no line is clamped to a border. Mode 2 `plane` adds `VERT_COUNT` bytes for `ground_vside`; the Ground-plus-near clipping pipeline is provisioned for polygons through 12 vertices. The `plane` path has a greater byte/cycle cost than `simple` and may require `high-basic-v2`.

For camera `rotation`, the public array is best read as rotations about public X/Y/Z. After conversion, the runtime variables receive `pitch=rotX`, `yaw=rotZ`, and `roll=rotY`, matching a Z-up world whose forward axis is Y. The alternative named camera fields are ambiguous in pre-1.0: the builder assembles `[pitch,yaw,roll]` and then applies the same component permutation, so the named `yaw` and `roll` do not land in the variables their names suggest. Use the three-component `rotation` array until that authoring API is audited separately.

Raw local mesh vertices are not axis-converted by the builder. They are copied in component order after integer coercion. Therefore `axisConvention: world-z-up` governs scene vectors, but mesh importers/exporters must currently deliver local vertex axes in the orientation expected by the engine. This is an authoring-contract gap, not a change made by this audit.

## Numeric formats and ranges / Formati numerici e intervalli

Host-side fixed conversion uses `round(value * 256)` with .NET midpoint-to-even rounding. Out-of-range values cause a build error; they are not clamped.

La conversione fixed host-side usa `round(value * 256)` con arrotondamento .NET midpoint-to-even. I valori fuori intervallo causano un errore di build e non vengono clampati.

### Objects / Oggetti

With `world-z-up`, object position and velocity map to these internal containers:

| Public component | Internal component | Position format and accepted host range | Velocity format and accepted host range |
|---|---|---|---|
| X | X | signed 8.8, -128 to 127.99609375 WU | signed 8.8, -128 to 127.99609375 WU/ST |
| Z | Y | signed 8.8, -128 to 127.99609375 WU | signed 8.8, -128 to 127.99609375 WU/ST |
| Y (forward) | Z (depth) | signed 16.8 `[fraction, integer-low, signed-extension]`, raw center domain -32768 to 32767.99609375 WU; mesh-safe interval validated per object | signed 16.8, -32768 to 32767.99609375 WU/ST |

The depth position container is emitted as three bytes, but its extension byte is sign extension rather than an extra unsigned magnitude byte. The runtime therefore represents raw values -8388608..8388607, or -32768..32767.99609375 WU. Before pre-1.0 development the host accepted -8388608..16777215 (-32768..65535.99609375 WU); values above 32767.99609375 encoded extension `$80..$FF` and were consumed as negative geometry. pre-1.0 development rejects this before assembly.

The safe center interval is also reduced by the mesh's possible local-depth extension. For each vertex and the object's quantized `scaleQ6`, the builder computes the all-rotation Q6 envelope:

```text
Evertex = floor(abs(x)*scaleQ6/64)
        + floor(abs(y)*scaleQ6/64)
        + floor(abs(z)*scaleQ6/64)
E = max(Evertex)
```

This mirrors the three separately truncated `mul_s6` terms. When `E < 128`, local depth is conservatively bounded by `[-E,+E]`; when `E >= 128`, byte addition may wrap and the complete signed local-byte domain `[-128,+127]` is used. If those local bounds are `[Dmin,Dmax]`, a safe runtime center integer is `[-32768-Dmin, 32767-Dmax]`. The accepted authored interval additionally follows fractional consumption: `fixed` rounds values whose fraction has bit 7 set upward into integer depth, while `walkLite` and `walkFull` ignore the stored object-center fraction during geometry. The final interval is intersected with the raw signed 16.8 domain.

Examples: a point mesh has raw intervals `[-32768,32767.49609375]` in `fixed` and `[-32768,32767.99609375]` in mobile modes; the standard cube at scale 64/64 has Q6 extension `[-84,+84]`, giving `[-32684.5,32683.49609375]` in `fixed` and `[-32684,32683.99609375]` in mobile modes. At scale 127/64 its envelope reaches the byte boundary, so `[-128,+127]` is used. complex reference mesh at scale 61/64 yields `[-89,+89]`. These are safety envelopes for every rotation, not claims that every bound is geometrically attainable.

La posizione depth usa tre byte, ma l'extension byte e un'estensione del segno e non magnitudine unsigned aggiuntiva. Il dominio raw e quindi -8388608..8388607 sotto-unita, cioe -32768..32767,99609375 WU. La pre-1.0 development rifiuta prima dell'assemblaggio sia i centri fuori dominio sia quelli che, sommati all'envelope Q6 della mesh scalata, potrebbero oltrepassare l'intervallo signed. Il messaggio diagnostico riporta oggetto, world Y richiesto, intervallo sicuro, estensione mesh, scala Q6 e profondita minima/massima risultante.

This contract protects object-world composition (`center + transformed/scaled local vertex`) at build time. Camera-relative arithmetic is a later signed operation: initial diagnostic poses at the origin are covered by the fixed/walk matrix, but no static object-position check can guarantee an indefinitely moving camera because mobile camera accumulators have no world-boundary clamp. That existing runtime-motion policy is not changed by pre-1.0 development.

Runtime additions wrap at their container width unless a specific subsystem implements a clamp. Object X/Z-public accumulators wrap at 16 bits; forward depth uses 24 bits. Rendering consumes integer WU from these accumulators, so sub-units accumulate motion smoothly but visible geometry changes at integer-coordinate boundaries.

### Camera / Camera

Scene and camera-file starting coordinates are coerced to whole integers and must be in -63..63 WU. They are not authored as fractional 8.8 values. A mobile camera then uses three-byte signed accumulators with one fractional byte, so controls advance in 1/256-WU sub-units.

`0.1.0-pre-1.0-pre-1.0 development-camera-initial-sign-extension` corrects the initial encoding for all three internal axes. Each whole-WU coordinate is emitted as `[lowFraction, highInteger, signedExtension]`. Public world X maps to internal X, public world Z maps to internal Y, and public world Y maps to internal Z. Negative integer starts use extension `$FF`; zero and positive starts use `$00`. Examples are `$00:$C1:$FF` for -63 WU, `$00:$FF:$FF` for -1 WU, and `$00:$3F:$00` for +63 WU. This is a one-time host-side encoding decision, not a per-frame conversion.

An explicit mobile camera at `[0,0,0]` remains at the real origin. The historical internal-depth fallback to -64 WU applies only when `CameraSource=default`, that is, when no camera was explicitly supplied by a scene or camera file. Translation-invariance tests confirm identical camera-space coordinates and framebuffer screenshots for translated-equivalent scenes in both `walkLite` and `walkFull`.

Camera motion has no world-boundary clamp; sufficiently long motion wraps at the accumulator width.

### Lights / Luci

Static and generated orbit-light coordinates are signed whole bytes in -127..127 WU. They do not have fractional 8.8 authoring or runtime storage. Orbit samples are precomputed as integer coordinates.

### Meshes and Q6 scale / Mesh e scala Q6

Mesh vertex components are coerced to integers using PowerShell/.NET midpoint-to-even conversion and must end in -63..63. Fractions are rounded rather than rejected.

`scale` is converted with `round(scale * 64)` and stored as `scaleQ6`; valid stored values are 1..127:

```text
scale 1.0 = 64/64
scale 0.5 = 32/64
maximum   = 127/64 = 1.984375
```

The intended geometric relation is:

```text
effective world coordinate = local integer vertex * scaleQ6 / 64
```

The runtime combines scale with Q6 rotation matrices and `mul_s6`, whose division by 64 truncates the magnitude toward zero. Rotation and scale are therefore integer-quantized, not exact real arithmetic.

The built-in standard cube uses local coordinates -28 and +28 on every axis. At scale 1.0 its side is 56 WU and its half-side is 28 WU. This cube is an artistic reference only; it does not define the WU.

## Geometric depth and near plane / Profondita geometrica e near-plane

All camera profiles use the same abstract WU. The `default` profile in GraphicsMode 3, 4, and 5 uses:

```text
CAMERA_FACE_MIN_DEPTH = 8 WU
```

pre-1.0 exposes `-Mode4NearProfile default|late|clip` for GraphicsMode 3, 4, and 5. The option name is retained for compatibility. `late` uses:

```text
reject depth <= 0 WU
minimum accepted depth = 1 WU
projection_divisor = max(2, camera_depth_geometric)
```

`late` separates the reject distance from the minimum projection divisor: depth 1 WU is projected with divisor 2, producing a limited plateau between 1 and 2 WU, and geometric depth is used at and beyond 2 WU. Near-polygon clipping remains disabled, backface culling is unchanged, and no two-sided behavior is introduced. Faces crossing the camera plane are rejected as complete faces.

`clip` keeps the same 1 WU intersection depth and minimum projection divisor of 2, but clips a crossing face against the camera plane with Sutherland-Hodgman instead of rejecting the complete face. Ground plane clipping runs first. Backface culling remains one-sided and uses the original camera-space polygon; rasterization in Modes 3-5 and the Mode 5 outline use the final post-clipping polygon and its final edges. A diagnostic wall remains visible at +0.5 WU and on the plane at 0 WU, where the diagnostic face has five post-clipping vertices, then is rejected at -0.25 WU after the camera has genuinely crossed it. The legacy near-polygon path remains disabled.

pre-1.0 keeps `camera_depth_geometric` separate from the physical table address. Under the default profile:

```text
projection_table_index = max(1, camera_depth_geometric + 190)
projection_divisor     = max(8, camera_depth_geometric)
```

The value 190 is not geometric distance. Fixed, walkLite, and walkFull compare geometric depth against 8 WU. Their precision and overflow envelopes are not identical: `fixed` is the compact Q6/byte-oriented path and can saturate or wrap intermediate transverse/local terms, while the mobile paths preserve 16-bit camera-space depth and Mobile Y-Q2 screen coordinates. Equality is guaranteed only while inputs remain inside the safe range of the compact path.

Near comparison is performed on integer camera-space WU after fixed-point accumulation/quantization. Fractional motion therefore changes the result when it crosses an integer boundary.

## Camera translation / Traslazione camera

The movement contract is:

```text
EXPLORER_MOVE_STEP = 127 positional sub-units per substep
EXPLORER_MOVE_SUBSTEPS_PER_TICK = 1
```

pre-1.0 development retains the signed-byte multiplier audited in pre-1.0 development but invokes each selected W/S/A/D/Q/E direction once per ST:

```text
127/256 = 0.49609375 WU
```

The effective axis-aligned displacement is:

```text
127/256 = 0.49609375 WU/ST
```

At the nominal 50 ST/s this is 24.8046875 WU/s, or approximately 0.4429408482 standard-cube sides per second.

Each substep computes `trunc(axisQ6*127/64)`, sign-extends the result, and adds it to the three-byte positional accumulator with normal carry propagation. pre-1.0 development removes the second identical call; it does not replace the pair with a fused 254 multiplier. Consequently pre-1.0 development after N ST equals pre-1.0 development after 2N ST at constant orientation, including Q6 truncation and carry behaviour. A 256-ST axis-aligned trajectory is 32512 raw positional units.

The same one-substep behaviour is shared by walkLite and walkFull. Fixed cameras, object velocity, object angular velocity, light animation, and depth ping-pong are unchanged.

Movement directions are additive and the combined vector is not normalized. At an axis-aligned pose, two orthogonal directions produce `sqrt(2) * 0.49609375 = 0.7015825095 WU/ST`; three produce `sqrt(3) * 0.49609375 = 0.8592595801 WU/ST`. Q6 sine/cosine quantization causes small orientation-dependent deviations. W+S, A+D, and Q+E are explicitly neutral.

W/S and A/D use yaw in the public X/Y horizontal plane. Pitch changes the view but is deliberately absent from translation: W/S does not climb or descend when looking up/down. With no roll, Q/E changes public Z. In walkFull, roll rotates the strafe and up axes and can mix X/Y/Z; pitch still does not enter the translation basis. Fixed cameras have no runtime translation controls.

## Camera angles / Angoli camera

Camera yaw, pitch, and roll are byte phases modulo 256 TU and retain `EXPLORER_LOOK_STEP = 1`. Yaw and pitch respond immediately to a new cursor press, then repeat after four ST and every four ST thereafter. Their continuous rate is 0.25 TU/ST = 0.3515625 degrees/ST = 17.578125 degrees/s. Roll responds immediately to N/M, then repeats after two ST and every two ST thereafter: 0.5 TU/ST = 0.703125 degrees/ST = 35.15625 degrees/s.

Yaw, pitch, and roll have independent repeat-phase bytes. Release resets the corresponding phase, so the next press always applies its first 1-TU update immediately. N+M is neutral and resets the roll phase. The C64 keyboard matrix represents each cursor axis with one physical cursor key plus Shift, so simultaneous logical left+right or up+down cannot be encoded by the stock keyboard; the host-side logical-opposite model treats such a state as neutral and phase-resetting. Camera reset clears all three phases. walkLite allocates two bytes (yaw and pitch); walkFull allocates those two plus one roll byte.

walkLite supports yaw and pitch and locks roll. walkFull supports yaw, pitch, and roll. With roll active, an accepted cursor repeat is decomposed through the roll angle into yaw/pitch accumulators; Q6 quantization and fractional accumulation are otherwise unchanged.

The ordinary cursor pitch clamp is -64..+64 TU, or -90..+90 degrees. Initial scene rotation is merely validated as 0..255 and is not clamped to that interval. In the rolled walkFull routine, pitch changes coupled from simultaneous yaw can bypass the ordinary clamp; the pitch variable therefore has no unconditional global -90..+90 guarantee in every combined-input state.

## Simulation time / Tempo di simulazione

The raster IRQ queues one video event per VBlank. The main loop drains the queue and advances simulation as follows:

- PAL: one ST for every VBlank, nominally 50 ST/s;
- NTSC: ST on the first five VBlanks of each six-VBlank group, then one skipped ST, nominally `60 * 5/6 = 50 ST/s`.

`NTSC_SIM_TICKS_PER_6_VBLANKS = 5` documents the policy; the runtime scheduler implements it with a six-phase counter. Auto-detection selects PAL or NTSC before the IRQ loop. If rendering falls behind, multiple queued STs are consumed before the next render. The input matrix is sampled once before that drain, so the sampled state applies to all queued ticks. The pending-VBlank counter is one byte and can wrap after an extreme unserviced backlog.

The nominal rates are equal on PAL and NTSC:

| Quantity | PAL | NTSC |
|---|---:|---:|
| Simulation rate | 50 ST/s | 60 * 5/6 = 50 ST/s |
| Axis camera motion | 24.8046875 WU/s | 24.8046875 WU/s |
| Camera motion in 56-WU cube sides | 0.4429408482/s | 0.4429408482/s |
| Continuous yaw/pitch | 17.578125 degrees/s | 17.578125 degrees/s |
| Continuous roll | 35.15625 degrees/s | 35.15625 degrees/s |

These are nominal engine rates. Real PAL/NTSC hardware refresh frequencies differ slightly from exact 50/60 Hz.

## Automatic animation conversions / Conversione animazioni automatiche

### Object velocity

`velocity` is converted component-wise with `q = round(value * 256)`. The stored value is added once per ST, so the effective component is `q/256 WU/ST`. Axes use the same world-to-engine permutation described above.

### object.angularVelocity

JSON values are expressed in TU/ST and quantized to signed 8.8:

```text
q                  = round(jsonAngularVelocity * 256)
runtime TU/ST      = q / 256
runtime degrees/ST = q * 360 / (256 * 256)
```

The signed accepted JSON range is -128 through 127.99609375 TU/ST. The 16-bit fixed angular accumulator adds `q` once per ST; its high byte indexes the 256-entry sine table and its low byte interpolates between entries. It wraps naturally after one turn. With `world-z-up`, `[wx,wy,wz]` is stored internally as `[wx,wz,wy]`. For example `[0.125,0.25,0.375]` becomes fixed steps `$0020,$0060,$0040` on internal X/Y/Z.

### Light orbit and pulse

Orbit geometry is a host-generated table of `phaseCount` integer samples (`phaseCount` is 8, 16, or 32). Runtime advances one phase every `tickDiv` ST, so a complete orbit/pulse cycle lasts:

```text
phaseCount * tickDiv ST
```

`flat` uses a radius-88 sampled circle and an internal Y offset of -42. `tumble3d` starts from a radius-88 local circle, applies phase-derived pitch/yaw/roll, subtracts 12 from internal Y, rounds, and clamps each component to -127..127. Pulse intensity uses the same phase and a host-generated cosine curve.

### depthPingPong

`min` and `max` are converted to fixed values with 256 sub-units per WU. The builder precomputes 256 sinusoidal samples:

```text
u(phase) = (1 + sin(2*pi*phase/256)) / 2
position = round(minFixed + (maxFixed-minFixed) * u)
```

Every ST, phase becomes `(phase + phaseStep) mod 256` and the corresponding position replaces camera internal Z/public world Y. The full table-cycle period is `256 / gcd(256, phaseStep)` ST. This feature is accepted only for walkLite/walkFull.

### Other tick-driven controls

- `AutoCycleFrames` is historical naming: it is incremented by `advance_sim_tick`, so its unit is ST, not rendered frames.
- `RandomMaterialCycleSeconds` becomes `seconds * 50` ST.
- Legacy `MotionZStep256` is already an unsigned fixed positional step in 1/256-WU units per ST.
- Legacy non-scene rotation steps are fixed angular sub-units added once per ST, following the same 256 sub-units per TU accumulator.

## Audit conclusion / Conclusione dell'audit

The abstract core is valid: WU is the linear scene unit, TU is 1/256 turn, and PAL/NTSC both target approximately 50 ST/s. The historical pre-1.0 default used one geometric near threshold of 8 WU and kept the projection-index bias out of geometric depth. The current Mode 3-5 contract instead has three explicit profiles: `default` keeps the 8-WU reject threshold and divisor minimum; `late` keeps whole-face rejection but accepts 1 WU with divisor minimum 2; `clip` performs camera-plane polygon clipping and retains the visible portion until the real crossing, with generated intersections at 1 WU and divisor minimum 2. All profiles remain one-sided.

The stronger proposed claim that camera, objects, and lights all share one public 8.8 format is **not** valid in pre-1.0. The audit also found raw (unconverted) mesh-local axes, the formerly unsafe upper object-depth interval, and ambiguous named camera yaw/roll fields. pre-1.0 development resolves negative mobile-camera X/Z initialization; pre-1.0 development resolves object-depth authoring safety; pre-1.0 development records the historical two-substep movement contract; pre-1.0 development deliberately changes the global walk defaults to one movement substep and deterministic angular repeats. pre-1.0 development does not change scene coordinates, fixed cameras, renderer, projection, clipping, materials, object animation, or tables. The remaining findings are separate tasks.

Il nucleo astratto è valido: WU è l'unità lineare della scena, TU è 1/256 di giro e PAL/NTSC mirano entrambi a circa 50 ST/s. Il default storico pre-1.0 usava un unico near geometrico di 8 WU e manteneva il bias dell'indice fuori dalla profondità geometrica. Il contratto corrente delle Mode 3-5 offre invece tre profili espliciti: `default` conserva reject e divisore minimo a 8 WU; `late` conserva il reject whole-face ma accetta 1 WU con divisore minimo 2; `clip` esegue il clipping poligonale contro il piano camera e conserva la porzione visibile fino al reale attraversamento, con intersezioni generate a 1 WU e divisore minimo 2. Tutti i profili restano monofacciali.

Non e invece valida l'affermazione piu forte secondo cui camera, oggetti e luci condividono tutti un formato pubblico 8.8. L'audit ha inoltre rilevato gli assi locali mesh non convertiti, il precedente intervallo alto non sicuro per la profondita oggetto e l'ambiguita dei campi camera nominati yaw/roll. La pre-1.0 development risolve l'inizializzazione X/Z negativa della camera mobile; la pre-1.0 development risolve la sicurezza della profondita oggetto; la pre-1.0 development registra il contratto storico a due sotto-step; la pre-1.0 development aggiorna deliberatamente i default walk a un sotto-step lineare e ripetizioni angolari deterministiche. La pre-1.0 development non modifica coordinate scena, camera fixed, renderer, proiezione, clipping, materiali, animazioni oggetto o tabelle. Gli altri rilievi restano incarichi separati.
