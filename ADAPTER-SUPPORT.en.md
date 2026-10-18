# Optional adapter support — 1.13.0

`extensions/gameplay/runtime_support.py` exports native assembly emitters and
host tables. They are opt-in primitives for external adapters, not an automatic
Backrooms generator, a route, a music player payload or a general game API.
No hook is installed into an ordinary scene unless the caller connects it.
Returned code/data has no fixed placement: the adapter must include it in its
actual assembled memory budget, preserving guards and bank visibility.

## Bounded resident pool

`resident_pool(slots,callback,prefix='pool')` returns6502 source. Slots1..32;
callback/prefix must be safe assembly symbols. Call pool_init once, then
pool_next when the application needs a recycled room/chunk. X=slot,
A=generation low,Y=high enter the callback. The callback must preserve X and
return carry set only after it has installed a complete valid slot. Failure
keeps cursor and generation; the application retries or handles the error.
Success marks the slot valid, increments the16-bit generation and wraps the
cursor modulo slots. Data is3+slots bytes, plus emitted code; generation wraps
at65536. Inactive state, world coordinate recentering, collisions, connectivity,
PRNG and geometry generation are application responsibilities. This is not
WORLD-01 disk loading or an unlimited persistent history. A constant-size
resident pool can support continuous procedural traversal through caller logic.

## Camera tables

`camera_tables(samples=256,step_height=0.18,bank_degrees=2.5,
glance_degrees=6.0)` returns bob/bank/glance signed16 arrays. Samples16..256;
finite nonnegative height<=4WU, bank<=30degrees, glance<=45degrees. Bob is WU Q8;
angles use signed16 Q8 phase,65536 units/turn. `camera_assembly(tables,
prefix='gait')` emits low/high byte planes:6*samples data bytes. Caller selects
tick progression, turn sign, glance timing, look-ahead target and Q8 camera
bindings. No path, per-frame trig, immersive controller or roll hook is hidden
inside the generator. Existing Q8-02 roll integration remains separately bounded.

## SID interface

`parse_sid(path,subtune=1)` reads an external PSID v2..4 and returns load/init/play,
payload, subtune,title,author. Rejects RSID, malformed ranges, missing play,
CIA timing, NTSC-only and multiple SID-chip headers. Zero load uses the little-
endian payload prefix. No relocation or compatibility proof is inferred.
MUS/PSID-specific drivers are not supported. The caller must audit actual
writes, reserved RAM/zero-page and all bank requirements before integration.

`sid_wrapper(init,play,zp_start=0xf0,zp_count=8,bank=0x35,subtune=1,prefix='sid')`
emits sid_init/sid_tick plus bank/ZP swap routines. Entry points$0200..$ffff,
1..32 contiguous audited zero-page bytes starting at$02 or later and fitting
within zero page, subtune1..256. Init passes zero-based subtune in A,X=Y=0.
The wrapper preserves P, $01 and the engine's chosen zero-page range, keeping
separate persistent player ZP. It disables interrupts while swapping and is not
reentrant; A/X/Y are clobbered, so the outer IRQ must preserve them. Tick must
be called exactly once per PAL refresh, independent of rendered frames. Data
cost is3+2*zp_count bytes plus code. Code/data must remain mapped under both
banks; no overlap with runtime, video, stack or player. SID payload loading,
relocation, channel volume/mixing and IRQ registration belong to the caller.
No SID song is distributed. See [raster contracts](RENDER-OPTIMIZATIONS.en.md).

## Verification

Self-contained assembled tests execute the pool success/failure path,1024
synthetic player calls with bank/ZP restoration, camera bounds and native span
math. They do not measure FPS or establish arbitrary SID compatibility.
Native performance and image tests use external projects and are listed in
[qualification](QUALIFICATION-1.13.0.en.md). [Inputs](EXTERNAL-INPUTS.en.md).

Pool callbacks must stage their writes or restore the old slot on failure: the manager does not roll back arbitrary geometry writes. Use unique assembly prefixes when emitting multiple helpers.
