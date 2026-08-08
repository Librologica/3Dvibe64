# Contributing to 3Dvibe64

Thank you for helping improve 3Dvibe64. The project is published as a
noncommercial source-available engine. Before contributing, read [LICENSE](LICENSE)
and [LICENSE-DOCUMENTATION.md](LICENSE-DOCUMENTATION.md).

## Reporting a problem

Open a GitHub issue with:

- the 3Dvibe64 version;
- the JSON scene and complete build command;
- the selected GraphicsMode, camera, viewport, projection and memory layout;
- the exact error message or observed result;
- the 64tass and VICE versions, when relevant;
- the smallest reproducible scene that preserves the problem.

Do not publish security-sensitive details in a normal issue. Follow
[SECURITY.md](SECURITY.md) instead.

## Proposing a change

1. Create a branch from the current maintained branch.
2. Keep changes focused and avoid committing generated PRG, ASM, logs or screenshots.
3. Preserve public JSON and command-line compatibility unless the change explicitly
   proposes a documented versioned contract update.
4. Update Italian and English documentation when public behavior changes.
5. Run `python scripts/test_world_metrics.py`.
6. Run `python scripts/test_release_contract.py`; the full contract requires 64tass
   and VICE x64sc as described in the README.
7. Explain the motivation, implementation and verification in the pull request.

## Contribution licensing

By submitting a contribution, you confirm that you have the right to submit it
and agree that it will be distributed under the same license that governs the
part of the project being changed:

- software, scripts, JSON examples, validation material and generated engine code:
  PolyForm Noncommercial License 1.0.0;
- Markdown documentation and manuals: Creative Commons Attribution-NonCommercial
  4.0 International.

The required author attribution for the original project remains
`librologica.digital`. A contribution does not grant commercial-use rights.
