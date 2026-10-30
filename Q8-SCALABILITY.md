# Q8 scalability — 1.15.1

> Stable1.15.1 source SDK published on GitHub. [Status and support](RELEASE-STATUS.en.md).

3Dvibe64 1.12.0: [EN optimization contract](RENDER-OPTIMIZATIONS.en.md) · [Contratto IT](RENDER-OPTIMIZATIONS.it.md).
All examples require external inputs / Tutti gli esempi richiedono input esterni.


The ordinary 1.10.0 geometry contract is retained with the 1.10.2 runtime.
Il contratto geometrico ordinario 1.10.0 è conservato con runtime 1.10.2.
Q8-01/Q8-02 use separate profile APIs / usano API di profilo separate.

Current 1.12.0 ordinary metric/geometry contract; inherited sections retain their stated profile/version.
Contratto metrico/geometrico ordinario 1.12.0; sezioni ereditate con profilo/versione dichiarati.
Current contracts / Contratti correnti: [EN](README.en.md), [IT](README.it.md);
[gameplay EN](GAMEPLAY.en.md), [gameplay IT](GAMEPLAY.it.md);
[qualification EN](QUALIFICATION-1.13.0.en.md), [qualificazione IT](QUALIFICATION-1.13.0.it.md).

## Historical qualification / Qualificazione storica

Official 1.10.0, promoted from the qualified 1.10.0-rc1.
Promotion changes documentation and package identity only. Q8 arithmetic, rounding, projection, near/screen clipping,
Q2 raster and inherited render modes are unchanged.

The public Q8 builder accepts 1..255 objects and 1..255 runtime vertices.
These are encoding ceilings, not guaranteed scene sizes. Source vertices,
faces, runtime faces, mode-specific shade vertices/edges and RAM have their
own existing constraints. The assembler and allocator still reject unsafe
overlap and exhausted gaps. No fallback to lower precision.

Each object owns disjoint mesh vertex/face ranges. The existing per-object
transform adapter is now enabled for arbitrary accepted object counts. For
single meshes above 128 vertices, the same range-based adapter also replaces
the signed descending invalidation loop, so invalid vertices are cleared
through the entire range. One/two-object historical binaries remain unchanged.

The ordinary Q8 exporter still does not accept MeshSourceSharing, Ground,
scene timeline or camera roll. Q8-01/Q8-02 use the separate 1.11.0 profile APIs.
Initial camera rotation is zero; runtime yaw/pitch and existing stationary,
interactive and automatic camera profiles remain supported. Scaled radius
<=40 WU and existing coordinate/scale domains remain enforced.

Normalized 16 keeps its separate experimental two-object/16-runtime-vertex
scope with an explicit object guard; expanding Q8 does not silently expand NF.

[Qualification / Qualificazione](Q8-QUALIFICATION.md) · [Release notes / Note di versione](RELEASE-NOTES-1.10.0.md).

## Build / Compilazione

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -Precision q8 -GraphicsMode 5 -SceneFile ../my-inputs/q8/scalability/13-objects-mode5.json -Q8Camera auto -VideoStandard pal -OutputDirectory ../q8-13-objects-mode5
```

Requires Python 3, PowerShell 7, 64tass. Tests additionally require py65.
Output must be new and outside this SDK. Qualification raw commands and
native data are shipped separately with the qualification evidence package.

## Italiano — contratto completo

La 1.10.0 ufficiale deriva dalla 1.10.0-rc1 qualificata. La promozione modifica
soltanto documentazione e identità del pacchetto. Aritmetica Q8, arrotondamento,
proiezione, clipping near/screen, raster Q2 e modalità di rendering ereditate
restano invariati.

Il builder Q8 pubblico accetta 1..255 oggetti e 1..255 vertici runtime. Sono
tetti di codifica, non dimensioni garantite per una scena. Vertici sorgenti,
facce, facce runtime, shade vertices/edge specifici della modalità e RAM
mantengono i propri vincoli. Assemblatore e allocatore rifiutano sovrapposizioni
non sicure e gap esauriti. Non esiste fallback a una precisione inferiore.

Ogni oggetto possiede intervalli disgiunti di vertici e facce della mesh.
L'adapter di trasformazione per oggetto esistente viene ora abilitato per
qualsiasi numero di oggetti accettato. Nelle mesh singole oltre 128 vertici,
lo stesso adapter per intervalli sostituisce anche il ciclo di invalidazione
discendente signed: i vertici non validi vengono azzerati su tutto l'intervallo.
I binari storici con uno/due oggetti restano invariati.

Questa release non aggiunge MeshSourceSharing, Ground, timeline o roll camera.
La rotazione iniziale della camera è zero; restano supportati yaw/pitch runtime
e i profili camera stationary, interactive e auto esistenti. Sono ancora
vincolanti raggio scalato <=40 WU e domini di coordinate/scala già previsti.

Normalized 16 conserva il proprio ambito sperimentale separato di due oggetti/
16 vertici runtime, con controllo esplicito del numero di oggetti. Ampliare Q8
non amplia implicitamente NF.

Per compilare, usare il comando PowerShell condiviso nella sezione precedente.
Servono Python 3, PowerShell 7 e 64tass; i test richiedono anche py65.
L'output deve essere nuovo ed esterno a questo SDK. Comandi grezzi e dati nativi
della qualificazione sono distribuiti separatamente nel pacchetto delle prove.
Vedere [qualificazione](Q8-QUALIFICATION.md) e
[note di versione](RELEASE-NOTES-1.10.0.md).


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
