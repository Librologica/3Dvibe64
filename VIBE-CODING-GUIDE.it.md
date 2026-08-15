# Manuale pratico per creare demo e PRG con 3Dvibe64 usando Codex

## Introduzione

3Dvibe64 è un engine grafico 3D progettato per il Commodore 64. Il suo scopo è permettere di descrivere una scena tridimensionale in un file JSON e di trasformare quella descrizione in un programma `.prg`, pronto per essere eseguito su un C64 compatibile oppure nell’emulatore VICE.

Questo manuale è rivolto anche a chi non conosce l’Assembly e non ha mai compilato un programma per Commodore 64. Non è necessario scrivere a mano il renderer, conoscere i registri del VIC-II o intervenire direttamente sulle routine 6510. Il lavoro viene suddiviso in due parti ben distinte:

- l’utente decide che cosa deve apparire nella demo e come deve comportarsi;
- Codex traduce quelle richieste in file, parametri e operazioni di compilazione compatibili con l’engine.

Il flusso generale è il seguente:

```text
Idea descritta in linguaggio naturale
             ↓
Codex prepara o modifica il JSON
             ↓
Il builder genera il codice Assembly
             ↓
64tass compila il codice
             ↓
Viene prodotto il PRG
             ↓
VICE esegue e verifica la demo
```

Ogni passaggio ha una funzione precisa. Il JSON contiene la descrizione della scena; il builder interpreta quella descrizione e genera il codice Assembly necessario; 64tass converte l’Assembly in un programma eseguibile; VICE permette infine di osservare il risultato e di controllare che la demo funzioni correttamente.

L’utente può quindi concentrarsi soprattutto sugli aspetti creativi e visivi:

- gli oggetti presenti nella scena;
- i colori;
- i materiali;
- i movimenti;
- la posizione e il comportamento della camera;
- la luce;
- il terreno;
- le animazioni;
- il ritmo della sequenza;
- il risultato visivo complessivo.

Codex può occuparsi delle attività più tecniche:

- analizzare la struttura dell’engine;
- leggere la documentazione e gli esempi ufficiali;
- scrivere o modificare il JSON;
- importare e controllare le mesh;
- verificare scala, orientamento, winding e compatibilità geometrica;
- lanciare il builder;
- interpretare i messaggi di errore;
- diagnosticare problemi di clipping, culling, profondità o rasterizzazione;
- compilare il PRG;
- provarlo in VICE;
- salvare log, screenshot e hash;
- conservare le versioni già approvate senza sovrascriverle.

Il principio più importante dell’intero metodo è semplice: **la scena deve poter essere ricostruita in modo ripetibile a partire dal JSON e dal comando di compilazione**. Un PRG ottenuto con modifiche manuali non documentate può anche funzionare, ma diventa difficile da correggere, aggiornare o riprodurre. Per questo il JSON deve rimanere la sorgente autorevole della demo, mentre l’Assembly generato deve essere considerato un prodotto intermedio.

## Come leggere e usare questo manuale

Le prime sezioni spiegano come preparare il computer e organizzare le directory. Le sezioni centrali descrivono le principali funzioni dell’engine: modalità grafiche, camera, viewport, memoria, unità di misura, clipping, culling, Ground, materiali, luci, istanze e timeline. Le sezioni finali mostrano invece come lavorare con Codex in modo ordinato, come compilare, come chiedere modifiche, come diagnosticare gli errori e come congelare una versione approvata.

Non è necessario memorizzare tutte le opzioni. È sufficiente comprendere il significato generale di ogni scelta e formulare richieste precise. Codex dovrà comunque controllare il builder e gli esempi inclusi nella release prima di usare un parametro, perché alcuni dettagli dell’interfaccia possono cambiare nel tempo.

Questo manuale va letto insieme a [README.it.md](README.it.md),
[QUICKSTART.md](QUICKSTART.md) e [WORLD-METRICS.md](WORLD-METRICS.md). Chi
desidera studiare o modificare direttamente il codice 6510/6502 generato deve invece
consultare [ASSEMBLY-GUIDE.it.md](ASSEMBLY-GUIDE.it.md).

## Indice

1. [Cosa occorre](#1-cosa-occorre)
2. [Come ottenere 3Dvibe64](#2-come-ottenere-3dvibe64)
3. [Installazione degli strumenti](#3-installazione-degli-strumenti)
4. [Lasciare che Codex prepari l’ambiente](#4-lasciare-che-codex-prepari-lambiente)
5. [Organizzazione delle directory](#5-organizzazione-delle-directory)
6. [Come funziona la compilazione](#6-come-funziona-la-compilazione)
7. [Le modalità grafiche](#7-le-modalità-grafiche)
8. [Camera](#8-camera)
9. [Viewport e memoria](#9-viewport-e-memoria)
10. [Unità dell’engine](#10-unità-dellengine)
11. [Near plane e avvicinamento alle superfici](#11-near-plane-e-avvicinamento-alle-superfici)
12. [Backface culling](#12-backface-culling)
13. [Ground](#13-ground)
14. [Struttura elementare di un JSON](#14-struttura-elementare-di-un-json)
15. [Importare una mesh](#15-importare-una-mesh)
16. [Materiali, colori e pattern](#16-materiali-colori-e-pattern)
17. [Luce statica e luce orbitale](#17-luce-statica-e-luce-orbitale)
18. [Istanze multiple](#18-istanze-multiple)
19. [Timeline dichiarativa](#19-timeline-dichiarativa)
20. [Compilare un PRG](#20-compilare-un-prg)
21. [Come iniziare una nuova demo con Codex](#21-come-iniziare-una-nuova-demo-con-codex)
22. [Come richiedere modifiche](#22-come-richiedere-modifiche)
23. [Come diagnosticare un problema](#23-come-diagnosticare-un-problema)
24. [Test in VICE](#24-test-in-vice)
25. [Controlli runtime](#25-controlli-runtime)
26. [Congelare una versione approvata](#26-congelare-una-versione-approvata)
27. [Quando una demo è canonica](#27-quando-una-demo-è-canonica)
28. [Errori comuni](#28-errori-comuni)
29. [Flusso di lavoro completo consigliato](#29-flusso-di-lavoro-completo-consigliato)
30. [Prompt completo per iniziare da zero](#30-prompt-completo-per-iniziare-da-zero)
31. [Conclusione](#conclusione)

## 1. Cosa occorre

L’ambiente consigliato è Windows 10 o Windows 11. Il builder principale è scritto per PowerShell e il flusso di lavoro descritto in questo manuale utilizza percorsi e comandi tipici di Windows.

Servono i seguenti elementi:

- una release di 3Dvibe64;
- PowerShell;
- 64tass;
- VICE;
- Python 3;
- Git, consigliato ma non strettamente obbligatorio;
- Codex con accesso alla directory di lavoro.

Questi elementi non hanno tutti lo stesso ruolo.

La release di 3Dvibe64 contiene il builder, gli esempi, la documentazione e gli eventuali test. PowerShell esegue il builder. 64tass compila l’Assembly generato. VICE avvia il PRG e permette di verificarlo. Python è utile per controlli, conversioni e automazioni. Git rende più sicuro il lavoro sulle versioni, anche se non è indispensabile per ottenere un PRG. Codex coordina le operazioni e modifica i file richiesti.

Non è necessario installare o configurare ogni strumento manualmente. Si può chiedere a Codex di controllare il computer, individuare ciò che manca, preparare versioni portabili e verificare che l’intera catena funzioni. È comunque importante lasciare a Codex una directory di lavoro nella quale possa leggere, creare e modificare file senza intervenire sulla copia ufficiale dell’engine.

## 2. Come ottenere 3Dvibe64

### Metodo consigliato: ZIP ufficiale da GitHub

Per un principiante, il metodo più semplice e sicuro consiste nello scaricare lo ZIP allegato a una release ufficiale del repository GitHub.

La procedura è questa:

1. aprire il collegamento GitHub fornito dall’autore;
2. entrare nella sezione **Releases**;
3. selezionare la versione che si desidera usare;
4. scaricare lo ZIP ufficiale allegato alla release;
5. estrarre lo ZIP in una directory dedicata.

Un possibile percorso è:

```text
C:\3Dvibe64\3Dvibe64-release
```

È preferibile usare lo ZIP pubblicato tra gli allegati della release, invece del comando generico:

```text
Code → Download ZIP
```

I due download non sono necessariamente equivalenti. Il pulsante **Code → Download ZIP** crea normalmente un archivio del contenuto corrente del repository o del ramo selezionato. Lo ZIP allegato a una release, invece, identifica in genere un pacchetto preciso, già preparato, verificato e destinato alla distribuzione. Per un primo utilizzo è quindi più facile partire dal pacchetto ufficiale della release.

Dopo l’estrazione è opportuno controllare che nella directory siano presenti almeno la documentazione, gli esempi e lo script di build. Il percorso tipico del builder è:

```text
work\build-3Dvibe64.ps1
```

Se si dispone soltanto del collegamento al repository, lo si può fornire direttamente a Codex con una richiesta come questa:

```text
Questo è il repository GitHub ufficiale dell’engine:

[incolla qui l’indirizzo copiato dal pulsante Code di GitHub]

Individua l’ultima release stabile, scarica lo ZIP ufficiale,
verificane il contenuto ed estrailo in:

C:\3Dvibe64\engine-ufficiale

Non modificare direttamente la copia ufficiale.
```

La frase finale è importante. La directory `engine-ufficiale` deve essere trattata come baseline, cioè come copia di riferimento da conservare intatta. Le demo e gli esperimenti verranno realizzati su copie separate.

Il manuale non incorpora un URL specifico, perché l’indirizzo dipende dalla
collocazione definitiva del repository. Copiarlo dal pulsante **Code** della
pagina GitHub ufficiale e incollarlo nella richiesta prima di eseguirla.

Se l’ambiente di Codex non permette l’accesso alla rete, possono verificarsi due situazioni:

- Codex chiede l’autorizzazione per accedere a Internet e scaricare il pacchetto;
- Codex invita l’utente a scaricare manualmente lo ZIP e a indicargli poi il percorso locale.

In entrambi i casi, una volta che lo ZIP è disponibile sul computer, Codex può verificarne il contenuto, estrarlo e predisporre una copia di lavoro.

### Metodo alternativo: Git

Chi desidera seguire più da vicino lo sviluppo del repository può usare Git:

```powershell
git clone <indirizzo-copiato-dal-pulsante-Code-di-GitHub>
```

Git è più potente di un semplice archivio ZIP perché permette di:

- vedere quali file sono cambiati;
- confrontare due stati del progetto;
- creare rami di sviluppo separati;
- annullare modifiche sbagliate;
- tornare a una versione precedente;
- aggiornare il progetto dal repository;
- verificare che la baseline non sia stata alterata;
- registrare in modo ordinato l’evoluzione di una demo.

L’uso di Git richiede però un minimo di familiarità con commit, branch e working tree. Per creare la prima demo non è necessario affrontare subito questi concetti. Lo ZIP ufficiale rimane quindi il metodo più diretto, mentre Git diventa particolarmente utile quando il lavoro inizia a produrre molte varianti o modifiche al builder.

## 3. Installazione degli strumenti

### PowerShell

PowerShell è già incluso nelle versioni moderne di Windows. Non va confuso con il vecchio Prompt dei comandi: il builder utilizza la sintassi e le funzioni di PowerShell.

Per controllare che sia disponibile, aprire PowerShell e digitare:

```powershell
powershell.exe -NoProfile -Command "$PSVersionTable.PSVersion"
```

L’opzione `-NoProfile` evita che eventuali personalizzazioni del profilo dell’utente interferiscano con l’esecuzione. Se il comando restituisce un numero di versione senza errori, PowerShell è disponibile.

Il builder dell’engine si trova normalmente qui:

```text
work\build-3Dvibe64.ps1
```

Lo script deve essere eseguito dalla radice della copia di lavoro oppure richiamato con un percorso completo. In alcuni sistemi Windows l’esecuzione degli script può essere limitata dalla Execution Policy; per questo i comandi di esempio usano:

```text
-ExecutionPolicy Bypass
```

Questa opzione viene applicata soltanto al processo lanciato dal comando e consente di eseguire lo script senza modificare necessariamente la configurazione permanente del sistema.

### 64tass

64tass è l’assembler che trasforma il codice generato dal builder nel PRG destinato al Commodore 64. Il builder pubblico risolve il percorso di 64tass all’inizio della propria esecuzione e, se non lo trova, si interrompe prima di scrivere `work\3Dvibe64.asm` e prima di creare il PRG. Per ottenere anche il solo ASM tramite il builder ufficiale è quindi necessario rendere disponibile 64tass con uno dei metodi supportati.

È richiesta una versione compatibile dell’assembler; la documentazione dell’engine indica 64tass 1.60 o successivo. Una sistemazione portabile consigliata è:

```text
C:\Tools\64tass\64tass.exe
```

Una versione portabile non richiede un’installazione tradizionale: è sufficiente estrarre i file in una directory stabile e indicare al builder dove si trova l’eseguibile.

Configurazione temporanea della variabile d’ambiente:

```powershell
$env:TASS64_EXE = "C:\Tools\64tass\64tass.exe"
& $env:TASS64_EXE --version
```

La variabile vale per la sessione corrente di PowerShell. Il secondo comando avvia 64tass e ne mostra la versione, permettendo di controllare che il percorso sia corretto.

Il builder può anche individuare 64tass attraverso altre configurazioni, per esempio una variabile `TASS64_PATH`, il `PATH` di Windows o una copia collocata sotto `work\tools\64tass`. Prima di cambiare la configurazione, Codex dovrebbe leggere il builder e usare uno dei metodi effettivamente supportati.

### VICE

VICE è l’emulatore utilizzato per eseguire e verificare i PRG. Nel pacchetto di VICE sono presenti diversi eseguibili; per questo manuale sono particolarmente importanti:

- `x64sc.exe`: emulazione accurata del C64, da usare per i test principali e per la verifica autorevole del rendering;
- `xscpu64.exe`: emulazione SuperCPU con CPU accelerabile, utilizzabile come prova supplementare e non contrattuale per individuare sequenze accidentalmente legate alla velocità della CPU. Non sostituisce `x64sc` e non fa parte delle firme ufficiali di regressione della distribuzione.

Un percorso portabile consigliato è:

```text
C:\Tools\VICE\bin
```

Per indicare a PowerShell l’eseguibile principale:

```powershell
$env:VICE_EXE = "C:\Tools\VICE\bin\x64sc.exe"
& $env:VICE_EXE -version
```

La variabile `VICE_EXE` non è necessariamente letta dal builder: viene usata in questo manuale come riferimento comodo per avviare l’emulatore. Codex può inoltre registrare separatamente il percorso di `xscpu64.exe` quando si sceglie di eseguire il test accelerato facoltativo. L’assenza di `xscpu64` non impedisce la build e non invalida il contratto pubblico basato su `x64sc`.

VICE serve non soltanto a “vedere se parte”. Deve essere usato per controllare l’assenza di ritorni al BASIC, corruzione della bitmap, errori di clipping, problemi di profondità e differenze temporali anomale tra configurazioni.

### Python 3

Python viene utilizzato per numerose attività di supporto:

- controlli automatici;
- esecuzione dei test inclusi nel pacchetto;
- verifica degli hash;
- importazione e analisi delle mesh;
- conversione di file OBJ;
- simulazioni grafiche;
- generazione o trasformazione di JSON;
- test contrattuali;
- elaborazione di log e screenshot;
- confronto di output prodotti da build differenti.

Per controllare la presenza di Python:

```powershell
python --version
```

È consigliata una versione moderna di Python 3. Se il comando `python` non viene riconosciuto, in alcuni sistemi può essere disponibile il launcher `py`. Codex può verificare entrambi e scegliere quello funzionante.

Python non sostituisce PowerShell o 64tass: è uno strumento complementare. Il builder rimane lo script ufficiale per generare l’Assembly e il PRG.

### Git

Git non è obbligatorio per compilare, ma è fortemente raccomandato quando si lavora su più revisioni della stessa demo o quando si modifica il builder.

Verifica:

```powershell
git --version
```

Se Git non è installato, si può comunque procedere usando copie di directory e hash SHA-256. Git rende però più semplice capire esattamente quali file sono stati modificati e impedisce che un cambiamento accidentale passi inosservato.

## 4. Lasciare che Codex prepari l’ambiente

È possibile affidare a Codex quasi tutta la preparazione tecnica, evitando di cercare manualmente ogni programma e ogni percorso.

Codex può:

- verificare quali strumenti sono già installati;
- individuare gli strumenti mancanti;
- controllare le versioni disponibili;
- scaricare i programmi dalle fonti ufficiali;
- installarli tramite `winget` o un altro package manager;
- predisporre versioni portabili;
- configurare variabili d’ambiente temporanee o permanenti;
- controllare il `PATH`;
- verificare che gli eseguibili partano;
- leggere il builder per capire come individua 64tass;
- compilare un esempio incluso nel pacchetto;
- avviare il PRG in VICE;
- riportare percorsi, versioni ed esito dei test.

A seconda delle impostazioni di sicurezza del computer e dell’ambiente di Codex, alcune operazioni possono richiedere un’autorizzazione esplicita. Codex potrà procedere direttamente oppure chiedere il permesso per:

- accedere a Internet;
- scaricare file;
- avviare installer;
- usare `winget`;
- modificare il `PATH`;
- scrivere fuori dal workspace assegnato;
- eseguire operazioni amministrative;
- avviare VICE o altri programmi esterni.

Le capacità concrete dipendono dalla superficie Codex utilizzata, dal workspace
attivo, dal sandbox e dalla policy di approvazione. Nelle configurazioni locali
predefinite l’accesso in scrittura è normalmente limitato al workspace e la rete è
disabilitata finché non viene concessa o configurata. Il riferimento aggiornato è la
[documentazione ufficiale su sandbox e autorizzazioni](https://learn.chatgpt.com/docs/agent-approvals-security.md).

Una richiesta completa può essere formulata così:

```text
Prepara questo computer per sviluppare demo con 3Dvibe64.

La release dell’engine è disponibile qui:

C:\3Dvibe64\engine-ufficiale

Controlla se sono disponibili:

- PowerShell;
- Python 3;
- Git;
- 64tass;
- VICE con x64sc e, soltanto per la prova supplementare non contrattuale, xscpu64.

Se manca qualcosa, scaricalo esclusivamente dalle fonti ufficiali
e installalo oppure predisponi una versione portabile.

Chiedimi l’autorizzazione quando il sistema la richiede per
download, installazioni, modifiche delle variabili d’ambiente
o avvio di programmi esterni.

Non modificare la release ufficiale. Crea una copia di lavoro
separata e compila un esempio ufficiale per verificare l’ambiente.
```

Questo prompt stabilisce quattro vincoli utili: l’uso di fonti ufficiali, la richiesta di autorizzazione quando necessaria, la protezione della baseline e l’obbligo di eseguire una prova reale.

Al termine della preparazione è preferibile chiedere a Codex un rapporto che includa:

- versione di Python;
- versione di Git;
- versione di 64tass;
- versione di VICE;
- percorso di ogni eseguibile;
- percorso della copia ufficiale;
- percorso della copia di lavoro;
- comando di compilazione eseguito;
- percorso del PRG di prova;
- esito della compilazione;
- esito della prova in VICE;
- eventuali autorizzazioni o configurazioni ancora necessarie.

Un semplice messaggio come “tutto installato” non è sufficiente: i percorsi e le versioni rendono il risultato verificabile e permettono di ripetere la build in seguito.

## 5. Organizzazione delle directory

Una struttura ordinata evita di perdere versioni funzionanti e rende più semplice confrontare gli esperimenti.

Esempio:

```text
C:\3Dvibe64\
    engine-ufficiale\
    engine-demo-dev1\
    engine-demo-dev2\
    demo-output\
    modelli\
```

Le directory hanno funzioni diverse:

- `engine-ufficiale` contiene la baseline e non deve essere modificata;
- `engine-demo-dev1` contiene la prima copia di sviluppo;
- `engine-demo-dev2` può contenere una variante successiva;
- `demo-output` raccoglie risultati e diagnostica senza sporcare la copia dell’engine;
- `modelli` conserva i file OBJ e gli altri asset sorgente.

La release ufficiale deve rimanere intatta. Non va usata come cartella di esperimento, perché una modifica accidentale renderebbe difficile distinguere ciò che appartiene al pacchetto originale da ciò che è stato creato durante lo sviluppo.

Per creare una copia completa in PowerShell:

```powershell
Copy-Item `
  -LiteralPath "C:\3Dvibe64\engine-ufficiale" `
  -Destination "C:\3Dvibe64\engine-demo-dev1" `
  -Recurse
```

`-LiteralPath` impedisce che caratteri speciali nel percorso vengano interpretati come wildcard. `-Recurse` copia tutte le sottodirectory.

Gli output diagnostici dovrebbero essere conservati fuori dalla copia dell’engine:

```text
C:\3Dvibe64\demo-output\
```

Qui si possono salvare:

- JSON sperimentali;
- PRG;
- ASM diagnostici;
- screenshot;
- log;
- trace;
- hash;
- rapporti tecnici;
- confronti tra build;
- eventuali copie dei comandi di compilazione.

Separare gli output ha due vantaggi. Il primo è che la directory dell’engine rimane leggibile. Il secondo è che diventa più facile eliminare i temporanei senza cancellare file necessari alla build.

## 6. Come funziona la compilazione

La sorgente principale di una demo è il file JSON. Il JSON descrive la scena, mentre il builder genera automaticamente il codice adatto alla configurazione selezionata.

Il processo completo è:

```text
scena.json
    ↓
build-3Dvibe64.ps1
    ↓
3Dvibe64.asm
    ↓
64tass
    ↓
3Dvibe64.prg
```

In dettaglio:

1. `scena.json` contiene oggetti, mesh, camera, luce, mondo e animazioni;
2. `build-3Dvibe64.ps1` legge il JSON e i parametri della riga di comando;
3. il builder genera `3Dvibe64.asm`, includendo soltanto le funzioni necessarie alla build;
4. 64tass assembla il sorgente generato;
5. il risultato finale è `3Dvibe64.prg`.

I file generati si trovano normalmente in:

```text
work\3Dvibe64.asm
work\3Dvibe64.prg
```

Il file ASM è un prodotto intermedio. Non dovrebbe essere modificato manualmente per creare una demo canonica, perché una nuova esecuzione del builder lo rigenererà e cancellerà le modifiche.

Se una funzione necessaria manca nell’engine, il percorso corretto è:

1. individuare con precisione il limite;
2. dimostrare che il comportamento non è ottenibile con il JSON e le opzioni già disponibili;
3. modificare il builder in una copia di sviluppo;
4. aggiungere un’opzione JSON o compile-time generale, evitando condizioni legate a una singola scena;
5. verificare che gli esempi precedenti continuino a funzionare;
6. ricostruire il PRG dal JSON;
7. documentare la nuova opzione e il comando usato.

Una patch applicata direttamente all’ASM può essere utile per una prova rapida o per confermare un’ipotesi tecnica. Non dovrebbe però diventare la sorgente definitiva della demo. Il risultato finale deve poter essere rigenerato senza interventi manuali successivi al builder.

## 7. Le modalità grafiche

3Dvibe64 dispone di cinque modalità grafiche. Non sono semplici livelli di qualità crescente: ciascuna utilizza una pipeline specializzata e risponde a esigenze differenti. La scelta della modalità incide sul tipo di immagine, sulla quantità di calcoli, sulla memoria necessaria e sulle funzioni disponibili.

Prima di compilare conviene decidere quale risultato è davvero necessario. Usare una modalità più complessa del necessario può ridurre la velocità o il margine di memoria senza produrre un vantaggio visibile nella scena.

### GraphicsMode 1

GraphicsMode 1 è il wireframe essenziale. Disegna principalmente gli spigoli delle mesh e riduce al minimo il lavoro richiesto per riempimento e illuminazione.

È indicata per:

- ottenere la massima leggerezza;
- visualizzare mesh semplici;
- mostrare chiaramente la struttura geometrica;
- realizzare demo tecniche;
- controllare rapidamente l’orientamento e la forma di un modello;
- verificare se una mesh viene trasformata e proiettata correttamente prima di passare a una modalità solida.

In questa modalità le superfici non vengono riempite. Per questo può essere difficile capire quali linee appartengano alla parte anteriore o posteriore di un oggetto complesso. Il vantaggio è il costo più contenuto.

Quando viene usato il profilo multimateriale supportato dall’engine, le modalità wire possono distinguere due famiglie cromatiche. Tale configurazione deve però rispettare il contratto effettivo del builder e va ricavata dagli esempi ufficiali, non improvvisata.

### GraphicsMode 2

GraphicsMode 2 è il percorso hidden-wire. Mantiene l’aspetto a linee, ma gestisce in modo più avanzato le superfici, il culling, il mascheramento delle linee nascoste, i materiali e l’ordine di profondità.

È utile quando si desidera:

- conservare uno stile wireframe;
- ridurre le linee che dovrebbero trovarsi dietro le superfici visibili;
- mostrare meglio la forma di oggetti sovrapposti;
- usare il clipping geometrico del Ground plane pur mantenendo una rappresentazione a linee.

Il Ground resta line-only: non viene riempito come nelle modalità solide. Anche quando il profilo geometrico `plane` classifica e taglia le facce rispetto al terreno, la rappresentazione del Ground rimane una linea d’orizzonte, non un semipiano colorato.

### GraphicsMode 3

GraphicsMode 3 usa un rendering solido specializzato e veloce. Le facce vengono riempite, ma lo shading è statico e viene calcolato dal builder.

Caratteristiche principali:

- shading statico calcolato prima dell’esecuzione;
- colori e pattern assegnati alle facce;
- rasterizzatore dedicato;
- fast path specifici;
- minore costo rispetto allo shading dinamico;
- assenza della trasformazione dinamica della luce necessaria alle modalità successive.

È adatta quando il colore delle facce non deve cambiare continuamente in risposta alla luce. Per esempio, può essere una buona scelta per un oggetto che ruota ma usa un’ombreggiatura artistica predefinita, oppure per una scena nella quale la priorità è aumentare la velocità mantenendo superfici piene.

La Mode 3 possiede alcuni percorsi propri, compreso il culling dedicato. Non bisogna quindi supporre che ogni opzione disponibile per Mode 4 e Mode 5 si applichi automaticamente anche a questa modalità.

### GraphicsMode 4

GraphicsMode 4 è la modalità solida con shading dinamico.

Caratteristiche:

- trasformazione delle normali;
- luce dinamica;
- riempimento dei poligoni;
- materiali satin, gloss, reflective e mirror secondo le tabelle effettivamente supportate;
- supporto alle funzioni avanzate di istanza;
- gestione delle mesh condivise quando richiesta nel JSON;
- pipeline subpixel XY-Q2 attivata automaticamente dal profilo ufficiale.

È indicata quando l’illuminazione deve reagire alla rotazione degli oggetti o al movimento della luce. È anche la modalità di riferimento per scene nelle quali la variazione dei materiali è una parte importante dell’effetto visivo.

Il costo è maggiore rispetto alla Mode 3, perché normali, luce e shading devono essere aggiornati durante l’esecuzione. Prima di usarla su una mesh molto pesante conviene controllare memoria, viewport e numero di facce simultaneamente visibili.

### GraphicsMode 5

GraphicsMode 5 eredita la pipeline della Mode 4 e aggiunge un outline di un pixel low-resolution.

Caratteristiche:

- riempimento con shading dinamico;
- materiali e illuminazione della Mode 4;
- contorno aggiunto dopo il fill;
- outline calcolato sul poligono finale dopo il clipping;
- contorno applicato secondo il painter order esistente;
- uso del colore di sfondo del mondo per il bordo.

Il fatto che il contorno venga calcolato sul poligono finale è importante. Se una faccia viene tagliata dal near plane o dai limiti dello schermo, l’outline segue la nuova forma risultante e non la geometria originale fuori campo. Le facce eliminate non devono lasciare contorni residui.

Mode 5 è adatta a uno stile più grafico, leggibile o vicino all’illustrazione. L’outline ha però un costo misurabile, perché viene disegnato faccia per faccia dopo il riempimento. In una scena già vicina ai limiti di tempo o memoria, la Mode 4 può essere preferibile.

### Come scegliere rapidamente

Come regola pratica:

- scegliere Mode 1 per un wireframe essenziale e molto leggero;
- scegliere Mode 2 per hidden-wire e linee nascoste più controllate;
- scegliere Mode 3 per superfici solide con shading statico e costo più contenuto;
- scegliere Mode 4 per illuminazione e materiali dinamici;
- scegliere Mode 5 quando serve anche un contorno sul risultato della Mode 4.

Questa è soltanto una guida iniziale. La scelta definitiva va sempre verificata sulla mesh e sulla scena reali.

## 8. Camera

La camera determina da quale punto viene osservata la scena e come vengono trasformati gli oggetti nello spazio di vista. I tre profili principali sono:

```text
fixed
walkLite
walkFull
```

I nomi non indicano soltanto quanti controlli sono disponibili. Ogni profilo può comportare differenze nel codice generato, nella memoria utilizzata e nella precisione della trasformazione.

### fixed

La camera `fixed` rimane ferma durante l’esecuzione, salvo eventuali animazioni esplicitamente gestite dalla scena o da funzioni dedicate.

È indicata per:

- oggetti rotanti davanti a un punto di vista stabile;
- animazioni automatiche;
- benchmark;
- presentazioni di una mesh;
- scene controllate interamente dalla timeline;
- build nelle quali si vuole ridurre codice e memoria.

Il percorso `fixed` è specializzato e leggero. In genere consuma meno risorse e si adatta più facilmente al layout di memoria `stable`. La proiezione è però più compatta e quantizzata rispetto alle camere mobili; in scene molto vicine, complesse o geometricamente delicate può offrire una qualità inferiore.

Una camera fixed non dispone dei normali controlli runtime di traslazione. Gli oggetti e la luce possono comunque continuare a ruotare o animarsi.

### walkLite

La camera `walkLite` è una camera mobile semplificata.

È utile quando servono:

- avanzamento e arretramento;
- movimento laterale o strafe;
- movimento verticale;
- yaw;
- pitch;
- una trasformazione mobile più precisa;

ma non è necessario il roll.

La camera parte dalla posa definita nella scena e rimane ferma finché l’utente non invia un comando. Il fatto che la camera sia ferma non blocca le altre animazioni: rotazione degli oggetti, luce orbitale e timeline possono continuare ad avanzare.

Il profilo `walkLite` usa la trasformazione Mobile Y-Q2. Se si desidera che le facce vengano tagliate realmente durante l’attraversamento del piano camera, va selezionato il profilo near `clip`.

### walkFull

La camera `walkFull` aggiunge il roll alle funzioni di `walkLite` e rappresenta il profilo di navigazione più completo.

In base ai controlli compilati può comprendere:

- `W` / `S`: avanti e indietro;
- `A` / `D`: strafe a sinistra e a destra;
- `Q` / `E`: movimento verticale;
- cursori: yaw e pitch;
- `N` / `M`: roll.

Il roll modifica l’orientamento degli assi laterale e verticale. Per questo, durante una camera inclinata, strafe e movimento verticale possono contribuire a più assi del mondo.

`walkFull` richiede più codice e più dati runtime rispetto a `walkLite`. Con mesh complesse, Ground geometrico, clipping e molte funzioni attive può essere necessario il layout `high-basic-v2`.

I controlli non necessari possono essere rimossi compile-time. Per esempio, `-NoCameraRuntimeControls` permette di compilare una camera mobile senza l’infrastruttura di input runtime, mentre `-StaticPose` impedisce gli aggiornamenti automatici della posa della mesh. Eliminare funzioni inutili può ridurre codice e costo.

### Nota sul movimento della camera

Le camere mobili avanzano secondo i tick della simulazione, non secondo il numero di frame effettivamente renderizzati. Questo evita che il movimento narrativo cambi quando la scena diventa più pesante o viene eseguita su una CPU accelerata.

Il movimento diagonale è additivo e non viene normalizzato. Premere due direzioni ortogonali produce quindi uno spostamento complessivo maggiore rispetto a una sola direzione. Le coppie opposte, come `W` e `S`, si neutralizzano.

## 9. Viewport e memoria

### Viewport

La viewport è l’area nella quale viene renderizzata la scena 3D. Una viewport più grande offre un’immagine più leggibile, ma richiede di elaborare più pixel. Una viewport più piccola riduce il lavoro del rasterizzatore e può liberare margine per scene più complesse.

Da riga di comando:

```text
-CameraViewport normal
-CameraViewport small
```

Nel JSON o nel contratto della scena il campo può essere indicato come `viewportProfile`. Quando viene fornito esplicitamente un valore dalla riga di comando, il builder deve applicare la precedenza prevista dal proprio contratto; per questo Codex deve controllare gli esempi e lo script prima della build.

#### normal

`normal` è la viewport predefinita. Con lo split Generic Text/FPS compilato offre un body 3D 160×88 a Y=12; `-NoFpsOverlay` ripristina il body storico 160×100.

È la scelta più leggibile e normalmente il punto di partenza. Va usata quando la scena entra nei limiti di memoria e mantiene una velocità adeguata.

#### small

`small` misura 128×80 pixel low-resolution. Con lo split testuale parte da Y=12; senza split è centrata a Y=10.

Comporta:

- meno pixel da elaborare;
- maggiore velocità potenziale;
- più margine per scene complesse;
- minore area visiva;
- oggetti apparentemente più piccoli sullo schermo a parità di composizione.

È una delle prime opzioni da provare quando il rendering è troppo pesante, purché la riduzione della superficie visibile sia accettabile.

L’area esterna alla viewport e la cornice VIC-II devono rimanere nere secondo il comportamento previsto dall’engine.

### Memory layout

Sono disponibili due layout principali:

```text
-MemoryLayout stable
-MemoryLayout high-basic-v2
```

Il layout stabilisce dove vengono collocati codice, dati e buffer nella memoria del C64. Non è un’opzione puramente estetica: una scena può compilare con un layout e superare una finestra di memoria con l’altro.

#### stable

`stable` è il layout standard, compatto e preferenziale.

È adatto a:

- scene leggere o medie;
- camera fixed;
- mesh non troppo grandi;
- numero contenuto di istanze;
- configurazioni prive di Ground geometrico pesante;
- build nelle quali non vengono attivate troppe funzioni simultanee.

Il builder deve interrompere la compilazione quando codice o dati invadono bitmap, screen buffer o altre aree riservate. Il passaggio a un altro layout non dovrebbe avvenire in silenzio.

#### high-basic-v2

`high-basic-v2` è il layout segmentato per le build più pesanti. Utilizza anche la RAM sotto la BASIC ROM e può produrre PRG fisicamente più grandi a causa dei vuoti tra i segmenti.

È indicato per:

- scene grandi;
- mesh complesse;
- molte istanze;
- camera mobile, soprattutto `walkFull`;
- Ground plane;
- clipping articolato;
- timeline complesse;
- modalità solide con numerosi dati runtime.

Il limite teorico di 255 elementi non significa che ogni scena possa contenere realmente 255 oggetti, facce o descrittori. Molti indici sono a un byte, ma i limiti pratici vengono raggiunti spesso prima a causa delle finestre di memoria, dei buffer runtime e del codice necessario alle funzioni attive.

Quando una build non entra in `stable`, il builder può suggerire `high-basic-v2`, ma il passaggio deve essere richiesto esplicitamente. Non bisogna interpretare il layout più grande come una soluzione automatica a qualsiasi problema: se anche quello viene superato, sarà necessario semplificare la scena.

## 10. Unità dell’engine

Per descrivere correttamente posizioni, angoli e tempi è necessario distinguere tre unità: WU, TU e ST.

### WU — World Unit

WU significa **World Unit**. È l’unità lineare astratta usata per:

- posizione;
- dimensioni;
- distanza;
- velocità lineare;
- quota del Ground;
- coordinate della camera e degli oggetti, secondo i campi supportati.

Una WU non equivale automaticamente a un metro, un centimetro o un’altra misura reale. La scala fisica viene decisa dall’autore della scena. Per esempio, si può stabilire che un cubo largo 56 WU rappresenti una piccola astronave oppure un edificio: l’engine non impone una corrispondenza reale.

Dove viene usato un accumulatore fixed-point, una WU contiene 256 sotto-unità posizionali. Questo permette a movimenti inferiori a una WU per tick di accumularsi in modo fluido, anche se la geometria visibile viene poi elaborata attraverso coordinate quantizzate.

### TU — Turn Unit

TU significa **Turn Unit** ed è l’unità angolare.

Un giro completo contiene 256 TU:

```text
256 TU = 360 gradi
1 TU = 1,40625 gradi
64 TU = 90 gradi
128 TU = 180 gradi
```

Gli angoli si avvolgono naturalmente nel ciclo 0-255. Questo sistema è adatto alle tabelle trigonometriche a 256 elementi usate dal renderer.

Quando si indica una rotazione o una velocità angolare nel JSON, bisogna verificare se il campo usa TU assolute oppure TU per tick. Non va inserito un valore in gradi pensando che il builder lo interpreti automaticamente come tale.

### ST — Simulation Tick

ST significa **Simulation Tick**. È il passo normalizzato con il quale avanzano:

- movimento degli oggetti;
- rotazione degli oggetti;
- controlli della camera;
- fasi della luce;
- timeline;
- depth ping-pong;
- altri automatismi collegati alla simulazione.

Le timeline lavorano a 50 tick logici al secondo:

```text
50 ST = 1 secondo
100 ST = 2 secondi
150 ST = 3 secondi
3000 ST = 1 minuto
```

Il tick normalizzato permette di mantenere la stessa durata degli eventi su PAL e NTSC. In PAL viene normalmente prodotto un ST per VBlank. In NTSC l’engine usa cinque tick ogni sei VBlank, così da ottenere nominalmente 50 ST al secondo anche con un refresh video differente.

Questo significa che una sequenza di 150 ST deve durare circa tre secondi sia su PAL sia su NTSC. Il numero di frame realmente renderizzati può cambiare se la scena è pesante, ma il tempo logico della simulazione non dovrebbe cambiare.

## 11. Near plane e avvicinamento alle superfici

Il near plane definisce come vengono trattate le facce quando si avvicinano molto alla camera o attraversano il piano della camera.

L’opzione pubblica è:

```text
-Mode4NearProfile default|late|clip
```

Il nome contiene `Mode4` per ragioni storiche, ma il profilo si applica alle GraphicsMode 3, 4 e 5.

La scelta influenza due aspetti distinti:

- a quale profondità una faccia viene accettata;
- se una faccia che attraversa il piano camera viene eliminata interamente oppure tagliata geometricamente.

### default

Il profilo `default` usa il comportamento conservativo:

- reject sotto 8 WU;
- divisore prospettico minimo 8;
- eliminazione delle facce troppo vicine secondo il percorso tradizionale;
- nessun avvicinamento estremo alla superficie.

È la scelta più prudente e compatibile. Va usata quando non è necessario portare la camera quasi a contatto con gli oggetti.

### late

Il profilo `late` ritarda il rigetto:

- visibilità fino a 1 WU;
- divisore prospettico minimo 2;
- reject a profondità zero o negativa;
- uso del divisore geometrico da 2 WU in poi;
- breve plateau prospettico tra 1 e 2 WU;
- nessun clipping poligonale contro il piano camera.

Una faccia che attraversa il piano camera può essere scartata integralmente. Questo profilo permette quindi di avvicinarsi molto di più rispetto a `default`, ma non conserva soltanto la parte ancora davanti alla camera.

`late` non modifica il backface culling e non rende le mesh two-sided.

### clip

Il profilo `clip` esegue il clipping reale contro il piano camera.

Caratteristiche:

- conserva la parte proiettabile della faccia;
- permette l’avvicinamento fino all’attraversamento;
- genera intersezioni proiettabili in prossimità del piano camera;
- usa un divisore prospettico minimo 2;
- rigetta la faccia soltanto dopo il reale attraversamento;
- funziona con camera `fixed`, `walkLite` e `walkFull`.

Se è attivo anche il Ground geometrico, il clipping rispetto al Ground viene eseguito prima del clipping contro il piano camera. Il culling camera-space continua a riferirsi al poligono originale, mentre rasterizzazione e outline Mode 5 usano il poligono finale post-clipping.

Questo è il profilo più adatto quando la camera deve arrivare realmente a contatto con una parete o attraversare una superficie senza che l’intera faccia sparisca in anticipo.

### Che cosa i profili near non fanno

Nessuno dei tre profili rende automaticamente le mesh visibili da entrambi i lati.

Dentro una mesh chiusa continuano a valere:

- winding;
- backface culling;
- comportamento monofacciale;
- orientamento delle normali e delle facce.

Perciò una camera che entra dentro un oggetto chiuso può vedere molte facce scomparire correttamente. Questo non indica necessariamente un errore del near plane.

Le opzioni diagnostiche legacy relative al clipping esplorativo non devono essere combinate casualmente con i profili `late` e `clip`. Codex deve attenersi al contratto pubblico del builder e agli esempi inclusi nella release.

## 12. Backface culling

Il backface culling elimina le facce rivolte dalla parte opposta rispetto alla camera. È una funzione fondamentale per ridurre il lavoro del renderer e per rappresentare correttamente oggetti chiusi e monofacciali.

Per Mode 4 e Mode 5 sono disponibili:

```text
-FaceCullProfile default
-FaceCullProfile stable
```

### default

`default` usa il percorso tradizionale di culling. È adatto alla maggior parte delle scene e mantiene il comportamento standard dell’engine.

Il test tradizionale si basa sul risultato proiettato. In pose quasi edge-on, coordinate molto vicine e quantizzate possono talvolta far cambiare il segno dell’area da un frame all’altro.

### stable

`stable` è consigliato per oggetti che eseguono:

- roll;
- yaw;
- pitch;
- rotazioni combinate;
- pose quasi edge-on;
- passaggi nei quali una faccia si presenta quasi di taglio.

Il profilo utilizza dati camera-space nella banda più delicata per ridurre le variazioni provocate dall’arrotondamento delle coordinate proiettate. Fuori dalla zona quasi edge-on può continuare a usare il test screen-space previsto dal percorso ottimizzato.

Le facce esattamente edge-on vengono conservate secondo il contratto dell’engine. Non viene introdotto uno stato tra frame e non viene applicata un’isteresi temporale.

`stable` non abilita il rendering two-sided. Una faccia rivolta realmente dalla parte opposta continua a essere eliminata.

La Mode 3 conserva il proprio percorso dedicato e non utilizza automaticamente `stable`. Se Codex riceve una richiesta di culling stabile in una modalità non supportata, deve controllare il builder e segnalare il limite invece di fingere che l’opzione sia stata applicata.

## 13. Ground

Il Ground rappresenta il terreno o l’orizzonte della scena. Sono disponibili due concetti distinti: `simple` e `plane`.

### Ground simple

`simple` è la soluzione più leggera. È adatta quando basta un riferimento visivo del terreno e non serve che le mesh vengano tagliate geometricamente rispetto a un piano del mondo.

A seconda della modalità grafica, può produrre una linea d’orizzonte decorativa oppure il comportamento screen-space tradizionale. Il vantaggio principale è il costo inferiore in byte e cicli.

È una buona scelta per:

- scene aperte nelle quali nessun oggetto attraversa il terreno;
- demo nelle quali il Ground serve soltanto come sfondo;
- build vicine ai limiti di memoria;
- prove rapide della camera e della composizione.

### Ground plane

`plane` definisce un vero piano geometrico con clipping. La quota è espressa in WU attraverso `ground.z` nella convenzione pubblica `world-z-up`; il piano è quindi:

```text
world Z = ground.z
```

Il comportamento dipende dalla modalità:

- Mode 1: rimane disponibile la linea d’orizzonte decorativa, senza occlusione geometrica e senza fill;
- Mode 2: il Ground resta line-only, ma `plane` classifica le facce rispetto al piano, elimina quelle interamente dal lato opposto alla camera e taglia quelle che lo attraversano;
- Mode 3: il semipiano può essere riempito e la geometria viene classificata e clippata;
- Mode 4: il piano viene riempito e illuminato secondo il percorso dinamico;
- Mode 5: il piano viene riempito e il risultato può includere l’outline previsto dalla modalità.

In Mode 2 non viene mai riempito un semipiano. Hidden-wire ed edge utilizzano il poligono risultante dopo il clipping.

Il Ground plane può richiedere più memoria e più cicli rispetto a `simple`. Le scene che superano il layout `stable` devono selezionare esplicitamente `high-basic-v2`.

La linea d’orizzonte è sensibile al roll. Secondo la convenzione dell’engine:

```text
+32 TU  = orizzonte discendente verso destra
-32 TU  = orizzonte ascendente verso destra
+64 TU  = orizzonte verticale
```

Se la linea è interamente fuori dalla viewport, non deve essere forzata su un bordo. Il risultato corretto è che non venga disegnata.

La quota della camera determina quale lato del piano è visibile. Il lato geometrico conservato cambia quando la camera attraversa il piano, non semplicemente quando la sua altezza viene modificata senza attraversarlo.

## 14. Struttura elementare di un JSON

Il JSON è il documento che descrive la scena. Deve essere leggibile sia dal builder sia da chi dovrà modificare la demo in futuro.

La struttura esatta può cambiare tra release. Prima di creare o modificare una scena, Codex deve leggere:

- il README principale;
- la documentazione italiana o inglese inclusa nel pacchetto;
- gli esempi ufficiali;
- il builder;
- lo schema eventualmente presente;
- i test contrattuali, quando aiutano a chiarire campi e limiti.

Non bisogna quindi prendere un esempio generico trovato online e supporre che tutti i campi siano validi. L’autorità finale è il builder contenuto nella release sulla quale si sta lavorando.

Una scena elementare comprende normalmente:

- un identificatore di schema;
- un nome;
- la modalità grafica;
- la convenzione degli assi;
- una camera;
- una o più mesh;
- uno o più oggetti che istanziano le mesh;
- una o più luci;
- il mondo, compreso il colore di sfondo;
- un eventuale contratto della scena;
- un’eventuale timeline.

Un esempio didattico, vicino alla struttura usata dagli esempi dell’engine, può apparire così:

```json
{
  "schema": 1,
  "name": "mia-demo",
  "graphicsMode": 4,
  "axisConvention": "world-z-up",

  "camera": {
    "id": "camera-main",
    "mode": "fixed",
    "position": [0, -63, 20],
    "rotation": [0, 0, 0]
  },

  "meshes": [
    {
      "id": "mesh-main",
      "type": "mesh",
      "geometry": "solid",
      "materialProfile": "single",
      "builtin": "cube"
    }
  ],

  "objects": [
    {
      "id": "object-main",
      "mesh": "mesh-main",
      "position": [0, 80, 0],
      "rotation": [0, 0, 0],
      "scale": 1,
      "visible": true,
      "material": "gray",
      "reflectivity": "satin"
    }
  ],

  "lights": [
    {
      "id": "light-main",
      "type": "static",
      "position": [-52, 12, 58],
      "intensity": 10
    }
  ],

  "world": {
    "backgroundColor": 0,
    "grounds": []
  },

  "contract": {
    "version": 1,
    "worldSpace": "world-z-up",
    "objectSpace": "aligned-world",
    "viewportProfile": "normal",
    "ground": false
  }
}
```

Questo esempio serve a comprendere l’organizzazione dei dati. Non deve essere copiato senza controllare gli esempi della release: campi, valori richiesti e combinazioni ammesse devono essere confermati dal builder.

L’uso di `"builtin": "cube"` rende la mesh dell’esempio completa e compilabile
senza lasciare array geometrici vuoti. Quando si usa geometria esplicita, `vertices`
e `faces` devono contenere dati validi; il builder rifiuta una mesh poligonale senza
facce.

In una descrizione puramente concettuale si può incontrare anche un’etichetta testuale come:

```json
"schema": "3dvibe64-scene"
```

Non bisogna però presumere che tale forma sia accettata dalla build effettiva. Negli esempi allegati all’engine lo schema è rappresentato numericamente. Codex deve usare il valore richiesto dal pacchetto reale.

### Convenzione degli assi

La convenzione pubblica è:

```text
world-z-up
```

Significa che:

- `+X` è verso destra e `-X` verso sinistra;
- `+Y` è in avanti, cioè verso il fondo del mondo, e `-Y` all’indietro;
- `+Z` è verso l’alto e `-Z` verso il basso.

Z rappresenta quindi normalmente la quota verticale. Questo vale per i vettori di scena, come posizione e velocità degli oggetti, posizione e rotazione della camera e posizione di una luce statica.

Internamente l’engine usa una diversa disposizione degli assi e converte i vettori di scena. Le coordinate locali grezze delle mesh, tuttavia, devono essere controllate attentamente durante l’importazione: l’importatore deve consegnarle nell’orientamento realmente atteso dal renderer. Per questo il semplice inserimento di `axisConvention: "world-z-up"` non sostituisce la verifica visiva e geometrica della mesh.

### Mesh e oggetti non sono la stessa cosa

La sezione `meshes` descrive la geometria sorgente. La sezione `objects` descrive le istanze collocate nel mondo.

Una mesh può contenere:

- vertici;
- facce;
- geometria built-in;
- profilo materiale;
- eventuali override locali delle facce.

Un oggetto può invece contenere:

- riferimento alla mesh;
- posizione;
- rotazione;
- scala;
- visibilità;
- materiale;
- riflettività;
- velocità;
- override di istanza.

Separare i due concetti permette di usare la stessa geometria in più punti della scena, soprattutto quando viene attivato il percorso di condivisione delle sorgenti.

## 15. Importare una mesh

Una mesh può essere fornita a Codex, per esempio, come file OBJ:

```text
C:\3Dvibe64\modelli\oggetto.obj
```

L’importazione non dovrebbe consistere in una semplice copia delle coordinate. Prima della compilazione vanno controllati geometria, limiti numerici e convenzione degli assi.

Una richiesta consigliata è:

```text
Importa questa mesh nella demo:

C:\3Dvibe64\modelli\oggetto.obj

Prima della compilazione verifica:

- numero di vertici;
- numero di facce;
- presenza di facce non triangolari;
- winding;
- normali;
- facce duplicate;
- vertici inutilizzati;
- scala;
- orientamento world-z-up;
- compatibilità con i limiti dell’engine.

Non semplificare o modificare la mesh senza segnalarmelo.
Crea una vista diagnostica e compila un PRG di prova.
```

Ogni controllo ha uno scopo preciso.

#### Numero di vertici e facce

Il numero influisce sia sul tempo di trasformazione e rasterizzazione sia sulla memoria. Gli indici a un byte impongono limiti teorici, ma il limite pratico può essere molto più basso.

#### Facce non triangolari

L’engine può usare triangoli e quad nei percorsi supportati, ma un OBJ può contenere anche poligoni con un numero maggiore di vertici o facce concave. Codex deve determinare se vadano triangolati e segnalare qualsiasi trasformazione.

#### Winding

Il winding è l’ordine dei vertici di una faccia. Stabilisce quale lato viene considerato anteriore. Un winding invertito può far sparire una faccia a causa del backface culling.

#### Normali

Le normali sono essenziali soprattutto per lo shading dinamico. Se sono incoerenti, il colore può reagire alla luce in modo opposto o discontinuo.

#### Facce duplicate e vertici inutilizzati

Le facce duplicate consumano memoria e possono creare sovrascritture o artefatti. I vertici inutilizzati non producono geometria visibile ma occupano spazio e complicano l’analisi.

#### Scala e intervalli locali

Le coordinate locali della mesh vengono convertite e quantizzate. Nella configurazione documentata dall’engine, i componenti locali devono rientrare nell’intervallo accettato dal builder e la scala viene convertita in Q6. Una scala nominale di `1.0` corrisponde a `64/64`; il massimo rappresentabile documentato è `127/64`, cioè `1.984375`.

Non conviene affidarsi a una scala enorme per compensare un modello troppo piccolo o viceversa. È preferibile normalizzare consapevolmente la mesh e verificare che le coordinate locali rientrino nel dominio accettato.

#### Orientamento

Una mesh proveniente da Blender o da un altro programma può usare una diversa convenzione per l’asse verticale e l’asse forward. Codex deve controllarla con una vista diagnostica, non limitarsi a cambiare l’etichetta `axisConvention`.

Se la mesh è troppo pesante, Codex può preparare una variante low-poly. Devono però essere conservati:

- il modello originale;
- la variante derivata;
- un rapporto delle modifiche;
- il numero di vertici e facce prima e dopo;
- l’indicazione di eventuali triangolazioni o rimozioni.

Nessuna semplificazione deve essere applicata in silenzio.

## 16. Materiali, colori e pattern

L’engine utilizza colori, rampe e pattern compatibili con il VIC-II. Non tutti i nomi o le combinazioni inventabili dall’utente esistono realmente nelle tabelle del builder.

Per evitare configurazioni incompatibili, bisogna chiedere a Codex di usare esclusivamente le famiglie effettivamente presenti.

Esempio:

```text
Usa soltanto i colori e i pattern della famiglia gray già
supportata dall’engine.

Assegna alle facce una combinazione leggibile di:

- colori solidi;
- pattern a scacchi;
- livelli satin;
- livelli reflective.

Non introdurre pigmenti o pattern non presenti nelle tabelle
ufficiali.
```

Le famiglie materiale documentate comprendono:

```text
gray
white
red
green
blue
yellow
cyan
magenta
orange
brown
```

Possono essere selezionate per nome oppure, nei campi che lo consentono, attraverso l’indice corrispondente. Le riflettività documentate sono:

```text
satin
gloss
reflective
mirror
```

Il risultato visivo non dipende soltanto dal nome. Ogni famiglia possiede rampe specifiche e il builder deve produrre i valori VIC-II previsti dal materiale.

### Colore VIC-II esplicito su una faccia

Le facce possono avere un colore esplicito attraverso `faceOverrides`:

```json
{
  "faceOverrides": {
    "0": {
      "solidColor": 7,
      "shading": false
    }
  }
}
```

`solidColor` usa valori VIC-II da 0 a 15.

Con:

```json
"shading": false
```

la faccia mantiene il colore assegnato e non viene modificata dalla luce dinamica. Questa opzione è utile per elementi che devono rimanere graficamente stabili, come un pannello, una luce dipinta, un dettaglio o una zona decorativa.

Nel percorso con mesh condivisa, `faceOverrides` appartiene alla mesh sorgente e usa indici locali delle facce. Non deve essere inserito come mappa differente dentro ciascuna istanza.

### Precedenza degli override

Quando più livelli assegnano un materiale o un colore, la precedenza è:

1. override locale della faccia sorgente;
2. override dell’istanza;
3. materiale della mesh sorgente.

Questa regola permette di mantenere un materiale generale e cambiare soltanto ciò che serve.

### Wire multimateriale

Nelle modalità wire supportate, il profilo multimateriale può rappresentare esattamente due famiglie cromatiche mediante i due slot bitmap previsti. La scena deve mappare esplicitamente le facce e non deve affidarsi a un fallback silenzioso.

Questa funzione è distinta dai materiali solidi delle Mode 3-5. Codex deve usare gli esempi ufficiali dedicati quando prepara una scena wire a due colori.

## 17. Luce statica e luce orbitale

La luce può essere realmente statica oppure appartenere al percorso orbitale. La differenza non è soltanto visiva: determina quali tabelle, contatori e routine vengono inseriti nella build.

### Luce realmente statica

Per una luce compile-time realmente statica usare:

```json
{
  "type": "static",
  "position": [-52, 12, 58]
}
```

È possibile aggiungere i campi richiesti dal contratto, per esempio l’intensità:

```json
{
  "id": "light-main",
  "type": "static",
  "position": [-52, 12, 58],
  "intensity": 10
}
```

Questo percorso permette al builder di evitare:

- avanzamento della fase;
- copie inutili della posizione;
- aggiornamenti orbitali;
- tick della luce;
- tabelle duplicate;
- infrastruttura orbitale non utilizzata.

La luce rimane ferma nel mondo, ma lo shading può comunque cambiare quando l’oggetto ruota, perché cambiano le normali trasformate rispetto alla direzione luminosa.

Non va confusa con il vecchio percorso:

```json
{
  "mode": "static"
}
```

Quest’ultimo può mantenere parte della logica orbitale, compresi fase, divisore e tabelle. Se lo scopo è ottenere una luce realmente statica e più leggera, deve essere usato il campo `type` previsto dal percorso dedicato.

### Luce orbitale

La luce orbitale cambia posizione nel tempo ed è utile per mostrare:

- shading dinamico;
- satinatura;
- riflettività;
- variazioni della superficie durante la rotazione;
- differenze tra materiali;
- effetti di illuminazione ciclica.

Le principali opzioni CLI comprendono:

```text
-LightOrbit
-LightPhaseCount
-LightTickDiv
-LightStaticPhase
```

I profili orbitali documentati sono `flat` e `tumble3d`. Il numero di fasi può essere 8, 16 o 32. `LightTickDiv` stabilisce ogni quanti ST viene avanzata la fase. Il periodo completo è quindi determinato dal numero delle fasi moltiplicato per il divisore dei tick.

`LightStaticPhase` può congelare un campione del percorso orbitale legacy. Questo non equivale necessariamente alla luce realmente statica `type: "static"`, perché può conservare dati e codice del sistema orbitale.

La velocità della luce deve essere legata ai tick della simulazione o al timing del VIC-II, non al numero di iterazioni della CPU. In questo modo la durata dell’orbita rimane coerente su PAL, NTSC e CPU accelerate.

## 18. Istanze multiple

Nelle Mode 4 e 5 è possibile riutilizzare una stessa mesh senza emettere più volte la geometria sorgente.

L’opzione JSON è:

```json
{
  "meshSourceSharing": true
}
```

Una mesh viene dichiarata una volta nella sezione `meshes`. Più oggetti nella sezione `objects` possono poi riferirsi allo stesso identificatore.

Ogni istanza può avere:

- posizione;
- rotazione;
- scala;
- visibilità;
- materiale;
- riflettività;
- colore;
- velocità;
- stato nella timeline.

La geometria sorgente viene emessa una sola volta, mentre ogni istanza mantiene buffer runtime separati per:

- vertici trasformati;
- vertici proiettati;
- posa corrente;
- visibilità;
- partecipazione all’ordine globale di profondità.

Questo significa che due istanze possono trovarsi in posizioni e rotazioni differenti nello stesso frame. Non sono semplici copie grafiche post-render: entrambe partecipano alla pipeline 3D e al painter order globale.

L’opzione è valida soltanto nelle Mode 4 e 5. Se viene richiesta in Mode 1, 2 o 3, la build deve interrompersi. Inoltre deve esistere un riuso reale: almeno una mesh deve essere referenziata da più istanze. L’engine non deve ricadere silenziosamente nell’espansione tradizionale.

Esempio concettuale:

```json
{
  "objects": [
    {
      "id": "object-blue",
      "mesh": "ship",
      "position": [-20, 80, 0],
      "colorOverride": 6
    },
    {
      "id": "object-red",
      "mesh": "ship",
      "position": [20, 120, 10],
      "colorOverride": 2
    }
  ]
}
```

Ordine di precedenza degli override:

1. override della faccia;
2. override dell’istanza;
3. materiale della mesh.

Nel percorso shared:

- `faceOverrides` deve appartenere alla mesh sorgente;
- le chiavi sono indici locali delle facce;
- non sono ammesse mappe `faceOverrides` differenti per ciascuna istanza della stessa sorgente;
- `materialOverride`, `reflectivityOverride` e `colorOverride` possono invece essere applicati all’istanza.

La condivisione riduce la duplicazione della geometria sorgente, ma non elimina il costo dei buffer runtime di ogni istanza. Una scena con molte copie può quindi esaurire comunque la memoria. Gli indici a un byte impongono limiti teorici di 255 per varie categorie, ma i limiti pratici sono generalmente inferiori.

## 19. Timeline dichiarativa

La timeline permette di costruire una sequenza animata senza scrivere a mano uno scheduler Assembly. La scena viene suddivisa in stati deterministici; ogni stato può impostare o aggiornare le proprietà degli oggetti per un certo numero di tick.

Struttura concettuale:

```json
{
  "timeline": {
    "tickRate": 50,
    "resetKey": "SPACE",
    "initialState": "entry",

    "states": [
      {
        "id": "entry",
        "duration": 150,
        "next": "loop",

        "instances": {
          "object-main": {
            "visible": true,
            "positionVelocity": [0, -1, 0],
            "rotationVelocity": [0, 0, 1]
          }
        }
      },

      {
        "id": "loop",
        "duration": 500,
        "loop": true,

        "instances": {
          "object-main": {
            "position": [0, 40, 0],
            "rotation": [0, 0, 0]
          }
        }
      }
    ]
  }
}
```

### Significato dei campi principali

```text
tickRate
resetKey
initialState
states[].id
states[].duration
states[].next
states[].loop
states[].instances
visible
position
rotation
scale
positionVelocity
rotationVelocity
materialOverride
reflectivityOverride
colorOverride
```

- `tickRate` stabilisce il contratto temporale e deve essere 50;
- `resetKey` può assegnare a `SPACE` il ripristino della sequenza;
- `initialState` indica lo stato dal quale iniziare;
- `id` identifica in modo univoco ogni stato;
- `duration` esprime la durata in ST;
- `next` indica lo stato successivo;
- `loop` segnala il comportamento ciclico previsto;
- `instances` contiene le modifiche applicate agli oggetti durante lo stato.

Il campo corretto per la visibilità è:

```text
visible
```

e non:

```text
visibility
```

Il campo errato può produrre un warning e venire ignorato. Questo tipo di errore è pericoloso perché il JSON può sembrare leggibile e valido, ma la scena non si comporta come previsto.

### Unità usate nella timeline

- `position` è espressa in WU;
- `rotation` è espressa in TU;
- `positionVelocity` è espressa in WU/ST;
- `rotationVelocity` è espressa in TU/ST;
- `duration` è espressa in ST.

Con `tickRate: 50`, una durata di 150 corrisponde a circa tre secondi.

### Limiti principali

- `tickRate` deve essere 50;
- la timeline deve contenere da 1 a 255 stati;
- ogni durata deve essere compresa tra 1 e 65535 tick;
- il prodotto tra numero degli stati e numero degli oggetti della scena non deve superare 255;
- non è presente un sistema generale di easing sinusoidale.

Il limite sulla matrice stati × oggetti esiste perché il builder deve rappresentare le combinazioni con strutture compatte. Non basta quindi controllare separatamente il numero di stati e il numero di oggetti.

### Reset della timeline

Con:

```json
"resetKey": "SPACE"
```

il reset deve ripristinare stato, pose, visibilità e contatori secondo il contratto dell’engine. È utile per ripetere una sequenza durante i test senza riavviare il PRG.

### Animazioni più complesse

In assenza di easing sinusoidale generale, animazioni più articolate possono essere costruite con:

- più stati consecutivi;
- velocità progressive;
- segmenti di accelerazione e decelerazione;
- tabelle precalcolate;
- include esterni chiaramente separati dal renderer.

Gli include esterni devono essere documentati e non devono trasformarsi in patch oscure applicate al codice generato. La demo deve continuare a essere ricostruibile in modo deterministico.

## 20. Compilare un PRG

La compilazione deve essere eseguita dalla copia di lavoro, non dalla release conservata come baseline.

Aprire PowerShell e spostarsi nella directory corretta:

```powershell
Set-Location "C:\3Dvibe64\engine-demo-dev1"
```

Prima di lanciare il builder, impostare i percorsi degli strumenti nella sessione corrente:

```powershell
$env:TASS64_EXE = "C:\Tools\64tass\64tass.exe"
$env:VICE_EXE = "C:\Tools\VICE\bin\x64sc.exe"
```

È opportuno verificare subito che entrambi gli eseguibili esistano:

```powershell
& $env:TASS64_EXE --version
& $env:VICE_EXE -version
```

Un comando di compilazione tipico è:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\work\build-3Dvibe64.ps1 `
  -SceneFile .\examples\mia-scena.json `
  -GraphicsMode 4 `
  -CameraMode fixed `
  -CameraViewport normal `
  -Quality balanced `
  -Projection table `
  -MemoryLayout stable `
  -Mode4NearProfile default `
  -FaceCullProfile stable `
  -NoFpsOverlay `
  -SkipCmdUpdate
```

Il comando è suddiviso su più righe con il carattere di continuazione di PowerShell. L’accento grave deve essere l’ultimo carattere della riga: spazi o testo dopo di esso possono interrompere il comando.

### Significato dei parametri dell’esempio

- `-File` indica lo script del builder;
- `-SceneFile` indica il JSON della scena;
- `-GraphicsMode 4` seleziona il rendering solido dinamico;
- `-CameraMode fixed` forza il profilo della camera;
- `-CameraViewport normal` seleziona la viewport 160×100;
- `-Quality balanced` usa il profilo di qualità bilanciato;
- `-Projection table` usa la proiezione tabellare;
- `-MemoryLayout stable` sceglie il layout compatto;
- `-Mode4NearProfile default` applica il profilo near conservativo;
- `-FaceCullProfile stable` richiede il culling stabile nelle modalità supportate;
- `-NoFpsOverlay` rimuove overlay e relativo controllo;
- `-SkipCmdUpdate` evita gli aggiornamenti non necessari previsti dal builder.

Il PRG viene normalmente prodotto in:

```text
work\3Dvibe64.prg
```

Anche l’Assembly generato si trova normalmente sotto `work`. Prima di considerare la build riuscita, Codex deve controllare:

- codice di uscita del builder;
- messaggi di warning;
- messaggi di 64tass;
- esistenza del PRG;
- dimensione del PRG;
- eventuale invasione di aree di memoria;
- eventuale suggerimento di passare a `high-basic-v2`.

Per avviare il risultato:

```powershell
& $env:VICE_EXE -autostart .\work\3Dvibe64.prg
```

Il semplice avvio non conclude il test. VICE deve rimanere in esecuzione abbastanza a lungo da produrre più frame completi e mostrare l’eventuale problema.

### Le opzioni possono cambiare

Le opzioni disponibili e le combinazioni valide possono cambiare tra release. Codex deve quindi verificare i parametri effettivi del builder prima di compilare.

In particolare deve controllare:

- i `ValidateSet` dichiarati nello script;
- la precedenza tra JSON e riga di comando;
- le opzioni valide soltanto in alcune modalità;
- le incompatibilità tra switch;
- i parametri diagnostici che non appartengono all’API pubblica;
- gli esempi ufficiali più vicini alla scena da costruire.

Non bisogna aggiungere un flag soltanto perché il suo nome sembra plausibile. Un parametro inesistente, riservato o non collegato al runtime deve essere rimosso o segnalato.

## 21. Come iniziare una nuova demo con Codex

Una buona richiesta iniziale deve fissare con chiarezza il perimetro del lavoro. Più informazioni vengono stabilite all’inizio, meno Codex dovrà interpretare liberamente.

È utile indicare:

- la baseline;
- la directory che deve rimanere intatta;
- la nuova copia di sviluppo;
- la directory degli output esterni;
- la modalità grafica;
- il profilo della camera;
- la viewport;
- il profilo near;
- il profilo di culling;
- il tipo di luce;
- il Ground;
- gli oggetti;
- le animazioni;
- i test richiesti;
- i file che non devono essere modificati.

Esempio completo:

```text
Lavora sulla release ufficiale:

C:\3Dvibe64\engine-ufficiale

La release deve restare intatta.

Crea:

C:\3Dvibe64\engine-demo-dev1

Mantieni JSON, PRG, screenshot e log in:

C:\3Dvibe64\demo-output

Crea una demo con:

- GraphicsMode 4;
- camera fixed;
- viewport normal;
- sfondo nero;
- una mesh importata da OBJ;
- rotazione sui tre assi;
- luce statica;
- FaceCullProfile stable;
- Mode4NearProfile clip.

Controlla winding, normali e limiti della mesh.
Genera il JSON e compila il PRG.

Prova il risultato in x64sc per almeno 8 frame.
Non modificare VERSION, README, manifest o contratto.

Alla fine indicami il percorso esatto del PRG.
```

Questa richiesta contiene sia il risultato desiderato sia i vincoli di sicurezza.

- La baseline è identificata e protetta.
- La copia di sviluppo ha un percorso preciso.
- Gli output non vengono dispersi nella directory dell’engine.
- Le principali opzioni di rendering sono già decise.
- La mesh deve essere verificata prima della build.
- Il test ha una durata minima.
- I file di identità e documentazione del pacchetto non devono essere modificati.
- Il risultato finale deve essere localizzabile.

Quando la demo è più complessa, si possono aggiungere durata, numero degli oggetti, timeline, tasti runtime, standard video e requisiti di memoria. Non è però necessario descrivere in anticipo ogni dettaglio creativo: si può partire da una scena minima e procedere per varianti isolate.

## 22. Come richiedere modifiche

Una richiesta vaga lascia a Codex troppo spazio di interpretazione.

Per esempio:

```text
Falla più lenta.
```

Non specifica quale elemento deve rallentare. Potrebbe riferirsi alla traslazione, alla rotazione, alla luce, alla camera, alla timeline oppure all’intera simulazione.

È meglio scrivere:

```text
Crea una nuova variante senza sovrascrivere quella precedente.

Riduci del 25% la velocità di traslazione.
Lascia invariate:

- velocità di rotazione;
- camera;
- luce;
- materiali;
- geometria;
- timeline.

Ricompila e indicami il nuovo PRG.
```

La richiesta precisa definisce:

- che cosa deve cambiare;
- di quanto deve cambiare;
- che cosa deve restare identico;
- che la versione precedente non va sovrascritta;
- che deve essere generato un nuovo PRG.

### Richieste sulle posizioni

Invece di “spostalo un po’ più in basso”, usare:

```text
Sposta l’oggetto di 8 WU verso il basso.
```

Con `world-z-up`, “verso il basso” significa ridurre la componente Z. È comunque utile indicare sia la direzione sia il valore numerico per evitare ambiguità.

### Richieste sul timing

Invece di “fallo entrare più tardi”, usare:

```text
Ritarda l’ingresso di 50 ST, equivalenti a un secondo.
```

Questa formulazione collega il valore tecnico alla durata percepita.

### Richieste sulle rotazioni

Invece di “fallo girare più lentamente”, usare:

```text
Dimezza la velocità angolare e mantieni invariato il numero
complessivo di rotazioni.
```

Quest’ultima condizione implica che la durata della fase debba aumentare, se si vuole conservare il numero di giri. Senza specificarlo, Codex potrebbe dimezzare la velocità mantenendo la stessa durata e ottenere soltanto metà della rotazione totale.

### Cambiare una sola variabile alla volta

Durante la messa a punto è preferibile modificare pochi parametri per variante. Se nello stesso passaggio cambiano camera, materiale, luce, velocità e geometria, diventa difficile capire quale modifica abbia migliorato o peggiorato il risultato.

Una buona variante dovrebbe registrare:

- file di partenza;
- valori precedenti;
- valori nuovi;
- elementi dichiarati invariati;
- comando di build;
- nuovo hash del JSON e del PRG.

## 23. Come diagnosticare un problema

Quando una faccia sparisce, lampeggia o viene disegnata nel posto sbagliato, non bisogna chiedere subito una patch casuale. La prima attività deve essere l’individuazione della fase responsabile.

Un prompt strutturato è:

```text
Non applicare subito una patch.

Individua prima la fase responsabile confrontando almeno
32 frame consecutivi.

Distingui:

- trasformazione;
- winding;
- clipping;
- near plane;
- proiezione;
- backface culling;
- screen clipping;
- depth bucket;
- painter order;
- raster;
- shading;
- timeline.

Determina il primo punto esatto in cui il risultato diventa
errato.

Applica una correzione generale soltanto dopo aver dimostrato
la causa. Non usare indici di faccia hardcoded o condizioni
specifiche per questa mesh.
```

La frase “primo punto esatto” è fondamentale. Un errore visibile nel raster può essere stato causato molto prima, per esempio da una coordinata camera-space errata o da un poligono clippato male.

### Strategia consigliata

1. riprodurre il difetto in modo deterministico;
2. congelare, se necessario, camera, luce e rotazione;
3. identificare la prima faccia o il primo frame problematico;
4. seguire i dati attraverso la pipeline;
5. confrontare un frame corretto con il primo frame errato;
6. isolare una causa generale;
7. applicare la modifica nella copia di sviluppo;
8. ricompilare dal JSON;
9. eseguire test di regressione su altre scene.

### Dati da tracciare per una faccia problematica

Si può chiedere a Codex di registrare:

- coordinate originali;
- coordinate trasformate;
- coordinate camera-space;
- profondità geometrica;
- risultato della classificazione rispetto al Ground;
- risultato del clipping Ground;
- risultato del clipping near;
- coordinate proiettate;
- clipping rispetto alla viewport;
- area signed;
- decisione di culling;
- bucket di profondità;
- ordine nel painter;
- materiale;
- livello di shading;
- raggiungimento del raster;
- poligono finale usato dall’outline, in Mode 5.

Una traccia utile deve indicare frame, oggetto, istanza e indice locale della faccia. In presenza di mesh condivise, un indice di faccia privo dell’identificatore dell’istanza può essere ambiguo.

### Correzioni da evitare

Non sono accettabili come soluzione generale:

- invertire soltanto una faccia perché “sembra funzionare” senza verificarne il winding;
- disabilitare il culling per tutta la scena per nascondere un errore locale;
- forzare la profondità di un oggetto con un valore hardcoded;
- saltare un indice specifico nel renderer;
- introdurre una condizione legata al nome della mesh;
- ritoccare manualmente l’ASM generato e non riportare la modifica nel builder.

Queste patch possono correggere un fotogramma e rompere altre pose o altre scene.

## 24. Test in VICE

VICE è parte integrante del processo di sviluppo. Una build che termina senza errori non è automaticamente una demo corretta.

### Test principale con x64sc

Usare `x64sc` per le prove autorevoli, perché privilegia un’emulazione accurata del C64.

Verificare:

- almeno 8 `render_frame_end` o l’equivalente numero di frame completi osservabili;
- nessun ritorno al BASIC;
- nessuna schermata nera persistente non prevista;
- nessuna corruzione bitmap;
- nessun wrap anomalo;
- nessun overflow visibile;
- nessun edge spurio;
- clipping corretto;
- painter order corretto;
- timing regolare;
- risposta corretta dei tasti inclusi nella build.

Otto frame rappresentano soltanto il minimo per uno smoke test visuale. Per rotazioni e animazioni bisogna controllare:

- almeno 32 frame consecutivi;
- il passaggio attraverso pose quasi edge-on;
- le fasi vicine al near plane;
- l’eventuale attraversamento del Ground;
- se possibile, un ciclo intero dell’animazione.

Un difetto periodico può non apparire nei primi frame. Se la timeline dura diversi secondi, il test deve coprire tutti gli stati e almeno una transizione completa.

### Smoke test facoltativo con xscpu64

Se disponibile e se interessa un controllo supplementare non contrattuale, usare `xscpu64` per una verifica aggiuntiva con CPU accelerabile. La build, la verifica autorevole del rendering e il contratto di release restano basati su `x64sc`.

Lo scopo non è certificare la resa finale al posto di `x64sc`, ma individuare animazioni erroneamente legate alla velocità della CPU. Gli eventi dovrebbero mantenere la stessa durata logica su:

- CPU normale;
- CPU accelerata;
- PAL;
- NTSC.

La fluidità e il numero di frame renderizzati possono cambiare. Il tempo narrativo della sequenza non dovrebbe cambiare: 150 ST devono continuare a rappresentare circa tre secondi.

Durante il confronto bisogna misurare eventi riconoscibili, per esempio:

- ingresso di un oggetto;
- inizio e fine di una rotazione;
- cambio di stato della timeline;
- completamento di un’orbita luminosa;
- reset della sequenza.

### Screenshot e log

Chiedere a Codex di salvare fuori dall’engine:

- screenshot;
- log di VICE;
- conteggi frame;
- hash;
- trace diagnostici;
- dump dei bucket, se necessario;
- eventuali confronti tra PAL e NTSC;
- eventuali confronti tra `x64sc` e `xscpu64`.

La directory consigliata è:

```text
C:\3Dvibe64\demo-output\
```

I nomi dei file dovrebbero includere almeno scena, modalità, camera e scopo del test. Un nome come `screen1.png` diventa presto incomprensibile; un nome come `cube-mode4-fixed-nearclip-frame032.png` conserva il contesto.

## 25. Controlli runtime

Le opzioni principali possono comprendere:

```text
-ControlRotation
-ControlLight
-ControlReflectivity
-FpsOverlay
-FpsOverlayOnStart
-NoFpsOverlay
-NoCameraRuntimeControls
-StaticPose
```

### Controlli della camera

Quando presenti nella build:

- `W` / `S`: avanti e indietro;
- `A` / `D`: movimento laterale;
- `Q` / `E`: movimento verticale;
- cursori: yaw e pitch;
- `N` / `M`: roll in `walkFull`.

`-NoCameraRuntimeControls` mantiene il profilo mobile ma rimuove la lettura degli input della camera. È utile per una scena automatica che necessita della pipeline mobile ma non della navigazione dell’utente.

### Rotazione

Quando `ControlRotation` è attivo, il tasto assegnato può sospendere o riprendere la rotazione. Il tasto documentato è `R`.

`-StaticPose` impedisce invece gli aggiornamenti automatici degli angoli della mesh. Non equivale necessariamente alla pausa interattiva: è una scelta compile-time.

### Luce

`-ControlLight` abilita il controllo della luce dove la scena e il percorso selezionato lo supportano. Il tasto documentato è `L`.

### Riflettività

`-ControlReflectivity` assegna normalmente `R` al ciclo della riflettività. Questo crea un conflitto con `-ControlRotation`.

Se `ControlRotation` e `ControlReflectivity` vengono forzati insieme, entrambi gli handler possono leggere `R`: quello della rotazione viene eseguito per primo e quello della riflettività subito dopo. Non esiste quindi un proprietario unico del tasto. Per usare `R` esclusivamente con la riflettività, bisogna omettere `-ControlRotation`.

Prima di abilitare più controlli contemporaneamente, chiedere a Codex di verificare:

- conflitti;
- precedenza;
- comportamento effettivo della release;
- presenza reale dell’handler nel codice generato;
- indicazioni degli esempi ufficiali.

### Generic Text e overlay FPS

DEV7 usa uno split same-bank con tre righe testuali sopra il body bitmap. `-HeaderText "..."` incorpora al massimo 40 caratteri del charset compatto in entrambe le bank video. Sono supportati spazio, cifre, punto e `S C R I T A D E M P O`; l’input non supportato diventa uno spazio. Il contatore FPS occupa le prime quattro celle della riga centrale. Il terminatore `$FF` è essenziale perché zero è il glifo spazio valido.

L’intero header può essere incluso e commutato con `F`.

- `-FpsOverlayOnStart` lo mostra fin dall’avvio;
- `-FpsOverlay` mantiene il selettore previsto dal contratto;
- `-FpsCounterOnly` conserva il campionamento senza header visivo;
- `-NoFpsOverlay` rimuove overlay e tasto FPS.

Gli switch overlay non devono essere combinati in modo incompatibile. Una build densa con Generic Text può richiedere `high-basic-v2`, perché viene emesso il font compatto completo da 184 byte.

### Temporal Scanline Mode

Nelle sole GraphicsMode 4 e 5 può essere presente la funzione associata a `H`. La pressione cicla tra tre stati di aggiornamento delle righe:

```text
0 → 1 → 2 → 0
```

- stato 0: vengono aggiornate tutte le righe;
- stato 1: vengono aggiornate 50 righe a parità alternata;
- stato 2: vengono aggiornate 25 righe secondo una classe modulo 4.

Le righe escluse conservano temporaneamente il contenuto precedente, producendo un effetto interlacciato e una moderata scia.

Non è una semplice modalità a bassa risoluzione e non garantisce un aumento di prestazioni. Trasformazione, proiezione, clipping, culling, ordinamento, shading e preparazione delle facce continuano a essere eseguiti; l’effetto può persino aumentare il costo del frame. Materiali, fill, painter order e outline Mode 5 rimangono invariati.

## 26. Congelare una versione approvata

Quando una demo raggiunge un risultato soddisfacente, la directory non deve più essere trattata come un semplice esperimento. Deve diventare una baseline approvata e immutabile.

Una richiesta consigliata è:

```text
Questa versione è approvata.

Lasciala intatta e considerala la nuova baseline della demo.

Registra:

- SHA-256 del JSON;
- SHA-256 del PRG;
- SHA-256 del builder;
- comando di compilazione;
- modalità e profili usati.

Ogni modifica successiva deve essere creata in una nuova
directory senza sovrascrivere questa versione.
```

Il congelamento serve a rispondere in modo certo a domande come:

- quale JSON ha prodotto questo PRG?
- quale builder è stato usato?
- quali opzioni erano attive?
- la versione approvata è stata modificata per errore?
- il PRG può essere ricostruito in modo byte-identico?

In PowerShell gli hash possono essere calcolati così:

```powershell
Get-FileHash -Algorithm SHA256 "C:\Percorso\demo.json"
Get-FileHash -Algorithm SHA256 "C:\Percorso\demo.prg"
Get-FileHash -Algorithm SHA256 "C:\Percorso\build-3Dvibe64.ps1"
```

È opportuno salvare i risultati in un piccolo rapporto, per esempio:

```text
baseline-demo.txt
```

Il rapporto dovrebbe contenere:

- data del congelamento;
- nome della scena;
- percorso della directory;
- hash del JSON;
- hash del PRG;
- hash del builder;
- comando completo di build;
- modalità grafica;
- camera;
- viewport;
- layout di memoria;
- profilo near;
- profilo di culling;
- standard video;
- esito x64sc;
- eventuale esito xscpu64, chiaramente indicato come prova facoltativa e non contrattuale;
- eventuali note visive.

Se esistono include esterni, mesh importate o tabelle precalcolate indispensabili alla ricostruzione, vanno registrati anche i loro hash.

La nuova variante deve essere realizzata copiando la baseline in una directory diversa, per esempio:

```text
C:\3Dvibe64\engine-demo-approved\
C:\3Dvibe64\engine-demo-dev-next\
```

Non bisogna affidarsi soltanto al nome della cartella. Gli hash sono la prova che i file non sono cambiati.

## 27. Quando una demo è canonica

Una demo può essere considerata canonica quando il suo risultato è riproducibile, documentato e ottenuto attraverso il normale percorso dell’engine.

I criteri principali sono:

- viene ricostruita dal JSON;
- usa il builder ufficiale o una modifica del builder chiaramente documentata nella copia di sviluppo;
- non richiede patch manuali successive all’ASM;
- gli eventuali include esterni sono chiaramente separati;
- il comando di compilazione è documentato;
- il PRG è riproducibile;
- gli hash sono registrati;
- `x64sc` supera i test;
- se è stata scelta la prova supplementare, l’eventuale risultato `xscpu64` viene registrato separatamente e non è usato come requisito di canonicità;
- non restano temporanei necessari ma non documentati;
- la release dell’engine è rimasta intatta;
- tutti gli asset indispensabili sono conservati.

La parola “canonica” non significa che la demo debba usare soltanto una scena banale o esclusivamente funzioni già presenti negli esempi. Significa che ogni estensione deve essere controllabile e che il risultato non dipende da passaggi manuali dimenticati.

### Effetti esterni ammessi

Un effetto grafico esterno, come uno sfondo o una routine decorativa, può essere ammesso se rimane chiaramente separato dal renderer 3D.

Non dovrebbe:

- modificare il culling;
- sostituire il renderer;
- riscrivere materiali interni;
- introdurre passaggi 3D separati;
- intervenire sugli indici globali delle facce;
- alterare la pipeline dell’engine;
- correggere con dati hardcoded una singola mesh;
- rendere impossibile la ricostruzione automatica.

Per esempio, una routine che disegna stelle nello sfondo può essere considerata decorativa. Una routine che ridisegna manualmente facce 3D saltate dal renderer non è più un semplice effetto esterno: sta sostituendo o correggendo la pipeline e deve essere trattata come una modifica dell’engine.

### Riproducibilità pratica

Per verificare che una demo sia davvero canonica, Codex dovrebbe essere in grado di:

1. partire dalla directory congelata;
2. eliminare gli output generati;
3. rilanciare il comando documentato;
4. ottenere di nuovo il PRG;
5. confrontarne l’hash;
6. ripetere il test in VICE.

Se il PRG non può essere rigenerato senza ricordare un intervento manuale, la procedura non è ancora completa.

## 28. Errori comuni

### Modificare la release ufficiale

La release ufficiale deve essere soltanto letta e copiata. Lavorare direttamente al suo interno rende difficile capire se un problema appartiene all’engine originale oppure a una modifica successiva.

Soluzione: creare sempre una copia separata prima di modificare JSON, builder, esempi o documentazione.

### Modificare direttamente l’ASM generato

L’Assembly sotto `work` viene rigenerato dal builder. Una modifica manuale:

- andrà persa alla build successiva;
- non sarà rappresentata nel JSON;
- renderà il PRG difficile da ricostruire;
- può nascondere il vero limite del builder.

Una patch ASM può essere usata soltanto come esperimento diagnostico temporaneo. Se conferma la soluzione, la modifica generale deve essere riportata nel builder o in un include dichiarato.

### Usare descrizioni non misurabili

Evitare richieste come:

```text
più veloce
un po’ più in basso
molto più lontano
```

Queste espressioni dipendono dall’interpretazione e non permettono di confrontare con precisione due varianti.

Preferire:

```text
aumenta la velocità del 20%
abbassa di 4 WU
sposta la partenza da 80 a 140 WU
ritarda di 75 ST
```

Una richiesta misurabile permette di verificare il JSON prima e dopo la modifica.

### Confondere colore, culling e proiezione

Una faccia che sparisce può dipendere da:

- winding;
- backface culling;
- near plane;
- clipping;
- proiezione;
- screen clipping;
- painter order;
- degenerazione;
- materiale;
- posizione dell’oggetto;
- overflow o wrap numerico.

Non è necessariamente un problema di shading.

Cambiare il colore può rendere una faccia più visibile, ma non corregge una decisione di culling. Disabilitare il culling può farla comparire, ma non dimostra che il culling sia sbagliato: il winding della mesh potrebbe essere invertito.

### Aspettarsi di vedere una mesh dall’interno

Il rendering è normalmente monofacciale. Dentro un oggetto chiuso, molte facce vengono correttamente eliminate perché il loro lato anteriore è rivolto verso l’esterno.

I profili near `late` e `clip` non rendono le mesh two-sided. Il clipping conserva la porzione geometrica davanti alla camera, ma non cambia l’orientamento delle facce.

### Usare troppi poligoni

Una mesh moderna può contenere migliaia o milioni di poligoni. Il fatto che sia possibile convertirla in JSON non significa che sia adatta al C64.

Per migliorare la velocità:

- semplificare la mesh;
- eliminare facce invisibili;
- eliminare duplicati;
- condividere le geometrie ripetute;
- usare viewport `small`;
- scegliere Mode 3 quando lo shading dinamico non serve;
- usare luce realmente statica;
- ridurre gli oggetti simultanei;
- ridurre la durata delle fasi più pesanti;
- eliminare controlli runtime inutili;
- scegliere Mode 4 invece di Mode 5 quando l’outline non è indispensabile.

La semplificazione deve essere controllata. Ridurre casualmente i poligoni può alterare silhouette, winding e normali.

### Ignorare la memoria

Se una finestra viene superata:

1. provare `high-basic-v2`;
2. ridurre vertici e facce;
3. ridurre le istanze;
4. semplificare la timeline;
5. eliminare controlli inutili;
6. usare luce statica;
7. ridurre il viewport.

Il passaggio a `high-basic-v2` deve essere esplicito. Se la scena continua a non entrare, non bisogna tentare di aggirare il controllo di build senza comprendere quali aree si sovrappongono.

### Presumere che 255 sia sempre un limite raggiungibile

Diversi indici e conteggi possono avere un massimo teorico di 255, ma codice, buffer, clipping, timeline e istanze consumano memoria prima di quel valore. Il limite effettivo dipende dall’intera configurazione.

### Dimenticare la precedenza tra JSON e CLI

Un valore nel JSON può essere sostituito da un parametro esplicito della riga di comando. Per esempio, la camera o la viewport effettive possono non coincidere con quelle lette superficialmente nel JSON.

Codex deve registrare il comando completo, non soltanto la scena.

### Confondere luce statica reale e fase congelata

`"type": "static"` seleziona il percorso realmente statico. Un vecchio campo `"mode": "static"` o una fase orbitale congelata possono conservare infrastruttura non necessaria.

### Usare `visibility` invece di `visible`

La timeline richiede `visible`. `visibility` può essere ignorato. Un warning del builder non deve essere trascurato.

### Abilitare controlli in conflitto

`ControlRotation` e `ControlReflectivity` possono condividere `R`. Prima di aggiungere entrambi, occorre decidere quale funzione deve possedere il tasto.

### Considerare `H` una modalità prestazionale

Il Temporal Scanline Mode conserva gran parte della pipeline e può aumentare il costo. Va usato come effetto visivo sperimentale, non come sostituto automatico dell’ottimizzazione.

### Collegare il tempo alla CPU

Una sequenza che dura correttamente su `x64sc` ma accelera su `xscpu64` sta probabilmente usando un contatore legato alle iterazioni o ai frame, invece degli ST. Il timing narrativo deve rimanere normalizzato.

## 29. Flusso di lavoro completo consigliato

### Fase 1: preparazione

1. fornire a Codex il link GitHub o il percorso dello ZIP;
2. scaricare o individuare lo ZIP della release;
3. estrarlo in una directory ufficiale;
4. installare o configurare gli strumenti;
5. controllare versioni e percorsi;
6. compilare un esempio ufficiale;
7. verificare il risultato in VICE;
8. registrare la configurazione funzionante.

La fase di preparazione deve concludersi con una build reale. Il fatto che gli eseguibili rispondano a `--version` non dimostra ancora che builder, assembler e percorsi lavorino insieme.

### Fase 2: nuova demo

1. creare una copia dell’engine;
2. scegliere l’esempio ufficiale più vicino al risultato desiderato;
3. creare un nuovo JSON senza modificare l’esempio originale;
4. importare e verificare le mesh;
5. selezionare modalità, camera, viewport, memoria, near e culling;
6. compilare il primo PRG;
7. eseguire il test in `x64sc`;
8. salvare screenshot, log e comando.

Partire dall’esempio più vicino riduce gli errori di schema. Una demo Mode 5 con mesh condivise dovrebbe partire da un esempio Mode 5 con sharing, non da una scena wire minimale.

### Fase 3: sviluppo iterativo

1. modificare pochi parametri alla volta;
2. usare valori numerici;
3. creare una nuova variante per ogni cambiamento significativo;
4. non sovrascrivere versioni approvate;
5. conservare screenshot e PRG;
6. confrontare varianti precise;
7. annotare ciò che deve rimanere invariato;
8. aggiornare gli hash delle varianti importanti.

Una buona iterazione deve poter rispondere alla domanda: “Quale singola modifica ha prodotto questa differenza?”.

### Fase 4: diagnosi

1. riprodurre il problema in modo deterministico;
2. congelare camera, luce e rotazione se necessario;
3. individuare la fase della pipeline;
4. confrontare almeno 32 frame quando il problema è temporale;
5. tracciare la prima faccia errata;
6. correggere la causa generale;
7. ricompilare senza patch manuali;
8. provare scene di regressione non collegate al caso iniziale.

La diagnosi deve precedere la modifica. Una patch che “sembra funzionare” non è sufficiente se non è chiaro perché funzioni.

### Fase 5: chiusura

1. ricostruire tutto dal JSON;
2. verificare gli hash;
3. provare `x64sc`;
4. se utile e disponibile, eseguire uno smoke test facoltativo `xscpu64`, senza sostituire la verifica `x64sc`;
5. verificare, quando rilevante, PAL e NTSC;
6. eliminare temporanei non necessari;
7. conservare comando, JSON, asset e PRG;
8. congelare la directory finale;
9. creare una nuova copia per ogni sviluppo successivo.

La chiusura non consiste soltanto nel copiare il PRG. La vera unità archivistica della demo comprende almeno JSON, builder identificato dall’hash, comando, asset, PRG e rapporto di test.

## 30. Prompt completo per iniziare da zero

Il seguente prompt raccoglie l’intero flusso di preparazione. Può essere adattato ai percorsi reali del computer.

```text
Voglio creare demo e PRG con 3Dvibe64 senza modificare
manualmente codice Assembly.

Repository ufficiale:

[incolla qui l’indirizzo copiato dal pulsante Code di GitHub]

Prepara l’ambiente di sviluppo.

1. Individua e scarica lo ZIP dell’ultima release stabile.
2. Estrailo in:

C:\3Dvibe64\engine-ufficiale

3. Non modificare questa directory.
4. Verifica la presenza di:
   - PowerShell;
   - Python 3;
   - Git;
   - 64tass;
   - VICE x64sc;
   - VICE xscpu64, facoltativo e non contrattuale.

5. Se manca qualcosa, usa esclusivamente fonti ufficiali.
6. Chiedimi l’autorizzazione quando richiesta per download,
   installazioni, privilegi amministrativi o avvio di programmi.
7. Se possibile, preferisci versioni portabili di 64tass e VICE.
8. Configura i percorsi degli strumenti.
9. Esegui i test contrattuali presenti nella release.
10. Crea una copia di lavoro in:

C:\3Dvibe64\engine-demo-dev1

11. Compila un esempio ufficiale senza modificare la release.
12. Esegui il PRG in x64sc per almeno 8 frame.
13. Se xscpu64 è disponibile, esegui un breve smoke test facoltativo e riportalo separatamente dal test autorevole x64sc.

Alla fine indicami:

- release scaricata;
- percorso della release ufficiale;
- percorso della copia di lavoro;
- versione di Python;
- versione di Git;
- versione di 64tass;
- versione di VICE;
- comando di compilazione;
- percorso del PRG;
- SHA-256 del PRG;
- esito dei test.
```

### Come adattare il prompt

Se lo ZIP è già stato scaricato, sostituire il punto relativo al download con il percorso locale. Se non si desidera installare Git, si può chiedere a Codex di segnalarne l’assenza e procedere con copie e hash.

Se VICE non può essere avviato automaticamente dall’ambiente, Codex deve comunque:

- produrre il PRG;
- indicare il comando esatto di avvio;
- preparare la directory degli output;
- spiegare quale verifica manuale resta da eseguire.

Se la release include test Python o contratti di build, questi devono essere eseguiti prima di modificare il builder. In questo modo si dispone di una baseline tecnica da confrontare con le modifiche successive.

## Conclusione

Il modo più semplice e sicuro per usare 3Dvibe64 consiste nel separare nettamente creazione, compilazione, verifica e conservazione delle versioni.

Il flusso raccomandato è:

- scaricare lo ZIP ufficiale da GitHub;
- conservarne una copia intatta;
- fornire a Codex il percorso della release;
- lasciare che Codex controlli e, previa autorizzazione, installi gli strumenti necessari;
- creare una copia di lavoro separata;
- descrivere la scena in linguaggio naturale;
- trasformare ogni richiesta visiva in numeri e condizioni verificabili;
- usare il JSON come sorgente autorevole;
- lasciare che builder e 64tass producano il PRG;
- verificare il risultato in VICE;
- confrontare PAL, NTSC e CPU accelerata quando il timing è importante;
- congelare ogni versione approvata con hash e comando di build.

Non serve conoscere Assembly per creare una demo con questo metodo. Serve soprattutto lavorare in modo ordinato: baseline intatta, copie isolate, richieste precise, test ripetibili e PRG sempre ricostruibile dal JSON.

L’Assembly rimane naturalmente al centro dell’esecuzione sul Commodore 64, ma non deve diventare il punto nel quale l’utente è costretto a intervenire manualmente. Il builder deve trasformare la descrizione della scena in codice, mentre Codex deve rendere trasparenti le decisioni tecniche, registrare i passaggi e impedire che una versione funzionante venga persa.

Una demo ben organizzata non è soltanto un PRG che parte. È un progetto del quale si conoscono la sorgente JSON, gli asset, il builder, il comando, gli hash, i test e il percorso esatto di ricostruzione.
