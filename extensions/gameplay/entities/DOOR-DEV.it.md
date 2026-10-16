# ENT-01 — porta poligonale e passaggio — 1.12.0

Release 1.12.0: [ottimizzazioni correnti](../../../RENDER-OPTIMIZATIONS.it.md), [input esterni](../../../EXTERNAL-INPUTS.it.md). Tutte le demo, gli esempi e le prove native sono esterni alla distribuzione sorgente.


La distribuzione 1.12.0 include soltanto il modulo riutilizzabile. I nuovi progetti/asset demo sono esclusi. Catture, checkpoint e misure native sotto descrivono prove storiche esterne. Le build di progetto richiedono `--project-source`; vedere la [guida di integrazione](../../../GAMEPLAY.it.md).


Contratto corrente incluso nella release 1.12.0. I riferimenti dev descrivono
la provenienza delle prove. [English](DOOR-DEV.en.md).

`door-entity` conserva UI, guardiano configurabile e materiali misti. Una
parete divisoria nel piano pubblico Y=8 separa la stanza in due parti, con
un'apertura larga 10 WU e alta 18 WU. La porta uniforme si ritrae nel suo
architrave. Il budget del modello skeleton è usato per geometria e logica
della porta; il confronto originale resta nel profilo comparison-ui.

```powershell
python -B work/build-gameplay.py --profile door-entity --out ../builds/door-dev4 --project-source ../my-project
python -B work/qualify-gameplay.py --out ../builds/door-dev4 --checks --benchmark --launcher
```

SPAZIO usa il guardiano entro la portata XY già presente e alterna la
richiesta aperta/chiusa. WASD avvia la visita manuale frontale. Avvicinarsi
al guardiano, azionarlo, spostarsi al centro dell'apertura e attraversarla.
R riavvia il giro automatico con porta chiusa e camera iniziale: i cambi
manuali non possono lasciare il percorso dimostrativo incoerente.

Il giro completo dura 3072 tick e mostra apertura, attraversamento, vista
posteriore, chiusura, riapertura, ritorno attraverso il varco e chiusura.
Le azioni avvengono alle chiavi 6/24/30/44; alla chiave 0 viene rifiutato
l'uso fuori portata. La camera cambia anche inclinazione, entro 14 gradi.
I tentativi d'uso sono azioni della demo, non input sintetici di tastiera.

## Stato e collisione

`dr_state`:0 chiusa,1 apertura,2 aperta,3 chiusura. La corsa è 18 WU a 0,25 WU
per tick,72 tick complessivi. Il giocatore ha raggio 0,5 WU e altezza 12 WU;
il passaggio è libero da 12,25 WU di sollevamento, includendo 0,25 WU di margine.
I montanti continuano a bloccare fuori dall'apertura. La collisione locale
XY è verificata nei due sensi, con bordi dell'apertura e scorrimento.

Una richiesta di chiusura con il giocatore nel varco riporta la richiesta
ad aperta, prima di ridurre la luce libera. Lo stato del guardiano e la
sua animazione seguono la richiesta corretta. Il controllo avanza nei tick
di simulazione, separato dal disegno e stabile durante ogni vista completa.

`dr_seen_states` accumula i 4 stati visitati; `dr_passages` conta i cambi di
lato; `dr_route_fault` segnala in modo saturante le posizioni automatiche
incompatibili con il varco. La qualifica del giro richiede 15,2 e 0 rispettivamente.
`dr_safety_events` conta le riaperture di sicurezza. La portata del guardiano
usa il controllo XY preesistente.

## Disegno e limiti

21 vertici e 32 triangoli/nodi, un oggetto sorgente. La parete e la porta sono
poligoni a doppio lato. Il bordo inferiore visibile viene aggiornato in
Q8 prima della trasformazione della camera; il bordo superiore resta
tagliato dall'architrave. Un materiale uniforme conserva l'aspetto durante
la ritrazione. Lo shader, il clipping vicino/schermo e la copertura sono
quelli comuni del percorso preciso; le texture restano precise con LOD 14–22.

L'importatore salda vertici uguali: i due vertici mobili hanno una quota
intera sorgente distinta, sostituita sempre con pavimento+sollevamento
prima della proiezione. I montanti non vengono spostati insieme alla porta.

Il piano divisorio separa tutta la geometria del guardiano per le camere
supportate. Da davanti viene disegnato prima del personaggio; da dietro
dopo, mostrando solo la parte nel varco libero. La build rifiuta una
configurazione del guardiano che invalida questa separazione. Questo
ordinamento è limitato a un divisorio, una stanza e un billboard; non è
il solver generale di visibilità/intersezioni previsto per altri livelli.
Anche le collisioni restano locali alla scena predisposta.

## Qualifica

20 casi nativi di stati, pressione singola, soglia di altezza, attraversamento,
bordi, chiusura, sicurezza e riavvio automatico dopo l'uso manuale.
14 viste controllano UI e clipping. Cinque confronti pixel indipendenti
verificano i 16.000 byte delle bitmap: porta chiusa, parzialmente aperta,
soglia, aperta e guardiano davanti. I quarti di WU dei vertici mobili sono
controllati nella memoria della macchina emulata.

Per il confronto FPS si usa lo stesso percorso, geometria, viewport e
qualità con `door.json` impostato a `{"schema":1,"motion":false}` tramite
`--door-config`. È un controllo diagnostico con porta fissa chiusa; la
camera programmata non esercita le collisioni durante questa misura di
controllo. L'apertura reale modifica superficie disegnata e occlusione:
gli FPS non misurano soltanto il costo delle istruzioni di stato.

Comandi, raw e misure native sono nell'evidence esterna. I profili precedenti
mantengono i loro programmi qualificati. Documentazione corrente nella release 1.12.0.
