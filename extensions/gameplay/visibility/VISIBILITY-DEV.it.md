# VIS-01 — visibilità conservativa per settori e portali — 1.15.1

Stabile1.15.1, release GitHub di soli sorgenti. [Stato release](../../../RELEASE-STATUS.it.md) · [Qualifica corrente](../../../QUALIFICATION-1.15.1.it.md). Scene e asset sono esterni; nessun progetto demo incluso.

> SDK sorgente stabile1.15.1 pubblicato su GitHub. [Stato e supporto](../../../RELEASE-STATUS.it.md).

Release stabile GitHub 1.15.1: [ottimizzazioni correnti](../../../RENDER-OPTIMIZATIONS.it.md), [input esterni](../../../EXTERNAL-INPUTS.it.md). Tutte le demo, gli esempi e le prove native sono esterni alla distribuzione sorgente.


La distribuzione 1.12.0 include soltanto il modulo riutilizzabile. I nuovi progetti/asset demo sono esclusi. Catture, checkpoint e misure native sotto descrivono prove storiche esterne. Le build di progetto richiedono `--project-source`; vedere la [guida di integrazione](../../../GAMEPLAY.it.md).


Contratto corrente incluso nella release 1.12.0. I riferimenti dev descrivono
la provenienza delle prove. [English](VISIBILITY-DEV.en.md).

Profilo sperimentale `sector-visibility`, erede di `static-light` nella dev8.
Il compilatore sul PC genera una tabella dei settori potenzialmente visibili
per ogni settore di partenza e combinazione di porte aperte. Segue tutti i
percorsi del grafo: più aperture e percorsi alternativi si uniscono. Chiudere
una porta non nasconde un settore raggiungibile attraverso un altro portale.
Non esegue esclusioni angolari o del frustum: la tabella è un sovrainsieme.

Il contratto del compilatore è un mondo sigillato con celle rettangolari
allineate agli assi, partizione completa del volume e tutte le aperture
dichiarate. Consente 2–8 settori, 0–4 porte, 1–16 portali; coordinate Q8
X/avanti/alto entro ±127 WU. I portali sono rettangoli sulle facce comuni.
Le geometrie che attraversano un confine appartengono a tutti i settori
intersecati dal loro AABB; i centroidi non decidono l'appartenenza.
Il formato host `PV01` contiene conteggi, maschere per faccia e righe PVS.

L'adapter nativo di questa prova accetta solo la stanza sigillata qualificata:
due settori, divisorio a Y=8 e apertura X[-5,5], Z[-10,8], con una porta
opaca che si ritrae. Verifica l'identità della geometria e i limiti dei due
billboard; i loro nodi appartengono al settore anteriore. Il divisorio e la
porta restano in entrambi i settori. Un livello arbitrario richiede un nuovo
adapter e la verifica della corrispondenza fra aperture e geometria reale.

Una porta è chiusa per la visibilità solo con `dr_lift == 0` in entrambi i
byte Q8. Anche 1/256 WU di apertura abilita tutti i settori connessi, prima
della soglia di passaggio del personaggio. I settori non visibili vengono
esclusi prima della raccolta delle facce, conservando le pipeline di
proiezione, clipping, materiali, palette e ordinamento già qualificate.

La camera viene classificata solo con yaw esattamente 0°/180°, pitch 0,
nell'inviluppo interno della stanza e oltre 8 WU dal divisorio. In tutte le
viste oblique si mantengono tutte le facce: il renderer storico può mostrare
pochi pixel dello sfondo lungo i bordi della geometria occludente e la nuova
selezione deve preservare anche quei pixel. Nella fascia vicina, sui limiti o fuori dall'inviluppo
si mantengono tutti i settori. Questa riserva contiene l'intero volume vicino
del viewport 96 × 60, focale 41 e near 4 WU, per ogni orientamento supportato;
evita esclusioni basate su un occludente già tagliato dal near plane.

```powershell
python -B work/build-gameplay.py --profile sector-visibility --out ../builds/visibility --project-source ../my-project
python -B work/qualify-gameplay.py --out ../builds/visibility --checks --benchmark --launcher
```

`--visibility` accetta un JSON alternativo entro il contratto dell'adapter.
`culling:false` conserva codice, dati e allocazione, cambiando soltanto il
byte iniziale `vs_enabled`: è il controllo nativo a condizioni uguali.
`enabled:false` omette interamente l'estensione e ricostruisce il PRG dev7.
I rapporti `visibility.json` e `visibility.bin` rendono ripetibile il bake.
Le prove e i benchmark della build consegnata sono nella cartella esterna
`reports/dev8`; i risultati non vengono dedotti dal numero di facce eliminate.

Questa fase qualifica il compilatore conservativo e il consumo delle sue
tabelle nella scena delimitata. La riduzione angolare attraverso i portali
e l'integrazione con livelli generali richiedono ulteriori qualifiche.
Documentazione corrente inclusa nella release 1.12.0.

Il percorso automatico mantiene le posizioni e le rotazioni orizzontali della
dev7. Ai keyframe 0–4,24–28,44–47 lo sguardo resta orizzontale per esercitare
la selezione; gli altri tratti conservano le variazioni verticali. Le due
configurazioni del benchmark usano la stessa camera. Con enabled:false
si conserva anche il percorso originale, per ricostruire il PRG dev7.
