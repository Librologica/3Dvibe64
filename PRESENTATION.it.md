# Presentazione bitmap sicura (Mode 1–7)

Il renderer precedente usciva da `wait_raster` subito dopo il raster 240, scambiava il buffer software e riutilizzava immediatamente il vecchio front buffer. Il VIC-II aggiornava banca/D018 nell'IRQ raster successivo. Con CPU veloce il clear poteva quindi cancellare il fondo di un'immagine ancora in lettura video. Il difetto è stato riprodotto nelle demo Mode 7 complete e fast PAL/NTSC; non indica un errore geometrico o di campionamento texture.

`-FramePresentation safe` è ora il default. Attende la fine del raster 252, oltre l'area bitmap visualizzata, prima di consentire il clear/dirty-clear successivo. L'IRQ seguente imposta il nuovo front prima della scansione visibile. Vale con/senza split testuale e con controlli runtime di risoluzione ridotta. Non modifica righe campionate, palette, shading o geometria. L'attesa aggiuntiva può incidere sulla cadenza nativa, non sul lavoro CPU del renderer.

`-FramePresentation legacy` conserva la sincronizzazione precedente esclusivamente per diagnosi e verifica dei riferimenti PRG storici. Gli hash attesi restano con questa opzione esplicita: non vengono riscritti per nascondere divergenze. I PRG di default della release differiscono intenzionalmente per la correzione. Mode 8 ha un protocollo proprio e rifiuta questa opzione; il suo renderer resta invariato.

Lo SDK contiene test di temporizzazione delle routine compilate su modello. La qualificazione della candidate registra separatamente trace IRQ/clear VICE e replay framebuffer. La copertura non prova ogni IRQ esterno, piattaforma accelerata o macchina reale. Il codice esterno deve rispettare la proprietà di buffer e IRQ dell'engine. Non reinserire il clear asincrono anticipato per guadagnare FPS apparenti.
