# Agentic34 — 1.15.2-dev-agentic34

Sviluppo non pubblicato dalla agentic33. Nuova dissolvenza a distanza opzionale nelle modalità1–8, default off. [Contratto completo](DISTANCE-FADE.it.md). Il LOD texture Mode7 resta indipendente.

Gli output poligonali spenti e i tre output auto Mode8 sono stati confrontati byte per byte con agentic33. Sette immagini native completamente opache sono identiche al percorso spento; sette immagini completamente distanti non contengono pixel degli oggetti. I due controlli Mode7 sono verificati separatamente e insieme, compresi test compilati di classificatore/campioni LOD. Mode8 conserva le frazioni della distanza della camera e i confini di memoria protetti; tutti i tre backend compilano in auto e interactive.

È una funzione opzionale di visibilità/qualità, non un'ottimizzazione universale: il retino parziale aggiunge lavoro. Risultati rappresentativi PAL64×: cubo statico Mode4 da50,12 a25,06 FPS durante la dissolvenza; Mode7 Gouraud-C da3,13 a2,89 FPS; Mode7 unlit con LOD da9,45 a7,93 FPS con dissolvenza parziale. Mode7 completamente escluso raggiunge50,12 FPS. Sono carichi/profili luce diversi, da non fondere in un punteggio generale.

Un percorso completo Mode8 multi è misurato per179,552762 secondi emulati dopo128 refresh di warm-up:50,124542→37,877446 FPS, tutte le142 tappe completate (150 visite), zero fault e perdite di tick. Il mono ha anche il costo di ripristino dello sfondo. Le altre misure brevi usano1024 refresh (20,429114 secondi emulati) dopo128 di warm-up, contando solo viste complete presentate. Musica assente nei profili pubblici Q8/Mode8 supportati. I test CPU non producono FPS. NTSC e moltiplicatori1/20 con effetto attivo non sono rimisurati; Mode8 interactive è verificato in compilazione/kernel condiviso/catture, senza una misura FPS separata.

Le allocazioni legacy/legacy-plus vengono ricostruite dopo la strumentazione per evitare sovrapposizioni con gli helper esistenti. Gli ingressi per caduta dei kernel wire/clip Mode1 sono preservati nella riallocazione. Le misure native Mode1 legacy e legacy-plus sono entrambe50,124542 FPS; legacy-plus Mode4 corretto misura33,432678 FPS contro50,124542 con effetto spento. I test di regressione compilano ed eseguono questi ingressi e il caso di un helper adiacente.

Indice generale SDK, riferimento fisso stabile1.15.0=100: base137,50563008162632; nuova137,50563008162632; variazione0%. È una stima ricostruita ereditata per i default invariati. L'indice canonico storico resta bloccato dal diverso hash PowerShell. I carichi con dissolvenza attiva non sostituiscono il paniere congelato.

Il [registro di qualifica](QUALIFICATION-AGENTIC34.json) riporta posizione delle evidenze locali, hash PRG, comandi e misure. Nessuna scena, demo, musica, PRG o cattura inclusa nella SDK sorgente. Nessuna pubblicazione o promozione a stabile. Agentic33 originale, release ufficiali e demo congelate preservate.
