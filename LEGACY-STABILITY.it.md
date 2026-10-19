> Edizione di sviluppo 1.15.0-dev2; contratti1.14.0 ereditati salvo estensioni esplicite nel [rendering esatto](EXACT-RENDER.it.md).

# LEGACY STABILITY — 1.14.0

Il selettore di compatibilità è `-Precision legacy -LegacyStability corrected`.
Omettere LegacyStability o scegliere `historical` conserva il legacy ordinario.
L'opzione è rifiutata per Q8, Normalized16 e Mode8; non dipende automaticamente
dalla CPU. Usare scena esterna e output nuovo esterno all'SDK.

Corrected introduce winding Mode2 signed24 sulle X schermo complete, trasformazione
camera separata dopo la composizione nel mondo, riporto signed16 X/Y locale/origine,
prodotti Q6 al più vicino con saturazione signed8 e arrotondamento camera intero
al più vicino (metà verso infinito positivo). Buffer originali e raster rimangono.
Punti mondo interi condivisi non dipendono più dall'origine del chunk nei casi
qualificati con traslazioni a identità. Non è una promessa di cuciture esatte
fra mesh arbitrarie trasformate indipendentemente.

È un profilo numerico di compatibilità, distinto da legacy-plus. Gli angoli
camera restano a byte (1,40625gradi), i coefficienti Q6 e il near intero.
Le prove native Mode2/Mode4 dev1 sono storiche, non una nuova promessa FPS1.13.0.
Usare [legacy-plus](LEGACY-PLUS.it.md) per la qualifica Mode1–7 near/camera corrente.
Non si deduce una nuova qualifica Ground, altri modi, NTSC o hardware.

I controlli aritmetici indipendenti richiedono build esterne prima/dopo fornite
dal chiamante; nessuna demo o fixture compilata è distribuita:

```powershell
python -B scripts/test_legacy_stability.py --before ../control-build --after ../corrected-build --out ../numeric-check.json
```

[Precisione](PRECISION.it.md) · [Test](TESTING.md)
