# TEX-01 — texture animate e scorrimento UV — 1.15.1

Stabile1.15.1, release GitHub di soli sorgenti. [Stato release](../../../RELEASE-STATUS.it.md) · [Qualifica corrente](../../../QUALIFICATION-1.15.1.it.md). Scene e asset sono esterni; nessun progetto demo incluso.

> SDK sorgente stabile1.15.1 pubblicato su GitHub. [Stato e supporto](../../../RELEASE-STATUS.it.md).

Release stabile GitHub 1.15.1: [ottimizzazioni correnti](../../../RENDER-OPTIMIZATIONS.it.md), [input esterni](../../../EXTERNAL-INPUTS.it.md). Tutte le demo, gli esempi e le prove native sono esterni alla distribuzione sorgente.


La distribuzione 1.12.0 include soltanto il modulo riutilizzabile. I nuovi progetti/asset demo sono esclusi. Catture, checkpoint e misure native sotto descrivono prove storiche esterne. Le build di progetto richiedono `--project-source`; vedere la [guida di integrazione](../../../GAMEPLAY.it.md).


Contratto corrente incluso nella release 1.12.0. I riferimenti dev descrivono
la provenienza delle prove. [English](ANIMATION-DEV.en.md).

Il profilo sperimentale `animated-textures` estende la stanza della dev5,
conservando UI, due billboard, porta, materiali misti e camera automatica.
Mantiene 96 × 60 pixel logici, campionamento preciso per pixel su tutte le
60 righe e LOD texture 14–22. Una parete cambia fra quattro fotogrammi;
un'altra scorre in U/V con passi interi, anche negativi.

```powershell
python -B work/build-gameplay.py --profile animated-textures --out ../builds/textures-dev6 --project-source ../my-project
python -B work/qualify-gameplay.py --out ../builds/textures-dev6 --checks --benchmark --launcher
```

## Configurazione opzionale

`assets/texture-animation.json`, sostituibile con `--texture-animation`,
usa schema 1, `running`, `sourceTexture`, `asset` e `materials`.
Ogni gruppo materiale ha id, lista di facce sorgente, sequenza `frames`,
durata `ticksPerFrame` e `scroll` con `step:[u,v]` e `ticks`.
I gruppi possiedono cursori e contatori separati; la scelta è per superficie,
senza cambiare lo schema pubblico stabile del livello. Una faccia può essere
assegnata a un solo gruppo e deve già usare lo shader texture e la sorgente
indicata. Flat, Gouraud e i nodi attore 14/15 non possono essere associati.

Sono ammessi da zero a due gruppi, uno stesso atlas 16 × 16 da uno a quattro
fotogrammi, fino a 16 riferimenti per sequenza, durate 1–255 tick e passi UV
interi−15..15 texel per asse. I passi si avvolgono modulo 16; nessuna
semitrasparenza o interpolazione temporale. I colori sono gli indici 1–3
della palette già residente. Il frame 0 deve coincidere con la texture
sorgente; ogni altro frame conserva lo stesso istogramma di pigmenti.
Questo vincolo mantiene invariati i colori modale/accento del LOD esistente.
Palette e istogrammi variabili richiedono un'estensione ulteriore.

Con `materials:[]` il nuovo codice, le tabelle e le pagine aggiuntive non
vengono inclusi: il PRG coincide con il profilo multiple-billboards dev5.
Con `running:false` restano presenti codice e allocazione, ma cursori e
offset non avanzano: questo è il controllo FPS a condizioni uguali.

## Runtime e precisione

La simulazione PAL aggiorna soltanto contatori, cursori e offset. Il cambio
fotogramma seleziona la pagina sorgente al bind del materiale; non ricopia
i texel a ogni tick/fotogramma. La prima pagina è riusata dal renderer.
Le tre pagine aggiuntive occupano 768 byte, con 255 byte riservati al loro
allineamento indipendente dal posizionamento del blocco.

La traslazione UV viene applicata dopo il quoziente prospettico esatto,
prima di formare l'indice della texture. I percorsi di byte completi e
pixel parziali applicano la stessa regola. La frazione e l'avvolgimento
restano quelli del sampler; non viene introdotta approssimazione affine.
I materiali non configurati conservano il percorso originale per pixel.
Il bind e il tick preservano registri e flag del chiamante. Lo stato resta
costante durante una vista completa e avanza in tick, indipendentemente
dal numero di disegni. Gli IRQ non entrano nel selettore o nello shader.

La build lascia 1428 byte nei gap allocabili,1576 in meno della dev5:
runtime 305, helper 146, stato/tabelle 64, blocco pagine 1023, più variazioni
dei call site e dell'allocazione. La scena, i billboard e il percorso sono
gli stessi; il budget residuo resta un limite reale per i passi successivi.

## Qualifica

Undici campioni nativi fra 0 e 128 tick controllano cambio pagina, cadenze,
passi positivi/negativi, avvolgimento e integrità delle quattro pagine
sorgente. Altri 24 tick con `running:false` lasciano lo stato invariato.
Dodici oracoli confrontano 16.000 byte bitmap ciascuno con texture traslate
e selezionate indipendentemente sul PC; comprendono i quattro frame,
scroll visibile, frame+UV combinati, clipping vicino e LOD.
Le 24 viste controllano anche UI e campionamento preciso. Tre tracce native
verificano sulle due facce animate pesi LOD 16/8/0 alle profondità 14/18/22 WU.

Sono eseguiti nuovamente 64 controlli di vista dei billboard,14 casi di
composizione, sette campioni delle animazioni indipendenti e 20 casi di
stato/collisione/sicurezza della porta. Le fixture controllano dati e
simulazione tramite monitor senza modificare il file PRG o gli shader.
I benchmark usano il programma automatico integro e contano soltanto nuove
viste complete, con riscontro del contatore nativo. Comandi e raw sono
nell'evidence esterna; Il checkpoint sopra è storico della1.12.0; la documentazione corrente è in [DOCS](../../../DOCS.md).
