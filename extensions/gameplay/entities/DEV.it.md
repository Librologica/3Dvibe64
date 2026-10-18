# BB-02 / primo ENT-01 — 1.13.0

Release 1.13.0: [ottimizzazioni correnti](../../../RENDER-OPTIMIZATIONS.it.md), [input esterni](../../../EXTERNAL-INPUTS.it.md). Tutte le demo, gli esempi e le prove native sono esterni alla distribuzione sorgente.


La distribuzione 1.12.0 include soltanto il modulo riutilizzabile. I nuovi progetti/asset demo sono esclusi. Catture, checkpoint e misure native sotto descrivono prove storiche esterne. Le build di progetto richiedono `--project-source`; vedere la [guida di integrazione](../../../GAMEPLAY.it.md).


Contratto corrente incluso nella release 1.12.0. I riferimenti dev descrivono
la provenienza delle prove. [English](DEV.en.md).

Il profilo `interactive-billboard` eredita la stanza UI con materiali misti.
Il billboard è configurato da `assets/gameplay-scene.json`: asset JSON 16 × 32
con 1..6 frame, posizione pubblica X/Y/Z, dimensioni nel mondo, sequenze idle
e used e durata dei frame in tick di simulazione. La prova alternativa
cambia asset, posizione, dimensioni e animazione modificando solo i dati.

```powershell
python -B work/build-gameplay.py --profile interactive-billboard --out ../builds/interactive-dev3 --project-source ../my-project
python -B work/qualify-gameplay.py --out ../builds/interactive-dev3 --checks --benchmark --launcher
```

Per un'altra configurazione usare `--gameplay-scene percorso/gameplay-scene.json`.
L'asset viene risolto nella cartella del JSON e copiato nella build; output
nuovo e fuori dai sorgenti. La versione PowerShell usa `-GameplayScene`.
Le API restano sperimentali e separate dallo schema pubblico stabile.

## Uso della demo

- All'avvio: orbita automatica completa. L'uso viene tentato all'ingresso
  delle chiavi 0 e 36: il primo è fuori portata, il secondo cambia lo stato
  del guardiano e mostra l'animazione con le mani alzate. Lo stato persiste.
- WASD: entra nella visita manuale frontale; W/S avanti/indietro, A/D
  lateralmente. SPAZIO usa il guardiano quando è entro la portata.
- R: riprende l'orbita automatica. Tenere premuto SPAZIO produce una sola
  azione; rilasciarlo permette una nuova azione.

## Contratto minimo

Una sola istanza, una stanza convessa, palette VIC già condivisa. I pixel
0 sono trasparenti;1..3 sono slot colore;4 è nero opaco. Maschera binaria,
piano parallelo allo schermo, precisione e LOD delle texture invariati.
Il centro sotto 8 WU di profondità viene scartato; BB-03 è disponibile nel
profilo separato multiple-billboards con near 4 WU.

L'entità ha stato 0/1, un evento di successo o rifiuto, contatori separati
e un volume XY. La portata è un quadrato centrato sull'entità: comprende
il bordo, non è una distanza sferica. Le collisioni usano un rettangolo
espanso del raggio giocatore 0,5 WU e i limiti della stanza±23 WU. Movimento
manuale 0,25 WU per tick, assi separati per permettere lo scorrimento. Il
volume del preset tiene la camera davanti al limite vicino del billboard.

La logica avanza nei tick di simulazione, indipendentemente dai frame
disegnati. `en_state`, `en_event_count`, `en_rejected` sono persistenti;
`en_event` è un impulso di un tick (0 nessuno,1 successo,2 rifiuto).
L'evento viene consumato dal binding che seleziona l'animazione. Il
contatore di successi/rifiuti è a 8 bit e torna a 0 dopo 255; nessuna coda eventi.
L'opzione entity.enabled=false esclude l'interazione e la visita manuale.

Questo è il primo tratto di ENT-01: oggetto utilizzabile, eventi e
collisioni locali. Porta mobile e variazione del passaggio sono disponibili nel profilo
door-entity. Collisioni generali e più entità interattive restano future. Mode 8 e fondazione
stabile non sono modificate. Documentazione corrente nella release 1.12.0.

Le prove native conservano snapshot e comandi:17 casi di stato/input,
collisione, scorrimento e animazione; oracoli pixel su tutti i frame;
secondo asset/configurazione, animazione a 3 frame ogni 5 tick; controllo
grafico della UI e confronto FPS sul percorso completo.

## Forma completa dei dati a istanza singola

Schema 1 contiene esattamente `schema`, `billboards`, `entity`; il billboard
ha `id`, `asset`, `position`, `size`, `animations`. XYZ pubblico Q8 finito
in[-20,20]. Larghezza/altezza 1–20 WU con mezze dimensioni Q8 esatte
(multipli 1/128 WU), larghezza≤10, Z inferiore≥−10.5, superiore≤18. Sono
limiti numerici del compilatore, non un solver di pareti/intersezioni:
conservare l’intero inviluppo nella stanza convessa e nel contratto camera.

`idle`/`used`:1–16 riferimenti frame validi, `ticksPerFrame`1–255. `entity`:
`billboard` uguale all’ID, `enabled` booleano, `useRange` Q8 da 1 a 24, due
`collisionHalfSize` Q8 da 0.25 a 10 e `demoUseKeys` interi 0–47. Le chiavi
programmano tentativi d’uso nel giro automatico 48 chiavi, non input tastiera;
il default è 0/36. Asset: `width:16`, `height:32`, `transparentIndex:0`,
`opaqueBlackIndex:4`,1–6`frames` da 512 indici interi 0–4. Campi/tipi/conteggi
errati sono rifiutati. JSON e asset completi in [GAMEPLAY](../../../GAMEPLAY.it.md).
