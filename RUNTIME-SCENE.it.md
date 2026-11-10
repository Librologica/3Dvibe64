# RuntimeScene — 1.20.0

> SDK sorgente stabile 1.20.0, derivato dalla agentic36. Pubblicato su GitHub. [Qualifica](QUALIFICATION-1.20.0.it.md).

Dissolvenza a distanza opzionale nelle modalità1–8: `-DistanceFade off/dither`, `-DistanceFadeStart`, `-DistanceFadeEnd`; default off. Il LOD texture Mode7 resta indipendente. Vedere il [contratto completo](DISTANCE-FADE.it.md).

[English](RUNTIME-SCENE.en.md).
Compilatore sorgente opzionale, senza applicazione né nuova modalità grafica.
Vedere [dinamica](DYNAMICS.it.md), [assembly/memoria](ASSEMBLY-GUIDE.it.md) e [qualifica](QUALIFICATION-1.20.0.json).

Una Scene1 esterna può includere `runtimeScene`: il builder ordinario valida
e rimuove il record prima della compilazione nativa. Profilo: `legacy-plus`,
Mode4/5/6, `walkLite`, normal160x100, `high-basic-v2`, `-NoFpsOverlay`, PAL,
clipping near-poly/schermo Q4. Gli altri profili sono rifiutati. Restano il percorso
predefinito e l'API AnimatedMesh. Non è ammessa la combinazione di `animatedMeshes`
mutabili con questa estensione per coordinate immutabili. La vista dinamica non
gestisce il renderer ground/grounds separato: usare geometria mesh.

```json
{
  "coordinateTerms": "active-mesh",
  "rigidMatrixCache": true,
  "objectBounds": true
}
```

È il valore di `runtimeScene`, non una scena completa. Nessuna funzione viene
abilitata implicitamente. Omettere il campo mantiene il comportamento del parent.
Usare `work/build-3Dvibe64.ps1 -SceneFile <scena-esterna>` con il profilo sopra;
`-SkipCmdUpdate` evita l'aggiornamento del launcher opzionale. Assembly, piano e
`.runtime-scene.json` generati descrivono le opzioni applicate. Compilare in una
copia di lavoro dell'SDK, mantenendo pulita la distribuzione sorgente.

| Campo | Contratto |
|---|---|
| `coordinateTerms` | `full` predefinito oppure `active-mesh`. Liste deduplicate degli indici delle coordinate della mesh sorgente attiva; chiave della cache con mesh e tutti i9 byte della matrice scalata effettiva. |
| `rigidMatrixCache` | Booleano. Pose/scale consecutive identiche ripristinano9 byte di matrice e6 trigonometrici prima dei consumatori; la luce dinamica può ricostruire la matrice non scalata. |
| `uniformGouraud` | Booleano, solo Mode6. Tutti gli shade dei vertici/clip a0 oppure32 usano il fill solid nativo soltanto quando le righe Bayer emesse provano lo stesso pigmento uniforme. Gli altri shade mantengono Gouraud. |
| `gouraudSaturation` | Intero1..32, predefinito32, Mode6. Curva d'uscita `min(32,round(q*32/s))` prima del boost materiale; stato canonico temporale invariato. Valori più bassi ampliano la zona chiara: la luce cambia intenzionalmente. |
| `lighting` | Mappa ID oggetto: `dynamic`, `frozen`, `solid`. Frozen Mode6 calcola una volta; solid richiede `colorOverride` esplicito. ID sconosciuti rifiutati. |
| `solidLamp` | Mappa ID mesh per vertici/facce inline esterni. `position` della lampada puntiforme locale, `dark`/`bright` VIC-II0..15, `threshold` opzionale-1..1 ed `emissive` indice-faccia/colore. Compila `faceSolidColors` una volta, senza lavoro lampada per frame. Geometria e lampada simmetriche producono facce simmetriche. |
| `objectBounds` | Scarto conservativo della sfera della mesh immutabile prima di rotazione, luce e proiezione dei vertici. Raggio L1 con margine di quantizzazione, scala Q6 corrente, trasformazione camera effettiva e focale/near nativi. Casi incerti/overflow restano visibili. Lo scarto grafico non elimina collider. Possiede i parametri corrispondenti di `support.frustum`. |
| `preserveBitmapTail` | Booleano. Pulisce8000 byte bitmap per banco e conserva i192 byte finali inutilizzati dopo lo startup. Non alloca sprite né riserva i puntatori. |
| `fixedBackground` | Booleano. Inizializza bordo/sfondo una volta e committa banco/body mode nativi con ogni vista presentata. Non usare se applicazione/IRQ anima `$d020/$d021`. |
| `beforePresent` | Simbolo assembly chiamato sotto PHP/SEI immediatamente prima del commit nativo. Solo foreground, RTS obbligatorio, lavoro breve/limitato, preservare stato renderer e non riabilitare IRQ. Serve allo staging di sprite/puntatori dell'applicazione; non costituisce un doppio buffer generico della color RAM. |
| `dynamicLens` | Booleano. Focale condivisa da proiezione Q4, clipping sui piani camera e API cerchi/sfere installata. `rs_lens_set`: A=focale pari64..254, C=1 accettata/C=0 rifiutata. Aggiorna focale/metà/focale*4 insieme. Chiamare fra viste. Non usa la specializzazione per focale costante. |
| `viewRoll` | Booleano. `rs_view_bank` signed16 fase Q8 (256 unità del byte alto/giro). `rs_view_prepare` esegue prima della vista. Prodotti Q10 signed indipendenti ruotano X/Y camera per mesh e sfere world installate, preservando Z. Nessun prestito di coefficienti/LUT della camera. Rispettare il dominio locale Q4 nativo. |
| `support` | Helper nativi opzionali allocati separatamente, descritti sotto; nessun asset di scena incluso. |

`rs_invalidate_terms` invalida i prodotti delle coordinate, non le liste compilate.
**Cambiare un indice con un valore fuori dalla lista compilata della mesh richiede
ricompilazione.** `rs_invalidate_matrix` invalida la cache rigida.
`rs_invalidate_light`: X=oggetto, C=1 valido/C=0 fuori range, forza il calcolo
frozen dopo modifiche a lampada/normali. Frozen congela l'illuminazione world,
senza renderla automaticamente locale: per quella usare `solidLamp`. Gli oggetti
interamente a colori fissi saltano gli aggiornamenti luce dei vertici.

Routine e stato rs_ appartengono al foreground e non sono rientranti, tranne i
brevi commit espliciti PHP/SEI. L'IRQ non deve chiamarli né sovrascriverne lo stato.
Possono alterare A/X/Y e flag aritmetici salvo indicazione diversa. Restano validi
i contratti dello scratch del renderer. Coordinate camera-oggetti in Q4; posizioni
di scena/API camera in Q8: non mescolare le scale.

Helper nativi in `support`:

| Chiave | Configurazione e ABI |
|---|---|
| `random` | `simulationSeed`/`cosmeticSeed`16 bit non nulli opzionali. `rs_sim_random` e `rs_fx_random` restituiscono A=byte da stati LFSR indipendenti. Seed ripetibile per replay; l'applicazione fornisce entropia quando desidera casualità. |
| `camera` | `shift`1..7(default3), `zoomEnter`<`zoomLeave` Q8 unsigned<=32767, `bankLimit`1..16383. `rs_camera_pose`/`rs_camera_target`: sei signed16 x,y,z,yaw,pitch,bank. `rs_camera_tick` filtra posizioni, angoli circolari più brevi e bank limitato; piccoli residui si agganciano al target. `rs_camera_distance`+`rs_camera_zoom_tick` danno isteresi di prossimità. `rs_camera_apply` copia posizione/yaw/pitch e bank se è installato `viewRoll`; chiamare fra viste. `rs_camera_ease_lo/hi`:65 campioni mezzo coseno0..256. L'applicazione sceglie target e cadenza; nessun percorso o selettore automatico. |
| `rigidPose` | `objects` uguale al numero oggetti. `rs_rigid_pose`: X=sorgente,Y=destinazione, C=1 successo. Copia atomica di posizione, angoli, scala; non mesh, materiali, visibilità o collider. Abilita canali X/Y/scala anche con valori iniziali coincidenti. Usare prima del rendering di componenti/LOD. |
| `lod` | `objects` uguale al numero oggetti,1..32 `groups` disgiunti con indici numerici `near`,`far` e `enter`<`leave` Q8 unsigned<=32767. `rs_lod_tick`: X=gruppo,A=distanza low,Y=high; C=1 valido, A=near0/1. Inizia con far visibile/near nascosto; cambia soltanto visibilità grafica con isteresi. Sincronizzare prima entrambe le pose; mantenere un proprietario collider indipendente. |
| `frustum` | `focal`1..255(default170), `nearQ4`1..32767(default128). `rs_bound_center`: signed16 Q4 x,y,z; `rs_bound_radius`:0..32767; `rs_bound_focal`:1..255. `rs_bounds_visible` C=0 soltanto se sicuramente fuori, C=1 forse visibile/incerto. Supporto conservativo della scatola contenente con margine di un pixel logico e prodotti esatti24 bit. |
| `origin` | `channels`:1..32 descrittori SoA `{low,high,extension?,count}`, count1..255. `rs_origin_shift`: A=delta signed Q8 low,Y=high. Sottrae atomicamente lo stesso delta ai canali e lo somma a `rs_origin_world` signed32. Registrare ogni canale dello stesso asse per fisica/render/colpi/particelle/camera. In alternativa `axes` con configurazioni x/y/z emette `rs_origin_x_shift`/`rs_origin_y_shift`/`rs_origin_z_shift` e accumulatori indipendenti. Ritirare i corpi lontani prima dell'ambiguità del range locale signed. |
| `particles` | `slots`1..32(default16), `attempts`1..32(default8), `life`1..255(default32). `rs_particle_origin`: signed16 Q8 xyz. `rs_particles_emit` riempie il pool con campioni casuali nel volume di raggio31, posizioni origine+campione*8 unità Q8, velocità signed8=campione. `rs_particles_tick` integra gli slot vivi e riduce la vita. SoA `rs_particle_life`, `{x,y,z}_{lo,hi}`, `v{x,y,z}` esposte per disegno/rebase. Usa soltanto RNG cosmetico; non disegna né ordina la profondità. Collegare alle API punto/cerchio esistenti. |
| `sat` | Record vuoto, narrow phase convessa planare: vedere [dinamica](DYNAMICS.it.md). |
| `contacts` | Scheduler limitato con callback, snapshot e rollback: vedere [dinamica](DYNAMICS.it.md). |

Gli helper usano stato nominato nei blocchi Plus esistenti: niente indirizzi RAM
fissi, prestiti di zero page o finestre ampliate. I costi dipendono da moduli,
oggetti, liste e pool; allocatore e mappa finali restano autoritativi. Tutti i moduli
insieme possono superare la RAM, soprattutto Mode6: comporre solo quelli necessari.
Una build rifiutata non riduce la qualità di nascosto. PAL Turbo6510 è qualificato
nel registro esterno; hardware/NTSC e combinazioni arbitrarie non sono implicati.
