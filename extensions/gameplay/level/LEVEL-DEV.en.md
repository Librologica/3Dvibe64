# Common level format and exact memory budget — 1.14.0

Stable release 1.14.0: [current optimizations](../../../RENDER-OPTIMIZATIONS.en.md), [external inputs](../../../EXTERNAL-INPUTS.en.md). All demonstration projects and raw native evidence remain external to the source distribution.


Current 1.12.0 distribution ships the reusable module only. New demo projects/assets are excluded. Source captures, checkpoint numbers and native measurements below describe historical external proofs. Native project builds require explicit `--project-source`; see the [integration guide](../../../GAMEPLAY.en.md).


`work/build-level.py` resolves IDs/assets and lowers groups, rooms, objects,
connections, spawns and events into the already qualified native WORLD-01
adapter. The buildable example reproduces its native program/group data
without generic runtime tables or extra resident RAM. The adapter remains
two divider rooms, one guardian/door per group and shared assets. Requests
outside that backend are diagnosed and rejected, never silently omitted.

```powershell
python -B work/build-level.py --level ../my-level/level.json --validate-only
python -B work/build-level.py --level ../my-level/level.json --out ../level-build --project-source ../my-project
python -B work/qualify-gameplay.py --out ../level-build/native --benchmark --launcher
python -B work/build-level.py --level ../my-level/level.json --plan-only --out ../level-plan
```

Output is new/outside sources and inputs. `launch-level.cmd` launches an
accepted build. `build.json` records result/hash; native project is in `native`.
`memory-budget.json` records actual assembled ranges/accounting. `level/`
contains original, dense-reference IR, copied assets and relocatable `level.json`.
Host compiler uses Python standard library. `--validate-only` writes nothing.

The planning example requests additional mesh/guardian/modules. `--plan-only`
returns `buildable:false` and reasons without a PRG or measured budget. A
normal build rejects unsupported integration before creating output. Data
validity and backend availability are distinct checks.

## Format1

`level.schema.json`, ID `urn:3dvibe64:level:1`, covers syntax. Python also
checks references/assets/geometry/events/backend compatibility. Unknown fields,
duplicate JSON keys, NaN/infinity and Booleans in numeric fields are rejected.
Globally unique IDs start with lowercase letter, then lowercase letters,
digits/hyphen, at most 48 characters.

| Field | Meaning |
|---|---|
|schema / format / id|1 / `3Dvibe64.level` / level ID|
|axisConvention|`world-z-up`: X right,Y forward,Z up|
|target|PAL,multiplier 64,precise,LOD[14,22],music:false,Boolean autoTransitions|
|memory|reserveBytes,minimumContiguousBytes,stagingBytes 1024|
|features|explicit integration requests; empty in buildable example|
|assets|ID,type billboard/materials/mesh,source|
|groups|ID,geometry template,materials,entry|
|rooms|ID,group,XYZ volume bounds|
|objects|ID,type,room,position,type-specific properties|
|connections|local doors or reciprocal group transitions|
|spawns|room,XYZ,yaw,pitch entries|
|events|used object and ordered actions|
|start|initial spawn ID|

Positions/volumes are finite multiples 1/256 WU, mesh scales 1/64. IR stores
Q8 XYZ and 16 bit spawn angles. References become dense indices by category,
initial group index 0; IDs remain in diagnostics, not 6502 addresses/routine names.

Built-in demo assets are excluded. Caller-supplied `file:assets/name.json` is relative to level directory
and must remain inside it after symlink resolution. Absolute/escaping/remote
paths are rejected. Reports store asset hashes/sizes; equal content is shared
rather than duplicated merely because IDs differ.

## Rooms, connections, objects and events

`two-room-divider-v1`: halfWidth 18–24, floorLevel null/0–32, doorIndex 1–3.
Front bounds[-width,-24,-10]..[width,8,18], rear[-width,8,-10]..[width,24,18],
frontal spawn[0,-20,0] yaw/pitch 0, door[0,8,-10] size[10,18]. `doorway`
references both rooms and door. One `group-transition` record names rooms
in different groups and their return/arrival spawns, defining a reciprocal
link. Graph connected; WORLD-01 permits 1–2 neighbors per group. Transition
spawns must be that group's entry. N/P is an explicit switch, not continuous
traversal of the described boundary. Automatic route is qualified for two
groups;2–8 groups with autoTransitions:false use explicit controls. The initial
48-key diagnostic camera requires the first door closed.

`billboard`: asset,XYZ,size[width,height],idle/used animations,useRange,
collisionHalfSize,used state. Asset 16 × 32,1–6 frames,transparent 0/opaque black 4;
existing compiler validates cadence/frames. `sliding-door`: XYZ,size,open.
`mesh`: asset,XYZ,yawDegrees,scale,visible,level is representable/validated but
WORLD-01 reports its missing integration and refuses compilation.

Default event uses guardian: first `toggle` its own door's open field, then
`animate-from` on guardian bound to door(false→idle,true→used). References
stay in the active group. Backend recognizes this pair using existing native
logic; it does not supply a generic action dispatcher. Initial guardian used
and door open must agree. IR maps logical IDs to 17 byte native slots including
visit flag/cursors/lift/state/counts. Inactive groups freeze, RAM-session only.

## Actual assembled budget

The report reads final build metadata, allocation, symbols and PRG hash.
It verifies legal windows, no overlaps, exact allocated/free partition,
sizes/growth guards, ROM-visible loader addresses, staging and persistent
slots. A sum of free bytes does not establish contiguous allocation capacity.

|Item|Bytes|
|---|---:|
|Legal relocatable helper windows|26018|
|Allocated including guards|25012|
|Payload inside blocks|24567|
|Remaining growth guards|445|
|Actually free|1006|
|Largest raw gap|965|
|Largest 2-byte-aligned capacity|964|
|Chosen minimum reserve|512|
|Beyond reserve|494|

39518 bytes outside the windows are fixed code/buffers/video/hardware/reserved,
not additional free memory. Resident staging 1024, active data 748,17 bytes/group,
source frames, decoded 512 byte cache and renderer buffers are already counted,
not added twice. Two 762 byte files occupy 1524 external bytes; only one is staged.
`reserveBytes` is an acceptance threshold, not an allocation.
`minimumContiguousBytes` uses 2 byte alignment. Failure keeps reports/assembly
but omits level launcher. An 8-group/48-key build leaves 460 bytes and fails a
512 byte reserve despite being assemblable.

## Lifetime integration plan: not applied to WORLD-01

UI decoder,12 compressed blocks,directory/dictionary occupy 3759 allocated bytes
(3639 payload+120 guards). In this backend they remain reserved after startup.
Proving unreachable from gameplay/loading/IRQ/reinitialization and adding a
phased emitter/loader are prerequisites to reuse; one textual init reference
is not proof. The separate Underworld experiment actually reuses 2904 bytes,
but that does not free WORLD-01's 3759 bytes or combine its modules.

Hypothetical verified recovery:4765 free bytes, maximum 2905 raw/2904 aligned.
The unapplied host plan reserves 2048 resident extension bytes($BBCC–$C 3 CC),
512 event/entity bytes($CC 3 C–$CE 3 C),512 safety threshold and 1693 unassigned.
Extensions would load once after UI and stay resident across group switches;
not evicted while animation/door/IRQ uses them. A 2048 byte startup extension
needs its own validated loader: current WG01 staging stays 1024. Startup
failure must prevent entry into incomplete code. Old complete view, active
geometry, staging, state and KERNAL backups coexist on transitions and are
not overlapped in the plan. Costs of separate profiles cannot establish that
their combination fits; an integrated assembly/qualification is required.

Tests cover references/events/portable safe assets,2–8 groups, ID order
independence, explicit unsupported-plan rejection, overlaps/holes/guards/
fragmentation/alignment. The default program/group files match WORLD-01.
Inherited native timing: PAL× 64, precise/LOD,silent,101 refresh warm-up,
3072 refresh A→B→A measurement. No new FPS comes from the hypothetical budget.

[Italiano](LEVEL-DEV.it.md).
