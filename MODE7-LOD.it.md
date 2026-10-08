# LOD graduale delle texture Mode 7 (1.8.0)

Opzione esplicita di qualità dell'immagine: non raycasting, mipmapping o ottimizzazione a immagine identica. Geometria, copertura, estremi prospettici e illuminazione mantengono i contratti esistenti. `off` è il default. I profili di qualità texture standard e fast restano selezionabili separatamente.

```powershell
pwsh -NoProfile -File work/build-3Dvibe64.ps1 -Precision q8 -GraphicsMode 7 -SceneFile examples/mode7-perspective-cube.json -TextureQuality fast -TextureLOD gradual -TextureLODNear 28 -TextureLODFar 44 -OutputDirectory ../lod-build
```

La scena può invece contenere `"textureLOD": "gradual"`, `"textureLODNear": 28`, `"textureLODFar": 44`. La CLI esplicita prevale sulla scena. Distanze intere in unità mondo: `1 < near < far < 256`, intervallo di transizione di **16 WU**. Le combinazioni non supportate sono rifiutate. Richiede Q8 e texture prospettiche, entro i limiti esistenti di oggetti, camera, profondità e memoria. Standard supporta none/flat/Gouraud C; fast richiede ancora Gouraud C. Il LOD non abilita automaticamente fast.

La build conta i 256 texel runtime reali (PNG e inline equivalenti). Il pigmento dominante è il più frequente fra 1/2/3, con indice minore in caso di parità. L'accento è il pigmento presente più saturo secondo una graduatoria RGB VIC-II fissa, poi il più luminoso, poi l'indice minore. La graduatoria non modifica la palette dell'emulatore. Selezione specifica per la palette di ogni faccia runtime; nessun indice texture o elenco di stanze codificato.

La minima profondità camera dei corner originali seleziona conservativamente il dettaglio. Un corner dietro la camera conserva il dettaglio completo. Fino a `near` la texture resta completa. Fra near e far una maschera Bayer 4×4 ancorata miscela dettaglio completo e riempimento lontano in sedici passi. Da far il riempimento usa 75% pigmento dominante e 25% accento. La composizione Gouraud/flat, se scelta, avviene successivamente. Le texture già uniformi restano invariate. Classificazione per faccia, non per pixel: una superficie lunga può mantenere dettaglio per un corner vicino. Nessuna piramide di texture a risoluzioni inferiori.

Standard ancora il pattern a x/y logici. Fast usa per y l'indice delle righe campionate (`y/2`) e duplica il risultato nella riga omessa. Nessun dithering temporale. Nel LOD lontano il dispatch uniforme esistente salta divisione UV e avanzamento dei carrier; conserva la lettura sicura della pagina originale, sostituendola con il pigmento selezionato. Encoding e controlli di dominio della profondità restano attivi.

Il renderer modifica un opcode JSR/BIT fuori dal loop di campionamento per saltare la miscela a dettaglio completo. Gli operandi del sampler indirizzi e della pagina texture restano invariati. L'IRQ non entra né modifica queste routine. Stato e codice usano l'allocatore con guardie esistente; una configurazione fuori budget fallisce senza riduzioni silenziose. Alcune configurazioni fast con camera mobile esauriscono la RAM già senza LOD: conta la build reale, non una promessa generale sulla dimensione della scena.

Test del codice assemblato, catture native e prestazioni misurate sono separati nel report di qualificazione della candidate con codice identico alla release. Il guadagno dipende da scena e distanza; nessuna promessa universale di FPS o qualificazione hardware.
