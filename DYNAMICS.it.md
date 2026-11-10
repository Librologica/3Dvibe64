# Dynamics — 1.20.0

> SDK sorgente stabile 1.20.0, derivato dalla agentic36. Pubblicato su GitHub. [Qualifica](QUALIFICATION-1.20.0.it.md).

[English](DYNAMICS.en.md).
[RuntimeScene](RUNTIME-SCENE.it.md) emette gli helper nativi opzionali; riferimenti
e compilatore host sono in `extensions/gameplay/dynamics.py`. Nessun modello,
suono, AI, punteggio o demo incluso. Sono contatti convessi planari con dati3D
per camera/particelle, non un motore completo di corpi rigidi3D.

`support.sat: {}` emette `rs_sat_query`. `rs_sat_a_count`/`rs_sat_b_count`:3..16;
SoA `rs_sat_a_x`, `rs_sat_a_z`, `rs_sat_b_x`, `rs_sat_b_z`: vertici convessi
ordinati in un **dominio intero locale comune[-63,63]**. L'applicazione trasforma
e ricentra i collider in quel dominio prima della chiamata. Non sono la mesh di
rendering, un'approssimazione bounding box o un estrattore automatico di collider.
`convex_polygon` valida forme authored: rifiuta degenerazione, concavità, vertici
duplicati e spigoli incrociati. Il runtime verifica conteggi/range, fidandosi della
convessità già validata.

La query prova prima i due assi AABB, poi l'asse separatore in cache, poi ogni
normale agli spigoli di entrambi i poligoni. Proiezioni intere signed16 esatte,
senza radici né normalizzazione. Il contatto al bordo conta come contatto.
C=1 indica sovrapposizione/status0; C=0 separazione/status1 o input invalido/status2
in `rs_sat_status`. Una separazione imposta `rs_sat_cached`=1 e i due signed8
`rs_sat_cache_axis`. Salvare/ripristinare questi tre byte per cache per coppia,
oppure lasciare l'ultimo asse: un asse precedente può scartare in sicurezza, mai
provare la sovrapposizione. Si può invalidarlo cambiando proprietari. Nessun
manifold o impulso di penetrazione viene restituito.

Campi di `support.contacts`:

* `bodies`:2..16; `passes`:1..16(default4); `pairBudget`:1..65535(default256).
* `query`,`resolve`: simboli callback assembly, X/Y=ID corpi. Query restituisce
  C=1 per contatto eleggibile; resolver modifica lo stato applicativo e ritorna
  RTS. Possono usare SAT/matematica privata; non alterare rs_contact_ né richiamare
  ricorsivamente lo scheduler.
* `positions`:1..6 descrittori SoA `{low,high}` con `bodies` elementi. Registrare
  tutti i canali di posizione/integratore da ripristinare.
* `velocities`:0..6 descrittori SoA signed16; al rollback subiscono uno shift
  aritmetico a destra. Nessun modello automatico di inerzia/rotazione.
* `priority` opzionale: indice corpo. Tutte le sue coppie vengono prima a ogni
  passaggio; seguono le altre in ordine stabile.

Sequenza: `rs_contacts_snapshot` **prima dell'integrazione**, integrazione
applicativa, poi `rs_contacts_solve`. Ogni coppia viene provata al massimo una
volta per passaggio; termina dopo un passaggio senza contatti e non supera il
budget query. C=1/status0 (`rs_contact_status`) indica convergenza; C=0/status1
indica budget/passaggi esauriti: ripristina lo snapshot e dimezza le velocità
registrate. C=0/status2 indica snapshot assente; crearne uno nuovo ogni tick.
`rs_contact_queries` conta16 bit; `rs_contact_pass` è il passaggio a base zero.
Il budget limita lo scheduling, non il lavoro arbitrario delle callback.

Esclusione di corpi lontani/dormienti, immunità temporanea dei fratelli, priorità,
test continui dei proiettili e risposta restano politiche applicative. Separare
sempre eleggibilità colpi/player da grazia dei fratelli e visibilità grafica.
Se il budget non copre nemmeno le coppie prioritarie richieste, il risultato è
il rollback esplicito: non si disabilitano silenziosamente contatti per alzare gli
FPS. `solve_bounded` host offre la stessa politica stabile con callback Python,
prendendo lo snapshot quando viene chiamato.

Utilità del compilatore/riferimento:

| Funzione | Scopo |
|---|---|
| `smooth`, `Hysteresis`, `easing_table` | Filtri Q8 su posizione/angolo più breve, soglie di prossimità/LOD, campioni compilati di transizione dolce. |
| `sphere_outside`, `rebase`, `grid_anchor` | Bound conservativi camera, canali con offset comune, unica griglia quadrata agganciata con floor anche nelle celle negative. Topologia/proiezione della griglia applicative. |
| `lfsr16`, `sphere_sample`, `advance_particles` | Riferimenti casuali deterministici, campioni nel volume con tentativi limitati e fallback zero, integrazione signed16/vita. Il campionamento cosmetico non consuma RNG simulazione. |
| `convex_polygon`, `broad_aabb`, `sat_overlap` | Validazione convessa e test planari interi esatti con asse precedente opzionale. Il riferimento host ammette interi più ampi dell'ABI nativa limitata. |
| `mesh_volume` | Volume per tetraedri di mesh chiusa triangoli/quad con winding coerente. Rifiuta aperture/winding incoerente/volume nullo; non certifica topologia3D arbitraria autointersecante. |
| `binary_fragment_scales`, `fragment_choices`, `fragment_plan` | Scale binarie dai volumi reali dei template, due figli distinti e diversi dal genitore. Il piano Q6 riporta l'errore relativo di volume e rifiuta scale non rappresentabili. Niente radici cubiche nel runtime. |
| `fragment_spawn` | Centri e velocità bilanciati per massa, centri vicini: separation0..1, impulse>=0, fraction0..1 esclusi, metadato siblingGrace0..255. Conserva baricentro e momento lineare pesati nel riferimento; applicazione converte alla precisione nativa e applica eleggibilità. |
| `solid_lamp_colors` | Colori faccia VIC-II compilati con lampada locale ed override emissivi. Usata da `runtimeScene.solidLamp`, senza ricalcolo con moto di oggetto/camera. |

I frammenti richiedono template e volumi applicativi. Non tagliano mesh arbitrarie
né promettono volume esatto dopo quantizzazione Q6. Scegliere template/scale con
errore riportato compatibile col proprio budget; centri vicini al genitore e breve
grazia soltanto fra fratelli durante la separazione. Resistenza, traffico e energia
del player sono regole del gioco, assenti dall'engine.

Eseguire `scripts/run_release_tests.py` in una copia di lavoro. I nuovi test
assemblano gli helper6502 reali e li confrontano con riferimenti host indipendenti;
il tempo della CPU simulata non è FPS. Benchmark PAL, cicli grezzi, comandi, hash
dei PRG, copertura e limiti restano nel registro esterno di qualifica.
