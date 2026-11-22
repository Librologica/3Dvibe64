# Dynamics — 1.20.1

> Stable source SDK 1.20.1. [Qualification](QUALIFICATION-1.20.1.en.md).

[Italiano](DYNAMICS.it.md).
[RuntimeScene](RUNTIME-SCENE.en.md) emits optional native helpers. Host references
and compiler utilities are in `extensions/gameplay/dynamics.py`. They include no
gameplay policy, models, sounds, AI, score or demo. This is planar convex contact
support with3D camera/particle data, not a full3D rigid-body engine.

`support.sat: {}` emits `rs_sat_query`. Input `rs_sat_a_count`/`rs_sat_b_count`
3..16; SoA `rs_sat_a_x`, `rs_sat_a_z`, `rs_sat_b_x`, `rs_sat_b_z` hold ordered
convex vertices in a **common local integer domain[-63,63]**. Transform/recenter
application colliders into that domain before calling. It is not the render
mesh, a bounding box approximation, or an automatic collider extractor. Use
`convex_polygon` on authored shapes to reject degeneracy, concavity, duplicate
vertices and crossing edges. Runtime checks counts/ranges; it trusts convexity.

The native query first checks two AABB axes, then the cached separating axis,
then every edge normal of both polygons. Projections use exact signed16 integer
arithmetic; no square roots or normal normalization. Touching is contact. C=1
means overlap/status0; C=0 means separated/status1 or invalid/status2 in
`rs_sat_status`. On separation `rs_sat_cached`=1 and `rs_sat_cache_axis` contains
two signed8 components. Save/restore those three bytes for caller-owned per-pair
caches, or leave the last axis: a stale axis may reject safely but never proves
overlap. Clear cached validity after replacing ownership if desired. The API does
not return a contact manifold or penetration impulse.

`support.contacts` fields:

* `bodies`:2..16; `passes`:1..16(default4); `pairBudget`:1..65535(default256).
* `query`,`resolve`: assembly callback symbols. Both receive X/Y=body IDs.
  Query returns C=1 for an eligible contact; resolver changes application state
  and returns RTS. Both may use SAT/private application math but must not edit
  scheduler-owned rs_contact_ state or call the scheduler recursively.
* `positions`:1..6 SoA `{low,high}` symbol descriptors with `bodies` entries.
  Register every position/camera-independent integration channel to restore.
* `velocities`:0..6 corresponding signed16 SoA descriptors, damped by arithmetic
  right shift on rollback. No automatic angular/inertia model is implied.
* Optional `priority`: body index. Every pair containing it is scheduled first
  on each pass; other pairs follow in stable order.

Tick sequence: call `rs_contacts_snapshot` **before integration**, integrate
application motion, then `rs_contacts_solve`. It queries each pair at most once
per pass, stops after a pass without contacts, and never exceeds the query
budget. C=1/status0 (`rs_contact_status`) means convergence; C=0/status1 means
budget/pass exhaustion, restores the snapshot and halves registered velocities.
C=0/status2 means no valid snapshot; take a new snapshot for every tick.
`rs_contact_queries` is a16-bit counter, `rs_contact_pass` the zero-based pass.
The budget bounds scheduling work, not arbitrary work inside callbacks.

Filtering distant/asleep bodies, temporary sibling grace, priorities, continuous
projectile tests and response are application policies. Keep projectile/player
eligibility independent from sibling grace and render visibility. If the budget
cannot even cover the required priority pairs, the explicit rollback remains
the result; contacts are not silently disabled to report higher FPS. The host
`solve_bounded` reference offers the same stable pass/query policy with Python
callbacks (its snapshot is taken when called).

Compiler/reference utilities:

| Function | Purpose |
|---|---|
| `smooth`, `Hysteresis`, `easing_table` | Q8 position/shortest-angle filtering, proximity/LOD thresholds, compile-time smooth transition samples. |
| `sphere_outside`, `rebase`, `grid_anchor` | Conservative camera-space bounds, common-offset channels, floor-snapped single square lattice even across negative cells. Grid topology/projection belongs to the application. |
| `lfsr16`, `sphere_sample`, `advance_particles` | Independent deterministic random oracles, bounded random-volume samples (zero fallback after attempts), signed16 motion/lifetimes. Cosmetic sampling does not consume simulation RNG. |
| `convex_polygon`, `broad_aabb`, `sat_overlap` | Validate ordered convex input and exact integer planar reference tests with an optional cached axis. Host reference supports wider integers than the native bounded ABI. |
| `mesh_volume` | Closed, consistently wound triangle/quad mesh volume by tetrahedral sum. Rejects open/mismatched winding/nonzero-volume failures; does not certify arbitrary self-intersecting3D topology. |
| `binary_fragment_scales`, `fragment_choices`, `fragment_plan` | Compile binary child scales from actual template volumes; two distinct children different from parent. Q6 plan reports relative quantization error and rejects unrepresentable scales instead of clamping. No cube roots at runtime. |
| `fragment_spawn` | Two nearby mass-balanced centers and velocities; separation0..1, impulse>=0, fraction0..1 exclusive, siblingGrace0..255 metadata. Preserves weighted COM and linear momentum in the reference; application converts to native precision and applies eligibility. |
| `solid_lamp_colors` | Compile local point-lamp VIC-II face colors, including emissive face overrides. Used by `runtimeScene.solidLamp`; not recalculated with camera/object motion. |

Fragment helpers require application-supplied templates and volumes. They do
not cut an arbitrary mesh, make children inherit identical parent geometry, or
claim exact volume after Q6 quantization. Choose templates/scales whose reported
error meets the application budget; keep spawn centers near the parent and use
brief sibling-only grace while they separate. Durability, incoming traffic and
player energy are game rules, deliberately absent from the engine.

Run public `scripts/run_release_tests.py` in a working copy. New tests assemble
the actual6502 helpers and compare independent host references; they never call
CPU execution time FPS. Native PAL benchmarks, raw cycles/commands/PRG hashes,
coverage and limitations are recorded separately in the qualification ledger.
