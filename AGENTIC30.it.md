# Agentic30 — 1.15.2-dev-agentic30

Sviluppo non pubblicato dalla agentic29 consegnata. [English](AGENTIC30.en.md).
[RuntimeScene](RUNTIME-SCENE.it.md) · [Dynamics](DYNAMICS.it.md) ·
[Qualifica](QUALIFICATION-AGENTIC30.json).

Questa dev estrae primitive riutilizzabili di rendering e dinamica dal lavoro
applicativo. Non include scene, modelli, demo, musica, video, launcher di giochi
o regole dell'applicazione. Preserva release ufficiali, demo congelate e storico
deprecato. Nessuna pubblicazione o promozione a stabile.

Il compilatore Scene1 esplicito `runtimeScene` supporta LegacyPlus ordinario
Mode4/5/6 walkLite normal/high-basic-v2/NoFpsOverlay. Opzioni del renderer:
prodotti delle coordinate limitati alla mesh attiva con cache completamente
posseduta, ripristino matrice per componenti rigide, scarto conservativo oggetti,
luce mista fixed/frozen/dynamic, bake locale dei colori faccia, fill Gouraud
uniforme esatto e curva configurabile più chiara. Default di rendering, qualità
e precisione mantengono il percorso del parent.

Moduli opzionali: camera Q8 con ritardo/angoli più brevi/bank e isteresi di
prossimità/LOD, focale dinamica coerente e roll Q10, copia atomica delle pose,
origine mobile condivisa, RNG simulazione/cosmetica indipendenti, particelle nel
volume casuale con lavoro limitato, SAT convesso planare e scheduler dei contatti
con budget, callback e rollback. Il compilatore host sceglie template figli
distinti, scale Q6 dai volumi e dati di spawn bilanciati per massa. Non promette
fisica continua3D completa, taglio arbitrario delle mesh, AI completa del gioco
o risposta automatica alle collisioni. ABI e domini sono espliciti.

Opzioni di presentazione: conserva la coda bitmap inutilizzata, evita scritture
ridondanti dello sfondo fisso ed espone un hook precommit limitato. Richiedono
ownership applicativa; non creano automaticamente doppio buffer della color RAM
o risorse sprite. I colpi possono riusare gli impostori circolari esistenti,
senza introdurre un secondo rasterizer.

Le aggiunte native possiedono stato privato nominato nei blocchi Plus limitati
esistenti. Nessun alias scratch o indirizzo fisso dell'applicazione importato,
nessuna finestra ampliata o riduzione nascosta di qualità. Non tutte le combinazioni
opzionali entrano nella RAM Mode6: i rifiuti di build/mappa restano espliciti.
AnimatedMesh resta invariata; le sue coordinate mutabili non si mescolano
implicitamente al percorso immutabile RuntimeScene. Restano le8 modalità esistenti.

Test pubblici: contratti host e routine6502 assemblate confrontate con riferimenti
indipendenti; i callback CPU verificano correttezza e non producono FPS. Qualifica
nativa esterna: VICE Turbo6510 PAL1x/20x/64x reale, SID originale della suite
attivo, warm-up128 refresh (~2,554s), misura1024 refresh (~20,429s), percorso16 pose,
solo nuove viste complete. Campagne distinte per default e opzioni nuove, pixel
prima/dopo, cicli/comandi/hash grezzi, intervalli/p95/peggiore e fasi ferme/mobili.
Nessuna qualifica implicita hardware/NTSC.

Indice performance-v1 e workload suite1.1.0 invariati; i casi RuntimeScene hanno
un'estensione identificata separatamente. Note e registri precedenti rimangono
storico immutabile; il registro corrente riporta copertura reale, blocchi ereditati
e regressioni locali. Identità fra staging misurato e runtime consegnato verificata
fuori dall'SDK.

Verifica nativa corrente:81 build predefinite a freddo,54 casi misurati/162 celle native,648 catture identiche alla base,27 blocchi ereditati,0 nuovi sui default.13 casi opzionali separati/39 celle native e72 confronti pixel esatti prima/dopo.12 ricompilazioni dei sorgenti finali coincidono con gli hash PRG misurati. API cerchi verificata con focale64/100/170/254 e trasformazione world inclinata su profilo minimo; la combinazione più ampia a due oggetti supera la RAM. Costi opzionali e FPS/p95/peggiore grezzi nel registro esterno; nessun aumento generale degli FPS dichiarato.

Confronto automatico storico e indice fisso performance-v1 bloccati dal diverso hash del binario PowerShell. PRG/label/pixel coincidono col parent e i nuovi confronti opzionali usano gli strumenti correnti, ma non si dichiara una qualifica storica completa compatibile.
