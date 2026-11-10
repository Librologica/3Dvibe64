# Memoria Mode8 — 1.20.0

> SDK sorgente stabile 1.20.0. Pubblicato su GitHub. [Qualifica](QUALIFICATION-1.20.0.it.md).


I contratti mono/multi mantengono template auto/interactive separati. Il pacchetto
è di soli sorgenti: le mappe sono esterne. L'ottimizzazione non aggiunge banchi
RAM, REU o riduzioni di risoluzione/precisione.

| Regione/risorsa | Contratto corrente |
|---|---|
|Codice basso|Da080d, limite3000 esclusivo per multi; assert code_end.|
|Bitmap|6000/e000; origini attive6660/e660,4608 byte attivi per buffer.|
|Screen/font|Screen RAM4000/cc00; font5800/d800; banking/split UI esistenti.|
|Cache profili multi esistente|4096 byte;32 slot e regole lazy16 colonne originali.|
|Coefficienti/stato multi correnti|608 byte; fine buffer144 attivi,256 riservati.|
|Supporto profilo nullo|ca20..cab7:24 byte codice,128 byte dati immutabili; entro ca00..caff.|
|Helper altezza fissa|5500..55bf,192 byte; fixed_height_end non oltre55c0.|
|Nuova cache per piano|55c0..57a4,485 byte dati:97 flag validi e4×97 valori.|
|Nuovi helper cache|57a5..57f9,85 byte codice; gr17_unit_code_end=57fa non oltre5800.|
|Guardia font|Sei byte prima di5800; l'assembler rifiuta sovrapposizioni.|

I rapporti vengono invalidati a ogni posa latched/composizione. Gli ID fisici
0..96 sono limitati; fuori intervallo resta la divisione originale. La cache
profili completa e quella dei rapporti sono distinte. Non collocare dati custom
in vuoti apparenti senza verificare tabelle runtime, screen e mappa compilata.

I layout automatici pubblici standard conservano157/120/3 byte di codice basso
per perimeter/apertures/two-levels; multi interactive1207. Sono margini dei
template qualificati, non promesse di RAM genericamente libera. Capacità mappe,
buffer e navigazione hanno guardie proprie. L'helper aggiunge2 byte di ritorno
sullo stack e nessuna riserva zero-page. La dimensione PRG comprende i vuoti,
non misura la RAM totale usata.

`work/mode8/build.py` riporta codeLowBytes,lowFree,profileCacheBytes,
profileStateBytes,planeUnitCacheBytes e l'intervallo semiaperto planeUnitCacheRange.
Etichette/mappe dell'assembler descrivono il documento realmente compilato.
[Mode8](MODE8.it.md) · [Formato mappe](MAPS-2.5D.it.md) ·
[Qualifica corrente](QUALIFICATION-1.20.0.json). MODE8-MEMORY.md è un rapporto storico.

La cache profili multi conserva 32 slot e 4096 byte e usa una politica second-chance. I 32 byte di stato aggiuntivo occupano $ca00..$ca1f nella finestra layout_support esistente; la cache per piano da 485 byte resta distinta. Il profilo nullo condiviso usa 128 byte e un helper di 24 byte a $ca20..$cab7; coefficienti e stato occupano complessivamente 608 byte, senza nuovi alias. Template automatici e interattivi condividono questo algoritmo. Guardie, geometria, campionamento lazy, input e presentazione restano quelli dei rispettivi contratti.

Il [registro corrente](QUALIFICATION-1.20.0.json) conserva le identità delle build e le condizioni necessarie per riutilizzare le misure native.
