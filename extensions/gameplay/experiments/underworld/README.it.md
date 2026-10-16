# Underworld: integrazione sperimentale — 1.11.0

Contratto corrente della release 1.11.0; i numeri dei checkpoint indicano
la provenienza delle prove. [English](README.en.md).

Variante corretta a tre stanze nella UI LABIRINTO, con tre cubi, skeleton 3D originale
con spada/scudo e guardiano billboard contornato. Entrambi hanno corpo alto
15 WU; il modello usa sempre 38 vertici e 52 segmenti, senza LOD geometrico.
La finestra rimane 96 × 60 logici /192 × 120 fisici, origine 48,8 e focale 51:
campionamento prospettico esatto per pixel e tutte le 60 righe, LOD texture 14–22.

```powershell
python -B work/build-underworld.py --out ../builds/underworld-adventure
```

Avvio nell'output: `launch-demo.cmd`. Usare cartelle nuove. La prova di
controllo accetta `--no-room-culling`; cambia soltanto lo scarto delle stanze
interamente nel semispazio negativo della camera. L'output include sorgenti,
SDK, scena, asset, mappe RAM e strumenti di verifica.

Il nuovo percorso comprende un'orbita intorno ai due personaggi, avvicinamenti
con variazioni verticali dello sguardo e l'esplorazione delle tre stanze.
Il totale resta 96 chiavi /6144 tick. Le visite originali sono ricampionate in 72
chiavi e deviate attorno ai personaggi e al primo cubo. Sono presenti i tre
cubi insieme agli attori: due sul pavimento nelle prime due stanze e uno
sospeso nella terza. In questa variante il cubo centrale è statico. Posizioni
e dimensioni originali; superfici piatte con tre livelli di grigio. Pareti,
aperture, corridoi, pavimenti, soffitti e texture restano quelli precedenti.

## Funzioni integrate

- BB-02: asset, posizione, dimensioni, frame e tempi tramite JSON validato.
  `--scene-config` importa una configurazione e il suo asset senza modificarli.
  Il default usa quattro frame di cammino e due di allerta; il contorno nero
  è opaco, l'esterno trasparente, con profondità e dimensioni prospettiche.
- ENT: entrando nel raggio configurato si invia un uso accettato. SPACE
  invia un uso al fronte di pressione; fuori portata l'evento viene rifiutato.
  Lo stato persistente commuta l'animazione del guardiano e seleziona la clip
  cammino/attacco dello skeleton. Le clip avanzano a tick, senza dipendere
  dagli FPS. La vecchia alternanza automatica delle tre clip è disattivata.
- Selezione conservativa per stanza: dopo il calcolo dei vertici Q8, si
  omette la raccolta delle facce solo se tutti i vertici sono dietro la camera.
  È un test del semispazio negativo, non un PVS angolare né portali dinamici.
- Memoria per fasi: dopo il ritorno di `game_ui_init`, 2904 byte prima usati
  dal decoder e dalle pagine compresse ospitano buffer skeleton, cache
  billboard, stato, ordinamento e coordinate Q8/schermo. Non si riscrive la
  bitmap dell'interfaccia. L'ordinamento compatto usa 175 byte al posto delle
  cinque tabelle da 120 byte; cubi e attori condividono la stessa banda di
  profondità per rispettare il loro ordine al cambiare del lato della camera.
  Pose e inizializzatori stanno sotto I/O; sei frame compressi senza perdita
  usano 1098 byte con token da un byte, decodificati nella cache residente.

## Vincoli e provenienza

È un adattatore privato per questo concatenamento di cinque celle convesse.
I due attori appartengono alla prima stanza e sono disgiunti; i nodi nel
painter conservano l'ordinamento tra soggetti e ambienti. Il billboard rimane
parallelo allo schermo, con centro sotto 8 WU scartato e palette VIC condivisa.
SPACE non ferma la camera; non viene aggiunta navigazione manuale o un solver
generale di collisioni/intersezioni. Il riuso UI è locale a questo profilo:
non libera automaticamente memoria nel backend WORLD-01, nel suo formato
comune o negli altri esperimenti.

Il generatore ordinario, la foundation 1.10.2 e Mode 8 restano sigillati.
L'ottimizzazione precisa `mode7_span_hot` della precedente 1.10.3-dev1 è
conservata esplicitamente come `inherited_precise_span.py`, con `fast=False`.
Il builder, viewport e adattatore sono inclusi; notice e licenza conservati.

## Verifiche

Nella copia di output:

```powershell
python -B tools/verify_adventure.py --project . --control ../underworld-control
python -B tools/benchmark_comparison.py
launch-demo.cmd -Verify
```

Il verificatore usa py65 per correttezza di pose, frame, banking, riuso a fasi,
eventi,3600 casi del painter,16 piani dei cubi e navigazione completa senza
attraversare i cubi; non ricava FPS dal replay CPU. Le catture VICE
confrontano il profilo con/senza scarto, controllano UI, palette e fault.
Il benchmark richiede il riferimento di controllo in `reference/previous`;
la preparazione di consegna e i dati effettivi sono esterni al sorgente SDK.
I runner riusano risultati presenti: per misure nuove scegliere output nuovi.
FPS da nuove presentazioni complete su VICE Turbo6510 PAL× 64, 101 refresh di
warm-up e 6400 refresh di misura, giro completo; comandi/hash/tracce conservati.
