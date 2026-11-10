# 3Dvibe64 1.15.2-dev-agentic18

Unpublished development from the exact published stable 1.15.1 source tree. This
is a new branch for rendering research, not a stable release or a GitHub tag.

The consolidated wire rasterizer divides the horizontal distance by the vertical
distance once per edge, then advances by the quotient and at most one remainder
correction per scanline. Connected inclusive pixel coverage is unchanged. The
known emitted walker and viewport Y<128 are required; other shapes retain the
parent code. Existing private dxabs/errhi scratch is restored before the final
flush. No new RAM variables, lookup tables or stack allocation are introduced.

The exact clipping divider specializes denominators <=255, keeping the remainder
in A and explicitly setting the quotient bit after overflow subtraction. Wider
denominators use the shifted carry as the seventeenth remainder bit. Integer
results, scratch, A/X/Y and architectural flags retain the parent contract.

Public API, workload, image quality, defaults and allocator windows are unchanged.
The stable QUALIFICATION-1.15.1.json and versioned reports are immutable history;
they do not qualify the changed runtime. Current evidence is external in
../evidence/ and current qualification is QUALIFICATION-AGENTIC18.json. Benchmark
scenes, PRGs, demos, captured images and dependencies are outside this source SDK.

The three stable-publication-only gates test_stable_package.py,
test_documentation.py and test_release_contract.py retain their original stable
assertions. Their development equivalents are verified by the external
tools/audit_development.py; 18 other self-contained public gates run unchanged. The legacy-plus source
ledger check selects the current qualification through RELEASE.json, and the
distribution gate expects this exact development version/prerelease. Their
hash, defaults, historical measurements and negative API assertions are retained.
Do not weaken or relabel the preserved stable tests as development passes.

Optional `-SphereRenderer circles` builds retain the parent clipping divider
and code layout. Supplementary native API validation found a Mode6/1x PAL
budget regression when the larger divider was emitted into that backend. This
is a general feature guard, not a scene/case/multiplier test. The public API
enabled/control PRGs and numeric labels must match stable1.15.1 exactly.

Qualification complete:54 catalog cases at1x/20x/64x,648 matching images,27
existing build blocks and0 new blocks. Fixed index 120.207624,
versus stable1.15.1 117.647645;1.15.0 anchor100. Native SID
music active,128 refresh warm-up,1024 measured refreshes (~20.429s) per run.
Three repetitions per side on4 selected cases; the near-2/1x short-window flag
is resolved separately by three8192-refresh runs per side. Raw original
observations and weights are retained. See QUALIFICATION-AGENTIC18.json and
the external REPORT.html/evidence folder. This remains unpublished development.
