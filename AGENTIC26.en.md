# Agentic26 â€” 1.15.2-dev-agentic26

Unpublished development from delivered agentic25. [Italiano](AGENTIC26.it.md).
Current ledger: [QUALIFICATION-AGENTIC26.json](QUALIFICATION-AGENTIC26.json).
Earlier versioned ledgers are immutable history. Mode1â€“7 and AnimatedMesh v1
retain the parent runtime/API sources. No public API or quality/default change.

Mode8 multi shares the exact all-zero projected profile. After the unchanged
projection and clipping prove a cached profile is entirely zero, its key maps
to sentinel $fe and its ordinary slot becomes empty. Repeated requests return
one immutable128-byte profile. The32 ordinary slots /4096 bytes keep their
second-chance policy for every other profile. Full-profile calls with lazy_mode=0
still fill the caller's original destination. Per-view key-map reset remains.
The getter uses Y as volatile scratch; every recognized caller initializes Y
before reading samples. Shared zero entries never participate in slot eviction.

The128-byte zero table and24-byte helper occupy $ca20..$cab7, immediately after
the inherited32 replacement flags, inside the original $ca00..$caff layout_support
window. Total coefficient/state data is608 bytes, including128 shared samples;
the4096-byte slot storage and485-byte plane-unit cache remain separate.
No allocator window or scratch alias is added. Low code stays below $3000.
Auto and interactive multi templates share the implementation. Mono templates,
projection arithmetic, geometry, sample values, font, colors, camera, collision,
music, and image publication remain inherited. No zero profile is approximated.

Technical Debug uses paused-only reads and matching PRG/labels. maincpu_clk is
PAL machine time, not accelerated internal CPU cycles. Native tests use the
same VICE Turbo6510 executable, PAL1x/20x/64x, original benchmark SID,128 refresh
warm-up and at least1024 measured refreshes (20.429s). Only new complete views
count. Targeted three-repeat and long-window checks supplement performance-v1;
its12 original stress cases/36 cells, reference and weights remain fixed.
CPU callbacks check correctness only. Holdouts are final validation only.
Hardware and NTSC are not newly qualified. Read the ledger for measured scope.

Builds, scenes, models, music, PRGs, captures, reference SDKs, trials and commands
are exclusively external in 3Dvibe64_Verifiche_1.15.2-dev-agentic26_2026-11-05. This dev and its ZIP contain source/docs
only. No publication or stable promotion. At each new dev/release verify suite
alignment and compare both the previous dev and official stable1.15.1.

Final validation:54 buildable cases /162 native cells;648 captures match parent,27 inherited build blocks and0 new.22 default public gates pass. Overall index 131.672274975, parent 130.594894169, stable1.15.1 117.647645352. Mode8 stress64x 46.991758 → 50.124542 FPS (+6.667%), render -4.970%. Three ordinary repetitions at all speeds and three81.716s64x windows per side confirm the change.5120 cached requests across5 poses and1120 full128-sample profiles match parent; stack and slot/key invariants hold. Technical Debug pose0:94 →86 misses,19623 →18243 machine cycles. Canonical low-code margins3 bytes auto /1207 interactive; layout support ends $cab8. Auto native-measured, interactive assembled/shared-kernel verified without new native timing. All53 other benchmark programs and all Mode1–7 implementation sources are identical to parent.420 source/doc files; verification external.
