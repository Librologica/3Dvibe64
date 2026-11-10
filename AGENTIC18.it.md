# 3Dvibe64 1.15.2-dev-agentic18

Sviluppo non pubblicato dall'esatta base stabile 1.15.1 presente su GitHub. È una
nuova dev di ricerca sul rendering, non una release stabile o un tag GitHub.

Il rasterizzatore wire consolidato divide una sola volta la distanza orizzontale
per quella verticale. Ogni riga avanza del quoziente e applica al massimo una
correzione del resto, conservando gli stessi pixel connessi inclusivi. La patch
richiede la forma nota del codice emesso e viewport Y<128; gli altri percorsi
mantengono il codice della base. Gli scratch privati dxabs/errhi vengono
ripristinati prima del flush finale. Nessuna nuova variabile RAM, tabella o
allocazione di stack.

La divisione esatta del clipping specializza i denominatori <=255, mantenendo il
resto in A e impostando esplicitamente il bit del quoziente dopo una sottrazione
con overflow. Per denominatori più grandi usa il carry come diciassettesimo bit
del resto. Risultati interi, scratch, A/X/Y e flag architetturali sono conservati.

API pubblica, carico, qualità, opzioni predefinite e finestre dell'allocatore
restano invariati. QUALIFICATION-1.15.1.json e i report versionati rimangono
storici e non qualificano il runtime modificato. Le nuove prove sono esterne in
../evidence/ e la qualificazione corrente è QUALIFICATION-AGENTIC18.json.
Scene benchmark, PRG, demo, immagini catturate e dipendenze restano fuori dall'SDK.

I tre controlli riservati alla pubblicazione stabile test_stable_package.py,
test_documentation.py e test_release_contract.py conservano le asserzioni
originali. Gli equivalenti per questa dev sono verificati dallo strumento esterno
tools/audit_development.py; 18 altri controlli pubblici autonomi restano invariati. Il controllo dei
sorgenti legacy-plus seleziona il registro corrente tramite RELEASE.json e
quello della distribuzione richiede questa precisa dev prerelease. I controlli
di hash, opzioni predefinite, misure storiche e rifiuto di API errate restano
attivi. Non indebolire o dichiarare superati come dev i test della stabile.

Le build opzionali `-SphereRenderer circles` conservano la divisione di clipping
e la disposizione del codice della base. La verifica nativa supplementare ha
rilevato una regressione del budget PAL nella API Mode6/1x quando la divisione
più grande veniva emessa in quel backend. Il controllo riguarda una funzione
generale dell’engine, senza nomi di scene, casi o moltiplicatori. PRG e simboli
numerici dei programmi API enabled/control devono coincidere con la stabile.

Qualificazione completata:54 casi a1x/20x/64x,648 immagini identiche,27 blocchi
di compilazione preesistenti e0 nuovi blocchi. Indice fisso 120.207624,
contro 117.647645 della stabile1.15.1; base1.15.0=100. Musica SID
attiva,128 refresh di warm-up e1024 refresh misurati (~20,429s) per esecuzione.
Tre ripetizioni per lato su4 casi selezionati; il flag della finestra breve
near-2/1x è risolto separatamente da tre prove da8192 refresh per lato.
Osservazioni originali e pesi restano invariati. Vedere QUALIFICATION-AGENTIC18.json
e REPORT.html/evidence esterni. La dev resta non pubblicata.
