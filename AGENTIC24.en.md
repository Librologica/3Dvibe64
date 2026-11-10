# Agentic24 â€” 1.15.2-dev-agentic24

Unpublished development based on delivered agentic23. Official releases, parent
SDKs and frozen demos are preserved. No GitHub tag, release or stable promotion
is created. [Italiano](AGENTIC24.it.md) Â· [AnimatedMesh contract](ANIMATED-MESH.en.md).

## Implemented reusable changes

- Native `AnimatedMesh v1`: shared indexed source geometry and compressed
  vertex-pose clips, independent per-instance phase/step and exact interpolation.
- Packed0/1/2/4/8-bit streams, cross-clip/asset deduplication and constant-column
  decoder paths. There are no zombie-specific counts or geometry branches.
- A source-content pose cache avoids repeated decoding; it tracks the last pose
  actually stored in a shared source, including switches between instances.
- Optional Mode6 frozen reference lighting: shade values are calculated on the
  instance's first visible shaded view and reused until explicitly invalidated.
- Ordinary object movement, camera, clipping, depth ordering, Gouraud raster and
  projection are reused. Animation cadence and world velocity remain independent.
- Native API for clip selection, animation reset and light invalidation. The
  existing bounded allocator places all new code/data without expanding windows.
- Explicit `compact-gouraud` profile: pure Mode6 can omit unreachable non-Gouraud
  fillers after profile/application-reference guards, with observable entry traps.

The new profile is opt-in and bounded: ordinary legacy-plus Modes4/5/6,
walkLite, normal viewport, high-basic-v2, NoFpsOverlay. Existing scenes use their
original generation path. Defaults, texture LOD, quality and public workloads
are unchanged. The private zombie application's UI/floor renderer is not copied
into the generic builder. The complete format, arithmetic, reset semantics,
memory costs and rejected combinations are in the paired API manual.

## Optimization discussion: what is inherited and what remains separate

Agentic23 already contains exact coherent Gouraud byte interpolation, projection
division variants, bounded placement, material caches and the qualified integer
edge/outline paths. Those implementations are retained. Their historical results
are in [agentic23 notes](AGENTIC23.en.md) and the immutable qualification ledger;
they must not be reported as newly achieved agentic24 gains.

The private zombie renderer's byte-aggregated halos, temporary floor/Gouraud
scratch reuse and reduced floor tables depend on that
application's lifetime and viewport assumptions. They are not enabled as global
engine defaults. Filler omission is limited to the new explicitly guarded pure
Gouraud profile. There is no global table shrink, disabled graphics mode or
benchmark-specific fast path. Dynamic deformed normals, bones, arbitrary root
motion and the Mode7 textured/UI integration remain future work, not v1 features.

## Verification and evidence

The [current ledger](QUALIFICATION-AGENTIC24.json) is authoritative for this dev's
measured status, hashes, native FPS and coverage. Historical ledgers retain their
original identities. Source documentation tests check current IT/EN pairs,
links, manifest hashes, source-only packaging and unpublished metadata. Host
and6502 correctness checks do not measure FPS.

Native timing uses PAL Turbo6510 at1Ã—/20Ã—/64Ã—, original benchmark SID music,
warm128 refreshes and at least1024 measured refreshes, complete new views only.
Raw commands, traces and builds remain in the external development evidence;
the source ZIP contains no scenes, PRGs, demos, soundtrack or captures. Compare
unchanged workloads with parent and official stable, retaining inherited build
blocks and fixed index weights. No stock-hardware or new NTSC qualification is
implied. See [testing](TESTING.en.md).

## Final validation / Verifica finale

54 unchanged programs and all numeric labels;162 fresh native catalog observations,648 matching parent captures;27 inherited build blocks,0 new. Fixed index 129.982745981, parent 129.982556846.22 public gates and current bilingual audit are required for the sealed delivery. Additional native AnimatedMesh tests cover Modes4/5/6 at1×/20×/64×. At64×, two original standing models achieve16.740814 FPS and two crawling models20.607844 FPS, tested separately on black background with original benchmark SID and real object movement. Each window is20.429s after128 warm-up refreshes. Compact/generic captures match in12 paired native comparisons. These additional workloads are outside the fixed index, not a comparison with the private floor/UI demo. No demo, model, music, PRG or capture is included in this dev or its source ZIP. Raw verification is external in 3Dvibe64_Verifiche_1.15.2-dev-agentic24_2026-11-04.
