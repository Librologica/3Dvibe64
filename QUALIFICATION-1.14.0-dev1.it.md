# Qualifica nativa — 1.14.0-dev1

La dev locale separata estende legacy-plus a Mode1–7 e Mode7 affine/prospettica, con none/flat/Gouraud A/B/C. Nessun backend geometrico Q8 collegato. Release ufficiali e demo congelate preservate; nessuna pubblicazione GitHub. [Profilo e build](LEGACY-PLUS.it.md) · [risultati strutturati](QUALIFICATION-1.14.0-dev1.json).

## Metodo e provenienza

VICE Turbo6510 MOS8565 **PAL, moltiplicatore64**, presentazione safe, normal160×100, Colodore/filter0, **silenzioso**. Questa qualifica engine non è la demo navetta con musica. Il vero `launch.ps1` esterno fornisce `-default +confirmonexit -pal -turbo6510 64 +sound -autostartprgmode 1 -VICIIfilter 0 -VICIIextpal -VICIIpalette ...`. La cattura aggiunge `-console -warp -initbreak ready -moncommands ...`; warp accelera soltanto l'acquisizione sull'host. JSON conserva comandi completi, percorsi, hash emulatore/PRG/scena/movimento e riferimenti ai grezzi.

Warm-up di128 eventi di simulazione, circa2,56–2,70 secondi emulati; poi un intero percorso di2048 tick, circa40,8 secondi emulati. Si contano solo nuove viste complete su `fps_frame_done`; trace e contatore nativo24 bit concordano. Baseclock PAL985248Hz,312×63 cicli/refresh. Osservate tutte le128 fasi del percorso; esclusi tempo host, refresh duplicati e FPS da replay CPU. Verificati IRQ, fault e scritture SID: zero fault promossi e zero scritture SID. Durata/warm-up individuali, viste complete e p95/peggiore sono nel JSON. Le otto finestre del percorso distinguono fasi visibili, attraversamenti e geometria totalmente esclusa.

Radice delle prove esterne: `C:/Users/rapso/Desktop/TEST 3Dvibe64/3Dvibe64_Dev_1.14.0-dev1-legacy-plus-modes1-7`. `build/` conserva input/ASM/label/mappe/log, `artifacts/` i PRG esatti, `reports/fps-*` timestamp/comandi/log monitor e finestre, `raw/poses-*` PNG/RAM VICE, `tools/` strumenti/oracoli. Sono prove della dev esterne all'SDK solo sorgenti.57 ricompilazioni finali coincidono nei byte con i riferimenti misurati; modifiche documentali non sostituiscono l'eseguibile. I controlli legacy/Q8 derivano dalla1.13.0 e restano identici nei byte nelle build finali.

## Mode1–7: medie native e intervalli

Camera: toroide8×6 da48 vertici, percorso frazionario XYZ/yaw/pitch. Clipping: due triangoli adiacenti indipendenti, a doppia faccia, con attraversamenti near e di tutti i bordi schermo, incluse fasi totalmente dietro. Mode7 è affine in questa tabella. Geometria, movimento, target e opzioni raster sono uguali dove gli adapter storici li supportano.

| Mode | Legacy camera / clip FPS | Plus camera / clip FPS | Q8 camera / clip FPS | Plus camera p95 / worst ms | Plus clip p95 / worst ms |
|---|---:|---:|---:|---:|---:|
| 1 | 50.125 / 50.125 | 50.125 / 50.125 | 16.708 / 50.125 | 19.950 / 19.950 | 19.950 / 19.950 |
| 2 | 50.125 / 41.093 | 49.072 / 41.191 | 12.531 / 37.177 | 19.950 / 39.901 | 39.901 / 39.901 |
| 3 | 50.125 / 46.802 | 50.125 / 47.609 | 21.401 / 47.016 | 19.950 / 19.950 | 39.901 / 39.901 |
| 4 | 50.125 / 46.802 | 25.331 / 47.536 | 16.708 / 46.894 | 39.901 / 39.901 | 39.901 / 39.901 |
| 5 | 25.062 / 46.092 | 25.062 / 47.047 | 16.708 / 41.314 | 39.901 / 39.901 | 39.901 / 39.901 |
| 6 | 25.062 / 34.877 | 25.062 / 35.440 | 16.708 / 34.845 | 39.901 / 39.901 | 59.851 / 99.752 |
| 7 | 12.531 / 30.310 | 12.531 / 31.891 | 7.196 / 29.904 | 79.801 / 79.801 | 79.801 / 179.553 |


**I volumi near differiscono:** plus8WU in ogni modo; Q8=1WU. Legacy1–6 usa8WU, ma il riferimento Mode1 originale supportato salta segmenti in attraversamento e disattiva il clipping schermo. Legacy Mode7 taglia sul piano camera0, genera intersezioni/profondità minima faccia1 e usa divisore minimo di proiezione2. Il vecchio campo generico `nearPlaneWU:8` nei report build era errato per Mode7: qui fa fede `nearClipPlaneWU`. Gli FPS di clipping includono fasi vuote/totale esclusione: non sono FPS uniformi di scena visibile. Nessuna equivalenza dichiarata fra immagini/carichi con near diversi.

La camera Mode4 plus scende dai50,125FPS legacy a25,331FPS: mantenere Y schermo Q2 nativa e prodotti camera seriali esatti costa tempo. Mode3–7 non possono conservare la LUT prodotti da3KB sovrapposta al codice solido attivo. Plus non è sempre più veloce di Q8: la fixture flat prospettica illuminata sotto è più lenta. Sono compromessi misurati, non promesse prestazionali.

## Mode7 prospettica: prima/dopo omogeneo

La fixture camera comune è un toroide6×4 inclinato,24 vertici e48 triangoli. Legacy resta affine perché non offre la selezione prospettica. Plus affine prima e prospettica dopo condividono geometria, percorso e near8; differiscono per interpolazione texture e carrier necessari.

| Profile | Camera FPS | Camera p95 / worst ms | Clip FPS | Clip p95 / worst ms |
|---|---:|---:|---:|---:|
|Legacy affine|16.708|59.851 / 59.851|30.310|79.801 / 159.602|
|Plus affine before|16.480|59.851 / 79.801|31.891|79.801 / 179.553|
|Plus perspective|5.834|179.553 / 199.503|26.417|219.453 / 758.112|
|Q8 perspective|3.948|279.304 / 279.304|25.307|199.503 / 997.515|


Piano clipping con UV continue:212.505 campioni interni robusti nativi per plus prospettica finale, **zero texel errati e zero pixel mancanti** rispetto a un oracolo indipendente raggio inverso/UV. Sulla stessa scena plus affine prima differisce nel31,6943% dei campioni robusti: deformazione affine attesa. Anche Q8 prospettica ha zero errori/mancanze su207.623 campioni; la quantizzazione angolare camera effettiva cambia l'insieme dei campioni. Sono esclusi bordi, profondità sotto10WU e confini del checker entro un quarto di texel. Nessuna prova di precisione infinita o eliminazione dell'aliasing nearest. Massima distanza fuori superficie finale plus sul piano:0,37131 pixel logico.

## Illuminazione

Stesso icosaedro12 vertici/20 facce e camera mobile. I controlli legacy etichettati prospettici usano esplicitamente affine: byte identici ai corrispondenti controlli affini, dei quali riusano le misure esatte; non sono misure prospettiche. Gouraud A/B sono fuori contratto pubblico Q8; Q8 Gouraud C prospettico rifiuta la RAM della stessa scena. Nessun FPS inventato, log di rifiuto conservati. Tutte le otto varianti illuminate plus passano33 pose del percorso e36 pose in orbita completa.

| Mode7 lighting / texture | Legacy affine FPS | Plus FPS | Q8 FPS | Plus p95 / worst ms |
|---|---:|---:|---:|---:|
|flat|22.590|21.587|16.708|59.851 / 59.851|
|gouraud-b|16.708|16.708|C only|59.851 / 59.851|
|gouraud-c|16.716|16.782|15.314|59.851 / 59.851|
|gouraud|16.708|16.708|C only|59.851 / 59.851|
|perspective-flat|22.590|6.780|8.273|159.602 / 159.602|
|perspective-gouraud-b|16.708|6.336|C only|179.553 / 179.553|
|perspective-gouraud-c|16.716|6.489|RAM limit|159.602 / 179.553|
|perspective-gouraud|16.708|6.287|C only|179.553 / 179.553|


## Stabilità e aritmetica

La tabella misura l'errore RMS per coordinata in pixel logici rispetto a trasformazioni camera floating indipendenti, sui vertici originali visibili comuni. Include la quantizzazione angolare dell'input pubblico: il driver scrive frazioni fini dove esiste quell'ABI; il percorso interattivo ereditato legacy/Q8 usa angoli camera byte. Confronta questi input esatti, non dimostra una precisione intrinsecamente inferiore della geometria Q8. Il JSON distingue errori di proiezione agli angoli effettivi e passi fra pose adiacenti. Una fase più fine può aumentare un singolo passo pixel riducendo l'errore di posizione.

| Camera case | Legacy RMS px | Plus RMS px | Q8 RMS px | Plus frozen/shared/disappearance/leak failures |
|---|---:|---:|---:|---|
| 1 | 2.3154 | 0.5620 | 1.8741 | 0 / 0 / 0 / 0 |
| 2 | 3.5259 | 0.6119 | 2.7365 | 0 / 0 / 0 / 0 |
| 3 | 2.3154 | 0.5620 | 1.8741 | 0 / 0 / 0 / 0 |
| 4 | 2.3154 | 0.5620 | 1.8741 | 0 / 0 / 0 / 0 |
| 5 | 2.3154 | 0.5620 | 1.8741 | 0 / 0 / 0 / 0 |
| 6 | 2.3154 | 0.5620 | 1.8741 | 0 / 0 / 0 / 0 |
| 7 | 2.3154 | 0.5620 | 1.8741 | 0 / 0 / 0 / 0 |


Mode2 comprende158 pose camera e368 clipping per profilo; gli altri casi principali33/47. Nei casi principali plus promossi non risultano buffer congelati discordanti, vertici originali condivisi discordanti, scomparse inattese, residui senza spigoli sorgente o pixel rimasti dietro il near.32 serie da36 pose in orbita coprono yaw360°, pitch−45°/0°/+45°, angoli frazionari e near/fuori schermo sui tre renderer e otto varianti illuminate plus. Tre viste complete native per posa; nessun FPS ricavato dalle pose. Sono verifiche osservazionali, non prove per ogni geometria intersecante o posizione possibile.

Le callback6510 assemblate passano oracoli interi indipendenti:800 casi near U/V/Q; per la prospettiva450 encode +450 sample +450 screen +450 span +450 edge, due verifiche span vuoto senza scritture e cinque fault di profondità. Nessun simbolo geometrico Q8 a runtime. py65 serve solo alla correttezza delle callback, mai agli FPS.

## Una modifica per verifica

1. Baseline1.13.0 separata conservata nei byte, con controlli nativi. Abilitati allocazione/spigoli Mode1: primo port a50,125FPS ma uno spigolo perso nell'attraversamento near. Correzione isolata del segmento: stessi50,125FPS, scomparsa eliminata.
2. Mode2 rimane identica nei byte alla plus baseline sulla nuova fixture:49,072/41,191FPS. La scena diversa non è il benchmark camera storico1.13.0.
3. Allocazione Mode3, Y schermo nativa Mode4, contorni Mode5 e adapter Mode6 separati, ciascuno con log nativi camera/clipping. Prima plus rifiutava questi modi: nessun FPS plus pre-estensione immaginario; i controlli legacy/Q8 sopra forniscono il riferimento.
4. Trasporto attributi Mode6: prima25,062/33,890FPS e32,909px massimi fuori superficie; prima correzione25,062/36,125FPS ma un errore di posa congelata per indice Y. Ripristino isolato Y:25,062/35,440FPS, zero errori e1,4511px massimi fuori superficie. Intermedi difettosi conservati nel registro.
5. Attributi Mode7 affine e near8 comune:12,531/31,891FPS. Aggiunta prospettica separata e confrontata con affine prima sopra. Il primo prototipo span prospettico mostrava corruzione grigia e1,33929FPS camera; il clipping non completava il warm-up, quindi nessun FPS valido. La sola correzione span half-open vuoti porta ai5,834/26,417FPS finali, immagini pulite e oracolo UV corretto.
6. Helper Gouraud Mode7 allocati nella coda RAM realmente libera e protetta. Le prime build illuminate fallivano le guardie RAM assembly, dunque nessun FPS prima. Le prestazioni finali sono misurate sopra; tutti i PRG finali non illuminati/flat e degli altri modi coincidono con quelli già qualificati.

Git locale, log intermedi build/FPS/pose e identità finali conservano l'ordine. I rifiuti RAM/profilo non sono prestazioni emulabili. Un primo probe di acquisizione Q8 sovrapponeva il codice rilocato: corretto misurando/riallocando i blocchi Q8 invariati dopo la strumentazione. Sono promosse soltanto le acquisizioni controls/reference corrette.

## Limiti e riproducibilità

Plus:walkLite, normal160×100, high-basic-v2, NoFpsOverlay, senza Ground plane; prospettiva depth8–256WU, texture standard, LOD off. Nessuna nuova qualifica NTSC, audio attivo o hardware fisico. Conservare l'SDK intero e installare il toolchain esternamente. Test sorgenti in [TESTING](TESTING.md); comandi della dev esterna:

```powershell
python -B tools/campaign.py --cases m7-perspective-camera m7-perspective-clipping --profiles legacy-plus --source repository --tag my-rebuild
python -B tools/run_checks.py --names m7-perspective-camera-legacy-plus-my-rebuild m7-perspective-clipping-legacy-plus-my-rebuild --tag my-native --poses
```

Usare nomi/cartelle nuovi: comandi e grezzi nativi sono salvati. Non sovrascrivere gli artefatti qualificati. Release/rapporto storico1.13.0 restano invariati e versionati separatamente.

Anche le otto build con clipping predefinito (Mode1–7 più Mode7 prospettica) coincidono nei byte con le build near8/poly esplicite. Verificati309/309 file invariati sia nella release ufficiale sia nella baseline immutabile.
