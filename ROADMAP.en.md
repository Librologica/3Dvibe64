> Development edition 1.15.0-dev2; inherited1.14.0 contracts remain unless explicitly extended in [exact rendering](EXACT-RENDER.en.md).

# Roadmap — 1.14.0

Included: exact opt-in renderer flags, MAT-01 packed spans, conservative wall adapter, static pattern/palette helpers and optional pool/camera/SID primitives. Existing billboard, materials, entity, visibility, shared mesh, controlled motion, WORLD-01 and LEVEL-01 contracts remain bounded.

Future work: general scene integration, arbitrary intersections/transparency, general occlusion, angular portals, dynamic textured shadows, persistent disk saves, a combined WORLD lifetime allocator and broader backend qualification. A helper is not a complete implementation of these integrations. No new demos will be bundled.

[Contracts](RENDER-OPTIMIZATIONS.en.md) · [Support](ADAPTER-SUPPORT.en.md) · [Qualification](QUALIFICATION-1.14.0.en.md)


## 1.14.0 application boundary

Legacy-plus Mode1–7 and Mode7 affine/perspective are stable within the [public plus profile](LEGACY-PLUS.en.md). The private Underworld port uses a different viewport, loader/RAM layout, culling and material/LOD/sampler optimizations; these are not public defaults or a new generic gameplay ABI. The reusable gameplay adapters retain their existing precision/profile restrictions. See [stable promotion scope](RELEASE-NOTES-1.14.0.en.md#distribution-and-private-application-boundary).
