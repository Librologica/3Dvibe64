# CAMERA ISOLATION — 1.14.0-dev1

Il selettore di compatibilità `-Precision legacy -LegacyStability camera`
richiede Mode2, walkLite, normal e high-basic-v2. Conserva quattro bit frazionari
di posizione durante sottrazione camera, yaw/pitch e proiezione dei vertici
originali. Mantiene coefficienti Q6 e angoli camera a byte; nessun backend Q8 o
Normalized16 viene usato.

La proiezione usa il rapporto aritmetico nativo con numeratore/denominatore Q4,
anziché la tabella a profondità intera. Il raw geometrico per culling e near
rimane intero: mancano le correzioni near/schermo di legacy-plus. Le coordinate
relative devono restare in[-1024,1024)WU per asse. Fuori dominio viene impostato
`legacy_camera_fault`: controllarlo insieme alle guardie del segmento alto.

Il percorso ottimizzato del quoziente `mul_s16_s6` usa prodotti quarter-square
nativi se entrambi gli operandi positivi entrano in signed8. Resto,
arrotondamento e fallback generale rimangono; non aggiunge cache per oggetto o
vertice. Rimangono il gradino angolare a byte1,40625gradi e il raster intero.
L'esperimento di compatibilità è mantenuto per riprodurre progetti esistenti.
La nuova qualifica nativa camera/near/FPS riguarda
[legacy-plus](LEGACY-PLUS.it.md), non questo percorso.

```powershell
python -B scripts/test_camera_profile.py --build ../camera-build --out ../camera-numeric.json
```

È un controllo aritmetico su una build esterna, mai un benchmark FPS.
[Precisione](PRECISION.it.md) · [Test](TESTING.md)
