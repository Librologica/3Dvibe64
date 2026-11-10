# Agentic30 — 1.15.2-dev-agentic30

Unpublished development from delivered agentic29. [Italiano](AGENTIC30.it.md).
[RuntimeScene](RUNTIME-SCENE.en.md) · [Dynamics](DYNAMICS.en.md) ·
[Qualification](QUALIFICATION-AGENTIC30.json).

This development extracts reusable renderer and dynamics primitives from the
application work. There are no bundled scenes, models, demos, music, videos,
launchers for a game or application-specific rules. Existing official releases,
frozen demos and deprecated work are preserved. No stable promotion/publication.

The new explicit `runtimeScene` Scene1 compiler supports ordinary LegacyPlus
Mode4/5/6 walkLite normal/high-basic-v2/NoFpsOverlay. Opt-in renderer features:
active-mesh coordinate products with complete cache ownership, rigid compound
matrix restore, conservative object rejection, mixed fixed/frozen/dynamic light,
local-space face-color bake, exact uniform Gouraud fill and configurable brighter
shade curve. Default renderer output/quality/precision remain the parent path.

Optional modules provide Q8 camera lag/shortest angles/bank and proximity/LOD
hysteresis, coherent dynamic focal and Q10 view roll, atomic pose copying, a
shared floating origin, independent simulation/cosmetic random streams, bounded
random-volume particles, planar convex SAT and a budgeted callback contact
scheduler with rollback. Host compilation helpers select distinct fragment
templates, calculate volume-aware Q6 child scales and mass-balanced spawn data.
No continuous full3D physics, arbitrary mesh cutting, complete gameplay AI or
automatic collision response is claimed. The ABI and domains are explicit.

Presentation options preserve the unused bitmap tail, avoid repeated fixed
background writes and expose a bounded precommit hook. They require application
ownership discipline; they do not magically double-buffer color RAM or allocate
sprite resources. Existing circle impostors are reused for projectiles rather
than introducing another rasterizer.

All native additions have named private state in existing bounded Plus allocation
blocks. No scratch aliases or fixed addresses from the application are imported.
No widened allocator windows or hidden lower-quality fallback. Not every optional
module combination fits Mode6 RAM; build/map failures remain explicit. AnimatedMesh
is unchanged, and its mutable coordinate ownership is not combined implicitly
with the immutable RuntimeScene path. Existing8 rendering modes are preserved.

Public tests validate host contracts and execute assembled6502 routines against
independent oracles; CPU correctness callbacks never supply FPS. External native
qualification uses actual VICE Turbo6510 PAL1x/20x/64x, original suite SID active,
128-refresh warm-up (~2.554s),1024 measured refreshes (~20.429s),16-pose routes,
new complete views only. Defaults and new opt-ins are separate campaigns, with
before/after pixels, raw clocks/commands/hashes, intervals/p95/worst and stationary
versus moving phases. Hardware/NTSC qualification is not implied.

The fixed performance-v1 index and suite1.1.0 workloads are not changed. New
RuntimeScene cases use a separately identified extension. Prior versioned notes
and qualification ledgers remain immutable historical records; the current
ledger records actual coverage, inherited build blocks and local regressions.
Measured source staging and final runtime identity are audited outside this SDK.

Native validation run:81 cold default builds,54 measured cases/162 native cells,648 parent-identical captures,27 inherited build blocks,0 new default blocks.13 separate optional cases/39 native cells;72 exact before/after pixel checks.12 final-source cold rebuilds match measured PRG hashes. Existing circle API verified with focal64/100/170/254 and rolled world transforms on a minimal profile; the larger two-object combination exceeds RAM. Optional costs and raw FPS/p95/worst are in the external ledger; no general FPS gain is claimed.

The automatic historical comparison and fixed performance-v1 index are blocked by a changed PowerShell executable hash. PRGs/labels/pixels match the parent, and new opt-in before/after runs use the current tools, but a complete compatible historical qualification is not claimed.
