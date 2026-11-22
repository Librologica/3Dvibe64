# Qualification — 1.20.1

Stable source SDK. Verified 20 programs by a clean rebuild. Qualification inherits 44 native PAL benchmark results from byte-identical programs with matching numeric symbols. The original tests used VICE Turbo6510 with SID active, 128 warm-up IRQ hits and 1,024 measured refreshes, approximately 20.43 emulated seconds per case.

The reconstructed historical index on the 1.15.0 = 100 scale is **145.481**, compared with **137.506** for the previous public release (+5.800%). The canonical calculation is blocked by VICE and PowerShell binary differences at the historical anchor.

A supplemental mixed wire/solid case retains its existing layout build limit. The qualification ledger contains coverage, FPS, P95 and worst frame intervals.

[JSON](QUALIFICATION-1.20.1.json)
