# AnimatedMesh v1 — 1.20.1

> SDK sorgente stabile 1.20.1. [Qualifica](QUALIFICATION-1.20.1.it.md).

[English](ANIMATED-MESH.en.md) ·
[Note di release](RELEASE-NOTES-1.20.1.it.md) · [Verifiche](TESTING.it.md).

## Profilo supportato

`AnimatedMesh` è una mesh solida indicizzata con clip di pose dei vertici, senza
scheletro. Il builder ordinario accetta `animatedMeshes` in un file Scene1 esterno.
Selezionare `-Precision legacy-plus -GraphicsMode 4`, `5` o `6`, `-CameraMode walkLite
-CameraViewport normal -MemoryLayout high-basic-v2 -NoFpsOverlay`. Mode4/5 usano
il renderer flat/con contorni esistente; Mode6 usa il renderer Gouraud esistente.
Il viewport normale è160×100 logici /320×200 pixel bitmap. Altre precisioni,
Mode1/2/3/7/8, viewport small, contratti espliciti del modello a oggetti e timeline
dichiarative vengono rifiutati. Piano con texture, interfaccia e alternanza a
tutto schermo dell'applicazione privata degli zombi non fanno parte dell'API v1.

Lo shading ordinario Mode4/5 richiede ancora una luce idonea nella scena oppure
`-DynamicLight`; l'animazione non aggira i controlli del profilo di shading.

Le scene prive di `animatedMeshes` mantengono il percorso di generazione originale.
Geometria, clip e musica sono input esterni; l'SDK sorgente non include asset
applicativi. Compilare, come di consueto, in una copia temporanea dell'SDK.

## Contratto della scena

La radice conserva i normali `schema:1`, `axisConvention:"engine-y-up"`, camera,
world, meshes e objects. Le coordinate hanno Y verticale. Ogni elemento di
`animatedMeshes` contiene questi campi; i campi sconosciuti sono errori.

Il campo radice facoltativo `animatedMeshRenderer` è `generic` di default.
`compact-gouraud` seleziona esplicitamente un profilo Mode6 puro, privo di world
grounds e mesh wire. Conserva Gouraud/clipping ordinari ma omette i quattro
corpi irraggiungibili dei filler generici solid/pattern, mantenendo entry trap
strumentate. Gli include applicativi che riferiscono le etichette rimosse vengono
rifiutati. Non abilita cambio modalità o chiamate private a helper non Gouraud.
Altre modalità e scene ordinarie mantengono tutti i filler. Il profilo libera
spazio per asset animati maggiori senza ampliare finestre RAM o sovrapporre buffer.
`am_cold_calls` deve restare0: un valore non nullo entra in trap e invalida la
qualifica. Prima di usare il risparmio va verificato il confronto delle catture native.
I quattro filler devono corrispondere agli hash sorgente qualificati: template
modificati o sconosciuti sono rifiutati con l'indicazione di selezionare `generic`.

| Campo | Contratto |
|---|---|
| `id` | Univoco tra mesh statiche e animate; lettera ASCII seguita da un massimo di47 lettere, cifre, `_` o `-`. |
| `faces` | 1..255 triangoli/quadrilateri, con ordinamento del normale engine; indici distinti in ogni faccia. Topologia e ordine dei vertici restano costanti. |
| `clips` | 1..16 clip per asset; totale1..255 clip. Ognuna ha `id` locale univoco e `frames`. |
| `frames` | 2/4/8/16/32/64 pose, ciascuna con gli stessi3..85 vertici `[x,y,z]`; coordinate intere con segno−63..63. |
| `material`, `reflectivity` | Proprietà facoltative del materiale sorgente ordinario. Le proprietà dell'istanza mantengono la precedenza normale dell'engine. |
| `lighting` | `reference` (default) oppure `frozen`; `frozen` richiede Mode6. |
| `creaseAngle` | Intero0..180 gradi, default180 per asset animati. Seleziona la normale condivisione delle normali della posa di riferimento; angoli minori separano gli spigoli e consumano più vertici di shading/RAM. |

Sono previsti1..32 asset animati e1..255 istanze animate. Restano i limiti ordinari:
vertici sorgente/runtime, facce, vertici di shading, memoria e oggetti devono
rientrare nei buffer indicizzati a byte esistenti. Sono limiti del formato, non
la garanzia che la combinazione massima entri nei64KB. Non vengono ampliate le
finestre dell'allocatore. Se il posizionamento fallisce, la compilazione si ferma
senza eliminare geometria.

L'oggetto riferisce l'asset mediante il normale `mesh`. Il suo `animation`
facoltativo contiene `clip` (default: prima clip), `phase` (default0), `step`
(default8) e `interpolation` (`linear` di default, oppure `step`). `phase` è un
intero0..(numeroPose×16−1); `step` è0..255 sedicesimi di posa per tick logico50Hz.
`step:0` mette in pausa la clip. `step:8` percorre25 pose/s. L'interpolazione
`step` seleziona la posa corrente: usa lo stesso orologio di fase senza fondere
gli estremi. I booleani non sono interi validi. Clip/campi sconosciuti sono errori.

I due manuali contengono la stessa scena sorgente minima completa:

```json
{
  "schema": 1,
  "axisConvention": "engine-y-up",
  "world": {"backgroundColor": 0, "grounds": []},
  "camera": {"mode": "walkLite", "position": [0,0,0], "rotation": [0,0,0]},
  "animatedMeshes": [{
    "id": "body",
    "faces": [[0,2,1],[0,1,3],[1,2,3],[2,0,3]],
    "lighting": "frozen",
    "clips": [{"id": "bend", "frames": [
      [[-5,-5,0],[5,-5,0],[0,5,0],[0,0,7]],
      [[-5,-5,0],[5,-5,0],[2,5,0],[1,0,7]]
    ]}]
  }],
  "objects": [
    {"id":"left","mesh":"body","position":[-10,0,65],"material":"gray","animation":{"phase":0,"step":4}},
    {"id":"right","mesh":"body","position":[10,0,70],"material":"gray","animation":{"phase":16,"step":7}}
  ]
}
```

Compilare con PowerShell7 e64tass disponibili, indicando la scena esterna:

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -SceneFile C:/project/scene.json -Precision legacy-plus -GraphicsMode 6 -CameraMode walkLite -CameraViewport normal -MemoryLayout high-basic-v2 -Quality fast -Projection extended-table -VideoStandard pal -FramePresentation safe -NoFpsOverlay -SkipCmdUpdate
```

`work/build/animated-mesh/scene.json` e `plan.json` sono intermedi generati: la
scena del chiamante non viene riscritta. `3Dvibe64.animated-mesh.json` riporta
payload delle pose, dimensione dei descrittori e conteggi esatti di compressione.
Il normale rapporto dell'allocatore registra il posizionamento. I percorsi
relativi dei file mesh/include vengono risolti rispetto alla scena originale.
I prodotti della compilazione restano fuori dallo ZIP sorgente.

## Animazione nativa e movimento

Le clip usano minimi per colonna e stream di delta condivisi a0/1/2/4/8 bit,
deduplicati tra clip/asset. Topologia e coordinate sorgente sono condivise quando
più oggetti riferiscono la stessa sorgente, mediante `meshSourceSharing` esistente;
vertici trasformati, ordinamento delle facce e valori Gouraud restano per istanza.
I descrittori costano12 byte per vertice sorgente per clip, oltre a payload
compresso, codice runtime, stato delle istanze e buffer di proiezione/shading.
Le tabelle dei contributi coprono l'intero dominio intero dell'animazione, inclusi
i valori intermedi: possono consumare più RAM della prima posa statica. Le sole
pose compresse non descrivono il consumo totale di memoria.

Il decoder precede la trasformazione. L'interpolazione esatta è
`a + sign(b-a) * floor(abs(b-a)*fraction/16)`, con frazione0..15; l'ultima posa
si fonde con la prima. Le colonne costanti saltano decompressione/moltiplicazione.
Una cache per mesh sorgente identifica la clip/fase realmente presente: alternare
istanze con fasi diverse non riusa la posa sbagliata. Le clip a scatti riusano la
posa decodificata finché non cambia il suo indice. Non vengono introdotti nuovi
intervalli zero-page o alias dello scratch del renderer.

L'animazione usa il clock logico50Hz dell'engine, anche con conversione NTSC,
indipendentemente da FPS e camera. `animation` modifica solo i vertici locali.
Usare le normali `velocity`, `position`, rotazioni e scala dell'oggetto per il
movimento reale nel mondo. Non ci sono root motion, blocco dei piedi, movimento
del pavimento, scorrimento delle texture, teletrasporti o reset dell'origine
automatici. L'applicazione deve abbinare cadenza, falcata e velocità nel mondo.

## Gouraud e illuminazione

Entrambe le politiche usano normali/centri della prima posa della prima clip
dichiarata dell'asset. Selezionare un'altra clip non li ricostruisce. `reference`
conserva il calcolo della luce per frame dell'engine su tale geometria di
riferimento; le normali non vengono ricalcolate dai vertici deformati. `frozen`
calcola i valori di ogni istanza nella sua prima vista illuminata, poi li riusa.
Il Gouraud continua a interpolare i valori dei vertici sui triangoli renderizzati
e ritagliati. È illuminazione di riferimento memorizzata, non illuminazione
fisicamente aggiornata della mesh deformata. Rotazione, movimento e luci mobili
non aggiornano i valori congelati fino all'invalidazione esplicita. La prima
vista visibile non coincide necessariamente con il primo frame video. Restano
le discontinuità delle normali e i limiti dell'ordinamento pittorico di Mode6.

## API nativa

Chiamare dal codice principale con la normale mappatura RAM dell'engine. Il decoder
modifica i propri operandi: non è rientrante e non va eseguito in IRQ. Non installa
nuovi interrupt. Registri e flag sono volatili, salvo il carry documentato. Gli
hook applicativi `graphicEffect` esistenti restano utilizzabili.

| Entry/stato | Contratto |
|---|---|
| `am_set_clip` | X=indice oggetto della scena, A=indice globale clip nell'ordine di dichiarazione asset/clip. C=0 azzera la fase di un'animazione valida; C=1 rifiuta indice fuori intervallo/oggetto statico/asset errato senza modificare lo stato. Non invalida la luce congelata. |
| `am_invalidate_light` | X=indice oggetto della scena. C=0 azzera il flag di luce valida; C=1 per indice fuori intervallo. La vista illuminata successiva aggiorna la luce di riferimento. |
| `am_reset_all` | Ripristina clip/fasi iniziali dichiarate e invalida tutte le cache di posa/luce. Non resetta posizioni ordinarie, camera o stato dell'applicazione. |
| `am_step`, `am_linear` | Indicizzati per oggetto della scena. Step scrivibile0..255; `am_linear` deve essere0 (`step`) oppure1 (`linear`). |
| `am_clip`, `am_phase_lo`, `am_phase_hi`, `am_light_valid` | Stato interno per oggetto, disponibile alla diagnostica in pausa. Per cambiare clip e resettare/invalidare lo stato usare l'API. |

Il builder inizializza l'animazione e chiama `am_tick` una volta per tick logico.
L'applicazione non deve chiamarlo una seconda volta. Il reset della sola
animazione è esplicito; il reset mediante timeline dichiarativa viene rifiutato
per evitare reset parziali. Vedere le [verifiche](TESTING.it.md) per i controlli
del decoder nativo e il protocollo FPS separato sui cicli reali emulati.
