# Qualification — 1.11.0 distribution correction

## Distribution correction within 1.11.0

New demo projects are excluded, including their source generators, UI,
character artwork, camera routes, launchers and captured/reference assets.
The duplicated 1.10.2 SDK is removed. The original examples from v1.10.2 are
retained. This corrects the existing release; VERSION stays 1.11.0.

Reusable gameplay compilers, validators and bounded assembly emitters remain.
Native gameplay builds require an external project supplied explicitly with
`--project-source`; no demo is reconstructed from bundled default inputs.
The ordinary engine and its existing examples remain directly buildable.
See [GAMEPLAY](GAMEPLAY.en.md), [quick start](QUICKSTART.md) and
[qualification](QUALIFICATION-1.11.0.en.md).

## Verification scope

The current results are recorded in [QUALIFICATION-1.11.0.json](QUALIFICATION-1.11.0.json).
Checks cover explicit project input/early refusal, synthetic schema/graph
contracts, unchanged billboard assembly emission, manifest/file exclusion,
EN/IT links and CLI coverage, and the ordinary package/native contract.
All 80 ordinary runtime/generator files retain the exact 1.10.2 bytes.
Previous example files are retained; their README is restored from v1.10.2.
Private development demos and older official releases remain preserved.

The initial 1.11.0 publication qualified 41 gates and 15 private checkpoint
rebuilds. That record is historical, not a claim that the removed demos are
still distributed or can be rebuilt without external project inputs. The
cleanup reruns changed host/distribution contracts and representative native
builds using explicitly supplied external inputs. Unchanged renderer gates
reuse their prior passing source/runtime identities. There is no new renderer
or FPS claim and no new demo PRG delivered in this correction. Native frame
rates remain specific to the original measured PRG and launch conditions.
Linux and physical hardware are not newly qualified.
