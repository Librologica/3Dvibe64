# LIGHT-01 — bake statico per vertici Gouraud — 1.15.0

> SDK sorgente stabile1.15.0 pubblicato su GitHub. [Stato e supporto](../../../RELEASE-STATUS.it.md).

Release stabile 1.15.0: [ottimizzazioni correnti](../../../RENDER-OPTIMIZATIONS.it.md), [input esterni](../../../EXTERNAL-INPUTS.it.md). Tutte le demo, gli esempi e le prove native sono esterni alla distribuzione sorgente.


La distribuzione 1.12.0 include soltanto il modulo riutilizzabile. I nuovi progetti/asset demo sono esclusi. Catture, checkpoint e misure native sotto descrivono prove storiche esterne. Le build di progetto richiedono `--project-source`; vedere la [guida di integrazione](../../../GAMEPLAY.it.md).


Contratto corrente incluso nella release 1.12.0. I riferimenti dev descrivono
la provenienza delle prove. [English](LIGHT-DEV.en.md).

Il profilo `static-light` estende la stanza della dev6. Il PC calcola valori
di luce per i vertici del pavimento, con lampade puntiformi e occlusione
del divisorio statico. Il C64 usa le tabelle Gouraud già residenti. Due
billboard, porta, texture animate, UI 96 × 60, campionamento preciso e LOD 14–22
conservano il loro funzionamento.

```powershell
python -B work/build-gameplay.py --profile static-light --out ../builds/light-dev7 --project-source ../my-project
python -B work/qualify-gameplay.py --out ../builds/light-dev7 --checks --benchmark --launcher
```

## Calcolo sul PC

`assets/light-bake.json`, sostituibile con `--light-bake`, contiene schema 1,
`enabled`, `ambient`, `biasWU`, `receivers`, `occluders` e `lights`.
Le luci hanno id, posizione pubblica X/destra,Y/avanti,Z/alto, `radiusWU`
e `strength`. Si configurano 1–8 luci, ambiente 0..32, intensità 0..64 e raggio
1..128 WU; posizioni e parametri sono rappresentabili in Q8.

Per ogni vertice si sommano ambiente e contributi di Lambert normalizzato,
con attenuazione lineare fino al raggio della lampada. Un segmento verso
la luce viene provato contro i triangoli statici selezionati; un ostacolo
elimina quel contributo. I valori finali sono arrotondati e limitati a 0..32.
Un bias lungo la normale evita l'auto-occlusione all'origine. Intersezioni
ai bordi sono opache; estremi del segmento e raggi paralleli/coplanari sono
esclusi, trattati come contatti/raggi radenti. Una lampada coincidente con
il campione dà soltanto ambiente, perché non definisce una direzione.

Dopo la conversione Q8, il compilatore usa solo interi, radici intere e
rapporti di determinanti per la visibilità: il bake non usa numeri casuali
o dipendenze dal tempo/percorso del progetto. Il profilo conserva la sua
convenzione privata di mesh X/alto/avanti; il compilatore la converte nello
spazio pubblico e tiene conto dell'avvolgimento orario delle facce sorgente.
Sono supportati un mesh, un oggetto visibile con trasformazione identità e
vertici Q8; trasformazioni o geometrie degeneri vengono rifiutate.

## Dati esportati e runtime

Gli output sono `reports/static-light.bin`, `static-light.json` e
`static-light-surfaces.json`. Il binario usa intestazione ASCII `LB01`,
un byte di conteggio e record di quattro byte: indice faccia e tre livelli
di vertice. Nella demo quattro record occupano 21 byte. Il rapporto conserva
hash di scena, configurazione, superfici in ingresso/uscita e payload,
oltre ai singoli contributi e ai triangoli che bloccano le lampade.

Il binario è un artefatto di compilazione, non un nuovo buffer residente.
I dodici livelli vengono inseriti nelle tre tabelle shader già presenti;
rispetto alla dev6 cambiano soltanto quei dodici byte del payload assemblato.
Codice, dimensioni dei blocchi, allocazione e RAM libera sono identici:
restano 1428 byte nei gap. Il renderer continua a interpolare e disegnare i
livelli Gouraud con le routine esistenti; nessuna lampada viene calcolata
sul C64. `enabled:false` conserva i livelli manuali e ricostruisce il PRG
della dev6.

## Ambito della prova

Sono ricevitori soltanto superfici già Gouraud senza texture. Pareti
texturizzate e facce flat mantengono il trattamento precedente. I vertici
del pavimento ricevono le due lampade della demo; muri e divisorio statico
possono fare ombra. Nodi attore 14/15 e facce della porta mobile 28..31 sono
vietati come ricevitori e occludenti. Le ombre dei corpi mobili richiedono
un sistema ulteriore. Il risultato è campionato ai vertici e interpolato:
la risoluzione geometrica del ricevitore determina il dettaglio dell'ombra.

## Qualifica

Fixture analitiche verificano Lambert, attenuazione, ombra a doppio lato,
estremi del segmento, convenzioni di coordinate, output ripetibile, formato
compatto e rifiuto degli input incompatibili. Un riferimento indipendente
usa distanze euclidee in virgola mobile e intersezioni con il piano/rettangoli
del divisorio, confrontando tutti i dodici campioni. La sua configurazione
manuale di superfici ricostruisce lo stesso PRG del bake automatico.

Le viste native confrontano bake e vecchi livelli manuali in sei camere:
controllano i byte residenti, cambiamenti visibili confinati al pavimento,
UI e palette invariate, sampler preciso. Sono ripetute anche le prove delle
texture animate, dei due billboard e della porta nella build illuminata.
Per gli FPS, bake e controllo usano stessi geometria, percorso, materiali,
qualità e allocazione; cambia soltanto il contenuto delle tabelle di luce.
Comandi, raw e risultati sono nell'evidence esterna. Documentazione corrente nella release 1.12.0.
