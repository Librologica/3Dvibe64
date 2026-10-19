# Ottimizzazioni esatte del renderer — 1.15.0

> SDK sorgente stabile1.15.0 pubblicato su GitHub. [Stato e supporto](RELEASE-STATUS.it.md).

## Supporto legacy-plus nella 1.15.0

Mode1–7 plus e Mode7 affine/prospettica sono promosse dalla dev qualificata in questo SDK stabile. Near8, geometria Q4, luce A/B/C e vincoli RAM/camera sono in [LEGACY-PLUS](LEGACY-PLUS.it.md). Il requisito camera-plane `Mode4NearProfile clip` della Mode7 legacy ordinaria sotto non è il profilo plus: plus richiede default/near8/poly. Campionamento texture fast e LOD restano solo Q8. Risultati e regressioni sono nella [qualifica nativa](QUALIFICATION-1.14.0.it.md).

Tutte le nuove opzioni sono esplicite. Restano i default ordinari: precisione
legacy, texture standard, linee precise, presentazione safe e LOD texture off.
Nessuna opzione attiva Fast, salta righe, riduce risoluzione o cambia il LOD.
L'allocatore conserva le guardie e rifiuta combinazioni che non entrano in RAM.
Non esiste un preset universalmente più veloce. Le differenze di shading Mode4
con camera-extremes e q8-arithmetic restano escluse dai miglioramenti qualificati.

## Opzioni del builder

Passare nomi separati da virgola a `--engine-experiments` in work/q8/build.py o
`-EngineExperiments` nel builder PowerShell. build.json registra le selezioni.
`none` disabilita gli esperimenti; `all` non garantisce compatibilità reciproca.

| Opzione | Dominio e comportamento esatto |
|---|---|
| camera-extremes | Mode7 Q8 mobile: scorciatoie esatte per coefficienti0/+1/-1, percorso originale negli altri casi. Rifiutata fuori Mode7. |
| zero-terms | Trasformazioni Q8: evita solo termini esattamente nulli, conserva frazioni, segni e riporti signed24. |
| degenerate-faces | Solo triangoli sorgente con indici ripetuti; conserva i quad perché una metà può restare visibile. |
| live-attributes | Mode7 prospettico standard: elabora solo i canali X/S/V/W/Q dichiarati dallo shader; conserva illuminazione Q e resa del LOD esistente. |
| adapter-outcodes | Mode7 prospettico: richiede outcode conservativi pubblici anche con geometry_adapter; hook mancanti producono errore. |
| inside-planes | Poligoni Q8: salta una copia del clipping schermo solo se tutti i vertici sono dentro quel piano esatto; intersezioni ancora Q8 complete. |
| bounded-divide | Mode7 prospettico standard: verifica numeratore>>8<denominatore prima della divisione8passi; altrimenti mantiene24/16 e fault per zero. |
| packed-samples | Mode7 prospettico standard: compone quattro campioni originali a due bit con sei shift; campionamento e avanzamenti invariati. |
| unrolled-advance | Mode7 prospettico standard non illuminato con ABI razionale: tre canali esatti, stessi errori/riporti e X/Y conservati. Shader illuminati rifiutati. |

I precedenti q8-arithmetic, uv-texel, camera-table e visibility restano esperimenti
separati. Mode8 e normalized16 non accettano queste aggiunte Q8.

```powershell
python -B work/q8/build.py --scene ../my-inputs/scene.json --out ../exact-build --mode 7 --camera auto --texture-precision perspective --texture-quality standard --engine-experiments inside-planes,bounded-divide,packed-samples
python -B work/build-gameplay.py --profile mixed-surfaces --project-source ../my-project --out ../mixed-build --flat-span-cache
```

`-FlatSpanCache` è l'equivalente PowerShell gameplay. Richiede MAT-01 e il binding
standard `return surfaces.hooks(source, TABLE)` nell'adapter esterno. Input
incompatibili sono rifiutati. Gli adapter diretti possono usare
`surfaces.hooks(source, table, optimize_flat=True)`. Gli span flat scrivono byte
compatti di slot palette preservando estremità e due righe fisiche; texture e
Gouraud mantengono i loro shader. Un pigmento fisso non diventa un materiale lit.

## Attributi attivi

`build(...,face_attribute_masks=[...])` richiede live-attributes e un byte per
faccia runtime. Bit X=1,S=2,V=4,W=8,Q=16; X obbligatorio, S/V richiedono W, Q
esiste solo nel renderer illuminato. `surfaces.attribute_masks(table,
gouraud_channel='q')` produce texture/flat/Gouraud31/1/17; `'s-w'` produce15/1/11
per adapter che implementano già quel carrier prospettico scalare. La maschera
è un contratto, non lo shader. I cambi di tipo faccia devono aggiornarla; lo
shader non deve leggere canali dichiarati inutilizzati.

## Helper raster per adapter

`work/q8/src/exact_raster.py` espone:

- `bounded_divide(parts)`: inserisce il divisore esatto nei parts prospettici standard, senza indirizzi fissi.
- `pack_four(samples)`: composizione host di quattro codici interi0..3.
- `unrolled_advance(source,parts)`: emitter razionale non illuminato, allocazione ordinaria del codice.
- `texture_page(texels)`: valida256 texel a due bit forniti dal chiamante e restituisce gli stessi byte. Il chiamante alloca/allinea la pagina e collega il sampler; non è un asset né una sostituzione automatica del lookup.
- `inline_gouraud(source,sites=1)`: espande chiamate al DDA originale con etichette locali uniche; stessi calcoli interi, più codice/RAM. Etichette incompatibili producono errore.
- `uniform_gouraud(patterns,bulk_entry='sp_solid',row_cache='sp_current_row',prefix='er_uniform')`: genera un dispatcher per1..64 livelli, quattro byte di retino per livello. Verifica che estremi uguali implichino byte uguali per tutti i livelli intermedi. L'adapter valida il dominio runtime e collega solo span compatibili. Gli span variabili mantengono Gouraud; il fill bulk deve rispettare la stessa ABI dei bordi.

`extensions/gameplay/materials/static_patterns.py` fornisce `pattern(level,
low=0,high=1)` (quattro byte Bayer, livello0..16), `constant_interval(patterns,
start,end)`, la cache host `FlatCache.assign(key,revision,level,low,high)` e
`invalidate(key)`. Preparano dati di cache nativa espliciti, senza installare
hook automatici di luce. Rigenerare le voci native quando cambiano revisioni di
geometria, materiali o luci. `bulk_span(closed_edges=False)` emette il raster Q8
Mode6 a byte e i suoi scratch/mask. Il chiamante fornisce span non vuoti0..159,
ptr0lo/hi,ptr1lo/hi,gouraud_init_span_pointers,leftval,rightval,yrow,
gouraud_scan_x/end e tq_closed, salvo bordi tutti chiusi. Preparare
sp_current_row[0..3]. Vengono scritte entrambe le righe fisiche del bitmap.

`shared_palette(source,immutable=True)` verifica material_screen_bytes e
material_color_bytes omogenei e rimuove solo i claim per span; inizializzazione
globale conservata. Il chiamante garantisce la stessa palette per ogni modifica
runtime. Non usarlo se i materiali possono cambiare colori hardware. Gli helper
restituiscono sorgente/dati: non riscrivono automaticamente shader arbitrari.

## Pareti conservative

`extensions/gameplay/visibility/wall_occlusion.py` è un emitter nativo opzionale
per adapter. `validate_quads(vertices,triangles,first_faces)` controlla tutte le
varianti locali: [a,b,c]/[a,c,d], quattro vertici distinti, rettangolo verticale
allineato agli assi, due piani Y ai lati dello zero. Poi usare
`attach(source,parts,face_count=...,first_faces=[...],draw_part=None,
opaque_vertical_contract=True)`:2..128 facce,1..64 coppie consecutive disgiunte.
Con draw_part=None la routine di disegno è in source; altrimenti indicare la
chiave parts che la contiene. Cache e codice usano l'allocatore ordinario,
senza numeri di stanze, palette, RAM fissa, indirizzi SID o percorsi scena.

L'adapter garantisce opacità, quad convessi verticali a tutta altezza, mapping
facce sorgente/runtime, Y superiore positivo/inferiore negativo, camera fra i
due piani, semantica painter e ABI sx/sy/projdone. Non usare con trasparenze,
pareti inclinate, altezze spezzate o movimenti fuori contratto. Validare tutte
le varianti del generatore. Il kernel richiede entrambi i triangoli raccolti,
quattro vertici davanti al near, ordine stretto dei bucket reali e proiezione
intera dentro un rettangolo dell'occludente con margine5pixel logici. Conserva
casi parziali, in parità, incerti o vicino al clipping. Trasformazione e raccolta
restano necessarie: non è uno z-buffer né un solver generale. I contatori
oc_frames/oc_culled_total sono16bit; contano occorrenze, non pareti uniche.

## Qualificazione e migrazione

Vedere [prove native](QUALIFICATION-1.14.0.it.md), [test](TESTING.md),
[input esterni](EXTERNAL-INPUTS.it.md) e [supporti opzionali](ADAPTER-SUPPORT.it.md).
Confrontare immagini agli stessi tick e FPS nativi prima di scegliere opzioni
per un altro progetto. Senza nuove opzioni il comportamento del renderer resta;
SceneFile e gli input gameplay sono sempre esterni ed espliciti.


Dati cache pareti: `2*face_count + 12*quad_count + 17` byte, oltre ai tre blocchi di codice e alle guardie dell’allocatore. Nessuna memoria ipoteticamente recuperabile è contata come libera. Le voci storiche referenceBuilds in PACKAGE-MANIFEST.json indicano input di regressione esterni, non file distribuiti nell’SDK.


## Entry point per adapter

Questo collegamento usa geometria del chiamante, non una scena allegata. `sdk`, `my_vertices`, `my_triangles`, `first_faces`, `my_scene_path` e `my_output` sono input espliciti del progetto. Validare tutte le varianti generate, non soltanto quella iniziale.

```python
import sys
sys.path.insert(0, str(sdk / 'extensions/gameplay/visibility'))
from wall_occlusion import validate_quads, attach

validate_quads(my_vertices, my_triangles, first_faces)
def adapt(source, parts, labels):
    return attach(source, parts,
                  face_count=labels['FACE_COUNT'],
                  first_faces=first_faces,
                  opaque_vertical_contract=True,
                  palette_indices=my_reachable_palette_entries)

builder.build(my_output, my_scene_path, mode=6,
              camera_auto=True, geometry_adapter=adapt,
              engine_experiments='inside-planes')
```
La sola geometria non dimostra opacità, limiti camera, trasformazioni oggetto/mondo o compatibilità shader. Dichiarare il contratto soltanto dopo queste verifiche dell’adapter. Per routine di disegno nei parts usare `draw_part`.

Chiavi e revisioni FlatCache devono essere immutabili/hashable; tipi errati non riusano voci esistenti.

L’occlusione pareti richiede anche una palette hardware VIC condivisa e immutabile. Le due tabelle dei materiali vengono controllate omogenee in build e l’adapter deve conservarle a runtime. Palette miste e conflitti di proprietà delle celle non sono qualificati e vengono rifiutati.

`palette_indices=None` controlla tutto il catalogo materiali. Se contiene palette inutilizzate, fornire una lista esplicita non vuota di tutte le voci raggiungibili, inclusi materiale+offset riflettività, inizializzazione e override istanza/colore. L’adapter garantisce che nessun’altra voce/colore diventi attivo. Sono controllate omogenee solo queste voci; transizioni dinamiche non dichiarate restano fuori contratto.

`static_patterns.native_cache(face_count,low=0,high=1,prefix='sf',row_cache='sp_current_row')` emette codice/dati di cache nativa alla generazione. Supporta1..255facce; dati6*face_count+68byte più codice/guardie. `sf_assign`: A=livello0..16,X=faccia, chiamare solo alla generazione/modifica. `sf_load`: X=faccia, copia quattro byte già pronti nella cache dello span; una faccia non assegnata restituisce carry zero senza cambiarla. `sf_invalidate`: X=faccia. Carry impostato indica successo; A/Y modificati,X conservato. Voci iniziali non assegnate; faccia/livello errati rifiutati. Aggiornare soltanto fra viste complete. L’adapter gestisce fallback e invalidazione per geometria/materiale/luce. Nessun calcolo di luce per frame viene installato.


## Confine applicativo 1.15.0

Legacy-plus Mode1–7 e Mode7 affine/prospettica sono stabili nel [profilo plus pubblico](LEGACY-PLUS.it.md). Il port privato Underworld usa viewport, loader/layout RAM, culling e ottimizzazioni materiali/LOD/campionatore diversi: non sono nuovi default pubblici o una nuova ABI gameplay generica. Gli adapter gameplay riutilizzabili conservano i vincoli di precisione/profilo esistenti. Vedere [ambito della promozione stabile](RELEASE-NOTES-1.14.0.it.md#distribuzione-e-confine-del-port-privato).

## Ottimizzazioni e API della1.15.0

Il selettore `-LegacyPlusOptimizations` è distinto da EngineExperiments,dal raster Q8 ibrido e dagli altri backend. Richiede Mode4 legacy-plus nel profilo qualificato; default none. `all` comprende arithmetic,edges,spans,outcodes,convex,integer-edges. Wire e stream sono API ASM esplicite escluse da all,non sostituzioni automatiche; stream richiede outcodes e possesso degli slot nativi. Frozen-lighting è separata e cambia intenzionalmente la risposta alle luci mobili. Il codec di chiavi è un modulo dati facoltativo. L'errore Bresenham a8bit non riduce la precisione geometrica Q4/Q10. La matrice oggetto ordinaria resta Q6; nessuna nuova API di rotazione rigida degli oggetti è implicita.

[Opzioni e profilo](EXACT-RENDER.it.md) · [ABI,materiali,memoria e ripieghi](REUSABLE-RENDER.it.md) · [Stato e supporto](RELEASE-STATUS.it.md). Alcune combinazioni non entrano nei64KB e vengono rifiutate.
