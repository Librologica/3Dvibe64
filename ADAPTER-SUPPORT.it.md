# Supporti opzionali per adapter — 1.15.0

> SDK sorgente stabile1.15.0 pubblicato su GitHub. [Stato e supporto](RELEASE-STATUS.it.md).

## Supporto legacy-plus nella 1.15.0

Mode1–7 plus e Mode7 affine/prospettica sono promosse dalla dev qualificata in questo SDK stabile. Near8, geometria Q4, luce A/B/C e vincoli RAM/camera sono in [LEGACY-PLUS](LEGACY-PLUS.it.md). Il requisito camera-plane `Mode4NearProfile clip` della Mode7 legacy ordinaria sotto non è il profilo plus: plus richiede default/near8/poly. Campionamento texture fast e LOD restano solo Q8. Risultati e regressioni sono nella [qualifica nativa](QUALIFICATION-1.14.0.it.md).

`extensions/gameplay/runtime_support.py` espone emitter assembly nativi e tabelle
host. Sono primitive esplicite per adapter esterni, non un generatore Backrooms,
un percorso, un brano musicale o un'API generale di gioco. Nessun hook entra
nelle scene ordinarie senza collegamento del chiamante. Codice e dati non hanno
indirizzi fissi: l'adapter li include nel budget assemblato reale, preservando
guardie e visibilità delle banche di memoria.

## Pool residente limitato

`resident_pool(slots,callback,prefix='pool')` restituisce sorgente6502. Slots1..32;
callback/prefix sono simboli assembly validi. Chiamare pool_init una volta e
pool_next quando serve riciclare una stanza/blocco. Il callback riceve X=slot,
A=generazione bassa,Y=alta; deve conservare X e restituire carry impostato solo
dopo avere installato uno slot completo e valido. Un errore conserva cursore e
generazione; l'applicazione decide come ritentare. Il successo marca lo slot,
incrementa la generazione16bit e ricicla il cursore modulo slots. Dati3+slots
byte, oltre al codice; la generazione torna a zero dopo65536. Stato inattivo,
ricentramento coordinate, collisioni, connessioni, PRNG e generazione geometrica
spettano al progetto. Non è caricamento disco WORLD-01 né storia persistente
illimitata. Il pool a memoria costante supporta un percorso procedurale continuo
quando collegato alla logica di generazione del chiamante.

## Tabelle camera

`camera_tables(samples=256,step_height=0.18,bank_degrees=2.5,
glance_degrees=6.0)` restituisce array signed16 bob/bank/glance. Samples16..256;
ampiezze finite non negative: altezza<=4WU, bank<=30gradi, glance<=45gradi.
Bob è WU Q8; gli angoli sono fase Q8 signed16,65536unità/giro.
`camera_assembly(tables,prefix='gait')` emette piani low/high:6*samples byte.
Tick, segno della svolta, tempi degli sguardi, anticipo del bersaglio e binding
Q8 spettano all'applicazione. Nessun percorso, trigonometria per frame,
controller immersivo o hook roll viene installato automaticamente. Il roll
Q8-02 resta un'integrazione separata con il proprio contratto delimitato.

## Interfaccia SID

`parse_sid(path,subtune=1)` legge un PSID esterno v2..4 e restituisce load/init/play,
payload,subtune,title,author. Rifiuta RSID, intervalli errati, play mancante,
temporizzazione CIA, clock solo NTSC e intestazioni multi-chip. Load zero usa
il prefisso little-endian del payload. Non esegue relocazione né dimostra
compatibilità. Driver MUS/PSID-specific non supportati. Il chiamante deve
verificare scritture reali, RAM/zero page riservati e requisiti di banking.

`sid_wrapper(init,play,zp_start=0xf0,zp_count=8,bank=0x35,subtune=1,prefix='sid')`
genera sid_init/sid_tick e lo scambio banca/ZP. Entry$0200..$ffff,1..32byte ZP
contigui verificati a partire da$02 e contenuti nella zero page, subtune1..256.
Init passa il subtune base zero in A,X=Y=0. Il wrapper conserva P,$01 e la ZP
dell'engine dichiarata, mantenendo una ZP persistente del player separata.
Disabilita interrupt durante lo scambio e non è rientrante; A/X/Y vengono
modificati e devono essere salvati dall'IRQ esterno. Chiamare tick una volta per
refresh PAL, indipendentemente dai frame renderizzati. Dati3+2*zp_count byte,
oltre al codice. Codice/dati devono restare visibili con entrambe le banche,
senza sovrapporsi a runtime, video, stack o player. Caricamento, relocazione,
volume/mix e registrazione IRQ restano al chiamante. Nessun brano SID incluso.
[Contratti raster](RENDER-OPTIMIZATIONS.it.md).

## Verifica

I test autonomi eseguono successo/errore del pool,1024chiamate a un player
sintetico con ripristino banca/ZP, limiti camera e matematica degli span.
Non misurano FPS e non qualificano player SID arbitrari. Le prove native usano
progetti esterni: [qualificazione](QUALIFICATION-1.14.0.it.md),
[input](EXTERNAL-INPUTS.it.md).

I callback del pool devono usare staging o ripristinare lo slot precedente in caso di errore: il manager non annulla scritture geometriche arbitrarie. Usare prefissi assembly unici quando si emettono più helper.


## Confine applicativo 1.15.0

Legacy-plus Mode1–7 e Mode7 affine/prospettica sono stabili nel [profilo plus pubblico](LEGACY-PLUS.it.md). Il port privato Underworld usa viewport, loader/layout RAM, culling e ottimizzazioni materiali/LOD/campionatore diversi: non sono nuovi default pubblici o una nuova ABI gameplay generica. Gli adapter gameplay riutilizzabili conservano i vincoli di precisione/profilo esistenti. Vedere [ambito della promozione stabile](RELEASE-NOTES-1.14.0.it.md#distribuzione-e-confine-del-port-privato).

## Ottimizzazioni e API della1.15.0

Il selettore `-LegacyPlusOptimizations` è distinto da EngineExperiments,dal raster Q8 ibrido e dagli altri backend. Richiede Mode4 legacy-plus nel profilo qualificato; default none. `all` comprende arithmetic,edges,spans,outcodes,convex,integer-edges. Wire e stream sono API ASM esplicite escluse da all,non sostituzioni automatiche; stream richiede outcodes e possesso degli slot nativi. Frozen-lighting è separata e cambia intenzionalmente la risposta alle luci mobili. Il codec di chiavi è un modulo dati facoltativo. L'errore Bresenham a8bit non riduce la precisione geometrica Q4/Q10. La matrice oggetto ordinaria resta Q6; nessuna nuova API di rotazione rigida degli oggetti è implicita.

[Opzioni e profilo](EXACT-RENDER.it.md) · [ABI,materiali,memoria e ripieghi](REUSABLE-RENDER.it.md) · [Stato e supporto](RELEASE-STATUS.it.md). Alcune combinazioni non entrano nei64KB e vengono rifiutate.
