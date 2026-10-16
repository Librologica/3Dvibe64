# Note di rilascio — 1.12.0

Release di soli sorgenti disponibile nel repository GitHub. Nessuna demo o esempio,
neppure preesistente. Nessun PRG, brano, disegno o cattura.

## Modifiche

Promuove le opzioni esplicite dev14 camera-extremes (Mode7),zero-terms,
degenerate-faces,live-attributes,adapter-outcodes e flat-span-cache MAT-01.
Aggiunge inside-planes,bounded-divide,packed-samples e unrolled-advance non lit.
Include l'adapter conservativo delle pareti nascoste con allocazione ordinaria,
helper per retini/palette statici, span Gouraud costanti e espansione opzionale
del DDA originale. Le pagine texel host usano solo dati del chiamante. Restano
calcoli esatti e fallback dei clipper/shader nei domini documentati.

I supporti opzionali forniscono pool residente a callback, tabelle camera
parametriche e interfaccia wrapper PSID con banking/ZP verificati. Sono
primitive, non livelli procedurali completi, percorsi camera o brani allegati.
I moduli gameplay precedenti mantengono contratti sperimentali delimitati.
Runtime Mode8 e normalized16 non ricevono queste ottimizzazioni.

## Migrazione

Fornire sempre -SceneFile/--scene. Gameplay richiede anche --project-source/
-ProjectSource esterno; engineVersion del preset deve essere1.12.0. Nessun asset
examples/validation è distribuito: usare scene e input propri. Default qualità
ordinaria e LOD invariati. Le nuove opzioni sono esplicite: scegliere quelle
misurate utili allo shader/progetto. Leggere [contratto ottimizzazioni](RENDER-OPTIMIZATIONS.it.md),
[ABI supporti](ADAPTER-SUPPORT.it.md), [input esterni](EXTERNAL-INPUTS.it.md) e
[qualificazione](QUALIFICATION-1.12.0.it.md). Manuali, indici, copertura CLI ed
esclusioni del pacchetto vengono controllati in italiano e inglese.

Migrazione: sostituire vecchie selezioni esperimenti `all` con liste esplicite compatibili; `all` include ora nuove opzioni e può rifiutare profili che accettavano il gruppo precedente.
