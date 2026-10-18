# Qualificazione — 1.13.0

Dei93 input work,92 sono byte-identici alla dev7. Solo il builder è normalizzato
da CRLF al formato LF documentato: otto ricompilazioni dei progetti nativi sono
byte-identiche. La preparazione stabile non cambia l'aritmetica del renderer. L'identità dei PRG nativi viene verificata dopo la build del
pacchetto finale. Programmi misurati identici riusano le prove native effettive:
nessuna stima FPS viene attribuita a un eseguibile diverso.

VICE Turbo6510 MOS8565 PAL ×64, clock base985248Hz,312×63cicli/refresh, safe,
Colodore, filtro0, senza musica/audio. Mode2/walkLite/normal/high-basic-v2/senza
overlay, near-poly ordinario, senza Ground; qualità fast, extended-table,
area/span0. Camera: toroide statico126vertici con movimento XYZ/yaw/pitch.
Clipping: triangoli adiacenti con origini diverse attraversano near8/schermo
e ritornano. Nessuna fase ferma.128 eventi di simulazione di warm-up, poi un
giro completo2048tick. Solo nuove viste complete dopo swap su `fps_frame_done`;
contatore e traccia concordi. Warp e tempo host non entrano negli FPS. Opzioni
launcher, timestamp grezzi, RAM, PNG, input e comandi effettivi sono conservati
fuori dalla distribuzione sorgente.

| Caso | Warm-up s | Secondi emulati | Viste nuove | FPS medi | p95 ms | Peggiore ms |
|---|---:|---:|---:|---:|---:|---:|
| Plus camera |2.589751|40.858229|1024|25.062271|39.900614|39.900614|
| Plus clipping |2.589750|40.858229|1683|41.191213|39.900614|39.900614|

SHA256 dei PRG misurati:
- Camera: `7755e1b1fdaf8dc9dbe0d362056953cb050cf358e4c1ee06b6721febd6d72223`.
- Clipping: `662ef5aa393285360c900b0ebb90df79360d9033e52b9530bef4dc043f92bf30`.

Prima: camera plus dev6 a25,050044FPS, massimo59,850921ms; clipping41,191213FPS.
Una seconda traccia nativa inizio/fine/presentazione e un offset di fase input
verificato di un tick ripetono la nuova cadenza camera. Tutte le658 immagini
native plus ferme coincidono con dev6, entrambi i buffer VIC sono stabili e
non si osservano nuovi residui senza spigoli sorgente, scomparse inattese,
perdite dietro al near o divergenze dei vertici originali condivisi.
L'oracolo float indipendente verifica la geometria osservata, non prova un
raster pixel-esatto. Precisione Q4, fallback ampio e raster intero rimangono.

Altri modi/layout, hardware, NTSC e complessità arbitraria non ricevono nuove
garanzie native FPS o di errore. I rapporti storici corrected/camera/rotation
conservano il proprio ambito. I riferimenti default legacy/Q8 si riusano solo
dopo identità PRG esatta. Il JSON aggregato corrente contiene hash, conteggi,
condizioni, metriche e limiti, senza scene, percorsi o catture grezze.

[Qualifica leggibile dagli strumenti](QUALIFICATION-1.13.0.json) ·
[Legacy-plus](LEGACY-PLUS.it.md) · [Test e riproduzione](TESTING.md)
