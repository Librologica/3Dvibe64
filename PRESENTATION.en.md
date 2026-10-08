# Safe bitmap presentation (Modes 1–7)

The old renderer returned from `wait_raster` just after raster 240, toggled the software draw buffer and immediately reused the old front buffer. The VIC-II bank/D018 update occurred in the following raster IRQ. At high CPU speed, clear could therefore erase the bottom of an image still being scanned out. The defect was reproduced on PAL/NTSC Mode 7 complete and fast demo builds; it is not evidence of a geometry or texture-sampling fault.

`-FramePresentation safe` is now the default. It waits for raster 252 to end, beyond the displayed bitmap area, before permitting the next clear/dirty-clear. The next IRQ establishes the newly selected front before visible scanout. The same rule applies with and without the text split and with runtime low-resolution controls. No sampled rows, palettes, shading or geometry are changed. The additional wait can affect native pacing; it does not increase the renderer's CPU work.

`-FramePresentation legacy` retains the old synchronization strictly for diagnosis and historical PRG reference checks. Old expected hashes are retained under this explicit option, not rewritten to conceal differences. The release's default PRGs intentionally differ because of this fix. Mode 8 has its own publication protocol and rejects this option; its renderer is unchanged.

The source SDK contains compiled-routine timing-model tests. The candidate qualification records real VICE IRQ/clear traces and framebuffer replay separately. Test coverage is not proof for every third-party IRQ, accelerated platform or real machine. External code must preserve the engine's buffer and IRQ ownership. Do not reintroduce asynchronous early clearing to gain apparent FPS.
